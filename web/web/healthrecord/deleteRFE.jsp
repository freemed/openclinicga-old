<%@ page import="be.mxs.common.util.system.ScreenHelper" %>
<%@ page import="be.openclinic.medical.ReasonForEncounter" %><%
    String serverid= ScreenHelper.checkString(request.getParameter("serverid"));
    String objectid= ScreenHelper.checkString(request.getParameter("objectid"));
    String encounterUid= ScreenHelper.checkString(request.getParameter("encounterUid"));
    String language= ScreenHelper.checkString(request.getParameter("language"));
    ReasonForEncounter.delete(Integer.parseInt(serverid),Integer.parseInt(objectid));
    String sResponse=ReasonForEncounter.getReasonsForEncounterAsHtml(encounterUid,language,"_img/icon_delete.gif","deleteRFE($serverid,$objectid)");
    out.println(sResponse);
%>