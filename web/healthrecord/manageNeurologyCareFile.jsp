<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>
<%=checkPermission("occup.neurologycarefile","select",activeUser)%>
<form name="transactionForm" id="transactionForm" method="POST" action='<c:url value="/healthrecord/updateTransaction.do"/>?ts=<%=getTs()%>' onclick="setSaveButton(event);" onkeyup="setSaveButton(event);">
    <bean:define id="transaction" name="be.mxs.webapp.wl.session.SessionContainerFactory.WO_SESSION_CONTAINER" property="currentTransactionVO"/>
	<%=checkPrestationToday(activePatient.personid, false, activeUser, (TransactionVO)transaction) %>
    <input type="hidden" id="transactionId" name="currentTransactionVO.<TransactionVO[hashCode=<bean:write name="transaction" scope="page" property="transactionId"/>]>.transactionId" value="<bean:write name="transaction" scope="page" property="transactionId"/>"/>
    <input type="hidden" id="serverId" name="currentTransactionVO.<TransactionVO[hashCode=<bean:write name="transaction" scope="page" property="transactionId"/>]>.serverId" value="<bean:write name="transaction" scope="page" property="serverId"/>"/>
    <input type="hidden" id="transactionType" name="currentTransactionVO.<TransactionVO[hashCode=<bean:write name="transaction" scope="page" property="transactionId"/>]>.transactionType" value="<bean:write name="transaction" scope="page" property="transactionType"/>"/>
    <input type="hidden" readonly name="be.mxs.healthrecord.updateTransaction.actionForwardKey" value="/main.do?Page=curative/index.jsp&ts=<%=getTs()%>"/>
    <input type="hidden" readonly name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_RECRUITMENT_CONVOCATION_ID" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_RECRUITMENT_CONVOCATION_ID" property="value"/>"/>
    <input type="hidden" readonly name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CONTEXT_DEPARTMENT" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CONTEXT_DEPARTMENT" translate="false" property="value"/>"/>
    <input type="hidden" readonly name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CONTEXT_CONTEXT" translate="false" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CONTEXT_CONTEXT" translate="false" property="value"/>"/>

<%=contextHeader(request,sWebLanguage)%>
<table class="list" width="100%" cellspacing="1">
    <%-- DATE --%>
    <tr>
        <td class="admin">
            <a href="javascript:openHistoryPopup();" title="<%=getTran("Web.Occup","History",sWebLanguage)%>">...</a>&nbsp;
            <%=getTran("Web.Occup","medwan.common.date",sWebLanguage)%>
        </td>
        <td class="admin2">
            <input type="text" class="text" size="12" maxLength="10" value="<mxs:propertyAccessorI18N name="transaction" scope="page" property="updateTime" formatType="date" format="dd-mm-yyyy"/>" name="currentTransactionVO.<TransactionVO[hashCode=<bean:write name="transaction" scope="page" property="transactionId"/>]>.updateTime" id="trandate" OnBlur='checkDate(this)'> <script>writeMyDate("trandate","<c:url value="/_img/icon_agenda.gif"/>","<%=getTran("Web","PutToday",sWebLanguage)%>");</script>
        </td>
    </tr>
    <%--  FAMILIAL SITUATION AND LIVING CONDITIONS --%>
    <tr>
        <td class="admin" width="<%=sTDAdminWidth%>" nowrap><%=getTran("Web.occup","neurology_carefile_familialsituation_and_livingconditions",sWebLanguage)%>&nbsp;</td>
        <td class="admin2" width="100%">
            <textarea id="focusField" onKeyup="resizeTextarea(this,10);limitChars(this,255);" <%=setRightClick("ITEM_TYPE_NEUROLOGY_CAREFILE_FAMILIALSITUATION_AND_LIVINGCONDITIONS")%> class="text" cols="80" rows="2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_NEUROLOGY_CAREFILE_FAMILIALSITUATION_AND_LIVINGCONDITIONS" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_NEUROLOGY_CAREFILE_FAMILIALSITUATION_AND_LIVINGCONDITIONS" property="value"/></textarea>
        </td>
    </tr>
    <%--  ACTUAL PROBLEM AND ILLNESS HISTORY --%>
    <tr>
        <td class="admin"><%=getTran("Web.occup","neurology_carefile_actualproblem_and_illnesshistory",sWebLanguage)%>&nbsp;</td>
        <td class="admin2">
            <textarea onKeyup="resizeTextarea(this,10);limitChars(this,255);" <%=setRightClick("ITEM_TYPE_NEUROLOGY_CAREFILE_ACTUALPROBLEM_AND_ILLNESSHISTORY")%> class="text" cols="80" rows="2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_NEUROLOGY_CAREFILE_ACTUALPROBLEM_AND_ILLNESSHISTORY" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_NEUROLOGY_CAREFILE_ACTUALPROBLEM_AND_ILLNESSHISTORY" property="value"/></textarea>
        </td>
    </tr>
    <%-- PROBLEM CONTEXT --%>
    <tr>
        <td class="admin"><%=getTran("Web.occup","neurology_carefile_problemcontext",sWebLanguage)%>&nbsp;</td>
        <td class="admin2">
            <textarea onKeyup="resizeTextarea(this,10);limitChars(this,255);" <%=setRightClick("ITEM_TYPE_NEUROLOGY_CAREFILE_PROBLEMCONTEXT")%> class="text" cols="80" rows="2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_NEUROLOGY_CAREFILE_PROBLEMCONTEXT" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_NEUROLOGY_CAREFILE_PROBLEMCONTEXT" property="value"/></textarea>
        </td>
    </tr>
    <%--  FAMILIAL HISTORY SHORT --%>
    <tr>
        <td class="admin"><%=getTran("Web.occup","neurology_carefile_familialhistoryshort",sWebLanguage)%>&nbsp;</td>
        <td class="admin2">
            <textarea onKeyup="resizeTextarea(this,10);limitChars(this,255);" <%=setRightClick("ITEM_TYPE_NEUROLOGY_CAREFILE_FAMILIALHISTORY_SHORT")%> class="text" cols="80" rows="2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_NEUROLOGY_CAREFILE_FAMILIALHISTORY_SHORT" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_NEUROLOGY_CAREFILE_FAMILIALHISTORY_SHORT" property="value"/></textarea>
        </td>
    </tr>
    <%--  PERSONAL HISTORY SHORT --%>
    <tr>
        <td class="admin"><%=getTran("Web.occup","neurology_carefile_personalhistoryshort",sWebLanguage)%>&nbsp;</td>
        <td class="admin2">
            <textarea onKeyup="resizeTextarea(this,10);limitChars(this,255);" <%=setRightClick("ITEM_TYPE_NEUROLOGY_CAREFILE_PERSONALHISTORY_SHORT")%> class="text" cols="80" rows="2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_NEUROLOGY_CAREFILE_PERSONALHISTORY_SHORT" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_NEUROLOGY_CAREFILE_PERSONALHISTORY_SHORT" property="value"/></textarea>
        </td>
    </tr>
    <%--  SOMATIC STATUS --%>
    <tr>
        <td class="admin"><%=getTran("Web.occup","neurology_carefile_somaticstatus",sWebLanguage)%>&nbsp;</td>
        <td class="admin2">
            <textarea onKeyup="resizeTextarea(this,10);limitChars(this,255);" <%=setRightClick("ITEM_TYPE_NEUROLOGY_CAREFILE_SOMATICSTATUS")%> class="text" cols="80" rows="2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_NEUROLOGY_CAREFILE_SOMATICSTATUS" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_NEUROLOGY_CAREFILE_SOMATICSTATUS" property="value"/></textarea>
        </td>
    </tr>
    <%--  NEUROLOGICAL STATUS AND OBJECTIVES --%>
    <tr>
        <td class="admin"><%=getTran("Web.occup","neurology_carefile_neurologicalstatus_and_objectives",sWebLanguage)%>&nbsp;</td>
        <td class="admin2">
            <textarea onKeyup="resizeTextarea(this,10);limitChars(this,255);" <%=setRightClick("ITEM_TYPE_NEUROLOGY_CAREFILE_NEUROLOGICALSTATUS_AND_OBJECTIVES")%> class="text" cols="80" rows="2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_NEUROLOGY_CAREFILE_NEUROLOGICALSTATUS_AND_OBJECTIVES" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_NEUROLOGY_CAREFILE_NEUROLOGICALSTATUS_AND_OBJECTIVES" property="value"/></textarea>
        </td>
    </tr>
    <%--  PROBLEM HYPOTHESIS --%>
    <tr>
        <td class="admin"><%=getTran("Web.occup","neurology_carefile_problemhypothesis",sWebLanguage)%>&nbsp;</td>
        <td class="admin2">
            <textarea onKeyup="resizeTextarea(this,10);limitChars(this,255);" <%=setRightClick("ITEM_TYPE_NEUROLOGY_CAREFILE_PROBLEMHYPOTHESIS")%> class="text" cols="80" rows="2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_NEUROLOGY_CAREFILE_PROBLEMHYPOTHESIS" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_NEUROLOGY_CAREFILE_PROBLEMHYPOTHESIS" property="value"/></textarea>
        </td>
    </tr>
    <%--  DIAGNOSTIC IMPRESSION --%>
    <tr>
        <td class="admin"><%=getTran("Web.occup","neurology_carefile_diagnosticimpression",sWebLanguage)%>&nbsp;</td>
        <td class="admin2">
            <textarea onKeyup="resizeTextarea(this,10);limitChars(this,255);" <%=setRightClick("ITEM_TYPE_NEUROLOGY_CAREFILE_DIAGNOSTICIMPRESSION")%> class="text" cols="80" rows="2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_NEUROLOGY_CAREFILE_DIAGNOSTICIMPRESSION" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_NEUROLOGY_CAREFILE_DIAGNOSTICIMPRESSION" property="value"/></textarea>
        </td>
    </tr>
    <%--  THERAPEUTICAL PROJECT --%>
    <tr>
        <td class="admin"><%=getTran("Web.occup","neurology_carefile_therapeuticalproject",sWebLanguage)%>&nbsp;</td>
        <td class="admin2">
            <textarea onKeyup="resizeTextarea(this,10);limitChars(this,255);" <%=setRightClick("ITEM_TYPE_NEUROLOGY_CAREFILE_THERAPEUTICALPROJECT")%> class="text" cols="80" rows="2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_NEUROLOGY_CAREFILE_THERAPEUTICALPROJECT" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_NEUROLOGY_CAREFILE_THERAPEUTICALPROJECT" property="value"/></textarea>
        </td>
    </tr>
    <tr>
        <td class="admin"/>
        <td class="admin2">
<%-- BUTTONS --%>
    <%
        if(activeUser.getAccessRight("occup.neurologycarefile.add") || activeUser.getAccessRight("occup.neurologycarefile.edit")){
            %><INPUT class="button" type="button" name="saveButton" id="saveButton" value="<%=getTran("Web","save",sWebLanguage)%>" onclick="submitForm();"/><%
        }
    %>
            <INPUT class="button" type="button" name="backButton" value="<%=getTran("Web","Back",sWebLanguage)%>" onclick="doBack();">
        </td>
    </tr>
</table>
<script>
  document.getElementById("focusField").focus();

  <%-- SUBMIT FORM --%>
  function submitForm(){
    document.transactionForm.saveButton.disabled = true;
    <%
        SessionContainerWO sessionContainerWO = (SessionContainerWO)SessionContainerFactory.getInstance().getSessionContainerWO(request,SessionContainerWO.class.getName());
        out.print(takeOverTransaction(sessionContainerWO, activeUser,"document.transactionForm.submit();"));
    %>
  }

  <%-- DO BACK --%>
  function doBack(){
    if(checkSaveButton("<%=sCONTEXTPATH%>','<%=getTran("Web.Occup","medwan.common.buttonquestion",sWebLanguage)%>")){
      window.location.href='<c:url value="/main.do?Page=curative/index.jsp&ts="/><%=getTs()%>';
    }
  }
</script>
<%=ScreenHelper.contextFooter(request)%>
</form>
<%=writeJSButtons("transactionForm","saveButton")%>