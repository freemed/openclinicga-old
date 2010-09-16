<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>
<%
    ScreenHelper.setIncludePage(customerInclude("/healthrecord/medIntConsultation.jsp"), pageContext);
%>