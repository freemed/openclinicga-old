<%@page import="be.openclinic.datacenter.DiagnosisGraph" %>
<%@include file="/includes/validateUser.jsp"%>
<%
	int serverId=Integer.parseInt(request.getParameter("serverid"));
	String code=request.getParameter("diagnosiscode");
	String filename=DiagnosisGraph.drawSimpleValueGraph(serverId,code,sWebLanguage,activeUser.userid);
%>
<img src='<c:url value="/documents/"/><%=filename+"?ts="+getTs()%>'/>