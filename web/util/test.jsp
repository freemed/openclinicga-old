<%@page import="be.openclinic.datacenter.TimeGraph" %>
<%@include file="/includes/validateUser.jsp"%>
<%
	String filename=TimeGraph.drawSimpleValueGraph(new SimpleDateFormat("dd/MM/yyyy").parse("01/01/2010"),new SimpleDateFormat("dd/MM/yyyy").parse("01/01/2011"),6,"core.1",sWebLanguage,activeUser.userid);
%>
<img src='<%= MedwanQuery.getInstance().getConfigString("DocumentsURL")+filename%>'/>