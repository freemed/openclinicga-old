<%@page import="be.openclinic.adt.Planning"%>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>

<%
    String sUserUID = checkString(request.getParameter("UserUID"));
    String sPlannedDate = checkString(request.getParameter("PlannedDate"));
    String sPlannedDateTime = checkString(request.getParameter("PlannedDateTime"));
    String sPlanningUID   = checkString(request.getParameter("PlanningUID"));
    String sEstimatedtime   = checkString(request.getParameter("PlannedEstimatedtime"));

    boolean bIsAvailable = Planning.isAvailablePlannedDate(sUserUID, sPlannedDate, sPlannedDateTime, sPlanningUID, sEstimatedtime);
%>

{"available":"<%=bIsAvailable%>"}