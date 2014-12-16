<%@page import="be.mxs.common.util.system.HTMLEntities,
                be.openclinic.meals.Meal,
                be.openclinic.meals.MealItem,
                be.openclinic.meals.MealProfile,
                java.util.Date,
                java.util.*"%>
<%@include file="/includes/validateUser.jsp"%>

<%
    String sAction = checkString(request.getParameter("action"));

    String sProfileId    = checkString(request.getParameter("profileId")),
           sProfileName  = checkString(request.getParameter("profileName")),
           sProfileItems = checkString(request.getParameter("profileItems"));

    /// DEBUG /////////////////////////////////////////////////////////////////////////////////////
    if(Debug.enabled){
    	Debug.println("\n*********************** meals/ajax/setProfile.jsp *********************");
    	Debug.println("sAction       : "+sAction);
    	Debug.println("sProfileId    : "+sProfileId);
    	Debug.println("sProfileName  : "+sProfileName);
    	Debug.println("sProfileItems : "+sProfileItems+"\n");
    }
    ///////////////////////////////////////////////////////////////////////////////////////////////
    
    List profiles = new LinkedList();
    MealProfile profile = new MealProfile(sProfileId);
    
    if(sProfileItems.length() > 0){
        String[] mealItems = sProfileItems.split(",");
        
        for(int i=0; i<mealItems.length; i++){
            String[] values = mealItems[i].split("-");
            
            profile = new MealProfile(sProfileId);
            profile.mealUid = values[0];
            profile.name = sProfileName;
            
            profile.mealDatetime = new Date();
            profile.mealDatetime.setHours(Integer.parseInt(values[1]));
            profile.mealDatetime.setMinutes(Integer.parseInt(values[2]));
            
            profiles.add(profile);
        }
    }
    
    //*** SAVE ***
    if(sAction.equals("save")){
        if(profiles.size() > 0){
            profile.updateOrInsert(profiles,activeUser.userid);
            out.write("<script>closeModalbox();searchProfiles();</script>");
        }
        else{
            out.write("<script>alertDialog('web.manage','dataMissing');</script>");
        }
    }
    //*** DELETE ***
    else if(sAction.equals("delete")){
        MealProfile.delete(sProfileId);
        out.write("<script>closeModalbox();searchProfiles();</script>");
    }
%>