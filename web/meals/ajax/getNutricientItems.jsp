<%@ page import="be.mxs.common.util.system.HTMLEntities" %>
<%@ page import="java.util.*" %>
<%@ page import="be.openclinic.meals.NutricientItem" %>
<%@include file="/includes/validateUser.jsp" %>
<%
    String sFindMealName = checkString(request.getParameter("FindNutricientName"));
    String sFindNutricientNameWindow = checkString(request.getParameter("FindNutricientNameWindow"));
    boolean bWithSearch = checkString(request.getParameter("withSearchFields")).trim().length() > 0;
    if (bWithSearch) {
        sFindMealName = sFindNutricientNameWindow;
    }
    NutricientItem item = new NutricientItem();
    item.name = sFindMealName;
    List lnutricientsitems = NutricientItem.getList(item);
    // IF TO SHOW SERACH FIELDS
    if (bWithSearch) {%>
<table width="100%" cellspacing="1" class="list" onKeyDown='if(event.keyCode==13){searchNutricientItemsWindow();return false;}'>
    <tr>
        <td class="admin" width="<%=sTDAdminWidth%>">
            <%=getTran("meals", "nutricientItemName", sWebLanguage)%>
        </td>
        <td class="admin2">
            <input type="text" class="text search" id="FindNutricientNameWindow" name="FindNutricientNameWindow" size="170" maxLength="255" style="width:170px"> &nbsp;&nbsp;<input type="button" class="button" name="searchButton" value="<%=getTranNoLink("Web","search",sWebLanguage)%>" onclick="searchNutricientItemsWindow();"> 
        </td>
    </tr>
</table>
<%-- SEARCH RESULTS --%>
<table width="100%" align="center" class='sortable' cellspacing="0">
    <%-- HEADER --%>
    <tr class="gray">
        <td width="24%"><%=HTMLEntities.htmlentities(getTranNoLink("meals", "nutricientItemName", sWebLanguage))%>
        </td>
        <td width="25%"><%=HTMLEntities.htmlentities(getTranNoLink("meals", "nutricientItemUnit", sWebLanguage))%>
        </td>
    </tr>
    <%Iterator it = lnutricientsitems.iterator();
        int i = 0;
        while (it.hasNext()) {
            item = (NutricientItem) it.next();
            String sClass = ((i % 2) == 0) ? "list" : "list1";
            out.write("<tr onclick='insertNutricientItem(\"" + item.getUid() + "\",\"" + HTMLEntities.htmlQuotes(HTMLEntities.htmlentities(item.name)) + "\",\"" + HTMLEntities.htmlQuotes(HTMLEntities.htmlentities(item.unit)) + "\")'  class='" + sClass + "' >");
            out.write("<td>" + HTMLEntities.htmlentities(item.name) + "</td>");
            out.write("<td >" + HTMLEntities.htmlentities(item.unit) + "</td>");
            out.write("</tr>");
            i++;
        }%>
</table>
<%="<div class='resultsDisplay'>" + lnutricientsitems.size() + " " + HTMLEntities.htmlentities(getTran("web", "recordsfound", sWebLanguage)) + "</div>"%>
<div class="clear">&nbsp;</div>
<input type="button" class="button" name="backButton" value="<%=getTranNoLink("Web","back",sWebLanguage)%>" onclick="openBackMealItem();">
<script>
    Modalbox.resizeToContent();
</script>
<% } else { %><%-- SEARCH RESULTS --%>
<table width="100%" align="center" class='sortable' cellspacing="0">
    <%-- HEADER --%>
    <tr class="gray">
        <td width="2%">&nbsp;</td>
        <td width="24%"><%=HTMLEntities.htmlentities(getTranNoLink("meals", "nutricientItemName", sWebLanguage))%>
        </td>
        <td width="25%"><%=HTMLEntities.htmlentities(getTranNoLink("meals", "nutricientItemUnit", sWebLanguage))%>
        </td>
    </tr>
    <%Iterator it = lnutricientsitems.iterator();
        int i = 0;
        while (it.hasNext()) {
            item = (NutricientItem) it.next();
            String sClass = ((i % 2) == 0) ? "list" : "list1";
            out.write("<tr  class='" + sClass + "' >");
            out.write(" <td align='center'><img src='" + sCONTEXTPATH + "/_img/icon_delete.png' class='link' title='" + (getTranNoLink("web", "delete", sWebLanguage)) + "' onclick=\"deleteNutricientItem('" + item.getUid() + "');\"></td>");
            out.write("<td onclick='openNutricientItem(\"" + item.getUid() + "\")'>" + HTMLEntities.htmlentities(item.name) + "</td>");
            out.write("<td onclick='openNutricientItem(\"" + item.getUid() + "\")'>" + HTMLEntities.htmlentities(item.unit) + "</td>");
            out.write("</tr>");
            i++;
        }%>
</table>
<%="<div class='resultsDisplay'>" + lnutricientsitems.size() + " " + HTMLEntities.htmlentities(getTran("web", "recordsfound", sWebLanguage)) + "</div>"%><%} %>
