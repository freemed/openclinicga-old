<%@include file="/includes/validateUser.jsp"%>
<%@page errorPage="/includes/error.jsp"%>

<%=checkPermission("occup.kinesitherapy.application","select",activeUser)%>

<form id="transactionForm" name="transactionForm" method="POST" action='<c:url value="/healthrecord/updateTransaction.do"/>?ts=<%=getTs()%>' onclick="setSaveButton(event);" onkeyup="setSaveButton(event);">
    <bean:define id="transaction" name="be.mxs.webapp.wl.session.SessionContainerFactory.WO_SESSION_CONTAINER" property="currentTransactionVO"/>
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
%>
    <table class="list" width="100%" cellspacing="1">
		<tr>
			<td valign="top" class="admin2">
			    <table class="list" cellspacing="1" cellpadding="0" width="100%">
			        <%-- DATE --%>
			        <tr>
			            <td class="admin" width="<%=sTDAdminWidth%>">
			                <a href="javascript:openHistoryPopup();" title="<%=getTran("Web.Occup","History",sWebLanguage)%>">...</a>&nbsp;
			                <%=getTran("Web.Occup","medwan.common.date",sWebLanguage)%>
			            </td>
			            <td class="admin2">
			                <input type="text" class="text" size="12" maxLength="10" name="currentTransactionVO.<TransactionVO[hashCode=<bean:write name="transaction" scope="page" property="transactionId"/>]>.updateTime" value="<mxs:propertyAccessorI18N name="transaction" scope="page" property="updateTime" formatType="date" format="dd-mm-yyyy"/>" id="trandate" OnBlur='checkDate(this)'>
			                <script type="text/javascript">writeMyDate("trandate","<c:url value="/_img/icon_agenda.gif"/>","<%=getTran("Web","PutToday",sWebLanguage)%>");</script>
			            </td>
			        </tr>
			
			        <tr>
			            <td class="admin">
			                <%=getTran("openclinic.chuk","anamnesis",sWebLanguage)%>
			            </td>
			            <td class="admin2">
			                <textarea onKeyup="resizeTextarea(this,10);limitChars(this,255);" <%=setRightClick("ITEM_TYPE_CNAR_CONSULTATION_ANAMNESIS")%> class="text" cols="100" rows="2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CNAR_CONSULTATION_ANAMNESIS" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CNAR_CONSULTATION_ANAMNESIS" property="value"/></textarea>
			            </td>
			        </tr>
			        <tr>
			            <td class="admin"><%=getTran("Web","consultation.by",sWebLanguage)%></td>
			            <td class="admin2">
			                <select class='text' name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CNAR_CONSULTATION_SOCIALASSISTANT" property="itemId"/>]>.value" id='socialassistant'>
			                    <option/>
			                    <%
			                        out.print(ScreenHelper.writeSelect("encounter.socialservice.manager",tran.getItemValue("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CNAR_CONSULTATION_SOCIALASSISTANT"),sWebLanguage));
			                    %>
			                </select>
			            </td>
			        </tr>
			
			        <tr>
			            <td class="admin">
			                <%=getTran("openclinic.chuk","foreseen.treatment",sWebLanguage)%>
			            </td>
			            <td class="admin2">
					        <input <%=setRightClick("ITEM_TYPE_CNAR_CONSULTATION_TREATMENT_ORTHO")%> type="checkbox"
					                                                                                name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CNAR_CONSULTATION_TREATMENT_ORTHO" property="itemId"/>]>.value"
					                <mxs:propertyAccessorI18N name="transaction.items" scope="page"
					                                          compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CNAR_CONSULTATION_TREATMENT_ORTHO;value=medwan.common.true"
					                                          property="value" outputString="checked"/> value="medwan.common.true"/><%=getTran("web","cnar.orthopedics",sWebLanguage) %>
					        <input <%=setRightClick("ITEM_TYPE_CNAR_CONSULTATION_TREATMENT_KINE")%> type="checkbox"
					                                                                                name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CNAR_CONSULTATION_TREATMENT_KINE" property="itemId"/>]>.value"
					                <mxs:propertyAccessorI18N name="transaction.items" scope="page"
					                                          compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CNAR_CONSULTATION_TREATMENT_KINE;value=medwan.common.true"
					                                          property="value" outputString="checked"/> value="medwan.common.true"/><%=getTran("web","cnar.kine",sWebLanguage) %>
					        <input <%=setRightClick("ITEM_TYPE_CNAR_CONSULTATION_TREATMENT_SURGERY")%> type="checkbox"
					                                                                                name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CNAR_CONSULTATION_TREATMENT_SURGERY" property="itemId"/>]>.value"
					                <mxs:propertyAccessorI18N name="transaction.items" scope="page"
					                                          compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CNAR_CONSULTATION_TREATMENT_SURGERY;value=medwan.common.true"
					                                          property="value" outputString="checked"/> value="medwan.common.true"/><%=getTran("web","cnar.surgery",sWebLanguage) %>
					        <input <%=setRightClick("ITEM_TYPE_CNAR_CONSULTATION_TREATMENT_TECH")%> type="checkbox"
					                                                                                name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CNAR_CONSULTATION_TREATMENT_TECH" property="itemId"/>]>.value"
					                <mxs:propertyAccessorI18N name="transaction.items" scope="page"
					                                          compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CNAR_CONSULTATION_TREATMENT_TECH;value=medwan.common.true"
					                                          property="value" outputString="checked"/> value="medwan.common.true"/><%=getTran("web","cnar.tech",sWebLanguage) %>
					        <input <%=setRightClick("ITEM_TYPE_CNAR_CONSULTATION_TREATMENT_XRAY")%> type="checkbox"
					                                                                                name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CNAR_CONSULTATION_TREATMENT_XRAY" property="itemId"/>]>.value"
					                <mxs:propertyAccessorI18N name="transaction.items" scope="page"
					                                          compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CNAR_CONSULTATION_TREATMENT_XRAY;value=medwan.common.true"
					                                          property="value" outputString="checked"/> value="medwan.common.true"/><%=getTran("web","cnar.xray",sWebLanguage) %>
			            </td>
			        </tr>
			
			        <%-- NUMBER OF MEETINGS --%>
			        <tr>
			            <td class="admin">
			                <%=getTran("openclinic.chuk","sceance",sWebLanguage)%>
			            </td>
			            <td class="admin2">
			                <input <%=setRightClick("ITEM_TYPE_CNAR_CONSULTATION_TREATMENT_SCEANCE")%> type="text" class="text" size="4" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CNAR_CONSULTATION_TREATMENT_SCEANCE" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CNAR_CONSULTATION_TREATMENT_SCEANCE" property="value"/>" onblur="isNumber(this);"/>
			            </td>
			        </tr>
			
			        <%-- FREQUENCY --%>
			        <tr>
			            <td class="admin">
			                <%=getTran("openclinic.chuk","frequency",sWebLanguage)%>
			            </td>
			            <td class="admin2">
			                <input <%=setRightClick("ITEM_TYPE_CNAR_CONSULTATION_FREQUENCY_DAY")%> type="text" class="text" size="4" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CNAR_CONSULTATION_FREQUENCY_DAY" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CNAR_CONSULTATION_FREQUENCY_DAY" property="value"/>" onblur="isNumber(this);"/> /<%=getTran("openclinic.chuk","day",sWebLanguage)%>
			                <br>
			                <input <%=setRightClick("ITEM_TYPE_CNAR_CONSULTATION_FREQUENCY_WEEK")%> type="text" class="text" size="4" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CNAR_CONSULTATION_FREQUENCY_WEEK" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CNAR_CONSULTATION_FREQUENCY_WEEK" property="value"/>" onblur="isNumber(this);"/> /<%=getTran("openclinic.chuk","week",sWebLanguage)%>
			            </td>
			        </tr>
			
			        <%-- REMARS --%>
			        <tr>
			            <td class="admin">
			                <%=getTran("openclinic.chuk","remarks",sWebLanguage)%>
			            </td>
			            <td class="admin2">
			                <textarea onKeyup="resizeTextarea(this,10);limitChars(this,255);" <%=setRightClick("ITEM_TYPE_CNAR_CONSULTATION_REMARKS")%> class="text" cols="100" rows="2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CNAR_CONSULTATION_REMARKS" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CNAR_CONSULTATION_REMARKS" property="value"/></textarea>
			            </td>
			        </tr>
			
			        <%-- BUTTONS --%>
			        <tr>
			            <td class="admin"/>
			            <td class="admin2" colspan="7">
			                <%=getButtonsHtml(request,activeUser,activePatient,"occup.kinesitherapy.application",sWebLanguage)%>
			            </td>
			        </tr>
			    </table>
			</td>
			<td valign="top" class="admin2">
			    <table class="list" width="100%" cellspacing="1">
			        <%-- Diagnoses --%>
			        <tr>
                        <td class="admin2">
                            <%ScreenHelper.setIncludePage(customerInclude("healthrecord/diagnosesEncoding.jsp"),pageContext);%>
                        </td>
			        </tr>
			    </table>
			</td>
		</tr>
    </table>

    <%=ScreenHelper.contextFooter(request)%>
</form>

<script>
  <%-- SUBMIT FORM --%>  
  function submitForm(){
    if(document.getElementById('encounteruid').value==''){
		alert('<%=getTranNoLink("web","no.encounter.linked",sWebLanguage)%>');
		searchEncounter();
	}	
    else {
	    var temp = Form.findFirstElement(transactionForm);//for ff compatibility
	    document.transactionForm.submit();
	    document.transactionForm.saveButton.style.visibility = "hidden";
    }
  }
  function searchEncounter(){
      openPopup("/_common/search/searchEncounter.jsp&ts=<%=getTs()%>&VarCode=currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CONTEXT_ENCOUNTERUID" property="itemId"/>]>.value&VarText=&FindEncounterPatient=<%=activePatient.personid%>");
  }
  if(document.getElementById('encounteruid').value==''){
	alert('<%=getTranNoLink("web","no.encounter.linked",sWebLanguage)%>');
	searchEncounter();
  }	
  
</script>

<%=writeJSButtons("transactionForm","saveButton")%>