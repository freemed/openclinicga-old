<%@page import="be.openclinic.pharmacy.Product,java.sql.*"%>
<%@include file="/mobile/validatePatient.jsp"%>

<table width='100%'>
	<tr><td colspan='3' bgcolor='peachpuff'><b><%=getTran("mobile","activemedication",activeUser) %></b></td></tr>
	<%
	
	    Vector vPrescriptions = Prescription.getActivePrescriptions(activePatient.personid);
	    Connection conn = MedwanQuery.getInstance().getAdminConnection();
	    for (int n=0; n<vPrescriptions.size(); n++){
	    	Prescription prescriPatient = (Prescription)vPrescriptions.elementAt(n);
	    	Product product;
	    	if(n>0){
	    		out.println("<hr/>");
	    	}
	    	AdminPerson mapersonne = AdminPerson.getAdminPerson(conn,prescriPatient.getPrescriberUid());
	    	out.print("<table width='100%'><tr><td>"+getTran("Web","begin",activeUser)+"</td><td>"+new SimpleDateFormat("dd/MM/yyyy").format(prescriPatient.getBegin())+"</td></tr>"+
  			      		  "<tr><td>"+getTran("Web","end",activeUser)+"</td><td>"+new SimpleDateFormat("dd/MM/yyyy").format(prescriPatient.getEnd())+"</td></tr>"+
	    			      "<tr><td>"+getTran("Web","name",activeUser)+"</td><td><b>"+Product.get(prescriPatient.getProductUid()).getName()+"</b></td></tr>"+
	    			      "<tr><td>"+getTran("Web","dose",activeUser)+"</td><td>"+prescriPatient.getUnitsPerTimeUnit()+"/"+getTran("prescription.timeunit",prescriPatient.getTimeUnit(),activeUser)+"</td></tr>"+
	    	              "<tr><td>"+getTran("mobile","prescriber",activeUser)+"</td><td>"+prescriPatient.getPrescriber().getFullName()+"</td></tr></table>");
	    
	    }
	    conn.close();	
    %>
   </table>
</table>