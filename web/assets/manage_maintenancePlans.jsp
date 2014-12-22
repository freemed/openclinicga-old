<%@page import="be.openclinic.assets.MaintenancePlan,
               java.text.*"%>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>
<%@include file="../assets/includes/commonFunctions.jsp"%>
<%=checkPermission("maintenancePlans","edit",activeUser)%>

<%=sJSPROTOTYPE%>
<%=sJSNUMBER%> 
<%=sJSSTRINGFUNCTIONS%>
<%=sJSSORTTABLE%>
<%=sJSEMAIL%>

<%
    /// DEBUG /////////////////////////////////////////////////////////////////////////////////////
    if(Debug.enabled){
        Debug.println("\n****************** assets/manage_maintenancePlans.jsp *****************");
        Debug.println("no parameters\n");
    }
    ///////////////////////////////////////////////////////////////////////////////////////////////
%>            

<form name="SearchForm" id="SearchForm" method="POST">
    <%=writeTableHeader("web.assets","maintenancePlans",sWebLanguage,"")%>
                
    <table class="list" border="0" width="100%" cellspacing="1">        
        <%-- search NAME --%>
        <tr>
            <td class="admin" width="<%=sTDAdminWidth%>"><%=getTran("web","name",sWebLanguage)%>&nbsp;</td>
            <td class="admin2">
                <input type="text" class="text" id="searchName" name="searchName" size="40" maxLength="50" value="">
            </td>
        </tr>     
        
        <%-- search ASSET --%>    
        <tr>
            <td class="admin"><%=getTran("web.assets","asset",sWebLanguage)%>&nbsp;</td>
            <td class="admin2">
                <input type="hidden" name="searchAssetUID" id="searchAssetUID" value="">
                <input type="text" class="text" id="searchAssetCode" name="searchAssetCode" size="20" readonly value="">
                                   
                <%-- buttons --%>
                <img src="<c:url value="/_img/icons/icon_search.gif"/>" class="link" alt="<%=getTranNoLink("web","select",sWebLanguage)%>" onclick="selectAsset('searchAssetUID','searchAssetCode');">
                <img src="<c:url value="/_img/icons/icon_delete.gif"/>" class="link" alt="<%=getTranNoLink("web","clear",sWebLanguage)%>" onclick="clearAssetSearchFields();">
            </td>
        </tr>  
        
        <%-- search OPERATOR (person) --%>
        <tr>
            <td class="admin"><%=getTran("web","operator",sWebLanguage)%>&nbsp;</td>
            <td class="admin2">
                <input type="text" class="text" id="searchOperator" name="searchOperator" size="40" maxLength="50" value="">
            </td>
        </tr>     
                    
        <%-- search BUTTONS --%>
        <tr>     
            <td class="admin"/>
            <td class="admin2" colspan="2">
                <input class="button" type="button" name="buttonSearch" id="buttonSearch" value="<%=getTranNoLink("web","search",sWebLanguage)%>" onclick="searchMaintenancePlans();">&nbsp;
                <input class="button" type="button" name="buttonClear" id="buttonClear" value="<%=getTranNoLink("web","clear",sWebLanguage)%>" onclick="clearSearchFields();">&nbsp;
            </td>
        </tr>
    </table>
</form>

<script>
  SearchForm.searchName.focus();

  <%-- SEARCH MAINTENANCE PLANS --%>
  function searchMaintenancePlans(){
    document.getElementById("divMaintenancePlans").innerHTML = "<img src='<%=sCONTEXTPATH%>/_img/themes/<%=sUserTheme%>/ajax-loader.gif'/><br>Searching";            
    var url = "<c:url value='/assets/ajax/maintenancePlan/getMaintenancePlans.jsp'/>?ts="+new Date().getTime();
    new Ajax.Request(url,{       
      method: "GET",
      parameters: "name="+encodeURIComponent(SearchForm.searchName.value)+
                  "&assetUID="+encodeURIComponent(SearchForm.searchAssetUID.value)+
                  //"&assetCode="+encodeURIComponent(SearchForm.searchAssetCode.value)+
                  "&operator="+encodeURIComponent(SearchForm.searchOperator.value),
      onSuccess: function(resp){
        $("divMaintenancePlans").innerHTML = resp.responseText;
        sortables_init();
      },
      onFailure: function(resp){
        $("divMessage").innerHTML = "Error in 'assets/ajax/maintenancePlan/getMaintenancePlans.jsp' : "+resp.responseText.trim();
      }
    });
  }

  <%-- CLEAR SEARCH FIELDS --%>
  function clearSearchFields(){
    document.getElementById("searchName").value = "";
    clearAssetSearchFields();
    document.getElementById("searchOperator").value = "";
    
    document.getElementById("searchName").focus();
    resizeAllTextareas(8);
  }
  
  <%-- SELECT ASSET --%>
  function selectAsset(uidField,codeField){
    var url = "/_common/search/searchAsset.jsp&ts=<%=getTs()%>"+
              "&ReturnFieldUid="+uidField+
              "&ReturnFieldCode="+codeField;
    openPopup(url);
    document.getElementById(codeField).focus();
  }  
</script>

<div id="divMaintenancePlans" class="searchResults" style="width:100%;height:160px;"></div>

<form name="EditForm" id="EditForm" method="POST">
    <input type="hidden" id="EditPlanUID" name="EditPlanUID" value="-1">
                
    <table class="list" border="0" width="100%" cellspacing="1">
        <%-- name (*) --%>
        <tr>
            <td class="admin" width="<%=sTDAdminWidth%>"><%=getTran("web.assets","name",sWebLanguage)%>&nbsp;*&nbsp;</td>
            <td class="admin2">
                <input type="text" class="text" id="name" name="name" size="20" maxLength="30" value="">
            </td>
        </tr>
        
        <%-- asset (code) (*) --%>
        <tr>
            <td class="admin"><%=getTran("web.assets","asset",sWebLanguage)%>&nbsp;*&nbsp;</td>
            <td class="admin2">
                <input type="hidden" name="assetUID" id="assetUID" value="">
                <input type="text" class="text" id="assetCode" name="assetCode" size="20" value="" readonly>
                
                <%-- BUTTONS --%>
                <img src="<c:url value="/_img/icons/icon_search.gif"/>" class="link" alt="<%=getTranNoLink("web","select",sWebLanguage)%>" onclick="selectAsset('assetUID','assetCode');">
                <img src="<c:url value="/_img/icons/icon_delete.gif"/>" class="link" alt="<%=getTranNoLink("web","clear",sWebLanguage)%>" onclick="clearAssetFields();">
            </td>
        </tr>
             
        <%-- startDate --%>
        <tr>
            <td class="admin"><%=getTran("web.assets","startDate",sWebLanguage)%>&nbsp;</td>
            <td class="admin2">
                <%=writeDateField("startDate","EditForm","",sWebLanguage)%>
            </td>
        </tr>   
             
        <%-- frequency --%>
        <tr>
            <td class="admin"><%=getTran("web.assets","frequency",sWebLanguage)%>&nbsp;</td>
            <td class="admin2">
                <input type="text" class="text" id="frequency" name="frequency" size="5" maxLength="5" value="" onKeyUp="isNumber(this);">&nbsp;<%=getTran("web","days",sWebLanguage)%>&nbsp;
            </td>
        </tr>  
             
        <%-- operator (person) --%>
        <tr>
            <td class="admin"><%=getTran("web.assets","operator",sWebLanguage)%>&nbsp;</td>
            <td class="admin2">
                <input type="text" class="text" id="operator" name="operator" size="40" maxLength="50" value="">
            </td>
        </tr>  
             
        <%-- plan manager (emailaddress) --%>
        <tr>
            <td class="admin"><%=getTran("web.assets","planManagerEmail",sWebLanguage)%>&nbsp;</td>
            <td class="admin2">
                <input type="text" name="planManager" id="planManager" size="40" maxLength="60" value="">
            </td>
        </tr>  
       
        <%-- instructions --%>                
        <tr>
            <td class="admin"><%=getTran("web.assets","instructions",sWebLanguage)%></td>
            <td class="admin2">
                <textarea class="text" name="instructions" id="instructions" cols="80" rows="4" onKeyup="resizeTextarea(this,8);"></textarea>
            </td>
        </tr>                       
            
        <%-- BUTTONS --%>
        <tr>     
            <td class="admin"/>
            <td class="admin2" colspan="2">
                <input class="button" type="button" name="buttonSave" id="buttonSave" value="<%=getTranNoLink("web","save",sWebLanguage)%>" onclick="saveMaintenancePlan();">&nbsp;
                <input class="button" type="button" name="buttonDelete" id="buttonDelete" value="<%=getTranNoLink("web","delete",sWebLanguage)%>" onclick="deleteMaintenancePlan();" style="visibility:hidden;">&nbsp;
                <input class="button" type="button" name="buttonNew" id="buttonNew" value="<%=getTranNoLink("web","new",sWebLanguage)%>" onclick="newMaintenancePlan();" style="visibility:hidden;">&nbsp;
            </td>
        </tr>
    </table>
    <i><%=getTran("web","colored_fields_are_obligate",sWebLanguage)%></i>
    
    <div id="divMessage" style="padding-top:10px;"></div>
</form>
    
<script>
  <%-- SAVE MAINTENANCE PLAN --%>
  function saveMaintenancePlan(){
    var okToSubmit = true;
    
    <%-- check required fields --%>
    if(requiredFieldsProvided()){
      <%-- check email (planManager) --%>
      if(okToSubmit==true){
        if(EditForm.planManager.value.length > 0){
          if(!validEmailAddress(EditForm.planManager.value)){
            okToSubmit = false;            
            alertDialog("Web","invalidemailaddress");
            EditForm.planManager.focus();
          }
        }
      }
    
      if(okToSubmit==true){
        document.getElementById("divMessage").innerHTML = "<img src='<%=sCONTEXTPATH%>/_img/themes/<%=sUserTheme%>/ajax-loader.gif'/><br>Saving";  
        disableButtons();
        
        var sParams = "EditPlanUID="+EditForm.EditPlanUID.value+
                      "&name="+EditForm.name.value+
                      "&assetUID="+EditForm.assetUID.value+
                      "&startDate="+EditForm.startDate.value+
                      "&frequency="+EditForm.frequency.value+
                      "&operator="+EditForm.operator.value+
                      "&planManager="+EditForm.planManager.value+
                      "&instructions="+EditForm.instructions.value;

        var url = "<c:url value='/assets/ajax/maintenancePlan/saveMaintenancePlan.jsp'/>?ts="+new Date().getTime();
        new Ajax.Request(url,{
          method: "POST",
          postBody: sParams,                   
          onSuccess: function(resp){
            var data = eval("("+resp.responseText+")");
            $("divMessage").innerHTML = data.message;

            //loadMaintenancePlan();
            searchMaintenancePlans();
            newMaintenancePlan();
            enableButtons();
          },
          onFailure: function(resp){
            $("divMessage").innerHTML = "Error in 'assets/ajax/maintenancePlan/saveMaintenancePlan.jsp' : "+resp.responseText.trim();
          }
        });
      }
    }
    else{
                window.showModalDialog?alertDialog("web.manage","dataMissing"):alertDialogDirectText('<%=getTran("web.manage","dataMissing",sWebLanguage)%>');
      
      <%-- focus empty field --%>
           if(document.getElementById("name").value.length==0)      document.getElementById("name").focus();    
      else if(document.getElementById("assetCode").value.length==0) document.getElementById("assetCode").focus();          
    }
  }
  
  <%-- REQUIRED FIELDS PROVIDED --%>
  function requiredFieldsProvided(){
    return (document.getElementById("name").value.length > 0 && 
            document.getElementById("assetCode").value.length > 0);
  }
  
  <%-- LOAD MAINTENANCEPLANS --%>
  function loadMaintenancePlans(){
    document.getElementById("divMaintenancePlans").innerHTML = "<img src='<%=sCONTEXTPATH%>/_img/themes/<%=sUserTheme%>/ajax-loader.gif'/><br>Loading..";            
    var url = "<c:url value='/assets/ajax/maintenancePlan/getMaintenancePlans.jsp'/>?ts="+new Date().getTime();
    new Ajax.Request(url,{
      method: "GET",
      parameters: "",
      onSuccess: function(resp){
        $("divMaintenancePlans").innerHTML = resp.responseText;
        sortables_init();
      },
      onFailure: function(resp){
        $("divMessage").innerHTML = "Error in 'assets/ajax/maintenancePlan/getMaintenancePlans.jsp' : "+resp.responseText.trim();
      }
    });
  }

  <%-- DISPLAY MAINTENANCEPLAN --%>
  function displayMaintenancePlan(planUID){
    var url = "<c:url value='/assets/ajax/maintenancePlan/getMaintenancePlan.jsp'/>?ts="+new Date().getTime();
    new Ajax.Request(url,{
      method: "GET",
      parameters: "planUID="+planUID,
      onSuccess: function(resp){
        var data = eval("("+resp.responseText+")");
         
        $("EditPlanUID").value = data.planUID;
        $("name").value = data.name.unhtmlEntities();
        $("assetUID").value = data.assetUID;
        $("assetCode").value = data.assetCode;
        $("startDate").value = data.startDate.unhtmlEntities();
        $("frequency").value = data.frequency;
        $("operator").value = data.operator.unhtmlEntities();
        $("planManager").value = data.planManager.unhtmlEntities();
        $("instructions").value = replaceAll(data.instructions.unhtmlEntities(),"<br>","\n");
          
        document.getElementById("divMessage").innerHTML = ""; 
        resizeAllTextareas(8);

        <%-- display hidden buttons --%>
        document.getElementById("buttonDelete").style.visibility = "visible";
        document.getElementById("buttonNew").style.visibility = "visible";
      },
      onFailure: function(resp){
        $("divMessage").innerHTML = "Error in 'assets/ajax/maintenancePlan/getMaintenancePlan.jsp' : "+resp.responseText.trim();
      }
    });
  }
  
  <%-- DELETE MAINTENACEPLAN --%>
  function deleteMaintenancePlan(){
      if(yesnoDeleteDialog()){
      disableButtons();
      
      var url = "<c:url value='/assets/ajax/maintenancePlan/deleteMaintenancePlan.jsp'/>?ts="+new Date().getTime();
      new Ajax.Request(url,{
        method: "GET",
        parameters: "PlanUID="+document.getElementById("EditPlanUID").value,
        onSuccess: function(resp){
          var data = eval("("+resp.responseText+")");
          $("divMessage").innerHTML = data.message;

          newMaintenancePlan();
          //loadMaintenancePlan();
          searchMaintenancePlans();
          enableButtons();
        },
        onFailure: function(resp){
          $("divMessage").innerHTML = "Error in 'assets/ajax/maintenancePlan/deleteMaintenancePlan.jsp' : "+resp.responseText.trim();
        }  
      });
    }
  }

  <%-- NEW MAINTENANCEPLAN --%>
  function newMaintenancePlan(){                   
    <%-- hide irrelevant buttons --%>
    document.getElementById("buttonDelete").style.visibility = "hidden";
    document.getElementById("buttonNew").style.visibility = "hidden";
    
    $("EditPlanUID").value = "-1";  
    $("name").value = "";
    $("assetUID").value = "";
    $("assetCode").value = "";
    $("startDate").value = "";
    $("frequency").value = "";
    $("operator").value = "";
    $("planManager").value = "";
    $("instructions").value = "";  
    
    $("name").focus();
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

  <%-- CLEAR ASSET SEARCHFIELDS --%>
  function clearAssetSearchFields(){
    $("searchAssetUID").value = "";
    $("searchAssetCode").value = "";
    
    $("searchAssetCode").focus();
  }
  
  <%-- CLEAR ASSET FIELDS --%>
  function clearAssetFields(){
    $("assetUID").value = "";
    $("assetCode").value = "";
    
    $("assetCode").focus();
  }
            
  //EditForm.code.focus();
  //loadMaintenancePlan();
  resizeAllTextareas(8);
</script>