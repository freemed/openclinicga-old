<%@page import="be.mxs.common.util.system.HTMLEntities"%>
<%@page import="be.openclinic.system.Screen"%>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>

<%
    String sScreenUID     = checkString(request.getParameter("ScreenUID")),
           sWidth         = checkString(request.getParameter("Width")),
   	       sHeight        = checkString(request.getParameter("Height")),
   	       sCellsEditable = checkString(request.getParameter("CellsEditable"));

    boolean cellsEditable = sCellsEditable.equalsIgnoreCase("true");

    /// DEBUG /////////////////////////////////////////////////////////////////////////////////////
    if(Debug.enabled){
        Debug.println("\n############### system/ajax/screenDesigner/drawScreen.jsp ##############");
        Debug.println("sScreenUID    : "+sScreenUID);
        Debug.println("sWidth        : "+sWidth);
        Debug.println("sHeight       : "+sHeight);
        Debug.println("cellsEditable : "+cellsEditable+"\n");
    }
    ///////////////////////////////////////////////////////////////////////////////////////////////

	Screen screen = null;
    if(sScreenUID.equals("new")){
		screen = new Screen();
		screen.setUpdateUser(activeUser.userid);
	}
	else{			
		screen = (Screen)session.getAttribute("screen");
	}
    
    if(sWidth.length() > 0 && sHeight.length() > 0){
	    // save parameters in screen-object in session
	    screen.widthInCells = Integer.parseInt(sWidth);	    
	    screen.heightInRows = Integer.parseInt(sHeight);
    }
	
	// generate html
    String sHtml = screen.display(sWebLanguage,cellsEditable,sCONTEXTPATH);
    if(Debug.enabled){
        System.out.println("\n"+sHtml+"\n");
    }
    
    sHtml = sHtml.replaceAll("<br>","").replaceAll("\r\n","").replaceAll("\n","");
    
    session.setAttribute("screen",screen);
%>

{
  "screenUID":"<%=screen.getUid()%>",
  "html":"<%=HTMLEntities.htmlentities(sHtml)%>"
}