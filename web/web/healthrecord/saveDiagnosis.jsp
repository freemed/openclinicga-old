<%@ page import="be.openclinic.system.Diagnosis" %>
<%@page errorPage="/includes/error.jsp"%>
<%@ include file="/includes/validateUser.jsp"%>
<%
    String sItemType = request.getParameter("itemType");
    if ((sItemType == null) || (sItemType.equals("null"))) {
        sItemType = "";
    }
    if (Debug.enabled) Debug.println("Saving diagnosis");
    if (sItemType.length() > 0) {
        Diagnosis.insert(sItemType,sItemType);
    }
%>
<script>history.back()</script>