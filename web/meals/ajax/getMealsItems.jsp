<%@ page import="be.mxs.common.util.system.HTMLEntities" %>
<%@ page import="java.util.*" %>
<%@ page import="be.openclinic.meals.MealItem" %>
<%@include file="/includes/validateUser.jsp" %>
<%
    String sFindMealName = checkString(request.getParameter("FindMealItemName"));
    String sFindMealDescription = checkString(request.getParameter("FindMealItemDescription"));
    boolean bWithSearch = checkString(request.getParameter("withSearchFields")).trim().length() > 0;
    MealItem item = new MealItem();
    item.name = sFindMealName;
    item.description = sFindMealDescription;
    List lMealsitems = MealItem.getList(item);

    // IF TO SHOW SERACH FIELDS
    if (bWithSearch) {%>
<table width="100%" cellspacing="1" class="list" onKeyDown='if(event.keyCode==13){searchMealItemsWindow();return false;}'>
    <tr>
        <td class="admin" width="<%=sTDAdminWidth%>">
            <%=HTMLEntities.htmlentities(getTran("meals", "mealItemName", sWebLanguage))%>
        </td>
        <td class="admin2">
            <input type="text" class="text search" id="FindMealItemName" maxLength="255" value="<%=HTMLEntities.htmlentities(sFindMealName)%>"/>
    </tr>
    <tr>
        <td class="admin" width="<%=sTDAdminWidth%>">
            <%=HTMLEntities.htmlentities(getTran("meals", "mealItemDescription", sWebLanguage))%>
        </td>
        <td class="admin2">
            <input type="text" class="text search" id="FindMealItemDescription" maxLength="100" value="<%=HTMLEntities.htmlentities(sFindMealDescription)%>"/> &nbsp;&nbsp;<input type="button" class="button" name="searchButton" value="<%=getTranNoLink("Web","search",sWebLanguage)%>" onclick="searchMealItemsWindow();">
        </td>
    </tr>
</table>
<script>
    searchMealItemsWindow = function() {
        var id = "mealItemsList";
        var params = "FindMealItemName=" + $F("FindMealItemName") + "&FindMealItemDescription=" + $F("FindMealItemDescription") + "&withSearchFields=1";
        var url = "<c:url value="/meals/ajax/getMealsItems.jsp" />?ts=" + new Date().getTime();
        new Ajax.Updater(id, url,
        {   parameters:params,
            evalScripts: true

        });
        $(id).update("<div id='wait'>&nbsp;</div>");
    }
</script>
<%-- SEARCH RESULTS --%>
<table width="100%" align="center" class='sortable' cellspacing="0">
    <%-- HEADER --%>
    <tr class="gray">
        <td width="24%"><%=HTMLEntities.htmlentities(getTranNoLink("meals", "mealItemName", sWebLanguage))%>
        </td>
        <td width="25%"><%=HTMLEntities.htmlentities(getTranNoLink("meals", "mealItemUnit", sWebLanguage))%>
        </td>
        <td width="25%"><%=HTMLEntities.htmlentities(getTranNoLink("meals", "mealItemDescription", sWebLanguage))%>
        </td>
    </tr>
    <%Iterator it = lMealsitems.iterator();
        int i = 0;
        while (it.hasNext()) {
            item = (MealItem) it.next();
            String sClass = ((i % 2) == 0) ? "list" : "list1";
            out.write("<tr onclick='insertMealItem(\"" + item.getUid() + "\",\"" + HTMLEntities.htmlQuotes(HTMLEntities.htmlentities(item.name)) + "\",\"" + HTMLEntities.htmlQuotes(HTMLEntities.htmlentities(item.unit)) + "\")' onmouseover=\"this.className='list_select hand';\" onmouseout=\"this.className='" + sClass + "';\" class='" + sClass + "' >");
            out.write("<td >" + HTMLEntities.htmlentities(item.name) + "</td>");
            out.write("<td >" + HTMLEntities.htmlentities(item.unit) + "</td>");
            out.write("<td >" + HTMLEntities.htmlentities(item.description) + "</td>");
            out.write("</tr>");
            i++;
        }%>
</table>
<%="<div class='resultsDisplay'>" + lMealsitems.size() + " " + HTMLEntities.htmlentities(getTran("web", "recordsfound", sWebLanguage)) + "</div>"%>
<div class="clear">&nbsp;</div>
<input type="button" class="button" name="backButton" value="<%=getTranNoLink("Web","back",sWebLanguage)%>" onclick="openBackMeal();">
<script>
    Modalbox.resizeToContent();
</script>
<%} else {
    //------------------- END IF TO SHOW SERACH FIELDS -----------//
    //-------------------  IF TO SHOW NORMAL PAGE -----------//%><%-- SEARCH RESULTS PAGE--%>
<table width="100%" align="center" class='sortable' cellspacing="0">
    <%-- HEADER --%>
    <tr class="gray">
        <td width="2%">&nbsp;</td>
        <td width="24%"><%=HTMLEntities.htmlentities(getTranNoLink("meals", "mealItemName", sWebLanguage))%>
        </td>
        <td width="25%"><%=HTMLEntities.htmlentities(getTranNoLink("meals", "mealItemUnit", sWebLanguage))%>
        </td>
        <td width="25%"><%=HTMLEntities.htmlentities(getTranNoLink("meals", "mealItemDescription", sWebLanguage))%>
        </td>
    </tr>
    <%Iterator it = lMealsitems.iterator();
        int i = 0;
        while (it.hasNext()) {
            item = (MealItem) it.next();
            String sClass = ((i % 2) == 0) ? "list" : "list1";
            out.write("<tr onmouseover=\"this.className='list_select hand';\" onmouseout=\"this.className='" + sClass + "';\" class='" + sClass + "' >");
            out.write(" <td align='center'><img src='" + sCONTEXTPATH + "/_img/icon_delete.png' class='link' title='" + (getTranNoLink("web", "delete", sWebLanguage)) + "' onclick=\"deleteMealItem('" + item.getUid() + "');\"></td>");
            out.write("<td onclick='openMealItem(\"" + item.getUid() + "\")'>" + HTMLEntities.htmlentities(item.name) + "</td>");
            out.write("<td onclick='openMealItem(\"" + item.getUid() + "\")'>" + HTMLEntities.htmlentities(item.unit) + "</td>");
            out.write("<td onclick='openMealItem(\"" + item.getUid() + "\")'>" + HTMLEntities.htmlentities(item.description) + "</td>");
            out.write("</tr>");
            i++;
        }%>
</table>
<%="<div class='resultsDisplay'>" + lMealsitems.size() + " " + HTMLEntities.htmlentities(getTran("web", "recordsfound", sWebLanguage)) + "</div>"%><%}%>

