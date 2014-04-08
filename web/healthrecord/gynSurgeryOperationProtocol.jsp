<%@include file="/includes/validateUser.jsp"%>
<%@page errorPage="/includes/error.jsp"%>

<%=checkPermission("occup.operationprotocol","select",activeUser)%>

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
        String sTransactionStart    = getItemType(tran.getItems(),sPREFIX+"ITEM_TYPE_OPERATION_PROTOCOL_START"),
               sTransactionEnd      = getItemType(tran.getItems(),sPREFIX+"ITEM_TYPE_OPERATION_PROTOCOL_END"),
               sTransactionDuration = getItemType(tran.getItems(),sPREFIX+"ITEM_TYPE_OPERATION_PROTOCOL_DURATION");
    %>

    <table class="list" cellspacing="1" cellpadding="0" width="100%">
        <%-- DATE --%>
        <tr>
            <td class="admin" colspan="2">
                <a href="javascript:openHistoryPopup();" title="<%=getTran("Web.Occup","History",sWebLanguage)%>">...</a>&nbsp;
                <%=getTran("Web.Occup","medwan.common.date",sWebLanguage)%>
            </td>
            <td class="admin2">
                <input type="text" class="text" size="12" maxLength="10" name="currentTransactionVO.<TransactionVO[hashCode=<bean:write name="transaction" scope="page" property="transactionId"/>]>.updateTime" value="<mxs:propertyAccessorI18N name="transaction" scope="page" property="updateTime" formatType="date" format="dd-mm-yyyy"/>" id="trandate" OnBlur='checkDate(this)'>
                <script>writeTranDate();</script>
            </td>
        </tr>

        <%-- START HOUR --%>
        <tr>
            <td class="admin" colspan="2"><%=getTran("openclinic.chuk","starthour",sWebLanguage)%></td>
            <td class="admin2">
                <input <%=setRightClick("ITEM_TYPE_OPERATION_PROTOCOL_START")%> class="text" type="text" size="5" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPERATION_PROTOCOL_START" property="itemId"/>]>.value" value="<%=sTransactionStart%>" onblur="checkTime(this);calculateDuration(this);"onkeypress="keypressTime(this)">
            </td>
        </tr>

        <%-- END HOUR --%>
        <tr>
            <td class="admin" colspan="2"><%=getTran("openclinic.chuk","endhour",sWebLanguage)%></td>
            <td class="admin2">
                <input <%=setRightClick("ITEM_TYPE_OPERATION_PROTOCOL_END")%> class="text" type="text" size="5" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPERATION_PROTOCOL_END" property="itemId"/>]>.value" value="<%=sTransactionEnd%>" onblur="checkTime(this);calculateDuration(this);"onkeypress="keypressTime(this)">
            </td>
        </tr>

        <%-- DURATION --%>
        <tr>
            <td class="admin" colspan="2"><%=getTran("openclinic.chuk","duration",sWebLanguage)%></td>
            <td class="admin2">
                <input <%=setRightClick("ITEM_TYPE_OPERATION_PROTOCOL_DURATION")%> class="text" type="text" size="5" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPERATION_PROTOCOL_DURATION" property="itemId"/>]>.value" value="<%=sTransactionDuration%>" onblur="checkTime(this);" readonly>
            </td>
        </tr>

        <%-- DIAGNOSTIC --%>
        <tr>
            <td class="admin" colspan="2"><%=getTran("openclinic.chuk","diagnostic",sWebLanguage)%></td>
            <td class="admin2">
                <textarea onKeyup="resizeTextarea(this,10);limitChars(this,255);" <%=setRightClick("ITEM_TYPE_OPERATION_PROTOCOL_DIAGNOSTIC")%> class="text" cols="100" rows="2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPERATION_PROTOCOL_DIAGNOSTIC" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPERATION_PROTOCOL_DIAGNOSTIC" property="value"/></textarea>
            </td>
        </tr>

        <%-- MAMMOGRPHY --%>
        <tr>
            <td class="admin" colspan="2"><%=getTran("openclinic.chuk","mammography",sWebLanguage)%></td>
            <td class="admin2">
                <textarea onKeyup="resizeTextarea(this,10);limitChars(this,255);" <%=setRightClick("ITEM_TYPE_OPERATION_PROTOCOL_MAMMOGRAPHY")%> class="text" cols="100" rows="2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPERATION_PROTOCOL_MAMMOGRAPHY" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPERATION_PROTOCOL_MAMMOGRAPHY" property="value"/></textarea>
            </td>
        </tr>

        <%-- INTERVENTION --%>
        <tr>
            <td class="admin" colspan="2"><%=getTran("openclinic.chuk","intervention",sWebLanguage)%></td>
            <td class="admin2">
                <textarea onKeyup="resizeTextarea(this,10);limitChars(this,255);" <%=setRightClick("ITEM_TYPE_OPERATION_PROTOCOL_INTERVENTION")%> class="text" cols="100" rows="2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPERATION_PROTOCOL_INTERVENTION" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPERATION_PROTOCOL_INTERVENTION" property="value"/></textarea>
            </td>
        </tr>

        <%-- GROUP COMPOSITION --%>
        <tr>
            <td class="admin" rowspan="3" width="100"><%=getTran("openclinic.chuk","group.composition",sWebLanguage)%></td>
            <td class="admin" width="150"><%=getTran("openclinic.chuk","surgeons",sWebLanguage)%></td>
            <td class="admin2">
                <textarea onKeyup="resizeTextarea(this,10);limitChars(this,255);" <%=setRightClick("ITEM_TYPE_OPERATION_PROTOCOL_SURGEONS")%> class="text" cols="100" rows="2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPERATION_PROTOCOL_SURGEONS" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPERATION_PROTOCOL_SURGEONS" property="value"/></textarea>
            </td>
        </tr>

        <%-- ANESTHESISTS --%>
        <tr>
            <td class="admin"><%=getTran("openclinic.chuk","anasthesists",sWebLanguage)%></td>
            <td class="admin2">
                <textarea onKeyup="resizeTextarea(this,10);limitChars(this,255);" <%=setRightClick("ITEM_TYPE_OPERATION_PROTOCOL_ANASTHESISTS")%> class="text" cols="100" rows="2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPERATION_PROTOCOL_ANASTHESISTS" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPERATION_PROTOCOL_ANASTHESISTS" property="value"/></textarea>
            </td>
        </tr>

        <%-- NURSES --%>
        <tr>
            <td class="admin"><%=getTran("openclinic.chuk","nurses",sWebLanguage)%></td>
            <td class="admin2">
                <textarea onKeyup="resizeTextarea(this,10);limitChars(this,255);" <%=setRightClick("ITEM_TYPE_OPERATION_PROTOCOL_NURSES")%> class="text" cols="100" rows="2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPERATION_PROTOCOL_NURSES" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPERATION_PROTOCOL_NURSES" property="value"/></textarea>
            </td>
        </tr>

        <%-- INSTALLATION --%>
        <tr>
            <td class="admin" colspan="2"><%=getTran("openclinic.chuk","patient.installation",sWebLanguage)%></td>
            <td class="admin2">
                <textarea onKeyup="resizeTextarea(this,10);limitChars(this,255);" <%=setRightClick("ITEM_TYPE_OPERATION_PROTOCOL_PATIENT_INSTALLATION")%> class="text" cols="100" rows="2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPERATION_PROTOCOL_PATIENT_INSTALLATION" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPERATION_PROTOCOL_PATIENT_INSTALLATION" property="value"/></textarea>
            </td>
        </tr>

        <%-- APROVAL --%>
        <tr>
            <td class="admin" colspan="2"><%=getTran("openclinic.chuk","aproval",sWebLanguage)%></td>
            <td class="admin2">
                <textarea onKeyup="resizeTextarea(this,10);limitChars(this,255);" <%=setRightClick("ITEM_TYPE_OPERATION_PROTOCOL_APROVAL")%> class="text" cols="100" rows="2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPERATION_PROTOCOL_APROVAL" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPERATION_PROTOCOL_APROVAL" property="value"/></textarea>
            </td>
        </tr>

        <%-- OBSERVATIONS --%>
        <tr>
            <td class="admin" colspan="2"><%=getTran("openclinic.chuk","observations",sWebLanguage)%></td>
            <td class="admin2">
                <textarea onKeyup="resizeTextarea(this,10);limitChars(this,255);" <%=setRightClick("ITEM_TYPE_OPERATION_PROTOCOL_OBSERVATION")%> class="text" cols="100" rows="2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPERATION_PROTOCOL_OBSERVATION" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPERATION_PROTOCOL_OBSERVATION" property="value"/></textarea>
            </td>
        </tr>

        <%-- SURGICAL ACT --%>
         <tr>
            <td class="admin" colspan="2"><%=getTran("openclinic.chuk","surgical.act",sWebLanguage)%></td>
            <td class="admin2">
                <textarea onKeyup="resizeTextarea(this,10);limitChars(this,255);" <%=setRightClick("ITEM_TYPE_OPERATION_PROTOCOL_SURGICAL_ACT")%> class="text" cols="100" rows="2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPERATION_PROTOCOL_SURGICAL_ACT" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPERATION_PROTOCOL_SURGICAL_ACT" property="value"/></textarea>
            </td>
        </tr>

        <%-- CLOSURE --%>
        <tr>
            <td class="admin" colspan="2"><%=getTran("openclinic.chuk","closure",sWebLanguage)%></td>
            <td class="admin2">
                <textarea onKeyup="resizeTextarea(this,10);limitChars(this,255);" <%=setRightClick("ITEM_TYPE_OPERATION_PROTOCOL_CLOSURE")%> class="text" cols="100" rows="2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPERATION_PROTOCOL_CLOSURE" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPERATION_PROTOCOL_CLOSURE" property="value"/></textarea>
            </td>
        </tr>

        <%-- CARE --%>
        <tr>
            <td class="admin" colspan="2"><%=getTran("openclinic.chuk","care.post.op",sWebLanguage)%></td>
            <td class="admin2">
                <textarea onKeyup="resizeTextarea(this,10);limitChars(this,255);" <%=setRightClick("ITEM_TYPE_OPERATION_PROTOCOL_CARE")%> class="text" cols="100" rows="2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPERATION_PROTOCOL_CARE" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPERATION_PROTOCOL_CARE" property="value"/></textarea>
            </td>
        </tr>

        <%-- REMARKS --%>
        <tr>
            <td class="admin" colspan="2"><%=getTran("openclinic.chuk","remarks",sWebLanguage)%></td>
            <td class="admin2">
                <textarea onKeyup="resizeTextarea(this,10);limitChars(this,255);" <%=setRightClick("ITEM_TYPE_OPERATION_PROTOCOL_REMARKS")%> class="text" cols="100" rows="2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPERATION_PROTOCOL_REMARKS" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPERATION_PROTOCOL_REMARKS" property="value"/></textarea>
            </td>
        </tr>
        
        <%-- BUTTONS --%>
        <tr>
            <td class="admin" colspan="2"/>
            <td class="admin2">
                <%=getButtonsHtml(request,activeUser,activePatient,"occup.operationprotocol",sWebLanguage)%>
            </td>
        </tr>
    </table>

    <%=ScreenHelper.contextFooter(request)%>
</form>

<script>
  <%-- SUBMIT FORM --%>
  function submitForm(){
    var temp = Form.findFirstElement(transactionForm);//for ff compatibility
    document.transactionForm.submit();
    document.getElementById("buttonsDiv").style.visibility = "hidden";
  }

  <%-- CALULATE DURATION --%>
  function calculateDuration(obj){
    var vStart = document.getElementsByName("currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPERATION_PROTOCOL_START" property="itemId"/>]>.value")[0].value;
    var vEnd   = document.getElementsByName("currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPERATION_PROTOCOL_END" property="itemId"/>]>.value")[0].value;

    var aStart = vStart.split(":");
    var aEnd = vEnd.split(":");

    var startDate = new Date();
    startDate.setHours(aStart[0]);
    startDate.setMinutes(aStart[1]);
    startDate.setSeconds(0);

    var endDate = new Date();
    endDate.setHours(aEnd[0]);
    endDate.setMinutes(aEnd[1]);
    endDate.setSeconds(0);

    var one_min = 1000*60;

    var vDurationDate = new Date();
    vDurationDate.setHours(0);
    vDurationDate.setMinutes(Math.ceil((endDate.getTime()-startDate.getTime())/(one_min)));
    vDurationDate.setSeconds(0);

    if(vStart != "" && vEnd != ""){
      if(endDate > startDate){
        document.getElementsByName("currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPERATION_PROTOCOL_DURATION" property="itemId"/>]>.value")[0].value = vDurationDate.getHours() + ":" + vDurationDate.getMinutes();
      }
      else{
        document.getElementsByName("currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPERATION_PROTOCOL_DURATION" property="itemId"/>]>.value")[0].value = "";
        var popupUrl = "<c:url value="/popup.jsp"/>?Page=_common/search/okPopup.jsp&ts=<%=getTs()%>&labelType=web&labelID=endhour_greater_than_starthour";
        var modalities = "dialogWidth:266px;dialogHeight:163px;center:yes;scrollbars:no;resizable:no;status:no;location:no;";
        (window.showModalDialog)?window.showModalDialog(popupUrl,"",modalities):window.confirm("<%=getTranNoLink("web","endhour_greater_than_starthour",sWebLanguage)%>");
        obj.value = "";
      }
    }
    else{
      document.getElementsByName("currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPERATION_PROTOCOL_DURATION" property="itemId"/>]>.value")[0].value = "";
    }
  }
</script>