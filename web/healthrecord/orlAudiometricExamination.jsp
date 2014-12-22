<%@page import="be.mxs.common.util.system.Audiometry,
                be.mxs.common.util.system.HearingLoss,
                be.openclinic.system.Healthrecord,
                java.util.*"%>
<%@include file="/includes/validateUser.jsp"%>
<%@page errorPage="/includes/error.jsp"%>

<%=checkPermission("occup.audiometry","select",activeUser)%>
<%=sJSCHARTJS%>
<%=sJSEXCANVAS%>

<%!
    //--- WRITE SELECT ----------------------------------------------------------------------------
    private String writeSelect(SessionContainerWO sessionContainerWO,String sItemType){
        String sItemValue = "";
        if(sessionContainerWO.getCurrentTransactionVO().getTransactionId().intValue() > 0){
            sItemValue = sessionContainerWO.getCurrentTransactionVO().getItemValue(sItemType);
        }

        String sReturn = "<option value=''>-</option>";
        for(int i=0; i<110; i+=10){
            sReturn+= "<option value='"+i+"'";

            if(sItemValue.equals(i+"")){
                sReturn+= " selected";
            }

            sReturn+= ">"+i+"</option>";
        }

        return sReturn;
    }
%>

<form name="transactionForm" id="transactionForm" method="POST" action='<c:url value="/healthrecord/updateTransaction.do"/>?ts=<%=getTs()%>'>
    <bean:define id="transaction" name="be.mxs.webapp.wl.session.SessionContainerFactory.WO_SESSION_CONTAINER" property="currentTransactionVO"/>
	<%=checkPrestationToday(activePatient.personid,false,activeUser,(TransactionVO)transaction)%>
   
    <input type="hidden" id="transactionId" name="currentTransactionVO.<TransactionVO[hashCode=<bean:write name="transaction" scope="page" property="transactionId"/>]>.transactionId" value="<bean:write name="transaction" scope="page" property="transactionId"/>"/>
    <input type="hidden" id="serverId" name="currentTransactionVO.<TransactionVO[hashCode=<bean:write name="transaction" scope="page" property="transactionId"/>]>.serverId" value="<bean:write name="transaction" scope="page" property="serverId"/>"/>
    <input type="hidden" id="transactionType" name="currentTransactionVO.<TransactionVO[hashCode=<bean:write name="transaction" scope="page" property="transactionId"/>]>.transactionType" value="<bean:write name="transaction" scope="page" property="transactionType"/>"/>
    
    <input type="hidden" readonly name="be.mxs.healthrecord.updateTransaction.actionForwardKey" value="/main.do?Page=curative/index.jsp&ts=<%=getTs()%>"/>
    <input type="hidden" readonly name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_TRANSACTION_RESULT" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_TRANSACTION_RESULT" property="value"/>"/>
    <input type="hidden" readonly name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_RECRUITMENT_CONVOCATION_ID" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_RECRUITMENT_CONVOCATION_ID" property="value"/>"/>
    <input type="hidden" readonly name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CONTEXT_DEPARTMENT" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CONTEXT_DEPARTMENT" translate="false" property="value"/>"/>
    <input type="hidden" readonly name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CONTEXT_CONTEXT" translate="false" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CONTEXT_CONTEXT" translate="false" property="value"/>"/>
    <br>

<%-- GRAPH TABLE --------------------------------------------------------------------------------%>
<table width="100%" id="tbltest" height="200">
    <tr>
        <td width="420" style="padding-left:20px">                        
            <%-- MAIN GRAPH --%>
            <table cellpadding="1" cellspacing="0">
                <tr>    
                    <td>			            
                        <canvas id="diagMain" width="400" height="220"></canvas>
			        </td>
			    </tr>
            </table>            
        </td>
        
        <%
            int iAge = MedwanQuery.getInstance().getAge(Integer.parseInt(activePatient.personid));
            String sGender = checkString(activePatient.gender); 
            String sGenderLabelId = "";
                 if(sGender.equalsIgnoreCase("m")) sGenderLabelId = "male";
            else if(sGender.equalsIgnoreCase("f")) sGenderLabelId = "female";
        %> 
        
        <td width="150" nowrap>
            <br><br>
            <font color="red"><b><%=getTran("Web.Occup","medwan.healthrecord.audiometry.OD",sWebLanguage)%></b></font><br/>
            <font color="blue"><b><%=getTran("Web.Occup","medwan.healthrecord.audiometry.OG",sWebLanguage)%></b></font><br/>
            <font color="#000000"><b><%=getTran("openclinic.chuk","audiometry.bony.OD",sWebLanguage)%></b></font><br/>
            <font color="#800080"><b><%=getTran("openclinic.chuk","audiometry.bony.OG",sWebLanguage)%></b></font><br/>
            <font color="#00AA00"><b><%=getTran("Web.Occup","medwan.healthrecord.audiometry.normal",sWebLanguage)%> (<%=getTran("web",sGenderLabelId,sWebLanguage)%>, <%=iAge%> <%=getTran("web","year",sWebLanguage).toLowerCase()%>)</b></font>
        </td>

        <td nowrap style="vertical-align:top;padding-left:20px">
            <%=getTran("Web.Occup","medwan.common.history",sWebLanguage)%>
            <select name="historySelector" class="text" onchange="displayHistories()">
                <option value=""><%=getTranNoLink("web","none",sWebLanguage)%></option>    
                <%
                    String sType,sValue,sOption = "",sDate = "",sTransactionID,sOldTransactionID = "";
                    Vector vAudiometric = Healthrecord.getAudiometricData(activePatient.personid);
                    Iterator iter = vAudiometric.iterator();
                    Hashtable hAudiometric;

                    while(iter.hasNext()){
                        hAudiometric = (Hashtable)iter.next();
                        sTransactionID = (String)hAudiometric.get("transactionid");
                        sType = (String)hAudiometric.get("type");
                        sValue = (String)hAudiometric.get("value");

                        if(!sTransactionID.equals(sOldTransactionID)){
                            if(sOldTransactionID.trim().length() > 0){
                                %><option value="<%=sOption%>"><%=sDate%></option><%
                            }
                            sOldTransactionID = sTransactionID;
                            sDate = ScreenHelper.getSQLDate((java.sql.Date)hAudiometric.get("updatetime"));//ScreenHelper.getSQLDate(Occuprs.getDate("updateTime"));
                            sOption = "";
                        }

                        if(sType.indexOf("BONY") > -1){
                            sType = sType.substring(sType.indexOf("BONY"));
                        }
                        else if(sType.indexOf("RIGHT") > -1){
                            sType = sType.substring(sType.indexOf("RIGHT"));
                        }
                        else if(sType.indexOf("LEFT") > -1){
                            sType = sType.substring(sType.indexOf("LEFT"));
                        }
                        else{
                            sType = "";
                        }

                        if(sType.length() > 0){
                            sOption += (":"+sType + "=" + sValue + ";");
                        }
                    }
                %>
                <option value="<%=sOption%>"><%=sDate%></option>
            </select>
            
            <br><br>
                        
            <%-- HISTORY GRAPH --%>
            <table cellpadding="1" cellspacing="0">
                <tr>                        
                    <td>
                        <canvas id="diagHist" width="250" height="138"></canvas>
                    </td>
			    </tr>
            </table>
        </td>
    </tr>
</table>

<br>

<%=writeHistoryFunctions(((TransactionVO)transaction).getTransactionType(),sWebLanguage)%>
<%=contextHeader(request,sWebLanguage)%>

    <table class="list" width="100%" cellspacing="1">
		<tr>
			<td style="vertical-align:top;padding:0;width:50%" class="admin2">
				<table class="list" width="100%" cellspacing="1" id="tbl1">
				    <%-- DATE --%>
				    <tr>
				        <td class="admin">
				            <a href="javascript:openHistoryPopup();" title="<%=getTranNoLink("Web.Occup","History",sWebLanguage)%>">...</a>&nbsp;
				            <%=getTran("Web.Occup","medwan.common.date",sWebLanguage)%>
				        </td>
				        <td class="admin2">
				            <input type="text" class="text" size="12" maxLength="10" value="<mxs:propertyAccessorI18N name="transaction" scope="page" property="updateTime" formatType="date"/>" name="currentTransactionVO.<TransactionVO[hashCode=<bean:write name="transaction" scope="page" property="transactionId"/>]>.updateTime" id="trandate" OnBlur='checkDate(this)'> <script>writeTranDate();</script>
				        </td>
				    </tr>
				
				    <%-- RIGHT EAR ---------------------------------------------------------------------------------------------------%>
				    <tr>
				        <td class="admin" align="left">
				            <%=getTran("Web.Occup","medwan.healthrecord.audiometry.OD",sWebLanguage)%>
				        </td>
				        <td class="admin2" align="left">
				            <table>
				                <tr>
				                    <td width="1%">0,125</td>
				                    <td width="1%">0,25</td>
				                    <td width="1%">0,5</td>
				                    <td width="1%">1</td>
				                    <td width="1%">2</td>
				                    <td width="1%">4</td>
				                    <td width="1%">8</td>
				                    <td/>
				                </tr>
				                <tr>
				                    <td>
				                        <% SessionContainerWO sessionContainerWO = (SessionContainerWO) SessionContainerFactory.getInstance().getSessionContainerWO(request,SessionContainerWO.class.getName()); %>
				                        <select name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_AUDIOMETRY_RIGHT_0125" property="itemId"/>]>.value" class="text" onChange="setDiag(this);" id="freqSliderR0125">
				                            <%=writeSelect(sessionContainerWO,sPREFIX+"ITEM_TYPE_AUDIOMETRY_RIGHT_0125")%>
				                        </select>
				                    </td>
				                    <td>
				                        <select name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_AUDIOMETRY_RIGHT_025" property="itemId"/>]>.value" class="text" onChange="setDiag(this);" id="freqSliderR0250">
				                            <%=writeSelect(sessionContainerWO,sPREFIX+"ITEM_TYPE_AUDIOMETRY_RIGHT_025")%>
				                        </select>
				                    </td>
				                    <td>
				                        <select name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_AUDIOMETRY_RIGHT_050" property="itemId"/>]>.value" class="text" onChange="setDiag(this);" id="freqSliderR0500">
				                            <%=writeSelect(sessionContainerWO,sPREFIX+"ITEM_TYPE_AUDIOMETRY_RIGHT_050")%>
				                        </select>
				                    </td>
				                    <td>
				                        <select name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_AUDIOMETRY_RIGHT_1" property="itemId"/>]>.value" class="text" onChange="setDiag(this);" id="freqSliderR1000">
				                            <%=writeSelect(sessionContainerWO,sPREFIX+"ITEM_TYPE_AUDIOMETRY_RIGHT_1")%>
				                        </select>
				                    </td>
				                    <td>
				                        <select name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_AUDIOMETRY_RIGHT_2" property="itemId"/>]>.value" class="text" onChange="setDiag(this);" id="freqSliderR2000">
				                            <%=writeSelect(sessionContainerWO,sPREFIX+"ITEM_TYPE_AUDIOMETRY_RIGHT_2")%>
				                        </select>
				                    </td>
				                    <td>
				                        <select name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_AUDIOMETRY_RIGHT_4" property="itemId"/>]>.value" class="text" onChange="setDiag(this);" id="freqSliderR4000">
				                            <%=writeSelect(sessionContainerWO,sPREFIX+"ITEM_TYPE_AUDIOMETRY_RIGHT_4")%>
				                        </select>
				                    </td>
				                    <td>
				                        <select name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_AUDIOMETRY_RIGHT_8" property="itemId"/>]>.value" class="text" onChange="setDiag(this);" id="freqSliderR8000">
				                            <%=writeSelect(sessionContainerWO,sPREFIX+"ITEM_TYPE_AUDIOMETRY_RIGHT_8")%>
				                        </select>
				                    </td>
				                </tr>
				            </table>
				        </td>
				    </tr>
				
				    <%-- LEFT EAR -------------------------------------------------------------------------------%>
				    <tr>
				        <td class="admin" align="left">
				            <%=getTran("Web.Occup","medwan.healthrecord.audiometry.OG",sWebLanguage)%>
				        </td>
				        <td class="admin2" align="left">
				            <table>
				                <tr>
				                    <td width="1%">0,125</td>
				                    <td width="1%">0,25</td>
				                    <td width="1%">0,5</td>
				                    <td width="1%">1</td>
				                    <td width="1%">2</td>
				                    <td width="1%">4</td>
				                    <td width="1%">8</td>
				                    <td/>
				                </tr>
				                <tr>
				                    <td>
				                        <select name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_AUDIOMETRY_LEFT_0125" property="itemId"/>]>.value" class="text" onChange="setDiag(this);" id="freqSliderL0125">
				                            <%=writeSelect(sessionContainerWO,sPREFIX+"ITEM_TYPE_AUDIOMETRY_LEFT_0125")%>
				                        </select>
				                    </td>
				                    <td>
				                        <select name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_AUDIOMETRY_LEFT_025" property="itemId"/>]>.value" class="text" onChange="setDiag(this);" id="freqSliderL0250">
				                            <%=writeSelect(sessionContainerWO,sPREFIX+"ITEM_TYPE_AUDIOMETRY_LEFT_025")%>
				                        </select>
				                    </td>
				                    <td>
				                        <select name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_AUDIOMETRY_LEFT_050" property="itemId"/>]>.value" class="text" onChange="setDiag(this);" id="freqSliderL0500">
				                            <%=writeSelect(sessionContainerWO,sPREFIX+"ITEM_TYPE_AUDIOMETRY_LEFT_050")%>
				                        </select>
				                    </td>
				                    <td>
				                        <select name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_AUDIOMETRY_LEFT_1" property="itemId"/>]>.value" class="text" onChange="setDiag(this);" id="freqSliderL1000">
				                            <%=writeSelect(sessionContainerWO,sPREFIX+"ITEM_TYPE_AUDIOMETRY_LEFT_1")%>
				                        </select>
				                    </td>
				                    <td>
				                        <select name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_AUDIOMETRY_LEFT_2" property="itemId"/>]>.value" class="text" onChange="setDiag(this);" id="freqSliderL2000">
				                            <%=writeSelect(sessionContainerWO,sPREFIX+"ITEM_TYPE_AUDIOMETRY_LEFT_2")%>
				                        </select>
				                    </td>
				                    <td>
				                        <select name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_AUDIOMETRY_LEFT_4" property="itemId"/>]>.value" class="text" onChange="setDiag(this);" id="freqSliderL4000">
				                            <%=writeSelect(sessionContainerWO,sPREFIX+"ITEM_TYPE_AUDIOMETRY_LEFT_4")%>
				                        </select>
				                    </td>
				                    <td>
				                        <select name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_AUDIOMETRY_LEFT_8" property="itemId"/>]>.value" class="text" onChange="setDiag(this);" id="freqSliderL8000">
				                            <%=writeSelect(sessionContainerWO,sPREFIX+"ITEM_TYPE_AUDIOMETRY_LEFT_8")%>
				                        </select>
				                    </td>
				                </tr>
				            </table>
				        </td>
				    </tr>
				
				    <%-- RIGHT EAR - BONY ---------------------------------------------------------------------------%>
				    <tr>
				        <td class="admin" align="left"><%=getTran("openclinic.chuk","audiometry.bony.OD",sWebLanguage)%></td>
				        <td class="admin2" align="left">
				            <table>
				                <tr>
				                    <td width="1%">0,125</td>
				                    <td width="1%">0,25</td>
				                    <td width="1%">0,5</td>
				                    <td width="1%">1</td>
				                    <td width="1%">2</td>
				                    <td width="1%">4</td>
				                    <td width="1%">8</td>
				                    <td/>
				                </tr>
				                <tr>
				                    <td>
				                        <select name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_AUDIOMETRY_BONY_RIGHT_0125" property="itemId"/>]>.value" class="text" onChange="setDiag(this);" id="freqSliderRb0125">
				                            <%=writeSelect(sessionContainerWO,sPREFIX+"ITEM_TYPE_AUDIOMETRY_BONY_RIGHT_0125")%>
				                        </select>
				                    </td>
				                    <td>
				                        <select name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_AUDIOMETRY_BONY_RIGHT_025" property="itemId"/>]>.value" class="text" onChange="setDiag(this);" id="freqSliderRb0250">
				                           <%=writeSelect(sessionContainerWO,sPREFIX+"ITEM_TYPE_AUDIOMETRY_BONY_RIGHT_025")%>
				                        </select>
				                    </td>
				                    <td>
				                        <select name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_AUDIOMETRY_BONY_RIGHT_050" property="itemId"/>]>.value" class="text" onChange="setDiag(this);" id="freqSliderRb0500">
				                            <%=writeSelect(sessionContainerWO,sPREFIX+"ITEM_TYPE_AUDIOMETRY_BONY_RIGHT_050")%>
				                        </select>
				                    </td>
				                    <td>
				                        <select name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_AUDIOMETRY_BONY_RIGHT_1" property="itemId"/>]>.value" class="text" onChange="setDiag(this);" id="freqSliderRb1000">
				                            <%=writeSelect(sessionContainerWO,sPREFIX+"ITEM_TYPE_AUDIOMETRY_BONY_RIGHT_1")%>
				                        </select>
				                    </td>
				                    <td>
				                        <select name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_AUDIOMETRY_BONY_RIGHT_2" property="itemId"/>]>.value" class="text" onChange="setDiag(this);" id="freqSliderRb2000">
				                            <%=writeSelect(sessionContainerWO,sPREFIX+"ITEM_TYPE_AUDIOMETRY_BONY_RIGHT_2")%>
				                        </select>
				                    </td>
				                    <td>
				                        <select name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_AUDIOMETRY_BONY_RIGHT_4" property="itemId"/>]>.value" class="text" onChange="setDiag(this);" id="freqSliderRb4000">
				                            <%=writeSelect(sessionContainerWO,sPREFIX+"ITEM_TYPE_AUDIOMETRY_BONY_RIGHT_4")%>
				                        </select>
				                    </td>
				                    <td>
				                        <select name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_AUDIOMETRY_BONY_RIGHT_8" property="itemId"/>]>.value" class="text" onChange="setDiag(this);" id="freqSliderRb8000">
				                            <%=writeSelect(sessionContainerWO,sPREFIX+"ITEM_TYPE_AUDIOMETRY_BONY_RIGHT_8")%>
				                        </select>
				                    </td>
				                </tr>
				            </table>
				        </td>
				    </tr>
				
				    <%-- LEFT EAR - BONY ----------------------------------------------------------------------------%>
				    <tr>
				        <td class="admin" align="left"><%=getTran("openclinic.chuk","audiometry.bony.OG",sWebLanguage)%></td>
				        <td class="admin2" align="left">
				            <table>
				                <tr>
				                    <td width="1%">0,125</td>
				                    <td width="1%">0,25</td>
				                    <td width="1%">0,5</td>
				                    <td width="1%">1</td>
				                    <td width="1%">2</td>
				                    <td width="1%">4</td>
				                    <td width="1%">8</td>
				                    <td/>
				                </tr>
				                <tr>
				                    <td>
				                        <select name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_AUDIOMETRY_BONY_LEFT_0125" property="itemId"/>]>.value" class="text" onChange="setDiag(this);" id="freqSliderLb0125">
				                            <%=writeSelect(sessionContainerWO,sPREFIX+"ITEM_TYPE_AUDIOMETRY_BONY_LEFT_0125")%>
				                        </select>
				                    </td>
				                    <td>
				                        <select name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_AUDIOMETRY_BONY_LEFT_025" property="itemId"/>]>.value" class="text" onChange="setDiag(this);" id="freqSliderLb0250">
				                            <%=writeSelect(sessionContainerWO,sPREFIX+"ITEM_TYPE_AUDIOMETRY_BONY_LEFT_025")%>
				                        </select>
				                    </td>
				                    <td>
				                        <select name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_AUDIOMETRY_BONY_LEFT_050" property="itemId"/>]>.value" class="text" onChange="setDiag(this);" id="freqSliderLb0500">
				                            <%=writeSelect(sessionContainerWO,sPREFIX+"ITEM_TYPE_AUDIOMETRY_BONY_LEFT_050")%>
				                        </select>
				                    </td>
				                    <td>
				                        <select name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_AUDIOMETRY_BONY_LEFT_1" property="itemId"/>]>.value" class="text" onChange="setDiag(this);" id="freqSliderLb1000">
				                            <%=writeSelect(sessionContainerWO,sPREFIX+"ITEM_TYPE_AUDIOMETRY_BONY_LEFT_1")%>
				                        </select>
				                    </td>
				                    <td>
				                        <select name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_AUDIOMETRY_BONY_LEFT_2" property="itemId"/>]>.value" class="text" onChange="setDiag(this);" id="freqSliderLb2000">
				                            <%=writeSelect(sessionContainerWO,sPREFIX+"ITEM_TYPE_AUDIOMETRY_BONY_LEFT_2")%>
				                        </select>
				                    </td>
				                    <td>
				                        <select name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_AUDIOMETRY_BONY_LEFT_4" property="itemId"/>]>.value" class="text" onChange="setDiag(this);" id="freqSliderLb4000">
				                            <%=writeSelect(sessionContainerWO,sPREFIX+"ITEM_TYPE_AUDIOMETRY_BONY_LEFT_4")%>
				                        </select>
				                    </td>
				                    <td>
				                        <select name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_AUDIOMETRY_BONY_LEFT_8" property="itemId"/>]>.value" class="text" onChange="setDiag(this);" id="freqSliderLb8000">
				                            <%=writeSelect(sessionContainerWO,sPREFIX+"ITEM_TYPE_AUDIOMETRY_BONY_LEFT_8")%>
				                        </select>
				                    </td>
				                </tr>
				            </table>
				        </td>
				    </tr>
				
				    <%-- personal history --%>
				    <tr>
				        <td class="admin"><%=getTran("Web.Occup","personal.audiometric.history",sWebLanguage)%></td>
				        <td class="admin2">
				            <textarea onKeyup="resizeTextarea(this,10);limitChars(this,255);" cols="80" rows="2" class="text" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_AUDIOMETRY_PERSONAL_HISTORY" property="itemId"/>]>.value"><%=ScreenHelper.getLastItem(request,sPREFIX+"ITEM_TYPE_AUDIOMETRY_PERSONAL_HISTORY").getValue()%></textarea>
				        </td>
				    </tr>
				
				    <%-- family history --%>
				    <tr>
				        <td class="admin"><%=getTran("Web.Occup","family.audiometric.history",sWebLanguage)%></td>
				        <td class="admin2">
				            <textarea onKeyup="resizeTextarea(this,10);limitChars(this,255);" cols="80" rows="2" class="text" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_AUDIOMETRY_FAMILY_HISTORY" property="itemId"/>]>.value"><%=ScreenHelper.getLastItem(request,sPREFIX+"ITEM_TYPE_AUDIOMETRY_FAMILY_HISTORY").getValue()%></textarea>
				        </td>
				    </tr>
				</table>
			</td>
			
			<%-- DIAGNOSES --%>
			<td style="vertical-align:top;padding:0" class="admin2">
		        <%ScreenHelper.setIncludePage(customerInclude("healthrecord/diagnosesEncoding.jsp"),pageContext);%>
			</td>
		</tr>
    </table>

	<%-- BUTTONS --%>
	<%=ScreenHelper.alignButtonsStart()%>
        <%=getButtonsHtml(request,activeUser,activePatient,"occup.audiometry",sWebLanguage)%>
	<%=ScreenHelper.alignButtonsStop()%>

    <%=ScreenHelper.contextFooter(request)%>
</form>

<script>

<%-- SUBMIT FORM --%>
function submitForm(){
  if(document.getElementById('encounteruid').value==''){
    alertDialog("web","no.encounter.linked");
    searchEncounter();
	}	
  else{
	  document.getElementById("buttonsDiv").style.visibility = "hidden";	  
	  var temp = Form.findFirstElement(transactionForm);
	  <% out.print(takeOverTransaction(sessionContainerWO,activeUser,"document.transactionForm.submit();")); %>
  }
}

function searchEncounter(){
  openPopup("/_common/search/searchEncounter.jsp&ts=<%=getTs()%>&VarCode=currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CONTEXT_ENCOUNTERUID" property="itemId"/>]>.value&VarText=&FindEncounterPatient=<%=activePatient.personid%>");
}

if(document.getElementById('encounteruid').value==''){
  alertDialog("web","no.encounter.linked");
  searchEncounter();
}	
</script>

<%
    HearingLoss hearingLoss = Audiometry.calculateHearingloss(iAge,sGender); 
%>

<script>
var diagMain, diagHist;

Chart.defaults.global.showTooltips = true;
Chart.defaults.global.animation = false;
Chart.defaults.global.scaleOverride = true;
Chart.defaults.global.scaleSteps = 10;
Chart.defaults.global.scaleStepWidth = 10;
Chart.defaults.global.scaleStartValue = -100;

var options = {
  scaleShowGridLines : true,
  scaleGridLineColor : "rgba(0,0,0,.05)",
  scaleGridLineWidth : 1,
  bezierCurve : true,
  bezierCurveTension : 0.2,
  pointDot : true,
  pointDotRadius : 3,
  pointDotStrokeWidth : 1,
  pointHitDetectionRadius : 16,
  datasetStroke : true,
  datasetStrokeWidth : 2,
  datasetFill : true   
};

window.onload = function(){
  //***** MAIN *****
  var data = {
    labels: ["125","250","500","1k","2k","4k","8k"],
    datasets: [
      {
        label: "RE",
        fillColor: "rgba(250,250,250,0)",
        strokeColor: "#CC3333",
        pointColor: "#CC3333",
	    pointHighlightStroke: "#CC3333",
        pointStrokeColor: "#fff",
	    data: [getSliderValue("freqSliderR0125"),
	           getSliderValue("freqSliderR0250"),
	           getSliderValue("freqSliderR0500"),
	           getSliderValue("freqSliderR1000"),
	           getSliderValue("freqSliderR2000"),
	           getSliderValue("freqSliderR4000"),
	           getSliderValue("freqSliderR8000")]
      },
      {
        label: "LE",
        fillColor: "rgba(250,250,250,0)",
        strokeColor: "#0000AA",
        pointColor: "#0000AA",
	    pointHighlightStroke: "#0000AA",
        pointStrokeColor: "#fff",
	    data: [getSliderValue("freqSliderL0125"),
	           getSliderValue("freqSliderL0250"),
	           getSliderValue("freqSliderL0500"),
	           getSliderValue("freqSliderL1000"),
	           getSliderValue("freqSliderL2000"),
	           getSliderValue("freqSliderL4000"),
	           getSliderValue("freqSliderL8000")]
      },
      {
        label: "RE Bony",
        fillColor: "rgba(250,250,250,0)",
        strokeColor: "#000000",
        pointColor: "#000000",
  	    pointHighlightStroke: "#000000",
        pointStrokeColor: "#fff",
	    data: [getSliderValue("freqSliderRb0125"),
	           getSliderValue("freqSliderRb0250"),
	           getSliderValue("freqSliderRb0500"),
	           getSliderValue("freqSliderRb1000"),
	           getSliderValue("freqSliderRb2000"),
	           getSliderValue("freqSliderRb4000"),
	           getSliderValue("freqSliderRb8000")]
      },
      {
        label: "LE Bony",
        fillColor: "rgba(250,250,250,0)",
        strokeColor: "#8000AA",
        pointColor: "#8000AA",
    	pointHighlightStroke: "#8000AA",
        pointStrokeColor: "#fff",
	    data: [getSliderValue("freqSliderLb0125"),
	           getSliderValue("freqSliderLb0250"),
	           getSliderValue("freqSliderLb0500"),
	           getSliderValue("freqSliderLb1000"),
	           getSliderValue("freqSliderLb2000"),
	           getSliderValue("freqSliderLb4000"),
	           getSliderValue("freqSliderLb8000")]
      },
	  {
  	    label: "Normal",
  	    fillColor: "rgba(250,250,250,0)",
  	    strokeColor: "#00AA00",
  	    pointColor: "#00AA00",
  	    pointHighlightStroke: "#00AA00",
  	    pointStrokeColor: "#fff",
  	    data: [-1*<%=Math.round(hearingLoss.getLoss0125()*1e3)/1e3%>,
  	           -1*<%=Math.round(hearingLoss.getLoss0250()*1e3)/1e3%>,
  	           -1*<%=Math.round(hearingLoss.getLoss0500()*1e3)/1e3%>,
  	           -1*<%=Math.round(hearingLoss.getLoss1000()*1e3)/1e3%>,
  	           -1*<%=Math.round(hearingLoss.getLoss2000()*1e3)/1e3%>,
  	           -1*<%=Math.round(hearingLoss.getLoss4000()*1e3)/1e3%>,
  	           -1*<%=Math.round(hearingLoss.getLoss8000()*1e3)/1e3%>]
        }
    ]
  };	  

  var ctx = document.getElementById("diagMain").getContext("2d");		
  diagMain = new Chart(ctx).Line(data,options);
		
  //***** HIST *****
  var data = {
    labels: ["125","250","500","1k","2k","4k","8k"],
	datasets: [
      {
        label: "RE history",
        fillColor: "rgba(250,250,250,0)",
        strokeColor: "#CC3333",
        pointColor: "#CC3333",
  	    pointHighlightStroke: "#CC3333",
        pointStrokeColor: "#fff",
 	    data: [null,null,null,null,null,null,null]
      },
      {
        label: "LE history",
        fillColor: "rgba(250,250,250,0)",
        strokeColor: "#0000AA",
        pointColor: "#0000AA",
  	    pointHighlightStroke: "#0000AA",
        pointStrokeColor: "#fff",
 	    data: [null,null,null,null,null,null,null]
      },
      {
        label: "RE Bony history",
        fillColor: "rgba(250,250,250,0)",
        strokeColor: "#000000",
        pointColor: "#000000",
        pointHighlightStroke: "#000000",
        pointStrokeColor: "#fff",
 	    data: [null,null,null,null,null,null,null]
      },
      {
        label: "LE Bony history",
        fillColor: "rgba(250,250,250,0)",
        strokeColor: "#8000AA",
        pointColor: "#8000AA",
      	pointHighlightStroke: "#8000AA",
        pointStrokeColor: "#fff",
 	    data: [null,null,null,null,null,null,null]
      }
    ]
  };	  

  var options = {
	showTooltips : false,
	animation : false,
	scaleOverride : true,
	scaleSteps : 10,
	scaleStepWidth : 10,
	scaleStartValue : -100,
	
    scaleShowGridLines : true,
    scaleGridLineColor : "rgba(0,0,0,.05)",
    scaleGridLineWidth : 1,
    bezierCurve : true,
    bezierCurveTension : 0.2,
    pointDot : true,
    pointDotRadius : 2,
    pointDotStrokeWidth : 1,
    pointHitDetectionRadius : 12,
    datasetStroke : true,
    datasetStrokeWidth : 1,
    datasetFill : true   
  };
  
  var ctx = document.getElementById("diagHist").getContext("2d");		
  diagHist = new Chart(ctx).Line(data,options);
  
  displayHistories();
}

<%-- GET SLIDER VALUE --%>
function getSliderValue(sliderId){
  var slider = document.getElementById(sliderId);
  if(slider){
	if(slider.value.length > 0){
	  if(slider.value=="-"){
		return null;
	  }
	  else{
        return -1*slider.value;
	  }
	}
	else{
      return null;
	}
  }
}
	
<%-- SET DIAG --%>
function setDiag(freqSlider){
  var sBony = freqSlider.id.substr(("freqSlider").length+1,1); // b ?
  var sLorR = freqSlider.id.substr(("freqSlider").length,1); // L or R
  var sFreq = freqSlider.id.substring(("freqSlider").length+1);

  var possibleFreqs = ["0125","0250","0500","1000","2000","4000","8000"];
  var diagram = eval("diagMain");
  
  for(var i=0; i<possibleFreqs.length; i++){
    if(freqSlider.id.toLowerCase()==("freqSlider"+sLorR+(sBony=="b"?"b":"")+possibleFreqs[i]).toLowerCase()){
      diagram.datasets[getDataSetIdx(sLorR,sBony)].points[i].value = getSliderValue(freqSlider.id);    
    }
  }

  diagram.update();
}

<%-- GET DATASET IDX --%>
function getDataSetIdx(sLorR,sBony){
  var idx = -1;
  
  if(sBony=="b"){
	     if(sLorR=="R") idx = 2; // Rb
	else if(sLorR=="L") idx = 3; // Lb
  }
  else{
         if(sLorR=="R") idx = 0; // R
    else if(sLorR=="L") idx = 1; // L
  }
  
  return idx;
}

<%-- DISPLAY HISTORIES --%>
function displayHistories(){
  if(document.all["historySelector"]!=null){
    if(document.all["historySelector"].selectedIndex > 0){
      displayHistory("RIGHT");
      displayHistory("LEFT");
      displayHistory("BONY_RIGHT");
      displayHistory("BONY_LEFT");
    }
    else{
      hideHistory();
    }
  }
}

<%-- HIDE HISTORY --%>
function hideHistory(){  
  for(var i=0; i<diagHist.datasets[1].points.length; i++){
    diagHist.datasets[0].points[i].value = null;
	diagHist.datasets[1].points[i].value = null;
	diagHist.datasets[2].points[i].value = null;
	diagHist.datasets[3].points[i].value = null;
  }
  diagHist.update();
}

<%-- DISPLAY HISTORY --%>
var sHistValues;

function displayHistory(sItemPrefix){
  var idx = getDataSetIdxByItemPrefix(sItemPrefix);
  sHistValues = document.all["historySelector"].value;
  var possibleFreqs = ["0125","025","050","1","2","4","8"];
  
  for(var i=0; i<possibleFreqs.length; i++){
    var tmpValue = getHist(sItemPrefix+"_"+possibleFreqs[i]);
    if(tmpValue.length > 0){
      if(tmpValue=="-"){
        diagHist.datasets[idx].points[i].value = null;
      }
      else{
    	diagHist.datasets[idx].points[i].value = -1*tmpValue;
      }
    }
    else{
      diagHist.datasets[idx].points[i].value = null;
    }
  }  
  diagHist.update();
}

<%-- GET DATASET IDX BY ITEM PREFIX --%>
function getDataSetIdxByItemPrefix(sItemPrefix){
  var idx = -1;
  
       if(sItemPrefix=="RIGHT") idx = 0; // R
  else if(sItemPrefix=="LEFT") idx = 1; // L
  else if(sItemPrefix=="BONY_RIGHT") idx = 2; // Rb
  else if(sItemPrefix=="BONY_LEFT") idx = 3; // Lb
    
  return idx;
}

<%-- GET HIST --%>
<%-- parse value of specified item from value of selected history option --%>
function getHist(sItemName){
  var sValue = "";
  if(sHistValues.indexOf(sItemName) > -1){
	  sValue = sHistValues.substring(sHistValues.indexOf(sItemName)+sItemName.length+1); // at position of start of value
  }

  if(sValue.length==0 || sValue.indexOf("=")==0){
    sValue = "";
  }
  else{
    sValue = sValue.substring(0,sValue.indexOf(";")); // until next value
  }

  return sValue;
}
</script>

<%=writeJSButtons("transactionForm","saveButton")%>