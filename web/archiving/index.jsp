<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>
<%=
 (
    ScreenHelper.writeTblHeader(getTran("web","archive",sWebLanguage),sCONTEXTPATH)
    +writeTblChild("main.do?Page=archiving/listArchiveDocuments.jsp",getTranNoLink("web.archiving","listArchiveDocuments",sWebLanguage))
    +ScreenHelper.writeTblFooter()
 )
%>
