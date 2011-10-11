<%@include file="/mobile/validatePatient.jsp"%>

<table width='100%'>
	<tr><td colspan='2' bgcolor='peachpuff'><%=getTran("mobile","labdata",activeUser) %></td></tr>
<%
	long week=7*24*3600*1000;
	String sMinDate=new SimpleDateFormat("dd/MM/yyyy").format(new Date().getTime()-week);
	Vector analysis = RequestedLabAnalysis.find("","",activePatient.personid,"","","","","","","","","",sMinDate,"","","",false,"");
	SortedMap requests = new TreeMap();
	for(int n=0;n<analysis.size();n++){
		RequestedLabAnalysis requestedLabAnalysis = (RequestedLabAnalysis)analysis.elementAt(n);
		requests.put(new SimpleDateFormat("dd/MM/yyyy").format(requestedLabAnalysis.getRequestDate())+"|"+requestedLabAnalysis.getServerId()+"|"+requestedLabAnalysis.getTransactionId()+"|"+requestedLabAnalysis.getRequestUserId(),"1");	
	}
	Iterator iterator = requests.keySet().iterator();
	while(iterator.hasNext()){
		String key = (String)iterator.next();
		out.println("<tr><td><a href='getPatientLabResult.jsp?serverid="+key.split("\\|")[1]+"&transactionid="+key.split("\\|")[2]+"'>"+key.split("\\|")[0]+"</a></td><td>"+MedwanQuery.getInstance().getUserName(Integer.parseInt(key.split("\\|")[3]))+"</td></tr>");
	}
%>
</table>