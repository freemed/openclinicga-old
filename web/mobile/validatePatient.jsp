<%@include file="/mobile/validateUser.jsp"%>

<%
	if(session.getAttribute("activePatient")==null){
		out.println("<script>window.location.href='searchPatient.jsp';</script>");
		out.flush();
	}
	AdminPerson activePatient = (AdminPerson)session.getAttribute("activePatient");
%>
<table>
	<tr>
		<td><%=activePatient.personid %></td>
		<td><%=activePatient.lastname.toUpperCase() %></td>
		<td><%=activePatient.firstname %></td>
		<td><%=activePatient.dateOfBirth %></td>
	</tr>
	<tr>
		<td colspan='2'><a href='patientMenu.jsp'><%=getTran("mobile","mainmenu",activeUser)%></a></td>
		<td colspan='2'><a href='searchPatient.jsp'><%=getTran("mobile","newsearch",activeUser)%></a></td>
	</tr>
</table>
<hr/>