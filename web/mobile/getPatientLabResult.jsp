<%@include file="/mobile/_common/head.jsp"%>

<table class="list" padding="0" cellspacing="1" width="<%=sTABLE_WIDTH%>">
	<tr class="admin"><td colspan="5"><%=getTran("mobile","labdata",activeUser)%></td></tr>
	<%
		TransactionVO transaction = MedwanQuery.getInstance().loadTransaction(Integer.parseInt(request.getParameter("serverid")),
				                                                              Integer.parseInt(request.getParameter("transactionid")));
		if(transaction!=null){
			out.println("<tr>"+
		                  "<td class='admin2' colspan='4'><b>"+stdDateFormat.format(transaction.getUpdateTime())+"</b> [ID: "+transaction.getUid()+"]</td>"+
		                 "</tr>");
			
			// list analyses
			Hashtable labresult = RequestedLabAnalysis.getLabAnalysesForLabRequest(Integer.parseInt(request.getParameter("serverid")),
					                                                               Integer.parseInt(request.getParameter("transactionid")));
			SortedSet set = new TreeSet();
		   	Enumeration e = labresult.keys();
		   	while(e.hasMoreElements()){
		   		set.add(e.nextElement());
		   	}		
			
		   	Iterator iterator = set.iterator();
		   	RequestedLabAnalysis analysis;
		   	String analysisCode, sClass = "1";
		   	
		   	while(iterator.hasNext()){
			   	analysisCode = (String)iterator.next();
			   	analysis = (RequestedLabAnalysis)labresult.get(analysisCode);
	    		
		        // alternate row-style
		        if(sClass.length()==0) sClass = "1";
		        else                   sClass = "";
		        
			   	out.print("<tr class='list"+sClass+"'>"+
			   	           "<td>"+LabAnalysis.labelForCode(analysisCode,activeUser.person.language)+"</td>"+
			   	           "<td>"+analysis.getResultValue()+"</td><td>"+analysis.getResultUnit()+"</td>"+
			   			   "<td>"+analysis.getResultModifier()+"</td>"+
			   	          "</tr>");
		   	}
		}	   
	%>
</table>
			
<%-- BUTTONS --%>
<%=alignButtonsStart()%>
	<input type="button" class="button" name="backButton" onclick="showPatientMenu();" value="<%=getTranNoLink("web","back",activeUser)%>">
<%=alignButtonsStop()%>
			
<%@include file="/mobile/_common/footer.jsp"%>