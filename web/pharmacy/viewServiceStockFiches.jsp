<%@page import="be.openclinic.pharmacy.*,be.openclinic.finance.*,java.text.*"%>
<%@include file="/includes/validateUser.jsp"%>
<%@page errorPage="/includes/error.jsp"%>

<%=checkPermission("pharmacy.productstockfiche","all",activeUser)%>
<%=sJSSORTTABLE%>
<%
	long lmonth = 1000 * 3600 * 24 ;
	lmonth=lmonth*32;
	java.util.Date date = new java.util.Date(ScreenHelper.parseDate("01/"+new SimpleDateFormat("MM/yyyy").format(new java.util.Date())).getTime());
	String year = request.getParameter("year");
	String month = request.getParameter("month");
	if(year!=null && month!=null){
		date = new java.util.Date(ScreenHelper.parseDate("01/"+month+"/"+year).getTime());
	}
	else{
		year = new SimpleDateFormat("yyyy").format(date);
		month = new SimpleDateFormat("MM").format(date);
	}
%>
<form name='transactionForm' method='post'>
<table cellspadding="1" cellspacing="0" class="list" width="100%">
	<tr>
		<td class='admin' width="50"><%=getTran("web","year",sWebLanguage) %>&nbsp;</td>
		<td class='admin2' width="70">
			<select name='year' id='year'>
				<%
					for (int n=0;n<20;n++){
						int y=Integer.parseInt(new SimpleDateFormat("yyyy").format(new java.util.Date()))-n;
						out.println("<option value='"+y+"' "+(year.equalsIgnoreCase(y+"")?"selected":"")+">"+y+"</option>");
					}
				%>
			</select>
		</td>
		<td class='admin' width="50"><%=getTran("web","month",sWebLanguage) %>&nbsp;</td>
		<td class='admin2' width="70">
			<select name='month' id='month'>
				<%
					for (int n=1;n<13;n++){
						out.println("<option value='"+n+"' "+(n==Integer.parseInt(month)?"selected":"")+">"+n+"</option>");
					}
				%>
			</select>
		</td>
		<td class='admin2' width="*"><input type='submit' name='submit' class="button" value='<%=getTran("web","find",sWebLanguage) %>'/></td>
	</tr>
</table>
</form>
<table width='100%'>
	<tr class='admin'>
		<td><%=getTran("web","productstock",sWebLanguage) %></td>
		<td><center><%=getTran("web","packageunits",sWebLanguage) %></center></td>
		<td><center><%=getTran("web","startstock",sWebLanguage) %></center></td>
		<td><center><%=getTran("web","outvisits",sWebLanguage) %></center></td>
		<td><center><%=getTran("web","outadmissions",sWebLanguage) %></center></td>
		<td><center><%=getTran("web","outother",sWebLanguage) %></center></td>
		<td><center><%=getTran("web","outtotal",sWebLanguage) %></center></td>
		<td><center><%=getTran("web","in",sWebLanguage) %></center></td>
		<td><center><%=getTran("web","endstock",sWebLanguage) %></center></td>
		<td><center><%=getTran("web","cost",sWebLanguage) %></center></td>
		<td><center><%=getTran("web","sellingprice",sWebLanguage) %></center></td>
		<td><center><%=getTran("web","sold.value",sWebLanguage) %></center></td>
		<td><center><%=getTran("web","stock.value.cost",sWebLanguage) %></center></td>
		<td><center><%=getTran("web","stock.value.sell",sWebLanguage) %></center></td>
	</tr>
<%
	String sFindServiceStockUid=request.getParameter("FindServiceStockUid");
	ServiceStock serviceStock = ServiceStock.get(sFindServiceStockUid);
	Vector productStocks = serviceStock.getProductStocks();
	int start,incoming,outgoingvisits,outgoingadmissions,outgoing;
	for(int n=0; n<productStocks.size();n++){
		ProductStock productStock = (ProductStock)productStocks.elementAt(n);
		if(productStock.getProduct()!=null){
			start = productStock.getLevel(date);
			incoming = productStock.getTotalUnitsInForMonth(date);
			outgoingvisits = productStock.getTotalVisitUnitsOutForMonth(date);
			outgoingadmissions = productStock.getTotalAdmissionUnitsOutForMonth(date);
			outgoing = productStock.getTotalUnitsOutForMonth(date);
			double buyingprice=productStock.getProduct().getUnitPrice();
			double sellingprice=0;
			if(productStock.getProduct().getPrestationcode()!=null && productStock.getProduct().getPrestationcode().length()>0){
				Prestation prestation = Prestation.get(productStock.getProduct().getPrestationcode());
				if(prestation!=null){
					sellingprice = prestation.getPrice()*productStock.getProduct().getPrestationquantity();
				}
			}
			DecimalFormat priceformat=new DecimalFormat(MedwanQuery.getInstance().getConfigString("priceFormat","#"));
			out.println("<tr><td class='admin' nowrap>"+productStock.getProduct().getName()+"</td><td class='admin2'><center>"+productStock.getProduct().getPackageUnits()+" "+getTran("product.unit",productStock.getProduct().getUnit(),sWebLanguage)+"</center></td><td class='admin2'><center><b>"+start+"</b></center></td><td class='admin2'><center>-"+outgoingvisits+"</center></td><td class='admin2'><center>-"+outgoingadmissions+"</td><td class='admin2'>-"+(outgoing-outgoingvisits-outgoingadmissions)+"</center></td><td class='admin2'><b><center>-"+outgoing+"</center></b></td><td class='admin2'><b><center>"+incoming+"</center></b></td><td class='admin2'><b><center>"+(start+incoming-outgoing)+"</center></b></td><td class='admin2'><center>"+priceformat.format(buyingprice)+"</center></td><td class='admin2'><center>"+priceformat.format(sellingprice)+"</center></td><td class='admin2'><center>"+priceformat.format(buyingprice*outgoing)+"</center></td><td class='admin2'><center>"+priceformat.format((start+incoming-outgoing)*buyingprice)+"</center></td><td class='admin2'><center>"+priceformat.format((start+incoming-outgoing)*sellingprice)+"</center></td></tr>");
		}
	}
	
%>
</table>