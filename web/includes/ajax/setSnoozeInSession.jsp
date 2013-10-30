<%@include file="/includes/validateUser.jsp"%>

<%       
    String sAction = checkString(request.getParameter("Action"));

    /// DEBUG /////////////////////////////////////////////////////////////////
    if(Debug.enabled){
        Debug.println("\n************** setSnoozeInSession.jsp **************");
        Debug.println("sAction = "+sAction+"\n");
    }
    ///////////////////////////////////////////////////////////////////////////

    
    //--- SET -------------------------------------------------------------------------------------
    if(sAction.equals("set")){
        int snoozeTimeInMillis = MedwanQuery.getInstance().getConfigInt("messageCheckerSnoozeTimeInMinutes",5)*60*1000;
	    session.setAttribute("snoozeDueTime",Long.toString((new java.util.Date().getTime()+snoozeTimeInMillis)));
    }
    //--- CLEAR -----------------------------------------------------------------------------------
    else if(sAction.equals("clear")){
	    session.setAttribute("snoozeDueTime","0");
    }
%>