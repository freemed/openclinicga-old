<%@page import="be.mxs.common.util.system.HTMLEntities"%>
<%@include file="/includes/validateUser.jsp"%>
<%@page errorPage="/includes/error.jsp"%>
<%=checkPermission("manage.meals","all",activeUser)%>
<link type="text/css" rel="stylesheet" href='<c:url value="/"/>_common/_css/meals.css'/>

<%
    /// DEBUG /////////////////////////////////////////////////////////////////////////////////////
    if(Debug.enabled){
    	Debug.println("\n********************** meals/manageMealsItem.jsp **********************");
    	Debug.println("No parameters\n");
    }
    ///////////////////////////////////////////////////////////////////////////////////////////////
%>

<table class="list" width="100%" cellspacing="1" onKeyDown="if(enterEvent(event,13)){searchMealItems();return false;}">
    <form name="manageMealsItemsTable" id="manageMealsItemsTable" method="post">
        <%-- ITEM NAME --%>
        <tr>
            <td class="admin" width="<%=sTDAdminWidth%>"><%=getTran("meals","name",sWebLanguage)%></td>
            <td class="admin2" style="padding-left:5px;">
                <input type="text" class="text" id="FindMealItemName" name="FindMealItemName" size="50" maxLength="100">
            </td>
        </tr>
        
        <%-- DESCRIPTION --%>
        <tr>
            <td class="admin"><%=getTran("meals","description",sWebLanguage)%></td>
            <td class="admin2" style="padding-left:5px;">
                <input type="text" class="text" id="FindMealItemDescription" name="FindMealItemDescription" size="50" maxLength="100">&nbsp;&nbsp;
                
                <%-- BUTTONS --%>
                <input type="button" class="button" name="searchButton" value="<%=HTMLEntities.htmlentities(getTranNoLink("web","search",sWebLanguage))%>" onclick="searchMealItems();">
                <img src="<%=sCONTEXTPATH%>/_img/icons/icon_delete.gif" class="link" title="<%=HTMLEntities.htmlentities(getTranNoLink("web","clear",sWebLanguage))%>" onclick="clearSearchFields();">&nbsp;&nbsp;
		        <input type="button" class="button" name="newButton" value="<%=HTMLEntities.htmlentities(getTranNoLink("web","new",sWebLanguage))%>" onclick="openMealItem('-1');">
            </td>
        </tr>
    </form>
</table>
<br>

<div id="mealItemResultsByAjax">&nbsp;</div>

<script>
  var itemuid = "";

  <%-- CLEAR SEARCHFIELDS --%>
  function clearSearchFields(){
    manageMealsItemsTable.FindMealItemName.value = "";
    manageMealsItemsTable.FindMealItemDescription.value = "";
    
    manageMealsItemsTable.FindMealItemName.focus();  
  }
  
  <%-- SEARCH MEAL ITEMS --%>
  function searchMealItems(){
    $("mealItemResultsByAjax").update("<div id='wait'></div>");
    var params = "FindMealItemName="+encodeURI($F("FindMealItemName"))+
                 "&FindMealItemDescription="+encodeURI($F("FindMealItemDescription"));
    var url = "<c:url value='/meals/ajax/getMealItems.jsp'/>?ts="+new Date().getTime();
    new Ajax.Updater("mealItemResultsByAjax",url,{parameters:params,evalScripts:true});
  }

  <%-- SEARCH NUTRIENT ITEMS WINDOW --%>
  function searchNutricientItemsWindow(doSearch){
	if(doSearch==null) doSearch = true;
	$("mealItemEdit").hide();
    var params = (doSearch?"Action=search&":"")+
                 "withSearchFields=1";
    if($("FindNutricientNameWindow")){
      params+= "&FindNutricientNameWindow="+encodeURI($F("FindNutricientNameWindow"));
    }
    
    $("nutricientItemsList").update("<div id='wait'></div>");
    var url = "<c:url value='/meals/ajax/getNutricientItems.jsp'/>?ts="+new Date().getTime();
    new Ajax.Updater("nutricientItemsList",url,{parameters:params,evalScripts:true});
    
    Modalbox.setTitle("<%=getTranNoLink("meals","searchNutricientItem",sWebLanguage)%>");
  }
  
  <%-- OPEN MEAL ITEM --%>
  function openMealItem(id){
    var params = "mealItemId="+id;
    var url = "<c:url value='/meals/ajax/getMealItem.jsp'/>?ts="+new Date().getTime();
    Modalbox.show(url,{title:"<%=getTran("meals","mealItem",sWebLanguage)%>",params:params,width:530});
  }

  <%-- SET MEAL ITEM --%>
  function setMealItem(){
	if($F("mealItemName").length > 0 && $F("mealItemUnit").length > 0){
      var params = "action=save"+
                   "&mealItemId="+$F("mealItemId")+
                   "&mealItemName="+encodeURI($F("mealItemName"))+
                   "&mealItemUnit="+encodeURI($F("mealItemUnit"))+
                   "&mealItemDescription="+encodeURI($F("mealItemDescription"));
      var elements = $("nutricientList").childElements();
      var reg = new RegExp("[_]+","g");
      var items = "&nutricientItems=";
      var allQtsSpecified = true;
      
      for(var i=0; i<elements.size(); i++){
        var t = elements[i].id.split(reg);
        
        if($("nutricientqt_"+t[1]).value.length > 0){
          items+= t[1]+"-"+($("nutricientqt_"+t[1])?$F("nutricientqt_"+t[1]):"0")+",";
        }
        else{
          allQtsSpecified = false;
          alertDialog("meals","specifyQuantity");
          $("nutricientqt_"+t[1]).focus();
          break;
        }
      }
      
      if(allQtsSpecified){
        params+= items;
    
        $("operationByAjax").update("<div id='wait'></div>");
        var url = "<c:url value='/meals/ajax/setMealItem.jsp'/>?ts="+new Date().getTime();
        new Ajax.Updater("operationByAjax",url,{parameters:params,evalScripts:true});
      }
	}
	else{
	       if($F("mealItemName").length==0) $("mealItemName").focus();
	  else if($F("mealItemUnit").length==0) $("mealItemUnit").focus();

 	            alertDialog("web.manage","dataMissing");
	}
  }
  
  <%-- DELETE MEAL ITEM --%>
  function deleteMealItem(id){
    itemuid = id;
    yesnoModalBox("deleteMealItemNext()","<%=getTranNoLink("web","areYouSureToDelete",sWebLanguage)%>");
  }

  <%-- DELETE MEAL ITEM NEXT --%>
  function deleteMealItemNext(){
    if(itemuid.length > 0){
      $("operationByAjax").update("<div id='wait'></div>");
      var url = "<c:url value='/meals/ajax/setMealItem.jsp'/>"+
                "?action=delete"+
                "&mealItemId="+itemuid+
                "&ts="+new Date().getTime();
      new Ajax.Updater("operationByAjax",url,{evalScripts:true});
    }
  }
  
  <%-- OPEN BACK MEAL ITEM --%>
  function openBackMealItem(name){
    Modalbox.setTitle("<%=getTranNoLink("meals","mealItem",sWebLanguage)%>");
	if($("nutrientsSearchDiv")) $("nutrientsSearchDiv").hide();
    $("mealItemEdit").show();
    Modalbox.resizeToContent();
  }

  <%-- REMOVE NUTRIENT ITEM --%>
  function removeNutricientItem(id){
    if($("nutricient_"+id)){
      $("nutricient_"+id).remove();
      Modalbox.resizeToContent();
    }
  }

  <%-- NUTRICIENT SELECTED --%>
  function nutricientSelected(id){
	var selected = false;
    var elements = $("nutricientList").childElements();
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
  
  <%-- INSERT NUTRIENT ITEM --%>
  function insertNutricientItem(id,name,unit,quantity){
	if(nutricientSelected(id)){
	  alertDialog("meals","nutrientAlreadySelected");
	}
	else{	
	  openBackMealItem();
	  if(quantity==null) quantity = "0.0";
      var li = document.createElement('LI');
      li.id = "nutricient_"+id;
      li.innerHTML = "<div style='width:25px'>"+
                      "<img src='<%=sCONTEXTPATH%>/_img/icons/icon_delete.png' class='link' style='vertical-align:-3px;' title='<%=getTranNoLink("web","delete",sWebLanguage)%>' onclick='removeNutricientItem(\""+id+"\");'>"+
                     "</div>"+
                     "<div style='width:180px'>"+name+"</div>"+
                     "<div style='width:100px'>"+
                      "<input type='text' size='6' maxLength='8' onKeyUp='isNumber(this);' onBlur='isNumber(this);' id='nutricientqt_"+id+"' value='"+quantity+"'/> "+unit+
                     "</div>";
      $("nutricientList").insert(li);
	}
  }
</script>