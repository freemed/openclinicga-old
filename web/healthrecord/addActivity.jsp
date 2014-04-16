<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>

<%
    MedwanQuery.getInstance().storeActivity(Integer.parseInt(activePatient.personid),Integer.parseInt(activeUser.userid),
    		                                new java.util.Date(),request.getParameter("activityCode"),
    		                                "USER-ADDED."+activePatient.personid+"."+activeUser.userid+"."+new SimpleDateFormat("yyyyMMddHHmmssSSS").format(new java.util.Date()),
    		                                null,null,checkString(request.getParameter("md")),activeUser.userid,
    		                                checkString((String)session.getAttribute("activeMedicalCenter")),
    		                                checkString((String)session.getAttribute("activePara")));
%>

<script>
  window.location.href='<c:url value='/popup.jsp'/>?Page=_common/search/searchActivityCode.jsp&ts=<%=getTs()%>';
</script>