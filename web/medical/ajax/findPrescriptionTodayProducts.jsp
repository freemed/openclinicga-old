<%@ page import="java.util.*" %>
<%@ page import="be.openclinic.medical.Prescription" %>
<%@ page import="be.openclinic.pharmacy.Product" %>
<%@include file="/includes/validateUser.jsp"%>
<table width="100%">
<%
    Vector activePrescriptions = Prescription.getActivePrescriptions(activePatient.personid);
    if(activePrescriptions!=null && activePrescriptions.size()>0){
        Hashtable ap = new Hashtable();
        Prescription prescription;
        String l="";
        for(int n=0;n<activePrescriptions.size();n++){
            prescription = (Prescription)activePrescriptions.elementAt(n);
            if(prescription!=null && prescription.getProduct()!=null){
                Product product = prescription.getProduct();
                if(ap.get(product.getName())==null){
                    if(l.length()==0){
                        l="1";
                    }
                    else{
                        l="";
                    }
                    out.println("<tr class='list"+l+"'><td valign='middle'><a href='javascript:copyproduct(\""+product.getUid()+"\");'>");
                    %>
                    <img src='<c:url value="/_img/arrow_right.gif"/>' alt='<%=getTranNoLink("web","right",sWebLanguage)%>'/></a>&nbsp;
                    <%
                    out.print("<a href='javascript:copycontent(\""+product.getUid()+"\");'>"+product.getName()+"</a></td></tr>");
                    ap.put(product.getName(),"1");
                }
            }
        }
    }
%>
</table>