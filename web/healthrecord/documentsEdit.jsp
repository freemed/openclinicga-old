<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>
<%=checkPermission("occup.documents","select",activeUser)%>
<%=sJSPROTOTYPE%>

<form name="transactionForm" id="transactionForm" method="POST" action="<c:url value="/healthrecord/updateTransaction.do"/>?ts=<%=getTs()%>" onclick="setSaveButton(event);" onkeyup="setSaveButton(event);">
    <bean:define id="transaction" name="be.mxs.webapp.wl.session.SessionContainerFactory.WO_SESSION_CONTAINER" property="currentTransactionVO"/>
	<%=checkPrestationToday(activePatient.personid,false,activeUser,(TransactionVO)transaction) %>
   
    <input type="hidden" id="transactionId" name="currentTransactionVO.<TransactionVO[hashCode=<bean:write name="transaction" scope="page" property="transactionId"/>]>.transactionId" value="<bean:write name="transaction" scope="page" property="transactionId"/>"/>
    <input type="hidden" id="serverId" name="currentTransactionVO.<TransactionVO[hashCode=<bean:write name="transaction" scope="page" property="transactionId"/>]>.serverId" value="<bean:write name="transaction" scope="page" property="serverId"/>"/>
    <input type="hidden" id="transactionType" name="currentTransactionVO.<TransactionVO[hashCode=<bean:write name="transaction" scope="page" property="transactionId"/>]>.transactionType" value="<bean:write name="transaction" scope="page" property="transactionType"/>"/>
    <input type="hidden" readonly name="be.mxs.healthrecord.updateTransaction.actionForwardKey" value="/main.do?Page=curative/index.jsp&ts=<%=getTs()%>"/>
    <input type="hidden" readonly name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_RECRUITMENT_CONVOCATION_ID" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_RECRUITMENT_CONVOCATION_ID" property="value"/>"/>
    <input type="hidden" readonly name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CONTEXT_DEPARTMENT" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CONTEXT_DEPARTMENT" translate="false" property="value"/>"/>
    <input type="hidden" readonly name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CONTEXT_CONTEXT" translate="false" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CONTEXT_CONTEXT" translate="false" property="value"/>"/>

    <%=contextHeader(request,sWebLanguage)%>
    
    <table width="100%" cellspacing="1" class="list">
        <%-- DATE --%>
        <tr>
            <td class="admin" width="<%=sTDAdminWidth%>">
                <a href="javascript:openHistoryPopup();" title="<%=getTranNoLink("Web.Occup","History",sWebLanguage)%>">...</a>&nbsp;
                <%=getTran("Web.Occup","medwan.common.date",sWebLanguage)%>
            </td>
            <td class="admin2">
                <input type="text" class="text" size="12" maxLength="10" value="<mxs:propertyAccessorI18N name="transaction" scope="page" property="updateTime" formatType="date"/>" name="currentTransactionVO.<TransactionVO[hashCode=<bean:write name="transaction" scope="page" property="transactionId"/>]>.updateTime" id="trandate" OnBlur="checkDate(this);">
                <script>writeTranDate();</script>
            </td>
        </tr>
        
        <%-- TITLE --%>
        <tr>
            <td class="admin"><%=getTran("web","title",sWebLanguage)%></td>
            <td class="admin2">
                <input type="text" class="text" size="60" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_EXTERNAL_DOCUMENT_TITLE" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_EXTERNAL_DOCUMENT_TITLE" property="value"/>">
            </td>
        </tr>
        
        <%-- DOCUMENTS --%>
        <tr>
            <td class="admin"><%=getTran("web","documents",sWebLanguage)%></td>
            <td class="admin2">
                <div id="divDocuments">
	                <%
	                    TransactionVO tran = (TransactionVO)transaction;
	                    String sDocuments = getItemType(tran.getItems(),sPREFIX+"ITEM_TYPE_EXTERNAL_DOCUMENT_DOCUMENTS");
	                    Debug.println("sDocuments : "+sDocuments);
	
	                    String[] aDocuments = sDocuments.split(";");
	
	                    for(int i=0;i<aDocuments.length;i++){
	                        if(checkString(aDocuments[i]).length()>0){
	                            %><a href="#" onclick="openDocument('<%=aDocuments[i]%>')"><%=be.openclinic.healthrecord.Document.getName(aDocuments[i])%></a><br><%
	                        }
	                    }
	                %>
                </div>
            </td>
        </tr>
        
        <%-- BUTTONS --%>
        <tr>
            <td class="admin"/>
            <td class="admin2">
                <%
                    if((activeUser.getAccessRight("occup.documents.add") || activeUser.getAccessRight("occup.documents.edit"))){
                        %><input class="button" type="button" name="buttonSave" value="<%=getTran("Web.Occup","medwan.common.record",sWebLanguage)%>" onclick="submitForm()"/><%
                    }
                %>
                <input class="button" type="button" value="<%=getTran("Web","back",sWebLanguage)%>" onclick="if(checkSaveButton()){doBack();}">
            </td>
        </tr>
    </table>
    
    <%=getTran("Web","colored_fields_are_obligate",sWebLanguage)%>
    
    <input type="hidden" id="EditDocument" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_EXTERNAL_DOCUMENT_DOCUMENTS" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_EXTERNAL_DOCUMENT_DOCUMENTS" property="value"/>">
    <%=ScreenHelper.contextFooter(request)%>
</form>

<%-- UPLOAD FORM --%>
<form target="_newForm" name="uploadForm" action="<c:url value='/healthrecord/documentUpload.jsp'/>" method="post" enctype="multipart/form-data">
    <%=writeTableHeader("Web","upload_file",sWebLanguage," doBack();")%>
    
    <table class="list" width="100%" cellspacing="1">
        <tr>
            <td class="admin" width="<%=sTDAdminWidth%>"><%=getTran("web","doc_upload",sWebLanguage)%></td>
            <td class="admin2">
                <input class='text' name="filename" type="file" title="" size='<%=sTextWidth%>' onchange="uploadFile()"/>
            </td>
        </tr>
    </table>
</form>

<div id="divMessage"></div>

<script>
  function uploadFile(){
    if(uploadForm.filename.value.length>0){
      uploadForm.submit();
    }
  }

  function closeNewForm(){
    window._newForm.close();
  }
  
  function submitForm(){
    document.transactionForm.buttonSave.style.visibility = "hidden";
    <%
        SessionContainerWO sessionContainerWO = (SessionContainerWO)SessionContainerFactory.getInstance().getSessionContainerWO(request,SessionContainerWO.class.getName());
        out.print(takeOverTransaction(sessionContainerWO, activeUser,"document.transactionForm.submit();"));
    %>
  }

  function doBack(){
    window.location.href = '<%=sCONTEXTPATH%>/main.do?Page=curative/index.jsp&ts=<%=getTs()%>';
  }

  <%-- OPEN DOCUMENT --%>
  function openDocument(sId){
    var url = '<c:url value="/_common/search/viewDocument.jsp"/>?ts='+new Date();

    new Ajax.Request(url,{
      method: "POST",
      postBody: 'documentId='+sId,
      onSuccess: function(resp){
        var file = eval('('+resp.responseText+')');
        window.open("<c:url value="/"/><%=MedwanQuery.getInstance().getConfigString("tempdir","/documents/")%>"+file.Filename);
      },
      onFailure: function(resp){
        $('divMessage').innerHTML = "Error in function openDocument() => "+resp.responseText;
      }
    });
  }
</script>

<%=writeJSButtons("transactionForm","saveButton")%>