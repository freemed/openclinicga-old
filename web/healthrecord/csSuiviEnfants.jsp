<%@page errorPage="/includes/error.jsp" %>
<%@include file="/includes/validateUser.jsp" %>
<%=checkPermission("cs.pvv", "select", activeUser)%>
<form name="transactionForm" id="transactionForm" method="POST" action="<c:url value="/healthrecord/updateTransaction.do"/>?ts=<%=getTs()%>" onclick="setSaveButton(event);" onkeyup="setSaveButton(event);">
    <bean:define id="transaction" name="be.mxs.webapp.wl.session.SessionContainerFactory.WO_SESSION_CONTAINER" property="currentTransactionVO"/>
	<%=checkPrestationToday(activePatient.personid, false, activeUser, (TransactionVO)transaction) %>
    <input type="hidden" id="transactionId" name="currentTransactionVO.<TransactionVO[hashCode=<bean:write name="transaction" scope="page" property="transactionId"/>]>.transactionId" value="<bean:write name="transaction" scope="page" property="transactionId"/>"/>
    <input type="hidden" id="serverId" name="currentTransactionVO.<TransactionVO[hashCode=<bean:write name="transaction" scope="page" property="transactionId"/>]>.serverId" value="<bean:write name="transaction" scope="page" property="serverId"/>"/>
    <input type="hidden" id="transactionType" name="currentTransactionVO.<TransactionVO[hashCode=<bean:write name="transaction" scope="page" property="transactionId"/>]>.transactionType" value="<bean:write name="transaction" scope="page" property="transactionType"/>"/>
    <input type="hidden" readonly name="be.mxs.healthrecord.updateTransaction.actionForwardKey" value="/main.do?Page=curative/index.jsp&ts=<%=getTs()%>"/>
    <input type="hidden" readonly name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_RECRUITMENT_CONVOCATION_ID" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_RECRUITMENT_CONVOCATION_ID" property="value"/>"/>
    <input type="hidden" readonly name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CONTEXT_DEPARTMENT" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CONTEXT_DEPARTMENT" translate="false" property="value"/>"/>
    <input type="hidden" readonly name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CONTEXT_CONTEXT" translate="false" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CONTEXT_CONTEXT" translate="false" property="value"/>"/>
    <%=contextHeader(request, sWebLanguage)%>
    <table width="100%" cellspacing="1" class="list">
        <%-- DATE --%>
        <tr>
            <td class="admin" width="<%=sTDAdminWidth%>">
                <a href="javascript:openHistoryPopup();" title="<%=getTranNoLink("Web.Occup","History",sWebLanguage)%>">...</a>&nbsp;<%=getTran("Web.Occup", "medwan.common.date", sWebLanguage)%>
            </td>
            <td class="admin2">
                <input type="text" class="text" size="12" maxLength="10" value="<mxs:propertyAccessorI18N name="transaction" scope="page" property="updateTime" formatType="date" format="dd-mm-yyyy"/>" name="currentTransactionVO.<TransactionVO[hashCode=<bean:write name="transaction" scope="page" property="transactionId"/>]>.updateTime" id="trandate" OnBlur="checkDate(this);">
                <script>writeTranDate();</script>
            </td>
        </tr>
        <tr>
            <td class="admin"><%=getTran("cs.suivi.enfants", "test.vih", sWebLanguage)%>&nbsp;</td>
            <td class="admin2">
                <select id="type_visite" class="text" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_SUIVI_ENFANTS_TEMPS" property="itemId"/>]>.value">
                    <option/>
                    <%SessionContainerWO sessionContainerWO = (SessionContainerWO) SessionContainerFactory.getInstance().getSessionContainerWO(request, SessionContainerWO.class.getName());
                        String item = sessionContainerWO.getCurrentTransactionVO().getItem(sPREFIX + "ITEM_TYPE_CS_SUIVI_ENFANTS_TEMPS").getValue();%>
                    <option value="6.weeks" <%=(item.equals("6.weeks") ? "selected" : "")%>>6 <%=getTran("web", "weeks", sWebLanguage)%>
                    </option>
                    <option value="7.5.months" <%=(item.equals("7.5.months") ? "selected" : "")%>>7 <%=getTran("web", "months", sWebLanguage)%>
                    </option>
                    <option value="9.months" <%=(item.equals("9.months") ? "selected" : "")%>>9 <%=getTran("web", "months", sWebLanguage)%>
                    </option>
                    <option value="15.months" <%=(item.equals("15.months") ? "selected" : "")%>>15 <%=getTran("web", "months", sWebLanguage)%>
                    </option>
                </select>
            </td>
        </tr>
        <tr>
            <td class="admin"><%=getTranNoLink("web.occup", "intradermo.result", sWebLanguage)%>
            </td>
            <td class="admin2">
                <input type="radio" onDblClick="uncheckRadio(this);" id="vih+" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_SUIVI_ENFANTS_RESULTAT" property="itemId"/>]>.value" value="+"
                <mxs:propertyAccessorI18N name="transaction.items" scope="page"
                                          compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_SUIVI_ENFANTS_RESULTAT;value=+"
                                          property="value" outputString="checked"/>><label for="vih+">+</label>
                <input type="radio" onDblClick="uncheckRadio(this);" id="vih-" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_SUIVI_ENFANTS_RESULTAT" property="itemId"/>]>.value" value="-"
                <mxs:propertyAccessorI18N name="transaction.items" scope="page"
                                          compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_SUIVI_ENFANTS_RESULTAT;value=-"
                                          property="value" outputString="checked"/>><label for="vih-">-</label>
            </td>
        </tr>
        <tr>
            <td class="admin"><%=getTranNoLink("cs.suivi.enfants", "deces", sWebLanguage)%>
            </td>
            <td class="admin2">
                <input type="radio" onDblClick="uncheckRadio(this);" id="deces1" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_SUIVI_ENFANTS_DECES" property="itemId"/>]>.value" value="yes"
                <mxs:propertyAccessorI18N name="transaction.items" scope="page"
                                          compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_SUIVI_ENFANTS_DECES;value=yes"
                                          property="value"
                                          outputString="checked"/>><%=getLabel("web", "yes", sWebLanguage, "deces1")%>
                <input type="radio" onDblClick="uncheckRadio(this);" id="deces2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_SUIVI_ENFANTS_DECES" property="itemId"/>]>.value" value="no"
                <mxs:propertyAccessorI18N name="transaction.items" scope="page"
                                          compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_SUIVI_ENFANTS_DECES;value=no"
                                          property="value"
                                          outputString="checked"/>><%=getLabel("web", "no", sWebLanguage, "deces2")%>
            </td>
        </tr>
          <%-- COMMENT --%>
        <tr>
            <td class="admin"><%=getTran("web", "comment", sWebLanguage)%>
            </td>
            <td colspan="3" class="admin2">
                <textarea id="comment" rows="1" onKeyup="resizeTextarea(this,10);" class="text" cols="75" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_SUIVI_ENFANTS_COMMENTAIRE_0" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_SUIVI_ENFANTS_COMMENTAIRE_0" property="value"/><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_SUIVI_ENFANTS_COMMENTAIRE_1" property="value"/><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_SUIVI_ENFANTS_COMMENTAIRE_2" property="value"/><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_SUIVI_ENFANTS_COMMENTAIRE_2" property="value"/><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_SUIVI_ENFANTS_COMMENTAIRE_3" property="value"/><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_SUIVI_ENFANTS_COMMENTAIRE_4" property="value"/></textarea>
                <input type="hidden" id="comment_1" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_SUIVI_ENFANTS_COMMENTAIRE_1" property="itemId"/>]>.value">
                <input type="hidden" id="comment_2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_SUIVI_ENFANTS_COMMENTAIRE_2" property="itemId"/>]>.value">
                <input type="hidden" id="comment_3" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_SUIVI_ENFANTS_COMMENTAIRE_3" property="itemId"/>]>.value">
                <input type="hidden" id="comment_4" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_SUIVI_ENFANTS_COMMENTAIRE_4" property="itemId"/>]>.value">
            </td>
        </tr>
    </table>
    <%-- BUTTONS --%><%=ScreenHelper.alignButtonsStart()%><%=getButtonsHtml(request, activeUser, activePatient, "cs.suivi.enfants", sWebLanguage)%><%=ScreenHelper.alignButtonsStop()%><%=ScreenHelper.contextFooter(request)%>
</form>
<script>
    <%-- SUBMIT FORM --%>
    function submitForm() {
        $("comment_1").value = $F("comment").substring(250, 500);
        $("comment_2").value = $F("comment").substring(500, 750);
        $("comment_3").value = $F("comment").substring(750, 1000);
        $("comment_4").value = $F("comment").substring(1000, 1250);
        $("comment").value = $F("comment").substring(0, 250);
        var temp = Form.findFirstElement(transactionForm);//for ff compatibility
        document.getElementById("buttonsDiv").style.visibility = "hidden";
    <%
        out.print(takeOverTransaction(sessionContainerWO, activeUser,"document.transactionForm.submit();"));
    %>
    }
</script>
<%=writeJSButtons("transactionForm", "saveButton")%>