<%@page import="be.openclinic.datacenter.EncounterDiagnosisGraph" %>
<%@include file="/includes/validateUser.jsp"%>
<%
	int serverId=Integer.parseInt(request.getParameter("serverid"));
	String code=request.getParameter("diagnosiscode");
	String type=request.getParameter("type");
	String filename=EncounterDiagnosisGraph.drawSimpleValueGraph(serverId,code,sWebLanguage,activeUser.userid,type);
%>
<img src='<c:url value="/documents/"/><%=filename+"?ts="+getTs()%>'/>