<%@ page import="be.openclinic.pharmacy.*,java.io.*,be.mxs.common.util.system.*,be.mxs.common.util.pdf.general.*,org.dom4j.*" %>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>
<%
	String sYear = checkString(request.getParameter("FindYear"));
	String sProductStockId=checkString(request.getParameter("ProductStockUid"));
%>
	<form name='transactionForm' method='post'>
		<table width='100%'>
			<tr>
				<td class='admin2'>
	           		<select class="text" name="FindYear" id="FindYear">
	                <%
	                     Calendar calendar = new GregorianCalendar();
	                     int currentYear = calendar.get(Calendar.YEAR); 
	
	                     for(int i=5; i>=0; i--){
	                         %><option value="<%=currentYear-i%>" <%=(i==0?"selected":"")%>><%=currentYear-i%></option><%
	                     }
	                %>
	                </select>
				</td>
				<td class='admin2'>
					<input type='button' name='print' value='<%=getTranNoLink("web","print",sWebLanguage) %>' onclick='printReport();'/>
				</td>
			</tr>
		</table>
	</form>

	<script>
		function printReport(){
			window.open('<c:url value="pharmacy/printProductStockFile.jsp"/>?FindYear='+document.getElementById('FindYear').value+'&ProductStockUid=<%=sProductStockId%>');
			window.close();
		}
	</script>