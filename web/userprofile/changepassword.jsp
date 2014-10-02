<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>

<script>
  function doBack(){
    window.location.href = "<c:url value='/main.do'/>?Page=userprofile/index.jsp";
  }
</script>

<%
    String sAction = checkString(request.getParameter("Action"));

    //--- retrieve rules ---
    int minimumChars         = MedwanQuery.getInstance().getConfigInt("PasswordMinimumCharacters"),
        notReusablePasswords = MedwanQuery.getInstance().getConfigInt("PasswordNotReusablePasswords");

    boolean lettersObliged      = MedwanQuery.getInstance().getConfigString("PasswordObligedLetters").equals("on"),
            uppercaseObliged    = MedwanQuery.getInstance().getConfigString("PasswordObligedUppercase").equals("on"),
            lowercaseObliged    = MedwanQuery.getInstance().getConfigString("PasswordObligedLowerCase").equals("on"),
            numbersObliged      = MedwanQuery.getInstance().getConfigString("PasswordObligedNumbers").equals("on"),
            alfanumericsObliged = MedwanQuery.getInstance().getConfigString("PasswordObligedAlfanumerics").equals("on");
    
    boolean noReuseOfOldPwd = (notReusablePasswords > 0); 

    /// DEBUG /////////////////////////////////////////////////////////////////////////////////////
    if(Debug.enabled){
    	Debug.println("\n******************** userprofile/changepassword.jsp *******************");
    	Debug.println("sAction              : "+sAction);
    	Debug.println("minimumChars         : "+minimumChars);
    	Debug.println("notReusablePasswords : "+notReusablePasswords);
    	
    	Debug.println("lettersObliged       : "+lettersObliged);
    	Debug.println("uppercaseObliged     : "+uppercaseObliged);
    	Debug.println("lowercaseObliged     : "+lowercaseObliged);
    	Debug.println("numbersObliged       : "+numbersObliged);
    	Debug.println("alfanumericsObliged  : "+alfanumericsObliged);
    	
    	Debug.println("--> noReuseOfOldPwd  : "+noReuseOfOldPwd+"\n");
    }
    ///////////////////////////////////////////////////////////////////////////////////////////////

    //--- DISPLAY FORM ----------------------------------------------------------------------------
    if(sAction.length()==0){
        %>
            <form name="UserProfile" method="post">
                <input type="hidden" name="Action">
                
                <%=writeTableHeader("Web.UserProfile","changePassword",sWebLanguage," doBack();")%>
                
                <table width="100%" cellspacing="1" cellpadding="0" class="list">
                    <%-- OldPassword --%>
                    <tr>
                        <td class="admin"><%=getTranNoLink("Web.UserProfile","PutOldPassword",sWebLanguage)%></td>
                        <td class="admin2"><input type="password" name="OldPassword" class="text" size="25" maxLength="20"></td>
                    </tr>
                    
                    <%-- NewPassword 1 --%>
                    <tr>
                        <td class="admin"><%=getTranNoLink("Web.UserProfile","PutNewPassword",sWebLanguage)%></td>
                        <td class="admin2"><input type="password" name="NewPassword1" class="text" size="25" maxLength="20"></td>
                    </tr>
                    
                    <%-- NewPassword 2 --%>
                    <tr>
                        <td class="admin" width="<%=sTDAdminWidth%>"><%=getTranNoLink("Web.UserProfile","PutNewPasswordAgain",sWebLanguage)%></td>
                        <td class="admin2"><input type="password" name="NewPassword2" class="text" size="25" maxLength="20"></td>
                    </tr>
                    
                    <%-- BUTTONS --%>
                    <%=ScreenHelper.setFormButtonsStart()%>
                        <input type="button" class="button" name="saveButton" value='<%=getTranNoLink("Web","save",sWebLanguage)%>' onClick='doSave();'>
                        <input type="button" class="button" name="backButton" value='<%=getTranNoLink("Web","back",sWebLanguage)%>' onClick='doBack();'>
                    <%=ScreenHelper.setFormButtonsStop()%>
                </table>
            </form>
                
            <script>
              UserProfile.OldPassword.focus();

              <%-- DO SAVE --%>
              function doSave(){
                if(UserProfile.OldPassword.value.length==0){
                  UserProfile.OldPassword.focus();
                }
                else if(UserProfile.NewPassword1.value.length==0){
                  UserProfile.NewPassword1.focus();
                }
                else if(UserProfile.NewPassword2.value.length==0){
                  UserProfile.NewPassword2.focus();
                }
                else if(UserProfile.NewPassword1.value.length > 250){
                  alertDialog("Web.Password","PasswordTooLong");
                  UserProfile.NewPassword1.focus();
                }
                else if(UserProfile.NewPassword2.value.length > 250){
                  alertDialog("Web.Password","PasswordTooLong");
                  UserProfile.NewPassword2.focus();
                }
                else{
                  UserProfile.saveButton.disabled = true;
                  UserProfile.backButton.disabled = true;
                  UserProfile.Action.value = "save";
                  UserProfile.submit();
                }
              }
            </script>
        <%

        //--- DISPLAY APPLIED RULES ---------------------------------------------------------------
        out.print("<p style='font-size:12px;'>");

        // reuse of old password allowed ?
        if(noReuseOfOldPwd){
            out.print("<img src='"+sCONTEXTPATH+"/_img/icons/icon_info.gif' style='vertical-align:-2px;'/>&nbsp;");
            out.print(getTran("web.userProfile","PasswordNoReuseOfOldPwdAllowed",sWebLanguage).replaceAll("#numberOfPasswords#",Integer.toString(notReusablePasswords))+"<br>");
        }
        
        if(minimumChars > -1){
            String msg = getTran("Web.UserProfile","PasswordMinimumCharactersObliged",sWebLanguage);
            msg = msg.replaceFirst("#minChars#",minimumChars+"");
            out.print("<img src='"+sCONTEXTPATH+"/_img/icons/icon_info.gif' style='vertical-align:-2px;'/>&nbsp;");
            out.print(msg+"<br>");
        }

        if(numbersObliged){
            out.print("<img src='"+sCONTEXTPATH+"/_img/icons/icon_info.gif' style='vertical-align:-2px;'/>&nbsp;");
            out.print(getTran("Web.UserProfile","PasswordNumbersObliged",sWebLanguage)+"<br>");
        }
        
        if(lettersObliged){
            out.print("<img src='"+sCONTEXTPATH+"/_img/icons/icon_info.gif' style='vertical-align:-2px;'/>&nbsp;");
            out.print(getTran("Web.UserProfile","PasswordLettersObliged",sWebLanguage)+"<br>");
        }

        if(uppercaseObliged){
            out.print("<img src='"+sCONTEXTPATH+"/_img/icons/icon_info.gif' style='vertical-align:-2px;'/>&nbsp;");
            out.print(getTran("Web.UserProfile","PasswordUppercaseObliged",sWebLanguage)+"<br>");
        }
        
        if(lowercaseObliged){
            out.print("<img src='"+sCONTEXTPATH+"/_img/icons/icon_info.gif' style='vertical-align:-2px;'/>&nbsp;");
            out.print(getTran("Web.UserProfile","PasswordLowercaseObliged",sWebLanguage)+"<br>");
        }
        
        if(alfanumericsObliged){
            out.print("<img src='"+sCONTEXTPATH+"/_img/icons/icon_info.gif' style='vertical-align:-2px;'/>&nbsp;");
            out.print(getTran("Web.UserProfile","PasswordAlfanumericsObliged",sWebLanguage)+"<br>");
        }

        out.print("</p>");

        //--- show popup to remind the user to change his password ---
        boolean showReminder = checkString(request.getParameter("popup")).equals("yes");

        if(showReminder){
            int daysLeft;
            try{
            	daysLeft = Integer.parseInt(checkString(request.getParameter("daysLeft")));
            }
            catch(Exception e){
            	daysLeft = 0;
            }

            String msg;
            if(daysLeft==0){
                msg = getTranNoLink("Web.Password","mustUpdatePasswordNow",sWebLanguage);
            }
            else{
                msg = getTranNoLink("Web.Password","mustUpdatePassword",sWebLanguage);
                msg = msg.replaceFirst("#days#",daysLeft+"");
            }
            
            %>
                <script>
                  alertDialogDirectText("<%=msg%>");
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
                 .append("<table>")
                 .append("<tr>")
                 .append("<td>")
                 .append("<font color='red'>");

        //--- retrieve passwords ---
        String sOldPassword  = checkString(request.getParameter("OldPassword")),
               sNewPassword1 = checkString(request.getParameter("NewPassword1")),
               sNewPassword2 = checkString(request.getParameter("NewPassword2"));

        // reuse of old pwd allowed ?
        if(noReuseOfOldPwd){
            // how many of the used passwords must be considered ?
            int oldPwdCount = 10000; // all
            if(notReusablePasswords > 0){
                oldPwdCount = notReusablePasswords;
            }

            boolean passwordIsUsedBefore = User.isPasswordUsedBefore(sNewPassword1,activeUser,oldPwdCount);
            if(passwordIsUsedBefore || sNewPassword1.equals(sOldPassword)){
                rulesObeyed = false;
                String msg = getTran("web.userProfile","PasswordNoReuseOfOldPwdAllowed",sWebLanguage).replaceAll("#numberOfPasswords#",Integer.toString(notReusablePasswords));
                ruleErrors.append("<img src='"+sCONTEXTPATH+"/_img/icons/icon_warning.gif' style='vertical-align:-3px'/>&nbsp;");
                ruleErrors.append(msg).append("<br>");
            }
        }
        
        //--- apply rules ---
        // minimum characters
        if(minimumChars > -1){
            if(sNewPassword1.length() < minimumChars){
                rulesObeyed = false;
                String msg = getTran("Web.UserProfile","PasswordMinimumCharactersObliged",sWebLanguage);
                msg = msg.replaceFirst("#minChars#",minimumChars+"");
                ruleErrors.append("<img src='"+sCONTEXTPATH+"/_img/icons/icon_warning.gif' style='vertical-align:-3px'/>&nbsp;");
                ruleErrors.append(msg).append("<br>");
            }
        }

        // numbers obliged && letters obliged
        if(numbersObliged && lettersObliged){
            if(!ScreenHelper.containsNumber(sNewPassword1)){
                rulesObeyed = false;
                ruleErrors.append("<img src='"+sCONTEXTPATH+"/_img/icons/icon_warning.gif' style='vertical-align:-3px'/>&nbsp;");
                ruleErrors.append(getTran("Web.UserProfile","PasswordNumbersObliged",sWebLanguage)).append("<br>");
            }

            if(!ScreenHelper.containsLetter(sNewPassword1)){
                rulesObeyed = false;
                ruleErrors.append("<img src='"+sCONTEXTPATH+"/_img/icons/icon_warning.gif' style='vertical-align:-3px'/>&nbsp;");
                ruleErrors.append(getTran("Web.UserProfile","PasswordLettersObliged",sWebLanguage)).append("<br>");
            }
        }
        else{
            // numbers obliged && letters allowed
            if(numbersObliged){
                if(!ScreenHelper.containsNumber(sNewPassword1)){
                    rulesObeyed = false;
                    ruleErrors.append("<img src='"+sCONTEXTPATH+"/_img/icons/icon_warning.gif' style='vertical-align:-3px'/>&nbsp;");
                    ruleErrors.append(getTran("Web.UserProfile","PasswordNumbersObliged",sWebLanguage)).append("<br>");
                }
            }

            // letters obliged && numbers allowed
            if(lettersObliged){
                if(!ScreenHelper.containsLetter(sNewPassword1)){
                    rulesObeyed = false;
                    ruleErrors.append("<img src='"+sCONTEXTPATH+"/_img/icons/icon_warning.gif' style='vertical-align:-3px'/>&nbsp;");
                    ruleErrors.append(getTran("Web.UserProfile","PasswordLettersObliged",sWebLanguage)).append("<br>");
                }
            }
        }

        // uppercase obliged and lowercase obliged
        if(uppercaseObliged && lowercaseObliged){
            if(!ScreenHelper.containsUppercase(sNewPassword1)){
                rulesObeyed = false;
                ruleErrors.append("<img src='"+sCONTEXTPATH+"/_img/icons/icon_warning.gif' style='vertical-align:-3px'/>&nbsp;");
                ruleErrors.append(getTran("Web.UserProfile","PasswordUppercaseObliged",sWebLanguage)).append("<br>");
            }

            if(!ScreenHelper.containsLowercase(sNewPassword1)){
                rulesObeyed = false;
                ruleErrors.append("<img src='"+sCONTEXTPATH+"/_img/icons/icon_warning.gif' style='vertical-align:-3px'/>&nbsp;");
                ruleErrors.append(getTran("Web.UserProfile","PasswordLowercaseObliged",sWebLanguage)).append("<br>");
            }
        }
        else{
            // uppercase obliged
            if(uppercaseObliged){
                if(!ScreenHelper.containsUppercase(sNewPassword1)){
                    rulesObeyed = false;
                    ruleErrors.append("<img src='"+sCONTEXTPATH+"/_img/icons/icon_warning.gif' style='vertical-align:-3px'/>&nbsp;");
                    ruleErrors.append(getTran("Web.UserProfile","PasswordUppercaseObliged",sWebLanguage)).append("<br>");
                }
            }

            // lowercase obliged
            if(lowercaseObliged){
                if(!ScreenHelper.containsLowercase(sNewPassword1)){
                    rulesObeyed = false;
                    ruleErrors.append("<img src='"+sCONTEXTPATH+"/_img/icons/icon_warning.gif' style='vertical-align:-3px'/>&nbsp;");
                    ruleErrors.append(getTran("Web.UserProfile","PasswordLowercaseObliged",sWebLanguage)).append("<br>");
                }
            }
        }

        // alfanumerics obliged
        if(alfanumericsObliged){
            if(!ScreenHelper.containsAlfanumerics(sNewPassword1)){
                rulesObeyed = false;
                ruleErrors.append("<img src='"+sCONTEXTPATH+"/_img/icons/icon_warning.gif' style='vertical-align:-3px'/>&nbsp;");
                ruleErrors.append(getTran("Web.UserProfile","PasswordAlfanumericsObliged",sWebLanguage)).append("<br>");
            }
        }
        
        //--- compare passwords ---
        if(!sNewPassword1.equals(sNewPassword2)){
            errorNewPassword = true;
            allErrors.append("<img src='"+sCONTEXTPATH+"/_img/icons/icon_warning.gif' style='vertical-align:-3px'/>&nbsp;");
            allErrors.append("<b>").append(getTran("Web.UserProfile","ErrorNewPassword",sWebLanguage)).append("</b><br>");
        }
        else{
            byte[] aOldPassword = activeUser.encrypt(sOldPassword);

            if(!activeUser.checkPassword(aOldPassword)){
                errorOldPassword = true;
                allErrors.append("<img src='"+sCONTEXTPATH+"/_img/icons/icon_warning.gif' style='vertical-align:-3px'/>&nbsp;");
                allErrors.append("<b>").append(getTran("Web.UserProfile","ErrorOldPassword",sWebLanguage)).append("</b><br>");
            }
            else{
                if(rulesObeyed && !errorOldPassword && !errorNewPassword){
                    // all OK :
                    byte[] aNewPassword = activeUser.encrypt(sNewPassword1);

                    // store the new password in session
                    activeUser.password = aNewPassword;
                    session.setAttribute("activeUser",activeUser);

                    //store new password in DB
                    activeUser.savePasswordToDB();
                    
                    //*** 2 : set the updatetime to now when the password is used before, otherwise add the new password ***
                    String sSql = "UPDATE UsedPasswords SET updatetime = ?"+
                   	              " WHERE userId = ?"+
                                  "  AND CAST(encryptedPassword AS BINARY) = ?";
                    Connection conn = MedwanQuery.getInstance().getAdminConnection();
                    PreparedStatement ps = conn.prepareStatement(sSql);
                    ps.setTimestamp(1,getSQLTime()); // now
                    ps.setInt(2,Integer.parseInt(activeUser.userid));
                    ps.setBytes(3,activeUser.encrypt(sNewPassword1));
                    int updatedRecords = ps.executeUpdate();
                    ps.close();
                    conn.close();
                    
                    if(updatedRecords==0){                
                    	sSql = "INSERT INTO UsedPasswords(usedPasswordId,encryptedPassword,userId,updatetime,serverid)"+
                               " VALUES (?,?,?,?,?)";
                        conn = MedwanQuery.getInstance().getAdminConnection();
                        ps = conn.prepareStatement(sSql);
                        ps.setInt(1,MedwanQuery.getInstance().getOpenclinicCounter("UsedPasswords"));
                        ps.setBytes(2,activeUser.encrypt(sNewPassword1));
                        ps.setInt(3,Integer.parseInt(activeUser.userid));
                        ps.setTimestamp(4,getSQLTime()); // now
                        ps.setInt(5,MedwanQuery.getInstance().getConfigInt("serverId"));
                        ps.executeUpdate();
                        ps.close();
                        conn.close();
                    }

                    // let user remember when he changed his password
                    Parameter pwdChangeParam = new Parameter("pwdChangeDate",System.currentTimeMillis()+"");
                    activeUser.updateParameter(pwdChangeParam);

                    // display how long the password remains valid
                    int availability = MedwanQuery.getInstance().getConfigInt("PasswordAvailability");

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
                  .append("value='").append(getTranNoLink("Web","back",sWebLanguage)).append("' ")
                  .append("onclick='window.location.href=\"main.do?Page=userprofile/changepassword.jsp&popup=no\"'>");

        //--- display errors ---
        // end table
        allErrors.append(ruleErrors)
                 .append("<br>")
                 .append("</font>")
                 .append("</td>")
                 .append("</tr>")
                 .append("<tr><td align='center'>"+backButton+"</td></tr>")
                 .append("</table>")
                 .append("</p>");

        out.print(allErrors);
    }
%>
<script>
  <%-- DO SAVE --%>
  function doSave(){
    UserProfile.saveButton.disabled = true;
    UserProfile.backButton.disabled = true;
    UserProfile.Action.value = "save";
    UserProfile.submit();
  }
</script>
