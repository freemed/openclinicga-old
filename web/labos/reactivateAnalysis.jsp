<%@include file="/includes/validateUser.jsp"%>
<%
	String serverid=checkString(request.getParameter("serverid"));
	String transactionid=checkString(request.getParameter("transactionid"));
	String labanalysiscode=checkString(request.getParameter("labanalysiscode"));
	Connection conn = MedwanQuery.getInstance().getOpenclinicConnection();
	String sql = "update requestedlabanalyses "+
		"set finalvalidationdatetime=null,"+
		"finalvalidator=null,"+
		"technicalvalidator=null,"+
		"technicalvalidationdatetime=null "+
		"where serverid=? and transactionid=? and analysiscode=?";
	PreparedStatement ps = conn.prepareStatement(sql);
	ps.setInt(1,Integer.parseInt(serverid));
	ps.setInt(2,Integer.parseInt(transactionid));
	ps.setString(3,labanalysiscode);
	ps.execute();
	ps.close();
	conn.close();
%>
<script>
	window.opener.location.reload();
	window.close();
</script>