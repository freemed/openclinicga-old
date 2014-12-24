<%@page errorPage="/includes/error.jsp" %>
<%@include file="/includes/validateUser.jsp" %>
<%=checkPermission("cs.pmtct", "select", activeUser)%>

<form name="transactionForm" id="transactionForm" method="POST" action="<c:url value="/healthrecord/updateTransaction.do"/>?ts=<%=getTs()%>">
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
                <input type="text" class="text" size="12" maxLength="10" value="<mxs:propertyAccessorI18N name="transaction" scope="page" property="updateTime" formatType="date"/>" name="currentTransactionVO.<TransactionVO[hashCode=<bean:write name="transaction" scope="page" property="transactionId"/>]>.updateTime" id="trandate" OnBlur="checkDate(this);">
                <script>writeTranDate();</script>
            </td>
        </tr>
        <tr>
            <td class="admin"><%=getTran("cs.pvv", "actions", sWebLanguage)%>&nbsp;</td>
            <td class="admin2">
                <input onclick="setCouncelingClick();" type="checkbox" id="action_1" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_PMTCT_COUNSELLING" property="itemId"/>]>.value" value="true"
                <mxs:propertyAccessorI18N name="transaction.items" scope="page"
                                          compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_PMTCT_COUNSELLING;value=true"
                                          property="value"
                                          outputString="checked"/>><%=getLabel("cs.pmtct", "counselling", sWebLanguage, "action_1")%>
                <div style="visibility:hidden;display:inline;" id="action_2_div">
                    <input type="checkbox" id="action_2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_PMTCT_AVEC_PARTENAIRE" property="itemId"/>]>.value" value="true"
                    <mxs:propertyAccessorI18N name="transaction.items" scope="page"
                                              compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_PMTCT_AVEC_PARTENAIRE;value=true"
                                              property="value"
                                              outputString="checked"/>><%=getLabel("cs.pmtct", "avec.partenaire", sWebLanguage, "action_2")%>
                </div>
                <br/>
                <input type="checkbox" id="action_3" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_PMTCT_TESTE_VIH" property="itemId"/>]>.value" value="true"
                <mxs:propertyAccessorI18N name="transaction.items" scope="page"
                                          compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_PMTCT_TESTE_VIH;value=true"
                                          property="value"
                                          outputString="checked"/>><%=getLabel("cs.pmtct", "teste.vih", sWebLanguage, "action_3")%>
                <br/>
                <input type="checkbox" id="action_4" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_PMTCT_TESTE_RPR" property="itemId"/>]>.value" value="true"
                <mxs:propertyAccessorI18N name="transaction.items" scope="page"
                                          compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_PMTCT_TESTE_RPR;value=true"
                                          property="value"
                                          outputString="checked"/>><%=getLabel("cs.pmtct", "teste.rpr", sWebLanguage, "action_4")%>
                <br/>
                <input type="checkbox" id="action_5" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_PMTCT_RECUPERATION_RESULTATS" property="itemId"/>]>.value" value="true"
                <mxs:propertyAccessorI18N name="transaction.items" scope="page"
                                          compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_PMTCT_RECUPERATION_RESULTATS;value=true"
                                          property="value"
                                          outputString="checked"/>><%=getLabel("cs.pmtct", "recuperation.resultats", sWebLanguage, "action_5")%>
                <br/>
            </td>
        </tr>
        <tr>
            <td class="admin"><%=getTranNoLink("cs.pvv", "vih", sWebLanguage)%></td>
            <td class="admin2">
                <input type="radio" onclick="setVihClick();" onDblClick="uncheckRadio(this);setVihClick();" id="vih1" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_PMTCT_VIH" property="itemId"/>]>.value" value="+"
                <mxs:propertyAccessorI18N name="transaction.items" scope="page"
                                          compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_PMTCT_VIH;value=+"
                                          property="value" outputString="checked"/>><label for="vih1">+</label>
                <input type="radio" onclick="setVihClick();" onDblClick="uncheckRadio(this);setVihClick();" id="vih2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_PMTCT_VIH" property="itemId"/>]>.value" value="-"
                <mxs:propertyAccessorI18N name="transaction.items" scope="page"
                                          compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_PMTCT_VIH;value=-"
                                          property="value" outputString="checked"/>><label for="vih2">-</label>

                <div style="display:none;float:left;clear:right;" id="vih1_div">
                    <input type="checkbox" id="vih3" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_PMTCT_ELIGIBLE_ARV" property="itemId"/>]>.value" value="true"
                    <mxs:propertyAccessorI18N name="transaction.items" scope="page"
                                              compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_PMTCT_ELIGIBLE_ARV;value=true"
                                              property="value"
                                              outputString="checked"/>><%=getLabel("cs.pmtct", "eligible.arv", sWebLanguage, "vih3")%>
                    <br/>
                    <input type="checkbox" id="vih4" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_PMTCT_ELIGIBLE_PROPHYLAXIE" property="itemId"/>]>.value" value="true"
                    <mxs:propertyAccessorI18N name="transaction.items" scope="page"
                                              compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_PMTCT_ELIGIBLE_PROPHYLAXIE;value=true"
                                              property="value"
                                              outputString="checked"/>><%=getLabel("cs.pmtct", "eligible.prophylaxie", sWebLanguage, "vih4")%>
                    <br/>
                </div>
            </td>
        </tr>
        <tr>
            <td class="admin"><%=getTranNoLink("cs.pmtct", "rpr", sWebLanguage)%></td>
            <td class="admin2">
                <input type="radio" onchange="setVihClick();" onDblClick="uncheckRadio(this);setVihClick();" id="rpr1" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_PMTCT_RPR" property="itemId"/>]>.value" value="+"
                <mxs:propertyAccessorI18N name="transaction.items" scope="page"
                                          compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_PMTCT_RPR;value=+"
                                          property="value" outputString="checked"/>><label for="rpr1">+</label>
                <input type="radio" onchange="setVihClick();" onDblClick="uncheckRadio(this);setVihClick();" id="rpr2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_PMTCT_RPR" property="itemId"/>]>.value" value="-"
                <mxs:propertyAccessorI18N name="transaction.items" scope="page"
                                          compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_PMTCT_RPR;value=-"
                                          property="value" outputString="checked"/>><label for="rpr2">-</label>
            </td>
        </tr>
        
        <%-- COMMENT --%>
        <tr>
            <td class="admin"><%=getTran("web", "comment", sWebLanguage)%></td>
            <td colspan="3" class="admin2">
                <textarea id="comment" rows="1" onKeyup="resizeTextarea(this,10);" class="text" cols="75" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_PMTCT_COMMENTAIRE_0" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_PMTCT_COMMENTAIRE_0" property="value"/><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_PMTCT_COMMENTAIRE_1" property="value"/><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_PMTCT_COMMENTAIRE_2" property="value"/><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_PMTCT_COMMENTAIRE_2" property="value"/><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_PMTCT_COMMENTAIRE_3" property="value"/><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_PMTCT_COMMENTAIRE_4" property="value"/></textarea>
                <input type="hidden" id="comment_1" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_PMTCT_COMMENTAIRE_1" property="itemId"/>]>.value" />
                <input type="hidden" id="comment_2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_PMTCT_COMMENTAIRE_2" property="itemId"/>]>.value" />
                <input type="hidden" id="comment_3" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_PMTCT_COMMENTAIRE_3" property="itemId"/>]>.value" />
                <input type="hidden" id="comment_4" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_PMTCT_COMMENTAIRE_4" property="itemId"/>]>.value" />
            </td>
        </tr>
    </table>
    
    <%-- BUTTONS --%>
    <%=ScreenHelper.alignButtonsStart()%>
    <%=getButtonsHtml(request,activeUser,activePatient,"cs.pmtct",sWebLanguage)%>
    <%=ScreenHelper.alignButtonsStop()%>
    
    <%=ScreenHelper.contextFooter(request)%>
</form>

<script>
  <%-- SUBMIT FORM --%>
  function submitForm(){
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
  
  var setCouncelingClick = function(){
    if($("action_1").checked == true){
      $("action_2_div").style.visibility = "visible";
    }
    else{
      $("action_2_div").style.visibility = "hidden";
      $("action_2").checked = false;
    }
  }
  
  var setVihClick = function(){
    if($("vih1").checked == true){
      $("vih1_div").style.display = "inline";
    }
    else{
      $("vih1_div").style.display = "none";
      $("vih3").checked = false;
      $("vih4").checked = false;
    }
  }
  
  window.onload = function() {
    setCouncelingClick();
    setVihClick();
  }
</script>

<%=writeJSButtons("transactionForm","saveButton")%>