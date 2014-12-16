<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>
<%
    reloadSingleton(session);
    Debug.println("Labels reloaded");
%>