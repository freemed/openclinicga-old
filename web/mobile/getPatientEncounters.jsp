<%@ page import="be.openclinic.medical.Diagnosis"%>
<%@include file="/mobile/validatePatient.jsp"%>

<table width='100%'>
	<tr><td colspan='3' bgcolor='peachpuff'><b><u><%=getTran("mobile","encounterdata",activeUser) %></u></b></td></tr>
  
    
<%
   Encounter activeContact = Encounter.getActiveEncounter(activePatient.personid);	
    if(activeContact!=null){
    	out.print("<tr><td colspan='3' bgcolor='peachpuff'>"+getTran("openclinic.chuk","rfe",activeUser)+"</td></tr>");
    	out.println("<tr><td width='1'>&nbsp;</td><td colspan='2'>"+ReasonForEncounter.getReasonsForEncounterAsHtml(activeContact.getUid(),activeUser.person.language)+"</td></tr>");
    	out.print("<tr><td colspan='3' bgcolor='peachpuff'>"+getTran("web","problemlist",activeUser)+"</td></tr>"); 
        Vector activeProblems = Problem.getActiveProblems(activePatient.personid);
		if(activeProblems.size()>0){
	    	out.println("<table width='100%' ccolspan='3'><td><b>" + getTran("web.occup", "medwan.common.description", activeUser) + "</td>" +
	                    "<td><b>" + getTran("web.occup", "medwan.common.datebegin", activeUser) + "</td></tr>");
	        for (int n=0; n<activeProblems.size(); n++){
	    		Problem problems = (Problem)activeProblems.elementAt(n);
	    		out.print("<tr><td>"+MedwanQuery.getInstance().getCodeTran(problems.getCodeType() + "code" + problems.getCode(), activeUser.person.language)+"</td><td>"+problems.getBegin()+"</td></tr>");		
	    	}
		}    
		else {
    		out.print("<tr><td colspan='2'>&nbsp;</td></tr>");		
			
		}
	    out.print("<tr><td colspan='3' bgcolor='peachpuff'>"+getTran("web","managediagnosespatient",activeUser)+"</td></tr>");
	    Vector diagnosisPatient = Diagnosis.selectDiagnoses("","",activeContact.getUid(),"","","","","","","","","","","","");
	
	  	for(int n=0;n<diagnosisPatient.size();n++){
			Diagnosis diago = (Diagnosis)diagnosisPatient.elementAt(n);
			out.println("<tr><td>"+ MedwanQuery.getInstance().getCodeTran(diago.getCodeType() + "code" + diago.getCode(), activeUser.person.language)+"</td></tr>");
	  	}
	   	 out.println("</table>");
    }
%>
</table>	