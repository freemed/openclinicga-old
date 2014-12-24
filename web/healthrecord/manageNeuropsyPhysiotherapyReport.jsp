<%@include file="/includes/validateUser.jsp"%>
<%@page errorPage="/includes/error.jsp"%>

<%=checkPermission("occup.neuropsyphysiotherapyreport","select",activeUser)%>

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
				<table class="list" width="100%" cellspacing="1">
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
			        
			        <%-- spacer --%>
			        <tr><td colspan="2" class="admin2" style="height:5px;"></td></tr>
			    
    		   		<%-- SUBJECTIVE EXAMINATION -----------------------------------------------------%> 				    
			        <tr class="admin">
			            <td colspan="2"><%=getTran("web","subjective.examination",sWebLanguage)%></td>
			        </tr>
			        <tr>
			            <td class="admin" width="<%=sTDAdminWidth%>"><%=getTran("web","reason.for.encounter",sWebLanguage)%></td>
			            <td class="admin2">
			                <textarea onKeyup="resizeTextarea(this,10);limitChars(this,255);" <%=setRightClick("ITEM_TYPE_NPPR_REASONFORENCOUNTER")%> class="text" cols="80" rows="2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_NPPR_REASONFORENCOUNTER" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_NPPR_REASONFORENCOUNTER" property="value"/></textarea>
			            </td>
			        </tr>
			        <tr>
			            <td class="admin"><%=getTran("web","disease.history",sWebLanguage)%></td>
			            <td class="admin2">
			                <textarea onKeyup="resizeTextarea(this,10);limitChars(this,255);" <%=setRightClick("ITEM_TYPE_NPPR_DISEASEHISTORY")%> class="text" cols="80" rows="2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_NPPR_DISEASEHISTORY" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_NPPR_DISEASEHISTORY" property="value"/></textarea>
			            </td>
			        </tr>
			        <tr>
			            <td class="admin"><%=getTran("web","disease.evolution",sWebLanguage)%></td>
			            <td class="admin2">
			                <textarea onKeyup="resizeTextarea(this,10);limitChars(this,255);" <%=setRightClick("ITEM_TYPE_NPPR_DISEASEEVOLUTION")%> class="text" cols="80" rows="2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_NPPR_DISEASEEVOLUTION" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_NPPR_DISEASEEVOLUTION" property="value"/></textarea>
			            </td>
			        </tr>
			        <tr>
			            <td class="admin"><%=getTran("web","antecedents",sWebLanguage)%></td>
			            <td class="admin2">
			                <textarea onKeyup="resizeTextarea(this,10);limitChars(this,255);" <%=setRightClick("ITEM_TYPE_NPPR_ANTECEDENTS")%> class="text" cols="80" rows="2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_NPPR_ANTECEDENTS" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_NPPR_ANTECEDENTS" property="value"/></textarea>
			            </td>
			        </tr>
			        <tr>
			            <td class="admin"><%=getTran("web","psychological.profile",sWebLanguage)%></td>
			            <td class="admin2">
			                <textarea onKeyup="resizeTextarea(this,10);limitChars(this,255);" <%=setRightClick("ITEM_TYPE_NPPR_PSYPROFILE")%> class="text" cols="80" rows="2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_NPPR_PSYPROFILE" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_NPPR_PSYPROFILE" property="value"/></textarea>
			            </td>
			        </tr>
			    </table>
			    <div style="padding-top:5px;"></div>
			    
		        <%-- OBJECTIVE EXAMINATION ------------------------------------------------------%>
				<table class="list" width="100%" cellspacing="1">    
			        <tr class="admin">
			            <td colspan="2"><%=getTran("web","objective.examination",sWebLanguage)%></td>
			        </tr>
			        <tr>
			            <td class="admin" width="<%=sTDAdminWidth%>"><%=getTran("web","inspection",sWebLanguage)%></td>
			            <td class="admin2">
			                <textarea onKeyup="resizeTextarea(this,10);limitChars(this,255);" <%=setRightClick("ITEM_TYPE_NPPR_INSPECTION")%> class="text" cols="80" rows="2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_NPPR_INSPECTION" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_NPPR_INSPECTION" property="value"/></textarea>
			            </td>
			        </tr>
			        <tr>
			            <td class="admin"><%=getTran("web","palpation",sWebLanguage)%></td>
			            <td class="admin2">
			                <textarea onKeyup="resizeTextarea(this,10);limitChars(this,255);" <%=setRightClick("ITEM_TYPE_NPPR_PALPATION")%> class="text" cols="80" rows="2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_NPPR_PALPATION" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_NPPR_PALPATION" property="value"/></textarea>
			            </td>
			        </tr>
			        <tr>
			            <td class="admin"><%=getTran("web","pain.status",sWebLanguage)%></td>
			            <td class="admin2">
			                <textarea onKeyup="resizeTextarea(this,10);limitChars(this,255);" <%=setRightClick("ITEM_TYPE_NPPR_PAINSTATUS")%> class="text" cols="80" rows="2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_NPPR_PAINSTATUS" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_NPPR_PAINSTATUS" property="value"/></textarea>
			            </td>
			        </tr>
			        <tr>
			            <td class="admin"><%=getTran("web","joints.status",sWebLanguage)%></td>
			            <td class="admin2">
			                <textarea onKeyup="resizeTextarea(this,10);limitChars(this,255);" <%=setRightClick("ITEM_TYPE_NPPR_JOINTSSTATUS")%> class="text" cols="80" rows="2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_NPPR_JOINTSSTATUS" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_NPPR_JOINTSSTATUS" property="value"/></textarea>
			            </td>
			        </tr>
			        <tr>
			            <td class="admin"><%=getTran("web","muscles.status",sWebLanguage)%></td>
			            <td class="admin2">
			                <textarea onKeyup="resizeTextarea(this,10);limitChars(this,255);" <%=setRightClick("ITEM_TYPE_NPPR_MUSCLESSTATUS")%> class="text" cols="80" rows="2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_NPPR_MUSCLESSTATUS" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_NPPR_MUSCLESSTATUS" property="value"/></textarea>
			            </td>
			        </tr>
			        <tr>
			            <td class="admin"><%=getTran("web","neurology.status",sWebLanguage)%></td>
			            <td class="admin2">
			                <textarea onKeyup="resizeTextarea(this,10);limitChars(this,255);" <%=setRightClick("ITEM_TYPE_NPPR_NEUROLOGYSTATUS")%> class="text" cols="80" rows="2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_NPPR_NEUROLOGYSTATUS" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_NPPR_NEUROLOGYSTATUS" property="value"/></textarea>
			            </td>
			        </tr>
			        <tr>
			            <td class="admin"><%=getTran("web","functional.status",sWebLanguage)%></td>
			            <td class="admin2">
			                <textarea onKeyup="resizeTextarea(this,10);limitChars(this,255);" <%=setRightClick("ITEM_TYPE_NPPR_FUNCTIONALSTATUS")%> class="text" cols="80" rows="2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_NPPR_FUNCTIONALSTATUS" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_NPPR_FUNCTIONALSTATUS" property="value"/></textarea>
			            </td>
			        </tr>
			        <tr>
			            <td class="admin"><%=getTran("web","diagnosis",sWebLanguage)%></td>
			            <td class="admin2">
			                <textarea onKeyup="resizeTextarea(this,10);limitChars(this,255);" <%=setRightClick("ITEM_TYPE_NPPR_DIAGNOSIS")%> class="text" cols="80" rows="2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_NPPR_DIAGNOSIS" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_NPPR_DIAGNOSIS" property="value"/></textarea>
			            </td>
			        </tr>
			        <tr>
			            <td class="admin"><%=getTran("web","treatment.goal",sWebLanguage)%></td>
			            <td class="admin2">
			                <textarea onKeyup="resizeTextarea(this,10);limitChars(this,255);" <%=setRightClick("ITEM_TYPE_NPPR_TREATMENTGOAL")%> class="text" cols="80" rows="2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_NPPR_TREATMENTGOAL" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_NPPR_TREATMENTGOAL" property="value"/></textarea>
			            </td>
			        </tr>
			        <tr>
			            <td class="admin"><%=getTran("web","treatment.means",sWebLanguage)%></td>
			            <td class="admin2">
			                <textarea onKeyup="resizeTextarea(this,10);limitChars(this,255);" <%=setRightClick("ITEM_TYPE_NPPR_TREATMENTMEANS")%> class="text" cols="80" rows="2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_NPPR_TREATMENTMEANS" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_NPPR_TREATMENTMEANS" property="value"/></textarea>
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
	    <%=getButtonsHtml(request,activeUser,activePatient,"occup.neuropsyphysiotherapyreport",sWebLanguage)%>
	<%=ScreenHelper.alignButtonsStop()%>

    <%=ScreenHelper.contextFooter(request)%>
</form>
<script>
  function submitForm(){
    document.getElementById("buttonsDiv").style.visibility = "hidden";
    var temp = Form.findFirstElement(transactionForm);//for ff compatibility
    document.transactionForm.submit();
  }
</script>
<%=writeJSButtons("transactionForm","saveButton")%>
