<%@page import="be.openclinic.accountancy.*,be.mxs.common.util.system.HTMLEntities,java.util.*"%>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>

<%
	String id = checkString(request.getParameter("id"));
    Account account = Account.get(id);
    if(account!=null){
%>
		
		{
		  "id":"<%=id%>",
		  "code":"<%=account.getCode()%>",
		  "type":"<%=account.getType()%>",
		  "name":"<%=account.getName()%>"
		}
		
<%
    }
%>
