<%@page import="be.openclinic.datacenter.DatacenterHelper" %>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>
<head>
    <%=sCSSNORMAL%>
    <%=sCSSMODALBOX%>
    <%//=sCSSOPERA%>
    <%=sJSTOGGLE%>
    <%=sJSFORM%>
    <%=sJSPOPUPMENU%>
    <%=sJSPROTOTYPE%>
    <%=sJSSCRPTACULOUS%>
    <%=sJSMODALBOX%>
    <%=sIcon%>
</head>

<form name='processPatientRecordForm' id='processPatientRecordForm' method='post'>
	<table width='100%'>
		<%
			Vector records=DatacenterHelper.getUnprocessedPatientRecords(Integer.parseInt(request.getParameter("serverid")));
			for(int n=0;n<records.size();n++){
				AdminPerson person = (AdminPerson)records.elementAt(n);
				out.println("<tr><td class='admin2'><input type='checkbox' checked name='cbp."+request.getParameter("serverid")+"."+person.personid+"'/> "+person.getUid()+"</td><td class='admin'>"+person.lastname.toUpperCase()+", "+person.firstname+"</td><td class='admin2'>°"+person.dateOfBirth+"</td><td class='admin2'>"+person.gender.toUpperCase()+"</td></tr>");
			}
		%>
		<tr><td colspan='4'>
			<input class='button' type='button' name='printcards' value='<%=getTranNoLink("web","printcards",sWebLanguage)%>' onclick='printcardsfunction();'/>
			<input class='button' type='button' name='setprocessed' value='<%=getTranNoLink("web","setprocessed",sWebLanguage)%>' onclick='setprocessedfunction();'/>
		</td></tr>
	</table>
	<input type='hidden' name='serverid' value='<%=request.getParameter("serverid") %>'/>
</form>

<script>
function printcardsfunction(){
	document.getElementById("processPatientRecordForm").action='datacenter/createPatientCards.jsp';
	document.getElementById("processPatientRecordForm").submit();
}
function setprocessedfunction(){
	document.getElementById("processPatientRecordForm").action='datacenter/setProcessedRecords.jsp';
	document.getElementById("processPatientRecordForm").submit();
}
</script>