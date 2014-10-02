<%@page import="be.openclinic.system.Screen,
                be.openclinic.pharmacy.*,
                be.openclinic.finance.*"%>
<%@include file="/includes/validateUser.jsp"%>
<%@page errorPage="/includes/error.jsp"%>

<%
    boolean storePrices = (request.getParameter("storeprices")!=null);

	/// DEBUG /////////////////////////////////////////////////////////////////////////////////////
	if(Debug.enabled){
		Debug.println("\n******************** pharmacy/recalculatePrices.jsp *******************");
		Debug.println("storePrices : "+storePrices+"\n");
	}
	///////////////////////////////////////////////////////////////////////////////////////////////
%>

<%=writeTableHeader("web","recalculatePrices",sWebLanguage,"")%>
<%
    Connection conn = null;
    PreparedStatement ps = null;
    ResultSet rs = null;
    int prestCount = 0;

    try{
	    conn = MedwanQuery.getInstance().getOpenclinicConnection();
        String sSql = "select * from oc_products"+
	                  " where oc_product_prestationcode <> ''"+
	                  "  and oc_product_prestationquantity > 0"+
    		          "  and oc_product_margin <> 0";
	    ps = conn.prepareStatement(sSql);
        rs = ps.executeQuery();

		if(rs.next()){			
            %>
                
				<table class="list" cellpadding="0" cellspacing="1">
					<tr class="admin">
						<td><%=getTran("web","prestation",sWebLanguage)%>&nbsp;</td>
						<td><%=getTran("web","oldprice",sWebLanguage)%>&nbsp;</td>
						<td><%=getTran("web","newprice",sWebLanguage)%>&nbsp;</td>
						<td><%=getTran("web","result",sWebLanguage)%>&nbsp;</td>
						<td><%=getTran("web","difference",sWebLanguage)%>&nbsp;</td>
					</tr>
			<%
							
			Prestation prestation;
			Product product;

			rs.beforeFirst(); // rewind
			while(rs.next()){
				product = Product.get(rs.getString("oc_product_serverid")+"."+rs.getString("oc_product_objectid"));
				if(product!=null){
					prestation = Prestation.get(product.getPrestationcode());
					if(prestation!=null){
						double newprice = Double.parseDouble(new DecimalFormat(MedwanQuery.getInstance().getConfigString("priceFormat","#.00")).format(product.getLastYearsAveragePrice()*(100+product.getMargin())/100).replaceAll(",", "."));
						double resultprice = newprice;
						double oldprice = prestation.getPrice();
						
						if(newprice<prestation.getPrice() && !product.isApplyLowerPrices()){
							resultprice = oldprice;
						}
						
						if(storePrices){
							prestation.setPrice(newprice);
							prestation.store();
						}
						
						out.print("<tr>"+
						           "<td class='admin'>"+prestation.getDescription()+"</td>"+
								   "<td class='admin2'>"+new DecimalFormat(MedwanQuery.getInstance().getConfigString("priceFormat","#")).format(oldprice)+" "+MedwanQuery.getInstance().getConfigString("currency","EUR")+"</td><td class='admin2'>"+new DecimalFormat(MedwanQuery.getInstance().getConfigString("priceFormat","#")).format(newprice)+" "+MedwanQuery.getInstance().getConfigString("currency","EUR")+"</td><td class='admin2'>"+new DecimalFormat(MedwanQuery.getInstance().getConfigString("priceFormat","#")).format(resultprice)+" "+MedwanQuery.getInstance().getConfigString("currency","EUR")+"</td><td class='admin2'>"+new DecimalFormat(MedwanQuery.getInstance().getConfigString("priceFormat","#")).format(resultprice-oldprice)+" "+MedwanQuery.getInstance().getConfigString("currency","EUR")+"</td>"+
						          "</tr>");
						
						prestCount++;
					}
				}
			}
		      	
		    %>
			   	</table>
			   	
				<form name="transactionForm" method="post">
				    <%=ScreenHelper.alignButtonsStart()%>
				        <input type="submit" class="button" name="storeprices" value="<%=getTranNoLink("web","save",sWebLanguage)%>"/>
				    <%=ScreenHelper.alignButtonsStop()%>
				</form>
			<%
		}
		else{
			if(prestCount > 0){
			    %><%=prestCount%> <%=getTranNoLink("web","recordsFound",sWebLanguage)%><%
			}
			else{
			    %><%=getTranNoLink("web","noRecordsFound",sWebLanguage)%><%
			}
		}
    }
	catch(Exception e){
		Debug.printStackTrace(e);
	}
	finally{
		try{
			if(rs!=null) rs.close();
			if(ps!=null) ps.close();
			if(conn!=null) conn.close();
		}
		catch(Exception e){
			e.printStackTrace();
		}
	}
%>