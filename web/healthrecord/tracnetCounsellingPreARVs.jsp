<%@include file="/includes/validateUser.jsp"%>
<%@page errorPage="/includes/error.jsp"%>

<%=checkPermission("occup.tracnet.counselling","select",activeUser)%>

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
            <td class="admin" width="<%=sTDAdminWidth%>">
                <a href="javascript:openHistoryPopup();" title="<%=getTran("Web.Occup","History",sWebLanguage)%>">...</a>&nbsp;
                <%=getTran("Web.Occup","medwan.common.date",sWebLanguage)%>
            </td>
            <td class="admin2">
                <input type="text" class="text" size="12" maxLength="10" name="currentTransactionVO.<TransactionVO[hashCode=<bean:write name="transaction" scope="page" property="transactionId"/>]>.updateTime" value="<mxs:propertyAccessorI18N name="transaction" scope="page" property="updateTime" formatType="date" format="dd-mm-yyyy"/>" id="trandate" OnBlur='checkDate(this)'>
                <script>writeTranDate();</script>
            </td>
        </tr>
        <tr>
            <td class="admin"><%=getTran("openclinic.chuk","tracnet.counselling.pre.arvs.sujets.abordes",sWebLanguage)%></td>
            <td class="admin2">
                <textarea onKeyup="resizeTextarea(this,10);limitChars(this,255);" <%=setRightClick("ITEM_TYPE_TRACNET_COUNSELLING_PRE_ARVS_SUJETS_ABORDES")%> class="text" cols="100" rows="2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_TRACNET_COUNSELLING_PRE_ARVS_SUJETS_ABORDES" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_TRACNET_COUNSELLING_PRE_ARVS_SUJETS_ABORDES" property="value"/></textarea>
            </td>
        </tr>
        <tr>
            <td class="admin"><%=getTran("openclinic.chuk","tracnet.counselling.pre.arvs.points.a.na.pas.oublier",sWebLanguage)%></td>
            <td class="admin2">
                <input <%=setRightClick("ITEM_TYPE_TRACNET_COUNSELLING_PRE_ARVS_COMPREHENSION")%> type="checkbox" id="cbcomprehension" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_TRACNET_COUNSELLING_PRE_ARVS_COMPREHENSION" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_TRACNET_COUNSELLING_PRE_ARVS_COMPREHENSION;value=medwan.common.true" property="value" outputString="checked"/> value="medwan.common.true"/><%=getLabel("openclinic.chuk","tracnet.counselling.pre.arvs.points.comprehension",sWebLanguage,"cbcomprehension")%><br>
                <input <%=setRightClick("ITEM_TYPE_TRACNET_COUNSELLING_PRE_ARVS_ADHERENCE")%> type="checkbox" id="cbadherence" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_TRACNET_COUNSELLING_PRE_ARVS_ADHERENCE" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_TRACNET_COUNSELLING_PRE_ARVS_ADHERENCE;value=medwan.common.true" property="value" outputString="checked"/> value="medwan.common.true"/><%=getLabel("openclinic.chuk","tracnet.counselling.pre.arvs.points.adherence",sWebLanguage,"cbadherence")%><br>
                <input <%=setRightClick("ITEM_TYPE_TRACNET_COUNSELLING_PRE_ARVS_RESPECT")%> type="checkbox" id="cbrespect" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_TRACNET_COUNSELLING_PRE_ARVS_RESPECT" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_TRACNET_COUNSELLING_PRE_ARVS_RESPECT;value=medwan.common.true" property="value" outputString="checked"/> value="medwan.common.true"/><%=getLabel("openclinic.chuk","tracnet.counselling.pre.arvs.points.respect",sWebLanguage,"cbrespect")%><br>
                <input <%=setRightClick("ITEM_TYPE_TRACNET_COUNSELLING_PRE_ARVS_EFFETS_SECONDAIRES")%> type="checkbox" id="cbeffetssecondaires" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_TRACNET_COUNSELLING_PRE_ARVS_EFFETS_SECONDAIRES" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_TRACNET_COUNSELLING_PRE_ARVS_EFFETS_SECONDAIRES;value=medwan.common.true" property="value" outputString="checked"/> value="medwan.common.true"/><%=getLabel("openclinic.chuk","tracnet.counselling.pre.arvs.points.effetssecondaires",sWebLanguage,"cbeffetssecondaires")%><br>
                <input <%=setRightClick("ITEM_TYPE_TRACNET_COUNSELLING_PRE_ARVS_PRISE_MEDICAMENTS")%> type="checkbox" id="cbprisemedicaments" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_TRACNET_COUNSELLING_PRE_ARVS_PRISE_MEDICAMENTS" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_TRACNET_COUNSELLING_PRE_ARVS_PRISE_MEDICAMENTS;value=medwan.common.true" property="value" outputString="checked"/> value="medwan.common.true"/><%=getLabel("openclinic.chuk","tracnet.counselling.pre.arvs.points.prisemedicaments",sWebLanguage,"cbprisemedicaments")%><br>
            </td>
        </tr>
        <tr>
            <td class="admin"><%=getTran("openclinic.chuk","tracnet.counselling.pre.arvs.conclusions",sWebLanguage)%></td>
            <td class="admin2">
                <textarea onKeyup="resizeTextarea(this,10);limitChars(this,255);" <%=setRightClick("ITEM_TYPE_TRACNET_COUNSELLING_PRE_ARVS_CONCLUSIONS")%> class="text" cols="100" rows="2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_TRACNET_COUNSELLING_PRE_ARVS_CONCLUSIONS" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_TRACNET_COUNSELLING_PRE_ARVS_CONCLUSIONS" property="value"/></textarea>
            </td>
        </tr>
<%-- BUTTONS --%>
        <tr>
            <td class="admin"/>
            <td class="admin2">
                <%=getButtonsHtml(request,activeUser,activePatient,"occup.tracnet.counselling",sWebLanguage)%>
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
