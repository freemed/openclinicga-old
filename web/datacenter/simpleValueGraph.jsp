<%@page import="be.openclinic.datacenter.TimeGraph" %>
<%@include file="/includes/validateUser.jsp"%>
<%
	int serverId=Integer.parseInt(request.getParameter("serverid"));
	String parameterId=request.getParameter("parameterid");
	String filename=TimeGraph.drawSimpleValueGraph(new SimpleDateFormat("dd/MM/yyyy").parse(new SimpleDateFormat("dd/MM/").format(new java.util.Date())+(Integer.parseInt(new SimpleDateFormat("yyyy").format(new java.util.Date()))-1)),
			new java.util.Date(new java.util.Date().getTime()+24*3600000),serverId,parameterId,sWebLanguage,activeUser.userid);
%>
<img src='<c:url value="/documents/"/><%=filename+"?ts="+getTs()%>'/>