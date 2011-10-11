<%@page import="be.mxs.common.util.db.MedwanQuery" %>
<%
	MedwanQuery.getInstance().runScheduler();
	out.println("Scheduler run at "+new java.text.SimpleDateFormat("dd/MM/yyyy").format(new java.util.Date()));
%>