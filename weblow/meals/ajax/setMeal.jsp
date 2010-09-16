<%@ page import="be.mxs.common.util.system.HTMLEntities" %>
<%@ page import="java.util.*" %>
<%@ page import="be.openclinic.meals.Meal" %>
<%@ page import="be.openclinic.meals.MealItem" %>
<%@include file="/includes/validateUser.jsp" %>
<%String sAction = checkString(request.getParameter("action"));
    String sMealId = checkString(request.getParameter("mealId"));
    String sMealName = checkString(request.getParameter("mealName"));
    String sMealmealsitems = checkString(request.getParameter("mealmealsitems"));
    Meal meal = new Meal(sMealId);
    if (sMealmealsitems.trim().length() > 0) {
        meal.mealItems = new LinkedList();
        MealItem mealitem = null;
        String[] mealitems = sMealmealsitems.split(",");
        for (int i = 0; i < mealitems.length; i++) {
            String[] values = mealitems[i].split("-");
            mealitem = new MealItem(values[0]);
            mealitem.quantity = Float.parseFloat(values[1]);
            meal.mealItems.add(mealitem);
        }
    }
    if (sAction.equals("save")) {
        meal.name = sMealName;
        meal.updateOrInsert(activeUser.userid);
        out.write("<script>closeModalbox();refreshMeals();</script>");
    } else if (sAction.equals("delete")) {
        meal.delete();
        out.write("<script>closeModalbox();refreshMeals();</script>");
    }

%>
