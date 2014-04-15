<%@include file="/mobile/validateUser.jsp"%>

<%
String action = ScreenHelper.checkString(request.getParameter("search"));
String patientname = ScreenHelper.checkString(request.getParameter("patientname"));
String patientfirstname = ScreenHelper.checkString(request.getParameter("patientfirstname"));
String patientdateofbirth = ScreenHelper.checkString(request.getParameter("patientdateofbirth"));
String patientpersonid = ScreenHelper.checkString(request.getParameter("patientpersonid"));
try{
	patientpersonid=Integer.parseInt(patientpersonid)+"";
}
catch(Exception e){
	e.printStackTrace();
}
String patientservice = ScreenHelper.checkString(request.getParameter("patientservice"));

List patients = new ArrayList();
if(action.length()>0){
	if(patientservice.length()==0 || patientpersonid.length()>0){
		if(patientname.length()>0 ||patientfirstname.length()>0 ||patientpersonid.length()>0 ||patientdateofbirth.length()>0 ||patientservice.length()>0){
			patients = AdminPerson.getAllPatients("","","",patientname,patientfirstname,patientdateofbirth,patientpersonid,"",20);
		}
	}
	else {
		Vector servicepatients = AdminPerson.getPatientsAdmittedInService(patientservice);
		for(int n=0;n<servicepatients.size();n++){
			AdminPerson patient = AdminPerson.getAdminPerson((String)servicepatients.elementAt(n));
			if(patientname.length()>0 && !patient.lastname.startsWith(patientname)){
				continue;
			}
			if(patientfirstname.length()>0 && !patient.firstname.startsWith(patientfirstname)){
				continue;
			}
			if(patientdateofbirth.length()>0 && !patient.dateOfBirth.equalsIgnoreCase(patientdateofbirth)){
				continue;
			}
			patients.add(patient);
		}
	}
}

if(patients.size()==1){
	AdminPerson patient = (AdminPerson)patients.get(0);
	out.print("<script>window.location.href='selectPatient.jsp?personid="+patient.personid+"';</script>");
	out.flush();
}
else if(patients.size()>0){
	out.print("<table>");
	//Show list of patients
	Iterator patientlist = patients.iterator();
	while(patientlist.hasNext()){
		AdminPerson patient = (AdminPerson)patientlist.next();
		out.print("<tr><td><a href='selectPatient.jsp?personid="+patient.personid+"'>"+patient.lastname+"</a></td><td>"+patient.firstname+"</td><td>"+patient.dateOfBirth+"</td></tr>");
	}
	out.print("<tr><td colspan='3'><hr/></td></tr></table>");
	out.print("<a href='searchPatient.jsp'>"+getTran("mobile","newsearch",activeUser)+"</a>");
}
else {
	if(action.length()>1){
		out.print(getTran("web","nopatientsfound",activeUser));
	}
%>
	<form name="searchPatient" method="post">
		<table>
			<tr><td><%=getTran("web","personid",activeUser) %></td><td><input name="patientpersonid" type="text" size="10"/></td></tr>
			<tr><td><%=getTran("web","name",activeUser) %></td><td><input name="patientname" type="text" size="20"/></td></tr>
			<tr><td><%=getTran("web","firstname",activeUser) %></td><td><input name="patientfirstname" type="text" size="20"/></td></tr>
			<tr><td><%=getTran("web","dateofbirth",activeUser) %></td><td><input name="patientdateofbirth" type="text" size="10"/></td></tr>
			<tr><td><%=getTran("web","service",activeUser) %></td><td><input name="patientservice" type="text" size="20"/></td></tr>
		</table>
		<input type="submit" name="search" value="<%=getTran("web","search",activeUser)%>"/>
	</form>
<%
}
%>
