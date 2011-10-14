<%@ page import="be.openclinic.medical.Diagnosis"%>
<%@include file="/mobile/validatePatient.jsp"%>

<%
	//Find active encounter for activePatient
	Encounter encounter = Encounter.getActiveEncounter(activePatient.personid);
	if(encounter!=null){
%>
	<table width='100%'>
		<tr><td colspan='3' bgcolor='peachpuff'><%=getTran("openclinic.chuk","rfe",activeUser) %></td></tr>
<%
		//--> Put the service of the active encounter here
		
		out.print("<tr><td colspan='3' bgcolor='peachpuff'>"+encounter.getService().getLabel(activeUser.person.language)+"</td></tr>");
		//--> Put the type of contact (consultation/admission) here
		out.print("<tr><td colspan='1' bgcolor='peachpuff'>"+getTran("encountertype",encounter.getType(),activeUser)+"</td><td colspan='2' bgcolor='peachpuff'>"+new SimpleDateFormat("dd/MM/yyyy").format(encounter.getBegin())+"</td></tr>");
		
		//Find reasons for the active encounter
		Vector rfe = ReasonForEncounter.getReasonsForEncounterByEncounterUid(encounter.getUid());
		for(int n=0;n<rfe.size();n++){
			//--> Load the reason for encounter and show the following content:
			//--> Code type (ICPC/ICD-10), code, label
			
			ReasonForEncounter reasonForEncounter = (ReasonForEncounter)rfe.elementAt(n);
			out.print("<tr><td>"+reasonForEncounter.getCodeType()+
                      "</td><td><b>"+reasonForEncounter.getCode()+
                      "</b></td><td><b>"+MedwanQuery.getInstance().getCodeTran(reasonForEncounter.getCodeType()+"code"+reasonForEncounter.getCode(),activeUser.person.language)+"</b></td></tr>");
		
		}	
		
		out.print("<tr><td colspan='3'><hr></td></tr>");
		
	    Vector diagnosisPatient = Diagnosis.selectDiagnoses("","",encounter.getUid(),"","","","","","","","","","","","");
	  	for(int n=0;n<diagnosisPatient.size();n++){
			Diagnosis diagnostic = (Diagnosis)diagnosisPatient.elementAt(n);
			out.println("<tr><td>"+diagnostic.getCodeType()+
					    "</td><td><b>"+diagnostic.getCode()+
			            "</b></td><td><b>"+ MedwanQuery.getInstance().getCodeTran(diagnostic.getCodeType() + "code" + diagnostic.getCode(), activeUser.person.language)+"</b></td></tr>");
	  	}
	    
%>
	</table>
<%
	}
%>