<%@ page import="be.openclinic.finance.*,java.util.Date" %>
<%@ page errorPage="/includes/error.jsp" %>
<%@ include file="/includes/validateUser.jsp" %>
<%
	String sDate=checkString(request.getParameter("expirydate"));
	if(sDate.length()==0){
		sDate=ScreenHelper.formatDate(new java.util.Date());
	}
	java.util.Date date = ScreenHelper.parseDate(sDate);
%>
<form name=renewExpiredForm" method="post">
<table>
	<tr><td class='admin'><label class='text'><%=getTran("web","renewcontributionsthatexpireon",sWebLanguage)%></label></td><td class='admin2'><%=writeDateField("expirydate","renewExpiredForm",sDate,sWebLanguage)%>
<%
	if(request.getParameter("find")==null){
%>
	<input name='find' type='submit' value='<%=getTran("web","find",sWebLanguage)%>'/></td></tr>
<%
	}
	else {
%>
	<input name='update' type='submit' value='<%=getTran("web","update",sWebLanguage)%>'/></td></tr>
<%
	}
%>
</table>
</form>
<br/>
<%
if(request.getParameter("find")!=null){
	out.println("<h2>"+getTran("web","totalnumberofcontributionstorenew",sWebLanguage)+": "+PrestationDebet.renewExpiredContributions(date,activeUser.userid,false)+"</h2>");
}
else if(request.getParameter("update")!=null){
	out.println("<h2>"+getTran("web","totalnumberofcontributionsrenewed",sWebLanguage)+": "+PrestationDebet.renewExpiredContributions(date,activeUser.userid,true)+"</h2>");
}
%>