<%@include file="/includes/validateUser.jsp"%>
<%@page errorPage="/includes/error.jsp"%>
<%=checkPermission("occup.intensivecare.daily.note","select",activeUser)%>

<form id="transactionForm" name="transactionForm" method="POST" action='<c:url value="/healthrecord/updateTransaction.do"/>?ts=<%=getTs()%>' onclick="setSaveButton(event);" onkeyup="setSaveButton(event);">
    <bean:define id="transaction" name="be.mxs.webapp.wl.session.SessionContainerFactory.WO_SESSION_CONTAINER" property="currentTransactionVO"/>
	<%=checkPrestationToday(activePatient.personid,false,activeUser,(TransactionVO)transaction)%>
   
    <input type="hidden" id="transactionId" name="currentTransactionVO.<TransactionVO[hashCode=<bean:write name="transaction" scope="page" property="transactionId"/>]>.transactionId" value="<bean:write name="transaction" scope="page" property="transactionId"/>"/>
    <input type="hidden" id="serverId" name="currentTransactionVO.<TransactionVO[hashCode=<bean:write name="transaction" scope="page" property="transactionId"/>]>.serverId" value="<bean:write name="transaction" scope="page" property="serverId"/>"/>
    <input type="hidden" id="transactionType" name="currentTransactionVO.<TransactionVO[hashCode=<bean:write name="transaction" scope="page" property="transactionId"/>]>.transactionType" value="<bean:write name="transaction" scope="page" property="transactionType"/>"/>
    <input type="hidden" readonly name="be.mxs.healthrecord.updateTransaction.actionForwardKey" value="/main.do?Page=curative/index.jsp&ts=<%=getTs()%>"/>
    <input type="hidden" readonly name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CONTEXT_DEPARTMENT" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CONTEXT_DEPARTMENT" translate="false" property="value"/>"/>
    <input type="hidden" readonly name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CONTEXT_CONTEXT" translate="false" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CONTEXT_CONTEXT" translate="false" property="value"/>"/>

    <%=writeHistoryFunctions(((TransactionVO)transaction).getTransactionType(),sWebLanguage)%>
    <%=contextHeader(request,sWebLanguage)%>

    <%
        TransactionVO tran = (TransactionVO)transaction;
    
        String sBilanDrains             = getItemType(tran.getItems(),sPREFIX+"ITEM_TYPE_DAILY_NOTE_BILAN_DRAINS"),
               sBilanIn                 = getItemType(tran.getItems(),sPREFIX+"ITEM_TYPE_DAILY_NOTE_BILAN_IN"),
               sDiurese                 = getItemType(tran.getItems(),sPREFIX+"ITEM_TYPE_DAILY_NOTE_DIURESE"),
               sBilanSondeNasoGastrique = getItemType(tran.getItems(),sPREFIX+"ITEM_TYPE_DAILY_NOTE_BILAN_SONDE_NASOGASTRIQUE"),
               sParameterT              = getItemType(tran.getItems(),sPREFIX+"ITEM_TYPE_DAILY_NOTE_PARAMETER_T"),
               sParameterTA             = getItemType(tran.getItems(),sPREFIX+"ITEM_TYPE_DAILY_NOTE_PARAMETER_TA"),
               sParameterRC             = getItemType(tran.getItems(),sPREFIX+"ITEM_TYPE_DAILY_NOTE_PARAMETER_RC"),
               sParameterRR             = getItemType(tran.getItems(),sPREFIX+"ITEM_TYPE_DAILY_NOTE_PARAMETER_RR"),
               sParameterSAT            = getItemType(tran.getItems(),sPREFIX+"ITEM_TYPE_DAILY_NOTE_PARAMETER_SAT"),
               sParameterFIO2           = getItemType(tran.getItems(),sPREFIX+"ITEM_TYPE_DAILY_NOTE_PARAMETER_FIO2"),
               sVomissements            = getItemType(tran.getItems(),sPREFIX+"ITEM_TYPE_DAILY_NOTE_VOMISSEMENTS"),
               sSelles                  = getItemType(tran.getItems(),sPREFIX+"ITEM_TYPE_DAILY_NOTE_SELLES"),
               sDiarrhee                = getItemType(tran.getItems(),sPREFIX+"ITEM_TYPE_DAILY_NOTE_DIARRHEE"),
               sName                    = getItemType(tran.getItems(),sPREFIX+"ITEM_TYPE_DAILY_NOTE_NAME"),
               sFirstname               = getItemType(tran.getItems(),sPREFIX+"ITEM_TYPE_DAILY_NOTE_FIRSTNAME"),
               sDayHospitalizedHospital = getItemType(tran.getItems(),sPREFIX+"ITEM_TYPE_DAILY_NOTE_DAY_HOSPITALIZED_HOSPITAL"),
               sDayHospitalizedUsi      = getItemType(tran.getItems(),sPREFIX+"ITEM_TYPE_DAILY_NOTE_DAY_HOSPITALIZED_USI"),
               sDateHourNote            = getItemType(tran.getItems(),sPREFIX+"ITEM_TYPE_DAILY_NOTE_DATE_HOUR_NOTE");
    %>

    <table class="list" width="100%" cellspacing="1">
        <%-- DATE --%>
        <tr>
            <td class="admin">
                <a href="javascript:openHistoryPopup();" title="<%=getTranNoLink("Web.Occup","History",sWebLanguage)%>">...</a>&nbsp;
                <%=getTran("Web.Occup","medwan.common.date",sWebLanguage)%>
            </td>
            <td class="admin2" colspan="3">
                <input type="text" class="text" size="12" maxLength="10" name="currentTransactionVO.<TransactionVO[hashCode=<bean:write name="transaction" scope="page" property="transactionId"/>]>.updateTime" value="<mxs:propertyAccessorI18N name="transaction" scope="page" property="updateTime" formatType="date"/>" id="trandate" OnBlur='checkDate(this)'>
                <script>writeTranDate();</script>
            </td>
        </tr>

        <%-- GENERAL INFO -----------------------------------------------------------------------%>
        <tr>
            <td colspan="4">&nbsp;</td>
        </tr>
        <tr class="admin">
            <td colspan="4">&nbsp;</td>
        </tr>
        <tr>
            <td class="admin" width="<%=sTDAdminWidth%>"><%=getTran("openclinic.chuk","name",sWebLanguage)%></td>
            <td class="admin2">
                <input <%=setRightClick("ITEM_TYPE_DAILY_NOTE_NAME")%> type="text" class="text" size="50" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DAILY_NOTE_NAME" property="itemId"/>]>.value" value="<%=sName%>">
            </td>
            <td class="admin" width="<%=sTDAdminWidth%>"><%=getTran("openclinic.chuk","firstname",sWebLanguage)%></td>
            <td class="admin2">
                <input <%=setRightClick("ITEM_TYPE_DAILY_NOTE_FIRSTNAME")%> type="text" class="text" size="50" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DAILY_NOTE_FIRSTNAME" property="itemId"/>]>.value" value="<%=sFirstname%>">
            </td>
        </tr>

        <tr>
            <td class="admin"><%=getTran("openclinic.chuk","day_hospitalized_usi",sWebLanguage)%></td>
            <td class="admin2">
                <input <%=setRightClick("ITEM_TYPE_DAILY_NOTE_DAY_HOSPITALIZED_USI")%> type="text" class="text" size="50" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DAILY_NOTE_DAY_HOSPITALIZED_USI" property="itemId"/>]>.value" value="<%=sDayHospitalizedUsi%>">
            </td>
            <td class="admin"><%=getTran("openclinic.chuk","day_hospitalized_hospital",sWebLanguage)%></td>
            <td class="admin2">
                <input <%=setRightClick("ITEM_TYPE_DAILY_NOTE_DAY_HOSPITALIZED_HOSPITAL")%> type="text" class="text" size="50" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DAILY_NOTE_DAY_HOSPITALIZED_HOSPITAL" property="itemId"/>]>.value" value="<%=sDayHospitalizedHospital%>">
            </td>
        </tr>

        <tr>
            <td class="admin"><%=getTran("openclinic.chuk","date_hour_note",sWebLanguage)%></td>
            <td class="admin2">
                <input <%=setRightClick("ITEM_TYPE_DAILY_NOTE_DATE_HOUR_NOTE")%> type="text" class="text" size="50" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DAILY_NOTE_DATE_HOUR_NOTE" property="itemId"/>]>.value" value="<%=sDateHourNote%>">
            </td>
            <td class="admin">&nbsp;</td>
            <td class="admin2">&nbsp;</td>
        </tr>

        <%-- Admission Note ---------------------------------------------------------------------%>
        <tr>
            <td colspan="4">&nbsp;</td>
        </tr>
        <tr class="admin">
            <td colspan="4"><%=getTran("openclinic.chuk","admission_note",sWebLanguage)%></td>
        </tr>

        <tr>
            <td class="admin"><%=getTran("openclinic.chuk","datetime_admission_hospitalized",sWebLanguage)%></td>
            <td class="admin2">
                <textarea onkeyup="resizeTextarea(this,10);limitChars(this,255);" <%=setRightClick("ITEM_TYPE_DAILY_NOTE_DATETIME_ADMISSION_HOSPITALIZED")%> class="text" cols="50" rows="2"  name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DAILY_NOTE_DATETIME_ADMISSION_HOSPITALIZED" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DAILY_NOTE_DATETIME_ADMISSION_HOSPITALIZED" property="value"/></textarea>
            </td>
            <td class="admin" width="<%=sTDAdminWidth%>"><%=getTran("openclinic.chuk","coming_from",sWebLanguage)%></td>
            <td class="admin2">
                <textarea onkeyup="resizeTextarea(this,10);limitChars(this,255);" <%=setRightClick("ITEM_TYPE_DAILY_NOTE_COMING_FROM")%> class="text" cols="50" rows="2"  name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DAILY_NOTE_COMING_FROM" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DAILY_NOTE_COMING_FROM" property="value"/></textarea>
            </td>
        </tr>

        <tr>
            <td class="admin"><%=getTran("openclinic.chuk","reason_admission",sWebLanguage)%></td>
            <td class="admin2">
                <textarea onkeyup="resizeTextarea(this,10);limitChars(this,255);" <%=setRightClick("ITEM_TYPE_DAILY_NOTE_REASON_ADMISSION")%> class="text" cols="50" rows="2"  name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DAILY_NOTE_REASON_ADMISSION" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DAILY_NOTE_REASON_ADMISSION" property="value"/></textarea>
            </td>
            <td class="admin"><%=getTran("openclinic.chuk","history",sWebLanguage)%></td>
            <td class="admin2">
                <textarea onkeyup="resizeTextarea(this,10);limitChars(this,255);" <%=setRightClick("ITEM_TYPE_DAILY_NOTE_HISTORY")%> class="text" cols="50" rows="2"  name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DAILY_NOTE_HISTORY" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DAILY_NOTE_HISTORY" property="value"/></textarea>
            </td>
        </tr>

        <tr>
            <td class="admin"><%=getTran("openclinic.chuk","atcd",sWebLanguage)%></td>
            <td class="admin2">
                <textarea onkeyup="resizeTextarea(this,10);limitChars(this,255);" <%=setRightClick("ITEM_TYPE_DAILY_NOTE_ATCD")%> class="text" cols="50" rows="2"  name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DAILY_NOTE_ATCD" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DAILY_NOTE_ATCD" property="value"/></textarea>
            </td>
            <td class="admin"><%=getTran("openclinic.chuk","physical_exam",sWebLanguage)%></td>
            <td class="admin2">
                <textarea onkeyup="resizeTextarea(this,10);limitChars(this,255);" <%=setRightClick("ITEM_TYPE_DAILY_NOTE_PHYSICAL_EXAM")%> class="text" cols="50" rows="2"  name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DAILY_NOTE_PHYSICAL_EXAM" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DAILY_NOTE_PHYSICAL_EXAM" property="value"/></textarea>
            </td>
        </tr>

        <tr>
            <td class="admin"><%=getTran("openclinic.chuk","supplementary_exams",sWebLanguage)%></td>
            <td class="admin2">
                <textarea onkeyup="resizeTextarea(this,10);limitChars(this,255);" <%=setRightClick("ITEM_TYPE_DAILY_NOTE_SUPPLEMENTARY_EXAM")%> class="text" cols="50" rows="2"  name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DAILY_NOTE_SUPPLEMENTARY_EXAM" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DAILY_NOTE_SUPPLEMENTARY_EXAM" property="value"/></textarea>
            </td>
            <td class="admin"><%=getTran("openclinic.chuk","diff_diagnosis",sWebLanguage)%></td>
            <td class="admin2">
                <textarea onkeyup="resizeTextarea(this,10);limitChars(this,255);" <%=setRightClick("ITEM_TYPE_DAILY_NOTE_DIFF_DIAGNOSIS")%> class="text" cols="50" rows="2"  name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DAILY_NOTE_DIFF_DIAGNOSIS" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DAILY_NOTE_DIFF_DIAGNOSIS" property="value"/></textarea>
            </td>
        </tr>

        <tr>
            <td class="admin"><%=getTran("openclinic.chuk","cat",sWebLanguage)%></td>
            <td class="admin2">
                <textarea onkeyup="resizeTextarea(this,10);limitChars(this,255);" <%=setRightClick("ITEM_TYPE_DAILY_NOTE_CAT")%> class="text" cols="50" rows="2"  name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DAILY_NOTE_CAT" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DAILY_NOTE_CAT" property="value"/></textarea>
            </td>
            <td class="admin"><%=getTran("openclinic.chuk","treatment",sWebLanguage)%></td>
            <td class="admin2">
                <textarea onkeyup="resizeTextarea(this,10);limitChars(this,255);" <%=setRightClick("ITEM_TYPE_DAILY_NOTE_TREATMENT")%> class="text" cols="50" rows="2"  name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DAILY_NOTE_TREATMENT" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DAILY_NOTE_TREATMENT" property="value"/></textarea>
            </td>
        </tr>

        <%-- TO DO --%>
        <tr>
            <td class="admin"><%=getTran("openclinic.chuk","todo",sWebLanguage)%></td>
            <td class="admin2">
                <textarea onkeyup="resizeTextarea(this,10);limitChars(this,255);" <%=setRightClick("ITEM_TYPE_DAILY_NOTE_TODO")%> class="text" cols="50" rows="2"  name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DAILY_NOTE_TODO" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DAILY_NOTE_TODO" property="value"/></textarea>
            </td>
            <td class="admin"></td>
            <td class="admin2"></td>
        </tr>

        <%-- Observation ------------------------------------------------------------------------%>
        <tr>
            <td colspan="4">&nbsp;</td>
        </tr>
        <tr class="admin">
            <td colspan="4"><%=getTran("openclinic.chuk","observation",sWebLanguage)%></td>
        </tr>

        <tr>
            <td class="admin"><%=getTran("openclinic.chuk","observation",sWebLanguage)%></td>
            <td class="admin2">
                <textarea onkeyup="resizeTextarea(this,10);limitChars(this,255);" <%=setRightClick("ITEM_TYPE_DAILY_NOTE_OBSERVATION")%> class="text" cols="50" rows="2"  name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DAILY_NOTE_OBSERVATION" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DAILY_NOTE_OBSERVATION" property="value"/></textarea>
            </td>
            <td class="admin"><%=getTran("openclinic.chuk","opinion_specialists",sWebLanguage)%></td>
            <td class="admin2">
                <textarea onkeyup="resizeTextarea(this,10);limitChars(this,255);" <%=setRightClick("ITEM_TYPE_DAILY_NOTE_OPINION_SPECIALISTS")%> class="text" cols="50" rows="2"  name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DAILY_NOTE_OPINION_SPECIALISTS" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DAILY_NOTE_OPINION_SPECIALISTS" property="value"/></textarea>
            </td>
        </tr>

        <tr>
            <td class="admin"><%=getTran("openclinic.chuk","labo_results",sWebLanguage)%></td>
            <td class="admin2">
                <textarea onkeyup="resizeTextarea(this,10);limitChars(this,255);" <%=setRightClick("ITEM_TYPE_DAILY_NOTE_LABO_RESULTS")%> class="text" cols="50" rows="2"  name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DAILY_NOTE_LABO_RESULTS" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DAILY_NOTE_LABO_RESULTS" property="value"/></textarea>
            </td>
            <td class="admin"><%=getTran("openclinic.chuk","other_results",sWebLanguage)%></td>
            <td class="admin2">
                <textarea onkeyup="resizeTextarea(this,10);limitChars(this,255);" <%=setRightClick("ITEM_TYPE_DAILY_NOTE_OTHER_RESULTS")%> class="text" cols="50" rows="2"  name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DAILY_NOTE_OTHER_RESULTS" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DAILY_NOTE_OTHER_RESULTS" property="value"/></textarea>
            </td>
        </tr>

        <%-- Summary ----------------------------------------------------------------------------%>
        <tr>
            <td colspan="4">&nbsp;</td>
        </tr>
        <tr class="admin">
            <td colspan="4"><%=getTran("openclinic.chuk","summary",sWebLanguage)%></td>
        </tr>
        <tr>
            <td class="admin"/>
            <td class="admin2">
                <textarea onkeyup="resizeTextarea(this,10);limitChars(this,255);" <%=setRightClick("ITEM_TYPE_DAILY_NOTE_SUMMARY")%> class="text" cols="50" rows="2"  name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DAILY_NOTE_SUMMARY" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DAILY_NOTE_SUMMARY" property="value"/></textarea>
            </td>
            <td class="admin"/>
            <td class="admin2"/>
        </tr>

        <%-- Morning parameters -----------------------------------------------------------------%>
        <tr>
            <td colspan="4">&nbsp;</td>
        </tr>
        <tr class="admin">
            <td colspan="4"><%=getTran("openclinic.chuk","morning_parameters",sWebLanguage)%></td>
        </tr>

        <tr>
            <td class="admin"><%=getTran("openclinic.chuk","parameter_t",sWebLanguage)%></td>
            <td class="admin2">
                <input <%=setRightClick("ITEM_TYPE_DAILY_NOTE_PARAMETER_T")%> type="text" class="text" size="4" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DAILY_NOTE_PARAMETER_T" property="itemId"/>]>.value" value="<%=sParameterT%>" onblur="isNumber(this);"> °C
            </td>
            <td class="admin"><%=getTran("openclinic.chuk","parameter_rc",sWebLanguage)%></td>
            <td class="admin2">
                <input <%=setRightClick("ITEM_TYPE_DAILY_NOTE_PARAMETER_RC")%> type="text" class="text" size="4" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DAILY_NOTE_PARAMETER_RC" property="itemId"/>]>.value" value="<%=sParameterRC%>" onblur="isNumber(this);"> /min
            </td>
        </tr>

        <tr>
            <td class="admin"><%=getTran("openclinic.chuk","parameter_ta",sWebLanguage)%></td>
            <td class="admin2">
                <input <%=setRightClick("ITEM_TYPE_DAILY_NOTE_PARAMETER_TA")%> type="text" class="text" size="4" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DAILY_NOTE_PARAMETER_TA" property="itemId"/>]>.value" value="<%=sParameterTA%>" onblur="isNumber(this);"> mmHg
            </td>
            <td class="admin"><%=getTran("openclinic.chuk","parameter_rr",sWebLanguage)%></td>
            <td class="admin2">
                <input <%=setRightClick("ITEM_TYPE_DAILY_NOTE_PARAMETER_RR")%> type="text" class="text" size="4" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DAILY_NOTE_PARAMETER_RR" property="itemId"/>]>.value" value="<%=sParameterRR%>" onblur="isNumber(this);"> /min
            </td>
        </tr>

        <tr>
            <td class="admin"><%=getTran("openclinic.chuk","parameter_Sat",sWebLanguage)%></td>
            <td class="admin2">
                <input <%=setRightClick("ITEM_TYPE_DAILY_NOTE_PARAMETER_SAT")%> type="text" class="text" size="4" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DAILY_NOTE_PARAMETER_SAT" property="itemId"/>]>.value" value="<%=sParameterSAT%>" onblur="isNumber(this);"> %
            </td>
            <td class="admin"><%=getTran("openclinic.chuk","parameter_fio2",sWebLanguage)%></td>
            <td class="admin2">
                <input <%=setRightClick("ITEM_TYPE_DAILY_NOTE_PARAMETER_FIO2")%> type="text" class="text" size="4" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DAILY_NOTE_PARAMETER_FIO2" property="itemId"/>]>.value" value="<%=sParameterFIO2%>" onblur="isNumber(this);"> ml
            </td>
        </tr>

        <%-- remarks --%>
        <tr>
            <td class="admin"><%=getTran("openclinic.chuk","remarks",sWebLanguage)%></td>
            <td class="admin2">
                <textarea onkeyup="resizeTextarea(this,10);limitChars(this,255);" <%=setRightClick("ITEM_TYPE_DAILY_NOTE_PARAMETER_REMARKS")%> class="text" cols="50" rows="2"  name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DAILY_NOTE_PARAMETER_REMARKS" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DAILY_NOTE_PARAMETER_REMARKS" property="value"/></textarea>
            </td>
            <td class="admin"/>
            <td class="admin2"/>
        </tr>

        <%-- BILAN IN --%>
        <tr>
            <td class="admin"><%=getTran("openclinic.chuk","bilan_in",sWebLanguage)%></td>
            <td class="admin2">
                <input <%=setRightClick("ITEM_TYPE_DAILY_NOTE_BILAN_IN")%> type="text" class="text" size="50" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DAILY_NOTE_BILAN_IN" property="itemId"/>]>.value" value="<%=sBilanIn%>">
            </td>
            <td class="admin"/>
            <td class="admin2"/>
        </tr>

        <%-- BILAN OUT --%>
        <tr class="admin">
            <td colspan="4"><%=getTran("openclinic.chuk","bilan_out",sWebLanguage)%></td>
        </tr>
        <tr>
            <td class="admin"><%=getTran("openclinic.chuk","diurese",sWebLanguage)%></td>
            <td class="admin2">
                <input <%=setRightClick("ITEM_TYPE_DAILY_NOTE_DIURESE")%> type="text" class="text" size="4" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DAILY_NOTE_DIURESE" property="itemId"/>]>.value" value="<%=sDiurese%>" onblur="isNumber(this);"> (ml/kg/h)
            </td>
            <td class="admin"><%=getTran("openclinic.chuk","bilan_drains",sWebLanguage)%></td>
            <td class="admin2">
                <input <%=setRightClick("ITEM_TYPE_DAILY_NOTE_BILAN_DRAINS")%> type="text" class="text" size="4" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DAILY_NOTE_BILAN_DRAINS" property="itemId"/>]>.value" value="<%=sBilanDrains%>" onblur="isNumber(this);"> (ml)
            </td>
        </tr>

        <tr>
            <td class="admin"><%=getTran("openclinic.chuk","bilan_sonde_nasogastrique",sWebLanguage)%></td>
            <td class="admin2">
                <input <%=setRightClick("ITEM_TYPE_DAILY_NOTE_BILAN_SONDE_NASOGASTRIQUE")%> type="text" class="text" size="4" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DAILY_NOTE_BILAN_SONDE_NASOGASTRIQUE" property="itemId"/>]>.value" value="<%=sBilanSondeNasoGastrique%>" onblur="isNumber(this);"> (ml)
            </td>
            <td class="admin"><%=getTran("openclinic.chuk","vomissements",sWebLanguage)%></td>
            <td class="admin2">
                <input <%=setRightClick("ITEM_TYPE_DAILY_NOTE_VOMISSEMENTS")%> type="text" class="text" size="4" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DAILY_NOTE_VOMISSEMENTS" property="itemId"/>]>.value" value="<%=sVomissements%>" onblur="isNumber(this);"> (ml)
            </td>
        </tr>

        <tr>
            <td class="admin"><%=getTran("openclinic.chuk","selles",sWebLanguage)%></td>
            <td class="admin2">
                <input <%=setRightClick("ITEM_TYPE_DAILY_NOTE_SELLES")%> type="text" class="text" size="4" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DAILY_NOTE_SELLES" property="itemId"/>]>.value" value="<%=sSelles%>" onblur="isNumber(this);"> (ml)
            </td>
            <td class="admin"><%=getTran("openclinic.chuk","diarrhée",sWebLanguage)%></td>
            <td class="admin2">
                <input <%=setRightClick("ITEM_TYPE_DAILY_NOTE_DIARRHEE")%> type="text" class="text" size="4" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DAILY_NOTE_DIARRHEE" property="itemId"/>]>.value" value="<%=sDiarrhee%>" onblur="isNumber(this);"> (ml)
            </td>
        </tr>

        <%-- remarks --%>
        <tr>
            <td class="admin"><%=getTran("openclinic.chuk","remarks",sWebLanguage)%></td>
            <td class="admin2">
                <textarea onkeyup="resizeTextarea(this,10);limitChars(this,255);" <%=setRightClick("ITEM_TYPE_DAILY_NOTE_PARAMETER_REMARKS2")%> class="text" cols="50" rows="2"  name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DAILY_NOTE_PARAMETER_REMARKS2" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DAILY_NOTE_PARAMETER_REMARKS2" property="value"/></textarea>
            </td>
            <td class="admin"/>
            <td class="admin2"/>
        </tr>

        <%-- Medical acts -----------------------------------------------------------------------%>
        <tr>
            <td colspan="4">&nbsp;</td>
        </tr>
        <tr class="admin">
            <td colspan="4"><%=getTran("openclinic.chuk","medical_acts",sWebLanguage)%></td>
        </tr>
        <tr>
            <td class="admin"/>
            <td class="admin2">
                <textarea onkeyup="resizeTextarea(this,10);limitChars(this,255);" <%=setRightClick("ITEM_TYPE_DAILY_NOTE_MEDICAL_ACTS")%> class="text" cols="50" rows="2"  name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DAILY_NOTE_MEDICAL_ACTS" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DAILY_NOTE_MEDICAL_ACTS" property="value"/></textarea>
            </td>
            <td class="admin"/>
            <td class="admin2"/>
        </tr>

        <%-- Adjustment -------------------------------------------------------------------------%>
        <tr>
            <td colspan="4">&nbsp;</td>
        </tr>
        <tr class="admin">
            <td colspan="4"><%=getTran("openclinic.chuk","adjustment",sWebLanguage)%></td>
        </tr>
        <tr>
            <td class="admin"/>
            <td class="admin2">
                <textarea onkeyup="resizeTextarea(this,10);limitChars(this,255);" <%=setRightClick("ITEM_TYPE_DAILY_NOTE_ADJUSTMENT")%> class="text" cols="50" rows="2"  name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DAILY_NOTE_ADJUSTMENT" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DAILY_NOTE_ADJUSTMENT" property="value"/></textarea>
            </td>
            <td class="admin"/>
            <td class="admin2"/>
        </tr>

        <%-- CONDUITE A TENIR -------------------------------------------------------------------%>
        <tr>
            <td colspan="4">&nbsp;</td>
        </tr>
        <tr class="admin">
            <td colspan="4"><%=getTran("openclinic.chuk","conduite_a_tenir",sWebLanguage)%></td>
        </tr>
        <tr>
            <td class="admin"/>
            <td class="admin2">
                <textarea onkeyup="resizeTextarea(this,10);limitChars(this,255);" <%=setRightClick("ITEM_TYPE_DAILY_NOTE_CONDUITE_A_TENIR")%> class="text" cols="50" rows="2"  name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DAILY_NOTE_CONDUITE_A_TENIR" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DAILY_NOTE_CONDUITE_A_TENIR" property="value"/></textarea>
            </td>
            <td class="admin"/>
            <td class="admin2"/>
        </tr>

        <%-- TO DO ------------------------------------------------------------------------------%>
        <tr>
            <td colspan="4">&nbsp;</td>
        </tr>
        <tr class="admin">
            <td colspan="4"><%=getTran("openclinic.chuk","todo",sWebLanguage)%></td>
        </tr>
        <tr>
            <td class="admin" width="<%=sTDAdminWidth%>"><%=getTran("openclinic.chuk","what",sWebLanguage)%></td>
            <td class="admin2">
                <textarea onkeyup="resizeTextarea(this,10);limitChars(this,255);" <%=setRightClick("ITEM_TYPE_DAILY_NOTE_TODO_WHAT")%> class="text" cols="50" rows="2"  name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DAILY_NOTE_TODO_WHAT" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DAILY_NOTE_TODO_WHAT" property="value"/></textarea>
            </td>
            <td class="admin" width="<%=sTDAdminWidth%>"><%=getTran("openclinic.chuk","when",sWebLanguage)%></td>
            <td class="admin2">
                <textarea onkeyup="resizeTextarea(this,10);limitChars(this,255);" <%=setRightClick("ITEM_TYPE_DAILY_NOTE_TODO_WHEN")%> class="text" cols="50" rows="2"  name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DAILY_NOTE_TODO_WHEN" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DAILY_NOTE_TODO_WHEN" property="value"/></textarea>
            </td>
        </tr>

        <%-- LABO -------------------------------------------------------------------------------%>
        <tr>
            <td class="admin"><%=getTran("openclinic.chuk","labo",sWebLanguage)%></td>
            <td class="admin2">
                <textarea onkeyup="resizeTextarea(this,10);limitChars(this,255);" <%=setRightClick("ITEM_TYPE_DAILY_NOTE_TODO_LABO")%> class="text" cols="50" rows="2"  name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DAILY_NOTE_TODO_LABO" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DAILY_NOTE_TODO_LABO" property="value"/></textarea>
            </td>
            <td class="admin"><%=getTran("openclinic.chuk","imaginary",sWebLanguage)%></td>
            <td class="admin2">
                <textarea onkeyup="resizeTextarea(this,10);limitChars(this,255);" <%=setRightClick("ITEM_TYPE_DAILY_NOTE_TODO_IMAGINARY")%> class="text" cols="50" rows="2"  name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DAILY_NOTE_TODO_IMAGINARY" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DAILY_NOTE_TODO_IMAGINARY" property="value"/></textarea>
            </td>
        </tr>

        <%-- other --%>
        <tr>
            <td class="admin"><%=getTran("openclinic.chuk","other",sWebLanguage)%></td>
            <td class="admin2">
                <textarea onkeyup="resizeTextarea(this,10);limitChars(this,255);" <%=setRightClick("ITEM_TYPE_DAILY_NOTE_TODO_OTHER")%> class="text" cols="50" rows="2"  name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DAILY_NOTE_TODO_OTHER" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DAILY_NOTE_TODO_OTHER" property="value"/></textarea>
            </td>
            <td class="admin"/>
            <td class="admin2"/>
        </tr>

        <%-- REMARKS ----------------------------------------------------------------------------%>
        <tr>
            <td colspan="4">&nbsp;</td>
        </tr>
        <tr class="admin">
            <td colspan="4"><%=getTran("openclinic.chuk","REMARKS",sWebLanguage)%></td>
        </tr>
        <tr>
            <td class="admin"/>
            <td class="admin2" style="vertical-align:top;">
                <textarea onkeyup="resizeTextarea(this,10);limitChars(this,255);" <%=setRightClick("ITEM_TYPE_DAILY_NOTE_REMARKS")%> class="text" cols="50" rows="2"  name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DAILY_NOTE_REMARKS" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DAILY_NOTE_REMARKS" property="value"/></textarea>
            </td>
	        <td class="admin2" colspan="2">
	             <%ScreenHelper.setIncludePage(customerInclude("healthrecord/diagnosesEncoding.jsp"),pageContext);%>
	        </td>
        </tr>
    </table>

    <%-- BUTTONS --%>
    <%=ScreenHelper.alignButtonsStart()%>                    
	    <%=getButtonsHtml(request,activeUser,activePatient,"occup.intensivecare.daily.note",sWebLanguage)%>
    <%=ScreenHelper.alignButtonsStop()%>

    <%=ScreenHelper.contextFooter(request)%>
</form>

<script>
  <%-- SUBMIT FORM --%>
  function submitForm(){
    if(document.getElementById('encounteruid').value==''){
      alertDialog("web","no.encounter.linked");
	  searchEncounter();
	}	
    else{
	  var temp = Form.findFirstElement(transactionForm);//for ff compatibility
	  document.getElementById("buttonsDiv").style.visibility = "hidden";
	  document.transactionForm.submit();
    }
  }
  
  function searchEncounter(){
    openPopup("/_common/search/searchEncounter.jsp&ts=<%=getTs()%>&VarCode=currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CONTEXT_ENCOUNTERUID" property="itemId"/>]>.value&VarText=&FindEncounterPatient=<%=activePatient.personid%>");
  }
  
  if(document.getElementById('encounteruid').value==''){
	alertDialog("web","no.encounter.linked");
	searchEncounter();
  }  
</script>

<%=writeJSButtons("transactionForm","saveButton")%>