<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>
<%=
 (
    ScreenHelper.writeTblHeader(getTran("Web","MyProfile",sWebLanguage),sCONTEXTPATH)
    +writeTblChild("main.do?Page=userprofile/changepassword.jsp",getTran("Web.UserProfile","ChangePassword",sWebLanguage))
    +writeTblChild("main.do?Page=userprofile/changedefaultpage.jsp",getTran("Web.UserProfile","ChangeDefaultPage",sWebLanguage))
    +writeTblChild("main.do?Page=userprofile/changedefaultfocus.jsp",getTran("Web.UserProfile","Change",sWebLanguage)+" "+getTran("Web.UserProfile","Focus",sWebLanguage).toLowerCase())
    +writeTblChild("main.do?Page=userprofile/changetimeout.jsp",getTran("Web.UserProfile","Change",sWebLanguage)+" "+getTran("Web.UserProfile","timeout",sWebLanguage).toLowerCase())
    +writeTblChild("main.do?Page=userprofile/changeservice.jsp",getTran("Web.UserProfile","ChangeService",sWebLanguage))
    +writeTblChild("main.do?Page=userprofile/changelanguage.jsp",getTran("Web.UserProfile","ChangeLanguage",sWebLanguage))
    //+writeTblChild("main.do?Page=userprofile/manageExaminations.jsp",getTranNoLink("Web.UserProfile","ManageExaminations",sWebLanguage))
    +writeTblChild("main.do?Page=userprofile/managePlanning.jsp",getTranNoLink("Web.UserProfile","ManagePlanning",sWebLanguage))
    +writeTblChild("main.do?Page=system/manageQuickList.jsp&UserQuickList=1",getTran("Web.UserProfile","ManageQuickList",sWebLanguage))
    +writeTblChild("main.do?Page=system/manageQuickLabList.jsp&UserQuickList=1",getTran("Web.UserProfile","ManageQuickLabList",sWebLanguage))
    +writeTblChild("main.do?Page=system/manageShortcuts.jsp&UserQuickList=1",getTran("Web.UserProfile","ManageShortcuts",sWebLanguage))
    +writeTblChild("main.do?Page=userprofile/manageUserShortcuts.jsp",getTranNoLink("web.userProfile","manageUserShortcuts",sWebLanguage))
    +ScreenHelper.writeTblFooter()
 )
%>
