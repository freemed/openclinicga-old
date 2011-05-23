<%@page import="be.openclinic.datacenter.TimeGraph" %>
<%@include file="/includes/validateUser.jsp"%>
<%
	String[] test ="a b - c-d".split(" - ");
	out.println("test.length()="+test.length+ " / "+test[0]+"/"+test[1]);
%>
