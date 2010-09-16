<%@ page import="be.openclinic.pharmacy.ServiceStock,
                 be.openclinic.pharmacy.Batch,
                 be.openclinic.pharmacy.BatchOperation,
                 be.openclinic.pharmacy.ProductStockOperation,
                 java.util.Vector,
                 be.mxs.common.util.system.HTMLEntities" %>
<%@ page import="be.openclinic.pharmacy.ProductStock" %>
<%@ page errorPage="/includes/error.jsp" %>
<%@ include file="/includes/validateUser.jsp" %>
<table width=100%>
<tr class="admin">
	<td><%=getTran("web","operation",sWebLanguage) %></td>
	<td><%=getTran("web","date",sWebLanguage) %></td>
	<td><%=getTran("web","thirdpartytype",sWebLanguage) %></td>
	<td><%=getTran("web","thirdpartyname",sWebLanguage) %></td>
	<td><%=getTran("web","beginlevel",sWebLanguage) %></td>
	<td><%=getTran("web","modification",sWebLanguage) %></td>
	<td><%=getTran("web","endlevel",sWebLanguage) %></td>
	<td><%=getTran("web","user",sWebLanguage) %></td>
	<td><%=getTran("web","prescription",sWebLanguage) %></td>
</tr>
<%
String batchUid=checkString(request.getParameter("batchUid"));
String productStockUid=checkString(request.getParameter("productStockUid"));
	Batch batch = Batch.get(batchUid);
	int endLevel = batch.getLevel();
	Vector operations = Batch.getProductStockOperations(batchUid,productStockUid);
	for(int n=0;n<operations.size();n++){
		BatchOperation operation = (BatchOperation)operations.elementAt(n);
		int unitsChanged=operation.getQuantity();
		ProductStockOperation productStockOperation = operation.getProductStockOperation();
		String user = User.getFirstUserName(productStockOperation.getUpdateUser()).toUpperCase();
		String prescription=getTran("web","no",sWebLanguage);
		if(checkString(productStockOperation.getPrescriptionUid()).length()>0){
			prescription=getTran("web","yes",sWebLanguage);;
		}
		if(operation.getType().equalsIgnoreCase("receipt")){
			//Incoming 
			out.println("<tr><td class='admin2'>&lt;- "+getTran("productstockoperation.medicationreceipt",operation.getDescription(),sWebLanguage)+"</td>");
			out.println("<td class='admin2'>"+date+"</td>");
			out.println("<td class='admin2'>"+getTran("productstockoperation.sourcedestinationtype",operation.getSourceDestination().getObjectType(),sWebLanguage)+"</td>");
			out.println("<td class='admin2'>"+thirdparty+"</td>");
			out.println("<td class='admin2'>"+(endLevel-unitsChanged)+"</td>");
			out.println("<td class='admin2'>+"+unitsChanged+"</td>");
			out.println("<td class='admin2'>"+endLevel+"</td>");
			out.println("<td class='admin2'>"+user+"</td>");
			out.println("<td class='admin2'></td>");
			endLevel-=unitsChanged;			
		}
		else {
			//Outgoing 
			if (operation.getSourceDestination().getObjectType().equalsIgnoreCase("patient")){
				out.println("<tr><td class='admin2'>-&gt; "+getTran("productstockoperation.patientmedicationdelivery",operation.getDescription(),sWebLanguage)+"</td>");
			}
			out.println("<td class='admin2'>"+date+"</td>");
			out.println("<td class='admin2'>"+getTran("productstockoperation.sourcedestinationtype",operation.getSourceDestination().getObjectType(),sWebLanguage)+"</td>");
			out.println("<td class='admin2'>"+thirdparty+"</td>");
			out.println("<td class='admin2'>"+(endLevel+unitsChanged)+"</td>");
			out.println("<td class='admin2'>"+(-unitsChanged)+"</td>");
			out.println("<td class='admin2'>"+endLevel+"</td>");
			out.println("<td class='admin2'>"+user+"</td>");
			out.println("<td class='admin2'>"+(operation.getSourceDestination().getObjectType().equalsIgnoreCase("patient")?prescription:"")+"</td>");
			endLevel+=unitsChanged;			
		}
	}
%>
</table>