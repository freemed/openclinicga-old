<%@include file="/includes/validateUser.jsp"%>
<%@page import="be.mxs.common.util.system.*"%>
<%
    UpdateSystem systemUpdate = new UpdateSystem();
	out.println(systemUpdate.updateExaminations()+" "+getTran("web","examinations.updated",sWebLanguage));
%>