<%@ page import="java.util.Vector" %>
<%@ page import="be.openclinic.pharmacy.Product" %>
<%@ page import="be.openclinic.medical.Prescription" %>
<%@include file="/includes/validateUser.jsp"%>
<table>
<%
    try {
        Vector vPrescriptions = Prescription.getPrescriptionsByPatient(activePatient.personid);

        Iterator iter = vPrescriptions.iterator();

        Prescription prescr;
        Product product;
        while (iter.hasNext()) {
            prescr = (Prescription) iter.next();
            if(prescr!=null){
                product = Product.get(checkString(prescr.getProductUid()));
                if(product!=null){
                    out.print("<tr><td>" + checkString(product.getName()) + "</td></tr>");
                }
            }                
        }
    }
    catch (Exception e) {
        e.printStackTrace();
    }
%>
</table>