<%@include file="/mobile/_common/head.jsp"%>

<%
	// active encounter for activePatient
	Encounter encounter = Encounter.getActiveEncounter(activePatient.personid);
	if(encounter!=null){
		%>
            <%-- 0 - active encounter --%>
		    <table class="list" padding="0" cellspacing="0" width="<%=sTABLE_WIDTH%>">
				<tr class="admin"><td colspan="3"><%=getTran("web","active_encounter",activeUser)%></td></tr>
				    <tr><td><%=encounter.getService().getLabel(activeUser.person.language)%></td></tr>
				    <tr><td><%=getTran("encountertype",encounter.getType(),activeUser)%>, <%=stdDateFormat.format(encounter.getBegin())%></td></tr>
			</table>		
			<div style="padding-top:3px"></div>
			
            <%-- 1 - reasons for the active encounter --%>
		    <table class="list" padding="0" cellspacing="0" width="<%=sTABLE_WIDTH%>">
				<tr class="admin"><td><%=getTran("openclinic.chuk","rfe",activeUser)%></td></tr>
				<tr><td><%=getReasonsForEncounterAsHtml(encounter.getUid(),activeUser.person.language)%></td></tr>
			</table>
			<div style="padding-top:3px"></div>

            <%-- 2 - diagnoses for the active encounter --%>
		    <table class="list" padding="0" cellspacing="0" width="<%=sTABLE_WIDTH%>">
				<tr class="admin"><td><%=getTran("openclinic.chuk","dfe",activeUser)%></td></tr>
				<tr><td><%=getDiagnosesForEncounterAsHtml(encounter.getUid(),activeUser.person.language)%></td></tr>
			</table>
			
			<%-- BUTTONS --%>
			<%=alignButtonsStart()%>
				<input type="button" class="button" name="backButton" onclick="doBack();" value="<%=getTranNoLink("web","back",activeUser)%>">
			<%=alignButtonsStop()%>
					 
			<script>
			  function doBack(){
				window.location.href = "selectPatient.jsp?personid=<%=activePatient.personid%>&ts=<%=getTs()%>";
			  }
			</script>
						
			<%@include file="/mobile/_common/footer.jsp"%>
		<%
	}
	else{
		out.print("No active encounter");
	}
%>