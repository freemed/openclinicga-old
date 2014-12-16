<%@page import="be.mxs.common.util.system.HTMLEntities"%>
<%@include file="/includes/validateUser.jsp"%>
<%@page errorPage="/includes/error.jsp"%>
<%=checkPermission("manage.meals","all",activeUser)%>
<%=sCSSGNOOCALENDAR%>
<%=sJSGNOOCALENDAR%>

<%
    /// DEBUG /////////////////////////////////////////////////////////////////////////////////////
    if(Debug.enabled){
    	Debug.println("\n********************* meals/managePatientMeals.jsp *********************");
    	Debug.println("No parameters\n");
    }
    ///////////////////////////////////////////////////////////////////////////////////////////////
%>

<table width="100%" class="list" cellpadding="0" cellspacing="1">
    <tr class="gray">
        <%-- CALENDAR (title) --%>
        <td><%=getTran("meals","chooseADay",sWebLanguage)%></td>
        
        <%-- DATE & BUTTONS --%>
        <td>
            <input type="button" class="button" value=" < " onclick="addDays($F('datechoosed'),-1);"/>
            <input type="text" class="text" id="datechoosed" value="" size="12" disabled/>
            <input type="button" class="button" value=" > " onclick="addDays($F('datechoosed'),+1);"/>&nbsp;&nbsp;
          
            <input type="button" class="button" value="<%=HTMLEntities.htmlentities(getTranNoLink("meals","addMeal",sWebLanguage))%>" onclick="getMeals();"/>
            <input type="button" class="button" value="<%=HTMLEntities.htmlentities(getTranNoLink("meals","addProfile",sWebLanguage))%>" onclick="getProfiles();"/>            
            <input type="button" class="button" id="mealNutricientsButton" value="<%=HTMLEntities.htmlentities(getTranNoLink("meals","seeNutricients",sWebLanguage))%>" onclick="getNutricientsInPatientMeals(false);"/>
        </td>
    </tr>
    
    <tr>
        <%-- CALENDAR (app) --%>
        <td class="admin2" width="150" style="vertical-align:top;padding:2px 5px">
            <div id="gnoocalendar">&nbsp;</div>
        </td>
        <td class="admin2" style="vertical-align:top;">
            <div id="contentblock" style="width:400px;">&nbsp;</div>
            <ul id="patientMealNutricientList" class="items" style="display:none;width:400px;"></ul>
        </td>
    </tr>
</table>

<script>
  var CL = null;
  var mealuid = "";
  
  <%-- GET PATIENT MEALS --%>
  function getPatientMeals(showNutrients){
	if(showNutrients==null) showNutrients = false;
    $("patientMealNutricientList").innerHTML = "";
    $("patientMealNutricientList").style.display = "none";
      
    $("contentblock").update("<div id='wait'></div>");
    var params = "FindMealByDay="+encodeURI($F("datechoosed"));
    var url = "<c:url value='/meals/ajax/getPatientMeals.jsp'/>?ts="+new Date().getTime();
    new Ajax.Updater("contentblock",url,{parameters:params,evalScripts:true});

	if(showNutrients){
	  setTimeout("getNutricientsInPatientMeals()",100);
    }
  }

  <%-- GET PATIENT MEAL --%>
  function getPatientMeal(id,update,patientmealid){
    var params = "mealId="+id+
                 "&FindMealByDay="+encodeURI($F("datechoosed"));    
    if(!patientmealid) patientmealid = "-1";
    params+="&patientmealId="+patientmealid;
    
    var url = "<c:url value='/meals/ajax/getPatientMeal.jsp'/>?ts="+new Date().getTime();
    if(update){
      Modalbox.show(url,{title:"<%=getTran("meals","updatePatientmeal",sWebLanguage)%> "+$F("datechoosed"),params:params,width:530});
    }
    else{
      params+= "&saveButtonIsAddButton=true";
      Modalbox.show(url,{title:"<%=getTran("meals","addPatientmeal",sWebLanguage)%> "+$F("datechoosed"),params:params,width:530});
    }
  }
  
  <%-- GET PATIENT PROFILE --%>
  function getPatientProfile(id){
    var params = "profileId="+id+
                 "&FindMealByDay="+encodeURI($F("datechoosed"))+
                 "&saveButtonIsAddButton=true";
    var url = "<c:url value='/meals/ajax/getPatientProfile.jsp'/>?ts="+new Date().getTime();
    Modalbox.show(url,{title:"<%=getTran("meals","addPatientProfile",sWebLanguage)%> "+$F("datechoosed"),params:params,width:530});
  }
    
  <%-- GET MEALS --%>
  function getMeals(){
    var params = "withSearchFields=1";
    var url = "<c:url value='/meals/ajax/getMeals.jsp'/>?ts="+new Date().getTime();
    Modalbox.show(url,{title:"<%=getTran("meals","searchMeals",sWebLanguage)%>",params:params,width:530});
  }

  <%-- GET PROFILES --%>
  function getProfiles(){
    var params = "withSearchFields=1";
    var url = "<c:url value='/meals/ajax/getProfiles.jsp'/>?ts="+new Date().getTime();
    Modalbox.show(url,{title:"<%=getTran("meals","searchProfiles",sWebLanguage)%>",params:params,width:530});
  }

  <%-- SET PATIENT MEAL --%>
  function setPatientMeal(id){
    var params = "patientMealId="+$("patientMealId").value+
                 "&action=save"+
                 "&mealId="+id+
                 "&chosenDate="+encodeURI($F("datechoosed"))+
                 "&mealHour="+$("mealHour").value+
                 "&mealMin="+$("mealMin").value+
                 "&mealtakenyes="+$("mealtakenyes").checked+
                 "&showNutrients="+($("patientMealNutricientList").style.display!="none");
    $("operationByAjax").update("<div id='wait'></div>");
    var url = "<c:url value='meals/ajax/setPatientMeal.jsp'/>?ts="+new Date().getTime();
    new Ajax.Updater("operationByAjax",url,{parameters:params,evalScripts:true});
  }
    
  <%-- SET PATIENT PROFILE --%>
  function setPatientProfile(id){
    var params = "action=save"+
                 "&profileId="+id+
                 "&chosenDate="+encodeURI($F("datechoosed"))+
                 "&showNutrients="+($("patientMealNutricientList").style.display!="none");
    $("operationByAjax").update("<div id='wait'></div>");    
    var url = "<c:url value='/meals/ajax/setPatientProfile.jsp'/>?ts="+new Date().getTime();
    new Ajax.Updater("operationByAjax",url,{parameters:params,evalScripts:true});
  }

  <%-- DELETE MEAL FROM PATIENT --%>
  function deleteMealFromPatient(id){
    mealuid = id;
    yesnoModalBox("deleteMealFromPatientNext()","<%=getTranNoLink("web","areYouSureToDelete",sWebLanguage)%>");
  }
    
  <%-- DELETE MEAL FROM PATIENT NEXT --%>
  function deleteMealFromPatientNext(){
    var params = "action=delete"+
                 "&mealId="+mealuid+
                 "&chosenDate="+encodeURI($F("datechoosed"));
    $("operationByAjax").update("<div id='wait'></div>");
    var url = "<c:url value='/meals/ajax/setPatientMeal.jsp'/>?ts="+new Date().getTime();
    new Ajax.Updater("operationByAjax",url,{parameters:params,evalScripts:true});
  }
    
  <%-- SET MEAL TAKEN --%>
  function setMealTaken(mealid,taken){
    var params = "mealId="+mealid+
                 "&taken="+taken+
                 "&chosenDate="+encodeURI($F("datechoosed"))+
                 "&showNutrients="+($("patientMealNutricientList").style.display!="none");
    var url = "<c:url value='/meals/ajax/setMealTaken.jsp'/>?ts="+new Date().getTime();
    new Ajax.Updater("operationByAjax",url,{parameters:params,evalScripts:true});
  }
    
  <%-- GET NUTRICIENTS IN PATIENT PROFILE --%>
  function getNutricientsInPatientProfile(noToggle){
	if(noToggle==null) noToggle = false;
    var id = "profileNutricientsList";
    
    if((!noToggle && $(id).childElements().length > 0)){
      $(id).innerHTML = "";
      $(id).style.display = "none";
      
      if($("mealNutricientsButton").hasClassName("up")){
        $("mealNutricientsButton").removeClassName("up");
        $("mealNutricientsButton").addClassName("down");
      }
    }
    else{
      if($("mealNutricientsButton").hasClassName("down")){
        $("mealNutricientsButton").removeClassName("down");
        $("mealNutricientsButton").addClassName("up");
      }

      if($("mealNutricientsRefresh")){
    	$("mealNutricientsRefresh").style.display = "inline";
      }

      $(id).style.display = "table";
      $(id).update("<div id='wait'></div>");
      
      var params = "ts="+new Date().getTime();
      var elements = $("patientProfileItems").childElements();
      var reg = new RegExp("[_]+","g");
      var items = "&meals=";
      elements.each(function(s){
        if(s.id.length>0){
          var t = s.id.split(reg);
          items+= t[1]+",";
        }
      });
      params+= items;

      $(id).style.display = "table";
      var url = "<c:url value='meals/ajax/getProfileNutricients.jsp'/>";
      new Ajax.Updater(id,url,{parameters:params,evalScripts:true});
    }
  }
  
  <%-- GET NUTRICIENTS IN PATIENT MEALS --%>
  function getNutricientsInPatientMeals(noToggle){
	if(noToggle==null) noToggle = false;
    var id = "patientMealNutricientList";
    
    if(!noToggle && $(id).childElements().length > 0){
      $(id).innerHTML = "";
      $(id).style.display = "none";
      
      if($("mealNutricientsButton").hasClassName("up")){
        $("mealNutricientsButton").removeClassName("up");
        $("mealNutricientsButton").addClassName("down");
      }
    }
    else{
      if($("mealNutricientsButton").hasClassName("down")){
        $("mealNutricientsButton").removeClassName("down");
        $("mealNutricientsButton").addClassName("up");
      }

      if($("mealNutricientsRefresh")){
    	$("mealNutricientsRefresh").style.display = "inline";
      }

      $(id).style.display = "table";
      $(id).update("<div id='wait'></div>");
      
      var params = "ts="+new Date().getTime();
      var elements = $("patientmeals").getElementsBySelector("TR");
      var reg = new RegExp("[_]+","g");
      var items = "&meals=";
      elements.each(function(s){
        if(s.id.length > 0){
          var t = s.id.split(reg);
          items+= t[1]+",";
        }
      });
      params+= items;

      $(id).style.display = "table";
      var url = "<c:url value='meals/ajax/getMealNutricients.jsp'/>";
      new Ajax.Updater(id,url,{parameters:params,evalScripts:true});
    }
  }

  <%-- INIT CALENDAR --%>
  function initCalendar(){
    getToday($("datechoosed"));
    addDays($F('datechoosed'),0);
  }
    
  <%-- ADD DAYS --%>
  function addDays(d,j){
    var date = new Date(makeDate(d).getTime()+(1000*60*60*24*j));
    if(date){
	  if(this.format=="us"){	
        $('datechoosed').value = (date.getDate()>9?"":"0")+date.getDate()+"/"+
                                 (date.getMonth()>8?"":"0")+(date.getMonth()+1)+"/"+
                                 y2k(date.getYear());
	  }
	  else{	
        $('datechoosed').value = (date.getMonth()>8?"":"0")+(date.getMonth()+1)+"/"+
                                 (date.getDate()>9?"":"0")+date.getDate()+"/"+
                                 y2k(date.getYear());
	  }
    }	

    CL = new GnooCalendar("CL",20,10,null,date);
    CL.change("gnoocalendar",$("datechoosed"),date);
    CL.show();
    CL.setTitle("");
       
    getPatientMeals();
  }
</script>