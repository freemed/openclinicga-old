<%@include file="/mobile/_common/head.jsp"%>

<table class="list" padding="0" cellspacing="1" width="<%=sTABLE_WIDTH%>">
	<tr class="admin"><td colspan="4"><%=getTran("mobile","imagingdata",activeUser)%></td></tr>
	
<%
	String sMinDate = stdDateFormat.format(new java.util.Date().getTime()-dataFreshness);
	Vector transactions = MedwanQuery.getInstance().getTransactionsByType(Integer.parseInt(activePatient.personid),"be.mxs.common.model.vo.healthrecord.IConstants.TRANSACTION_TYPE_MIR2");
	SortedMap requests = new TreeMap();
	
	if(transactions.size() > 0){
		// header
        %>
        	<tr class="gray">
        		<td colspan="2"></td>
        		<td><%=getTran("web","protocol",activeUser)%></td>
        		<td><%=getTran("web","emergency",activeUser)%></td>
        	</tr>
        <%
		
		TransactionVO transaction;		
		for(int n=0; n<transactions.size(); n++){
			transaction = (TransactionVO)transactions.elementAt(n);
			
			// only recent transactions
			if(!transaction.getUpdateTime().before(new java.util.Date(new java.util.Date().getTime()-dataFreshness))){
				String type = "?";
			
			    // type
				String sItemValue = transaction.getItemValue(ITEM_PREFIX+"ITEM_TYPE_MIR2_TYPE");
				if(sItemValue.length() > 0){
					type = getTran("mir_type",sItemValue,activeUser);
					
					// specification
					sItemValue = transaction.getItemValue(ITEM_PREFIX+"ITEM_TYPE_MIR2_SPECIFICATION");
					if(sItemValue.length()>0){
						type+= " - "+sItemValue;
					}
				}
				
				// protocol
				String protocol = "-";
				sItemValue = transaction.getItemValue(ITEM_PREFIX+"ITEM_TYPE_MIR2_PROTOCOL");
				if(sItemValue.length() > 0){
					protocol = "+";
				}
				
				// emergency
				String emergency = "-";
				sItemValue = transaction.getItemValue(ITEM_PREFIX+"ITEM_TYPE_OTHER_REQUESTS_URGENT");
				if(sItemValue.length() > 0){
					emergency = "+";
				}
				
				requests.put(stdDateFormat.format(transaction.getUpdateTime())+"|"+transaction.getServerId()+"|"+transaction.getTransactionId()+"|"+transaction.getUser().personVO.getFullName()+"|"+type+"|"+protocol+"|"+emergency,"1");	
			}
		}
		
		Iterator iterator = requests.keySet().iterator();		
		while(iterator.hasNext()){
			String key = (String)iterator.next();
	        
			out.println("<tr>"+
			             "<td class='admin' colspan='4'><a href='getPatientImagingResult.jsp?serverid="+key.split("\\|")[1]+"&transactionid="+key.split("\\|")[2]+"'><b>"+key.split("\\|")[0]+"</b></a>&nbsp;&nbsp;("+key.split("\\|")[3]+")</td>"+
			            "</tr>"+
			            "<tr>"+
			             "<td colspan='2'>"+key.split("\\|")[4]+"</td><td>"+key.split("\\|")[5]+"</td><td>"+key.split("\\|")[6]+"</td>"+
			            "</tr>");
		}
	}
	else{
		out.print("<tr><td colspan='2'>&nbsp;<i>"+getTran("web","noData",activeUser)+"</i></td></tr>");
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