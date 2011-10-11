<%@include file="/mobile/validatePatient.jsp"%>

<table width='100%'>
	<tr><td colspan='3' bgcolor='peachpuff'><%=getTran("mobile","clinicaldata",activeUser) %></td></tr>
<%
	long week=7*24*3600*1000;
	String sMinDate=new SimpleDateFormat("dd/MM/yyyy").format(new Date().getTime()-week);
	Vector transactions = MedwanQuery.getInstance().getTransactionsAfter(Integer.parseInt(activePatient.personid),new Date(new Date().getTime()-week));
	SortedMap requests = new TreeMap();
	for(int n=0;n<transactions.size();n++){
		TransactionVO transaction = (TransactionVO)transactions.elementAt(n);
		if(transaction.getTransactionType().equalsIgnoreCase("be.mxs.common.model.vo.healthrecord.IConstants.TRANSACTION_TYPE_MIR2")){
			out.print("<tr><td><a href='getPatientImagingResult.jsp?serverid="+transaction.getServerId()+"&transactionid="+transaction.getTransactionId()+"'>"+new SimpleDateFormat("dd/MM/yyyy").format(transaction.getUpdateTime())+"</a></td><td>"+getTran("web.occup",transaction.getTransactionType(),activeUser)+"</td><td>"+transaction.getUser().personVO.getFullName()+"</td></tr>");
		}
		else if(transaction.getTransactionType().equalsIgnoreCase("be.mxs.common.model.vo.healthrecord.IConstants.TRANSACTION_TYPE_LAB_REQUEST")){
			out.print("<tr><td><a href='getPatientLabResult.jsp?serverid="+transaction.getServerId()+"&transactionid="+transaction.getTransactionId()+"'>"+new SimpleDateFormat("dd/MM/yyyy").format(transaction.getUpdateTime())+"</a></td><td>"+getTran("web.occup",transaction.getTransactionType(),activeUser)+"</td><td>"+transaction.getUser().personVO.getFullName()+"</td></tr>");
		}
		else {
			out.print("<tr><td>"+new SimpleDateFormat("dd/MM/yyyy").format(transaction.getUpdateTime())+"</td><td>"+getTran("web.occup",transaction.getTransactionType(),activeUser)+"</td><td>"+transaction.getUser().personVO.getFullName()+"</td></tr>");
		}
	}
%>
</table>