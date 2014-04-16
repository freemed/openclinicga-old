<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>
<%=ScreenHelper.writeTblHeader(getTran("web","xrays",sWebLanguage),sCONTEXTPATH)%>
<%
    if(activePatient!=null){
        if(activeUser.getAccessRight("rx.listxrayrequests.select")) out.print(writeTblChildWithCode("javascript:showImagingRequests(0);",getTran("Web","xrayrequestsforthispatient",sWebLanguage)+" "+activePatient.firstname+" "+activePatient.lastname));
    }
    if(activeUser.getAccessRight("rx.openxrayrequests.select")) out.print(writeTblChildWithCode("javascript:showImagingRequests(1);",getTran("Web","openXRayRequestToExecute",sWebLanguage)));
    if(activeUser.getAccessRight("rx.xrayrequesttoprotocol.select")) out.print(writeTblChildWithCode("javascript:showImagingRequests(2);",getTran("web","openXRayRequestToValidate",sWebLanguage)));
    out.print(ScreenHelper.writeTblFooter());
%>
<script>
  function showImagingRequests(type){
    if(type==0){
      window.location.href = "<c:url value='/main.do'/>?Page=healthrecord/manageXRayRequests.jsp&ts=<%=getTs()%>";
    }
    else if(type==1){
      window.location.href = "<c:url value='/main.do'/>?Page=xrays/manageXRayRequests.jsp&toexecute=true&ts=<%=getTs()%>";
    }
    else if(type==2){
      window.location.href = "<c:url value='/main.do'/>?Page=xrays/manageXRayRequests.jsp&tovalidate=true&ts=<%=getTs()%>";
    }
  }
</script>