<%@include file="/mobile/validateUser.jsp"%>

<%
	if(request.getParameter("personid")==null){
		out.println("<script>window.location.href='searchPatient.jsp';</script>");
		out.flush();
	}
	else {
		AdminPerson activePatient = AdminPerson.getAdminPerson(request.getParameter("personid"));
		if(activePatient.lastname==null || activePatient.lastname.length()==0){
			out.println("<script>window.location.href='searchPatient.jsp';</script>");
			out.flush();
		}
		session.setAttribute("activepatient",activePatient);
	}
%>
<script>window.location.href='patientMenu.jsp';</script>