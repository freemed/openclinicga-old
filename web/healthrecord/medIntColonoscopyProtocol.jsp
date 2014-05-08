<%@include file="/includes/validateUser.jsp"%>
<%@page errorPage="/includes/error.jsp"%>
<%=checkPermission("occup.protocol.colonoscopy","select",activeUser)%>

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
			<td style="vertical-align:top;">
			    <table class="list" width="100%" cellspacing="1">
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
			
			        <%-- motive --%>
			        <tr>
			            <td class="admin"><%=getTran("openclinic.chuk","motive",sWebLanguage)%></td>
			            <td class="admin2">
			                <textarea onkeyup="resizeTextarea(this,10);limitChars(this,255);" <%=setRightClick("ITEM_TYPE_COLONOSCOPY_PROTOCOL_MOTIVE")%> class="text" cols="80" rows="2"  name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_COLONOSCOPY_PROTOCOL_MOTIVE" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_COLONOSCOPY_PROTOCOL_MOTIVE" property="value"/></textarea>
			            </td>
			        </tr>
			
			        <%-- premedication --%>
			        <tr>
			            <td class="admin"><%=getTran("openclinic.chuk","premedication",sWebLanguage)%></td>
			            <td class="admin2">
			                <textarea onkeyup="resizeTextarea(this,10);limitChars(this,255);" <%=setRightClick("ITEM_TYPE_COLONOSCOPY_PROTOCOL_PREMEDICATION")%> class="text" cols="80" rows="2"  name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_COLONOSCOPY_PROTOCOL_PREMEDICATION" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_COLONOSCOPY_PROTOCOL_PREMEDICATION" property="value"/></textarea>
			            </td>
			        </tr>
			
			        <%-- endoscopy_type --%>
			        <tr>
			            <td class="admin"><%=getTran("openclinic.chuk","endoscopy_type",sWebLanguage)%></td>
			            <td class="admin2">
			                <textarea onkeyup="resizeTextarea(this,10);limitChars(this,255);" <%=setRightClick("ITEM_TYPE_COLONOSCOPY_PROTOCOL_ENDOSCOPY_TYPE")%> class="text" cols="80" rows="2"  name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_COLONOSCOPY_PROTOCOL_ENDOSCOPY_TYPE" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_COLONOSCOPY_PROTOCOL_ENDOSCOPY_TYPE" property="value"/></textarea>
			            </td>
			        </tr>
			
			        <%-- examination_description --%>
			        <tr>
			            <td class="admin"><%=getTran("openclinic.chuk","examination_description",sWebLanguage)%></td>
			            <td class="admin2">
			                <textarea onkeyup="resizeTextarea(this,10);limitChars(this,255);" <%=setRightClick("ITEM_TYPE_COLONOSCOPY_PROTOCOL_EXAMINATION_DESCRIPTION")%> class="text" cols="80" rows="2"  name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_COLONOSCOPY_PROTOCOL_EXAMINATION_DESCRIPTION" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_COLONOSCOPY_PROTOCOL_EXAMINATION_DESCRIPTION" property="value"/></textarea>
			            </td>
			        </tr>
			
			        <%-- investigations_done --%>
			        <tr>
			            <td class="admin"><%=getTran("openclinic.chuk","investigations_done",sWebLanguage)%></td>
			            <td class="admin2">
			                <input <%=setRightClick("ITEM_TYPE_COLONOSCOPY_PROTOCOL_BIOSCOPY")%> type="checkbox" id="central"   name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_COLONOSCOPY_PROTOCOL_BIOSCOPY" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_COLONOSCOPY_PROTOCOL_BIOSCOPY;value=medwan.common.true" property="value" outputString="checked"/> value="medwan.common.true"/><label for="central"><%=getTran("openclinic.chuk","biopsy",sWebLanguage)%></label>
			            </td>
			        </tr>
			
			        <%-- conclusion --%>
			        <tr>
			            <td class="admin"><%=getTran("openclinic.chuk","conclusion",sWebLanguage)%></td>
			            <td class="admin2">
			                <textarea onkeyup="resizeTextarea(this,10);limitChars(this,255);" <%=setRightClick("ITEM_TYPE_COLONOSCOPY_PROTOCOL_CONCLUSION")%> class="text" cols="80" rows="2"  name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_COLONOSCOPY_PROTOCOL_CONCLUSION" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_COLONOSCOPY_PROTOCOL_CONCLUSION" property="value"/></textarea>
			            </td>
			        </tr>
			
			        <%-- remarks --%>
			        <tr>
			            <td class="admin"><%=getTran("openclinic.chuk","remarks",sWebLanguage)%></td>
			            <td class="admin2">
			                <textarea onkeyup="resizeTextarea(this,10);limitChars(this,255);" <%=setRightClick("ITEM_TYPE_COLONOSCOPY_PROTOCOL_REMARKS")%> class="text" cols="80" rows="2"  name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_COLONOSCOPY_PROTOCOL_REMARKS" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_COLONOSCOPY_PROTOCOL_REMARKS" property="value"/></textarea>
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
	    <%=getButtonsHtml(request,activeUser,activePatient,"occup.protocol.colonoscopy",sWebLanguage)%>
	<%=ScreenHelper.alignButtonsStop()%>

    <%=ScreenHelper.contextFooter(request)%>
</form>

<script>
  <%-- SUBMIT FORM --%>
  function submitForm(){
    if(document.getElementById('encounteruid').value==""){
      alertDialog("web","no.encounter.linked");
      searchEncounter();
	}	
    else{
	  var temp = Form.findFirstElement(transactionForm); // for ff compatibility
	  document.getElementById("buttonsDiv").style.visibility = "hidden";
	  document.transactionForm.submit();
    }
  }
  
  <%-- SEARCH ENCOUNTER --%>
  function searchEncounter(){
	var url = "/_common/search/searchEncounter.jsp&ts=<%=getTs()%>"+
	          "&VarCode=currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CONTEXT_ENCOUNTERUID" property="itemId"/>]>.value"+
	          "&VarText="+
	          "&FindEncounterPatient=<%=activePatient.personid%>";
    openPopup(url);
  }
  
  if(document.getElementById('encounteruid').value==""){
	alertDialog("web","no.encounter.linked");
	searchEncounter();
  }  
</script>

<%=writeJSButtons("transactionForm","saveButton")%>