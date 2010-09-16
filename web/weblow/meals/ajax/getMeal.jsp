<%@ page import="be.mxs.common.util.system.HTMLEntities" %>
<%@ page import="java.util.*" %>
<%@ page import="be.openclinic.meals.Meal" %>
<%@ page import="be.openclinic.meals.MealItem" %>
<%@include file="/includes/validateUser.jsp" %>
<%
    String sMealId = checkString(request.getParameter("mealId"));
    Meal item = new Meal(sMealId);
    if (sMealId.length() > 0 && !sMealId.equals("-1")) {
        item = Meal.get(item);
    }
%>
<div id="mealEdit" style="width:515px">
    <table cellspacing="1" cellpadding="1" style="width:515px" onKeyDown='if(event.keyCode==13){setMeal();return false;}'>
        <tr>
            <td class="admin" width="150px"><%=HTMLEntities.htmlentities(getTran("meals", "mealName", sWebLanguage))%>
            </td>
            <td class="admin2">
                <input class="text" style="width:200px" type="text" id="mealName" value="<%=checkString(HTMLEntities.htmlentities(item.name))%>"/>
            </td>
        </tr>
        <tr>
            <td class="admin"><%=HTMLEntities.htmlentities(getTran("meals", "mealItems", sWebLanguage))%>
            </td>
            <td class="admin2">
                <a href="javascript:void(0)" class="link add" onclick="searchMealItem();"><span><%=HTMLEntities.htmlentities(getTranNoLink("web", "add", sWebLanguage) + " " + getTranNoLink("meals", "mealItem", sWebLanguage).toLowerCase())%></span></a>
                <br/>
                <ul id="mealmealsitems" class="items" style="width:370px">
                    <%Iterator it = item.mealItems.iterator();
                        while (it.hasNext()) {
                            MealItem mealitem = (MealItem) it.next();
                            out.write("<li id='mealmealsitem_" + mealitem.getUid() + "'><div style='width:190px'>" + mealitem.name + "</div><div style='width:150px'><input type='text' size='7' id='mealmealsitemqt_" + mealitem.getUid() + "' value='" + mealitem.quantity + "'/> " + HTMLEntities.htmlentities(mealitem.unit) + "</div><div style='width:20px'><img src='" + sCONTEXTPATH + "/_img/icon_delete.png' class='link' title='" + (getTranNoLink("web", "delete", sWebLanguage)) + "' onclick='removeMealItem(\"" + mealitem.getUid() + "\");'></div></li>");
                        }%>
                </ul>
            </td>
        </tr>
        <tr>
            <td class="admin"><%=HTMLEntities.htmlentities(getTran("meals", "mealnutricients", sWebLanguage))%>
            </td>
            <td class="admin2">
                <a href="javascript:void(0)" id="mealnutricientsbutton" class="link down" onclick="getNutricientsIntoMeal('<%=item.getUid()%>',false);"><span><%=getTranNoLink("meals", "seemealnutricients", sWebLanguage).toLowerCase()%></span></a> &nbsp;&nbsp;&nbsp;<a href="javascript:void(0)" id="mealnutricientsrefresh" class="link reload" style="display:none;" onclick="getNutricientsIntoMeal('<%=item.getUid()%>',true);"><span><%=getTranNoLink("meals", "reloadmealnutricients", sWebLanguage).toLowerCase()%></span></a>
                <ul id="mealNutricientsList" class="items" style="width:370px"></ul>
            </td>
        </tr>
        <tr>
            <td class="admin">&nbsp;
            </td>
            <td class="admin2">
                <input class="button" type="button" name="SaveButton" id="SaveButton" value="<%=HTMLEntities.htmlentities(getTranNoLink("web","Save",sWebLanguage))%>" onclick="setMeal();"> &nbsp;<input <%=(item.getUid().equalsIgnoreCase("-1")?"type=\"hidden\"":"type=\"button\"")%> class="button" name="SaveButton" id="deleteButton" value="<%=HTMLEntities.htmlentities(getTranNoLink("web","delete",sWebLanguage))%>" onclick="deleteMeal('<%=item.getUid()%>');"> &nbsp;<input class="button" type="button" name="closeButton" id="closeButton" value="<%=HTMLEntities.htmlentities(getTranNoLink("web","close",sWebLanguage))%>" onclick="closeModalbox();">
                <input type="hidden" id="mealId" value="<%=checkString(item.getUid())%>"/>
            </td>
        </tr>
    </table>
</div>
<div id="mealItemsList" style="width:500px">&nbsp;</div>