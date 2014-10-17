<%@page import="be.openclinic.assets.MaintenanceOperation,
               java.text.*"%>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>
<%@include file="../assets/includes/commonFunctions.jsp"%>
<%=checkPermission("maintenanceOperations","edit",activeUser)%>

<%=sJSPROTOTYPE%>
<%=sJSNUMBER%> 
<%=sJSSTRINGFUNCTIONS%>
<%=sJSSORTTABLE%>

<%
    /// DEBUG /////////////////////////////////////////////////////////////////////////////////////
    if(Debug.enabled){
        Debug.println("\n*************** assets/manage_maintenanceOperations.jsp ***************");
        Debug.println("no parameters\n");
    }
    ///////////////////////////////////////////////////////////////////////////////////////////////
%>            

<form name="SearchForm" id="SearchForm" method="POST">
    <%=writeTableHeader("web.assets","maintenanceOperations",sWebLanguage,"")%>
                
    <table class="list" border="0" width="100%" cellspacing="1">
        <%-- search maintenance PLAN --%>
        <tr>
            <td class="admin" width="<%=sTDAdminWidth%>"><%=getTran("web.assets","maintenancePlan",sWebLanguage)%>&nbsp;</td>
            <td class="admin2">
                <input type="hidden" name="searchMaintenancePlanUID" id="searchMaintenancePlanUID" value="">
                <input type="text" class="text" id="searchMaintenancePlanName" name="searchMaintenancePlanName" size="20" readonly value="">
                                   
                <%-- buttons --%>
                <img src="<c:url value="/_img/icons/icon_search.gif"/>" class="link" alt="<%=getTranNoLink("web","select",sWebLanguage)%>" onclick="selectMaintenancePlan('searchMaintenancePlanUID','searchMaintenancePlanName');">
                <img src="<c:url value="/_img/icons/icon_delete.gif"/>" class="link" alt="<%=getTranNoLink("web","clear",sWebLanguage)%>" onclick="clearMaintenancePlanSearchFields();">
            </td>
        </tr>   
        
        <%-- search PERIOD PERFORMED --%>
        <tr>
            <td class="admin"><%=getTran("web.assets","periodPerformed",sWebLanguage)%>&nbsp;</td>
            <td class="admin2">
                <%=writeDateField("searchPeriodPerformedBegin","SearchForm","",sWebLanguage)%>&nbsp;&nbsp;<%=getTran("web","until",sWebLanguage)%>&nbsp;&nbsp; 
                <%=writeDateField("searchPeriodPerformedEnd","SearchForm","",sWebLanguage)%>            
            </td>                        
        </tr>        
        
        <%-- search OPERATOR (person) --%>
        <tr>
            <td class="admin"><%=getTran("web.assets","operator",sWebLanguage)%>&nbsp;</td>
            <td class="admin2">
                <input type="text" class="text" id="searchOperator" name="searchOperator" size="40" maxLength="50" value="">
            </td>
        </tr>     
        
        <%-- search RESULT --%>
        <tr>
            <td class="admin"><%=getTran("web.assets","result",sWebLanguage)%>&nbsp;</td>
            <td class="admin2">                
                <select class="text" id="searchResult" name="searchResult">
                    <option/>
                    <%=ScreenHelper.writeSelect("assets.maintenanceoperations.result","",sWebLanguage)%>
                </select>
            </td>
        </tr>
                    
        <%-- search BUTTONS --%>
        <tr>     
            <td class="admin"/>
            <td class="admin2" colspan="2">
                <input class="button" type="button" name="buttonSearch" id="buttonSearch" value="<%=getTranNoLink("web","search",sWebLanguage)%>" onclick="searchMaintenanceOperations();">&nbsp;
                <input class="button" type="button" name="buttonClear" id="buttonClear" value="<%=getTranNoLink("web","clear",sWebLanguage)%>" onclick="clearSearchFields();">&nbsp;
            </td>
        </tr>
    </table>
</form>

<script>
  SearchForm.searchMaintenancePlanName.focus();
  
  <%-- CLEAR MAINTENANCE PLAN SEARCH FIELDS --%>
  function clearMaintenancePlanSearchFields(){
    $("searchMaintenancePlanUID").value = "";
    $("searchMaintenancePlanName").value = "";
    
    $("searchMaintenancePlanName").focus();
  }
  
  <%-- SEARCH MAINTENANCE OPERATIONS --%>
  function searchMaintenanceOperations(){
	var okToSearch = true;
	
    <%-- periodBegin can not be after periodEnd --%>
    if(document.getElementById("searchPeriodPerformedEnd").value.length > 0){
      var periodBegin = makeDate(document.getElementById("searchPeriodPerformedBegin").value),
          periodEnd   = makeDate(document.getElementById("searchPeriodPerformedEnd").value);
        
      if(periodBegin > periodEnd){
    	okToSearch = false;
        alertDialog("web","beginMustComeBeforeEnd");
        document.getElementById("searchPeriodPerformedBegin").focus();
      }  
    }
      
    if(okToSearch==true){
      document.getElementById("divMaintenanceOperations").innerHTML = "<img src='<%=sCONTEXTPATH%>/_img/themes/<%=sUserTheme%>/ajax-loader.gif'/><br>Searching";            
      var url = "<c:url value='/assets/ajax/maintenanceOperation/getMaintenanceOperations.jsp'/>?ts="+new Date().getTime();
      new Ajax.Request(url,
        {
          method: "GET",
          parameters: "planUID="+encodeURIComponent(SearchForm.searchMaintenancePlanUID.value)+
                      "&periodPerformedBegin="+encodeURIComponent(SearchForm.searchPeriodPerformedBegin.value)+
                      "&periodPerformedEnd="+encodeURIComponent(SearchForm.searchPeriodPerformedEnd.value)+
                      "&operator="+encodeURIComponent(SearchForm.searchOperator.value)+
                      "&result="+encodeURIComponent(SearchForm.searchResult.value),
          onSuccess: function(resp){
            $("divMaintenanceOperations").innerHTML = resp.responseText;
            sortables_init();
          },
          onFailure: function(resp){
            $("divMessage").innerHTML = "Error in 'assets/ajax/maintenanceOperation/getMaintenanceOperations.jsp' : "+resp.responseText.trim();
          }
        }
      );
    }
  }
  
  <%-- CLEAR SEARCH FIELDS --%>
  function clearSearchFields(){
    clearMaintenancePlanSearchFields();
    document.getElementById("searchPeriodPerformedBegin").value = "";
    document.getElementById("searchPeriodPerformedEnd").value = "";
    document.getElementById("searchOperator").value = "";
    document.getElementById("searchResult").value = "";
    
    resizeAllTextareas(8);
  }
</script>

<div id="divMaintenanceOperations" class="searchResults" style="width:100%;height:160px;"></div>

<form name="EditForm" id="EditForm" method="POST">
    <input type="hidden" id="EditOperationUID" name="EditOperationUID" value="-1">
                
    <table class="list" border="0" width="100%" cellspacing="1">
        <%-- MAINTENANCE PLAN (*) --%>
        <tr>
            <td class="admin" width="<%=sTDAdminWidth%>"><%=getTran("web.assets","maintenancePlan",sWebLanguage)%>&nbsp;*&nbsp;</td>
            <td class="admin2">
                <input type="hidden" name="maintenancePlanUID" id="maintenancePlanUID" value="">
                <input type="text" class="text" id="maintenancePlanName" name="maintenancePlanName" size="20" readonly value="">
                                   
                <%-- buttons --%>
                <img src="<c:url value="/_img/icons/icon_search.gif"/>" class="link" alt="<%=getTranNoLink("web","select",sWebLanguage)%>" onclick="selectMaintenancePlan('maintenancePlanUID','maintenancePlanName');">
                <img src="<c:url value="/_img/icons/icon_delete.gif"/>" class="link" alt="<%=getTranNoLink("web","clear",sWebLanguage)%>" onclick="clearMaintenancePlanFields();">
            </td>
        </tr>   
        
        <%-- DATE (*) --%>
        <tr>
            <td class="admin"><%=getTran("web.assets","date",sWebLanguage)%>&nbsp;*&nbsp;</td>
            <td class="admin2">
                <%=writeDateField("date","EditForm","",sWebLanguage)%>
            </td>
        </tr> 
            
        <%-- OPERATOR (*) --%>
        <tr>
            <td class="admin"><%=getTran("web.assets","operator",sWebLanguage)%>&nbsp;*&nbsp;</td>
            <td class="admin2">
                <input type="text" class="text" id="operator" name="operator" size="40" maxLength="50" value="">
            </td>
        </tr>      
        
        <%-- RESULT (*) --%>
        <tr>
            <td class="admin"><%=getTran("web.assets","result",sWebLanguage)%>&nbsp;*&nbsp;</td>
            <td class="admin2">                
                <select class="text" id="result" name="result">
                    <option value=""><%=getTranNoLink("web","choose",sWebLanguage)%></option>
                    <%=ScreenHelper.writeSelect("assets.maintenanceoperations.result","",sWebLanguage)%>
                </select>
            </td>
        </tr>
        
        <%-- COMMENT --%>                
        <tr>
            <td class="admin"><%=getTran("web","comment",sWebLanguage)%></td>
            <td class="admin2">
                <textarea class="text" name="comment" id="comment" cols="80" rows="4" onKeyup="resizeTextarea(this,8);limitChars(this,255);"></textarea>
            </td>
        </tr>
               
        <%-- NEXT DATE --%>
        <tr>
            <td class="admin"><%=getTran("web.assets","nextMaintenanceDate",sWebLanguage)%></td>
            <td class="admin2">
                <%=writeDateField("nextDate","EditForm","",sWebLanguage)%>
            </td>
        </tr>                    
            
        <%-- BUTTONS --%>
        <tr>     
            <td class="admin"/>
            <td class="admin2" colspan="2">
                <input class="button" type="button" name="buttonSave" id="buttonSave" value="<%=getTranNoLink("web","save",sWebLanguage)%>" onclick="saveMaintenanceOperation();">&nbsp;
                <input class="button" type="button" name="buttonDelete" id="buttonDelete" value="<%=getTranNoLink("web","delete",sWebLanguage)%>" onclick="deleteMaintenanceOperation();" style="visibility:hidden;">&nbsp;
                <input class="button" type="button" name="buttonNew" id="buttonNew" value="<%=getTranNoLink("web","new",sWebLanguage)%>" onclick="newMaintenanceOperation();" style="visibility:hidden;">&nbsp;
            </td>
        </tr>
    </table>
    <i><%=getTran("web","colored_fields_are_obligate",sWebLanguage)%></i>
    
    <div id="divMessage" style="padding-top:10px;"></div>
</form>
    
<script>
  <%-- SELECT MAINTENANCE PLAN --%>
  function selectMaintenancePlan(uidField,codeField){
    var url = "/_common/search/searchMaintenancePlan.jsp&ts=<%=getTs()%>"+
              "&ReturnFieldUid="+uidField+
              "&ReturnFieldCode="+codeField;
    openPopup(url);
    document.getElementById(codeField).focus();
  }  

  <%-- SAVE MAINTENANCE OPERATION --%>
  function saveMaintenanceOperation(){
    var okToSubmit = true;
    
    <%-- check required fields --%>
    if(requiredFieldsProvided()){    	
      <%-- date can not be after nextDate --%>
      if(document.getElementById("nextDate").value.length > 0){
        var periodBegin = makeDate(document.getElementById("date").value),
            periodEnd   = makeDate(document.getElementById("nextDate").value);
            
        if(periodBegin > periodEnd){
        	okToSubmit = false;
          alertDialog("web","beginMustComeBeforeEnd");
          document.getElementById("date").focus();
        }  
      }
          
      if(okToSubmit==true){
        document.getElementById("divMessage").innerHTML = "<img src='<%=sCONTEXTPATH%>/_img/themes/<%=sUserTheme%>/ajax-loader.gif'/><br>Saving";  
        disableButtons();
        
        var sParams = "EditOperationUID="+EditForm.EditOperationUID.value+
                      "&maintenancePlanUID="+EditForm.maintenancePlanUID.value+
                      "&date="+EditForm.date.value+
                      "&operator="+EditForm.operator.value+
                      "&result="+EditForm.result.value+
                      "&comment="+EditForm.comment.value+
                      "&nextDate="+EditForm.nextDate.value;

        var url = "<c:url value='/assets/ajax/maintenanceOperation/saveMaintenanceOperation.jsp'/>?ts="+new Date().getTime();
        new Ajax.Request(url,
          {
            method: "POST",
            postBody: sParams,                   
            onSuccess: function(resp){
              var data = eval("("+resp.responseText+")");
              $("divMessage").innerHTML = data.message;

              //loadMaintenanceOperation();
              searchMaintenanceOperations();
              newMaintenanceOperation();
              enableButtons();
            },
            onFailure: function(resp){
              $("divMessage").innerHTML = "Error in 'assets/ajax/maintenanceOperation/saveMaintenanceOperation.jsp' : "+resp.responseText.trim();
            }
          }
        );
      }
    }
    else{
      alertDialog("web.manage","dataMissing");
      
      <%-- focus empty field --%>
           if(document.getElementById("maintenancePlanName").value.length==0) document.getElementById("maintenancePlanName").focus(); 
      else if(document.getElementById("date").value.length==0) document.getElementById("date").focus(); 
      else if(document.getElementById("operator").value.length==0) document.getElementById("operator").focus(); 
      else if(document.getElementById("result").value.length==0) document.getElementById("result").focus();          
    }
  }
  
  <%-- REQUIRED FIELDS PROVIDED --%>
  function requiredFieldsProvided(){
    return (document.getElementById("maintenancePlanUID").value.length > 0 &&
            document.getElementById("date").value.length > 0 &&
            document.getElementById("operator").value.length > 0 &&
            document.getElementById("result").selectedIndex > 0);
  }
  
  <%-- LOAD MAINTENANCE OPERATIONS --%>
  function loadMaintenanceOperations(){
    document.getElementById("divMaintenanceOperations").innerHTML = "<img src='<%=sCONTEXTPATH%>/_img/themes/<%=sUserTheme%>/ajax-loader.gif'/><br>Loading..";            
    var url = "<c:url value='/assets/ajax/maintenanceOperation/getMaintenanceOperations.jsp'/>?ts="+new Date().getTime();
    new Ajax.Request(url,{
      method: "GET",
      parameters: "",
      onSuccess: function(resp){
        $("divMaintenanceOperations").innerHTML = resp.responseText;
        sortables_init();
      },
      onFailure: function(resp){
        $("divMessage").innerHTML = "Error in 'assets/ajax/maintenanceOperation/getMaintenanceOperations.jsp' : "+resp.responseText.trim();
      }
    });
  }

  <%-- DISPLAY MAINTENANCE OPERATION --%>
  function displayMaintenanceOperation(operationUID){
    var url = "<c:url value='/assets/ajax/maintenanceOperation/getMaintenanceOperation.jsp'/>?ts="+new Date().getTime();
    new Ajax.Request(url,{
      method: "GET",
      parameters: "OperationUID="+operationUID,
      onSuccess: function(resp){
        var data = eval("("+resp.responseText+")");

        $("EditOperationUID").value = operationUID;
        $("maintenancePlanUID").value = data.maintenancePlanUID;
        $("maintenancePlanName").value = data.maintenancePlanName.unhtmlEntities();
        $("date").value = data.date;
        $("operator").value = data.operator.unhtmlEntities();
        $("result").value = data.result.unhtmlEntities();
        $("comment").value = replaceAll(data.comment.unhtmlEntities(),"<br>","\n");
        $("nextDate").value = data.nextDate;
          
        document.getElementById("divMessage").innerHTML = ""; 
        resizeAllTextareas(8);

        <%-- display hidden buttons --%>
        document.getElementById("buttonDelete").style.visibility = "visible";
        document.getElementById("buttonNew").style.visibility = "visible";
      },
      onFailure: function(resp){
        $("divMessage").innerHTML = "Error in 'assets/ajax/maintenanceOperation/getMaintenanceOperation.jsp' : "+resp.responseText.trim();
      }
    });
  }
  
  <%-- DELETE MAINTENANCE OPERATION --%>
  function deleteMaintenanceOperation(){
	if(yesnoDialog("Web","areYouSureToDelete")){       
      disableButtons();
      
      var url = "<c:url value='/assets/ajax/maintenanceOperation/deleteMaintenanceOperation.jsp'/>?ts="+new Date().getTime();
      new Ajax.Request(url,{
        method: "GET",
        parameters: "OperationUID="+document.getElementById("EditOperationUID").value,
        onSuccess: function(resp){
          var data = eval("("+resp.responseText+")");
          $("divMessage").innerHTML = data.message;

          newMaintenanceOperation();
          //loadMaintenanceOperations();
          searchMaintenanceOperations();
          enableButtons();
        },
        onFailure: function(resp){
          $("divMessage").innerHTML = "Error in 'assets/ajax/maintenanceOperation/deleteMaintenanceOperation.jsp' : "+resp.responseText.trim();
        }  
      });
    }
  }

  <%-- NEW MAINTENANCE OPERATION --%>
  function newMaintenanceOperation(){                   
    <%-- hide irrelevant buttons --%>
    document.getElementById("buttonDelete").style.visibility = "hidden";
    document.getElementById("buttonNew").style.visibility = "hidden";

    $("EditOperationUID").value = "-1";  
    $("maintenancePlanUID").value = "";
    $("maintenancePlanName").value = "";
    $("date").value = "";
    $("operator").value = "";
    $("result").selectedIndex = 0;
    $("comment").value = "";
    $("nextDate").value = "";
    
    $("maintenancePlanName").focus();
    resizeAllTextareas(8);
  }
  
  <%-- DISABLE BUTTONS --%>
  function disableButtons(){
    document.getElementById("buttonSave").disabled = true;
    document.getElementById("buttonDelete").disabled = true;
    document.getElementById("buttonNew").disabled = true;
  }
  
  <%-- ENABLE BUTTONS --%>
  function enableButtons(){
    document.getElementById("buttonSave").disabled = false;
    document.getElementById("buttonDelete").disabled = false;
    document.getElementById("buttonNew").disabled = false;
  }
  
  <%-- CLEAR MAINTENANCE PLAN FIELDS --%>
  function clearMaintenancePlanFields(){
    $("maintenancePlanUID").value = "";
    $("maintenancePlanName").value = "";
    
    $("maintenancePlanName").focus();
  }
            
  //EditForm.maintenancePlanName.focus();
  //loadMaintenanceOperations();
  resizeAllTextareas(8);
</script>