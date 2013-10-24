<%@page import="be.mxs.common.util.system.HTMLEntities,
                java.util.*"%>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>

<%
    String sUserId     = checkString(request.getParameter("UserId")),
           sShortcutId = checkString(request.getParameter("ShortcutId"));

    /// DEBUG /////////////////////////////////////////////////////////////////
    if(Debug.enabled){
        Debug.println("\n********* userprofile/ajax/getShortcut.jsp ********");
        Debug.println("sUserId     : "+sUserId);
        Debug.println("sShortcutId : "+sShortcutId+"\n");
    }
    ///////////////////////////////////////////////////////////////////////////
   
    Vector userParameters = activeUser.getUserParametersByType(activeUser.userid,"usershortcut$");

    String sLongLabelId, sShortcutType = "", sShortcutSubtype = "";
    String sIconName = "", sIconOnClick = "", sIconText = "", sLabelType = "", sShortcutTitle = "";
    UserParameter userParameter;
    boolean dataFound = false;

    Debug.println("\n***** userShortcuts (userid:"+activeUser.userid+") : "+userParameters.size()+" *****");
    for(int i=0; i<userParameters.size(); i++){
        userParameter = (UserParameter)userParameters.get(i);
        Debug.println("\nuserShortcut : "+userParameter.getParameter());
        
        sLongLabelId = userParameter.getParameter().substring("usershortcut$".length());
        if(sShortcutId.equalsIgnoreCase(sLongLabelId)){
        	// a - parse id of parameter
           	String[] iconIds = sLongLabelId.split("\\$");
        	sShortcutType = iconIds[0];
           	if(iconIds.length > 1){
        	  sShortcutSubtype = iconIds[1];
           	}
           	
           	if(Debug.enabled){
           		Debug.println("  sShortcutType    : "+sShortcutType);
           		Debug.println("  sShortcutSubtype : "+sShortcutSubtype);
           	}
           	
        	// b - parse value of parameter
           	String[] iconValues = userParameter.getValue().split("\\$");
            sIconName = iconValues[0];
            sIconOnClick = iconValues[1].replaceAll("\"","'"); // javascript-related
           	if(iconValues.length > 2){
                sIconText = iconValues[2];
           	}

           	if(Debug.enabled){
           		Debug.println("  sIconName    : "+sIconName);
           		Debug.println("  sIconOnClick : "+sIconOnClick);
           		Debug.println("  sIconText    : "+sIconText);
           	}
           	
           	dataFound = true;
           	break;
        }
    }
    
    // compose message
    String sMsg = "";
    if(dataFound){
    	sMsg = "dataFound";    
    }
    else{
    	sMsg = "<font color='red'>Error while fetching shortcut</font>";
    }
%>

{
  "msg":"<%=HTMLEntities.htmlentities(sMsg)%>",
  "shortcutType":"<%=HTMLEntities.htmlentities(sShortcutType)%>",
  "shortcutSubtype":"<%=HTMLEntities.htmlentities(sShortcutSubtype)%>",
  "iconName":"<%=sIconName%>",
  "iconOnClick":"<%=HTMLEntities.htmlentities(sIconOnClick)%>",
  "iconText":"<%=HTMLEntities.htmlentities(sIconText)%>"
}