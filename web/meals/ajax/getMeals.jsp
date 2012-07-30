<%@ page import="be.mxs.common.util.system.HTMLEntities" %>
<%@ page import="java.util.*" %>
<%@ page import="be.openclinic.meals.Meal" %>
<%@include file="/includes/validateUser.jsp" %>
<%
    String sFindMealName = checkString(request.getParameter("FindMealName"));
    boolean bWithSearch = checkString(request.getParameter("withSearchFields")).trim().length() > 0;
    boolean bToMakeProfile = checkString(request.getParameter("toMakeProfile")).trim().length() > 0;
    Meal item = new Meal();
    item.name = sFindMealName;
    List lMeals = Meal.getList(item);
    // IF TO SHOW SERACH FIELDS
    if (bWithSearch) {%>
<div id="mealsSearchDiv">
<table width="100%" cellspacing="1" onKeyDown='if(event.keyCode==13){searchMealsWindow();return false;}'>
    <tr>
        <td class="admin" width="<%=sTDAdminWidth%>"><%=getTran("meals", "mealName", sWebLanguage)%>
        </td>
        <td class="admin2">
            <input type="text" class="text search" name="FindMealName" id="FindMealNameWindow" size="30" maxLength="100"> &nbsp;<input type="button" class="button" name="searchButton" value="<%=getTranNoLink("Web","search",sWebLanguage)%>" onclick="searchMealsWindow(bToMakeProfile);">
        </td>
    </tr>
</table>
<%-- SEARCH RESULTS --%>
<table width="100%" align="center" class='sortable' cellspacing="0">
    <%-- HEADER --%>
    <tr class="gray">
        <td width="98%"><%=HTMLEntities.htmlentities(getTranNoLink("meals", "mealName", sWebLanguage))%>
        </td>
    </tr>
    <%Iterator it = lMeals.iterator();
        int i = 0;
        while (it.hasNext()) {
            item = (Meal) it.next();
            String sClass = ((i % 2) == 0) ? "list" : "list1";
            out.write("<tr  class='" + sClass + "' >");
            if (bToMakeProfile) {
                out.write("<td onclick='insertMealIntoProfile(\"" + item.getUid() + "\",\"" + HTMLEntities.htmlentities(item.name) + "\"," + item.mealDatetime.getHours() + "," + item.mealDatetime.getMinutes() + ")'>" + HTMLEntities.htmlentities(item.name) + "</td>");
            } else {
                out.write("<td onclick='getPatientMeal(\"" + item.getUid() + "\",null,null)'>" + HTMLEntities.htmlentities(item.name) + "</td>");
            }
            out.write("</tr>");
            i++;
        }%>
</table>
<%="<div class='resultsDisplay'>" + lMeals.size() + " " + HTMLEntities.htmlentities(getTran("web", "recordsfound", sWebLanguage)) + "</div>"%>
<div class="clear">&nbsp;</div>
<input type="button" class="button" name="backButton" value="<%=getTranNoLink("Web","back",sWebLanguage)%>" onclick="closeModalbox()">
<script>
    Modalbox.resizeToContent();
</script>
    </div>
<%} else {
    //------------------- END IF TO SHOW SERACH FIELDS -----------//
    //-------------------  IF TO SHOW NORMAL PAGE -----------//%><%-- SEARCH RESULTS --%>
<table width="100%" align="center" class='sortable' cellspacing="0">
    <%-- HEADER --%>
    <tr class="gray">
        <td width="2%">&nbsp;</td>
        <td width="98%"><%=HTMLEntities.htmlentities(getTranNoLink("meals", "mealName", sWebLanguage))%>
        </td>
    </tr>
    <%Iterator it = lMeals.iterator();
        int i = 0;
        while (it.hasNext()) {
            item = (Meal) it.next();
            String sClass = ((i % 2) == 0) ? "list" : "list1";
            out.write("<tr  class='" + sClass + "' >");
            out.write(" <td align='center'><img src='" + sCONTEXTPATH + "/_img/icon_delete.png' class='link' title='" + (getTranNoLink("web", "delete", sWebLanguage)) + "' onclick=\"deleteMeal('" + item.getUid() + "');\"></td>");
            out.write("<td onclick='openMeal(\"" + item.getUid() + "\")'>" + HTMLEntities.htmlentities(item.name) + "</td>");
            out.write("</tr>");
            i++;
        }%>
</table>
<%
        out.write("<div class='resultsDisplay'>" + lMeals.size() + " " + HTMLEntities.htmlentities(getTran("web", "recordsfound", sWebLanguage)) + "</div>");
    }%>