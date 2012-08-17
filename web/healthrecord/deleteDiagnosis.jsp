<%@ page import="be.openclinic.medical.*" %>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>
<%
	Diagnosis.deleteForUid(request.getParameter("uid"));
%>
<script>
	window.opener.location.reload();
	window.close();
</script>