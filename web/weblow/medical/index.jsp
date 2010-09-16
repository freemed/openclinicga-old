<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>

<%-- MEDICAL --%>
<%=ScreenHelper.writeTblHeader(getTran("Web","medical",sWebLanguage),sCONTEXTPATH)
    +writeTblChild("main.do?Page=medical/managePrescriptions.jsp",getTran("Web.Manage","managePrescriptions",sWebLanguage))
    +writeTblChild("main.do?Page=medical/manageDiagnosesPatient.jsp",getTran("Web","manageDiagnosesPatient",sWebLanguage))
    +writeTblChild("main.do?Page=medical/manageDiagnosesPop.jsp",getTran("Web","manageDiagnosesPop",sWebLanguage))
    +ScreenHelper.writeTblFooter()
%>