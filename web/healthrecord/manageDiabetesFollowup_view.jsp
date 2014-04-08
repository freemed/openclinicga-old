<%@ page import="java.util.*" %>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>
<%=checkPermission("occup.diabetesfollowup","select",activeUser)%>
<%=sJSDIAGRAM%>
<%
    // min/max glycemy
    int minValueYGly = MedwanQuery.getInstance().getConfigInt("minValueY_glycemy");
    if(minValueYGly < 0) minValueYGly = 0; // default

    int maxValueYGly = MedwanQuery.getInstance().getConfigInt("maxValueY_glycemy");
    if(maxValueYGly < 0) maxValueYGly = 350; // default

    // min/max insuline
    int minValueYIns = MedwanQuery.getInstance().getConfigInt("minValueY_insuline");
    if(minValueYIns < 0) minValueYIns = 0; // default

    int maxValueYIns = MedwanQuery.getInstance().getConfigInt("maxValueY_insuline");
    if(maxValueYIns < 0) maxValueYIns = 350; // default

    SimpleDateFormat stdDateFormat = new SimpleDateFormat("dd/MM/yyyy");
    java.util.Date date;
    String value;

    int minGlycemy = minValueYGly;
    int maxGlycemy = maxValueYGly;

    String glycemyMsg = getTranNoLink("Web.Occup","medwan.healthrecord.glycemy.validationerror",sWebLanguage);
    glycemyMsg = glycemyMsg.replaceAll("#min#",minGlycemy+"");
    glycemyMsg = glycemyMsg.replaceAll("#max#",maxGlycemy+"");

    int minInsuline = minValueYIns;
    int maxInsuline = maxValueYIns;

    String insulineMsg = getTranNoLink("Web.Occup","medwan.healthrecord.insuline.validationerror",sWebLanguage);
    insulineMsg = insulineMsg.replaceAll("#min#",minInsuline+"");
    insulineMsg = insulineMsg.replaceAll("#max#",maxInsuline+"");
%>
<script>
  <%-- VALIDATE GLYCEMY --%>
  function validateGlycemy(inputObj){
    inputObj.value = inputObj.value.replace(",",".");
    if(inputObj.value.length > 0){
      var min = <%=minGlycemy%>;
      var max = <%=maxGlycemy%>;

      if(isNaN(inputObj.value) || inputObj.value < min || inputObj.value > max){
        var popupUrl = "<%=sCONTEXTPATH%>/_common/search/okPopup.jsp?ts=<%=getTs()%>&labelValue=<%=glycemyMsg%>";
        var modalities = "dialogWidth:266px;dialogHeight:143px;center:yes;scrollbars:no;resizable:no;status:no;location:no;";
        window.showModalDialog(popupUrl,'',modalities);

        inputObj.focus();
      }
    }
  }

  <%-- VALIDATE INSULINE --%>
  function validateInsuline(inputObj){
    inputObj.value = inputObj.value.replace(",",".");
    if(inputObj.value.length > 0){
      var min = <%=minInsuline%>;
      var max = <%=maxInsuline%>;

      if(isNaN(inputObj.value) || inputObj.value < min || inputObj.value > max){
        var popupUrl = "<%=sCONTEXTPATH%>/_common/search/okPopup.jsp?ts=<%=getTs()%>&labelValue=<%=insulineMsg%>";
        var modalities = "dialogWidth:266px;dialogHeight:143px;center:yes;scrollbars:no;resizable:no;status:no;location:no;";
        window.showModalDialog(popupUrl,'',modalities);

        inputObj.focus();
      }
    }
  }
</script>

<form name="transactionForm" id="transactionForm" method="POST" action='<c:url value="/healthrecord/updateTransaction.do"/>?ts=<%=getTs()%>' onclick="setSaveButton(event);" onkeyup="setSaveButton(event);">
    <bean:define id="transaction" name="be.mxs.webapp.wl.session.SessionContainerFactory.WO_SESSION_CONTAINER" property="currentTransactionVO"/>
	<%=checkPrestationToday(activePatient.personid,false,activeUser,(TransactionVO)transaction)%>
    <input type="hidden" id="transactionId" name="currentTransactionVO.<TransactionVO[hashCode=<bean:write name="transaction" scope="page" property="transactionId"/>]>.transactionId" value="<bean:write name="transaction" scope="page" property="transactionId"/>"/>
    <input type="hidden" id="serverId" name="currentTransactionVO.<TransactionVO[hashCode=<bean:write name="transaction" scope="page" property="transactionId"/>]>.serverId" value="<bean:write name="transaction" scope="page" property="serverId"/>"/>
    <input type="hidden" id="transactionType" name="currentTransactionVO.<TransactionVO[hashCode=<bean:write name="transaction" scope="page" property="transactionId"/>]>.transactionType" value="<bean:write name="transaction" scope="page" property="transactionType"/>"/>
    <input type="hidden" readonly name="be.mxs.healthrecord.updateTransaction.actionForwardKey" value="/main.do?Page=curative/index.jsp&ts=<%=getTs()%>"/>
    <input type="hidden" readonly name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_RECRUITMENT_CONVOCATION_ID" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_RECRUITMENT_CONVOCATION_ID" property="value"/>"/>
    <input type="hidden" readonly name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CONTEXT_DEPARTMENT" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CONTEXT_DEPARTMENT" translate="false" property="value"/>"/>
    <input type="hidden" readonly name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CONTEXT_CONTEXT" translate="false" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CONTEXT_CONTEXT" translate="false" property="value"/>"/>
<%=contextHeader(request,sWebLanguage)%>
<table class="list" width="100%" cellspacing="1">
    <%-- DATE --%>
    <tr>
        <td colspan="2">
            <table width="100%" cellspacing="1">
                <tr>
                    <td class="admin" width="210">
                        <a href="javascript:openHistoryPopup();" title="<%=getTranNoLink("Web.Occup","History",sWebLanguage)%>">...</a>&nbsp;
                        <%=getTran("Web.Occup","medwan.common.date",sWebLanguage)%>
                    </td>
                    <td class="admin2">
                        <input type="text" class="text" size="12" maxLength="10" value="<mxs:propertyAccessorI18N name="transaction" scope="page" property="updateTime" formatType="date" format="dd-mm-yyyy"/>" name="currentTransactionVO.<TransactionVO[hashCode=<bean:write name="transaction" scope="page" property="transactionId"/>]>.updateTime" id="trandate" OnBlur='checkDate(this)'>
                        <script>writeTranDate();</script>
                    </td>
                </tr>
            </table>
        </td>
    </tr>
    <tr><td>&nbsp;</td></tr>
    <tr>
        <td colspan="2">
            <table width="100%" cellspacing="1" class="list">
            <%-- GLYCEMY -----------------------------------------------------------------------------------------------------%>
                <%
                    String sGlycemyUnit = MedwanQuery.getInstance().getConfigString("glycemyUnit","mg / dl");
                %>
                <tr class="admin">
                    <td colspan="6"><%=getTran("web.occup","glycemy",sWebLanguage)%></td>
                </tr>
                <tr class="gray">
                    <td colspan="6"><%=getTran("diabetes","glucometer",sWebLanguage)%></td>
                </tr>

                <%-- GLYCEMY MORNING --%>
                <tr>
                    <td class="admin" width="210"><%=getTran("diabetes","morning_sober",sWebLanguage)%>&nbsp;</td>
                    <td class="admin2" width="150">
                        <input id="focusField" <%=setRightClick("ITEM_TYPE_DIABETES_FOLLOWUP_GLYCEMY_SHOT_MORNING")%> type="text" class="text" size="5" maxLength="5" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DIABETES_FOLLOWUP_GLYCEMY_SHOT_MORNING" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DIABETES_FOLLOWUP_GLYCEMY_SHOT_MORNING" property="value"/>" onBlur="setDecimalLength(this,2);if(isNumber(this)){validateGlycemy(this);}"> <%=sGlycemyUnit%>
                    </td>
                    <td class="admin" width="200"><%=getTran("Web","noon",sWebLanguage)%>&nbsp;</td>
                    <td class="admin2" width="150">
                        <input <%=setRightClick("ITEM_TYPE_DIABETES_FOLLOWUP_GLYCEMY_SHOT_NOON")%> type="text" class="text" size="5" maxLength="5" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DIABETES_FOLLOWUP_GLYCEMY_SHOT_NOON" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DIABETES_FOLLOWUP_GLYCEMY_SHOT_NOON" property="value"/>" onBlur="setDecimalLength(this,2);if(isNumber(this)){validateGlycemy(this);}"> <%=sGlycemyUnit%>
                    </td>
                    <td class="admin" width="200"><%=getTran("diabetes","2hours_after_morning",sWebLanguage)%>&nbsp;</td>
                    <td class="admin2">
                        <input <%=setRightClick("ITEM_TYPE_DIABETES_FOLLOWUP_GLYCEMY_SHOT_2_HOURS_AFTER_BREAKFAST")%> type="text" class="text" size="5" maxLength="5" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DIABETES_FOLLOWUP_GLYCEMY_SHOT_2_HOURS_AFTER_BREAKFAST" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DIABETES_FOLLOWUP_GLYCEMY_SHOT_2_HOURS_AFTER_BREAKFAST" property="value"/>" onBlur="setDecimalLength(this,2);if(isNumber(this)){validateGlycemy(this);}"> <%=sGlycemyUnit%>
                    </td>
                </tr>

                <%-- GLYCEMY EVENING --%>
                <tr>
                    <td class="admin"><%=getTran("Web","evening",sWebLanguage)%>&nbsp;</td>
                    <td class="admin2">
                        <input <%=setRightClick("ITEM_TYPE_DIABETES_FOLLOWUP_GLYCEMY_SHOT_EVENING")%> type="text" class="text" size="5" maxLength="5" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DIABETES_FOLLOWUP_GLYCEMY_SHOT_EVENING" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DIABETES_FOLLOWUP_GLYCEMY_SHOT_EVENING" property="value"/>" onBlur="setDecimalLength(this,2);if(isNumber(this)){validateGlycemy(this);}"> <%=sGlycemyUnit%>
                    </td>
                    <td class="admin"><%=getTran("Web","remark",sWebLanguage)%>&nbsp;</td>
                    <td class="admin2" colspan="3">
                        <textarea onKeyup="resizeTextarea(this,10);limitChars(this,255);" <%=setRightClick("ITEM_TYPE_DIABETES_FOLLOWUP_GLYCEMY_REMARK")%> class="text" cols="80" rows="2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DIABETES_FOLLOWUP_GLYCEMY_REMARK" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DIABETES_FOLLOWUP_GLYCEMY_REMARK" property="value"/></textarea>
                    </td>
                </tr>
                <tr class="gray">
                    <td colspan="6"><%=getTran("diabetes","glucosurie",sWebLanguage)%></td>
                </tr>

                <%-- glucosurie MORNING --%>
                <tr>
                    <td class="admin"><%=getTran("diabetes","morning_sober",sWebLanguage)%>&nbsp;</td>
                    <td class="admin2">
                        <select <%=setRightClick("ITEM_TYPE_DIABETES_FOLLOWUP_GLYCOSERIE_MORNING")%> id="slglmorning" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DIABETES_FOLLOWUP_GLYCOSERIE_MORNING" property="itemId"/>]>.value" class="text">
                            <option/>
                            <option value="-">-</option>
                            <option value="+">+</option>
                            <option value="++">++</option>
                            <option value="+++">+++</option>
                            <option value="++++">++++</option>
                        </select>
                    </td>
                    <td class="admin"><%=getTran("Web","noon",sWebLanguage)%>&nbsp;</td>
                    <td class="admin2">
                        <select <%=setRightClick("ITEM_TYPE_DIABETES_FOLLOWUP_GLYCOSERIE_NOON")%> id="slglnoon" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DIABETES_FOLLOWUP_GLYCOSERIE_NOON" property="itemId"/>]>.value" class="text">
                            <option/>
                            <option value="-">-</option>
                            <option value="+">+</option>
                            <option value="++">++</option>
                            <option value="+++">+++</option>
                            <option value="++++">++++</option>
                        </select>
                    </td>
                    <td class="admin"><%=getTran("Web","evening",sWebLanguage)%>&nbsp;</td>
                    <td class="admin2">
                        <select <%=setRightClick("ITEM_TYPE_DIABETES_FOLLOWUP_GLYCOSERIE_EVENING")%> id="slglevening" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DIABETES_FOLLOWUP_GLYCOSERIE_EVENING" property="itemId"/>]>.value" class="text">
                            <option/>
                            <option value="-">-</option>
                            <option value="+">+</option>
                            <option value="++">++</option>
                            <option value="+++">+++</option>
                            <option value="++++">++++</option>
                        </select>
                    </td>
                </tr>
                <tr class="gray">
                    <td colspan="6"><%=getTran("diabetes","labo",sWebLanguage)%></td>
                </tr>
            </table>
        </td>
    </tr>
    <tr><td>&nbsp;</td></tr>
    <tr>
        <td colspan="2">
            <table width="100%" cellspacing="1" class="list">
                <%-- INSULINE ----------------------------------------------------------------------------------------------------%>
                <%
                    String sInsulineUnit = MedwanQuery.getInstance().getConfigString("insulineUnit","lU");
                %>
                <tr class="admin">
                    <td colspan="7"><%=getTran("web.occup","insuline",sWebLanguage)%></td>
                </tr>

                <%-- INSULINE RAPID MORNING --%>
                <tr>
                    <td class="admin" width="100"><%=getTran("web","morning",sWebLanguage)%>&nbsp;</td>
                    <td class="admin" width="100"><%=getTran("Web","rapide",sWebLanguage)%>&nbsp;</td>
                    <td class="admin2" width="150">
                        <input <%=setRightClick("ITEM_TYPE_DIABETES_FOLLOWUP_INSULINE_SHOT_MORNING_FAST")%> type="text" class="text" size="5" maxLength="5" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DIABETES_FOLLOWUP_INSULINE_SHOT_MORNING_FAST" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DIABETES_FOLLOWUP_INSULINE_SHOT_MORNING_FAST" property="value"/>" onBlur="setDecimalLength(this,2);if(isNumber(this)){validateInsuline(this);}"> <%=sInsulineUnit%>
                    </td>
                    <td class="admin" width="200"><%=getTran("diabetes","intermediair",sWebLanguage)%>&nbsp;</td>
                    <td class="admin2" width="150">
                        <input <%=setRightClick("ITEM_TYPE_DIABETES_FOLLOWUP_INSULINE_SHOT_MORNING_INTERMEDIAIR")%> type="text" class="text" size="5" maxLength="5" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DIABETES_FOLLOWUP_INSULINE_SHOT_MORNING_INTERMEDIAIR" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DIABETES_FOLLOWUP_INSULINE_SHOT_MORNING_INTERMEDIAIR" property="value"/>" onBlur="setDecimalLength(this,2);if(isNumber(this)){validateInsuline(this);}"> <%=sInsulineUnit%>
                    </td>
                    <td class="admin" width="200"><%=getTran("diabetes","mixte",sWebLanguage)%>&nbsp;</td>
                    <td class="admin2">
                        <input <%=setRightClick("ITEM_TYPE_DIABETES_FOLLOWUP_INSULINE_SHOT_MORNING_MIXTE")%> type="text" class="text" size="5" maxLength="5" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DIABETES_FOLLOWUP_INSULINE_SHOT_MORNING_MIXTE" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DIABETES_FOLLOWUP_INSULINE_SHOT_MORNING_MIXTE" property="value"/>" onBlur="setDecimalLength(this,2);if(isNumber(this)){validateInsuline(this);}"> <%=sInsulineUnit%>
                    </td>
                </tr>
                <%-- INSULINE RAPID NOON --%>
                <tr>
                    <td class="admin"><%=getTran("web","noon",sWebLanguage)%>&nbsp;</td>
                    <td class="admin"><%=getTran("Web","rapide",sWebLanguage)%>&nbsp;</td>
                    <td class="admin2">
                        <input <%=setRightClick("ITEM_TYPE_DIABETES_FOLLOWUP_INSULINE_SHOT_NOON_FAST")%> type="text" class="text" size="5" maxLength="5" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DIABETES_FOLLOWUP_INSULINE_SHOT_NOON_FAST" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DIABETES_FOLLOWUP_INSULINE_SHOT_NOON_FAST" property="value"/>" onBlur="setDecimalLength(this,2);if(isNumber(this)){validateInsuline(this);}"> <%=sInsulineUnit%>
                    </td>
                    <td class="admin"><%=getTran("diabetes","intermediair",sWebLanguage)%>&nbsp;</td>
                    <td class="admin2">
                        <input <%=setRightClick("ITEM_TYPE_DIABETES_FOLLOWUP_INSULINE_SHOT_NOON_INTERMEDIAIR")%> type="text" class="text" size="5" maxLength="5" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DIABETES_FOLLOWUP_INSULINE_SHOT_NOON_INTERMEDIAIR" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DIABETES_FOLLOWUP_INSULINE_SHOT_NOON_INTERMEDIAIR" property="value"/>" onBlur="setDecimalLength(this,2);if(isNumber(this)){validateInsuline(this);}"> <%=sInsulineUnit%>
                    </td>
                    <td class="admin"><%=getTran("diabetes","mixte",sWebLanguage)%>&nbsp;</td>
                    <td class="admin2">
                        <input <%=setRightClick("ITEM_TYPE_DIABETES_FOLLOWUP_INSULINE_SHOT_NOON_MIXTE")%> type="text" class="text" size="5" maxLength="5" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DIABETES_FOLLOWUP_INSULINE_SHOT_NOON_MIXTE" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DIABETES_FOLLOWUP_INSULINE_SHOT_NOON_MIXTE" property="value"/>" onBlur="setDecimalLength(this,2);if(isNumber(this)){validateInsuline(this);}"> <%=sInsulineUnit%>
                    </td>
                </tr>
                <%-- INSULINE RAPID EVENING --%>
                <tr>
                    <td class="admin"><%=getTran("web","evening",sWebLanguage)%>&nbsp;</td>
                    <td class="admin"><%=getTran("Web","rapide",sWebLanguage)%>&nbsp;</td>
                    <td class="admin2">
                        <input <%=setRightClick("ITEM_TYPE_DIABETES_FOLLOWUP_INSULINE_SHOT_EVENING_FAST")%> type="text" class="text" size="5" maxLength="5" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DIABETES_FOLLOWUP_INSULINE_SHOT_EVENING_FAST" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DIABETES_FOLLOWUP_INSULINE_SHOT_EVENING_FAST" property="value"/>" onBlur="setDecimalLength(this,2);if(isNumber(this)){validateInsuline(this);}"> <%=sInsulineUnit%>
                    </td>
                    <td class="admin"><%=getTran("diabetes","intermediair",sWebLanguage)%>&nbsp;</td>
                    <td class="admin2">
                        <input <%=setRightClick("ITEM_TYPE_DIABETES_FOLLOWUP_INSULINE_SHOT_EVENING_INTERMEDIAIR")%> type="text" class="text" size="5" maxLength="5" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DIABETES_FOLLOWUP_INSULINE_SHOT_EVENING_INTERMEDIAIR" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DIABETES_FOLLOWUP_INSULINE_SHOT_EVENING_INTERMEDIAIR" property="value"/>" onBlur="setDecimalLength(this,2);if(isNumber(this)){validateInsuline(this);}"> <%=sInsulineUnit%>
                    </td>
                    <td class="admin"><%=getTran("diabetes","mixte",sWebLanguage)%>&nbsp;</td>
                    <td class="admin2">
                        <input <%=setRightClick("ITEM_TYPE_DIABETES_FOLLOWUP_INSULINE_SHOT_EVENING_MIXTE")%> type="text" class="text" size="5" maxLength="5" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DIABETES_FOLLOWUP_INSULINE_SHOT_EVENING_MIXTE" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DIABETES_FOLLOWUP_INSULINE_SHOT_EVENING_MIXTE" property="value"/>" onBlur="setDecimalLength(this,2);if(isNumber(this)){validateInsuline(this);}"> <%=sInsulineUnit%>
                    </td>
                </tr>
            </table>
        </td>
    </tr>
    <tr><td>&nbsp;</td></tr>
    <tr>
        <td>
            <table width="100%" cellspacing="1" class="list">
                <tr class="admin">
                    <td colspan="7"><%=getTran("diabetes","diet",sWebLanguage)%></td>
                </tr>
                <tr>
                    <td class="admin" width="100">07h00</td>
                    <td class="admin" width="100"><%=getTran("diabetes","repas",sWebLanguage)%></td>
                    <td class="admin2">
                        <textarea onKeyup="resizeTextarea(this,10);limitChars(this,255);" cols="80" rows="2" class="text" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DIABETES_FOLLOWUP_DIET_07" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DIABETES_FOLLOWUP_DIET_07" property="value"/></textarea>
                    </td>
                </tr>
                <tr>
                    <td class="admin">10h00</td>
                    <td class="admin"><%=getTran("diabetes","collation",sWebLanguage)%></td>
                    <td class="admin2">
                        <textarea onKeyup="resizeTextarea(this,10);limitChars(this,255);" cols="80" rows="2" class="text" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DIABETES_FOLLOWUP_DIET_10" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DIABETES_FOLLOWUP_DIET_10" property="value"/></textarea>
                    </td>
                </tr>
                <tr>
                    <td class="admin">12h00</td>
                    <td class="admin"><%=getTran("diabetes","repas",sWebLanguage)%></td>
                    <td class="admin2">
                        <textarea onKeyup="resizeTextarea(this,10);limitChars(this,255);" cols="80" rows="2" class="text" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DIABETES_FOLLOWUP_DIET_12" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DIABETES_FOLLOWUP_DIET_12" property="value"/></textarea>
                    </td>
                </tr>
                <tr>
                    <td class="admin">15h00</td>
                    <td class="admin"><%=getTran("diabetes","collation",sWebLanguage)%></td>
                    <td class="admin2">
                        <textarea onKeyup="resizeTextarea(this,10);limitChars(this,255);" cols="80" rows="2" class="text" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DIABETES_FOLLOWUP_DIET_15" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DIABETES_FOLLOWUP_DIET_15" property="value"/></textarea>
                    </td>
                </tr>
                <tr>
                    <td class="admin">17h00</td>
                    <td class="admin"><%=getTran("diabetes","repas",sWebLanguage)%></td>
                    <td class="admin2">
                        <textarea onKeyup="resizeTextarea(this,10);limitChars(this,255);" cols="80" rows="2" class="text" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DIABETES_FOLLOWUP_DIET_17" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DIABETES_FOLLOWUP_DIET_17" property="value"/></textarea>
                    </td>
                </tr>
                <tr>
                    <td class="admin" colspan="2"><%=getTran("openclinic.chuk","other",sWebLanguage)%></td>
                    <td class="admin2">
                        <textarea onKeyup="resizeTextarea(this,10);limitChars(this,255);" cols="80" rows="2" class="text" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DIABETES_FOLLOWUP_DIET_OTHER" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DIABETES_FOLLOWUP_DIET_OTHER" property="value"/></textarea>
                    </td>
                </tr>
            </table>
		</td>
		
		<%-- DIAGNOSES --%>
		<td style="vertical-align:top;padding:0" class="admin2">
               <%ScreenHelper.setIncludePage(customerInclude("healthrecord/diagnosesEncoding.jsp"),pageContext);%>
		</td>			
	</tr>
</table>
<script>
  sslglmorning = "<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DIABETES_FOLLOWUP_GLYCOSERIE_MORNING" property="value"/>";
  sslglnoon = "<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DIABETES_FOLLOWUP_GLYCOSERIE_NOON" property="value"/>";
  sslglevening = "<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DIABETES_FOLLOWUP_GLYCOSERIE_EVENING" property="value"/>";

  for (var n=0;n<transactionForm.slglmorning.length;n++){
    if (transactionForm.slglmorning.options[n].value==sslglmorning){
      transactionForm.slglmorning.selectedIndex=n;
      break;
    }
  }

  for (var n=0;n<transactionForm.slglnoon.length;n++){
    if (transactionForm.slglnoon.options[n].value==sslglnoon){
      transactionForm.slglnoon.selectedIndex=n;
      break;
    }
  }

  for (var n=0;n<transactionForm.slglevening.length;n++){
    if (transactionForm.slglevening.options[n].value==sslglevening){
      transactionForm.slglevening.selectedIndex=n;
      break;
    }
  }

    <%-- SUBMIT FORM --%>
  function submitForm(){
    transactionForm.saveButton.disabled = true;
    <%
        SessionContainerWO sessionContainerWO = (SessionContainerWO)SessionContainerFactory.getInstance().getSessionContainerWO(request,SessionContainerWO.class.getName());
        out.print(takeOverTransaction(sessionContainerWO, activeUser,"document.transactionForm.submit();"));
    %>
  }

  <%-- DO BACK --%>
  function doBack(){
    if(checkSaveButton('<%=sCONTEXTPATH%>','<%=getTranNoLink("Web.Occup","medwan.common.buttonquestion",sWebLanguage)%>')){
      window.location.href='<c:url value="/main.do"/>?Page=curative/index.jsp&ts=<%=getTs()%>';
    }
  }
</script>
<%
//    SessionContainerWO sessionContainerWO = (SessionContainerWO)SessionContainerFactory.getInstance().getSessionContainerWO(request,SessionContainerWO.class.getName());
    TransactionVO transactionVO = sessionContainerWO.getCurrentTransactionVO();

    if (transactionVO.getTransactionId().intValue()>0){
%>
<br>

<%--################################################## GRAPHS ######################################################--%>
<table class="list" width="100%" cellspacing="0">
    <tr class="admin">
        <td colspan="3"><%=getTran("web","graphs",sWebLanguage)%></td>
    </tr>

    <%-- FROM-DATE-SELECTOR (applicable on the 3 insuline graphs) --%>
    <%
        // get data from one month ago untill now
        Calendar now              = new GregorianCalendar(), // until
                 defaultBeginDate = new GregorianCalendar();
        defaultBeginDate.add(Calendar.MONTH,-1); // from : default one month ago

        String sBeginDate = checkString(request.getParameter("beginDate"));
        if(sBeginDate.length()==0) sBeginDate = stdDateFormat.format(defaultBeginDate.getTime());
    %>
    <tr>
        <td class="admin" width="210">
            <%=getTran("Web","begindate",sWebLanguage)%>
        </td>
        <td class="admin2">
            <input type="text" class="text" size="12" maxLength="10" value="<%=sBeginDate%>" name="beginDateInsulineGraphs" onBlur="checkDate(this);">
            <script>writeMyDate("beginDateInsulineGraphs","<c:url value="/_img/icon_agenda.gif"/>","<%=getTran("Web","PutToday",sWebLanguage)%>");</script>&nbsp;&nbsp;

            <%-- button to open blur popup --%>
            <input class="button" type="button" name="setGraphsDataButton" value="<%=getTranNoLink("Web","show",sWebLanguage)%>" onClick="reloadPage(transactionForm.beginDateInsulineGraphs.value);">
        </td>
    </tr>
</table>

<script>
  <%-- SET INSULINE GRAPHS DATA --%>
  function reloadPage(beginDate){
    if(checkSaveButton("<%=sCONTEXTPATH%>","<%=getTranNoLink("Web.Occup","medwan.common.buttonquestion",sWebLanguage)%>")){
      window.location.href = "<c:url value='/main.do'/>?Page=/healthrecord/manageDiabetesFollowup_view.jsp&beginDate="+beginDate+"&ts=<%=getTs()%>";
    }
  }

  <%-- SET INSULINE GRAPHS DATA --%>
  function setInsGraphsData(beginDate){
    openPopup("/_common/search/blurInsulineGraphsData.jsp&BeginDate="+beginDate);
  }
</script>

<br>

<table class="list" width="100%" cellspacing="0">
    <%-- GLYCEMY GRAPH -----------------------------------------------------------------------------------------------%>
    <%
        Hashtable glyDatesAndValues = MedwanQuery.getGlycemyShots(activePatient.personid, stdDateFormat.parse(sBeginDate), now.getTime());

        // sort hash on dates (DB only sorted them on day, not on hour)
        Vector dates = new Vector(glyDatesAndValues.keySet());
        Collections.sort(dates);

        String sGlyBeginDate = "", sGlyEndDate;
        StringBuffer sGlyDates = new StringBuffer(),
                sGlyValues = new StringBuffer();

        // concatenate vector-content to use in JS below
        for (int i = 0; i < dates.size(); i++) {
            date = (java.util.Date) dates.get(i);
            value = (String) glyDatesAndValues.get(date);
            sGlyEndDate = checkString(new SimpleDateFormat("dd/MM/yyyy HH:mm").format(date));

            // keep notice of the earlyest date
            if (sGlyBeginDate.trim().length() == 0) {
                sGlyBeginDate = sGlyEndDate;
            }

            // concatenate
            sGlyDates.append("'" + sGlyEndDate + "',");
            sGlyValues.append("'" + value + "',");
        }

        // remove last commas from concatenate-strings
        if (sGlyDates.length() > 0) {
            sGlyDates = sGlyDates.deleteCharAt(sGlyDates.length() - 1);
        }

        if (sGlyValues.length() > 0) {
            sGlyValues = sGlyValues.deleteCharAt(sGlyValues.length() - 1);
        }
    %>

    <%-- graph header --%>
    <tr onmouseover="this.style.cursor='hand';" onmouseout="this.style.cursor='default';" id="header_glycemyGraph">
        <td class="admin" width="20" align="center" onClick="toggleGraph('glycemyGraph');">
            <img id="img_glycemyGraph" src="<%=sCONTEXTPATH%>/_img/plus.png" class="link">
        </td>
        <td class="admin" width="99%" onClick="toggleGraph('glycemyGraph');"><%=getTran("web.occup","glycemy",sWebLanguage)%></td>
        <td class="admin" align="right" width ="1%" style="vertical-align:bottom;">
            <a href="#topp" class="topbutton">&nbsp;</a>
        </td>
    </tr>

    <tr>
        <td style="border-style: solid;border-width: 1px;border-color: #cccccc;" colspan="3">
            <div id="glycemyGraph" style="position:relative; left:50px; top:20px; height:220px" style="display:none;">
            <%
                if(sGlyValues.length() > 0){
                    %>
                    <script>
                      var today = new Date();
                      var minValueY = <%=minValueYGly%>;
                      var maxValueY = <%=maxValueYGly%>;

                      var aGlyValues = new Array(<%=sGlyValues.toString()%>);
                      var aGlyDates  = new Array(<%=sGlyDates.toString()%>);

                      <%-- DRAW GRAPH - GLYCEMY --%>
                      function drawGraph_Glycemy(beginDate){
                        //if(aGlyDates.length>0){
                          <%-- init diagram object --%>
                          var glyDia = new Diagram();
                          glyDia.SetFrame(0,0,600,155);
                          glyDia.XScale = 5;
                          glyDia.YScale = 1;

                          var yearBegin  = beginDate.substr(beginDate.lastIndexOf("/")+1,4);
                          var monthBegin = (beginDate.substr(beginDate.indexOf("/")+1,2)*1)-1;
                          var dayBegin   = beginDate.substr(0,beginDate.indexOf("/"))*1;

                          <%-- TODO : till last date in array or till today ? --%>
                          //var yearEnd  = aGlyDates[aGlyDates.length-1].substr(aGlyDates[aGlyDates.length-1].lastIndexOf("/")+1,4);
                          //var monthEnd = (aGlyDates[aGlyDates.length-1].substr(aGlyDates[aGlyDates.length-1].indexOf("/")+1,2)*1)-1;
                          //var dayEnd   = aGlyDates[aGlyDates.length-1].substr(0,aGlyDates[aGlyDates.length-1].indexOf("/"))*1;
                          var yearEnd  = today.getYear();
                          var monthEnd = today.getMonth(); if(monthEnd<0) monthEnd = 11;
                          var dayEnd   = today.getDate();

                          // search for largest value to set graph-height
                          var maxValue = 0;
                          for(var i=0; i<aGlyValues.length; i++){
                            if((aGlyValues[i]*1) > maxValue){
                              maxValue = aGlyValues[i]*1;
                            }
                          }
                          if(maxValue < maxValueY) maxValueY = maxValue*1.1; // add 10% space

                          <%-- prevent the X-axis from beginning and ending too close to the frame --%>
                          var dateInterval = (glyDia.DateInterval())*1; // 2500 = 1 month..
                          var startDate = Date.UTC(yearBegin,monthBegin,dayBegin,0,0,0); // begin of day
                          startDate = startDate-(dateInterval*24*60*60);
                          var endDate = Date.UTC(yearEnd,monthEnd,dayEnd,23,59,59); // end of day
                          endDate = endDate+(dateInterval*24*60*60);

                          glyDia.SetBorder(startDate,endDate,minValueY,maxValueY);
                          glyDia.Draw("#F6F6F6","#000000",false,"","","#DDDDDD");

                          // put values on graph
                          var xPos, yPos, xPosNext, yPosNext;
                          for(var i=0; i<aGlyValues.length; i++){
                            var year  = aGlyDates[i].substr(aGlyDates[i].lastIndexOf("/")+1,4);
                            var month = (aGlyDates[i].substr(aGlyDates[i].indexOf("/")+1,2)*1)-1;
                            var day   = aGlyDates[i].substr(0,aGlyDates[i].indexOf("/"))*1;
                            var hour  = aGlyDates[i].substr(aGlyDates[i].lastIndexOf("/")+6,2)*1;

                            xPos = Date.UTC(year,month,day,hour,0,0);
                            yPos = aGlyValues[i];

                            if(hour==8){ // blue
                              new Dot(glyDia.ScreenX(xPos), glyDia.ScreenY(yPos), 8, 1, "0000FF", aGlyDates[i]+"h = "+aGlyValues[i]+" <%=sGlycemyUnit%>");
                            }
                            else if(hour==12){ // green
                              new Dot(glyDia.ScreenX(xPos), glyDia.ScreenY(yPos), 8, 1, "00AA00", aGlyDates[i]+"h = "+aGlyValues[i]+" <%=sGlycemyUnit%>");
                            }
                            else if(hour==17){ // red
                              new Dot(glyDia.ScreenX(xPos), glyDia.ScreenY(yPos), 8, 1, "FF0000", aGlyDates[i]+"h = "+aGlyValues[i]+" <%=sGlycemyUnit%>");
                            }

                            if(i < aGlyValues.length-1){
                              var nextYear  = aGlyDates[i+1].substr(aGlyDates[i+1].lastIndexOf("/")+1,4);
                              var nextMonth = (aGlyDates[i+1].substr(aGlyDates[i+1].indexOf("/")+1,2)*1)-1;
                              var nextDay   = aGlyDates[i+1].substr(0,aGlyDates[i+1].indexOf("/"))*1;
                              var nextHour  = aGlyDates[i+1].substr(aGlyDates[i+1].lastIndexOf("/")+6,2)*1;

                              xPosNext = Date.UTC(nextYear,nextMonth,nextDay,nextHour,0,0);
                              yPosNext = aGlyValues[i+1];

                              new Line(glyDia.ScreenX(xPos), glyDia.ScreenY(yPos), glyDia.ScreenX(xPosNext), glyDia.ScreenY(yPosNext), "999999", 2, "");
                            }
                          }
                        //}
                      }
                          drawGraph_Glycemy("<%=sBeginDate%>");
                        </script>
                   <%
               }
           %>
            </div>
        </td>
    </tr>

    <%-- INSULE RAPID GRAPH ------------------------------------------------------------------------------------------%>
    <script>
        var barWidth = 5; // used by all three insuline graphs
    </script>

    <%
        Hashtable insDatesAndValues = MedwanQuery.getInsulineShots(activePatient.personid,"RAPID",stdDateFormat.parse(sBeginDate),now.getTime());

        // sort hash on dates (DB only sorted them on day, not on hour)
        dates = new Vector(insDatesAndValues.keySet());
        Collections.sort(dates);

        String sInsBeginDate = "", sInsEndDate;
        StringBuffer sInsDates = new StringBuffer(),
                     sInsValues = new StringBuffer();

        // concatenate vector-content to use in JS below
        for(int i=0; i<dates.size(); i++){
            date = (java.util.Date)dates.get(i);
            value = (String)insDatesAndValues.get(date);
            sInsEndDate = checkString(new SimpleDateFormat("dd/MM/yyyy HH:mm").format(date));

            // keep notice of the earlyest date
            if(sInsBeginDate.trim().length()==0){
                sInsBeginDate = sInsEndDate;
            }

            // concatenate
            sInsDates.append("'"+sInsEndDate+"',");
            sInsValues.append("'"+value+"',");
        }

        // remove last commas from concatenate-strings
        if(sInsDates.length()>0){
            sInsDates = sInsDates.deleteCharAt(sInsDates.length()-1);
        }

        if(sInsValues.length()>0){
            sInsValues = sInsValues.deleteCharAt(sInsValues.length()-1);
        }
    %>

    <%-- graph header --%>
    <tr onmouseover="this.style.cursor='hand';" onmouseout="this.style.cursor='default';" id="header_insulineRapidGraph">
        <td class="admin" width="20" align="center" onClick="toggleGraph('insulineRapidGraph');">
            <img id="img_insulineRapidGraph" src="<%=sCONTEXTPATH%>/_img/plus.png" class="link">
        </td>
        <td class="admin" width="99%" onClick="toggleGraph('insulineRapidGraph');"><%=getTran("web.occup","insuline",sWebLanguage)%>&nbsp;<%=getTran("web","rapid",sWebLanguage)%></td>
        <td class="admin" align="right" width ="1%" style="vertical-align:bottom;">
            <a href="#topp" class="topbutton">&nbsp;</a>
        </td>
    </tr>

    <tr>
        <td style="border-style: solid;border-width: 1px;border-color: #cccccc;" colspan="3">
            <div id="insulineRapidGraph" style="position:relative; left:50px; top:20px; height:220px; display:none;">
            <%
                if(sInsValues.length() > 0){
                    %>
                    <script>
                      var minValueY = <%=minValueYIns%>;
                      var maxValueY = <%=maxValueYIns%>;

                      var aInsRValues = new Array(<%=sInsValues.toString()%>);
                      var aInsRDates  = new Array(<%=sInsDates.toString()%>);

                      <%-- DRAW GRAPH - INSULINE RAPID --%>
                      function drawGraph_InsulineRapid(beginDate){
                        //if(aInsRDates.length>0){
                          <%-- init diagram object --%>
                          var insDia = new Diagram();
                          insDia.SetFrame(0,0,600,155);
                          insDia.XScale = 5;

                          var yearBegin  = beginDate.substr(beginDate.lastIndexOf("/")+1,4);
                          var monthBegin = (beginDate.substr(beginDate.indexOf("/")+1,2)*1)-1;
                          var dayBegin   = beginDate.substr(0,beginDate.indexOf("/"))*1;

                          var yearEnd  = today.getYear();
                          var monthEnd = today.getMonth(); if(monthEnd<0) monthEnd = 11;
                          var dayEnd   = today.getDate();

                          // search for largest value to set graph-height
                          var maxValue = 0;
                          for(var i=0; i<aInsRValues.length; i++){
                            if((aInsRValues[i]*1) > maxValue){
                              maxValue = aInsRValues[i]*1;
                            }
                          }
                          if(maxValue < maxValueY) maxValueY = maxValue*1.1;

                          <%-- prevent the X-axis from beginning and ending too close to the frame --%>
                          var dateInterval = (insDia.DateInterval())*1; // 2500 = 1 month..
                          var startDate = Date.UTC(yearBegin,monthBegin,dayBegin,0,0,0); // begin of day
                          startDate = startDate-(dateInterval*24*60*60);
                          var endDate = Date.UTC(yearEnd,monthEnd,dayEnd,23,59,59); // end of day
                          endDate = endDate+(dateInterval*24*60*60);

                          insDia.SetBorder(startDate,endDate,minValueY,maxValueY);
                          insDia.Draw("#F6F6F6","#000000",false,"","","#DDDDDD");

                          // put values on graph
                          var xPos, yPos, xPosNext, yPosNext;
                          for(var i=0; i<aInsRValues.length; i++){
                            var year  = aInsRDates[i].substr(aInsRDates[i].lastIndexOf("/")+1,4);
                            var month = (aInsRDates[i].substr(aInsRDates[i].indexOf("/")+1,2)*1)-1;
                            var day   = aInsRDates[i].substr(0,aInsRDates[i].indexOf("/"))*1;
                            var hour  = aInsRDates[i].substr(aInsRDates[i].lastIndexOf("/")+6,2)*1;

                            xPos = Date.UTC(year,month,day,hour,0,0);
                            yPos = aInsRValues[i];

                            if(hour==17){
                              new Box(insDia.ScreenX(xPos), insDia.ScreenY(yPos), insDia.ScreenX(xPos)+barWidth, insDia.ScreenY(0), "#FF0000", "", "#FFFFFF", 1, "#000000", aInsRDates[i]+"h = "+aInsRValues[i]+" <%=sInsulineUnit%>");
                            }
                            else{
                              new Box(insDia.ScreenX(xPos), insDia.ScreenY(yPos), insDia.ScreenX(xPos)+barWidth, insDia.ScreenY(0), "#0000FF", "", "#000000", 1, "#000000", aInsRDates[i]+"h = "+aInsRValues[i]+" <%=sInsulineUnit%>");
                            }

                            if(i < aInsRValues.length-1){
                              var nextYear  = aInsRDates[i+1].substr(aInsRDates[i+1].lastIndexOf("/")+1,4);
                              var nextMonth = (aInsRDates[i+1].substr(aInsRDates[i+1].indexOf("/")+1,2)*1)-1;
                              var nextDay   = aInsRDates[i+1].substr(0,aInsRDates[i+1].indexOf("/"))*1;
                              var nextHour  = aInsRDates[i].substr(aInsRDates[i].lastIndexOf("/")+6,2)*1;

                              xPosNext = Date.UTC(nextYear,nextMonth,nextDay,nextHour,0,0);
                              yPosNext = aInsRValues[i];

                              if(hour==17){
                                new Box(insDia.ScreenX(xPosNext), insDia.ScreenY(yPosNext), insDia.ScreenX(xPosNext)+barWidth, insDia.ScreenY(0), "#FF0000", "", "#FFFFFF", 1, "#000000", aInsRDates[i]+"h = "+aInsRValues[i]+" <%=sInsulineUnit%>");
                              }
                              else{
                                new Box(insDia.ScreenX(xPosNext), insDia.ScreenY(yPosNext), insDia.ScreenX(xPosNext)+barWidth, insDia.ScreenY(0), "#0000FF", "", "#000000", 1, "#000000", aInsRDates[i]+"h = "+aInsRValues[i]+" <%=sInsulineUnit%>");
                              }
                            }
                          }
                        //}
                      }
                          drawGraph_InsulineRapid("<%=sBeginDate%>");
                        </script>
                    <%
                }
                else{
                    %><%=getTran("web","nodataavailable",sWebLanguage)%>
                    <script>
                        document.getElementById("insulineRapidGraph").style.height=30;
                    </script>
                <%
                }
            %>
            </div>
        </td>
    </tr>

    <%-- INSULINE SEMIRAPID GRAPH ------------------------------------------------------------------------------------%>
    <%
        insDatesAndValues = MedwanQuery.getInsulineShots(activePatient.personid,"SEMIRAPID",stdDateFormat.parse(sBeginDate),now.getTime());

        // sort hash on dates (DB only sorted them on day, not on hour)
        dates = new Vector(insDatesAndValues.keySet());
        Collections.sort(dates);

        sInsBeginDate = "";
        sInsDates = new StringBuffer();
        sInsValues = new StringBuffer();

        // concatenate vector-content to use in JS below
        for(int i=0; i<dates.size(); i++){
            date = (java.util.Date)dates.get(i);
            value = (String)insDatesAndValues.get(date);
            sInsEndDate = checkString(new SimpleDateFormat("dd/MM/yyyy HH:mm").format(date));

            // keep notice of the earlyest date
            if(sInsBeginDate.trim().length()==0){
                sInsBeginDate = sInsEndDate;
            }

            // concatenate
            sInsDates.append("'"+sInsEndDate+"',");
            sInsValues.append("'"+value+"',");
        }

        // remove last commas from concatenate-strings
        if(sInsDates.length()>0){
            sInsDates = sInsDates.deleteCharAt(sInsDates.length()-1);
        }

        if(sInsValues.length()>0){
            sInsValues = sInsValues.deleteCharAt(sInsValues.length()-1);
        }
    %>

    <%-- graph header --%>
    <tr onmouseover="this.style.cursor='hand';" onmouseout="this.style.cursor='default';" id="header_insulineSemiRapidGraph">
        <td class="admin" width="20" align="center" onClick="toggleGraph('insulineSemiRapidGraph');">
            <img id="img_insulineSemiRapidGraph" src="<%=sCONTEXTPATH%>/_img/plus.png" class="link">
        </td>
        <td class="admin" width="99%" onClick="toggleGraph('insulineSemiRapidGraph');"><%=getTran("web.occup","insuline",sWebLanguage)%>&nbsp;<%=getTran("web","semirapid",sWebLanguage)%></td>
        <td class="admin" align="right" width ="1%" style="vertical-align:bottom;">
            <a href="#topp" class="topbutton">&nbsp;</a>
        </td>
    </tr>

    <tr>
        <td style="border-style: solid;border-width: 1px;border-color: #cccccc;" colspan="3">
            <div id="insulineSemiRapidGraph" style="position:relative; left:50px; top:20px; height:220px" style="display:none;">
            <%
                if(sInsValues.length() > 0){
                    %>
                    <script>
                      var minValueY = <%=minValueYIns%>;
                      var maxValueY = <%=maxValueYIns%>;

                      var aInsSRValues = new Array(<%=sInsValues.toString()%>);
                      var aInsSRDates  = new Array(<%=sInsDates.toString()%>);

                      <%-- DRAW GRAPH - INSULINE SEMI RAPID --%>
                      function drawGraph_InsulineSemiRapid(beginDate){
                        //if(aInsSRDates.length>0){
                          <%-- init diagram object --%>
                          var insDia = new Diagram();
                          insDia.SetFrame(0,0,600,155);
                          insDia.XScale = 5;

                          var yearBegin  = beginDate.substr(beginDate.lastIndexOf("/")+1,4);
                          var monthBegin = (beginDate.substr(beginDate.indexOf("/")+1,2)*1)-1;
                          var dayBegin   = beginDate.substr(0,beginDate.indexOf("/"))*1;

                          var yearEnd  = today.getYear();
                          var monthEnd = today.getMonth(); if(monthEnd<0) monthEnd = 11;
                          var dayEnd   = today.getDate();

                          // search for largest value to set graph-height
                          var maxValue = 0;
                          for(var i=0; i<aInsSRValues.length; i++){
                            if((aInsSRValues[i]*1) > maxValue){
                              maxValue = aInsSRValues[i]*1;
                            }
                          }
                          if(maxValue < maxValueY) maxValueY = maxValue*1.1;

                          <%-- prevent the X-axis from beginning and ending too close to the frame --%>
                          var dateInterval = (insDia.DateInterval())*1; // 2500 = 1 month..
                          var startDate = Date.UTC(yearBegin,monthBegin,dayBegin,0,0,0); // begin of day
                          startDate = startDate-(dateInterval*24*60*60);
                          var endDate = Date.UTC(yearEnd,monthEnd,dayEnd,23,59,59); // end of day
                          endDate = endDate+(dateInterval*24*60*60);

                          insDia.SetBorder(startDate,endDate,minValueY,maxValueY);
                          insDia.Draw("#F6F6F6","#000000",false,"","","#DDDDDD");

                          // put values on graph
                          var xPos, yPos, xPosNext, yPosNext;
                          for(var i=0; i<aInsSRValues.length; i++){
                            var year  = aInsSRDates[i].substr(aInsSRDates[i].lastIndexOf("/")+1,4);
                            var month = (aInsSRDates[i].substr(aInsSRDates[i].indexOf("/")+1,2)*1)-1;
                            var day   = aInsSRDates[i].substr(0,aInsSRDates[i].indexOf("/"))*1;
                            var hour  = aInsSRDates[i].substr(aInsSRDates[i].lastIndexOf("/")+6,2)*1;

                            xPos = Date.UTC(year,month,day,hour,0,0);
                            yPos = aInsSRValues[i];

                            if(hour==17){
                              new Box(insDia.ScreenX(xPos), insDia.ScreenY(yPos), insDia.ScreenX(xPos)+barWidth, insDia.ScreenY(0), "#FF0000", "", "#FFFFFF", 1, "#000000", aInsSRDates[i]+"h = "+aInsSRValues[i]+" <%=sInsulineUnit%>");
                            }
                            else{
                              new Box(insDia.ScreenX(xPos), insDia.ScreenY(yPos), insDia.ScreenX(xPos)+barWidth, insDia.ScreenY(0), "#0000FF", "", "#000000", 1, "#000000", aInsSRDates[i]+"h = "+aInsSRValues[i]+" <%=sInsulineUnit%>");
                            }

                            if(i < aInsSRValues.length-1){
                              var nextYear  = aInsSRDates[i+1].substr(aInsSRDates[i+1].lastIndexOf("/")+1,4);
                              var nextMonth = (aInsSRDates[i+1].substr(aInsSRDates[i+1].indexOf("/")+1,2)*1)-1;
                              var nextDay   = aInsSRDates[i+1].substr(0,aInsSRDates[i+1].indexOf("/"))*1;
                              var nextHour  = aInsSRDates[i].substr(aInsSRDates[i].lastIndexOf("/")+6,2)*1;

                              xPosNext = Date.UTC(nextYear,nextMonth,nextDay,nextHour,0,0);
                              yPosNext = aInsSRValues[i];

                              if(hour==17){
                                new Box(insDia.ScreenX(xPosNext), insDia.ScreenY(yPosNext), insDia.ScreenX(xPosNext)+barWidth, insDia.ScreenY(0), "#FF0000", "", "#FFFFFF", 1, "#000000", aInsSRDates[i]+"h = "+aInsSRValues[i]+" <%=sInsulineUnit%>");
                              }
                              else{
                                new Box(insDia.ScreenX(xPosNext), insDia.ScreenY(yPosNext), insDia.ScreenX(xPosNext)+barWidth, insDia.ScreenY(0), "#0000FF", "", "#000000", 1, "#000000", aInsSRDates[i]+"h = "+aInsSRValues[i]+" <%=sInsulineUnit%>");
                              }
                            }
                          }
                        //}
                      }
                          drawGraph_InsulineSemiRapid("<%=sBeginDate%>");
                        </script>
                    <%
                }
                else{
                    %><%=getTran("web","nodataavailable",sWebLanguage)%>
                <script>
                    document.getElementById("insulineSemiRapidGraph").style.height=30;
                </script>
                <%
                }
            %>
            </div>
        </td>
    </tr>

    <%-- INSULINE SLOW GRAPH -----------------------------------------------------------------------------------------%>
    <%
        insDatesAndValues = MedwanQuery.getInsulineShots(activePatient.personid,"SLOW",stdDateFormat.parse(sBeginDate),now.getTime());

        // sort hash on dates (DB only sorted them on day, not on hour)
        dates = new Vector(insDatesAndValues.keySet());
        Collections.sort(dates);

        sInsBeginDate = "";
        sInsDates = new StringBuffer();
        sInsValues = new StringBuffer();

        // concatenate vector-content to use in JS below
        for(int i=0; i<dates.size(); i++){
            date = (java.util.Date)dates.get(i);
            value = (String)insDatesAndValues.get(date);
            sInsEndDate = checkString(new SimpleDateFormat("dd/MM/yyyy HH:mm").format(date));

            // keep notice of the earlyest date
            if(sInsBeginDate.trim().length()==0){
                sInsBeginDate = sInsEndDate;
            }

            // concatenate
            sInsDates.append("'"+sInsEndDate+"',");
            sInsValues.append("'"+value+"',");
        }

        // remove last commas from concatenate-strings
        if(sInsDates.length()>0){
            sInsDates = sInsDates.deleteCharAt(sInsDates.length()-1);
        }

        if(sInsValues.length()>0){
            sInsValues = sInsValues.deleteCharAt(sInsValues.length()-1);
        }
    %>

    <%-- graph header --%>
    <tr onmouseover="this.style.cursor='hand';" onmouseout="this.style.cursor='default';" id="header_insulineSlowGraph">
        <td class="admin" width="20" align="center" onClick="toggleGraph('insulineSlowGraph');">
            <img id="img_insulineSlowGraph" src="<%=sCONTEXTPATH%>/_img/plus.png" class="link">
        </td>
        <td class="admin" width="99%" onClick="toggleGraph('insulineSlowGraph');"><%=getTran("web.occup","insuline",sWebLanguage)%>&nbsp;<%=getTran("web","slow",sWebLanguage)%></td>
        <td class="admin" align="right" width ="1%" style="vertical-align:bottom;">
            <a href="#topp" class="topbutton">&nbsp;</a>
        </td>
    </tr>

    <tr>
        <td style="border-style: solid;border-width: 1px;border-color: #cccccc;" colspan="3">
            <div id="insulineSlowGraph" style="position:relative; left:50px; top:20px; height:220px" style="display:none;">
            <%
                if(sInsValues.length() > 0){
                    %>
                    <script>
                      var minValueY = <%=minValueYIns%>;
                      var maxValueY = <%=maxValueYIns%>;

                      var aInsSValues = new Array(<%=sInsValues.toString()%>);
                      var aInsSDates  = new Array(<%=sInsDates.toString()%>);

                      <%-- DRAW GRAPH - INSULINE SLOW --%>
                      function drawGraph_InsulineSlow(beginDate){
                        //if(aInsSDates.length>0){
                          <%-- init diagram object --%>
                          var insDia = new Diagram();
                          insDia.SetFrame(0,0,600,155);
                          insDia.XScale = 5;

                          var yearBegin  = beginDate.substr(beginDate.lastIndexOf("/")+1,4);
                          var monthBegin = (beginDate.substr(beginDate.indexOf("/")+1,2)*1)-1;
                          var dayBegin   = beginDate.substr(0,beginDate.indexOf("/"))*1;

                          var yearEnd  = today.getYear();
                          var monthEnd = today.getMonth(); if(monthEnd<0) monthEnd = 11;
                          var dayEnd   = today.getDate();

                          // search for largest value to set graph-height
                          var maxValue = 0;
                          for(var i=0; i<aInsSValues.length; i++){
                            if((aInsSValues[i]*1) > maxValue){
                              maxValue = aInsSValues[i]*1;
                            }
                          }
                          if(maxValue < maxValueY) maxValueY = maxValue*1.1;

                          <%-- prevent the X-axis from beginning and ending too close to the frame --%>
                          var dateInterval = (insDia.DateInterval())*1; // 2500 = 1 month..
                          var startDate = Date.UTC(yearBegin,monthBegin,dayBegin,0,0,0); // begin of day
                          startDate = startDate-(dateInterval*24*60*60);
                          var endDate = Date.UTC(yearEnd,monthEnd,dayEnd,23,59,59); // end of day
                          endDate = endDate+(dateInterval*24*60*60);

                          insDia.SetBorder(startDate,endDate,minValueY,maxValueY);
                          insDia.Draw("#F6F6F6","#000000",false,"","","#DDDDDD");

                          // put values on graph
                          var xPos, yPos, xPosNext, yPosNext;
                          for(var i=0; i<aInsSValues.length; i++){
                            var year  = aInsSDates[i].substr(aInsSDates[i].lastIndexOf("/")+1,4);
                            var month = (aInsSDates[i].substr(aInsSDates[i].indexOf("/")+1,2)*1)-1;
                            var day   = aInsSDates[i].substr(0,aInsSDates[i].indexOf("/"))*1;
                            var hour  = aInsSDates[i].substr(aInsSDates[i].lastIndexOf("/")+6,2)*1;

                            xPos = Date.UTC(year,month,day,hour,0,0);
                            yPos = aInsSValues[i];

                            if(hour==17){
                              new Box(insDia.ScreenX(xPos), insDia.ScreenY(yPos), insDia.ScreenX(xPos)+barWidth, insDia.ScreenY(0), "#FF0000", "", "#FFFFFF", 1, "#000000", aInsSDates[i]+"h = "+aInsSValues[i]+" <%=sInsulineUnit%>");
                            }
                            else{
                              new Box(insDia.ScreenX(xPos), insDia.ScreenY(yPos), insDia.ScreenX(xPos)+barWidth, insDia.ScreenY(0), "#0000FF", "", "#000000", 1, "#000000", aInsSDates[i]+"h = "+aInsSValues[i]+" <%=sInsulineUnit%>");
                            }

                            if(i < aInsSValues.length-1){
                              var nextYear  = aInsSDates[i+1].substr(aInsSDates[i+1].lastIndexOf("/")+1,4);
                              var nextMonth = (aInsSDates[i+1].substr(aInsSDates[i+1].indexOf("/")+1,2)*1)-1;
                              var nextDay   = aInsSDates[i+1].substr(0,aInsSDates[i+1].indexOf("/"))*1;
                              var nextHour  = aInsSDates[i].substr(aInsSDates[i].lastIndexOf("/")+6,2)*1;

                              xPosNext = Date.UTC(nextYear,nextMonth,nextDay,nextHour,0,0);
                              yPosNext = aInsSValues[i];

                              if(hour==17){
                                new Box(insDia.ScreenX(xPosNext), insDia.ScreenY(yPosNext), insDia.ScreenX(xPosNext)+barWidth, insDia.ScreenY(0), "#FF0000", "", "#FFFFFF", 1, "#000000", aInsSDates[i]+"h = "+aInsSValues[i]+" <%=sInsulineUnit%>");
                              }
                              else{
                                new Box(insDia.ScreenX(xPosNext), insDia.ScreenY(yPosNext), insDia.ScreenX(xPosNext)+barWidth, insDia.ScreenY(0), "#0000FF", "", "#000000", 1, "#000000", aInsSDates[i]+"h = "+aInsSValues[i]+" <%=sInsulineUnit%>");
                              }
                            }
                          }
                        //}
                      }
                          drawGraph_InsulineSlow("<%=sBeginDate%>");
                        </script>
                    <%
                }
                else{
                    %><%=getTran("web","nodataavailable",sWebLanguage)%>
                <script>
                    document.getElementById("insulineSlowGraph").style.height=30;
                </script>
                <%
                }
            %>
            </div>
        </td>
    </tr>

    <%-- LEGEND ------------------------------------------------------------------------------------------------------%>
    <tr>
        <td class="admin" colspan="2"><%=getTran("web","legend",sWebLanguage)%>&nbsp;</td>
        <td class="admin" align="right" width ="1%" style="vertical-align:bottom;">
            <a href="#topp" class="topbutton">&nbsp;</a>
        </td>
    </tr>

    <tr><td class="admin2" colspan="3">&nbsp;<font color="#0000FF">08h00 <%=getTran("Web","morning",sWebLanguage)%></font>
        &nbsp;<font color="#00AA00">12h00 <%=getTran("Web","noon",sWebLanguage)%></font>
        &nbsp;<font color="#FF0000">17h00 <%=getTran("Web","evening",sWebLanguage)%></font></td></tr>
</table>
    <%
        }
    %>
<%-- BUTTONS --%>
<%=ScreenHelper.alignButtonsStart()%>
    <%
        if(activeUser.getAccessRight("occup.diabetesfollowup.add") || activeUser.getAccessRight("occup.diabetesfollowup.edit")){
            %><INPUT class="button" type="button" name="saveButton" id="saveButton" value="<%=getTran("Web","save",sWebLanguage)%>" onclick="submitForm();"/><%
        }
    %>
    <INPUT class="button" type="button" name="backButton" value="<%=getTran("Web","Back",sWebLanguage)%>" onclick="doBack();">
<%=ScreenHelper.alignButtonsStop()%>

<script>
  document.getElementById("focusField").focus();

  toggleGraph('glycemyGraph');
  toggleGraph('insulineRapidGraph');
  toggleGraph('insulineSemiRapidGraph');
  toggleGraph('insulineSlowGraph');

  <%-- TOGGLE GRAPH --%>
  <%
      String showGraphTran = getTranNoLink("web","showGraph",sWebLanguage),
             hideGraphTran = getTranNoLink("web","hideGraph",sWebLanguage);
  %>
  function toggleGraph(graphId){
    var headerObj = document.getElementById('header_'+graphId);
    var divObj = document.getElementById(graphId);
    var imgObj = document.getElementById('img_'+graphId);

    if(divObj.style.display == 'none'){
      divObj.style.display = 'block';
      headerObj.title = "<%=hideGraphTran%>";
      imgObj.src = "<%=sCONTEXTPATH%>/_img/minus.png";
    }
    else{
      divObj.style.display = 'none';
      headerObj.title = "<%=showGraphTran%>";
      imgObj.src = "<%=sCONTEXTPATH%>/_img/plus.png";
    }
  }
</script>
<%=ScreenHelper.contextFooter(request)%>
</form>
<%=writeJSButtons("transactionForm","saveButton")%>