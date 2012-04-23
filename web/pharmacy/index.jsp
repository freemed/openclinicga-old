<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>

<%-- PHARMACY --%>
<%=ScreenHelper.writeTblHeader(getTran("Web","pharmacy",sWebLanguage),sCONTEXTPATH)
    +writeTblChild("main.do?Page=pharmacy/manageProducts.jsp",getTran("Web.Manage","manageProducts",sWebLanguage))
    +writeTblChild("main.do?Page=pharmacy/manageServiceStocks.jsp",getTran("Web.Manage","manageServiceStocks",sWebLanguage))
    +writeTblChild("main.do?Page=pharmacy/drugsOut.jsp",getTran("web","drugsout",sWebLanguage))
    +writeTblChild("main.do?Page=pharmacy/manageUserProducts.jsp",getTran("web","manageUserProducts",sWebLanguage))
    +writeTblChild("main.do?Page=pharmacy/manageProductOrders.jsp",getTran("web","manageProductOrders",sWebLanguage))
    +writeTblChild("main.do?Page=pharmacy/viewOrderTickets.jsp",getTran("web","viewOrderTickets",sWebLanguage))
    +writeTblChild("main.do?Page=pharmacy/manageProductStockDocuments.jsp",getTran("web","manageProductStockDocuments",sWebLanguage))
    +ScreenHelper.writeTblFooter()
%>