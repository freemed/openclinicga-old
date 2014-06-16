<%@ include file="/includes/validateUser.jsp"%>
<%
    String sPage = request.getParameter("Page");
    ScreenHelper.setIncludePage(customerInclude(sPage), pageContext);
%>