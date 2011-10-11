<%@include file="/mobile/validatePatient.jsp"%>

<table>
	<tr><td><a href='getPatientAdmin.jsp'><%=getTran("mobile","administrativedata",activeUser) %></a></td></tr>
	<tr><td><a href='getPatientBiometrics.jsp'><%=getTran("mobile","biometricdata",activeUser) %></a></td></tr>
	<tr><td><a href='getPatientLab.jsp'><%=getTran("mobile","labdata",activeUser) %></a></td></tr>
	<tr><td><a href='getPatientImaging.jsp'><%=getTran("mobile","imagingdata",activeUser) %></a></td></tr>
	<tr><td><a href='getPatientEncounters.jsp'><%=getTran("mobile","encounterdata",activeUser) %></a></td></tr>
	<tr><td><a href='getPatientClinical.jsp'><%=getTran("mobile","clinicaldata",activeUser) %></a></td></tr>
	<tr><td><a href='getPatientMedication.jsp'><%=getTran("mobile","medicationdata",activeUser) %></a></td></tr>
	<tr><td><a href='getReasonsForEncounter.jsp'><%=getTran("mobile","reasonsforencounter",activeUser) %></a></td></tr>
</table>