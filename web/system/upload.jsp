<%@include file="/includes/validateUser.jsp"%>
<%@page errorPage="/includes/error.jsp"%>
<%@page import="javazoom.upload.MultipartFormDataRequest,
                 javazoom.upload.UploadFile,
                 java.util.Hashtable,
                 be.mxs.common.util.db.MedwanQuery,
                 java.io.File"%>
<%
    
%>
<jsp:useBean id="upBean" scope="page" class="javazoom.upload.UploadBean" >
    <jsp:setProperty name="upBean" property="folderstore" value="c:/temp/uploads" />
    <jsp:setProperty name="upBean" property="parser" value="<%= MultipartFormDataRequest.CFUPARSER %>"/>
    <jsp:setProperty name="upBean" property="parsertmpdir" value="c:/temp"/>
</jsp:useBean>
<%!
    private String getFolder(String root){
        java.util.Date today = new java.util.Date();
        String year  = new SimpleDateFormat("yyyy").format(today);
        String month = new SimpleDateFormat("MM").format(today);
        String day   = new SimpleDateFormat("dd").format(today);

        if (!(new File(root+"/"+year+"/"+month+"/"+day).isDirectory())){
            File initFile= new File(root+"/"+year+"/"+month+"/"+day);
            initFile.mkdirs();
        }

        return((root+"/"+year+"/"+month+"/"+day).replaceAll("//","/"));
    }
%>
<%
    if (MultipartFormDataRequest.isMultipartFormData(request)) {
        // Uses MultipartFormDataRequest to parse the HTTP request.
        MultipartFormDataRequest mrequest = new MultipartFormDataRequest(request);
        String todo = null;
        if (mrequest != null) todo = mrequest.getParameter("todo");

        if ((todo != null) && (todo.equalsIgnoreCase("upload"))) {
            Hashtable files = mrequest.getFiles();

            if ( (files != null) && (!files.isEmpty()) ) {
                UploadFile file = (UploadFile)files.get("uploadfile");
                if (file != null){
                    out.print("<li>Form fields : uploadfile"+"<BR> Uploaded file : "+file.getFileName()+" ("+file.getFileSize()+" bytes)"+"<BR> Content Type : "+file.getContentType());
                }

                // Uses the bean now to store specified by jsp:setProperty at the top.
                String docType=mrequest.getParameter("docType");
                String docFormat = file.getContentType();
                String extension = "";
                if (docFormat.indexOf("pdf")>-1){
                    extension = ".pdf";
                }
                if (docFormat.indexOf("doc")>-1){
                    extension = ".doc";
                }

                file.setFileName(""+MedwanQuery.getInstance().getOpenclinicCounter("DocumentName")+extension);
                upBean.setFolderstore(getFolder(MedwanQuery.getInstance().getConfigString("DocumentsFolder")));
                upBean.store(mrequest, "uploadfile");
                String docName = mrequest.getParameter("docName");
                String docFilename = (upBean.getFolderstore()+"/"+file.getFileName()).replaceAll("//","/");
                String docFolder = mrequest.getParameter("docFolder");

                int personid = 0;
                if ((activePatient!= null) && (!activePatient.personid.equals(""))){
                    personid = Integer.parseInt(activePatient.personid);
                }

                if (!MedwanQuery.getInstance().storeDocument(docType,docFormat,docName,docFilename,Integer.parseInt(activeUser.userid),docFolder,new java.util.Date(),personid)){
                    out.print("<br/>Error storing document");
                }
            }
            else {
                out.print("<li>No uploaded files");
            }
       }
       else out.print("<BR> todo="+todo);
    }
%>
<form method="post" action="<c:url value='/main.do?Page=/system/upload.jsp'/>&ts=<%=getTs()%>" name="upform" enctype="multipart/form-data">
    <input type="hidden" name="todo" value="upload">
    <table width="100%" border="0" cellspacing="1" class="list">
        <tr class="admin">
            <td colspan="2">&nbsp;&nbsp;<%=getTran("Web.Occup","medwan.common.view-patient-documents",sWebLanguage)%></td>
        </tr>

        <tr>
            <td class="admin"><%= getTran("Web.Occup","medwan.common.selectfile",sWebLanguage) %></td>
            <td class="admin2"><input type="file" name="uploadfile" size="80" class="text"></td>
        </tr>

        <tr>
            <td class="admin"><%= getTran("Web.Occup","medwan.common.documenttype",sWebLanguage) %></td>
            <td class="admin2">
                <select name ="docType" class="text">
                    <option value="template"><%= getTran("Web.Occup","medwan.common.template",sWebLanguage) %>
                    <option value="record"><%= getTran("Web.Occup","medwan.common.patientrecord",sWebLanguage) %>
                </select>
            </td>
        </tr>

        <tr>
            <td class="admin"><%= getTran("Web.Occup","medwan.common.name",sWebLanguage) %></td>
            <td class="admin2"><input type="text" name="docName" size="80" class="text"></td>
        </tr>

        <tr>
            <td class="admin"><%= getTran("Web.Occup","medwan.common.folder",sWebLanguage) %></td>
            <td class="admin2"><input type="text" name="docFolder" size="80" class="text">
                <select name ="sel" class="text" onchange="document.getElementsByName('docFolder')[0].value=this.value;">
                    <option value="">
                    <option value="VARIA">VARIA
                    <option value="LAB">LAB
                    <option value="RX">RX
                    <option value="ANAPAT">ANAPATH
                    <option value="SPECIALIST(E)">SPECIALIST(E)
                    <option value="CERTIF">CERTIF
                </select>
            </td>
        </tr>
    </table>
    <%-- BUTTONS --%>
    <%=ScreenHelper.alignButtonsStart()%>
        <input class="button" type="button" value="<%=getTran("Web.Occup","medwan.common.view-system-documents",sWebLanguage)%>" onclick="window.location.href='<c:url value='/main.do?Page=viewSystemDocuments.jsp'/>'"/>
        <input class="button" type="button" value="<%=getTran("Web.Occup","medwan.common.view-patient-documents",sWebLanguage)%>" onclick="window.location.href='<c:url value='/main.do?Page=viewPatientDocuments.jsp'/>'"/>
        <input class="button" type="submit" name="Submit" value="<%=getTran("Web.Occup","medwan.common.record",sWebLanguage)%>">
    <%=ScreenHelper.alignButtonsStop()%>
</form>
<%
    if (request.getParameter("type")!=null){
        out.print("<script>document.getElementsByName('docType')[0].value='"+request.getParameter("type")+"';</script>");
    }
%>