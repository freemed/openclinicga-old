<%@ page import="java.util.*,be.openclinic.pharmacy.*" %>
<%@include file="/includes/validateUser.jsp"%>
<%=checkPermission("pharmacy","select",activeUser)%>
<%
	if(request.getParameter("deleteoperation")!=null){
		ProductStockOperation operation = ProductStockOperation.get(request.getParameter("deleteoperation"));
		if(operation!=null){
			System.out.println("canceling operation "+operation.getUid());
			System.out.println("result="+operation.cancel(true));
		}
	}
	long n3months = 1000*3600;
	n3months=n3months*24*92;
	String sExpiryDate = new SimpleDateFormat("dd/MM/yyyy").format(new java.util.Date(new java.util.Date().getTime()-n3months));
	if(request.getParameter("submit")!=null){
		sExpiryDate = request.getParameter("expirydate");
	}
	System.out.println("test");
%>
<form name='transactionForm' id='transactionForm' method='post'>
	<table>
		<tr><td class='admin'><%=getTran("web","deliveries.after",sWebLanguage) %></td><td class='admin2'><%=writeDateField("expirydate","transactionForm",sExpiryDate,sWebLanguage)%></td><td><input type='submit' name='search' value='<%=getTran("web","find",sWebLanguage)%>'/></td></tr>
	</table>
	<input type='hidden' name='deleteoperation' id='deleteoperation' value=''/>
</form>

<table width='100%'>
	<tr class='admin'><td/>
		<td><%=getTran("web","servicestock",sWebLanguage) %></td>
		<td><%=getTran("web","productstock",sWebLanguage) %></td>
		<td><%=getTran("web","quantity",sWebLanguage) %></td>
		<td><%=getTran("web","packageunits",sWebLanguage) %></td>
		<td><%=getTran("web","batch.number",sWebLanguage) %></td>
		<td><%=getTran("web","date",sWebLanguage) %></td>
	</tr>
<%
	try{
		java.util.Date dDate = new SimpleDateFormat("dd/MM/yyyy").parse(sExpiryDate);
		String sQuery = " select * from oc_productstockoperations where oc_operation_srcdesttype='patient' and oc_operation_date>? and oc_operation_srcdestuid=? order by oc_operation_date desc";
		Connection conn = MedwanQuery.getInstance().getOpenclinicConnection();
		PreparedStatement ps = conn.prepareStatement(sQuery);
		ps.setDate(1,new java.sql.Date(dDate.getTime()));
		ps.setString(2,activePatient.personid);
		ResultSet rs = ps.executeQuery();
		while(rs.next()){
			ProductStockOperation operation = ProductStockOperation.get(rs.getString("oc_operation_serverid")+"."+rs.getString("oc_operation_objectid"));
			if(operation!=null && operation.getProductStock()!=null){
				out.println("<tr><td class='admin'>"+(operation.getUnitsChanged()!=0?"<a href='javascript:cancelOperation(\""+operation.getUid()+"\");'><img src='"+sCONTEXTPATH+"/_img/erase.png' title='"+getTranNoLink("web","delete",sWebLanguage)+"'/></a>":"")+"</td><td class='admin'>"+operation.getProductStock().getServiceStock().getName()+"</td><td class='admin2'>"+operation.getProductStock().getProduct().getName()+"</td><td class='admin2'>"+(operation.getDescription().indexOf("delivery")==-1?"-":"")+operation.getUnitsChanged()+"</td><td class='admin2'>"+operation.getProductStock().getProduct().getPackageUnits()+" "+getTran("product.unit",operation.getProductStock().getProduct().getUnit(),sWebLanguage)+"</td><td class='admin2'>"+(operation.getBatchNumber()!=null?operation.getBatchNumber():"?")+"</td><td class='admin2'>"+new SimpleDateFormat("dd/MM/yyyy").format(operation.getDate())+"</td></tr>");
			}
		}
		rs.close();
		ps.close();
		conn.close();
		
	}
	catch(Exception e){
		e.printStackTrace();
	}
%>
</table>

<script>
	function cancelOperation(uid){
	  var popupUrl = "<%=sCONTEXTPATH%>/_common/search/template.jsp?Page=yesnoPopup.jsp&ts=<%=getTs()%>&labelType=web&labelID=areyousuretodelete";
	  var modalitiesIE = "dialogWidth:266px;dialogHeight:143px;center:yes;scrollbars:no;resizable:no;status:no;location:no;";
	  var answer;

	    if(window.showModalDialog){
	        answer = window.showModalDialog(popupUrl,'',modalitiesIE);
	    }else{
	        answer = window.confirm("<%=getTranNoLink("web","areyousuretodelete",sWebLanguage)%>");
	    }
	  if(answer==1){
			document.getElementById('deleteoperation').value=uid;
			document.transactionForm.submit();
	  }
	}
</script>