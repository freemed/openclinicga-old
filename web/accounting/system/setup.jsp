<%@page import="be.mxs.common.util.db.MedwanQuery,
                be.openclinic.system.Config,java.util.Hashtable,java.util.Enumeration" %>
<%@include file="/includes/validateUser.jsp"%>
<%@page errorPage="/includes/error.jsp"%>

<%
	if(request.getParameter("save")!=null){
		Enumeration parameters = request.getParameterNames();
		while(parameters.hasMoreElements()){
			String name = (String)parameters.nextElement();
			if(name.startsWith("config.")){
				MedwanQuery.getInstance().setConfigString(name.substring(7),request.getParameter(name));
			}
		}
	}
%>

<form name="searchForm" method="post">
	<%=writeTableHeader("web.manage","manageaccountancysetup",sWebLanguage,"doBack();")%>
	<table width="100%" class="menu" cellspacing="0" cellpadding="1">
		<tr>
			<td class='admin' width="1%" nowrap><%=getTran("web.accountancy","client.prefix",sWebLanguage)%>&nbsp;</td>
			<td class='admin2'><input name="config.accountancy.ledger.clientprefix" type="text" class="text" size="10" value="<%=MedwanQuery.getInstance().getConfigString("accountancy.ledger.clientprefix","400")%>"/></td>
		</tr>
		<tr>
			<td class='admin'><%=getTran("web.accountancy","supplier.prefix",sWebLanguage)%>&nbsp;</td>
			<td class='admin2'><input name="config.accountancy.ledger.supplierprefix" type="text" class="text" size="10" value="<%=MedwanQuery.getInstance().getConfigString("accountancy.ledger.supplierprefix","2900")%>"/></td>
		</tr>
	</table>
	<input type='submit' name='save' value='<%=getTranNoLink("web","save",sWebLanguage)%>'/>
</form>

