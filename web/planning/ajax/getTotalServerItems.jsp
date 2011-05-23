<%@include file="/includes/validateUser.jsp" %>
<%
	try{
		String sResults="";
		Connection conn = MedwanQuery.getInstance().getOpenclinicConnection();
		PreparedStatement ps;
		ResultSet rs;
		String sDates = checkString(request.getParameter("sDates"));
		String userid=checkString(request.getParameter("userid"));
		long day=24*3600*1000;
		if(sDates.length()>0){
			String dates[]=sDates.split(";");
			for(int n=0;n<dates.length;n++){
				ps=conn.prepareStatement("select count(*) total from OC_PLANNING where OC_PLANNING_PLANNEDDATE >= ? and OC_PLANNING_PLANNEDDATE <? and OC_PLANNING_USERUID=?");
				ps.setDate(1,new java.sql.Date(new SimpleDateFormat("yyyy_MM_dd").parse(dates[n].replaceAll("day\\_","")).getTime()));
				ps.setDate(2,new java.sql.Date(new SimpleDateFormat("yyyy_MM_dd").parse(dates[n].replaceAll("day\\_","")).getTime()+day));
				ps.setString(3,userid);
				rs=ps.executeQuery();
				rs.next();
				if (sResults.length()>0){
					sResults+=";";
				}
				sResults+=dates[n]+"="+rs.getString("total");
				rs.close();
				ps.close();
			}
		}
		conn.close();
		out.println(sResults);
	}
	catch(Exception e){
		e.printStackTrace();
	}
%>