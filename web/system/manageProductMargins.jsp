<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>
<%
	if(request.getParameter("submit")!=null){
		try{
			if(request.getParameter("profitMargin")!=null){
				double d = Double.parseDouble(request.getParameter("profitMargin"));
				Connection conn = MedwanQuery.getInstance().getOpenclinicConnection();
				PreparedStatement ps = conn.prepareStatement("update OC_PRODUCTS set OC_PRODUCT_MARGIN=?");
				ps.setDouble(1,d);
				ps.execute();
				ps.close();
				conn.close();
				MedwanQuery.getInstance().setConfigString("defaultProductsMargin",d+"");
			}
			int i = request.getParameter("EditApplyLowerPrices")!=null?1:0;
			Connection conn = MedwanQuery.getInstance().getOpenclinicConnection();
			PreparedStatement ps = conn.prepareStatement("update OC_PRODUCTS set OC_PRODUCT_APPLYLOWERPRICES=?");
			ps.setDouble(1,i);
			ps.execute();
			ps.close();
			MedwanQuery.getInstance().setConfigString("applyLowerProductMargins",i+"");
			//Now update all prestation prices
			ps = conn.prepareStatement("select * from OC_PRODUCTS a,OC_PRESTATIONS b where OC_PRESTATION_OBJECTID=replace(OC_PRODUCT_PRESTATIONCODE,'"+MedwanQuery.getInstance().getConfigString("serverId")+".','') and OC_PRODUCT_PRESTATIONQUANTITY>0 and OC_PRODUCT_UNITPRICE>0 and OC_PRODUCT_MARGIN>0");
			ResultSet rs = ps.executeQuery();
			while(rs.next()){
				int quantity=rs.getInt("OC_PRODUCT_PRESTATIONQUANTITY");
				double newPrice=rs.getDouble("OC_PRODUCT_UNITPRICE")*(100+rs.getDouble("OC_PRODUCT_MARGIN"))/(100*quantity);
           		if(i==1||newPrice>rs.getDouble("OC_PRESTATION_PRICE")){
    				PreparedStatement ps2 = conn.prepareStatement("update OC_PRESTATIONS set OC_PRESTATION_PRICE=? where OC_PRESTATION_OBJECTID=?");
            		ps2.setDouble(1,newPrice);
            		int objectid=rs.getInt("OC_PRESTATION_OBJECTID");
            		ps2.setInt(2,objectid);
            		ps2.execute();
            		ps2.close();
            		MedwanQuery.getInstance().getObjectCache().removeObject("prestation",rs.getInt("OC_PRESTATION_SERVERID")+"."+objectid);
           		}
			}
			rs.close();
			ps.close();
			conn.close();
		}
		catch(Exception e){
			e.printStackTrace();
		}
	}
%>
<form name='transactionForm' method='post'>
<table>
	<tr>
		<td class='admin'><%=getTran("web","default.profit.margin",sWebLanguage) %></td>
		<td class='admin2'><input type='text' class='text' size="5" name='profitMargin' value='<%=MedwanQuery.getInstance().getConfigString("defaultProductsMargin","0")%>' onKeyUp="isNumber(this);"/>% <%=getTran("web","zero.is.nocalculation",sWebLanguage) %></td>
	</tr>
    <tr>
        <td class="admin" nowrap><%=getTran("Web","apply.lower.prices",sWebLanguage)%></td>
        <td class="admin2">
            <input class="text" type="checkbox" name="EditApplyLowerPrices"  value="1" <%=MedwanQuery.getInstance().getConfigString("applyLowerProductMargins","0").equalsIgnoreCase("1")?"checked":"" %>>
        </td>
    </tr>
    <tr>
    	<td><input type='submit' class='button' name='submit' value='<%=getTranNoLink("web","save",sWebLanguage)%>'/></td>
    </tr>
</table>
</form>