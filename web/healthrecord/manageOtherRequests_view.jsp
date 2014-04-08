<%@page import="be.dpms.medwan.webapp.wo.common.system.SessionContainerWO,
                be.mxs.webapp.wl.session.SessionContainerFactory"%>
<%@include file="/includes/validateUser.jsp"%>
<%@page errorPage="/includes/error.jsp"%>
<%=checkPermission("occupother","select",activeUser)%>

<form name="transactionForm" id="transactionForm" method="POST" action="<c:url value="/healthrecord/updateTransaction.do"/>?ts=<%=getTs()%>">
    <bean:define id="transaction" name="WO_SESSION_CONTAINER" property="currentTransactionVO"/>
	<%=checkPrestationToday(activePatient.personid,false,activeUser,(TransactionVO)transaction)%>

    <input type="hidden" id="transactionId" name="currentTransactionVO.<TransactionVO[hashCode=<bean:write name="transaction" scope="page" property="transactionId"/>]>.transactionId" value="<bean:write name="transaction" scope="page" property="transactionId"/>"/>
    <input type="hidden" id="serverId" name="currentTransactionVO.<TransactionVO[hashCode=<bean:write name="transaction" scope="page" property="transactionId"/>]>.serverId" value="<bean:write name="transaction" scope="page" property="serverId"/>"/>
    <input type="hidden" id="transactionType" name="currentTransactionVO.<TransactionVO[hashCode=<bean:write name="transaction" scope="page" property="transactionId"/>]>.transactionType" value="<bean:write name="transaction" scope="page" property="transactionType"/>"/>
    <input type="hidden" readonly name="be.mxs.healthrecord.updateTransaction.actionForwardKey" value="/occupationalmedicine/managePeriodicExaminations.do?&ts=<%=getTs()%>"/>

    <input type="hidden" readonly name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_TRANSACTION_RESULT" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_TRANSACTION_RESULT" property="value"/>"/>
    <input type="hidden" readonly name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_RECRUITMENT_CONVOCATION_ID" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_RECRUITMENT_CONVOCATION_ID" property="value"/>"/>
    <input type="hidden" readonly name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CONTEXT_DEPARTMENT" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CONTEXT_DEPARTMENT" translate="false" property="value"/>"/>
    <input type="hidden" readonly name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CONTEXT_CONTEXT" translate="false" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CONTEXT_CONTEXT" translate="false" property="value"/>"/>

    <script>
      function submitForm(){
        if(checkProviderLength()){
          document.all["currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_TRANSACTION_RESULT" property="itemId"/>]>.value"].value=document.all["currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OTHER_REQUESTS_DESCRIPTION" property="itemId"/>]>.value"].value;
          transactionForm.saveButton.disabled = true;

          // set value of visible check as value of hidden check
          document.getElementById("recapture").value = "medwan.common."+document.getElementById("recaptureCB").checked;

          <%
              SessionContainerWO sessionContainerWO = (SessionContainerWO)SessionContainerFactory.getInstance().getSessionContainerWO(request,SessionContainerWO.class.getName());
              out.println(takeOverTransaction(sessionContainerWO, activeUser,"transactionForm.submit();"));
          %>
        }
      }
    </script>

    <%=writeHistoryFunctions(((TransactionVO)transaction).getTransactionType(),sWebLanguage)%>
    <%=contextHeader(request,sWebLanguage,activeUser)%>

<table class="list" width="100%" cellspacing="1">
    <%-- TITLE --%>
    <tr>
         <td class="admin" width="20%">
            <a href="javascript:openHistoryPopup();" title="<%=getTranNoLink("web.occup","History",sWebLanguage)%>">...</a>&nbsp;
            <%=getTran("web","date",sWebLanguage)%>
         </td>
         <td class="admin2">
            <input type="text" class="text" size="12" maxLength="10" name="currentTransactionVO.<TransactionVO[hashCode=<bean:write name="transaction" scope="page" property="transactionId"/>]>.updateTime" value="<mxs:propertyAccessorI18N name="transaction" scope="page" property="updateTime" formatType="date" format="dd-mm-yyyy"/>" id="trandate" OnBlur="checkDate(this);"> 
            <script>writeTranDate();</script>
         </td>
    </tr>

    <%-- TYPE --%>
    <tr>
        <td class="admin" width="20%"><%=getTran("web.occup","medwan.common.type",sWebLanguage)%>&nbsp;</td>
        <td class="admin2" colspan="4">
            <select class="text" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_SPECIALIST_TYPE" property="itemId"/>]>.value">
                <option value="0" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_SPECIALIST_TYPE;value=0" property="value" outputString="selected"/>>&nbsp;
                <option value="1" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_SPECIALIST_TYPE;value=1" property="value" outputString="selected"/>><%=getTran("web","medwan.occupational-medicine.medical-specialist.type-1",sWebLanguage)%>
                <option value="2" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_SPECIALIST_TYPE;value=2" property="value" outputString="selected"/>><%=getTran("web","medwan.occupational-medicine.medical-specialist.type-2",sWebLanguage)%>
                <option value="3" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_SPECIALIST_TYPE;value=3" property="value" outputString="selected"/>><%=getTran("web","medwan.occupational-medicine.medical-specialist.type-3",sWebLanguage)%>
                <option value="4" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_SPECIALIST_TYPE;value=4" property="value" outputString="selected"/>><%=getTran("web","medwan.occupational-medicine.medical-specialist.type-4",sWebLanguage)%>
                <option value="5" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_SPECIALIST_TYPE;value=5" property="value" outputString="selected"/>><%=getTran("web","medwan.occupational-medicine.medical-specialist.type-5",sWebLanguage)%>
                <option value="6" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_SPECIALIST_TYPE;value=6" property="value" outputString="selected"/>><%=getTran("web","medwan.occupational-medicine.medical-specialist.type-6",sWebLanguage)%>
                <option value="7" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_SPECIALIST_TYPE;value=7" property="value" outputString="selected"/>><%=getTran("web","medwan.occupational-medicine.medical-specialist.type-7",sWebLanguage)%>
                <option value="8" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_SPECIALIST_TYPE;value=8" property="value" outputString="selected"/>><%=getTran("web","medwan.occupational-medicine.medical-specialist.type-8",sWebLanguage)%>
                <option value="9" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_SPECIALIST_TYPE;value=9" property="value" outputString="selected"/>><%=getTran("web","medwan.occupational-medicine.medical-specialist.type-9",sWebLanguage)%>
                <option value="10" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_SPECIALIST_TYPE;value=10" property="value" outputString="selected"/>><%=getTran("web","medwan.occupational-medicine.medical-specialist.type-10",sWebLanguage)%>
            </select>
        </td>
    </tr>

    <%-- CONTACT DESCRIPTION --%>
    <tr>
        <td class="admin"><%=getTran("web.occup","medwan.healthrecord.contact-description",sWebLanguage)%></td>
        <td class="admin2">
            <textarea onKeyup="resizeTextarea(this,10);limitChars(this,255);" class="text" <%=setRightClick("ITEM_TYPE_OTHER_REQUESTS_DESCRIPTION")%> cols="80" rows="2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OTHER_REQUESTS_DESCRIPTION" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OTHER_REQUESTS_DESCRIPTION" property="value"/></textarea>
        </td>
    </tr>

    <%-- PROVIDER --%>
    <tr>
        <td class="admin"><%=getTran("web.occup","provider",sWebLanguage)%></td>
        <td class="admin2">            
            <input type="text" class="text" id="providerCode" size="3" maxLength="3" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OTHER_REQUESTS_SUPPLIER" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OTHER_REQUESTS_SUPPLIER" property="value"/>" onKeyUp="if(document.getElementById('providerCode').value.length == 3){lookupProvider();}">
            <input class="button" type="button" name="searchProviderButton" value="<%=getTranNoLink("web","Select",sWebLanguage)%>" onClick="searchProvider(document.getElementById('providerCode').value);">
            <span id="providerMsg"></span>
        </td>
    </tr>

    <%-- VALUE --%>
    <tr>
        <td class="admin"><%=getTran("web.occup","value",sWebLanguage)%></td>
        <td class="admin2">
            <input type="text" class="text" size="10" onBlur="setDecimalLength(this,2);isNumber(this);" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OTHER_REQUESTS_VALUE" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OTHER_REQUESTS_VALUE" property="value"/>">
        </td>
    </tr>

    <%-- ALS PRESTATIE HERNEMEN --%>
    <tr>
        <td class="admin" width="<%=sTDAdminWidth%>"><%=getTran("web.occup","medwan.healthrecord.prestation_recapture",sWebLanguage)%></td>
        <td class="admin2">
            <input type="checkbox" id="recaptureCB">
            <input type="hidden" id="recapture" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OTHER_REQUESTS_PRESTATION" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OTHER_REQUESTS_PRESTATION;value=medwan.common.true" property="value" outputString="checked"/> value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OTHER_REQUESTS_PRESTATION" property="value" translate="false"/>">
        </td>
    </tr>

    <script>
        <%-- set recaptureCB checked depending on the value of recapture --%>
        document.getElementById("recaptureCB").checked = (document.getElementById("recapture").value=="medwan.common.true");
    </script>
</table>

<%-- BUTTONS --%>
<p align="right">
    <%
        if(activeUser.hasAccessRight("occupother.add") || activeUser.hasAccessRight("occupother.edit")){
            %>
                <button accesskey="<%=ScreenHelper.getAccessKey(getTranNoLink("accesskey","save",sWebLanguage))%>" class="buttoninvisible" onclick="submitForm();"></button>
                <button class="button" name="save" onclick="submitForm();"><%=getTranNoLink("accesskey","save",sWebLanguage)%></button>
            <%
        }
    %>
    <input class="button" type="button" value="<%=getTranNoLink("web","Back",sWebLanguage)%>" onclick="doBack();">
    <%=writeResetButton("transactionForm",sWebLanguage,activeUser)%>
</p>

<%=contextFooter(request)%>

<script>
  if(transactionForm.transactionId.value.charAt(0)=="-"){
    document.all["recapture"].checked = true;
  }

  <%-- DO BACK --%>
  function doBack(){
    if(checkSaveButton()){
      window.location.href = "<c:url value='/occupationalmedicine/managePeriodicExaminations.do'/>?ts=<%=getTs()%>";
    }
  }

  <%-- BLUR PROVIDER on page load --%>
  var providerCode = document.getElementById("providerCode");
  if(providerCode.value.length() > 0 && providerCode.value!=" "){
    var url = "<%=sCONTEXTPATH%>/_common/search/getProvider.jsp?ts="+new Date().getTime();
    new Ajax.Request(url,
      {
        method: "GET",
        parameters: {
          SearchCode:providerCode.value
        },
        onSuccess: function(resp){
          var respText = convertSpecialCharsToHTML(resp.responseText);
          var data = eval("("+respText+")");

          var msgField = document.getElementById("providerMsg");
          if(trim(data.providerName).length > 0){
            msgField.innerHTML = data.providerName;
            msgField.style.color = "black";
          }
          else{
            msgField.innerHTML = "<%=getTranNoLink("web.manage","providernotfound",sWebLanguage)%>";
            msgField.style.color = "red";
          }
        },
        onFailure: function(resp){
          alert("ERROR :\n"+resp.responseText);
        }
      }
    );
  }

  <%-- SEARCH PROVIDER --%>
  function searchProvider(providerCode){
    var url = "<%=sCONTEXTPATH%>/_common/search/template.jsp?Page=searchProvider.jsp"+
              "&CodeField=providerCode"+
              "&TextField=providerMsg"+
              "&FindCode="+providerCode;
    window.open(url,"SearchProvider","toolbar=no,status=no,scrollbars=yes,resizable=yes,menubar=no,width=1,height=1");
  }
          
  <%-- LOOK UP PROVIDER --%>
  function lookupProvider(){
    if(providerCode.value.length == 3){
      var url = "<%=sCONTEXTPATH%>/_common/search/getProvider.jsp?ts="+new Date().getTime();
      new Ajax.Request(url,
        {
          method: "GET",
          parameters: {
            SearchCode:providerCode.value
          },
          onSuccess: function(resp){
            var respText = convertSpecialCharsToHTML(resp.responseText);
            var data = eval("("+respText+")");

            var msgField = document.getElementById("providerMsg");
            if(trim(data.providerName).length > 0){
              msgField.innerHTML = data.providerName;
              msgField.style.color = "black";
            }
            else{
              msgField.innerHTML = "<%=getTranNoLink("web.manage","providernotfound",sWebLanguage)%>";
              msgField.style.color = "red";

              var srcField = document.getElementById("providerCode");
              srcField.value = "";
              srcField.focus();
            }
          },
          onFailure: function(resp){
            alert("ERROR :\n"+resp.responseText);
          }
        }
      );
    }
    else{
      document.getElementById("providerMsg").innerHTML = "";
    }
  }

  <%-- CHECK PROVIDER LENGTH --%>
  function checkProviderLength(){
    if(providerCode.value.length > 0){
      if(providerCode.value.length == 3){
        return true;
      }
      else{
        providerCode.focus();
        document.getElementById("providerMsg").innerHTML = "<%=getTranNoLink("web.manage","invalidprovidercode",sWebLanguage)%>";
        document.getElementById("providerMsg").style.color = "red";
        return false;
      }
    }
    document.getElementById("providerMsg").innerHTML = "";
    return true;
  }
</script>

</form>
<%=writeJSButtons("transactionForm","document.all['save']")%>