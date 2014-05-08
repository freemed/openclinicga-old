<%@ page import="java.util.*,java.sql.*" %>
<%@include file="/includes/validateUser.jsp"%>
<%=checkPermission("statistics","select",activeUser)%>
<%
	String begin = checkString(request.getParameter("start"));
	String end = checkString(request.getParameter("end"));
	int newcases = 0, oldcases=0, unknown=0;
	
	Connection conn = MedwanQuery.getInstance().getOpenclinicConnection();
	String serverid = MedwanQuery.getInstance().getConfigString("serverId");
	PreparedStatement ps = conn.prepareStatement("select count(*) total,OC_ENCOUNTER_NEWCASE from OC_ENCOUNTERS where OC_ENCOUNTER_BEGINDATE>=? and OC_ENCOUNTER_BEGINDATE<=? group by OC_ENCOUNTER_NEWCASE");
	ps.setTimestamp(1,new java.sql.Timestamp(ScreenHelper.parseDate(begin).getTime()));
	ps.setTimestamp(2,new java.sql.Timestamp(ScreenHelper.fullDateFormat.parse(end+" 23:59").getTime()));
	ResultSet rs = ps.executeQuery();
	while(rs.next()){
		String cs=rs.getString("OC_ENCOUNTER_NEWCASE");
		if(cs==null){
			unknown=rs.getInt("total");
		}
		else if(cs.equals("0")){
			oldcases=rs.getInt("total");
		}
		else {
			newcases=rs.getInt("total");
		}
	}
	rs.close();
	ps.close();
	conn.close();
%>

<table width='100%'>
	<tr class='admin'><td colspan='2'><%=getTran("web","statistics.oldandnewcases",sWebLanguage) %></td></tr>
	<tr class='admin2'>
		<td class='admin'><%=getTran("web","period",sWebLanguage) %></td>
		<td class='admin2'><%=begin%> - <%=end %></td>
	</tr>
	<tr>
		<td class='admin'><%=getTran("web","statistics.oldcases",sWebLanguage) %></td>
		<td class='admin2'><%=oldcases+"" %></td>
	</tr>
	<tr class='admin2'>
		<td class='admin'><%=getTran("web","statistics.newcases",sWebLanguage) %></td>
		<td class='admin2'><%=newcases+"" %></td>
	</tr>
	<tr class='admin2'>
		<td class='admin'>?</td>
		<td class='admin2'><%=unknown+"" %></td>
	</tr>
</table>