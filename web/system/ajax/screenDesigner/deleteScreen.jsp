<%@page import="be.mxs.common.util.system.HTMLEntities"%>
<%@page import="be.openclinic.system.Screen"%>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>

<%	
	String sScreenUID = checkString(request.getParameter("ScreenUID")),
	       sExamId    = checkString(request.getParameter("ExamId"));

    /// DEBUG /////////////////////////////////////////////////////////////////////////////////////
    if(Debug.enabled){
        Debug.println("\n############## system/ajax/screenDesigner/deleteScreen.jsp #############");
        Debug.println("sScreenUID : "+sScreenUID);
        Debug.println("sExamId    : "+sExamId+"\n");
    }
    ///////////////////////////////////////////////////////////////////////////////////////////////

    
	Screen screen = (Screen)session.getAttribute("screen");
	
    screen.delete(sScreenUID,sExamId,Integer.parseInt(activeUser.userid));	
    session.removeAttribute("screen");
%>

{
  "msg":"<%=HTMLEntities.htmlentities(getTranNoLink("web","dataIsDeleted",sWebLanguage))%>"
}