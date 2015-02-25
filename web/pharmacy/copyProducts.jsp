<%@page import="be.openclinic.pharmacy.*"%>
<%@include file="/includes/validateUser.jsp"%>
<%
	String sourceStockUid=request.getParameter("ServiceStockUid");
	ServiceStock sourceStock = ServiceStock.get(sourceStockUid);
	boolean bClose=false;
	if(request.getParameter("submit")!=null){
		bClose=true;
		String destinationStockUid=request.getParameter("DestinationStockUid");
		ServiceStock destinationStock = ServiceStock.get(destinationStockUid);
		Vector destinationProducts = destinationStock.getProductStocks();
		HashSet dp = new HashSet();
		for(int n=0;n<destinationProducts.size();n++){
			ProductStock destinationProduct = (ProductStock)destinationProducts.elementAt(n);
			dp.add(destinationProduct.getProduct().getUid());
		}
		Vector products = sourceStock.getProductStocks();
		for(int n=0;n<products.size();n++){
			ProductStock productStock = (ProductStock)products.elementAt(n);
			if(!dp.contains(productStock.getProductUid())){
				ProductStock newStock = new ProductStock();
				newStock.setUid("-1");
				newStock.setBegin(destinationStock.getBegin());
				newStock.setLevel(0);
				newStock.setCreateDateTime(new java.util.Date());
				newStock.setMaximumLevel(productStock.getMaximumLevel());
				newStock.setMinimumLevel(productStock.getMinimumLevel());
				newStock.setOrderLevel(productStock.getOrderLevel());
				newStock.setProductUid(productStock.getProductUid());
				newStock.setServiceStockUid(destinationStockUid);
				newStock.setSupplierUid(productStock.getSupplierUid());
				newStock.setUpdateUser(activeUser.getUid());
				newStock.setUpdateDateTime(new java.util.Date());
				newStock.setDefaultImportance(productStock.getDefaultImportance());
				newStock.setVersion(1);
				newStock.store();
			}
		}
	}
%>
<form name='transactionForm' method='post'>
	<input type='hidden' name='sourceStockUid' id='sourceStockUid' value='<%=sourceStockUid%>'/>
	<table width='100%'>
		<tr>
			<td class='admin'><%=getTran("web","source",sWebLanguage) %></td>
			<td class='admin2'><%=sourceStock.getName() %></td>
		</tr>
		<tr>
			<td class='admin'><%=getTran("web","destination",sWebLanguage) %></td>
			<td class='admin2'>
				<select name='DestinationStockUid' id='DestinationStockUid'>
				<%
					Vector stocks=ServiceStock.getStocksByUserWithEmpty(activeUser.userid);
					for(int n=0;n<stocks.size();n++){
						ServiceStock destinationStock = (ServiceStock)stocks.elementAt(n);
						if(!destinationStock.getUid().equals(sourceStockUid)){
							out.println("<option value='"+destinationStock.getUid()+"'>"+destinationStock.getName()+"</option>");
						}
					}
				%>
				</select>
			</td>
		</tr>
		<tr>
			<td class='admin' colspan='2'><input type='submit' name='submit' value='<%=getTranNoLink("web","copy",sWebLanguage)%>'/></td>
		</tr>
	</table>
</form>
		<%
			if(bClose){
		%>
			<script>
				window.opener.location.reload();
				window.close();
			</script>
		<%
			}
		%>
