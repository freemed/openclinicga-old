<%@page import="java.io.File,
                java.io.FileWriter,
                java.io.FileOutputStream"%>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/helper.jsp"%>
<%
    String sDocumentId = checkString(request.getParameter("documentId"));
    String sFilename = be.openclinic.healthrecord.Document.load(sDocumentId);
%>
{
"Filename":"<%=sFilename%>"
}