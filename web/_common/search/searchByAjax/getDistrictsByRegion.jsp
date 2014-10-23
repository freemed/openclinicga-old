<%@page import="java.util.*,
                be.mxs.common.util.system.HTMLEntities"%>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>
<%
    String sFindRegion = checkString(request.getParameter("FindRegion"));

    Vector vDistricts = Zipcode.getDistricts(sFindRegion,MedwanQuery.getInstance().getConfigString("zipcodetable","RwandaZipcodes"));
    Collections.sort(vDistricts);
 
    String sTmpDistrict, sDistricts = "";
    for(int i=0; i<vDistricts.size(); i++){
        sTmpDistrict = (String)vDistricts.elementAt(i);
        sDistricts+= "$"+checkString(sTmpDistrict);
    }
    
    out.print(sDistricts);
%>
