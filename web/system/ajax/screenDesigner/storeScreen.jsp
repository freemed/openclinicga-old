<%@page import="be.mxs.common.util.system.HTMLEntities"%>
<%@page import="be.openclinic.system.Screen"%>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>

<%
	Screen screen = (Screen)session.getAttribute("screen");
	if(screen==null){
		screen = new Screen();
		screen.setUpdateUser(activeUser.userid);
	}
	
	String sScreenWidth  = checkString(request.getParameter("Width")),
		   sScreenHeight = checkString(request.getParameter("Height")),
		   sScreenLabels = checkString(request.getParameter("Labels"));

    /// DEBUG /////////////////////////////////////////////////////////////////////////////////////
    if(Debug.enabled){
        Debug.println("\n\n########################################################################");
        Debug.println("############## system/ajax/screenDesigner/storeScreen.jsp ##############");
        Debug.println("########################################################################");
        Debug.println("--> screen.getUid() : "+screen.getUid());
        Debug.println("sScreenWidth  : "+sScreenWidth);
        Debug.println("sScreenHeight : "+sScreenHeight);
        Debug.println("sScreenLabels : "+sScreenLabels+"\n");
    }
    ///////////////////////////////////////////////////////////////////////////////////////////////

    screen.widthInCells = Integer.parseInt(sScreenWidth);
	screen.heightInRows = Integer.parseInt(sScreenHeight); 
    screen.userID = Integer.parseInt(activeUser.userid);
    
    // parse labels
    String[] labels = sScreenLabels.split("\\$");
    String sLabel;
    String[] labelParts;

    for(int i=0; i<labels.length; i++){
    	sLabel = (String)labels[i];    	
    	labelParts = sLabel.split("£");
    	
    	labelParts[0] = labelParts[0].substring(0,labelParts[0].length()-1);
        screen.addLabel(labelParts[0],labelParts[1]); // language, value
    }
    	
    // store screen
    screen.store(sWebLanguage,session);	
    session.setAttribute("screen",screen);
%>

{
  "msg":"<%=HTMLEntities.htmlentities(getTranNoLink("web","dataSaved",sWebLanguage))%>"
}