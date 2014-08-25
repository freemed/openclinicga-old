<%@ page import="be.openclinic.pharmacy.*,java.io.*,be.mxs.common.util.system.*,be.mxs.common.util.pdf.general.*,org.dom4j.*" %>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>
<%
	String sServiceStockId=checkString(request.getParameter("ServiceStockUid"));
%>
	<form name='transactionForm' method='post'>
		<table width='100%'>
			<tr>
				<td class='admin2'>
					<%=getTran("web","from",sWebLanguage)%> <%=writeDateField("FindBeginDate", "transactionForm", new SimpleDateFormat("dd/MM/yyyy").format(new java.util.Date()), sWebLanguage) %>
					<%=getTran("web","to",sWebLanguage)%> <%=writeDateField("FindEndDate", "transactionForm", new SimpleDateFormat("dd/MM/yyyy").format(new java.util.Date()), sWebLanguage) %>
				</td>
				<td class='admin2'>
					<input type='button' class="button" name='print' value='<%=getTranNoLink("web","print",sWebLanguage) %>' onclick='printReport();'/>
				</td>
			</tr>
		</table>
	</form>

	<script>
		function printReport(){
			window.open('<c:url value="pharmacy/printServiceStockOperations.jsp"/>?FindBeginDate='+document.getElementById('FindBeginDate').value+'&FindEndDate='+document.getElementById('FindEndDate').value+'&ServiceStockUid=<%=sServiceStockId%>');
			window.close();
		}
	</script>