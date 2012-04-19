<%@ page import="java.util.*,be.mxs.common.util.system.HTMLEntities" %>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>
<%
	String sFindRegion = checkString(request.getParameter("FindRegion"));
	String sFindDistrict = checkString(request.getParameter("FindDistrict"));
	String sFindCity = checkString(request.getParameter("FindSector"));
    Vector vQuarters = Zipcode.getQuarters(sFindRegion,sFindDistrict,sFindCity,MedwanQuery.getInstance().getConfigString("zipcodetable","RwandaZipcodes"));

    Collections.sort(vQuarters);
    String sTmpQuarter, sQuarters = "";

    for (int i = 0; i < vQuarters.size(); i++) {
        sTmpQuarter = (String) vQuarters.elementAt(i);

        sQuarters += "$" + checkString(sTmpQuarter);
    }
    out.print(sQuarters);
%>
