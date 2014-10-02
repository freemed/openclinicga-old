<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>

<html>
<head>
    <%
        String sUserTheme = checkString((String)session.getAttribute("UserTheme"));
        if(sUserTheme.equals("default")) sUserTheme = "";
        if(sUserTheme.length() > 0) sUserTheme = "_"+sUserTheme;
    %>
    <link href="<c:url value='/_common/_css/web<%=sUserTheme%>.css'/>" rel="stylesheet" type="text/css" media="screen">
</head>

<body>
    <br><br>
    <br><br>
    <br><br>
    
<%
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
		Debug.println("\n******************* userprofile/changepasswordonly.jsp *****************");
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

    //--- DISPLAY PASSWORDS -----------------------------------------------------------------------
    if(request.getParameter("SaveUserProfile")==null) {
        %>
            <form name='UserProfile' action='<c:url value='/changePassword.do'/>' method='post'>
                <input type='hidden' name='SaveUserProfile' value='ok'/>
                <input type='hidden' name='ts' value='<%=getTs()%>'/>
                    
                <table width='100%' align='center' cellspacing="1" class="list">
                    <%-- TITLE --%>
                    <tr class="admin">
                        <td colspan="2">&nbsp;&nbsp;<%=(getTranNoLink("Web.UserProfile","ChangePassword",sWebLanguage))%>&nbsp;</td>
                    </tr>

                    <%-- OldPassword --%>
                    <tr>
                        <td class="admin"><%=getTranNoLink("Web.UserProfile","PutOldPassword",sWebLanguage)%></td>
                        <td class="admin2"><input type='password' name='OldPassword' class="text" size="25" maxLength="20"></td>
                    </tr>

                    <%-- NewPassword1 --%>
                    <tr>
                        <td class="admin"><%=getTranNoLink("Web.UserProfile","PutNewPassword",sWebLanguage)%></td>
                        <td class="admin2"><input type='password' name='NewPassword1' class="text" size="25" maxLength="20"></td>
                    </tr>

                    <%-- NewPassword2 --%>
                    <tr>
                        <td class="admin" width="<%=sTDAdminWidth%>"><%=getTranNoLink("Web.UserProfile","PutNewPasswordAgain",sWebLanguage)%></td>
                        <td class="admin2"><input type='password' name='NewPassword2' class="text" size="25" maxLength="20"></td>
                    </tr>
                </table>

                <%-- SAVE BUTTON --%>
                <%=ScreenHelper.alignButtonsStart()%>
                    <input type='button' name='SaveUserProfile' class="button" value='<%=getTranNoLink("Web.UserProfile","Change",sWebLanguage)%>' OnClick='doSubmit();'>
                <%=ScreenHelper.alignButtonsStop()%>
            </form>

            <%-- CHECK IF FIELDS ARE PROPERLY SUPPLIED WITH DATA --%>
            <script>
              UserProfile.OldPassword.focus();

              function doSubmit(){
                if (UserProfile.OldPassword.value.length==0){
                  UserProfile.OldPassword.focus();
                }
                else if (UserProfile.NewPassword1.value.length==0){
                  UserProfile.NewPassword1.focus();
                }
                else if (UserProfile.NewPassword2.value.length==0){
                  UserProfile.NewPassword2.focus();
                }
                else if (UserProfile.NewPassword1.value.length > 250){
                  var popupUrl = "<c:url value='/popup.jsp'/>?Page=_common/search/okPopup.jsp&ts=999999999&labelType=Web.Password&labelID=PasswordTooLong";
                  var modalities = "dialogWidth:266px;dialogHeight:163px;center:yes;scrollbars:no;resizable:no;status:no;location:no;";
                  (window.showModalDialog)?window.showModalDialog(popupUrl,"",modalities):window.confirm("<%=getTranNoLink("web.Password","PasswordTooLong",sWebLanguage)%>");

                  UserProfile.NewPassword1.focus();
                }
                else if (UserProfile.NewPassword2.value.length > 250){
                  var popupUrl = "<c:url value='/popup.jsp'/>?Page=_common/search/okPopup.jsp&ts=999999999&labelType=Web.Password&labelID=PasswordTooLong";
                  var modalities = "dialogWidth:266px;dialogHeight:163px;center:yes;scrollbars:no;resizable:no;status:no;location:no;";
                  (window.showModalDialog)?window.showModalDialog(popupUrl,"",modalities):window.confirm("<%=getTranNoLink("web.Password","PasswordTooLong",sWebLanguage)%>");

                  UserProfile.NewPassword2.focus();
                }
                else{
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
        boolean showReminder = !checkString(request.getParameter("popup")).equals("no");

        if(showReminder){
            %>
                <script>
                  var popupUrl = "<c:url value='/popup.jsp'/>?Page=_common/search/okPopup.jsp&ts=999999999&labelType=Web.Password&labelID=mustUpdatePasswordNow";
                  var modalities = "dialogWidth:266px;dialogHeight:163px;center:yes;scrollbars:no;resizable:no;status:no;location:no;";
                  (window.showModalDialog)?window.showModalDialog(popupUrl,"",modalities):window.confirm("<%=getTranNoLink("web.Password","mustUpdatePasswordNow",sWebLanguage)%>");

                  UserProfile.OldPassword.focus();
                </script>
            <%
        }
    }
    //--- SAVE PASSWORDS --------------------------------------------------------------------------
    else{
        boolean rulesObeyed = true;
        boolean errorNewPassword = false;
        boolean errorOldPassword = false;
        StringBuffer allErrors = new StringBuffer();
        StringBuffer ruleErrors = new StringBuffer();

        // start table
        allErrors.append("<p align='center'>")
                 .append("<table>")
                 .append("<tr>")
                 .append("<td>")
                 .append("<font color='red'>");

        //--- retrieve passwords ---
        String sOldPassword  = checkString(request.getParameter("OldPassword")),
               sNewPassword  = checkString(request.getParameter("NewPassword1")),
               sNewPassword1 = checkString(request.getParameter("NewPassword2"));

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
            if(sNewPassword.length() < minimumChars){
                rulesObeyed = false;
                String msg = getTran("Web.UserProfile","PasswordMinimumCharactersObliged",sWebLanguage);
                msg = msg.replaceFirst("#minChars#",minimumChars+"");
                ruleErrors.append("<img src='"+sCONTEXTPATH+"/_img/icons/icon_warning.gif' style='vertical-align:-3px'/>&nbsp;");
                ruleErrors.append(msg).append("<br>");
            }
        }

        // numbers obliged && letters obliged
        if(numbersObliged && lettersObliged){
            if(!ScreenHelper.containsNumber(sNewPassword)){
                rulesObeyed = false;
                ruleErrors.append("<img src='"+sCONTEXTPATH+"/_img/icons/icon_warning.gif' style='vertical-align:-3px'/>&nbsp;");
                ruleErrors.append(getTran("Web.UserProfile","PasswordNumbersObliged",sWebLanguage)).append("<br>");
            }

            if(!ScreenHelper.containsLetter(sNewPassword)){
                rulesObeyed = false;
                ruleErrors.append("<img src='"+sCONTEXTPATH+"/_img/icons/icon_warning.gif' style='vertical-align:-3px'/>&nbsp;");
                ruleErrors.append(getTran("Web.UserProfile","PasswordLettersObliged",sWebLanguage)).append("<br>");
            }
        }
        else{
            // numbers obliged
            if(numbersObliged){
                if(!ScreenHelper.containsNumber(sNewPassword)){
                    rulesObeyed = false;
                    ruleErrors.append("<img src='"+sCONTEXTPATH+"/_img/icons/icon_warning.gif' style='vertical-align:-3px'/>&nbsp;");
                    ruleErrors.append(getTran("Web.UserProfile","PasswordNumbersObliged",sWebLanguage)).append("<br>");
                }
            }

            // letters obliged
            if(lettersObliged){
                if(!ScreenHelper.containsLetter(sNewPassword)){
                    rulesObeyed = false;
                    ruleErrors.append("<img src='"+sCONTEXTPATH+"/_img/icons/icon_warning.gif' style='vertical-align:-3px'/>&nbsp;");
                    ruleErrors.append(getTran("Web.UserProfile","PasswordLettersObliged",sWebLanguage)).append("<br>");
                }
            }
        }

        // uppercase obliged and lowercase obliged
        if(uppercaseObliged && lowercaseObliged){
            if(!ScreenHelper.containsUppercase(sNewPassword)){
                rulesObeyed = false;
                ruleErrors.append("<img src='"+sCONTEXTPATH+"/_img/icons/icon_warning.gif' style='vertical-align:-3px'/>&nbsp;");
                ruleErrors.append(getTran("Web.UserProfile","PasswordUppercaseObliged",sWebLanguage)).append("<br>");
            }

            if(!ScreenHelper.containsLowercase(sNewPassword)){
                rulesObeyed = false;
                ruleErrors.append("<img src='"+sCONTEXTPATH+"/_img/icons/icon_warning.gif' style='vertical-align:-3px'/>&nbsp;");
                ruleErrors.append(getTran("Web.UserProfile","PasswordLowercaseObliged",sWebLanguage)).append("<br>");
            }
        }
        else{
            // uppercase obliged
            if(uppercaseObliged){
                if(!ScreenHelper.containsUppercase(sNewPassword)){
                    rulesObeyed = false;
                    ruleErrors.append("<img src='"+sCONTEXTPATH+"/_img/icons/icon_warning.gif' style='vertical-align:-3px'/>&nbsp;");
                    ruleErrors.append(getTran("Web.UserProfile","PasswordUppercaseObliged",sWebLanguage)).append("<br>");
                }
            }

            // lowercase obliged
            if(lowercaseObliged){
                if(!ScreenHelper.containsLowercase(sNewPassword)){
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
        if(!sNewPassword.equals(sNewPassword1)){
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
                    // all OK : store new password in DB
                    byte[] aNewPassword = activeUser.encrypt(sNewPassword);
                    User uUser = new User();
                    uUser.password = aNewPassword;
                    uUser.userid = activeUser.userid;
                    uUser.savePasswordToDB();
                    // also store the new password in session
                    activeUser.password = aNewPassword;
                    session.setAttribute("activeUser", activeUser);

                    // let user remember when he last changed his password
                    Parameter pwdChangeParam = new Parameter("pwdChangeDate",System.currentTimeMillis()+"");
                    activeUser.updateParameter(pwdChangeParam);

                    // display how long the password remains valid
                    int availability;
                    try{ availability = Integer.parseInt(MedwanQuery.getInstance().getConfigString("PasswordAvailability")); }
                    catch(NumberFormatException e1){ availability = -1; }

                    if(availability > 0){
                        String msg = getTran("Web.UserProfile","PasswordAvailability",sWebLanguage);
                        msg = msg.replaceFirst("#validDays#",availability+"");

                        // go to userprofile indexpage with a message
				        if(request.getRequestURL().indexOf("main")>-1){
				        	allErrors.append("&msg=");
				        }
                        allErrors.append(msg);
                    }

			        if(request.getRequestURL().indexOf("main")>-1){
			        	allErrors.append("'</script>");
			        }
                }
            }
        }

        //--- back button ---
        StringBuffer backButton = new StringBuffer();
        backButton.append("<input type='button' class='button' value='").append(getTranNoLink("Web","back",sWebLanguage)).append("' ")
                  .append("onclick='window.location.href=\""+sCONTEXTPATH+"/main.do\"'");

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
</body>
</html>
