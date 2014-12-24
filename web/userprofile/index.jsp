<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>
<% int rowIdx = 0; %>
<%=
 (
    ScreenHelper.writeTblHeader(getTran("Web","MyProfile",sWebLanguage),sCONTEXTPATH)
    +writeTblChild("main.do?Page=userprofile/changepassword.jsp",getTran("Web.UserProfile","ChangePassword",sWebLanguage),rowIdx++)
    +writeTblChild("main.do?Page=userprofile/changedefaultpage.jsp",getTran("Web.UserProfile","ChangeDefaultPage",sWebLanguage),rowIdx++)
    +writeTblChild("main.do?Page=userprofile/changedefaultfocus.jsp",getTran("Web.UserProfile","Change",sWebLanguage)+" "+getTran("Web.UserProfile","Focus",sWebLanguage).toLowerCase(),rowIdx++)
    +writeTblChild("main.do?Page=userprofile/changetimeout.jsp",getTran("Web.UserProfile","Change",sWebLanguage)+" "+getTran("Web.UserProfile","timeout",sWebLanguage).toLowerCase(),rowIdx++)
    +writeTblChild("main.do?Page=userprofile/changeservice.jsp",getTran("Web.UserProfile","ChangeService",sWebLanguage),rowIdx++)
    +writeTblChild("main.do?Page=userprofile/changelanguage.jsp",getTran("Web.UserProfile","ChangeLanguage",sWebLanguage),rowIdx++)
    //+writeTblChild("main.do?Page=userprofile/manageExaminations.jsp",getTranNoLink("Web.UserProfile","ManageExaminations",sWebLanguage),rowIdx++)
    +writeTblChild("main.do?Page=userprofile/managePlanning.jsp",getTranNoLink("Web.UserProfile","ManagePlanning",sWebLanguage),rowIdx++)
    +writeTblChild("main.do?Page=system/manageQuickList.jsp&UserQuickList=1",getTran("Web.UserProfile","ManageQuickList",sWebLanguage),rowIdx++)
    +writeTblChild("main.do?Page=system/manageQuickLabList.jsp&UserQuickLabList=1",getTran("Web.UserProfile","ManageQuickLabList",sWebLanguage),rowIdx++)
    +writeTblChild("main.do?Page=system/manageShortcuts.jsp&UserQuickList=1",getTran("Web.UserProfile","manage.contact.shortcuts",sWebLanguage),rowIdx++)
    +writeTblChild("main.do?Page=userprofile/manageUserShortcuts.jsp",getTran("web.userProfile","manage.general.shortcuts",sWebLanguage),rowIdx++)
    +writeTblChild("main.do?Page=userprofile/manageHistoryItems.jsp",getTranNoLink("web.manage","manageHistoryItems",sWebLanguage),rowIdx++)
    +writeTblChild("main.do?Page=userprofile/changeTheme.jsp",getTran("web.userProfile","changeTheme",sWebLanguage),rowIdx++)
    +writeTblChild("main.do?Page=userprofile/manageDefaultValues.jsp",getTran("web.userProfile","manageDefaultValues",sWebLanguage),rowIdx++)
    +ScreenHelper.writeTblFooter()
 )
%>
