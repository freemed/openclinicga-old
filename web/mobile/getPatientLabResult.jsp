<%@include file="/mobile/validatePatient.jsp"%>

<table width='100%'>
	<tr><td colspan='5' bgcolor='peachpuff'><%=getTran("mobile","labResult",activeUser) %></td></tr>
	<%
	TransactionVO transaction = MedwanQuery.getInstance().loadTransaction(Integer.parseInt(request.getParameter("serverid")),Integer.parseInt(request.getParameter("transactionid")));
	if(transaction!=null){
		out.println("<tr><td>"+new SimpleDateFormat("dd/MM/yyyy").format(transaction.getUpdateTime())+"</td><td colspan='4'>ID: "+transaction.getUid()+"</td></tr>");
		Hashtable labresult = RequestedLabAnalysis.getLabAnalysesForLabRequest(Integer.parseInt(request.getParameter("serverid")),Integer.parseInt(request.getParameter("transactionid")));
	  
	   	Enumeration e = labresult.keys();
	   	while(e.hasMoreElements()){
		   	String analysisCode = (String)e.nextElement();
		   	RequestedLabAnalysis analysis = (RequestedLabAnalysis)labresult.get(analysisCode);
		   	out.println("<tr><td>"+analysisCode+"</td><td>"+LabAnalysis.labelForCode(analysisCode,activeUser.person.language)+"</td><td>"+analysis.getResultValue()+"</td><td>"+analysis.getResultUnit()+"</td><td>"+analysis.getResultModifier()+"</td></tr>");
	   	}
	}
	   
	%>
</table>