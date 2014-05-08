<%@ page import="be.openclinic.adt.Encounter,java.util.*,be.openclinic.adt.Bed" %>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>
<%
    String sEncounterUID = checkString(request.getParameter("EncounterUID"));
    String sServiceUID = checkString(request.getParameter("ServiceUID"));    

    Encounter.deleteService(sEncounterUID,sServiceUID);

    Encounter tmpEncounter =  Encounter.get(sEncounterUID);
%>
<table width="100%">
<%
    if (tmpEncounter != null) {
        Vector transferHistory = tmpEncounter.getTransferHistory();
        Encounter.EncounterService encounterService;
        java.util.Hashtable username;

        for (int n = 0; n < transferHistory.size(); n++) {
            encounterService = (Encounter.EncounterService) transferHistory.elementAt(n);
            username = User.getUserName(encounterService.managerUID);
%>
    <tr>
        <td><img src="<c:url value="/_img/icon_delete.gif"/>" class="link" alt="<%=getTran("Web","delete",sWebLanguage)%>" onclick="deleteService('<%=encounterService.serviceUID%>')"></td>
        <td><%=ScreenHelper.fullDateFormat.format(encounterService.begin)+" - "+ScreenHelper.fullDateFormat.format(encounterService.end)%></td>
        <td><b><%=getTran("Service", encounterService.serviceUID, sWebLanguage)%></b></td>
        <td><%=getTran("web", "bed", sWebLanguage) + ": " + checkString(Bed.get(encounterService.bedUID).getName())%></td>
        <td><%=getTran("web","manager",sWebLanguage)+": "+(username!=null?username.get("firstname")+" "+username.get("lastname"):"")%></td>
    </tr>
<%
        }
    }
%>
</table>