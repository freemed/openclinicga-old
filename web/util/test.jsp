<%@page import="be.mxs.common.util.system.HTMLEntities"%>
<%@ page import="java.util.*,be.openclinic.accountancy.*" %>
<%
	Account account = new Account();
	Vector v = account.getAll();
	for(int n=0;n<v.size();n++){
		Account acc = (Account)v.elementAt(n);
		out.println(acc.getId()+": "+acc.getType()+"<br/>");
	}
	
%>