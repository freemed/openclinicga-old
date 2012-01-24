<%@page import="be.openclinic.pharmacy.*"%>
<%@include file="/includes/validateUser.jsp"%>
<%
	Connection conn = MedwanQuery.getInstance().getOpenclinicConnection();
	PreparedStatement ps = conn.prepareStatement("select * from OC_PRODUCTSTOCKS");
	ResultSet rs = ps.executeQuery();
	while (rs.next()){
		ProductStock productStock = ProductStock.get(rs.getInt("OC_STOCK_SERVERID")+"."+rs.getInt("OC_STOCK_OBJECTID"));
		if(productStock!=null){
			int newlevel = productStock.getLevel(new java.util.Date());
			if(newlevel!=productStock.getLevel()){
				productStock.setLevel(newlevel);
				productStock.store();
			}
		}
	}
	rs.close();
	ps.close();
	conn.close();
	out.println(getTran("web","stocklevels.successfully.updated",sWebLanguage));
%>