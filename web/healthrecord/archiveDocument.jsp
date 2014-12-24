<%@page import="be.openclinic.system.Screen"%>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>
<%=checkPermission("occup.arch.documents","select",activeUser)%>

<form name="transactionForm" id="transactionForm" method="POST" action="<c:url value='/healthrecord/updateTransaction.do'/>?ts=<%=getTs()%>" focus='type'>
    <bean:define id="transaction" name="be.mxs.webapp.wl.session.SessionContainerFactory.WO_SESSION_CONTAINER" property="currentTransactionVO"/>
	<%=checkPrestationToday(activePatient.personid,false,activeUser,(TransactionVO)transaction)%>

    <input type="hidden" id="transactionId" name="currentTransactionVO.<TransactionVO[hashCode=<bean:write name="transaction" scope="page" property="transactionId"/>]>.transactionId" value="<bean:write name="transaction" scope="page" property="transactionId"/>"/>
    <input type="hidden" id="transactionType" name="currentTransactionVO.<TransactionVO[hashCode=<bean:write name="transaction" scope="page" property="transactionId"/>]>.transactionType" value="<bean:write name="transaction" scope="page" property="transactionType"/>"/>
    <input type="hidden" id="serverId" name="currentTransactionVO.<TransactionVO[hashCode=<bean:write name="transaction" scope="page" property="transactionId"/>]>.serverId" value="<bean:write name="transaction" scope="page" property="serverId"/>"/>
    <input type="hidden" readonly name="be.mxs.healthrecord.updateTransaction.actionForwardKey" value="/main.do?Page=curative/index.jsp?ts=<%=getTs()%>"/>
   
    <%=writeTableHeader("web.occup",sPREFIX+"TRANSACTION_TYPE_ARCHIVE_DOCUMENT",sWebLanguage,sCONTEXTPATH+"/main.do?Page=healthrecord/index.jsp&ts="+getTs())%>   
    <%=writeHistoryFunctions(((TransactionVO)transaction).getTransactionType(),sWebLanguage)%>
    <% TransactionVO tran = (TransactionVO)transaction; %>
    
    <table class="list" width="100%" cellspacing="1"> 
        <% String sDocUID = tran.getItemValue(ScreenHelper.ITEM_PREFIX+"ITEM_TYPE_DOC_UID"); %>
        <input type="hidden" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DOC_UID" property="itemId"/>]>.value" value="<%=sDocUID%>">
        <input type="hidden" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DOC_PERSONID" property="itemId"/>]>.value" value="<%=activePatient.personid%>">              
                
        <%-- date --%>
        <tr>
            <td class="admin">
                <a href="javascript:openHistoryPopup();" title="<%=getTranNoLink("web.occup","history",sWebLanguage)%>">...</a>&nbsp;<%=getTran("web.occup","medwan.common.date",sWebLanguage)%>&nbsp;*&nbsp;
            </td>
            <td class="admin2">
                <input type="text" class="text" size="12" maxLength="10" value="<mxs:propertyAccessorI18N name="transaction" scope="page" property="updateTime" formatType="date"/>" name="currentTransactionVO.<TransactionVO[hashCode=<bean:write name="transaction" scope="page" property="transactionId"/>]>.updateTime" id="trandate" OnBlur="checkDate(this);">
                <script>writeTranDate();</script>
            </td>
        </tr>
        
        <%-- UDI (read-only) --%>
        <%
            if(!tran.isNew()){
                %>
			        <tr>
			            <td width="<%=sTDAdminWidth%>" class="admin"><%=getTran("web","udi",sWebLanguage)%>&nbsp;</td>
			            <td class="admin2">
			                <% String sUDI = tran.getItemValue(ScreenHelper.ITEM_PREFIX+"ITEM_TYPE_DOC_UDI"); %>   
			                <input type="hidden" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DOC_UDI" property="itemId"/>]>.value" value="<%=sUDI%>">              
			                <span onClick="printBarcode('<%=sUDI%>');" class="hand"><b><font style="background-color:yellow;border:1px solid orange;padding:2px;height:18px;">&nbsp;<%=sUDI%>&nbsp;</font></b></span>
			            </td>
			        </tr>
			    <%
            }
        %>
        
        <%-- title --%>
        <tr>
            <td class="admin"><%=getTran("web","title",sWebLanguage)%>&nbsp;*&nbsp;</td>
            <td class="admin2">
                <input type="text" class="text" id="title" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DOC_TITLE" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DOC_TITLE" property="value"/>" size="50" maxLenght="255">
            </td>
        </tr>
        
        <%-- description --%>
        <tr>
            <td class="admin"><%=getTran("web","description",sWebLanguage)%>&nbsp;</td>
            <td class="admin2">
                <textarea onKeyup="resizeTextarea(this,10);limitChars(this,255);" class="text" cols="80" rows="2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DOC_DESCRIPTION" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DOC_DESCRIPTION" property="value"/></textarea>
            </td>
        </tr>
			        
        <%-- category --%>
        <tr>
            <td class="admin"><%=getTran("web","category",sWebLanguage)%>&nbsp;</td>
            <td class="admin2">
                <select class="text" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DOC_CATEGORY" property="itemId"/>]>.value" id="category">
                    <option/>
                    <%=ScreenHelper.writeSelect("arch.doc.category",tran.getItemValue(ScreenHelper.ITEM_PREFIX+"ITEM_TYPE_DOC_CATEGORY"),sWebLanguage)%>
                </select>
            </td>
        </tr>
        
        <%-- author --%>
        <tr>
            <td class="admin"><%=getTran("web","author",sWebLanguage)%>&nbsp;</td>
            <td class="admin2">
                <input type="text" class="text" id="author" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DOC_AUTHOR" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DOC_AUTHOR" property="value"/>" size="50" maxLenght="255">
            </td>
        </tr>
        
        <%-- destination --%>
        <tr>
            <td class="admin"><%=getTran("web","destination",sWebLanguage)%>&nbsp;</td>
            <td class="admin2">
                <input type="text" class="text" id="destination" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DOC_DESTINATION" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DOC_DESTINATION" property="value"/>" size="50" maxLenght="255">
            </td>
        </tr>
        
        <%-- reference --%>
        <tr>
            <td class="admin"><%=getTran("web","paperReference",sWebLanguage)%>&nbsp;</td>
            <td class="admin2">
                <input type="text" class="text" id="reference" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DOC_REFERENCE" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DOC_REFERENCE" property="value"/>" size="50" maxLenght="50">
            </td>
        </tr>
        
        <%-- storage-name (read-only) --%>
        <%
            if(!tran.isNew()){
                %>
			        <tr>
			            <td class="admin"><%=getTran("web","storageName",sWebLanguage)%>&nbsp;</td>
			            <td class="admin2">
			                <% String sStorageName = tran.getItemValue(ScreenHelper.ITEM_PREFIX+"ITEM_TYPE_DOC_STORAGENAME"); %>   
			                <input type="hidden" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DOC_STORAGENAME" property="itemId"/>]>.value" value="<%=sStorageName%>">
			                <%
			                    if(sStorageName.length()==0){
			                        %><%=getTranNoLink("web.occup","documentIsBeingProcessed",sWebLanguage)%><%
			                    }
			                    else{
			                    	// show link to open document, when server is configured
			                    	String sServer = MedwanQuery.getInstance().getConfigString("scanDirectoryMonitor_url","http://localhost/openclinic/scan")+"/"+
			                    	                 MedwanQuery.getInstance().getConfigString("scanDirectoryMonitor_dirTo","to");
			                    	if(sServer.length() > 0){
			                            %><a href="<%=sServer+"/"+sStorageName%>" target="_new"><%=sStorageName%></a><%
			                        }
			                        else{
			                            %><%=sStorageName%><%
			                        }
			                    }
			                %>              
			            </td>
			        </tr>
			    <%
			}
	    %>
    </table>
    &nbsp;<%=getTran("web","asterisk_fields_are_obligate",sWebLanguage)%>

	<%-- BUTTONS --%>
	<%=ScreenHelper.alignButtonsStart()%>
	    <%=getButtonsHtml(request,activeUser,activePatient,"occup.arch.documents",sWebLanguage,false)%>
	<%=ScreenHelper.alignButtonsStop()%>
</form>

<script>  
  document.getElementById("title").focus();
  
  <%-- SUBMIT FORM --%>
  function submitForm(){
	if(formComplete()){
	  transactionForm.saveButton.disabled = true; 
  	  transactionForm.backButton.disabled = true;
	
      <%
          SessionContainerWO sessionContainerWO = (SessionContainerWO)SessionContainerFactory.getInstance().getSessionContainerWO(request,SessionContainerWO.class.getName());
          out.print(takeOverTransaction(sessionContainerWO, activeUser,"document.transactionForm.submit();"));
      %>
	}
	else{
	            window.showModalDialog?alertDialog("web.manage","dataMissing"):alertDialogDirectText('<%=getTran("web.manage","dataMissing",sWebLanguage)%>');	
	  
	       if(document.getElementById("trandate").value.length==0) document.getElementById("trandate").focus();
      else if(document.getElementById("title").value.length==0) document.getElementById("title").focus();
	}
  }
  
  <%-- FORM COMPLETE --%>
  function formComplete(){
	return (document.getElementById("trandate").value.length>0 &&
			document.getElementById("title").value.length>0);
  }
  
  <%-- PRINT BARCODE --%>
  function printBarcode(udi){
	var url = "<%=sCONTEXTPATH%>/archiving/printBarcode.jsp?barcodeValue="+udi+"&numberOfPrints=1";
	var w = 430;
    var h = 200;
    var left = (screen.width/2)-(w/2);
    var topp = (screen.height/2)-(h/2);
    window.open(url,"PrintBarcode<%=getTs()%>","toolbar=no,status=no,scrollbars=yes,resizable=yes,menubar=yes,width="+w+",height="+h+",top="+topp+",left="+left);
  }
</script>

<%=writeJSButtons("transactionForm","saveButton")%>