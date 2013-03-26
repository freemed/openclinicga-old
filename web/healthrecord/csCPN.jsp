<%@page errorPage="/includes/error.jsp" %>
<%@include file="/includes/validateUser.jsp" %>
<%=checkPermission("cs.cpn", "select", activeUser)%>
<form name="transactionForm" id="transactionForm" method="POST" action="<c:url value="/healthrecord/updateTransaction.do"/>?ts=<%=getTs()%>" onclick="setSaveButton(event);" onkeyup="setSaveButton(event);">
    <bean:define id="transaction" name="be.mxs.webapp.wl.session.SessionContainerFactory.WO_SESSION_CONTAINER" property="currentTransactionVO"/>
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
                <script>writeMyDate("trandate", "<c:url value="/_img/icon_agenda.gif"/>", "<%=getTran("Web","PutToday",sWebLanguage)%>");</script>
            </td>
        </tr>
        <tr>
            <td class="admin"><%=getTran("cs.cpn", "type.de.visite", sWebLanguage)%>&nbsp;</td>
            <td class="admin2">
                <select id="type_visite" class="text" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_CPN_TYPE_VISITE" property="itemId"/>]>.value">
                    <option/>
                    <%SessionContainerWO sessionContainerWO = (SessionContainerWO) SessionContainerFactory.getInstance().getSessionContainerWO(request, SessionContainerWO.class.getName());
                        String item = sessionContainerWO.getCurrentTransactionVO().getItem(sPREFIX + "ITEM_TYPE_CS_CPN_TYPE_VISITE").getValue();%>
                    <option value="nouvelle.inscription" <%=(item.equals("nouvelle.inscription") ? "selected" : "")%>><%=getTran("cs.cpn.type.visite", "nouvelle.inscription", sWebLanguage)%>
                    </option>
                    <option value="premier.trimestre" <%=(item.equals("premier.trimestre") ? "selected" : "")%>><%=getTran("cs.cpn.type.visite", "premier.trimestre", sWebLanguage)%>
                    </option>
                    <option value="deuxieme.trimestre" <%=(item.equals("deuxieme.trimestre") ? "selected" : "")%>><%=getTran("cs.cpn.type.visite", "deuxieme.trimestre", sWebLanguage)%>
                    </option>
                    <option value="7.8.mois" <%=(item.equals("7.8.mois") ? "selected" : "")%>><%=getTran("cs.cpn.type.visite", "7.8.mois", sWebLanguage)%>
                    </option>
                    <option value="9.mois" <%=(item.equals("9.mois") ? "selected" : "")%>><%=getTran("cs.cpn.type.visite", "9.mois", sWebLanguage)%>
                    </option>
                    <option value="autre" <%=(item.equals("autre") ? "selected" : "")%>><%=getTran("cs.cpn.type.visite", "autre", sWebLanguage)%>
                    </option>
                </select>
            </td>
        <tr>
            <td class="admin">&nbsp;</td>
            <td class="admin2">
                <input type="checkbox" id="grossesse_risque" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_CPN_GROSSESSE_RISQUE" property="itemId"/>]>.value" value="true"
                <mxs:propertyAccessorI18N name="transaction.items" scope="page"
                                          compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_CPN_GROSSESSE_RISQUE;value=true"
                                          property="value"
                                          outputString="checked"/>><%=getLabel("cs.cpn", "grossesse.risque", sWebLanguage, "grossesse_risque")%>
            </td>
        </tr>
        <tr>
            <td class="admin"><%=getTranNoLink("cs.cpn", "tpi", sWebLanguage)%>
            </td>
            <td class="admin2">
                <input type="radio" onDblClick="uncheckRadio(this);" id="tpi1" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_CPN_TPI" property="itemId"/>]>.value" value="I"
                <mxs:propertyAccessorI18N name="transaction.items" scope="page"
                                          compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_CPN_TPI;value=I"
                                          property="value" outputString="checked"/>><label for="tpi1">I</label>
                <input type="radio" onDblClick="uncheckRadio(this);" id="tpi2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_CPN_TPI" property="itemId"/>]>.value" value="II"
                <mxs:propertyAccessorI18N name="transaction.items" scope="page"
                                          compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_CPN_TPI;value=II"
                                          property="value" outputString="checked"/>><label for="tpi2">II</label>
                <input type="radio" onDblClick="uncheckRadio(this);" id="tpi3" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_CPN_TPI" property="itemId"/>]>.value" value="III"
                <mxs:propertyAccessorI18N name="transaction.items" scope="page"
                                          compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_CPN_TPI;value=III"
                                          property="value" outputString="checked"/>>III
            </td>
        </tr>
        <tr>
            <td class="admin"><%=getTranNoLink("cs.cpn", "vat", sWebLanguage)%>
            </td>
            <td class="admin2">
                <input type="radio" onDblClick="uncheckRadio(this);" id="vat1" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_CPN_VAT" property="itemId"/>]>.value" value="1"
                <mxs:propertyAccessorI18N name="transaction.items" scope="page"
                                          compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_CPN_VAT;value=1"
                                          property="value" outputString="checked"/>><label for="vat1">1</label>
                <input type="radio" onDblClick="uncheckRadio(this);" id="vat2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_CPN_VAT" property="itemId"/>]>.value" value="2"
                <mxs:propertyAccessorI18N name="transaction.items" scope="page"
                                          compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_CPN_VAT;value=2"
                                          property="value" outputString="checked"/>><label for="vat2">2</label>
                <input type="radio" onDblClick="uncheckRadio(this);" id="vat3" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_CPN_VAT" property="itemId"/>]>.value" value="3"
                <mxs:propertyAccessorI18N name="transaction.items" scope="page"
                                          compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_CPN_VAT;value=3"
                                          property="value" outputString="checked"/>><label for="vat3">3</label>
                <input type="radio" onDblClick="uncheckRadio(this);" id="vat4" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_CPN_VAT" property="itemId"/>]>.value" value="4"
                <mxs:propertyAccessorI18N name="transaction.items" scope="page"
                                          compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_CPN_VAT;value=4"
                                          property="value" outputString="checked"/>><label for="vat4">4</label>
                <input type="radio" onDblClick="uncheckRadio(this);" id="vat5" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_CPN_VAT" property="itemId"/>]>.value" value="5"
                <mxs:propertyAccessorI18N name="transaction.items" scope="page"
                                          compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_CPN_VAT;value=5"
                                          property="value" outputString="checked"/>><label for="vat5">5</label>
            </td>
        </tr>
        <tr>
            <td class="admin">&nbsp;</td>
            <td class="admin2">
                <input type="checkbox" id="fer" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_CPN_FER_ACIDE_FOLIQUE" property="itemId"/>]>.value" value="true"
                <mxs:propertyAccessorI18N name="transaction.items" scope="page"
                                          compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_CPN_FER_ACIDE_FOLIQUE;value=true"
                                          property="value"
                                          outputString="checked"/>><%=getLabel("cs.cpn", "fer.acide.folique", sWebLanguage, "fer")%>
            </td>
        </tr>
        <tr>
            <td class="admin">&nbsp;</td>
            <td class="admin2">
                <input type="checkbox" id="moustiquaire" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_CPN_MOUSTIQUAIRE_IMPREGNEE" property="itemId"/>]>.value" value="true"
                <mxs:propertyAccessorI18N name="transaction.items" scope="page"
                                          compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_CPN_MOUSTIQUAIRE_IMPREGNEE;value=true"
                                          property="value"
                                          outputString="checked"/>><%=getLabel("cs.cpn", "moustiquaire.impregnee", sWebLanguage, "moustiquaire")%>
            </td>
        </tr>
         <tr>
            <td class="admin"><%=getTran("web", "comment", sWebLanguage)%>
            </td>
            <td colspan="3" class="admin2">
                <textarea id="comment" rows="1" onKeyup="resizeTextarea(this,10);" class="text" cols="75" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_CPN_COMMENTAIRE_0" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_CPN_COMMENTAIRE_0" property="value"/><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_CPN_COMMENTAIRE_1" property="value"/><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_CPN_COMMENTAIRE_2" property="value"/><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_CPN_COMMENTAIRE_2" property="value"/><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_CPN_COMMENTAIRE_3" property="value"/><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_CPN_COMMENTAIRE_4" property="value"/></textarea>
                <input type="hidden" id="comment_1" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_CPN_COMMENTAIRE_1" property="itemId"/>]>.value">
                <input type="hidden" id="comment_2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_CPN_COMMENTAIRE_2" property="itemId"/>]>.value">
                <input type="hidden" id="comment_3" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_CPN_COMMENTAIRE_3" property="itemId"/>]>.value">
                <input type="hidden" id="comment_4" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_CPN_COMMENTAIRE_4" property="itemId"/>]>.value">
            </td>
        </tr>
    </table>
    <%-- BUTTONS --%><%=ScreenHelper.alignButtonsStart()%><%=getButtonsHtml(request, activeUser, activePatient, "cs.cpn", sWebLanguage)%><%=ScreenHelper.alignButtonsStop()%><%=ScreenHelper.contextFooter(request)%>
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
        document.transactionForm.saveButton.style.visibility = "hidden";
    <%
      out.print(takeOverTransaction(sessionContainerWO, activeUser,"document.transactionForm.submit();"));
    %>
    }
    window.onload = function() {
        if ("<bean:write name="transaction" scope="page" property="transactionId"/>" < 0 && "<%=MedwanQuery.getInstance().getLastItemValue(Integer.parseInt(activePatient.personid),"be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_CPN_GROSSESSE_RISQUE")%>".length>0) {
        <%

TransactionVO tran = MedwanQuery.getInstance().getLastTransactionVO(Integer.parseInt(activePatient.personid),"be.mxs.common.model.vo.healthrecord.IConstants.TRANSACTION_TYPE_CS_CPN");
        if (tran!=null){
              tran = MedwanQuery.getInstance().loadTransaction(tran.getServerId(),tran.getTransactionId().intValue());
              ItemVO itemVO = tran.getItem("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_CPN_GROSSESSE_RISQUE");

              if (itemVO!=null){
              //set checked
                out.write("$(\"grossesse_risque\").checked = \"checked\";");
           }
          }
        %>
        }
    }
</script>
<%=writeJSButtons("transactionForm", "saveButton")%>