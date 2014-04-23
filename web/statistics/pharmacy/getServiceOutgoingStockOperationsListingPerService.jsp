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
					<%=getTran("web","from",sWebLanguage)%> <%=writeDateField("FindBeginDate", "transactionForm", "01/01/"+(Integer.parseInt(new SimpleDateFormat("yyyy").format(new java.util.Date()))-1), sWebLanguage) %>
					<%=getTran("web","to",sWebLanguage)%> <%=writeDateField("FindEndDate", "transactionForm", "31/12/"+(Integer.parseInt(new SimpleDateFormat("yyyy").format(new java.util.Date()))-1), sWebLanguage) %>
				</td>
			</tr>
			<tr>
				<td class='admin2'>
					<%=getTran("web","destination",sWebLanguage) %>: 
					<select name='destinationStockUid' id='destinationStockUid' class='text'>
						<%
							Vector serviceStocks = ServiceStock.find("", "", "", "", "", "", "OC_STOCK_NAME", "ASC");
							for(int n=0;n<serviceStocks.size();n++){
								ServiceStock stock = (ServiceStock)serviceStocks.elementAt(n);
								if(!stock.getUid().equalsIgnoreCase(sServiceStockId)){
									out.println("<option value='"+stock.getUid()+"'>"+stock.getName()+"</option>");
								}
							}
						%>
					</select>
				</td>
			</tr>
			<tr>
				<td class='admin2'>
					<input type='button' name='print' value='<%=getTranNoLink("web","print",sWebLanguage) %>' onclick='printReport();'/>
				</td>
			</tr>
		</table>
	</form>

	<script>
		function printReport(){
			window.open('<c:url value="pharmacy/printServiceOutgoingStockOperationsListingPerService.jsp"/>?FindBeginDate='+document.getElementById('FindBeginDate').value+'&FindEndDate='+document.getElementById('FindEndDate').value+'&ServiceStockUid=<%=sServiceStockId%>&DestinationStockUid='+document.getElementById('destinationStockUid').value);
			window.close();
		}
	</script>