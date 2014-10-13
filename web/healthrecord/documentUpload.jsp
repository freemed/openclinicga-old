<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>
<%@page import="java.util.Hashtable,
                javazoom.upload.UploadFile,
                javazoom.upload.MultipartFormDataRequest"%>
                
<jsp:useBean id="upBean" scope="page" class="javazoom.upload.UploadBean">
    <jsp:setProperty name="upBean" property="folderstore" value='<%=MedwanQuery.getInstance().getConfigString("tempDirectory","/tmp")%>'/>
    <jsp:setProperty name="upBean" property="parsertmpdir" value='<%=MedwanQuery.getInstance().getConfigString("tempDirectory","/tmp")%>'/>
    <jsp:setProperty name="upBean" property="parser" value="<%=MultipartFormDataRequest.CFUPARSER%>"/>
</jsp:useBean>

<%
    String sFolderStore = application.getRealPath("/") + MedwanQuery.getInstance().getConfigString("tempdir","/documents/");
    Debug.println("sFolderStore : "+sFolderStore);
    String sDocumentId = "";

    String sFileName = "";
    if(MultipartFormDataRequest.isMultipartFormData(request)){
        // Uses MultipartFormDataRequest to parse the HTTP request
        MultipartFormDataRequest mrequest = new MultipartFormDataRequest(request);
        try{
            Hashtable files = mrequest.getFiles();
            if(files!=null && !files.isEmpty()){
                UploadFile file = (UploadFile) files.get("filename");
                
                sFileName = file.getFileName();
                file.setFileName(sFileName);
                Debug.println("sFileName : "+sFileName);
                Debug.println("--> fileSize : "+file.getFileSize()+" bytes"); 
                
                upBean.setFolderstore(sFolderStore);
                upBean.setParsertmpdir(application.getRealPath("/")+"/"+MedwanQuery.getInstance().getConfigString("tempdir","/tmp/"));
                upBean.store(mrequest, "filename");

                sDocumentId = be.openclinic.healthrecord.Document.store(sFileName,activeUser.userid,file.getData());
                Debug.println("--> sDocumentId : "+sDocumentId); 
            }
        }
        catch(Exception e){
        	Debug.printStackTrace(e);
        }
    }
%>
<script>
  <%
      if(sDocumentId.startsWith("ERR_")){
	      %>window.opener.document.getElementById("divMessage").innerHTML = "<font color='red'><%=sDocumentId.substring(4)%></font>";<%
      }
      else{
          %>
    	    window.opener.document.getElementById('divDocuments').innerHTML += "<img src='<%=sCONTEXTPATH%>/_img/icons/icon_delete.gif' class='link' onClick='deleteDoc(\"<%=sDocumentId%>\");'>&nbsp;"+
    	                                                                       "<a href='javascript:openDocument(\"<%=sDocumentId%>\");'><%=sFileName%></a><br>";
    	    window.opener.document.getElementById('EditDocument').value += "<%=sDocumentId%>;";
    	    window.opener.addDocName("<%=sFileName%>");
	      <%
      }
  %>
  var ie7 = (document.all && !window.opera && window.XMLHttpRequest) ? true : false;
  if(ie7){     
    // required to close window without prompt for IE7
    window.open('','_parent','');
    window.close();
  }
  else{
    // required to close window without prompt for IE6
    this.focus();
    self.opener = this;
    self.close();
  }
</script>
