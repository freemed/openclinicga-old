<%@page errorPage="/includes/error.jsp"%>
<%@page import="be.openclinic.adt.*"%>
<%@include file="/includes/validateUser.jsp"%>
<%
	Encounter encounter = Encounter.get(request.getParameter("encounteruid"));
	Encounter.EncounterService encounterService = encounter.getLastEncounterService();
	Service service = Service.getService(encounterService.serviceUID);
%>
{
"uid":"<%=service.code%>",
"name":"<%=service.getLabel(sWebLanguage)%>"
}