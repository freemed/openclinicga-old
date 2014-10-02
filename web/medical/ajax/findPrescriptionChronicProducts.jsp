<%@page import="java.util.*"%>
<%@page import="be.openclinic.medical.Prescription"%>
<%@page import="be.openclinic.pharmacy.Product"%>
<%@page import="be.openclinic.medical.ChronicMedication"%>
<%@include file="/includes/validateUser.jsp"%>

<table width="100%">
<%	
	/// DEBUG /////////////////////////////////////////////////////////////////////////////////////
	if(Debug.enabled){
		Debug.println("\n********** medical/ajax/findPrescriptionChronicProduct.jsp ************");
		Debug.println("No parameters\n");
	}
	///////////////////////////////////////////////////////////////////////////////////////////////

    int recCount = 0;

    Vector chronicMedications = ChronicMedication.find(activePatient.personid,"","","","OC_CHRONICMED_BEGIN","ASC");
    if(chronicMedications!=null && chronicMedications.size()>0){
        String sClass = "";
        
        for(int n=0; n<chronicMedications.size(); n++){
            ChronicMedication chronicMedication = (ChronicMedication)chronicMedications.elementAt(n);
            
            if(chronicMedication!=null && chronicMedication.getProduct()!=null){
                Product product = chronicMedication.getProduct();

            	// alternate row-style
                if(sClass.length()==0) sClass = "1";
                else                   sClass = "";

                out.print("<tr class='list"+sClass+"'>"+
                           "<td valign='middle'>"+
                            "<a href='javascript:copyproduct(\""+product.getUid()+"\");'>");
                
                %><img src='<c:url value="/_img/themes/default/next.gif"/>' class='link' alt='<%=getTranNoLink("web","copy",sWebLanguage)%>'/></a>&nbsp;<%
               
                out.print(  "<a href='javascript:copycontent(\""+product.getUid()+"\");'>"+product.getName()+"</a>"+
                           "</td>"+
                		  "</tr>");
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