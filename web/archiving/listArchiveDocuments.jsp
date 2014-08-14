<%@page import="be.openclinic.archiving.ArchiveDocument"%>
<%@include file="/includes/validateUser.jsp"%>
<%@page errorPage="/includes/error.jsp"%>

<%=checkPermission("archiving.listArchiveDocuments","select",activeUser)%>
<%=sJSSORTTABLE%>

<%!
    //--- OBJECTS TO HTML -------------------------------------------------------------------------
    private StringBuffer objectsToHtml(Vector objects, String sWebLanguage, User activeUser){
        StringBuffer html = new StringBuffer();
        String sClass = "";

        // frequently used translations
        String sInfoTran = getTranNoLink("web","info",sWebLanguage),
               sViewTran = getTranNoLink("web","view",sWebLanguage);
        
        // run thru found documents
        ArchiveDocument doc;        
        for(int i=0; i<objects.size(); i++){
        	doc = (ArchiveDocument)objects.get(i);

            // alternate row-style
            if(sClass.length()==0) sClass = "1";
            else                   sClass = "";
            
            //*** display stock in one row ***
            html.append("<tr class='list"+sClass+"'>");
            
            html.append("<td>"+ScreenHelper.stdDateFormat.format(doc.date)+"</td>")
                .append("<td><a href='javascript:void(0);' onClick=\"openArchiveDocumentTran('"+doc.tranServerId+"','"+doc.tranTranId+"');\">"+doc.title+"</a></td>")
                .append("<td>"+getTran("arch.doc.category",doc.category,sWebLanguage)+"</td>")
                .append("<td>"+doc.author+"</td>");
            
            // buttons
            html.append("<td>")
                 .append("<input type='button' class='button' value='"+sInfoTran+"' onclick=\"showDocInfo('"+doc.udi+"','"+doc.personId+"');\">&nbsp;");
            
            if(doc.storageName.length() > 0){
                html.append("<input type='button' class='button' value='"+sViewTran+"' onclick=\"openDoc('"+doc.storageName+"');\">");
            }
            else{
            	html.append(getTranNoLink("web.occup","documentIsBeingProcessed",sWebLanguage));
            }
            
            html.append("</td>")	            
                .append("</tr>");
        }

        return html;
    }
%>

<%
    String sAction = checkString(request.getParameter("Action"));

    String sFindTitle    = checkString(request.getParameter("FindTitle")),
           sFindCategory = checkString(request.getParameter("FindCategory")),
           sFindBegin    = checkString(request.getParameter("FindBegin")),
           sFindEnd      = checkString(request.getParameter("FindEnd"));

    /// DEBUG ///////////////////////////////////////////////////////////////////////////
    if(Debug.enabled){
        Debug.println("\n############## archiving/listArchiveDocuments.jsp ############");
        Debug.println("sAction       : "+sAction);
        Debug.println("sFindTitle    : "+sFindTitle);
        Debug.println("sFindCategory : "+sFindCategory);
        Debug.println("sFindBegin    : "+sFindBegin);
        Debug.println("sFindEnd      : "+sFindEnd+"\n");
    }
    /////////////////////////////////////////////////////////////////////////////////////
    
    StringBuffer sHTML = new StringBuffer();
    int foundDocsCount = 0;
    String msg = "";

    if(sAction.length()==0) sAction = "findLast";

    //--- FIND ------------------------------------------------------------------------------------
    if(sAction.equals("find")){
        Vector archDocs = ArchiveDocument.find(Integer.parseInt(activePatient.personid),
        		                               sFindTitle,sFindCategory,sFindBegin,sFindEnd);
        sHTML = objectsToHtml(archDocs,sWebLanguage,activeUser);
        foundDocsCount = archDocs.size();
    }
    //--- FIND LAST -------------------------------------------------------------------------------
    else if(sAction.equals("findLast")){
    	int maxDocs = MedwanQuery.getInstance().getConfigInt("RecentArchiveDocumentDisplayCount",50);
        Vector archDocs = ArchiveDocument.getMostRecentDocuments(maxDocs,Integer.parseInt(activePatient.personid));
        sHTML = objectsToHtml(archDocs,sWebLanguage,activeUser);
        foundDocsCount = archDocs.size();
        
        if(foundDocsCount>maxDocs){
	        msg = getTranNoLink("web","showingOnlyXRecords",sWebLanguage);
	        msg = msg.replaceAll("#shownRecords#",Integer.toString(foundDocsCount));
	        msg = msg.replaceAll("#totalRecords#",Integer.toString(maxDocs));
        }
        else{
        	msg = foundDocsCount+" "+getTran("web","recordsFound",sWebLanguage);
        }
    }
%>

<form name="transactionForm" id="transactionForm" method="post">
    <%=writeTableHeader("web.archiving","listArchiveDocuments",sWebLanguage," doBack();")%>
    <input type="hidden" name="Action" value="findLast">

    <table width="100%" class="list" cellspacing="1" onKeyDown="if(checkKey13(event)){doSearch();}">
        <%-- find title --%>
        <tr>
            <td class="admin" width="<%=sTDAdminWidth%>" nowrap><%=getTran("web","title",sWebLanguage)%>&nbsp;</td>
            <td class="admin2">
                <input type="text" class="text" name="FindTitle" size="50" maxLength="255" value="<%=sFindTitle%>">
            </td>
        </tr>
			        
        <%-- find category --%>
        <tr>
            <td class="admin" nowrap><%=getTran("web","category",sWebLanguage)%>&nbsp;</td>
            <td class="admin2">
                <select class="text" name="FindCategory">
                    <option/>
                    <%=ScreenHelper.writeSelect("arch.doc.category",sFindCategory,sWebLanguage)%>
                </select>
            </td>
        </tr>
        
        <%-- find begin --%>
        <tr>
            <td class="admin" nowrap><%=getTran("web","begindate",sWebLanguage)%>&nbsp;</td>
            <td class="admin2"><%=writeDateField("FindBegin","transactionForm",sFindBegin,sWebLanguage)%></td>
        </tr>
        
        <%-- find end --%>
        <tr>
            <td class="admin" nowrap><%=getTran("web","enddate",sWebLanguage)%>&nbsp;</td>
            <td class="admin2"><%=writeDateField("FindEnd","transactionForm",sFindEnd,sWebLanguage)%></td>
        </tr>
        
        <%-- BUTTONS --%>
        <tr>
            <td class="admin"/>
            <td class="admin2">
                <input type="button" class="button" name="searchButton" value="<%=getTranNoLink("web","search",sWebLanguage)%>" onclick="doSearch();">
                <input type="button" class="button" name="clearButton" value="<%=getTranNoLink("web","clear",sWebLanguage)%>" onclick="clearSearchFields();">&nbsp;
                <input type="button" class="button" name="backButton" value="<%=getTranNoLink("web","back",sWebLanguage)%>" onclick="doBack();">
            </td>
        </tr>
    </table>
    <br>

    <%
        //--- SEARCH RESULTS ----------------------------------------------------------------------
        if(foundDocsCount > 0){
            %>
                <table width="100%" cellspacing="0" cellpadding="0" class="sortable" id="searchresults">
                    <tr class="admin">
                        <td width="100"><%=getTran("web","date",sWebLanguage)%></td>
                        <td width="300"><%=getTran("web","title",sWebLanguage)%></td>
                        <td width="150"><%=getTran("web","category",sWebLanguage)%></td>
                        <td width="200"><%=getTran("web","author",sWebLanguage)%></td>
                        <td width="*"/>
                    </tr>
                    <%=sHTML%>
                </table>
                
                <%-- number of records found --%>
                <span style="width:49%;text-align:left;">
                    <%=msg%>
                </span>
                
                <%
                    if(foundDocsCount > 20){
                        // link to top of page
                        %>
                            <span style="width:51%;text-align:right;">
                                <a href="#topp" class="topbutton">&nbsp;</a>
                            </span>
                            <br>
                        <%
                    }
                %>
            <%
        }
        else{
            // no records found
            %><%=getTran("web","norecordsfound",sWebLanguage)%><br><br><%
        }
    %>    
</form>
    
<%-- CLOSE-BUTTON --%> 
<%=ScreenHelper.alignButtonsStart()%>
    <input type="button" class="button" name="backButton" value="<%=getTranNoLink("web","back",sWebLanguage)%>" onclick="doBack();">
<%=ScreenHelper.alignButtonsStop()%>

<script>
  transactionForm.FindTitle.focus();

  <%-- DO SEARCH --%>
  function doSearch(){
    if(fieldsComplete()){
      transactionForm.searchButton.disabled = true;
      transactionForm.clearButton.disabled = true;
      transactionForm.backButton.disabled = true;
      
      transactionForm.Action.value = "find";
      transactionForm.submit();
    }
    else{
      alertDialog("web.manage","dataMissing"); 	
    	
      if(transactionForm.FindTitle.value.length==0){
        transactionForm.FindTitle.focus();
      }
      else if(transactionForm.FindCategory.selectedIndex==0){
        transactionForm.FindCategory.focus();
      }
      else if(transactionForm.FindBegin.value.length==0){
        transactionForm.FindBegin.focus();
      }
      else if(transactionForm.FindEnd.value.length==0){
        transactionForm.FindEnd.focus();
      }
    }
  }
  
  <%-- FIELDS COMPLETE --%>
  function fieldsComplete(){
    if(transactionForm.FindTitle.value.length > 0 ||
       transactionForm.FindCategory.selectedIndex > 0 ||
       transactionForm.FindBegin.value.length > 0 ||
       transactionForm.FindEnd.value.length > 0){
    	return true;
    }
    return false;
  }

  <%-- CLEAR SEARCH FIELDS --%>
  function clearSearchFields(){
    transactionForm.FindTitle.value = "";
    transactionForm.FindCategory.selectedIndex = 0;
    transactionForm.FindBegin.value = "";
    transactionForm.FindEnd.value = "";
  }

  <%-- SHOW DOC INFO --%>
  function showDocInfo(udi,personId){
	var url = "<c:url value='popup.jsp'/>?Page=archiving/showArchDocInfo.jsp&UDI="+udi+"&PersonId="+personId+"&ts=<%=getTs()%>";
    window.open(url,"ArchiveDocumentInfo"+new Date().getTime(),"toolbar=no,status=yes,scrollbars=yes,resizable=yes,width=500,height=350,menubar=no").moveTo((screen.width-800)/2,(screen.height-600)/2);
  }
  
  <%-- OPEN DOC --%>
  function openDoc(filePathAndName){
    var url = "<%=MedwanQuery.getInstance().getConfigString("archiveDocumentStorageRoot")%>/"+filePathAndName+"?ts=<%=getTs()%>";
    var w = 900;
    var h = 600;
    var left = (screen.width/2)-(w/2);
    var topp = (screen.height/2)-(h/2);
    window.open(url,"ArchiveDocument<%=new java.util.Date().getTime()%>","toolbar=no,status=no,scrollbars=yes,resizable=yes,menubar=no,width="+w+",height="+h+",top="+topp+",left="+left);
  }
  
  <%-- OPEN ARCHIVE DOCUMENT TRANsaction --%>
  function openArchiveDocumentTran(serverId,tranId){
    var url = "<%=sCONTEXTPATH%>/healthrecord/editTransaction.do"+
              "?be.mxs.healthrecord.createTransaction.transactionType=<%=ScreenHelper.ITEM_PREFIX+"TRANSACTION_TYPE_ARCHIVE_DOCUMENT"%>"+
              "&be.mxs.healthrecord.transaction_id="+tranId+
              "&be.mxs.healthrecord.server_id="+serverId+
              "&ts=<%=getTs()%>";
	window.location.href = url;
  }

  <%-- DO BACK --%>
  function doBack(){
	window.location.href = "<c:url value='/main.do'/>?Page=archiving/index.jsp";
  }
  
  <%-- CHECK KEY 13 --%>
  function checkKey13(evt){
    evt = evt || window.event;
    var kcode = evt.keyCode || evt.which;
    if(kcode && kcode==13){
      return true;
    }
    else{
      return false;
    }
  }
</script>