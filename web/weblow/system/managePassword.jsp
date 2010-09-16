<%@page import="be.mxs.common.util.db.MedwanQuery"%>
<%@include file="/includes/validateUser.jsp"%>
<%@page errorPage="/includes/error.jsp"%>

<%=checkPermission("system.management","",activeUser)%>

<%
    String sAction = checkString(request.getParameter("Action"));

    //--- SAVE ------------------------------------------------------------------------------------
    if(sAction.equals("Save")){
        // get data from form
        String sEditAvailability      = checkString(request.getParameter("EditAvailability"));
        String sEditNoticeTime        = checkString(request.getParameter("EditNoticeTime"));
        String sEditMinimumCharacters = checkString(request.getParameter("EditMinimumCharacters"));
        String sEditObligedLetters    = checkString(request.getParameter("EditObligedLetters"));
        String sEditObligedUppercase  = checkString(request.getParameter("EditObligedUppercase"));
        String sEditObligedLowerCase  = checkString(request.getParameter("EditObligedLowerCase"));
        String sEditObligedNumbers    = checkString(request.getParameter("EditObligedNumbers"));

        // set data in DB
        MedwanQuery.getInstance().setConfigString("PasswordAvailability",sEditAvailability);
        MedwanQuery.getInstance().setConfigString("PasswordNoticeTime",sEditNoticeTime);
        MedwanQuery.getInstance().setConfigString("PasswordMinimumCharacters",sEditMinimumCharacters);
        MedwanQuery.getInstance().setConfigString("PasswordObligedLetters",sEditObligedLetters);
        MedwanQuery.getInstance().setConfigString("PasswordObligedUppercase",sEditObligedUppercase);
        MedwanQuery.getInstance().setConfigString("PasswordObligedLowerCase",sEditObligedLowerCase);
        MedwanQuery.getInstance().setConfigString("PasswordObligedNumbers",sEditObligedNumbers);
    }

    MedwanQuery.reload();
%>

<form name="transactionForm" method="post">
    <input type="hidden" name="Action">
    <%=writeTableHeader("Web.manage","ManagePassword",sWebLanguage," doBack();")%>
    <table width="100%" cellspacing="1" cellpadding="0" class="list">
        <%-- Availability --%>
        <tr>
            <td class="admin" width="<%=sTDAdminWidth%>"><%=getTran("Web.Manage.Password","Availability",sWebLanguage)%></td>
            <td class="admin2">
                <input type="text" class="text" size="5" maxLength="4" name="EditAvailability" value="<%=MedwanQuery.getInstance().getConfigString("PasswordAvailability")%>" onblur="isNumber(this)"> <%=getTran("Web","days",sWebLanguage)%>
            </td>
        </tr>
        <%-- NoticeTime --%>
        <tr>
            <td class="admin" width="<%=sTDAdminWidth%>"><%=getTran("Web.Manage.Password","NoticeTime",sWebLanguage)%></td>
            <td class="admin2">
                <input type="text" class="text" size="5" maxLength="4" name="EditNoticeTime" value="<%=MedwanQuery.getInstance().getConfigString("PasswordNoticeTime")%>" onblur="isNumber(this);isLessThanAvailability(this)"> <%=getTran("Web","days",sWebLanguage)%>
            </td>
        </tr>
        <%-- MinimumCharacters --%>
        <tr>
            <td class="admin"><%=getTran("Web.Manage.Password","MinimumCharacters",sWebLanguage)%></td>
            <td class="admin2">
                <input type="text" class="text" size="5" maxLength="4" name="EditMinimumCharacters" value="<%=MedwanQuery.getInstance().getConfigString("PasswordMinimumCharacters")%>" onblur="isNumber(this)">
            </td>
        </tr>
        <%-- ObligedLetters --%>
        <tr>
            <td class="admin"><%=getTran("Web.Manage.Password","ObligedLetters",sWebLanguage)%></td>
            <td class="admin2">
                <input type="checkbox" name="EditObligedLetters"<%=(MedwanQuery.getInstance().getConfigString("PasswordObligedLetters").equals("on")?" checked":"")%>>
            </td>
        </tr>
        <%-- ObligedUppercase --%>
        <tr>
            <td class="admin"><%=getTran("Web.Manage.Password","ObligedUppercase",sWebLanguage)%></td>
            <td class="admin2">
                <input type="checkbox" name="EditObligedUppercase"<%=(MedwanQuery.getInstance().getConfigString("PasswordObligedUppercase").equals("on")?" checked":"")%>>
            </td>
        </tr>
        <%-- ObligedLowerCase --%>
        <tr>
            <td class="admin"><%=getTran("Web.Manage.Password","ObligedLowerCase",sWebLanguage)%></td>
            <td class="admin2">
                <input type="checkbox" name="EditObligedLowerCase"<%=(MedwanQuery.getInstance().getConfigString("PasswordObligedLowerCase").equals("on")?" checked":"")%>>
            </td>
        </tr>
        <%-- ObligedNumbers --%>
        <tr>
            <td class="admin"><%=getTran("Web.Manage.Password","ObligedNumbers",sWebLanguage)%></td>
            <td class="admin2">
                <input type="checkbox" name="EditObligedNumbers"<%=(MedwanQuery.getInstance().getConfigString("PasswordObligedNumbers").equals("on")?" checked":"")%>>
            </td>
        </tr>
        <%-- BUTTONS --%>
        <%=ScreenHelper.setFormButtonsStart()%>
            <input class="button" type="button" name="saveButton" value="<%=getTran("Web","Save",sWebLanguage)%>" onclick="doSave();">
            <input class="button" type="button" name="backbutton" value="<%=getTran("Web","Back",sWebLanguage)%>" onclick="doBack();">
        <%=ScreenHelper.setFormButtonsStop()%>
    </table>
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
</form>