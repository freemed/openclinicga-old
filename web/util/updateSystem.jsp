<%@page import="be.mxs.common.util.system.*" %>
<%@include file="/includes/validateUser.jsp"%>
<%
	UpdateSystem.updateDb();
	UpdateSystem.updateLabels(session,sAPPFULLDIR);
	UpdateSystem.updateTransactionItems(sAPPFULLDIR);
	if(request.getParameter("updateVersion")!=null){
		MedwanQuery.getInstance().setConfigString("updateVersion",request.getParameter("updateVersion"));
	}
%>
<script>window.location.href='<c:url value="/login.jsp"/>'</script>
