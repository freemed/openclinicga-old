<%@page import="java.util.GregorianCalendar"%>
<%@include file="/includes/validateUser.jsp"%>
<%@page errorPage="/includes/error.jsp"%>

<form name="transactionForm" method="POST" action='<c:url value="/healthrecord/updateTransaction.do"/>?ts=<%=getTs()%>' onclick="setSaveButton();" onkeyup="setSaveButton();">
    <bean:define id="transaction" name="be.mxs.webapp.wl.session.SessionContainerFactory.WO_SESSION_CONTAINER" property="currentTransactionVO"/>

    <input type="hidden" name="subClass" value="GENERAL"/>
    <input id="transactionId" type="hidden" name="currentTransactionVO.<TransactionVO[hashCode=<bean:write name="transaction" scope="page" property="transactionId"/>]>.transactionId" value="<bean:write name="transaction" scope="page" property="transactionId"/>"/>
    <input id="transactionType" type="hidden" name="currentTransactionVO.<TransactionVO[hashCode=<bean:write name="transaction" scope="page" property="transactionId"/>]>.transactionType" value="<bean:write name="transaction" scope="page" property="transactionType"/>"/>
    <input id="serverId" type="hidden" name="currentTransactionVO.<TransactionVO[hashCode=<bean:write name="transaction" scope="page" property="transactionId"/>]>.serverId" value="<bean:write name="transaction" scope="page" property="serverId"/>"/>
    <input type="hidden" readonly name="be.mxs.healthrecord.updateTransaction.actionForwardKey" value="/healthrecord/editTransaction.do?be.mxs.healthrecord.createTransaction.transactionType=<bean:write name="transaction" scope="page" property="transactionType"/>&be.mxs.healthrecord.transaction_id=currentTransaction&ts=<%=getTs()%>"/>
    <input type="hidden" readonly name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_GENERAL_RAS" property="itemId"/>]>.value" value="medwan.common.false"/>

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

  function testbutton(item){
    alert(window.event.button);
  }
</script>

<table width="100%" class="list" cellspacing="0">
    <tr class="admin">
        <td><%=getTran("Web.Occup","medwan.common.general",sWebLanguage)%></td>
        <td align="right" width="20%"><%=getLabel("Web.Occup","medwan.common.nothing-to-mention",sWebLanguage,"mcegen-c1")%><input name="general-ras" type="checkbox" id="mcegen-c1" value="medwan.common.true" onclick="if (this.checked == true) {hide('general-details');setTrue('<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_GENERAL_RAS" property="itemId"/>'); } else {show('general-details');setFalse('<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_GENERAL_RAS" property="itemId"/>'); }"></td>
        <td align="right" width ="1%"><a href="#topp" class="topbutton">&nbsp;</a></td>
    </tr>
    <tr id="general-details" style="display:none" width="100%">
        <td colspan="3" width="100%">
            <table width="100%" cellspacing="1">
                <tr class="admin">
                    <td colspan="3"><%=getTran("Web.Occup","medwan.healthrecord.anamnese",sWebLanguage)%></td>
                </tr>
                <tr>
                    <td class="admin"><%=getTran("Web.Occup","medwan.healthrecord.anamnese.general.style-de-vie",sWebLanguage)%></td>
                    <td class="admin2" colspan="2"><input <%=setRightClick("[GENERAL.ANAMNESE]ITEM_TYPE_LIFE_STYLE")%> type="text" class="text" size="97" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.[GENERAL.ANAMNESE]ITEM_TYPE_LIFE_STYLE" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.[GENERAL.ANAMNESE]ITEM_TYPE_LIFE_STYLE" property="value"/>" onblur="validateText(this);limitLength(this);"></td>
                </tr>
                <tr>
                    <td class="admin"><%=getTran("Web.Occup","medwan.healthrecord.anamnese.general.medicaments",sWebLanguage)%></td>
                    <td class="admin2" colspan="2">
                        <textarea onKeyup="resizeTextarea(this,10);limitChars(this,255);" <%=setRightClick("[GENERAL.ANAMNESE]ITEM_TYPE_MEDICIATIONS")%> class="text" rows="2" cols="90" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.[GENERAL.ANAMNESE]ITEM_TYPE_MEDICIATIONS" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.[GENERAL.ANAMNESE]ITEM_TYPE_MEDICIATIONS" property="value"/></textarea>
                    </td>
                </tr>
                <tr>
                    <td class="admin"><%=getTran("Web.Occup","medwan.healthrecord.anamnese.general.drugs-usage",sWebLanguage)%></td>
                    <td class="admin2" colspan="2"><input <%=setRightClick("[GENERAL.ANAMNESE]ITEM_TYPE_DRUGS_USAGE")%> type="text" class="text" size="97" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.[GENERAL.ANAMNESE]ITEM_TYPE_DRUGS_USAGE" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.[GENERAL.ANAMNESE]ITEM_TYPE_DRUGS_USAGE" property="value"/>" onblur="validateText(this);limitLength(this);"></td>
                </tr>
                <tr>
                    <td class="admin"><%=getTran("Web.Occup","medwan.healthrecord.anamnese.general.etat-familial-et-social",sWebLanguage)%></td>
                    <td class="admin2" colspan="2"><input <%=setRightClick("[GENERAL.ANAMNESE]ITEM_TYPE_SOCIAL_AND_FAMILIAL_STATUS")%> type="text" class="text" size="97" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.[GENERAL.ANAMNESE]ITEM_TYPE_SOCIAL_AND_FAMILIAL_STATUS" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.[GENERAL.ANAMNESE]ITEM_TYPE_SOCIAL_AND_FAMILIAL_STATUS" property="value"/>" onblur="validateText(this);limitLength(this);"></td>
                </tr>
                <tr>
                    <td class="admin"><%=getTran("Web.Occup","medwan.healthrecord.anamnese.general.sports",sWebLanguage)%></td>
                    <td class="admin2" colspan="2"><input <%=setRightClick("[GENERAL.ANAMNESE]ITEM_TYPE_SPORTS")%> type="text" class="text" size="97" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.[GENERAL.ANAMNESE]ITEM_TYPE_SPORTS" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.[GENERAL.ANAMNESE]ITEM_TYPE_SPORTS" property="value"/>" onblur="validateText(this);limitLength(this);"></td>
                </tr>
                <tr>
                    <td class="admin"><%=getTran("Web.Occup","medwan.common.remark",sWebLanguage)%></td>
                    <td class="admin2" colspan="2">
                        <textarea onKeyup="resizeTextarea(this,10);limitChars(this,255);" <%=setRightClick("[GENERAL.ANAMNESE]ITEM_TYPE_REMARK")%> class="text" rows="2" cols="90" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.[GENERAL.ANAMNESE]ITEM_TYPE_REMARK" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.[GENERAL.ANAMNESE]ITEM_TYPE_REMARK" property="value"/></textarea>
                    </td>
                </tr>
                <tr class="admin">
                    <td colspan="3"><%=getTran("Web.Occup","medwan.healthrecord.clinical-examination",sWebLanguage)%></td>
                </tr>
                <tr>
                    <td width="20%" class="admin"><%=getTran("Web.Occup","medwan.healthrecord.clinical-examination.conscience",sWebLanguage)%></td>
                    <td width="20%" class="admin2">
                        <input <%=setRightClick("[GENERAL.CLINICAL_EXAMNIATION]ITEM_TYPE_CONSCIENCE")%> type="radio" id="mcegen-r1" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.[GENERAL.CLINICAL_EXAMNIATION]ITEM_TYPE_CONSCIENCE" property="itemId"/>]>.value" value="medwan.common.normal" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.[GENERAL.CLINICAL_EXAMNIATION]ITEM_TYPE_CONSCIENCE;value=medwan.common.normal" property="value" outputString="checked"/>><%=getLabel("Web.Occup","medwan.common.normal",sWebLanguage,"mcegen-r1")%>
                    </td>
                    <td width="*" class="admin2">
                        <input <%=setRightClick("[GENERAL.CLINICAL_EXAMNIATION]ITEM_TYPE_CONSCIENCE")%> type="radio" id="mcegen-r2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.[GENERAL.CLINICAL_EXAMNIATION]ITEM_TYPE_CONSCIENCE" property="itemId"/>]>.value" value="medwan.common.anormal" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.[GENERAL.CLINICAL_EXAMNIATION]ITEM_TYPE_CONSCIENCE;value=medwan.common.anormal" property="value" outputString="checked"/>><%=getLabel("Web.Occup","medwan.common.anormal",sWebLanguage,"mcegen-r2")%>
                     </td>
                </tr>
                <tr>
                    <td class="admin"><%=getTran("Web.Occup","medwan.healthrecord.clinical-examination.tatouage",sWebLanguage)%></td>
                    <td class="admin2">
                        <input <%=setRightClick("[GENERAL.CLINICAL_EXAMNIATION]ITEM_TYPE_TATOUAGE")%> type="radio" onDblClick="uncheckRadio(this);" id="mcegen-r3" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.[GENERAL.CLINICAL_EXAMNIATION]ITEM_TYPE_TATOUAGE" property="itemId"/>]>.value" value="medwan.common.ok" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.[GENERAL.CLINICAL_EXAMNIATION]ITEM_TYPE_TATOUAGE;value=medwan.common.ok" property="value" outputString="checked"/>><%=getLabel("Web.Occup","medwan.common.ok",sWebLanguage,"mcegen-r3")%>
                    </td>
                    <td class="admin2">
                        <input <%=setRightClick("[GENERAL.CLINICAL_EXAMNIATION]ITEM_TYPE_TATOUAGE")%> type="radio" onDblClick="uncheckRadio(this);" id="mcegen-r4" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.[GENERAL.CLINICAL_EXAMNIATION]ITEM_TYPE_TATOUAGE" property="itemId"/>]>.value" value="medwan.common.nok" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.[GENERAL.CLINICAL_EXAMNIATION]ITEM_TYPE_TATOUAGE;value=medwan.common.nok" property="value" outputString="checked"/>><%=getLabel("Web.Occup","medwan.common.nok",sWebLanguage,"mcegen-r4")%>
                    </td>
                </tr>
                <tr>
                    <td class="admin"><%=getTran("Web.Occup","medwan.healthrecord.clinical-examination.piercing",sWebLanguage)%></td>
                    <td class="admin2">
                        <input <%=setRightClick("[GENERAL.CLINICAL_EXAMNIATION]ITEM_TYPE_PIERCING")%> type="radio" onDblClick="uncheckRadio(this);" id="mcegen-r5" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.[GENERAL.CLINICAL_EXAMNIATION]ITEM_TYPE_PIERCING" property="itemId"/>]>.value" value="medwan.common.yes" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.[GENERAL.CLINICAL_EXAMNIATION]ITEM_TYPE_PIERCING;value=medwan.common.yes" property="value" outputString="checked"/>><%=getLabel("Web.Occup","medwan.common.yes",sWebLanguage,"mcegen-r5")%>
                    </td>
                    <td class="admin2">
                        <input <%=setRightClick("[GENERAL.CLINICAL_EXAMNIATION]ITEM_TYPE_PIERCING")%> type="radio" onDblClick="uncheckRadio(this);" id="mcegen-r6" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.[GENERAL.CLINICAL_EXAMNIATION]ITEM_TYPE_PIERCING" property="itemId"/>]>.value" value="medwan.common.no" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.[GENERAL.CLINICAL_EXAMNIATION]ITEM_TYPE_PIERCING;value=medwan.common.no" property="value" outputString="checked"/>><%=getLabel("Web.Occup","medwan.common.no",sWebLanguage,"mcegen-r6")%>
                    </td>
                </tr>

                <tr class="admin">
                    <td colspan="3"><%=getTran("Web.Occup","medwan.healthrecord.diagnose",sWebLanguage)%></td>
                </tr>
                <tr>
                    <td class="admin2">
                        <input <%=setRightClick("[GENERAL.DIAGNOSE]ITEM_TYPE_ACCEPTABLE_TATOO")%> type="radio" onDblClick="uncheckRadio(this);" id="mcegen-r7" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.[GENERAL.DIAGNOSE]ITEM_TYPE_ACCEPTABLE_TATOO" property="itemId"/>]>.value" value="medwan.common.true" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.[GENERAL.DIAGNOSE]ITEM_TYPE_ACCEPTABLE_TATOO;value=medwan.common.true" property="value" outputString="checked"/>><%=getLabel("Web.Occup","medwan.healthrecord.diagnose.acceptable-tatoo",sWebLanguage,"mcegen-r7")%>
                    </td>
                    <td class="admin2" colspan="2">
                        <input <%=setRightClick("[GENERAL.DIAGNOSE]ITEM_TYPE_ACCEPTABLE_TATOO")%> type="radio" onDblClick="uncheckRadio(this);" id="mcegen-r8" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.[GENERAL.DIAGNOSE]ITEM_TYPE_ACCEPTABLE_TATOO" property="itemId"/>]>.value" value="medwan.common.false" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.[GENERAL.DIAGNOSE]ITEM_TYPE_ACCEPTABLE_TATOO;value=medwan.common.false" property="value" outputString="checked"/>><%=getLabel("Web.Occup","medwan.healthrecord.diagnose.inacceptable-tatoo",sWebLanguage,"mcegen-r8")%>
                    </td>
                </tr>
                <tr>
                    <td class="admin2">
                        <input <%=setRightClick("[GENERAL.DIAGNOSE]ITEM_TYPE_COOPER_TEST_INSUFFICIENT_RESULT")%> type="checkbox" id="mcegen-c2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.[GENERAL.DIAGNOSE]ITEM_TYPE_COOPER_TEST_INSUFFICIENT_RESULT" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.[GENERAL.DIAGNOSE]ITEM_TYPE_COOPER_TEST_INSUFFICIENT_RESULT;value=medwan.common.true" property="value" outputString="checked"/> value="medwan.common.true"><%=getLabel("Web.Occup","medwan.healthrecord.diagnose.cooper-test-insufficient",sWebLanguage,"mcegen-c2")%>
                    </td>
                    <td class="admin2">
                        <input <%=setRightClick("[GENERAL.DIAGNOSE]ITEM_TYPE_SHUTTLE_RUN_INSUFFICIENT_RESULT")%> type="checkbox" id="mcegen-c3" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.[GENERAL.DIAGNOSE]ITEM_TYPE_SHUTTLE_RUN_INSUFFICIENT_RESULT" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.[GENERAL.DIAGNOSE]ITEM_TYPE_SHUTTLE_RUN_INSUFFICIENT_RESULT;value=medwan.common.true" property="value" outputString="checked"/> value="medwan.common.true"><%=getLabel("Web.Occup","medwan.healthrecord.diagnose.shuttle-run-insufficient",sWebLanguage,"mcegen-c3")%>
                    </td>
                    <td class="admin2">
                        <input <%=setRightClick("[GENERAL.DIAGNOSE]ITEM_TYPE_BALANCE_TEST_INSUFFICIENT_RESULT")%> type="checkbox" id="mcegen-c4" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.[GENERAL.DIAGNOSE]ITEM_TYPE_BALANCE_TEST_INSUFFICIENT_RESULT" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.[GENERAL.DIAGNOSE]ITEM_TYPE_BALANCE_TEST_INSUFFICIENT_RESULT;value=medwan.common.true" property="value" outputString="checked"/> value="medwan.common.true"><%=getLabel("Web.Occup","medwan.healthrecord.diagnose.balance-test-insufficient",sWebLanguage,"mcegen-c4")%>
                    </td>
                </tr>
                <tr>
                    <td class="admin2">
                        <input <%=setRightClick("[GENERAL.DIAGNOSE]ITEM_TYPE_POTENTIALITY_TEST_UNDONE")%> type="checkbox" id="mcegen-c5" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.[GENERAL.DIAGNOSE]ITEM_TYPE_POTENTIALITY_TEST_UNDONE" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.[GENERAL.DIAGNOSE]ITEM_TYPE_POTENTIALITY_TEST_UNDONE;value=medwan.common.true" property="value" outputString="checked"/> value="medwan.common.true"><%=getLabel("Web.Occup","medwan.healthrecord.diagnose.potentiality-test-undone",sWebLanguage,"mcegen-c5")%>
                    </td>
                    <td class="admin2" colspan="2">
                        <input <%=setRightClick("[GENERAL.DIAGNOSE]ITEM_TYPE_USUAL_CANABIS_CONSOMMATION")%> type="checkbox" id="mcegen-c6" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.[GENERAL.DIAGNOSE]ITEM_TYPE_USUAL_CANABIS_CONSOMMATION" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.[GENERAL.DIAGNOSE]ITEM_TYPE_USUAL_CANABIS_CONSOMMATION;value=medwan.common.true" property="value" outputString="checked"/> value="medwan.common.true"><%=getLabel("Web.Occup","medwan.healthrecord.diagnose.usual-canabis-consommation",sWebLanguage,"mcegen-c6")%>
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

  document.getElementsByName('general-ras')[0].onclick();
</script>
</form>
<%=writeJSButtons("transactionForm", "document.getElementsByName('save')[0]")%>