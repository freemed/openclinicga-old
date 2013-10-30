<%@page import="be.mxs.common.util.db.MedwanQuery,
                be.mxs.common.util.system.ScreenHelper,
                be.mxs.common.util.system.Debug"%>
<%@include file="commonFunctions.jsp"%>

<%    
    int snoozeTimeInMillis = MedwanQuery.getInstance().getConfigInt("messageCheckerSnoozeTimeInMinutes",5)*60*1000,
        checkTimeInMillis  = MedwanQuery.getInstance().getConfigInt("messageCheckerTimeout",10*1000); // 10 seconds

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
	     	  Debug.println(" --> remainingMillisTillSnoozeDueTime : "+remainingMillisTillSnoozeDueTime);
	    	  
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
          yesnoModalbox(data.message);
    	}
    	else{    	  
    	  <%-- continue --%>
          window.clearInterval(interval);
  	      interval = window.setInterval("checkForMessage()",checkTimeInMillis);  	      
    	}
      }
    });
  }
    
  <%-- DO SNOOZE (yes-button) --%>
  function doSnooze(){
    window.clearInterval(interval);
    interval = window.setInterval("checkForMessage()",snoozeTimeInMillis);
    setSnoozeInSession();
  }
  
  <%-- DO NOT SNOOZE (no-button) --%>
  function doNotSnooze(){
	window.clearInterval(interval);
	clearSnoozeInSession();
  }
    
  <%-- SET SNOOZE IN SESSION (after doSnooze) --%>
  function setSnoozeInSession(){
    var url = "<c:url value='/includes/ajax/setSnoozeInSession.jsp'/>?ts="+new Date().getTime();
    var params = "Action=set";      
    
    new Ajax.Request(url,{
      parameters: params
    });
  }
  
  <%-- CLEAR SNOOZE IN SESSION (after doNotSnooze) --%>
  function clearSnoozeInSession(){
    var url = "<c:url value='/includes/ajax/setSnoozeInSession.jsp'/>?ts="+new Date().getTime();
    var params = "Action=clear";      
    
    new Ajax.Request(url,{
      parameters: params
    });
  }
  
  <%-- OBSERVERS for yesNoModalbox --%>
  var yesObserver = doSnooze.bindAsEventListener(Modalbox);
  var noObserver = doNotSnooze.bindAsEventListener(Modalbox);
  
  function setObservers(){
	$("yesButton").observe("click",yesObserver);
	$("noButton").observe("click",noObserver);
  }
  
  function removeObservers(){
	$("yesButton").stopObserving("click",yesObserver);
	$("noButton").stopObserving("click",noObserver);
  }
  
  <%-- YESNO MODALBOX (2 buttons) --%>
  function yesnoModalbox(msg){
    var html = "<div style='border:1px solid #bbccff;padding:1px;'>"+ // class="warning"
                "<p>"+msg+"</p>"+
                "<p style='text-align:center'>"+
                 "<input type='button' class='button' id='yesButton' style='padding-left:7px;padding-right:7px' value='<%=getTranNoLink("web","yes",sWebLanguage)%>' onclick='Modalbox.hide();'/>"+
                 "&nbsp;&nbsp;&nbsp;"+
                 "<input type='button' class='button' id='noButton' style='padding-left:7px;padding-right:7px' value='<%=getTranNoLink("web","no",sWebLanguage)%>' onclick='Modalbox.hide();'/>"+
                "</p>"+
               "</div>";
    Modalbox.show(html,{title:'<%=getTranNoLink("web","message",sWebLanguage)%>',width:300,afterLoad:setObservers,onHide:removeObservers});
  }
</script>