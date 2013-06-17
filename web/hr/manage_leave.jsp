<%@page import="be.openclinic.hr.Leave,
               java.text.*"%>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>
<%@include file="../hr/includes/commonFunctions.jsp"%>
<%=checkPermission("hr.leave.edit","edit",activeUser)%>

<%=sJSPROTOTYPE%>
<%=sJSNUMBER%> 
<%=sJSSTRINGFUNCTIONS%>
<%=sJSSORTTABLE%>

<%
    /// DEBUG /////////////////////////////////////////////////////////////////
    if(Debug.enabled){
        Debug.println("\n**************** manage_leave.jsp *****************");
        Debug.println("no parameters\n");
    }
    ///////////////////////////////////////////////////////////////////////////
%>            

<%=writeTableHeader("web","leave",sWebLanguage,"")%><br>
<div id="divLeaves" class="searchResults" style="width:100%;height:160px;"></div>

<form name="EditForm" id="EditForm" method="POST">
    <input type="hidden" id="EditLeaveUid" name="EditLeaveUid" value="-1">
                
    <table class="list" border="0" width="100%" cellspacing="1">
        <%-- begin (*) --%>
        <tr>
            <td class="admin" width="<%=sTDAdminWidth%>"><%=getTran("web.hr","begin",sWebLanguage)%>&nbsp;*&nbsp;</td>
            <td class="admin2"> 
                <%=writeDateField("begin","EditForm","",sWebLanguage)%>            
            </td>                        
        </tr>
        
        <%-- end (*) --%>
        <tr>
            <td class="admin"><%=getTran("web.hr","end",sWebLanguage)%>&nbsp;*&nbsp;</td>
            <td class="admin2"> 
                <%=writeDateField("end","EditForm","",sWebLanguage,"calculateDuration();")%>            
            </td>                        
        </tr>
                        
        <%-- duration (calculated) (*) --%>
        <tr>
            <td class="admin"><%=getTran("web.hr","duration",sWebLanguage)%>&nbsp;*&nbsp;</td>
            <td class="admin2">
                <input type="text" class="text" id="duration" name="duration" size="3" maxLength="6" value="" onKeyUp="if(isNumber(this))setDecimalLength(this,2,false);"> <%=getTran("web","days",sWebLanguage)%>
            </td>
        </tr>
                                  
        <%-- type (*) --%>
        <tr>
            <td class="admin"><%=getTran("web.hr","type",sWebLanguage)%>&nbsp;*&nbsp;</td>
            <td class="admin2">
                <select class="text" id="grade" name="type">
                    <option/>
                    <%=ScreenHelper.writeSelect("hr.leave.type","",sWebLanguage)%>
                </select>
            </td>
        </tr>
        
        <%-- requestDate --%>
        <tr>
            <td class="admin"><%=getTran("web.hr","requestDate",sWebLanguage)%></td>
            <td class="admin2"> 
                <%=writeDateField("requestDate","EditForm","",sWebLanguage)%>            
            </td>                        
        </tr>
        
        <%-- authorizationDate --%>
        <tr>
            <td class="admin"><%=getTran("web.hr","authorizationDate",sWebLanguage)%></td>
            <td class="admin2"> 
                <%=writeDateField("authorizationDate","EditForm","",sWebLanguage)%>            
            </td>                        
        </tr>
        
        <%-- authorizedBy --%>
        <tr>
            <td class="admin"><%=getTran("web.hr","authorizedBy",sWebLanguage)%></td>
            <td class="admin2">
                <input type="text" class="text" id="authorizedBy" name="authorizedBy" size="50" maxLength="255" value="">
            </td>
        </tr>
        
        <%-- episodeCode --%>
        <tr>
            <td class="admin"><%=getTran("web.hr","episodeCode",sWebLanguage)%></td>
            <td class="admin2">
                <input type="text" class="text" id="episodeCode" name="episodeCode" size="20" maxLength="50" value="">
            </td>
        </tr>
        
        <%-- comment --%>                    
        <tr>
            <td class="admin"><%=getTran("web.hr","comment",sWebLanguage)%></td>
            <td class="admin2">
                <textarea class="text" name="comment" cols="80" rows="4" onKeyup="resizeTextarea(this,8);"></textarea>
            </td>
        </tr>
            
        <%-- BUTTONS --%>
        <tr>     
            <td class="admin"/>
            <td class="admin2" colspan="2">
                <input class="button" type="button" name="buttonSave" value="<%=getTranNoLink("web","save",sWebLanguage)%>" onclick="saveLeave();">&nbsp;
                <input class="button" type="button" name="buttonDelete" value="<%=getTranNoLink("web","delete",sWebLanguage)%>" onclick="deleteLeave();" style="visibility:hidden;">&nbsp;
                <input class="button" type="button" name="buttonNew" value="<%=getTranNoLink("web","new",sWebLanguage)%>" onclick="newLeave();" style="visibility:hidden;">&nbsp;
            </td>
        </tr>
    </table>
    <i><%=getTran("web","colored_fields_are_obligate",sWebLanguage)%></i>
    
    <div id="divMessage" style="padding-top:10px;"></div>
</form>
    
<script>
  <%-- SAVE LEAVE --%>
  function saveLeave(){
    var okToSubmit = true;
    
    if(document.getElementById("begin").value.length > 8 &&
       document.getElementById("end").value.length > 0 &&
       document.getElementById("duration").value.length > 0 &&
       document.getElementById("type").value.length > 0
      ){   
      if(okToSubmit){  
        <%-- begin can not be after end --%>
        if(document.getElementById("begin").value.length > 0 && document.getElementById("end").value.length > 0){
          var beginDate = makeDate(document.getElementById("begin").value);
          var endDate = makeDate(document.getElementById("end").value);
      
          if(beginDate > endDate){
            okToSubmit = false;
            alertDialog("web","beginMustComeBeforeEnd");
            document.getElementById("begin").focus();
          }
        }  
      }   

      if(okToSubmit){
        <%-- requestDate can not be after authorizationDate --%>
        if(document.getElementById("requestDate").value.length > 0 && document.getElementById("authorizationDate").value.length > 0){
          var reqDate = makeDate(document.getElementById("requestDate").value);
          var authDate = makeDate(document.getElementById("authorizationDate").value);
          
          if(reqDate > authDate){
            okToSubmit = false;
            alertDialog("web","beginMustComeBeforeEnd");
            document.getElementById("requestDate").focus();
          }
        }
      }
      
      if(okToSubmit){
        document.getElementById("divMessage").innerHTML = "<img src=\"<c:url value='/_img/ajax-loader.gif'/>\"/><br>Saving";  
        var url = "<c:url value='/hr/ajax/leave/saveLeave.jsp'/>?ts="+new Date().getTime();

        document.getElementById("buttonSave").disabled = true;
        document.getElementById("buttonDelete").disabled = true;
        document.getElementById("buttonNew").disabled = true;
        
        new Ajax.Request(url,
          {
            method: "POST",
            postBody: "EditLeaveUid="+EditForm.EditLeaveUid.value+
                      "&PersonId=<%=activePatient.personid%>"+
                      "&begin="+document.getElementById("begin").value+
                      "&end="+document.getElementById("end").value+
                      "&duration="+document.getElementById("duration").value+
                      "&type="+document.getElementById("type").value+
                      "&requestDate="+document.getElementById("requestDate").value+
                      "&authorizationDate="+document.getElementById("authorizationDate").value+
                      "&authorizedBy="+document.getElementById("authorizedBy").value+
                      "&episodeCode="+document.getElementById("episodeCode").value+
                      "&comment="+document.getElementById("comment").value,                          
            onSuccess: function(resp){
              var data = eval("("+resp.responseText+")");
              $("divMessage").innerHTML = data.message;
              
              loadLeaves();
              newLeave();
              
              //EditForm.EditLeaveUid.value = data.newUid;
              document.getElementById("buttonSave").disabled = false;
              document.getElementById("buttonDelete").disabled = false;
              document.getElementById("buttonNew").disabled = false;
            },
            onFailure: function(resp){
              $("divMessage").innerHTML = "Error in 'hr/ajax/leave/saveLeave.jsp' : "+resp.responseText.trim();
            }
          }
        );
      }
    }
    else{
      alertDialog("web.manage","dataMissing");
      
      <%-- focus empty field --%>
           if(document.getElementById("begin").value.length==0) document.getElementById("begin").focus();
      else if(document.getElementById("end").value.length==0) document.getElementById("end").focus();
      else if(document.getElementById("duration").value.length==0) document.getElementById("duration").focus();
      else if(document.getElementById("type").value.length==0) document.getElementById("type").focus();          
    }
  }
    
  <%-- LOAD LEAVES --%>
  function loadLeaves(){
    document.getElementById("divLeaves").innerHTML = "<img src=\"<c:url value='/_img/ajax-loader.gif'/>\"/><br>Loading";            
    var url = "<c:url value='/hr/ajax/leave/getLeaves.jsp'/>?ts="+new Date().getTime();
    new Ajax.Request(url,
      {
        method: "GET",
        parameters: "PatientId=<%=activePatient.personid%>",
        onSuccess: function(resp){
          $("divLeaves").innerHTML = resp.responseText;
          sortables_init();
        },
        onFailure: function(resp){
          $("divMessage").innerHTML = "Error in 'hr/ajax/leave/getLeaves.jsp' : "+resp.responseText.trim();
        }
      }
    );
  }

  <%-- DISPLAY LEAVES --%>
  function displayLeave(leaveUid){          
    var url = "<c:url value='/hr/ajax/leave/getLeave.jsp'/>?ts="+new Date().getTime();
    
    new Ajax.Request(url,
      {
        method: "GET",
        parameters: "LeaveUid="+leaveUid,
        onSuccess: function(resp){
          var data = eval("("+resp.responseText+")");

          $("EditLeaveUid").value = leaveUid;
          $("begin").value = data.begin;
          $("end").value = data.end;
          $("duration").value = data.duration;
          $("type").value = data.type;
          $("requestDate").value = data.requestDate;
          $("authorizationDate").value = data.authorizationDate;
          $("authorizedBy").value = data.authorizedBy;
          $("episodeCode").value = data.episodeCode;
          $("comment").value = replaceAll(data.comment,"<br>","\n");

          document.getElementById("divMessage").innerHTML = ""; 
          resizeAllTextareas(8);

          <%-- display hidden buttons --%>
          document.getElementById("buttonDelete").style.visibility = "visible";
          document.getElementById("buttonNew").style.visibility = "visible";
        },
        onFailure: function(resp){
          $("divMessage").innerHTML = "Error in 'hr/ajax/leave/getLeave.jsp' : "+resp.responseText.trim();
        }
      }
    );
  }
  
  <%-- DELETE LEAVES --%>
  function deleteLeave(){
    var answer = yesnoDialog("web","areYouSureToDelete"); 
     if(answer==1){                 
      var url = "<c:url value='/hr/ajax/leave/deleteLeave.jsp'/>?ts="+new Date().getTime();

      document.getElementById("buttonSave").disabled = true;
      document.getElementById("buttonDelete").disabled = true;
      document.getElementById("buttonNew").disabled = true;
    
      new Ajax.Request(url,
        {
          method: "GET",
          parameters: "LeaveUid="+document.getElementById("EditLeaveUid").value,
          onSuccess: function(resp){
            var data = eval("("+resp.responseText+")");
            $("divMessage").innerHTML = data.message;

            loadLeaves();
            newLeave();
          
            document.getElementById("buttonSave").disabled = false;
            document.getElementById("buttonDelete").disabled = false;
            document.getElementById("buttonNew").disabled = false;
          },
          onFailure: function(resp){
            $("divMessage").innerHTML = "Error in 'hr/ajax/leave/deleteLeave.jsp' : "+resp.responseText.trim();
          }  
        }
      );
    }
  }
  
  <%-- NEW LEAVES --%>
  function newLeave(){                   
    <%-- hide irrelevant buttons --%>
    document.getElementById("buttonDelete").style.visibility = "hidden";
    document.getElementById("buttonNew").style.visibility = "hidden";

    $("EditLeaveUid").value = "-1";
    $("begin").value = "";
    $("end").value = "";
    $("duration").value = "";
    $("type").selectedIndex = 0;
    $("requestDate").value = "";
    $("authorizationDate").value = "";
    $("authorizedBy").value = "";
    $("episodeCode").value = "";
    $("comment").value = "";   
    
    $("begin").focus();
    resizeAllTextareas(8);
  }
  
  <%-- CALCULATE DURATION --%>
  function calculateDuration(){
    var sDuration = "";
    
    if(document.getElementById("begin").value.length > 0 && document.getElementById("end").value.length > 0){
      var beginDate = makeDate(document.getElementById("begin").value);
      var endDate = makeDate(document.getElementById("end").value);

      <%-- begin can not be after end --%>
      if(beginDate <= endDate){              
        <%-- calculate --%>
        var difMillis = (endDate.getTime()-beginDate.getTime());
        var diffDays = (difMillis/(24*60*60*1000));
        sDuration = diffDays+1;
      }
      else{
        alertDialog("web","beginMustComeBeforeEnd");
        document.getElementById("begin").focus();
      }
    }        

    document.getElementById("duration").value = sDuration;
  }
    
  EditForm.begin.focus();
  loadLeaves();
  resizeAllTextareas(8);
</script>