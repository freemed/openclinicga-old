<%@page import="be.mxs.common.util.db.MedwanQuery"%>
<%@include file="/includes/validateUser.jsp"%>
<%@page errorPage="/includes/error.jsp"%>
<%=checkPermission("system.management","",activeUser)%>

<%
    String sAction = checkString(request.getParameter("Action"));

	// get data from form
	String sEditAvailability         = checkString(request.getParameter("EditAvailability")),
	       sEditNoticeTime           = checkString(request.getParameter("EditNoticeTime")),
	       sEditMinimumCharacters    = checkString(request.getParameter("EditMinimumCharacters")),
	       sEditNotReusablePasswords = checkString(request.getParameter("EditNotReusablePasswords"));
	
	String sEditObligedLetters       = checkString(request.getParameter("EditObligedLetters")),
	       sEditObligedUppercase     = checkString(request.getParameter("EditObligedUppercase")),
	       sEditObligedLowerCase     = checkString(request.getParameter("EditObligedLowerCase")),
	       sEditObligedNumbers       = checkString(request.getParameter("EditObligedNumbers")),
	       sEditObligedAlfanumerics  = checkString(request.getParameter("EditObligedAlfanumerics"));

    /// DEBUG /////////////////////////////////////////////////////////////////////////////////////
    if(Debug.enabled){
    	Debug.println("\n*********************** system/managePassword.jsp *********************");
    	Debug.println("sAction                   : "+sAction);
    	Debug.println("sEditAvailability         : "+sEditAvailability);
    	Debug.println("sEditNoticeTime           : "+sEditNoticeTime);
    	Debug.println("sEditMinimumCharacters    : "+sEditMinimumCharacters);
    	Debug.println("sEditNotReusablePasswords : "+sEditNotReusablePasswords);
    	
    	Debug.println("sEditObligedLetters       : "+sEditObligedLetters);
    	Debug.println("sEditObligedUppercase     : "+sEditObligedUppercase);
    	Debug.println("sEditObligedLowerCase     : "+sEditObligedLowerCase);
    	Debug.println("sEditObligedLowerCase     : "+sEditObligedLowerCase);
    	Debug.println("sEditObligedAlfanumerics  : "+sEditObligedAlfanumerics+"\n");
    }
    ///////////////////////////////////////////////////////////////////////////////////////////////

    //--- SAVE ------------------------------------------------------------------------------------
    if(sAction.equals("Save")){
        MedwanQuery.getInstance().setConfigString("PasswordAvailability",sEditAvailability);
        MedwanQuery.getInstance().setConfigString("PasswordNoticeTime",sEditNoticeTime);
        MedwanQuery.getInstance().setConfigString("PasswordMinimumCharacters",sEditMinimumCharacters);
        MedwanQuery.getInstance().setConfigString("PasswordNotReusablePasswords",sEditNotReusablePasswords);
        
        MedwanQuery.getInstance().setConfigString("PasswordObligedLetters",sEditObligedLetters);
        MedwanQuery.getInstance().setConfigString("PasswordObligedUppercase",sEditObligedUppercase);
        MedwanQuery.getInstance().setConfigString("PasswordObligedLowerCase",sEditObligedLowerCase);
        MedwanQuery.getInstance().setConfigString("PasswordObligedNumbers",sEditObligedNumbers);
        MedwanQuery.getInstance().setConfigString("PasswordObligedAlfanumerics",sEditObligedAlfanumerics);
    }

    MedwanQuery.reload();
%>

<form name="transactionForm" method="post">
    <input type="hidden" name="Action">
    
    <%=writeTableHeader("Web.manage","ManagePassword",sWebLanguage," doBack();")%>
    
    <table width="100%" cellspacing="1" cellpadding="0" class="list">
        <%-- Availability --%>
        <tr>
            <td class="admin" width="<%=sTDAdminWidth%>"><%=getTran("Web.Manage.Password","availability",sWebLanguage)%></td>
            <td class="admin2">
                <input type="text" class="text" size="5" maxLength="4" name="EditAvailability" value="<%=MedwanQuery.getInstance().getConfigString("PasswordAvailability")%>" onblur="isNumber(this)"> <%=getTran("Web","days",sWebLanguage)%>
            </td>
        </tr>
        <%-- NoticeTime --%>
        <tr>
            <td class="admin" width="<%=sTDAdminWidth%>"><%=getTran("Web.Manage.Password","noticeTime",sWebLanguage)%></td>
            <td class="admin2">
                <input type="text" class="text" size="5" maxLength="4" name="EditNoticeTime" value="<%=MedwanQuery.getInstance().getConfigString("PasswordNoticeTime")%>" onblur="isNumber(this);isLessThanAvailability(this)"> <%=getTran("Web","days",sWebLanguage)%>
            </td>
        </tr>
        <%-- MinimumCharacters --%>
        <tr>
            <td class="admin"><%=getTran("Web.Manage.Password","minimumCharacters",sWebLanguage)%></td>
            <td class="admin2">
                <input type="text" class="text" size="5" maxLength="4" name="EditMinimumCharacters" value="<%=MedwanQuery.getInstance().getConfigString("PasswordMinimumCharacters")%>" onblur="isNumber(this)">
            </td>
        </tr>
        <%-- NotReusablePasswords --%>
        <tr>
            <td class="admin"><%=getTran("Web.Manage.Password","notReusablePasswords",sWebLanguage)%></td>
            <td class="admin2">
                <input type="text" class="text" size="5" maxLength="4" name="EditNotReusablePasswords" value="<%=MedwanQuery.getInstance().getConfigString("PasswordNotReusablePasswords")%>" onblur="isNumber(this)">
            </td>
        </tr>
        
        <%-- ObligedLetters --%>
        <tr>
            <td class="admin"><%=getTran("Web.Manage.Password","obligedLetters",sWebLanguage)%></td>
            <td class="admin2">
                <input type="checkbox" name="EditObligedLetters"<%=(MedwanQuery.getInstance().getConfigString("PasswordObligedLetters").equals("on")?" checked":"")%>>
            </td>
        </tr>
        <%-- ObligedUppercase --%>
        <tr>
            <td class="admin"><%=getTran("Web.Manage.Password","obligedUppercase",sWebLanguage)%></td>
            <td class="admin2">
                <input type="checkbox" name="EditObligedUppercase"<%=(MedwanQuery.getInstance().getConfigString("PasswordObligedUppercase").equals("on")?" checked":"")%>>
            </td>
        </tr>
        <%-- ObligedLowerCase --%>
        <tr>
            <td class="admin"><%=getTran("Web.Manage.Password","obligedLowerCase",sWebLanguage)%></td>
            <td class="admin2">
                <input type="checkbox" name="EditObligedLowerCase"<%=(MedwanQuery.getInstance().getConfigString("PasswordObligedLowerCase").equals("on")?" checked":"")%>>
            </td>
        </tr>
        <%-- ObligedNumbers --%>
        <tr>
            <td class="admin"><%=getTran("Web.Manage.Password","obligedNumbers",sWebLanguage)%></td>
            <td class="admin2">
                <input type="checkbox" name="EditObligedNumbers"<%=(MedwanQuery.getInstance().getConfigString("PasswordObligedNumbers").equals("on")?" checked":"")%>>
            </td>
        </tr>
        <%-- ObligedAlfanumerics --%>
        <tr>
            <td class="admin"><%=getTran("Web.Manage.Password","obligedAlfanumerics",sWebLanguage)%></td>
            <td class="admin2">
                <input type="checkbox" name="EditObligedAlfanumerics"<%=(MedwanQuery.getInstance().getConfigString("PasswordObligedAlfanumerics").equals("on")?" checked":"")%>>
            </td>
        </tr>
        
        <%-- BUTTONS --%>
        <%=ScreenHelper.setFormButtonsStart()%>
            <input class="button" type="button" name="saveButton" value="<%=getTran("Web","Save",sWebLanguage)%>" onclick="doSave();">
            <input class="button" type="button" name="backbutton" value="<%=getTran("Web","Back",sWebLanguage)%>" onclick="doBack();">
        <%=ScreenHelper.setFormButtonsStop()%>
    </table>
</form>

<script>
  transactionForm.EditAvailability.focus();

  function doSave(){
    transactionForm.saveButton.disabled = true;
    transactionForm.backbutton.disabled = true;
    transactionForm.Action.value = "Save";
    transactionForm.submit();
  }

  function doBack(){
    window.location.href = "<c:url value='/main.do'/>?Page=system/menu.jsp";
  }

  <%-- IS LESS THAN AVAILABILITY --%>
  function isLessThanAvailability(obj){
    if(obj.value*1 > transactionForm.EditAvailability.value*1){
      var popupUrl = "<c:url value='/popup.jsp'/>?Page=_common/search/okPopup.jsp&ts=<%=getTs()%>&labelType=web.Manage.Password&labelID=NoticeNotLargerThanAvailability";
      var modalities = "dialogWidth:266px;dialogHeight:143px;center:yes;scrollbars:no;resizable:no;status:no;location:no;";
      (window.showModalDialog)?window.showModalDialog(popupUrl,"",modalities):window.confirm("<%=getTranNoLink("web.Manage.Password","NoticeNotLargerThanAvailability",sWebLanguage)%>");

      obj.value = transactionForm.EditAvailability.value;
      obj.focus();
    }
  }
</script>