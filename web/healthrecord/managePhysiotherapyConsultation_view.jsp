<%@page import="be.dpms.medwan.webapp.wo.common.system.SessionContainerWO,
                be.mxs.webapp.wl.session.SessionContainerFactory"%>
<%@page import="java.util.StringTokenizer"%>
<%@include file="/includes/validateUser.jsp"%>
<%@page errorPage="/includes/error.jsp"%>
<%=checkPermission("occup.physioconsultation","select",activeUser)%>

<%!
	//--- SET TERMINOLOGY LIST --------------------------------------------------------------------
	public String setTerminologyList(){
	    String sTerminology = " onkeydown='if(enterEvent(event,123)){"+
	                          " openPopup(\"/_common/search/terminologyList.jsp&ts="+getTs()+"&VarText=\"+this.name+\"&displayImmatNew=no&isUser=no\");" +
	                          " }'";
	    return sTerminology;
	}
%>

<%
    // supported languages
    String supportedLanguages = MedwanQuery.getInstance().getConfigString("supportedLanguages");
    if(supportedLanguages.length()==0) supportedLanguages = "nl,fr";
    supportedLanguages = supportedLanguages.toLowerCase();
%>

<form name="transactionForm" id="transactionForm" method="POST" action='<c:url value="/healthrecord/updateTransaction.do"/>?ts=<%=getTs()%>' onclick="setSaveButton(event);" onkeyup="setSaveButton(event);">
    <bean:define id="transaction" name="be.mxs.webapp.wl.session.SessionContainerFactory.WO_SESSION_CONTAINER" property="currentTransactionVO"/>
	<%=checkPrestationToday(activePatient.personid,false,activeUser,(TransactionVO)transaction)%>
  
    <input id="transactionId" type="hidden" name="currentTransactionVO.<TransactionVO[hashCode=<bean:write name="transaction" scope="page" property="transactionId"/>]>.transactionId" value="<bean:write name="transaction" scope="page" property="transactionId"/>"/>
    <input id="serverId" type="hidden" name="currentTransactionVO.<TransactionVO[hashCode=<bean:write name="transaction" scope="page" property="transactionId"/>]>.serverId" value="<bean:write name="transaction" scope="page" property="serverId"/>"/>
    <input id="transactionType" type="hidden" name="currentTransactionVO.<TransactionVO[hashCode=<bean:write name="transaction" scope="page" property="transactionId"/>]>.transactionType" value="<bean:write name="transaction" scope="page" property="transactionType"/>"/>
   
    <input type="hidden" readonly name="be.mxs.healthrecord.updateTransaction.actionForwardKey" value="/main.do?Page=curative/index.jsp&ts=<%=getTs()%>"/>
    <input type="hidden" readonly name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_RECRUITMENT_CONVOCATION_ID" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_RECRUITMENT_CONVOCATION_ID" property="value"/>"/>
    <input type="hidden" readonly name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CONTEXT_DEPARTMENT" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CONTEXT_DEPARTMENT" translate="false" property="value"/>"/>
    <input type="hidden" readonly name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CONTEXT_CONTEXT" translate="false" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CONTEXT_CONTEXT" translate="false" property="value"/>"/>

    <%=writeHistoryFunctions(((TransactionVO)transaction).getTransactionType(),sWebLanguage)%>
    <%=contextHeader(request,sWebLanguage)%>
    
    <table width="100%" cellspacing="1" cellpadding="0">
	    <%-- DATE --%>
	    <tr>
	        <td class="admin" width="20%">
	            <a href="javascript:openHistoryPopup();" title="<%=getTran("Web.Occup","History",sWebLanguage)%>">...</a>&nbsp;
	            <%=getTran("Web.Occup","medwan.common.date",sWebLanguage)%>
	        </td>
	        <td class="admin2">
	            <input type="text" class="text" size="12" maxLength="10" name="currentTransactionVO.<TransactionVO[hashCode=<bean:write name="transaction" scope="page" property="transactionId"/>]>.updateTime" value="<mxs:propertyAccessorI18N name="transaction" scope="page" property="updateTime" formatType="date" format="dd-mm-yyyy"/>" id="trandate" OnBlur='checkDate(this)'>
	            <script>writeTranDate();</script>
	        </td>
	    </tr>
	</table>
	<div style="padding-top:5px;"></div>
			    
    <table width="100%" cellspacing="1" cellpadding="0">
        <tr>
            <td style="vertical-align:top;padding:0px;" class="admin2">           
			    <table class="list" width="100%" cellspacing="1">			    
				    <%-- Medical Diagnosis --%>
				    <tr>
				        <td class="admin"><%=getTran("Web.Occup","medwan.common.diagnose_medical",sWebLanguage)%>&nbsp;</td>
				        <td class="admin2">
				            <textarea onKeyup="resizeTextarea(this,10);limitChars(this,255);" class="text" <%=setRightClick("ITEM_TYPE_PHYSIO_CONS_DIAG_MEDIC")%> cols="80" rows="2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_PHYSIO_CONS_DIAG_MEDIC" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_PHYSIO_CONS_DIAG_MEDIC" property="value"/></textarea>
				        </td>
				    </tr>
				    
				    <%-- Anamnese--%>
				    <tr>
				        <td class="admin"><%=getTran("Web.Occup","medwan.common.anamnese",sWebLanguage)%>&nbsp;</td>
				        <td class="admin2">
				            <textarea onKeyup="resizeTextarea(this,10);limitChars(this,255);" class="text" <%=setRightClick("ITEM_TYPE_PHYSIO_CONS_ANAMNESE")%> cols="80" rows="2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_PHYSIO_CONS_ANAMNESE" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_PHYSIO_CONS_ANAMNESE" property="value"/></textarea>
				        </td>
				    </tr>
			    
				    <%-- Physical Exam--%>
				    <tr>
				        <td class="admin"><%=getTran("Web.Occup","medwan.common.physical_exam",sWebLanguage)%>&nbsp;</td>
				        <td class="admin2">
				            <textarea onKeyup="resizeTextarea(this,10);limitChars(this,255);" class="text" <%=setRightClick("ITEM_TYPE_PHYSIO_CONS_EXAM_PHYS")%> cols="80" rows="2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_PHYSIO_CONS_EXAM_PHYS" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_PHYSIO_CONS_EXAM_PHYS" property="value"/></textarea>
				        </td>
				    </tr>
				    
				    <%-- Physical Diagnose--%>
				    <tr>
				        <td class="admin"><%=getTran("Web.Occup","medwan.common.physical_diagnose",sWebLanguage)%>&nbsp;</td>
				        <td class="admin2">
				            <textarea onKeyup="resizeTextarea(this,10);limitChars(this,255);" class="text" <%=setRightClick("ITEM_TYPE_PHYSIO_CONS_DIAG_PHYS")%> cols="80" rows="2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_PHYSIO_CONS_DIAG_PHYS" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_PHYSIO_CONS_DIAG_PHYS" property="value"/></textarea>
				        </td>
				    </tr>
				    
				    <%-- Physical treatment plan--%>
				    <tr>
				        <td class="admin"><%=getTran("Web.Occup","medwan.common.physical_treatment_plan",sWebLanguage)%>&nbsp;</td>
				        <td class="admin2">
				            <textarea onKeyup="resizeTextarea(this,10);limitChars(this,255);" class="text" <%=setRightClick("ITEM_TYPE_PHYSIO_CONS_PLAN_TRAIT_PHYS")%> cols="80" rows="2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_PHYSIO_CONS_PLAN_TRAIT_PHYS" property="itemId"/>]>.value" <%=setTerminologyList()%>><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_PHYSIO_CONS_PLAN_TRAIT_PHYS" property="value"/></textarea>
				        </td>
				    </tr>
				    
				    <%-- Reevalution--%>
				    <tr>
				        <td class="admin"><%=getTran("Web.Occup","medwan.common.reeval",sWebLanguage)%>&nbsp;</td>
				        <td class="admin2">
				            <textarea onKeyup="resizeTextarea(this,10);limitChars(this,255);" class="text" <%=setRightClick("ITEM_TYPE_PHYSIO_CONS_REEVAL")%> cols="80" rows="2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_PHYSIO_CONS_REEVAL" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_PHYSIO_CONS_REEVAL" property="value"/></textarea>
				        </td>
				    </tr>
				    
				    <%-- End Treatment --%>
				    <tr>
				        <td class='admin'><%=getTran("web.occup","medwan.common.enddate_treatment",sWebLanguage)%>&nbsp;</td>
				        <td class='admin2'>
				            <input type="text" class="text" size="12" maxLength="10" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_PHYSIO_CONS_FIN_TRAIT" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_PHYSIO_CONS_FIN_TRAIT" property="value" formatType="date" format="dd-mm-yyyy"/>" id="endtreatdate"/>
				            <script>writeMyDate("endtreatdate","<c:url value="/_img/icon_agenda.gif"/>","<%=getTran("Web","PutToday",sWebLanguage)%>");</script>
				        </td>
				    </tr>
	            </table>
	        </td> 
	    
	        <%-- DIAGNOSES --%>
	        <td style="vertical-align:top;">
	            <%ScreenHelper.setIncludePage(customerInclude("healthrecord/diagnosesEncoding.jsp"),pageContext);%>
	        </td>
	    </tr>
	</table>
    
	<%-- BUTTONS --%>
	<%=ScreenHelper.alignButtonsStart()%>
	    <%=getButtonsHtml(request,activeUser,activePatient,"occup.physioconsultation",sWebLanguage)%>
	<%=ScreenHelper.alignButtonsStop()%>
	    
	<%=ScreenHelper.contextFooter(request)%>
</form>

<script>
  <%-- SUBMIT FORM --%>
  function submitForm(){
    document.transactionForm.saveButton.disabled = true;
    <%
        SessionContainerWO sessionContainerWO = (SessionContainerWO)SessionContainerFactory.getInstance().getSessionContainerWO(request,SessionContainerWO.class.getName());
        out.print(takeOverTransaction(sessionContainerWO, activeUser,"document.transactionForm.submit();"));
    %>
  }
</script>

<%=writeJSButtons("transactionForm","saveButton")%>