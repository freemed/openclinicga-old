<%@ page import="java.util.*,be.mxs.common.util.system.HTMLEntities" %>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>
<%
    String sFindDistrict = checkString(request.getParameter("FindDistrict"));
	String sFindCity = checkString(request.getParameter("FindCity"));
	String sFindRegion = checkString(request.getParameter("FindRegion"));
	String sFindSector = checkString(request.getParameter("FindQuarter"));

    String sZipcode = Zipcode.getZipcode(sFindRegion,sFindDistrict,sFindCity,sFindSector,MedwanQuery.getInstance().getConfigString("zipcodetable","RwandaZipcodes"));

    out.print(sZipcode);
%>
