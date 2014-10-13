<%@page import="be.openclinic.pharmacy.*,
                java.io.*,
                be.mxs.common.util.system.*,
                be.mxs.common.util.pdf.general.*,
                org.dom4j.*"%>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>
<%
	String sServiceStockId = checkString(request.getParameter("ServiceStockUid"));
%>
<form name='transactionForm' method='post'>
	<table width='100%'>
		<tr>
			<td class='admin2'>
				<%=getTran("web","date",sWebLanguage)%> <%=writeDateField("FindDate", "transactionForm",ScreenHelper.formatDate(new java.util.Date()),sWebLanguage)%>
			</td>
		</tr>
		<tr>
			<td class='admin2'>
				<input name='includePatients' id='includePatients' class='text' type='checkbox'/><%=getTran("web","includepatients",sWebLanguage)%> 
				<input name='includeStocks' id='includeStocks' class='text' type='checkbox'/><%=getTran("web","includeservicestocks",sWebLanguage)%> 
				<input name='includeOther' id='includeOther' class='text' type='checkbox'/><%=getTran("web","includeother",sWebLanguage)%> 
			</td>
		</tr>
		<tr>
			<td class='admin2'>
				<input type="button" class="button" name="print" value='<%=getTranNoLink("web","print",sWebLanguage)%>' onclick='printReport();'/>
			</td>
		</tr>
	</table>
</form>

<script>
	function printReport(){
		var pat="", sto="", oth="";
		if(document.getElementById('includePatients').checked){
			pat="on";
		}
		if(document.getElementById('includeStocks').checked){
			sto="on";
		}
		if(document.getElementById('includeOther').checked){
			oth="on";
		}
		window.open('<c:url value="pharmacy/printMonthlyConsumption.jsp"/>?FindDate='+document.getElementById('FindDate').value+'&includePatients='+pat+'&includeOther='+oth+'&includeStocks='+sto+'&ServiceStockUid=<%=sServiceStockId%>');
		window.close();
	}
</script>