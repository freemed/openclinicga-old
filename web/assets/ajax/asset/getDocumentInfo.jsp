<%@page import="be.mxs.common.util.system.HTMLEntities,
                be.openclinic.archiving.ArchiveDocument,
                java.util.*,
                java.io.*"%>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>
       
<%
    String sDocumentId = checkString(request.getParameter("DocumentId"));
	
	/// DEBUG /////////////////////////////////////////////////////////////////////////////////////
	if(Debug.enabled){
	    Debug.println("\n***************** assets/ajax:asset/getDocumentInfo.jsp ****************");
        Debug.println("sDocumentId   : "+sDocumentId+"\n");
    }
    ///////////////////////////////////////////////////////////////////////////////////////////////
   
    ArchiveDocument docu = ArchiveDocument.get(sDocumentId);
    if(docu!=null){
        if(Debug.enabled){
            Debug.println("docu.author       : "+docu.author);
            Debug.println("docu.category     : "+docu.category);
            Debug.println("docu.description  : "+docu.description);
            Debug.println("docu.destination  : "+docu.destination);
            Debug.println("docu.personId     : "+docu.personId);
            Debug.println("docu.reference    : "+docu.reference);
            Debug.println("docu.storageName  : "+docu.storageName);
            Debug.println("docu.title        : "+docu.title);
            Debug.println("docu.tranServerId : "+docu.tranServerId);
            Debug.println("docu.tranTranId   : "+docu.tranTranId);
            Debug.println("docu.udi          : "+docu.udi);
            Debug.println("docu.date         : "+ScreenHelper.stdDateFormat.format(docu.date));
            Debug.println("docu.deleteDate   : "+ScreenHelper.stdDateFormat.format(docu.deleteDate)+"\n");
        }
        
        // check wether the referred document exists as a file
        File docuFile = new File(docu.storageName);
        boolean documentExistsAsFile = (docuFile.exists() && !docuFile.isDirectory());
        
        if(documentExistsAsFile){
            // 1 : all is right
            %>
{
  "message":"ok",
  "documentUdi":"<%=HTMLEntities.htmlentities(docu.udi)%>",
  "documentFilename":"<%=HTMLEntities.htmlentities(docu.storageName)%>",
  "documentDate":"<%=HTMLEntities.htmlentities(ScreenHelper.stdDateFormat.format(docu.date))%>",
  "documentAuthor":"<%=HTMLEntities.htmlentities(docu.author)%>"
}
            <%
        }
        else{
            // 2 : not found as file
            String sMessage = "<font color='red'>"+getTranNoLink("web","fileNotFound",sWebLanguage)+" : "+docu.storageName+"</font>";
            
            %>
{
  "message":"<%=HTMLEntities.htmlentities(sMessage)%>",
  "documentUdi":"<%=HTMLEntities.htmlentities(docu.udi)%>",
  "documentFilename":"<%=HTMLEntities.htmlentities(docu.storageName)%>",
  "documentDate":"<%=HTMLEntities.htmlentities(ScreenHelper.stdDateFormat.format(docu.date))%>",
  "documentAuthor":"<%=HTMLEntities.htmlentities(docu.author)%>"
}
            <%
        }
    }
    else{
        // 3 : not found in database
        String sMessage = "<font color='red'>"+getTranNoLink("web","documentNotFound",sWebLanguage)+"</font>";
        
        %>
{
  "message":"<%=HTMLEntities.htmlentities(sMessage)%>",
  "documentUdi":"",
  "documentFilename":"",
  "documentDate":"",
  "documentAuthor":""
}
        <%
    }
%>    