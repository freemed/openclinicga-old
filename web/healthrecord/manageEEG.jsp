<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>
<%=checkPermission("occup.eeg","select",activeUser)%>

<form name="transactionForm" id="transactionForm" method="POST" action="<c:url value='/healthrecord/updateTransaction.do'/>?ts=<%=getTs()%>" focus='type' onclick="setSaveButton(event);" onkeyup="setSaveButton(event);">
    <bean:define id="transaction" name="be.mxs.webapp.wl.session.SessionContainerFactory.WO_SESSION_CONTAINER" property="currentTransactionVO"/>
	<%=checkPrestationToday(activePatient.personid,false,activeUser,(TransactionVO)transaction)%>

    <input type="hidden" id="transactionId" name="currentTransactionVO.<TransactionVO[hashCode=<bean:write name="transaction" scope="page" property="transactionId"/>]>.transactionId" value="<bean:write name="transaction" scope="page" property="transactionId"/>"/>
    <input type="hidden" id="transactionType" name="currentTransactionVO.<TransactionVO[hashCode=<bean:write name="transaction" scope="page" property="transactionId"/>]>.transactionType" value="<bean:write name="transaction" scope="page" property="transactionType"/>"/>
    <input type="hidden" id="serverId" name="currentTransactionVO.<TransactionVO[hashCode=<bean:write name="transaction" scope="page" property="transactionId"/>]>.serverId" value="<bean:write name="transaction" scope="page" property="serverId"/>"/>
    <input type="hidden" readonly name="be.mxs.healthrecord.updateTransaction.actionForwardKey" value="/main.do?Page=curative/index.jsp?ts=<%=getTs()%>"/>
    <input type="hidden" readonly name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CONTEXT_DEPARTMENT" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CONTEXT_DEPARTMENT" translate="false" property="value"/>"/>
    <input type="hidden" readonly name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CONTEXT_CONTEXT" translate="false" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CONTEXT_CONTEXT" translate="false" property="value"/>"/>

    <%=writeHistoryFunctions(((TransactionVO)transaction).getTransactionType(),sWebLanguage)%>
    <%=contextHeader(request,sWebLanguage)%>
    
    <table class="list" width='100%' border='0' cellspacing="1">
        <tr>
            <td style="vertical-align:top;">
                <table width="100%" cellpadding="1" cellspacing="1">
				    <%-- DATE --%>
				    <tr>
				        <td class="admin">
				            <a href="javascript:openHistoryPopup();" title="<%=getTran("Web.Occup","History",sWebLanguage)%>">...</a>&nbsp;
				            <%=getTran("Web.Occup","medwan.common.date",sWebLanguage)%>
				        </td>
				        <td class="admin2">
				            <input type="text" class="text" size="12" maxLength="10" value="<mxs:propertyAccessorI18N name="transaction" scope="page" property="updateTime" formatType="date" format="dd-mm-yyyy"/>" name="currentTransactionVO.<TransactionVO[hashCode=<bean:write name="transaction" scope="page" property="transactionId"/>]>.updateTime" id="trandate" OnBlur='checkDate(this)'> <script>writeTranDate();</script>
				        </td>
				    </tr>
				    
				    <%--  DONNEES CLINIQUES --%>
				    <tr>
				        <td width ="<%=sTDAdminWidth%>" class='admin'><%=getTran("web","eeg.clinicaldata",sWebLanguage)%>&nbsp;</td>
				        <td class='admin2'>
				            <textarea onKeyup="resizeTextarea(this,10);" <%=setRightClick("ITEM_TYPE_EEG_CLINICALDATA")%> class="text" cols="74" rows="2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_EEG_CLINICALDATA" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_EEG_CLINICALDATA" property="value"/></textarea>
				        </td>
				    </tr>
				
				    <%--  MODALITE D ETUDE --%>
				    <tr>
				        <td class='admin'><%=getTran("web","eeg.studymodality",sWebLanguage)%>&nbsp;</td>
				        <td class='admin2'>
				            <textarea onKeyup="resizeTextarea(this,10);" <%=setRightClick("ITEM_TYPE_EEG_STUDYMODALITY")%> class="text" cols="74" rows="2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_EEG_STUDYMODALITY" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_EEG_STUDYMODALITY" property="value"/></textarea>
				        </td>
				    </tr>

				    <%-- RESULTATS --%>
				    <tr>
				        <td class="admin" width="<%=sTDAdminWidth%>" nowrap><%=getTran("web","results",sWebLanguage)%>&nbsp;</td>
				        <td class="admin2" width="100%">
					        <input <%=setRightClick("ITEM_TYPE_EEG_RESULTS")%> type="radio" onDblClick="uncheckRadio(this);" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_EEG_RESULTS" property="itemId"/>]>.value" value="medwan.results.normal" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_EEG_RESULTS;value=medwan.results.normal" property="value" outputString="checked"/>><%=getTran("web","medwan.results.normal",sWebLanguage)%>
					        <input <%=setRightClick("ITEM_TYPE_EEG_RESULTS")%> type="radio" onDblClick="uncheckRadio(this);" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_EEG_RESULTS" property="itemId"/>]>.value" value="medwan.results.abnormal" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_EEG_RESULTS;value=medwan.results.abnormal" property="value" outputString="checked"/>><%=getTran("web","medwan.results.abnormal",sWebLanguage)%>
				        </td>
				    </tr>
				</table>
				
				<div style="padding-top:5px;"></div>
				    
				<%-- DESCRIPTION ------------------------------------------------------------%>
                <table width="100%" cellpadding="1" cellspacing="1">
				    <tr class="admin">
				        <td colspan="3"><%=getTran("Web.Occup","medwan.healthrecord.description",sWebLanguage)%></td>
				    </tr>
    
				    <%-- RAPPORT TECHNIQUE --%>
				    <tr>
				        <td class='admin'><%=getTran("web","technical.report",sWebLanguage)%>&nbsp;</td>
				        <td class='admin2'>
				            <textarea <%=setRightClick("ITEM_TYPE_EEG_TECHNICAL_REPORT")%> onKeyup="resizeTextarea(this,10);" class="text" cols="74" rows="2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_EEG_TECHNICAL_REPORT" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_EEG_TECHNICAL_REPORT" property="value"/></textarea>
				        </td>
				    </tr>
				
				    <%-- RESULTATS --%>
				    <tr>
				        <td class='admin'><%=getTran("web","results",sWebLanguage)%>&nbsp;</td>
				        <td class='admin2'>
				            <textarea <%=setRightClick("ITEM_TYPE_EEG_RESULTS_DESCRIPTION")%> onKeyup="resizeTextarea(this,10);" class="text" cols="74" rows="2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_EEG_RESULTS_DESCRIPTION" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_EEG_RESULTS_DESCRIPTION" property="value"/></textarea>
				        </td>
				    </tr>

				    <%-- CONCLUSION --%>
				    <tr>
				        <td class='admin'><%=getTran("web","conclusion",sWebLanguage)%>&nbsp;</td>
				        <td class='admin2'>
				            <textarea <%=setRightClick("ITEM_TYPE_EEG_CONCLUSION")%> onKeyup="resizeTextarea(this,10);" class="text" cols="74" rows="2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_EEG_CONCLUSION" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_EEG_CONCLUSION" property="value"/></textarea>
				        </td>
				    </tr>
				</table>
		    </td>
   
	        <%-- DIAGNOSIS --%>
	    	<td class="admin">
		      	<%ScreenHelper.setIncludePage(customerInclude("healthrecord/diagnosesEncoding.jsp"),pageContext);%>
	    	</td>
	    </tr>
    </table>
        
	<%-- BUTTONS --%>
	<%=ScreenHelper.alignButtonsStart()%>
	    <%=getButtonsHtml(request,activeUser,activePatient,"occup.eeg",sWebLanguage)%>
	<%=ScreenHelper.alignButtonsStop()%>

    <%=ScreenHelper.contextFooter(request)%>
</form>

<script>
  <%-- SUBMIT FORM --%>
  function submitForm(){
    document.getElementById("buttonsDiv").style.visibility = "hidden";
    var temp = Form.findFirstElement(transactionForm);//for ff compatibility
    document.transactionForm.submit();
  }
</script>

<%=writeJSButtons("transactionForm","saveButton")%>