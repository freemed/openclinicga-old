<%@ page import="be.mxs.common.util.system.HTMLEntities" %>
<%@ page import="java.util.*" %>
<%@ page import="be.openclinic.meals.Meal" %>
<%@ page import="be.openclinic.meals.MealProfil" %>
<%@include file="/includes/validateUser.jsp" %>
<%
    String sFindProfileMealName = checkString(request.getParameter("FindProfileMealName"));
    boolean bWithSearch = checkString(request.getParameter("withSearchFields")).trim().length() > 0;
    MealProfil profil = new MealProfil(sFindProfileMealName);
    List lMeals = MealProfil.getMeals(sFindProfileMealName);

    // IF TO SHOW SERACH FIELDS
    if (bWithSearch) {%><%-- SEARCH RESULTS --%>
<table width="100%" align="center" class='sortable' cellspacing="0">
    <%-- HEADER --%>
    <tr class="gray">
        <td width="98%"><%=HTMLEntities.htmlentities(getTranNoLink("meals", "mealprofil", sWebLanguage))%>
        </td>
    </tr>
    <%Iterator it = lMeals.iterator();
        int i = 0;
        while (it.hasNext()) {
            profil = (MealProfil) it.next();
            String sClass = ((i % 2) == 0) ? "list" : "list1";
            out.write("<tr onmouseover=\"this.className='list_select hand';\" onmouseout=\"this.className='" + sClass + "';\" class='" + sClass + "' >");
            out.write("<td onclick='getPatientMealProfile(\"" + profil.getUid() + "\")'>" + HTMLEntities.htmlentities(profil.name) + "</td>");
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
            profil = (MealProfil) it.next();
            String sClass = ((i % 2) == 0) ? "list" : "list1";
            out.write("<tr onmouseover=\"this.className='list_select hand';\" onmouseout=\"this.className='" + sClass + "';\" class='" + sClass + "' >");
            out.write(" <td align='center'><img src='" + sCONTEXTPATH + "/_img/icon_delete.png' class='link' title='" + (getTranNoLink("web", "delete", sWebLanguage)) + "' onclick=\"deleteMealProfile('" + profil.getUid() + "');\"></td>");
            out.write("<td onclick='openMealProfile(\"" + profil.getUid() + "\")'>" + HTMLEntities.htmlentities(profil.name) + "</td>");
            out.write("</tr>");
            i++;
        }%>
</table>
<%
        out.write("<div class='resultsDisplay'>" + lMeals.size() + " " + HTMLEntities.htmlentities(getTran("web", "recordsfound", sWebLanguage)) + "</div>");
    }%>