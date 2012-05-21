<%@ page import="java.util.*,java.sql.*" %>
<%@include file="/includes/validateUser.jsp"%>
<%=checkPermission("statistics","select",activeUser)%>
<%
	String begin = checkString(request.getParameter("start"));
	String end = checkString(request.getParameter("end"));
	Hashtable newcases = new Hashtable(), oldcases=new Hashtable();
	
	Connection conn = MedwanQuery.getInstance().getOpenclinicConnection();
	String serverid = MedwanQuery.getInstance().getConfigString("serverId");
	PreparedStatement ps = conn.prepareStatement("select distinct a.OC_RFE_ENCOUNTERUID,a.OC_RFE_FLAGS from OC_RFE a,OC_ENCOUNTERS b where b.OC_ENCOUNTER_OBJECTID=replace(a.OC_RFE_ENCOUNTERUID,'"+serverid+".','') and b.OC_ENCOUNTER_BEGINDATE>=? and OC_ENCOUNTER_BEGINDATE<=?");
	ps.setTimestamp(1,new java.sql.Timestamp(new SimpleDateFormat("dd/MM/yyyy").parse(begin).getTime()));
	ps.setTimestamp(2,new java.sql.Timestamp(new SimpleDateFormat("dd/MM/yyyy HH:mm").parse(end+" 23:59").getTime()));
	ResultSet rs = ps.executeQuery();
	while(rs.next()){
		if(rs.getString("OC_RFE_FLAGS").indexOf("N")>-1){
			newcases.put(rs.getString("OC_RFE_ENCOUNTERUID"),"1");
		}
		else {
			oldcases.put(rs.getString("OC_RFE_ENCOUNTERUID"),"1");
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
		<td class='admin2'><%=oldcases.size() %></td>
	</tr>
	<tr class='admin2'>
		<td class='admin'><%=getTran("web","statistics.newcases",sWebLanguage) %></td>
		<td class='admin2'><%=newcases.size() %></td>
	</tr>
</table>