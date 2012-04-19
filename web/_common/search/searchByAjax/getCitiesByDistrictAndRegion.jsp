<%@ page import="java.util.*,be.mxs.common.util.system.HTMLEntities" %>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>
<%
	String sFindRegion = checkString(request.getParameter("FindRegion"));
	String sFindDistrict = checkString(request.getParameter("FindDistrict"));

    Vector vCities = Zipcode.getCities(sFindRegion,sFindDistrict,MedwanQuery.getInstance().getConfigString("zipcodetable","RwandaZipcodes"));

    Collections.sort(vCities);
    String sTmpCity, sCities = "";

    for (int i = 0; i < vCities.size(); i++) {
        sTmpCity = (String) vCities.elementAt(i);

        sCities += "$" + checkString(sTmpCity);
    }
    out.print(sCities);
%>
