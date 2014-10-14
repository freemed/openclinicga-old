<%@page import="be.openclinic.pharmacy.Product,
                be.openclinic.pharmacy.ProductOrder,
                be.openclinic.pharmacy.ProductStock,
                be.openclinic.pharmacy.ServiceStock,
                java.text.DecimalFormat,java.util.*,
                be.openclinic.medical.Prescription"%>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/_common/templateAddIns.jsp"%>
<%=checkPermission("pharmacy.productorder","edit",activeUser)%>
<%=sJSSORTTABLE%>

<form name='orderForm' method='post'>
<%
    //*** ORDER ***************************************************************
	if(request.getParameter("orderbutton")!=null){
		String parameter = null, productstockuid = null;
		int quantity;
		ProductOrder productOrder = null;

		Enumeration parameters = request.getParameterNames();
		while(parameters.hasMoreElements()){
			parameter = (String)parameters.nextElement();
			
			if(parameter.startsWith("productstock.")){
				productstockuid = parameter.split("\\.")[1]+"."+parameter.split("\\.")[2];
				
				ProductStock productStock = ProductStock.get(productstockuid);
				try{
					quantity = Integer.parseInt(request.getParameter("quantity."+parameter.split("\\.")[1]+"."+parameter.split("\\.")[2]));
				}
				catch(Exception e){
					quantity = 0;
				}
				
				if(quantity>0 && productStock!=null){
					Product product = productStock.getProduct();
					if(product!=null){
						productOrder = new ProductOrder();
						
						productOrder.setUid("-1");
						productOrder.setCreateDateTime(new java.util.Date());
						productOrder.setDateOrdered(new java.util.Date());
						productOrder.setDescription(product.getName());
						productOrder.setImportance(MedwanQuery.getInstance().getConfigString("defaultOrderImportance","type1native"));
						productOrder.setPackagesOrdered(quantity);
						productOrder.setProductStockUid(productstockuid);
						productOrder.setUpdateDateTime(new java.util.Date());
						productOrder.setUpdateUser(activeUser.userid);
						productOrder.setVersion(1);
						
						productOrder.store();
					}
				}
			}
		}
		
		out.println("<script>window.opener.location.reload();</script>");
	}

	String sServiceStockUid = checkString(request.getParameter("ServiceStockUid"));
	if(sServiceStockUid.length() > 0){
		ServiceStock serviceStock = ServiceStock.get(sServiceStockUid);
		
		if(serviceStock!=null){
			out.print(writeTableHeaderDirectText(serviceStock.getUid()+" "+serviceStock.getName(),sWebLanguage," window.close();"));
			out.print("<table width='100%' class='sortable' cellpadding='0' cellspacing='1' id='searchresults'>");
									
			Vector productStocks = serviceStock.getProductStocks();
			int quantity, recCount = 0;
			for(int n=0; n<productStocks.size(); n++){
				ProductStock productStock = (ProductStock)productStocks.elementAt(n);
				
				quantity = productStock.getMaximumLevel()-productStock.getLevel()-ProductOrder.getOpenOrderedQuantity(productStock.getUid());
				if(quantity>0 && productStock.getProduct().getMinimumOrderPackages()>1){
					quantity = quantity+productStock.getProduct().getMinimumOrderPackages() - quantity%productStock.getProduct().getMinimumOrderPackages();
				}
				
				if(productStock.getLevel() < productStock.getOrderLevel()){
					recCount++;
					
					if(recCount==1){
						// header
						out.print("<tr class='gray'>"+
					               "<td width='250'>"+getTran("web","productname",sWebLanguage)+"</td>"+
						           "<td width='60'>"+getTran("web","level",sWebLanguage)+"</td>"+
					               "<td width='60'>"+getTran("web","orderlevel",sWebLanguage)+"</td>"+
						           "<td width='70'>"+getTran("web","maximumlevel",sWebLanguage)+"</td>"+
					               "<td width='60'>"+getTran("web","openorders",sWebLanguage)+"</td>"+
						           "<td width='*'>"+getTran("web","order",sWebLanguage)+"</td>"+
					              "</tr>");
					}
					
					// For every product to be ordered, add a line 
					out.print("<tr>"+
					           "<td class='admin'><input type='checkbox' name='productstock."+productStock.getUid()+"' checked id='prod"+n+"'/><label for='prod"+n+"' class='hand'>"+productStock.getProduct().getName()+"</label></td>"+
					           "<td class='admin2'>"+productStock.getLevel()+"</td>"+
					           "<td class='admin2'>"+productStock.getOrderLevel()+"</td>"+
					           "<td class='admin2'>"+productStock.getMaximumLevel()+"</td>"+
					           "<td class='admin2'>"+ProductOrder.getOpenOrderedQuantity(productStock.getUid())+"</td>"+
					           "<td class='admin2'><input size='4' type='text' class='text' name='quantity."+productStock.getUid()+"' value='"+quantity+"'/></td>"+
					          "</tr>");
				}
			}
			out.print("</table>");
			
		    if(recCount > 0){
			    out.print(recCount+" "+getTran("web","recordsFound",sWebLanguage));
		    }
		    else{
			    out.print(getTran("web","noRecordsFound",sWebLanguage));
		    }
					        		
			// BUTTONS
			out.print(ScreenHelper.alignButtonsStart());
			if(recCount > 0){
			    out.print("<input type='submit' name='orderbutton' class='button' value='"+getTranNoLink("web","order",sWebLanguage)+"'/>&nbsp;");
			}
            out.print("<input type='button' name='closeButton' class='button' value='"+getTranNoLink("web","close",sWebLanguage)+"' onClick='window.close();'/>");
			out.print(ScreenHelper.alignButtonsStop());
		}
		else{
			out.print("Service stock for service UID "+sServiceStockUid+" does not exist");
		}
	}
	else{
		out.print("Service UID cannot be empty");
	}
%>
</form>