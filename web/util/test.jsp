<%@include file="/includes/validateUser.jsp"%>
<%@ page import="be.openclinic.finance.*" %>
<%
	InsuranceStats stats = new InsuranceStats();
	stats.writeAgeConsumptionChart("", sWebLanguage,  1, "c:/temp/stats.png");
%>