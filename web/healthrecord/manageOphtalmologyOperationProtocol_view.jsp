<%@include file="/includes/validateUser.jsp"%>
<%@page errorPage="/includes/error.jsp"%>

<%=checkPermission("occup.ophtalmology.operation.protocol","select",activeUser)%>

<form name="transactionForm" method="POST" action='<c:url value="/healthrecord/updateTransaction.do"/>?ts=<%=getTs()%>' onclick="setSaveButton(event);" onkeyup="setSaveButton(event);">
    <bean:define id="transaction" name="be.mxs.webapp.wl.session.SessionContainerFactory.WO_SESSION_CONTAINER" property="currentTransactionVO"/>
	<%=checkPrestationToday(activePatient.personid,false,activeUser,(TransactionVO)transaction) %>
  
    <input type="hidden" id="transactionId" name="currentTransactionVO.<TransactionVO[hashCode=<bean:write name="transaction" scope="page" property="transactionId"/>]>.transactionId" value="<bean:write name="transaction" scope="page" property="transactionId"/>"/>
    <input type="hidden" id="serverId" name="currentTransactionVO.<TransactionVO[hashCode=<bean:write name="transaction" scope="page" property="transactionId"/>]>.serverId" value="<bean:write name="transaction" scope="page" property="serverId"/>"/>
    <input type="hidden" id="transactionType" name="currentTransactionVO.<TransactionVO[hashCode=<bean:write name="transaction" scope="page" property="transactionId"/>]>.transactionType" value="<bean:write name="transaction" scope="page" property="transactionType"/>"/>
    <input type="hidden" readonly name="be.mxs.healthrecord.updateTransaction.actionForwardKey" value="/main.do?Page=curative/index.jsp&ts=<%=getTs()%>"/>
    <input type="hidden" readonly name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CONTEXT_DEPARTMENT" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CONTEXT_DEPARTMENT" translate="false" property="value"/>"/>
    <input type="hidden" readonly name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CONTEXT_CONTEXT" translate="false" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CONTEXT_CONTEXT" translate="false" property="value"/>"/>
  
    <%=writeHistoryFunctions(((TransactionVO)transaction).getTransactionType(),sWebLanguage)%>
    <%=contextHeader(request,sWebLanguage)%>
    
    <%
        String sTranStartHour = "", sTranEndHour = "", sTranSurgeon = "", sSurgeonName = "";

        if(transaction != null){
            TransactionVO tran = (TransactionVO)transaction;
            if(tran!=null){
                sTranStartHour = getItemType(tran.getItems(),"be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPHTALMOLOGY_OPERATION_PROTOCOL_STARTHOUR");
                sTranEndHour   = getItemType(tran.getItems(),"be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPHTALMOLOGY_OPERATION_PROTOCOL_ENDHOUR");
                sTranSurgeon   = getItemType(tran.getItems(),"be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPHTALMOLOGY_OPERATION_PROTOCOL_SURGEON");
            }
        }

        if(sTranSurgeon.length() > 0){
           	Connection ad_conn = MedwanQuery.getInstance().getAdminConnection();
            sSurgeonName = ScreenHelper.getFullUserName(sTranSurgeon,ad_conn);
            ad_conn.close();
        }
    %>
    
    <table class="list" cellspacing="1" cellpadding="0" width="100%">
        <%-- DATE --%>
        <tr>
            <td class="admin" width="<%=sTDAdminWidth%>">
                <a href="javascript:openHistoryPopup();" title="<%=getTran("Web.Occup","History",sWebLanguage)%>">...</a>&nbsp;
                <%=getTran("Web.Occup","medwan.common.date",sWebLanguage)%>
            </td>
            <td class="admin2" colspan="2">
                <input type="text" class="text" size="12" maxLength="10" name="currentTransactionVO.<TransactionVO[hashCode=<bean:write name="transaction" scope="page" property="transactionId"/>]>.updateTime" value="<mxs:propertyAccessorI18N name="transaction" scope="page" property="updateTime" formatType="date" format="dd-mm-yyyy"/>" id="trandate" OnBlur='checkDate(this)'>
                <script>writeTranDate();</script>
            </td>
        </tr>
        
        <%-- start hour --%>
        <tr>
            <td class="admin" width="<%=sTDAdminWidth%>"><%=getTran("openclinic.chuk","start",sWebLanguage)%></td>
            <td class="admin2" colspan="2">
                <input <%=setRightClick("ITEM_TYPE_OPHTALMOLOGY_OPERATION_PROTOCOL_STARTHOUR")%> class="text" type="text" size="5" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPHTALMOLOGY_OPERATION_PROTOCOL_STARTHOUR" property="itemId"/>]>.value" value="<%=sTranStartHour%>" onblur="checkTime(this);"/>
            </td>
        </tr>
        
        <%-- end hour --%>
        <tr>
            <td class="admin"><%=getTran("openclinic.chuk","end",sWebLanguage)%></td>
            <td class="admin2" colspan="2">
                <input <%=setRightClick("ITEM_TYPE_OPHTALMOLOGY_OPERATION_PROTOCOL_ENDHOUR")%> class="text" type="text" size="5" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPHTALMOLOGY_OPERATION_PROTOCOL_ENDHOUR" property="itemId"/>]>.value" value="<%=sTranEndHour%>" onblur="checkTime(this);"/>
            </td>
        </tr>
        
        <%-- surgeon --%>
        <tr>
            <td class="admin"><%=getTran("openclinic.chuk","surgeon",sWebLanguage)%></td>
            <td class="admin2" colspan="2">
                <input type="hidden" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPHTALMOLOGY_OPERATION_PROTOCOL_SURGEON" property="itemId"/>]>.value" value="<%=sTranSurgeon%>">
                <input class="text" type="text" name="surgeonName" readonly size="<%=sTextWidth%>" value="<%=sSurgeonName%>">
                <img src="<c:url value="/_img/icon_search.gif"/>" class="link" alt="<%=getTran("Web","select",sWebLanguage)%>" onclick="searchSurgeon('currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPHTALMOLOGY_OPERATION_PROTOCOL_SURGEON" property="itemId"/>]>.value','surgeonName');">
                <img src="<c:url value="/_img/icon_delete.gif"/>" class="link" alt="<%=getTran("Web","clear",sWebLanguage)%>" onclick="document.getElementsByName('currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPHTALMOLOGY_OPERATION_PROTOCOL_SURGEON" property="itemId"/>]>.value')[0].value='';transactionForm.surgeonName.value='';">
            </td>
        </tr>
        
        <%-- remarks --%>
        <tr>
            <td class="admin"><%=getTran("openclinic.chuk","remarks",sWebLanguage)%></td>
            <td class="admin2" colspan="2">
                <textarea onKeyup="resizeTextarea(this,10);limitChars(this,255);" <%=setRightClick("ITEM_TYPE_OPHTALMOLOGY_OPERATION_PROTOCOL_REMARKS")%> class="text" cols="80" rows="2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPHTALMOLOGY_OPERATION_PROTOCOL_REMARKS" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPHTALMOLOGY_OPERATION_PROTOCOL_REMARKS" property="value"/></textarea>
            </td>
        </tr>
        
        <tr><td>&nbsp;</td></tr>
        
        <%-- ################################### EYES ######################################## --%>
        <tr class="admin">
            <td>&nbsp;</td>
            <td align="center"><%=getTran("openclinic.chuk","left.eye",sWebLanguage)%></td>
            <td align="center"><%=getTran("openclinic.chuk","right.eye",sWebLanguage)%></td>
        </tr>
        
        <%-- diagnosis --%>
        <tr>
            <td class="admin"><%=getTran("openclinic.chuk","diagnosis",sWebLanguage)%></td>
            <td class="admin2">
                <textarea onKeyup="resizeTextarea(this,10);limitChars(this,255);" <%=setRightClick("ITEM_TYPE_OPHTALMOLOGY_OPERATION_PROTOCOL_DIAGNOSIS_LEFT")%> class="text" cols="80" rows="2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPHTALMOLOGY_OPERATION_PROTOCOL_DIAGNOSIS_LEFT" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPHTALMOLOGY_OPERATION_PROTOCOL_DIAGNOSIS_LEFT" property="value"/></textarea>
            </td>
            <td class="admin2">
                <textarea onKeyup="resizeTextarea(this,10);limitChars(this,255);" <%=setRightClick("ITEM_TYPE_OPHTALMOLOGY_OPERATION_PROTOCOL_DIAGNOSIS_RIGHT")%> class="text" cols="80" rows="2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPHTALMOLOGY_OPERATION_PROTOCOL_DIAGNOSIS_RIGHT" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPHTALMOLOGY_OPERATION_PROTOCOL_DIAGNOSIS_RIGHT" property="value"/></textarea>
            </td>
        </tr>
        
        <%-- intervention --%>
        <tr>
            <td class="admin"><%=getTran("openclinic.chuk","intervention",sWebLanguage)%></td>
            <td class="admin2">
                <textarea onKeyup="resizeTextarea(this,10);limitChars(this,255);" <%=setRightClick("ITEM_TYPE_OPHTALMOLOGY_OPERATION_PROTOCOL_INTERVENTION_LEFT")%> class="text" cols="80" rows="2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPHTALMOLOGY_OPERATION_PROTOCOL_INTERVENTION_LEFT" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPHTALMOLOGY_OPERATION_PROTOCOL_INTERVENTION_LEFT" property="value"/></textarea>
            </td>
            <td class="admin2">
                <textarea onKeyup="resizeTextarea(this,10);limitChars(this,255);" <%=setRightClick("ITEM_TYPE_OPHTALMOLOGY_OPERATION_PROTOCOL_INTERVENTION_RIGHT")%> class="text" cols="80" rows="2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPHTALMOLOGY_OPERATION_PROTOCOL_INTERVENTION_RIGHT" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPHTALMOLOGY_OPERATION_PROTOCOL_INTERVENTION_RIGHT" property="value"/></textarea>
            </td>
        </tr>
        
        <%-- complications --%>
        <tr>
            <td class="admin"><%=getTran("openclinic.chuk","complications",sWebLanguage)%></td>
            <td class="admin2">
                <textarea onKeyup="resizeTextarea(this,10);limitChars(this,255);" <%=setRightClick("ITEM_TYPE_OPHTALMOLOGY_OPERATION_PROTOCOL_COMPLICATIONS_LEFT")%> class="text" cols="80" rows="2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPHTALMOLOGY_OPERATION_PROTOCOL_COMPLICATIONS_LEFT" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPHTALMOLOGY_OPERATION_PROTOCOL_COMPLICATIONS_LEFT" property="value"/></textarea>
            </td>
            <td class="admin2">
                <textarea onKeyup="resizeTextarea(this,10);limitChars(this,255);" <%=setRightClick("ITEM_TYPE_OPHTALMOLOGY_OPERATION_PROTOCOL_COMPLICATIONS_RIGHT")%> class="text" cols="80" rows="2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPHTALMOLOGY_OPERATION_PROTOCOL_COMPLICATIONS_RIGHT" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPHTALMOLOGY_OPERATION_PROTOCOL_COMPLICATIONS_RIGHT" property="value"/></textarea>
            </td>
        </tr>
        
        <%-- care post op --%>
        <tr>
            <td class="admin"><%=getTran("openclinic.chuk","care.post.op",sWebLanguage)%></td>
            <td class="admin2">
                <textarea onKeyup="resizeTextarea(this,10);limitChars(this,255);" <%=setRightClick("ITEM_TYPE_OPHTALMOLOGY_OPERATION_PROTOCOL_CARE_LEFT")%> class="text" cols="80" rows="2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPHTALMOLOGY_OPERATION_PROTOCOL_CARE_LEFT" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPHTALMOLOGY_OPERATION_PROTOCOL_CARE_LEFT" property="value"/></textarea>
            </td>
            <td class="admin2">
                <textarea onKeyup="resizeTextarea(this,10);limitChars(this,255);" <%=setRightClick("ITEM_TYPE_OPHTALMOLOGY_OPERATION_PROTOCOL_CARE_RIGHT")%> class="text" cols="80" rows="2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPHTALMOLOGY_OPERATION_PROTOCOL_CARE_RIGHT" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPHTALMOLOGY_OPERATION_PROTOCOL_CARE_RIGHT" property="value"/></textarea>
            </td>
        </tr>
        
        <%-- conclusion --%>
        <tr>
            <td class="admin"><%=getTran("openclinic.chuk","conclusion",sWebLanguage)%></td>
            <td class="admin2">
                <textarea onKeyup="resizeTextarea(this,10);limitChars(this,255);" <%=setRightClick("ITEM_TYPE_OPHTALMOLOGY_OPERATION_PROTOCOL_CONCLUSION_LEFT")%> class="text" cols="80" rows="2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPHTALMOLOGY_OPERATION_PROTOCOL_CONCLUSION_LEFT" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPHTALMOLOGY_OPERATION_PROTOCOL_CONCLUSION_LEFT" property="value"/></textarea>
            </td>
            <td class="admin2">
                <textarea onKeyup="resizeTextarea(this,10);limitChars(this,255);" <%=setRightClick("ITEM_TYPE_OPHTALMOLOGY_OPERATION_PROTOCOL_CONCLUSION_RIGHT")%> class="text" cols="80" rows="2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPHTALMOLOGY_OPERATION_PROTOCOL_CONCLUSION_RIGHT" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPHTALMOLOGY_OPERATION_PROTOCOL_CONCLUSION_RIGHT" property="value"/></textarea>
            </td>
        </tr>
    </table>
        
	<%-- BUTTONS --%>
	<%=ScreenHelper.alignButtonsStart()%>
	    <%=getButtonsHtml(request,activeUser,activePatient,"occup.ophtalmology.operation.protocol",sWebLanguage)%>
	<%=ScreenHelper.alignButtonsStop()%>
	
    <%=ScreenHelper.contextFooter(request)%>
</form>

<script>
  <%-- SUBMIT FORM --%>
  function submitForm(){
    transactionForm.saveButton.disabled = true;
    document.transactionForm.submit();
  }

  <%-- search surgeon --%>
  function searchSurgeon(surgeonUidField,surgeonNameField){
    openPopup("/_common/search/searchUser.jsp&ts=<%=getTs()%>&ReturnUserID="+surgeonUidField+"&ReturnName="+surgeonNameField);
    transactionForm.surgeonName.focus();
  }
</script>