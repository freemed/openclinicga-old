<%@page import="be.openclinic.accountancy.*,java.util.*,be.mxs.common.util.system.HTMLEntities"%>
<%@include file="/includes/validateUser.jsp"%>
<table width="100%" class="sortable" id="searchresults" cellspacing="1" style="border-bottom:none;">
    <%-- header --%>
    <tr class="admin" style="padding-left: 1px;">
        <td><%=HTMLEntities.htmlentities(getTran("web","code",sWebLanguage))%></td>
        <td><%=HTMLEntities.htmlentities(getTran("web","type",sWebLanguage))%></td>
        <td><%=HTMLEntities.htmlentities(getTran("web","name",sWebLanguage))%></td>
    </tr>
    
    <tbody onmouseover='this.style.cursor="hand"' onmouseout='this.style.cursor="default"'>
<%
	Vector accounts = new Account().getAllSorted("AC_ACCOUNT_CODE");
	String sClass="";
	for (int n=0;n<accounts.size();n++){
		Account account = (Account)accounts.elementAt(n);
        if(sClass.length()==0) sClass = "1";
        else                   sClass = "";
		out.println("<tr class='list"+sClass+"' onclick='displayItem("+account.getId()+")'>");
		out.println("<td>"+checkString(account.getCode())+"</td>");
		out.println("<td>"+getTranNoLink("account.type",checkString(account.getType()),sWebLanguage)+"</td>");
		out.println("<td>"+checkString(account.getName())+"</td>");
		out.println("</tr>");
	}
%>
    </tbody>
</table>
