<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>
<%

%>
<script>
  function doBack(){
    window.location.href = "<c:url value='/main.do'/>?Page=userprofile/index.jsp";
  }
</script>
<%
    String sAction = checkString(request.getParameter("Action"));

    //--- retrieve rules ---
    int minimumChars;
    try{ minimumChars = Integer.parseInt(MedwanQuery.getInstance().getConfigString("PasswordMinimumCharacters")); }
    catch(Exception e){ minimumChars = -1; }

    boolean lettersObliged   = MedwanQuery.getInstance().getConfigString("PasswordObligedLetters").equals("on");
    boolean uppercaseObliged = MedwanQuery.getInstance().getConfigString("PasswordObligedUppercase").equals("on");
    boolean lowercaseObliged = MedwanQuery.getInstance().getConfigString("PasswordObligedLowerCase").equals("on");
    boolean numbersObliged   = MedwanQuery.getInstance().getConfigString("PasswordObligedNumbers").equals("on");

    //--- DISPLAY FORM ----------------------------------------------------------------------------
    if(sAction.length() == 0){
        %>
            <form name='UserProfile' method='post'>
                <input type="hidden" name="Action">
                <%=writeTableHeader("Web.UserProfile","ChangePassword",sWebLanguage," doBack();")%>
                <table width='100%' cellspacing="1" cellpadding="0" class="list">
                    <%-- OldPassword --%>
                    <tr>
                        <td class="admin"><%=getTranNoLink("Web.UserProfile","PutOldPassword",sWebLanguage)%></td>
                        <td class="admin2"><input type='password' name='OldPassword' class="text" size="25" maxLength="20"></td>
                    </tr>
                    <%-- NewPassword 1 --%>
                    <tr>
                        <td class="admin"><%=getTranNoLink("Web.UserProfile","PutNewPassword",sWebLanguage)%></td>
                        <td class="admin2"><input type='password' name='NewPassword1' class="text" size="25" maxLength="20"></td>
                    </tr>
                    <%-- NewPassword 2 --%>
                    <tr>
                        <td class="admin" width="<%=sTDAdminWidth%>"><%=getTranNoLink("Web.UserProfile","PutNewPasswordAgain",sWebLanguage)%></td>
                        <td class="admin2"><input type='password' name='NewPassword2' class="text" size="25" maxLength="20"></td>
                    </tr>
                    <%-- BUTTONS --%>
                    <%=ScreenHelper.setFormButtonsStart()%>
                        <input type="button" class="button" name='saveButton' value='<%=getTranNoLink("Web","save",sWebLanguage)%>' onClick='doSave();'>
                        <input type="button" class="button" name='backButton' value='<%=getTranNoLink("Web","back",sWebLanguage)%>' onClick='doBack();'>
                    <%=ScreenHelper.setFormButtonsStop()%>
                </table>
                <script>
                  UserProfile.OldPassword.focus();

                  function doSave() {
                    if (UserProfile.OldPassword.value.length == 0) {
                      UserProfile.OldPassword.focus();
                    }
                    else if (UserProfile.NewPassword1.value.length == 0) {
                      UserProfile.NewPassword1.focus();
                    }
                    else if (UserProfile.NewPassword2.value.length == 0) {
                      UserProfile.NewPassword2.focus();
                    }
                    else if (UserProfile.NewPassword1.value.length > 250) {
                      var popupUrl = "<c:url value='/popup.jsp'/>?Page=_common/search/okPopup.jsp&ts=999999999&labelType=Web.Password&labelID=PasswordTooLong";
                      var modalities = "dialogWidth:266px;dialogHeight:163px;center:yes;scrollbars:no;resizable:no;status:no;location:no;";
                      (window.showModalDialog)?window.showModalDialog(popupUrl,"",modalities):window.confirm("<%=getTranNoLink("web.Password","PasswordTooLong",sWebLanguage)%>");

                      UserProfile.NewPassword1.focus();
                    }
                    else if (UserProfile.NewPassword2.value.length > 250) {
                      var popupUrl = "<c:url value='/popup.jsp'/>?Page=_common/search/okPopup.jsp&ts=999999999&labelType=Web.Password&labelID=PasswordTooLong";
                      var modalities = "dialogWidth:266px;dialogHeight:163px;center:yes;scrollbars:no;resizable:no;status:no;location:no;";
                      (window.showModalDialog)?window.showModalDialog(popupUrl,"",modalities):window.confirm("<%=getTranNoLink("web.Password","PasswordTooLong",sWebLanguage)%>");

                      UserProfile.NewPassword2.focus();
                    }
                    else {
                      UserProfile.saveButton.disabled = true;
                      UserProfile.backButton.disabled = true;
                      UserProfile.Action.value = "save";
                      UserProfile.submit();
                    }
                  }
                </script>
            </form>
        <%

        //--- DISPLAY APPLIED RULES ---------------------------------------------------------------
        out.print("<p style='font-size:12px;'>");

        if(minimumChars > -1){
            String msg = getTran("Web.UserProfile","PasswordMinimumCharactersObliged",sWebLanguage);
            msg = msg.replaceFirst("#minChars#",minimumChars+"");
            out.print("<img src='"+sCONTEXTPATH+"/_img/icon_info.gif'/>");
            out.print(msg+"<br>");
        }

        if(numbersObliged && lettersObliged){
            out.print("<img src='"+sCONTEXTPATH+"/_img/icon_info.gif'/>");
            out.print(getTran("Web.UserProfile","PasswordNumbersObliged",sWebLanguage)+"<br>");

            out.print("<img src='"+sCONTEXTPATH+"/_img/icon_info.gif'/>");
            out.print(getTran("Web.UserProfile","PasswordLettersObliged",sWebLanguage)+"<br>");
        }
        else{
            if(numbersObliged){
                out.print("<img src='"+sCONTEXTPATH+"/_img/icon_info.gif'/>");
                out.print(getTran("Web.UserProfile","PasswordNumbersObliged",sWebLanguage)+"<br>");
            }
            if(lettersObliged){
                out.print("<img src='"+sCONTEXTPATH+"/_img/icon_info.gif'/>");
                out.print(getTran("Web.UserProfile","PasswordLettersObliged",sWebLanguage)+"<br>");
            }
        }

        if(uppercaseObliged && lowercaseObliged){
            out.print("<img src='"+sCONTEXTPATH+"/_img/icon_info.gif'/>");
            out.print(getTran("Web.UserProfile","PasswordUppercaseObliged",sWebLanguage)+"<br>");

            out.print("<img src='"+sCONTEXTPATH+"/_img/icon_info.gif'/>");
            out.print(getTran("Web.UserProfile","PasswordLowercaseObliged",sWebLanguage)+"<br>");
        }
        else{
            if(uppercaseObliged){
                out.print("<img src='"+sCONTEXTPATH+"/_img/icon_info.gif'/>");
                out.print(getTran("Web.UserProfile","PasswordUppercaseObliged",sWebLanguage)+"<br>");
            }
            if(lowercaseObliged){
                out.print("<img src='"+sCONTEXTPATH+"/_img/icon_info.gif'/>");
                out.print(getTran("Web.UserProfile","PasswordLowercaseObliged",sWebLanguage)+"<br>");
            }
        }

        out.print("</p>");

        //--- show popup to remind the user to change his password ---
        boolean showReminder = checkString(request.getParameter("popup")).equals("yes");

        if(showReminder){
            int daysLeft;
            try{ daysLeft = Integer.parseInt(checkString(request.getParameter("daysLeft"))); }
            catch(Exception e){ daysLeft = 0; }

            String msg;
            if(daysLeft==0){
                msg = getTran("Web.Password","mustUpdatePasswordNow",sWebLanguage);
            }
            else{
                msg = getTran("Web.Password","mustUpdatePassword",sWebLanguage);
                msg = msg.replaceFirst("#days#",daysLeft+"");
            }
            %>
                <script>
                  var popupUrl = "<c:url value='/popup.jsp'/>?Page=_common/search/okPopup.jsp&ts=999999999&labelValue=<%=msg%>";
                  var modalities = "dialogWidth:266px;dialogHeight:163px;center:yes;scrollbars:no;resizable:no;status:no;location:no;";
                  (window.showModalDialog)?window.showModalDialog(popupUrl,"",modalities):window.confirm("<%=msg%>");

                  UserProfile.OldPassword.focus();
                </script>
            <%
        }
    }
    //--- SAVE PASSWORD ---------------------------------------------------------------------------
    else if(sAction.equals("save")){
        boolean rulesObeyed = true;
        boolean errorNewPassword = false;
        boolean errorOldPassword = false;
        StringBuffer allErrors = new StringBuffer("<br>");
        StringBuffer ruleErrors = new StringBuffer();

        // start table
        allErrors.append("<p align='center'>")
                 .append(" <table>")
                 .append("  <tr>")
                 .append("   <td>")
                 .append("    <font color='red'>");

        //--- retrieve passwords ---
        String sOldPassword  = checkString(request.getParameter("OldPassword"));
        String sNewPassword1 = checkString(request.getParameter("NewPassword1"));
        String sNewPassword2 = checkString(request.getParameter("NewPassword2"));

        //--- apply rules ---
        // minimum characters
        if(minimumChars > -1){
            if(sNewPassword1.length() < minimumChars){
                rulesObeyed = false;
                String msg = getTran("Web.UserProfile","PasswordMinimumCharactersObliged",sWebLanguage);
                msg = msg.replaceFirst("#minChars#",minimumChars+"");
                ruleErrors.append("<img src='"+sCONTEXTPATH+"/_img/warning.gif'/>&nbsp;");
                ruleErrors.append(msg).append("<br>");
            }
        }

        // numbers obliged && letters obliged
        if(numbersObliged && lettersObliged){
            if(!ScreenHelper.containsNumber(sNewPassword1)){
                rulesObeyed = false;
                ruleErrors.append("<img src='"+sCONTEXTPATH+"/_img/warning.gif'/>&nbsp;");
                ruleErrors.append(getTran("Web.UserProfile","PasswordNumbersObliged",sWebLanguage)).append("<br>");
            }

            if(!ScreenHelper.containsLetter(sNewPassword1)){
                rulesObeyed = false;
                ruleErrors.append("<img src='"+sCONTEXTPATH+"/_img/warning.gif'/>&nbsp;");
                ruleErrors.append(getTran("Web.UserProfile","PasswordLettersObliged",sWebLanguage)).append("<br>");
            }
        }
        else{
            // numbers obliged && letters allowed
            if(numbersObliged){
                if(!ScreenHelper.containsNumber(sNewPassword1)){
                    rulesObeyed = false;
                    ruleErrors.append("<img src='"+sCONTEXTPATH+"/_img/warning.gif'/>&nbsp;");
                    ruleErrors.append(getTran("Web.UserProfile","PasswordNumbersObliged",sWebLanguage)).append("<br>");
                }
            }

            // letters obliged && numbers allowed
            if(lettersObliged){
                if(!ScreenHelper.containsLetter(sNewPassword1)){
                    rulesObeyed = false;
                    ruleErrors.append("<img src='"+sCONTEXTPATH+"/_img/warning.gif'/>&nbsp;");
                    ruleErrors.append(getTran("Web.UserProfile","PasswordLettersObliged",sWebLanguage)).append("<br>");
                }
            }
        }

        // uppercase obliged and lowercase obliged
        if(uppercaseObliged && lowercaseObliged){
            if(!ScreenHelper.containsUppercase(sNewPassword1)){
                rulesObeyed = false;
                ruleErrors.append("<img src='"+sCONTEXTPATH+"/_img/warning.gif'/>&nbsp;");
                ruleErrors.append(getTran("Web.UserProfile","PasswordUppercaseObliged",sWebLanguage)).append("<br>");
            }

            if(!ScreenHelper.containsLowercase(sNewPassword1)){
                rulesObeyed = false;
                ruleErrors.append("<img src='"+sCONTEXTPATH+"/_img/warning.gif'/>&nbsp;");
                ruleErrors.append(getTran("Web.UserProfile","PasswordLowercaseObliged",sWebLanguage)).append("<br>");
            }
        }
        else{
            // uppercase obliged
            if(uppercaseObliged){
                if(!ScreenHelper.containsUppercase(sNewPassword1)){
                    rulesObeyed = false;
                    ruleErrors.append("<img src='"+sCONTEXTPATH+"/_img/warning.gif'/>&nbsp;");
                    ruleErrors.append(getTran("Web.UserProfile","PasswordUppercaseObliged",sWebLanguage)).append("<br>");
                }
            }

            // lowercase obliged
            if(lowercaseObliged){
                if(!ScreenHelper.containsLowercase(sNewPassword1)){
                    rulesObeyed = false;
                    ruleErrors.append("<img src='"+sCONTEXTPATH+"/_img/warning.gif'/>&nbsp;");
                    ruleErrors.append(getTran("Web.UserProfile","PasswordLowercaseObliged",sWebLanguage)).append("<br>");
                }
            }
        }

        //--- compare passwords ---
        if(!sNewPassword1.equals(sNewPassword2)){
            errorNewPassword = true;
            allErrors.append("<img src='"+sCONTEXTPATH+"/_img/warning.gif'/>&nbsp;");
            allErrors.append("<b>").append(getTran("Web.UserProfile","ErrorNewPassword",sWebLanguage)).append("</b><br>");
        }
        else{
            byte[] aOldPassword = activeUser.encrypt(sOldPassword);

            if(!activeUser.checkPassword(aOldPassword)){
                errorOldPassword = true;
                allErrors.append("<img src='"+sCONTEXTPATH+"/_img/warning.gif'/>&nbsp;");
                allErrors.append("<b>").append(getTran("Web.UserProfile","ErrorOldPassword",sWebLanguage)).append("</b><br>");
            }
            else{
                if(rulesObeyed && !errorOldPassword && !errorNewPassword){
                    // all OK :
                    byte[] aNewPassword = activeUser.encrypt(sNewPassword1);

                    // store the new password in session
                    activeUser.password = aNewPassword;
                    session.setAttribute("activeUser", activeUser);

                    //store new password in DB
                    activeUser.savePasswordToDB();
                    
                    // let user remember when he changed his password
                    Parameter pwdChangeParam = new Parameter("pwdChangeDate",System.currentTimeMillis()+"");
                    activeUser.updateParameter(pwdChangeParam);

                    // display how long the password remains valid
                    int availability;
                    try{ availability = Integer.parseInt(MedwanQuery.getInstance().getConfigString("PasswordAvailability")); }
                    catch(NumberFormatException e1){ availability = -1; }

                    // return to userprofile index
                    allErrors.append("<script>window.location.href='main.do?Page=userprofile/index.jsp");

                    // add message to url
                    if(availability > 0){
                        String msg = getTran("Web.UserProfile","PasswordAvailability",sWebLanguage);
                        msg = msg.replaceFirst("#validDays#",availability+"");

                        // go to userprofile mainpage with a message
                        allErrors.append("&msg=").append(msg);
                    }

                    allErrors.append("'</script>");
                }
            }
        }

        //--- append back button ---
        StringBuffer backButton = new StringBuffer();
        backButton.append("<input type='button' class='button'")
                  .append(" value='").append(getTran("Web","back",sWebLanguage)).append("'")
                  .append(" onclick='window.location.href=\"main.do?Page=userprofile/changepassword.jsp&popup=no\"'>");

        //--- display errors ---
        // end table
        allErrors.append(ruleErrors)
                 .append("     <br>")
                 .append("    </font>")
                 .append("   </td>")
                 .append("  </tr>")
                 .append("  <tr><td align='center'>"+backButton+"</td></tr>")
                 .append(" </table>")
                 .append("</p>");

        out.print(allErrors);
    }
%>
<script>
  function doSave(){
    UserProfile.saveButton.disabled = true;
    UserProfile.backButton.disabled = true;
    UserProfile.Action.value = "save";
    UserProfile.submit();
  }
</script>
