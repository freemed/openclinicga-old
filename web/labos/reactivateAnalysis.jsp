<%@include file="/includes/validateUser.jsp"%>
<%
	String serverid        = checkString(request.getParameter("serverid")),
	       transactionid   = checkString(request.getParameter("transactionid")),
	       labanalysiscode = checkString(request.getParameter("labanalysiscode"));

	/// DEBUG /////////////////////////////////////////////////////////////////////////////////////
	if(Debug.enabled){
		Debug.println("\n********************* labos/reactivateAnalysis.jsp ********************");
		Debug.println("serverid : "+serverid);
		Debug.println("transactionid : "+transactionid);
		Debug.println("labanalysiscode : "+labanalysiscode+"\n");
	}
	///////////////////////////////////////////////////////////////////////////////////////////////

	Connection conn = null;
	PreparedStatement ps = null;
	
    try{
		conn = MedwanQuery.getInstance().getOpenclinicConnection();
		String sql = "update requestedlabanalyses"+
			         " set finalvalidationdatetime=null,"+
	                 "  finalvalidator=null,"+
	                 "  technicalvalidator=null,"+
	                 "  technicalvalidationdatetime=null"+
	                 " where serverid=? and transactionid=? and analysiscode=?";
		ps = conn.prepareStatement(sql);
		ps.setInt(1,Integer.parseInt(serverid));
		ps.setInt(2,Integer.parseInt(transactionid));
		ps.setString(3,labanalysiscode);
		ps.execute();
    }
    catch(Exception e){
        try{
            if(ps!=null) ps.close();
            if(conn!=null) conn.close();
        }
        catch(Exception e){
        	Debug.printStackTrace(e);
        }
    }
%>
<script>
  window.opener.location.reload();
  window.close();
</script>