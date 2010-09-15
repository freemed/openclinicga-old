<%@page import="be.dpms.medwan.webapp.wo.common.system.SessionContainerWO,
                be.mxs.webapp.wl.session.SessionContainerFactory"%>
<%@include file="/includes/validateUser.jsp"%>
<%@page errorPage="/includes/error.jsp"%>
<%=checkPermission("occup.otherrequests","select",activeUser)%>
<form name="transactionForm" id="transactionForm" method="POST" action='<c:url value="/healthrecord/updateTransaction.do"/>?ts=<%=getTs()%>' onclick="setSaveButton(event);" onkeyup="setSaveButton(event);">
    <bean:define id="transaction" name="be.mxs.webapp.wl.session.SessionContainerFactory.WO_SESSION_CONTAINER" property="currentTransactionVO"/>
    <input type="hidden" id="transactionId" name="currentTransactionVO.<TransactionVO[hashCode=<bean:write name="transaction" scope="page" property="transactionId"/>]>.transactionId" value="<bean:write name="transaction" scope="page" property="transactionId"/>"/>
    <input type="hidden" id="serverId" name="currentTransactionVO.<TransactionVO[hashCode=<bean:write name="transaction" scope="page" property="transactionId"/>]>.serverId" value="<bean:write name="transaction" scope="page" property="serverId"/>"/>
    <input type="hidden" id="transactionType" name="currentTransactionVO.<TransactionVO[hashCode=<bean:write name="transaction" scope="page" property="transactionId"/>]>.transactionType" value="<bean:write name="transaction" scope="page" property="transactionType"/>"/>
    <input type="hidden" readonly name="be.mxs.healthrecord.updateTransaction.actionForwardKey" value="/main.do?&Page=curative/index.jsp&ts=<%=getTs()%>"/>
    <input type="hidden" readonly name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_TRANSACTION_RESULT" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_TRANSACTION_RESULT" property="value"/>"/>
    <input type="hidden" readonly name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_RECRUITMENT_CONVOCATION_ID" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_RECRUITMENT_CONVOCATION_ID" property="value"/>"/>
    <input type="hidden" readonly name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CONTEXT_DEPARTMENT" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CONTEXT_DEPARTMENT" translate="false" property="value"/>"/>
    <input type="hidden" readonly name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CONTEXT_CONTEXT" translate="false" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CONTEXT_CONTEXT" translate="false" property="value"/>"/>

    <script>
      function submitForm(){
        if(checkProviderLength()){
          document.all['currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_TRANSACTION_RESULT" property="itemId"/>]>.value'].value=document.all['currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OTHER_REQUESTS_DESCRIPTION" property="itemId"/>]>.value'].value;
          document.transactionForm.save.disabled = true;
          <%
              SessionContainerWO sessionContainerWO = (SessionContainerWO)SessionContainerFactory.getInstance().getSessionContainerWO(request,SessionContainerWO.class.getName());
              out.print(takeOverTransaction(sessionContainerWO, activeUser,"document.transactionForm.submit();"));
          %>
        }
      }
    </script>
    <%=writeHistoryFunctions(((TransactionVO)transaction).getTransactionType(),sWebLanguage)%>
    <%=contextHeader(request,sWebLanguage)%>
<table class="list" width="100%" cellspacing="1">
    <%-- TITLE --%>
    <tr>
         <td class="admin" width="20%">
            <a href="javascript:openHistoryPopup();" title="<%=getTran("Web.Occup","History",sWebLanguage)%>">...</a>&nbsp;
            <%=getTran("Web.Occup","medwan.common.date",sWebLanguage)%>
         </td>
         <td class="admin2">
            <input type="text" class="text" size="12" maxLength="10" name="currentTransactionVO.<TransactionVO[hashCode=<bean:write name="transaction" scope="page" property="transactionId"/>]>.updateTime" value="<mxs:propertyAccessorI18N name="transaction" scope="page" property="updateTime" formatType="date" format="dd-mm-yyyy"/>" id="trandate" OnBlur='checkDate(this)'> <script>writeMyDate("trandate","<c:url value="/_img/calbtn.gif"/>","<%=getTran("Web","PutToday",sWebLanguage)%>");</script>
         </td>
    </tr>
    <%-- TYPE --%>
    <tr>
        <td class='admin' width="20%"><%=getTran("Web.Occup","medwan.common.type",sWebLanguage)%>&nbsp;</td>
        <td class='admin2' colspan="4">
            <select class="text" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_SPECIALIST_TYPE" property="itemId"/>]>.value">
                <option value="0" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_SPECIALIST_TYPE;value=0" property="value" outputString="selected"/>>&nbsp;
                <option value="1" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_SPECIALIST_TYPE;value=1" property="value" outputString="selected"/>><%=getTran("Web","medwan.occupational-medicine.medical-specialist.type-1",sWebLanguage)%>
                <option value="2" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_SPECIALIST_TYPE;value=2" property="value" outputString="selected"/>><%=getTran("Web","medwan.occupational-medicine.medical-specialist.type-2",sWebLanguage)%>
                <option value="3" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_SPECIALIST_TYPE;value=3" property="value" outputString="selected"/>><%=getTran("Web","medwan.occupational-medicine.medical-specialist.type-3",sWebLanguage)%>
                <option value="4" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_SPECIALIST_TYPE;value=4" property="value" outputString="selected"/>><%=getTran("Web","medwan.occupational-medicine.medical-specialist.type-4",sWebLanguage)%>
                <option value="5" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_SPECIALIST_TYPE;value=5" property="value" outputString="selected"/>><%=getTran("Web","medwan.occupational-medicine.medical-specialist.type-5",sWebLanguage)%>
                <option value="6" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_SPECIALIST_TYPE;value=6" property="value" outputString="selected"/>><%=getTran("Web","medwan.occupational-medicine.medical-specialist.type-6",sWebLanguage)%>
                <option value="7" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_SPECIALIST_TYPE;value=7" property="value" outputString="selected"/>><%=getTran("Web","medwan.occupational-medicine.medical-specialist.type-7",sWebLanguage)%>
                <option value="8" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_SPECIALIST_TYPE;value=8" property="value" outputString="selected"/>><%=getTran("Web","medwan.occupational-medicine.medical-specialist.type-8",sWebLanguage)%>
                <option value="9" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_SPECIALIST_TYPE;value=9" property="value" outputString="selected"/>><%=getTran("Web","medwan.occupational-medicine.medical-specialist.type-9",sWebLanguage)%>
                <option value="10" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_SPECIALIST_TYPE;value=10" property="value" outputString="selected"/>><%=getTran("Web","medwan.occupational-medicine.medical-specialist.type-10",sWebLanguage)%>
            </select>
        </td>
    </tr>
    <%-- CONTACT DESCRIPTION --%>
    <tr>
        <td class="admin"><%=getTran("Web.Occup","medwan.healthrecord.contact-description",sWebLanguage)%></td>
        <td class="admin2">
            <textarea onKeyup="resizeTextarea(this,10);limitChars(this,255);" class="text" <%=setRightClick("ITEM_TYPE_OTHER_REQUESTS_DESCRIPTION")%> cols="80" rows="2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OTHER_REQUESTS_DESCRIPTION" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OTHER_REQUESTS_DESCRIPTION" property="value"/></textarea>
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
    <%-- ALS PRESTATIE HERNEMEN --%>
    <tr>
        <td class="admin"><%=getTran("Web.Occup","medwan.healthrecord.prestation_recapture",sWebLanguage)%></td>
        <td class="admin2">
            <input <%=setRightClick("ITEM_TYPE_OTHER_REQUESTS_PRESTATION")%> type="checkbox" id="mor_c1" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OTHER_REQUESTS_PRESTATION" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OTHER_REQUESTS_PRESTATION;value=medwan.common.true" property="value" outputString="checked"/> value="medwan.common.true">
        </td>
    </tr>
    <tr>
        <td class="admin"/>
        <td class="admin2">
<%-- BUTTONS --%>
    <%
        if((activeUser.getAccessRight("occup.otherrequests.add"))||(activeUser.getAccessRight("occup.otherrequests.edit"))){
            %>
            <INPUT class="button" type="button" name="save" id="save" value="<%=getTran("Web.Occup","medwan.common.record",sWebLanguage)%>" onclick="submitForm()"/>
            <%
        }
    %>
            <INPUT class="button" type="button" value="<%=getTran("Web","Back",sWebLanguage)%>" onclick="if (checkSaveButton('<%=sCONTEXTPATH%>','<%=getTran("Web.Occup","medwan.common.buttonquestion",sWebLanguage)%>')){window.location.href='<c:url value="/main.do"/>?Page=curative/index.jsp&ts=<%=getTs()%>'}">
        </td>
    </tr>
</table>
<%=ScreenHelper.contextFooter(request)%>
<script>
  if(transactionForm.transactionId.value.charAt(0)=="-"){
    document.all['mor_c1'].checked = true;
  }

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
</form>
<%=writeJSButtons("transactionForm","save")%>