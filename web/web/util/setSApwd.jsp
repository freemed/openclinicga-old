<%@page import="net.admin.User"%>
<%
	User user = new User();
	user.initialize(4);
	user.password=user.encrypt("overmeire");
	user.savePasswordToDB();
	out.println("personid="+user.personid);
	out.println("password="+new String(user.password));
%>