<%@include file="/mobile/validatePatient.jsp"%>

<%
	//Find active encounter for activePatient
	Encounter encounter = Encounter.getActiveEncounter(activePatient.personid);
	if(encounter!=null){
%>
	<table width='100%'>
		<tr><td colspan='2' bgcolor='peachpuff'><%=getTran("mobile","reasonsforencounter",activeUser) %></td></tr>
		<tr><td colspan='2' bgcolor='peachpuff'><%=encounter.getService().getLabel(activeUser.person.language) %></td></tr>
		<tr><td bgcolor='peachpuff'><%=getTran("encountertype",encounter.getType(),activeUser) %></td><td bgcolor='peachpuff'><%=new SimpleDateFormat("dd/MM/yyyy").format(encounter.getBegin()) %></td></tr>
<%
		//Find reasons for the active encounter
		Vector rfe = ReasonForEncounter.getReasonsForEncounterByEncounterUid(encounter.getUid());
		for(int n=0;n<rfe.size();n++){
			ReasonForEncounter reasonForEncounter = (ReasonForEncounter)rfe.elementAt(n);
			%>
			<tr><td><%=reasonForEncounter.getCodeType()+": "+reasonForEncounter.getCode()%></td><td><%=MedwanQuery.getInstance().getCodeTran(reasonForEncounter.getCodeType()+"code"+reasonForEncounter.getCode(),activeUser.person.language) %></td></tr>
			<%
		}
%>
	</table>
<%
	}
%>
