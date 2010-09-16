<%@ page import="be.mxs.common.util.system.HTMLEntities" %>
<%@ page import="java.util.*" %>
<%@ page import="be.openclinic.meals.Meal" %>
<%@ page import="be.openclinic.meals.MealItem" %>
<%@include file="/includes/validateUser.jsp" %>
<%
    boolean sTaken = checkString(request.getParameter("taken")).equals("ok");
    String sPatientMealId = checkString(request.getParameter("mealId"));

    Meal meal = new Meal(sPatientMealId);
    meal.patientMealUid = sPatientMealId;
    meal.updateMealTaken(activeUser.userid,sTaken);
    out.write("<script>refreshPatientMeals();</script>");
%>
