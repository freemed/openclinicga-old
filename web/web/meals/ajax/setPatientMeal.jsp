<%@ page import="be.mxs.common.util.system.HTMLEntities" %>
<%@ page import="java.util.*" %>
<%@ page import="be.openclinic.meals.Meal" %>
<%@ page import="be.openclinic.meals.MealItem" %>
<%@ page import="java.util.Date" %>
<%@include file="/includes/validateUser.jsp" %>
<%
    String sAction = checkString(request.getParameter("action"));
    String sMealId = checkString(request.getParameter("mealId"));
    String sChoosedDate = checkString(request.getParameter("choosedDate"));
    String sPatientMeal = checkString(request.getParameter("patientMealId"));
    String sMealHour = checkString(request.getParameter("mealHour"));
    String sMealMin = checkString(request.getParameter("mealMin"));
    boolean bMealTaken = checkString(request.getParameter("mealtakenyes")).equals("true");



    Meal meal = new Meal(sMealId);
    meal.patientMealUid = sPatientMeal;
    if (sAction.equals("save")) {
        meal.insertOrUpdatePatientMeal(activePatient, sChoosedDate, (sMealHour + ":" + sMealMin), activeUser.userid, bMealTaken,null);
        out.write("<script>closeModalbox();refreshPatientMeals();</script>");
    } else if (sAction.equals("delete")) {
        meal.patientMealUid = sPatientMeal;
        meal.deleteMealFromPatient();
        out.write("<script>closeModalbox();refreshPatientMeals();</script>");
    }
%>
