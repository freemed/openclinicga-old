<%@page import="be.mxs.common.util.system.HTMLEntities"%>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>

<%
    String sUserId     = checkString(request.getParameter("UserId")),
           sShortcutId = checkString(request.getParameter("ShortcutId"));

    /// DEBUG /////////////////////////////////////////////////////////////////
    if(Debug.enabled){
        Debug.println("\n******* userprofile/ajax/deleteShortcut.jsp *******");
        Debug.println("sUserId     : "+sUserId);
        Debug.println("sShortcutId : "+sShortcutId+"\n");
    }
    ///////////////////////////////////////////////////////////////////////////
   
    boolean deleted = activeUser.deleteParameter("usershortcut$"+sShortcutId);
    Debug.println("--> deleted : "+deleted);

    // compose message
    String sMsg = "";
    if(deleted){
    	sMsg = "<font color='green'>"+getTranNoLink("web","dataIsDeleted",sWebLanguage)+"</font>";    
    }
    else{
    	sMsg = "<font color='red'>Error while deleting shortcut</font>";
    }
%>

{
  "msg":"<%=HTMLEntities.htmlentities(sMsg)%>"
}