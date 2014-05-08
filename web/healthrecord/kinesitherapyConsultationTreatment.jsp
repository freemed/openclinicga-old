<%@page import="java.util.Hashtable,
                be.openclinic.medical.Diagnosis"%>
<%@include file="/includes/validateUser.jsp"%>
<%@page errorPage="/includes/error.jsp"%>
<%=sJSSORTTABLE%>

<%=checkPermission("occup.kinesitherapy.consultation.treatment","select",activeUser)%>

<%!
    //--- GET ITEM TYPE ---------------------------------------------------------------------------
    private StringBuffer addSeance(int iTotal, String sDate, String sHour, 
    		                       String sTreatment1, String sTreatment2, String sTreatment3, String sWebLanguage){
        StringBuffer sTmp = new StringBuffer();

        if(sTreatment1.length() > 0){
            sTreatment1 = getTran("physiotherapy.act",sTreatment1,sWebLanguage);
        }

        if(sTreatment2.length() > 0){
            sTreatment2 = getTran("physiotherapy.act",sTreatment2,sWebLanguage);
        }

        if(sTreatment3.length() > 0){
            sTreatment3 = getTran("physiotherapy.act",sTreatment3,sWebLanguage);
        }

        sTmp.append(
            "<tr id='rowSeance"+iTotal+"' class='list'>"+
              "<td>"+
                "<a href='javascript:deleteSeance(rowSeance"+iTotal+")'><img src='"+sCONTEXTPATH+"/_img/icon_delete.gif' alt='"+getTranNoLink("Web.Occup","medwan.common.delete",sWebLanguage)+"' border='0'></a> "+
                "<a href='javascript:editSeance(rowSeance"+iTotal+")'><img src='"+sCONTEXTPATH+"/_img/icon_edit.gif' alt='"+getTranNoLink("Web.Occup","medwan.common.edit",sWebLanguage)+"' border='0'></a>"+
              "</td>"+
              "<td>&nbsp;"+sDate+"</td>"+
              "<td>&nbsp;"+sHour+"</td>"+
              "<td>&nbsp;"+sTreatment1+"</td>"+
              "<td>&nbsp;"+sTreatment2+"</td>"+
              "<td>&nbsp;"+sTreatment3+"</td>"+
              "<td>"+
              "</td>"+
            "</tr>"
        );

        return sTmp;
    }
%>

<form id="transactionForm" name="transactionForm" method="POST" action='<c:url value="/healthrecord/updateTransaction.do"/>?ts=<%=getTs()%>' onclick="setSaveButton(event);" onkeyup="setSaveButton(event);">
    <bean:define id="transaction" name="be.mxs.webapp.wl.session.SessionContainerFactory.WO_SESSION_CONTAINER" property="currentTransactionVO"/>
	<%=checkPrestationToday(activePatient.personid,false,activeUser,(TransactionVO)transaction)%>

    <input type="hidden" id="transactionId" name="currentTransactionVO.<TransactionVO[hashCode=<bean:write name="transaction" scope="page" property="transactionId"/>]>.transactionId" value="<bean:write name="transaction" scope="page" property="transactionId"/>"/>
    <input type="hidden" id="serverId" name="currentTransactionVO.<TransactionVO[hashCode=<bean:write name="transaction" scope="page" property="transactionId"/>]>.serverId" value="<bean:write name="transaction" scope="page" property="serverId"/>"/>
    <input type="hidden" id="transactionType" name="currentTransactionVO.<TransactionVO[hashCode=<bean:write name="transaction" scope="page" property="transactionId"/>]>.transactionType" value="<bean:write name="transaction" scope="page" property="transactionType"/>"/>

    <input type="hidden" readonly name="be.mxs.healthrecord.updateTransaction.actionForwardKey" value="/main.do?Page=curative/index.jsp&ts=<%=getTs()%>"/>
    <input type="hidden" readonly name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CONTEXT_DEPARTMENT" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CONTEXT_DEPARTMENT" translate="false" property="value"/>"/>
    <input type="hidden" readonly name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CONTEXT_CONTEXT" translate="false" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CONTEXT_CONTEXT" translate="false" property="value"/>"/>

    <%=writeHistoryFunctions(((TransactionVO)transaction).getTransactionType(),sWebLanguage)%>
    <%=contextHeader(request,sWebLanguage)%>

    <%
        StringBuffer sDivSeances = new StringBuffer(),
                     sSeances    = new StringBuffer();
        String[] sAct = new String[9];
        String sActAutre, sStartDate, sEndDate;

        TransactionVO tran = (TransactionVO)transaction;
        
        sSeances.append(getItemType(tran.getItems(),sPREFIX+"ITEM_TYPE_KINESITHERAPY_CONSULTATION_TREATMENT_SEANCE1"));
        sSeances.append(getItemType(tran.getItems(),sPREFIX+"ITEM_TYPE_KINESITHERAPY_CONSULTATION_TREATMENT_SEANCE2"));
        sSeances.append(getItemType(tran.getItems(),sPREFIX+"ITEM_TYPE_KINESITHERAPY_CONSULTATION_TREATMENT_SEANCE3"));
        sSeances.append(getItemType(tran.getItems(),sPREFIX+"ITEM_TYPE_KINESITHERAPY_CONSULTATION_TREATMENT_SEANCE4"));
        sSeances.append(getItemType(tran.getItems(),sPREFIX+"ITEM_TYPE_KINESITHERAPY_CONSULTATION_TREATMENT_SEANCE5"));

        sAct[0] = getItemType(tran.getItems(),sPREFIX+"ITEM_TYPE_KINESITHERAPY_CONSULTATION_TREATMENT_ACT1");
        sAct[1] = getItemType(tran.getItems(),sPREFIX+"ITEM_TYPE_KINESITHERAPY_CONSULTATION_TREATMENT_ACT2");
        sAct[2] = getItemType(tran.getItems(),sPREFIX+"ITEM_TYPE_KINESITHERAPY_CONSULTATION_TREATMENT_ACT3");
        sAct[3] = getItemType(tran.getItems(),sPREFIX+"ITEM_TYPE_KINESITHERAPY_CONSULTATION_TREATMENT_ACT4");
        sAct[4] = getItemType(tran.getItems(),sPREFIX+"ITEM_TYPE_KINESITHERAPY_CONSULTATION_TREATMENT_ACT5");
        sAct[5] = getItemType(tran.getItems(),sPREFIX+"ITEM_TYPE_KINESITHERAPY_CONSULTATION_TREATMENT_ACT6");
        sAct[6] = getItemType(tran.getItems(),sPREFIX+"ITEM_TYPE_KINESITHERAPY_CONSULTATION_TREATMENT_ACT7");
        sAct[7] = getItemType(tran.getItems(),sPREFIX+"ITEM_TYPE_KINESITHERAPY_CONSULTATION_TREATMENT_ACT8");
        sAct[8] = getItemType(tran.getItems(),sPREFIX+"ITEM_TYPE_KINESITHERAPY_CONSULTATION_TREATMENT_ACT9");

        sActAutre  = tran.getItemValue(sPREFIX+"ITEM_TYPE_KINESITHERAPY_CONSULTATION_TREATMENT_ACT_AUTRE");
        sStartDate = tran.getItemValue(sPREFIX+"ITEM_TYPE_KINESITHERAPY_CONSULTATION_TREATMENT_STARTDATE");
        sEndDate   = tran.getItemValue(sPREFIX+"ITEM_TYPE_KINESITHERAPY_CONSULTATION_TREATMENT_ENDDATE");

        int iSeancesTotal = 1;
        if(sSeances.indexOf("£")>-1){
            StringBuffer sTmpSeances = sSeances;
            String sTmpDate, sTmpHeure, sTmpTreatment1, sTmpTreatment2, sTmpTreatment3;
            sSeances = new StringBuffer();

            while(sTmpSeances.toString().toLowerCase().indexOf("$")>-1){
                sTmpDate  = "";
                sTmpHeure = "";
                sTmpTreatment1 = "";
                sTmpTreatment2 = "";
                sTmpTreatment3 = "";

                if(sTmpSeances.toString().toLowerCase().indexOf("£")>-1){
                    sTmpDate = sTmpSeances.substring(0,sTmpSeances.toString().toLowerCase().indexOf("£"));
                    sTmpDate = ScreenHelper.convertDate(sTmpDate);
                    sTmpSeances = new StringBuffer(sTmpSeances.substring(sTmpSeances.toString().toLowerCase().indexOf("£")+1));
                }

                if(sTmpSeances.toString().toLowerCase().indexOf("£")>-1){
                    sTmpHeure = sTmpSeances.substring(0,sTmpSeances.toString().toLowerCase().indexOf("£"));
                    sTmpSeances = new StringBuffer(sTmpSeances.substring(sTmpSeances.toString().toLowerCase().indexOf("£")+1));
                }

                if(sTmpSeances.toString().toLowerCase().indexOf("£")>-1){
                    sTmpTreatment1 = sTmpSeances.substring(0,sTmpSeances.toString().toLowerCase().indexOf("£"));
                    sTmpSeances = new StringBuffer(sTmpSeances.substring(sTmpSeances.toString().toLowerCase().indexOf("£")+1));
                }

                if(sTmpSeances.toString().toLowerCase().indexOf("£")>-1){
                    sTmpTreatment2 = sTmpSeances.substring(0,sTmpSeances.toString().toLowerCase().indexOf("£"));
                    sTmpSeances = new StringBuffer(sTmpSeances.substring(sTmpSeances.toString().toLowerCase().indexOf("£")+1));
                }

                if(sTmpSeances.toString().toLowerCase().indexOf("$")>-1){
                    sTmpTreatment3 = sTmpSeances.substring(0,sTmpSeances.toString().toLowerCase().indexOf("$"));
                    sTmpSeances = new StringBuffer(sTmpSeances.substring(sTmpSeances.toString().toLowerCase().indexOf("$")+1));
                }

                sSeances.append("rowSeance"+iSeancesTotal+"="+sTmpDate+"£"+sTmpHeure+"£"+sTmpTreatment1+"£"+sTmpTreatment2+"£"+sTmpTreatment3+"$");
                sDivSeances.append(addSeance(iSeancesTotal, sTmpDate, sTmpHeure, sTmpTreatment1,sTmpTreatment2,sTmpTreatment3,sWebLanguage));
                iSeancesTotal++;
            }
        }
    %>
    <table class="list" cellspacing="1" cellpadding="0" width="100%">
        <%-- DATE --%>
        <tr>
            <td class="admin" width="<%=sTDAdminWidth%>">
                <a href="javascript:openHistoryPopup();" title="<%=getTranNoLink("Web.Occup","History",sWebLanguage)%>">...</a>&nbsp;
                <%=getTran("Web.Occup","medwan.common.date",sWebLanguage)%>
            </td>
            <td class="admin2" colspan="5">
                <input type="text" class="text" size="12" maxLength="10" name="currentTransactionVO.<TransactionVO[hashCode=<bean:write name="transaction" scope="page" property="transactionId"/>]>.updateTime" value="<mxs:propertyAccessorI18N name="transaction" scope="page" property="updateTime" formatType="date" format="dd-mm-yyyy"/>" id="trandate" OnBlur='checkDate(this)'>
                <script>writeTranDate();</script>
            </td>
        </tr>

        <%-- CONTEXT --%>
        <tr>
            <td class="admin"><%=getTran("openclinic.chuk","context",sWebLanguage)%></td>
            <td class="admin2">
                <input id="rbcontextconsultation" <%=setRightClick("ITEM_TYPE_KINESITHERAPY_CONSULTATION_TREATMENT_CONTEXT")%>  onDblClick="uncheckRadio(this);"type="radio" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_KINESITHERAPY_CONSULTATION_TREATMENT_CONTEXT" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_KINESITHERAPY_CONSULTATION_TREATMENT_CONTEXT;value=kine.treatment.consultation" property="value" outputString="checked"/> value="kine.treatment.consultation"/>
                &nbsp;<%=getLabel("web.occup","kine.treatment.consultation",sWebLanguage,"rbcontextconsultation")%>
                &nbsp;<input id="rbcontexthospitalized" <%=setRightClick("ITEM_TYPE_KINESITHERAPY_CONSULTATION_TREATMENT_CONTEXT")%>  onDblClick="uncheckRadio(this);"type="radio" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_KINESITHERAPY_CONSULTATION_TREATMENT_CONTEXT" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_KINESITHERAPY_CONSULTATION_TREATMENT_CONTEXT;value=kine.treatment.hospitalized" property="value" outputString="checked"/> value="kine.treatment.hospitalized"/>
                &nbsp;<%=getLabel("web.occup","kine.treatment.hospitalized",sWebLanguage,"rbcontexthospitalized")%>
            </td>
        </tr>

        <%-- MEDICAL HISTORY --%>
        <tr>
            <td class="admin"><%=getTran("openclinic.chuk","medical.history",sWebLanguage)%></td>
            <td class="admin2">
                <textarea onKeyup="resizeTextarea(this,10);limitChars(this,255);" <%=setRightClick("ITEM_TYPE_KINESITHERAPY_CONSULTATION_TREATMENT_MEDICAL_HISTORY")%> class="text" cols="50" rows="2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_KINESITHERAPY_CONSULTATION_TREATMENT_MEDICAL_HISTORY" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_KINESITHERAPY_CONSULTATION_TREATMENT_MEDICAL_HISTORY" property="value"/></textarea>
            </td>
        </tr>

        <%-- PHYSIO THERAPY --%>
        <tr>
            <td class="admin"><%=getTran("openclinic.chuk","physio.therapy",sWebLanguage)%></td>
            <td class="admin2">
                <textarea onKeyup="resizeTextarea(this,10);limitChars(this,255);" <%=setRightClick("ITEM_TYPE_KINESITHERAPY_CONSULTATION_TREATMENT_PHYSIO_THERAPY")%> class="text" cols="50" rows="2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_KINESITHERAPY_CONSULTATION_TREATMENT_PHYSIO_THERAPY" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_KINESITHERAPY_CONSULTATION_TREATMENT_PHYSIO_THERAPY" property="value"/></textarea>
            </td>
        </tr>

        <%-- ICPC / ICD10 --%>
        <tr>
            <td class="admin"><a href="javascript:openPopup('healthrecord/findICPC.jsp&ts=<%=getTs()%>&patientuid=<%=activePatient.personid %>')"><%=getTran("openclinic.chuk","diagnostic",sWebLanguage)%> <%=getTran("Web.Occup","ICPC-2",sWebLanguage)%>/<%=getTran("Web.Occup","ICD-10",sWebLanguage)%></a></td>
            <td id='icpccodes' class="admin2">
                <%
                    SessionContainerWO sessionContainerWO = (SessionContainerWO) SessionContainerFactory.getInstance().getSessionContainerWO(request, SessionContainerWO.class.getName());
                    TransactionVO curTran = sessionContainerWO.getCurrentTransactionVO();
                    Iterator items = curTran.getItems().iterator();
                    ItemVO item;

                    String sReferenceUID = curTran.getServerId()+"."+curTran.getTransactionId();
                    String sReferenceType = "Transaction";
                    Hashtable hDiagnoses = Diagnosis.getDiagnosesByReferenceUID(sReferenceUID, sReferenceType);
                    Hashtable hDiagnosisInfo;
                    String sCode, sGravity, sCertainty;

                    while(items.hasNext()){
                        item = (ItemVO)items.next();
                        
                        if(item.getType().indexOf("ICPCCode") == 0){
                            sCode = item.getType().substring("ICPCCode".length(), item.getType().length());
                            
                            hDiagnosisInfo = (Hashtable) hDiagnoses.get(sCode);
                            if(hDiagnosisInfo != null){
                                sGravity = (String) hDiagnosisInfo.get("Gravity");
                                sCertainty = (String) hDiagnosisInfo.get("Certainty");

	                            %>
	                              <span id="ICPCCode<%=item.getItemId()%>">
	                                  <img src="<c:url value='/_img/icon_delete.gif'/>" onclick="document.getElementById('ICPCCode<%=item.getItemId()%>').innerHTML='';"/><input type='hidden' name='ICPCCode<%=item.getType().replaceAll("ICPCCode","")%>' value="<%=item.getValue().trim()%>"/><input type='hidden' name='GravityICPCCode<%=item.getType().replaceAll("ICPCCode","")%>' value="<%=sGravity%>"/><input type='hidden' name='CertaintyICPCCode<%=item.getType().replaceAll("ICPCCode","")%>' value="<%=sCertainty%>"/>
	                                  <%=item.getType().replaceAll("ICPCCode","")%>&nbsp;<%=MedwanQuery.getInstance().getCodeTran(item.getType().trim(),sWebLanguage)%> <%=item.getValue().trim()%> G:<%=sGravity %>/C:<%=sCertainty %>
	                                  <br>
	                              </span>
	                            <%
                            }
                        }
                        else if(item.getType().indexOf("ICD10Code")==0){
                            sCode = item.getType().substring("ICD10Code".length(),item.getType().length());
                            hDiagnosisInfo = (Hashtable)hDiagnoses.get(sCode);
                            if(hDiagnosisInfo != null){
                                sGravity = (String) hDiagnosisInfo.get("Gravity");
                                sCertainty = (String) hDiagnosisInfo.get("Certainty");

	                            %>
	                              <span id='ICD10Code<%=item.getItemId()%>'>
	                                  <img src='<c:url value="/_img/icon_delete.gif"/>' onclick="document.getElementById('ICD10Code<%=item.getItemId()%>').innerHTML='';"/><input type='hidden' name='ICD10Code<%=item.getType().replaceAll("ICD10Code","")%>' value='<%=item.getValue().trim()%>'/><input type='hidden' name='GravityICD10Code<%=item.getType().replaceAll("ICD10Code","")%>' value="<%=sGravity%>"/><input type='hidden' name='CertaintyICD10Code<%=item.getType().replaceAll("ICD10Code","")%>' value="<%=sCertainty%>"/>
	                                  <%=item.getType().replaceAll("ICD10Code","")%>&nbsp;<%=MedwanQuery.getInstance().getCodeTran(item.getType().trim(),sWebLanguage)%> <%=item.getValue().trim()%> G:<%=sGravity %>/C:<%=sCertainty %>
	                                  <br>
	                              </span>
	                            <%
                            }
                        }
                    }
                %>
            </td>
        </tr>

        <%-- NUMBER OF MEETINGS --%>
        <tr>
            <td class="admin"><%=getTran("openclinic.chuk","nr.of.meetings",sWebLanguage)%></td>
            <td class="admin2">
                <input type="text" class="text" <%=setRightClick("ITEM_TYPE_KINESITHERAPY_CONSULTATION_TREATMENT_NR_OF_MEETINGS")%> name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_KINESITHERAPY_CONSULTATION_TREATMENT_NR_OF_MEETINGS" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_KINESITHERAPY_CONSULTATION_TREATMENT_NR_OF_MEETINGS" property="value"/>" onBlur="isNumber(this);" size="5"/>
            </td>
        </tr>

        <%-- START DATE --%>
        <tr>
            <td class="admin"><%=getTran("openclinic.chuk","startdate",sWebLanguage)%></td>
            <td class="admin2">
                <input <%=setRightClick("ITEM_TYPE_KINESITHERAPY_CONSULTATION_TREATMENT_STARTDATE")%> type="text" class="text" size="12" maxLength="10" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_KINESITHERAPY_CONSULTATION_TREATMENT_STARTDATE" property="itemId"/>]>.value" value="<%=sStartDate%>" id="startdate" OnBlur='checkDate(this)'>
                <script>writeMyDate("startdate");</script>
            </td>
        </tr>

        <%-- SEANCES SCEME --%>
        <tr>
            <td class="admin"><%=getTran("openclinic.chuk","date.seances",sWebLanguage)%></td>
            <td class="admin2">                
                <table id="searchresults" width="100%" class="sortable" cellspacing="0" headerrowcount="2">
                    <%-- HEADER --%>
                    <tr>
                        <td class="admin" width="38"/>
                        <td class="admin" width="120"><%=getTran("Web.occup","medwan.common.date",sWebLanguage)%></td>
                        <td class="admin" width="55"><%=getTran("Web.occup","medwan.common.hour",sWebLanguage)%></td>
                        <td class="admin"><%=getTran("openclinic.chuk","treatment",sWebLanguage)%></td>
                        <td class="admin"><%=getTran("openclinic.chuk","treatment",sWebLanguage)%></td>
                        <td class="admin"><%=getTran("openclinic.chuk","treatment",sWebLanguage)%></td>
                        <td class="admin"></td>
                        <td/>
                    </tr>

                    <%-- ADD ROW --%>
                    <tr>
                        <td class="admin2"/>
                        <td class="admin2">
                            <input type="text" class="text" size="12" maxLength="10" id="seanceDate" name="seanceDate" OnBlur='checkDate(this)'>
                            <script>writeMyDate("seanceDate");</script>
                        </td>
                        <td class="admin2">
                            <input type="text" class="text" size="5" name="seanceHour" onblur="checkTime(this);"onkeypress="keypressTime(this)">
                        </td>
                        <td class="admin2">
                            <select class="text" name="seancetreatment1">
                                <option/>
                                <%=ScreenHelper.writeSelect("physiotherapy.act","",sWebLanguage)%>
                            </select>
                        </td>
                        <td class="admin2">
                            <select class="text" name="seancetreatment2">
                                <option/>
                                <%=ScreenHelper.writeSelect("physiotherapy.act","",sWebLanguage)%>
                            </select>
                        </td>
                        <td class="admin2">
                            <select class="text" name="seancetreatment3">
                                <option/>
                                <%=ScreenHelper.writeSelect("physiotherapy.act","",sWebLanguage)%>
                            </select>
                        </td>

                        <%-- ADD/EDIT BUTTONS --%>
                        <td class="admin2">
                            <input type="button" class="button" name="ButtonAddSeance" value="<%=getTran("Web","add",sWebLanguage)%>" onclick="addSeance();">
                            <input type="button" class="button" name="ButtonUpdateSeance" value="<%=getTran("Web","edit",sWebLanguage)%>" onclick="updateSeance();">
                        </td>
                    </tr>

                    <%=sDivSeances%>
                </table>

                <%-- hidden fields --%>
                <input type="hidden" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_KINESITHERAPY_CONSULTATION_TREATMENT_SEANCE1" property="itemId"/>]>.value">
                <input type="hidden" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_KINESITHERAPY_CONSULTATION_TREATMENT_SEANCE2" property="itemId"/>]>.value">
                <input type="hidden" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_KINESITHERAPY_CONSULTATION_TREATMENT_SEANCE3" property="itemId"/>]>.value">
                <input type="hidden" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_KINESITHERAPY_CONSULTATION_TREATMENT_SEANCE4" property="itemId"/>]>.value">
                <input type="hidden" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_KINESITHERAPY_CONSULTATION_TREATMENT_SEANCE5" property="itemId"/>]>.value">
            </td>
        </tr>

        <%-- END DATE --%>
        <tr>
            <td class="admin"><%=getTran("openclinic.chuk","enddate",sWebLanguage)%></td>
            <td class="admin2">
                <input <%=setRightClick("ITEM_TYPE_KINESITHERAPY_CONSULTATION_TREATMENT_ENDDATE")%> type="text" class="text" size="12" maxLength="10" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_KINESITHERAPY_CONSULTATION_TREATMENT_ENDDATE" property="itemId"/>]>.value" value="<%=sEndDate%>" id="enddate" OnBlur='checkDate(this)'>
                <script>writeMyDate("enddate");</script>
            </td>
        </tr>

        <%-- CONCLUSION --%>
        <tr>
            <td class="admin"><%=getTran("openclinic.chuk","conclusion",sWebLanguage)%></td>
            <td class="admin2">
                <textarea onKeyup="resizeTextarea(this,10);limitChars(this,255);" <%=setRightClick("ITEM_TYPE_KINESITHERAPY_CONSULTATION_TREATMENT_CONCLUSION")%> class="text" cols="50" rows="2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_KINESITHERAPY_CONSULTATION_TREATMENT_CONCLUSION" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_KINESITHERAPY_CONSULTATION_TREATMENT_CONCLUSION" property="value"/></textarea>
            </td>
        </tr>

        <%-- REFERENCE --%>
        <tr>
            <td class="admin"><%=getTran("openclinic.chuk","reference",sWebLanguage)%></td>
            <td class="admin2">
                <input id="rbrefyes" <%=setRightClick("ITEM_TYPE_KINESITHERAPY_CONSULTATION_TREATMENT_REFERENCE")%>  onDblClick="uncheckRadio(this);" type="radio" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_KINESITHERAPY_CONSULTATION_TREATMENT_REFERENCE" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_KINESITHERAPY_CONSULTATION_TREATMENT_REFERENCE;value=medwan.common.yes" property="value" outputString="checked"/> value="medwan.common.yes"/>
                &nbsp;<%=getLabel("web.occup","medwan.common.yes",sWebLanguage,"rbrefyes")%>
                &nbsp;<input id="rbrefno" type="radio" onDblClick="uncheckRadio(this);" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_KINESITHERAPY_CONSULTATION_TREATMENT_REFERENCE" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_KINESITHERAPY_CONSULTATION_TREATMENT_REFERENCE;value=medwan.common.no" property="value" outputString="checked"/> value="medwan.common.no"/>
                &nbsp;<%=getLabel("web.occup","medwan.common.no",sWebLanguage,"rbrefno")%>
            </td>
        </tr>

        <%-- DATE --%>
        <tr>
            <td class="admin"><%=getTran("openclinic.chuk","remarks",sWebLanguage)%></td>
            <td class="admin2">
                <textarea onKeyup="resizeTextarea(this,10);limitChars(this,255);" <%=setRightClick("ITEM_TYPE_KINESITHERAPY_CONSULTATION_TREATMENT_REMARKS")%> class="text" cols="50" rows="2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_KINESITHERAPY_CONSULTATION_TREATMENT_REMARKS" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_KINESITHERAPY_CONSULTATION_TREATMENT_REMARKS" property="value"/></textarea>
            </td>
        </tr>
    </table>

    <%-- BUTTONS --%>
    <%=ScreenHelper.alignButtonsStart()%>
        <%=getButtonsHtml(request,activeUser,activePatient,"occup.kinesitherapy.consultation.treatment",sWebLanguage)%>
    <%=ScreenHelper.alignButtonsStop()%>

    <%=ScreenHelper.contextFooter(request)%>
</form>

<script>
  var treatmentLabels = new Array();
  
  <%
      Hashtable labelTypes = (Hashtable)MedwanQuery.getInstance().getLabels().get(sWebLanguage.toLowerCase());
      if(labelTypes!=null){
          Hashtable labelIds = (Hashtable)labelTypes.get("physiotherapy.act");
     
          Enumeration labelEnum = labelIds.keys();
	      String sLabelId, sLabel;  
	      net.admin.Label label;
	      
	      while(labelEnum.hasMoreElements()){
	    	  sLabelId = (String)labelEnum.nextElement();
	    	  label = (net.admin.Label)labelIds.get(sLabelId);
	    	  
	    	  %>treatmentLabels["<%=sLabelId%>"] = "<%=label.value%>";<%
	      }
      }
  %>

  var iSeancesIndex = <%=iSeancesTotal%>;
  var sSeances = "<%=sSeances%>";
  var editSeancesRowid = "";

  <%
      for(int i=0; i<9; i++){
          %>
            if("<%=sAct[i]%>" == "medwan.true"){
              transactionForm.acte<%=i+1%>.checked = true;
            }
          <%
      }
  %>

  updateRowStyles(1);
  
<%-- SEANCES ----------------------------------------------------------------------------------%>
function addSeance(){
  if(isAtLeastOneSeanceFieldFilled()){
    iSeancesIndex++;
    if(transactionForm.seanceHour.value == ""){
      getTime(transactionForm.seanceHour);
    }

    sSeances+="rowSeance"+iSeancesIndex+"="+transactionForm.seanceDate.value+"£"
                                           +transactionForm.seanceHour.value+"£"
                                           +transactionForm.seancetreatment1.value+"£"
                                           +transactionForm.seancetreatment2.value+"£"
                                           +transactionForm.seancetreatment3.value+"$";
      
    var tr;
    tr = searchresults.insertRow(searchresults.rows.length);
    tr.id = "rowSeance"+iSeancesIndex;

    var td = tr.insertCell(0);
    td.innerHTML = "<a href='javascript:deleteSeance(rowSeance"+iSeancesIndex+")'><img src='<%=sCONTEXTPATH%>/_img/icon_delete.gif' alt='<%=getTranNoLink("Web.Occup","medwan.common.delete",sWebLanguage)%>' border='0'></a> "+
                   "<a href='javascript:editSeance(rowSeance"+iSeancesIndex+")'><img src='<%=sCONTEXTPATH%>/_img/icon_edit.gif' alt='<%=getTranNoLink("Web.Occup","medwan.common.edit",sWebLanguage)%>' border='0'></a>";
    tr.appendChild(td);

    td = tr.insertCell(1);
    td.innerHTML = "&nbsp;"+transactionForm.seanceDate.value;
    tr.appendChild(td);

    td = tr.insertCell(2);
    td.innerHTML = "&nbsp;"+transactionForm.seanceHour.value;
    tr.appendChild(td);

    td = tr.insertCell(3);
    td.innerHTML = "&nbsp;"+translateTreatment(transactionForm.seancetreatment1.value);
    tr.appendChild(td);

    td = tr.insertCell(4);
    td.innerHTML = "&nbsp;"+translateTreatment(transactionForm.seancetreatment2.value);
    tr.appendChild(td);

    td = tr.insertCell(5);
    td.innerHTML = "&nbsp;"+translateTreatment(transactionForm.seancetreatment3.value);
    tr.appendChild(td);

    td = tr.insertCell(6);
    td.innerHTML = "&nbsp;";
    tr.appendChild(td);

    setCellStyle(tr);
    clearSeanceFields()
    transactionForm.ButtonUpdateSeance.disabled = true;
  }

  return true;
}

function updateSeance(){
  if(isAtLeastOneSeanceFieldFilled()){
    <%-- update arrayString --%>
    var newRow, row;
    if(transactionForm.seanceHour.value == ""){
      getTime(transactionForm.seanceHour);
    }

    newRow = editSeancesRowid.id+"="+transactionForm.seanceDate.value+"£"
                                    +transactionForm.seanceHour.value+"£"
                                    +transactionForm.seancetreatment1.value+"£"
                                    +transactionForm.seancetreatment2.value+"£"
                                    +transactionForm.seancetreatment3.value;

    sSeances = replaceRowInArrayString(sSeances,newRow,editSeancesRowid.id);

    <%-- update table object --%>
    row = searchresults.rows[editSeancesRowid.rowIndex];
    row.cells[0].innerHTML = "<a href='javascript:deleteSeance("+editSeancesRowid.id+")'><img src='<%=sCONTEXTPATH%>/_img/icon_delete.gif' alt='<%=getTranNoLink("Web.Occup","medwan.common.delete",sWebLanguage)%>' border='0'></a> "
                            +"<a href='javascript:editSeance("+editSeancesRowid.id+")'><img src='<%=sCONTEXTPATH%>/_img/icon_edit.gif' alt='<%=getTranNoLink("Web.Occup","medwan.common.edit",sWebLanguage)%>' border='0'></a>";

    row.cells[1].innerHTML = "&nbsp;"+transactionForm.seanceDate.value;
    row.cells[2].innerHTML = "&nbsp;"+transactionForm.seanceHour.value;
    row.cells[3].innerHTML = "&nbsp;"+translateTreatment(transactionForm.seancetreatment1.value);
    row.cells[4].innerHTML = "&nbsp;"+translateTreatment(transactionForm.seancetreatment2.value);
    row.cells[5].innerHTML = "&nbsp;"+translateTreatment(transactionForm.seancetreatment3.value);

    setCellStyle(row);
    clearSeanceFields();
    transactionForm.ButtonUpdateSeance.disabled = true;
  }
}

function isAtLeastOneSeanceFieldFilled(){
  if(transactionForm.seanceDate.value.length>0) return true;
  if(transactionForm.seanceHour.value.length>0) return true;
  if(transactionForm.seancetreatment1.selectedIndex>0) return true;
  if(transactionForm.seancetreatment2.selectedIndex>0) return true;
  if(transactionForm.seancetreatment3.selectedIndex>0) return true;
  return false;
}

function clearSeanceFields(){
  transactionForm.seanceDate.value = "";
  transactionForm.seanceHour.value = "";
  transactionForm.seancetreatment1.selectedIndex = -1;
  transactionForm.seancetreatment2.selectedIndex = -1;
  transactionForm.seancetreatment3.selectedIndex = -1;
}

function deleteSeance(rowid){
  if(yesnoDialog("Web","areYouSureToDelete")){
    sSeances = deleteRowFromArrayString(sSeances,rowid.id);
    searchresults.deleteRow(rowid.rowIndex);
    clearSeanceFields();
  }
}

function editSeance(rowid){
  var row = getRowFromArrayString(sSeances,rowid.id);
  transactionForm.seanceDate.value = getCelFromRowString(row,0);
  transactionForm.seanceHour.value = getCelFromRowString(row,1);
  transactionForm.seancetreatment1.value = getCelFromRowString(row,2);
  transactionForm.seancetreatment2.value = getCelFromRowString(row,3);
  transactionForm.seancetreatment3.value = getCelFromRowString(row,4);

  editSeancesRowid = rowid;
  transactionForm.ButtonUpdateSeance.disabled = false;
}

<%-- GENERAL FUNCTIONS --------------------------------------------------------------------------%>
function deleteRowFromArrayString(sArray,rowid){
  var array = sArray.split("$");
  for(var i=0; i<array.length; i++){
    if(array[i].indexOf(rowid) > -1){
      array.splice(i,1);
    }
  }
    
  return array.join("$");
}

function getRowFromArrayString(sArray, rowid){
  var array = sArray.split("$");
  var row = "";
  for(var i=0; i<array.length; i++){
    if(array[i].indexOf(rowid) > -1){
      row = array[i].substring(array[i].indexOf("=")+1);
      break;
    }
  }
   
  return row;
}

function getCelFromRowString(sRow, celid){
  var row = sRow.split("£");
  return row[celid];
}

function replaceRowInArrayString(sArray, newRow, rowid){
  var array = sArray.split("$");
  for(var i=0; i<array.length; i++){
    if(array[i].indexOf(rowid) > -1){
      array.splice(i,1,newRow);
      break;
    }
  }
    
  return array.join("$");
}

<%-- SUBMIT FORM --%>
function submitForm(){
  if(document.getElementById('encounteruid').value==''){
    alertDialog("web","no.encounter.linked");
	searchEncounter();
  }	
  else{
	var maySubmit = true;
	
	if(isAtLeastOneSeanceFieldFilled()){
	  if(maySubmit){
        if(!addSeance()){
          maySubmit = false;
        }
      }
    }
	
    var sTmpBegin, sTmpEnd;

    while(sSeances.indexOf("rowSeance") > -1){
      sTmpBegin = sSeances.substring(sSeances.indexOf("rowSeance"));
      sTmpEnd = sTmpBegin.substring(sTmpBegin.indexOf("=")+1);
      sSeances = sSeances.substring(0, sSeances.indexOf("rowSeance"))+sTmpEnd;
    }

    document.getElementsByName("currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_KINESITHERAPY_CONSULTATION_TREATMENT_SEANCE1" property="itemId"/>]>.value")[0].value = sSeances.substring(0,254);
    document.getElementsByName("currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_KINESITHERAPY_CONSULTATION_TREATMENT_SEANCE2" property="itemId"/>]>.value")[0].value = sSeances.substring(254,508);
    document.getElementsByName("currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_KINESITHERAPY_CONSULTATION_TREATMENT_SEANCE3" property="itemId"/>]>.value")[0].value = sSeances.substring(508,762);
    document.getElementsByName("currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_KINESITHERAPY_CONSULTATION_TREATMENT_SEANCE4" property="itemId"/>]>.value")[0].value = sSeances.substring(762,1016);
    document.getElementsByName("currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_KINESITHERAPY_CONSULTATION_TREATMENT_SEANCE5" property="itemId"/>]>.value")[0].value = sSeances.substring(1016,1270);
	
    if(maySubmit){
      document.getElementById("buttonsDiv").style.visibility = "hidden";
      var temp = Form.findFirstElement(transactionForm);//for ff compatibility
      <%
          sessionContainerWO = (SessionContainerWO)SessionContainerFactory.getInstance().getSessionContainerWO(request,SessionContainerWO.class.getName());
          out.print(takeOverTransaction(sessionContainerWO, activeUser,"document.transactionForm.submit();"));
      %>
    }
  }
}
  
function searchEncounter(){
  openPopup("/_common/search/searchEncounter.jsp&ts=<%=getTs()%>&VarCode=currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CONTEXT_ENCOUNTERUID" property="itemId"/>]>.value&VarText=&FindEncounterPatient=<%=activePatient.personid%>");
}
  
if(document.getElementById('encounteruid').value==''){
  alertDialog("web","no.encounter.linked");
  searchEncounter();
}	

<%-- SET CELL STYLE --%>
function setCellStyle(row){
  for(var i=0; i<row.cells.length; i++){
    row.cells[i].style.color = "#333333";
    row.cells[i].style.fontFamily = "arial";
    row.cells[i].style.fontSize = "10px";
    row.cells[i].style.fontWeight = "normal";
    row.cells[i].style.textAlign = "left";
    row.cells[i].style.paddingLeft = "1px";
    row.cells[i].style.paddingRight = "1px";
    row.cells[i].style.paddingTop = "1px";
    row.cells[i].style.paddingBottom = "1px";
    //row.cells[i].style.backgroundColor = "#E0EBF2";
  }
}

<%-- SEARCH ICPC --%>
function searchICPC(code,codelabel,codetype){
  openPopup("/_common/search/searchICPC.jsp&ts=<%=getTs()%>&returnField="+code+"&returnField2="+codelabel+"&returnField3="+codetype+"&ListChoice=FALSE");
}

<%-- TRANSLATE TREATMENT --%>
function translateTreatment(treatmentId){
  return treatmentLabels[treatmentId];
}
</script>

<%=writeJSButtons("transactionForm","saveButton")%>