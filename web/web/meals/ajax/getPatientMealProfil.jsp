<%@ page import="be.mxs.common.util.system.HTMLEntities" %>
<%@ page import="java.util.*" %>
<%@ page import="be.openclinic.meals.Meal" %>
<%@ page import="be.openclinic.meals.MealItem" %>
<%@ page import="be.openclinic.meals.MealProfil" %>
<%@ page import="java.util.Date" %>
<%@include file="/includes/validateUser.jsp" %>
<%!
    public String getHoursField(String id, Date _date, String sWebLanguage) {
    String sOut = ((_date.getHours() < 10) ? "0" + _date.getHours() : "" + _date.getHours()) + "&nbsp;:&nbsp;" + ((_date.getMinutes() < 10) ? "0" + _date.getMinutes() : "" + _date.getMinutes());
    return sOut + "&nbsp;" + getTran("hrm", "uur", sWebLanguage);
}%><%
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
                <b><%=checkString(HTMLEntities.htmlentities(item.name))%>
                </b>
            </td>
        </tr>
        <tr>
            <td class="admin"><%=HTMLEntities.htmlentities(getTran("meals", "mealProfileItems", sWebLanguage))%>
            </td>
            <td class="admin2">
                <ul id="mealProfileitems" class="items" style="width:370px">
                    <%Iterator it = mealProfiles.iterator();
                        while (it.hasNext()) {
                            MealProfil profil = (MealProfil) it.next();
                            out.write("<li id='meal_" + profil.mealUid + "'><div style='width:200px'>" + HTMLEntities.htmlentities(profil.mealName) + "</div><div style='width:160px'>" + getHoursField(profil.mealUid, profil.mealDatetime, sWebLanguage) + "</div></li>");
                        }%>
                </ul>
            </td>
        </tr>
         <tr>
            <td class="admin"><%=HTMLEntities.htmlentities(getTran("meals", "nutricients", sWebLanguage))%>
            </td>
            <td class="admin2">
                <a href="javascript:void(0)" id="mealnutricientsbutton" class="link down" onclick="getNutricientsIntoProfile('<%=item.getUid()%>',false);"><span><%=getTranNoLink("meals", "seenutricients", sWebLanguage).toLowerCase()%></span></a> 
                <ul id="mealprofileNutricientsList" class="items" style="width:370px"></ul>
            </td>
        </tr>
        <tr>
            <td class="admin">&nbsp;
            </td>
            <td class="admin2">
                <input class="button" type="button" name="SaveButton" id="SaveButton" value="<%=HTMLEntities.htmlentities(getTranNoLink("web","Save",sWebLanguage))%>" onclick="setPatientProfil('<%=item.getUid()%>');"> &nbsp;<input class="button" type="button" name="closeButton" id="closeButton" value="<%=HTMLEntities.htmlentities(getTranNoLink("web","close",sWebLanguage))%>" onclick="closeModalbox();">
                <input type="hidden" id="mealProfileId" value="<%=checkString(item.getUid())%>"/>
            </td>
        </tr>
    </table>
</div>
<div id="mealItemsList" style="width:500px">&nbsp;</div>