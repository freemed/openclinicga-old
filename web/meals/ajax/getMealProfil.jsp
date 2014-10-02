<%@ page import="be.mxs.common.util.system.HTMLEntities" %>
<%@ page import="java.util.*" %>
<%@ page import="be.openclinic.meals.Meal" %>
<%@ page import="be.openclinic.meals.MealItem" %>
<%@ page import="be.openclinic.meals.MealProfil" %>
<%@ page import="java.util.Date" %>
<%@include file="/includes/validateUser.jsp" %>
<%!
    public String getHoursField(String id, Date _date, String sWebLanguage) {
    String sOut = "<select id='mealHour_" + id + "' style='width:40px;height:auto' class='text'>";
    for (int i = 0; i <= 23; i++) {
        sOut += "<option value=" + i + " " + ((_date.getHours() == i) ? "selected=selected " : "") + ">" + ((i < 10) ? "0" + i : "" + i) + "</option>";
    }
    sOut += "</select>&nbsp;:&nbsp;<select id='mealMin_" + id + "' style='width:40px;height:auto' class='text'>";
    for (int i = 0; i <= 59; i += 5) {
        sOut += "<option value=" + i + " " + ((_date.getMinutes() == i) ? "selected=selected " : "") + ">" + ((i < 10) ? "0" + i : "" + i) + "</option>";
    }
    return sOut + "</select>&nbsp;" + getTran("hrm", "uur", sWebLanguage);
}
%><%
    String sMealProfileId = checkString(request.getParameter("mealProfileId"));
    MealProfil item = new MealProfil(sMealProfileId);
    List mealProfiles = item.getMealProfil();
    if (mealProfiles.size() > 0) {
        item.name = ((MealProfil) mealProfiles.get(0)).name;
    }
%>
<div id="mealEdit" style="width:500px">
    <table cellspacing="1" cellpadding="1" style="width:500px" onKeyDown='if(event.keyCode==13){setMeal();return false;}'>
        <tr>
            <td class="admin" width="<%=sTDAdminWidth%>"><%=HTMLEntities.htmlentities(getTran("meals", "mealName", sWebLanguage))%>
            </td>
            <td class="admin2">
                <input class="text" style="width:200px" type="text" id="mealprofileName" value="<%=checkString(HTMLEntities.htmlentities(item.name))%>"/>
            </td>
        </tr>
        <tr>
            <td class="admin"><%=HTMLEntities.htmlentities(getTran("meals", "mealProfileItems", sWebLanguage))%>
            </td>
            <td class="admin2">
                <a href="javascript:void(0)" class="link add" onclick="searchMeal();"><span><%=HTMLEntities.htmlentities(getTranNoLink("web", "add", sWebLanguage) + " " + getTranNoLink("meals", "meal", sWebLanguage).toLowerCase())%></span></a>
                <br/>
                <ul id="mealProfileitems" class="items" style="width:370px">
                    <%Iterator it = mealProfiles.iterator();
                        while (it.hasNext()) {
                            MealProfil profil = (MealProfil) it.next();
                            out.write("<li id='meal_" + profil.mealUid + "'><div style='width:180px'>" + HTMLEntities.htmlentities(profil.mealName) + "</div><div style='width:160px'>" + getHoursField(profil.mealUid, profil.mealDatetime, sWebLanguage) + "</div><div style='width:20px'><img src='" + sCONTEXTPATH + "/_img/icons/icon_delete.png' class='link' title='" + (getTranNoLink("web", "delete", sWebLanguage)) + "' onclick='removeMealfromProfil(\"" + profil.mealUid + "\");'></div></li>");
                        }%>
                </ul>
            </td>
        </tr>
         <tr>
            <td class="admin"><%=HTMLEntities.htmlentities(getTran("meals", "nutricients", sWebLanguage))%>
            </td>
            <td class="admin2">
                <a href="javascript:void(0)" id="mealnutricientsbutton" class="link down" onclick="getNutricientsIntoProfile('<%=item.getUid()%>',false);"><span><%=getTranNoLink("meals", "seenutricients", sWebLanguage).toLowerCase()%></span></a> &nbsp;&nbsp;&nbsp;<a href="javascript:void(0)" id="mealnutricientsrefresh" class="link reload" style="display:none;" onclick="getNutricientsIntoProfile('<%=item.getUid()%>',true);"><span><%=getTranNoLink("meals", "reloadmealnutricients", sWebLanguage).toLowerCase()%></span></a>
                <ul id="mealprofileNutricientsList" class="items" style="width:370px"></ul>
            </td>
        </tr>
        <tr>
            <td class="admin">&nbsp;
            </td>
            <td class="admin2">
                <input class="button" type="button" name="SaveButton" id="SaveButton" value="<%=HTMLEntities.htmlentities(getTranNoLink("web","Save",sWebLanguage))%>" onclick="setMealProfile();"> &nbsp;<input <%=(item.getUid().equalsIgnoreCase("-1")?"type=\"hidden\"":"type=\"button\"")%> class="button" name="SaveButton" id="deleteButton" value="<%=HTMLEntities.htmlentities(getTranNoLink("web","delete",sWebLanguage))%>" onclick="deleteMealProfile('<%=item.getUid()%>');"> &nbsp;<input class="button" type="button" name="closeButton" id="closeButton" value="<%=HTMLEntities.htmlentities(getTranNoLink("web","close",sWebLanguage))%>" onclick="closeModalbox();">
                <input type="hidden" id="mealProfileId" value="<%=checkString(item.getUid())%>"/>
            </td>
        </tr>
    </table>
</div>
<div id="mealItemsList" style="width:500px">&nbsp;</div>