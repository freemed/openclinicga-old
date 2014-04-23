<%@include file="/mobile/_common/head.jsp"%>

<table class="list" padding="0" cellspacing="1" width="<%=sTABLE_WIDTH%>">
	<tr class="admin"><td><%=getTran("mobile","clinicaldata",activeUser)%></td></tr>
<%
	String sMinDate = stdDateFormat.format(new java.util.Date().getTime()-dataFreshness);
	Vector transactions = MedwanQuery.getInstance().getTransactionsAfter(Integer.parseInt(activePatient.personid),new java.util.Date(new java.util.Date().getTime()-dataFreshness));
	
	if(transactions.size() > 0){
		SortedMap requests = new TreeMap();
		
		TransactionVO transaction;
		String sSecondRow = "";
		for(int n=0; n<transactions.size(); n++){
			transaction = (TransactionVO)transactions.elementAt(n);
			
			// second row : trantype and user
			sSecondRow = "<tr><td class='admin2'>"+getTran("web.occup",transaction.getTransactionType(),activeUser)+"</td></tr>";
			
			// first row : date
			if(transaction.getTransactionType().equalsIgnoreCase(ITEM_PREFIX+"TRANSACTION_TYPE_MIR2")){
				out.print("<tr><td class='admin'><a href='getPatientImagingResult.jsp?serverid="+transaction.getServerId()+"&transactionid="+transaction.getTransactionId()+"'><b>"+stdDateFormat.format(transaction.getUpdateTime())+"</b></a> ("+transaction.getUser().personVO.getFullName()+")</td></tr>"+sSecondRow);
			}
			else if(transaction.getTransactionType().equalsIgnoreCase(ITEM_PREFIX+"TRANSACTION_TYPE_LAB_REQUEST")){
				out.print("<tr><td class='admin'><a href='getPatientLabResult.jsp?serverid="+transaction.getServerId()+"&transactionid="+transaction.getTransactionId()+"'><b>"+stdDateFormat.format(transaction.getUpdateTime())+"</b></a> ("+transaction.getUser().personVO.getFullName()+")</td></tr>"+sSecondRow);
			}
			else{
				out.print("<tr><td class='admin'><b>"+stdDateFormat.format(transaction.getUpdateTime())+"</b> ("+transaction.getUser().personVO.getFullName()+")</td></tr>"+sSecondRow);
			}
		}
	}
	else{
		out.print("<tr><i>"+getTran("web","noData",activeUser)+"</i></td></tr>");
	}
%>
</table>
			
<%-- BUTTONS --%>
<%=alignButtonsStart()%>
	<input type="button" class="button" name="backButton" onclick="doBack();" value="<%=getTranNoLink("web","back",activeUser)%>">
<%=alignButtonsStop()%>
		 
<script>
  function doBack(){
	window.location.href = "selectPatient.jsp?personid=<%=activePatient.personid%>&ts=<%=getTs()%>";
  }
</script>
			
<%@include file="/mobile/_common/footer.jsp"%>