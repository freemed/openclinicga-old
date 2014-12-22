<%@page import="java.util.StringTokenizer,
                java.io.File"%>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>

<script>
  function doBack(){
   window.location.href = "<c:url value='/main.do'/>?Page=userprofile/index.jsp";
  } 
</script>

<%!
    //--- GET SUPPORTED THEMES --------------------------------------------------------------------
    private Vector getSupportedThemes() throws Exception {
	    Vector themes = new Vector();
	    
	    String sThemeDir = sAPPFULLDIR+"/"+MedwanQuery.getInstance().getConfigString("themeDir","/_img/themes");
	    File themeDir = new File(sThemeDir); 
	    if(themeDir.exists() && themeDir.isDirectory()){
	        File[] dirs = themeDir.listFiles();
	        File dir;
	        for(int i=0; i<dirs.length; i++){
	        	dir = (File)dirs[i]; 
	        	if(dir.isDirectory() && !dir.isHidden()){
	        		if(dir.listFiles().length > 0){
	        		    themes.add(dir.getName());
	        		}
	        	}
	        }
	        
	    }
	    else{
	    	Debug.println("WARNING : Configured 'themeDir' '"+sThemeDir+"' does not exist as a directory.");
	    	throw new Exception("WARNING : Configured 'themeDir' '"+sThemeDir+"' does not exist as a directory.");
	    }
	    
	    return themes;
    }
%>

<%
    String sAction = checkString(request.getParameter("Action"));
    sUserTheme = checkString((String)session.getAttribute("UserTheme"));

    /// DEBUG /////////////////////////////////////////////////////////////////////////////////////
    if(Debug.enabled){
    	Debug.println("\n********************* userprofile/changeTheme.jsp *********************");
    	Debug.println("sAction    : "+sAction);
    	Debug.println("sUserTheme : "+sUserTheme+"\n");
    }    
    ///////////////////////////////////////////////////////////////////////////////////////////////

    //--- DISPLAY FORM ----------------------------------------------------------------------------
    if(sAction.length()==0){
        %>
            <form name="transactionForm" method="post">
                <input type="hidden" name="Action">
                
                <%=writeTableHeader("web.userProfile","changeTheme",sWebLanguage," doBack();")%>
                <table width="100%" cellspacing="1" cellpadding="0" class="list">
                    <%-- theme --%>
                    <tr>
                        <td class="admin" width="<%=sTDAdminWidth%>"><%=getTran("web","theme",sWebLanguage)%>&nbsp;*&nbsp;</td>
                        <td class="admin2">
                            <select name="UserTheme" class="text">
                                <option value=""><%=getTranNoLink("web","choose",sWebLanguage)%></option>
                                <%
                                    // supported themes
                                    Vector supportedThemes = getSupportedThemes();

                                    String sTmpTheme;
                                    for(int i=0; i<supportedThemes.size(); i++){
                                    	sTmpTheme = (String)supportedThemes.get(i);

                                        %><option value="<%=sTmpTheme%>" <%=(sUserTheme.equals(sTmpTheme)?"selected":"")%>><%=ScreenHelper.uppercaseFirstLetter(getTranNoLink("web.themes",sTmpTheme,sWebLanguage))%></option><%
                                    }
                                %>
                            </select>
                        </td>
                    </tr>
                    
                    <%-- BUTTONS --%>
                    <%=ScreenHelper.setFormButtonsStart()%>
                        <input type="button" name="saveButton" class="button" value="<%=getTranNoLink("web","save",sWebLanguage)%>" onClick="doSubmit();">
                        <input type="button" name="backButton" class="button" value="<%=getTranNoLink("web","back",sWebLanguage)%>" onClick="doBack();">
                    <%=ScreenHelper.setFormButtonsStop()%>
                </table>
            </form>
        <%
    }
    //--- SAVE LANGUAGE AND RETURN TO INDEX -------------------------------------------------------
    else if(sAction.equals("save")){
        sUserTheme = checkString(request.getParameter("UserTheme"));
        
        // put chosen theme in session
        session.setAttribute("UserTheme",sUserTheme);

        // put chosen theme in activeUser
        Parameter parameter = new Parameter("UserTheme",sUserTheme);
        activeUser.removeParameter("UserTheme");
        activeUser.updateParameter(parameter);
        activeUser.parameters.add(parameter);
        
        session.setAttribute("activeUser",activeUser);
		
        // return to userprofile index
        out.print("<script>doBack();</script>");
    }
%>
<script>
  function doSubmit(){
	if(transactionForm.UserTheme.selectedIndex > 0){
	  transactionForm.saveButton.disabled = true;
      transactionForm.backButton.disabled = true;
      
      transactionForm.Action.value = "save";
      transactionForm.submit();
	}
	else{
	  transactionForm.UserTheme.focus();
	            window.showModalDialog?alertDialog("web.manage","dataMissing"):alertDialogDirectText('<%=getTran("web.manage","dataMissing",sWebLanguage)%>');
	}
  }
</script>