<%@page import="be.openclinic.hr.Training,
               java.text.*"%>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>
<%@include file="../hr/includes/commonFunctions.jsp"%>
<%=checkPermission("hr.training.edit","edit",activeUser)%>

<%=sJSPROTOTYPE%>
<%=sJSNUMBER%> 
<%=sJSSTRINGFUNCTIONS%>
<%=sJSSORTTABLE%>

<%
    /// DEBUG /////////////////////////////////////////////////////////////////
    if(Debug.enabled){
        Debug.println("\n**************** manage_training.jsp **************");
        Debug.println("no parameters\n");
    }
    ///////////////////////////////////////////////////////////////////////////
%>            

<%=writeTableHeader("web","training",sWebLanguage,"")%><br>
<div id="divTrainings" class="searchResults" style="width:100%;height:160px;"></div>

<form name="EditForm" id="EditForm" method="POST">
    <input type="hidden" id="EditTrainingUid" name="EditTrainingUid" value="-1">
                
    <table class="list" border="0" width="100%" cellspacing="1">
        <%-- begin (*) --%>
        <tr>
            <td class="admin" width="<%=sTDAdminWidth%>"><%=getTran("web.hr","begin",sWebLanguage)%>&nbsp;*&nbsp;</td>
            <td class="admin2" nowrap> 
                <%=writeDateField("begin","EditForm","",sWebLanguage)%>            
            </td>                        
        </tr>
        
        <%-- end --%>
        <tr>
            <td class="admin"><%=getTran("web.hr","end",sWebLanguage)%></td>
            <td class="admin2" nowrap> 
                <%=writeDateField("end","EditForm","",sWebLanguage)%>            
            </td>                        
        </tr>
        
        <%-- institute --%>
        <tr>
            <td class="admin"><%=getTran("web.hr","trainingInstitute",sWebLanguage)%>&nbsp;*&nbsp;</td>
            <td class="admin2">
                <input type="text" class="text" id="institute" name="institute" size="50" maxLength="255" value="">
            </td>
        </tr>
        
        <%-- type --%>
        <tr>
            <td class="admin"><%=getTran("web.hr","trainingType",sWebLanguage)%></td>
            <td class="admin2">
                <input type="text" class="text" id="type" name="type" size="50" maxLength="50" value="">
            </td>
        </tr>
         
        <%-- level (*) --%>
        <tr>
            <td class="admin"><%=getTran("web.hr","trainingLevel",sWebLanguage)%>&nbsp;*&nbsp;</td>
            <td class="admin2">
                <select class="text" id="level" name="level">
                    <option/>
                    <%=ScreenHelper.writeSelect("hr.training.level","",sWebLanguage)%>
                </select>
            </td>
        </tr>
            
        <%-- diploma --%>
        <tr>
            <td class="admin"><%=getTran("web.hr","titleOrDiploma",sWebLanguage)%>&nbsp;*&nbsp;</td>
            <td class="admin2"> 
                <input type="text" class="text" id="diploma" name="diploma" size="80" maxLength="255" value="">
            </td>
        </tr>
        
        <%-- diplomaDate (*) --%>
        <tr>
            <td class="admin" width="<%=sTDAdminWidth%>"><%=getTran("web.hr","diplomaDate",sWebLanguage)%>&nbsp;*&nbsp;</td>
            <td class="admin2" nowrap> 
                <%=writeDateField("diplomaDate","EditForm","",sWebLanguage)%>            
            </td>                        
        </tr>
                    
        <%-- DIPLOMA CODES (dynamic) --%>
        <%            
            for(int i=1; i<=5; i++){ 
                if(MedwanQuery.getInstance().getConfigString("enableDiplomaCode"+i).equals("1")){
                    %>                    
                        <tr>
                            <td class="admin"><%=getTran("web.hr","diplomaCode",sWebLanguage)%> <%=i%></td>
                            <td class="admin2">                                                    
                                <select class="text" id="diplomaCode<%=i%>" name="diplomaCode<%=i%>">
                                    <option/>
                                    <%=ScreenHelper.writeSelect("hr.training.diplomacode"+i,"",sWebLanguage)%>
                                </select>
                            </td>
                        </tr>
                    <%
                }
            }
        %>            
            
        
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
                <input class="button" type="button" name="buttonSave" id="buttonSave" value="<%=getTranNoLink("web","save",sWebLanguage)%>" onclick="saveTraining();">&nbsp;
                <input class="button" type="button" name="buttonDelete" id="buttonDelete" value="<%=getTranNoLink("web","delete",sWebLanguage)%>" onclick="deleteTraining();" style="visibility:hidden;">&nbsp;
                <input class="button" type="button" name="buttonNew" id="buttonNew" value="<%=getTranNoLink("web","new",sWebLanguage)%>" onclick="newTraining();" style="visibility:hidden;">&nbsp;
            </td>
        </tr>
    </table>
    <i><%=getTran("web","colored_fields_are_obligate",sWebLanguage)%></i>
    
    <div id="divMessage" style="padding-top:10px;"></div>
</form>
    
<script>
  <%-- SAVE TRAINING --%>
  function saveTraining(){
    var okToSubmit = true;
    
    if(document.getElementById("begin").value.length > 8 &&
       document.getElementById("institute").value.length > 0 &&
       document.getElementById("level").value.length > 0 &&
       document.getElementById("diploma").value.length > 0 &&
       document.getElementById("diplomaDate").value.length > 0
      ){    
      if(okToSubmit){ 
        <%-- begin can not be after end --%>
        if(document.getElementById("end").value.length > 0){
          var begin = makeDate(document.getElementById("begin").value),
              end   = makeDate(document.getElementById("end").value);
      
          if(begin > end){
            okToSubmit = false;
            alertDialog("web","beginMustComeBeforeEnd");
            document.getElementById("begin").focus(); 
          }  
        }
      }
      
      if(okToSubmit){
        <%-- diplomaDate can not be before begin --%>
        if(document.getElementById("diplomaDate").value.length > 0 && document.getElementById("begin").value.length > 0){
          var diplomaDate = makeDate(document.getElementById("diplomaDate").value),
              begin       = makeDate(document.getElementById("begin").value);
      
          if(begin > diplomaDate){
            okToSubmit = false;
            alertDialog("web.hr","diplomaDateMustComeAfterBegin");
            document.getElementById("diplomaDate").focus();
          }  
        }
      }
      
      if(okToSubmit){
        <%-- diplomaDate can not be after end --%>
        if(document.getElementById("diplomaDate").value.length > 0 && document.getElementById("end").value.length > 0){
          var diplomaDate = makeDate(document.getElementById("diplomaDate").value),
              end         = makeDate(document.getElementById("end").value);
      
          if(end > diplomaDate){
            okToSubmit = false;
            alertDialog("web.hr","diplomadateMustComeAfterEnd");
            document.getElementById("diplomaDate").focus();
          }  
        }
      }
      
      if(okToSubmit){
        document.getElementById("divMessage").innerHTML = "<img src='<%=sCONTEXTPATH%>/_img/themes/<%=sUserTheme%>/ajax-loader.gif'/><br>Saving";  
        var url = "<c:url value='/hr/ajax/training/saveTraining.jsp'/>?ts="+new Date().getTime();

        document.getElementById("buttonSave").disabled = true;
        document.getElementById("buttonDelete").disabled = true;
        document.getElementById("buttonNew").disabled = true;
        
        // does not function when put inside ajax call
        var sParameters = "EditTrainingUid="+EditForm.EditTrainingUid.value+
                           "&PersonId=<%=activePatient.personid%>"+
                          "&begin="+document.getElementById("begin").value+
                          "&end="+document.getElementById("end").value+
                          "&institute="+document.getElementById("institute").value+
                          "&type="+document.getElementById("type").value+
                          "&level="+document.getElementById("level").value+
                          "&diploma="+document.getElementById("diploma").value+
                          "&diplomaDate="+document.getElementById("diplomaDate").value;
      
       if(document.getElementById("diplomaCode1")!=null){
         sParameters+= "&diplomaCode1="+document.getElementById("diplomaCode1").value;
       }
       if(document.getElementById("diplomaCode2")!=null){
         sParameters+= "&diplomaCode2="+document.getElementById("diplomaCode2").value;
       }
       if(document.getElementById("diplomaCode3")!=null){
         sParameters+= "&diplomaCode3="+document.getElementById("diplomaCode3").value;
       }
      
       sParameters+= "&comment="+document.getElementById("comment").value;
        
        new Ajax.Request(url,
          {
            method: "POST",
            postBody: sParameters,
            onSuccess: function(resp){
              var data = eval("("+resp.responseText+")");
              $("divMessage").innerHTML = data.message;

              loadTrainings();
              newTraining();
              
              //EditForm.EditTrainingUid.value = data.newUid;
              document.getElementById("buttonSave").disabled = false;
              document.getElementById("buttonDelete").disabled = false;
              document.getElementById("buttonNew").disabled = false;
            },
            onFailure: function(resp){
              $("divMessage").innerHTML = "Error in 'hr/ajax/training/saveTraining.jsp' : "+resp.responseText.trim();
            }
          }
        );
      }
    }
    else{
                window.showModalDialog?alertDialog("web.manage","dataMissing"):alertDialogDirectText('<%=getTran("web.manage","dataMissing",sWebLanguage)%>');
        
      <%-- focus empty field --%>
           if(document.getElementById("begin").value.length==0) document.getElementById("begin").focus();
      else if(document.getElementById("institute").value.length==0) document.getElementById("institute").focus();
      else if(document.getElementById("level").value.length==0) document.getElementById("level").focus();
      else if(document.getElementById("diploma").value.length==0) document.getElementById("diploma").focus();  
      else if(document.getElementById("diplomaDate").value.length==0) document.getElementById("diplomaDate").focus();          
    }
  }
    
  <%-- LOAD TRAININGS --%>
  function loadTrainings(){
    document.getElementById("divTrainings").innerHTML = "<img src='<%=sCONTEXTPATH%>/_img/themes/<%=sUserTheme%>/ajax-loader.gif'/><br>Loading..";  
    
    var url = "<c:url value='/hr/ajax/training/getTrainings.jsp'/>?ts="+new Date().getTime();
    new Ajax.Request(url,{
      method: "GET",
      parameters: "PatientId=<%=activePatient.personid%>",
      onSuccess: function(resp){
        $("divTrainings").innerHTML = resp.responseText;
        setTimeout("sortables_init()",500);
      },
      onFailure: function(resp){
        $("divMessage").innerHTML = "Error in 'hr/ajax/training/getTrainings.jsp' : "+resp.responseText.trim();
      }
    });
  }

  <%-- DISPLAY TRAINING --%>
  function displayTraining(trainingUid){          
    var url = "<c:url value='/hr/ajax/training/getTraining.jsp'/>?ts="+new Date().getTime();
    new Ajax.Request(url,{
      method: "GET",
      parameters: "TrainingUid="+trainingUid,
      onSuccess: function(resp){
        var data = eval("("+resp.responseText+")");

        $("EditTrainingUid").value = trainingUid;
        $("begin").value = data.begin;
        $("end").value = data.end;
        $("institute").value = data.institute.unhtmlEntities();
        $("type").value = data.type.unhtmlEntities();
        $("level").value = data.level.unhtmlEntities();
        $("diploma").value = data.diploma.unhtmlEntities();
        $("diplomaDate").value = data.diplomaDate;
        if($("diplomaCode1")!=null) $("diplomaCode1").value = data.diplomaCode1;
        if($("diplomaCode2")!=null) $("diplomaCode2").value = data.diplomaCode2;
        if($("diplomaCode3")!=null) $("diplomaCode3").value = data.diplomaCode3;
        $("comment").value = replaceAll(data.comment.unhtmlEntities(),"<br>","\n");
          
        document.getElementById("divMessage").innerHTML = ""; 
        resizeAllTextareas(8);

        <%-- display hidden buttons --%>
        document.getElementById("buttonDelete").style.visibility = "visible";
        document.getElementById("buttonNew").style.visibility = "visible";
      },
      onFailure: function(resp){
        $("divMessage").innerHTML = "Error in 'hr/ajax/training/getTraining.jsp' : "+resp.responseText.trim();
      }
    });
  }
  
  <%-- DELETE TRAINING --%>
  function deleteTraining(){ 
      if(yesnoDeleteDialog()){
      var url = "<c:url value='/hr/ajax/training/deleteTraining.jsp'/>?ts="+new Date().getTime();

      document.getElementById("buttonSave").disabled = true;
      document.getElementById("buttonDelete").disabled = true;
      document.getElementById("buttonNew").disabled = true;
    
      new Ajax.Request(url,{
        method: "GET",
        parameters: "TrainingUid="+document.getElementById("EditTrainingUid").value,
        onSuccess: function(resp){
          var data = eval("("+resp.responseText+")");
          $("divMessage").innerHTML = data.message;

          loadTrainings();
          newTraining();
          
          document.getElementById("buttonSave").disabled = false;
          document.getElementById("buttonDelete").disabled = false;
          document.getElementById("buttonNew").disabled = false;
        },
        onFailure: function(resp){
          $("divMessage").innerHTML = "Error in 'hr/ajax/training/deleteTraining.jsp' : "+resp.responseText.trim();
        }  
      });
    }
  }
  
  <%-- NEW TRAINING --%>
  function newTraining(){                   
    <%-- hide irrelevant buttons --%>
    document.getElementById("buttonDelete").style.visibility = "hidden";
    document.getElementById("buttonNew").style.visibility = "hidden";

    $("EditTrainingUid").value = "-1";        
    $("begin").value = "";
    $("end").value = "";
    $("institute").value = "";
    $("type").value = "";
    $("level").value = "";
    $("diploma").value = "";
    $("diplomaDate").value = "";
    if($("diplomaCode1")!=null) $("diplomaCode1").value = "";
    if($("diplomaCode2")!=null) $("diplomaCode2").value = "";
    if($("diplomaCode3")!=null) $("diplomaCode3").value = "";
    $("comment").value = "";
    
    $("begin").focus();
    resizeAllTextareas(8);
  }
  
  EditForm.begin.focus();
  loadTrainings();
  resizeAllTextareas(8);
</script>