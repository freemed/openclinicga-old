<%@page import="be.mxs.common.util.system.HTMLEntities,
                be.openclinic.meals.MealItem,
                be.openclinic.meals.Meal,
                java.util.*"%>
<%@include file="/includes/validateUser.jsp"%>

<%
    String sAction = checkString(request.getParameter("action"));

    String sMealId    = checkString(request.getParameter("mealId")),
           sMealName  = checkString(request.getParameter("mealName")),
           sMealItems = checkString(request.getParameter("mealItems"));

    /// DEBUG /////////////////////////////////////////////////////////////////////////////////////
    if(Debug.enabled){
    	Debug.println("\n************************* meals/ajax/setMeal.jsp **********************");
    	Debug.println("sAction    : "+sAction);
    	Debug.println("sMealId    : "+sMealId);
    	Debug.println("sMealName  : "+sMealName);
    	Debug.println("sMealItems : "+sMealItems+"\n");
    }
    ///////////////////////////////////////////////////////////////////////////////////////////////
    
    
    Meal meal = new Meal(sMealId);
    if(sMealItems.length() > 0){
        meal.mealItems = new LinkedList();
        MealItem mealitem = null;
        
        String[] mealitems = sMealItems.split(",");
        for(int i=0; i<mealitems.length; i++){
            String[] values = mealitems[i].split("-");
            mealitem = new MealItem(values[0]);
            mealitem.quantity = Float.parseFloat(values[1].replace(",","."));
            
            meal.mealItems.add(mealitem);
        }
    }
    
    if(sAction.equals("save")){
        meal.name = sMealName;
        meal.updateOrInsert(activeUser.userid);
    }
    else if(sAction.equals("delete")){
        meal.delete();
    }
    
    out.write("<script>closeModalbox();searchMeals();</script>");
%>