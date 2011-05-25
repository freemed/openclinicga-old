<%@page import="be.mxs.common.util.system.*" %>
<%@include file="/includes/validateUser.jsp"%>
<%
	UpdateSystem.updateDb();
	UpdateSystem.updateLabels(session,sAPPFULLDIR);
%>
