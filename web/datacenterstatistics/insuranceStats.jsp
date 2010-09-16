<%@include file="/includes/validateUser.jsp"%>
<%@ page import="java.sql.Statement" %>
<%@ page import="be.openclinic.statistics.HospitalStats" %>
<%@ page import="be.openclinic.statistics.BaseChart" %>
<%@ page import="be.openclinic.statistics.XYValue" %>
<%@ page import="be.mxs.common.util.system.StatFunctions" %>
<%@ page import="be.openclinic.common.KeyValue" %>
<%@ page import="java.text.DecimalFormat" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="java.util.Enumeration,java.text.SimpleDateFormat" %>
<table width='100%'>
<tr class='admin'>
	<td colspan='3'><%=getTran("hospital.statistics","inpatients",sWebLanguage)%></td>
</tr>
<tr class='admin'>
	<td><%=getTran("hospital.statistics","insurar",sWebLanguage)%></td>
	<td># <%=getTran("hospital.statistics","admissions",sWebLanguage)%></td>
	<td>% <%=getTran("hospital.statistics","total.admissions",sWebLanguage)%></td>
</tr>

<%
	KeyValue[] kv = HospitalStats.getInsuranceCasesBasic(new SimpleDateFormat("dd/MM/yyyy").parse(request.getParameter("start")),new SimpleDateFormat("dd/MM/yyyy").parse(request.getParameter("end")),"admission");
	double ta=0;
	for(int n=0;n<kv.length;n++){
		ta+=Double.parseDouble(kv[n].getValue());
	}
	for(int n=0;n<kv.length;n++){
		out.println("<tr><td>"+kv[n].getKey()+"</td><td>"+kv[n].getValue()+"</td><td>"+new DecimalFormat("#.#").format(100*Double.parseDouble(kv[n].getValue())/ta)+"%</td></tr>");
	}
%>
<tr>
	<td colspan='3' class='list'>&nbsp;</td>
</tr>
<tr>
	<td colspan='3' class='list'><hr/></td>
</tr>
<tr>
	<td colspan='3' class='list'>&nbsp;</td>
</tr>
<tr class='admin'>
	<td colspan='3'><%=getTran("hospital.statistics","outpatients",sWebLanguage)%></td>
</tr>
<tr class='admin'>
	<td><%=getTran("hospital.statistics","insurar",sWebLanguage)%></td>
	<td># <%=getTran("hospital.statistics","visits",sWebLanguage)%></td>
	<td>% <%=getTran("hospital.statistics","total.visits",sWebLanguage)%></td>
</tr>
<%
	kv = HospitalStats.getInsuranceCasesBasic(new SimpleDateFormat("dd/MM/yyyy").parse(request.getParameter("start")),new SimpleDateFormat("dd/MM/yyyy").parse(request.getParameter("end")),"visit");
	for(int n=0;n<kv.length;n++){
		ta+=Double.parseDouble(kv[n].getValue());
	}
	for(int n=0;n<kv.length;n++){
		out.println("<tr><td>"+kv[n].getKey()+"</td><td>"+kv[n].getValue()+"</td><td>"+new DecimalFormat("#.#").format(100*Double.parseDouble(kv[n].getValue())/ta)+"%</td></tr>");
	}
%>
</table>


