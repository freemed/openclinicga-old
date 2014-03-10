<%@ page import="be.mxs.common.util.system.HTMLEntities" %>
<%@ page import="java.util.*" %>
<%@ page import="be.openclinic.meals.NutricientItem" %>
<%@include file="/includes/validateUser.jsp" %>
<%
    String sNutricientItemId = checkString(request.getParameter("nutricientItemId"));
    NutricientItem item = new NutricientItem(sNutricientItemId);
    if (sNutricientItemId.length() > 0 && !sNutricientItemId.equals("-1")) {
        item = NutricientItem.get(item);
    }
%>
<table cellspacing="1" cellpadding="1" width="100%" class="sortable" onKeyDown='if(event.keyCode==13){setNutricientItem();return false;}'>
    <tr width="100%">
        <td class="admin" width="<%=sTDAdminWidth%>"><%=HTMLEntities.htmlentities(getTran("meals", "nutricientItemName", sWebLanguage))%>
        </td>
        <td class="admin2">
            <input class="text" style="width:200px" type="text" id="nutricientItemName" value="<%=checkString(HTMLEntities.htmlentities(item.name))%>"/>
        </td>
    </tr>
    <tr width="100%">
        <td class="admin"><%=HTMLEntities.htmlentities(getTran("meals", "nutricientItemUnit", sWebLanguage))%>
        </td>
        <td class="admin2">
            <select id="nutricientItemUnit" style="width:200px">
                <%Hashtable labelTypes = (Hashtable) MedwanQuery.getInstance().getLabels().get(sWebLanguage.toLowerCase());
                    if (labelTypes != null) {
                        Hashtable labelIds = (Hashtable) labelTypes.get("meals");
                        Iterator it = labelIds.keySet().iterator();
                        Label l = null;
                        while (it.hasNext()) {
                            String s = (String) it.next();
                            if (s.indexOf("unit.nutricient") == 0) {
                                l = (Label) labelIds.get(s);
                                out.write("<option " + (l.value.equalsIgnoreCase(item.unit) ? "selected=selected" : "") + " >" + HTMLEntities.htmlentities(l.value) + "</option>");
                            }
                        }
                    }%>
            </select>
        </td>
    </tr>
    <tr width="100%">
        <td class="admin">&nbsp;
        </td>
        <td class="admin2">
            <input class="button" type="button" name="SaveButton" id="SaveButton" value="<%=HTMLEntities.htmlentities(getTranNoLink("web","Save",sWebLanguage))%>" onclick="setNutricientItem();"> &nbsp;<input <%=(item.getUid().equalsIgnoreCase("-1")?"type=\"hidden\"":"type=\"button\"")%> class="button" name="SaveButton" id="deleteButton" value="<%=HTMLEntities.htmlentities(getTranNoLink("web","delete",sWebLanguage))%>" onclick="deleteNutricientItem('<%=item.getUid()%>');"> &nbsp;<input class="button" type="button" name="closeButton" id="closeButton" value="<%=HTMLEntities.htmlentities(getTranNoLink("web","close",sWebLanguage))%>" onclick="closeModalbox();">
            <input type="hidden" id="nutricientItemId" value="<%=checkString(item.getUid())%>"/>
        </td>
    </tr>
</table>
<script></script>