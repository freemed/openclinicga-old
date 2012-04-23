<%@include file="/includes/validateUser.jsp"%>
<%@page errorPage="/includes/error.jsp"%>
<%@page import="javazoom.upload.*,
                 java.util.*,
                 be.mxs.common.util.db.MedwanQuery,
                 java.io.File,java.io.*,be.mxs.common.util.system.Picture"%>
<jsp:useBean id="upBean" scope="page" class="javazoom.upload.UploadBean" >
    <jsp:setProperty name="upBean" property="storemodel" value="<%=UploadBean.MEMORYSTORE %>" />
</jsp:useBean>

<%
if (MultipartFormDataRequest.isMultipartFormData(request)) {
     // Uses MultipartFormDataRequest to parse the HTTP request.
     MultipartFormDataRequest mrequest = new MultipartFormDataRequest(request);
     String todo = null;
     if (mrequest !=null) todo=mrequest.getParameter("todo");
     if ((todo != null) && (todo.equalsIgnoreCase("upload"))) {
         Hashtable files = mrequest.getFiles();

         if ( (files != null) && (!files.isEmpty()) ) {
        	 UploadFile file = (UploadFile)files.get("uploadfile");
             upBean.store(mrequest, "uploadfile");
             UploadFile uFile =(UploadFile)upBean.getMemorystore().firstElement();
             Picture p = new Picture();
             p.setPersonid(Integer.parseInt(activePatient.personid));
             p.delete();
             p.setPicture(uFile.getData());
             p.store();
         }
  	}
}
%>
<form method="post" action="<c:url value='/main.do?Page=/system/uploadPicture.jsp'/>&ts=<%=getTs()%>" name="upform" enctype="multipart/form-data">
    <input type="hidden" name="todo" value="upload">
    <table width="100%" border="0" cellspacing="1" class="list">
        <tr class="admin">
            <td colspan="2">&nbsp;&nbsp;<%=getTran("Web","upload.picture",sWebLanguage)%></td>
        </tr>

        <tr>
            <td class="admin"><%= getTran("Web.Occup","medwan.common.selectfile",sWebLanguage) %></td>
            <td class="admin2"><input type="file" name="uploadfile" size="80" class="text"></td>
        </tr>

    </table>
    <%-- BUTTONS --%>
    <%=ScreenHelper.alignButtonsStart()%>
        <input class="button" type="submit" name="Submit" value="<%=getTran("Web.Occup","medwan.common.record",sWebLanguage)%>">
    <%=ScreenHelper.alignButtonsStop()%>
</form>
