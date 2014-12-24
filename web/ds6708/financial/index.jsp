<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>

<%=ScreenHelper.writeTblHeader(getTran("web","financial",sWebLanguage),sCONTEXTPATH)
    +writeTblChild("main.do?Page=financial/managePrestations.jsp",getTran("Web.manage","managePrestations",sWebLanguage))
    +writeTblChild("main.do?Page=financial/managePrestationGroups.jsp",getTran("Web.manage","managePrestationGroups",sWebLanguage))
    +writeTblChild("main.do?Page=financial/manageBalances.jsp",getTran("Web.manage","manageBalances",sWebLanguage))
    +writeTblChild("main.do?Page=financial/wicket/wicketOverview.jsp",getTran("wicket","wicketoverview",sWebLanguage))
    +ScreenHelper.writeTblFooter()
%>