<%@include file="/includes/validateUser.jsp"%>
<%@page errorPage="/includes/error.jsp"%>
<%
    
%>
<form name="transactionForm" method="POST" action='<c:url value="/healthrecord/updateTransaction.do"/>?ts=<%=getTs()%>' onclick="setSaveButton();" onkeyup="setSaveButton();">
    <bean:define id="transaction" name="be.mxs.webapp.wl.session.SessionContainerFactory.WO_SESSION_CONTAINER" property="currentTransactionVO"/>

    <input type="hidden" name="subClass" value="ENDOCRINO"/>
    <input id="transactionId" type="hidden" name="currentTransactionVO.<TransactionVO[hashCode=<bean:write name="transaction" scope="page" property="transactionId"/>]>.transactionId" value="<bean:write name="transaction" scope="page" property="transactionId"/>"/>
    <input id="transactionType" type="hidden" name="currentTransactionVO.<TransactionVO[hashCode=<bean:write name="transaction" scope="page" property="transactionId"/>]>.transactionType" value="<bean:write name="transaction" scope="page" property="transactionType"/>"/>
    <input id="serverId" type="hidden" name="currentTransactionVO.<TransactionVO[hashCode=<bean:write name="transaction" scope="page" property="transactionId"/>]>.serverId" value="<bean:write name="transaction" scope="page" property="serverId"/>"/>
    <input type="hidden" readonly name="be.mxs.healthrecord.updateTransaction.actionForwardKey" value="/healthrecord/editTransaction.do?be.mxs.healthrecord.createTransaction.transactionType=<bean:write name="transaction" scope="page" property="transactionType"/>&be.mxs.healthrecord.transaction_id=currentTransaction&ts=<%=getTs()%>"/>
    <input type="hidden" readonly name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ENDOCRINO_RAS" property="itemId"/>]>.value" value="medwan.common.false"/>

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
        <td><%=getTran("Web.Occup","medwan.healthrecord.anamnese.endocrinologie",sWebLanguage)%></td>
        <td align="right" width="20%">
            <%=getLabel("Web.Occup","medwan.common.nothing-to-mention",sWebLanguage,"mcee-c1")%>&nbsp;<input name="endocrino-ras" type="checkbox" id="mcee-c1" value="medwan.common.true" onclick="if (this.checked == true) {hide('ENDOCRINO-details');setTrue('<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ENDOCRINO_RAS" property="itemId"/>'); } else {show('ENDOCRINO-details');setFalse('<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ENDOCRINO_RAS" property="itemId"/>'); }">
        </td>
        <td align="right" width ="1%"><a href="#top" >&nbsp;</a></td>
    </tr>
    <tr id="ENDOCRINO-details" style="display:none" width="100%">
        <td colspan="4" width="100%">
            <table width="100%" cellspacing="1">
                <tr class="admin">
                    <td colspan="4"><%=getTran("Web.Occup","medwan.healthrecord.anamnese",sWebLanguage)%></td>
                </tr>
                <tr>
                    <td class="admin2"><input <%=setRightClick("ITEM_TYPE_ENDOCRINO_ANAMNESIS_POLYURIA")%> type="checkbox" id="mcee-c2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ENDOCRINO_ANAMNESIS_POLYURIA" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ENDOCRINO_ANAMNESIS_POLYURIA;value=medwan.common.true" property="value" outputString="checked"/> value="medwan.common.true"/><%=getLabel("Web.Occup","medwan.healthrecord.endocrino.polyuria",sWebLanguage,"mcee-c2")%></td>
                    <td class="admin2" colspan="3"><input <%=setRightClick("ITEM_TYPE_ENDOCRINO_ANAMNESIS_POLYDIPSIA")%> type="checkbox" id="mcee-c3" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ENDOCRINO_ANAMNESIS_POLYDIPSIA" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ENDOCRINO_ANAMNESIS_POLYDIPSIA;value=medwan.common.true" property="value" outputString="checked"/> value="medwan.common.true"/><%=getLabel("Web.Occup","medwan.healthrecord.endocrino.polydypsia",sWebLanguage,"mcee-c3")%></td>
                </tr>
                <tr class="admin">
                    <td colspan="4"><%=getTran("Web.Occup","medwan.healthrecord.clinical-examination",sWebLanguage)%></td>
                </tr>
                <tr>
                    <td class="admin2" colspan="4"><input <%=setRightClick("ITEM_TYPE_ENDOCRINO_CLINICAL_EXAMINATION_THYROID_ENLARGEMENT")%> type="checkbox" id="mcee-c4" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ENDOCRINO_CLINICAL_EXAMINATION_THYROID_ENLARGEMENT" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ENDOCRINO_CLINICAL_EXAMINATION_THYROID_ENLARGEMENT;value=medwan.common.true" property="value" outputString="checked"/> value="medwan.common.true"/><%=getLabel("Web.Occup","medwan.healthrecord.endocrino.thyroid-enlargement",sWebLanguage,"mcee-c4")%></td>
                </tr>
                <tr class="admin">
                    <td colspan="4"><%=getTran("Web.Occup","medwan.healthrecord.diagnose",sWebLanguage)%></td>
                </tr>
                <tr>
                    <td class="admin2" width="25%"><input <%=setRightClick("ITEM_TYPE_ENDOCRINO_DIAGNOSIS_NIDDM")%> type="checkbox" id="mcee-c5" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ENDOCRINO_DIAGNOSIS_NIDDM" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ENDOCRINO_DIAGNOSIS_NIDDM;value=medwan.common.true" property="value" outputString="checked"/> value="medwan.common.true"/><%=getLabel("Web.Occup","medwan.healthrecord.endocrino.niddm",sWebLanguage,"mcee-c5")%></td>
                    <td class="admin2" width="25%"><input <%=setRightClick("ITEM_TYPE_ENDOCRINO_DIAGNOSIS_IDDM")%> type="checkbox" id="mcee-c6" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ENDOCRINO_DIAGNOSIS_IDDM" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ENDOCRINO_DIAGNOSIS_IDDM;value=medwan.common.true" property="value" outputString="checked"/> value="medwan.common.true"/><%=getLabel("Web.Occup","medwan.healthrecord.endocrino.iddm",sWebLanguage,"mcee-c6")%></td>
                    <td class="admin2" width="25%"><input <%=setRightClick("ITEM_TYPE_ENDOCRINO_DIAGNOSIS_GOITRE")%> type="checkbox" id="mcee-c7" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ENDOCRINO_DIAGNOSIS_GOITRE" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ENDOCRINO_DIAGNOSIS_GOITRE;value=medwan.common.true" property="value" outputString="checked"/> value="medwan.common.true"/><%=getLabel("Web.Occup","medwan.healthrecord.endocrino.goitre",sWebLanguage,"mcee-c7")%></td>
                    <td class="admin2" width="25%"><input <%=setRightClick("ITEM_TYPE_ENDOCRINO_DIAGNOSIS_HYPOTHYROIDIA")%> type="checkbox" id="mcee-c8" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ENDOCRINO_DIAGNOSIS_HYPOTHYROIDIA" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ENDOCRINO_DIAGNOSIS_HYPOTHYROIDIA;value=medwan.common.true" property="value" outputString="checked"/> value="medwan.common.true"/><%=getLabel("Web.Occup","medwan.healthrecord.endocrino.hypothyroidia",sWebLanguage,"mcee-c8")%></td>
                </tr>
                <tr>
                    <td class="admin2"><input <%=setRightClick("ITEM_TYPE_ENDOCRINO_DIAGNOSIS_HYPERTHYROIDIA")%>  type="checkbox" id="mcee-c9" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ENDOCRINO_DIAGNOSIS_HYPERTHYROIDIA" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ENDOCRINO_DIAGNOSIS_HYPERTHYROIDIA;value=medwan.common.true" property="value" outputString="checked"/> value="medwan.common.true"/><%=getLabel("Web.Occup","medwan.healthrecord.endocrino.hyperthyroidia",sWebLanguage,"mcee-c9")%></td>
                    <td class="admin2"><input <%=setRightClick("ITEM_TYPE_ENDOCRINO_DIAGNOSIS_HASHIMOTO")%> type="checkbox" id="mcee-c10" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ENDOCRINO_DIAGNOSIS_HASHIMOTO" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ENDOCRINO_DIAGNOSIS_HASHIMOTO;value=medwan.common.true" property="value" outputString="checked"/> value="medwan.common.true"/><%=getLabel("Web.Occup","medwan.healthrecord.endocrino.hashimoto",sWebLanguage,"mcee-c10")%></td>
                    <td class="admin2"><input <%=setRightClick("ITEM_TYPE_ENDOCRINO_DIAGNOSIS_DE_QUERVAIN")%> type="checkbox" id="mcee-c11" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ENDOCRINO_DIAGNOSIS_DE_QUERVAIN" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ENDOCRINO_DIAGNOSIS_DE_QUERVAIN;value=medwan.common.true" property="value" outputString="checked"/> value="medwan.common.true"/><%=getLabel("Web.Occup","medwan.healthrecord.endocrino.de-quervain",sWebLanguage,"mcee-c11")%></td>
                    <td class="admin2"><input <%=setRightClick("ITEM_TYPE_ENDOCRINO_DIAGNOSIS_NODULAR_THYROID_SUFFERING")%> type="checkbox" id="mcee-c12" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ENDOCRINO_DIAGNOSIS_NODULAR_THYROID_SUFFERING" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ENDOCRINO_DIAGNOSIS_NODULAR_THYROID_SUFFERING;value=medwan.common.true" property="value" outputString="checked"/> value="medwan.common.true"/><%=getLabel("Web.Occup","medwan.healthrecord.endocrino.nodular-thyroid-suffering",sWebLanguage,"mcee-c12")%></td>
                </tr>
                <tr>
                    <td class="admin2"><input <%=setRightClick("ITEM_TYPE_ENDOCRINO_DIAGNOSIS_HYPOPHYSIS")%> type="checkbox" id="mcee-c13" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ENDOCRINO_DIAGNOSIS_HYPOPHYSIS" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ENDOCRINO_DIAGNOSIS_HYPOPHYSIS;value=medwan.common.true" property="value" outputString="checked"/> value="medwan.common.true"/><%=getLabel("Web.Occup","medwan.healthrecord.endocrino.hypophysis",sWebLanguage,"mcee-c13")%></td>
                    <td class="admin2"><input <%=setRightClick("ITEM_TYPE_ENDOCRINO_DIAGNOSIS_ADENOTHYROID_GLANDS")%> type="checkbox" id="mcee-c14" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ENDOCRINO_DIAGNOSIS_ADENOTHYROID_GLANDS" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ENDOCRINO_DIAGNOSIS_ADENOTHYROID_GLANDS;value=medwan.common.true" property="value" outputString="checked"/> value="medwan.common.true"/><%=getLabel("Web.Occup","medwan.healthrecord.endocrino.adenothyroid-glands",sWebLanguage,"mcee-c14")%></td>
                    <td class="admin2"><input <%=setRightClick("ITEM_TYPE_ENDOCRINO_DIAGNOSIS_ADENORENAL_INSUFFICIENCY")%> type="checkbox" id="mcee-c15" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ENDOCRINO_DIAGNOSIS_ADENORENAL_INSUFFICIENCY" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ENDOCRINO_DIAGNOSIS_ADENORENAL_INSUFFICIENCY;value=medwan.common.true" property="value" outputString="checked"/> value="medwan.common.true"/><%=getLabel("Web.Occup","medwan.healthrecord.endocrino.adenorenal-insufficiency",sWebLanguage,"mcee-c15")%></td>
                    <td class="admin2"><input <%=setRightClick("ITEM_TYPE_ENDOCRINO_DIAGNOSIS_GYNECOMASTIA")%> type="checkbox" id="mcee-c16" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ENDOCRINO_DIAGNOSIS_GYNECOMASTIA" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ENDOCRINO_DIAGNOSIS_GYNECOMASTIA;value=medwan.common.true" property="value" outputString="checked"/> value="medwan.common.true"/><%=getLabel("Web.Occup","medwan.healthrecord.endocrino.gynecomastia",sWebLanguage,"mcee-c16")%></td>
                </tr>
                <tr>
                    <td class="admin2"><input <%=setRightClick("ITEM_TYPE_ENDOCRINO_DIAGNOSIS_HYPERCHOLESTEROLAEMIA")%> type="checkbox" id="mcee-c17" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ENDOCRINO_DIAGNOSIS_HYPERCHOLESTEROLAEMIA" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ENDOCRINO_DIAGNOSIS_HYPERCHOLESTEROLAEMIA;value=medwan.common.true" property="value" outputString="checked"/> value="medwan.common.true"/><%=getLabel("Web.Occup","medwan.healthrecord.endocrino.hypercholesterolemia",sWebLanguage,"mcee-c17")%></td>
                    <td class="admin2"><input <%=setRightClick("ITEM_TYPE_ENDOCRINO_DIAGNOSIS_HYPERTRIGLYCERIDAEMIA")%> type="checkbox" id="mcee-c18" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ENDOCRINO_DIAGNOSIS_HYPERTRIGLYCERIDAEMIA" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ENDOCRINO_DIAGNOSIS_HYPERTRIGLYCERIDAEMIA;value=medwan.common.true" property="value" outputString="checked"/> value="medwan.common.true"/><%=getLabel("Web.Occup","medwan.healthrecord.endocrino.hypertriglyceridemia",sWebLanguage,"mcee-c18")%></td>
                    <td class="admin2" colspan="2"><input <%=setRightClick("ITEM_TYPE_ENDOCRINO_DIAGNOSIS_GOUT")%> type="checkbox" id="mcee-c19" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ENDOCRINO_DIAGNOSIS_GOUT" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ENDOCRINO_DIAGNOSIS_GOUT;value=medwan.common.true" property="value" outputString="checked"/> value="medwan.common.true"/><%=getLabel("Web.Occup","medwan.healthrecord.endocrino.gout",sWebLanguage,"mcee-c19")%></td>
                </tr>
                <tr>
                    <td class="admin"><%=getTran("Web.Occup","medwan.common.remark",sWebLanguage)%></td>
                    <td class="admin2" colspan="3">
                        <textarea onKeyup="resizeTextarea(this,10);limitChars(this,255);" <%=setRightClick("ITEM_TYPE_ENDOCRINO_DIAGNOSIS_OTHER")%> class="text" rows="2" cols="80" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ENDOCRINO_DIAGNOSIS_OTHER" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ENDOCRINO_DIAGNOSIS_OTHER" property="value"/></textarea>
                    </td>
                </tr>
            </table>
        </td>
    </tr>
</table>

<%-- BUTTONS --%>
<%=ScreenHelper.alignButtonsStart()%>
    <INPUT class="button" type="button" name="saveButton" onClick="doSubmit();" value="<%=getTran("Web.Occup","medwan.common.record",sWebLanguage)%>">
    <INPUT class="button" type="button" value="<%=getTran("Web","Back",sWebLanguage)%>" onclick="if(checkSaveButton('<%=sCONTEXTPATH%>','<%=getTran("Web.Occup","medwan.common.buttonquestion",sWebLanguage)%>')){window.location.href='<c:url value='/healthrecord/editTransaction.do'/>?be.mxs.healthrecord.createTransaction.transactionType=<bean:write name="transaction" scope="page" property="transactionType"/>&be.mxs.healthrecord.transaction_id=currentTransaction&ts=<%=getTs()%>'}">
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

  document.getElementsByName('endocrino-ras')[0].onclick();
</script>

</form>
<%=writeJSButtons("transactionForm", "document.getElementsByName('save')[0]")%>