<%@page import="be.openclinic.accounting.*,
                java.util.*,
                be.mxs.common.util.system.HTMLEntities"%>
<%@include file="/includes/validateUser.jsp"%>

<table width="100%" class="sortable" id="searchresults" cellspacing="1" style="border:none;">
    <%-- header --%>
    <tr class="admin" style="padding-left:1px;">
        <td><%=HTMLEntities.htmlentities(getTran("web","code",sWebLanguage))%></td>
        <td><%=HTMLEntities.htmlentities(getTran("web","type",sWebLanguage))%></td>
        <td><%=HTMLEntities.htmlentities(getTran("web","name",sWebLanguage))%></td>
    </tr>
    
    <tbody class="hand">
		<%
			Vector accounts = new Account().getAllSorted("AC_ACCOUNT_CODE");
			String sClass = "";
			Account account;
			for(int n=0; n<accounts.size(); n++){
				account = (Account)accounts.elementAt(n);
				
		        if(sClass.length()==0) sClass = "1";
		        else                   sClass = "";
		        
				out.print("<tr class='list"+sClass+"' onclick='displayItem("+account.getId()+")'>");
				 out.print("<td>"+checkString(account.getCode())+"</td>");
				 out.print("<td>"+getTranNoLink("account.type",checkString(account.getType()),sWebLanguage)+"</td>");
				 out.print("<td>"+checkString(account.getName())+"</td>");
				out.print("</tr>");
			}
		%>
    </tbody>
</table>