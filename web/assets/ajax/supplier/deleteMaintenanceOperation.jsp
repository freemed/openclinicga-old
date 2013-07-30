<%@page import="be.mxs.common.util.system.HTMLEntities,
                be.openclinic.assets.MaintenanceOperation"%>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>

<%
    String sOperationUid = checkString(request.getParameter("OperationUid"));
       
    /// DEBUG /////////////////////////////////////////////////////////////////
    if(Debug.enabled){
        Debug.println("\n********* deleteMaintenanceOperation.jsp **********");
        Debug.println("sOperationUid : "+sOperationUid+"\n");
    }
    ///////////////////////////////////////////////////////////////////////////

    
    boolean errorOccurred = MaintenanceOperation.delete(sOperationUid);
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