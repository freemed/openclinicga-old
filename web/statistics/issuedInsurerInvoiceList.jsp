<%@include file="/includes/validateUser.jsp"%>
<%@page import="be.openclinic.finance.*,
                java.util.Hashtable,
                java.util.Vector,
                java.util.Collections,
                java.text.DecimalFormat"%>
<table width="100%">
<tr class='admin'>
	<td><%=getTran("web","date",sWebLanguage) %></td>
	<td><%=getTran("web","invoicenumber",sWebLanguage) %></td>
	<td><%=getTran("web","insurar",sWebLanguage) %></td>
	<td><%=getTran("web","amount",sWebLanguage) %></td>
</tr>
<%
	Vector invoices = InsurarInvoice.searchInvoices(request.getParameter("start"),request.getParameter("end"), "", "", "");
	for(int n=invoices.size()-1;n>=0;n--){
		InsurarInvoice invoice = (InsurarInvoice)invoices.elementAt(n);
		if(invoice!=null){
			out.println("<tr><td>"+new SimpleDateFormat("dd/MM/yyyy").format(invoice.getDate())+"</td>");
			out.println("<td>"+invoice.getUid()+"</td>");
			out.println("<td>"+(invoice.getInsurar()!=null?invoice.getInsurar().getName():"?")+"</td>");
			out.println("<td>"+new DecimalFormat(MedwanQuery.getInstance().getConfigString("priceFormat")).format(invoice.getAmount())+" "+MedwanQuery.getInstance().getConfigString("currency")+"</td></tr>");
		}
	}
%>
</table>