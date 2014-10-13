<%@page import="java.util.*,be.openclinic.pharmacy.*"%>
<%@include file="/includes/validateUser.jsp"%>
<%=checkPermission("pharmacy","select",activeUser)%>
<%=sJSSORTTABLE%>

<%
    //*** DELETE ******************************************
	if(request.getParameter("deleteoperation")!=null){
		ProductStockOperation operation = ProductStockOperation.get(request.getParameter("deleteoperation"));
		if(operation!=null){
			operation.delete(request.getParameter("deleteoperation"));
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
</form>
	
<%
    int recCount = 0;

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
		if(rs.next()){
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
				               "<td>"+ScreenHelper.formatDate(operation.getDate())+"</td>"+
				               "<td>"+operation.getProductStock().getServiceStock().getName()+"</td>"+
				               "<td>"+operation.getProductStock().getProduct().getName()+"</td>"+
				               "<td>"+(operation.getDescription().indexOf("delivery")==-1?"-":"")+operation.getUnitsChanged()+"</td>"+
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
    if(yesnoDialog("Web","areYouSureToDelete")){
      document.getElementById('deleteoperation').value = uid;
      document.transactionForm.submit();
    }
  }
</script>