<%@ page import="be.openclinic.finance.*,java.text.*" %>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>
<table width='100%'>
<%
	AdminPerson person = AdminPerson.getAdminPerson(request.getParameter("personid"));
	out.println("<tr class='admin'><td colspan='3'>"+getTran("web","contributionsby",sWebLanguage)+" "+person.lastname.toUpperCase()+", "+person.firstname+"</td></tr>");
	out.println("<tr class='admin'><td>"+getTran("web","contribution",sWebLanguage)+"</td><td>"+getTran("web","date",sWebLanguage)+"</td><td>"+getTran("web","validity",sWebLanguage)+"</td></tr>");
	Vector contributions = Debet.getContributions(request.getParameter("personid"));
	for(int n=0;n<contributions.size() && n<100;n++){
		Debet debet = (Debet)contributions.elementAt(n);
		if(debet.getCredited()!=1){
			java.util.Date dv=debet.getContributionValidity();
			out.println("<tr><td class='admin'>"+debet.getPrestation().getDescription()+"</td><td class='admin'>"+ScreenHelper.formatDate(debet.getDate())+"</td><td "+(dv.before(new java.util.Date())?"class='admin'":"bgcolor='lightgreen'")+">"+ScreenHelper.formatDate(dv)+"</td></tr>");
		}
	}
%>
</table>