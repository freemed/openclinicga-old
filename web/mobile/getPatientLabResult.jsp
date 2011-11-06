<%@include file="/mobile/validatePatient.jsp"%>

<table width='100%'>
	<tr><td colspan='5' bgcolor='peachpuff'><b><%=getTran("mobile","labdata",activeUser) %></b></td></tr>
	<%
	TransactionVO transaction = MedwanQuery.getInstance().loadTransaction(Integer.parseInt(request.getParameter("serverid")),Integer.parseInt(request.getParameter("transactionid")));
	if(transaction!=null){
		out.println("<tr><td><b>"+new SimpleDateFormat("dd/MM/yyyy").format(transaction.getUpdateTime())+"</b></td><td colspan='3'>ID: "+transaction.getUid()+"</td></tr>");
		Hashtable labresult = RequestedLabAnalysis.getLabAnalysesForLabRequest(Integer.parseInt(request.getParameter("serverid")),Integer.parseInt(request.getParameter("transactionid")));
		SortedSet set = new TreeSet();
	   	Enumeration e = labresult.keys();
	   	while(e.hasMoreElements()){
	   		set.add(e.nextElement());
	   	}		
		
	   	Iterator iterator=set.iterator();
	   	while(iterator.hasNext()){
		   	String analysisCode = (String)iterator.next();
		   	RequestedLabAnalysis analysis = (RequestedLabAnalysis)labresult.get(analysisCode);
		   	out.println("<tr><td>"+LabAnalysis.labelForCode(analysisCode,activeUser.person.language)+"</td><td>"+analysis.getResultValue()+"</td><td>"+analysis.getResultUnit()+"</td><td>"+analysis.getResultModifier()+"</td></tr>");
	   	}
	}
	   
	%>
</table>