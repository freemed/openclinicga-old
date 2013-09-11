<%@page import="be.openclinic.hr.DisciplinaryRecord,
               java.text.*"%>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>
<%@include file="../hr/includes/commonFunctions.jsp"%>
<%=checkPermission("hr.disciplinaryrecord.edit","edit",activeUser)%>

<%=sJSPROTOTYPE%>
<%=sJSNUMBER%> 
<%=sJSSTRINGFUNCTIONS%>
<%=sJSSORTTABLE%>

<%
    /// DEBUG /////////////////////////////////////////////////////////////////
    if(Debug.enabled){
        Debug.println("\n********** manage_disciplinaryRecord.jsp ***********");
        Debug.println("no parameters\n");
    }
    ///////////////////////////////////////////////////////////////////////////
%>            

<%=writeTableHeader("web","disciplinaryRecord",sWebLanguage,"")%><br>
<div id="divDisRecs" class="searchResults" style="width:100%;height:160px;"></div>

<form name="EditForm" id="EditForm" method="POST">
    <input type="hidden" id="EditDisRecUid" name="EditDisRecUid" value="-1">
                
    <table class="list" border="0" width="100%" cellspacing="1">
        <%-- date --%>
        <tr>
            <td class="admin" width="<%=sTDAdminWidth%>"><%=getTran("web.hr","date",sWebLanguage)%>&nbsp;*&nbsp;</td>
            <td class="admin2" nowrap> 
                <%=writeDateField("date","EditForm","",sWebLanguage)%>            
            </td>                        
        </tr>
        
        <%-- title --%>
        <tr>
            <td class="admin"><%=getTran("web.hr","title",sWebLanguage)%>&nbsp;*&nbsp;</td>
            <td class="admin2">
                <input type="text" class="text" id="title" name="title" size="50" maxLength="255" value="">
            </td>
        </tr>
        
        <%-- description --%>
        <tr>
            <td class="admin"><%=getTran("web.hr","description",sWebLanguage)%></td>
            <td class="admin2">
                <textarea class="text" name="description" id="description" cols="80" rows="4" onKeyup="resizeTextarea(this,8);"></textarea>
            </td>
        </tr>
                 
        <%-- decision --%>
        <tr>
            <td class="admin"><%=getTran("web.hr","decision",sWebLanguage)%>&nbsp;*&nbsp;</td>
            <td class="admin2">
                <select class="text" id="decision" name="decision">
                    <option/>
                    <%=ScreenHelper.writeSelect("hr.disrec.decision","",sWebLanguage)%>
                </select>
            </td>
        </tr>
            
        <%-- duration --%>
        <tr>
            <td class="admin"><%=getTran("web.hr","duration",sWebLanguage)%></td>
            <td class="admin2">
                <input type="text" class="text" id="duration" name="duration" size="3" maxLength="3" value="" onKeyUp="isNumber(this);"> <%=getTran("web","days",sWebLanguage)%>
            </td>
        </tr>
        
        <%-- decisionBy --%>
        <tr>
            <td class="admin"><%=getTran("web.hr","decisionBy",sWebLanguage)%>&nbsp;*&nbsp;</td>
            <td class="admin2">
                <input type="text" class="text" id="decisionBy" name="decisionBy" size="50" maxLength="100" value="">
            </td>
        </tr>
        
        <%-- followUp --%>                    
        <tr>
            <td class="admin"><%=getTran("web.hr","followUp",sWebLanguage)%></td>
            <td class="admin2">
                <textarea class="text" name="followUp" id="followUp" cols="80" rows="4" onKeyup="limitChars(this,6000);resizeTextarea(this,8);"></textarea>
            </td>
        </tr>
            
        <%-- BUTTONS --%>
        <tr>     
            <td class="admin"/>
            <td class="admin2" colspan="2">
                <input class="button" type="button" name="buttonSave" id="buttonSave" value="<%=getTranNoLink("web","save",sWebLanguage)%>" onclick="saveDisRec();">&nbsp;
                <input class="button" type="button" name="buttonDelete" id="buttonDelete" value="<%=getTranNoLink("web","delete",sWebLanguage)%>" onclick="deleteDisRec();" style="visibility:hidden;">&nbsp;
                <input class="button" type="button" name="buttonNew" id="buttonNew" value="<%=getTranNoLink("web","new",sWebLanguage)%>" onclick="newDisRec();" style="visibility:hidden;">&nbsp;
            </td>
        </tr>
    </table>
    <i><%=getTran("web","colored_fields_are_obligate",sWebLanguage)%></i>
    
    <div id="divMessage" style="padding-top:10px;"></div>
</form>
    
<script>
  <%-- SAVE DISREC --%>
  function saveDisRec(){
    var okToSubmit = true;
    
    if(document.getElementById("date").value.length > 8 &&
       document.getElementById("title").value.length > 0 &&
       document.getElementById("decision").value.length > 0 &&
       document.getElementById("decisionBy").value.length > 0
      ){               
      if(okToSubmit){
        document.getElementById("divMessage").innerHTML = "<img src=\"<c:url value='/_img/ajax-loader.gif'/>\"/><br>Saving";  
        var url = "<c:url value='/hr/ajax/disciplinaryrecord/saveDisciplinaryRecord.jsp'/>?ts="+new Date().getTime();

        document.getElementById("buttonSave").disabled = true;
        document.getElementById("buttonDelete").disabled = true;
        document.getElementById("buttonNew").disabled = true;
        new Ajax.Request(url,
          {
            method: "POST",
            postBody: "EditDisRecUid="+EditForm.EditDisRecUid.value+
                      "&PersonId=<%=activePatient.personid%>"+
                      "&date="+document.getElementById("date").value+
                      "&title="+document.getElementById("title").value+
                      "&description="+document.getElementById("description").value+
                      "&decision="+document.getElementById("decision").value+
                      "&duration="+document.getElementById("duration").value+
                      "&decisionBy="+document.getElementById("decisionBy").value+
                      "&followUp="+document.getElementById("followUp").value,
            onSuccess: function(resp){
              var data = eval("("+resp.responseText+")");

              $("divMessage").innerHTML = data.message;
              loadDisRecs();
              newDisRec();
              
              //EditForm.EditDisRecUid.value = data.newUid;
              document.getElementById("buttonSave").disabled = false;
              document.getElementById("buttonDelete").disabled = false;
              document.getElementById("buttonNew").disabled = false;
            },
            onFailure: function(resp){
              $("divMessage").innerHTML = "Error in 'hr/ajax/disciplinaryrecord/saveDisciplinaryRecord.jsp' : "+resp.responseText.trim();
            }
          }
        );
      }
    }
    else{
      alertDialog("web.manage","dataMissing");
        
      <%-- focus empty field --%>
           if(document.getElementById("date").value.length==0) document.getElementById("date").focus();
      else if(document.getElementById("title").value.length==0) document.getElementById("title").focus();
      else if(document.getElementById("decision").value.length==0) document.getElementById("decision").focus();
      else if(document.getElementById("decisionBy").value.length==0) document.getElementById("decisionBy").focus();          
    }
  }
    
  <%-- LOAD DISRECS --%>
  function loadDisRecs(){
    document.getElementById("divDisRecs").innerHTML = "<img src=\"<c:url value='/_img/ajax-loader.gif'/>\"/><br>Loading";            
    var url = "<c:url value='/hr/ajax/disciplinaryrecord/getDisciplinaryRecords.jsp'/>?ts="+new Date().getTime();
    new Ajax.Request(url,
      {
        method: "GET",
        parameters: "PatientId=<%=activePatient.personid%>",
        onSuccess: function(resp){
          $("divDisRecs").innerHTML = resp.responseText;
          sortables_init();
        },
        onFailure: function(resp){
          $("divMessage").innerHTML = "Error in 'hr/ajax/disciplinaryrecord/getDisciplinaryRecords.jsp' : "+resp.responseText.trim();
        }
      }
    );
  }

  <%-- DISPLAY DISREC --%>
  function displayDisrec(disRecUid){
    var url = "<c:url value='/hr/ajax/disciplinaryrecord/getDisciplinaryRecord.jsp'/>?ts="+new Date().getTime();
    
    new Ajax.Request(url,
      {
        method: "GET",
        parameters: "DisRecUid="+disRecUid,
        onSuccess: function(resp){ 
          var data = eval("("+resp.responseText+")");

          $("EditDisRecUid").value = disRecUid;
          $("date").value = data.date;
          $("title").value = data.title.unhtmlEntities();
          $("description").value = replaceAll(data.description.unhtmlEntities(),"<br>","\n");
          $("decision").value = data.decision.unhtmlEntities();
          if(data.duration > -1){
            $("duration").value = data.duration;
          }
          $("decisionBy").value = data.decisionBy.unhtmlEntities();
          $("followUp").value = replaceAll(data.followUp.unhtmlEntities(),"<br>","\n");
          
          document.getElementById("divMessage").innerHTML = ""; 
          resizeAllTextareas(8);

          <%-- display hidden buttons --%>
          document.getElementById("buttonDelete").style.visibility = "visible";
          document.getElementById("buttonNew").style.visibility = "visible";
        },
        onFailure: function(resp){
          $("divMessage").innerHTML = "Error in 'hr/ajax/disciplinaryrecord/getDisciplinaryRecord.jsp' : "+resp.responseText.trim();
        }
      }
    );
  }
  
  <%-- DELETE DISREC --%>
  function deleteDisRec(){  
    var answer = yesnoDialog("web","areYouSureToDelete"); 
     if(answer==1){                 
      var url = "<c:url value='/hr/ajax/disciplinaryrecord/deleteDisciplinaryRecord.jsp'/>?ts="+new Date().getTime();

      document.getElementById("buttonSave").disabled = true;
      document.getElementById("buttonDelete").disabled = true;
      document.getElementById("buttonNew").disabled = true;
    
      new Ajax.Request(url,
        {
          method: "GET",
          parameters: "DisRecUid="+document.getElementById("EditDisRecUid").value,
          onSuccess: function(resp){
            var data = eval("("+resp.responseText+")");
            $("divMessage").innerHTML = data.message;

            loadDisRecs();
            newDisRec();
          
            document.getElementById("buttonSave").disabled = false;
            document.getElementById("buttonDelete").disabled = false;
            document.getElementById("buttonNew").disabled = false;
          },
          onFailure: function(resp){
            $("divMessage").innerHTML = "Error in 'hr/ajax/disciplinaryrecord/deleteDisiplinaryRecord.jsp' : "+resp.responseText.trim();
          }  
        }
      );
    }
  }
  
  <%-- NEW DISREC --%>
  function newDisRec(){                   
    <%-- hide irrelevant buttons --%>
    document.getElementById("buttonDelete").style.visibility = "hidden";
    document.getElementById("buttonNew").style.visibility = "hidden";

    $("EditDisRecUid").value = "-1";
    $("date").value = "";
    $("title").value = "";
    $("description").value = "";
    $("decision").value = "";
    $("duration").value = "";
    $("decisionBy").value = "";
    $("followUp").value = "";   
    
    $("date").focus();
    resizeAllTextareas(8);
  }
      
  EditForm.date.focus();
  loadDisRecs();
  resizeAllTextareas(8);
</script>