<%@page import="be.mxs.common.util.system.HTMLEntities,
                be.openclinic.meals.MealProfile,
                be.openclinic.meals.MealItem,   
                be.openclinic.meals.Meal,             
                java.util.*"%>
<%@include file="/includes/validateUser.jsp"%>

<%
    String sAction = checkString(request.getParameter("action"));

    String sProfileId  = checkString(request.getParameter("profileId")),
           sChosenDate = checkString(request.getParameter("chosenDate"));
    
    boolean bShowNutrients = checkString(request.getParameter("showNutrients")).equals("true");
    
    /// DEBUG /////////////////////////////////////////////////////////////////////////////////////
    if(Debug.enabled){
    	Debug.println("\n******************* meals/ajax/setPatientProfile.jsp *******************");
    	Debug.println("sAction     : "+sAction);
    	Debug.println("sProfileId  : "+sProfileId);
    	Debug.println("sChosenDate : "+sChosenDate+"\n");
    }
    ///////////////////////////////////////////////////////////////////////////////////////////////
    
    
    MealProfile profile = new MealProfile(sProfileId);
    
    //--- SAVE ------------------------------------------------------------------------------------
    if(sAction.equals("save")){
        List profiles = profile.getProfiles("");
        
        new Meal().insertPatientProfile(profiles,activePatient,activeUser.userid);
        
        out.write("<script>closeModalbox();getPatientMeals("+(bShowNutrients?"true":"false")+");</script>");
    }
%>