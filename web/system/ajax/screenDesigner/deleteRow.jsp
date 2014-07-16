<%@page import="be.mxs.common.util.system.HTMLEntities"%>
<%@page import="be.openclinic.system.Screen"%>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>

<%	
	String sScreenUID = checkString(request.getParameter("ScreenUID")),
	       sRowId     = checkString(request.getParameter("RowId"));

    /// DEBUG /////////////////////////////////////////////////////////////////////////////////////
    if(Debug.enabled){
        Debug.println("\n################ system/ajax/screenDesigner/deleteRow.jsp ###############");
        Debug.println("sScreenUID : "+sScreenUID);
        Debug.println("sRowId     : "+sRowId+"\n");
    }
    ///////////////////////////////////////////////////////////////////////////////////////////////
    
	Screen screen = (Screen)session.getAttribute("screen");

    Debug.println("--> rows before : "+screen.getRows().size());
    screen.deleteRow(sRowId,Integer.parseInt(activeUser.userid),sWebLanguage,session);
    Debug.println("--> rows after : "+screen.getRows().size()+"\n");
    
    session.setAttribute("screen",screen);
%>

{
  "msg":"<%=HTMLEntities.htmlentities(getTranNoLink("web","dataIsDeleted",sWebLanguage))%>"
}