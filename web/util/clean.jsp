<%@page errorPage="/includes/error.jsp" %>
<%@include file="/includes/validateUser.jsp" %>
<%
	Connection conn=MedwanQuery.getInstance().getLongOpenclinicConnection();
	PreparedStatement ps = conn.prepareStatement("select * from RequestedLabanalyses");
	PreparedStatement ps2 = conn.prepareStatement("insert into numericvalues(transactionid,analysiscode) values (?,?)");
	ResultSet rs = ps.executeQuery();
	while (rs.next()){
		try{
			double d = Double.parseDouble(rs.getString("resultvalue"));
			d = Double.parseDouble(rs.getString("resultrefmin"));
			d = Double.parseDouble(rs.getString("resultrefmax"));
			ps2.setInt(1, rs.getInt("transactionid"));
			ps2.setString(2, rs.getString("analysiscode"));
			ps2.execute();
		}
		catch (Exception e){
			
		}
	}
	rs.close();
	ps.close();
	ps2.close();
	conn.close();
%>