<%@ page import="be.openclinic.finance.*,be.openclinic.adt.Encounter,java.text.*,be.mxs.common.util.system.*" %>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>

<%
	if(request.getParameter("novalidate")!=null){
		if(Pointer.getPointer("NOVALIDATE."+checkString(request.getParameter("invoiceuid"))).length()==0){
			Pointer.storePointer("NOVALIDATE."+checkString(request.getParameter("invoiceuid")), activeUser.userid+";"+checkString(request.getParameter("reason")));
		}
	%>
		<script>
			window.opener.setPatientInvoice('<%=checkString(request.getParameter("invoiceuid"))%>');
			window.close();
		</script>
	<%
	}
%>

<form name='transactionForm' method='post'>
	<input type='hidden' name='invoiceuid' value='<%=checkString(request.getParameter("invoiceuid")) %>'/>
	<table width='100%'>
		<tr>
			<td class='admin'><%=getTran("web","reason",sWebLanguage) %></td>
			<td class='admin2'><textarea name='reason' id='reason' cols='60' rows='8' maxlength='240'></textarea></td>
		</tr>
		<tr>
			<td><input class='button' type='submit' name='novalidate' value='<%=getTranNoLink("web","save",sWebLanguage) %>'/></td>
			<td><input class='button' type='button' name='close' onclick='window.close();' value='<%=getTranNoLink("web","close",sWebLanguage) %>'/></td>
		</tr>
	</table>
</form>