<%@include file="/mobile/validatePatient.jsp"%>

<table width='100%'>
	<tr><td colspan='2' bgcolor='peachpuff'><b><%=getTran("mobile","demographics",activeUser) %></b></td></tr>
	<tr><td width='1' nowrap><%=getTran("web.admin","nationality",activeUser) %></td><td><%=getTran("country",activePatient.nativeCountry,activeUser) %></td></tr>
	<tr><td nowrap><%=getTran("mobile","idcard",activeUser) %></td><td><%=activePatient.getID("natreg") %></td></tr>
	<tr><td nowrap><%=getTran("web","language",activeUser) %></td><td><%=getTran("web.language",activePatient.language,activeUser) %></td></tr>
	<tr><td nowrap><%=getTran("web","gender",activeUser) %></td><td><%=activePatient.gender %></td></tr>
	<tr><td nowrap><%=getTran("web","civilstatus",activeUser) %></td><td><%=getTran("civil.status",activePatient.comment2,activeUser) %></td></tr>
	<tr><td nowrap><%=getTran("web","province",activeUser) %></td><td><%=activePatient.getActivePrivate().province%></td></tr>
	<tr><td nowrap><%=getTran("web","district",activeUser) %></td><td><%=activePatient.getActivePrivate().district%></td></tr>
	<tr><td nowrap><%=getTran("web","city",activeUser) %></td><td><%=activePatient.getActivePrivate().city%></td></tr>
	<tr><td nowrap><%=getTran("web","telephone",activeUser) %></td><td><%=activePatient.getActivePrivate().telephone%></td></tr>
</table>


<hr/>
<table width='100%'>
	<tr><td colspan='3' bgcolor='peachpuff'><b><%=getTran("web","adt",activeUser) %></b></td></tr>
	<tr><td colspan='3' bgcolor='lightyellow'><%=getTran("web","active_encounter",activeUser) %></td></tr>
	<%
		Encounter activeContact = Encounter.getActiveEncounter(activePatient.personid);	
		if(activeContact!=null){
			out.print("<tr><td width='1'>&nbsp;</td><td nowrap>"+getTran("web.occup","medwan.common.contacttype",activeUser)+"</td><td>"+getTran("encountertype",activeContact.getType(),activeUser)+"</td></tr>");
			out.print("<tr><td width='1'>&nbsp;</td><td width='1' nowrap>"+getTran("web","begin",activeUser)+"</td><td>"+new SimpleDateFormat("dd/MM/yyyy").format(activeContact.getBegin())+"</td></tr>");
			out.print("<tr><td width='1'>&nbsp;</td><td nowrap>"+getTran("openclinic.chuk","urgency.origin",activeUser)+"</td><td>"+getTran("urgency.origin",activeContact.getOrigin(),activeUser)+"</td></tr>");
			if(activeContact.getManager()!=null && activeContact.getManager().person!=null){
				out.print("<tr><td width='1'>&nbsp;</td><td nowrap>"+getTran("web","manager",activeUser)+"</td><td>"+activeContact.getManager().person.getFullName()+"</td></tr>");
			}
			out.print("<tr><td width='1'>&nbsp;</td><td nowrap>"+getTran("web","service",activeUser)+"</td><td>"+activeContact.getService().getLabel(activeUser.person.language)+"</td></tr>");
			out.print("<tr><td colspan='3' bgcolor='lightyellow'>"+getTran("openclinic.chuk","rfe",activeUser)+"</td></tr>");
			out.println("<tr><td width='1'>&nbsp;</td><td colspan='2'>"+ReasonForEncounter.getReasonsForEncounterAsHtml(activeContact.getUid(),activeUser.person.language)+"</td></tr>");
		}
	%>
	<tr><td colspan='3' bgcolor='lightyellow'><%=getTran("mobile","lastcontacts",activeUser) %></td></tr>
	<%
		Encounter lastvisit = Encounter.getInactiveEncounterBefore(activePatient.personid,"visit",new Date());
		if(lastvisit!=null){
			out.print("<tr><td width='1'>&nbsp;</td><td nowrap>"+getTran("encountertype","visit",activeUser)+"</td><td>"+new SimpleDateFormat("dd/MM/yyyy").format(lastvisit.getBegin())+": "+lastvisit.getService().getLabel(activeUser.person.language)+"</td></tr>");
		}
		Encounter lastadmission = Encounter.getInactiveEncounterBefore(activePatient.personid,"admission",new Date());
		if(lastadmission!=null){
			out.print("<tr><td width='1'>&nbsp;</td><td nowrap>"+getTran("encountertype","admission",activeUser)+"</td><td>"+new SimpleDateFormat("dd/MM/yyyy").format(lastadmission.getBegin())+": "+lastadmission.getService().getLabel(activeUser.person.language)+"</td></tr>");
		}
	%>
</table>