<%@page import="be.openclinic.pharmacy.Product"%>
<%@include file="/mobile/_common/head.jsp"%>

<table class="list" padding="0" cellspacing="1" width="<%=sTABLE_WIDTH%>">
	<tr class="admin"><td colspan="3"><%=getTran("mobile","activeMedication",activeUser)%></td></tr>
	
	<%	
	    Vector vPrescriptions = Prescription.getActivePrescriptions(activePatient.personid);
	    
	    if(vPrescriptions.size() > 0){
		    Connection conn = MedwanQuery.getInstance().getAdminConnection();
		    
		    Prescription prescriPatient;
		    AdminPerson mapersonne;
	    	Product product;
		    
		    for(int n=0; n<vPrescriptions.size(); n++){
		    	prescriPatient = (Prescription)vPrescriptions.elementAt(n);		    	
		    	mapersonne = AdminPerson.getAdminPerson(conn,prescriPatient.getPrescriberUid());
		    	
		    	out.print("<table class='list' padding='0' cellspacing='1' width='"+sTABLE_WIDTH+"' style='border-bottom:none;'>"+
		    	           "<tr><td width='80' class='admin'>"+getTran("Web","begin",activeUser)+"</td><td>"+stdDateFormat.format(prescriPatient.getBegin())+"</td></tr>"+
	  			      	   "<tr><td class='admin'>"+getTran("Web","end",activeUser)+"</td><td>"+stdDateFormat.format(prescriPatient.getEnd())+"</td></tr>"+
		    			   "<tr><td class='admin'>"+getTran("Web","name",activeUser)+"</td><td><b>"+Product.get(prescriPatient.getProductUid()).getName()+"</b></td></tr>"+
		    			   "<tr><td class='admin'>"+getTran("Web","dose",activeUser)+"</td><td>"+prescriPatient.getUnitsPerTimeUnit()+"/"+getTran("prescription.timeunit",prescriPatient.getTimeUnit(),activeUser)+"</td></tr>"+
		    	           "<tr><td class='admin'>"+getTran("mobile","prescriber",activeUser)+"</td><td>"+prescriPatient.getPrescriber().getFullName()+"</td></tr>"+
		    			  "</table>");
		    
		    }
		    conn.close();
		}
	    else{
			out.print("<tr><td colspan='2'><i>"+getTran("web","noData",activeUser)+"</i></td></tr>");
	    }
    %>
</table>
			
<%-- BUTTONS --%>
<%=alignButtonsStart()%>
	<input type="button" class="button" name="backButton" onclick="doBack();" value="<%=getTranNoLink("web","back",activeUser)%>">
<%=alignButtonsStop()%>
		 
<script>
  function doBack(){
	window.location.href = "selectPatient.jsp?personid=<%=activePatient.personid%>&ts=<%=getTs()%>";
  }
</script>
			
<%@include file="/mobile/_common/footer.jsp"%>