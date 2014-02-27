<%@page import="be.dpms.medwan.common.model.vo.recruitment.RecordRowVO,
                be.mxs.common.util.io.MessageReader,
                be.mxs.common.util.io.MessageReaderMedidoc,be.openclinic.system.Transaction,java.util.*" %>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>
<%

%>
<script type="text/javascript">
    var myForm=document;
</script>
<%
    int i=0;
    String sClass = "",sUserName, sUserId, sItemValue, sTransactionType = "", allAnalysis = "";
    RecordRowVO record;

    String sITEM_TYPE_MIR_TYPE               = sPREFIX+"ITEM_TYPE_MIR_TYPE";
    String sTRANSACTION_TYPE_MIR             = sPREFIX+"TRANSACTION_TYPE_MIR";
    String sTRANSACTION_TYPE_MIR_MOBILE_UNIT = sPREFIX+"TRANSACTION_TYPE_MIR_MOBILE_UNIT";
    String sTRANSACTION_TYPE_LAB_REQUEST     = sPREFIX+"TRANSACTION_TYPE_LAB_REQUEST";
%>
<table width="100%" cellspacing="0" class="list">
    <%-- GENERAL TITLE --%>
    <tr class="admin" height="20">
        <td colspan="4">&nbsp;<%=getTran("Web.Occup","medwan.common.history",sWebLanguage)%></td>
    </tr>

    <%-- CONVOCATION --%>
    <logic:present name="be.mxs.webapp.wl.session.SessionContainerFactory.WO_SESSION_CONTAINER" property="activeRecruitmentConvocation">
        <bean:define id="activeRecruitmentConvocation" name="be.mxs.webapp.wl.session.SessionContainerFactory.WO_SESSION_CONTAINER" property="activeRecruitmentConvocation"/>
        <tr>
            <td colspan="4" class="admin"><%=getTran("Web.Occup","medwan.healthrecord.annexe-iv.insurance-organism.option-2-Number",sWebLanguage)%>: <bean:write name="activeRecruitmentConvocation" scope="page" property="convocationId"/></td>
        </tr>
        <tr>
            <td colspan="4" class="admin"><%=getTran("Web.Occup","medwan.recruitment.invitation-date",sWebLanguage)%>: <mxs:propertyAccessorI18N name="activeRecruitmentConvocation" scope="page" property="invitationDateTime" formatType="date" format="dd-mm-yyyy"/></td>
        </tr>
    </logic:present>

    <logic:present name="be.mxs.webapp.wl.session.SessionContainerFactory.WO_SESSION_CONTAINER" property="fullRecord">
        <%-- GENERAL HEADER --%>
        <tr class='list_select'>
            <td width="15">&nbsp;</td>
            <td width="100"><%=getTran("Web.Occup","medwan.common.date",sWebLanguage)%></td>
            <td width="50%"><%=getTran("Web.Occup","medwan.common.contacttype",sWebLanguage)%></td>
            <td width="35%"><%=getTran("Web.Occup","medwan.common.user",sWebLanguage)%></td>
        </tr>

        <logic:iterate id="recordRow" scope="session" name="be.mxs.webapp.wl.session.SessionContainerFactory.WO_SESSION_CONTAINER" property="fullRecord.recordRows">
            <%-- CLICKABLE RECORD HEADER (indent == 0) --%>
            <logic:equal name="recordRow" property="indent" value="0">
                <%
                    if (i > 0){
                        %>
                                    </table>
                                    <br>
                                </td>
                            </tr>
                        <%
                    }
                %>

                <%
                    i++;
                    String context = "";

                    // alternate row looks
                    if (sClass.equals("")) sClass = "1";
                    else sClass = "";
					
                    record = (RecordRowVO) recordRow;
                    sUserName = "";
                    if (record != null){
                        // get user names
                        System.out.println("record.getTransactionId()="+record.getTransactionId());
                        Transaction transaction = Transaction.getTransaction(record.getTransactionId(), record.getServerId());

                        if (transaction != null){
                            sUserId = checkString(Integer.toString(transaction.getUserId()));
                            sTransactionType = transaction.getTransactionType();

                            Hashtable hName = User.getUserName(sUserId);

                            if(hName!=null){
                                sUserName = hName.get("lastname") + " " + hName.get("firstname");
                            }
                        }
                        String sContext = Transaction.getTransactionContext(record.getTransactionId(),record.getHealthrecordId(),record.getTransactionType());

                        if(sContext!=null){
                            context = getTran("web.occup", sContext, sWebLanguage);
                        }
                    }

                    // forward
                    String sForward = MedwanQuery.getInstance().getForward(sTransactionType);
                    if (sForward != null) {
                        sForward = sForward.substring(0, sForward.indexOf("main.do")) + "medical/viewLastTransaction.jsp" + sForward.substring(sForward.indexOf("main.do") + 8);
                    }
                %>
                <tr class="list<%=sClass%>">
                    <td>
                        <img id="tr<%=i%>S" src="<c:url value='/_img/plus.png'/>" onclick="showD('tr<%=i%>','tr<%=i%>S','tr<%=i%>H');">
                        <img id="tr<%=i%>H" src="<c:url value='/_img/minus.png'/>" onclick="hideD('tr<%=i%>','tr<%=i%>S','tr<%=i%>H');" style="display:none">
                    </td>
                    <td><mxs:propertyAccessorI18N name="recordRow" scope="page" property="result"/></td>
                    <td>
                        <a href="<%=sCONTEXTPATH+sForward%>&be.mxs.healthrecord.createTransaction.transactionType=<bean:write name="recordRow" scope="page" property="transactionType"/>&be.mxs.healthrecord.transaction_id=<bean:write name="recordRow" scope="page" property="transactionId"/>&be.mxs.healthrecord.server_id=<bean:write name="recordRow" scope="page" property="serverId"/>&useTemplate=no" onMouseOver="window.status='';return true;">
                            <mxs:propertyAccessorI18N name="recordRow" scope="page" property="label"/> <%=(context.length() > 0 ?"("+context+")":"")%>
                        </a>
                    </td>
                    <td><%=sUserName%></td>
                </tr>

                <%-- HIDDEN TABLE --%>
                <tr id="tr<%=i%>" style="display:none">
                    <td colspan="4">
                        <table class="list" width="100%" cellspacing="1">
            </logic:equal>

            <%-- subheader --%>
            <logic:equal name="recordRow" property="indent" value="1">
                <tr class="list_select">
                    <td colspan="2">
                        <mxs:propertyAccessorI18N name="recordRow" scope="page" property="label"/>
                    </td>
                </tr>
            </logic:equal>

            <%-- content (indent > 0) --%>
            <logic:greaterThan name="recordRow" property="resultWidth" value="0" >
                <%
                    record = (RecordRowVO)recordRow;
                    String sLabel = record.getLabel();
                    String sResult = record.getResult();

                    //--- LAB_RESULT --------------------------------------------------------------
                    if (sTransactionType.indexOf("LAB_RESULT") > -1){
                        sLabel = getTran("TRANSACTION_TYPE_LAB_RESULT",sLabel,sWebLanguage);
                        MessageReader messageReader = new MessageReaderMedidoc();
                        messageReader.lastline = sResult;
                        String type = messageReader.readField("|");

                        if (type.equalsIgnoreCase("T") || type.equalsIgnoreCase("C")){
                            sResult=messageReader.readField("|");
                        }
                        else if (type.equalsIgnoreCase("N") || type.equalsIgnoreCase("D") || type.equalsIgnoreCase("H") || type.equalsIgnoreCase("M") || type.equalsIgnoreCase("S")){
                            sResult = messageReader.readField("|")+" ";
                            sResult+= messageReader.readField("|")+" ";
                        }
                    }
                    else {
                        sLabel = getTran("web.occup",sLabel,sWebLanguage);
                    }

                    //--- MIR ---------------------------------------------------------------------
                    // MIR Type is saved as a single number;
                    // We must append labelid, otherwise only the number is displayed in the history.
                    if(record!=null
                       && (sTransactionType.equalsIgnoreCase(sTRANSACTION_TYPE_MIR) || (sTransactionType.equalsIgnoreCase(sTRANSACTION_TYPE_MIR_MOBILE_UNIT))
                       && checkString(record.getLabel()).equalsIgnoreCase(sITEM_TYPE_MIR_TYPE))){
                        if(record.getLabel().equalsIgnoreCase(sITEM_TYPE_MIR_TYPE)){
                            sItemValue = getTran("Web.Occup",checkString("medwan.occupational-medicine.medical-imaging-request.type-"+record.getResult()),sWebLanguage);
                        }
                        else{
                            sItemValue = getTran("Web.Occup",checkString(record.getResult()),sWebLanguage);
                        }
                        %>
                            <tr>
                                <td class="admin" width="<%=sTDAdminWidth%>"><%=sLabel%></td>
                                <td class="admin2" width="*"><%=sItemValue%></td>
                            </tr>
                        <%
                        }
                        //--- LAB_REQUEST -------------------------------------------------------------
                        // requested analysis are concatenated AND spread over multiple items.
                        else if (record != null && (sTransactionType.equalsIgnoreCase(sTRANSACTION_TYPE_LAB_REQUEST))) {

                            // concatenate the content of the (max 5) analysis-items
                            if (checkString(record.getLabel()).toLowerCase().indexOf(sPREFIX+"item_type_lab_analysis") > -1) {
                                if (checkString(record.getLabel()).equalsIgnoreCase(sPREFIX+"ITEM_TYPE_LAB_ANALYSIS1")) {
                                    allAnalysis = record.getResult();
                                } else {
                                    allAnalysis += record.getResult();
                                }

                                String analysisTran = getTran("web.occup", "labanalysis.analysis", sWebLanguage);
                                String oneAnalysis, analysisCode, analysisComm;

                                // split the total analysis-string into one analysis per row
                                StringTokenizer tokenizer = new StringTokenizer(allAnalysis, "$");
                                while (tokenizer.hasMoreTokens()) {
                                    oneAnalysis = tokenizer.nextToken();

                                    if (oneAnalysis.indexOf("£") > -1) {
                                        analysisCode = oneAnalysis.substring(0, oneAnalysis.indexOf("£"));
                                    } else {
                                        analysisCode = oneAnalysis;
                                    }

                                    analysisComm = oneAnalysis.substring(oneAnalysis.indexOf("£") + 1);

                                    // trim comment
                                    if (analysisComm.length() > 20) {
                                        analysisComm = analysisComm.substring(0, 20) + " ...";
                                    }
                        %>
                                    <tr>
                                        <td class="admin" width="<%=sTDAdminWidth%>"><%=analysisTran%> <%=analysisCode%></td>
                                        <td class="admin2" width="*">
                                            <%=getTran("labanalysis",analysisCode,sWebLanguage)%>
                                            <%
                                                // comment
                                                if(analysisComm.length() > 0){
                                                    %> (<%=analysisComm%>)<%
                                                }
                                            %>
                                        </td>
                                    </tr>
                                <%
                            }
                        }
                        else{
                            // process other items of LAB_REQUEST
                            %>
                                <tr>
                                    <td class="admin" width="<%=sTDAdminWidth%>"><%=sLabel%></td>
                                    <td class="admin2" width="*"><%=getTran("web.occup",sResult,sWebLanguage)%></td>
                                </tr>
                            <%
                        }
                    }
                    //--- OTHER TRANSACTIONS ------------------------------------------------------
                    else{
                        // checked icon
                        if(sResult.equalsIgnoreCase("medwan.common.true")){
                            %>
                                <tr>
                                    <td class="admin" width="<%=sTDAdminWidth%>"><%=sLabel%></td>
                                    <td class="admin2" width="*"><img src="<c:url value="/_img/check.gif"/>"/></td>
                                </tr>
                            <%
                        }
                        // unchecked icon
                        else if(sResult.equalsIgnoreCase("medwan.common.false")){
                            %>
                                <tr>
                                    <td class="admin" width="<%=sTDAdminWidth%>"><%=sLabel%></td>
                                    <td class="admin2" width="*"><img src="<c:url value="/_img/uncheck.gif"/>"/></td>
                                </tr>
                            <%
                        }
                        // textual value
                        else{
                            %>
                                <tr>
                                    <td class="admin" width="<%=sTDAdminWidth%>"><%=sLabel%></td>
                                    <td class="admin2" width="*"><%=getTranNoLink("web.occup",sResult,sWebLanguage)%></td>
                                </tr>
                            <%
                        }
                    }
                %>
            </logic:greaterThan>

        </logic:iterate>
    </logic:present>

    <%
        if (i > 0){
            %>
                        </table>
                    </td>
                </tr>
            <%
        }
    %>
</table>

<%-- BUTTONS --%>
<a href="#" onclick="expandAll();"><%=getTran("web","expand_all",sWebLanguage)%></a>&nbsp;
<a href="#" onclick="collapseAll();"><%=getTran("web","close_all",sWebLanguage)%></a>
<%=ScreenHelper.alignButtonsStart()%>
    <input class="button" type="button" value="<%=getTran("Web","close",sWebLanguage)%>" onClick="window.close();">
<%=ScreenHelper.alignButtonsStop()%>
<script>
  window.resizeTo(800,570);
  var iTotal = <%=i%>;

  function expandAll(){
	for (var i=1; i<= iTotal; i++){
      showD("tr"+i,"tr"+i+"S","tr"+i+"H");
	}
  }

  function collapseAll(){
	for (var i=1; i< iTotal+1; i++){
	  hideD("tr"+i,"tr"+i+"S","tr"+i+"H");
	}
  }
</script>
