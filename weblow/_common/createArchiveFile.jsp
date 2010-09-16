<%@include file="/includes/validateUser.jsp"%>
<%
    if(MedwanQuery.getInstance().updateArchiveFile(Integer.parseInt(activePatient.personid))){
        out.println("<script>window.opener.doSPatient();window.close();</script>");
    }
    else{
        out.println("<script>window.close();</script>");    
    }
%>