<%@include file="/includes/validateUser.jsp"%>
<%@page errorPage="/includes/error.jsp"%>

<%=checkPermission("occup.protocol.thyroidechography","select",activeUser)%>

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
        
        String sThyroidLeftGrandAxe  = getItemType(tran.getItems(),sPREFIX+"ITEM_TYPE_THYROID_ECHOGRAPHY_PROTOCOL_GRAND_AXE_LEFT"),
               sThyroidRightGrandAxe = getItemType(tran.getItems(),sPREFIX+"ITEM_TYPE_THYROID_ECHOGRAPHY_PROTOCOL_GRAND_AXE_RIGHT");
   	%>
   	
    <table class="list" width="100%" cellspacing="1">
		<tr>
			<td style="vertical-align:top;padding:0" class="admin2">
			    <table class="list" width="100%" cellspacing="1">
			        <%-- DATE --%>
			        <tr>
			            <td class="admin" colspan="2" width="<%=sTDAdminWidth%>">
			                <a href="javascript:openHistoryPopup();" title="<%=getTranNoLink("Web.Occup","History",sWebLanguage)%>">...</a>&nbsp;
			                <%=getTran("Web.Occup","medwan.common.date",sWebLanguage)%>
			            </td>
			            <td class="admin2">
			                <input type="text" class="text" size="12" maxLength="10" name="currentTransactionVO.<TransactionVO[hashCode=<bean:write name="transaction" scope="page" property="transactionId"/>]>.updateTime" value="<mxs:propertyAccessorI18N name="transaction" scope="page" property="updateTime" formatType="date"/>" id="trandate" OnBlur='checkDate(this)'>
			                <script>writeTranDate();</script>
			            </td>
			        </tr>
			
			        <%-- motive --%>
			        <tr>
			            <td class="admin" colspan="2"><%=getTran("openclinic.chuk","motive",sWebLanguage)%></td>
			            <td class="admin2">
			                <textarea onkeyup="resizeTextarea(this,10);limitChars(this,255);" <%=setRightClick("ITEM_TYPE_THYROID_ECHOGRAPHY_PROTOCOL_MOTIVE")%> class="text" cols="70" rows="2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_THYROID_ECHOGRAPHY_PROTOCOL_MOTIVE" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_THYROID_ECHOGRAPHY_PROTOCOL_MOTIVE" property="value"/></textarea>
			            </td>
			        </tr>
			
			        <%-- RIGHT LOBE -------------------------------------------------------------------------%>
			        <%-- echostructure --%>
			        <tr>
			            <td class="admin" rowspan="3"><%=getTran("openclinic.chuk","right_lobe",sWebLanguage)%></td>
			            <td class="admin2"><%=getTran("openclinic.chuk","echostructure",sWebLanguage)%></td>
			            <td class="admin2">
			                <textarea onkeyup="resizeTextarea(this,10);limitChars(this,255);" <%=setRightClick("ITEM_TYPE_THYROID_ECHOGRAPHY_PROTOCOL_ECHOSTRUCTURE_RIGHT")%> class="text" cols="70" rows="2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_THYROID_ECHOGRAPHY_PROTOCOL_ECHOSTRUCTURE_RIGHT" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_THYROID_ECHOGRAPHY_PROTOCOL_ECHOSTRUCTURE_RIGHT" property="value"/></textarea>
			            </td>
			        </tr>
			
			        <%-- grande_axe --%>
			        <tr>
			            <td class="admin2"><%=getTran("openclinic.chuk","grande_axe",sWebLanguage)%></td>
			            <td class="admin2">
			                <input <%=setRightClick("ITEM_TYPE_THYROID_ECHOGRAPHY_PROTOCOL_GRAND_AXE_RIGHT")%> type="text" class="text" size="4" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_THYROID_ECHOGRAPHY_PROTOCOL_GRAND_AXE_RIGHT" property="itemId"/>]>.value" value="<%=sThyroidRightGrandAxe%>" onblur="isNumber(this);">  cm
			            </td>
			        </tr>
			
			        <%-- nodules --%>
			        <tr>
			            <td class="admin2"><%=getTran("openclinic.chuk","nodules",sWebLanguage)%></td>
			            <td class="admin2">
			                <textarea onkeyup="resizeTextarea(this,10);limitChars(this,255);" <%=setRightClick("ITEM_TYPE_THYROID_ECHOGRAPHY_PROTOCOL_NODULES_RIGHT")%> class="text" cols="70" rows="2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_THYROID_ECHOGRAPHY_PROTOCOL_NODULES_RIGHT" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_THYROID_ECHOGRAPHY_PROTOCOL_NODULES_RIGHT" property="value"/></textarea>
			            </td>
			        </tr>
			
			        <%-- LEFT LOBE --------------------------------------------------------------------------%>
			        <%-- echostructure --%>
			        <tr>
			            <td class="admin" rowspan="3"><%=getTran("openclinic.chuk","left_lobe",sWebLanguage)%></td>
			            <td class="admin2"><%=getTran("openclinic.chuk","echostructure",sWebLanguage)%></td>
			            <td class="admin2">
			                <textarea onkeyup="resizeTextarea(this,10);limitChars(this,255);" <%=setRightClick("ITEM_TYPE_THYROID_ECHOGRAPHY_PROTOCOL_ECHOSTRUCTURE_LEFT")%> class="text" cols="70" rows="2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_THYROID_ECHOGRAPHY_PROTOCOL_ECHOSTRUCTURE_LEFT" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_THYROID_ECHOGRAPHY_PROTOCOL_ECHOSTRUCTURE_LEFT" property="value"/></textarea>
			            </td>
			        </tr>
			
			        <%-- grande_axe --%>
			        <tr>
			            <td class="admin2"><%=getTran("openclinic.chuk","grande_axe",sWebLanguage)%></td>
			            <td class="admin2">
			                <input <%=setRightClick("ITEM_TYPE_THYROID_ECHOGRAPHY_PROTOCOL_GRAND_AXE_LEFT")%> type="text" class="text" size="4" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_THYROID_ECHOGRAPHY_PROTOCOL_GRAND_AXE_LEFT" property="itemId"/>]>.value" value="<%=sThyroidLeftGrandAxe%>" onblur="isNumber(this);"> cm
			            </td>
			        </tr>
			
			        <%-- nodules --%>
			        <tr>
			            <td class="admin2"><%=getTran("openclinic.chuk","nodules",sWebLanguage)%></td>
			            <td class="admin2">
			                <textarea onkeyup="resizeTextarea(this,10);limitChars(this,255);" <%=setRightClick("ITEM_TYPE_THYROID_ECHOGRAPHY_PROTOCOL_NODULES_LEFT")%> class="text" cols="70" rows="2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_THYROID_ECHOGRAPHY_PROTOCOL_NODULES_LEFT" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_THYROID_ECHOGRAPHY_PROTOCOL_NODULES_LEFT" property="value"/></textarea>
			            </td>
			        </tr>
			
			        <%-- isthmus --%>
			        <tr>
			            <td class="admin" colspan="2"><%=getTran("openclinic.chuk","isthmus",sWebLanguage)%></td>
			            <td class="admin2">
			                <textarea onkeyup="resizeTextarea(this,10);limitChars(this,255);" <%=setRightClick("ITEM_TYPE_THYROID_ECHOGRAPHY_PROTOCOL_ISTHMUS")%> class="text" cols="70" rows="2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_THYROID_ECHOGRAPHY_PROTOCOL_ISTHMUS" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_THYROID_ECHOGRAPHY_PROTOCOL_ISTHMUS" property="value"/></textarea>
			            </td>
			        </tr>
			
			        <%-- conclusion --%>
			        <tr>
			            <td class="admin" colspan="2"><%=getTran("openclinic.chuk","conclusion",sWebLanguage)%></td>
			            <td class="admin2">
			                <textarea onkeyup="resizeTextarea(this,10);limitChars(this,255);" <%=setRightClick("ITEM_TYPE_THYROID_ECHOGRAPHY_PROTOCOL_CONCLUSION")%> class="text" cols="70" rows="2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_THYROID_ECHOGRAPHY_PROTOCOL_CONCLUSION" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_THYROID_ECHOGRAPHY_PROTOCOL_CONCLUSION" property="value"/></textarea>
			            </td>
			        </tr>
			
			        <%-- remarks --%>
			        <tr>
			            <td class="admin" colspan="2"><%=getTran("openclinic.chuk","remarks",sWebLanguage)%></td>
			            <td class="admin2">
			                <textarea onkeyup="resizeTextarea(this,10);limitChars(this,255);" <%=setRightClick("ITEM_TYPE_THYROID_ECHOGRAPHY_PROTOCOL_REMARKS")%> class="text" cols="70" rows="2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_THYROID_ECHOGRAPHY_PROTOCOL_REMARKS" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_THYROID_ECHOGRAPHY_PROTOCOL_REMARKS" property="value"/></textarea>
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

	<%-- BUTTONS --%>
	<%=ScreenHelper.alignButtonsStart()%>
	    <%=getButtonsHtml(request,activeUser,activePatient,"occup.protocol.thyroidechography",sWebLanguage)%>
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
	  document.getElementById("buttonsDiv").style.visibility = "hidden";
	  Form.findFirstElement(transactionForm); //for ff compatibility
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