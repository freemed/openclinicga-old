<%@page import="be.mxs.common.util.system.HTMLEntities"%>
<%@include file="/includes/validateUser.jsp"%>

<%   
    String sSnoozeTimeInMinutes = MedwanQuery.getInstance().getConfigString("messageCheckerSnoozeTimeInMinutes","5");

    String sMessage = ScreenHelper.getTranExists("systemMessages","mainMessage",sWebLanguage);

    /// DEBUG /////////////////////////////////////////////////////////////////////////////////////
    if(Debug.enabled && 1==2){
        Debug.println("\n****************** includes/ajax/checkForMessage.jsp ******************");
        
        if(sMessage.length()==0){
            Debug.println("--> NO MESSAGE SET ('systemMessages','mainMessage')\n");
        }
        else{
            Debug.println("--> sMessage : "+sMessage+"\n");
        }
    }
    ///////////////////////////////////////////////////////////////////////////////////////////////
    
    // add snooze-question to message, if any
    if(sMessage.length() > 0){
    	sMessage = "<font color='red'>"+sMessage+"</font>"; // actual message in red
    	
    	// fixed message below
    	sMessage+= "<br><br>"+getTranNoLink("web.manage","doYouWantToSnoozeThisAlert",sWebLanguage).replaceAll("#minutes#",sSnoozeTimeInMinutes);
    }
%>

{
  "message":"<%=HTMLEntities.htmlentities(sMessage)%>",  
  "labelType":"<%=(sMessage.length() > 0?"systemMessages":"")%>",
  "labelId":"<%=(sMessage.length() > 0?"mainMessage":"")%>"
}