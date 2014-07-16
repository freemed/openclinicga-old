<%@page import="be.mxs.common.util.system.HTMLEntities"%>
<%@page import="be.openclinic.system.Screen"%>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>

<%	
	String sScreenUID        = checkString(request.getParameter("ScreenUID")),
		   sRowId            = checkString(request.getParameter("RowId")),
		   sDirectionAndStep = checkString(request.getParameter("DirectionAndStep"));

    /// DEBUG /////////////////////////////////////////////////////////////////////////////////////
    if(Debug.enabled){
        Debug.println("\n################ system/ajax/screenDesigner/moveRow.jsp ################");
        Debug.println("sScreenUID        : "+sScreenUID);
        Debug.println("sRowId            : "+sRowId);
        Debug.println("sDirectionAndStep : "+sDirectionAndStep+"\n");
    }
    ///////////////////////////////////////////////////////////////////////////////////////////////
    
	Screen screen = (Screen)session.getAttribute("screen");

    screen.moveRow(sRowId,Integer.parseInt(sDirectionAndStep),Integer.parseInt(activeUser.userid),sWebLanguage,session);
	
    session.setAttribute("screen",screen);
%>

{
  "msg":"<%=HTMLEntities.htmlentities(getTranNoLink("web","rowIsMoved",sWebLanguage))%>"
}