<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>
<%=checkPermission("occup.managealerts","select",activeUser)%>
<form name="transactionForm" id="transactionForm" method="POST" action="<c:url value='/healthrecord/updateTransaction.do'/>?ts=<%=getTs()%>" focus='type' onclick="setSaveButton(event);" onkeyup="setSaveButton(event);">
    <bean:define id="transaction" name="be.mxs.webapp.wl.session.SessionContainerFactory.WO_SESSION_CONTAINER" property="currentTransactionVO"/>
	<%=checkPrestationToday(activePatient.personid, false, activeUser, (TransactionVO)transaction) %>

    <input type="hidden" id="transactionId" name="currentTransactionVO.<TransactionVO[hashCode=<bean:write name="transaction" scope="page" property="transactionId"/>]>.transactionId" value="<bean:write name="transaction" scope="page" property="transactionId"/>"/>
    <input type="hidden" id="transactionType" name="currentTransactionVO.<TransactionVO[hashCode=<bean:write name="transaction" scope="page" property="transactionId"/>]>.transactionType" value="<bean:write name="transaction" scope="page" property="transactionType"/>"/>
    <input type="hidden" id="serverId" name="currentTransactionVO.<TransactionVO[hashCode=<bean:write name="transaction" scope="page" property="transactionId"/>]>.serverId" value="<bean:write name="transaction" scope="page" property="serverId"/>"/>
    <input type="hidden" readonly name="be.mxs.healthrecord.updateTransaction.actionForwardKey" value="/main.do?Page=curative/index.jsp?ts=<%=getTs()%>"/>
    <%=writeTableHeader("Web.Occup",sPREFIX+"TRANSACTION_TYPE_ALERT",sWebLanguage,sCONTEXTPATH+"/main.do?Page=curative/index.jsp&ts="+getTs())%>
    <table class="list" width='100%' border='0' cellspacing="1">
        <tr>
            <td width ="<%=sTDAdminWidth%>" class='admin'><%=getTran("Web.Occup","medwan.common.name",sWebLanguage)%>&nbsp;</td>
            <td class='admin2'>
                <input class="text" type="text" size="50" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ALERTS_LABEL" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ALERTS_LABEL" property="value"/>" onblur="validateText(this);limitLength(this);">
            </td>
        </tr>
        <tr>
            <td class='admin'><%=getTran("Web.Occup","medwan.common.description",sWebLanguage)%>&nbsp;</td>
            <td class='admin2'>
                <textarea onKeyup="resizeTextarea(this,10);" class="text" cols="74" rows="2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ALERTS_DESCRIPTION" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ALERTS_DESCRIPTION" property="value"/></textarea>
            </td>
        </tr>
        <tr>
            <td class='admin'><%=getTran("Web.Occup","medwan.common.expiration-date",sWebLanguage)%>&nbsp;</td>
            <td class='admin2'>
                <input id="expiration" class="text" type="text" size="11" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ALERTS_EXPIRATION_DATE" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ALERTS_EXPIRATION_DATE" property="value" formatType="date"  format="dd/mm/yyyy"/>" onblur="checkDate(this);">
                <script>writeMyDate("expiration","<c:url value="/_img/icon_agenda.gif"/>","<%=getTran("Web","PutToday",sWebLanguage)%>");</script>
            </td>
        </tr>
        <tr>
            <td class="admin"/>
            <td class="admin2">
                <%
                    if (activeUser.getAccessRight("occup.managealerts.add") || activeUser.getAccessRight("occup.managealerts.edit")) {
                        %>
                            <INPUT class="button" type="button" name="save" id="save" onClick="doSubmit();" value="<%=getTran("Web.Occup","medwan.common.record",sWebLanguage)%>">
                        <%
                    }
                %>
                <INPUT class="button" type="button" value="<%=getTran("Web","back",sWebLanguage)%>" onclick="doBack();">
            </td>
        </tr>
    </table>
</form>

<script>
  function doBack(){
    if(checkSaveButton('<%=sCONTEXTPATH%>','<%=getTran("Web.Occup","medwan.common.buttonquestion",sWebLanguage)%>')){
      window.location.href = '<c:url value="/main.do?Page=curative/index.jsp"/>?ts=<%=getTs()%>';
    }
  }

  function doSubmit(){
    document.transactionForm.save.disabled = true;
    <%
        SessionContainerWO sessionContainerWO = (SessionContainerWO)SessionContainerFactory.getInstance().getSessionContainerWO(request,SessionContainerWO.class.getName());
        out.print(takeOverTransaction(sessionContainerWO, activeUser,"document.transactionForm.submit();"));
    %>
  }
</script>
<%=writeJSButtons("transactionForm","saveButton")%>