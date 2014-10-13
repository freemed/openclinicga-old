<%@include file="/includes/validateUser.jsp"%>
<%@include file="/util/progressbar.jsp"%>
<head>
    <%=sJSFORM%>
    <%=sCSSNORMAL%>
</head>
<%
	String reportid=getTs();
%>

<form name='reportForm' id='reportForm' method="post" action='<c:url value='/datacenterstatistics/printHospitalReport.jsp'/>'>
	<input type='hidden' name='reportid' value='<%= reportid %>'/>
	<input type='hidden' name='start' value='<%= request.getParameter("start") %>'/>
	<input type='hidden' name='end' value='<%= request.getParameter("end") %>'/>
	<table width="100%" class="list">
		<tr>
			<td><input type='checkbox' name='chapter1'/><%= ScreenHelper.getTranNoLink("hospital.statistics", "base.activity.information", sWebLanguage)%></td>
		</tr>
		<tr>
			<td><input type='checkbox' name='chapter2'/><%= ScreenHelper.getTranNoLink("hospital.statistics", "base.outcome.information", sWebLanguage)%></td>
		</tr>
		<tr>
			<td><input type='checkbox' name='chapter3'/><%= ScreenHelper.getTranNoLink("hospital.statistics", "pathology.profile", sWebLanguage)%></td>
		</tr>
		<tr>
			<td><input type='checkbox' name='chapter4'/><%= ScreenHelper.getTranNoLink("hospital.statistics", "comorbidity.profile", sWebLanguage)%></td>
		</tr>
		<tr>
			<td><input type='checkbox' name='chapter5'/><%= ScreenHelper.getTranNoLink("hospital.statistics", "financial.profile", sWebLanguage)%></td>
		</tr>
		<tr>
			<td><input type='checkbox' name='chapter6'/><%= ScreenHelper.getTranNoLink("hospital.statistics", "insurance.profile", sWebLanguage)%></td>
		</tr>
		<tr>
			<td><input class='button' type='button' onclick="printHospitalReport();" name='dosubmit' value='<%= ScreenHelper.getTranNoLink("web", "execute", sWebLanguage)%>'/></td>
		</tr>
	</table>
</form>

<script>
	function printHospitalReport(){
		startProgress('<%=reportid%>');
		reportForm.submit();
	}
	makeProgressBar();
</script>