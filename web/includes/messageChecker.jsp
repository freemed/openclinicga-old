<%@page import="be.mxs.common.util.db.MedwanQuery,
                be.mxs.common.util.system.ScreenHelper"%>                            
<%=sJSPROTOTYPE%>   
   
<%    
    int snoozeTimeInMillis = MedwanQuery.getInstance().getConfigInt("messageCheckerSnoozeTimeInMinutes",1)*60*1000,
        checkTimeInMillis  = MedwanQuery.getInstance().getConfigInt("messageCheckerTimeout",10*1000);

	/// DEBUG /////////////////////////////////////////////////////////////////
	if(Debug.enabled){
	    Debug.println("\n**************** messageChecker.jsp ****************");
	    Debug.println("snoozeTimeInMillis : "+snoozeTimeInMillis);
	    Debug.println("checkTimeInMillis  : "+checkTimeInMillis+"\n");
	}
	///////////////////////////////////////////////////////////////////////////
%>   
                   
<script>  
  var snoozeTimeInMillis = "<%=snoozeTimeInMillis%>",
      checkTimeInMillis = "<%=checkTimeInMillis%>";
  var interval;      
      
  <%
      Long snoozeDueTime = 0L;
  
      if(session.getAttribute("snoozeDueTime")!=null){
    	  // message displayed before, only check for message when snooze due time is passed
    	  snoozeDueTime = Long.parseLong((String)session.getAttribute("snoozeDueTime"));
    	  //Debug.println(" snoozeDueTime : "+snoozeDueTime);

    	  if(snoozeDueTime==0){
    		  // stop checking for messages when snoozeDueTime is 0    		  
    	  }
    	  else{    		  
			  long remainingMillisTillSnoozeDueTime = (new java.util.Date(snoozeDueTime).getTime()-new java.util.Date().getTime());
	     	  //Debug.println(" --> remainingMillisTillSnoozeDueTime : "+remainingMillisTillSnoozeDueTime);
	    	  
	    	  if(remainingMillisTillSnoozeDueTime < 0){
	    		  %>checkForMessage();<%
	    	  }
	    	  else{
	      	      %>interval = window.setInterval("checkForMessage()",<%=remainingMillisTillSnoozeDueTime%>);<% 
	    	  }
    	  }
      }
      else{
    	  // message NOT displayed before
          %>checkForMessage();<%    
      }
  %>
  
  <%-- CHECK FOR MESSAGE --%>
  function checkForMessage(){
    var url = "<c:url value='/includes/ajax/checkForMessage.jsp'/>?ts="+new Date().getTime();
    var params = ""; // no parameters      
    
    new Ajax.Request(url,{
      parameters: params,
      onComplete: function(resp){
        var data = eval("("+resp.responseText+")");
        
    	if(data.labelType.length > 0){	
          if(yesnoDialogDirectText(data.message)==1){
        	<%-- snooze --%>
        	window.clearInterval(interval);
      	    interval = window.setInterval("checkForMessage()",snoozeTimeInMillis);
      	    setSnoozeInSession();
          }
          else{
        	<%-- no snooze --%>
      	    window.clearInterval(interval);
      	    clearSnoozeInSession();
          }
    	}
    	else{    	  
    	  <%-- continue --%>
          window.clearInterval(interval);
  	      interval = window.setInterval("checkForMessage()",checkTimeInMillis);  	      
    	}
      }
    });
  }
    
  <%-- SET SNOOZE IN SESSION --%>
  function setSnoozeInSession(){
    var url = "<c:url value='/includes/ajax/setSnoozeInSession.jsp'/>?ts="+new Date().getTime();
    var params = "Action=set";      
    
    new Ajax.Request(url,{
      parameters: params
    });
  }
  
  <%-- CLEAR SNOOZE IN SESSION --%>
  function clearSnoozeInSession(){
    var url = "<c:url value='/includes/ajax/setSnoozeInSession.jsp'/>?ts="+new Date().getTime();
    var params = "Action=clear";      
    
    new Ajax.Request(url,{
      parameters: params
    });
  }
</script>