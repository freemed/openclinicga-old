<%@ page import="java.util.*,java.sql.*" %>
<%@include file="/includes/validateUser.jsp"%>
<%=checkPermission("statistics","select",activeUser)%>
<table width='100%'>
	<tr class='admin'>
		<td><%=getTran("web","name",sWebLanguage)%></td>
		<td><%=getTran("web","dateofbirth",sWebLanguage)%></td>
		<td><%=getTran("web","gender",sWebLanguage)%></td>
		<td><%=getTran("web","creationdate",sWebLanguage)%></td>
	</tr>
<%
	String begin = checkString(request.getParameter("start"));
	String end = checkString(request.getParameter("end"));
	Hashtable newcases = new Hashtable(), oldcases=new Hashtable();
	int total=0;
	Connection conn = MedwanQuery.getInstance().getAdminConnection();
	String serverid = MedwanQuery.getInstance().getConfigString("serverId");
	PreparedStatement ps = conn.prepareStatement("select accesscode,accesstime from AccessLogs where accesscode like 'C.%' and accesstime>=? and accesstime<=?");
	ps.setTimestamp(1,new java.sql.Timestamp(ScreenHelper.parseDate(begin).getTime()));
	ps.setTimestamp(2,new java.sql.Timestamp(ScreenHelper.fullDateFormat.parse(end+" 23:59").getTime()));
	ResultSet rs = ps.executeQuery();
	AdminPerson patient = null;
	SortedSet patients = new TreeSet();
	while(rs.next()){
		patient=AdminPerson.getAdminPerson(rs.getString("accesscode").split("\\.")[1]);
		patients.add("<tr><td class='admin'>"+patient.lastname.toUpperCase()+", "+patient.firstname+" ("+patient.personid+")</td><td class='admin2'>"+patient.dateOfBirth+"</td><td class='admin2'>"+patient.gender+"</td><td class='admin2'>"+ScreenHelper.stdDateFormat.format(rs.getDate("accesstime"))+"</td></tr>");
	}
	rs.close();
	ps.close();
	conn.close();
	Iterator i = patients.iterator();
	while(i.hasNext()){
		out.println(i.next());
	}
%>
</table>