<%@page errorPage="/includes/error.jsp" %>
<%@include file="/includes/validateUser.jsp" %>
<%=checkPermission("cs.pvv", "select", activeUser)%>
<form name="transactionForm" id="transactionForm" method="POST" action="<c:url value="/healthrecord/updateTransaction.do"/>?ts=<%=getTs()%>" onclick="setSaveButton(event);" onkeyup="setSaveButton(event);">
    <bean:define id="transaction" name="be.mxs.webapp.wl.session.SessionContainerFactory.WO_SESSION_CONTAINER" property="currentTransactionVO"/>
	<%=checkPrestationToday(activePatient.personid,false,activeUser,(TransactionVO)transaction)%>
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
        <%-- DEPISTAGE --%>
        <tr class="admin">
            <td colspan="4"><%=getTran("cs.pvv", "depistage", sWebLanguage)%>
            </td>
        </tr>
        <tr>
            <td class="admin"><%=getTran("cs.pvv", "actions", sWebLanguage)%>&nbsp;</td>
            <td class="admin2">
                <input type="checkbox" id="actions_1" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_PVV_RECU_INDIVIDUELLEMENT" property="itemId"/>]>.value" value="true"
                <mxs:propertyAccessorI18N name="transaction.items" scope="page"
                                          compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_PVV_RECU_INDIVIDUELLEMENT;value=true"
                                          property="value"
                                          outputString="checked"/>><%=getLabel("cs.pvv", "recu.individuellement", sWebLanguage, "actions_1")%>
                <br/>
                <input type="checkbox" id="actions_2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_PVV_CONSEILLE" property="itemId"/>]>.value" value="true"
                <mxs:propertyAccessorI18N name="transaction.items" scope="page"
                                          compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_PVV_CONSEILLE;value=true"
                                          property="value"
                                          outputString="checked"/>><%=getLabel("cs.pvv", "conseille", sWebLanguage, "actions_2")%>
                <br/>
                <input type="checkbox" id="actions_3" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_PVV_TESTE" property="itemId"/>]>.value" value="true"
                <mxs:propertyAccessorI18N name="transaction.items" scope="page"
                                          compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_PVV_TESTE;value=true"
                                          property="value"
                                          outputString="checked"/>><%=getLabel("cs.pvv", "teste", sWebLanguage, "actions_3")%>
                <br/>
                <input type="checkbox" id="actions_4" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_PVV_PARTENAIRE_TESTE" property="itemId"/>]>.value" value="true"
                <mxs:propertyAccessorI18N name="transaction.items" scope="page"
                                          compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_PVV_PARTENAIRE_TESTE;value=true"
                                          property="value"
                                          outputString="checked"/>><%=getLabel("cs.pvv", "partenaire.teste", sWebLanguage, "actions_4")%>
                <br/>
                <input type="checkbox" id="actions_5" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_PVV_RECUPERATION_RESULTATS" property="itemId"/>]>.value" value="true"
                <mxs:propertyAccessorI18N name="transaction.items" scope="page"
                                          compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_PVV_RECUPERATION_RESULTATS;value=true"
                                          property="value"
                                          outputString="checked"/>><%=getLabel("cs.pvv", "recuperation.resultats", sWebLanguage, "actions_5")%>
                <br/>
                <input type="checkbox" id="actions_6" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_PVV_SUIVI_VIH" property="itemId"/>]>.value" value="true"
                <mxs:propertyAccessorI18N name="transaction.items" scope="page"
                                          compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_PVV_SUIVI_VIH;value=true"
                                          property="value"
                                          outputString="checked"/>><%=getLabel("cs.pvv", "suivi.vih", sWebLanguage, "actions_6")%>
                <br/>
                <input type="checkbox" id="actions_7" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_PVV_SERODISCORDANCE" property="itemId"/>]>.value" value="true"
                <mxs:propertyAccessorI18N name="transaction.items" scope="page"
                                          compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_PVV_SERODISCORDANCE;value=true"
                                          property="value"
                                          outputString="checked"/>><%=getLabel("cs.pvv", "sero.discordance", sWebLanguage, "actions_7")%>
                <br/>
            </td>
        </tr>
        <tr>
            <td class="admin"><%=getTranNoLink("cs.pvv", "vih", sWebLanguage)%>
            </td>
            <td class="admin2">
                <input type="radio" onDblClick="uncheckRadio(this);" id="vih+" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_PVV_VIH" property="itemId"/>]>.value" value="+"
                <mxs:propertyAccessorI18N name="transaction.items" scope="page"
                                          compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_PVV_VIH;value=+"
                                          property="value" outputString="checked"/>><label for="vih+">+</label>
                <input type="radio" onDblClick="uncheckRadio(this);" id="vih-" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_PVV_VIH" property="itemId"/>]>.value" value="-"
                <mxs:propertyAccessorI18N name="transaction.items" scope="page"
                                          compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_PVV_VIH;value=-"
                                          property="value" outputString="checked"/>><label for="vih-">-</label>
            </td>
        </tr>
        <%-- Suivi --%>
        <tr class="admin">
            <td colspan="4"><%=getTran("cs.pvv", "suivi", sWebLanguage)%>
            </td>
        </tr>
        <tr>
            <td class="admin"><%=getTranNoLink("cs.pvv", "nouveau.cas", sWebLanguage)%>
            </td>
            <td class="admin2">
                <input type="radio" onDblClick="uncheckRadio(this);" id="newcase1" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_PVV_NOUVEAU_CAS" property="itemId"/>]>.value" value="yes"
                <mxs:propertyAccessorI18N name="transaction.items" scope="page"
                                          compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_PVV_NOUVEAU_CAS;value=yes"
                                          property="value"
                                          outputString="checked"/>><%=getLabel("web", "yes", sWebLanguage, "newcase1")%>
                <input type="radio" onDblClick="uncheckRadio(this);" id="newcase2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_PVV_NOUVEAU_CAS" property="itemId"/>]>.value" value="no"
                <mxs:propertyAccessorI18N name="transaction.items" scope="page"
                                          compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_PVV_NOUVEAU_CAS;value=no"
                                          property="value"
                                          outputString="checked"/>><%=getLabel("web", "no", sWebLanguage, "newcase2")%>
            </td>
        </tr>
        <%-- Prise en Charge --%>
        <tr class="admin">
            <td colspan="4"><%=getTran("cs.pvv", "prise.en.charge", sWebLanguage)%>
            </td>
        </tr>
        <tr>
            <td class="admin">&nbsp;</td>
            <td class="admin2">
                <input type="checkbox" id="prise_charge_1" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_PVV_ARV" property="itemId"/>]>.value" value="true"
                <mxs:propertyAccessorI18N name="transaction.items" scope="page"
                                          compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_PVV_ARV;value=true"
                                          property="value"
                                          outputString="checked"/>><%=getLabel("cs.pvv", "arv", sWebLanguage, "prise_charge_1")%>
                <br/>
                <input type="checkbox" id="prise_charge_2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_PVV_TRAITEMENT_IO" property="itemId"/>]>.value" value="true"
                <mxs:propertyAccessorI18N name="transaction.items" scope="page"
                                          compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_PVV_TRAITEMENT_IO;value=true"
                                          property="value"
                                          outputString="checked"/>><%=getLabel("cs.pvv", "traitement.io", sWebLanguage, "prise_charge_2")%>
                <br/>
                <input type="checkbox" id="prise_charge_3" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_PVV_TRAITEMENT_IST" property="itemId"/>]>.value" value="true"
                <mxs:propertyAccessorI18N name="transaction.items" scope="page"
                                          compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_PVV_TRAITEMENT_IST;value=true"
                                          property="value"
                                          outputString="checked"/>><%=getLabel("cs.pvv", "traitement.ist", sWebLanguage, "prise_charge_3")%>
                <br/>
                <input type="checkbox" id="prise_charge_4" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_PVV_PREVENTION_AU_BACTRIM" property="itemId"/>]>.value" value="true"
                <mxs:propertyAccessorI18N name="transaction.items" scope="page"
                                          compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_PVV_PREVENTION_AU_BACTRIM;value=true"
                                          property="value"
                                          outputString="checked"/>><%=getLabel("cs.pvv", "prevention.bactrim", sWebLanguage, "prise_charge_4")%>
                <br/>
                <input type="checkbox" id="prise_charge_5" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_PVV_TRAITEMENT_TBC" property="itemId"/>]>.value" value="true"
                <mxs:propertyAccessorI18N name="transaction.items" scope="page"
                                          compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_PVV_TRAITEMENT_TBC;value=true"
                                          property="value"
                                          outputString="checked"/>><%=getLabel("cs.pvv", "traitement.tbc", sWebLanguage, "prise_charge_5")%>
                <br/>
            </td>
        </tr>
        <%-- COMMENT --%>
        <tr>
            <td class="admin"><%=getTran("web", "comment", sWebLanguage)%>
            </td>
            <td colspan="3" class="admin2">
                <textarea id="comment" rows="1" onKeyup="resizeTextarea(this,10);" class="text" cols="75" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_PVV_COMMENTAIRE_0" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_PVV_COMMENTAIRE_0" property="value"/><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_PVV_COMMENTAIRE_1" property="value"/><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_PVV_COMMENTAIRE_2" property="value"/><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_PVV_COMMENTAIRE_2" property="value"/><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_PVV_COMMENTAIRE_3" property="value"/><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_PVV_COMMENTAIRE_4" property="value"/></textarea>
                <input type="hidden" id="comment_1" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_PVV_COMMENTAIRE_1" property="itemId"/>]>.value">
                <input type="hidden" id="comment_2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_PVV_COMMENTAIRE_2" property="itemId"/>]>.value">
                <input type="hidden" id="comment_3" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_PVV_COMMENTAIRE_3" property="itemId"/>]>.value">
                <input type="hidden" id="comment_4" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_PVV_COMMENTAIRE_4" property="itemId"/>]>.value">
            </td>
        </tr>
    </table>
    <%-- BUTTONS --%><%=ScreenHelper.alignButtonsStart()%><%=getButtonsHtml(request, activeUser, activePatient, "cs.pvv", sWebLanguage)%><%=ScreenHelper.alignButtonsStop()%><%=ScreenHelper.contextFooter(request)%>
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
        SessionContainerWO sessionContainerWO = (SessionContainerWO)SessionContainerFactory.getInstance().getSessionContainerWO(request,SessionContainerWO.class.getName());
        out.print(takeOverTransaction(sessionContainerWO, activeUser,"document.transactionForm.submit();"));
    %>
    }
</script>
<%=writeJSButtons("transactionForm", "saveButton")%>