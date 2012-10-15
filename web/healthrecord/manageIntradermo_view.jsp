<%@include file="/includes/validateUser.jsp"%>
<%@page errorPage="/includes/error.jsp"%>
<%=checkPermission("manageIntradermo","select",activeUser)%>

<form name="transactionForm" id="transactionForm" method="POST" action="<c:url value="/healthrecord/updateTransaction.do"/>?ts=<%=getTs()%>">
    <bean:define id="transaction" name="be.mxs.webapp.wl.session.SessionContainerFactory.WO_SESSION_CONTAINER" property="currentTransactionVO"/>
    <% TransactionVO tran = (TransactionVO)transaction; %>

    <input type="hidden" id="transactionId" name="currentTransactionVO.<TransactionVO[hashCode=<bean:write name="transaction" scope="page" property="transactionId"/>]>.transactionId" value="<bean:write name="transaction" scope="page" property="transactionId"/>"/>
    <input type="hidden" id="serverId" name="currentTransactionVO.<TransactionVO[hashCode=<bean:write name="transaction" scope="page" property="transactionId"/>]>.serverId" value="<bean:write name="transaction" scope="page" property="serverId"/>"/>
    <input type="hidden" id="transactionType" name="currentTransactionVO.<TransactionVO[hashCode=<bean:write name="transaction" scope="page" property="transactionId"/>]>.transactionType" value="<bean:write name="transaction" scope="page" property="transactionType"/>"/>
    <input type="hidden" readonly name="be.mxs.healthrecord.updateTransaction.actionForwardKey" value="/occupationalmedicine/managePeriodicExaminations.do?&ts=<%=getTs()%>"/>
    <input type="hidden" readonly name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CONTEXT_CONTEXT" translate="false" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CONTEXT_CONTEXT" translate="false" property="value"/>"/>

    <%=writeHistoryFunctions(tran.getTransactionType(),sWebLanguage)%>
    <%=contextHeader(request,sWebLanguage)%>

    <table width="100%" class="list" cellspacing="1">
        <%-- DATE --%>
        <tr>
            <td class="admin" width="<%=sTDAdminWidth%>">
                <a href="javascript:openHistoryPopup();" title="<%=getTranNoLink("web.occup","History",sWebLanguage)%>">...</a>&nbsp;
                <%=getTran("web","date",sWebLanguage)%>
            </td>
            <td class="admin2">
                <input type="text" class="text" size="12" maxLength="10" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DATE" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DATE" property="value" formatType="date" format="dd-mm-yyyy"/>" id="trandate" onBlur="if(checkDate(this)){ checkAfter('nextdate',this); }"/>
                <script>writeMyDate("trandate","<c:url value="/_img/calbtn.gif"/>","<%=getTranNoLink("web","PutToday",sWebLanguage)%>");</script>
            </td>
        </tr>

        <%-- NEXT DATE --%>
        <tr>
            <td class="admin"><%=getTran("web.occup","intradermo.nextdate",sWebLanguage)%>&nbsp;</td>
            <td class="admin2">
                <input type="text" class="text" size="12" maxLength="10" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_NEXTDATE" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_NEXTDATE" property="value" formatType="date" format="dd-mm-yyyy"/>" id="nextdate" onBlur="if(checkDate(this)){ checkBefore('trandate',this); }"/>
                <script>writeMyDate("nextdate","<c:url value="/_img/calbtn.gif"/>","<%=getTranNoLink("web","PutToday",sWebLanguage)%>");</script>
            </td>
        </tr>

        <%-- READ DATE --%>
        <tr>
            <td class="admin"><%=getTran("web.occup","intradermo.readdate",sWebLanguage)%>&nbsp;</td>
            <td class="admin2">
                <input type="text" class="text" size="12" maxLength="10" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_READDATE" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_READDATE" property="value" formatType="date" format="dd-mm-yyyy"/>" id="readdate" onBlur="if(checkDate(this)){ checkBefore('trandate',this); }"/>
                <script>writeMyDate("readdate","<c:url value="/_img/calbtn.gif"/>","<%=getTranNoLink("web","PutToday",sWebLanguage)%>");</script>
            </td>
        </tr>

        <%-- RESULT (dropdown) --%>
        <tr>
            <td class="admin"><%=getTran("web.occup","intradermo.result",sWebLanguage)%>&nbsp;</td>
            <td class="admin2">
                <select id="result" onChange="setBelongingFieldsActive(this);" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_RESULT" property="itemId"/>]>.value" class="text">
                    <option value="medwan.common.negative" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_RESULT;value=medwan.common.negative" property="value" outputString="selected"/>><%=getTran("web.occup","medwan.common.negative",sWebLanguage)%>
                    <option value="medwan.common.positive" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_RESULT;value=medwan.common.positive" property="value" outputString="selected"/>><%=getTran("web.occup","medwan.common.positive",sWebLanguage)%>
                </select>
            </td>
        </tr>

        <%-- induration size --%>
        <tr>
            <td class="admin"><%=getTran("web.occup","intradermo.indurationsize",sWebLanguage)%>&nbsp;</td>
            <td class="admin2">
                <input type="text" class="text" id="indurationsize" size="12" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_INDURATION_SIZE" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_INDURATION_SIZE" property="value"/>" onBlur="isNumber(this);"> mm
            </td>
        </tr>

        <%-- associated reactions (dropdown) --%>
        <tr>
            <td class="admin"><%=getTran("web.occup","intradermo.associatedreactions",sWebLanguage)%>&nbsp;</td>
            <td class="admin2">
                <select id="associatedreactions" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ASSOCIATED_REACTIONS" property="itemId"/>]>.value" class="text">
                    <option value="intradermo.accosiatedreactions.no" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ASSOCIATED_REACTIONS;value=intradermo.accosiatedreactions.no"  property="value" outputString="selected"/>><%=getTran("web.occup","intradermo.accosiatedreactions.no",sWebLanguage)%>
                    <option value="intradermo.accosiatedreactions.yes"<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ASSOCIATED_REACTIONS;value=intradermo.accosiatedreactions.yes" property="value" outputString="selected"/>><%=getTran("web.occup","intradermo.accosiatedreactions.yes",sWebLanguage)%>
                </select>
            </td>
        </tr>

        <%-- induration consistence (dropdown) --%>
        <tr>
            <td class="admin"><%=getTran("web.occup","intradermo.indurationconsistence",sWebLanguage)%>&nbsp;</td>
            <td class="admin2">
                <select id="indurationconsistence" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_INDURATION_CONSISTENCY" property="itemId"/>]>.value" class="text">
                    <option>
                    <option value="intradermo.indurationconsistency.1" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_INDURATION_CONSISTENCY;value=intradermo.indurationconsistency.1" property="value" outputString="selected"/>><%=getTran("web.occup","intradermo.indurationconsistency.1",sWebLanguage)%>
                    <option value="intradermo.indurationconsistency.2" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_INDURATION_CONSISTENCY;value=intradermo.indurationconsistency.2" property="value" outputString="selected"/>><%=getTran("web.occup","intradermo.indurationconsistency.2",sWebLanguage)%>
                    <option value="intradermo.indurationconsistency.3" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_INDURATION_CONSISTENCY;value=intradermo.indurationconsistency.3" property="value" outputString="selected"/>><%=getTran("web.occup","intradermo.indurationconsistency.3",sWebLanguage)%>
                    <option value="intradermo.indurationconsistency.4" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_INDURATION_CONSISTENCY;value=intradermo.indurationconsistency.4" property="value" outputString="selected"/>><%=getTran("web.occup","intradermo.indurationconsistency.4",sWebLanguage)%>
                </select>
            </td>
        </tr>

        <%-- reaction types (checkboxes) --%>
        <tr>
            <td class="admin"><%=getTran("web.occup","intradermo.reactiontype",sWebLanguage)%>&nbsp;</td>
            <td class="admin2">
                <input type="checkbox" id="reaction1" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_REACTION_TYPE_BUBBLE" property="itemId"/>]>.value"       value="intradermo.reactiontype.bubble"       <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_REACTION_TYPE_BUBBLE;value=intradermo.reactiontype.bubble" property="value" outputString="checked"/>/><%=getLabel("web.occup","intradermo.reactiontype.bubble",sWebLanguage,"reaction1")%>
                <input type="checkbox" id="reaction2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_REACTION_TYPE_BLUSH" property="itemId"/>]>.value"        value="intradermo.reactiontype.blush"        <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_REACTION_TYPE_BLUSH;value=intradermo.reactiontype.blush" property="value" outputString="checked"/>/><%=getLabel("web.occup","intradermo.reactiontype.blush",sWebLanguage,"reaction2")%>
                <input type="checkbox" id="reaction3" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_REACTION_TYPE_OEDEEM" property="itemId"/>]>.value"       value="intradermo.reactiontype.oedeem"       <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_REACTION_TYPE_OEDEEM;value=intradermo.reactiontype.oedeem" property="value" outputString="checked"/>/><%=getLabel("web.occup","intradermo.reactiontype.oedeem",sWebLanguage,"reaction3")%>
                <input type="checkbox" id="reaction4" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_REACTION_TYPE_LYMPHANGITIS" property="itemId"/>]>.value" value="intradermo.reactiontype.lymphangitis" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_REACTION_TYPE_LYMPHANGITIS;value=intradermo.reactiontype.lymphangitis" property="value" outputString="checked"/>/><%=getLabel("web.occup","intradermo.reactiontype.lymphangitis",sWebLanguage,"reaction4")%>
                <input type="checkbox" id="reaction5" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_REACTION_TYPE_ADENOPATHY" property="itemId"/>]>.value"   value="intradermo.reactiontype.adenopathy"   <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_REACTION_TYPE_ADENOPATHY;value=intradermo.reactiontype.adenopathy" property="value" outputString="checked"/>/><%=getLabel("web.occup","intradermo.reactiontype.adenopathy",sWebLanguage,"reaction5")%>
            </td>
        </tr>

        <%-- COMMENT --%>
        <tr>
            <td class="admin"><%=getTran("web.occup","intradermo.comment",sWebLanguage)%>&nbsp;</td>
            <td class="admin2">
                <textarea onKeyup="resizeTextarea(this,10);limitChars(this,255);" class="text" cols="110" rows="3" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_COMMENT" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_COMMENT" property="value"/></textarea>
            </td>
        </tr>

        <%-- RESULT RECEIVED --%>
        <tr>
            <td class="admin"><%=getTran("web.occup","resultreceived",sWebLanguage)%></td>
            <td class="admin2">
                <input type="checkbox" id="resultReceivedCB">
                <input type="hidden" id="resultReceived" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_RESULTRECEIVED" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_RESULTRECEIVED" property="value" translate="false"/>">
            </td>
        </tr>


        <script>
          <%-- set resultReceivedCB checked depending on the value of resultReceived --%>
          var resultReceivedCB = document.getElementById("resultReceivedCB");
          var resultReceived = document.getElementById("resultReceived");

          resultReceivedCB.checked = (resultReceived.value=="on");
        </script>
    </table>

    <%
    	boolean dossierBlocked=false;
    String sBlockedReason="";
        // display "dossier blocked"
        if(dossierBlocked){
            %><br><font color="red"><%=getTran("web",sBlockedReason,sWebLanguage)%></font>&nbsp;<%
        }
    %>

    <%-- BUTTONS --%>
    <p align="right">
        <%
            if(!dossierBlocked ){
            }
            else{
                %><button class="button" name="saveButton" style="display:none;">hidden</button><%
            }
        %>
        <input class="button" type="button" name="resetButton" value="<%=getTranNoLink("web","reset",sWebLanguage)%>" onclick="doReset();">
        <input class="button" type="button" name="backButton" value="<%=getTranNoLink("web","back",sWebLanguage)%>" onclick="doBack();">
    </p>
</form>

<script>
  setBelongingFieldsActive(document.getElementById("result"));

  <%-- trandate now by default if no other date specified --%>
  if(transactionForm.trandate.value.length == 0){
    transactionForm.trandate.value = "<%=new SimpleDateFormat("dd/MM/yyyy").format(new java.util.Date())%>";
  }

  <%-- SET BELONGING FIELDS ACTIVE --%>
  function setBelongingFieldsActive(selectObj){
    var state;
    if(selectObj.value == "medwan.common.negative"){
      state = true;
      clearBelongingFields();
    }
    else{
      state = false;
    }

    document.getElementById("indurationsize").disabled = state;
    document.getElementById("associatedreactions").disabled = state;
    document.getElementById("indurationconsistence").disabled = state;
    document.getElementById("reaction1").disabled = state;
    document.getElementById("reaction2").disabled = state;
    document.getElementById("reaction3").disabled = state;
    document.getElementById("reaction4").disabled = state;
    document.getElementById("reaction5").disabled = state;
  }

  <%-- CLEAR BELONGING FIELDS --%>
  function clearBelongingFields(){
    document.getElementById("indurationsize").value = "";
    document.getElementById("associatedreactions").selectedIndex = 0;
    document.getElementById("indurationconsistence").selectedIndex = 0;
    document.getElementById("reaction1").checked = false;
    document.getElementById("reaction2").checked = false;
    document.getElementById("reaction3").checked = false;
    document.getElementById("reaction4").checked = false;
    document.getElementById("reaction5").checked = false;
  }

  <%-- RESET --%>
  function doReset(){
    transactionForm.reset();
    setBelongingFieldsActive(document.getElementById("result"));
  }

  <%-- BACK --%>
  function doBack(){
    if(checkSaveButton()){
      window.location.href = "<c:url value="/occupationalmedicine/managePeriodicExaminations.do"/>?ts=<%=getTs()%>";
    }
  }

  <%-- SUBMIT FORM --%>
  function submitForm(){
    var okToSubmit = true;

    if(okToSubmit){
      okToSubmit = checkTranDate();
    }

    if(okToSubmit){
      <%-- set the value of the hidden field 'resultReceived' to the textual condition of resultReceivedCB --%>
      var resultReceivedCB = document.getElementById("resultReceivedCB");
      var resultReceived = document.getElementById("resultReceived");

      if(resultReceivedCB.checked) resultReceived.value = "on";
      else                         resultReceived.value = "off";

      disableButtons();

      <%
          SessionContainerWO sessionContainerWO = (SessionContainerWO)SessionContainerFactory.getInstance().getSessionContainerWO(request,SessionContainerWO.class.getName());
          out.println(takeOverTransaction(sessionContainerWO, activeUser,"transactionForm.submit();"));
      %>
    }
  }

  <%-- DISABLE BUTTONS --%>
  function disableButtons(){
    if(transactionForm.saveButton!=null) transactionForm.saveButton.disabled = true;
    if(transactionForm.resetButton!=null) transactionForm.resetButton.disabled = true;
    if(transactionForm.backButton!=null) transactionForm.backButton.disabled = true;
  }
</script>

<%=ScreenHelper.contextFooter(request)%>
<%=writeJSButtons("transactionForm","document.getElementsByName('saveButton')[0]")%>
