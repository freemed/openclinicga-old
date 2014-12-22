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
	String SCANDIR_BASE = MedwanQuery.getInstance().getConfigString("scanDirectoryMonitor_basePath","c:/projects/openclinicnew/web/scan");
    String sFolderStore = SCANDIR_BASE+"/"+MedwanQuery.getInstance().getConfigString("scanDirectoryMonitor_dirFrom","from");
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
                Debug.println("sFileName : "+sFileName);
                String sUid=mrequest.getParameter("fileuploadid")+sFileName.substring(sFileName.lastIndexOf("."));
                file.setFileName(sUid);
                Debug.println("sFileID : "+sUid);
                Debug.println("--> fileSize : "+file.getFileSize()+" bytes"); 
                
                upBean.setFolderstore(sFolderStore);
                upBean.setParsertmpdir(application.getRealPath("/")+"/"+MedwanQuery.getInstance().getConfigString("tempdir","/tmp/"));
                upBean.store(mrequest, "filename");
                Debug.println("Removing transaction from cache: "+mrequest.getParameter("uploadtransactionid"));
                MedwanQuery.getInstance().getObjectCache().removeObject("transaction",mrequest.getParameter("uploadtransactionid"));

            }
        }
        catch(Exception e){
        	Debug.printStackTrace(e);
        }
    }
%>
<script>
  
  var ie7 = (document.all && !window.opera && window.XMLHttpRequest)?true:false;
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
