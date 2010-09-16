<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>

<%-- PHARMACY --%>
<%=ScreenHelper.writeTblHeader(getTran("Web","pharmacy",sWebLanguage),sCONTEXTPATH)
    +writeTblChild("main.do?Page=pharmacy/manageProducts.jsp",getTran("Web.Manage","manageProducts",sWebLanguage))
    +writeTblChild("main.do?Page=pharmacy/manageServiceStocks.jsp",getTran("Web.Manage","manageServiceStocks",sWebLanguage))
    +ScreenHelper.writeTblFooter()
%>