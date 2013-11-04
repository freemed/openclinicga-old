<%@include file="/includes/validateUser.jsp"%>
<%@page errorPage="/includes/error.jsp"%>

<%=checkPermission("occup.anatomopathology","select",activeUser)%>

<form name="transactionForm" id="transactionForm" method="POST" action='<c:url value="/healthrecord/updateTransaction.do"/>?ts=<%=getTs()%>' onclick="setSaveButton(event);" onkeyup="setSaveButton(event);">
    <bean:define id="transaction" name="be.mxs.webapp.wl.session.SessionContainerFactory.WO_SESSION_CONTAINER" property="currentTransactionVO"/>
	<%=checkPrestationToday(activePatient.personid, false, activeUser, (TransactionVO)transaction) %>
    <input type="hidden" id="transactionId" name="currentTransactionVO.<TransactionVO[hashCode=<bean:write name="transaction" scope="page" property="transactionId"/>]>.transactionId" value="<bean:write name="transaction" scope="page" property="transactionId"/>"/>
    <input type="hidden" id="serverId" name="currentTransactionVO.<TransactionVO[hashCode=<bean:write name="transaction" scope="page" property="transactionId"/>]>.serverId" value="<bean:write name="transaction" scope="page" property="serverId"/>"/>
    <input type="hidden" id="transactionType" name="currentTransactionVO.<TransactionVO[hashCode=<bean:write name="transaction" scope="page" property="transactionId"/>]>.transactionType" value="<bean:write name="transaction" scope="page" property="transactionType"/>"/>
    <input type="hidden" readonly name="be.mxs.healthrecord.updateTransaction.actionForwardKey" value="/main.do?Page=curative/index.jsp&ts=<%=getTs()%>"/>
    <input type="hidden" readonly name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CONTEXT_DEPARTMENT" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CONTEXT_DEPARTMENT" translate="false" property="value"/>"/>
    <input type="hidden" readonly name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CONTEXT_CONTEXT" translate="false" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CONTEXT_CONTEXT" translate="false" property="value"/>"/>

    <%=writeHistoryFunctions(((TransactionVO)transaction).getTransactionType(),sWebLanguage)%>
    <%=contextHeader(request,sWebLanguage)%>

    <%
        SessionContainerWO sessionContainerWO = (SessionContainerWO) SessionContainerFactory.getInstance().getSessionContainerWO(request, SessionContainerWO.class.getName());
        String sIdentificationNr = "";
        if (sessionContainerWO.getCurrentTransactionVO().getTransactionId().intValue() > 0) {
            ItemVO item = sessionContainerWO.getCurrentTransactionVO().getItem(sPREFIX+"ITEM_TYPE_ANATOMOPATHOLOGY_IDENTIFICATION_NUMBER");
            if (item != null) {
                sIdentificationNr = item.getValue();
            }
        }
        else {
            String sServerID = sessionContainerWO.getCurrentTransactionVO().getServerId() + "";
            sIdentificationNr = "5" + ScreenHelper.padLeft(sServerID,"0",3) + MedwanQuery.getInstance().getNewOccupCounterValue("IdentificationAnatomopathologyID");
        }
    %>

    <table class="list" cellspacing="1" cellpadding="0" width="100%">
        <%-- DATE --%>
        <tr>
            <td class="admin" width="<%=sTDAdminWidth%>">
                <a href="javascript:openHistoryPopup();" title="<%=getTran("Web.Occup","History",sWebLanguage)%>">...</a>&nbsp;
                <%=getTran("Web.Occup","medwan.common.date",sWebLanguage)%>
            </td>
            <td class="admin2">
                <input type="text" class="text" size="12" maxLength="10" name="currentTransactionVO.<TransactionVO[hashCode=<bean:write name="transaction" scope="page" property="transactionId"/>]>.updateTime" value="<mxs:propertyAccessorI18N name="transaction" scope="page" property="updateTime" formatType="date" format="dd-mm-yyyy"/>" id="trandate" OnBlur='checkDate(this)'>
                <script>writeMyDate("trandate","<c:url value="/_img/icon_agenda.gif"/>","<%=getTran("Web","PutToday",sWebLanguage)%>");</script>
            </td>
        </tr>

        <%-- identificationumber --%>
        <tr>
            <td class='admin'><%=getTran("openclinic.chuk","identificationumber",sWebLanguage)%></td>
            <td class='admin2'>
                <input type="text" id='rxid' class="text" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ANATOMOPATHOLOGY_IDENTIFICATION_NUMBER" property="itemId"/>]>.value" value="<%=sIdentificationNr%>" READONLY>
            </td>
        </tr>

        <%-- nature --%>
        <tr>
            <td class="admin"><%=getTran("openclinic.chuk","nature",sWebLanguage)%>&nbsp;</td>
            <td class="admin2">
                <textarea onKeyup="resizeTextarea(this,10);limitChars(this,255);" <%=setRightClick("ITEM_TYPE_ANATOMOPATHOLOGY_NATURE")%> class="text" cols="100" rows="2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ANATOMOPATHOLOGY_NATURE" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ANATOMOPATHOLOGY_NATURE" property="value"/></textarea>
            </td>
        </tr>

        <%-- sample_date --%>
        <tr>
            <td class="admin"><%=getTran("openclinic.chuk","sample_date",sWebLanguage)%>&nbsp;</td>
            <td class="admin2">
                <input type="text" class="text" size="12" maxLength="10" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ANATOMOPATHOLOGY_SAMPLE_DATE" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ANATOMOPATHOLOGY_SAMPLE_DATE" property="value"/>" id="sampledate" OnBlur='checkDate(this)'>
                <script>writeMyDate("sampledate","<c:url value="/_img/icon_agenda.gif"/>","<%=getTran("Web","PutToday",sWebLanguage)%>");</script>
            </td>
        </tr>

        <%-- disease_history --%>
        <tr>
            <td class="admin"><%=getTran("openclinic.chuk","disease_history",sWebLanguage)%>&nbsp;</td>
            <td class="admin2">
                <textarea onKeyup="resizeTextarea(this,10);limitChars(this,255);" <%=setRightClick("ITEM_TYPE_ANATOMOPATHOLOGY_HISTORY")%> class="text" cols="100" rows="2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ANATOMOPATHOLOGY_HISTORY" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ANATOMOPATHOLOGY_HISTORY" property="value"/></textarea>
            </td>
        </tr>

        <%-- result --%>
        <tr>
            <td class="admin"><%=getTran("openclinic.chuk","result",sWebLanguage)%>&nbsp;</td>
            <td class="admin2">
                <textarea onKeyup="resizeTextarea(this,10);limitChars(this,255);" <%=setRightClick("ITEM_TYPE_ANATOMOPATHOLOGY_RESULT")%> class="text" cols="100" rows="2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ANATOMOPATHOLOGY_RESULT" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ANATOMOPATHOLOGY_RESULT" property="value"/></textarea>
            </td>
        </tr>

        <%-- declared_valid --%>
        <tr>
            <td class="admin"><%=getTran("openclinic.chuk","declared_valid",sWebLanguage)%>&nbsp;</td>
            <td class="admin2">
                <textarea onKeyup="resizeTextarea(this,10);limitChars(this,255);" <%=setRightClick("ITEM_TYPE_ANATOMOPATHOLOGY_DECLARED_VALID")%> class="text" cols="100" rows="2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ANATOMOPATHOLOGY_DECLARED_VALID" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ANATOMOPATHOLOGY_DECLARED_VALID" property="value"/></textarea>
            </td>
        </tr>

        <%-- BUTTONS --%>
        <tr>
            <td class="admin"/>
            <td class="admin2">
                <input class="button" type="button" name="printLabelsButton" value="<%=getTran("Web","printlabels",sWebLanguage)%>" onclick="printLabels()"/>&nbsp;
                <%=getButtonsHtml(request,activeUser,activePatient,"occup.anatomopathology",sWebLanguage)%>
            </td>
        </tr>
    </table>

    <%=ScreenHelper.contextFooter(request)%>
</form>

<script>
  <%-- PRINT LABELS --%>
  function printLabels(){
    var url = "<c:url value="/healthrecord/createAnatomopathologyLabelPdf.jsp"/>?imageid="+document.getElementsByName("rxid")[0].value+"&trandate="+document.getElementsByName("trandate")[0].value+"&ts=<%=getTs()%>";
    window.open(url,"Popup"+new Date().getTime(),"toolbar=no, status=yes, scrollbars=yes, resizable=yes, width=400, height=300, menubar=no").moveTo((screen.width-400)/2,(screen.height-300)/2);
  }

  <%-- SUBMIT FORM --%>
  function submitForm(){
     var temp = Form.findFirstElement(transactionForm);// FOR COMPATIBILITY WITH FIREFOX
        document.transactionForm.saveButton.style.visibility = "hidden";
    <%
        out.print(takeOverTransaction(sessionContainerWO, activeUser,"document.transactionForm.submit();"));
    %>
  }
</script>

<%=writeJSButtons("transactionForm", "saveButton")%>