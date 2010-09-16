<%@page errorPage="/includes/error.jsp"%>
<%@ include file="/includes/validateUser.jsp"%>
<%
    String sDocument = checkString(request.getParameter("Document"));
    ScreenHelper.setIncludePage(customerInclude(sDocument), pageContext);
%>