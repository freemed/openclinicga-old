<%@page import="be.mxs.common.util.system.HTMLEntities"%>
<%@include file="/includes/validateUser.jsp"%>
<%@page errorPage="/includes/error.jsp"%>
<%=checkPermission("manage.meals","all",activeUser)%>

<%
    /// DEBUG /////////////////////////////////////////////////////////////////////////////////////
    if(Debug.enabled){
    	Debug.println("\n************************ meals/manageMeals.jsp ************************");
    	Debug.println("No parameters\n");
    }
    ///////////////////////////////////////////////////////////////////////////////////////////////
%>
    
<table class="list" width="100%" cellspacing="1" onKeyDown="if(enterEvent(event,13)){searchMeals();return false;}">
    <%-- MEAL NAME --%>
    <tr>
        <td class="admin" width="<%=sTDAdminWidth%>"><%=getTran("meals","name",sWebLanguage)%>&nbsp;</td>
        <td class="admin2" style="padding-left:5px;">
            <input type="text" class="text" name="FindMealName" id="FindMealName" size="50" maxLength="100">&nbsp;&nbsp;
            
            <%-- BUTTONS --%>
            <input type="button" class="button" name="searchButton" id="searchMealButton" value="<%=HTMLEntities.htmlentities(getTranNoLink("web","search",sWebLanguage))%>" onclick="searchMeals();">
            <img src="<%=sCONTEXTPATH%>/_img/icons/icon_delete.gif" class="link" title="<%=HTMLEntities.htmlentities(getTranNoLink("web","clear",sWebLanguage))%>" onclick="FindMealName.value='';FindMealName.focus();">&nbsp;&nbsp;
		    <input type="button" class="button" name="newButton" id="newMealButton" value="<%=HTMLEntities.htmlentities(getTranNoLink("web","new",sWebLanguage))%>" onclick="openMeal('-1');">
        </td>
    </tr>
</table>
<br>

<div id="mealResultsByAjax"></div>

<script>
  var itemuid = ""; 

  <%-- SEARCH MEALS --%>
  function searchMeals(){
    $("mealResultsByAjax").update("<div id='wait'></div>");
    document.getElementById("searchMealButton").disabled = true;
    document.getElementById("newMealButton").disabled = true;
    
    var params = "FindMealName="+encodeURI($F("FindMealName"));
    var url = "<c:url value='/meals/ajax/getMeals.jsp'/>?ts="+new Date().getTime();
    new Ajax.Updater("mealResultsByAjax",url,{parameters:params,evalScripts:true});
    
    document.getElementById("searchMealButton").disabled = false;
    document.getElementById("newMealButton").disabled = false;
  }

  <%-- SEARCH MEALS WINDOW --%>
  function searchMealsWindow(bToMakeProfile){
    var params = "FindMealName="+$F("FindMealNameWindow")+
                 "&withSearchFields=1";
    if(bToMakeProfile) params+= "&toMakeProfile=1";
    var url = "<c:url value='meals/ajax/getMeals.jsp'/>?ts="+new Date().getTime();
    $("mealsSearchDiv").update("<div id='wait'></div>");
    new Ajax.Updater("mealsSearchDiv",url,{parameters:params,evalScripts:true});
  }

  <%-- OPEN MEAL --%>
  function openMeal(id){
    var params = "mealId="+id;
    var url = "<c:url value='meals/ajax/getMeal.jsp'/>?ts="+new Date().getTime();
    Modalbox.show(url,{title:"<%=getTran("meals","meal",sWebLanguage)%>",params:params,evalScripts:true,width:530});
  }

  <%-- SET MEAL --%>
  function setMeal(){
	if($("mealName").value.length > 0){
      var params = "action=save"+
                   "&mealId="+$F("mealId")+
                   "&mealName="+encodeURI($F("mealName"));
      var elements = $("mealItemList").childElements();
      var reg = new RegExp("[_]+","g");
      var items = "&mealItems=";
      var allQtsSpecified = true;
      
      for(var i=0; i<elements.size(); i++){
        var t = elements[i].id.split(reg);
        
        if($("mealitemqt_"+t[1]).value.length > 0){
          items+= t[1]+"-"+($("mealitemqt_"+t[1])?$F("mealitemqt_"+t[1]):"0")+",";
        }
        else{
          allQtsSpecified = false;
          alertDialog("meals","specifyQuantity");
          $("mealitemqt_"+t[1]).focus();
          break;
        }
      }
      
      if(allQtsSpecified){
        params+= items;
        $("operationByAjax").update("<div id='wait'></div>");

        var url = "<c:url value='/meals/ajax/setMeal.jsp'/>?ts="+new Date().getTime();
        new Ajax.Updater("operationByAjax",url,{parameters:params,evalScripts:true});
      }
	}
	else{
	  if($("mealName").value.length==0) $("mealName").focus();	  
	            alertDialog("web.manage","dataMissing");
	}
  }
  
  <%-- DELETE MEAL --%>
  function deleteMeal(id){
    itemuid = id;
    yesnoModalBox("deleteMealNext()","<%=getTranNoLink("web","areYouSureToDelete",sWebLanguage)%>");
  }
    
  <%-- DELETE MEAL NEXT --%>
  function deleteMealNext(){
    if(itemuid.length > 0){
      $("operationByAjax").update("<div id='wait'></div>");
      var url = "<c:url value='meals/ajax/setMeal.jsp'/>"+
    		    "?action=delete"+
    		    "&mealId="+itemuid+
    		    "&ts="+new Date().getTime();
      new Ajax.Updater("operationByAjax",url,{evalScripts:true});
    }
  }
        
  <%-- OPEN BACK MEAL --%>
  function openBackMeal(){
    $("mealEdit").show();
    if($("mealItemsDiv")) $("mealItemsDiv").hide();
    //getNutricientsInMeal();
    Modalbox.resizeToContent();
    Modalbox.setTitle("<%=getTranNoLink("meals","meal",sWebLanguage)%>");
  }
    
  <%-- SEARCH MEAL ITEM --%>
  function searchMealItem(){
    $("mealEdit").hide();
    var params = $("manageMealsItemsTable").serialize()+
                 "&withSearchFields=1";
    var url = "<c:url value='/meals/ajax/getMealItems.jsp'/>?ts="+new Date().getTime();
    new Ajax.Updater("mealItemsList",url,{parameters:params,evalScripts:true});
    Modalbox.setTitle("<%=getTranNoLink("meals","searchMealItem",sWebLanguage)%>");
  }

  <%-- REMOVE MEAL ITEM --%>
  function removeMealItem(id){
    if($("mealitem_"+id)){
      $("mealitem_"+id).remove();
      getNutricientsInMeal();
      Modalbox.resizeToContent();
    }
  }

  <%-- MEAL ITEM SELECTED --%>
  function mealItemSelected(id){
	var selected = false;
    var elements = $("mealItemList").childElements();
    var reg = new RegExp("[_]+","g");
    for(var i=0; i<elements.length; i++){
      var data = elements[i].id.split(reg);
      if(data[1]==id){
        selected = true;
        break;
      }
    }

	return selected;
  }
  
  <%-- INSERT MEAL ITEM --%>
  function insertMealItem(id,name,unit,quantity){
	if(quantity==null) quantity = "";
	
	if(mealItemSelected(id)){
	  alertDialog("meals","mealItemAlreadySelected");
	}
	else{	
      var li = document.createElement("LI");
      li.id = "mealitem_"+id;
      li.innerHTML = "<div style='width:25px'>"+
                      "<img src='<%=sCONTEXTPATH%>/_img/icons/icon_delete.png' class='link' style='vertical-align:-3px;' title='<%=getTranNoLink("web","delete",sWebLanguage)%>' onclick='removeMealItem(\""+id+"\");'>"+
                     "</div>"+
                     "<div style='width:180px'>"+name+"</div>"+
                     "<div style='width:100px'>"+
                      "<input type='text' size='6' maxLength='8' onKeyUp='isNumber(this);' onBlur='if(isNumber(this))getNutricientsInMeal();' id='mealitemqt_"+id+"' value='"+quantity+"'/> "+unit+
                     "</div>";
      $("mealItemList").insert(li);
      openBackMeal();
	}
  }
    
  <%-- GET NUTRICIENTS IN MEAL --%>
  function getNutricientsInMeal(toggle){
	if(toggle==null) toggle = false;
    var id = "mealNutricientList";
    
    if(toggle){
      if($(id).style.display=="none"){
        $(id).style.display = "table";
        $("mealNutricientsRefresh").style.display = "inline";
      }
      else{
        $(id).style.display = "none";
        $("mealNutricientsRefresh").style.display = "none";
      }
    }
    
    var fetchData = ($(id).style.display=="table"); 
    if(fetchData){
      if($("mealNutricientsButton").hasClassName("up")){
        $("mealNutricientsButton").removeClassName("up");
        $("mealNutricientsButton").addClassName("down");
      }
      else{
        $("mealNutricientsButton").removeClassName("down");
        $("mealNutricientsButton").addClassName("up");
      }
                 
      $(id).update("<div id='wait'></div>");
      var params = "ts="+new Date().getTime();
      var elements = $("mealItemList").childElements();
      var regExp = new RegExp("[_]+","g");
      var items = "&items=";
      elements.each(function(elem){
        var idParts = elem.id.split(regExp);
        items+= idParts[1]+"-"+(($("mealitemqt_"+idParts[1]).value.length > 0)?$("mealitemqt_"+idParts[1]).value:"0")+",";
      });
      params+= items;
      
      var url = "<c:url value='/meals/ajax/getMealItemNutricients.jsp'/>";
      new Ajax.Updater(id,url,{parameters:params,evalScripts:true});
    }
  }

  <%-- CLEAR MEAL ITEM SEARCH FIELDS --%>
  function clearMealItemSearchFields(){
    document.getElementById("FindMealItemName").value = "";
    document.getElementById("FindMealItemDescription").value = "";
    
    document.getElementById("FindMealItemName").focus();
  }
  
  <%-- SEARCH MEAL-ITEMS WINDOW --%>
  function searchMealItemsWindow(){
    var params = "FindMealItemName="+encodeURI($F("FindMealItemName"))+
                 "&FindMealItemDescription="+encodeURI($F("FindMealItemDescription"))+
                 "&withSearchFields=1";
    var url = "<c:url value='/meals/ajax/getMealItems.jsp'/>?ts="+new Date().getTime();
    new Ajax.Updater("mealItemsList",url,{parameters:params,evalScripts:true});
    $("mealItemsList").update("<div id='wait'></div>");
  }
</script>