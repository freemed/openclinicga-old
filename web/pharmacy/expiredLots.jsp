<%@ page import="java.util.*" %>
<%@include file="/includes/validateUser.jsp"%>
<%=checkPermission("pharmacy","select",activeUser)%>
<%
	long n3months = 1000*3600;
	n3months=n3months*24*92;
	String sExpiryDate = ScreenHelper.stdDateFormat.format(new java.util.Date(new java.util.Date().getTime()+n3months));
	if(request.getParameter("submit")!=null){
		sExpiryDate = request.getParameter("expirydate");
	}
%>
<form name='transactionForm' method='post'>
	<table>
		<tr><td class='admin'><%=getTran("web","expiry.date.before",sWebLanguage) %></td><td class='admin2'><%=writeDateField("expirydate","transactionForm",sExpiryDate,sWebLanguage)%></td><td><input type='submit' name='submit' value='<%=getTran("web","find",sWebLanguage)%>'/></td></tr>
	</table>
</form>

<table>
	<tr class='admin'>
		<td><%=getTran("web","servicestock",sWebLanguage) %></td>
		<td><%=getTran("web","productstock",sWebLanguage) %></td>
		<td><%=getTran("web","batch.number",sWebLanguage) %></td>
		<td><%=getTran("web","level",sWebLanguage) %></td>
		<td><%=getTran("web","batch.expiration",sWebLanguage) %></td>
	</tr>
<%
	try{
		java.util.Date dDate = ScreenHelper.parseDate(sExpiryDate);
		String sQuery = " select c.oc_stock_name,d.oc_product_name,a.oc_batch_number,a.oc_batch_level,a.oc_batch_end from oc_batches a,oc_productstocks b, oc_servicestocks c, oc_products d"+ 
						" where "+
						" a.oc_batch_end<? and"+
						" a.oc_batch_level>0 and"+
						" b.oc_stock_objectid=replace(a.oc_batch_productstockuid,'"+MedwanQuery.getInstance().getConfigString("serverId")+".','') and"+
						" c.oc_stock_objectid=replace(b.oc_stock_servicestockuid,'"+MedwanQuery.getInstance().getConfigString("serverId")+".','') and"+
						" d.oc_product_objectid=replace(b.oc_stock_productuid,'"+MedwanQuery.getInstance().getConfigString("serverId")+".','')"+
						" order by c.oc_stock_objectid,b.oc_stock_objectid,a.oc_batch_end";
		Connection conn = MedwanQuery.getInstance().getOpenclinicConnection();
		PreparedStatement ps = conn.prepareStatement(sQuery);
		ps.setDate(1,new java.sql.Date(dDate.getTime()));
		ResultSet rs = ps.executeQuery();
		String sColor="";
		java.util.Date dExp=null;
		while(rs.next()){
			dExp=rs.getDate("oc_batch_end");
			if(dExp.before(new java.util.Date())){
				sColor="color='red'";
			}
			else {
				sColor="";
			}
			out.println("<tr><td class='admin'>"+rs.getString("oc_stock_name")+"</td><td class='admin2'>"+rs.getString("oc_product_name")+"</td><td class='admin2'>"+rs.getString("oc_batch_number")+"</td><td class='admin2'><b>"+rs.getString("oc_batch_level")+"</b></td><td class='admin2'><font "+sColor+">"+ScreenHelper.stdDateFormat.format(dExp)+"</font></td></tr>");
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