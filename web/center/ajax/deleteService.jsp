<%@page import="be.mxs.common.util.system.HTMLEntities,
                be.openclinic.system.Center"%>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>

<%
    String sServiceUid = checkString(request.getParameter("ServiceUid"));
       
    /// DEBUG /////////////////////////////////////////////////////////////////
    if(Debug.enabled){
        Debug.println("\n********** center/ajax/deleteService.jsp **********");
        Debug.println("sServiceUid : "+sServiceUid+"\n");
    }
    ///////////////////////////////////////////////////////////////////////////

    
    boolean errorOccurred = Center.delete(sServiceUid);
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