<%@ page import="be.openclinic.adt.Encounter" %>

<%
	if(request.getParameter("uid")!=null){
		Encounter encounter = Encounter.get(request.getParameter("uid"));
		if(encounter!=null){
			encounter.setEnd(new java.util.Date());
			encounter.store();
		}
	}
%>