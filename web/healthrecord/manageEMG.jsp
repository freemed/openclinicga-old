<%@include file="/includes/validateUser.jsp"%>
<%@page errorPage="/includes/error.jsp"%>
<%=checkPermission("occup.emg","select",activeUser)%>

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
  
    <table class="list" width="100%" cellspacing="1">
		<tr>
			<td style="vertical-align:top;padding:0" class="admin2">
			    <table class="list" cellspacing="1" cellpadding="0" width="100%">
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
			        </tr>
				    
				    <%-- CLINICAL DATA --%>
			        <tr>
			            <td class="admin"><%=getTran("web","emg.clinicaldata",sWebLanguage)%></td>
			            <td class="admin2">
			                <textarea onKeyup="resizeTextarea(this,10);limitChars(this,255);" <%=setRightClick("ITEM_TYPE_EMG_CLINICALDATA")%> class="text" cols="80" rows="2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_EMG_CLINICALDATA" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_EMG_CLINICALDATA" property="value"/></textarea>
			            </td>
			        </tr>
			        
			        <%-- MODALITE D'ETUDE --%>
			        <tr>
			            <td class='admin' colspan="1">
			                <%=getTran("web","emg.studymodality",sWebLanguage)%>&nbsp;
			            </td>
			            <td class='admin2'>
			                <select <%=setRightClick("ITEM_TYPE_EMG_STUDY_MODALITY")%> class="text" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_EMG_STUDY_MODALITY" property="itemId"/>]>.value" class="text">
			                    <option value="medwan.common.not-executed" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_EMG_STUDY_MODALITY;value=medwan.common.not-executed" property="value" outputString="selected"/>><%=getTran("web.occup","medwan.common.not-executed",sWebLanguage)%></option>
			                    <option value="emg" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_EMG_STUDY_MODALITY;value=emg" property="value" outputString="selected"/>><%=getTran("web","emg",sWebLanguage)%></option>
			                    <option value="neurophysiology" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_EMG_STUDY_MODALITY;value=neurophysiology" property="value" outputString="selected"/>><%=getTran("web","neurophysiology",sWebLanguage)%></option>
			                </select>
			              
			            </td>
			        </tr>
			        
			        <%-- RESULTATS --%>        
			        <tr>
			            <td class='admin' colspan="1"><%=getTran("web","results",sWebLanguage)%></td>
			            <td class='admin2'>
			                <input type="radio" id="resultRadio1" <%=setRightClick("ITEM_TYPE_EMG_RESULTS")%> onDblClick="uncheckRadio(this);" value="medwan.results.normal" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_EMG_RESULTS" property="itemId"/>]>.value" value="medwan.results.normal" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_EMG_RESULTS;value=medwan.results.normal" property="value" outputString="checked"/>><%=getLabel("web","medwan.results.normal",sWebLanguage,"resultRadio1")%>
			                <input type="radio" id="resultRadio2" <%=setRightClick("ITEM_TYPE_EMG_RESULTS")%> onDblClick="uncheckRadio(this);" value="medwan.results.abnormal" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_EMG_RESULTS" property="itemId"/>]>.value" value="medwan.results.abnormal" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_EMG_RESULTS;value=medwan.results.abnormal" property="value" outputString="checked"/>><%=getLabel("web","medwan.results.abnormal",sWebLanguage,"resultRadio2")%>
			            </td>
			        </tr>
			                   
			        <%-- DESCRIPTION --%>
			        <tr class="admin">
			            <td colspan="3"><%=getTran("web","description",sWebLanguage)%></td>
			        </tr>
			        
			        <%--RAPPORT TECHNIQUE  --%>
			        <tr>
			            <td class="admin"><%=getTran("web","technical.report",sWebLanguage)%></td>
			            <td class="admin2">
			                <textarea onKeyup="resizeTextarea(this,10);limitChars(this,255);" <%=setRightClick("ITEM_TYPE_EMG_TECHNICAL_REPORT")%> class="text" cols="80" rows="2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_EMG_TECHNICAL_REPORT" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_EMG_TECHNICAL_REPORT" property="value"/></textarea>
			            </td>
			        </tr>
			        
			        <%--RESULTATS --%>
			        <tr>
			            <td class="admin"><%=getTran("web","results",sWebLanguage)%></td>
			            <td class="admin2">
			                <textarea onKeyup="resizeTextarea(this,10);limitChars(this,255);" <%=setRightClick("ITEM_TYPE_EMG_RESULTS_DESCRIPTION")%> class="text" cols="80" rows="2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_EMG_RESULTS_DESCRIPTION" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_EMG_RESULTS_DESCRIPTION" property="value"/></textarea>
			            </td>
			        </tr>
			        
			        <%-- MUSCLES ETUDIES --%>
			        <tr>
			            <td class="admin"><%=getTran("web","studied.muscles",sWebLanguage)%></td>
			            <td class="admin2">
			                <textarea onKeyup="resizeTextarea(this,10);limitChars(this,10000);" <%=setRightClick("ITEM_TYPE_EMG_STUDIED_MUSCLES")%> class="text" cols="80" rows="2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_EMG_STUDIED_MUSCLES" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_EMG_STUDIED_MUSCLES" property="value"/></textarea>
			            </td>
			        </tr>
			        
			        <%-- CONCLUSION --%>
			        <tr>
			            <td class="admin"><%=getTran("web","conclusion",sWebLanguage)%></td>
			            <td class="admin2">
			                <textarea onKeyup="resizeTextarea(this,10);limitChars(this,500);" <%=setRightClick("ITEM_TYPE_EMG_CONCLUSION")%> class="text" cols="80" rows="2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_EMG_CONCLUSION" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_EMG_CONCLUSION" property="value"/></textarea>
			            </td>
			        </tr>
			    </table>
			</td>
        
	        <%-- DIAGNOSIS --%>
	    	<td class="admin" colspan="2">
		      	<%ScreenHelper.setIncludePage(customerInclude("healthrecord/diagnosesEncoding.jsp"),pageContext);%>
	    	</td>
	    </tr>
    </table>
    
    <%-- BUTTONS --%>
    <%=ScreenHelper.alignButtonsStart()%>                    
	    <%=getButtonsHtml(request,activeUser,activePatient,"occup.emg",sWebLanguage)%>
    <%=ScreenHelper.alignButtonsStop()%>
			                
    <%=ScreenHelper.contextFooter(request)%>
</form>

<script>
  function submitForm(){
    document.getElementById("buttonsDiv").style.visibility = "hidden";
    var temp = Form.findFirstElement(transactionForm); //for ff compatibility
    document.transactionForm.submit();
  }
</script>

<%=writeJSButtons("transactionForm","saveButton")%>