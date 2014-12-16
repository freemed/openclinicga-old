<%@page import="be.mxs.common.util.system.HTMLEntities,
                java.util.*,
                be.openclinic.meals.Meal,
                be.openclinic.meals.MealItem,
                be.openclinic.meals.MealProfile,
                java.util.Date"%>
<%@include file="/includes/validateUser.jsp"%>

<%!
    //--- GET HOURS FIELD -------------------------------------------------------------------------
    public String getHoursField(String id, Date date, String sWebLanguage){
        String sOut = getTran("meals","at",sWebLanguage)+"&nbsp;";
    
	    // hour
	    sOut+= (date.getHours()<10?"0"+date.getHours():""+date.getHours());
	    
	    sOut+= ":";
	    
	    // minutes
	    sOut+= (date.getMinutes()<10?"0"+date.getMinutes():""+date.getMinutes());
	    
	    return sOut;
    }
%>

<%
    String sProfileId = checkString(request.getParameter("profileId"));

    boolean saveButtonIsAddButton = checkString(request.getParameter("saveButtonIsAddButton")).equals("true");

	/// DEBUG /////////////////////////////////////////////////////////////////////////////////////
	if(Debug.enabled){
		Debug.println("\n******************* meals/ajax/getPatientProfile.jsp ******************");
		Debug.println("sProfileId            : "+sProfileId);
		Debug.println("saveButtonIsAddButton : "+saveButtonIsAddButton+"\n");
	}
	///////////////////////////////////////////////////////////////////////////////////////////////

	
	MealProfile profile = MealProfile.getProfile(sProfileId);
%>

<div id="patientProfileEdit" style="width:514px">
    <table class="list" cellspacing="1" cellpadding="1" width="100%" onKeyDown="if(enterEvent(event,13)){setProfile();return false;}">
        <%-- PROFILE NAME --%>
        <tr>
            <td class="admin" width="100"><%=HTMLEntities.htmlentities(getTran("meals","name",sWebLanguage))%></td>
            <td class="admin2">
                <b><%=checkString(HTMLEntities.htmlentities(profile.name))%></b>
            </td>
        </tr>
        
        <%-- PROFILE ITEMS (MEALS) --%>
        <tr>
            <td class="admin"><%=HTMLEntities.htmlentities(getTran("meals","profileItems",sWebLanguage))%></td>
            <td class="admin2">
                <ul id="patientProfileItems" class="items" style="width:380px">
                    <%
                        List meals = profile.getProfileMeals(profile.name);
                        Iterator iter = meals.iterator();
                        
                        while(iter.hasNext()){
                            profile = (MealProfile)iter.next();
                            
                            out.write("<li id='meal_"+profile.mealUid+"'>"+
                                       "<div style='width:80px'>"+getHoursField(profile.mealUid,profile.mealDatetime,sWebLanguage)+"</div>"+
                                       "<div style='width:200px'>"+HTMLEntities.htmlentities(profile.mealName)+"</div>"+
                                      "</li>");
                        }
                    %>
                </ul>
            </td>
        </tr>
        
        <%-- PROFILE NUTRIENTS --%>
        <tr>
            <td class="admin"><%=HTMLEntities.htmlentities(getTran("meals","nutricients",sWebLanguage))%></td>
            <td class="admin2">
                <a href="javascript:void(0)" id="profileNutricientsButton" class="link down" onclick="getNutricientsInPatientProfile(true);"><%=getTranNoLink("meals","seeNutricients",sWebLanguage).toLowerCase()%></a> 
                <ul id="profileNutricientsList" class="items" style="display:none;width:380px"></ul>
            </td>
        </tr>
        
        <%-- BUTTONS --%>
        <tr>
            <td class="admin">&nbsp;</td>
            <td class="admin2">
                <input class="button" type="button" name="SaveButton" id="SaveButton" value="<%=HTMLEntities.htmlentities(getTranNoLink("web",(saveButtonIsAddButton?"add":"save"),sWebLanguage))%>" onclick="setPatientProfile('<%=profile.getUid()%>');">&nbsp;&nbsp;
                <input class="button" type="button" name="closeButton" id="closeButton" value="<%=HTMLEntities.htmlentities(getTranNoLink("web","close",sWebLanguage))%>" onclick="closeModalbox();">
       
                <input type="hidden" id="profileId" value="<%=checkString(profile.getUid())%>"/>
            </td>
        </tr>
    </table>
</div>

<div id="mealItemsList" style="width:520px">&nbsp;</div>