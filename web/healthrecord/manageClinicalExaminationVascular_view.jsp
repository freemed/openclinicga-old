<%@include file="/includes/validateUser.jsp"%>
<%@page errorPage="/includes/error.jsp"%>

<form name="transactionForm" method="POST" action='<c:url value="/healthrecord/updateTransaction.do"/>?ts=<%=getTs()%>' onclick="setSaveButton();" onkeyup="setSaveButton();">
    <bean:define id="transaction" name="be.mxs.webapp.wl.session.SessionContainerFactory.WO_SESSION_CONTAINER" property="currentTransactionVO"/>

    <input id="serverId" type="hidden" name="currentTransactionVO.<TransactionVO[hashCode=<bean:write name="transaction" scope="page" property="transactionId"/>]>.serverId" value="<bean:write name="transaction" scope="page" property="serverId"/>"/>
    <input id="transactionId" type="hidden" name="currentTransactionVO.<TransactionVO[hashCode=<bean:write name="transaction" scope="page" property="transactionId"/>]>.transactionId" value="<bean:write name="transaction" scope="page" property="transactionId"/>"/>
    <input type="hidden" name="subClass" value="VASCULAR"/>
    <input id="transactionType" type="hidden" name="currentTransactionVO.<TransactionVO[hashCode=<bean:write name="transaction" scope="page" property="transactionId"/>]>.transactionType" value="<bean:write name="transaction" scope="page" property="transactionType"/>"/>
    <input type="hidden" readonly name="be.mxs.healthrecord.updateTransaction.actionForwardKey" value="/healthrecord/editTransaction.do?be.mxs.healthrecord.createTransaction.transactionType=<bean:write name="transaction" scope="page" property="transactionType"/>&be.mxs.healthrecord.transaction_id=currentTransaction&ts=<%=getTs()%>"/>
    <input type="hidden" readonly name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_VASCULAR_RAS" property="itemId"/>]>.value" value="medwan.common.false"/>

<script>
  function setTrue(itemType){
    var fieldName;
    fieldName = "currentTransactionVO.items.<ItemVO[hashCode="+itemType+"]>.value";
    document.getElementsByName(fieldName)[0].value = "medwan.common.true";
  }

  function setFalse(itemType){
    var fieldName;
    fieldName = "currentTransactionVO.items.<ItemVO[hashCode="+itemType+"]>.value";
    document.getElementsByName(fieldName)[0].value = "medwan.common.false";
  }
</script>

<table width="100%" class="list" cellspacing="0">
    <tr class="admin">
        <td><%=getTran("Web.Occup","medwan.healthrecord.anamnese.vasculaire",sWebLanguage)%></td>
        <td align="right" width="20%">
            <%=getLabel("Web.Occup","medwan.common.nothing-to-mention",sWebLanguage,"vasc-c1")%>&nbsp;<input name="vascular-ras" type="checkbox" id="vasc-c1" value="medwan.common.true" onclick="if (this.checked == true) {hide('VASCULAR-details');setTrue('<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_VASCULAR_RAS" property="itemId"/>'); } else {show('VASCULAR-details');setFalse('<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_VASCULAR_RAS" property="itemId"/>'); }">
        </td>
        <td align="right" width ="1%"><a href="#top" class="topbutton">&nbsp;</a></td>
    </tr>
    <tr id="VASCULAR-details" style="display:none" width="100%">
        <td colspan="4" width="100%">
            <table width="100%" cellspacing="1">
                <tr class="admin">
                    <td colspan="3"><%=getTran("Web.Occup","medwan.healthrecord.anamnese",sWebLanguage)%></td>
                </tr>
                <tr>
                    <td class="admin2" colspan="3"><input <%=setRightClick("ITEM_TYPE_VASCULAR_ANAMNESIS_PAIN_WHEN_WALKING")%> type="checkbox" id="vasc-c2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_VASCULAR_ANAMNESIS_PAIN_WHEN_WALKING" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_VASCULAR_ANAMNESIS_PAIN_WHEN_WALKING;value=medwan.common.true" property="value" outputString="checked"/> value="medwan.common.true"/><%=getLabel("Web.Occup","medwan.healthrecord.vascular.pain-when-walking",sWebLanguage,"vasc-c2")%></td>
                </tr>
                <tr  class="admin">
                    <td colspan="3"><%=getTran("Web.Occup","medwan.healthrecord.clinical-examination",sWebLanguage)%></td>
                </tr>
                <tr>
                    <td class="admin2" width="33%"><input <%=setRightClick("ITEM_TYPE_VASCULAR_CLINICAL_EXAMINATION_HEMANGIOMES")%> type="checkbox" id="vasc-c3" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_VASCULAR_CLINICAL_EXAMINATION_HEMANGIOMES" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_VASCULAR_CLINICAL_EXAMINATION_HEMANGIOMES;value=medwan.common.true" property="value" outputString="checked"/> value="medwan.common.true"/><%=getLabel("Web.Occup","medwan.healthrecord.vascular.hemangiomes",sWebLanguage,"vasc-c3")%></td>
                    <td class="admin2" width="*%"><%=getTran("Web.Occup","medwan.healthrecord.vascular.varices",sWebLanguage)%>
                        <input <%=setRightClick("ITEM_TYPE_VASCULAR_CLINICAL_EXAMINATION_VARICES_RIGHT")%> type="checkbox" id="vasc-c4" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_VASCULAR_CLINICAL_EXAMINATION_VARICES_RIGHT" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_VASCULAR_CLINICAL_EXAMINATION_VARICES_RIGHT;value=medwan.common.true" property="value" outputString="checked"/> value="medwan.common.true"/><%=getLabel("Web.Occup","medwan.common.right",sWebLanguage,"vasc-c4")%>
                        <input <%=setRightClick("ITEM_TYPE_VASCULAR_CLINICAL_EXAMINATION_VARICES_LEFT")%> type="checkbox" id="vasc-c5" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_VASCULAR_CLINICAL_EXAMINATION_VARICES_LEFT" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_VASCULAR_CLINICAL_EXAMINATION_VARICES_LEFT;value=medwan.common.true" property="value" outputString="checked"/> value="medwan.common.true"/><%=getLabel("Web.Occup","medwan.common.left",sWebLanguage,"vasc-c5")%>
                    </td>
                    <td class="admin2" width="33%"><input <%=setRightClick("ITEM_TYPE_VASCULAR_CLINICAL_EXAMINATION_OEDEMA_LEGS")%> type="checkbox" id="vasc-c6" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_VASCULAR_CLINICAL_EXAMINATION_OEDEMA_LEGS" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_VASCULAR_CLINICAL_EXAMINATION_OEDEMA_LEGS;value=medwan.common.true" property="value" outputString="checked"/> value="medwan.common.true"/><%=getLabel("Web.Occup","medwan.healthrecord.vascular.oedema-legs",sWebLanguage,"vasc-c6")%></td>
                </tr>
                <tr>
                    <td class="admin2"><input <%=setRightClick("ITEM_TYPE_VASCULAR_CLINICAL_EXAMINATION_VENOUS_ULCERS")%> type="checkbox" id="vasc-c7" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_VASCULAR_CLINICAL_EXAMINATION_VENOUS_ULCERS" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_VASCULAR_CLINICAL_EXAMINATION_VENOUS_ULCERS;value=medwan.common.true" property="value" outputString="checked"/> value="medwan.common.true"/><%=getLabel("Web.Occup","medwan.healthrecord.vascular.venous-ulcers",sWebLanguage,"vasc-c7")%></td>
                    <td class="admin2"><input <%=setRightClick("ITEM_TYPE_VASCULAR_CLINICAL_EXAMINATION_PERTHES")%> type="checkbox" id="vasc-c8" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_VASCULAR_CLINICAL_EXAMINATION_PERTHES" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_VASCULAR_CLINICAL_EXAMINATION_PERTHES;value=medwan.common.true" property="value" outputString="checked"/> value="medwan.common.true"/><%=getLabel("Web.Occup","medwan.healthrecord.vascular.perthes",sWebLanguage,"vasc-c8")%></td>
                    <td class="admin2"><input <%=setRightClick("ITEM_TYPE_VASCULAR_CLINICAL_EXAMINATION_TRENDELENBURG")%> type="checkbox" id="vasc-c9" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_VASCULAR_CLINICAL_EXAMINATION_TRENDELENBURG" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_VASCULAR_CLINICAL_EXAMINATION_TRENDELENBURG;value=medwan.common.true" property="value" outputString="checked"/> value="medwan.common.true"/><%=getLabel("Web.Occup","medwan.healthrecord.vascular.trendelenburg",sWebLanguage,"vasc-c9")%></td>
                </tr>
                <tr class="admin">
                    <td colspan="3"><%=getTran("Web.Occup","medwan.healthrecord.diagnose",sWebLanguage)%></td>
                </tr>
                <tr>
                    <td class="admin2"><input <%=setRightClick("ITEM_TYPE_VASCULAR_DIAGNOSIS_CLAUDICATIO")%> type="checkbox" id="vasc-c10" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_VASCULAR_DIAGNOSIS_CLAUDICATIO" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_VASCULAR_DIAGNOSIS_CLAUDICATIO;value=medwan.common.true" property="value" outputString="checked"/> value="medwan.common.true"/><%=getLabel("Web.Occup","medwan.healthrecord.vascular.claudicatio",sWebLanguage,"vasc-c10")%></td>
                    <td class="admin2"><input <%=setRightClick("ITEM_TYPE_VASCULAR_DIAGNOSIS_ARTERIOSCLEROSIS")%> type="checkbox" id="vasc-c11" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_VASCULAR_DIAGNOSIS_ARTERIOSCLEROSIS" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_VASCULAR_DIAGNOSIS_ARTERIOSCLEROSIS;value=medwan.common.true" property="value" outputString="checked"/> value="medwan.common.true"/><%=getLabel("Web.Occup","medwan.healthrecord.vascular.arteriosclerosis",sWebLanguage,"vasc-c11")%></td>
                    <td class="admin2"><input <%=setRightClick("ITEM_TYPE_VASCULAR_DIAGNOSIS_DEEP_VENOUS_THROMBOSIS")%> type="checkbox" id="vasc-c12" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_VASCULAR_DIAGNOSIS_DEEP_VENOUS_THROMBOSIS" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_VASCULAR_DIAGNOSIS_DEEP_VENOUS_THROMBOSIS;value=medwan.common.true" property="value" outputString="checked"/> value="medwan.common.true"/><%=getLabel("Web.Occup","medwan.healthrecord.vascular.deep-venous-thrombosis",sWebLanguage,"vasc-c12")%></td>
                </tr>
                <tr>
                    <td class="admin2"><input <%=setRightClick("ITEM_TYPE_VASCULAR_DIAGNOSIS_SUPERFICIAL_VENOUS_THROMBOSIS")%> type="checkbox" id="vasc-c13" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_VASCULAR_DIAGNOSIS_SUPERFICIAL_VENOUS_THROMBOSIS" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_VASCULAR_DIAGNOSIS_SUPERFICIAL_VENOUS_THROMBOSIS;value=medwan.common.true" property="value" outputString="checked"/> value="medwan.common.true"/><%=getLabel("Web.Occup","medwan.healthrecord.vascular.superficial-venous-thrombosis",sWebLanguage,"vasc-c13")%></td>
                    <td class="admin2"><input <%=setRightClick("ITEM_TYPE_VASCULAR_DIAGNOSIS_ANEURYSMA")%> type="checkbox" id="vasc-c14" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_VASCULAR_DIAGNOSIS_ANEURYSMA" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_VASCULAR_DIAGNOSIS_ANEURYSMA;value=medwan.common.true" property="value" outputString="checked"/> value="medwan.common.true"/><%=getLabel("Web.Occup","medwan.healthrecord.vascular.aneurysma",sWebLanguage,"vasc-c14")%></td>
                    <td class="admin2"><input <%=setRightClick("ITEM_TYPE_VASCULAR_DIAGNOSIS_SUPERFICIAL_VENOUS_PHLEBITIS")%> type="checkbox" id="vasc-c15" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_VASCULAR_DIAGNOSIS_SUPERFICIAL_VENOUS_PHLEBITIS" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_VASCULAR_DIAGNOSIS_SUPERFICIAL_VENOUS_PHLEBITIS;value=medwan.common.true" property="value" outputString="checked"/> value="medwan.common.true"/><%=getLabel("Web.Occup","medwan.healthrecord.vascular.superficial-phlebitis",sWebLanguage,"vasc-c15")%></td>
                </tr>
                <tr>
                    <td class="admin"><%=getTran("Web.Occup","medwan.common.remark",sWebLanguage)%></td>
                    <td class="admin2" colspan="2">
                        <textarea onKeyup="resizeTextarea(this,10);limitChars(this,255);" <%=setRightClick("ITEM_TYPE_VASCULAR_DIAGNOSIS_OTHER")%> class="text" rows="2" cols="80" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_VASCULAR_DIAGNOSIS_OTHER" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_VASCULAR_DIAGNOSIS_OTHER" property="value"/></textarea>
                    </td>
                </tr>
            </table>
        </td>
    </tr>
</table>

<%-- BUTTONS --%>
<%=ScreenHelper.alignButtonsStart()%>
    <INPUT class="button" type="button" name="saveButton" onClick="doSubmit();" value="<%=getTran("Web.Occup","medwan.common.record",sWebLanguage)%>">
    <INPUT class="button" type="button" value="<%=getTran("Web","Back",sWebLanguage)%>" onclick="if(checkSaveButton())){window.location.href='<c:url value='/healthrecord/editTransaction.do'/>?be.mxs.healthrecord.createTransaction.transactionType=<bean:write name="transaction" scope="page" property="transactionType"/>&be.mxs.healthrecord.transaction_id=currentTransaction&ts=<%=getTs()%>'}">
    <%=writeResetButton("transactionForm",sWebLanguage)%>
<%=ScreenHelper.alignButtonsStop()%>

<script>
  function doSubmit(){
    transactionForm.saveButton.disabled = true;
    <%
        SessionContainerWO sessionContainerWO = (SessionContainerWO)SessionContainerFactory.getInstance().getSessionContainerWO(request,SessionContainerWO.class.getName());
        out.print(takeOverTransaction(sessionContainerWO, activeUser,"document.transactionForm.submit();"));
    %>
  }

  document.getElementsByName('vascular-ras')[0].onclick();
</script>

</form>
<%=writeJSButtons("transactionForm", "document.getElementsByName('save')[0]")%>