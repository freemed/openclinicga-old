<%@ page import="be.openclinic.medical.PaperPrescription" %><%
    try{
        PaperPrescription.delete(request.getParameter("prescriptionuid"));
        out.print("<script>window.opener.document.getElementById('pp"+request.getParameter("prescriptionuid")+"').style.display='none';</script>");
    }
    catch(Exception e){

    }
%>
<script type="text/javascript">window.close();</script>