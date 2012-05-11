<%@ page import="be.dpms.medwan.common.model.vo.occupationalmedicine.*" %>
<%@include file="/includes/validateUser.jsp"%>
<%@page errorPage="/includes/error.jsp"%>
<%
	if(request.getParameter("submit")!=null){
		String activeVaccinations="*";
		Enumeration pars = request.getParameterNames();
		while(pars.hasMoreElements()){
			String parname = (String)pars.nextElement();
			if(parname.startsWith("cb")){
				activeVaccinations+=parname.substring(2)+"*";
			}
		}
		MedwanQuery.getInstance().setConfigString("activeVaccinations",activeVaccinations);
	}
%>
<form name="activeVaccinationsForm" method="post">
	<table>
		<tr class='admin'><td colspan="2"><%=getTran("web.manage","ManageActivatedVaccinations",sWebLanguage) %></td></tr>
		<%
			String activeVaccinations = MedwanQuery.getInstance().getConfigString("activeVaccinations","*504*506*517*525*526*527*529*530*531*539*");
			Iterator vaccinations = MedwanQuery.getInstance().getAllExaminations(sWebLanguage).iterator();
			while(vaccinations.hasNext()){
				ExaminationVO examination = (ExaminationVO)vaccinations.next();
				if(examination.getTransactionType().indexOf("VACCINATION")>-1){
					out.println("<tr><td class='admin'><input type='checkbox' name='cb"+examination.getId()+"'"+(activeVaccinations.indexOf("*"+examination.getId()+"*")>-1?"checked":"")+"/></td><td class='admin2'>"+getTran("web.occup",examination.getMessageKey(),sWebLanguage)+"</td></tr>");
				}
			}
		
		%>		
	</table>
	<input type='submit' name='submit' value='<%=getTran("web","save",sWebLanguage) %>'/>
</form>
