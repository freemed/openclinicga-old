<%@page import="be.mxs.common.util.system.HTMLEntities,
                be.openclinic.hr.Salary"%>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>

<%
    String sSalaryUid = checkString(request.getParameter("SalaryUid"));
       
    /// DEBUG /////////////////////////////////////////////////////////////////
    if(Debug.enabled){
        Debug.println("\n***************** deleteSalary.jsp ****************");
        Debug.println("sSalaryUid : "+sSalaryUid+"\n");
    }
    ///////////////////////////////////////////////////////////////////////////

    
    boolean errorOccurred = Salary.delete(sSalaryUid);
    String sMessage = "";
    
    if(!errorOccurred){
        sMessage = getTran("web","dataIsDeleted",sWebLanguage);
    }
    else{
        sMessage = getTran("web","error",sWebLanguage);
    }
%>

{
  "message":"<%=HTMLEntities.htmlentities(sMessage)%>"
}