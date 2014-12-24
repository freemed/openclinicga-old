<%@include file="/includes/validateUser.jsp"%>
<%@page errorPage="/includes/error.jsp"%>
<%=checkPermission("occup.kinesitherapy.application","select",activeUser)%>

<form id="transactionForm" name="transactionForm" method="POST" action='<c:url value="/healthrecord/updateTransaction.do"/>?ts=<%=getTs()%>'>
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
		<tr>
			<td style="vertical-align:top;padding:0" class="admin2" width="50%">
			    <table class="list" cellspacing="1" cellpadding="0" width="100%">
			        <%-- DATE --%>
			        <tr>
			            <td class="admin" width="<%=sTDAdminWidth%>">
			                <a href="javascript:openHistoryPopup();" title="<%=getTranNoLink("Web.Occup","History",sWebLanguage)%>">...</a>&nbsp;
			                <%=getTran("Web.Occup","medwan.common.date",sWebLanguage)%>
			            </td>
			            <td class="admin2">
			                <input type="text" class="text" size="12" maxLength="10" name="currentTransactionVO.<TransactionVO[hashCode=<bean:write name="transaction" scope="page" property="transactionId"/>]>.updateTime" value="<mxs:propertyAccessorI18N name="transaction" scope="page" property="updateTime" formatType="date"/>" id="trandate" OnBlur='checkDate(this)'>
			                <script>writeTranDate();</script>
			            </td>
			        </tr>
			
			        <%-- INTERVENTION --%>
			        <tr>
			            <td class="admin">
			                <%=getTran("openclinic.chuk","intervention",sWebLanguage)%>
			            </td>
			            <td class="admin2">
			                <textarea onKeyup="resizeTextarea(this,10);limitChars(this,255);" <%=setRightClick("ITEM_TYPE_KINESITHERAPY_APPLICATION_INTERVENTION")%> class="text" cols="100" rows="2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_KINESITHERAPY_APPLICATION_INTERVENTION" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_KINESITHERAPY_APPLICATION_INTERVENTION" property="value"/></textarea>
			            </td>
			        </tr>
			
			        <%-- ACTS ASKED --%>
			        <tr>
			            <td class="admin">
			                <%=getTran("openclinic.chuk","acts.asked",sWebLanguage)%>
			            </td>
			            <td class="admin2">
			                <textarea onKeyup="resizeTextarea(this,10);limitChars(this,255);" <%=setRightClick("ITEM_TYPE_KINESITHERAPY_APPLICATION_ACTS_ASKED")%> class="text" cols="100" rows="2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_KINESITHERAPY_APPLICATION_ACTS_ASKED" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_KINESITHERAPY_APPLICATION_ACTS_ASKED" property="value"/></textarea>
			            </td>
			        </tr>
			
			        <%-- NUMBER OF MEETINGS --%>
			        <tr>
			            <td class="admin">
			                <%=getTran("openclinic.chuk","nr.meetings",sWebLanguage)%>
			            </td>
			            <td class="admin2">
			                <input <%=setRightClick("ITEM_TYPE_KINESITHERAPY_APPLICATION_NR_MEETINGS")%> type="text" class="text" size="4" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_KINESITHERAPY_APPLICATION_NR_MEETINGS" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_KINESITHERAPY_APPLICATION_NR_MEETINGS" property="value"/>" onblur="isNumber(this);"/>
			            </td>
			        </tr>
			
			        <%-- FREQUENCY --%>
			        <tr>
			            <td class="admin">
			                <%=getTran("openclinic.chuk","frequency",sWebLanguage)%>
			            </td>
			            <td class="admin2">
			                <input <%=setRightClick("ITEM_TYPE_KINESITHERAPY_APPLICATION_FREQUENCY_DAY")%> type="text" class="text" size="4" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_KINESITHERAPY_APPLICATION_FREQUENCY_DAY" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_KINESITHERAPY_APPLICATION_FREQUENCY_DAY" property="value"/>" onblur="isNumber(this);"/> /<%=getTran("openclinic.chuk","day",sWebLanguage)%>
			                &nbsp;
			                <input <%=setRightClick("ITEM_TYPE_KINESITHERAPY_APPLICATION_FREQUENCY_WEEK")%> type="text" class="text" size="4" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_KINESITHERAPY_APPLICATION_FREQUENCY_WEEK" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_KINESITHERAPY_APPLICATION_FREQUENCY_WEEK" property="value"/>" onblur="isNumber(this);"/> /<%=getTran("openclinic.chuk","week",sWebLanguage)%>
			            </td>
			        </tr>
			
			        <%-- REMARS --%>
			        <tr>
			            <td class="admin">
			                <%=getTran("openclinic.chuk","remarks",sWebLanguage)%>
			            </td>
			            <td class="admin2">
			                <textarea onKeyup="resizeTextarea(this,10);limitChars(this,255);" <%=setRightClick("ITEM_TYPE_KINESITHERAPY_APPLICATION_REMARKS")%> class="text" cols="100" rows="2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_KINESITHERAPY_APPLICATION_REMARKS" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_KINESITHERAPY_APPLICATION_REMARKS" property="value"/></textarea>
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
	    <%=getButtonsHtml(request,activeUser,activePatient,"occup.kinesitherapy.application",sWebLanguage)%>
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
    else {
	  var temp = Form.findFirstElement(transactionForm);//for ff compatibility
	  document.transactionForm.submit();
	  document.getElementById("buttonsDiv").style.visibility = "hidden";
    }
  }
  
  <%-- SEARCH ENCOUNTER --%>
  function searchEncounter(){
    openPopup("/_common/search/searchEncounter.jsp&ts=<%=getTs()%>&VarCode=currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CONTEXT_ENCOUNTERUID" property="itemId"/>]>.value&VarText=&FindEncounterPatient=<%=activePatient.personid%>");
  }
  
  if(document.getElementById('encounteruid').value==''){
	alertDialog("web","no.encounter.linked");
	searchEncounter();
  }	
</script>

<%=writeJSButtons("transactionForm","saveButton")%>