<%@ page import="be.mxs.common.util.system.HTMLEntities" %>
<%@ page import="java.util.*" %>
<%@ page import="be.openclinic.meals.Meal" %>
<%@ page import="be.openclinic.meals.MealItem" %>
<%@ page import="java.util.Date" %>
<%@include file="/includes/validateUser.jsp" %>
<%
    SimpleDateFormat simple = new SimpleDateFormat("dd/MM/yyyy HH:mm");
    String sMealId = checkString(request.getParameter("mealId"));
    String sPatientMealId = checkString(request.getParameter("patientmealId"));
    String sFindMealByDay = checkString(request.getParameter("FindMealByDay"));
    Meal item = new Meal(sMealId);
    int hour = 7;
    int min = 0;
    Meal tmpmeal = null;
    if (sMealId.length() > 0 && !sMealId.equals("-1")) {
        item = Meal.get(item);
        List l = Meal.getPatientMeals(activePatient, sFindMealByDay, item);
        if (l.size() > 0) {
            tmpmeal = ((Meal) l.get(0));
            hour = tmpmeal.mealDatetime.getHours();
            min = tmpmeal.mealDatetime.getMinutes();
            item.taken = tmpmeal.taken;
        }
    }
%>
<table cellspacing="1" cellpadding="1" style="width:515px" onKeyDown='if(event.keyCode==13){closeModalbox();return false;}'>
    <tr>
        <td class="admin" width="250px"><%=HTMLEntities.htmlentities(getTran("meals", "mealName", sWebLanguage))%>
        </td>
        <td class="admin2">
            <%=checkString(HTMLEntities.htmlentities(item.name))%>
        </td>
    </tr>
    <tr>
        <td class="admin" width="250px"><%=HTMLEntities.htmlentities(getTran("meals", "mealTime", sWebLanguage))%>
        </td>
        <td class="admin2">
            <%-- hour --%> <select style="width:40px;padding:2px;height:auto;" id="mealHour" class="text">
            <%
                for (int n = 0; n <= 23; n++) {
                    out.print("<option value='" + (n < 10 ? "0" + n : "" + n) + "' ");
                    if (n == hour) {
                        out.print("selected");
                    }
                    out.print(">" + (n < 10 ? "0" + n : "" + n) + "</option>");
                }
            %>
        </select>: <%-- minutes --%> <select style="width:40px;padding:2px;height:auto;" id="mealMin" class="text">
            <%
                for (int n = 0; n < 60; n = n + 5) {
                    out.print("<option value='" + (n < 10 ? "0" + n : "" + n) + "' ");
                    if (n == min) {
                        out.print("selected");
                    }
                    out.print(">" + (n < 10 ? "0" + n : "" + n) + "</option>");
                }
            %>
        </select>&nbsp;<%=HTMLEntities.htmlentities(getTran("hrm", "uur", sWebLanguage))%>&nbsp;
        </td>
    </tr>
    <tr>
        <td class="admin"><%=HTMLEntities.htmlentities(getTran("meals", "mealItems", sWebLanguage))%>
        </td>
        <td class="admin2">
            <ul id="mealmealsitems" class="items" style="width:370px">
                <%Iterator it = item.mealItems.iterator();
                    while (it.hasNext()) {
                        MealItem mealitem = (MealItem) it.next();
                        out.write("<li id='mealmealsitem_" + mealitem.getUid() + "'><div style='width:190px'>" + mealitem.name + "</div><div style='width:150px;border-left:1px solid #C3D9FF;padding-left:5px'><input type='hidden' id='mealmealsitemqt_" + mealitem.getUid() + "' value='" + mealitem.quantity + "' />" + mealitem.quantity + " " + HTMLEntities.htmlentities(mealitem.unit) + "</div></li>");
                    }%>
            </ul>
        </td>
    </tr>
    <tr>
        <td class="admin" width="<%=sTDAdminWidth%>"><%=HTMLEntities.htmlentities(getTran("meals", "mealtaken", sWebLanguage))%>
        </td>
        <td class="admin2">
            <input type="radio" id="mealtakenyes" name="mealtaken" value="1" <%=(item.taken ? "checked=true" : "")%>/><label for="mealtakenyes"><%=getTran("web", "yes", sWebLanguage)%>
        </label>
            <input type="radio" id="mealtakenno" name="mealtaken" value="0" <%=(!item.taken ? "checked=true" : "")%>/><label for="mealtakenno"><%=getTran("web", "no", sWebLanguage)%>
        </label>
        </td>
    </tr>
    <tr>
        <td class="admin"><%=HTMLEntities.htmlentities(getTran("meals", "mealnutricients", sWebLanguage))%>
        </td>
        <td class="admin2">
            <a href="javascript:void(0)" id="mealnutricientsbutton" class="link down" onclick="getNutricientsIntoMeal('<%=item.getUid()%>',false);"><span><%=getTranNoLink("meals", "seemealnutricients", sWebLanguage).toLowerCase()%></span></a>
            <ul id="mealNutricientsList" class="items" style="width:370px"></ul>
        </td>
    </tr>
    <tr>
        <td class="admin">&nbsp;
        </td>
        <td class="admin2">
            <input type="hidden" id="patientMealId" value="<%=sPatientMealId%>">
            <input class="button" type="button" name="SaveButton" id="SaveButton" value="<%=HTMLEntities.htmlentities(getTranNoLink("web","Save",sWebLanguage))%>" onclick="setPatientMeal('<%=item.getUid()%>');"> &nbsp;
            <input <%=(item.getUid().equalsIgnoreCase("-1")?"type=\"hidden\"":"type=\"button\"")%> class="button" name="SaveButton" id="deleteButton" value="<%=HTMLEntities.htmlentities(getTranNoLink("web","delete",sWebLanguage))%>" onclick="deleteMealFromPatient('<%=item.getUid()%>');">
            <input class="button" type="button" name="closeButton" id="closeButton" value="<%=HTMLEntities.htmlentities(getTranNoLink("web","back",sWebLanguage))%>" onclick="closeModalbox();">
        </td>
    </tr>
</table>


