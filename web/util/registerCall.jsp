<%@ page import="be.mxs.common.util.db.*,java.sql.*" %>
<%
	String host=request.getHeader("X-Forwarded-For");
	if(host==null){
		host=request.getRemoteAddr();
	}
	Connection conn = MedwanQuery.getInstance().getOpenclinicConnection();
	PreparedStatement ps = conn.prepareStatement("insert into servercalls(updatetime,server) values(?,?)");
	ps.setTimestamp(1, new Timestamp(new java.util.Date().getTime()));
	ps.setString(2,host);
	ps.execute();
	ps.close();
	conn.close();
%>
Call from <%=host%> registered