<%@ page import="be.openclinic.pharmacy.*,be.openclinic.finance.*" %>
<%@include file="/includes/validateUser.jsp"%>
<%@page errorPage="/includes/error.jsp"%>
<table>
<tr class='admin'>
	<td><%=getTran("web","prestation",sWebLanguage) %></td>
	<td><%=getTran("web","oldprice",sWebLanguage) %></td>
	<td><%=getTran("web","newprice",sWebLanguage) %></td>
	<td><%=getTran("web","result",sWebLanguage) %></td>
	<td><%=getTran("web","difference",sWebLanguage) %></td>
</tr>
<%
	Connection conn = MedwanQuery.getInstance().getOpenclinicConnection();
	PreparedStatement ps = conn.prepareStatement("select * from oc_products where oc_product_prestationcode<>'' and oc_product_prestationquantity>0 and oc_product_margin<>0");
	ResultSet rs = ps.executeQuery();
	while(rs.next()){
		Product product = Product.get(rs.getString("oc_product_serverid")+"."+rs.getString("oc_product_objectid"));
		if(product!=null){
			Prestation prestation = Prestation.get(product.getPrestationcode());
			if(prestation !=null){
				double newprice=Double.parseDouble(new DecimalFormat(MedwanQuery.getInstance().getConfigString("priceFormat","#.00")).format(product.getLastYearsAveragePrice()*(100+product.getMargin())/100).replaceAll(",", "."));
				double resultprice=newprice;
				double oldprice=prestation.getPrice();
				if(newprice<prestation.getPrice() && !product.isApplyLowerPrices()){
					resultprice=oldprice;
				}
				if(request.getParameter("storeprices")!=null){
					prestation.setPrice(newprice);
					prestation.store();
				}
				out.println("<tr><td class='admin'>"+prestation.getDescription()+"</td><td class='admin2'>"+new DecimalFormat(MedwanQuery.getInstance().getConfigString("priceFormat","#")).format(oldprice)+" "+MedwanQuery.getInstance().getConfigString("currency","EUR")+"</td><td class='admin2'>"+new DecimalFormat(MedwanQuery.getInstance().getConfigString("priceFormat","#")).format(newprice)+" "+MedwanQuery.getInstance().getConfigString("currency","EUR")+"</td><td class='admin2'>"+new DecimalFormat(MedwanQuery.getInstance().getConfigString("priceFormat","#")).format(resultprice)+" "+MedwanQuery.getInstance().getConfigString("currency","EUR")+"</td><td class='admin2'>"+new DecimalFormat(MedwanQuery.getInstance().getConfigString("priceFormat","#")).format(resultprice-oldprice)+" "+MedwanQuery.getInstance().getConfigString("currency","EUR")+"</td></tr>");
			}
		}
	}
%>
</table>
<form name="transactionForm" method="post">
<input type="submit" class="button" name="storeprices" value="<%=getTran("web","save",sWebLanguage)%>"/>
</form>