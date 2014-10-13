<%@page import="be.mxs.common.model.vo.healthrecord.TransactionVO,
                be.mxs.common.model.vo.healthrecord.ItemVO"%>
<%@ page import="java.util.*" %>
<%@ page import="be.openclinic.system.Item" %>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>
<%=checkPermission("occup.ergotherapy","select",activeUser)%>

<%!
	private String addErgotherapy(int iTotal, String sTmpErgotherapyDate, String sTmpErgotherapyObservation, String sTmpErgotherapyConclusion, String sWebLanguage) {
	    return "<tr id='rowErgotherapy" + iTotal + "'>"
	            + "<td width='36'>"
	            + " <a href='javascript:deleteErgotherapy(rowErgotherapy" + iTotal + ")'><img src='" + sCONTEXTPATH + "/_img/icons/icon_delete.gif' alt='" + getTran("Web.Occup", "medwan.common.delete", sWebLanguage) + "' border='0'></a> "
	            + " <a href='javascript:editErgotherapy(rowErgotherapy" + iTotal + ")'><img src='" + sCONTEXTPATH + "/_img/icons/icon_edit.gif' alt='" + getTran("Web.Occup", "medwan.common.edit", sWebLanguage) + "' border='0'></a>"
	            + "</td>"
	            + "<td>&nbsp;" + sTmpErgotherapyDate + "</td>"
	            + "<td>&nbsp;" + sTmpErgotherapyObservation + "</td>"
	            + "<td>&nbsp;" + sTmpErgotherapyConclusion + "</td>"
	            + "</tr>";
	}


%>
    <bean:define id="transaction" name="be.mxs.webapp.wl.session.SessionContainerFactory.WO_SESSION_CONTAINER" property="currentTransactionVO"/>
	<%=checkPrestationToday(activePatient.personid,false,activeUser,(TransactionVO)transaction)%>
<%
	String sDivErgotherapy="";
	String sErgotherapy="";
	TransactionVO tran=null;
	if(transaction!=null){
        tran = (TransactionVO) transaction;
        if (tran != null) {
            sErgotherapy = getItemType(tran.getItems(), sPREFIX+"ITEM_TYPE_ERGOTHERAPY_OBSERVATION");
        }
	}
	
    int iTotal = 1;

    if (sErgotherapy.indexOf("£") > -1) {
        String sTmpErgotherapy = sErgotherapy;
        String sTmpErgotherapyDate, sTmpErgotherapyObservation, sTmpErgotherapyConclusion;
        sErgotherapy = "";
        while (sTmpErgotherapy.toLowerCase().indexOf("$") > -1) {
            sTmpErgotherapyDate = "";
            sTmpErgotherapyObservation = "";
            sTmpErgotherapyConclusion = "";

            if (sTmpErgotherapy.toLowerCase().indexOf("£") > -1) {
            	sTmpErgotherapyDate = sTmpErgotherapy.substring(0, sTmpErgotherapy.toLowerCase().indexOf("£"));
            	sTmpErgotherapyDate = ScreenHelper.convertDate(sTmpErgotherapyDate);
                sTmpErgotherapy = sTmpErgotherapy.substring(sTmpErgotherapy.toLowerCase().indexOf("£") + 1);
            }
            if (sTmpErgotherapy.toLowerCase().indexOf("£") > -1) {
            	sTmpErgotherapyObservation = sTmpErgotherapy.substring(0, sTmpErgotherapy.toLowerCase().indexOf("£"));
                sTmpErgotherapy = sTmpErgotherapy.substring(sTmpErgotherapy.toLowerCase().indexOf("£") + 1);
            }
            if (sTmpErgotherapy.toLowerCase().indexOf("$") > -1) {
            	sTmpErgotherapyConclusion = sTmpErgotherapy.substring(0, sTmpErgotherapy.toLowerCase().indexOf("$"));
                sTmpErgotherapy = sTmpErgotherapy.substring(sTmpErgotherapy.toLowerCase().indexOf("$") + 1);
            }

            sErgotherapy += "rowErgotherapy" + iTotal + "=" + sTmpErgotherapyDate + "£" + sTmpErgotherapyObservation + "£" + sTmpErgotherapyConclusion + "$";
            sDivErgotherapy += addErgotherapy(iTotal, sTmpErgotherapyDate, sTmpErgotherapyObservation, sTmpErgotherapyConclusion, sWebLanguage);
            iTotal++;
        }
    } else if (sErgotherapy.length() > 0) {
        String sTmpErgotherapy = sErgotherapy;
        sErgotherapy += "rowErgotherapy" + iTotal + "=££" + sTmpErgotherapy + "$";
        sDivErgotherapy += addErgotherapy(iTotal, "", "", sTmpErgotherapy, sWebLanguage);
        iTotal++;
    }
%>

<form id="transactionForm" name="transactionForm" method="POST" action='<c:url value="/healthrecord/updateTransaction.do"/>?ts=<%=getTs()%>' onclick="setSaveButton(event);" onkeyup="setSaveButton(event);">
    <input type="hidden" id="transactionId" name="currentTransactionVO.<TransactionVO[hashCode=<bean:write name="transaction" scope="page" property="transactionId"/>]>.transactionId" value="<bean:write name="transaction" scope="page" property="transactionId"/>"/>
    <input type="hidden" id="serverId" name="currentTransactionVO.<TransactionVO[hashCode=<bean:write name="transaction" scope="page" property="transactionId"/>]>.serverId" value="<bean:write name="transaction" scope="page" property="serverId"/>"/>
    <input type="hidden" id="transactionType" name="currentTransactionVO.<TransactionVO[hashCode=<bean:write name="transaction" scope="page" property="transactionId"/>]>.transactionType" value="<bean:write name="transaction" scope="page" property="transactionType"/>"/>
    <input type="hidden" readonly name="be.mxs.healthrecord.updateTransaction.actionForwardKey" value="/main.do?Page=curative/index.jsp&ts=<%=getTs()%>"/>
    <input type="hidden" readonly name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CONTEXT_DEPARTMENT" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CONTEXT_DEPARTMENT" translate="false" property="value"/>"/>
    <input type="hidden" readonly name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CONTEXT_CONTEXT" translate="false" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CONTEXT_CONTEXT" translate="false" property="value"/>"/>

    <%=writeHistoryFunctions(((TransactionVO)transaction).getTransactionType(),sWebLanguage)%>
    <%=contextHeader(request,sWebLanguage)%>
    <table class="list" cellspacing="1" cellpadding="0" width="100%">
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
	    <%-- DIAGNOSIS --%>
	    <tr>
	    	<td class="admin" colspan="2">
		      	<%ScreenHelper.setIncludePage(customerInclude("healthrecord/diagnosesEncoding.jsp"),pageContext);%>
	    	</td>
	    </tr>
    <%--  MOTIF --%>
    <tr>
        <td class="admin" width="<%=sTDAdminWidth%>" nowrap><%=getTran("web","reason",sWebLanguage)%>&nbsp;</td>
        <td class="admin2" width="100%">
            <textarea id="focusField" onKeyup="resizeTextarea(this,10);limitChars(this,255);" <%=setRightClick("ITEM_TYPE_ERGOTHERAPY_REASON")%> class="text" cols="80" rows="2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ERGOTHERAPY_REASON" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ERGOTHERAPY_REASON" property="value"/></textarea>
        </td>
    </tr>
    <%--  HISTORIQUE --%>
    <tr>
        <td class="admin"><%=getTran("web","short.history",sWebLanguage)%>&nbsp;</td>
        <td class="admin2">
            <textarea onKeyup="resizeTextarea(this,10);limitChars(this,255);" <%=setRightClick("ITEM_TYPE_ERGOTHERAPY_HISTORY")%> class="text" cols="80" rows="2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ERGOTHERAPY_HISTORY" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ERGOTHERAPY_HISTORY" property="value"/></textarea>
        </td>
    </tr>
    
    <%--  PERSPECTIVE DE LA VIE DU MALADE --%>
    <tr>
        <td class="admin" width="<%=sTDAdminWidth%>" nowrap><%=getTran("web","life.perspective",sWebLanguage)%>&nbsp;</td>
        <td class="admin2" width="100%">
            <textarea id="focusField" onKeyup="resizeTextarea(this,10);limitChars(this,255);" <%=setRightClick("ITEM_TYPE_ERGOTHERAPY_LIFEPERSPECTIVE")%> class="text" cols="80" rows="2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ERGOTHERAPY_LIFEPERSPECTIVE" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ERGOTHERAPY_LIFEPERSPECTIVE" property="value"/></textarea>
        </td>
    </tr>
    <%--  PROBLEME DE SOINS --%>
    <tr>
        <td class="admin"><%=getTran("web","care.problems",sWebLanguage)%>&nbsp;</td>
        <td class="admin2">
            <textarea onKeyup="resizeTextarea(this,10);limitChars(this,255);" <%=setRightClick("ITEM_TYPE_ERGOTHERAPY_CAREPROBLEMS")%> class="text" cols="80" rows="2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ERGOTHERAPY_CAREPROBLEMS" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ERGOTHERAPY_CAREPROBLEMS" property="value"/></textarea>
        </td>
    </tr>
    
    <%--  OBJECTIF --%>
    <tr>
        <td class="admin"><%=getTran("web","objective",sWebLanguage)%>&nbsp;</td>
        <td class="admin2">
            <textarea onKeyup="resizeTextarea(this,10);limitChars(this,255);" <%=setRightClick("ITEM_TYPE_ERGOTHERAPY_OBJECTIVE")%> class="text" cols="80" rows="2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ERGOTHERAPY_OBJECTIVE" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ERGOTHERAPY_OBJECTIVE" property="value"/></textarea>
        </td>
    </tr>
    <tr class="admin" >
        <td colspan="2" > <%=getTran("web","activity.plan",sWebLanguage)%></td>
    </tr>
    <tr>
        <td class="admin"><%=getTran("web","activity.calendar",sWebLanguage)%>&nbsp;</td>
        <td class="admin2">
			<table>
				<tr>
					<td><%=getTran("web","monday",sWebLanguage)%></td>
					<td><%=getTran("web","tuesday",sWebLanguage)%></td>
					<td><%=getTran("web","wednesday",sWebLanguage)%></td>
					<td><%=getTran("web","thursday",sWebLanguage)%></td>
					<td><%=getTran("web","friday",sWebLanguage)%></td>
					<td><%=getTran("web","saturday",sWebLanguage)%></td>
				</tr>
				<tr>
					<td>
						<select name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ERGOTHERAPY_MONDAY" property="itemId"/>]>.value">
							<%=ScreenHelper.writeSelect("ergotherapy.activity",tran.getItemValue("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ERGOTHERAPY_MONDAY"),sWebLanguage)%>
						</select>
					</td>
					<td>
						<select name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ERGOTHERAPY_TUESDAY" property="itemId"/>]>.value">
							<%=ScreenHelper.writeSelect("ergotherapy.activity",tran.getItemValue("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ERGOTHERAPY_TUESDAY"),sWebLanguage)%>
						</select>
					</td>
					<td>
						<select name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ERGOTHERAPY_WEDNESDAY" property="itemId"/>]>.value">
							<%=ScreenHelper.writeSelect("ergotherapy.activity",tran.getItemValue("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ERGOTHERAPY_WEDNESDAY"),sWebLanguage)%>
						</select>
					</td>
					<td>
						<select name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ERGOTHERAPY_THURSDAY" property="itemId"/>]>.value">
							<%=ScreenHelper.writeSelect("ergotherapy.activity",tran.getItemValue("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ERGOTHERAPY_THURSDAY"),sWebLanguage)%>
						</select>
					</td>
					<td>
						<select name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ERGOTHERAPY_FRIDAY" property="itemId"/>]>.value">
							<%=ScreenHelper.writeSelect("ergotherapy.activity",tran.getItemValue("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ERGOTHERAPY_FRIDAY"),sWebLanguage)%>
						</select>
					</td>
					<td>
						<select name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ERGOTHERAPY_SATURDAY" property="itemId"/>]>.value">
							<%=ScreenHelper.writeSelect("ergotherapy.activity",tran.getItemValue("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ERGOTHERAPY_SATURDAY"),sWebLanguage)%>
						</select>
					</td>
				</tr>
			</table>
        </td>
    </tr>
    <tr class="admin" >
        <td colspan="2" > <%=getTran("web","observations",sWebLanguage)%></td>
    </tr>
    <tr>
    	<td colspan="2">
	    	<table id="tblErgotherapy" width="100%">
	    		<tr>
	                <td class="admin" width="36">&nbsp;</td>
	  	     		<td class="admin"><%=getTran("web","date",sWebLanguage)%></td>
		     		<td class="admin"><%=getTran("web","observation",sWebLanguage)%></td>
		     		<td class="admin"><%=getTran("web","conclusion",sWebLanguage)%></td>
	                <td class="admin">&nbsp;</td>
		     	</tr>
		     	<tr>
	                <td class="admin2"></td>
	                <td class="admin2"><%=writeDateField("ErgotherapyDate", "transactionForm","",sWebLanguage)%></td>
	                <td class="admin2"><input type="text" class="text" name="ErgotherapyObservation" size="80" onblur="limitLength(this);"></td>
	                <td class="admin2"><input type="text" class="text" name="ErgotherapyConclusion" size="80" onblur="limitLength(this);"></td>
	                <td class="admin2">
	                    <input type="button" class="button" name="ButtonAddErgotherapy" onclick="addErgotherapy()" value="<%=getTranNoLink("Web","add",sWebLanguage)%>">
	                    <input type="button" class="button" name="ButtonUpdateErgotherapy" onclick="updateErgotherapy()" value="<%=getTranNoLink("Web","edit",sWebLanguage)%>">
	                </td>
		     	</tr>
	            <%=sDivErgotherapy%>
	            <input type="hidden" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ERGOTHERAPY_OBSERVATION1" property="itemId"/>]>.value"/>
	            <input type="hidden" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ERGOTHERAPY_OBSERVATION2" property="itemId"/>]>.value"/>
	            <input type="hidden" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ERGOTHERAPY_OBSERVATION3" property="itemId"/>]>.value"/>
	            <input type="hidden" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ERGOTHERAPY_OBSERVATION4" property="itemId"/>]>.value"/>
	            <input type="hidden" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ERGOTHERAPY_OBSERVATION5" property="itemId"/>]>.value"/>
	    	</table>
	    </td>
    </tr>
</table>     
       
<%-- BUTTONS --%>
<table class="list" width="100%" cellspacing="1">
        <tr>
            <td width="16%" class="admin"/>
            <td class="admin2">
                <%=getButtonsHtml(request,activeUser,activePatient,"occup.ergotherapy",sWebLanguage)%>
            </td>
        </tr>
  </table>  

    <%=ScreenHelper.contextFooter(request)%>
</table>
</form>

<script>
  var iIndexPersoonlijk = <%=iTotal%>;
  var sErgotherapy = "<%=sErgotherapy%>";
 
  function submitForm(){
    document.getElementById("buttonsDiv").style.visibility = "hidden";
    var temp = Form.findFirstElement(transactionForm);//for ff compatibility
    while (sErgotherapy.indexOf("rowErgotherapy")>-1){
      sTmpBegin = sErgotherapy.substring(sErgotherapy.indexOf("rowErgotherapy"));
      sTmpEnd = sTmpBegin.substring(sTmpBegin.indexOf("=")+1);
      sErgotherapy = sErgotherapy.substring(0,sErgotherapy.indexOf("rowErgotherapy"))+sTmpEnd;
    }
    document.getElementsByName("currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ERGOTHERAPY_OBSERVATION1" property="itemId"/>]>.value")[0].value = sErgotherapy.substring(0,250);
    document.getElementsByName("currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ERGOTHERAPY_OBSERVATION2" property="itemId"/>]>.value")[0].value = sErgotherapy.substring(250,500);
    document.getElementsByName("currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ERGOTHERAPY_OBSERVATION3" property="itemId"/>]>.value")[0].value = sErgotherapy.substring(500,750);
    document.getElementsByName("currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ERGOTHERAPY_OBSERVATION4" property="itemId"/>]>.value")[0].value = sErgotherapy.substring(750,1000);
    document.getElementsByName("currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ERGOTHERAPY_OBSERVATION5" property="itemId"/>]>.value")[0].value = sErgotherapy.substring(1000,1250);

    document.transactionForm.submit();
  }
  
  function addErgotherapy(){
	  if(isAtLeastOneErgotherapyFieldFilled()){
	      iIndexPersoonlijk ++;
	      sErgotherapy+="rowErgotherapy"+iIndexPersoonlijk+"="+document.getElementById("transactionForm").ErgotherapyDate.value+"£"+document.getElementById("transactionForm").ErgotherapyObservation.value+"£"+document.getElementById("transactionForm").ErgotherapyConclusion.value+"$";
	      var tr = tblErgotherapy.insertRow(tblErgotherapy.rows.length);
	      tr.id = "rowErgotherapy"+iIndexPersoonlijk;
	
	      var td = tr.insertCell(0);
	      td.innerHTML = "<a href='javascript:deleteErgotherapy(rowErgotherapy"+iIndexPersoonlijk+")'><img src='<%=sCONTEXTPATH%>/_img/icons/icon_delete.gif' alt='<%=getTranNoLink("Web.Occup","medwan.common.delete",sWebLanguage)%>' border='0'></a> "
	                    +"<a href='javascript:editErgotherapy(rowErgotherapy"+iIndexPersoonlijk+")'><img src='<%=sCONTEXTPATH%>/_img/icons/icon_edit.gif' alt='<%=getTranNoLink("Web.Occup","medwan.common.edit",sWebLanguage)%>' border='0'></a>";
	      tr.appendChild(td);
	
	      td = tr.insertCell(1);
	      td.innerHTML =  "&nbsp;"+document.getElementById("transactionForm").ErgotherapyDate.value;
	      tr.appendChild(td);
	
	      td = tr.insertCell(2);
	      td.innerHTML =  "&nbsp;"+document.getElementById("transactionForm").ErgotherapyObservation.value;
	      tr.appendChild(td);
	
	      td = tr.insertCell(3);
	      td.innerHTML = "&nbsp;"+document.getElementById("transactionForm").ErgotherapyConclusion.value;
	      tr.appendChild(td);
	
	      // reset
	      clearErgotherapyFields();
	      document.getElementById("transactionForm").ButtonUpdateErgotherapy.disabled = true;
	  }
	}

	function isAtLeastOneErgotherapyFieldFilled(){
	  if(document.getElementById("transactionForm").ErgotherapyDate.value != "") return true;
	  if(document.getElementById("transactionForm").ErgotherapyObservation.value != "") return true;
	  if(document.getElementById("transactionForm").ErgotherapyConclusion.value != "") return true;
	  return false;
	}

	function deleteErgotherapy(rowid){
	  if(yesnoDialog("Web","areYouSureToDelete")){
	    sErgotherapy = deleteRowFromArrayString(sErgotherapy,rowid.id);
	    tblErgotherapy.deleteRow(rowid.rowIndex);
	    clearErgotherapyFields();
	  }
	}

	function editErgotherapy(rowid){
	  var row = getRowFromArrayString(sErgotherapy,rowid.id);

	  document.getElementById("transactionForm").ErgotherapyDate.value = getCelFromRowString(row,0);
	  document.getElementById("transactionForm").ErgotherapyObservation.value = getCelFromRowString(row,1);
	  document.getElementById("transactionForm").ErgotherapyConclusion.value = getCelFromRowString(row,2);

	  editErgotherapyRowid = rowid;
	  document.getElementById("transactionForm").ButtonUpdateErgotherapy.disabled = false;
	}

	function updateErgotherapy(){
	  if(isAtLeastOneErgotherapyFieldFilled()){
	    // update arrayString
	    newRow = editErgotherapyRowid.id+"="
	             +document.getElementById("transactionForm").ErgotherapyDate.value+"£"
	             +document.getElementById("transactionForm").ErgotherapyObservation.value+"£"
	             +document.getElementById("transactionForm").ErgotherapyConclusion.value;

	    sErgotherapy = replaceRowInArrayString(sErgotherapy,newRow,editErgotherapyRowid.id);

	    // update table object
	    var row = tblErgotherapy.rows[editErgotherapyRowid.rowIndex];
	    row.cells[0].innerHTML = "<a href='javascript:deleteErgotherapy("+editErgotherapyRowid.id+")'><img src='<%=sCONTEXTPATH%>/_img/icons/icon_delete.gif' alt='<%=getTranNoLink("Web.Occup","medwan.common.delete",sWebLanguage)%>' border='0'></a> "
	                            +"<a href='javascript:editErgotherapy("+editErgotherapyRowid.id+")'><img src='<%=sCONTEXTPATH%>/_img/icons/icon_edit.gif' alt='<%=getTranNoLink("Web.Occup","medwan.common.edit",sWebLanguage)%>' border='0'></a>";
	    row.cells[1].innerHTML = "&nbsp;"+document.getElementById("transactionForm").ErgotherapyDate.value;
	    row.cells[2].innerHTML = "&nbsp;"+document.getElementById("transactionForm").ErgotherapyObservation.value;
	    row.cells[3].innerHTML = "&nbsp;"+document.getElementById("transactionForm").ErgotherapyConclusion.value;

	    // reset
	    clearErgotherapyFields();
	    document.getElementById("transactionForm").ButtonUpdateErgotherapy.disabled = true;
	  }
	}

	function clearErgotherapyFields(){
	  document.getElementById("transactionForm").ErgotherapyDate.value = "";
	  document.getElementById("transactionForm").ErgotherapyObservation.value = "";
	  document.getElementById("transactionForm").ErgotherapyConclusion.value = "";
	}
	
  function deleteRowFromArrayString(sArray,rowid){
	    var array = sArray.split("$");
	    for (var i=0;i<array.length;i++){
	      if (array[i].indexOf(rowid)>-1){
	        array.splice(i,1);
	      }
	    }
	    return array.join("$");
  }

  function getRowFromArrayString(sArray,rowid){
	    var array = sArray.split("$");
	    var row = "";
	    for (var i=0;i<array.length;i++){
	      if (array[i].indexOf(rowid)>-1){
	        row = array[i].substring(array[i].indexOf("=")+1);
	        break;
	      }
	    }
	    return row;
	  }
  function getCelFromRowString(sRow,celid){
	    var row = sRow.split("£");
	    return row[celid];
	  }

	  function replaceRowInArrayString(sArray,newRow,rowid){
	    var array = sArray.split("$");
	    for (var i=0;i<array.length;i++){
	      if (array[i].indexOf(rowid)>-1){
	        array.splice(i,1,newRow);
	        break;
	      }
	    }
	    return array.join("$");
	  }


</script>
<%=writeJSButtons("transactionForm","saveButton")%>