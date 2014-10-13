<%@page import="java.util.*"%>
<%@include file="/includes/validateUser.jsp"%>
<%=checkPermission("pharmacy","select",activeUser)%>

<%
    // expiry date
	long n3months = 1000*3600;
	n3months = n3months*24*92;
	
	String sExpiryDate = ScreenHelper.formatDate(new java.util.Date(new java.util.Date().getTime()+n3months));
	if(request.getParameter("submit")!=null){
		sExpiryDate = request.getParameter("expirydate");
	}
	
	/// DEBUG /////////////////////////////////////////////////////////////////////////////////////
	if(Debug.enabled){
		Debug.println("\n************************ pharmacy/expiredLots.jsp *********************");
		Debug.println("sExpiryDate : "+sExpiryDate+"\n");
	}
	///////////////////////////////////////////////////////////////////////////////////////////////
%>

<form name="transactionForm" method="post">
	<table width="100%" class="list" cellpadding="0" cellspacing="1">
	    <%-- TITLE --%>
	    <tr class="gray">
	        <td colspan="2"><%=getTranNoLink("web","pharmacy.report.expiring.lots",sWebLanguage)%></td>
	    </tr>
	    
		<tr>
		    <td class="admin" width="<%=sTDAdminWidth%>"><%=getTran("web","expiry.date.before",sWebLanguage)%></td>
	        <td class="admin2"><%=writeDateField("expirydate","transactionForm",sExpiryDate,sWebLanguage)%></td>
	    </tr>
	    <tr>
	        <td class="admin"></td>
	        <td class="admin2"><input type="submit" name="submit" class="button" value="<%=getTranNoLink("web","find",sWebLanguage)%>"/></td>
	    </tr>
	</table>
</form>

<%
	try{
		java.util.Date dDate = ScreenHelper.parseDate(sExpiryDate);
		String sQuery = "select c.oc_stock_name, d.oc_product_name, a.oc_batch_number, a.oc_batch_level, a.oc_batch_end"+
		                " from oc_batches a, oc_productstocks b, oc_servicestocks c, oc_products d"+ 
						"  where a.oc_batch_end<? and"+
						"   a.oc_batch_level>0 and"+
						"   b.oc_stock_objectid = replace(a.oc_batch_productstockuid,'"+MedwanQuery.getInstance().getConfigString("serverId")+".','') and"+
						"   c.oc_stock_objectid = replace(b.oc_stock_servicestockuid,'"+MedwanQuery.getInstance().getConfigString("serverId")+".','') and"+
						"   d.oc_product_objectid = replace(b.oc_stock_productuid,'"+MedwanQuery.getInstance().getConfigString("serverId")+".','')"+
						"  order by c.oc_stock_objectid, b.oc_stock_objectid, a.oc_batch_end";
		Connection conn = MedwanQuery.getInstance().getOpenclinicConnection();
		PreparedStatement ps = conn.prepareStatement(sQuery);
		ps.setDate(1,new java.sql.Date(dDate.getTime()));
		ResultSet rs = ps.executeQuery();
		String sColor = "";
		java.util.Date dExp;
		
		if(rs.next()){
			int recCount = 0;
			
			%>			
				<table width="100%" class="list" cellpadding="0" cellspacing="1">
				    <%-- header --%>
					<tr class="admin">
						<td><%=getTran("web","servicestock",sWebLanguage)%></td>
						<td><%=getTran("web","productstock",sWebLanguage)%></td>
						<td><%=getTran("web","batch.number",sWebLanguage)%></td>
						<td><%=getTran("web","level",sWebLanguage)%></td>
						<td><%=getTran("web","batch.expiration",sWebLanguage)%></td>
					</tr>
			<%
			
			rs.beforeFirst(); // rewind

			String sClass = "1";
			while(rs.next()){
				// expired --> red
				dExp = rs.getDate("oc_batch_end");
				if(dExp.before(new java.util.Date())) sColor = "color='red'";
				else                                  sColor = "";

				// alternate row-style
				if(sClass.length()==0) sClass = "1";
				else                   sClass = ""; 
				
				out.print("<tr class='list"+sClass+"'>"+
				            "<td class='admin'>"+rs.getString("oc_stock_name")+"</td>"+
				            "<td class='admin2'>"+rs.getString("oc_product_name")+"</td>"+
				            "<td class='admin2'>"+rs.getString("oc_batch_number")+"</td>"+
				            "<td class='admin2'><b>"+rs.getString("oc_batch_level")+"</b></td>"+
				            "<td class='admin2'><font "+sColor+">"+ScreenHelper.formatDate(dExp)+"</font></td>"+
				          "</tr>");
				
				recCount++;
			}			
			rs.close();
			ps.close();
			conn.close();

			%>			
				</table>
				
				<%=recCount%> <%=getTran("web","recordsFound",sWebLanguage)%>
			<%
		}
		else{
			%><%=getTran("web","noRecordsFound",sWebLanguage)%><%
		}		
	}
	catch(Exception e){
		e.printStackTrace();
	}
%>

<%=ScreenHelper.alignButtonsStart()%>
    <input type="button" name="closeButton" class="button" value="<%=getTranNoLink("web","close",sWebLanguage)%>" onclick="window.close();">
<%=ScreenHelper.alignButtonsStop()%>