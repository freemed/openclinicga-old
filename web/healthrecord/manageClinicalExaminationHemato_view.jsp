<%@include file="/includes/validateUser.jsp"%>
<%@page errorPage="/includes/error.jsp"%>
<%
    
%>
<form name="transactionForm" method="POST" action='<c:url value="/healthrecord/updateTransaction.do"/>?ts=<%=getTs()%>' onclick="setSaveButton();" onkeyup="setSaveButton();">
    <bean:define id="transaction" name="be.mxs.webapp.wl.session.SessionContainerFactory.WO_SESSION_CONTAINER" property="currentTransactionVO"/>

    <input type="hidden" name="subClass" value="HEMATO"/>
    <input id="transactionId" type="hidden" name="currentTransactionVO.<TransactionVO[hashCode=<bean:write name="transaction" scope="page" property="transactionId"/>]>.transactionId" value="<bean:write name="transaction" scope="page" property="transactionId"/>"/>
    <input id="transactionType" type="hidden" name="currentTransactionVO.<TransactionVO[hashCode=<bean:write name="transaction" scope="page" property="transactionId"/>]>.transactionType" value="<bean:write name="transaction" scope="page" property="transactionType"/>"/>
    <input id="serverId" type="hidden" name="currentTransactionVO.<TransactionVO[hashCode=<bean:write name="transaction" scope="page" property="transactionId"/>]>.serverId" value="<bean:write name="transaction" scope="page" property="serverId"/>"/>
    <input type="hidden" readonly name="be.mxs.healthrecord.updateTransaction.actionForwardKey" value="/healthrecord/editTransaction.do?be.mxs.healthrecord.createTransaction.transactionType=<bean:write name="transaction" scope="page" property="transactionType"/>&be.mxs.healthrecord.transaction_id=currentTransaction&ts=<%=getTs()%>"/>
    <input type="hidden" readonly name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_HEMATO_RAS" property="itemId"/>]>.value" value="medwan.common.false"/>

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
        <td><%=getTran("Web.Occup","medwan.healthrecord.anamnese.hematologique",sWebLanguage)%></td>
        <td align="right" width="20%">
            <%=getLabel("Web.Occup","medwan.common.nothing-to-mention",sWebLanguage,"mceh-c1")%>&nbsp;<input name="hemato-ras" type="checkbox" id="mceh-c1" value="medwan.common.true" onclick="if (this.checked == true) {hide('HEMATO-details');setTrue('<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_HEMATO_RAS" property="itemId"/>'); } else {show('HEMATO-details');setFalse('<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_HEMATO_RAS" property="itemId"/>'); }">
        </td>
        <td align="right" width ="1%"><a href="#top" class="topbutton">&nbsp;</a></td>
    </tr>
    <tr id="HEMATO-details" style="display:none" width="100%">
        <td colspan="4" width="100%">
            <table width="100%" cellspacing="1">
                <tr class="admin">
                    <td colspan="4"><%=getTran("Web.Occup","medwan.healthrecord.anamnese",sWebLanguage)%></td>
                </tr>
                <tr>
                    <td class="admin2" colspan="4"><input <%=setRightClick("ITEM_TYPE_HEMATO_ANAMNESIS_FEVER_ATTACKS")%> type="checkbox" id="mceh-c2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_HEMATO_ANAMNESIS_FEVER_ATTACKS" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_HEMATO_ANAMNESIS_FEVER_ATTACKS;value=medwan.common.true" property="value" outputString="checked"/> value="medwan.common.true"/><%=getLabel("Web.Occup","medwan.healthrecord.hemato.fever-attacks",sWebLanguage,"mceh-c2")%></td>
                </tr>
                <tr class="admin">
                    <td colspan="4"><%=getTran("Web.Occup","medwan.healthrecord.clinical-examination",sWebLanguage)%></td>
                </tr>
                <tr class="admin">
                    <td colspan="4">&nbsp; - <%=getTran("Web.Occup","medwan.healthrecord.hemato.inspection",sWebLanguage)%></td>
                </tr>
                <tr>
                    <td class="admin2"><input <%=setRightClick("ITEM_TYPE_HEMATO_CLINICAL_EXAMINATION_PETECCHIAE")%> type="checkbox" id="mceh-c3" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_HEMATO_CLINICAL_EXAMINATION_PETECCHIAE" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_HEMATO_CLINICAL_EXAMINATION_PETECCHIAE;value=medwan.common.true" property="value" outputString="checked"/> value="medwan.common.true"/><%=getLabel("Web.Occup","medwan.healthrecord.hemato.petechiae",sWebLanguage,"mceh-c3")%></td>
                    <td class="admin2"><input <%=setRightClick("ITEM_TYPE_HEMATO_CLINICAL_EXAMINATION_PALE_MUCOSA")%> type="checkbox" id="mceh-c4" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_HEMATO_CLINICAL_EXAMINATION_PALE_MUCOSA" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_HEMATO_CLINICAL_EXAMINATION_PALE_MUCOSA;value=medwan.common.true" property="value" outputString="checked"/> value="medwan.common.true"/><%=getLabel("Web.Occup","medwan.healthrecord.hemato.pale-mucosa",sWebLanguage,"mceh-c4")%></td>
                    <td class="admin2" colspan="2"><input <%=setRightClick("ITEM_TYPE_HEMATO_CLINICAL_EXAMINATION_GRAY_SKIN")%> type="checkbox" id="mceh-c5" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_HEMATO_CLINICAL_EXAMINATION_GRAY_SKIN" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_HEMATO_CLINICAL_EXAMINATION_GRAY_SKIN;value=medwan.common.true" property="value" outputString="checked"/> value="medwan.common.true"/><%=getLabel("Web.Occup","medwan.healthrecord.hemato.gray-skin",sWebLanguage,"mceh-c5")%></td>
                </tr>
                <tr class="admin">
                    <td colspan="4">&nbsp; - <%=getTran("Web.Occup","medwan.healthrecord.hemato.palpation",sWebLanguage)%></td>
                </tr>
                <tr>
                    <td class="admin2" colspan="4"><input <%=setRightClick("ITEM_TYPE_HEMATO_CLINICAL_EXAMINATION_SPLEEN_ENLARGED")%> type="checkbox" id="mceh-c6" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_HEMATO_CLINICAL_EXAMINATION_SPLEEN_ENLARGED" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_HEMATO_CLINICAL_EXAMINATION_SPLEEN_ENLARGED;value=medwan.common.true" property="value" outputString="checked"/> value="medwan.common.true"/><%=getLabel("Web.Occup","medwan.healthrecord.hemato.spleen-enlargement",sWebLanguage,"mceh-c6")%></td>
                </tr>
                <tr class="admin">
                    <td colspan="4"><%=getTran("Web.Occup","medwan.healthrecord.diagnose",sWebLanguage)%></td>
                </tr>
                <tr class="admin">
                    <td colspan="4">&nbsp; - <%=getTran("Web.Occup","medwan.common.tumors",sWebLanguage)%></td>
                </tr>
                <tr>
                    <td class="admin2" width="25%"><input <%=setRightClick("ITEM_TYPE_HEMATO_DIAGNOSIS_TUMOR_LEUKEMIA")%> type="checkbox" id="mceh-c7" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_HEMATO_DIAGNOSIS_TUMOR_LEUKEMIA" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_HEMATO_DIAGNOSIS_TUMOR_LEUKEMIA;value=medwan.common.true" property="value" outputString="checked"/> value="medwan.common.true"/><%=getLabel("Web.Occup","medwan.common.tumors.leukemia",sWebLanguage,"mceh-c7")%></td>
                    <td class="admin2" width="25%"><input <%=setRightClick("ITEM_TYPE_HEMATO_DIAGNOSIS_TUMOR_HODGKIN")%> type="checkbox" id="mceh-c8" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_HEMATO_DIAGNOSIS_TUMOR_HODGKIN" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_HEMATO_DIAGNOSIS_TUMOR_HODGKIN;value=medwan.common.true" property="value" outputString="checked"/> value="medwan.common.true"/><%=getLabel("Web.Occup","medwan.common.tumors.hodgkin",sWebLanguage,"mceh-c8")%></td>
                    <td class="admin2" width="25%"><input <%=setRightClick("ITEM_TYPE_HEMATO_DIAGNOSIS_TUMOR_NON_HODGKIN")%> type="checkbox" id="mceh-c9" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_HEMATO_DIAGNOSIS_TUMOR_NON_HODGKIN" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_HEMATO_DIAGNOSIS_TUMOR_NON_HODGKIN;value=medwan.common.true" property="value" outputString="checked"/> value="medwan.common.true"/><%=getLabel("Web.Occup","medwan.common.tumors.non-hodgkin",sWebLanguage,"mceh-c9")%></td>
                    <td class="admin2" width="25%"><input <%=setRightClick("ITEM_TYPE_HEMATO_DIAGNOSIS_TUMOR_KAHLER")%> type="checkbox" id="mceh-c10" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_HEMATO_DIAGNOSIS_TUMOR_KAHLER" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_HEMATO_DIAGNOSIS_TUMOR_KAHLER;value=medwan.common.true" property="value" outputString="checked"/> value="medwan.common.true"/><%=getLabel("Web.Occup","medwan.common.tumors.kahler",sWebLanguage,"mceh-c10")%></td>
                </tr>
                <tr>
                    <td class="admin2"><input <%=setRightClick("ITEM_TYPE_HEMATO_DIAGNOSIS_TUMOR_BENIGN")%> type="checkbox" id="mceh-c11" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_HEMATO_DIAGNOSIS_TUMOR_BENIGN" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_HEMATO_DIAGNOSIS_TUMOR_BENIGN;value=medwan.common.true" property="value" outputString="checked"/> value="medwan.common.true"/><%=getLabel("Web.Occup","medwan.healthrecord.cardial.tumeur.benin",sWebLanguage,"mceh-c11")%></td>
                    <td class="admin2" colspan="3"><input <%=setRightClick("ITEM_TYPE_HEMATO_DIAGNOSIS_TUMOR_MALIGN")%> type="checkbox" id="mceh-c12" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_HEMATO_DIAGNOSIS_TUMOR_MALIGN" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_HEMATO_DIAGNOSIS_TUMOR_MALIGN;value=medwan.common.true" property="value" outputString="checked"/> value="medwan.common.true"/><%=getLabel("Web.Occup","medwan.healthrecord.cardial.tumeur.malin",sWebLanguage,"mceh-c12")%></td>
                </tr>
                <tr class="admin">
                    <td colspan="4">&nbsp; - <%=getTran("Web.Occup","medwan.common.other",sWebLanguage)%></td>
                </tr>
                <tr>
                    <td class="admin2"><input <%=setRightClick("ITEM_TYPE_HEMATO_DIAGNOSIS_COAGULATION_DISORDERS")%> type="checkbox" id="mceh-c13" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_HEMATO_DIAGNOSIS_COAGULATION_DISORDERS" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_HEMATO_DIAGNOSIS_COAGULATION_DISORDERS;value=medwan.common.true" property="value" outputString="checked"/> value="medwan.common.true"/><%=getLabel("Web.Occup","medwan.healthrecord.hemato.coagulation-disorders",sWebLanguage,"mceh-c13")%></td>
                    <td class="admin2"><input <%=setRightClick("ITEM_TYPE_HEMATO_DIAGNOSIS_THROMBOCYTOPENIA")%> type="checkbox" id="mceh-c14" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_HEMATO_DIAGNOSIS_THROMBOCYTOPENIA" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_HEMATO_DIAGNOSIS_THROMBOCYTOPENIA;value=medwan.common.true" property="value" outputString="checked"/> value="medwan.common.true"/><%=getLabel("Web.Occup","medwan.healthrecord.hemato.thrombocytopenia",sWebLanguage,"mceh-c14")%></td>
                    <td class="admin2"><input <%=setRightClick("ITEM_TYPE_HEMATO_DIAGNOSIS_LEUCOPENIA")%> type="checkbox" id="mceh-c15" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_HEMATO_DIAGNOSIS_LEUCOPENIA" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_HEMATO_DIAGNOSIS_LEUCOPENIA;value=medwan.common.true" property="value" outputString="checked"/> value="medwan.common.true"/><%=getLabel("Web.Occup","medwan.healthrecord.hemato.leukopenia",sWebLanguage,"mceh-c15")%></td>
                    <td class="admin2"><input <%=setRightClick("ITEM_TYPE_HEMATO_DIAGNOSIS_FERRIPRIVE_ANEMIA")%> type="checkbox" id="mceh-c16" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_HEMATO_DIAGNOSIS_FERRIPRIVE_ANEMIA" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_HEMATO_DIAGNOSIS_FERRIPRIVE_ANEMIA;value=medwan.common.true" property="value" outputString="checked"/> value="medwan.common.true"/><%=getLabel("Web.Occup","medwan.healthrecord.hemato.ferriprive-anemia",sWebLanguage,"mceh-c16")%></td>
                </tr>
                <tr>
                    <td class="admin2"><input <%=setRightClick("ITEM_TYPE_HEMATO_DIAGNOSIS_OTHER_ANEMIA")%> type="checkbox" id="mceh-c17" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_HEMATO_DIAGNOSIS_OTHER_ANEMIA" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_HEMATO_DIAGNOSIS_OTHER_ANEMIA;value=medwan.common.true" property="value" outputString="checked"/> value="medwan.common.true"/><%=getLabel("Web.Occup","medwan.healthrecord.hemato.other-anemia",sWebLanguage,"mceh-c17")%></td>
                    <td class="admin2"><input <%=setRightClick("ITEM_TYPE_HEMATO_DIAGNOSIS_HEMOCHROMATOSIS")%> type="checkbox" id="mceh-c18" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_HEMATO_DIAGNOSIS_HEMOCHROMATOSIS" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_HEMATO_DIAGNOSIS_HEMOCHROMATOSIS;value=medwan.common.true" property="value" outputString="checked"/> value="medwan.common.true"/><%=getLabel("Web.Occup","medwan.healthrecord.hemato.hemochromatosis",sWebLanguage,"mceh-c18")%></td>
                    <td class="admin2"><input <%=setRightClick("ITEM_TYPE_HEMATO_DIAGNOSIS_SPLEEN_AFFECTION")%> type="checkbox" id="mceh-c19" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_HEMATO_DIAGNOSIS_SPLEEN_AFFECTION" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_HEMATO_DIAGNOSIS_SPLEEN_AFFECTION;value=medwan.common.true" property="value" outputString="checked"/> value="medwan.common.true"/><%=getLabel("Web.Occup","medwan.healthrecord.hemato.spleen-affection",sWebLanguage,"mceh-c19")%></td>
                    <td class="admin2"><input <%=setRightClick("ITEM_TYPE_HEMATO_DIAGNOSIS_MALARIA")%> type="checkbox" id="mceh-c20" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_HEMATO_DIAGNOSIS_MALARIA" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_HEMATO_DIAGNOSIS_MALARIA;value=medwan.common.true" property="value" outputString="checked"/> value="medwan.common.true"/><%=getLabel("Web.Occup","medwan.healthrecord.hemato.malaria",sWebLanguage,"mceh-c20")%></td>
                </tr>
                <tr>
                    <td class="admin2" colspan="4"><input <%=setRightClick("ITEM_TYPE_HEMATO_DIAGNOSIS_AIDS")%> type="checkbox" id="mceh-c21" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_HEMATO_DIAGNOSIS_AIDS" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_HEMATO_DIAGNOSIS_AIDS;value=medwan.common.true" property="value" outputString="checked"/> value="medwan.common.true"/><%=getLabel("Web.Occup","medwan.healthrecord.hemato.aids",sWebLanguage,"mceh-c21")%></td>
                </tr>
                <tr>
                    <td class="admin"><%=getTran("Web.Occup","medwan.common.remark",sWebLanguage)%></td>
                    <td class="admin2" colspan="3">
                        <textarea onKeyup="resizeTextarea(this,10);limitChars(this,255);" <%=setRightClick("ITEM_TYPE_HEMATO_DIAGNOSIS_OTHER")%> class="text" rows="2" cols="80" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_HEMATO_DIAGNOSIS_OTHER" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_HEMATO_DIAGNOSIS_OTHER" property="value"/></textarea>
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

  document.getElementsByName('hemato-ras')[0].onclick();
</script>

</form>
<%=writeJSButtons("transactionForm", "document.getElementsByName('save')[0]")%>