<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>
<%=ScreenHelper.writeTblHeader(getTran("web","xrays",sWebLanguage),sCONTEXTPATH)%>
<%
    if(activePatient!=null){
        if(activeUser.getAccessRight("rx.listxrayrequests.select")) out.print(writeTblChildWithCode("javascript:showImagingRequests(0);",getTran("Web","xrayrequestsforthispatient",sWebLanguage)+" "+activePatient.firstname+" "+activePatient.lastname));
    }
    if(activeUser.getAccessRight("rx.openxrayrequests.select")) out.print(writeTblChildWithCode("javascript:showImagingRequests(1);",getTran("Web","openXRayRequestToExecute",sWebLanguage)));
    if(activeUser.getAccessRight("rx.xrayrequesttoprotocol.select")) out.print(writeTblChildWithCode("javascript:showImagingRequests(2);",getTran("web","openXRayRequestToValidate",sWebLanguage)));
    if(activeUser.getAccessRight("rx.openxrayrequests.select") && MedwanQuery.getInstance().getConfigInt("enableImageHub",0)==1) out.print(writeTblChildWithCode("javascript:showImageHub();",getTran("web","imagehub",sWebLanguage)));
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
  
  function showImageHub(){
	  showModalDialog("<c:url value='/xrays/ih_getstudies.jsp'/>","","dialogTop:"+((screen.height-400)/2)+"; dialogLeft:"+((screen.width-600)/2)+";dialogWidth:600px;dialogHeight:400px");
  }
</script>