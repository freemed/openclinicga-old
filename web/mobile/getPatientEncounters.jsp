<%@page import="be.openclinic.medical.Diagnosis"%>
<%@include file="/mobile/_common/head.jsp"%>

<table class="list" padding="0" cellspacing="1" width="<%=sTABLE_WIDTH%>">
	<tr class="admin"><td colspan="4"><%=getTran("mobile","encounterdata",activeUser)%></td></tr>
	<%
	    Encounter activeEncounter = Encounter.getActiveEncounter(activePatient.personid);	
	    if(activeEncounter!=null){
	    	// 0 - reasons for encounter
	    	out.print("<tr><td colspan='4' class='admin'>"+getTran("openclinic.chuk","rfe",activeUser)+"</td></tr>");
	    	out.print("<tr><td colspan='4'>"+getReasonsForEncounterAsHtml(activeEncounter.getUid(),activeUser.person.language)+"</td></tr>");
	    			
	    	// 1 - problems
	    	out.print("<tr><td colspan='4' class='admin'>"+getTran("web","problemlist",activeUser)+"</td></tr>");
	    	out.print("<tr><td colspan='4'>"+getProblemsForEncounterAsHtml(activePatient.personid,activeUser.person.language)+"</td></tr>");
	    			
			// 2 - diagnoses
		    out.print("<tr><td colspan='4' class='admin'>"+getTran("web","managediagnosesPatient",activeUser)+"</td></tr>");
	    	out.print("<tr><td colspan='4'>"+getDiagnosesForEncounterAsHtml(activeEncounter.getUid(),activeUser.person.language)+"</td></tr>");
	    }
	%>
</table>			
			
<%-- BUTTONS --%>
<%=alignButtonsStart()%>
    <input type="button" class="button" name="backButton" onclick="showPatientMenu();" value="<%=getTranNoLink("web","back",activeUser)%>">
<%=alignButtonsStop()%>

<%@include file="/mobile/_common/footer.jsp"%>