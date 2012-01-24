<%@page import="be.openclinic.adt.Encounter"%>
<%@include file="/includes/validateUser.jsp"%>
<%
	String sInit=checkString(request.getParameter("init"));
	if(sInit.split(";").length>=3){
		Encounter encounter = new Encounter();
		encounter.setBegin(new java.util.Date());
		encounter.setCreateDateTime(new java.util.Date());
		encounter.setPatientUID(activePatient.personid);
		encounter.setUpdateDateTime(new java.util.Date());
		encounter.setUpdateUser(activeUser.userid);
		encounter.setVersion(1);
		encounter.setType(sInit.split(";")[0]);
		encounter.setOrigin(sInit.split(";")[1]);
		encounter.setServiceUID(sInit.split(";")[2]);
		if(sInit.split(";").length>=4){
			encounter.setManagerUID(sInit.split(";")[3]);
		}
		encounter.store();
	}
%>
