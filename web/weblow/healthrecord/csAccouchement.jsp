<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>

<%=checkPermission("cs.accouchement","select",activeUser)%>

<form name="transactionForm" id="transactionForm" method="POST" action="<c:url value="/healthrecord/updateTransaction.do"/>?ts=<%=getTs()%>" onclick="setSaveButton(event);" onkeyup="setSaveButton(event);">
    <bean:define id="transaction" name="be.mxs.webapp.wl.session.SessionContainerFactory.WO_SESSION_CONTAINER" property="currentTransactionVO"/>
    <input type="hidden" id="transactionId" name="currentTransactionVO.<TransactionVO[hashCode=<bean:write name="transaction" scope="page" property="transactionId"/>]>.transactionId" value="<bean:write name="transaction" scope="page" property="transactionId"/>"/>
    <input type="hidden" id="serverId" name="currentTransactionVO.<TransactionVO[hashCode=<bean:write name="transaction" scope="page" property="transactionId"/>]>.serverId" value="<bean:write name="transaction" scope="page" property="serverId"/>"/>
    <input type="hidden" id="transactionType" name="currentTransactionVO.<TransactionVO[hashCode=<bean:write name="transaction" scope="page" property="transactionId"/>]>.transactionType" value="<bean:write name="transaction" scope="page" property="transactionType"/>"/>
    <input type="hidden" readonly name="be.mxs.healthrecord.updateTransaction.actionForwardKey" value="/main.do?Page=curative/index.jsp&ts=<%=getTs()%>"/>
    <input type="hidden" readonly name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_RECRUITMENT_CONVOCATION_ID" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_RECRUITMENT_CONVOCATION_ID" property="value"/>"/>
    <input type="hidden" readonly name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CONTEXT_DEPARTMENT" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CONTEXT_DEPARTMENT" translate="false" property="value"/>"/>
    <input type="hidden" readonly name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CONTEXT_CONTEXT" translate="false" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CONTEXT_CONTEXT" translate="false" property="value"/>"/>

    <%=contextHeader(request,sWebLanguage)%>

    <table width="100%" cellspacing="1" class="list">
        <%-- DATE --%>
        <tr>
            <td class="admin" width="<%=sTDAdminWidth%>">
                <a href="javascript:openHistoryPopup();" title="<%=getTranNoLink("Web.Occup","History",sWebLanguage)%>">...</a>&nbsp;
                <%=getTran("Web.Occup","medwan.common.date",sWebLanguage)%>
            </td>
            <td class="admin2">
                <input type="text" class="text" size="12" maxLength="10" value="<mxs:propertyAccessorI18N name="transaction" scope="page" property="updateTime" formatType="date" format="dd-mm-yyyy"/>" name="currentTransactionVO.<TransactionVO[hashCode=<bean:write name="transaction" scope="page" property="transactionId"/>]>.updateTime" id="trandate" OnBlur="checkDate(this);">
                <script>writeMyDate("trandate","<c:url value="/_img/icon_agenda.gif"/>","<%=getTran("Web","PutToday",sWebLanguage)%>");</script>
            </td>
        </tr>


            <tr>
             <td class="admin"><%=getTranNoLink("cs.accouchement","lieu",sWebLanguage)%></td>
                         <td class="admin2">
                   <input type="radio" onDblClick="uncheckRadio(this);" id="lieucs" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_ACCOUCHEMENT_LIEU" property="itemId"/>]>.value" value="cs"
                           <mxs:propertyAccessorI18N name="transaction.items" scope="page"
                                                     compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_ACCOUCHEMENT_LIEU;value=cs"
                                                     property="value" outputString="checked"/>><%=getLabel("cs.accouchement","cs",sWebLanguage,"lieucs")%>
                    <input type="radio" onDblClick="uncheckRadio(this);" id="lieuhcs" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_ACCOUCHEMENT_LIEU" property="itemId"/>]>.value" value="hors.cs"
                           <mxs:propertyAccessorI18N name="transaction.items" scope="page"
                                                     compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_ACCOUCHEMENT_LIEU;value=hors.cs"
                                                     property="value" outputString="checked"/>><%=getLabel("cs.accouchement","hors.cs",sWebLanguage,"lieuhcs")%>
                         </td>
             </tr>

            <tr>
             <td class="admin"><%=getTran("cs.accouchement","type",sWebLanguage)%></td>
                         <td class="admin2">
                   <input type="radio" onDblClick="uncheckRadio(this);" id="typeeu" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_ACCOUCHEMENT_TYPE" property="itemId"/>]>.value" value="eutocy"
                           <mxs:propertyAccessorI18N name="transaction.items" scope="page"
                                                     compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_ACCOUCHEMENT_TYPE;value=eutocy"
                                                     property="value" outputString="checked"/>><%=getLabel("cs.accouchement","eutocy",sWebLanguage,"typeeu")%>
                    <input type="radio" onDblClick="uncheckRadio(this);" id="typedys" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_ACCOUCHEMENT_TYPE" property="itemId"/>]>.value" value="dystocy"
                           <mxs:propertyAccessorI18N name="transaction.items" scope="page"
                                                     compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_ACCOUCHEMENT_TYPE;value=dystocy"
                                                     property="value" outputString="checked"/>><%=getLabel("cs.accouchement","dystocy",sWebLanguage,"typedys")%>
                         </td>
             </tr>



        <%-- Suivi --%>
        <tr class="admin">
            <td colspan="4"><%=getTran("cs.accouchement","nouveau.ne",sWebLanguage)%></td>
        </tr>
        <tr>
          <td class="admin"><%=getTranNoLink("cs.accouchement","poids",sWebLanguage)%></td>
                      <td class="admin2">
                         <input type="text" class="text" size="5" id="poids" maxLength="4" onBlur="checkPoids(this);" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_ACCOUCHEMENT_POIDS" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_ACCOUCHEMENT_POIDS" property="value"/>"> g
                          <input type="checkbox" id="actions_1" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_ACCOUCHEMENT_REFERENCE_HD" property="itemId"/>]>.value" value="true" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_ACCOUCHEMENT_REFERENCE_HD;value=true" property="value" outputString="checked"/>><%=getLabel("cs.accouchement","reference.hd",sWebLanguage,"actions_1")%><br />
                  </td>
          </tr>
            <tr>
                <td class="admin"><%=getTran("cs.accouchement","enfant.mort",sWebLanguage)%></td>
                   <td class="admin2"><input type="radio" onDblClick="uncheckRadio(this);" id="mortnon" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_ACCOUCHEMENT_MORT" property="itemId"/>]>.value" value="no"
                           <mxs:propertyAccessorI18N name="transaction.items" scope="page"
                                                     compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_ACCOUCHEMENT_MORT;value=no"
                                                     property="value" outputString="checked"/>><%=getLabel("cs.accouchement","dead.no",sWebLanguage,"mortnon")%>
                             <input type="radio" onDblClick="uncheckRadio(this);" id="mortinutero" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_ACCOUCHEMENT_MORT" property="itemId"/>]>.value" value="inutero"
                                    <mxs:propertyAccessorI18N name="transaction.items" scope="page"
                                                              compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_ACCOUCHEMENT_MORT;value=inutero"
                                                              property="value" outputString="checked"/>><%=getLabel("cs.accouchement","dead.inutero",sWebLanguage,"mortinutero")%>
                             <input type="radio" onDblClick="uncheckRadio(this);" id="mortne" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_ACCOUCHEMENT_MORT" property="itemId"/>]>.value" value="birth"
                                    <mxs:propertyAccessorI18N name="transaction.items" scope="page"
                                                              compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_ACCOUCHEMENT_MORT;value=birth"
                                                              property="value" outputString="checked"/>><%=getLabel("cs.accouchement","dead.birth",sWebLanguage,"mortne")%>
                         </td>
             </tr>

        <%-- Prise en Charge --%>
       <tr class="admin">
            <td colspan="4"><%=getTran("cs.accouchement","mere",sWebLanguage)%></td>
        </tr>
         <tr>

          <td class="admin"><%=getTranNoLink("cs.pvv","vih",sWebLanguage)%></td>
                      <td class="admin2">
                <input type="radio" onDblClick="uncheckRadio(this);" id="vih+" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_ACCOUCHEMENT_MERE_VIH" property="itemId"/>]>.value" value="+"
                        <mxs:propertyAccessorI18N name="transaction.items" scope="page"
                                                  compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_ACCOUCHEMENT_MERE_VIH;value=+"
                                                  property="value" outputString="checked"/>><label for="vih+">+</label>
                 <input type="radio" onDblClick="uncheckRadio(this);" id="vih-" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_ACCOUCHEMENT_MERE_VIH" property="itemId"/>]>.value" value="-"
                        <mxs:propertyAccessorI18N name="transaction.items" scope="page"
                                                  compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_ACCOUCHEMENT_MERE_VIH;value=-"
                                                  property="value" outputString="checked"/>><label for="vih-">-</label>
                      </td>
          </tr>
         <%-- COMMENT --%>
        <tr>
            <td class="admin"><%=getTran("web", "comment", sWebLanguage)%>
            </td>
            <td colspan="3" class="admin2">
                <textarea id="comment" rows="1" onKeyup="resizeTextarea(this,10);" class="text" cols="75" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_ACCOUCHEMENT_COMMENTAIRE_0" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_ACCOUCHEMENT_COMMENTAIRE_0" property="value"/><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_ACCOUCHEMENT_COMMENTAIRE_1" property="value"/><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_ACCOUCHEMENT_COMMENTAIRE_2" property="value"/><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_ACCOUCHEMENT_COMMENTAIRE_2" property="value"/><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_ACCOUCHEMENT_COMMENTAIRE_3" property="value"/><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_ACCOUCHEMENT_COMMENTAIRE_4" property="value"/></textarea>
                <input type="hidden" id="comment_1" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_ACCOUCHEMENT_COMMENTAIRE_1" property="itemId"/>]>.value">
                <input type="hidden" id="comment_2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_ACCOUCHEMENT_COMMENTAIRE_2" property="itemId"/>]>.value">
                <input type="hidden" id="comment_3" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_ACCOUCHEMENT_COMMENTAIRE_3" property="itemId"/>]>.value">
                <input type="hidden" id="comment_4" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_ACCOUCHEMENT_COMMENTAIRE_4" property="itemId"/>]>.value">
            </td>
        </tr>

    </table>

    <%-- BUTTONS --%>
    <%=ScreenHelper.alignButtonsStart()%>
        <%=getButtonsHtml(request,activeUser,activePatient,"cs.accouchement",sWebLanguage)%>
    <%=ScreenHelper.alignButtonsStop()%>

    <%=ScreenHelper.contextFooter(request)%>
</form>

<script>
   var checkPoids = function(obj){
       if(!isNumber(obj) || obj.value<0 || obj.value>8000){
           obj.value = "";
       }
   }
  <%-- SUBMIT FORM --%>
  function submitForm(){
      $("comment_1").value = $F("comment").substring(250, 500);
        $("comment_2").value = $F("comment").substring(500, 750);
        $("comment_3").value = $F("comment").substring(750, 1000);
        $("comment_4").value = $F("comment").substring(1000, 1250);
        $("comment").value = $F("comment").substring(0, 250);
    var temp = Form.findFirstElement(transactionForm);//for ff compatibility
    document.transactionForm.saveButton.style.visibility = "hidden";
    <%
        SessionContainerWO sessionContainerWO = (SessionContainerWO)SessionContainerFactory.getInstance().getSessionContainerWO(request,SessionContainerWO.class.getName());
        out.print(takeOverTransaction(sessionContainerWO, activeUser,"document.transactionForm.submit();"));
    %>
  }
</script>

<%=writeJSButtons("transactionForm","saveButton")%>