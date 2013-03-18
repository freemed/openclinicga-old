<%@ page import="be.mxs.common.util.db.*" %>
<%
	out.print("{\"server\":\""+MedwanQuery.getInstance().getConfigString("javaPOSServer","http://localhost/openclinic")+"\"}");
%>