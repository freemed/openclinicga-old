<%@ page import="sun.misc.*,be.mxs.common.util.io.*,org.apache.commons.httpclient.*,org.apache.commons.httpclient.methods.*,be.mxs.common.util.db.*,be.mxs.common.util.system.*,be.openclinic.finance.*,net.admin.*,java.util.*,java.text.*,be.openclinic.adt.*" %>
<%@include file="/includes/SingletonContainer.jsp"%>
<%
	System.out.println("project="+HTMLEntities.unhtmlentities(request.getParameter("project"))+"*");
	System.out.println("content="+HTMLEntities.unhtmlentities(request.getParameter("content")));
	reloadSingleton(session);
	JavaPOSPrinter printer = new JavaPOSPrinter();
	System.out.println("Now printing...");
	String error=printer.printReceipt(request.getParameter("project"), request.getParameter("language"),HTMLEntities.unhtmlentities(request.getParameter("content")),request.getParameter("id"));
%>
<error><![CDATA[<%= HTMLEntities.htmlentities(error) %>]]></error>
