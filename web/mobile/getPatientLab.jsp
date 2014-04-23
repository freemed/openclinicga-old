<%@include file="/mobile/_common/head.jsp"%>

<table class="list" padding="0" cellspacing="1" width="<%=sTABLE_WIDTH%>">
	<tr class="admin"><td colspan="2"><%=getTran("mobile","labdata",activeUser)%></td></tr>
	
<%
	String sMinDate = stdDateFormat.format(new java.util.Date().getTime()-dataFreshness);
	Vector analyses = RequestedLabAnalysis.find("","",activePatient.personid,"","","","","","","","","",sMinDate,"","","",false,"");
	
	if(analyses.size() > 0){
		SortedMap requests = new TreeMap();
		RequestedLabAnalysis analysis;
		for(int n=0; n<analyses.size(); n++){
			analysis = (RequestedLabAnalysis)analyses.elementAt(n);
			requests.put(stdDateFormat.format(analysis.getRequestDate())+"|"+analysis.getServerId()+"|"+analysis.getTransactionId()+"|"+analysis.getRequestUserId(),"1");	
		}
		
		Iterator iterator = requests.keySet().iterator();
		String sClass = "1";
		
		while(iterator.hasNext()){
			String key = (String)iterator.next();

	        // alternate row-style
	        if(sClass.length()==0) sClass = "1";
	        else                   sClass = "";
			
			out.print("<tr class='list"+sClass+"'>"+
			           "<td width='80'><a href='getPatientLabResult.jsp?serverid="+key.split("\\|")[1]+"&transactionid="+key.split("\\|")[2]+"'>"+key.split("\\|")[0]+"</a></td>"+
			           "<td>"+MedwanQuery.getInstance().getUserName(Integer.parseInt(key.split("\\|")[3]))+"</td>"+
			          "</tr>");
		}
	}
	else{
		out.print("<tr><td colspan='2'><i>"+getTran("web","noData",activeUser)+"</i></td></tr>");
	}
%>
</table>
			
<%-- BUTTONS --%>
<%=alignButtonsStart()%>
	<input type="button" class="button" name="backButton" onclick="showPatientMenu();" value="<%=getTranNoLink("web","back",activeUser)%>">
<%=alignButtonsStop()%>
		 
<%@include file="/mobile/_common/footer.jsp"%>