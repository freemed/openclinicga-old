<%@page import="be.openclinic.pharmacy.Product"%>
<%@include file="/mobile/validatePatient.jsp"%>

<table width='100%'>
	<tr><td colspan='3' bgcolor='gray'><b><u><%=getTran("mobile","Active medication",activeUser) %></u></b></td></tr>
	<table width='100%'>	
    <td><b><%=getTran("Web","begindate",activeUser)%></b></td><td><b><%=getTran("Web","productname",activeUser)%></b></td>
	<td><b><%=getTran("Web","prescriptionrule",activeUser)%></b></td><td><b><%=getTran("Web","enddate",activeUser)%></b></td>
	<td><b><%=getTran("pdfprescriptions","name.prescriber",activeUser)%></b></td>
	<%
	
	    Vector vPrescriptions = Prescription.getActivePrescriptions(activePatient.personid);
	    Connection conn = MedwanQuery.getInstance().getAdminConnection();
	    for (int n=0; n<vPrescriptions.size(); n++){
	    	Prescription prescriPatient = (Prescription)vPrescriptions.elementAt(n);
	    	Product product;
	    	
	    	AdminPerson mapersonne = AdminPerson.getAdminPerson(conn,prescriPatient.getPrescriberUid());
	
	    	out.print("<tr><td>"+new SimpleDateFormat("dd/MM/yyyy").format(prescriPatient.getBegin())+"</td>"+
	    			      "<td>"+Product.get(prescriPatient.getProductUid()).getName()+"</td>"+
	    			      "<td>"+prescriPatient.getUnitsPerTimeUnit()+"</td>"+
	    			      "<td>"+new SimpleDateFormat("dd/MM/yyyy").format(prescriPatient.getEnd())+"</td>"+
	    	              "<td>"+prescriPatient.getPrescriber().getFullName()+"</td></tr>");
	    
	    }
	    conn.close();	
    %>
   </table>
</table>