<%@page import="be.openclinic.finance.*"%>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>
<%
	String userid = checkString(request.getParameter("userid"));
	String feetype = checkString(request.getParameter("feetype"));
	String feeid = checkString(request.getParameter("feeid"));
	Connection conn = MedwanQuery.getInstance().getOpenclinicConnection();
	if(feetype.equalsIgnoreCase("default")){
		PreparedStatement ps = conn.prepareStatement("delete from OC_CAREPROVIDERFEES where OC_CAREPROVIDERFEE_USERID=? and OC_CAREPROVIDERFEE_TYPE=?");
		ps.setString(1,userid);
		ps.setString(2,feetype);
		ps.execute();
		ps.close();
	}
	else {
		PreparedStatement ps = conn.prepareStatement("delete from OC_CAREPROVIDERFEES where OC_CAREPROVIDERFEE_USERID=? and OC_CAREPROVIDERFEE_TYPE=? and  OC_CAREPROVIDERFEE_ID=?");
		ps.setString(1,userid);
		ps.setString(2,feetype);
		ps.setString(3,feeid);
		ps.execute();
		ps.close();
	}
	conn.close();
%>