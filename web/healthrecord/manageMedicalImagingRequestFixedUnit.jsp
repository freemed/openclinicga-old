<%@ page import="java.util.*" %>
<%@ page import="be.openclinic.system.Healthrecord" %>
<%@include file="/includes/validateUser.jsp"%>
<%@page errorPage="/includes/error.jsp"%>
<%=checkPermission("occup.medicalimagingrequest_fixedunit","select",activeUser)%>
<form name="transactionForm" id="transactionForm" method="POST" action='<c:url value="/healthrecord/updateTransaction.do"/>?ts=<%=getTs()%>'>
    <bean:define id="transaction" name="be.mxs.webapp.wl.session.SessionContainerFactory.WO_SESSION_CONTAINER" property="currentTransactionVO"/>
	<%=checkPrestationToday(activePatient.personid,false,activeUser,(TransactionVO)transaction)%>

    <input type="hidden" id="transactionId" name="currentTransactionVO.<TransactionVO[hashCode=<bean:write name="transaction" scope="page" property="transactionId"/>]>.transactionId" value="<bean:write name="transaction" scope="page" property="transactionId"/>"/>
    <input type="hidden" id="serverId" name="currentTransactionVO.<TransactionVO[hashCode=<bean:write name="transaction" scope="page" property="transactionId"/>]>.serverId" value="<bean:write name="transaction" scope="page" property="serverId"/>"/>
    <input type="hidden" id="transactionType" name="currentTransactionVO.<TransactionVO[hashCode=<bean:write name="transaction" scope="page" property="transactionId"/>]>.transactionType" value="<bean:write name="transaction" scope="page" property="transactionType"/>"/>

    <input type="hidden" readonly name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_TRANSACTION_RESULT" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_TRANSACTION_RESULT" property="value"/>"/>
    <input type="hidden" readonly name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CONTEXT_DEPARTMENT" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CONTEXT_DEPARTMENT" translate="false" property="value"/>"/>
    <input type="hidden" readonly name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CONTEXT_CONTEXT" translate="false" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CONTEXT_CONTEXT" translate="false" property="value"/>"/>

    <input type="hidden" readonly name="be.mxs.healthrecord.updateTransaction.actionForwardKey" value="/main.do?Page=curative/index.jsp&ts=<%=getTs()%>"/>
    <input type="hidden" name="subClass" value="FIXED_UNIT"/>
    <input type="hidden" readonly name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_MIR2_SCREEN_FIXED_UNIT" translate="false" property="itemId"/>]>.value" value="medwan.common.true"/>

    <%=writeHistoryFunctions(((TransactionVO)transaction).getTransactionType(),sWebLanguage)%>
    <%=contextHeader(request,sWebLanguage,getTran("web.occup","mer_fixed_unit",sWebLanguage))%>

    <table class="list" width="100%" class="list" cellspacing="1">
        <%-- DATE --%>
        <tr>
            <td class="admin" width="<%=sTDAdminWidth%>">
                <a href="javascript:openHistoryPopup();" title="<%=getTranNoLink("Web.Occup","History",sWebLanguage)%>">...</a>&nbsp;
                <%=getTran("Web.Occup","medwan.common.date",sWebLanguage)%>
            </td>
            <td class="admin2">
                <input type="text" class="text" size="12" value="<mxs:propertyAccessorI18N name="transaction" scope="page" property="updateTime" formatType="date"/>" name="currentTransactionVO.<TransactionVO[hashCode=<bean:write name="transaction" scope="page" property="transactionId"/>]>.updateTime" id="trandate" OnBlur='checkDate(this)'>
                <script>writeTranDate();</script>
            </td>
        </tr>

        <%-- AANVRAGENDE GENEESHEER --%>
        <tr>
            <td class='admin'><%=getTran("Web.Occup","be.mxs.common.model.vo.healthrecord.iconstants.item_type_mir_applying_physician",sWebLanguage)%></td>
            <td class='admin2'>
                <select id="applying_physician" class="text" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_MIR2_APPLYING_PHYSICIAN" property="itemId"/>]>.value">
                    <option><%=getTranNoLink("web","choose",sWebLanguage)%></option>
                    <%
                        SessionContainerWO sessionContainerWO = (SessionContainerWO) SessionContainerFactory.getInstance().getSessionContainerWO(request, SessionContainerWO.class.getName());

                        String sMedCode, sFirstname, sLastname, sApplyingPhysician = "", sSelected;
                        if (sessionContainerWO.getCurrentTransactionVO().getTransactionId().intValue() > 0) {
                            ItemVO item = sessionContainerWO.getCurrentTransactionVO().getItem("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_MIR2_APPLYING_PHYSICIAN");
                            if (item != null) {
                                sApplyingPhysician = item.getValue();
                            }
                        }
                        else {
                            sApplyingPhysician = checkString((String) session.getAttribute("activeMD"));
                            String sServerID = sessionContainerWO.getCurrentTransactionVO().getServerId() + "";
                            while (sServerID.length() < 3) {
                                sServerID = "0" + sServerID;
                            }
                        }

                        Vector vMedicalImagingRequest = Healthrecord.getApplyingPhysicians();
                        Iterator iter = vMedicalImagingRequest.iterator();
                        Hashtable hMedicalImagingRequest;
                        while (iter.hasNext()) {
                            hMedicalImagingRequest = (Hashtable) iter.next();
                            sLastname = ScreenHelper.checkString((String) hMedicalImagingRequest.get("lastname"));
                            sFirstname = ScreenHelper.checkString((String) hMedicalImagingRequest.get("firstname"));
                            sMedCode = ScreenHelper.checkString((String) hMedicalImagingRequest.get("medcode"));
                            sSelected = "";

                            if (sMedCode.equals(sApplyingPhysician)) {
                                sSelected = " selected";
                            }

                            if (sFirstname.length() > 0) {
                                sLastname += ", " + sFirstname;
                            }

                            %><option value="<%=sMedCode%>" <%=sSelected%>><%=sLastname%> (<%=sMedCode%>)</option><%
                        }
                    %>
                </select>
            </td>
        </tr>

        <%-- TYPE --%>
        <tr>
            <td class='admin'><%=getTran("Web.Occup","medwan.common.type",sWebLanguage)%>&nbsp;</td>
            <td class='admin2'>
                <select id="examination" class="text" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_MIR2_TYPE" property="itemId"/>]>.value">
                    <option value="0" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_MIR2_TYPE;value=0" property="value" outputString="selected"/>><%=getTranNoLink("web","choose",sWebLanguage)%>
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
            </td>
        </tr>

        <%-- OTHER --%>
        <tr>
            <td class='admin'><%=getTran("Web.Occup","othertype",sWebLanguage)%>&nbsp;</td>
            <td class='admin2'>
                <input id="other" type="text" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_MIR2_OTHER" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_MIR2_OTHER" property="value"/>" class="text" size="40" onblur="limitLength(this);">
            </td>
        </tr>

        <%-- REMARK --%>
        <tr>
            <td class='admin'><%=getTran("Web.Occup","medwan.common.remark",sWebLanguage)%>&nbsp;</td>
            <td class='admin2'>
                <textarea id="remark" onKeyup="resizeTextarea(this,10);limitChars(this,255);" <%=setRightClick("ITEM_TYPE_MIR2_REMARK")%> class="text" cols='75' rows='2' name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_MIR2_REMARK" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_MIR2_REMARK" property="value"/></textarea>
            </td>
        </tr>

        <%-- EXAMINATION REASON --%>
        <tr>
            <td class='admin'><%=getTran("Web.Occup","examinationreason",sWebLanguage)%>&nbsp;</td>
            <td class='admin2'>
                <textarea id="reason" onKeyup="resizeTextarea(this,10);limitChars(this,255);" <%=setRightClick("ITEM_TYPE_MIR2_EXAMINATIONREASON")%> class="text" cols='75' rows='2' name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_MIR2_EXAMINATIONREASON" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_MIR2_EXAMINATIONREASON" property="value"/></textarea>
            </td>
        </tr>

        <%-- PROVIDER --%>
        <tr>
            <td class="admin"><%=getTran("Web.Occup","provider",sWebLanguage)%></td>
            <td class="admin2">
                <input type="text" class="text" id="providerCode" size="3" maxLength="3" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OTHER_REQUESTS_SUPPLIER" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OTHER_REQUESTS_SUPPLIER" property="value"/>" onKeyUp="if(document.getElementById('providerCode').value.length == 3){lookupProvider();}">
                <span id="providerMsg"></span>
            </td>
        </tr>

        <%-- VALUE --%>
        <tr>
            <td class="admin"><%=getTran("Web.Occup","value",sWebLanguage)%></td>
            <td class="admin2">
                <input type="text" class="text" size="10" onBlur="setDecimalLength(this,2);isNumber(this);" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OTHER_REQUESTS_VALUE" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OTHER_REQUESTS_VALUE" property="value"/>">
            </td>
        </tr>

        <%-- RESULT RECEIVED --%>
        <tr>
            <td class="admin"><%=getTran("Web.occup","resultreceived",sWebLanguage)%></td>
            <td class="admin2">
                <input type="checkbox" id="resultReceivedCB">
                <input type="hidden" id="resultReceived" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_MIR2_RESULTRECEIVED" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_MIR2_RESULTRECEIVED" property="value" translate="false"/>">
            </td>
        </tr>

        <script>
          <%-- set resultReceivedCB checked depending on the value of resultReceived --%>
          var resultReceivedCB = document.getElementById("resultReceivedCB");
          var resultReceived = document.getElementById("resultReceived");

          if(resultReceived.value=='medwan.common.true'){
            resultReceivedCB.checked = true;
          }
          else{
            resultReceivedCB.checked = false;
          }
        </script>

        <%-- ALS PRESTATIE HERNEMEN --%>
        <tr>
            <td class="admin"><%=getTran("Web.Occup","medwan.healthrecord.prestation_recapture",sWebLanguage)%></td>
            <td class="admin2">
                <input <%=setRightClick("ITEM_TYPE_OTHER_REQUESTS_PRESTATION")%> type="checkbox" id="recapture" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OTHER_REQUESTS_PRESTATION" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OTHER_REQUESTS_PRESTATION;value=medwan.common.true" property="value" outputString="checked"/> value="medwan.common.true">
            </td>
        </tr>
        
    	<%-- BUTTONS ---------------------------------------------------------------------------------%>
        <tr>
            <td class="admin"/>
            <td class="admin2">
		        <input class="button" type="button" value="<%=getTranNoLink("Web.Occup","medwan.common.print",sWebLanguage)%>" onclick="doPrintPDF();">&nbsp;
		        <%
		            if(activeUser.getAccessRight("occup.medicalimagingrequest_fixedunit.add") || activeUser.getAccessRight("occup.medicalimagingrequest_fixedunit.edit")) {
		                %>
		                    <button accesskey="<%=ScreenHelper.getAccessKey(getTranNoLink("accesskey","save",sWebLanguage))%>" class="buttoninvisible" onclick="doSave();"></button>
		                    <button class="button" name="save" id="save" onclick="doSave();"><%=getTran("accesskey","save",sWebLanguage)%></button>
		                <%
		            }
		        %>
                <input class="button" type="button" value="<%=getTranNoLink("Web","back",sWebLanguage)%>" onclick="doBack();"/>
            </td>
        </tr>
    </table>
    
    <%=ScreenHelper.contextFooter(request)%>
</form>

<script>
  <%-- DO SAVE --%>
  function doSave(){
    if(transactionForm.applying_physician.selectedIndex > 0){
      if(transactionForm.examination.selectedIndex > 0){
        if(checkProviderLength()){
          submitForm();
        }
      }
      else{
                  alertDialog("web.manage","dataMissing");
        transactionForm.examination.focus();
      }
    }
    else{
                alertDialog("web.manage","dataMissing");
      transactionForm.applying_physician.focus();
    }
  }
  
  <%-- SUBMIT FORM --%>
  function submitForm(){
    var typeSelect = document.getElementsByName('currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_MIR2_TYPE" property="itemId"/>]>.value'];
    document.getElementsByName('currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_TRANSACTION_RESULT" property="itemId"/>]>.value')[0].value=typeSelect.options[typeSelect.selectedIndex].text;
    transactionForm.saveButton.disabled = true;

    <%-- set the value of the hidden field 'resultReceived' to the textual condition of resultReceivedCB --%>
    var resultReceivedCB = document.getElementById("resultReceivedCB");
    var resultReceived = document.getElementById("resultReceived");

    if(resultReceivedCB.checked){
      resultReceived.value = 'medwan.common.true';
    }
    else{
      resultReceived.value = 'medwan.common.false';
    }

    <%=takeOverTransaction(sessionContainerWO, activeUser,"transactionForm.submit();")%>
  }

  <%-- DO BACK --%>
  function doBack(){
    if(checkSaveButton()){
      window.location.href = '<c:url value="/main.do"/>?Page=curative/index.jsp&ts=<%=getTs()%>';
    }
  }

  <%-- DO PRINT PDF --%>
  function doPrintPDF(){
    window.open('<c:url value="/healthrecord/loadPDF.jsp"/>?file=base/<%=sWebLanguage%>4CO.pdf&module=N4CO&modulepar1='+document.getElementsByName('examination')[0].options[document.getElementsByName('examination')[0].selectedIndex)[0].text+'&modulepar2='+document.getElementsByName('other')[0].value+'&modulepar3='+document.getElementsByName('remark')[0].value+'&modulepar4='+document.getElementsByName('reason')[0].value+'$'+document.getElementById('applying_physician').value+'&ts=<%=ScreenHelper.getTs()%>','Print','toolbar=yes, status=yes, scrollbars=yes, resizable=yes, width=700, height=500,menubar=yes');
  }

  <%-- PROVIDER METHODS --%>
  var providerCode = document.getElementById('providerCode');
  if(providerCode.value!="" && providerCode.value!=" "){
    window.open("<c:url value='/_common/search/template.jsp'/>?Page=blurProvider.jsp&SearchCode="+providerCode.value+"&SourceVar=providerCode&MsgVar=providerMsg&ClearField=no","","height=1, width=1, toolbar=no, status=no, scrollbars=no, resizable=no, menubar=no");
  }

  function lookupProvider(){
    if(providerCode.value.length == 3){
      window.open("<c:url value='/_common/search/template.jsp'/>?Page=blurProvider.jsp&SearchCode="+providerCode.value+"&SourceVar=providerCode&MsgVar=providerMsg","","height=1, width=1, toolbar=no, status=no, scrollbars=no, resizable=no, menubar=no");
    }
    else{
      document.getElementById('providerMsg').innerHTML = '';
    }
  }

  function checkProviderLength(){
    if(providerCode.value.length > 0){
      if(providerCode.value.length == 3){
        return true;
      }
      else{
        providerCode.focus();
        document.getElementById('providerMsg').innerHTML = '<%=getTran("web.manage","invalidprovidercode",sWebLanguage)%>';
        document.getElementById('providerMsg').style.color = 'red';
        return false;
      }
    }

    document.getElementById('providerMsg').innerHTML = '';

    return true;
  }
</script>
<%=writeJSButtons("transactionForm","saveButton")%>