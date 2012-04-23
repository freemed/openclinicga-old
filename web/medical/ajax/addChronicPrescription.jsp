<%@ page import="be.openclinic.medical.ChronicMedication" %>
<%@include file="/includes/validateUser.jsp"%>
<%
	ChronicMedication med = new ChronicMedication();
	med.setUid("-1");
	
	med.setPatientUid(activePatient.personid);
	med.setProductUid(request.getParameter("productuid"));
	med.setBegin(new java.util.Date());
	med.setPrescriberUid(activeUser.person.personid);
	med.setTimeUnit("D");
	med.setTimeUnitCount(1);
	med.setUnitsPerTimeUnit(1);
	med.setUpdateUser(activeUser.userid);
	med.store();
%>