<%@include file="/mobile/validatePatient.jsp"%>

<%
	//Find active encounter for activePatient
	Encounter encounter = Encounter.getActiveEncounter(activePatient.personid);
	if(encounter!=null){
%>
	<table width='100%'>
		<tr><td colspan='2' bgcolor='peachpuff'><%=getTran("mobile","reasonsforencounter",activeUser) %></td></tr>
<%
		//--> Put the service of the active encounter here
		//--> Put the type of contact (consultation/admission) here
		
		//Find reasons for the active encounter
		Vector rfe = ReasonForEncounter.getReasonsForEncounterByEncounterUid(encounter.getUid());
		for(int n=0;n<rfe.size();n++){
			//--> Load the reason for encounter and show the following content:
			//--> Code type (ICPC/ICD-10), code, label
		}
%>
	</table>
<%
	}
%>
