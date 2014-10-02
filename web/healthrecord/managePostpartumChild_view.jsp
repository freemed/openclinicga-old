<%@include file="/includes/validateUser.jsp"%>
<%@page errorPage="/includes/error.jsp"%>
<%=checkPermission("occup.postpartumchild","select",activeUser)%>
<form name="transactionForm" id="transactionForm" method="POST" action='<c:url value="/healthrecord/updateTransaction.do"/>?ts=<%=getTs()%>' onclick="setSaveButton(event);" onkeyup="setSaveButton(event);">
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
    <table class="list" width="100%" cellspacing="1">
        <%-- DATE --%>
        <tr>
            <td class="admin" width="<%=sTDAdminWidth%>">
                <a href="javascript:openHistoryPopup();" title="<%=getTranNoLink("Web.Occup","History",sWebLanguage)%>">...</a>&nbsp;
                <%=getTran("Web.Occup","medwan.common.date",sWebLanguage)%>
            </td>
            <td class="admin2" colspan="3">
                <input type="text" class="text" size="12" maxLength="10" name="currentTransactionVO.<TransactionVO[hashCode=<bean:write name="transaction" scope="page" property="transactionId"/>]>.updateTime" value="<mxs:propertyAccessorI18N name="transaction" scope="page" property="updateTime" formatType="date"/>" id="trandate" OnBlur='checkDate(this)'>
                <script>writeTranDate();</script>
            </td>
        </tr>

        <%-- DESCRIPTION --%>
        <tr>
            <td class="admin" width="<%=sTDAdminWidth%>"><%=getTran("openclinic.chuk","weight",sWebLanguage)%></td>
            <td class="admin2">
                <input <%=setRightClick("ITEM_TYPE_PPC_CHILD_WEIGHT")%> type="text" class="text" size="5" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_PPC_CHILD_WEIGHT" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_PPC_CHILD_WEIGHT" property="value"/>" onblur="isNumber(this)"> g
            </td>
            <td class="admin" width="<%=sTDAdminWidth%>"><%=getTran("openclinic.chuk","paleness.conjunctiva",sWebLanguage)%></td>
            <td class="admin2">
                <textarea onKeyup="resizeTextarea(this,10);limitChars(this,255);" <%=setRightClick("ITEM_TYPE_PPC_CONJUNCTIVA")%> class="text" cols="50" rows="2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_PPC_CONJUNCTIVA" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_PPC_CONJUNCTIVA" property="value"/></textarea>
            </td>
        </tr>
        <tr>
            <td class="admin"><%=getTran("openclinic.chuk","umbilicus",sWebLanguage)%></td>
            <td class="admin2">
                <textarea onKeyup="resizeTextarea(this,10);limitChars(this,255);" <%=setRightClick("ITEM_TYPE_PPC_UMBILICUS")%> class="text" cols="50" rows="2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_PPC_UMBILICUS" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_PPC_UMBILICUS" property="value"/></textarea>
            </td>
            <td class="admin" width="<%=sTDAdminWidth%>"><%=getTran("gynaeco","temperature",sWebLanguage)%></td>
            <td class="admin2">
                <input <%=setRightClick("ITEM_TYPE_PPC_TEMPERATURE")%> type="text" class="text" size="5" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_PPC_TEMPERATURE" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_PPC_TEMPERATURE" property="value"/>" onblur="isNumber(this)"> °C
            </td>
        </tr>
        <tr>
            <td class="admin"><%=getTran("openclinic.chuk","observation",sWebLanguage)%></td>
            <td class="admin2">
                <textarea onKeyup="resizeTextarea(this,10);limitChars(this,255);" <%=setRightClick("ITEM_TYPE_PPC_OBSERVATION")%> class="text" cols="50" rows="2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_PPC_OBSERVATION" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_PPC_OBSERVATION" property="value"/></textarea>
            </td>
            <td class="admin"><%=getTran("openclinic.chuk","treatment",sWebLanguage)%></td>
            <td class="admin2">
                <textarea onKeyup="resizeTextarea(this,10);limitChars(this,255);" <%=setRightClick("ITEM_TYPE_PPC_TREATMENT")%> class="text" cols="50" rows="2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_PPC_TREATMENT" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_PPC_TREATMENT" property="value"/></textarea>
            </td>
        </tr>
        <tr>
            <td class="admin"><%=getTran("gynaeco","alimentation",sWebLanguage)%></td>
            <td class="admin2">
                <input <%=setRightClick("ITEM_TYPE_PPC_ALIMENTATION_MATERNELLE")%> type="checkbox" id="cbmaternelle" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_PPC_ALIMENTATION_MATERNELLE" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_PPC_ALIMENTATION_MATERNELLE;value=medwan.common.true" property="value" outputString="checked"/> value="medwan.common.true"/><%=getLabel("gynaeco.alimentation","maternelle",sWebLanguage,"cbmaternelle")%>
                <input <%=setRightClick("ITEM_TYPE_PPC_ALIMENTATION_ARTIFICIELLE")%> type="checkbox" id="cbartificielle" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_PPC_ALIMENTATION_ARTIFICIELLE" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_PPC_ALIMENTATION_ARTIFICIELLE;value=medwan.common.true" property="value" outputString="checked"/> value="medwan.common.true"/><%=getLabel("gynaeco.alimenation","artificielle",sWebLanguage,"cbartificielle")%>
                <br/>
                <%=getTran("gynaeco","regurgitation",sWebLanguage)%>
                <input <%=setRightClick("ITEM_TYPE_PPC_REGURGITATION")%> type="radio" onDblClick="uncheckRadio(this);" id="regu_r1" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_PPC_REGURGITATION" property="itemId"/>]>.value" value="medwan.common.yes" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_PPC_REGURGITATION;value=medwan.common.yes" property="value" outputString="checked"/>><%=getLabel("web.occup","medwan.common.yes",sWebLanguage,"regu_r1")%>
                <input <%=setRightClick("ITEM_TYPE_PPC_REGURGITATION")%> type="radio" onDblClick="uncheckRadio(this);" id="regu_r2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_PPC_REGURGITATION" property="itemId"/>]>.value" value="medwan.common.no" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_PPC_REGURGITATION;value=medwan.common.no" property="value" outputString="checked"/>><%=getLabel("web.occup","medwan.common.no",sWebLanguage,"regu_r2")%>
            </td>
            <td class="admin"><%=getTran("gynaeco","ictere",sWebLanguage)%></td>
            <td class="admin2">
                <input <%=setRightClick("ITEM_TYPE_PPC_ICTERE")%> type="radio" onDblClick="uncheckRadio(this);" id="ictere_r1" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_PPC_ICTERE" property="itemId"/>]>.value" value="medwan.common.yes" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_PPC_ICTERE;value=medwan.common.yes" property="value" outputString="checked"/>><%=getLabel("web.occup","medwan.common.yes",sWebLanguage,"ictere_r1")%>
                <input <%=setRightClick("ITEM_TYPE_PPC_ICTERE")%> type="radio" onDblClick="uncheckRadio(this);" id="ictere_r2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_PPC_ICTERE" property="itemId"/>]>.value" value="medwan.common.no" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_PPC_ICTERE;value=medwan.common.no" property="value" outputString="checked"/>><%=getLabel("web.occup","medwan.common.no",sWebLanguage,"ictere_r2")%>
            </td>
        </tr>
        <tr>
            <td class="admin"/>
            <td class="admin2" colspan="3">
<%-- BUTTONS --%>
        <%
        if (activeUser.getAccessRight("occup.postpartumchild.add") || activeUser.getAccessRight("occup.postpartumchild.edit")){
        %>
            <INPUT class="button" type="button" name="saveButton" id="save" value="<%=getTranNoLink("Web.Occup","medwan.common.record",sWebLanguage)%>" onclick="submitForm()"/>
        <%
        }
        %>
                <INPUT class="button" type="button" value="<%=getTranNoLink("Web","back",sWebLanguage)%>" onclick="if(checkSaveButton()){window.location.href='<c:url value="/main.do?Page=curative/index.jsp"/>&ts=<%=getTs()%>'}">
            </td>
        </tr>
    </table>
    <script>
      function submitForm(){
        transactionForm.saveButton.disabled = true;
        <%
            SessionContainerWO sessionContainerWO = (SessionContainerWO)SessionContainerFactory.getInstance().getSessionContainerWO(request,SessionContainerWO.class.getName());
            out.print(takeOverTransaction(sessionContainerWO, activeUser,"document.transactionForm.submit();"));
        %>
      }
    </script>
<%=ScreenHelper.contextFooter(request)%>
</form>
<%=writeJSButtons("transactionForm","saveButton")%>