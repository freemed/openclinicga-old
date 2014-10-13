<%@page import="be.mxs.common.util.system.HTMLEntities,
                be.openclinic.assets.MaintenanceOperation"%>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>

<%
    String sOperationUID = checkString(request.getParameter("OperationUID"));
       
    /// DEBUG /////////////////////////////////////////////////////////////////
    if(Debug.enabled){
        Debug.println("\n********* deleteMaintenanceOperation.jsp **********");
        Debug.println("sOperationUID : "+sOperationUID+"\n");
    }
    ///////////////////////////////////////////////////////////////////////////

    
    boolean errorOccurred = MaintenanceOperation.delete(sOperationUID);
    String sMessage = "";
    
    if(!errorOccurred){
        sMessage = "<font color='green'>"+getTranNoLink("web","dataIsDeleted",sWebLanguage)+"</font>";
    }
    else{
        sMessage = "<font color='red'>"+getTranNoLink("web","error",sWebLanguage)+"</font>";
    }
%>

{
  "message":"<%=HTMLEntities.htmlentities(sMessage)%>"
}