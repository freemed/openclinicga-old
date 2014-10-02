<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>

<%
    String sAction = checkString(request.getParameter("Action")); 
    String sMsg = "";

    //--- SAVE ------------------------------------------------------------------------------------
    if(sAction.equals("save")){
    	String sDateType = "";
        String sDateFormat = checkString(request.getParameter("EditDateFormat"));
        if(sDateFormat.equals("dd/MM/yyyy")){
        	sDateType = "eu";
        }
        else if(sDateFormat.equals("MM/dd/yyyy")){
        	sDateType = "us";
        }        

        Config objConfig = Config.getConfig("dateFormat");
        objConfig.setOc_value(new StringBuffer(sDateFormat));
        objConfig.setUpdateuserid(Integer.parseInt(activeUser.userid));
        objConfig.setUpdatetime(getSQLTime());
        objConfig.setDeletetime(null);
        Config.saveConfig(objConfig); 

        objConfig = Config.getConfig("dateType");
        objConfig.setOc_value(new StringBuffer(sDateType));
        objConfig.setUpdateuserid(Integer.parseInt(activeUser.userid));
        objConfig.setUpdatetime(getSQLTime());
        objConfig.setDeletetime(null);        
        Config.saveConfig(objConfig); 
        
        MedwanQuery.getInstance().reloadConfigValues();
        ScreenHelper.reloadDateFormats();
        
        sMsg = "<font color='green'>"+getTran("web","dataSaved",sWebLanguage)+"</font>";
    }
%>

<form name="transactionForm" method="post">
    <input type="hidden" name="Action">
    
    <%=writeTableHeader("web.manage","manageDateFormat",sWebLanguage," doBack();")%>
    
    <table width="100%" cellspacing="1" cellpadding="0" class="list">
        <%-- date format --%>
        <tr>
            <td class="admin" width="<%=sTDAdminWidth%>"><%=getTran("Web","dateFormat",sWebLanguage)%></td>
            <td class="admin2">
                <select name="EditDateFormat" class="text">
                    <%
                        String sConfiguredDateFormat = MedwanQuery.getInstance().getConfigString("dateFormat","dd/MM/yyyy");
                        String supportedFormats = MedwanQuery.getInstance().getConfigString("supportedDateFormats","dd/MM/yyyy,MM/dd/yyyy");
                        
                        StringTokenizer tokenizer = new StringTokenizer(supportedFormats,",");
                        String tmpFormat;
                        while(tokenizer.hasMoreTokens()) {
                        	tmpFormat = tokenizer.nextToken();
                            %><option value="<%=tmpFormat%>" <%=(sConfiguredDateFormat.equals(tmpFormat)?"selected":"")%>><%=getTran("dateFormat",tmpFormat,sWebLanguage)%></option><%
                        }
                    %>
                </select>
            </td>
        </tr>
        
        <%-- BUTTONS --%>
        <%=ScreenHelper.setFormButtonsStart()%>
            <input type="button" name="saveButton" class="button" value="<%=getTranNoLink("Web","save",sWebLanguage)%>" onClick="doSubmit();">
            <input type="button" name="backButton" class="button" value="<%=getTranNoLink("Web","back",sWebLanguage)%>" onClick="doBack();">
        <%=ScreenHelper.setFormButtonsStop()%>
    </table>

	<%
	    if(sMsg.length() > 0){
	    	%><%=sMsg%><%
	    }
	%>
</form>

<script>
  function doSubmit(){
    transactionForm.saveButton.disabled = true;
    transactionForm.backButton.disabled = true;
    transactionForm.Action.value = "save";
    transactionForm.submit();
  }
  
  function doBack(){
    window.location.href = "<c:url value='/main.do'/>?Page=system/menu.jsp";
  }
</script>