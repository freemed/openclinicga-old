<%@include file="/mobile/_common/validateUser.jsp"%>
<%
	if(request.getParameter("personid")==null){
		// back to search screen when no patient specified
		out.println("<script>window.location.href='searchPatient.jsp?ts="+getTs()+"';</script>");
		out.flush();
	}
	else{
		// fetch specified patient
		activePatient = AdminPerson.getAdminPerson(request.getParameter("personid"));
		if(activePatient.lastname==null || activePatient.lastname.length()==0){
			// back to search screen when specified patient not found
			out.println("<script>window.location.href='searchPatient.jsp?ts="+getTs()+"';</script>");
			out.flush();
		}
		session.setAttribute("activePatient",activePatient);
		// below : display found patient
	}
%>
<script>window.location.href='patientMenu.jsp?ts=<%=getTs()%>';</script>