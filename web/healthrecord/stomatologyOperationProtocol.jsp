<%@include file="/includes/validateUser.jsp"%>
<%@page errorPage="/includes/error.jsp"%>

<%=checkPermission("occup.operationprotocol","select",activeUser)%>

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
    
        String sTransactionStart    = getItemType(tran.getItems(),sPREFIX+"ITEM_TYPE_OPERATION_PROTOCOL_START"),
               sTransactionEnd      = getItemType(tran.getItems(),sPREFIX+"ITEM_TYPE_OPERATION_PROTOCOL_END"),
               sTransactionDuration = getItemType(tran.getItems(),sPREFIX+"ITEM_TYPE_OPERATION_PROTOCOL_DURATION");
    %>
    
    <table class="list" width="100%" cellspacing="1">
		<tr>
			<td style="vertical-align:top;padding:0" class="admin2">
			    <table class="list" cellspacing="1" cellpadding="0" width="100%">
			        <%-- DATE --%>
			        <tr>
			            <td class="admin" colspan="2">
			                <a href="javascript:openHistoryPopup();" title="<%=getTran("Web.Occup","History",sWebLanguage)%>">...</a>&nbsp;
			                <%=getTran("Web.Occup","medwan.common.date",sWebLanguage)%>
			            </td>
			            <td class="admin2">
			                <input type="text" class="text" size="12" maxLength="10" name="currentTransactionVO.<TransactionVO[hashCode=<bean:write name="transaction" scope="page" property="transactionId"/>]>.updateTime" value="<mxs:propertyAccessorI18N name="transaction" scope="page" property="updateTime" formatType="date" format="dd-mm-yyyy"/>" id="trandate" OnBlur='checkDate(this)'>
			                <script>writeTranDate();</script>
			            </td>
			        </tr>
			
			        <%-- starthour --%>
			        <tr>
			            <td class="admin" colspan="2"><%=getTran("openclinic.chuk","starthour",sWebLanguage)%></td>
			            <td class="admin2">
			                <input <%=setRightClick("ITEM_TYPE_OPERATION_PROTOCOL_START")%> class="text" type="text" size="5" id="startHour" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPERATION_PROTOCOL_START" property="itemId"/>]>.value" value="<%=sTransactionStart%>" onblur="checkTime(this);calculateDuration(this);" onkeypress="keypressTime(this)">
			            </td>
			        </tr>
			
			        <%-- endhour --%>
			        <tr>
			            <td class="admin" colspan="2"><%=getTran("openclinic.chuk","endhour",sWebLanguage)%></td>
			            <td class="admin2">
			                <input <%=setRightClick("ITEM_TYPE_OPERATION_PROTOCOL_END")%> class="text" type="text" size="5" id="endHour" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPERATION_PROTOCOL_END" property="itemId"/>]>.value" value="<%=sTransactionEnd%>" onblur="checkTime(this);calculateDuration(this);" onkeypress="keypressTime(this)">
			            </td>
			        </tr>
			
			        <%-- duration (calculated) --%>
			        <tr>
			            <td class="admin" colspan="2"><%=getTran("openclinic.chuk","duration",sWebLanguage)%></td>
			            <td class="admin2">
			                <input <%=setRightClick("ITEM_TYPE_OPERATION_PROTOCOL_DURATION")%> class="text" type="text" size="5" id="duration" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPERATION_PROTOCOL_DURATION" property="itemId"/>]>.value" value="<%=sTransactionDuration%>" onblur="checkTime(this);" readonly>
			            </td>
			        </tr>
			
			        <%-- diagnostic --%>
			        <tr>
			            <td class="admin" colspan="2"><%=getTran("openclinic.chuk","diagnostic",sWebLanguage)%></td>
			            <td class="admin2">
			                <textarea onKeyup="resizeTextarea(this,10);limitChars(this,255);" <%=setRightClick("ITEM_TYPE_OPERATION_PROTOCOL_DIAGNOSTIC")%> class="text" cols="60" rows="2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPERATION_PROTOCOL_DIAGNOSTIC" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPERATION_PROTOCOL_DIAGNOSTIC" property="value"/></textarea>
			            </td>
			        </tr>
			
			        <%-- intervention --%>
			        <tr>
			            <td class="admin" colspan="2"><%=getTran("openclinic.chuk","intervention",sWebLanguage)%></td>
			            <td class="admin2">
			                <textarea onKeyup="resizeTextarea(this,10);limitChars(this,255);" <%=setRightClick("ITEM_TYPE_OPERATION_PROTOCOL_INTERVENTION")%> class="text" cols="60" rows="2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPERATION_PROTOCOL_INTERVENTION" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPERATION_PROTOCOL_INTERVENTION" property="value"/></textarea>
			            </td>
			        </tr>
			
			        <%-- group.composition ------------------------------------------------------%>
			        <%-- surgeons --%>
			        <tr>
			            <td class="admin" rowspan="3" width="100"><%=getTran("openclinic.chuk","group.composition",sWebLanguage)%></td>
			            <td class="admin2" width="150"><%=getTran("openclinic.chuk","surgeons",sWebLanguage)%></td>
			            <td class="admin2">
			                <textarea onKeyup="resizeTextarea(this,10);limitChars(this,255);" <%=setRightClick("ITEM_TYPE_OPERATION_PROTOCOL_SURGEONS")%> class="text" cols="60" rows="2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPERATION_PROTOCOL_SURGEONS" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPERATION_PROTOCOL_SURGEONS" property="value"/></textarea>
			            </td>
			        </tr>
			
			        <%-- anasthesists --%>
			        <tr>
			            <td class="admin2"><%=getTran("openclinic.chuk","anasthesists",sWebLanguage)%></td>
			            <td class="admin2">
			                <textarea onKeyup="resizeTextarea(this,10);limitChars(this,255);" <%=setRightClick("ITEM_TYPE_OPERATION_PROTOCOL_ANASTHESISTS")%> class="text" cols="60" rows="2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPERATION_PROTOCOL_ANASTHESISTS" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPERATION_PROTOCOL_ANASTHESISTS" property="value"/></textarea>
			            </td>
			        </tr>
			
			        <%-- nurses --%>
			        <tr>
			            <td class="admin2"><%=getTran("openclinic.chuk","nurses",sWebLanguage)%></td>
			            <td class="admin2">
			                <textarea onKeyup="resizeTextarea(this,10);limitChars(this,255);" <%=setRightClick("ITEM_TYPE_OPERATION_PROTOCOL_NURSES")%> class="text" cols="60" rows="2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPERATION_PROTOCOL_NURSES" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPERATION_PROTOCOL_NURSES" property="value"/></textarea>
			            </td>
			        </tr>
			
			        <%-- installation --%>
			        <tr>
			            <td class="admin" colspan="2"><%=getTran("openclinic.chuk","patient.installation",sWebLanguage)%></td>
			            <td class="admin2">
			                <textarea onKeyup="resizeTextarea(this,10);limitChars(this,255);" <%=setRightClick("ITEM_TYPE_OPERATION_PROTOCOL_PATIENT_INSTALLATION")%> class="text" cols="60" rows="2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPERATION_PROTOCOL_PATIENT_INSTALLATION" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPERATION_PROTOCOL_PATIENT_INSTALLATION" property="value"/></textarea>
			            </td>
			        </tr>
			
			        <%-- aproval --%>
			        <tr>
			            <td class="admin" colspan="2"><%=getTran("openclinic.chuk","aproval",sWebLanguage)%></td>
			            <td class="admin2">
			                <textarea onKeyup="resizeTextarea(this,10);limitChars(this,255);" <%=setRightClick("ITEM_TYPE_OPERATION_PROTOCOL_APROVAL")%> class="text" cols="60" rows="2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPERATION_PROTOCOL_APROVAL" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPERATION_PROTOCOL_APROVAL" property="value"/></textarea>
			            </td>
			        </tr>
			
			        <%-- observations --%>
			        <tr>
			            <td class="admin" colspan="2"><%=getTran("openclinic.chuk","observations",sWebLanguage)%></td>
			            <td class="admin2">
			                <textarea onKeyup="resizeTextarea(this,10);limitChars(this,255);" <%=setRightClick("ITEM_TYPE_OPERATION_PROTOCOL_OBSERVATION")%> class="text" cols="60" rows="2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPERATION_PROTOCOL_OBSERVATION" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPERATION_PROTOCOL_OBSERVATION" property="value"/></textarea>
			            </td>
			        </tr>
			
			        <%-- surgical.act --%>
			        <tr>
			            <td class="admin" colspan="2"><%=getTran("openclinic.chuk","surgical.act",sWebLanguage)%></td>
			            <td class="admin2">
			                <textarea onKeyup="resizeTextarea(this,10);limitChars(this,255);" <%=setRightClick("ITEM_TYPE_OPERATION_PROTOCOL_SURGICAL_ACT")%> class="text" cols="60" rows="2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPERATION_PROTOCOL_SURGICAL_ACT" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPERATION_PROTOCOL_SURGICAL_ACT" property="value"/></textarea>
			            </td>
			        </tr>
			
			        <%-- closure --%>
			        <tr>
			            <td class="admin" colspan="2"><%=getTran("openclinic.chuk","closure",sWebLanguage)%></td>
			            <td class="admin2">
			                <textarea onKeyup="resizeTextarea(this,10);limitChars(this,255);" <%=setRightClick("ITEM_TYPE_OPERATION_PROTOCOL_CLOSURE")%> class="text" cols="60" rows="2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPERATION_PROTOCOL_CLOSURE" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPERATION_PROTOCOL_CLOSURE" property="value"/></textarea>
			            </td>
			        </tr>
			
			        <%-- care.post --%>
			        <tr>
			            <td class="admin" colspan="2"><%=getTran("openclinic.chuk","care.post.op",sWebLanguage)%></td>
			            <td class="admin2">
			                <textarea onKeyup="resizeTextarea(this,10);limitChars(this,255);" <%=setRightClick("ITEM_TYPE_OPERATION_PROTOCOL_CARE")%> class="text" cols="60" rows="2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPERATION_PROTOCOL_CARE" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPERATION_PROTOCOL_CARE" property="value"/></textarea>
			            </td>
			        </tr>
			
			        <%-- remarks --%>
			        <tr>
			            <td class="admin" colspan="2"><%=getTran("openclinic.chuk","remarks",sWebLanguage)%></td>
			            <td class="admin2">
			                <textarea onKeyup="resizeTextarea(this,10);limitChars(this,255);" <%=setRightClick("ITEM_TYPE_OPERATION_PROTOCOL_REMARKS")%> class="text" cols="60" rows="2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPERATION_PROTOCOL_REMARKS" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPERATION_PROTOCOL_REMARKS" property="value"/></textarea>
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
	    <%=getButtonsHtml(request,activeUser,activePatient,"occup.operationprotocol",sWebLanguage)%>
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
	  document.getElementById("buttonsDiv").style.visibility = "hidden";
	  document.transactionForm.submit();
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

  <%-- CALCULATE DURATION --%>
  function calculateDuration(obj){
    var vStart = document.getElementById("startHour").value,
        vEnd   = document.getElementById("endHour").value;

    var aStart = vStart.split(":");
    var aEnd = vEnd.split(":");

    var startDate = new Date();
    startDate.setHours(aStart[0]);
    startDate.setMinutes(aStart[1]);
    startDate.setSeconds(0);

    var endDate = new Date();
    endDate.setHours(aEnd[0]);
    endDate.setMinutes(aEnd[1]);
    endDate.setSeconds(0);

    var one_min = 1000*60;
    
    var vDurationDate = new Date();
    vDurationDate.setHours(0);
    vDurationDate.setMinutes(Math.ceil((endDate.getTime()-startDate.getTime())/(one_min)));
    vDurationDate.setSeconds(0);

    if(vStart!="" && vEnd!=""){
      if(endDate > startDate){
    	document.getElementById("duration").value = vDurationDate.getHours()+":"+(vDurationDate.getMinutes()<10?"0"+vDurationDate.getMinutes():vDurationDate.getMinutes());
      }
      else{
        durationObj.value = "";        
        alertDialog("web","endhour_greater_than_starthour");       
        obj.value = "";
      }
    }
    else{
      document.getElementById("duration").value = "";
    }
  }
</script>