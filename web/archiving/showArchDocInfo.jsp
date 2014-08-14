<%@page import="be.openclinic.archiving.ArchiveDocument"%>
<%@include file="/includes/validateUser.jsp"%>
<%@page errorPage="/includes/error.jsp"%>

<% 
    String sUDI      = checkString(request.getParameter("UDI")),
    	   sPersonId = checkString(request.getParameter("PersonId"));

    /// DEBUG ///////////////////////////////////////////////////////////////////////////
    if(Debug.enabled){
        Debug.println("\n################ archiving/showArchDocInfo.jsp ###############");
        Debug.println("sUDI      : "+sUDI);
        Debug.println("sPersonId : "+sPersonId+"\n");
    }
    /////////////////////////////////////////////////////////////////////////////////////
    
    //ArchiveDocument doc = ArchiveDocument.get(sUDI);   
    ArchiveDocument doc = ArchiveDocument.getThroughTransactions(sUDI,Integer.parseInt(sPersonId));   
%>

<%=writeTableHeader("web.occup",sPREFIX+"TRANSACTION_TYPE_ARCHIVE_DOCUMENT",sWebLanguage,"javascript:window.close()")%>   
    
<table class="list" width="100%" border="0" cellspacing="1"> 
    <%-- date --%>
    <tr>
        <td width="150" class="admin"><%=getTran("web","date",sWebLanguage)%>&nbsp;</td>
        <td class="admin2"><%=ScreenHelper.stdDateFormat.format(doc.date)%></td>
    </tr>
    
    <%-- UDI --%>
    <tr>
       <td class="admin"><%=getTran("web","udi",sWebLanguage)%>&nbsp;</td>
       <td class="admin2"> 
           <div onClick="printBarcode('<%=sUDI%>');" style="cursor:pointer"><b><font style="background-color:yellow;border:1px solid orange;padding:2px;height:18px;">&nbsp;<%=sUDI%>&nbsp;</font></b></div>
	   </td>
   </tr>

    <%-- title --%>
    <tr>
        <td class="admin"><%=getTran("web","title",sWebLanguage)%>&nbsp;</td>
        <td class="admin2"><%=doc.title%></td>
    </tr>
    
    <%-- description --%>
    <tr>
        <td class="admin"><%=getTran("web","description",sWebLanguage)%>&nbsp;</td>
        <td class="admin2"><%=doc.description.replaceAll("\r\n","<br>")%></td>
    </tr>
       
    <%-- category --%>
    <tr>
        <td class="admin"><%=getTran("web","category",sWebLanguage)%>&nbsp;</td>
        <td class="admin2"><%=doc.category%></td>
    </tr>
    
    <%-- author --%>
    <tr>
        <td class="admin"><%=getTran("web","author",sWebLanguage)%>&nbsp;</td>
        <td class="admin2"><%=doc.author%></td>
    </tr>
    
    <%-- destination --%>
    <tr>
        <td class="admin"><%=getTran("web","destination",sWebLanguage)%>&nbsp;</td>
        <td class="admin2"><%=doc.destination%></td>
    </tr>
    
    <%-- reference --%>
    <tr>
        <td class="admin"><%=getTran("web","paperReference",sWebLanguage)%>&nbsp;</td>
        <td class="admin2"><%=doc.reference%></td>
    </tr>
    
    <%-- storage-name --%>
    <tr>
        <td class="admin"><%=getTran("web","storageName",sWebLanguage)%>&nbsp;</td>
        <td class="admin2">
        <%
	        if(doc.storageName.length()==0){
	            %><%=getTranNoLink("web.occup","documentIsBeingProcessed",sWebLanguage)%><%
	        }
	        else{
	            // show link to open document, when server is configured
	         	String sServer = MedwanQuery.getInstance().getConfigString("archiveDocumentStorageRoot");
	         	if(sServer.length() > 0){
	                %><a href="<%=sServer+"/"+doc.storageName%>" target="_new"><%=doc.storageName%></a><%
	            }
	            else{
	                %><%=doc.storageName%><%
	            }
	        }
	    %> 
	    </td>
    </tr>
</table>

<%-- BUTTONS --%>
<%=ScreenHelper.alignButtonsStart()%>
    <input class="button" type="button" name="closeButton" id="closeButton" value="<%=getTranNoLink("web","close",sWebLanguage)%>" onclick="window.close();">
<%=ScreenHelper.alignButtonsStop()%>

<script>
  <%-- PRINT BARCODE --%>
  function printBarcode(udi){
    var url = "<%=sCONTEXTPATH%>/archiving/printBarcode.jsp?barcodeValue="+udi+"&numberOfPrints=2";
	var w = 550;
    var h = 760;
    var left = (screen.width/2)-(w/2);
    var topp = (screen.height/2)-(h/2);
    window.open(url,"PrintBarcode<%=new java.util.Date().getTime()%>","toolbar=no,status=no,scrollbars=yes,resizable=yes,menubar=no,width="+w+",height="+h+",top="+topp+",left="+left);
  }
</script>