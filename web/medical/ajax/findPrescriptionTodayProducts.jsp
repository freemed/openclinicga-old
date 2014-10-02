<%@page import="java.util.*"%>
<%@page import="be.openclinic.medical.Prescription"%>
<%@page import="be.openclinic.pharmacy.Product"%>
<%@include file="/includes/validateUser.jsp"%>

<table width="100%">
<%
	/// DEBUG /////////////////////////////////////////////////////////////////////////////////////
	if(Debug.enabled){
		Debug.println("\n************ medical/ajax/findPrescriptionTodayProduct.jsp ************");
		Debug.println("No parameters\n");
	}
	///////////////////////////////////////////////////////////////////////////////////////////////

	int recCount = 0;
	
    Vector activePrescriptions = Prescription.getActivePrescriptions(activePatient.personid);
    if(activePrescriptions!=null && activePrescriptions.size()>0){
        Hashtable ap = new Hashtable();
        Prescription prescription;
        String sClass = "";
        
        for(int n=0; n<activePrescriptions.size(); n++){
            prescription = (Prescription)activePrescriptions.elementAt(n);
            
            if(prescription!=null && prescription.getProduct()!=null){
                Product product = prescription.getProduct();
                
                if(ap.get(product.getName())==null){
                	// alternate row-style
                    if(sClass.length()==0) sClass = "1";
                    else                   sClass = "";
                    
                    out.print("<tr class='list"+sClass+"'><td valign='middle'><a href='javascript:copyproduct(\""+product.getUid()+"\");'>");
                    
                    %><img src='<c:url value="/_img/themes/default/next.gif"/>' class='link' alt='<%=getTranNoLink("web","copy",sWebLanguage)%>'/></a>&nbsp;<%
                    
                    out.print("<a href='javascript:copycontent(\""+product.getUid()+"\");'>"+product.getName()+"</a></td></tr>");
                    
                    ap.put(product.getName(),"1");
                }
            }
            
            recCount++;
        }
    }
%>
</table>

<%
    if(recCount > 0){
    	%><%=recCount%> <%=getTranNoLink("web","recordsFound",sWebLanguage)%><%
    }
    else{
    	%><%=getTranNoLink("web","noRecordsFound",sWebLanguage)%><%
    }
%>