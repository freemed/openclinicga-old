<%@page import="be.mxs.common.util.system.HTMLEntities,
                be.openclinic.meals.Meal,
                be.openclinic.meals.MealItem,
                java.util.Date,
                java.util.*"%>
<%@include file="/includes/validateUser.jsp"%>

<%
    String sMealId        = checkString(request.getParameter("mealId")),
           sPatientMealId = checkString(request.getParameter("patientmealId")),
           sFindMealByDay = checkString(request.getParameter("FindMealByDay"));

    boolean saveButtonIsAddButton = checkString(request.getParameter("saveButtonIsAddButton")).equals("true");

    /// DEBUG /////////////////////////////////////////////////////////////////////////////////////
    if(Debug.enabled){
    	Debug.println("\n******************** meals/ajax/getPatientMeal.jsp ********************");
    	Debug.println("sMealId               : "+sMealId);
    	Debug.println("sPatientMealId        : "+sPatientMealId);
    	Debug.println("sFindMealByDay        : "+sFindMealByDay);
    	Debug.println("saveButtonIsAddButton : "+saveButtonIsAddButton+"\n");
    }
    ///////////////////////////////////////////////////////////////////////////////////////////////
    
    Meal item = new Meal(sMealId);
    int hour = 7, min = 0; // default hour
    
    Meal tmpMeal = null;
    if(sMealId.length() > 0 && !sMealId.equals("-1")){
        item = Meal.get(item);
        
        List meals = Meal.getPatientMeals(activePatient,sFindMealByDay,item);
        if(meals.size() > 0){
            tmpMeal = (Meal)meals.get(0); // first meal
            
            hour = tmpMeal.mealDatetime.getHours();
            min = tmpMeal.mealDatetime.getMinutes();
            item.taken = tmpMeal.taken;
        }
    }
%>

<div id="mealAddDiv" style="width:510px">
<table class="list" cellspacing="1" cellpadding="1" width="100%" onKeyDown="if(enterEvent(event,13)){closeModalbox();return false;}">
    <%-- MEAL NAME --%>
    <tr>
        <td class="admin" width="250"><%=HTMLEntities.htmlentities(getTran("meals","mealName",sWebLanguage))%></td>
        <td class="admin2"><%=checkString(HTMLEntities.htmlentities(item.name))%></td>
    </tr>
    
    <%-- MEAL TIME --%>
    <tr>
        <td class="admin" width="250"><%=HTMLEntities.htmlentities(getTran("meals","mealTime",sWebLanguage))%></td>
        <td class="admin2">
            <%-- hour --%>
            <select style="width:40px;padding:2px" id="mealHour" class="text">
            <%
                for(int n=0; n<=23; n++){
                    out.print("<option value='"+(n<10?"0"+n:""+n)+"'");
                    if(n==hour){
                        out.print(" selected");
                    }
                    out.print(">"+(n<10?"0"+n:""+n)+"</option>");
                }
            %>
	        </select>:
	        
	        <%-- minutes --%>
	        <select style="width:40px;padding:2px" id="mealMin" class="text">
	            <%
	                for(int n=0; n<60; n=n+5){
	                    out.print("<option value='"+(n<10?"0"+n:""+n)+"'");
	                    if(n==min){
	                        out.print(" selected");
	                    }
	                    out.print(">"+(n<10?"0"+n:""+n)+"</option>");
	                }
	            %>
	        </select>&nbsp;<%=HTMLEntities.htmlentities(getTran("hrm","uur",sWebLanguage))%>&nbsp;
        </td>
    </tr>
    
    <%-- MEAL ITEMS --%>
    <tr>
        <td class="admin"><%=HTMLEntities.htmlentities(getTran("meals","mealItems",sWebLanguage))%></td>
        <td class="admin2">
            <ul id="mealItemList" class="items" style="width:370px">
                <%
                    Iterator iter = item.mealItems.iterator();
                    while(iter.hasNext()){
                        MealItem mealItem = (MealItem)iter.next();
                        
                        out.write("<li id='mealitem_"+mealItem.getUid()+"'>"+
                                   "<div style='width:190px'>"+mealItem.name+"</div>"+
                                   "<div style='width:150px;border-left:1px solid #C3D9FF;padding-left:5px'>"+
                                    "<input type='hidden' id='mealitemqt_"+mealItem.getUid()+"' value='"+mealItem.quantity+"'/>"+mealItem.quantity+" "+HTMLEntities.htmlentities(mealItem.unit)+
                                   "</div>"+
                                  "</li>");
                    }
                %>
            </ul>
        </td>
    </tr>
    
    <%-- MEAL TAKEN --%>
    <tr>
        <td class="admin" width="100"><%=HTMLEntities.htmlentities(getTran("meals","mealtaken",sWebLanguage))%></td>
        <td class="admin2">
            <input type="radio" id="mealtakenyes" name="mealtaken" value="1" <%=(item.taken?"checked=true":"")%>/><%=getLabel("web","yes",sWebLanguage,"mealtakenyes")%>
            <input type="radio" id="mealtakenno" name="mealtaken" value="0" <%=(!item.taken?"checked=true":"")%>/><%=getLabel("web","no",sWebLanguage,"mealtakenno")%>
        </td>
    </tr>
    
    <%-- MEAL NUTRICIENTS --%>
    <tr>
        <td class="admin"><%=HTMLEntities.htmlentities(getTran("meals","mealNutricients",sWebLanguage))%></td>
        <td class="admin2">
            <a href="javascript:void(0)" id="mealNutricientsButton" class="link down" onclick="getNutricientsInMeal('<%=item.getUid()%>',false);"><%=getTranNoLink("meals","seemealNutricients",sWebLanguage)%></a>
            <ul id="mealNutricientList" class="items" style="width:370px"></ul>
        </td>
    </tr>
    
    <%-- BUTTONS --%>
    <tr>
        <td class="admin">&nbsp;</td>
        <td class="admin2">
            <input type="hidden" id="patientMealId" value="<%=sPatientMealId%>">
            <input class="button" type="button" name="SaveButton" id="SaveButton" value="<%=HTMLEntities.htmlentities(getTranNoLink("web",(saveButtonIsAddButton?"add":"save"),sWebLanguage))%>" onclick="setPatientMeal('<%=item.getUid()%>');">&nbsp;
            <%
                if(!saveButtonIsAddButton && !item.getUid().equalsIgnoreCase("-1")){
                    %><input type="button" class="button" name="deleteButton" id="deleteButton" value="<%=HTMLEntities.htmlentities(getTranNoLink("web","delete",sWebLanguage))%>" onclick="deleteMealFromPatient('<%=sPatientMealId%>');">&nbsp;<%
                }
            %>
            <input class="button" type="button" name="closeButton" id="closeButton" value="<%=HTMLEntities.htmlentities(getTranNoLink("web","close",sWebLanguage))%>" onclick="closeModalbox();">
        </td>
    </tr>
</table>
</div>