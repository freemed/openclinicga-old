<%@page import="be.mxs.common.util.system.HTMLEntities,
                java.util.*,
                be.openclinic.meals.Meal,
                be.openclinic.meals.MealItem"%>
<%@include file="/includes/validateUser.jsp"%>

<%
    String sPatientMealId = checkString(request.getParameter("mealId"));

    boolean bMealTaken     = checkString(request.getParameter("taken")).equals("ok"),  
            bShowNutrients = checkString(request.getParameter("showNutrients")).equals("true");

    /// DEBUG /////////////////////////////////////////////////////////////////////////////////////
    if(Debug.enabled){
    	Debug.println("\n********************* meals/ajax/setMealTaken.jsp *********************");
    	Debug.println("sPatientMealId : "+sPatientMealId+"\n");
    	Debug.println("bMealTaken     : "+bMealTaken);
    	Debug.println("bShowNutrients : "+bShowNutrients+"\n");
    }
    ///////////////////////////////////////////////////////////////////////////////////////////////

    Meal meal = new Meal(sPatientMealId);
    meal.patientMealUid = sPatientMealId;
    meal.updateMealTaken(activeUser.userid,bMealTaken);
    
    out.write("<script>getPatientMeals("+(bShowNutrients?"true":"false")+");</script>");
%>
