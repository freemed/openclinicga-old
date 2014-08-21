<%@page import="be.mxs.common.util.system.SessionMessage"%><%
	SessionMessage sessionMessage=((SessionMessage)session.getAttribute("messages"));
	String msg=sessionMessage.getLastMessages();
	out.print(msg);
%>