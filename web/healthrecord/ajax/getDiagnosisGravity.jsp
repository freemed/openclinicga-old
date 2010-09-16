<%@ page import="be.openclinic.medical.Diagnosis" %>
<%
	int gravity=Diagnosis.getGravity(request.getParameter("codetype"),request.getParameter("code"),500);
	out.print(gravity);
%>