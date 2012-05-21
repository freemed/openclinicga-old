<%@ page import="java.util.*,java.sql.*" %>
<%@include file="/includes/validateUser.jsp"%>
<%=checkPermission("statistics","select",activeUser)%>
<%
	String begin = checkString(request.getParameter("start"));
	String end = checkString(request.getParameter("end"));
	Hashtable newcases = new Hashtable(), oldcases=new Hashtable();
	int total=0;
	Connection conn = MedwanQuery.getInstance().getAdminConnection();
	String serverid = MedwanQuery.getInstance().getConfigString("serverId");
	PreparedStatement ps = conn.prepareStatement("select count(*) total from AccessLogs where accesscode like 'C.%' and accesstime>=? and accesstime<=?");
	ps.setTimestamp(1,new java.sql.Timestamp(new SimpleDateFormat("dd/MM/yyyy").parse(begin).getTime()));
	ps.setTimestamp(2,new java.sql.Timestamp(new SimpleDateFormat("dd/MM/yyyy HH:mm").parse(end+" 23:59").getTime()));
	ResultSet rs = ps.executeQuery();
	if(rs.next()){
		total=rs.getInt("total");
	}
	rs.close();
	ps.close();
	conn.close();
%>

<table width='100%'>
	<tr class='admin'><td colspan='2'><%=getTran("web","statistics.newpatients",sWebLanguage) %></td></tr>
	<tr class='admin2'>
		<td class='admin'><%=getTran("web","period",sWebLanguage) %></td>
		<td class='admin2'><%=begin%> - <%=end %></td>
	</tr>
	<tr>
		<td class='admin'><%=getTran("web","statistics.newpatients",sWebLanguage) %></td>
		<td class='admin2'><%=total>0?"<a href='javascript:shownewpatients()'>"+total+"</a>":"0" %></td>
	</tr>
</table>

<script>
	function shownewpatients(){
		var URL = "statistics/showNewPatients.jsp&start=<%=begin%>&end=<%=end%>&ts=<%=getTs()%>";
		openPopup(URL,600,400,"OpenClinic");
	}
</script>