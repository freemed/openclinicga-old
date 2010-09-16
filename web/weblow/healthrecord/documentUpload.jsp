<%@include file="/includes/validateUser.jsp"%>
<%@ page import="java.util.Hashtable,
                 javazoom.upload.UploadFile,
                 javazoom.upload.MultipartFormDataRequest"%>
<jsp:useBean id="upBean" scope="page" class="javazoom.upload.UploadBean" >
    <jsp:setProperty name="upBean" property="folderstore" value="c:/temp" />
    <jsp:setProperty name="upBean" property="parser" value="<%= MultipartFormDataRequest.CFUPARSER %>"/>
    <jsp:setProperty name="upBean" property="parsertmpdir" value="c:/temp"/>
</jsp:useBean>
<%
    String sFolderStore = application.getRealPath("/") + MedwanQuery.getInstance().getConfigString("tempdir","/documents/");
    String sDocumentId = "";

    String sFileName = "";
    if (MultipartFormDataRequest.isMultipartFormData(request)) {
        // Uses MultipartFormDataRequest to parse the HTTP request.
        MultipartFormDataRequest mrequest = new MultipartFormDataRequest(request);
        try{
            Hashtable files = mrequest.getFiles();
            if (files != null && !files.isEmpty()){
                UploadFile file = (UploadFile) files.get("filename");
                sFileName=file.getFileName();
                file.setFileName(sFileName);
                upBean.setFolderstore(sFolderStore);
                upBean.setParsertmpdir(application.getRealPath("/")+"/"+MedwanQuery.getInstance().getConfigString("tempdir","/tmp/"));
                upBean.store(mrequest, "filename");

                sDocumentId = be.openclinic.healthrecord.Document.store(sFileName,activeUser.userid,file.getData());
            }
        }
        catch(Exception e){
            e.printStackTrace();
        }
    }
%>
<script>
    window.opener.document.all['divDocuments'].innerHTML += '<br><a href="#" onclick="openDocument(\'<%=sDocumentId%>\')"><%=sDocumentId+"_"+sFileName%></a>';
    window.opener.document.all['EditDocument'].value += ';<%=sDocumentId%>';

/*    window.open('','_self','');
    window.close();*/

    var ie7 = (document.all && !window.opera && window.XMLHttpRequest) ? true : false;
    if (ie7) {     
       //This method is required to close a window without any prompt for IE7
       window.open('','_parent','');
       window.close();
     }
     else {
       //This method is required to close a window without any prompt for IE6
       this.focus();
       self.opener = this;
       self.close();
     }
</script>
