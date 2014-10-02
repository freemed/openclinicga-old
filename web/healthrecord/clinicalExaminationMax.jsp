<%@include file="/includes/validateUser.jsp"%>
<%@page errorPage="/includes/error.jsp"%>
<%

%>
<form name="transactionForm" id="transactionForm" method="POST" action='<c:url value="/healthrecord/updateTransaction.do"/>?ts=<%=getTs()%>' onclick="setSaveButton(event);" onkeyup="setSaveButton(event);">
    <bean:define id="transaction" name="be.mxs.webapp.wl.session.SessionContainerFactory.WO_SESSION_CONTAINER" property="currentTransactionVO"/>

    <input id="transactionId" type="hidden" name="currentTransactionVO.<TransactionVO[hashCode=<bean:write name="transaction" scope="page" property="transactionId"/>]>.transactionId" value="<bean:write name="transaction" scope="page" property="transactionId"/>"/>
    <input id="serverId" type="hidden" name="currentTransactionVO.<TransactionVO[hashCode=<bean:write name="transaction" scope="page" property="transactionId"/>]>.serverId" value="<bean:write name="transaction" scope="page" property="serverId"/>"/>
    <input id="transactionType" type="hidden" name="currentTransactionVO.<TransactionVO[hashCode=<bean:write name="transaction" scope="page" property="transactionId"/>]>.transactionType" value="<bean:write name="transaction" scope="page" property="transactionType"/>"/>
    <input type="hidden" readonly name="be.mxs.healthrecord.updateTransaction.actionForwardKey" value="/healthrecord/managePeriodicExaminations.do?ts=<%=getTs()%>"/>
    <input type="hidden" readonly name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_RECRUITMENT_CONVOCATION_ID" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_RECRUITMENT_CONVOCATION_ID" property="value"/>"/>
    <input type="hidden" readonly name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CONTEXT_DEPARTMENT" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CONTEXT_DEPARTMENT" translate="false" property="value"/>"/>
    <input type="hidden" readonly name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CONTEXT_CONTEXT" translate="false" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CONTEXT_CONTEXT" translate="false" property="value"/>"/>
    <input type="hidden" readonly name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_EXTENDED_CLINICAL_EXAMINATION" translate="false" property="itemId"/>]>.value" value="medwan.common.true"/>

    <table border='0' width='100%' height='100%' cellspacing="1" cellpadding="0" class="list">
        <tr class="admin">
            <td colspan="2"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CONTEXT_CONTEXT" property="value"/></td>
        </tr>
        <tr>
            <td class="admin" width="25%">
                <a href="<c:url value="/healthrecord/managePrintHistory.do?"/>transactionType=<bean:write name="transaction" scope="page" property="transactionType"/>&ts=<%=getTs()%>">...</a>
                <%=getTran("Web.Occup","medwan.common.date",sWebLanguage)%>
            </td>
            <td class="admin2" width="*">
                <input type="text" class="text" size="12" maxLength="10" value="<mxs:propertyAccessorI18N name="transaction" scope="page" property="updateTime" formatType="date"/>" name="currentTransactionVO.<TransactionVO[hashCode=<bean:write name="transaction" scope="page" property="transactionId"/>]>.updateTime" id="trandate" OnBlur='checkDate(this)'>
                <script>writeTranDate();</script>
            </td>
        </tr>
        <tr class="admin">
            <td colspan="2"><%=getTran("Web.Occup","medwan.common.general",sWebLanguage)%></td>
        </tr>
        <tr>
            <td class="admin"><%=getTran("Web.Occup","medwan.healthrecord.anamnese.general.style-de-vie",sWebLanguage)%></td>
            <td class="admin2"><input <%=setRightClick("[GENERAL.ANAMNESE]ITEM_TYPE_LIFE_STYLE")%> type="text" class="text" size="97" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.[GENERAL.ANAMNESE]ITEM_TYPE_LIFE_STYLE" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.[GENERAL.ANAMNESE]ITEM_TYPE_LIFE_STYLE" property="value"/>" onblur="limitLength(this);"></td>
        </tr>
        <tr>
            <td class="admin"><%=getTran("Web.Occup","medwan.healthrecord.anamnese.general.medicaments",sWebLanguage)%></td>
            <td class="admin2">
                <textarea onKeyup="resizeTextarea(this,10);limitChars(this,255);" <%=setRightClick("[GENERAL.ANAMNESE]ITEM_TYPE_MEDICIATIONS")%> class="text" rows="2" cols="95" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.[GENERAL.ANAMNESE]ITEM_TYPE_MEDICIATIONS" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.[GENERAL.ANAMNESE]ITEM_TYPE_MEDICIATIONS" property="value"/></textarea>
            </td>
        </tr>
        <tr>
            <td class="admin"><%=getTran("Web.Occup","medwan.healthrecord.anamnese.general.tobacco-usage",sWebLanguage)%></td>
            <td class="admin2">
                <select <%=setRightClick("[GENERAL.ANAMNESE]ITEM_TYPE_TOBACCO_USAGE")%> id="EditSmoking" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.[GENERAL.ANAMNESE]ITEM_TYPE_TOBACCO_USAGE" property="itemId"/>]>.value" class="text">
                    <option/>
                    <option value="1">0</option>
                    <option value="2">0 - 5</option>
                    <option value="3">5 - 10</option>
                    <option value="4">10 - 15</option>
                    <option value="5">15 - 25</option>
                    <option value="6">&gt; 25</option>
                </select>
                &nbsp;&nbsp;<%=getTran("Web.Occup","ADay",sWebLanguage)%>
            </td>
        </tr>
        <tr>
            <td class="admin"><%=getTran("Web.Occup","medwan.healthrecord.anamnese.general.alcohol-usage",sWebLanguage)%></td>
            <td class="admin2">
                <select <%=setRightClick("[GENERAL.ANAMNESE]ITEM_TYPE_ALCOHOL_USAGE")%> id="EditAlcohol" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.[GENERAL.ANAMNESE]ITEM_TYPE_ALCOHOL_USAGE" property="itemId"/>]>.value" class="text">
                    <option/>
                    <option value="1">0 <%=getTran("Web.Occup","ADay",sWebLanguage)%></option>
                    <option value="2">&lt; 1 <%=getTran("Web.Occup","ADay",sWebLanguage)%></option>
                    <option value="3">1 <%=getTran("Web.Occup","ADay",sWebLanguage)%></option>
                    <option value="4">1 - 2 <%=getTran("Web.Occup","ADay",sWebLanguage)%></option>
                    <option value="5">1 - 3 <%=getTran("Web.Occup","ADay",sWebLanguage)%></option>
                    <option value="6">3 - 6 <%=getTran("Web.Occup","ADay",sWebLanguage)%></option>
                    <option value="8">&gt; 1 <%=getTran("Web.Occup","ADay",sWebLanguage)%></option>
                    <option value="7">&gt; 6 <%=getTran("Web.Occup","ADay",sWebLanguage)%></option>
                    <option value="9">&lt; 1 <%=getTran("Web.Occup","AMonth",sWebLanguage)%></option>
                    <option value="10">&lt; 1 <%=getTran("Web.Occup","AWeek",sWebLanguage)%></option>
                    <option value="11">&gt; 1 <%=getTran("Web.Occup","AWeek",sWebLanguage)%></option>
                </select>
            </td>
        </tr>
        <tr>
            <td class="admin"><%=getTran("Web.Occup","medwan.healthrecord.anamnese.general.cofee-usage",sWebLanguage)%></td>
            <td class="admin2"><input <%=setRightClick("[GENERAL.ANAMNESE]ITEM_TYPE_COFFEE_USAGE")%> type="text" class="text" size="97" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.[GENERAL.ANAMNESE]ITEM_TYPE_COFFEE_USAGE" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.[GENERAL.ANAMNESE]ITEM_TYPE_COFFEE_USAGE" property="value"/>" onblur="limitLength(this);"></td>
        </tr>
        <tr>
            <td class="admin"><%=getTran("Web.Occup","medwan.healthrecord.anamnese.general.etat-familial-et-social",sWebLanguage)%></td>
            <td class="admin2"><input <%=setRightClick("[GENERAL.ANAMNESE]ITEM_TYPE_SOCIAL_AND_FAMILIAL_STATUS")%> type="text" class="text" size="97" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.[GENERAL.ANAMNESE]ITEM_TYPE_SOCIAL_AND_FAMILIAL_STATUS" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.[GENERAL.ANAMNESE]ITEM_TYPE_SOCIAL_AND_FAMILIAL_STATUS" property="value"/>" onblur="limitLength(this);"></td>
        </tr>
        <tr>
            <td class="admin"><%=getTran("Web.Occup","medwan.healthrecord.anamnese.general.sports",sWebLanguage)%></td>
            <td class="admin2">
                <select <%=setRightClick("ITEM_TYPE_CE_ANAMNESE_SPORT")%> id="EditSports" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CE_ANAMNESE_SPORT" property="itemId"/>]>.value" class="text">
                    <option/>
                    <option value="1">0</option>
                    <option value="2">0 - 1</option>
                    <option value="3">1 - 2</option>
                    <option value="4">2 - 3</option>
                    <option value="5">3 - 1</option>
                    <option value="6">&gt; 4</option>
                </select>
                &nbsp;&nbsp;<%=getTran("Web.Occup","hoursAWeek",sWebLanguage)%>
                <input <%=setRightClick("[GENERAL.ANAMNESE]ITEM_TYPE_SPORTS")%> type="text" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.[GENERAL.ANAMNESE]ITEM_TYPE_SPORTS" property="itemId"/>]>.value" class="text" size="40" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.[GENERAL.ANAMNESE]ITEM_TYPE_SPORTS" property="value"/>" onblur="limitLength(this);">
            </td>
        </tr>
        <tr>
            <td class="admin"><%=getTran("Web.Occup","medwan.healthrecord.anamnese.general.work-conditions",sWebLanguage)%></td>
            <td class="admin2">
                <textarea onKeyup="resizeTextarea(this,10);limitChars(this,255);" <%=setRightClick("[GENERAL.ANAMNESE]ITEM_TYPE_WORKCONDITIONS")%> class="text" rows="2" cols="95" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.[GENERAL.ANAMNESE]ITEM_TYPE_WORKCONDITIONS" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.[GENERAL.ANAMNESE]ITEM_TYPE_WORKCONDITIONS" property="value"/></textarea>
            </td>
        </tr>
        <tr>
            <td class="admin"><%=getTran("Web.Occup","medwan.healthrecord.anamnese.general.complaints",sWebLanguage)%></td>
            <td class="admin2">
                <textarea onKeyup="resizeTextarea(this,10);limitChars(this,255);" <%=setRightClick("[GENERAL.ANAMNESE]ITEM_TYPE_COMPLAINTS")%> class="text" rows="2" cols="95" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.[GENERAL.ANAMNESE]ITEM_TYPE_COMPLAINTS" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.[GENERAL.ANAMNESE]ITEM_TYPE_COMPLAINTS" property="value"/></textarea>
            </td>
        </tr>
    </table>

    <%
        ScreenHelper.setIncludePage(customerInclude("healthrecord/clinicalExamination1.jsp"),pageContext);
        ScreenHelper.setIncludePage(customerInclude("healthrecord/clinicalExamination2.jsp"),pageContext);
        ScreenHelper.setIncludePage(customerInclude("healthrecord/clinicalExamination3.jsp"),pageContext);
        ScreenHelper.setIncludePage(customerInclude("healthrecord/clinicalExamination4.jsp"),pageContext);
    %>

<script>
  iAlcohol = "<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.[GENERAL.ANAMNESE]ITEM_TYPE_ALCOHOL_USAGE" property="value"/>";
  iSmoking = "<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.[GENERAL.ANAMNESE]ITEM_TYPE_TOBACCO_USAGE" property="value"/>";
  transactionForm.EditAlcohol.selectedIndex = iAlcohol;
  transactionForm.EditSmoking.selectedIndex = iSmoking;
</script>

<%-- BUTTONS --%>
<%=ScreenHelper.alignButtonsStart()%>
    <INPUT class="button" type="button" value="<%=getTranNoLink("Web.Occup","medwan.common.limited",sWebLanguage)%>" onclick="window.location.href='healthrecord/manageClinicalExamination.do?ts=<%=getTs()%>'">
<%
    if ((activeUser.getAccessRight("occupgeneralclinicalexamination.add"))||(activeUser.getAccessRight("occupgeneralclinicalexamination.edit"))) {
%>
        <INPUT class="button" type="button" name="saveButton" id="save" onClick="submitForm();" value="<%=getTranNoLink("Web.Occup","medwan.common.record",sWebLanguage)%>">
<%
    }
%>
    <INPUT class="button" type="button" value="<%=getTranNoLink("Web","Back",sWebLanguage)%>" onclick="window.location.href='<c:url value='/healthrecord/managePeriodicExaminations.do'/>?ts=<%=getTs()%>'">
<%=ScreenHelper.alignButtonsStop()%>

<script>
  function submitForm(){
    transactionForm.saveButton.disabled = true;
    <%
        SessionContainerWO sessionContainerWO = (SessionContainerWO)SessionContainerFactory.getInstance().getSessionContainerWO(request,SessionContainerWO.class.getName());
        out.println(takeOverTransaction(sessionContainerWO, activeUser,"document.transactionForm.submit();"));
    %>
  }
</script>

</form>
<%=writeJSButtons("transactionForm","saveButton")%>