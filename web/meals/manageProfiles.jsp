<%@page import="be.mxs.common.util.system.HTMLEntities"%>
<%@include file="/includes/validateUser.jsp"%>
<%@page errorPage="/includes/error.jsp"%>
<%=checkPermission("manage.meals","all",activeUser)%>

<%
    /// DEBUG /////////////////////////////////////////////////////////////////////////////////////
    if(Debug.enabled){
    	Debug.println("\n*********************** meals/manageProfiles.jsp ***********************");
    	Debug.println("No parameters\n");
    }
    ///////////////////////////////////////////////////////////////////////////////////////////////
%>

<table class="list" width="100%" cellspacing="1" onKeyDown="if(enterEvent(event,13)){searchProfiles();return false;}">
    <%-- PROFILE NAME --%>
    <tr>
        <td class="admin" width="<%=sTDAdminWidth%>"><%=getTran("meals","name",sWebLanguage)%></td>
        <td class="admin2">
            <input type="text" class="text" name="FindProfileName" id="FindProfileName" size="50" maxLength="100">&nbsp;&nbsp;
            
            <%-- BUTTONS --%>
            <input type="button" class="button" name="searchButton" value="<%=HTMLEntities.htmlentities(getTranNoLink("web","search",sWebLanguage))%>" onclick="searchProfiles();">
            <img src="<%=sCONTEXTPATH%>/_img/icons/icon_delete.gif" class="link" title="<%=HTMLEntities.htmlentities(getTranNoLink("web","clear",sWebLanguage))%>" onclick="FindProfileName.value='';FindProfileName.focus();">&nbsp;&nbsp;
            <input type="button" class="button" name="newButton" value="<%=HTMLEntities.htmlentities(getTranNoLink("web","new",sWebLanguage))%>" onclick="openProfile('-1');">
        </td>
    </tr>
</table>
<br>

<div id="profileResultsByAjax"></div>

<script>
  var profileId = "";

  <%-- SEARCH PROFILES --%>
  function searchProfiles(){
    $("profileResultsByAjax").update("<div id='wait'></div>");
    var params = "FindProfileName="+encodeURI($F("FindProfileName"));
    var url = "<c:url value='/meals/ajax/getProfiles.jsp'/>?ts="+new Date().getTime();
    new Ajax.Updater("profileResultsByAjax",url,{parameters:params,evalScripts:true});
  }

  <%-- SEARCH PROFILES WINDOW --%>
  function searchProfilesWindow(bToMakeProfile){
    var params = "FindProfileName="+$F("FindProfileNameWindow")+
                 "&withSearchFields=1";
    var url = "<c:url value='meals/ajax/getProfiles.jsp'/>?ts="+new Date().getTime();
    new Ajax.Updater("profileSearchDiv",url,{parameters:params,evalScripts:true});
  }
   
  <%-- OPEN PROFILE --%>
  function openProfile(id){
    var params = "profileId="+id;
    var url = "<c:url value='/meals/ajax/getProfile.jsp'/>?ts="+new Date().getTime();
    Modalbox.show(url,{title:"<%=getTran("meals","profile",sWebLanguage)%>",params:params,width:530});
  }
  
  <%-- SET PROFILE --%>
  function setProfile(){
	if($("profileName").value.length > 0){
	  if(atLeastOneMealSelected()){
        var params = "action=save"+
                     "&profileId="+$F("profileId")+
                     "&profileName="+encodeURI($F("profileName"));
        var elements = $("profileItemList").childElements();
        var reg = new RegExp("[_]+","g");
        var items = "&profileItems=";
        elements.each(function(s){
          var t = s.id.split(reg);
          items+= t[1]+"-"+($("mealHour_"+t[1])?$("mealHour_"+t[1]).value:"0")+"-"+($("mealMin_"+t[1])?$("mealMin_"+t[1]).value:"0")+",";
        });
        params+= items;
        $("operationByAjax").update("<div id='wait'></div>");
 
        var url = "<c:url value='/meals/ajax/setProfile.jsp'/>?ts="+new Date().getTime();
        new Ajax.Updater("operationByAjax",url,{parameters:params,evalScripts:true});
	  }
	  else{	 	
	    alertDialog("meals","selectAtLeastOneMeal");
      }
	}
    else{
      if($("profileName").value.length==0) $("profileName").focus();	 	
      alertDialog("web.manage","dataMissing");
    }
  }
  
  <%-- AT LEAST ONE MEAL SELECTED --%>
  function atLeastOneMealSelected(){
    var elements = $("profileItemList").childElements();
	return (elements.size() > 0);  
  }
  
  <%-- DELETE PROFILE --%>
  function deleteProfile(id){
    profileId = id;
    yesnoModalBox("deleteProfileNext()","<%=getTranNoLink("web","areYouSureToDelete",sWebLanguage)%>");
  }

  <%-- DELETE PROFILE NEXT --%>
  function deleteProfileNext(){
    if(profileId.length > 0){
      $("operationByAjax").update("<div id='wait'></div>");
      var url = "<c:url value='/meals/ajax/setProfile.jsp'/>"+
                "?action=delete"+
                "&profileId="+profileId+
                "&ts="+new Date().getTime();
      new Ajax.Updater("operationByAjax",url,{evalScripts:true});
    }
  }
    
  <%-- SEARCH MEAL --%>
  function searchMeal(){
    $("profileEdit").hide();
    $("mealItemsList").update("<div id='wait'></div>");
    var params = $("manageMealsItemsTable").serialize()+
                 "&withSearchFields=1"+
                 "&toMakeProfile=1";
    var url = "<c:url value='/meals/ajax/getMeals.jsp'/>?ts="+new Date().getTime();
    new Ajax.Updater("mealItemsList",url,{parameters:params,evalScripts:true});
    Modalbox.setTitle("<%=getTranNoLink("meals","searchMealItem",sWebLanguage)%>");
  }
  
  <%-- REMOVE MEAL FROM PROFILE --%>
  function removeMealFromProfile(id){
    if($("meal_"+id)){
      $("meal_"+id).remove();
      Modalbox.resizeToContent();
    }
  }

  <%-- MEAL SELECTED --%>
  function mealSelected(id){	
	var selected = false;
	if($("mealItemsList")){
      var elements = $("profileItemList").childElements();
      var reg = new RegExp("[_]+","g");
      for(var i=0; i<elements.length; i++){
        var data = elements[i].id.split(reg);
        if(data[1]==id){
          selected = true;
          break;
        }
      }
	}

	return selected;
  }
  
  <%-- INSERT MEAL --%>
  function insertMeal(id,name,hour,min){
	if(mealSelected(id)){
	  alertDialog("meals","mealAlreadySelected");
	}
	else{	
      var li = document.createElement("LI");
      li.id = "profileitem_"+id;                   
      li.innerHTML = "<div style='width:35px'>"+
                      "<img src='<%=sCONTEXTPATH%>/_img/icons/icon_delete.png' class='link' style='vertical-align:-3px;' title='<%=getTranNoLink("web","delete",sWebLanguage)%>' onclick='removeProfile(\""+id+"\");'>"+
                     "</div>"+
                     "<div style='width:120px'>"+getHoursSelect(id,hour,min)+"</div>"+
                     "<div style='width:190px'>"+name+"</div>";
      $("profileItemList").insert(li,{position:top});
      openBackProfile();
	}
  }
  
  <%-- OPEN BACK MEAL PROFILE --%>
  function openBackProfile(name){
    if($("profileEdit")!=null){
      $("profileEdit").show();
      $("mealItemsList").update("");
      Modalbox.resizeToContent();
      Modalbox.setTitle("<%=getTranNoLink("meals","profile",sWebLanguage)%>");
    }
    else{
      closeModalbox();
    }
  }
    
  <%-- GET HOURS SELECT --%>
  function getHoursSelect(id,hour,min){
    var sOut = "<%=getTranNoLink("meals","at",sWebLanguage)%>&nbsp;"+
               "<select style='padding:2px' id='mealHour_"+id+"' style='width:40px' class='text'>";
    for(i=0; i<=23; i++){
      sOut+= "<option"+(hour==i?" selected":"")+" value="+i+">"+(i<10?"0"+i:""+i)+"</option>";
    }
    sOut+= "</select>:";
    
    sOut+= "<select style='padding:2px' id='mealMin_"+id+"' style='width:40px' class='text'>";
    for(i=0; i<=59; i+=5){
      sOut+= "<option"+(min==i?" selected":"")+" value="+i+">"+(i<10?"0"+i:""+i)+"</option>";
    }
    sOut+= "</select>";
    
    return sOut;
  }
    
  <%-- GET NUTRICIENTS IN PROFILE --%>
  function getNutricientsInProfile(profileid,noToggle){
    var id = "profileNutricientsList";
    
    if(!noToggle && $(id).childElements().length > 0){
      $(id).innerHTML = "";
      $(id).style.display = "none";
      Modalbox.resizeToContent();
      
      if($("profileNutricientsButton").hasClassName("up")){
        $("profileNutricientsButton").removeClassName("up");
        $("profileNutricientsButton").addClassName("down");
      }
      
      if($("profileNutricientsRefresh")){
    	$("profileNutricientsRefresh").style.display = "none";
      }
    }
    else{
      if($("profileNutricientsButton").hasClassName("down")){
        $("profileNutricientsButton").removeClassName("down");
        $("profileNutricientsButton").addClassName("up");
      }
      
      if($("profileNutricientsRefresh")){
    	$("profileNutricientsRefresh").style.display = "inline";
      }
      
      $(id).style.display = "table";
      $(id).update("<div id='wait'></div>");
      
      var params = "ts="+new Date().getTime();
      var elements = $("profileItemList").childElements();
      var reg = new RegExp("[_]+","g");
      var items = "&meals=";
      elements.each(function(s){
        var t = s.id.split(reg);
        items+= t[1]+",";
      });
      params+= items;
      
      var url = "<c:url value='/meals/ajax/getProfileNutricients.jsp'/>";
      new Ajax.Updater(id,url,{parameters:params,evalScripts:true});
    }
  }
</script>