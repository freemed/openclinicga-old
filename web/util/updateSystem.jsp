<%@page import="be.mxs.common.util.system.*" %>
<%@include file="/includes/validateUser.jsp"%>
<%
	UpdateSystem.update(sAPPFULLDIR);
%>
<script>window.location.href='<c:url value="/login.jsp"/>'</script>
