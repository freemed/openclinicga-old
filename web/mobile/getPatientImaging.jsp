<%@include file="/mobile/validatePatient.jsp"%>

<table width='100%'>
	<tr><td colspan='2' bgcolor='peachpuff'><b><%=getTran("mobile","imagingdata",activeUser) %></b></td><td colspan='1' bgcolor='peachpuff'><%=getTran("web","protocol",activeUser) %></td><td colspan='1' bgcolor='peachpuff'><%=getTran("web","emergency",activeUser) %></td></tr>
<%
	long week=7*24*3600*1000;
	String sMinDate=new SimpleDateFormat("dd/MM/yyyy").format(new Date().getTime()-week);
	Vector transactions = MedwanQuery.getInstance().getTransactionsByType(Integer.parseInt(activePatient.personid),"be.mxs.common.model.vo.healthrecord.IConstants.TRANSACTION_TYPE_MIR2");
	SortedMap requests = new TreeMap();
	for(int n=0;n<transactions.size();n++){
		TransactionVO transaction = (TransactionVO)transactions.elementAt(n);
		if(!transaction.getUpdateTime().before(new Date(new Date().getTime()-week))){
			String type="?";
			ItemVO item = transaction.getItem("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_MIR2_TYPE");
			if(item!=null && item.getValue()!=null && item.getValue().length()>0){
				type=item.getValue();
				type=getTran("mir_type",type,activeUser);
				item = transaction.getItem("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_MIR2_SPECIFICATION");
				if(item!=null && item.getValue()!=null && item.getValue().length()>0){
					type = type + " - " + item.getValue();
				}
			}
			String protocol = "-";
			item=transaction.getItem("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_MIR2_PROTOCOL");
			if(item!=null && item.getValue()!=null && item.getValue().length()>0){
				protocol="+";
			}
			String emergency = "-";
			item=transaction.getItem("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OTHER_REQUESTS_URGENT");
			if(item!=null && item.getValue()!=null && item.getValue().length()>0){
				emergency="+";
			}
			requests.put(new SimpleDateFormat("dd/MM/yyyy").format(transaction.getUpdateTime())+"|"+transaction.getServerId()+"|"+transaction.getTransactionId()+"|"+transaction.getUser().personVO.getFullName()+"|"+type+"|"+protocol+"|"+emergency,"1");	
		}
	}
	Iterator iterator = requests.keySet().iterator();
	while(iterator.hasNext()){
		String key = (String)iterator.next();
		out.println("<tr><td colspan='4'><a href='getPatientImagingResult.jsp?serverid="+key.split("\\|")[1]+"&transactionid="+key.split("\\|")[2]+"'>"+key.split("\\|")[0]+"</a></td></tr><tr><td colspan='2'>"+key.split("\\|")[4]+"<br/>("+key.split("\\|")[3]+")</td><td>"+key.split("\\|")[5]+"</td><td>"+key.split("\\|")[6]+"</td></tr>");
	}

%>
</table>