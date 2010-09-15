<%@ page import="be.mxs.common.util.system.HTMLEntities" %>
<%@ page import="java.util.*" %>
<%@ page import="be.openclinic.meals.MealItem" %>
<%@ page import="be.openclinic.meals.NutricientItem" %>
<%@include file="/includes/validateUser.jsp" %>
<%
    String sAction = checkString(request.getParameter("action"));
    String sMealItemId = checkString(request.getParameter("mealItemId"));
    String sMealItemUnit = checkString(request.getParameter("mealItemUnit"));
    String sMealItemDescription = checkString(request.getParameter("mealItemDescription"));
    String sMealItemName = checkString(request.getParameter("mealItemName"));
    String sNutricientitems = checkString(request.getParameter("nutricientItems"));
        
    MealItem item = new MealItem(sMealItemId);
    if (sNutricientitems.trim().length() > 0) {
        item.nutricientItems = new LinkedList();
        NutricientItem nutricientItem = null;
        String[] nutricientItems = sNutricientitems.split(",");
        for (int i = 0; i < nutricientItems.length; i++) {
            String[] values = nutricientItems[i].split("-");
            nutricientItem = new NutricientItem(values[0]);
            nutricientItem.quantity = Float.parseFloat(values[1]);
            item.nutricientItems.add(nutricientItem);
        }
    }
    if (sAction.equals("save")) {
        item.name = sMealItemName;
        item.unit = sMealItemUnit;
        item.description = sMealItemDescription;
        item.updateOrInsert(activeUser.userid);
        out.write("<script>closeModalbox();refreshMealItems();</script>");
    } else if (sAction.equals("delete")) {
        item.delete();
        out.write("<script>closeModalbox();refreshMealItems();</script>");
    }
    %>