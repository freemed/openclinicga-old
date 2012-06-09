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
System.out.println("1");
String batchUid=checkString(request.getParameter("batchUid"));
String productStockUid=checkString(request.getParameter("productStockUid"));
	Batch batch = Batch.get(batchUid);
	int endLevel = batch.getLevel();
	Vector operations = Batch.getBatchOperations(batchUid,productStockUid);
	System.out.println("2");
	for(int n=0;n<operations.size();n++){
		System.out.println("2.1");
		BatchOperation operation = (BatchOperation)operations.elementAt(n);
		System.out.println("2.2");
		int unitsChanged=operation.getQuantity();
		System.out.println("2.3");
		ProductStockOperation productStockOperation = operation.getProductStockOperation();
		System.out.println("2.4");
		String user = "?";
		if(productStockOperation!=null && productStockOperation.getUpdateUser()!=null && User.getFirstUserName(productStockOperation.getUpdateUser())!=null){
			user = User.getFirstUserName(productStockOperation.getUpdateUser()).toUpperCase();
		}
		System.out.println("2.5");
		String prescription=getTran("web","no",sWebLanguage);
		if(productStockOperation!=null && checkString(productStockOperation.getPrescriptionUid()).length()>0){
			prescription=getTran("web","yes",sWebLanguage);;
		}
		System.out.println("2.6");
		String date=new SimpleDateFormat("dd/MM/yyyy").format(operation.getDate());
		String thirdparty=checkString(operation.getThirdParty());
		System.out.println("3");
		if(operation != null && operation.getType()!=null){
			if(operation.getType().equalsIgnoreCase("receipt")){
				//Incoming 
				if(productStockOperation!=null){
					if(productStockOperation.getSourceDestination()!=null && productStockOperation.getSourceDestination().getObjectType()!=null && productStockOperation.getSourceDestination().getObjectType().equalsIgnoreCase("supplier") || productStockOperation.getSourceDestination().getObjectType().equalsIgnoreCase("servicestock")){
						thirdparty=	productStockOperation.getSourceDestination().getObjectUid();
					}
					out.println("<tr><td class='admin2'>&lt;- "+getTran("productstockoperation.medicationreceipt",productStockOperation.getDescription(),sWebLanguage)+"</td>");
					out.println("<td class='admin2'>"+date+"</td>");
					out.println("<td class='admin2'>"+getTran("productstockoperation.sourcedestinationtype",productStockOperation.getSourceDestination().getObjectType(),sWebLanguage)+"</td>");
					out.println("<td class='admin2'>"+thirdparty+"</td>");
					out.println("<td class='admin2'>"+(endLevel-unitsChanged)+"</td>");
					out.println("<td class='admin2'>+"+unitsChanged+"</td>");
					out.println("<td class='admin2'>"+endLevel+"</td>");
					out.println("<td class='admin2'>"+user+"</td>");
					out.println("<td class='admin2'></td>");
					endLevel-=unitsChanged;			
					System.out.println("4");
				}
			}
			else {
				//Outgoing 
				if(productStockOperation!=null){
					if (productStockOperation.getSourceDestination()!=null && productStockOperation.getSourceDestination().getObjectType()!=null && productStockOperation.getSourceDestination().getObjectType().equalsIgnoreCase("patient")){
						AdminPerson person=AdminPerson.getAdminPerson(thirdparty);
						if(person!=null){
							thirdparty=person.lastname.toUpperCase()+", "+person.firstname.toUpperCase();
						}
						out.println("<tr><td class='admin2'>-&gt; "+getTran("productstockoperation.medicationdelivery",productStockOperation.getDescription(),sWebLanguage)+"</td>");
					}
					else if(productStockOperation.getSourceDestination()!=null && productStockOperation.getSourceDestination().getObjectType()!=null && productStockOperation.getSourceDestination().getObjectType().equalsIgnoreCase("servicestock")){
						thirdparty=	productStockOperation.getSourceDestination().getObjectUid();
						if(thirdparty!=null && thirdparty.length()>0){
							ServiceStock service = ServiceStock.get(thirdparty);
							if(service!=null){
								thirdparty=service.getName();
							}
						}
						out.println("<tr><td class='admin2'>-&gt; "+getTran("productstockoperation.medicationdelivery",productStockOperation.getDescription(),sWebLanguage)+"</td>");
					}
					out.println("<td class='admin2'>"+date+"</td>");
					out.println("<td class='admin2'>"+getTran("productstockoperation.sourcedestinationtype",productStockOperation.getSourceDestination().getObjectType(),sWebLanguage)+"</td>");
					out.println("<td class='admin2'>"+thirdparty+"</td>");
					out.println("<td class='admin2'>"+(endLevel+unitsChanged)+"</td>");
					out.println("<td class='admin2'>"+(-unitsChanged)+"</td>");
					out.println("<td class='admin2'>"+endLevel+"</td>");
					out.println("<td class='admin2'>"+user+"</td>");
					out.println("<td class='admin2'>"+(productStockOperation.getSourceDestination().getObjectType().equalsIgnoreCase("patient")?prescription:"")+"</td>");
					endLevel+=unitsChanged;			
					System.out.println("5");
				}
			}
		}
	}
%>
</table>