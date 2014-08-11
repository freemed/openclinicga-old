<%@page import="be.openclinic.pharmacy.*"%>
<%@include file="/includes/validateUser.jsp"%>

<%
	Enumeration params = request.getParameterNames();
	while(params.hasMoreElements()){
		String param = (String)params.nextElement();
		if(param.startsWith("receive.")){
			String deliveryOperationUid=param.split("\\.")[1]+"."+param.split("\\.")[2];
			ProductStockOperation deliveryOperation = ProductStockOperation.get(deliveryOperationUid);
			if(deliveryOperation!=null && deliveryOperation.getProductStock()!=null){
				//Identify detsination product stock
				ProductStock productStock = ProductStock.get(deliveryOperation.getProductStock().getProductUid(),request.getParameter("ServiceStockUid"));
				if(productStock == null){
					//does not exist, create one
					productStock = new ProductStock();
					productStock.setUid("-1");
					productStock.setBegin(deliveryOperation.getDate());
					productStock.setLevel(0);
					productStock.setProductUid(deliveryOperation.getProductStock().getProductUid());
					productStock.setServiceStockUid(request.getParameter("ServiceStockUid"));
					productStock.setUpdateDateTime(new java.util.Date());
					productStock.setUpdateUser(activeUser.userid);
					productStock.setVersion(1);
					productStock.setDefaultImportance(MedwanQuery.getInstance().getConfigString("defaultProductStockImportance","type1native"));
					productStock.setSupplierUid(MedwanQuery.getInstance().getConfigString("defaultProductStockSupplierUid",""));
					productStock.store();
				}
				//Create receipt operation
				ProductStockOperation receiptOperation = new ProductStockOperation();
				receiptOperation.setUid("-1");
				receiptOperation.setBatchEnd(deliveryOperation.getBatchEnd());
				receiptOperation.setBatchNumber(deliveryOperation.getBatchNumber());
				receiptOperation.setBatchUid(deliveryOperation.getBatchUid());
				receiptOperation.setDate(new java.util.Date());
				receiptOperation.setDescription("medicationreceipt.1");
				receiptOperation.setProductStockUid(productStock.getUid());
				receiptOperation.setSourceDestination(new ObjectReference("servicestock",deliveryOperation.getProductStock().getServiceStockUid()));
				receiptOperation.setUnitsChanged(Integer.parseInt(request.getParameter(param)));
				receiptOperation.setUpdateDateTime(new java.util.Date());
				receiptOperation.setUpdateUser(activeUser.userid);
				receiptOperation.setVersion(1);
				receiptOperation.store();
				//Update delivery operation
				deliveryOperation.setUnitsReceived(deliveryOperation.getUnitsReceived()+Integer.parseInt(request.getParameter(param)));
				deliveryOperation.setReceiveProductStockUid(productStock.getUid());
				deliveryOperation.store();
			}
		}
	}
%>

<form name='bulkreceiveForm' method='post'>
	<input type='hidden' name='ServiceStockUid' id='ServiceStockUid' values='<%=request.getParameter("ServiceStockUid") %>'/>
	<table width='100%'>
		<tr class='admin'>
			<td></td>
			<td>ID</td>
			<td><%=getTran("web","date",sWebLanguage) %></td>
			<td><%=getTran("web","source",sWebLanguage) %></td>
			<td><%=getTran("web","product",sWebLanguage) %></td>
			<td><%=getTran("web","sent",sWebLanguage) %></td>
			<td><%=getTran("web","received",sWebLanguage) %></td>
			<td><%=getTran("web","remains",sWebLanguage) %></td>
		</tr>
	<%
		Vector operations = ProductStockOperation.getOpenServiceStockDeliveries(request.getParameter("ServiceStockUid"));
		for(int n=0;n<operations.size();n++){
			ProductStockOperation operation = (ProductStockOperation)operations.elementAt(n);
			String servicename="?",productname="?";
			if(operation.getProductStock()!=null && operation.getProductStock().getServiceStock()!=null){
				servicename=operation.getProductStock().getServiceStock().getName();
			}
			if(operation.getProductStock()!=null && operation.getProductStock().getProduct()!=null){
				productname=operation.getProductStock().getProduct().getName();
			}
			out.println("<tr class='admin2'>");
			out.println("<td><img src='_img/icon_delete.gif' onclick='javascript:doDelete(\""+operation.getUid()+"\");' class='link'/></td>");
			out.println("<td>"+operation.getUid()+"</td>");
			out.println("<td>"+ScreenHelper.stdDateFormat.format(operation.getDate())+"</td>");
			out.println("<td>"+servicename+"</td>");
			out.println("<td>"+productname+"</td>");
			out.println("<td>"+operation.getUnitsChanged()+"</td>");
			out.println("<td>"+operation.getUnitsReceived()+"</td>");
			out.println("<td><input type='text' class='text' size='5' onchange='validatemax("+(operation.getUnitsChanged()-operation.getUnitsReceived())+",this.value);' name='receive."+operation.getUid()+"' value='"+(operation.getUnitsChanged()-operation.getUnitsReceived())+"'></td>");
			out.println("</tr>");
		}
	%>
	</table>
	<%
		if(operations.size()>0){
			%><input type='submit' name='submit' value='<%=getTran("web","save",sWebLanguage)%>'/><%
		}
		else {
			%>
				<label class='text'><%=getTran("web","noresults",sWebLanguage) %></label>
				<script>window.opener.location.reload();</script>
			<%
		}
	%>
</form>

<script>
	function validatemax(maxval,thisval){
		if(maxval*1<thisval*1){
			alertDialogMessage('<%=getTran("web","value.must.be",sWebLanguage)%> <= '+maxval);
			return false;
		}
	}
	
	function doDelete(operationuid){
      var params = '';
      var today = new Date();
      var url= '<c:url value="/pharmacy/closeProductStockOperation.jsp"/>?operationuid='+operationuid+'&ts='+today;
      new Ajax.Request(url,{
		method: "GET",
        parameters: params,
        onSuccess: function(resp){
				window.location.reload();
            }
        }
    	);
	}

</script>