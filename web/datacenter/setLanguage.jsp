<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>
<%
	if(request.getParameter("language")!=null){
		activeUser.person.language=request.getParameter("language");
        session.setAttribute(sAPPTITLE + "WebLanguage", activeUser.person.language);
	}
%>