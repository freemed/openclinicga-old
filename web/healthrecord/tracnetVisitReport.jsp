<%@include file="/includes/validateUser.jsp"%>
<%@page errorPage="/includes/error.jsp"%>
<%=checkPermission("occup.tracnet.visit.report","select",activeUser)%>
<form id="transactionForm" name="transactionForm" method="POST" action='<c:url value="/healthrecord/updateTransaction.do"/>?ts=<%=getTs()%>' onclick="setSaveButton(event);" onkeyup="setSaveButton(event);">
    <bean:define id="transaction" name="be.mxs.webapp.wl.session.SessionContainerFactory.WO_SESSION_CONTAINER" property="currentTransactionVO"/>
	<%=checkPrestationToday(activePatient.personid,false,activeUser,(TransactionVO)transaction)%>
    <input type="hidden" id="transactionId" name="currentTransactionVO.<TransactionVO[hashCode=<bean:write name="transaction" scope="page" property="transactionId"/>]>.transactionId" value="<bean:write name="transaction" scope="page" property="transactionId"/>"/>
    <input type="hidden" id="serverId" name="currentTransactionVO.<TransactionVO[hashCode=<bean:write name="transaction" scope="page" property="transactionId"/>]>.serverId" value="<bean:write name="transaction" scope="page" property="serverId"/>"/>
    <input type="hidden" id="transactionType" name="currentTransactionVO.<TransactionVO[hashCode=<bean:write name="transaction" scope="page" property="transactionId"/>]>.transactionType" value="<bean:write name="transaction" scope="page" property="transactionType"/>"/>
    <input type="hidden" readonly name="be.mxs.healthrecord.updateTransaction.actionForwardKey" value="/main.do?Page=curative/index.jsp&ts=<%=getTs()%>"/>
    <input type="hidden" readonly name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CONTEXT_DEPARTMENT" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CONTEXT_DEPARTMENT" translate="false" property="value"/>"/>
    <input type="hidden" readonly name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CONTEXT_CONTEXT" translate="false" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CONTEXT_CONTEXT" translate="false" property="value"/>"/>

    <%=writeHistoryFunctions(((TransactionVO)transaction).getTransactionType(),sWebLanguage)%>
    <%=contextHeader(request,sWebLanguage)%>
    <table class="list" cellspacing="1" cellpadding="0" width="100%">
        <tr>
            <td class="admin" width="350">
                <a href="javascript:openHistoryPopup();" title="<%=getTran("Web.Occup","History",sWebLanguage)%>">...</a>&nbsp;
                <%=getTran("Web.Occup","medwan.common.date",sWebLanguage)%>
            </td>
            <td class="admin2">
                <input type="text" class="text" size="12" maxLength="10" name="currentTransactionVO.<TransactionVO[hashCode=<bean:write name="transaction" scope="page" property="transactionId"/>]>.updateTime" value="<mxs:propertyAccessorI18N name="transaction" scope="page" property="updateTime" formatType="date" format="dd-mm-yyyy"/>" id="trandate" OnBlur='checkDate(this)'>
                <script>writeTranDate();</script>
            </td>
        </tr>
        <tr>
            <td class="admin"><%=getTran("openclinic.chuk","tracnet.visit.report.first.home.visit",sWebLanguage)%></td>
            <td class="admin2">
                <input <%=setRightClick("ITEM_TYPE_TRACNET_VISIT_REPORT_FIRST_HOME_VISIT")%> id="cbhomeyes" type="radio" onDblClick="uncheckRadio(this);" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_TRACNET_VISIT_REPORT_FIRST_HOME_VISIT" property="itemId"/>]>.value" value="medwan.common.yes" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_TRACNET_VISIT_REPORT_FIRST_HOME_VISIT;value=medwan.common.yes" property="value" outputString="checked"/>><%=getLabel("web.occup","medwan.common.yes",sWebLanguage,"cbhomeyes")%>
                <input <%=setRightClick("ITEM_TYPE_TRACNET_VISIT_REPORT_FIRST_HOME_VISIT")%> id="cbhomeno" type="radio" onDblClick="uncheckRadio(this);" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_TRACNET_VISIT_REPORT_FIRST_HOME_VISIT" property="itemId"/>]>.value" value="medwan.common.no" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_TRACNET_VISIT_REPORT_FIRST_HOME_VISIT;value=medwan.common.no" property="value" outputString="checked"/>><%=getLabel("web.occup","medwan.common.no",sWebLanguage,"cbhomeno")%>
            </td>
        </tr>
        <tr>
            <td class="admin"><%=getTran("openclinic.chuk","tracnet.visit.report.hiv.statute",sWebLanguage)%></td>
            <td class="admin2">
                <input <%=setRightClick("ITEM_TYPE_TRACNET_VISIT_REPORT_STATUTE_HIV")%> id="cbhivyes" type="radio" onDblClick="uncheckRadio(this);" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_TRACNET_VISIT_REPORT_STATUTE_HIV" property="itemId"/>]>.value" value="medwan.common.yes" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_TRACNET_VISIT_REPORT_STATUTE_HIV;value=medwan.common.yes" property="value" outputString="checked"/>><%=getLabel("web.occup","medwan.common.yes",sWebLanguage,"cbhivyes")%>
                <input <%=setRightClick("ITEM_TYPE_TRACNET_VISIT_REPORT_STATUTE_HIV")%> id="cvhivno" type="radio" onDblClick="uncheckRadio(this);" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_TRACNET_VISIT_REPORT_STATUTE_HIV" property="itemId"/>]>.value" value="medwan.common.no" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_TRACNET_VISIT_REPORT_STATUTE_HIV;value=medwan.common.no" property="value" outputString="checked"/>><%=getLabel("web.occup","medwan.common.no",sWebLanguage,"cbhivno")%>
            </td>
        </tr>
        <tr>
            <td class="admin"><%=getTran("openclinic.chuk","tracnet.visit.report.home.visit.executed.by",sWebLanguage)%></td>
            <td class="admin2">
                <textarea onKeyup="resizeTextarea(this,10);limitChars(this,255);" <%=setRightClick("ITEM_TYPE_TRACNET_VISIT_REPORT_HOME_VISIT_EXECUTED_BY")%> class="text" cols="50" rows="2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_TRACNET_VISIT_REPORT_HOME_VISIT_EXECUTED_BY" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_TRACNET_VISIT_REPORT_HOME_VISIT_EXECUTED_BY" property="value"/></textarea>
            </td>
        </tr>
        <tr>
            <td class="admin"><%=getTran("openclinic.chuk","tracnet.visit.report.objective",sWebLanguage)%></td>
            <td class="admin2">
                <select class="text" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_TRACNET_VISIT_REPORT_OBJECTIVE" property="itemId"/>]>.value">
                    <option/>
                    <%
                        String sType = checkString(request.getParameter("type"));
                        if(sType.length() == 0){
                            SessionContainerWO sessionContainerWO = (SessionContainerWO) SessionContainerFactory.getInstance().getSessionContainerWO(request, SessionContainerWO.class.getName());
                            ItemVO item = sessionContainerWO.getCurrentTransactionVO().getItem(sPREFIX+"ITEM_TYPE_TRACNET_VISIT_REPORT_OBJECTIVE");
                            if (item!=null){
                                sType = checkString(item.getValue());
                            }
                        }
                    %>
                    <%=ScreenHelper.writeSelect("tracnet.visit.report.objective",sType,sWebLanguage,false,true)%>
                </select>
            </td>
        </tr>
        <tr>
            <td class="admin"><%=getTran("openclinic.chuk","tracnet.visit.report.precisions",sWebLanguage)%></td>
            <td class="admin2">
                <textarea onKeyup="resizeTextarea(this,10);limitChars(this,255);" <%=setRightClick("ITEM_TYPE_TRACNET_VISIT_REPORT_PRECISIONS")%> class="text" cols="50" rows="2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_TRACNET_VISIT_REPORT_PRECISIONS" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_TRACNET_VISIT_REPORT_PRECISIONS" property="value"/></textarea>
            </td>
        </tr>
    </table>
    <br>
    <table class="list" cellspacing="1" cellpadding="0" width="100%">
        <tr class="admin">
            <td width="<%=sTDAdminWidth%>"><%=getTran("openclinic.chuk","tracnet.visit.report.recommandations",sWebLanguage)%></td>
            <td><%=getTran("openclinic.chuk","tracnet.visit.report.details",sWebLanguage)%></td>
            <td width="<%=sTDAdminWidth%>"><%=getTran("openclinic.chuk","tracnet.visit.report.recommandations",sWebLanguage)%></td>
            <td><%=getTran("openclinic.chuk","tracnet.visit.report.details",sWebLanguage)%></td>
        </tr>
        <tr>
            <td class="admin">
                <input <%=setRightClick("ITEM_TYPE_TRACNET_VISIT_REPORT_RETURN")%> type="checkbox" id="cbreturn" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_TRACNET_VISIT_REPORT_RETURN" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_TRACNET_VISIT_REPORT_RETURN;value=medwan.common.true" property="value" outputString="checked"/> value="medwan.common.true"/><%=getLabel("openclinic.chuk","tracnet.visit.report.return",sWebLanguage,"cbreturn")%><br>
            </td>
            <td class="admin2">
                <textarea onKeyup="resizeTextarea(this,10);limitChars(this,255);" <%=setRightClick("ITEM_TYPE_TRACNET_VISIT_REPORT_RETURN_COMMENT")%> class="text" cols="50" rows="2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_TRACNET_VISIT_REPORT_RETURN_COMMENT" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_TRACNET_VISIT_REPORT_RETURN_COMMENT" property="value"/></textarea>
            </td>
            <td class="admin">
                <input <%=setRightClick("ITEM_TYPE_TRACNET_VISIT_REPORT_SERVICES")%> type="checkbox" id="cbservices" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_TRACNET_VISIT_REPORT_SERVICES" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_TRACNET_VISIT_REPORT_SERVICES;value=medwan.common.true" property="value" outputString="checked"/> value="medwan.common.true"/><%=getLabel("openclinic.chuk","tracnet.visit.report.services",sWebLanguage,"cbservices")%><br>
            </td>
            <td class="admin2">
                <textarea onKeyup="resizeTextarea(this,10);limitChars(this,255);" <%=setRightClick("ITEM_TYPE_TRACNET_VISIT_REPORT_SERVICES_COMMENT")%> class="text" cols="50" rows="2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_TRACNET_VISIT_REPORT_SERVICES_COMMENT" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_TRACNET_VISIT_REPORT_SERVICES_COMMENT" property="value"/></textarea>
            </td>
        </tr>
        <tr>
            <td class="admin">
                <input <%=setRightClick("ITEM_TYPE_TRACNET_VISIT_REPORT_EXTRA_VISIT")%> type="checkbox" id="cbextravisit" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_TRACNET_VISIT_REPORT_EXTRA_VISIT" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_TRACNET_VISIT_REPORT_EXTRA_VISIT;value=medwan.common.true" property="value" outputString="checked"/> value="medwan.common.true"/><%=getLabel("openclinic.chuk","tracnet.visit.report.extra.visit",sWebLanguage,"cbextravisit")%><br>
            </td>
            <td class="admin2">
                <textarea onKeyup="resizeTextarea(this,10);limitChars(this,255);" <%=setRightClick("ITEM_TYPE_TRACNET_VISIT_REPORT_EXTRA_VISIT_COMMENT")%> class="text" cols="50" rows="2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_TRACNET_VISIT_REPORT_EXTRA_VISIT_COMMENT" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_TRACNET_VISIT_REPORT_EXTRA_VISIT_COMMENT" property="value"/></textarea>
            </td>
            <td class="admin">
                <input <%=setRightClick("ITEM_TYPE_TRACNET_VISIT_REPORT_RDV_COUNSEL")%> type="checkbox" id="cbrdvcounsel" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_TRACNET_VISIT_REPORT_RDV_COUNSEL" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_TRACNET_VISIT_REPORT_RDV_COUNSEL;value=medwan.common.true" property="value" outputString="checked"/> value="medwan.common.true"/><%=getLabel("openclinic.chuk","tracnet.visit.report.rdv.counsel",sWebLanguage,"cbrdvcounsel")%><br>
            </td>
            <td class="admin2">
                <textarea onKeyup="resizeTextarea(this,10);limitChars(this,255);" <%=setRightClick("ITEM_TYPE_TRACNET_VISIT_REPORT_RDV_COUNSEL")%> class="text" cols="50" rows="2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_TRACNET_VISIT_REPORT_RDV_COUNSEL_COMMENT" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_TRACNET_VISIT_REPORT_RDV_COUNSEL_COMMENT" property="value"/></textarea>
            </td>
        </tr>
        <tr>
            <td class="admin">
                <input <%=setRightClick("ITEM_TYPE_TRACNET_VISIT_REPORT_MEETING")%> type="checkbox" id="cbmeeting" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_TRACNET_VISIT_REPORT_MEETING" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_TRACNET_VISIT_REPORT_MEETING;value=medwan.common.true" property="value" outputString="checked"/> value="medwan.common.true"/><%=getLabel("openclinic.chuk","tracnet.visit.report.meeting",sWebLanguage,"cbmeeting")%><br>
            </td>
            <td class="admin2">
                <textarea onKeyup="resizeTextarea(this,10);limitChars(this,255);" <%=setRightClick("ITEM_TYPE_TRACNET_VISIT_REPORT_MEETING_COMMENT")%> class="text" cols="50" rows="2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_TRACNET_VISIT_REPORT_MEETING_COMMENT" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_TRACNET_VISIT_REPORT_MEETING_COMMENT" property="value"/></textarea>
            </td>
            <td class="admin">
                <input <%=setRightClick("ITEM_TYPE_TRACNET_VISIT_REPORT_OTHER_SUIVI")%> type="checkbox" id="cbothersuivi" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_TRACNET_VISIT_REPORT_OTHER_SUIVI" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_TRACNET_VISIT_REPORT_OTHER_SUIVI;value=medwan.common.true" property="value" outputString="checked"/> value="medwan.common.true"/><%=getLabel("openclinic.chuk","tracnet.visit.report.other.suivi",sWebLanguage,"cbothersuivi")%><br>
            </td>
            <td class="admin2">
                <textarea onKeyup="resizeTextarea(this,10);limitChars(this,255);" <%=setRightClick("ITEM_TYPE_TRACNET_VISIT_REPORT_OTHER_SUIVI_COMMENT")%> class="text" cols="50" rows="2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_TRACNET_VISIT_REPORT_OTHER_SUIVI_COMMENT" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_TRACNET_VISIT_REPORT_OTHER_SUIVI_COMMENT" property="value"/></textarea>
            </td>
        </tr>
    </table>
    <br>
    <table class="list" cellspacing="1" cellpadding="0" width="100%">
        <tr>
            <td class="admin" width="350"><%=getTran("openclinic.chuk","tracnet.visit.report.comment",sWebLanguage)%></td>
            <td class="admin2">
                <textarea onKeyup="resizeTextarea(this,10);limitChars(this,255);" <%=setRightClick("ITEM_TYPE_TRACNET_VISIT_REPORT_COMMENT")%> class="text" cols="50" rows="2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_TRACNET_VISIT_REPORT_COMMENT" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_TRACNET_VISIT_REPORT_COMMENT" property="value"/></textarea>
            </td>
        </tr>
<%-- BUTTONS --%>
        <tr>
            <td class="admin"/>
            <td class="admin2">
                <%=getButtonsHtml(request,activeUser,activePatient,"occup.tracnet.visit.report",sWebLanguage)%>
            </td>
        </tr>
    </table>

    <%=ScreenHelper.contextFooter(request)%>
</form>
<script>
  function submitForm(){
    document.getElementById("buttonsDiv").style.visibility = "hidden";
    var temp = Form.findFirstElement(transactionForm);//for ff compatibility
    document.transactionForm.submit();
  }
</script>
<%=writeJSButtons("transactionForm","saveButton")%>
