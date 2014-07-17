<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>
<%@ page import="be.openclinic.adt.*" %>
<%
	Encounter encounter = Encounter.get(request.getParameter("encounteruid"));
	Encounter.EncounterService s = encounter.getLastEncounterService();
	Service service = Service.getService(s.serviceUID);
%>
{
"uid":"<%=service.code%>",
"name":"<%=service.getLabel(sWebLanguage)%>"
}