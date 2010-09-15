<%@ page import="be.openclinic.system.Healthrecord" %>
<%@ page import="java.util.*" %>
<%@include file="/includes/validateUser.jsp"%>
<%@page errorPage="/includes/error.jsp"%>
<%=checkPermission("occup.medicalimagingrequest_mobileunit","select",activeUser)%>
<form name="transactionForm" id="transactionForm" method="POST" action='<c:url value="/healthrecord/updateTransaction.do"/>?ts=<%=getTs()%>' onclick="setSaveButton(event);" onkeyup="setSaveButton(event);">
    <bean:define id="transaction" name="be.mxs.webapp.wl.session.SessionContainerFactory.WO_SESSION_CONTAINER" property="currentTransactionVO"/>

    <input type="hidden" id="transactionId" name="currentTransactionVO.<TransactionVO[hashCode=<bean:write name="transaction" scope="page" property="transactionId"/>]>.transactionId" value="<bean:write name="transaction" scope="page" property="transactionId"/>"/>
    <input type="hidden" id="serverId" name="currentTransactionVO.<TransactionVO[hashCode=<bean:write name="transaction" scope="page" property="transactionId"/>]>.serverId" value="<bean:write name="transaction" scope="page" property="serverId"/>"/>
    <input type="hidden" id="transactionType" name="currentTransactionVO.<TransactionVO[hashCode=<bean:write name="transaction" scope="page" property="transactionId"/>]>.transactionType" value="<bean:write name="transaction" scope="page" property="transactionType"/>"/>

    <input type="hidden" readonly name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_MIR2_SCREEN_MOBILE_UNIT" property="itemId"/>]>.value" value="medwan.common.true"/>
    <input type="hidden" readonly name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CONTEXT_DEPARTMENT" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CONTEXT_DEPARTMENT" translate="false" property="value"/>"/>
    <input type="hidden" readonly name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CONTEXT_CONTEXT" translate="false" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CONTEXT_CONTEXT" translate="false" property="value"/>"/>

    <input type="hidden" readonly name="be.mxs.healthrecord.updateTransaction.actionForwardKey" value="/main.do?Page=curative/index.jsp&ts=<%=getTs()%>"/>
    <input type="hidden" name="subClass" value="MOBILE_UNIT"/>

    <%=writeHistoryFunctions(((TransactionVO)transaction).getTransactionType(),sWebLanguage)%>
    <%=contextHeader(request,sWebLanguage,getTran("web.occup","mer_mobile_unit",sWebLanguage))%>

    <table class="list" width="100%" class="list" cellspacing="1">
        <%-- DATE --%>
        <tr>
            <td class="admin" width="<%=sTDAdminWidth%>">
                <a href="javascript:openHistoryPopup();" title="<%=getTran("Web.Occup","History",sWebLanguage)%>">...</a>&nbsp;
                <%=getTran("Web.Occup","medwan.common.date",sWebLanguage)%>
            </td>
            <td class="admin2">
                <input type="text" class="text" size="12" value="<mxs:propertyAccessorI18N name="transaction" scope="page" property="updateTime" formatType="date" format="dd-mm-yyyy"/>" name="currentTransactionVO.<TransactionVO[hashCode=<bean:write name="transaction" scope="page" property="transactionId"/>]>.updateTime" id="trandate" OnBlur='checkDate(this)'>
                <script>writeMyDate("trandate","<c:url value="/_img/calbtn.gif"/>","<%=getTran("Web","PutToday",sWebLanguage)%>");</script>
            </td>
        </tr>

        <%-- AANVRAGENDE GENEESHEER --%>
        <tr>
            <td class='admin'><%=getTran("Web.Occup","be.mxs.common.model.vo.healthrecord.iconstants.item_type_mir_applying_physician",sWebLanguage)%></td>
            <td class='admin2'>
                <select id="applying_physician" class="text" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_MIR2_APPLYING_PHYSICIAN" property="itemId"/>]>.value">
                    <option>test</option>
                    <option><%=getTran("web","choose",sWebLanguage)%></option>
                    <%
                        SessionContainerWO sessionContainerWO = (SessionContainerWO) SessionContainerFactory.getInstance().getSessionContainerWO(request, SessionContainerWO.class.getName());

                        String sMedCode, sFirstname, sLastname, sApplyingPhysician = "", sSelected, sIdentificationRX = "";
                        if (sessionContainerWO.getCurrentTransactionVO().getTransactionId().intValue() > 0) {
                            ItemVO item = sessionContainerWO.getCurrentTransactionVO().getItem("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_MIR2_APPLYING_PHYSICIAN");
                            if (item != null) {
                                sApplyingPhysician = item.getValue();
                            }

                            item = sessionContainerWO.getCurrentTransactionVO().getItem("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_MIR2_IDENTIFICATION_RX");
                            if (item != null) {
                                sIdentificationRX = item.getValue();
                            }
                        } else {
                            sApplyingPhysician = checkString((String) session.getAttribute("activeMD"));
                            String sServerID = sessionContainerWO.getCurrentTransactionVO().getServerId() + "";
                            while (sServerID.length() < 3) {
                                sServerID = "0" + sServerID;
                            }
                            sIdentificationRX = "0" + sServerID + MedwanQuery.getInstance().getNewOccupCounterValue("IdentificationRXID");
                        }

                        Vector vMedicalImagingRequest = Healthrecord.getApplyingPhysicians();
                        Iterator iter = vMedicalImagingRequest.iterator();
                        Hashtable hMedicalImagingRequest;
                        while(iter.hasNext()){
                            hMedicalImagingRequest = (Hashtable)iter.next();
                            sLastname = ScreenHelper.checkString((String)hMedicalImagingRequest.get("lastname"));
                            sFirstname = ScreenHelper.checkString((String)hMedicalImagingRequest.get("firstname"));
                            sMedCode = ScreenHelper.checkString((String)hMedicalImagingRequest.get("medcode"));
                            sSelected = "";

                            if (sMedCode.equals(sApplyingPhysician)) {
                                sSelected = " selected";
                            }

                            if (sFirstname.length() > 0) {
                                sLastname += ", " + sFirstname;
                            }

                    %>
                                <option value="<%=sMedCode%>" <%=sSelected%>><%=sLastname%> (<%=sMedCode%>)</option>
                            <%
                        }
                    %>
                </select>
            </td>
        </tr>

        <%-- TYPE --%>
        <tr>
            <td class='admin'><%=getTran("Web.Occup","be.mxs.common.model.vo.healthrecord.iconstants.item_type_mir_type",sWebLanguage)%></td>
            <td class='admin2'>
                <%
                    String type = checkString(request.getParameter("type"));
                    if(type.length() > 0){
                        %>
                            <select id="examination" class="text" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_MIR2_TYPE" property="itemId"/>]>.value">
                                <option value="0" <%=(type.equals("0")?"SELECTED":"")%>><%=getTran("Web","choose",sWebLanguage)%>
                                <option value="1" <%=(type.equals("1")?"SELECTED":"")%>><%=getTran("Web.Occup","medwan.occupational-medicine.medical-imaging-request.type-1",sWebLanguage)%>
                                <option value="2" <%=(type.equals("2")?"SELECTED":"")%>><%=getTran("Web.Occup","medwan.occupational-medicine.medical-imaging-request.type-2",sWebLanguage)%>
                                <option value="3" <%=(type.equals("3")?"SELECTED":"")%>><%=getTran("Web.Occup","medwan.occupational-medicine.medical-imaging-request.type-3",sWebLanguage)%>
                                <option value="4" <%=(type.equals("4")?"SELECTED":"")%>><%=getTran("Web.Occup","medwan.occupational-medicine.medical-imaging-request.type-4",sWebLanguage)%>
                                <option value="5" <%=(type.equals("5")?"SELECTED":"")%>><%=getTran("Web.Occup","medwan.occupational-medicine.medical-imaging-request.type-5",sWebLanguage)%>
                                <option value="6" <%=(type.equals("6")?"SELECTED":"")%>><%=getTran("Web.Occup","medwan.occupational-medicine.medical-imaging-request.type-6",sWebLanguage)%>
                                <option value="7" <%=(type.equals("7")?"SELECTED":"")%>><%=getTran("Web.Occup","medwan.occupational-medicine.medical-imaging-request.type-7",sWebLanguage)%>
                                <option value="8" <%=(type.equals("8")?"SELECTED":"")%>><%=getTran("Web.Occup","medwan.occupational-medicine.medical-imaging-request.type-8",sWebLanguage)%>
                                <option value="9" <%=(type.equals("9")?"SELECTED":"")%>><%=getTran("Web.Occup","medwan.occupational-medicine.medical-imaging-request.type-9",sWebLanguage)%>
                            </select>
                        <%
                    }
                    else{
                        %>
                            <select id="examination" class="text" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_MIR2_TYPE" property="itemId"/>]>.value">
                                <option value="0" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_MIR2_TYPE;value=0" property="value" outputString="selected"/>>
                                <option value="1" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_MIR2_TYPE;value=1" property="value" outputString="selected"/>><%=getTran("Web.Occup","medwan.occupational-medicine.medical-imaging-request.type-1",sWebLanguage)%>
                                <option value="2" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_MIR2_TYPE;value=2" property="value" outputString="selected"/>><%=getTran("Web.Occup","medwan.occupational-medicine.medical-imaging-request.type-2",sWebLanguage)%>
                                <option value="3" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_MIR2_TYPE;value=3" property="value" outputString="selected"/>><%=getTran("Web.Occup","medwan.occupational-medicine.medical-imaging-request.type-3",sWebLanguage)%>
                                <option value="4" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_MIR2_TYPE;value=4" property="value" outputString="selected"/>><%=getTran("Web.Occup","medwan.occupational-medicine.medical-imaging-request.type-4",sWebLanguage)%>
                                <option value="5" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_MIR2_TYPE;value=5" property="value" outputString="selected"/>><%=getTran("Web.Occup","medwan.occupational-medicine.medical-imaging-request.type-5",sWebLanguage)%>
                                <option value="6" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_MIR2_TYPE;value=6" property="value" outputString="selected"/>><%=getTran("Web.Occup","medwan.occupational-medicine.medical-imaging-request.type-6",sWebLanguage)%>
                                <option value="7" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_MIR2_TYPE;value=7" property="value" outputString="selected"/>><%=getTran("Web.Occup","medwan.occupational-medicine.medical-imaging-request.type-7",sWebLanguage)%>
                                <option value="8" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_MIR2_TYPE;value=8" property="value" outputString="selected"/>><%=getTran("Web.Occup","medwan.occupational-medicine.medical-imaging-request.type-8",sWebLanguage)%>
                                <option value="9" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_MIR2_TYPE;value=9" property="value" outputString="selected"/>><%=getTran("Web.Occup","medwan.occupational-medicine.medical-imaging-request.type-9",sWebLanguage)%>
                            </select>
                        <%
                    }
                %>
            </td>
        </tr>

        <%-- EXAMINATION REASON --%>
        <tr>
            <td class='admin'><%=getTran("Web.Occup","examinationreason",sWebLanguage)%>&nbsp;</td>
            <td class='admin2'>
                <textarea id="reason" onKeyup="resizeTextarea(this,10);limitChars(this,255);" <%=setRightClick("ITEM_TYPE_MIR2_EXAMINATIONREASON")%> class="text" cols='75' rows='2' name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_MIR2_EXAMINATIONREASON" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_MIR2_EXAMINATIONREASON" property="value"/></textarea>
            </td>
        </tr>

        <%-- IDENTIFICATIE NR RX --%>
        <tr>
            <td class='admin'><%=getTran("Web.Occup","be.mxs.common.model.vo.healthrecord.iconstants.item_type_mir_identification_rx",sWebLanguage)%></td>
            <td class='admin2'>
                <input type="text" id='rxid' class="text" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_MIR2_IDENTIFICATION_RX" property="itemId"/>]>.value" value="<%=sIdentificationRX%>" READONLY>
            </td>
        </tr>

        <%-- PROTOCOL --%>
        <tr>
            <td class='admin'><%=getTran("Web.Occup","be.mxs.common.model.vo.healthrecord.iconstants.item_type_mir_protocol",sWebLanguage)%></td>
            <td class='admin2'>
                <textarea id="protocol" onKeyup="resizeTextarea(this,10);limitChars(this,255);" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_MIR2_PROTOCOL" property="itemId"/>]>.value" class="text" rows="2" cols="80"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_MIR2_PROTOCOL" property="value"/></textarea>
            </td>
        </tr>

        <%-- NIETS TE MELDEN --%>
        <tr>
            <td class="admin"><%=getTran("Web.Occup","be.mxs.common.model.vo.healthrecord.iconstants.item_type_mir_nothing_to_mention",sWebLanguage)%></td>
            <td class="admin2">
                <input id="nothing_to_mention" type="checkbox" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_MIR2_NOTHING_TO_MENTION" property="itemId"/>]>.value" value="medwan.common.true" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_MIR2_NOTHING_TO_MENTION;value=medwan.common.true" property="value" outputString="checked"/>>
            </td>
        </tr>

        <%-- ALS PRESTATIE HERNEMEN --%>
        <tr>
            <td class="admin"><%=getTran("Web.Occup","medwan.healthrecord.prestation_recapture",sWebLanguage)%></td>
            <td class="admin2">
                <input <%=setRightClick("ITEM_TYPE_OTHER_REQUESTS_PRESTATION")%> type="checkbox" id="recapture" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OTHER_REQUESTS_PRESTATION" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OTHER_REQUESTS_PRESTATION;value=medwan.common.true" property="value" outputString="checked"/> value="medwan.common.true">
            </td>
        </tr>
       <tr>
            <td class="admin"/>
            <td class="admin2">
    <%-- BUTTONS ---------------------------------------------------------------------------------%>
        <%
        if(activeUser.getAccessRight("occup.medicalimagingrequest_mobileunit.add") || activeUser.getAccessRight("occup.medicalimagingrequest_mobileunit.edit")) {
        %>
                <INPUT class="button" type="button" value="<%=getTran("Web.Occup","medwan.common.print",sWebLanguage)%>" onclick="doPrintPDF();">&nbsp;
                <button accesskey="<%=ScreenHelper.getAccessKey(getTranNoLink("accesskey","save",sWebLanguage))%>" class="buttoninvisible" onclick="doSave();"></button>
                <button class="button" name="ButtonSave" id="ButtonSave" onclick="doSave();"><%=getTran("accesskey","save",sWebLanguage)%></button>
        <%
            }
        %>
                <INPUT class="button" type="button" value="<%=getTran("Web","back",sWebLanguage)%>" onclick="doBack();"/>
            </td>
        </tr>
    </table>
    <%-- PROVIDER (=802) --%>
    <input type="hidden" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OTHER_REQUESTS_SUPPLIER" property="itemId"/>]>.value" value="802">

    <%-- VALUE (=0) --%>
    <input type="hidden" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OTHER_REQUESTS_VALUE" property="itemId"/>]>.value" value="0">

<%
    // compose email (will be sent by UpdateTransactionAction)
    String sMailSubject = getTran("web.occup","mir.email.subject",sWebLanguage);
    sMailSubject = sMailSubject.replaceFirst("#firstname#",activePatient.firstname);
    sMailSubject = sMailSubject.replaceFirst("#lastname#",activePatient.lastname);
    sMailSubject = sMailSubject.replaceFirst("#immatnew#",activePatient.getID("immatnew"));

    String sMailMessage = getTran("web.occup","mir.email.message.line1",sWebLanguage);
    sMailMessage = sMailMessage.replaceFirst("#date#",getDate());

    sMailMessage+= "\n";

    // patient gegevens
    sMailMessage+= "\n "+getTran("web.occup","medwan.admin.firstname",sWebLanguage)+" : "+activePatient.firstname;
    sMailMessage+= "\n "+getTran("web.occup","medwan.admin.lastname",sWebLanguage)+" : "+activePatient.lastname;
    sMailMessage+= "\n "+getTran("web","immatnew",sWebLanguage)+" : "+activePatient.getID("immatnew");

    // Identificatienummer RX
    sMailMessage+= "\n "+getTran("web.occup","be.mxs.common.model.vo.healthrecord.iconstants.item_type_mir_identification_rx",sWebLanguage)+" : "+sIdentificationRX;

    // slotzin
    sMailMessage+= "\n\n "+getTran("web.occup","mir.email.message.end",sWebLanguage);

    /*
    String sMailMessage = getTran("web.occup","mir.email.message",sWebLanguage);
    sMailMessage = sMailMessage.replaceFirst("#date#",getDate());
    sMailMessage = sMailMessage.replaceFirst("#firstname#",activePatient.firstname);
    sMailMessage = sMailMessage.replaceFirst("#lastname#",activePatient.lastname);
    sMailMessage = sMailMessage.replaceFirst("#immatnew#",activePatient.getID("immatnew"));
    sMailMessage = sMailMessage.replaceFirst("#serviceid#",sServiceID);
    */
%>

    <input type="hidden" name="MailTo">
    <input type="hidden" name="MailSubject" value="<%=sMailSubject%>">
    <input type="hidden" name="MailMessage" value="<%=sMailMessage%>">

    <%=ScreenHelper.contextFooter(request)%>
</form>

<script>
  transactionForm.trandate.focus();

  function doSave(){
    if(true || transactionForm.applying_physician.selectedIndex > 0){
      if(true || transactionForm.examination.selectedIndex > 0){
        submitForm();
      }
      else{
        alert("<%=getTran("web.manage","datamissing",sWebLanguage)%>");
        transactionForm.examination.focus();
      }
    }
    else{
      alert("<%=getTran("web.manage","datamissing",sWebLanguage)%>");
      transactionForm.applying_physician.focus();
    }
  }

  function submitForm(){
    document.transactionForm.ButtonSave.disabled = true;

    if (transactionForm.nothing_to_mention.checked || transactionForm.protocol.value.length > 0) {
      transactionForm.MailTo.value = transactionForm.applying_physician.value;
      while (transactionForm.MailMessage.value.indexOf("#tdate#")>-1){
        transactionForm.MailMessage.value = transactionForm.MailMessage.value.replace("#tdate#",transactionForm.trandate.value);
      }
    }

    <%=takeOverTransaction(sessionContainerWO,activeUser,"transactionForm.submit();")%>
  }

  function doBack(){
    if(checkSaveButton('<%=sCONTEXTPATH%>','<%=getTran("Web.Occup","medwan.common.buttonquestion",sWebLanguage)%>')){
      window.location.href = '<c:url value="/main.do"/>?Page=curative/index.jsp&ts=<%=getTs()%>';
    }
  }

  <%-- DO PRINT PDF --%>
  function doPrintPDF(){
    window.open('<c:url value="/healthrecord/loadPDF.jsp"/>?file=base/<%=sWebLanguage%>4M.pdf&module=N4M&modulepar1='+document.all['examination'].options[document.all['examination'].selectedIndex].text+'&modulepar2='+document.all['protocol'].value+'&modulepar3='+document.all['rxid'].value+'&modulepar4=<%=checkString((String)session.getAttribute("activeMD"))+"$"+checkString((String)session.getAttribute("activePara"))+"$"+checkString((String)session.getAttribute("activeMedicalCenter"))%>&ts=<%=ScreenHelper.getTs()%>','Print','toolbar=yes, status=yes, scrollbars=yes, resizable=yes, width=700, height=500,menubar=yes');
  }
</script>

<%=writeJSButtons("transactionForm","ButtonSave")%>
