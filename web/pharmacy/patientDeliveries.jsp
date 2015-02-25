<%@page import="java.util.*,be.openclinic.pharmacy.*"%>
<%@include file="/includes/validateUser.jsp"%>
<%=checkPermission("pharmacy","select",activeUser)%>
<%=sJSSORTTABLE%>

<%
    //*** DELETE ******************************************
	if(request.getParameter("deleteoperation")!=null){
		ProductStockOperation operation = ProductStockOperation.get(request.getParameter("deleteoperation"));
		if(operation!=null){
			ProductStock productStock = operation.getProductStock();
			operation.delete(request.getParameter("deleteoperation"));
			productStock.setLevel(productStock.getLevel(new java.util.Date()));
			productStock.store();
		}
	}

if(request.getParameter("modifydateoperation")!=null){
	ProductStockOperation operation = ProductStockOperation.get(request.getParameter("modifydateoperation").split(";")[0]);
	if(operation!=null){
		try{
			operation.setDate(ScreenHelper.getSQLDate(request.getParameter("modifydateoperation").split(";")[1]));
			operation.store();
		}
		catch(Exception e){
			
		}
	}
}

if(request.getParameter("modifyquantityoperation")!=null){
	ProductStockOperation operation = ProductStockOperation.get(request.getParameter("modifyquantityoperation").split(";")[0]);
	if(operation!=null){
		try{
			ProductStock productStock = operation.getProductStock();
			operation.setUnitsChanged(Math.abs(Integer.parseInt(request.getParameter("modifyquantityoperation").split(";")[1])));
			operation.store();
			productStock.setLevel(productStock.getLevel(new java.util.Date()));
			productStock.store();
		}
		catch(Exception e){
			
		}
	}
}

    // expiry date
	long n3months = 1000*3600;
	n3months = n3months*24*92;
	
	String sExpiryDate = ScreenHelper.formatDate(new java.util.Date(new java.util.Date().getTime()-n3months));
	if(request.getParameter("submit")!=null){
		sExpiryDate = request.getParameter("expirydate");
	}
	
	/// DEBUG /////////////////////////////////////////////////////////////////////////////////////
	if(Debug.enabled){
		Debug.println("\n********************* pharmacy/patientDeliveries.jsp ******************");
		Debug.println("sExpiryDate : "+sExpiryDate+"\n");
	}
	///////////////////////////////////////////////////////////////////////////////////////////////
%>
<form name="transactionForm" id="transactionForm" method="post">
	<table width="100%" class="list" cellpadding="0" cellspacing="1">
	    <%-- TITLE --%>
	    <tr class="gray">
	        <td colspan="2"><%=getTranNoLink("web","patientDrugDeliveries",sWebLanguage)%></td>
	    </tr>
	    
		<tr>
		    <td class="admin" width="<%=sTDAdminWidth%>"><%=getTran("web","deliveries.after",sWebLanguage)%></td>
		    <td class="admin2"><%=writeDateField("expirydate","transactionForm",sExpiryDate,sWebLanguage)%></td>
		</tr>
		
		<%-- BUTTONS --%>
		<tr>
		    <td class="admin">&nbsp;</td>
		    <td class="admin2"><input type="submit" class="button" name="search" value="<%=getTranNoLink("web","find",sWebLanguage)%>"/></td>
		</tr>
	</table>
	<input type='hidden' name='deleteoperation' id='deleteoperation' value=''/>
	<input type='hidden' name='modifydateoperation' id='modifydateoperation' value=''/>
	<input type='hidden' name='modifyquantityoperation' id='modifyquantityoperation' value=''/>
</form>
	
<%
    int recCount = 0;

	try{
		java.util.Date dDate = ScreenHelper.parseDate(sExpiryDate);
		String sQuery = " select oc_stock_name,oc_operation_productstockuid,sum(quantity) quantity from ("+
						" select oc_operation_objectid,c.oc_stock_name,oc_operation_productstockuid,oc_operation_unitschanged quantity from oc_productstockoperations a,oc_productstocks b,oc_servicestocks c"+
		                " where oc_operation_srcdesttype='patient'"+
		                "  and oc_operation_date>?"+
		                "  and oc_operation_description like '%delivery%'"+
		                "  and oc_operation_srcdestuid=?"+
		                "  and b.oc_stock_objectid=replace(a.oc_operation_productstockuid,'"+MedwanQuery.getInstance().getConfigInt("serverId")+".','')"+
		                "  and c.oc_stock_objectid=replace(b.oc_stock_servicestockuid,'"+MedwanQuery.getInstance().getConfigInt("serverId")+".','')"+
		                " union"+
		                " select oc_operation_objectid,c.oc_stock_name,oc_operation_productstockuid,-oc_operation_unitschanged quantity from oc_productstockoperations a,oc_productstocks b,oc_servicestocks c"+
		                " where oc_operation_srcdesttype='patient'"+
		                "  and oc_operation_date>?"+
		                "  and oc_operation_description like '%receipt%'"+
		                "  and oc_operation_srcdestuid=?"+
		                "  and b.oc_stock_objectid=replace(a.oc_operation_productstockuid,'"+MedwanQuery.getInstance().getConfigInt("serverId")+".','')"+
		                "  and c.oc_stock_objectid=replace(b.oc_stock_servicestockuid,'"+MedwanQuery.getInstance().getConfigInt("serverId")+".','')) q"+
		                " group by oc_stock_name,oc_operation_productstockuid";
		Connection conn = MedwanQuery.getInstance().getOpenclinicConnection();
		PreparedStatement ps = conn.prepareStatement(sQuery);
		ps.setDate(1,new java.sql.Date(dDate.getTime()));
		ps.setString(2,activePatient.personid);
		ps.setDate(3,new java.sql.Date(dDate.getTime()));
		ps.setString(4,activePatient.personid);
		
		ResultSet rs = ps.executeQuery();
		%>			
			<table width="100%" class="sortable" id="searchresultssummary" cellpadding="0" cellspacing="1">    
			    <%-- HEADER --%>
				<tr class='admin'>
					<td width="150"><%=getTran("web","servicestock",sWebLanguage)%></td>
					<td width="150"><%=getTran("web","productstock",sWebLanguage)%></td>
					<td width="100"><%=getTran("web","quantity",sWebLanguage)%></td>
					<td width="100"><%=getTran("web","packageunits",sWebLanguage)%></td>
				</tr>
        <%

		ProductStock productstock;
		String sClass = "1";
		
		while(rs.next()){
			productstock = ProductStock.get(rs.getString("oc_operation_productstockuid"));
			if(productstock!=null){
				// alternate row-style
				if(sClass.length()==0) sClass = "1";
				else                   sClass = ""; 
				
				out.print("<tr class='list"+sClass+"'>"+
			               "<td>"+rs.getString("OC_STOCK_NAME")+"</td>"+
			               "<td>"+productstock.getProduct().getName()+"</td>"+
			               "<td>"+rs.getInt("quantity")+"</td>"+
			               "<td>"+productstock.getProduct().getPackageUnits()+" "+getTran("product.unit",productstock.getProduct().getUnit(),sWebLanguage)+"</td>"+
			              "</tr>");
				
				recCount++;
			}
		}
		
		rs.close();
		ps.close();
		conn.close();
		
		%>
               </table>
		<%
	}		
	catch(Exception e){
		e.printStackTrace();
	}
	
    if(recCount > 0){
        %><%=recCount%> <%=getTran("web","recordsFound",sWebLanguage)%><%
    }
    else{
    	%><%=getTran("web","noRecordsFound",sWebLanguage)%><%
    }
%>
<%
    recCount = 0;

	try{
		java.util.Date dDate = ScreenHelper.parseDate(sExpiryDate);
		String sQuery = "select * from oc_productstockoperations"+
		                " where oc_operation_srcdesttype='patient'"+
		                "  and oc_operation_date>?"+
		                "  and oc_operation_srcdestuid=?"+
		                " order by oc_operation_date desc";
		Connection conn = MedwanQuery.getInstance().getOpenclinicConnection();
		PreparedStatement ps = conn.prepareStatement(sQuery);
		ps.setDate(1,new java.sql.Date(dDate.getTime()));
		ps.setString(2,activePatient.personid);
		
		ResultSet rs = ps.executeQuery();
		%>			
			<table width="100%" class="sortable" id="searchresults" cellpadding="0" cellspacing="1">    
			    <%-- HEADER --%>
				<tr class='admin'>
				    <td width="25">&nbsp;</td>
					<td width="100"><%=getTran("web","date",sWebLanguage)%></td>
					<td width="150"><%=getTran("web","servicestock",sWebLanguage)%></td>
					<td width="150"><%=getTran("web","productstock",sWebLanguage)%></td>
					<td width="100"><%=getTran("web","quantity",sWebLanguage)%></td>
					<td width="100"><%=getTran("web","packageunits",sWebLanguage)%></td>
					<td width="*"><%=getTran("web","batch.number",sWebLanguage)%></td>
				</tr>
        <%

		ProductStockOperation operation;
		String sClass = "1";
		
		while(rs.next()){
			operation = ProductStockOperation.get(rs.getString("oc_operation_serverid")+"."+rs.getString("oc_operation_objectid"));
			if(operation!=null && operation.getProductStock()!=null){
				// alternate row-style
				if(sClass.length()==0) sClass = "1";
				else                   sClass = ""; 
				
				out.print("<tr class='list"+sClass+"'>"+
			               "<td>"+(operation.getUnitsChanged()!=0?"<a href='javascript:cancelOperation(\""+operation.getUid()+"\");'><img src='"+sCONTEXTPATH+"/_img/icons/icon_erase.gif' class='link' title='"+getTranNoLink("web","cancel",sWebLanguage)+"'/></a>":"")+"</td>"+
			               (activeUser.getAccessRight("patient.modifypharmacydelivery.select")?
			            		   "<td><a href=\"javascript:modifydate('"+operation.getUid()+"','"+ScreenHelper.formatDate(operation.getDate())+"')\">"+ScreenHelper.formatDate(operation.getDate())+"</a></td>"
			            		   :"<td>"+ScreenHelper.formatDate(operation.getDate())+"</td>"
			               )+
			               "<td>"+operation.getProductStock().getServiceStock().getName()+"</td>"+
			               "<td>"+operation.getProductStock().getProduct().getName()+"</td>"+
			               (activeUser.getAccessRight("patient.modifypharmacydelivery.select")?
			            		   "<td><a href=\"javascript:modifyquantity('"+operation.getUid()+"',"+operation.getUnitsChanged()+")\">"+(operation.getDescription().indexOf("delivery")==-1?"-":"")+operation.getUnitsChanged()+"</a></td>"
			            		   :"<td>"+(operation.getDescription().indexOf("delivery")==-1?"-":"")+operation.getUnitsChanged()+"</td>"
			               )+
			               "<td>"+operation.getProductStock().getProduct().getPackageUnits()+" "+getTran("product.unit",operation.getProductStock().getProduct().getUnit(),sWebLanguage)+"</td>"+
			               "<td>"+(operation.getBatchNumber()!=null?operation.getBatchNumber():"?")+"</td>"+
			              "</tr>");
				
				recCount++;
			}
		}
		rs.close();
		ps.close();
		conn.close();
		
		%>
               </table>
		<%
	}
	catch(Exception e){
		e.printStackTrace();
	}
	
    if(recCount > 0){
        %><%=recCount%> <%=getTran("web","recordsFound",sWebLanguage)%><%
    }
    else{
    	%><%=getTran("web","noRecordsFound",sWebLanguage)%><%
    }
%>

<%=ScreenHelper.alignButtonsStart()%>
    <input type="button" name="closeButton" class="button" value="<%=getTranNoLink("web","close",sWebLanguage)%>" onclick="window.close();">
<%=ScreenHelper.alignButtonsStop()%>

<script>
  function cancelOperation(uid){
      if(yesnoDeleteDialog()){
      document.getElementById('deleteoperation').value = uid;
      document.transactionForm.submit();
    }
  }
  
  function modifydate(uid,date){
	  var d = prompt("<%=getTran("web","date",sWebLanguage)%>",date);
	  document.getElementById('modifydateoperation').value=uid+";"+d;
	  if(date!=d){
	  	transactionForm.submit();
	  }
  }
  function modifyquantity(uid,quantity){
	  var d = prompt("<%=getTran("web","quantity",sWebLanguage)%>",quantity);
	  document.getElementById('modifyquantityoperation').value=uid+";"+d;
	  if(quantity!=d){
		  transactionForm.submit();
	  }
  }
</script>