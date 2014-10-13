<%@include file="/mobile/_common/head.jsp"%>
<%
	if(activePatient==null){
		out.print("<script>window.location.href='searchPatient.jsp';</script>");
	}
	else{
%>
<table class="list" padding="0" cellspacing="1" width="<%=sTABLE_WIDTH%>">
	<tr class="admin"><td><%=activePatient.lastname+", "+activePatient.firstname%> - <%=activePatient.dateOfBirth%></td></tr>

	<tr class="list1"><td><a href="getPatientAdmin.jsp"><%=getTran("mobile","administrativedata",activeUser)%></a></td></tr>
	<tr class="list"><td><a href="getPatientBiometrics.jsp"><%=getTran("mobile","biometricdata",activeUser)%></a></td></tr>
	<tr class="list1"><td><a href="getPatientLab.jsp"><%=getTran("mobile","labdata",activeUser)%></a></td></tr>
	<tr class="list"><td><a href="getPatientImaging.jsp"><%=getTran("mobile","imagingdata",activeUser)%></a></td></tr>
	<tr class="list1"><td><a href="getPatientEncounters.jsp"><%=getTran("mobile","encounterdata",activeUser)%></a></td></tr>
	<tr class="list"><td><a href="getPatientClinical.jsp"><%=getTran("mobile","clinicaldata",activeUser)%></a></td></tr>
	<tr class="list1"><td><a href="getPatientMedication.jsp"><%=getTran("mobile","activeMedication",activeUser)%></a></td></tr>
	<tr class="list"><td><a href="getReasonsForEncounter.jsp"><%=getTran("mobile","reasonsforencounter",activeUser)%></a></td></tr>
</table>

<%@include file="/mobile/_common/footer.jsp"%>
<%
	}
%>