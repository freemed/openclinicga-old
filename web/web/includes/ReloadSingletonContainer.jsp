<%@ include file="SingletonContainer.jsp"%>
<%@page errorPage="/includes/error.jsp"%>
<%@ include file="/includes/validateUser.jsp"%>
<%
reloadSingleton(session);
out.print("Labels reloaded");
%>