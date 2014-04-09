<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>
<%

%>
<form name="transactionForm" id="transactionForm" method="POST" action='<c:url value="/healthrecord/updateTransaction.do"/>?ts=<%=getTs()%>' onclick="setSaveButton(event);" onkeyup="setSaveButton(event);">
    <bean:define id="transaction" name="be.mxs.webapp.wl.session.SessionContainerFactory.WO_SESSION_CONTAINER" property="currentTransactionVO"/>
    <input type="hidden" id="transactionId" name="currentTransactionVO.<TransactionVO[hashCode=<bean:write name="transaction" scope="page" property="transactionId"/>]>.transactionId" value="<bean:write name="transaction" scope="page" property="transactionId"/>"/>
    <input type="hidden" id="transactionType" name="currentTransactionVO.<TransactionVO[hashCode=<bean:write name="transaction" scope="page" property="transactionId"/>]>.transactionType" value="<bean:write name="transaction" scope="page" property="transactionType"/>"/>
    <input type="hidden" id="serverId" name="currentTransactionVO.<TransactionVO[hashCode=<bean:write name="transaction" scope="page" property="transactionId"/>]>.serverId" value="<bean:write name="transaction" scope="page" property="serverId"/>"/>
    <input type="hidden" readonly name="be.mxs.healthrecord.updateTransaction.actionForwardKey" value="manageClinicalExamination.do?be.mxs.healthrecord.createTransaction.transactionType=<bean:write name="transaction" scope="page" property="transactionType"/>&be.mxs.healthrecord.transaction_id=currentTransaction"/>
    <input type="hidden" readonly name="subClass" value=".CARDIAL.RESPIRATORY"/>
    <input type="hidden" readonly name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CONTEXT_DEPARTMENT" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CONTEXT_DEPARTMENT" translate="false" property="value"/>"/>
    <input type="hidden" readonly name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CONTEXT_CONTEXT" translate="false" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CONTEXT_CONTEXT" translate="false" property="value"/>"/>
    <%
        if (session.getAttribute("sessionCounter")==null){
            session.setAttribute("sessionCounter",new Integer(0));
        }
        else {
            session.setAttribute("sessionCounter",new Integer(((Integer)session.getAttribute("sessionCounter")).intValue()+1));
        }
        session.setAttribute("sessionURL","/healthrecord/template.jsp?be.mxs.healthrecord.transaction_id=currentTransaction&Page="+customerInclude("/healthrecord/ausculatie.jsp")+"&message=true");
        if (request.getParameter("message")!=null){
            out.print("<script>alert('"+getTran("Web.Occup","medwan.common.do-not-use-back",sWebLanguage)+"');</script>");
        }
    %>
    <br>
    <%-- CARDIAL ---------------------------------------------------------------------------------%>
    <table border='0' width='100%' cellspacing="1" cellpadding="0" class="list">
        <tr class="admin">
            <td colspan="4"><%=getTran("Web.Occup","medwan.healthrecord.cardial",sWebLanguage)%></td>
        </tr>
        <tr>
            <td class="admin" width="<%=sTDAdminWidth%>" rowspan="2"/>
            <td class="admin2" width="250"><input <%=setRightClick("ITEM_TYPE_CARDIAL_ANAMNESIS_EFFORT_DYSPNOE")%> type="checkbox" id="ausc-c1" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CARDIAL_ANAMNESIS_EFFORT_DYSPNOE" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CARDIAL_ANAMNESIS_EFFORT_DYSPNOE;value=medwan.common.true" property="value" outputString="checked"/> value="medwan.common.true"/><%=getLabel("Web.Occup","medwan.healthrecord.cardial.dyspnee-effort",sWebLanguage,"ausc-c1")%></td>
            <td class="admin2" width="250"><input <%=setRightClick("ITEM_TYPE_CARDIAL_ANAMNESIS_HYPERTENSION")%> type="checkbox" id="ausc-c2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CARDIAL_ANAMNESIS_HYPERTENSION" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CARDIAL_ANAMNESIS_HYPERTENSION;value=medwan.common.true" property="value" outputString="checked"/> value="medwan.common.true"/><%=getLabel("Web.Occup","medwan.healthrecord.cardial.hypertension",sWebLanguage,"ausc-c2")%></td>
            <td class="admin2"><input <%=setRightClick("ITEM_TYPE_CARDIAL_ANAMNESIS_PALPITATIONS")%> type="checkbox" id="ausc-c3" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CARDIAL_ANAMNESIS_PALPITATIONS" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CARDIAL_ANAMNESIS_PALPITATIONS;value=medwan.common.true" property="value" outputString="checked"/> value="medwan.common.true"/><%=getLabel("Web.Occup","medwan.healthrecord.cardial.palpitations",sWebLanguage,"ausc-c3")%></td>
        </tr>
        <tr>
            <td class="admin2" colspan="3"><input <%=setRightClick("ITEM_TYPE_CARDIAL_ANAMNESIS_PRECORDIALGIA")%> type="checkbox" id="ausc-c4" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CARDIAL_ANAMNESIS_PRECORDIALGIA" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CARDIAL_ANAMNESIS_PRECORDIALGIA;value=medwan.common.true" property="value" outputString="checked"/> value="medwan.common.true"/><%=getLabel("Web.Occup","medwan.healthrecord.cardial.precordialgie",sWebLanguage,"ausc-c4")%></td>
        </tr>
        <tr>
            <td class="clinical" colspan="4"><%=getTran("Web.Occup","medwan.healthrecord.clinical-examination",sWebLanguage)%></td>
        </tr>
        <tr>
            <td class="admin" width=""><%=getTran("Web.Occup","medwan.healthrecord.cardial.auscultation",sWebLanguage)%></td>
            <td class="admin2" colspan="3">
                <textarea onKeyup="resizeTextarea(this,10);limitChars(this,255);" <%=setRightClick("ITEM_TYPE_CARDIAL_CLINICAL_EXAMINATION_AUSCULTATION")%> class="text" rows="2" cols="80" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CARDIAL_CLINICAL_EXAMINATION_AUSCULTATION" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CARDIAL_CLINICAL_EXAMINATION_AUSCULTATION" property="value"/></textarea>
            </td>
        </tr>
        <%-- DIAGNOSE --%>
        <tr>
            <td class="clinical" colspan="4"><%=getTran("Web.Occup","medwan.healthrecord.diagnose",sWebLanguage)%></td>
        </tr>
        <tr>
            <td class="admin" rowspan="3"/>
            <td class="admin2"><input <%=setRightClick("ITEM_TYPE_CARDIAL_DIAGNOSIS_ANGINA_PECTORIS")%> type="checkbox" id="ausc-c5" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CARDIAL_DIAGNOSIS_ANGINA_PECTORIS" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CARDIAL_DIAGNOSIS_ANGINA_PECTORIS;value=medwan.common.true" property="value" outputString="checked"/> value="medwan.common.true"/><%=getLabel("Web.Occup","medwan.healthrecord.cardial.angine-de-poitrine",sWebLanguage,"ausc-c5")%></td>
            <td class="admin2"><input <%=setRightClick("ITEM_TYPE_CARDIAL_DIAGNOSIS_AMI")%> type="checkbox" id="ausc-c6" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CARDIAL_DIAGNOSIS_AMI" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CARDIAL_DIAGNOSIS_AMI;value=medwan.common.true" property="value" outputString="checked"/> value="medwan.common.true"/><%=getLabel("Web.Occup","medwan.healthrecord.cardial.infarctus-aigu-myocarde",sWebLanguage,"ausc-c6")%></td>
            <td class="admin2"><input <%=setRightClick("ITEM_TYPE_CARDIAL_DIAGNOSIS_CENTRAL_ANEURYSMA")%> type="checkbox" id="ausc-c7" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CARDIAL_DIAGNOSIS_CENTRAL_ANEURYSMA" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CARDIAL_DIAGNOSIS_CENTRAL_ANEURYSMA;value=medwan.common.true" property="value" outputString="checked"/> value="medwan.common.true"/><%=getLabel("Web.Occup","medwan.healthrecord.cardial.anevrysme",sWebLanguage,"ausc-c7")%></td>
        </tr>
        <tr>
            <td class="admin2"><input <%=setRightClick("ITEM_TYPE_CARDIAL_DIAGNOSIS_PACEMAKER")%> type="checkbox" id="ausc-c8" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CARDIAL_DIAGNOSIS_PACEMAKER" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CARDIAL_DIAGNOSIS_PACEMAKER;value=medwan.common.true" property="value" outputString="checked"/> value="medwan.common.true"/><%=getLabel("Web.Occup","medwan.healthrecord.cardial.pacemaker",sWebLanguage,"ausc-c8")%></td>
            <td class="admin2"><input <%=setRightClick("ITEM_TYPE_CARDIAL_DIAGNOSIS_HYPOTENSION")%> type="checkbox" id="ausc-c9" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CARDIAL_DIAGNOSIS_HYPOTENSION" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CARDIAL_DIAGNOSIS_HYPOTENSION;value=medwan.common.true" property="value" outputString="checked"/> value="medwan.common.true"/><%=getLabel("Web.Occup","medwan.healthrecord.cardial.hypotension",sWebLanguage,"ausc-c9")%></td>
            <td class="admin2"><input <%=setRightClick("ITEM_TYPE_CARDIAL_DIAGNOSIS_CARDIOMYOPATHIA")%> type="checkbox" id="ausc-c10" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CARDIAL_DIAGNOSIS_CARDIOMYOPATHIA" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CARDIAL_DIAGNOSIS_CARDIOMYOPATHIA;value=medwan.common.true" property="value" outputString="checked"/> value="medwan.common.true"/><%=getLabel("Web.Occup","medwan.healthrecord.cardial.cardiomyopathie",sWebLanguage,"ausc-c10")%></td>
        </tr>
        <tr>
            <td class="admin2" colspan="3"><input <%=setRightClick("ITEM_TYPE_CARDIAL_DIAGNOSIS_HYPERTENSION")%> type="checkbox" id="ausc-c11" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CARDIAL_DIAGNOSIS_HYPERTENSION" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CARDIAL_DIAGNOSIS_HYPERTENSION;value=medwan.common.true" property="value" outputString="checked"/> value="medwan.common.true"/><%=getLabel("Web.Occup","medwan.healthrecord.cardial.hypertension",sWebLanguage,"ausc-c11")%></td>
        </tr>
        <%-- REMARK --%>
        <tr>
            <td class="admin"><%=getTran("Web.Occup","medwan.common.remark",sWebLanguage)%></td>
            <td class="admin2"colspan="3">
                <textarea onKeyup="resizeTextarea(this,10);limitChars(this,255);" <%=setRightClick("ITEM_TYPE_CARDIAL_DIAGNOSIS_OTHER")%> class="text" rows="2" cols="80" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CARDIAL_DIAGNOSIS_OTHER" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CARDIAL_DIAGNOSIS_OTHER" property="value"/></textarea>
            </td>
        </tr>
    </table>
    <br>
    <%-- RESPIRATOIRE ----------------------------------------------------------------------------%>
    <table border='0' width='100%' cellspacing="1" cellpadding="0" class="list">
        <tr class="admin">
            <td colspan="4"><%=getTran("Web.Occup","medwan.healthrecord.anamnese.respiratoire",sWebLanguage)%></td>
        </tr>
        <tr>
            <td class="admin" width="<%=sTDAdminWidth%>" rowspan="2"/>
            <td class="admin2" width="250"><input <%=setRightClick("ITEM_TYPE_RESPIRATORY_ANAMNESIS_COUGH")%> type="checkbox" id="ausc-c12" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_RESPIRATORY_ANAMNESIS_COUGH" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_RESPIRATORY_ANAMNESIS_COUGH;value=medwan.common.true" property="value" outputString="checked"/> value="medwan.common.true"/><%=getLabel("Web.Occup","medwan.healthrecord.respiratory.cough",sWebLanguage,"ausc-c12")%></td>
            <td class="admin2" width="250"><input <%=setRightClick("ITEM_TYPE_RESPIRATORY_ANAMNESIS_EXPECTORATIONS")%> type="checkbox" id="ausc-c13" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_RESPIRATORY_ANAMNESIS_EXPECTORATIONS" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_RESPIRATORY_ANAMNESIS_EXPECTORATIONS;value=medwan.common.true" property="value" outputString="checked"/> value="medwan.common.true"/><%=getLabel("Web.Occup","medwan.healthrecord.respiratory.expectorations",sWebLanguage,"ausc-c13")%></td>
            <td class="admin2"><input <%=setRightClick("ITEM_TYPE_RESPIRATORY_ANAMNESIS_HAEMOPTOE")%> type="checkbox" id="ausc-c14" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_RESPIRATORY_ANAMNESIS_HAEMOPTOE" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_RESPIRATORY_ANAMNESIS_HAEMOPTOE;value=medwan.common.true" property="value" outputString="checked"/> value="medwan.common.true"/><%=getLabel("Web.Occup","medwan.healthrecord.respiratory.hemoptoe",sWebLanguage,"ausc-c14")%></td>
        </tr>
        <tr>
            <td class="admin2"><input <%=setRightClick("ITEM_TYPE_RESPIRATORY_ANAMNESIS_THORACALGIA")%> type="checkbox" id="ausc-c15" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_RESPIRATORY_ANAMNESIS_THORACALGIA" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_RESPIRATORY_ANAMNESIS_THORACALGIA;value=medwan.common.true" property="value" outputString="checked"/> value="medwan.common.true"/><%=getLabel("Web.Occup","medwan.healthrecord.respiratory.thoracalgia",sWebLanguage,"ausc-c15")%></td>
            <td class="admin2" colspan="2"><input <%=setRightClick("ITEM_TYPE_RESPIRATORY_ANAMNESIS_DYSPNOE")%> type="checkbox" id="ausc-c16" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_RESPIRATORY_ANAMNESIS_DYSPNOE" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_RESPIRATORY_ANAMNESIS_DYSPNOE;value=medwan.common.true" property="value" outputString="checked"/> value="medwan.common.true"/><%=getLabel("Web.Occup","medwan.healthrecord.respiratory.dyspnoe",sWebLanguage,"ausc-c16")%></td>
        </tr>
        <tr>
            <td class="clinical" colspan="4"><%=getTran("Web.Occup","medwan.healthrecord.clinical-examination",sWebLanguage)%></td>
        </tr>
        <tr>
            <td class="admin" rowspan="2"><%=getTran("Web.Occup","medwan.healthrecord.respiratory.auscultation",sWebLanguage)%></td>
            <td class="admin2"><input <%=setRightClick("ITEM_TYPE_RESPIRATORY_CLINICAL_EXAMINATION_REUTELS")%> type="checkbox" id="ausc-c17" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_RESPIRATORY_CLINICAL_EXAMINATION_REUTELS" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_RESPIRATORY_CLINICAL_EXAMINATION_REUTELS;value=medwan.common.true" property="value" outputString="checked"/> value="medwan.common.true"/><%=getLabel("Web.Occup","medwan.healthrecord.respiratory.reutels",sWebLanguage,"ausc-c17")%></td>
            <td class="admin2"><input <%=setRightClick("ITEM_TYPE_RESPIRATORY_CLINICAL_EXAMINATION_WHEEZING")%> type="checkbox" id="ausc-c18" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_RESPIRATORY_CLINICAL_EXAMINATION_WHEEZING" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_RESPIRATORY_CLINICAL_EXAMINATION_WHEEZING;value=medwan.common.true" property="value" outputString="checked"/> value="medwan.common.true"/><%=getLabel("Web.Occup","medwan.healthrecord.respiratory.wheezing",sWebLanguage,"ausc-c18")%></td>
            <td class="admin2"><input <%=setRightClick("ITEM_TYPE_RESPIRATORY_CLINICAL_EXAMINATION_CREPITATIONS")%> type="checkbox" id="ausc-c19" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_RESPIRATORY_CLINICAL_EXAMINATION_CREPITATIONS" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_RESPIRATORY_CLINICAL_EXAMINATION_CREPITATIONS;value=medwan.common.true" property="value" outputString="checked"/> value="medwan.common.true"/><%=getLabel("Web.Occup","medwan.healthrecord.respiratory.crepitations",sWebLanguage,"ausc-c19")%></td>
        </tr>
        <tr>
            <td class="admin2"><input <%=setRightClick("ITEM_TYPE_RESPIRATORY_CLINICAL_EXAMINATION_SIBILANCES")%> type="checkbox" id="ausc-c20" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_RESPIRATORY_CLINICAL_EXAMINATION_SIBILANCES" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_RESPIRATORY_CLINICAL_EXAMINATION_SIBILANCES;value=medwan.common.true" property="value" outputString="checked"/> value="medwan.common.true"/><%=getLabel("Web.Occup","medwan.healthrecord.respiratory.sibilances",sWebLanguage,"ausc-c20")%></td>
            <td class="admin2" colspan="2"><input <%=setRightClick("ITEM_TYPE_RESPIRATORY_CLINICAL_EXAMINATION_VAG")%> type="checkbox" id="ausc-c21" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_RESPIRATORY_CLINICAL_EXAMINATION_VAG" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_RESPIRATORY_CLINICAL_EXAMINATION_VAG;value=medwan.common.true" property="value" outputString="checked"/> value="medwan.common.true"/><%=getLabel("Web.Occup","medwan.healthrecord.respiratory.vag",sWebLanguage,"ausc-c21")%></td>
        </tr>
        <%-- DIAGNOSE --%>
        <tr>
            <td class="clinical" colspan="4"><%=getTran("Web.Occup","medwan.healthrecord.diagnose",sWebLanguage)%></td>
        </tr>
        <tr>
            <td class="admin" rowspan="2"/>
            <td class="admin2"><input <%=setRightClick("ITEM_TYPE_RESPIRATORY_DIAGNOSIS_HAY_FEVER")%> type="checkbox" id="ausc-c22" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_RESPIRATORY_DIAGNOSIS_HAY_FEVER" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_RESPIRATORY_DIAGNOSIS_HAY_FEVER;value=medwan.common.true" property="value" outputString="checked"/> value="medwan.common.true"/><%=getLabel("Web.Occup","medwan.healthrecord.respiratory.hay-fever",sWebLanguage,"ausc-c22")%></td>
            <td class="admin2"><input <%=setRightClick("ITEM_TYPE_RESPIRATORY_DIAGNOSIS_DISTURBED_LUNG_FUNCTION")%> type="checkbox" id="ausc-c23" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_RESPIRATORY_DIAGNOSIS_DISTURBED_LUNG_FUNCTION" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_RESPIRATORY_DIAGNOSIS_DISTURBED_LUNG_FUNCTION;value=medwan.common.true" property="value" outputString="checked"/> value="medwan.common.true"/><%=getLabel("Web.Occup","medwan.healthrecord.respiratory.disturbed-lung-function",sWebLanguage,"ausc-c23")%></td>
            <td class="admin2"><input <%=setRightClick("ITEM_TYPE_RESPIRATORY_DIAGNOSIS_BPCO")%> type="checkbox" id="ausc-c24" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_RESPIRATORY_DIAGNOSIS_BPCO" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_RESPIRATORY_DIAGNOSIS_BPCO;value=medwan.common.true" property="value" outputString="checked"/> value="medwan.common.true"/><%=getLabel("Web.Occup","medwan.healthrecord.respiratory.bpco",sWebLanguage,"ausc-c24")%></td>
        </tr>
        <tr>
            <td class="admin2"><input <%=setRightClick("ITEM_TYPE_RESPIRATORY_DIAGNOSIS_TUBERCULOSIS")%> type="checkbox" id="ausc-c25" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_RESPIRATORY_DIAGNOSIS_TUBERCULOSIS" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_RESPIRATORY_DIAGNOSIS_TUBERCULOSIS;value=medwan.common.true" property="value" outputString="checked"/> value="medwan.common.true"/><%=getLabel("Web.Occup","medwan.healthrecord.respiratory.tuberculosis",sWebLanguage,"ausc-c25")%></td>
            <td class="admin2" colspan="2"><input <%=setRightClick("ITEM_TYPE_RESPIRATORY_DIAGNOSIS_ASTHMA")%> type="checkbox" id="ausc-c26" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_RESPIRATORY_DIAGNOSIS_ASTHMA" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_RESPIRATORY_DIAGNOSIS_ASTHMA;value=medwan.common.true" property="value" outputString="checked"/> value="medwan.common.true"/><%=getLabel("Web.Occup","medwan.healthrecord.respiratory.asthma",sWebLanguage,"ausc-c26")%></td>
        </tr>
        <%-- REMARK --%>
        <tr>
            <td class="admin"><%=getTran("Web.Occup","medwan.common.remark",sWebLanguage)%></td>
            <td class="admin2" colspan="3">
                <textarea onKeyup="resizeTextarea(this,10);limitChars(this,255);" <%=setRightClick("ITEM_TYPE_RESPIRATORY_DIAGNOSIS_OTHER")%> class="text" rows="2" cols="80" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_RESPIRATORY_DIAGNOSIS_OTHER" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_RESPIRATORY_DIAGNOSIS_OTHER" property="value"/></textarea>
            </td>
        </tr>
        <tr>
            <td class="admin"/>
            <td class="admin2" colspan="3">
                <INPUT class="button" type="button" name="saveButton" id="save" onClick="doSubmit();" value="<%=getTran("Web.Occup","medwan.common.record",sWebLanguage)%>">
                <INPUT class="button" type="button" value="<%=getTran("Web","Back",sWebLanguage)%>" onclick="if(checkSaveButton()){window.location.href='<c:url value='/healthrecord/editTransaction.do'/>?be.mxs.healthrecord.createTransaction.transactionType=<bean:write name="transaction" scope="page" property="transactionType"/>&be.mxs.healthrecord.transaction_id=currentTransaction&ts=<%=getTs()%>'}">
            </td>
        </tr>
    </table>
    <%-- BUTTONS ---------------------------------------------------------------------------------%>
</form>
<script>
  function doSubmit(){
    transactionForm.saveButton.disabled = true;
    <%
        SessionContainerWO sessionContainerWO = (SessionContainerWO)SessionContainerFactory.getInstance().getSessionContainerWO(request,SessionContainerWO.class.getName());
        out.print(takeOverTransaction(sessionContainerWO, activeUser,"document.transactionForm.submit();"));
    %>
  }

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

<%=writeJSButtons("transactionForm","saveButton")%>