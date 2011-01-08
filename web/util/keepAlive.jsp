<%@page import="java.text.*" %>
<%
	out.print(new SimpleDateFormat("yyyyMMddHHmmss").format(new java.util.Date()));
%>