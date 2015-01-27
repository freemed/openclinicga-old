<%@page import="be.openclinic.hr.Career,
               java.text.*"%>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>
<%@include file="../hr/includes/commonFunctions.jsp"%>
<%=checkPermission("hr.career.edit","edit",activeUser)%>

<%=sJSPROTOTYPE%>
<%=sJSNUMBER%> 
<%=sJSSTRINGFUNCTIONS%>
<%=sJSSORTTABLE%>

<%
    /// DEBUG /////////////////////////////////////////////////////////////////
    if(Debug.enabled){
        Debug.println("\n**************** manage_career.jsp ****************");
        Debug.println("no parameters\n");
    }
    ///////////////////////////////////////////////////////////////////////////
%>            

<%=writeTableHeader("web","career",sWebLanguage,"")%><br>
<div id="divCareers" class="searchResults" style="width:100%;height:160px;"></div>

<form name="EditForm" id="EditForm" method="POST">
    <input type="hidden" id="EditCareerUid" name="EditCareerUid" value="-1">
                
    <table class="list" border="0" width="100%" cellspacing="1">
        <%-- period (begin & end date) --%>
        <tr>
            <td class="admin" width="<%=sTDAdminWidth%>"><%=getTran("web.hr","period",sWebLanguage)%>&nbsp;(<%=getTran("web.hr","begin",sWebLanguage)%>* - <%=getTran("web.hr","end",sWebLanguage)%>)</td>
            <td class="admin2">
                <%=writeDateField("careerBegin","EditForm","",sWebLanguage)%>&nbsp;&nbsp;<%=getTran("web","until",sWebLanguage)%>&nbsp;&nbsp; 
                <%=writeDateField("careerEnd","EditForm","",sWebLanguage)%>            
            </td>                        
        </tr>
        
        <%-- contract --%>  
        <tr>
            <td class="admin"><%=getTran("web.hr","contract",sWebLanguage)%>&nbsp;*&nbsp;</td>
            <td class="admin2">
                <input type="hidden" name="contract" id="contract" value="">
                <input type="text" class="text" name="contractName" id="contractName" readonly size="20" value="">
                   
                <%-- buttons --%>
                <img src="<c:url value="/_img/icons/icon_search.gif"/>" class="link" alt="<%=getTranNoLink("web","select",sWebLanguage)%>" onclick="searchContract('contract','contractName');">
                <img src="<c:url value="/_img/icons/icon_delete.gif"/>" class="link" alt="<%=getTranNoLink("web","clear",sWebLanguage)%>" onclick="document.getElementById('contract').value='';document.getElementById('contractName').value='';">
            </td>
        </tr>
        
        <%-- position --%>
        <tr>
            <td class="admin"><%=getTran("web.hr","position",sWebLanguage)%>&nbsp;*&nbsp;</td>
            <td class="admin2">
                <input type="text" class="text" id="position" name="position" size="50" maxLength="255" value="">
            </td>
        </tr>
                                
        <%-- department (service) --%>
        <tr>
            <td class="admin"><%=getTran("web","department",sWebLanguage)%>&nbsp;*&nbsp;</td>
            <td class="admin2">
                <input type="hidden" name="service" id="service" value="">
                <input type="text" class="text" name="serviceName" id="serviceName" readonly size="<%=sTextWidth%>" value="">
                   
                <%-- buttons --%>
                <img src="<c:url value="/_img/icons/icon_search.gif"/>" class="link" alt="<%=getTranNoLink("web","select",sWebLanguage)%>" onclick="searchService('service','serviceName');">
                <img src="<c:url value="/_img/icons/icon_delete.gif"/>" class="link" alt="<%=getTranNoLink("web","clear",sWebLanguage)%>" onclick="document.getElementById('service').value='';document.getElementById('serviceName').value='';">
            </td>
        </tr>
        
        <%-- grade --%>
        <tr>
            <td class="admin"><%=getTran("web.hr","grade",sWebLanguage)%></td>
            <td class="admin2">
                <select class="text" id="grade" name="grade">
                    <option/>
                    <%=ScreenHelper.writeSelect("hr.career.grade","",sWebLanguage)%>
                </select>
            </td>
        </tr>
            
        <%-- status --%>
        <tr>
            <td class="admin"><%=getTran("web.hr","status",sWebLanguage)%></td>
            <td class="admin2">
                <select class="text" id="status" name="status"> 
                    <option/>
                    <%=ScreenHelper.writeSelect("hr.career.status","",sWebLanguage)%>
                </select>
            </td>
        </tr>
        
        <%-- comment --%>                    
        <tr>
            <td class="admin"><%=getTran("web.hr","comment",sWebLanguage)%></td>
            <td class="admin2">
                <textarea class="text" name="comment" id="comment" cols="80" rows="4" onKeyup="resizeTextarea(this,8);"></textarea>
            </td>
        </tr>
            
        <%-- BUTTONS --%>
        <tr>     
            <td class="admin"/>
            <td class="admin2" colspan="2">
                <input class="button" type="button" name="buttonSave" id="buttonSave" value="<%=getTranNoLink("web","save",sWebLanguage)%>" onclick="saveCareer();">&nbsp;
                <input class="button" type="button" name="buttonDelete" id="buttonDelete" value="<%=getTranNoLink("web","delete",sWebLanguage)%>" onclick="deleteCareer();" style="visibility:hidden;">&nbsp;
                <input class="button" type="button" name="buttonNew" id="buttonNew" value="<%=getTranNoLink("web","new",sWebLanguage)%>" onclick="newCareer();" style="visibility:hidden;">&nbsp;
            </td>
        </tr>
    </table>
    <i><%=getTran("web","colored_fields_are_obligate",sWebLanguage)%></i>
    
    <div id="divMessage" style="padding-top:10px;"></div>
</form>
    
<script>
  <%-- SAVE CAREER --%>
  function saveCareer(){
    var okToSubmit = true;
    
    if(document.getElementById("careerBegin").value.length > 8 &&
       document.getElementById("contractName").value.length > 0 &&
       document.getElementById("position").value.length > 0 &&
       document.getElementById("service").value.length > 0
      ){     
      <%-- careerBegin can not be after carreerEnd --%>
      if(document.getElementById("careerEnd").value.length > 0){
        var careerBegin = makeDate(document.getElementById("careerBegin").value),
            careerEnd   = makeDate(document.getElementById("careerEnd").value);
        
        if(careerBegin > careerEnd){
          okToSubmit = false;
          alertDialog("web","beginMustComeBeforeEnd");
          document.getElementById("careerBegin").focus();
        }  
      }
      
      if(okToSubmit){
        document.getElementById("divMessage").innerHTML = "<img src='<%=sCONTEXTPATH%>/_img/themes/<%=sUserTheme%>/ajax-loader.gif'/><br>Saving";  
        var url = "<c:url value='/hr/ajax/career/saveCareer.jsp'/>?ts="+new Date().getTime();

        document.getElementById("buttonSave").disabled = true;
        document.getElementById("buttonDelete").disabled = true;
        document.getElementById("buttonNew").disabled = true;
        
        new Ajax.Request(url,{
          method: "POST",
          postBody: "EditCareerUid="+EditForm.EditCareerUid.value+
                    "&PersonId=<%=activePatient.personid%>"+
                    "&careerBegin="+document.getElementById("careerBegin").value+
                    "&careerEnd="+document.getElementById("careerEnd").value+
                    "&contractUid="+document.getElementById("contract").value+
                    "&position="+document.getElementById("position").value+
                    "&serviceUid="+document.getElementById("service").value+
                    "&grade="+document.getElementById("grade").value+
                    "&status="+document.getElementById("status").value+
                    "&comment="+document.getElementById("comment").value,
          onSuccess: function(resp){
            var data = eval("("+resp.responseText+")");
            $("divMessage").innerHTML = data.message;

            loadCareers();
            newCareer();
              
            //EditForm.EditCareerUid.value = data.newUid;
            document.getElementById("buttonSave").disabled = false;
            document.getElementById("buttonDelete").disabled = false;
            document.getElementById("buttonNew").disabled = false;
          },
          onFailure: function(resp){
            $("divMessage").innerHTML = "Error in 'hr/ajax/career/saveCareer.jsp' : "+resp.responseText.trim();
          }
        });
      }
    }
    else{
      alertDialog("web.manage","dataMissing");
      
      <%-- focus empty field --%>
           if(document.getElementById("careerBegin").value.length==0) document.getElementById("careerBegin").focus();
      else if(document.getElementById("contract").value.length==0) document.getElementById("contractName").focus();
      else if(document.getElementById("position").value.length==0) document.getElementById("position").focus();
      else if(document.getElementById("service").value.length==0) document.getElementById("serviceName").focus();          
    }
  }
    
  <%-- LOAD CAREERS --%>
  function loadCareers(){
    document.getElementById("divCareers").innerHTML = "<img src='<%=sCONTEXTPATH%>/_img/themes/<%=sUserTheme%>/ajax-loader.gif'/><br>Loading..";            
    var url = "<c:url value='/hr/ajax/career/getCareers.jsp'/>?ts="+new Date().getTime();
    new Ajax.Request(url,{
      method: "GET",
      parameters: "PatientId=<%=activePatient.personid%>",
      onSuccess: function(resp){
        $("divCareers").innerHTML = resp.responseText;
        setTimeout("sortables_init()",500);
      },
      onFailure: function(resp){
        $("divMessage").innerHTML = "Error in 'hr/ajax/career/getCareers.jsp' : "+resp.responseText.trim();
      }
    });
  }

  <%-- DISPLAY CAREER --%>
  function displayCareer(careerUid){          
    var url = "<c:url value='/hr/ajax/career/getCareer.jsp'/>?ts="+new Date().getTime();
    
    new Ajax.Request(url,{
      method: "GET",
      parameters: "CareerUid="+careerUid,
      onSuccess: function(resp){
        var data = eval("("+resp.responseText+")");

        $("EditCareerUid").value = careerUid;
        $("careerBegin").value = data.begin;
        $("careerEnd").value = data.end;
        $("contract").value = data.contractUid;
        $("contractName").value = data.contractName.unhtmlEntities();
        $("position").value = data.position.unhtmlEntities();
        $("service").value = data.serviceUid;
        $("serviceName").value = data.serviceName.unhtmlEntities();
        $("grade").value = data.grade.unhtmlEntities();
        $("status").value = data.status.unhtmlEntities();
        $("comment").value = replaceAll(data.comment.unhtmlEntities(),"<br>","\n");
          
        document.getElementById("divMessage").innerHTML = ""; 
        resizeAllTextareas(8);

        <%-- display hidden buttons --%>
        document.getElementById("buttonDelete").style.visibility = "visible";
        document.getElementById("buttonNew").style.visibility = "visible";
      },
      onFailure: function(resp){
        $("divMessage").innerHTML = "Error in 'hr/ajax/career/getCareer.jsp' : "+resp.responseText.trim();
      }
    });
  }
  
  <%-- DELETE CAREER --%>
  function deleteCareer(){ 
      if(yesnoDeleteDialog()){
      var url = "<c:url value='/hr/ajax/career/deleteCareer.jsp'/>?ts="+new Date().getTime();

      document.getElementById("buttonSave").disabled = true;
      document.getElementById("buttonDelete").disabled = true;
      document.getElementById("buttonNew").disabled = true;
    
      new Ajax.Request(url,{
    	method: "GET",
        parameters: "CareerUid="+document.getElementById("EditCareerUid").value,
        onSuccess: function(resp){
          var data = eval("("+resp.responseText+")");
          $("divMessage").innerHTML = data.message;

          newCareer();
          loadCareers();
          
          document.getElementById("buttonSave").disabled = false;
          document.getElementById("buttonDelete").disabled = false;
          document.getElementById("buttonNew").disabled = false;
        },
        onFailure: function(resp){
          $("divMessage").innerHTML = "Error in 'hr/ajax/career/deleteCareer.jsp' : "+resp.responseText.trim();
        }  
      });
    }
  }
  
  <%-- NEW CAREER --%>
  function newCareer(){                   
    <%-- hide irrelevant buttons --%>
    document.getElementById("buttonDelete").style.visibility = "hidden";
    document.getElementById("buttonNew").style.visibility = "hidden";

    $("EditCareerUid").value = "-1";
    $("careerBegin").value = "";
    $("careerEnd").value = "";
    $("contract").value = "";
    $("contractName").value = "";
    $("position").value = "";
    $("service").value = "";
    $("serviceName").value = "";
    $("grade").value = "";
    $("status").value = "";
    $("comment").value = "";   
    
    $("careerBegin").focus();
    resizeAllTextareas(8);
  }
    
  <%-- SEARCH SERVICE --%>
  function searchService(serviceUidField,serviceNameField){
    openPopup("/_common/search/searchService.jsp&ts=<%=getTs()%>&VarCode="+serviceUidField+"&VarText="+serviceNameField);
    document.getElementById(serviceNameField).focus();
  }
    
  <%-- SEARCH CONTRACT --%>
  function searchContract(contractUidField,contractIdField){
    var url = "/_common/search/searchContract.jsp&ts=<%=getTs()%>"+
              "&PersonId=<%=activePatient.personid%>"+
              "&ReturnFieldContractUid="+contractUidField+
              "&ReturnFieldContractId="+contractIdField;
    openPopup(url);
    document.getElementById(contractIdField).focus();
  }
    
  EditForm.careerBegin.focus();
  loadCareers();
  resizeAllTextareas(8);
</script>