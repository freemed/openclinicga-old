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

    String sFolderStore = application.getRealPath("/") + MedwanQuery.getInstance().getConfigString("documentsdir","adt/documents/");
    String sReturnField="";
    String sFileName = "";
    if (MultipartFormDataRequest.isMultipartFormData(request)) {
        // Uses MultipartFormDataRequest to parse the HTTP request.
        MultipartFormDataRequest mrequest = new MultipartFormDataRequest(request);
        sReturnField=mrequest.getParameter("ReturnField");
        try{
            Hashtable files = mrequest.getFiles();
            if (files != null && !files.isEmpty()){
                UploadFile file = (UploadFile) files.get("filename");
                sFileName=file.getFileName();
                file.setFileName(sFileName);
                upBean.setFolderstore(sFolderStore);
                upBean.setParsertmpdir(application.getRealPath("/")+"/"+MedwanQuery.getInstance().getConfigString("tempdir","/adt/tmp"));
                upBean.store(mrequest, "filename");
            }
        }
        catch(Exception e){
            e.printStackTrace();
        }
    }
%>
<script>
    window.resizeTo(1,1);
    window.opener.document.getElementsByName('<%=sReturnField%>')[0].value='<%=sFileName%>';
    window.close();
</script>
