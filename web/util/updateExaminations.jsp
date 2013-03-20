<%@include file="/includes/validateUser.jsp"%>
<%@page import="be.mxs.common.util.system.*" %>
<%
	out.println(UpdateSystem.updateExaminations()+" "+getTran("web","examinations.updated",sWebLanguage));
%>