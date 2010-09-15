<%@include file="/includes/validateUser.jsp"%>
<%@page errorPage="/includes/error.jsp"%>
<%=checkPermission("occup.other","select",activeUser)%>
<form name="transactionForm" id="transactionForm" method="POST" action='<c:url value="/healthrecord/updateTransaction.do"/>?ts=<%=getTs()%>' onclick="setSaveButton(event);" onkeyup="setSaveButton(event);">
    <bean:define id="transaction" name="be.mxs.webapp.wl.session.SessionContainerFactory.WO_SESSION_CONTAINER" property="currentTransactionVO"/>
    <input type="hidden" id="transactionId" name="currentTransactionVO.<TransactionVO[hashCode=<bean:write name="transaction" scope="page" property="transactionId"/>]>.transactionId" value="<bean:write name="transaction" scope="page" property="transactionId"/>"/>
    <input type="hidden" id="serverId" name="currentTransactionVO.<TransactionVO[hashCode=<bean:write name="transaction" scope="page" property="transactionId"/>]>.serverId" value="<bean:write name="transaction" scope="page" property="serverId"/>"/>
    <input type="hidden" id="transactionType" name="currentTransactionVO.<TransactionVO[hashCode=<bean:write name="transaction" scope="page" property="transactionId"/>]>.transactionType" value="<bean:write name="transaction" scope="page" property="transactionType"/>"/>
    <input type="hidden" readonly name="be.mxs.healthrecord.updateTransaction.actionForwardKey" value="/main.do?Page=curative/index.jsp&ts=<%=getTs()%>"/>
    <input type="hidden" readonly name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_TRANSACTION_RESULT" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_TRANSACTION_RESULT" property="value"/>"/>
    <input type="hidden" readonly name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CONTEXT_DEPARTMENT" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CONTEXT_DEPARTMENT" translate="false" property="value"/>"/>
    <input type="hidden" readonly name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CONTEXT_CONTEXT" translate="false" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CONTEXT_CONTEXT" translate="false" property="value"/>"/>

    <%=writeHistoryFunctions(((TransactionVO)transaction).getTransactionType(),sWebLanguage)%>
    <%=contextHeader(request,sWebLanguage)%>
    <table class="list" width="100%" cellspacing="1">
        <%-- DATE --%>
        <tr>
            <td class="admin">
                <a href="javascript:openHistoryPopup();" title="<%=getTran("Web.Occup","History",sWebLanguage)%>">...</a>&nbsp;
                <%=getTran("Web.Occup","medwan.common.date",sWebLanguage)%>
            </td>
            <td class="admin2">
                <input type="text" class="text" size="12" value="<mxs:propertyAccessorI18N name="transaction" scope="page" property="updateTime" formatType="date" format="dd-mm-yyyy"/>" name="currentTransactionVO.<TransactionVO[hashCode=<bean:write name="transaction" scope="page" property="transactionId"/>]>.updateTime" id="trandate" OnBlur='checkDate(this)'>
                <script>writeMyDate("trandate","<c:url value="/_img/icon_agenda.gif"/>","<%=getTran("Web","PutToday",sWebLanguage)%>");</script>
            </td>
        </tr>
        <%-- TYPE --%>
        <tr>
            <td class='admin'><%=getTran("Web.Occup","medwan.common.type",sWebLanguage)%>&nbsp;</td>
            <td class='admin2'>
                <select id="examination" class="text" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_MIR_TYPE" property="itemId"/>]>.value">
                    <option value="0" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_MIR_TYPE;value=0" property="value" outputString="selected"/>><%=getTran("Web","choose",sWebLanguage)%>
                    <option value="1" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_MIR_TYPE;value=1" property="value" outputString="selected"/>><%=getTran("Web.Occup","medwan.occupational-medicine.medical-imaging-request.type-1",sWebLanguage)%>
                    <option value="2" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_MIR_TYPE;value=2" property="value" outputString="selected"/>><%=getTran("Web.Occup","medwan.occupational-medicine.medical-imaging-request.type-2",sWebLanguage)%>
                    <option value="3" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_MIR_TYPE;value=3" property="value" outputString="selected"/>><%=getTran("Web.Occup","medwan.occupational-medicine.medical-imaging-request.type-3",sWebLanguage)%>
                    <option value="4" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_MIR_TYPE;value=4" property="value" outputString="selected"/>><%=getTran("Web.Occup","medwan.occupational-medicine.medical-imaging-request.type-4",sWebLanguage)%>
                    <option value="5" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_MIR_TYPE;value=5" property="value" outputString="selected"/>><%=getTran("Web.Occup","medwan.occupational-medicine.medical-imaging-request.type-5",sWebLanguage)%>
                    <option value="6" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_MIR_TYPE;value=6" property="value" outputString="selected"/>><%=getTran("Web.Occup","medwan.occupational-medicine.medical-imaging-request.type-6",sWebLanguage)%>
                    <option value="7" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_MIR_TYPE;value=7" property="value" outputString="selected"/>><%=getTran("Web.Occup","medwan.occupational-medicine.medical-imaging-request.type-7",sWebLanguage)%>
                    <option value="8" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_MIR_TYPE;value=8" property="value" outputString="selected"/>><%=getTran("Web.Occup","medwan.occupational-medicine.medical-imaging-request.type-8",sWebLanguage)%>
                    <option value="9" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_MIR_TYPE;value=9" property="value" outputString="selected"/>><%=getTran("Web.Occup","medwan.occupational-medicine.medical-imaging-request.type-9",sWebLanguage)%>
                </select>
            </td>
        </tr>
        <%-- OTHER --%>
        <tr>
            <td class='admin'><%=getTran("Web.Occup","othertype",sWebLanguage)%>&nbsp;</td>
            <td class='admin2'>
                <input id="other" type="text" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_MIR_OTHER" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_MIR_OTHER" property="value"/>" class="text" size="40" onblur="validateText(this);limitLength(this);">
            </td>
        </tr>
        <%-- REMARK --%>
        <tr>
            <td class='admin'><%=getTran("Web.Occup","medwan.common.remark",sWebLanguage)%>&nbsp;</td>
            <td class='admin2'>
                <textarea id="remark" onKeyup="resizeTextarea(this,10);limitChars(this,255);" <%=setRightClick("ITEM_TYPE_MIR_REMARK")%> class="text" cols='75' rows='2' name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_MIR_REMARK" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_MIR_REMARK" property="value"/></textarea>
            </td>
        </tr>
        <%-- EXAMINATION REASON --%>
        <tr>
            <td class='admin'><%=getTran("Web.Occup","examinationreason",sWebLanguage)%>&nbsp;</td>
            <td class='admin2'>
                <textarea id="reason" onKeyup="resizeTextarea(this,10);limitChars(this,255);" <%=setRightClick("ITEM_TYPE_MIR_EXAMINATIONREASON")%> class="text" cols='75' rows='2' name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_MIR_EXAMINATIONREASON" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_MIR_EXAMINATIONREASON" property="value"/></textarea>
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
                <input type="checkbox" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_MIR_RESULTRECEIVED" property="itemId"/>]>.value" value="medwan.common.true" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_MIR_RESULTRECEIVED;value=medwan.common.true" property="value" outputString="checked"/>/>
            </td>
        </tr>
    </table>
    <%-- BUTTONS --%>
    <%=ScreenHelper.alignButtonsStart()%>
        <INPUT class="button" type="button" value="<%=getTran("Web.Occup","medwan.common.print",sWebLanguage)%>" onclick="window.open('<%=sCONTEXTPATH+sAPPDIR%>/loadPDF.jsp?file=base/<%=sWebLanguage%>4CO.pdf&module=N4C&modulepar1='+document.all['examination'].options[document.all['examination'].selectedIndex].text+'&modulepar2='+document.all['other'].value+'&modulepar3='+document.all['remark'].value+'&modulepar4='+document.all['reason'].value+'&ts=<%=ScreenHelper.getTs()%>','Print','toolbar=yes, status=yes, scrollbars=yes, resizable=yes, width=700, height=500,menubar=yes');">
        <%
            if(activeUser.getAccessRight("occup.other.add") || activeUser.getAccessRight("occup.other.edit")) {
            %>
                <INPUT class="button" type="button" name="save" id="save" value="<%=getTran("Web.Occup","medwan.common.record",sWebLanguage)%>" onclick="submitForm()"/>
            <%
            }
        %>
        <INPUT class="button" type="button" value="<%=getTran("Web","back",sWebLanguage)%>" onclick="doBack();"/>
    <%=ScreenHelper.alignButtonsStop()%>
    <%=ScreenHelper.contextFooter(request)%>
</form>
<script>
  var providerCode = document.getElementById('providerCode');
  if(providerCode.value!="" && providerCode.value!=" "){
    window.open("<c:url value='/_common/search/template.jsp'/>?Page=blurProvider.jsp&SearchCode="+providerCode.value+"&SourceVar=providerCode&MsgVar=providerMsg&ClearField=no","","height=1, width=1, toolbar=no, status=no, scrollbars=no, resizable=no, menubar=no");
  }

  function submitForm(){
    if(document.getElementById('examination').selectedIndex > 0){
      if(checkProviderLength()){
        var typeSelect = document.all['currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_MIR_TYPE" property="itemId"/>]>.value'];
        document.all['currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_TRANSACTION_RESULT" property="itemId"/>]>.value'].value=typeSelect.options[typeSelect.selectedIndex].text;
        document.transactionForm.save.disabled = true;
        <%
            SessionContainerWO sessionContainerWO = (SessionContainerWO)SessionContainerFactory.getInstance().getSessionContainerWO(request,SessionContainerWO.class.getName());
            out.print(takeOverTransaction(sessionContainerWO, activeUser,"transactionForm.submit();"));
        %>
      }
    }
    else{
      var popupUrl = "<%=sCONTEXTPATH%>/_common/search/template.jsp?Page=okPopup.jsp&ts=<%=getTs()%>&labelType=web.manage&labelID=datamissing";
      var modalities = "dialogWidth:266px;dialogHeight:143px;center:yes;scrollbars:no;resizable:no;status:no;location:no;";
      var answer = window.showModalDialog(popupUrl,'',modalities);

      transactionForm.examination.focus();
    }
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

  function doBack(){
    if (checkSaveButton('<%=sCONTEXTPATH%>','<%=getTran("Web.Occup","medwan.common.buttonquestion",sWebLanguage)%>')){
      window.location.href = '<c:url value="/main.do"/>?Page=curative/index.jsp&ts=<%=getTs()%>';
    }
  }
</script>
<%=writeJSButtons("transactionForm","save")%>