<%@include file="/includes/validateUser.jsp"%>
<%@page errorPage="/includes/error.jsp"%>
<%
	String sEncounterUid = "", sEncounterName = "";
	String personid = request.getParameter("personid");
	Encounter encounter = Encounter.getActiveEncounter(personid);
	if(encounter!=null){
		sEncounterUid = encounter.getUid();
		sEncounterName = encounter.getEncounterDisplayName(sWebLanguage);
	}
%>
{
"EncounterUid":"<%=sEncounterUid%>",
"EncounterName":"<%=sEncounterName%>"
}