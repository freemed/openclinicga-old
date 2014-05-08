<%@include file="/includes/validateUser.jsp"%>
<%@page errorPage="/includes/error.jsp"%>

<%=checkPermission("occup.cnar.consultation","select",activeUser)%>

<form id="transactionForm" name="transactionForm" method="POST" action='<c:url value="/healthrecord/updateTransaction.do"/>?ts=<%=getTs()%>' onclick="setSaveButton(event);" onkeyup="setSaveButton(event);">
    <bean:define id="transaction" name="be.mxs.webapp.wl.session.SessionContainerFactory.WO_SESSION_CONTAINER" property="currentTransactionVO"/>
	<%=checkPrestationToday(activePatient.personid,false,activeUser,(TransactionVO)transaction)%>
  
    <input type="hidden" id="transactionId" name="currentTransactionVO.<TransactionVO[hashCode=<bean:write name="transaction" scope="page" property="transactionId"/>]>.transactionId" value="<bean:write name="transaction" scope="page" property="transactionId"/>"/>
    <input type="hidden" id="serverId" name="currentTransactionVO.<TransactionVO[hashCode=<bean:write name="transaction" scope="page" property="transactionId"/>]>.serverId" value="<bean:write name="transaction" scope="page" property="serverId"/>"/>
    <input type="hidden" id="transactionType" name="currentTransactionVO.<TransactionVO[hashCode=<bean:write name="transaction" scope="page" property="transactionId"/>]>.transactionType" value="<bean:write name="transaction" scope="page" property="transactionType"/>"/>
    <input type="hidden" readonly name="be.mxs.healthrecord.updateTransaction.actionForwardKey" value="/main.do?Page=curative/index.jsp&ts=<%=getTs()%>"/>
    <input type="hidden" readonly name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CONTEXT_DEPARTMENT" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CONTEXT_DEPARTMENT" translate="false" property="value"/>"/>
    <input type="hidden" readonly name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CONTEXT_CONTEXT" translate="false" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CONTEXT_CONTEXT" translate="false" property="value"/>"/>

    <% TransactionVO tran = (TransactionVO)transaction; %>
    <%=writeHistoryFunctions(tran.getTransactionType(),sWebLanguage)%>
    <%=contextHeader(request,sWebLanguage)%>
    
    <table class="list" width="100%" cellspacing="1">
		<tr>
			<td style="vertical-align:top;padding:0" class="admin2">
			    <table class="list" cellspacing="1" cellpadding="0" width="100%">
			        <%-- DATE --%>
			        <tr>
			            <td class="admin" width="<%=sTDAdminWidth%>">
			                <a href="javascript:openHistoryPopup();" title="<%=getTranNoLink("Web.Occup","History",sWebLanguage)%>">...</a>&nbsp;
			                <%=getTran("Web.Occup","medwan.common.date",sWebLanguage)%>
			            </td>
			            <td class="admin2">
			                <input type="text" class="text" size="12" maxLength="10" name="currentTransactionVO.<TransactionVO[hashCode=<bean:write name="transaction" scope="page" property="transactionId"/>]>.updateTime" value="<mxs:propertyAccessorI18N name="transaction" scope="page" property="updateTime" formatType="date" format="dd-mm-yyyy"/>" id="trandate" OnBlur='checkDate(this)'>
			                <script>writeTranDate();</script>
			            </td>
			        </tr>
			
			        <%-- ANAMNESIS --%>
			        <tr>
			            <td class="admin"><%=getTran("openclinic.chuk","anamnesis",sWebLanguage)%></td>
			            <td class="admin2">
			                <textarea onKeyup="resizeTextarea(this,10);limitChars(this,255);" <%=setRightClick("ITEM_TYPE_CNAR_CONSULTATION_ANAMNESIS")%> class="text" cols="80" rows="2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CNAR_CONSULTATION_ANAMNESIS" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CNAR_CONSULTATION_ANAMNESIS" property="value"/></textarea>
			            </td>
			        </tr>
			        
			        <%-- CONSULTATION BY --%>
			        <tr>
			            <td class="admin"><%=getTran("Web","consultation.by",sWebLanguage)%></td>
			            <td class="admin2">
			                <select class='text' name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CNAR_CONSULTATION_SOCIALASSISTANT" property="itemId"/>]>.value" id='socialassistant'>
			                    <option/>
			                    <% out.print(ScreenHelper.writeSelect("encounter.socialservice.manager",tran.getItemValue("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CNAR_CONSULTATION_SOCIALASSISTANT"),sWebLanguage)); %>
			                </select>
			            </td>
			        </tr>
			
			        <%-- FORESEEN TREATMENT --%>
			        <tr>
			            <td class="admin"><%=getTran("openclinic.chuk","foreseen.treatment",sWebLanguage)%></td>
			            <td class="admin2">
					        <input <%=setRightClick("ITEM_TYPE_CNAR_CONSULTATION_TREATMENT_ORTHO")%> type="checkbox" id="ft_1" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CNAR_CONSULTATION_TREATMENT_ORTHO" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CNAR_CONSULTATION_TREATMENT_ORTHO;value=medwan.common.true" property="value" outputString="checked"/> value="medwan.common.true"/><%=getLabel("web","cnar.orthopedics",sWebLanguage,"ft_1")%>
					        <input <%=setRightClick("ITEM_TYPE_CNAR_CONSULTATION_TREATMENT_KINE")%> type="checkbox" id="ft_2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CNAR_CONSULTATION_TREATMENT_KINE" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CNAR_CONSULTATION_TREATMENT_KINE;value=medwan.common.true" property="value" outputString="checked"/> value="medwan.common.true"/><%=getLabel("web","cnar.kine",sWebLanguage,"ft_2")%>
					        <input <%=setRightClick("ITEM_TYPE_CNAR_CONSULTATION_TREATMENT_SURGERY")%> type="checkbox" id="ft_3" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CNAR_CONSULTATION_TREATMENT_SURGERY" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CNAR_CONSULTATION_TREATMENT_SURGERY;value=medwan.common.true" property="value" outputString="checked"/> value="medwan.common.true"/><%=getLabel("web","cnar.surgery",sWebLanguage,"ft_3")%>
					        <input <%=setRightClick("ITEM_TYPE_CNAR_CONSULTATION_TREATMENT_TECH")%> type="checkbox" id="ft_4" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CNAR_CONSULTATION_TREATMENT_TECH" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CNAR_CONSULTATION_TREATMENT_TECH;value=medwan.common.true" property="value" outputString="checked"/> value="medwan.common.true"/><%=getLabel("web","cnar.tech",sWebLanguage,"ft_4")%>
					        <input <%=setRightClick("ITEM_TYPE_CNAR_CONSULTATION_TREATMENT_XRAY")%> type="checkbox" id="ft_5" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CNAR_CONSULTATION_TREATMENT_XRAY" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CNAR_CONSULTATION_TREATMENT_XRAY;value=medwan.common.true" property="value" outputString="checked"/> value="medwan.common.true"/><%=getLabel("web","cnar.xray",sWebLanguage,"ft_5")%>
			            </td>
			        </tr>
			
			        <%-- NUMBER OF MEETINGS --%>
			        <tr>
			            <td class="admin"><%=getTran("openclinic.chuk","sceances",sWebLanguage)%></td>
			            <td class="admin2">
			                <input <%=setRightClick("ITEM_TYPE_CNAR_CONSULTATION_TREATMENT_SCEANCE")%> type="text" class="text" size="4" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CNAR_CONSULTATION_TREATMENT_SCEANCE" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CNAR_CONSULTATION_TREATMENT_SCEANCE" property="value"/>" onblur="isNumber(this);"/>
			            </td>
			        </tr>
			
			        <%-- FREQUENCY --%>
			        <tr>
			            <td class="admin"><%=getTran("openclinic.chuk","frequency",sWebLanguage)%></td>
			            <td class="admin2">
			                <input <%=setRightClick("ITEM_TYPE_CNAR_CONSULTATION_FREQUENCY_DAY")%> type="text" class="text" size="4" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CNAR_CONSULTATION_FREQUENCY_DAY" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CNAR_CONSULTATION_FREQUENCY_DAY" property="value"/>" onblur="isNumber(this);"/> /<%=getTran("openclinic.chuk","day",sWebLanguage)%><br>
			                <input <%=setRightClick("ITEM_TYPE_CNAR_CONSULTATION_FREQUENCY_WEEK")%> type="text" class="text" size="4" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CNAR_CONSULTATION_FREQUENCY_WEEK" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CNAR_CONSULTATION_FREQUENCY_WEEK" property="value"/>" onblur="isNumber(this);"/> /<%=getTran("openclinic.chuk","week",sWebLanguage)%>
			            </td>
			        </tr>
			
			        <%-- REMARKS --%>
			        <tr>
			            <td class="admin"><%=getTran("openclinic.chuk","remarks",sWebLanguage)%></td>
			            <td class="admin2">
			                <textarea onKeyup="resizeTextarea(this,10);limitChars(this,255);" <%=setRightClick("ITEM_TYPE_CNAR_CONSULTATION_REMARKS")%> class="text" cols="80" rows="2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CNAR_CONSULTATION_REMARKS" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CNAR_CONSULTATION_REMARKS" property="value"/></textarea>
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
	    <%=getButtonsHtml(request,activeUser,activePatient,"occup.cnar.consultation",sWebLanguage)%>
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