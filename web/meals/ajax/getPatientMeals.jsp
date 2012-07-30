<%@ page import="be.mxs.common.util.system.HTMLEntities" %>
<%@ page import="java.util.*" %>
<%@ page import="be.openclinic.meals.Meal" %>
<%@include file="/includes/validateUser.jsp" %>
<%
    String sFindMealByDay = checkString(request.getParameter("FindMealByDay"));
    boolean bWithSearch = checkString(request.getParameter("withSearchFields")).trim().length() > 0;
    Meal item = null;
    List lMeals = Meal.getPatientMeals(activePatient, sFindMealByDay, null);
    if (lMeals.size() > 0) {%>
<%-- SEARCH RESULTS --%>
<table width="100%" align="center" class='sortable' cellspacing="0" id="patientmeals">
    <%-- HEADER --%>
    <tr class="gray">
        <td width="28">&nbsp;</td>
        <td width="35">&nbsp;</td>
        <td width="80"><%=HTMLEntities.htmlentities(getTranNoLink("web", "time", sWebLanguage))%>
        </td>
        <td width="*"><%=HTMLEntities.htmlentities(getTranNoLink("meals", "mealName", sWebLanguage))%>
        </td>
    </tr>
        
    <%
        Iterator it = lMeals.iterator();
        int i = 0;
        while (it.hasNext()) {
            item = (Meal) it.next();
            String sClass = ((i % 2) == 0) ? "list" : "list1";
            out.write("<tr id=\"patientmeal_"+item.getUid()+"\"  class='" + sClass + " ' >");
            out.write("<td align='center'><img src='" + sCONTEXTPATH + "/_img/icon_delete.png' class='link' title='" + (HTMLEntities.htmlentities(getTranNoLink("web", "delete", sWebLanguage))) + "' onclick=\"deleteMealFromPatient('" + item.patientMealUid + "');\"></td>");
            if (item.taken) {
                out.write("<td align='center'><img src='" + sCONTEXTPATH + "/_img/checked.png' class='link' title='" + (HTMLEntities.htmlentities(getTranNoLink("meals", "mealtaken", sWebLanguage))) + "' onclick=\"setMealTaken('" + item.patientMealUid  + "','');\"></td>");
            } else {
                out.write("<td align='center'><img src='" + sCONTEXTPATH + "/_img/unchecked.png' class='link' title='" + (HTMLEntities.htmlentities(getTranNoLink("meals", "mealnottaken", sWebLanguage))) + "' onclick=\"setMealTaken('" + item.patientMealUid  + "','ok');\"></td>");
            }
            out.write("<td onclick='getPatientMeal(\"" + item.getUid() + "\",true,\""+item.patientMealUid+"\")'><strong>" + HTMLEntities.htmlentities(new SimpleDateFormat("HH:mm").format(item.mealDatetime)) + "</strong></td>");
            out.write("<td onclick='getPatientMeal(\"" + item.getUid() + "\",true,\""+item.patientMealUid+"\")'>" + HTMLEntities.htmlentities(item.name) + "</td>");
            out.write("</tr>");
            i++;
        }%>
</table>
<%}
    out.write("<div class='resultsDisplay'>" + lMeals.size() + " " + HTMLEntities.htmlentities(getTran("web", "recordsfound", sWebLanguage)) + "</div>");%>

