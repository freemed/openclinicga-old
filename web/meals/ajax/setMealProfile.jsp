<%@ page import="be.mxs.common.util.system.HTMLEntities" %>
<%@ page import="java.util.*" %>
<%@ page import="be.openclinic.meals.Meal" %>
<%@ page import="be.openclinic.meals.MealItem" %>
<%@ page import="be.openclinic.meals.MealProfil" %>
<%@ page import="java.util.Date" %>
<%@include file="/includes/validateUser.jsp" %>
<%
    String sAction = checkString(request.getParameter("action"));
    String sMealId = checkString(request.getParameter("mealProfileId"));
    String sMealprofileName = checkString(request.getParameter("mealprofileName"));
    String sMealProfileitems = checkString(request.getParameter("mealProfileitems"));
    
    List meals = new LinkedList();
    MealProfil mealProfil = new MealProfil(sMealId);
    if (sMealProfileitems.trim().length() > 0) {
        String[] mealitems = sMealProfileitems.split(",");
        for (int i = 0; i < mealitems.length; i++) {
            String[] values = mealitems[i].split("-");
            mealProfil = new MealProfil(sMealId);
            mealProfil.name = sMealprofileName;
            mealProfil.mealUid = values[0];
            mealProfil.mealDatetime = new Date();
            mealProfil.mealDatetime.setHours(Integer.parseInt(values[1]));
            mealProfil.mealDatetime.setMinutes(Integer.parseInt(values[2]));
            meals.add(mealProfil);
        }
    }
    if (sAction.equals("save")) {
        if (meals.size() > 0) {
            mealProfil.updateOrInsert(meals, activeUser.userid);
            out.write("<script>closeModalbox();refreshMealsProfils();</script>");
        } else {
            out.write("<script>alert('must choose meals');</script>");
        }
    } else if (sAction.equals("delete")) {
        MealProfil.delete(sMealId);
        out.write("<script>closeModalbox();refreshMealsProfils();</script>");
    }

%>
