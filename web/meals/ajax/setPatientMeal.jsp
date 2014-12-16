<%@page import="be.mxs.common.util.system.HTMLEntities,
                java.util.*,
                java.util.Date,
                be.openclinic.meals.Meal,
                be.openclinic.meals.MealItem"%>
<%@include file="/includes/validateUser.jsp"%>

<%
    String sAction = checkString(request.getParameter("action"));

    String sMealId      = checkString(request.getParameter("mealId")),
           sChosenDate  = checkString(request.getParameter("chosenDate")),
           sPatientMeal = checkString(request.getParameter("patientMealId")),
           sMealHour    = checkString(request.getParameter("mealHour")),
           sMealMin     = checkString(request.getParameter("mealMin"));

    boolean bMealTaken     = checkString(request.getParameter("mealtakenyes")).equals("true"),
            bShowNutrients = checkString(request.getParameter("showNutrients")).equals("true");
    
    /// DEBUG /////////////////////////////////////////////////////////////////////////////////////
    if(Debug.enabled){
    	Debug.println("\n********************* meals/ajax/setPatientMeal.jsp ********************");
    	Debug.println("sAction      : "+sAction);
    	Debug.println("sMealId      : "+sMealId);
    	Debug.println("sChosenDate  : "+sChosenDate);
    	Debug.println("sPatientMeal : "+sPatientMeal);
    	Debug.println("sMealHour    : "+sMealHour);
    	Debug.println("sMealMin     : "+sMealMin+"\n");

    	Debug.println("bMealTaken     : "+bMealTaken);
    	Debug.println("bShowNutrients : "+bShowNutrients+"\n");
    }
    ///////////////////////////////////////////////////////////////////////////////////////////////

    Meal meal = new Meal(sMealId);
    meal.patientMealUid = sPatientMeal;
    
    if(sAction.equals("save")){
        meal.insertOrUpdatePatientMeal(activePatient,sChosenDate,(sMealHour+":"+sMealMin),activeUser.userid,bMealTaken,null);
    }
    else if(sAction.equals("delete")){
        meal.patientMealUid = sPatientMeal;
        meal.deleteMealFromPatient();        
    }
    
    out.write("<script>closeModalbox();getPatientMeals("+(bShowNutrients?"true":"false")+");</script>");
%>