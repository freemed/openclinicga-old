<%@include file="/includes/validateUser.jsp"%>
<%@page import="be.openclinic.datacenter.DatacenterHelper,be.mxs.common.util.db.MedwanQuery" %>
<table width='100%'>
<%
	String serverid=request.getParameter("serverid");
	String period=request.getParameter("period");
	java.util.Vector diagnoses = DatacenterHelper.getDiagnoses(Integer.parseInt(serverid),period,"KPGS");
	for(int n=0;n<diagnoses.size();n++){
		String diag=(String)diagnoses.elementAt(n);
		out.print("<tr><td class='admin'>"+diag.split(";")[0].toUpperCase()+"</td><td class='admin'>"+MedwanQuery.getInstance().getCodeTran("icd10code"+diag.split(";")[0],sWebLanguage)+"</td><td class='admin2'><a href='javascript:diagnosisGraph(\""+diag.split(";")[0]+"\")'>"+diag.split(";")[1]+"</a></td></tr>");
	}
%>
</table>