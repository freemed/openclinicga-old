<%@ page import="java.util.*" %>
<%@ page import="be.openclinic.medical.Prescription" %>
<%@ page import="be.openclinic.pharmacy.Product" %>
<%@ page import="be.openclinic.medical.ChronicMedication" %>
<%@include file="/includes/validateUser.jsp"%>
<table width="100%">
<%
    Vector chronicMedications = ChronicMedication.find(activePatient.personid, "", "",
                "", "OC_CHRONICMED_BEGIN", "ASC");
    if(chronicMedications!=null && chronicMedications.size()>0){
        String l="";
        for(int n=0;n<chronicMedications.size();n++){
            ChronicMedication chronicMedication = (ChronicMedication) chronicMedications.elementAt(n);
            if(chronicMedication!=null && chronicMedication.getProduct()!=null){
                Product product = chronicMedication.getProduct();
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
            }
        }
    }
%>
</table>