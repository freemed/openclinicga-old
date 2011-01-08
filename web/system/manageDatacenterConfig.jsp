<%@include file="/includes/validateUser.jsp"%>
<%@page errorPage="/includes/error.jsp"%>

<%
	if(request.getParameter("submit")!=null){
		MedwanQuery.getInstance().setConfigString("datacenterEnabled",request.getParameter("datacenterEnabled"));
		MedwanQuery.getInstance().setConfigString("datacenterScheduleInterval",request.getParameter("datacenterScheduleInterval"));
		MedwanQuery.getInstance().setConfigString("datacenterServerId",request.getParameter("datacenterServerId"));
		MedwanQuery.getInstance().setConfigString("datacenterPOP3Host",request.getParameter("datacenterPOP3Host"));
		MedwanQuery.getInstance().setConfigString("datacenterPOP3Username",request.getParameter("datacenterPOP3Username"));
		MedwanQuery.getInstance().setConfigString("datacenterPOP3Password",request.getParameter("datacenterPOP3Password"));
		MedwanQuery.getInstance().setConfigString("datacenterSMTPHost",request.getParameter("datacenterSMTPHost"));
		MedwanQuery.getInstance().setConfigString("datacenterSMTPFrom",request.getParameter("datacenterSMTPFrom"));
		MedwanQuery.getInstance().setConfigString("datacenterSMTPTo",request.getParameter("datacenterSMTPTo"));
		MedwanQuery.getInstance().setConfigString("datacenterTemplateSource",request.getParameter("datacenterTemplateSource"));
	}
%>

<form name="transactionForm" method="post" action="<c:url value="/main.do?Page=/system/manageDatacenterConfig.jsp"/>">
	<table>
		<tr class="admin">
			<td colspan="2"><%=getTran("Web.Manage", "manageDatacenterConfig", sWebLanguage)%></td>
		</tr>
		<tr>
			<td class="admin">datacenterEnabled</td>
			<td class="admin2"><input type="text" size="2" name="datacenterEnabled" value="<%=MedwanQuery.getInstance().getConfigString("datacenterEnabled","0")%>"/></td>
		</tr>
		<tr>
			<td class="admin">datacenterScheduleInterval</td>
			<td class="admin2"><input type="text" size="10" name="datacenterScheduleInterval" value="<%=MedwanQuery.getInstance().getConfigString("datacenterScheduleInterval","20000")%>"/> ms</td>
		</tr>
		<tr>
			<td class="admin">datacenterServerId</td>
			<td class="admin2"><input type="text" size="5" name="datacenterServerId" value="<%=MedwanQuery.getInstance().getConfigString("datacenterServerId","")%>"/></td>
		</tr>
		<tr>
			<td class="admin">datacenterPOP3Host</td>
			<td class="admin2"><input type="text" size="80" name="datacenterPOP3Host" value="<%=MedwanQuery.getInstance().getConfigString("datacenterPOP3Host","mail.globalhealthbarometer.org")%>"/></td>
		</tr>
		<tr>
			<td class="admin">datacenterPOP3Username</td>
			<td class="admin2"><input type="text" size="80" name="datacenterPOP3Username" value="<%=MedwanQuery.getInstance().getConfigString("datacenterPOP3Username","@globalhealthbarometer.org")%>"/></td>
		</tr>
		<tr>
			<td class="admin">datacenterPOP3Password</td>
			<td class="admin2"><input type="text" size="80" name="datacenterPOP3Password" value="<%=MedwanQuery.getInstance().getConfigString("datacenterPOP3Password","")%>"/></td>
		</tr>
		<tr>
			<td class="admin">datacenterSMTPHost</td>
			<td class="admin2"><input type="text" size="80" name="datacenterSMTPHost" value="<%=MedwanQuery.getInstance().getConfigString("datacenterSMTPHost","mail.globalhealthbarometer.org")%>"/></td>
		</tr>
		<tr>
			<td class="admin">datacenterSMTPFrom</td>
			<td class="admin2"><input type="text" size="80" name="datacenterSMTPFrom" value="<%=MedwanQuery.getInstance().getConfigString("datacenterSMTPFrom","@globalhealthbarometer.org")%>"/></td>
		</tr>
		<tr>
			<td class="admin">datacenterSMTPTo</td>
			<td class="admin2"><input type="text" size="80" name="datacenterSMTPTo" value="<%=MedwanQuery.getInstance().getConfigString("datacenterSMTPTo","server.mxs@globalhealthbarometer.org")%>"/></td>
		</tr>
		<tr>
			<td class="admin">datacenterTemplateSource</td>
			<td class="admin2"><input type="text" size="80" name="datacenterTemplateSource" value="<%=MedwanQuery.getInstance().getConfigString("datacenterTemplateSource",MedwanQuery.getInstance().getConfigString("templateSource","http://localhost/openclinic/_common/xml/"))%>"/></td>
		</tr>
	</table>
	<p/>
	<input type="submit" name="submit" value="<%=getTran("web","save",sWebLanguage)%>"/>
</form>