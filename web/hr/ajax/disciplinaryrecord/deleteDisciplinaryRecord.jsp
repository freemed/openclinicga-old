<%@page import="be.mxs.common.util.system.HTMLEntities,
                be.openclinic.hr.DisciplinaryRecord"%>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>

<%
    String sDisRecUid = checkString(request.getParameter("DisRecUid"));
       
    /// DEBUG /////////////////////////////////////////////////////////////////
    if(Debug.enabled){
        Debug.println("\n********** deleteDisciplinaryRecord.jsp ***********");
        Debug.println("sDisRecUid : "+sDisRecUid+"\n");
    }
    ///////////////////////////////////////////////////////////////////////////

    
    boolean errorOccurred = DisciplinaryRecord.delete(sDisRecUid);
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