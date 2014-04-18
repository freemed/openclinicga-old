<%@include file="/includes/validateUser.jsp"%>
<%@page errorPage="/includes/error.jsp"%>
<%=checkPermission("occup.protocol.oesophagogastroduodenoscopy","select",activeUser)%>
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
    <table class="list" width="100%" cellspacing="1">
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
                <textarea onkeyup="resizeTextarea(this,10);limitChars(this,255);" <%=setRightClick("ITEM_TYPE_OESOPHAGOGASTRODUODENOSCOPY_PROTOCOL_MOTIVE")%> class="text" cols="50" rows="2"  name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OESOPHAGOGASTRODUODENOSCOPY_PROTOCOL_MOTIVE" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OESOPHAGOGASTRODUODENOSCOPY_PROTOCOL_MOTIVE" property="value"/></textarea>
            </td>
            <td class="admin"><%=getTran("openclinic.chuk","premedication",sWebLanguage)%></td>
            <td class="admin2">
                <textarea onkeyup="resizeTextarea(this,10);limitChars(this,255);" <%=setRightClick("ITEM_TYPE_OESOPHAGOGASTRODUODENOSCOPY_PROTOCOL_PREMEDICATION")%> class="text" cols="50" rows="2"  name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OESOPHAGOGASTRODUODENOSCOPY_PROTOCOL_PREMEDICATION" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OESOPHAGOGASTRODUODENOSCOPY_PROTOCOL_PREMEDICATION" property="value"/></textarea>
            </td>
        </tr>
        <tr>
            <td class="admin"><%=getTran("openclinic.chuk","endoscopy_type",sWebLanguage)%></td>
            <td class="admin2">
                <textarea onkeyup="resizeTextarea(this,10);limitChars(this,255);" <%=setRightClick("ITEM_TYPE_OESOPHAGOGASTRODUODENOSCOPY_PROTOCOL_ENDOSCOPY_TYPE")%> class="text" cols="50" rows="2"  name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OESOPHAGOGASTRODUODENOSCOPY_PROTOCOL_ENDOSCOPY_TYPE" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OESOPHAGOGASTRODUODENOSCOPY_PROTOCOL_ENDOSCOPY_TYPE" property="value"/></textarea>
            </td>
            <td class="admin"><%=getTran("openclinic.chuk","oesophago",sWebLanguage)%></td>
            <td class="admin2">
                <textarea onkeyup="resizeTextarea(this,10);limitChars(this,255);" <%=setRightClick("ITEM_TYPE_OESOPHAGOGASTRODUODENOSCOPY_PROTOCOL_OESOPHAGO")%> class="text" cols="50" rows="2"  name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OESOPHAGOGASTRODUODENOSCOPY_PROTOCOL_OESOPHAGO" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OESOPHAGOGASTRODUODENOSCOPY_PROTOCOL_OESOPHAGO" property="value"/></textarea>
            </td>
        </tr>
    </table>
    <br>
    <table class="list" width="100%" cellspacing="1">
        <tr class="admin">
            <td colspan="4"><%=getTran("openclinic.chuk","cardio",sWebLanguage)%></td>
        </tr>
        <tr>
            <td class="admin" width="<%=sTDAdminWidth%>"><%=getTran("openclinic.chuk","stomach",sWebLanguage)%></td>
            <td class="admin2">
                <textarea onkeyup="resizeTextarea(this,10);limitChars(this,255);" <%=setRightClick("ITEM_TYPE_OESOPHAGOGASTRODUODENOSCOPY_PROTOCOL_STOMACH")%> class="text" cols="50" rows="2"  name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OESOPHAGOGASTRODUODENOSCOPY_PROTOCOL_STOMACH" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OESOPHAGOGASTRODUODENOSCOPY_PROTOCOL_STOMACH" property="value"/></textarea>
            </td>
            <td class="admin" width="<%=sTDAdminWidth%>"><%=getTran("openclinic.chuk","pylorus",sWebLanguage)%></td>
            <td class="admin2">
                <textarea onkeyup="resizeTextarea(this,10);limitChars(this,255);" <%=setRightClick("ITEM_TYPE_OESOPHAGOGASTRODUODENOSCOPY_PROTOCOL_PYLORUS")%> class="text" cols="50" rows="2"  name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OESOPHAGOGASTRODUODENOSCOPY_PROTOCOL_PYLORUS" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OESOPHAGOGASTRODUODENOSCOPY_PROTOCOL_PYLORUS" property="value"/></textarea>
            </td>
        </tr>
        <tr>
            <td class="admin" style="padding-left: 40px;"><%=getTran("openclinic.chuk","liquide_quantity_aspect",sWebLanguage)%></td>
            <td class="admin2">
                <textarea onkeyup="resizeTextarea(this,10);limitChars(this,255);" <%=setRightClick("ITEM_TYPE_OESOPHAGOGASTRODUODENOSCOPY_PROTOCOL_LIQUIDE_QUANTITY_ASPECT")%> class="text" cols="50" rows="2"  name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OESOPHAGOGASTRODUODENOSCOPY_PROTOCOL_LIQUIDE_QUANTITY_ASPECT" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OESOPHAGOGASTRODUODENOSCOPY_PROTOCOL_LIQUIDE_QUANTITY_ASPECT" property="value"/></textarea>
            </td>
            <td class="admin"><%=getTran("openclinic.chuk","bulb",sWebLanguage)%></td>
            <td class="admin2">
                <textarea onkeyup="resizeTextarea(this,10);limitChars(this,255);" <%=setRightClick("ITEM_TYPE_OESOPHAGOGASTRODUODENOSCOPY_PROTOCOL_BULB")%> class="text" cols="50" rows="2"  name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OESOPHAGOGASTRODUODENOSCOPY_PROTOCOL_BULB" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OESOPHAGOGASTRODUODENOSCOPY_PROTOCOL_BULB" property="value"/></textarea>
            </td>
        </tr>
        <tr>
            <td class="admin" style="padding-left: 40px;"><%=getTran("openclinic.chuk","pH",sWebLanguage)%></td>
            <td class="admin2">
                <textarea onkeyup="resizeTextarea(this,10);limitChars(this,255);" <%=setRightClick("ITEM_TYPE_OESOPHAGOGASTRODUODENOSCOPY_PROTOCOL_PH")%> class="text" cols="50" rows="2"  name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OESOPHAGOGASTRODUODENOSCOPY_PROTOCOL_PH" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OESOPHAGOGASTRODUODENOSCOPY_PROTOCOL_PH" property="value"/></textarea>
            </td>
            <td class="admin"><%=getTran("openclinic.chuk","duodenum",sWebLanguage)%></td>
            <td class="admin2">
                <textarea onkeyup="resizeTextarea(this,10);limitChars(this,255);" <%=setRightClick("ITEM_TYPE_OESOPHAGOGASTRODUODENOSCOPY_PROTOCOL_DUODENUM")%> class="text" cols="50" rows="2"  name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OESOPHAGOGASTRODUODENOSCOPY_PROTOCOL_DUODENUM" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OESOPHAGOGASTRODUODENOSCOPY_PROTOCOL_DUODENUM" property="value"/></textarea>
            </td>
        </tr>
        <tr>
            <td class="admin" style="padding-left: 40px;"><%=getTran("openclinic.chuk","fundus",sWebLanguage)%></td>
            <td class="admin2">
                <textarea onkeyup="resizeTextarea(this,10);limitChars(this,255);" <%=setRightClick("ITEM_TYPE_OESOPHAGOGASTRODUODENOSCOPY_PROTOCOL_FUNDUS")%> class="text" cols="50" rows="2"  name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OESOPHAGOGASTRODUODENOSCOPY_PROTOCOL_FUNDUS" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OESOPHAGOGASTRODUODENOSCOPY_PROTOCOL_FUNDUS" property="value"/></textarea>
            </td>
            <td class="admin"><%=getTran("openclinic.chuk","Investigations_done",sWebLanguage)%></td>
            <td class="admin2">
                <input <%=setRightClick("ITEM_TYPE_OESOPHAGOGASTRODUODENOSCOPY_PROTOCOL_BIOSCOPY")%> type="checkbox" id="central"   name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OESOPHAGOGASTRODUODENOSCOPY_PROTOCOL_BIOSCOPY" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OESOPHAGOGASTRODUODENOSCOPY_PROTOCOL_BIOSCOPY;value=medwan.common.true" property="value" outputString="checked"/> value="medwan.common.true"/><label for="central"><%=getTran("openclinic.chuk","biopsy",sWebLanguage)%></label>
            </td>
        </tr>
        <tr>
            <td class="admin" style="padding-left: 40px;"><%=getTran("openclinic.chuk","antre",sWebLanguage)%></td>
            <td class="admin2">
                <textarea onkeyup="resizeTextarea(this,10);limitChars(this,255);" <%=setRightClick("ITEM_TYPE_OESOPHAGOGASTRODUODENOSCOPY_PROTOCOL_ANTRE")%> class="text" cols="50" rows="2"  name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OESOPHAGOGASTRODUODENOSCOPY_PROTOCOL_ANTRE" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OESOPHAGOGASTRODUODENOSCOPY_PROTOCOL_ANTRE" property="value"/></textarea>
            </td>
            <td class="admin"><%=getTran("openclinic.chuk","conclusion",sWebLanguage)%></td>
            <td class="admin2">
                <textarea onkeyup="resizeTextarea(this,10);limitChars(this,255);" <%=setRightClick("ITEM_TYPE_OESOPHAGOGASTRODUODENOSCOPY_PROTOCOL_CONCLUSION")%> class="text" cols="50" rows="2"  name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OESOPHAGOGASTRODUODENOSCOPY_PROTOCOL_CONCLUSION" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OESOPHAGOGASTRODUODENOSCOPY_PROTOCOL_CONCLUSION" property="value"/></textarea>
            </td>
        </tr>
        <tr>
            <td class="admin"><%=getTran("openclinic.chuk","remarks",sWebLanguage)%></td>
            <td class="admin2">
                <textarea onkeyup="resizeTextarea(this,10);limitChars(this,255);" <%=setRightClick("ITEM_TYPE_OESOPHAGOGASTRODUODENOSCOPY_PROTOCOL_REMARKS")%> class="text" cols="50" rows="2"  name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OESOPHAGOGASTRODUODENOSCOPY_PROTOCOL_REMARKS" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OESOPHAGOGASTRODUODENOSCOPY_PROTOCOL_REMARKS" property="value"/></textarea>
            </td>
            <td class="admin"/>
            <td class="admin2"/>
        </tr>
        <tr>
            <td class="admin"/>
            <td class="admin2" colspan="3">
<%-- BUTTONS --%>
    <%
      if (activeUser.getAccessRight("occup.protocol.oesophagogastroduodenoscopy.add") || activeUser.getAccessRight("occup.protocol.oesophagogastroduodenoscopy.edit")){
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