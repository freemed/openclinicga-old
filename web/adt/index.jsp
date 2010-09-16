<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>

<%=ScreenHelper.writeTblHeader(getTran("web","adt",sWebLanguage),sCONTEXTPATH)
    +writeTblChild("main.do?Page=adt/manageBeds.jsp",getTran("Web.manage","manageBeds",sWebLanguage))
    //+writeTblChild("main.do?Page=adt/manageEncounters.jsp",getTran("Web.manage","manageEncounters",sWebLanguage))todo update manageEncounters.jsp to current version
    +ScreenHelper.writeTblFooter()
%>