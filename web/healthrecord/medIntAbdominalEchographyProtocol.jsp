<%@include file="/includes/validateUser.jsp"%>
<%@page errorPage="/includes/error.jsp"%>

<%=checkPermission("occup.protocol.abdominalechography","select",activeUser)%>

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
    </table>
    <div style="padding-top:5px;"></div>
     
    <table class="list" width="100%" cellspacing="1">	
        <%-- motive / liver --%>	
        <tr>
            <td class="admin" width="<%=sTDAdminWidth%>"><%=getTran("openclinic.chuk","motive",sWebLanguage)%></td>
            <td class="admin2">
                <textarea onkeyup="resizeTextarea(this,10);limitChars(this,255);" <%=setRightClick("ITEM_TYPE_ABDOMINAL_ECHOGRAPHY_PROTOCOL_MOTIVE")%> class="text" cols="60" rows="2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ABDOMINAL_ECHOGRAPHY_PROTOCOL_MOTIVE" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ABDOMINAL_ECHOGRAPHY_PROTOCOL_MOTIVE" property="value"/></textarea>
            </td>
            <td class="admin" width="<%=sTDAdminWidth%>"><%=getTran("openclinic.chuk","liver",sWebLanguage)%></td>
            <td class="admin2">
                <textarea onkeyup="resizeTextarea(this,10);limitChars(this,255);" <%=setRightClick("ITEM_TYPE_ABDOMINAL_ECHOGRAPHY_PROTOCOL_LIVER")%> class="text" cols="60" rows="2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ABDOMINAL_ECHOGRAPHY_PROTOCOL_LIVER" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ABDOMINAL_ECHOGRAPHY_PROTOCOL_LIVER" property="value"/></textarea>
            </td>
        </tr>

        <%-- hile / vp_diameter --%>
        <tr>
            <td class="admin"><%=getTran("openclinic.chuk","hile",sWebLanguage)%></td>
            <td class="admin2">
                <textarea onkeyup="resizeTextarea(this,10);limitChars(this,255);" <%=setRightClick("ITEM_TYPE_ABDOMINAL_ECHOGRAPHY_PROTOCOL_HILE")%> class="text" cols="60" rows="2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ABDOMINAL_ECHOGRAPHY_PROTOCOL_HILE" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ABDOMINAL_ECHOGRAPHY_PROTOCOL_HILE" property="value"/></textarea>
            </td>
            <td class="admin"><%=getTran("openclinic.chuk","vp_diameter",sWebLanguage)%></td>
            <td class="admin2">
                <textarea onkeyup="resizeTextarea(this,10);limitChars(this,255);" <%=setRightClick("ITEM_TYPE_ABDOMINAL_ECHOGRAPHY_PROTOCOL_VP_DIAMETER")%> class="text" cols="60" rows="2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ABDOMINAL_ECHOGRAPHY_PROTOCOL_VP_DIAMETER" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ABDOMINAL_ECHOGRAPHY_PROTOCOL_VP_DIAMETER" property="value"/></textarea>
            </td>
        </tr>

        <%-- biliary_vesicle / paroi --%>
        <tr>
            <td class="admin"><%=getTran("openclinic.chuk","biliary_vesicle",sWebLanguage)%></td>
            <td class="admin2">
                <textarea onkeyup="resizeTextarea(this,10);limitChars(this,255);" <%=setRightClick("ITEM_TYPE_ABDOMINAL_ECHOGRAPHY_PROTOCOL_BILIARY_VESICLE")%> class="text" cols="60" rows="2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ABDOMINAL_ECHOGRAPHY_PROTOCOL_BILIARY_VESICLE" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ABDOMINAL_ECHOGRAPHY_PROTOCOL_BILIARY_VESICLE" property="value"/></textarea>
            </td>
            <td class="admin"><%=getTran("openclinic.chuk","paroi",sWebLanguage)%></td>
            <td class="admin2">
                <textarea onkeyup="resizeTextarea(this,10);limitChars(this,255);" <%=setRightClick("ITEM_TYPE_ABDOMINAL_ECHOGRAPHY_PROTOCOL_PAROI")%> class="text" cols="60" rows="2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ABDOMINAL_ECHOGRAPHY_PROTOCOL_PAROI" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ABDOMINAL_ECHOGRAPHY_PROTOCOL_PAROI" property="value"/></textarea>
            </td>
        </tr>

        <%-- veine_cave / aorta --%>
        <tr>
            <td class="admin"><%=getTran("openclinic.chuk","veine_cave",sWebLanguage)%></td>
            <td class="admin2">
                <textarea onkeyup="resizeTextarea(this,10);limitChars(this,255);" <%=setRightClick("ITEM_TYPE_ABDOMINAL_ECHOGRAPHY_PROTOCOL_VEINE_CAVE")%> class="text" cols="60" rows="2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ABDOMINAL_ECHOGRAPHY_PROTOCOL_VEINE_CAVE" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ABDOMINAL_ECHOGRAPHY_PROTOCOL_VEINE_CAVE" property="value"/></textarea>
            </td>
            <td class="admin"><%=getTran("openclinic.chuk","aorta",sWebLanguage)%></td>
            <td class="admin2">
                <textarea onkeyup="resizeTextarea(this,10);limitChars(this,255);" <%=setRightClick("ITEM_TYPE_ABDOMINAL_ECHOGRAPHY_PROTOCOL_AORTA")%> class="text" cols="60" rows="2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ABDOMINAL_ECHOGRAPHY_PROTOCOL_AORTA" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ABDOMINAL_ECHOGRAPHY_PROTOCOL_AORTA" property="value"/></textarea>
            </td>
        </tr>

        <%-- kidneys --%>
        <tr>
            <td class="admin"><%=getTran("openclinic.chuk","right_kidney",sWebLanguage)%></td>
            <td class="admin2">
                <textarea onkeyup="resizeTextarea(this,10);limitChars(this,255);" <%=setRightClick("ITEM_TYPE_ABDOMINAL_ECHOGRAPHY_PROTOCOL_RIGHT_KIDNEY")%> class="text" cols="60" rows="2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ABDOMINAL_ECHOGRAPHY_PROTOCOL_RIGHT_KIDNEY" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ABDOMINAL_ECHOGRAPHY_PROTOCOL_RIGHT_KIDNEY" property="value"/></textarea>
            </td>
            <td class="admin"><%=getTran("openclinic.chuk","left_kidney",sWebLanguage)%></td>
            <td class="admin2">
                <textarea onkeyup="resizeTextarea(this,10);limitChars(this,255);" <%=setRightClick("ITEM_TYPE_ABDOMINAL_ECHOGRAPHY_PROTOCOL_LEFT_KIDNEY")%> class="text" cols="60" rows="2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ABDOMINAL_ECHOGRAPHY_PROTOCOL_LEFT_KIDNEY" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ABDOMINAL_ECHOGRAPHY_PROTOCOL_LEFT_KIDNEY" property="value"/></textarea>
            </td>
        </tr>

        <%-- ascite / spleen --%>
        <tr>
            <td class="admin">
                <%=getTran("openclinic.chuk","ascite",sWebLanguage)%>
            </td>
            <td class="admin2">
                <textarea onkeyup="resizeTextarea(this,10);limitChars(this,255);" <%=setRightClick("ITEM_TYPE_ABDOMINAL_ECHOGRAPHY_PROTOCOL_ASCITES")%> class="text" cols="60" rows="2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ABDOMINAL_ECHOGRAPHY_PROTOCOL_ASCITES" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ABDOMINAL_ECHOGRAPHY_PROTOCOL_ASCITES" property="value"/></textarea>
            </td>
            <td class="admin">
                <%=getTran("openclinic.chuk","spleen",sWebLanguage)%>
            </td>
            <td class="admin2">
                <textarea onkeyup="resizeTextarea(this,10);limitChars(this,255);" <%=setRightClick("ITEM_TYPE_ABDOMINAL_ECHOGRAPHY_PROTOCOL_SPLEEN")%> class="text" cols="60" rows="2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ABDOMINAL_ECHOGRAPHY_PROTOCOL_SPLEEN" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ABDOMINAL_ECHOGRAPHY_PROTOCOL_SPLEEN" property="value"/></textarea>
            </td>
        </tr>

        <%-- pancreas --%>
        <tr>
            <td class="admin"><%=getTran("openclinic.chuk","pancreas",sWebLanguage)%></td>
            <td class="admin2">
                <textarea onkeyup="resizeTextarea(this,10);limitChars(this,255);" <%=setRightClick("ITEM_TYPE_ABDOMINAL_ECHOGRAPHY_PROTOCOL_PANCREAS")%> class="text" cols="60" rows="2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ABDOMINAL_ECHOGRAPHY_PROTOCOL_PANCREAS" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ABDOMINAL_ECHOGRAPHY_PROTOCOL_PANCREAS" property="value"/></textarea>
            </td>
            <td class="admin"><%=getTran("openclinic.chuk","right_pleural_effusion",sWebLanguage)%></td>
            <td class="admin2">
                <textarea onkeyup="resizeTextarea(this,10);limitChars(this,255);" <%=setRightClick("ITEM_TYPE_ABDOMINAL_ECHOGRAPHY_PROTOCOL_RIGHT_PLEURAL_EFFUSION")%> class="text" cols="60" rows="2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ABDOMINAL_ECHOGRAPHY_PROTOCOL_RIGHT_PLEURAL_EFFUSION" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ABDOMINAL_ECHOGRAPHY_PROTOCOL_RIGHT_PLEURAL_EFFUSION" property="value"/></textarea>
            </td>
        </tr>

        <%-- pleural_effusion --%>
        <tr>
            <td class="admin"><%=getTran("openclinic.chuk","left_pleural_effusion",sWebLanguage)%></td>
            <td class="admin2">
                <textarea onkeyup="resizeTextarea(this,10);limitChars(this,255);" <%=setRightClick("ITEM_TYPE_ABDOMINAL_ECHOGRAPHY_PROTOCOL_LEFT_PLEURAL_EFFUSION")%> class="text" cols="60" rows="2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ABDOMINAL_ECHOGRAPHY_PROTOCOL_LEFT_PLEURAL_EFFUSION" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ABDOMINAL_ECHOGRAPHY_PROTOCOL_LEFT_PLEURAL_EFFUSION" property="value"/></textarea>
            </td>
            <td class="admin"><%=getTran("openclinic.chuk","precardial_pleural_effusion",sWebLanguage)%></td>
            <td class="admin2">
                <textarea onkeyup="resizeTextarea(this,10);limitChars(this,255);" <%=setRightClick("ITEM_TYPE_ABDOMINAL_ECHOGRAPHY_PROTOCOL_PRECARDIAL_PLEURAL_EFFUSION")%> class="text" cols="60" rows="2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ABDOMINAL_ECHOGRAPHY_PROTOCOL_PRECARDIAL_PLEURAL_EFFUSION" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ABDOMINAL_ECHOGRAPHY_PROTOCOL_PRECARDIAL_PLEURAL_EFFUSION" property="value"/></textarea>
            </td>
        </tr>
    </table>
    <div style="padding-top:5px;"></div>
     
    <%-- CONCLUSION & REMARKS --%>
    <table class="list" width="100%" cellspacing="0" cellpadding="0">
        <tr>
			<td style="vertical-align:top;width:49%">
                <table width="100%" cellspacing="1" cellpadding="1">
				    <%-- CONCLUSION --%>
					<tr>
			            <td class="admin" width="<%=sTDAdminWidth%>"><%=getTran("openclinic.chuk","conclusion",sWebLanguage)%></td>
			            <td class="admin2">
			                <textarea onkeyup="resizeTextarea(this,10);limitChars(this,255);" <%=setRightClick("ITEM_TYPE_ABDOMINAL_ECHOGRAPHY_PROTOCOL_CONCLUSION")%> class="text" cols="60" rows="2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ABDOMINAL_ECHOGRAPHY_PROTOCOL_CONCLUSION" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ABDOMINAL_ECHOGRAPHY_PROTOCOL_CONCLUSION" property="value"/></textarea>
			            </td>
            		</tr>
            		
				    <%-- REMARKS --%>
					<tr>
			            <td class="admin" width="<%=sTDAdminWidth%>"><%=getTran("openclinic.chuk","remarks",sWebLanguage)%></td>
			            <td class="admin2">
			                <textarea onkeyup="resizeTextarea(this,10);limitChars(this,255);" <%=setRightClick("ITEM_TYPE_ABDOMINAL_ECHOGRAPHY_PROTOCOL_REMARKS")%> class="text" cols="60" rows="2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ABDOMINAL_ECHOGRAPHY_PROTOCOL_REMARKS" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ABDOMINAL_ECHOGRAPHY_PROTOCOL_REMARKS" property="value"/></textarea>
			            </td>
            		</tr>
            	</table>
           	</td>
           	
            <%-- DIAGNOSES --%>
			<td class="admin2" style="vertical-align:top;">
                <%ScreenHelper.setIncludePage(customerInclude("healthrecord/diagnosesEncoding.jsp"),pageContext);%>
           	</td>
        </tr>
    </table>

	<%-- BUTTONS --%>
	<%=ScreenHelper.alignButtonsStart()%>
        <%=getButtonsHtml(request,activeUser,activePatient,"occup.protocol.abdominalechography",sWebLanguage)%>
	<%=ScreenHelper.alignButtonsStop()%>
	
    <%=ScreenHelper.contextFooter(request)%>
</form>

<script>
  <%-- SUBMIT FORM --%>
  function submitForm(){
    if(document.getElementById('encounteruid').value.length==0){
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
  
  if(document.getElementById('encounteruid').value.length==0){
	alertDialog("web","no.encounter.linked");
	searchEncounter();
  }  
</script>