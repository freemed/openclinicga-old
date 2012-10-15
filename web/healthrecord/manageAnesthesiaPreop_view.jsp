<%@include file="/includes/validateUser.jsp"%>
<%@page errorPage="/includes/error.jsp"%>

<%=checkPermission("occup.anesthesiapreop","select",activeUser)%>

<form name="transactionForm" id="transactionForm" method="POST" action='<c:url value="/healthrecord/updateTransaction.do"/>?ts=<%=getTs()%>' onclick="setSaveButton(event);" onkeyup="setSaveButton(event);">
    <bean:define id="transaction" name="be.mxs.webapp.wl.session.SessionContainerFactory.WO_SESSION_CONTAINER" property="currentTransactionVO"/>
    <input type="hidden" id="transactionId" name="currentTransactionVO.<TransactionVO[hashCode=<bean:write name="transaction" scope="page" property="transactionId"/>]>.transactionId" value="<bean:write name="transaction" scope="page" property="transactionId"/>"/>
    <input type="hidden" id="serverId" name="currentTransactionVO.<TransactionVO[hashCode=<bean:write name="transaction" scope="page" property="transactionId"/>]>.serverId" value="<bean:write name="transaction" scope="page" property="serverId"/>"/>
    <input type="hidden" id="transactionType" name="currentTransactionVO.<TransactionVO[hashCode=<bean:write name="transaction" scope="page" property="transactionId"/>]>.transactionType" value="<bean:write name="transaction" scope="page" property="transactionType"/>"/>
    <input type="hidden" readonly name="be.mxs.healthrecord.updateTransaction.actionForwardKey" value="/main.do?Page=curative/index.jsp&ts=<%=getTs()%>"/>
    <input type="hidden" readonly name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CONTEXT_DEPARTMENT" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CONTEXT_DEPARTMENT" translate="false" property="value"/>"/>
    <input type="hidden" readonly name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CONTEXT_CONTEXT" translate="false" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CONTEXT_CONTEXT" translate="false" property="value"/>"/>

    <script>
      function submitForm(){
        document.transactionForm.save.disabled = true;
        <%
            SessionContainerWO sessionContainerWO = (SessionContainerWO)SessionContainerFactory.getInstance().getSessionContainerWO(request,SessionContainerWO.class.getName());
            out.print(takeOverTransaction(sessionContainerWO, activeUser,"document.transactionForm.submit();"));
        %>
      }
    </script>

    <%=writeHistoryFunctions(((TransactionVO)transaction).getTransactionType(),sWebLanguage)%>
    <%=contextHeader(request,sWebLanguage)%>
    <table class="list" width="100%" cellspacing="1">
        <%-- DATE --%>
        <tr>
            <td class="admin">
                <a href="javascript:openHistoryPopup();" title="<%=getTran("Web.Occup","History",sWebLanguage)%>">...</a>&nbsp;
                <%=getTran("Web.Occup","medwan.common.date",sWebLanguage)%>
            </td>
            <td class="admin2" colspan="4">
                <input type="text" class="text" size="12" maxLength="10" name="currentTransactionVO.<TransactionVO[hashCode=<bean:write name="transaction" scope="page" property="transactionId"/>]>.updateTime" value="<mxs:propertyAccessorI18N name="transaction" scope="page" property="updateTime" formatType="date" format="dd-mm-yyyy"/>" id="trandate" OnBlur='checkDate(this)'>
                <script>writeMyDate("trandate","<c:url value="/_img/icon_agenda.gif"/>","<%=getTran("Web","PutToday",sWebLanguage)%>");</script>

                <input type='text' class='text' name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ANESTHESIA_HOUR" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ANESTHESIA_HOUR" property="value"/>" onblur='checkTime(this)' size='5'>
                &nbsp;<%=getTran("web.occup","medwan.common.hour",sWebLanguage)%>
            </td>
        </tr>
        <%-- Généralités --%>
        <tr>
            <td class="admin"><%=getTran("openclinic.chuk","anesthesia.indication",sWebLanguage)%></td>
            <td class="admin2" colspan="4">
                <input <%=setRightClick("ITEM_TYPE_ANESTHESIA_INDICATION")%> type="radio" onDblClick="uncheckRadio(this);" id="sum_r1a" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ANESTHESIA_INDICATION" property="itemId"/>]>.value" value="openclinic.common.urgency" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ANESTHESIA_INDICATION;value=openclinic.common.urgency" property="value" outputString="checked"/>><%=getLabel("openclinic.chuk","openclinic.common.urgency",sWebLanguage,"sum_r1a")%>
                <input <%=setRightClick("ITEM_TYPE_ANESTHESIA_INDICATION")%> type="radio" onDblClick="uncheckRadio(this);" id="sum_r1b" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ANESTHESIA_INDICATION" property="itemId"/>]>.value" value="openclinic.common.programmed" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ANESTHESIA_INDICATION;value=openclinic.common.programmed" property="value" outputString="checked"/>><%=getLabel("openclinic.chuk","openclinic.common.programmed",sWebLanguage,"sum_r1b")%>
            </td>
        </tr>
        <tr>
            <td class="admin"><%=getTran("openclinic.chuk","intervention",sWebLanguage)%></td>
            <td class="admin2" colspan="4">
                <textarea onKeyup="resizeTextarea(this,10);limitChars(this,255);" <%=setRightClick("ITEM_TYPE_ANESTHESIA_INTERVENTION")%> class="text" cols="100" rows="2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ANESTHESIA_INTERVENTION" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ANESTHESIA_INTERVENTION" property="value"/></textarea>
            </td>
        </tr>

        <%-- Antécédents du patient --%>
        <tr class="admin">
            <td colspan="5"><%=getTran("openclinic.chuk","patient.antecedents",sWebLanguage)%></td>
        </tr>
        <tr>
            <td class="admin" width="<%=sTDAdminWidth%>"/>
            <td class="admin2" width="200"><input <%=setRightClick("ITEM_TYPE_ANESTHESIA_TOBACCO")%> type="checkbox" id="cbtobacco" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ANESTHESIA_TOBACCO" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ANESTHESIA_TOBACCO;value=medwan.common.true" property="value" outputString="checked"/> value="medwan.common.true"/><%=getLabel("openclinic.chuk","tobacco",sWebLanguage,"cbtobacco")%></td>
            <td class="admin2" width="200"><input <%=setRightClick("ITEM_TYPE_ANESTHESIA_ASTHMA")%> type="checkbox" id="cbasthma" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ANESTHESIA_ASTHMA" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ANESTHESIA_ASTHMA;value=medwan.common.true" property="value" outputString="checked"/> value="medwan.common.true"/><%=getLabel("openclinic.chuk","asthma",sWebLanguage,"cbasthma")%></td>
            <td class="admin2" width="200"><input <%=setRightClick("ITEM_TYPE_ANESTHESIA_DIABETES")%> type="checkbox" id="cbdiabetes" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ANESTHESIA_DIABETES" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ANESTHESIA_DIABETES;value=medwan.common.true" property="value" outputString="checked"/> value="medwan.common.true"/><%=getLabel("openclinic.chuk","diabetes",sWebLanguage,"cbdiabates")%></td>
            <td class="admin2"><input <%=setRightClick("ITEM_TYPE_ANESTHESIA_HEPATITIS")%> type="checkbox" id="cbhepatitis" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ANESTHESIA_HEPATITIS" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ANESTHESIA_HEPATITIS;value=medwan.common.true" property="value" outputString="checked"/> value="medwan.common.true"/><%=getLabel("openclinic.chuk","hepatitis",sWebLanguage,"cbhepatitis")%></td>
        </tr>
        <tr>
            <td class="admin"/>
            <td class="admin2"><input <%=setRightClick("ITEM_TYPE_ANESTHESIA_ALLERGY")%> type="checkbox" id="cballergy" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ANESTHESIA_ALLERGY" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ANESTHESIA_ALLERGY;value=medwan.common.true" property="value" outputString="checked"/> value="medwan.common.true"/><%=getLabel("openclinic.chuk","allergy",sWebLanguage,"cballergy")%></td>
            <td class="admin2"><input <%=setRightClick("ITEM_TYPE_ANESTHESIA_CARDIOPATHY")%> type="checkbox" id="cbcardiopathy" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ANESTHESIA_CARDIOPATHY" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ANESTHESIA_CARDIOPATHY;value=medwan.common.true" property="value" outputString="checked"/> value="medwan.common.true"/><%=getLabel("openclinic.chuk","cardiopathy",sWebLanguage,"cbcardiopathy")%></td>
            <td class="admin2"><input <%=setRightClick("ITEM_TYPE_ANESTHESIA_HYPERTENSION")%> type="checkbox" id="cbhypertension" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ANESTHESIA_HYPERTENSION" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ANESTHESIA_HYPERTENSION;value=medwan.common.true" property="value" outputString="checked"/> value="medwan.common.true"/><%=getLabel("openclinic.chuk","hypertension",sWebLanguage,"cbhypertension")%></td>
            <td class="admin2"><input <%=setRightClick("ITEM_TYPE_ANESTHESIA_OTHERA")%> type="checkbox" id="cbother" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ANESTHESIA_OTHERA" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ANESTHESIA_OTHERA;value=medwan.common.true" property="value" outputString="checked"/> value="medwan.common.true"/><%=getLabel("openclinic.chuk","other",sWebLanguage,"cbother")%></td>
        </tr>
        <tr>
            <td class="admin"><%=getTran("openclinic.chuk","previous_anesthesia",sWebLanguage)%></td>
            <td class="admin2" colspan="4">
                <textarea onKeyup="resizeTextarea(this,10);limitChars(this,255);" <%=setRightClick("ITEM_TYPE_ANESTHESIA_PREVIOUS_ANESTHESIA")%> class="text" cols="100" rows="2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ANESTHESIA_PREVIOUS_ANESTHESIA" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ANESTHESIA_PREVIOUS_ANESTHESIA" property="value"/></textarea>
            </td>
        </tr>
        <tr>
            <td class="admin"><%=getTran("openclinic.chuk","neurologic_problem",sWebLanguage)%></td>
            <td class="admin2" colspan="4">
                <textarea onKeyup="resizeTextarea(this,10);limitChars(this,255);" <%=setRightClick("ITEM_TYPE_ANESTHESIA_NEUROLOGIC_PROBLEM")%> class="text" cols="100" rows="2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ANESTHESIA_NEUROLOGIC_PROBLEM" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ANESTHESIA_NEUROLOGIC_PROBLEM" property="value"/></textarea>
            </td>
        </tr>
        <tr>
            <td class="admin"><%=getTran("openclinic.chuk","comment",sWebLanguage)%>&nbsp;</td>
            <td class="admin2" colspan="4">
                <textarea onKeyup="resizeTextarea(this,10);limitChars(this,255);" <%=setRightClick("ITEM_TYPE_ANESTHESIA_COMMENTA")%> class="text" cols="100" rows="2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ANESTHESIA_COMMENTA" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ANESTHESIA_COMMENTA" property="value"/></textarea>
            </td>
        </tr>
        <%-- Clinique --%>
        <tr class="admin">
            <td colspan="5"><%=getTran("openclinic.chuk","patient.clinical",sWebLanguage)%></td>
        </tr>
        <tr>
            <td class="admin"><%=getTran("openclinic.chuk","general.condition",sWebLanguage)%></td>
            <td class="admin2" colspan="4">
                <textarea onKeyup="resizeTextarea(this,10);limitChars(this,255);" <%=setRightClick("ITEM_TYPE_ANESTHESIA_GENERAL_CONDITION")%> class="text" cols="100" rows="2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ANESTHESIA_GENERAL_CONDITION" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ANESTHESIA_GENERAL_CONDITION" property="value"/></textarea>
            </td>
        </tr>
        <tr>
            <td class="admin"><%=getTran("Web.Occup","medwan.healthrecord.cardial.pression-arterielle",sWebLanguage)%></td>
            <td class="admin2">
                <%=getTran("Web.Occup","medwan.healthrecord.cardial.bras-droit",sWebLanguage)%>
                <input id="sbpr" <%=setRightClick("ITEM_TYPE_CARDIAL_CLINICAL_EXAMINATION_SYSTOLIC_PRESSURE_RIGHT")%> type="text" class="text" size="3" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CARDIAL_CLINICAL_EXAMINATION_SYSTOLIC_PRESSURE_RIGHT" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CARDIAL_CLINICAL_EXAMINATION_SYSTOLIC_PRESSURE_RIGHT" property="value"/>" onblur="setBP(this,'sbpr','dbpr');"> /
                <input id="dbpr" <%=setRightClick("ITEM_TYPE_CARDIAL_CLINICAL_EXAMINATION_DIASTOLIC_PRESSURE_RIGHT")%> type="text" class="text" size="3" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CARDIAL_CLINICAL_EXAMINATION_DIASTOLIC_PRESSURE_RIGHT" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CARDIAL_CLINICAL_EXAMINATION_DIASTOLIC_PRESSURE_RIGHT" property="value"/>" onblur="setBP(this,'sbpr','dbpr');"> mmHg
            </td>
            <td class="admin2" colspan="3">
                <%=getTran("Web.Occup","medwan.healthrecord.cardial.bras-gauche",sWebLanguage)%>
                <input id="sbpl" <%=setRightClick("ITEM_TYPE_CARDIAL_CLINICAL_EXAMINATION_SYSTOLIC_PRESSURE_LEFT")%> type="text" class="text" size="3" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CARDIAL_CLINICAL_EXAMINATION_SYSTOLIC_PRESSURE_LEFT" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CARDIAL_CLINICAL_EXAMINATION_SYSTOLIC_PRESSURE_LEFT" property="value"/>" onblur="setBP(this,'sbpl','dbpl');"> /
                <input id="dbpl" <%=setRightClick("ITEM_TYPE_CARDIAL_CLINICAL_EXAMINATION_DIASTOLIC_PRESSURE_LEFT")%> type="text" class="text" size="3" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CARDIAL_CLINICAL_EXAMINATION_DIASTOLIC_PRESSURE_LEFT" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CARDIAL_CLINICAL_EXAMINATION_DIASTOLIC_PRESSURE_LEFT" property="value"/>" onblur="setBP(this,'sbpl','dbpl');"> mmHg
            </td>
        </tr>
        <tr>
            <td class="admin"><%=getTran("openclinic.chuk","conjunctiva",sWebLanguage)%></td>
            <td class="admin2" colspan="4"><input <%=setRightClick("ITEM_TYPE_ANESTHESIA_CONJUNCTIVA")%> type="text" class="text" size="40" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ANESTHESIA_CONJUNCTIVA" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ANESTHESIA_CONJUNCTIVA" property="value"/>"></td>
        </tr>
        <tr>
            <td class="admin"><%=getTran("openclinic.chuk","oedema.legs",sWebLanguage)%></td>
            <td class="admin2" colspan="4"><input <%=setRightClick("ITEM_TYPE_ANESTHESIA_OEDEMA_LEGS")%> type="text" class="text" size="40" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ANESTHESIA_OEDEMA_LEGS" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ANESTHESIA_OEDEMA_LEGS" property="value"/>"></td>
        </tr>
        <tr>
            <td class="admin"><%=getTran("openclinic.chuk","dyspnoe",sWebLanguage)%></td>
            <td class="admin2" colspan="4"><input <%=setRightClick("ITEM_TYPE_ANESTHESIA_DYSPNOE")%> type="text" class="text" size="40" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ANESTHESIA_DYSPNOE" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ANESTHESIA_DYSPNOE" property="value"/>"></td>
        </tr>
        <tr>
            <td class="admin"><%=getTran("openclinic.chuk","other",sWebLanguage)%></td>
            <td class="admin2" colspan="4">
                <textarea onKeyup="resizeTextarea(this,10);limitChars(this,255);" <%=setRightClick("ITEM_TYPE_ANESTHESIA_OTHERB")%> class="text" cols="100" rows="2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ANESTHESIA_OTHERB" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ANESTHESIA_OTHERB" property="value"/></textarea>
            </td>
        </tr>
        <%-- Examens paracliniques --%>
        <tr class="admin">
            <td colspan="5"><%=getTran("openclinic.chuk","paraclinic.examinations",sWebLanguage)%></td>
        </tr>
        <tr>
            <td class="admin"/>
            <td class="admin2">
                <input <%=setRightClick("ITEM_TYPE_ANESTHESIA_HB")%> type="text" class="text" size="5" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ANESTHESIA_HB" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ANESTHESIA_HB" property="value"/>">
                <%=getTran("openclinic.chuk","anesthesia.hb",sWebLanguage)%>
            </td>
            <td class="admin2">
                <input <%=setRightClick("ITEM_TYPE_ANESTHESIA_NA")%> type="text" class="text" size="5" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ANESTHESIA_NA" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ANESTHESIA_NA" property="value"/>">
                <%=getTran("openclinic.chuk","anesthesia.na",sWebLanguage)%>
            </td>
            <td class="admin2">
                <input <%=setRightClick("ITEM_TYPE_ANESTHESIA_K")%> type="text" class="text" size="5" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ANESTHESIA_K" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ANESTHESIA_K" property="value"/>">
                <%=getTran("openclinic.chuk","anesthesia.k",sWebLanguage)%>
            </td>
            <td class="admin2">
                <input <%=setRightClick("ITEM_TYPE_ANESTHESIA_CA")%> type="text" class="text" size="5" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ANESTHESIA_CA" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ANESTHESIA_CA" property="value"/>">
                <%=getTran("openclinic.chuk","anesthesia.ca",sWebLanguage)%>
            </td>
        </tr>
        <tr>
            <td class="admin"/>
            <td class="admin2">
                <input <%=setRightClick("ITEM_TYPE_ANESTHESIA_GLUC")%> type="text" class="text" size="5" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ANESTHESIA_GLUC" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ANESTHESIA_GLUC" property="value"/>">
                <%=getTran("openclinic.chuk","anesthesia.glucose",sWebLanguage)%>
            </td>
            <td class="admin2">
                <input <%=setRightClick("ITEM_TYPE_ANESTHESIA_UREUM")%> type="text" class="text" size="5" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ANESTHESIA_UREUM" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ANESTHESIA_UREUM" property="value"/>">
                <%=getTran("openclinic.chuk","anesthesia.ureum",sWebLanguage)%>
            </td>
            <td class="admin2">
                <input <%=setRightClick("ITEM_TYPE_ANESTHESIA_CREATININE")%> type="text" class="text" size="5" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ANESTHESIA_CREATININE" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ANESTHESIA_CREATININE" property="value"/>">
                <%=getTran("openclinic.chuk","anesthesia.creatinine",sWebLanguage)%>
            </td>
            <td class="admin2">
                <input <%=setRightClick("ITEM_TYPE_ANESTHESIA_PROTIDES")%> type="text" class="text" size="5" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ANESTHESIA_PROTIDES" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ANESTHESIA_PROTIDES" property="value"/>">
                <%=getTran("openclinic.chuk","anesthesia.protides",sWebLanguage)%>
            </td>
        </tr>
        <tr>
            <td class="admin"/>
            <td class="admin2">
                <input <%=setRightClick("ITEM_TYPE_ANESTHESIA_SGOT")%> type="text" class="text" size="5" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ANESTHESIA_SGOT" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ANESTHESIA_SGOT" property="value"/>">
                <%=getTran("openclinic.chuk","anesthesia.sgot",sWebLanguage)%>
            </td>
            <td class="admin2" colspan="3">
                <input <%=setRightClick("ITEM_TYPE_ANESTHESIA_SGPT")%> type="text" class="text" size="5" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ANESTHESIA_SGPT" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ANESTHESIA_SGPT" property="value"/>">
                <%=getTran("openclinic.chuk","anesthesia.sgpt",sWebLanguage)%>
            </td>
        </tr>
        <tr>
            <td class="admin"/>
            <td class="admin2">
                <input <%=setRightClick("ITEM_TYPE_ANESTHESIA_FIBRINOGENE")%> type="text" class="text" size="5" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ANESTHESIA_FIBRINOGENE" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ANESTHESIA_FIBRINOGENE" property="value"/>">
                <%=getTran("openclinic.chuk","anesthesia.fibrinogene",sWebLanguage)%>
            </td>
            <td class="admin2">
                <input <%=setRightClick("ITEM_TYPE_ANESTHESIA_PLATELETS")%> type="text" class="text" size="5" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ANESTHESIA_PLATELETS" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ANESTHESIA_PLATELETS" property="value"/>">
                <%=getTran("openclinic.chuk","anesthesia.platelets",sWebLanguage)%>
            </td>
            <td class="admin2" colspan="2">
                <input <%=setRightClick("ITEM_TYPE_ANESTHESIA_TCA")%> type="text" class="text" size="5" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ANESTHESIA_TCA" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ANESTHESIA_TCA" property="value"/>">
                <%=getTran("openclinic.chuk","anesthesia.tca",sWebLanguage)%>
            </td>
        </tr>
        <tr>
            <td class="admin"><%=getTran("openclinic.chuk","xray.lungs",sWebLanguage)%></td>
            <td class="admin2" colspan="4">
                <textarea onKeyup="resizeTextarea(this,10);limitChars(this,255);" <%=setRightClick("ITEM_TYPE_ANESTHESIA_XRAY_LUNGS")%> class="text" cols="100" rows="2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ANESTHESIA_XRAY_LUNGS" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ANESTHESIA_XRAY_LUNGS" property="value"/></textarea>
            </td>
        </tr>
        <tr>
            <td class="admin"><%=getTran("openclinic.chuk","ecg",sWebLanguage)%></td>
            <td class="admin2" colspan="4">
                <textarea onKeyup="resizeTextarea(this,10);limitChars(this,255);" <%=setRightClick("ITEM_TYPE_ANESTHESIA_ECG")%> class="text" cols="100" rows="2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ANESTHESIA_ECG" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ANESTHESIA_ECG" property="value"/></textarea>
            </td>
        </tr>
        <tr>
            <td class="admin"><%=getTran("openclinic.chuk","eyefundus",sWebLanguage)%></td>
            <td class="admin2" colspan="4">
                <textarea onKeyup="resizeTextarea(this,10);limitChars(this,255);" <%=setRightClick("ITEM_TYPE_ANESTHESIA_EYE_FUNDUS")%> class="text" cols="100" rows="2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ANESTHESIA_EYE_FUNDUS" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ANESTHESIA_EYE_FUNDUS" property="value"/></textarea>
            </td>
        </tr>
        <%-- Traitement en cours --%>
        <tr class="admin">
            <td colspan="5"><%=getTran("openclinic.chuk","treatment",sWebLanguage)%></td>
        </tr>
        <tr>
            <td class="admin"><%=getTran("openclinic.chuk","current.treatment",sWebLanguage)%></td>
            <td class="admin2" colspan="4">
                <textarea onKeyup="resizeTextarea(this,10);limitChars(this,255);" <%=setRightClick("ITEM_TYPE_ANESTHESIA_CURRENT_TREATMENT")%> class="text" cols="100" rows="2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ANESTHESIA_CURRENT_TREATMENT" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ANESTHESIA_CURRENT_TREATMENT" property="value"/></textarea>
            </td>
        </tr>
        <%-- Conclusion --%>
        <tr class="admin">
            <td colspan="5"><%=getTran("openclinic.chuk","conclusion",sWebLanguage)%></td>
        </tr>
        <tr>
            <td class="admin"><%=getTran("openclinic.chuk","intubation",sWebLanguage)%></td>
            <td class="admin2" colspan="4">
                <textarea onKeyup="resizeTextarea(this,10);limitChars(this,255);" <%=setRightClick("ITEM_TYPE_ANESTHESIA_INTUBATION")%> class="text" cols="100" rows="2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ANESTHESIA_INTUBATION" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ANESTHESIA_INTUBATION" property="value"/></textarea>
            </td>
        </tr>
        <tr>
            <td class="admin"><%=getTran("openclinic.chuk","anesthesia.class",sWebLanguage)%></td>
            <td class="admin2" colspan="4">
                <input <%=setRightClick("ITEM_TYPE_ANESTHESIA_CLASS")%> type="radio" onDblClick="uncheckRadio(this);" id="class_r1" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ANESTHESIA_CLASS" property="itemId"/>]>.value" value="openclinic.anesthesia.asa" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ANESTHESIA_CLASS;value=openclinic.anesthesia.asa" property="value" outputString="checked"/>><%=getLabel("openclinic.chuk","openclinic.anesthesia.asa",sWebLanguage,"class_r1")%>
                <input <%=setRightClick("ITEM_TYPE_ANESTHESIA_CLASS")%> type="radio" onDblClick="uncheckRadio(this);" id="class_r2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ANESTHESIA_CLASS" property="itemId"/>]>.value" value="openclinic.anesthesia.mallampati" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ANESTHESIA_CLASS;value=openclinic.anesthesia.mallampati" property="value" outputString="checked"/>><%=getLabel("openclinic.chuk","openclinic.anesthesia.mallampati",sWebLanguage,"class_r2")%>
            </td>
        </tr>
        <tr>
            <td class="admin"><%=getTran("openclinic.chuk","anesthesia.protocol",sWebLanguage)%></td>
            <td class="admin2" colspan="4">
                <input <%=setRightClick("ITEM_TYPE_ANESTHESIA_PROTOCOLE")%> type="radio" onDblClick="uncheckRadio(this);" id="protocole_r1" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ANESTHESIA_PROTOCOLE" property="itemId"/>]>.value" value="openclinic.anesthesia.ag" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ANESTHESIA_PROTOCOLE;value=openclinic.anesthesia.ag" property="value" outputString="checked"/>><%=getLabel("openclinic.chuk","openclinic.anesthesia.ag",sWebLanguage,"protocol_r1")%>
                <input <%=setRightClick("ITEM_TYPE_ANESTHESIA_PROTOCOLE")%> type="radio" onDblClick="uncheckRadio(this);" id="protocole_r2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ANESTHESIA_PROTOCOLE" property="itemId"/>]>.value" value="openclinic.anesthesia.locoregional" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ANESTHESIA_PROTOCOLE;value=openclinic.anesthesia.locoregional" property="value" outputString="checked"/>><%=getLabel("openclinic.chuk","openclinic.anesthesia.locoregional",sWebLanguage,"protocol_r2")%>
                <input <%=setRightClick("ITEM_TYPE_ANESTHESIA_PROTOCOLE")%> type="radio" onDblClick="uncheckRadio(this);" id="protocole_r3" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ANESTHESIA_PROTOCOLE" property="itemId"/>]>.value" value="openclinic.anesthesia.local" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ANESTHESIA_PROTOCOLE;value=openclinic.anesthesia.local" property="value" outputString="checked"/>><%=getLabel("openclinic.chuk","openclinic.anesthesia.local",sWebLanguage,"protocol_r3")%>
            </td>
        </tr>
        <tr>
            <td class="admin"><%=getTran("openclinic.chuk","sober",sWebLanguage)%></td>
            <td class="admin2" colspan="4">
                <input type="text" class="text" size="12" maxLength="10" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ANESTHESIA_SOBER_DATE" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ANESTHESIA_SOBER_DATE" property="value"/>" id="soberdate" OnBlur='checkDate(this)'>
                <script>writeMyDate("soberdate","<c:url value="/_img/icon_agenda.gif"/>","<%=getTran("Web","PutToday",sWebLanguage)%>");</script>

                <input type='text' class='text' name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ANESTHESIA_SOBER_HOUR" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ANESTHESIA_SOBER_HOUR" property="value"/>" onblur='checkTime(this)' size='5'>
                &nbsp;<%=getTran("web.occup","medwan.common.hour",sWebLanguage)%>
            </td>
        </tr>
        <tr>
            <td class="admin"><%=getTran("openclinic.chuk","premedication",sWebLanguage)%>&nbsp;</td>
            <td class="admin2" colspan="4">
                <textarea onKeyup="resizeTextarea(this,10);limitChars(this,255);" <%=setRightClick("ITEM_TYPE_ANESTHESIA_PREMEDICATION")%> class="text" cols="100" rows="2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ANESTHESIA_PREMEDICATION" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ANESTHESIA_PREMEDICATION" property="value"/></textarea>
            </td>
        </tr>
        <tr>
            <td class="admin"/>
            <td class="admin2" colspan="4">
<%-- BUTTONS --%>
    <%
      if (activeUser.getAccessRight("occup.anesthesiapreop.add") || activeUser.getAccessRight("occup.anesthesiapreop.edit")){
    %>
            <INPUT class="button" type="button" name="save" id="save" value="<%=getTran("Web.Occup","medwan.common.record",sWebLanguage)%>" onclick="submitForm()"/>
    <%
      }
    %>
                <INPUT class="button" type="button" value="<%=getTran("Web","back",sWebLanguage)%>" onclick="if (checkSaveButton('<%=sCONTEXTPATH%>','<%=getTran("Web.Occup","medwan.common.buttonquestion",sWebLanguage)%>')){window.location.href='<c:url value="/main.do?Page=curative/index.jsp"/>&ts=<%=getTs()%>'}">
            </td>
        </tr>
    </table>
<%=ScreenHelper.contextFooter(request)%>
</form>
<%=writeJSButtons("transactionForm", "save")%>
<script type="text/javascript">
    function setBP(oObject,sbp,dbp){
      if(oObject.value.length>0){
          if(!isNumberLimited(oObject,40,300)){
            alert('<%=getTran("Web.Occup","out-of-bounds-value",sWebLanguage)%>');
          }
          else if ((sbp.length>0)&&(dbp.length>0)){
            isbp = document.getElementsByName(sbp)[0].value*1;
            idbp = document.getElementsByName(dbp)[0].value*1;
            if (idbp>isbp){
              alert('<%=getTran("Web.Occup","error.dbp_greather_than_sbp",sWebLanguage)%>');
            }
          }
      }
    }
</script>