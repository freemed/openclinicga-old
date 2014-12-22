<%@include file="/includes/validateUser.jsp"%>
<%@page errorPage="/includes/error.jsp"%>

<%=checkPermission("system.management","all",activeUser)%>

<%
    String sAction = checkString(request.getParameter("Action"));
    
	String sSupportedLanguages = MedwanQuery.getInstance().getConfigString("supportedLanguages","fr,en,nl");	
		
	/// DEBUG /////////////////////////////////////////////////////////////////
	if(Debug.enabled){
	    Debug.println("\n************* manageSystemMessage.jsp *************");
	    Debug.println("sAction : "+sAction);
	    Debug.println("--> sSupportedLanguages : "+sSupportedLanguages+"\n");
	}
	///////////////////////////////////////////////////////////////////////////
	
	Hashtable messagesHash = new Hashtable();
	String sMsg = "";

	// load the saved labels
    String[] languages = sSupportedLanguages.split(",");
	Arrays.sort(languages);
  		
    for(int l=0; l<languages.length; l++){
    	String sLabel = ScreenHelper.getTranExists("systemMessages","mainMessage",languages[l]);    	
        messagesHash.put(languages[l].toUpperCase(),sLabel);
	}
    
	
	//--- SAVE MESSAGE ----------------------------------------------------------------------------
	if(sAction.equals("save")){
		// fetch all messages-parameters from request
		String sMessage, sParamName, sParamValue;
		Enumeration messageParams = request.getParameterNames();
		
		while(messageParams.hasMoreElements()){
			sParamName = (String)messageParams.nextElement();
			
			if(sParamName.startsWith("Message")){
				sParamValue = checkString(request.getParameter(sParamName));
				sParamName = sParamName.substring("Message".length());
			    messagesHash.put(sParamName,sParamValue);
			}
		}
		
		// sort
		Vector messageKeys = new Vector(messagesHash.keySet());
		Collections.sort(messageKeys);
		
		String sLanguage;
		boolean deleted = false;
		for(int k=0; k<messageKeys.size(); k++){
			sLanguage = ((String)messageKeys.get(k));
			
			if(!deleted && checkString((String)messagesHash.get(sLanguage)).length() > 0){
				Label label = new Label();
				label.type = "systemMessages";
				label.id = "mainMessage";
				label.language = sLanguage;
	            label.showLink = "1";	
	            label.updateUserId = activeUser.userid;
				label.value = (String)messagesHash.get(sLanguage);

                label.saveToDB();	            
			}
			else{
				// delete the label (since storing it empty is not allowed)
				Label.delete("systemMessages","mainMessage",sLanguage);
				deleted = true;
			}
		}		

	    reloadSingleton(session);
	    
		// compose user-message
		if(deleted){
		    sMsg = "<font color='green'>"+getTranNoLink("web","dataIsDeleted",sWebLanguage)+"</font>";
		}
		else{
		    sMsg = "<font color='green'>"+getTranNoLink("web","dataIsSaved",sWebLanguage)+"</font>";
		}
	}
%>

<form name="msgForm" method="post">
    <%=writeTableHeader("web.manage","manageSystemMessage",sWebLanguage,"doBack();")%>
    <input type="hidden" name="Action" value="">
                
    <table border="0" width="100%" align="center" cellspacing="1" class="list">
        <%-- a MESSAGE for each supported language --%>
        <%        		
	    	for(int l=0; l<languages.length; l++){
                %>
			        <tr>
			            <td class="admin" width="<%=sTDAdminWidth%>"><%=getTran("web","message",sWebLanguage)%>&nbsp;<%=languages[l].toUpperCase()%>&nbsp;</td>
			            <td class="admin2">
			                <textarea class="text" name="Message<%=languages[l].toUpperCase()%>" cols="80" rows="4" onKeyup="limitChars(this,255);resizeTextarea(this,4);"><%=checkString((String)messagesHash.get(languages[l].toUpperCase()))%></textarea>
			            </td>
			        </tr>
			    <%
		    }
		%>
            
        <%-- BUTTONS --%>
        <tr>     
            <td class="admin"/>
            <td class="admin2" colspan="2">
                <input class="button" type="button" name="saveButton" value="<%=getTranNoLink("web","save",sWebLanguage)%>" onclick="doSave();">
                <input class="button" type="button" name="clearButton" value="<%=getTranNoLink("web.manage","clearallmessages",sWebLanguage)%>" onclick="clearAll();">&nbsp;&nbsp;
                <input class="button" type="button" name="backButton" value="<%=getTranNoLink("web","back",sWebLanguage)%>" onclick="doBack();">&nbsp;
            </td>
        </tr>
    </table>
    
    <%
        //-- MESSAGE --
        if(sMsg.length() > 0){
            %><%=sMsg%><br><%    	
        }
    %>
</form>

<script>
  msgForm.elements[1].focus(); <%-- first textarea --%>

  <%-- CLEAR ALL textareas --%>
  function clearAll(){
      if(yesnoDeleteDialog()){
	  <%
	      for(int l=0; l<languages.length; l++){
	          %>msgForm.Message<%=languages[l].toUpperCase()%>.value = "";<%
	      }
	  %>

      msgForm.saveButton.disabled = true;
	  msgForm.clearButton.disabled = true;
	  msgForm.backButton.disabled = true;
	      
	  msgForm.Action.value = "save";
	  msgForm.submit();
	}
  }  
  
  <%-- DO SAVE --%>
  function doSave(){
	var okToSubmit = true;
	var totalMessages = <%=languages.length%>;
	var emptyMessages = 0;

    <%-- check each message for content --> all empty or all not-empty --%>
	if(okToSubmit){
      <%
	      for(int l=0; l<languages.length; l++){
              %>
	            if(msgForm.Message<%=languages[l].toUpperCase()%>.value.length==0){
	      	      emptyMessages++;
	            }
	          <%
	      }
      %>

      if(emptyMessages > 0 && emptyMessages!=totalMessages){
        alertDialog("web.manage","allMessagesShouldBeSpecified");
        okToSubmit = false;
      }
	}
	
	if(okToSubmit){
      msgForm.saveButton.disabled = true;
      msgForm.clearButton.disabled = true;
      msgForm.backButton.disabled = true;
      
	  msgForm.Action.value = "save";
	  msgForm.submit();
	}
  }

  <%-- DO BACK --%>
  function doBack(){
    window.location.href = "main.do?Page=system/menu.jsp";
  }
</script>