<%@ page import="java.util.*,be.mxs.common.util.system.HTMLEntities" %>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>
<%
    String sFindDistrict = checkString(request.getParameter("FindDistrict"));
    String sFindCity = checkString(request.getParameter("FindCity"));

    String sZipcode = Zipcode.getZipcode(sFindDistrict,sFindCity,MedwanQuery.getInstance().getConfigString("zipcodetable","RwandaZipcodes"));

    out.print(sZipcode);
%>
