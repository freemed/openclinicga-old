<%@include file="/includes/validateUser.jsp"%>
<%@page errorPage="/includes/error.jsp"%>
<%=checkPermission("occup.protocol.cardioechography","select",activeUser)%>
<form name="transactionForm" method="POST" action='<c:url value="/healthrecord/updateTransaction.do"/>?ts=<%=getTs()%>' onclick="setSaveButton(event);" onkeyup="setSaveButton(event);">
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
        String sAO = "";
        String sSeptum = "";
        String sOg = "";
        String sParoiPost = "";
        String sDtdvgA = "";
        String sFe = "";
        String sDtdvgB = "";
        String sRaccouc = "";
        String sVd = "";
        String sPericardium = "";
        String sMitralValve = "";
        String sValveAort = "";
        String sValveTric = "";
        String sValvePulm = "";

        if (transaction != null){
            TransactionVO tran = (TransactionVO)transaction;
            if (tran!=null){
                sAO = getItemType(tran.getItems(),"be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CARDIO_ECHOGRAPHY_PROTOCOL_AO");
                sSeptum = getItemType(tran.getItems(),"be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CARDIO_ECHOGRAPHY_PROTOCOL_SEPTUM");
                sOg = getItemType(tran.getItems(),"be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CARDIO_ECHOGRAPHY_PROTOCOL_OG");
                sParoiPost = getItemType(tran.getItems(),"be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CARDIO_ECHOGRAPHY_PROTOCOL_PAROI_POST");
                sDtdvgA = getItemType(tran.getItems(),"be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CARDIO_ECHOGRAPHY_PROTOCOL_DTDVGA");
                sFe = getItemType(tran.getItems(),"be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CARDIO_ECHOGRAPHY_PROTOCOL_FE");
                sDtdvgB = getItemType(tran.getItems(),"be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CARDIO_ECHOGRAPHY_PROTOCOL_DTDVGB");
                sRaccouc = getItemType(tran.getItems(),"be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CARDIO_ECHOGRAPHY_PROTOCOL_RACCOUC");
                sVd = getItemType(tran.getItems(),"be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CARDIO_ECHOGRAPHY_PROTOCOL_VD");
                sPericardium = getItemType(tran.getItems(),"be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CARDIO_ECHOGRAPHY_PROTOCOL_PERICARDIUM");
                sMitralValve = getItemType(tran.getItems(),"be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CARDIO_ECHOGRAPHY_PROTOCOL_MITRAL_VALVE");
                sValveAort = getItemType(tran.getItems(),"be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CARDIO_ECHOGRAPHY_PROTOCOL_VALVE_AORT");
                sValveTric = getItemType(tran.getItems(),"be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CARDIO_ECHOGRAPHY_PROTOCOL_VALVE_TRIC");
                sValvePulm = getItemType(tran.getItems(),"be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CARDIO_ECHOGRAPHY_PROTOCOL_VALVE_PULM");
            }
        }
    %>
    <table class="list" width="100%" cellspacing="1" border="0">
        <%-- DATE --%>
        <tr>
            <td class="admin" width="<%=sTDAdminWidth%>">
                <a href="javascript:openHistoryPopup();" title="<%=getTran("Web.Occup","History",sWebLanguage)%>">...</a>&nbsp;
                <%=getTran("Web.Occup","medwan.common.date",sWebLanguage)%>
            </td>
            <td class="admin2">
                <input type="text" class="text" size="12" maxLength="10" name="currentTransactionVO.<TransactionVO[hashCode=<bean:write name="transaction" scope="page" property="transactionId"/>]>.updateTime" value="<mxs:propertyAccessorI18N name="transaction" scope="page" property="updateTime" formatType="date" format="dd-mm-yyyy"/>" id="trandate" OnBlur='checkDate(this)'>
                <script>writeTranDate();</script>
            </td>
            <td class="admin" width="<%=sTDAdminWidth%>"/>
            <td class="admin2"/>
        </tr>
        <tr>
            <td class="admin"><%=getTran("openclinic.chuk","motive",sWebLanguage)%></td>
            <td class="admin2">
                <textarea onkeyup="resizeTextarea(this,10);limitChars(this,255);" <%=setRightClick("ITEM_TYPE_CARDIO_ECHOGRAPHY_PROTOCOL_MOTIVE")%> class="text" cols="50" rows="2"  name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CARDIO_ECHOGRAPHY_PROTOCOL_MOTIVE" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CARDIO_ECHOGRAPHY_PROTOCOL_MOTIVE" property="value"/></textarea>
            </td>
            <td class="admin">Mode</td>
            <td class="admin2">
                <input <%=setRightClick("ITEM_TYPE_CARDIO_ECHOGRAPHY_PROTOCOL_TM")%> type="checkbox" id="tm"   name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CARDIO_ECHOGRAPHY_PROTOCOL_TM" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CARDIO_ECHOGRAPHY_PROTOCOL_TM;value=medwan.common.true" property="value" outputString="checked"/> value="medwan.common.true"/><label for="tm"><%=getTran("openclinic.chuk","tm",sWebLanguage)%></label>
                &nbsp;&nbsp;&nbsp;<input <%=setRightClick("ITEM_TYPE_CARDIO_ECHOGRAPHY_PROTOCOL_2D")%> type="checkbox" id="2d"   name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CARDIO_ECHOGRAPHY_PROTOCOL_2D" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CARDIO_ECHOGRAPHY_PROTOCOL_2D;value=medwan.common.true" property="value" outputString="checked"/> value="medwan.common.true"/><label for="2d"><%=getTran("openclinic.chuk","2d",sWebLanguage)%></label>
            </td>
        </tr>
        <tr>
            <td class="admin"><%=getTran("openclinic.chuk","ao",sWebLanguage)%></td>
            <td class="admin2">
                <input <%=setRightClick("ITEM_TYPE_CARDIO_ECHOGRAPHY_PROTOCOL_AO")%> type="text" class="text" size="50" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CARDIO_ECHOGRAPHY_PROTOCOL_AO" property="itemId"/>]>.value" value="<%=sAO%>">
            </td>
            <td class="admin"><%=getTran("openclinic.chuk","septum",sWebLanguage)%></td>
            <td class="admin2">
                <input <%=setRightClick("ITEM_TYPE_CARDIO_ECHOGRAPHY_PROTOCOL_SEPTUM")%> type="text" class="text" size="50" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CARDIO_ECHOGRAPHY_PROTOCOL_SEPTUM" property="itemId"/>]>.value" value="<%=sSeptum%>">
            </td>
        </tr>
        <tr>
            <td class="admin"><%=getTran("openclinic.chuk","og",sWebLanguage)%></td>
            <td class="admin2">
                <input <%=setRightClick("ITEM_TYPE_CARDIO_ECHOGRAPHY_PROTOCOL_OG")%> type="text" class="text" size="50" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CARDIO_ECHOGRAPHY_PROTOCOL_OG" property="itemId"/>]>.value" value="<%=sOg%>">
            </td>
            <td class="admin"><%=getTran("openclinic.chuk","paroi_post",sWebLanguage)%></td>
            <td class="admin2">
                <input <%=setRightClick("ITEM_TYPE_CARDIO_ECHOGRAPHY_PROTOCOL_PAROI_POST")%> type="text" class="text" size="50" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CARDIO_ECHOGRAPHY_PROTOCOL_PAROI_POST" property="itemId"/>]>.value" value="<%=sParoiPost%>">
            </td>
        </tr>
        <tr>
            <td class="admin"><%=getTran("openclinic.chuk","dtdvg",sWebLanguage)%></td>
            <td class="admin2">
                <input <%=setRightClick("ITEM_TYPE_CARDIO_ECHOGRAPHY_PROTOCOL_DTDVGA")%> type="text" class="text" size="50" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CARDIO_ECHOGRAPHY_PROTOCOL_DTDVGA" property="itemId"/>]>.value" value="<%=sDtdvgA%>">
            </td>
            <td class="admin"><%=getTran("openclinic.chuk","fe",sWebLanguage)%></td>
            <td class="admin2">
                <input <%=setRightClick("ITEM_TYPE_CARDIO_ECHOGRAPHY_PROTOCOL_FE")%> type="text" class="text" size="50" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CARDIO_ECHOGRAPHY_PROTOCOL_FE" property="itemId"/>]>.value" value="<%=sFe%>">
            </td>
        </tr>
        <tr>
            <td class="admin"><%=getTran("openclinic.chuk","dtdvg",sWebLanguage)%></td>
            <td class="admin2">
                <input <%=setRightClick("ITEM_TYPE_CARDIO_ECHOGRAPHY_PROTOCOL_DTDVGB")%> type="text" class="text" size="50" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CARDIO_ECHOGRAPHY_PROTOCOL_DTDVGB" property="itemId"/>]>.value" value="<%=sDtdvgB%>">
            </td>
            <td class="admin">% <%=getTran("openclinic.chuk","raccouc",sWebLanguage)%></td>
            <td class="admin2">
                <input <%=setRightClick("ITEM_TYPE_CARDIO_ECHOGRAPHY_PROTOCOL_RACCOUC")%> type="text" class="text" size="50" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CARDIO_ECHOGRAPHY_PROTOCOL_RACCOUC" property="itemId"/>]>.value" value="<%=sRaccouc%>">
            </td>
        </tr>
        <tr>
            <td class="admin"><%=getTran("openclinic.chuk","vd",sWebLanguage)%></td>
            <td class="admin2">
                <input <%=setRightClick("ITEM_TYPE_CARDIO_ECHOGRAPHY_PROTOCOL_VD")%> type="text" class="text" size="50" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CARDIO_ECHOGRAPHY_PROTOCOL_VD" property="itemId"/>]>.value" value="<%=sVd%>">
            </td>
            <td class="admin"><%=getTran("openclinic.chuk","pericardium",sWebLanguage)%></td>
            <td class="admin2">
                <input <%=setRightClick("ITEM_TYPE_CARDIO_ECHOGRAPHY_PROTOCOL_PERICARDIUM")%> type="text" class="text" size="50" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CARDIO_ECHOGRAPHY_PROTOCOL_PERICARDIUM" property="itemId"/>]>.value" value="<%=sPericardium%>">
            </td>
        </tr>
        <tr>
            <td class="admin"><%=getTran("openclinic.chuk","mitral_valve",sWebLanguage)%></td>
            <td class="admin2">
                <input <%=setRightClick("ITEM_TYPE_CARDIO_ECHOGRAPHY_PROTOCOL_MITRAL_VALVE")%> type="text" class="text" size="50" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CARDIO_ECHOGRAPHY_PROTOCOL_MITRAL_VALVE" property="itemId"/>]>.value" value="<%=sMitralValve%>">
            </td>
            <td class="admin"><%=getTran("openclinic.chuk","valve_aort",sWebLanguage)%></td>
            <td class="admin2">
                <input <%=setRightClick("ITEM_TYPE_CARDIO_ECHOGRAPHY_PROTOCOL_VALVE_AORT")%> type="text" class="text" size="50" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CARDIO_ECHOGRAPHY_PROTOCOL_VALVE_AORT" property="itemId"/>]>.value" value="<%=sValveAort%>">
            </td>
        </tr>
        <tr>
            <td class="admin"><%=getTran("openclinic.chuk","valve_tric",sWebLanguage)%></td>
            <td class="admin2">
                <input <%=setRightClick("ITEM_TYPE_CARDIO_ECHOGRAPHY_PROTOCOL_VALVE_TRIC")%> type="text" class="text" size="50" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CARDIO_ECHOGRAPHY_PROTOCOL_VALVE_TRIC" property="itemId"/>]>.value" value="<%=sValveTric%>">
            </td>
            <td class="admin"><%=getTran("openclinic.chuk","valve_pulm",sWebLanguage)%></td>
            <td class="admin2">
                <input <%=setRightClick("ITEM_TYPE_CARDIO_ECHOGRAPHY_PROTOCOL_VALVE_PULM")%> type="text" class="text" size="50" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CARDIO_ECHOGRAPHY_PROTOCOL_VALVE_PULM" property="itemId"/>]>.value" value="<%=sValvePulm%>">
            </td>
        </tr>
         <tr>
            <td class="admin"><%=getTran("openclinic.chuk","other",sWebLanguage)%></td>
            <td class="admin2">
                <textarea onkeyup="resizeTextarea(this,10);limitChars(this,255);" <%=setRightClick("ITEM_TYPE_CARDIO_ECHOGRAPHY_PROTOCOL_OTHER")%> class="text" cols="50" rows="2"  name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CARDIO_ECHOGRAPHY_PROTOCOL_OTHER" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CARDIO_ECHOGRAPHY_PROTOCOL_OTHER" property="value"/></textarea>
            </td>
            <td class="admin"><%=getTran("openclinic.chuk","doppler",sWebLanguage)%></td>
            <td class="admin2">
                <textarea onkeyup="resizeTextarea(this,10);limitChars(this,255);" <%=setRightClick("ITEM_TYPE_CARDIO_ECHOGRAPHY_PROTOCOL_DOPPLER")%> class="text" cols="50" rows="2"  name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CARDIO_ECHOGRAPHY_PROTOCOL_DOPPLER" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CARDIO_ECHOGRAPHY_PROTOCOL_DOPPLER" property="value"/></textarea>
            </td>
        </tr>
        <tr>
            <td class="admin"><%=getTran("openclinic.chuk","conclusion",sWebLanguage)%></td>
            <td class="admin2">
                <textarea onkeyup="resizeTextarea(this,10);limitChars(this,255);" <%=setRightClick("ITEM_TYPE_CARDIO_ECHOGRAPHY_PROTOCOL_CONCLUSION")%> class="text" cols="50" rows="2"  name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CARDIO_ECHOGRAPHY_PROTOCOL_CONCLUSION" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CARDIO_ECHOGRAPHY_PROTOCOL_CONCLUSION" property="value"/></textarea>
            </td>
            <td class="admin"><%=getTran("openclinic.chuk","remarks",sWebLanguage)%></td>
            <td class="admin2">
                <textarea onkeyup="resizeTextarea(this,10);limitChars(this,255);" <%=setRightClick("ITEM_TYPE_CARDIO_ECHOGRAPHY_PROTOCOL_REMARKS")%> class="text" cols="50" rows="2"  name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CARDIO_ECHOGRAPHY_PROTOCOL_REMARKS" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CARDIO_ECHOGRAPHY_PROTOCOL_REMARKS" property="value"/></textarea>
            </td>
        </tr>
        <tr>
            <td class="admin"/>
            <td class="admin2" colspan="3">
<%-- BUTTONS --%>
    <%
      if (activeUser.getAccessRight("occup.protocol.cardioechography.add") || activeUser.getAccessRight("occup.protocol.cardioechography.edit")){
    %>
                <INPUT class="button" type="button" name="saveButton" value="<%=getTran("Web.Occup","medwan.common.record",sWebLanguage)%>" onclick="doSubmit();"/>
    <%
      }
    %>
                <INPUT class="button" type="button" value="<%=getTran("Web","back",sWebLanguage)%>" onclick="if(checkSaveButton()){window.location.href='<c:url value="/main.do?Page=curative/index.jsp"/>&ts=<%=getTs()%>'}">
            </td>
        </tr>
    </table>
<%=ScreenHelper.contextFooter(request)%>
</form>
<script>
    function doSubmit(){
        transactionForm.saveButton.disabled = true;
        document.transactionForm.submit();
    }
</script>