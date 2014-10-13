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
					<%=getTran("web","date",sWebLanguage)%> <%=writeDateField("FindDate", "transactionForm", ScreenHelper.formatDate(new java.util.Date()), sWebLanguage)%>
				</td>
				<td class='admin2'>
					<input type='button' class="button" name='print' value='<%=getTranNoLink("web","print",sWebLanguage)%>' onclick='printReport();'/>
				</td>
			</tr>
		</table>
	</form>

	<script>
		function printReport(){
			window.open('<c:url value="pharmacy/printServiceStockInventorySummary.jsp"/>?FindDate='+document.getElementById('FindDate').value+'&ServiceStockUid=<%=sServiceStockId%>');
			window.close();
		}
	</script>