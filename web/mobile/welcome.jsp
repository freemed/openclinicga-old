<%@page import="java.sql.*, java.text.*"%>
<%@include file="/mobile/validateUser.jsp"%>

<%=getTran("mobile","welcome",activeUser)%> <%=activeUser.person.firstname+" "+activeUser.person.lastname%>

<%
	Connection conn = MedwanQuery.getInstance().getAdminConnection();
	PreparedStatement ps = conn.prepareStatement("select max(accesstime) as maxtime from AccessLogs where userid=?");
	ps.setString(1,activeUser.userid);
	ResultSet rs = ps.executeQuery();
	if(rs.next()){
		out.println("<br/>"+getTran("mobile","lastlogin",activeUser)+": "+new SimpleDateFormat("dd/MM/yyyy HH:mm:ss").format(rs.getTimestamp("maxtime")));
	}
	rs.close();
	ps.close();
	conn.close();
	
%>
<br/>
<a href="searchPatient.jsp"><%=getTran("mobile","searchpatient",activeUser) %></a>