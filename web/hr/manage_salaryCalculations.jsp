<%@page import="java.util.*"%>
<%@include file="/includes/validateUser.jsp"%>
<%@include file="../hr/includes/commonFunctions.jsp"%>
<%=checkPermission("hr.salarycalculations","select",activeUser)%>
<%=sJSSTRINGFUNCTIONS%>
<%=sJSDATE%>
<%=sJSSORTTABLE%>

<%    
    SimpleDateFormat monthFormat = new SimpleDateFormat("MM/yyyy");
    String sDisplayedMonth = checkString(request.getParameter("DisplayedMonth"));
    
    if(sDisplayedMonth.length()==0){
        Calendar cal = Calendar.getInstance();
        cal.set(Calendar.DATE,1);
        sDisplayedMonth = monthFormat.format(cal.getTime());
    }
    else{
        // to MM/yyyy format
        sDisplayedMonth = sDisplayedMonth.replaceAll("-","/");
        if(sDisplayedMonth.length() > 7){
            int firstSlashIdx = sDisplayedMonth.indexOf("/");
            sDisplayedMonth = sDisplayedMonth.substring(firstSlashIdx+1);
        }
    }
    
    /// DEBUG //////////////////////////////////////////////////////////////////////
    if(Debug.enabled){
        Debug.println("\n*********** hr/manage_salaryCalculations.jsp ***********");
        Debug.println("sDisplayedMonth : "+sDisplayedMonth+"\n");
    }
    ////////////////////////////////////////////////////////////////////////////////
%>

<script src="<%=sCONTEXTPATH%>/hr/includes/commonFunctions.js"></script> 

<script>
  /* CLASS : ClientMsg */
  var ClientMsg = Class.create();
  
  ClientMsg.prototype = {
    initialize: function(div){
      this.div = $(div);
    },
    /* SET DIV */
    setDiv: function(div){
      this.div = $(div);
    },
    /* SET ERROR */
    setError: function(msg,option,time){
      this.div.hide();
      if(!time) time = 5000;
      if(option){
        if(option=="before"){
          this.div.update("<span class='error'><img src='<%=sCONTEXTPATH%>/_img/icons/icon_warning.gif' style='vertical-align:-3px;'>&nbsp;<blink>"+msg+"</blink></span>" +
                          "<br>"+this.div.innerHTML);
        }
        else if(option=="after"){
          this.div.update(this.div.innerHTML+"<br><span class='error'><img src='<%=sCONTEXTPATH%>/_img/icons/icon_warning.gif' style='vertical-align:-3px;'>&nbsp;<blink>"+msg+"</blink></span>");
        }
      }
      else{
        this.div.update("<span class='error'><img src='<%=sCONTEXTPATH%>/_img/icons/icon_warning.gif' style='vertical-align:-3px;'>&nbsp;<blink>"+msg+"</blink></span>");
      }
      
      this.div.style.display = "block";      
      setTimeout(function(){$(clientMsg.div).style.display = "none";},time);
    },
    /* SET VALID */
    setValid: function(msg,option,time){
      this.div.hide();
      if(!time) time = 3000;
      if(option){
        if(option=="before"){
          this.div.update("<span class='valid'><img src='<%=sCONTEXTPATH%>/_img/themes/default/valid.gif' style='vertical-align:-3px;'>&nbsp;"+msg+"</span><br>"+this.div.innerHTML);
        }
        else if(option=="after"){
          this.div.update(this.div.innerHTML+"<br><span class='valid'><img src='<%=sCONTEXTPATH%>/_img/themes/default/valid.gif' style='vertical-align:-3px;'>&nbsp;"+msg+"</span>");
        }
      }
      else{
        this.div.update("<span class='valid'><img src='<%=sCONTEXTPATH%>/_img/themes/default/valid.gif' style='vertical-align:-3px;'>&nbsp;"+msg+"</span>");
      }
      
      this.div.style.display = "block";      
      setTimeout(function(){$(clientMsg.div).style.display = "none";},time);
    }
  }
  
  var clientMsg = new ClientMsg("");
  
  <%-- DISPLAY CLIENT MSG - DATA IS SAVED --%>
  function displayClientMsgDataIsSaved(){
    closeCalculationForm();
    showCalendar();
        
    clientMsg.setValid("<%=getTranNoLink("web.control","dataIsSaved",sWebLanguage)%>",null,1500);
  }
  
  <%-- DISPLAY CLIENT MSG - DATA IS DELETED --%>
  function displayClientMsgDataIsDeleted(){    
    showCalendar();	  
    
    clientMsg.setValid("<%=getTranNoLink("web","dataIsDeleted",sWebLanguage)%>",null,1000);
  }
    
  <%-- DISPLAY CLIENT ERR --%>
  function displayClientErr(){
    clientMsg.setError("<%=getTranNoLink("web.control","dberror",sWebLanguage)%>",null,10000);
  }
</script>

<%-- form to edit calculation, displayed by modalbox --%>
<div id="calculationFormByAjax" style="position:absolute;z-index:50000">&nbsp;</div>

<%-- monthScheduler --%>
<form name="schedulerForm" method="post" action="<c:url value='/main.do'/>?Page=hr/manage_salaryCalculations.jsp&ts=<%=getTs()%>" onkeydown="if(enterEvent(event,13)){showCalendar();return false;}">
    <input id="PersonId" type="hidden" value="<%=activePatient.personid%>">
                
    <%=writeTableHeader("web","salaryCalculations",sWebLanguage)%>

    <table width="100%" class="list" cellspacing="0" cellpadding="0" style="border:none;">
        <tr style="height:30px;">
            <td class="admin2" width="50"><%=getTran("web","month",sWebLanguage)%></td>
            
            <%-- ARROWS --%>
            <td class="admin2" width="150" nowrap>                
                <input type="button" class="button" name="buttonPrevious" value=" < " onclick="showPrevMonth();"/>
                <input type="text" class="text" id="DisplayedMonth" name="DisplayedMonth" value="<%=sDisplayedMonth%>" size="10" maxLength="10" onBlur="checkDateMonthAndYearAllowed(this);"/>
                <input type="button" class="button" name="buttonNext" value=" > " onclick="showNextMonth();"/>                        
                               
                <%-- only past dates --%>
                <script>writeMyDate("DisplayedMonth","<c:url value='/_img/icons/icon_agenda.gif'/>","<%=getTran("web","putToday",sWebLanguage)%>",true,false);</script>
            </td>
            
            <%-- BUTTONS --%>
            <td class="admin2" width="*">
                <div style="float:left;height:20px;">
                    <input type="button" name="buttonSearch" class="button" value="<%=getTranNoLink("web","search",sWebLanguage)%>" onclick="showCalendar();"/>
                </div>
                
                <div style="float:left;height:20px;padding-left:20px;">
                    <input type="button" name="buttonRepeat" class="button" value="<%=getTranNoLink("web","repeat",sWebLanguage)%>" onclick="repeatCalculation();"/>&nbsp;
                    <input type="button" name="buttonCreate" class="button" value="<%=getTranNoLink("web.manage","createSalaryCalculationsForLeavesAndWorkschedules",sWebLanguage)%>" onclick="createSalaryCalculationsForLeavesAndWorkschedules('<%=activePatient.personid%>');"/>
                </div>
                
                <%-- ajax icon --%>
                <div id="wait" style="width:140px;display:none">&nbsp;</div>
            </td>
        </tr>

        <%-- instructions --%>
        <tr>                
            <td class="admin2" colspan="3">                
                <%=getTran("hr.salarycalculations","instructions",sWebLanguage)%>                 
            </td>
        </tr>
    </table>
            
    <%=sJSMONTHPLANNERAJAX%>    
    <%=sJSMONTHPLANNER%>
    <%=sCSSMONTHPLANNER%>

    <%-- JS variables --%>
    <script>
      externalSourceFile_items = "<c:url value='/hr/ajax/salarycalculations/getSalaryCalculations.jsp'/>?ts=<%=getTs()%>";
      externalSourceFile_save = "";
      
      dateStartOfMonth = makeDate("01/<%=sDisplayedMonth%>");
      
      var calculationDivTitle = "<%=getTranNoLink("web","doubleClickToOpen",sWebLanguage)%>";
      var hourShortTran = "<%=getTranNoLink("web","hourShort",sWebLanguage)%>";
      var daysTran = "<%=getTranNoLink("web","days",sWebLanguage)%>";
      var deleteTran = "<%=getTranNoLink("web","delete",sWebLanguage)%>";
      var manuallyEditedTran = "<%=getTranNoLink("web","manuallyEdited",sWebLanguage)%>";
    </script>
    
    <script>
      <% int dayRowHeight = 120; %>
      
      var itemRowHeight = <%=dayRowHeight%>;
      var patientName = "<%=(activePatient!=null)?activePatient.lastname+" "+activePatient.firstname:""%>";

      if(document.all){
        var containerWidth = document.body.clientWidth - 8;
        var containerHeight = document.body.clientHeight - 285;
      }
      else{
        var containerWidth = document.body.clientWidth - 16;
        var containerHeight = document.body.clientHeight - 271;
      }
    </script>
        
    <div id="monthScheduler_container" style="border:1px solid #eee;">
        <div id="monthScheduler_msgBox">&nbsp;</div>

        <div id="monthScheduler_top">  
            <%-- spacer --%>
            <div class="spacer">&nbsp;</div>
                      
            <%-- days header (7 days) --%>
            <div class="dayHeaders" id="monthScheduler_dayHeaders">
                <div id="dayHeader_0" style="border-left: 1px solid #eee;"><%=getTran("web","saturday",sWebLanguage)%></div>
                <div id="dayHeader_1"><%=getTran("web","sunday",sWebLanguage)%></div>
                <div id="dayHeader_2"><%=getTran("web","monday",sWebLanguage)%></div>
                <div id="dayHeader_3"><%=getTran("web","tuesday",sWebLanguage)%></div>
                <div id="dayHeader_4"><%=getTran("web","wednesday",sWebLanguage)%></div>
                <div id="dayHeader_5"><%=getTran("web","thursday",sWebLanguage)%></div>
                <div id="dayHeader_6"><%=getTran("web","friday",sWebLanguage)%></div>
            </div>   
        </div>
        
        <div id="monthScheduler_content">
            <div id="monthScheduler_weeks">
                <%    
                    // cells on the left containing number of the month
                    for(int i=0; i<6; i++){                       
                        out.write("<div class='weekCell' style='line-height:"+dayRowHeight+"px;'>"+getTran("web","weekShort",sWebLanguage)+(i+1)+"</div>");
                    } 
                %>
            </div>
            
            <div id="monthScheduler_days" style="background:#eee;border-bottom:1px solid #eee;">
                <%                        
                    // 6 weeks of 7 blanco days
                    for(int i=0; i<42; i++){
                        out.write("<div id='monthScheduler_day"+i+"' class='monthScheduler_day' style='height:"+(dayRowHeight-1)+"px;'>"+  
                                   "<span>&nbsp;</span>"+
                                  "</div>\n");
                    }
                %>
            </div>
        </div>
    </div>
     
    <div id="responseByAjax" style="display:none;">&nbsp;</div>   
</form>
    
<script>  
  <%-- SHOW PREV MONTH --%>
  function showPrevMonth(){
    if($("DisplayedMonth").value.length==0){
      $("DisplayedMonth").focus();
                alertDialog("web.manage","dataMissing");
    }
    else{
      var dispMonth = makeDate("01/"+toMonthFormat($("DisplayedMonth").value));
      var month = dispMonth.getMonth();
      if(month < 10) month = "0"+month;
      showCalendar("01/"+month+"/"+dispMonth.getFullYear());
    }
  }

  <%-- SHOW NEXT MONTH --%>
  function showNextMonth(){
    if($("DisplayedMonth").value.length==0){
      $("DisplayedMonth").focus();
                alertDialog("web.manage","dataMissing");
    }
    else{
      var dispMonth = makeDate("01/"+toMonthFormat($("DisplayedMonth").value));
      var month = dispMonth.getMonth()+2;
      if(month < 10) month = "0"+month;
      showCalendar("01/"+month+"/"+dispMonth.getFullYear());
    }
  }
  
  <%-- SHOW CALENDAR --%>
  function showCalendar(sDate){
    if($("DisplayedMonth").value.length==0){
      $("DisplayedMonth").focus();
                alertDialog("web.manage","dataMissing");
    }
    else{
      var sOrigDate = $("DisplayedMonth").value;
      if(sDate) $("DisplayedMonth").value = sDate;
      $("DisplayedMonth").value = toMonthFormat($("DisplayedMonth").value);
    
      var thisMonth = makeDate("01/"+(new Date().getMonth()+1)+"/"+new Date().getFullYear()),
          dispMonth = makeDate("01/"+$("DisplayedMonth").value);
    
      if(dispMonth.getTime() <= thisMonth.getTime()){
        displayMonth(dispMonth);
      }
      else{
        $("DisplayedMonth").value = sOrigDate;
        $("DisplayedMonth").focus();
        alertDialog("web","futureDatesNotAllowed");
      }
    }
  }
  
  <%-- TO MONTH FORMAT --%>
  function toMonthFormat(sDate){
    if(sDate.length > 7){
      sDate = formatDate(sDate);
      sDate = sDate.substring(sDate.indexOf("/")+1);
    }
    
    return sDate;
  }
                          
  <%-- RESIZE SCHEDULER --%>
  function resizeScheduler(containerHeight,containerWidth){
    $("monthScheduler_content").style.height = containerHeight+"px";
    $("monthScheduler_content").style.width = containerWidth+"px";
      
    var days = $("monthScheduler_days").getElementsByClassName("monthScheduler_day");
    days.concat($("monthScheduler_days").getElementsByClassName("monthScheduler_future"));
    
    var dayHeaders = $("monthScheduler_dayHeaders").getElementsByTagName("DIV");

    var width = ((containerWidth/7)-14);    
    for(i=0;i<days.length;i++){
      days[i].style.width = width+"px";
    }

    width = ((containerWidth/7)-12);
    for(i=0;i<dayHeaders.length;i++){
      dayHeaders[i].style.width = width+"px";
    }
  }
     
  <%-- SEARCH CALCULATION CODES --%>
  function searchCalculationCodes(){
    var url = "/hr/ajax/salarycalculations/searchCalculationCodes.jsp?ts="+new Date().getTime()+
              "&ReturnFieldCode=addCode"+
              "&ReturnFieldLabel=codeAndLabel";
    openPopup(url,500,400,"SearchCalculationCodes");
  }
   
  resizeScheduler(containerHeight,containerWidth);
  clientMsg.setDiv("monthScheduler_msgBox");
  
  <%--- CALCULATION -----------------------------------------------------------------------------%>

  <%-- CREATE SALARY CALCULATIONS FOR LEAVES AND WORKSCHEDULES (for displayed month) --%>
  function createSalaryCalculationsForLeavesAndWorkschedules(personId){
      if(yesnoDeleteDialog()){
      var dispMonth = makeDate("01/"+toMonthFormat($("DisplayedMonth").value));
      var nextMonth = dispMonth.getMonth()+2;
        
      var url = "<c:url value='/hr/management/createSalaryCalculationsForLeavesAndWorkSchedules.jsp'/>?ts="+new Date().getTime();
      var params = "Action=create"+
			       "&AjaxMode=true"+
			       "&personId="+personId+
                   "&beginDate=01/"+(dispMonth.getMonth()+1)+"/"+dispMonth.getFullYear()+
                   "&endDate=01/"+nextMonth+"/"+dispMonth.getFullYear();      
      
      new Ajax.Request(url,{
        evalScripts: true,
        parameters: params,
        onComplete: function(resp){
          displayClientMsgDataIsSaved();
        }
      });
    }
  }
  
  <%-- CREATE SALARY CALCULATIONS FOR WORKSCHEDULES (for displayed month)
  function createSalaryCalculationsForWorkschedules(){
    if(yesnoDialog("web","areYouSure")){
      var url = "<c:url value='/hr/management/createSalaryCalculationsForWorkSchedules.jsp'/>?ts="+new Date().getTime();
      var params = "Action=create"+
			       "&AjaxMode=true"+
			       "&beginDate=01/"+$("DisplayedMonth").value+
			       "&endDate=01/"+$("DisplayedMonth").value;     
        
      new Ajax.Request(url,{
        evalScripts: true,
        parameters: params,
        onComplete: function(resp){
          var msg = resp.responseText;
          clientMsg.setValid("<%=getTranNoLink("web.control","dataIsSaved",sWebLanguage)%>",null,1500);      
          //clientMsg.setValid(resp.responseText,null,10000);
        }
      });
    }
  }
  --%>
  
  <%-- CREATE SALARY CALCULATIONS FOR LEAVES (for displayed month)
  function createSalaryCalculationsForLeaves(){
    if(yesnoDialog("web","areYouSure")){
      var url = "<c:url value='/hr/management/createSalaryCalculationsForLeaves.jsp'/>?ts="+new Date().getTime();
      var params = "Action=create"+
			       "&AjaxMode=true"+
			       "&beginDate=01/"+$("DisplayedMonth").value+
			       "&endDate=01/"+$("DisplayedMonth").value;     
      
      new Ajax.Request(url,{
        evalScripts: true,
        parameters: params,
        onComplete: function(resp){
          var msg = resp.responseText; 
          clientMsg.setValid("<%=getTranNoLink("web.control","dataIsSaved",sWebLanguage)%>",null,1500);      
          //clientMsg.setValid(resp.responseText,null,10000);
        }
      });
    }
  }
  --%>
  
  <%-- REPEAT CALCULATION --%>
  function repeatCalculation(){ 
    var dispMonth = makeDate("01/"+toMonthFormat($("DisplayedMonth").value));
    var month = dispMonth.getMonth()+1;
    if(month < 10) month = "0"+month;    
    var sDisplayedDate = "01/"+month+"/"+dispMonth.getFullYear();
        
    var url = "<c:url value='/hr/ajax/salarycalculations/repeatCalculation.jsp'/>?ts="+new Date().getTime();
    var params = "Action=create"+
                 "&Begin="+sDisplayedDate+
                 "&PersonId="+$("PersonId").value;
    
    Modalbox.show(url,{title:"<%=getTranNoLink("web","salaryCalculation",sWebLanguage)%>",width:550,params:params},{evalScripts:true});
  }
  
  <%-- OPEN CALCULATION --%>
  function openCalculation(){    
    var url = "<c:url value='/hr/ajax/salarycalculations/editCalculation.jsp'/>?ts="+new Date().getTime();
    var params = "Action=show"+
                 "&SalCalUID="+actualCalculationId;
    
    Modalbox.show(url,{title:"<%=getTranNoLink("web","salaryCalculation",sWebLanguage)%>",width:550,params:params},{evalScripts:true});
  }
  
  <%-- CREATE CALCULATION --%>
  function createCalculation(e){
    if(!e) var e = window.event;
    var source;
         if(e.target) source = e.target;
    else if(e.srcElement) source = e.srcElement;
      
    actualCalculationId = "";
    var url = "<c:url value='/hr/ajax/salarycalculations/editCalculation.jsp'/>?ts="+new Date().getTime();
    var params = "Action=create"+
			     "&Begin="+source.date+
                 "&PersonId="+$("PersonId").value;
    
    Modalbox.show(url,{title:"<%=getTranNoLink("web","newSalaryCalculation",sWebLanguage)%>",width:550,params:params,afterHide:function(){showCalendar();}},{evalScripts:true});
  }
  
  <%-- REMOVE CALCULATION FROM SCREEN --%>
  function removeCalculationFromScreen(sSalCalUID){
    var calculationDivs = $("monthScheduler_days").getElementsByClassName("calculation");
    var salCal;
    for(var i=0; i<calculationDivs.length; i++){
      salCal = calculationDivs[i];
      if(salCal.calculationUID==sSalCalUID){
        $("monthScheduler_days").removeChild(salCal);
      }
    }
  }
  
  <%-- DELETE CALCULATION --%>
  function deleteCalculation(e){
    if(!e) var e = window.event;
    var source;
         if(e.target) source = e.target;
    else if(e.srcElement) source = e.srcElement;
          
         if(yesnoDeleteDialog()){
      var url = "<c:url value='/hr/ajax/salarycalculations/editCalculation.jsp'/>?ts="+new Date().getTime();
      var params = "Action=delete"+
                   "&SalCalUID="+source.calculationUID;      
      
      new Ajax.Request(url,{
        evalScripts: true,
        parameters: params,
        onComplete: function(resp){
          hideCalculation(source.calculationUID);
          displayClientMsgDataIsDeleted();
        }
      });
    }
  }
  
  <%-- DELETE CALCULATION THRU UID --%>
  function deleteCalculationThruUID(salCalUID){
      if(yesnoDeleteDialog()){
      var url = "<c:url value='/hr/ajax/salarycalculations/editCalculation.jsp'/>?ts="+new Date().getTime();
      var params = "Action=delete"+
                   "&SalCalUID="+salCalUID;      

      new Ajax.Request(url,{
        evalScripts: true,
        parameters: params,
        onComplete: function(resp){ 
          hideCalculation(salCalUID);
          closeCalculationForm();
          displayClientMsgDataIsDeleted();
        }
      });
    }
  }
    
  <%-- CLOSE CALCULATION FORM --%>
  function closeCalculationForm(){
    if(Modalbox.initialized){
      Modalbox.hide();
    }
    else{
      //showCalendar();
    }
  }
  
  <%-- SAVE CALCULATION --%>
  function saveCalculation(sSalCalUID){
    var okToSubmit = true;
    
    <%-- add data which were entered but not yet added --%>
    if(document.getElementById("addDuration").value.length > 0 && document.getElementById("addCode").value.length > 0){
        if(window.showModalDialog?yesnoDialog("web","firstAddData"):yesnoDialog('','<%=getTran("web","firstAddData",sWebLanguage)%>')){
        okToSubmit = addCC();
      }
    }
    else{ 
      if(okToSubmit){
        if(document.getElementById("addDuration").value.length > 0){
          document.getElementById("codeAndLabel").focus();
          alertDialog("web.manage","addData");
          okToSubmit = false;
        }
      }

      if(okToSubmit){
        if(document.getElementById("addCode").value.length > 0){
          document.getElementById("addDuration").focus();
          alertDialog("web.manage","addData");
          okToSubmit = false;
        }
      }
    }
     
    <%-- check codes --%>
    if(okToSubmit){
      var tblCC = document.getElementById("tblCC"); // FF
      if(tblCC.rows.length < 3){
        document.getElementById("addDuration").focus();
        alertDialog("web.manage","specifyAtLeastOneCode");
        okToSubmit = false;
      }
    } 
    
    if(okToSubmit){
      var url = "<c:url value='/hr/ajax/salarycalculations/editCalculation.jsp'/>?ts="+new Date().getTime();
      var params = "Action=save"+
                   "&PersonId="+document.getElementById("PersonId").value+
                   "&Begin="+document.getElementById("Begin").value+
                   "&End="+document.getElementById("End").value+
                   "&Source="+document.getElementById("Source").value+
                   "&Type="+document.getElementById("Type").value+
                   "&SalCalUID="+(sSalCalUID?sSalCalUID:actualCalculationId)+
                   "&CalculationCodes="+removeTRIndexes(sCC);

      new Ajax.Request(url,{
        evalScripts: true,
        parameters: params,
        onComplete: function(){setTimeout("displayClientMsgDataIsSaved()",500)} // wait for sql to save data
      });
    }
  }
  
  <%-- SAVE REPEAT CALCULATION --%>
  function saveRepeatCalculation(){
    var okToSubmit = true;
    
    <%-- add data which were entered but not yet added --%>
    if(document.getElementById("addDuration").value.length > 0 && document.getElementById("addCode").value.length > 0){
        if(window.showModalDialog?yesnoDialog("web","firstAddData"):yesnoDialog('','<%=getTran("web","firstAddData",sWebLanguage)%>')){
        okToSubmit = addCC();
      }
    }
    else{ 
      if(okToSubmit){
        if(document.getElementById("addDuration").value.length > 0){
          document.getElementById("codeAndLabel").focus();
          alertDialog("web.manage","addData");
          okToSubmit = false;
        }
      }

      if(okToSubmit){
        if(document.getElementById("addCode").value.length > 0){
          document.getElementById("addDuration").focus();
          alertDialog("web.manage","addData");
          okToSubmit = false;
        }
      }
    }

    <%-- check required fields --%>
    if(okToSubmit){
      if(document.getElementById("Begin").value.length==0){
        document.getElementById("Begin").focus();
                  alertDialog("web.manage","dataMissing");
        okToSubmit = false;
      }
    } 

    if(okToSubmit){
      if(document.getElementById("End").value.length==0){
        document.getElementById("End").focus();
                  alertDialog("web.manage","dataMissing");
        okToSubmit = false;
      }
    }
    
    <%-- begin can not be after end --%>
    if(document.getElementById("End").value.length > 0){
      var calculBegin = makeDate(document.getElementById("Begin").value),
          calculEnd   = makeDate(document.getElementById("End").value);
      
      if(calculBegin > calculEnd){
        okToSubmit = false;
        alertDialog("web","beginMustComeBeforeEnd");
        document.getElementById("Begin").focus();
      }  
    }
    
    <%-- check codes --%>
    if(okToSubmit){
      if(document.getElementById("tblCC").rows.length < 3){
        document.getElementById("addDuration").focus();
        alertDialog("web.manage","specifyAtLeastOneCode");
        okToSubmit = false;
      }
    } 
    
    if(okToSubmit){
      var url = "<c:url value='/hr/ajax/salarycalculations/repeatCalculation.jsp'/>?ts="+new Date().getTime();
      var params = "Action=save"+
                   "&PersonId="+document.getElementById("PersonId").value+
                   "&Begin="+document.getElementById("Begin").value+
                   "&End="+document.getElementById("End").value+
                   "&Source="+document.getElementById("Source").value+
                   "&Type="+document.getElementById("Type").value+
                   "&CalculationCodes="+removeTRIndexes(sCC);

      new Ajax.Request(url,{
        evalScripts: true,
        parameters: params,
        onComplete: function(){setTimeout("displayClientMsgDataIsSaved()",500)} // wait for sql to save data
      });
    }
  }
    
  <%--- CALCULATION CODES -----------------------------------------------------------------------%>
  var editCCRowid = "", iCCIndex = 0, sCC = "";

  <%-- DISPLAY CALCULATION CODES --%>
  function displayCalculationCodes(){
    sCC = document.getElementById("calculationCodes").value;
        
    if(sCC.indexOf("|") > -1){
      var sTmpCC = sCC;
      sCC = "";
      
      var sTmpDuration, sTmpCode, sTmpLabel;
 
      while(sTmpCC.indexOf("$") > -1){
        sTmpDuration = "";
        sTmpCode = "";
        sTmpLabel = "";

        if(sTmpCC.indexOf("|") > -1){
          sTmpDuration = sTmpCC.substring(0,sTmpCC.indexOf("|"));
          sTmpCC = sTmpCC.substring(sTmpCC.indexOf("|")+1);
        }
        
        if(sTmpCC.indexOf("|") > -1){
          sTmpCode = sTmpCC.substring(0,sTmpCC.indexOf("|"));
          sTmpCC = sTmpCC.substring(sTmpCC.indexOf("|")+1);
        }
            
        if(sTmpCC.indexOf("$") > -1){
          sTmpLabel = sTmpCC.substring(0,sTmpCC.indexOf("$"));
          sTmpCC = sTmpCC.substring(sTmpCC.indexOf("$")+1);
        }

        sCC+= "rowCC"+iCCIndex+"="+sTmpDuration+"|"+
                                   sTmpCode+"$";
        displayCC(iCCIndex++,sTmpDuration,sTmpCode,sTmpLabel);
      }
    }
  }
  
  <%-- DELETE Calculation Code --%>
  function deleteCC(rowid){ 
      if(yesnoDeleteDialog()){
      sCC = deleteRowFromArrayString(sCC,rowid.id);
      
      var tblCC = document.getElementById("tblCC"); // FF
      tblCC.deleteRow(rowid.rowIndex);
      clearCCFields();
    }
  }
  
  <%-- ADD Calculation Code (user) --%>
  function addCC(){ 
    if(okToAdd()){
      var tblCC = document.getElementById("tblCC"); // FF
      var tr = tblCC.insertRow(tblCC.rows.length);
      iCCIndex++;
      tr.id = "rowCC"+iCCIndex;
    
      var td = tr.insertCell(0);
      td.innerHTML = "<a href='javascript:deleteCC(rowCC"+iCCIndex+")'>"+
                      "<img src='<%=sCONTEXTPATH%>/_img/icons/icon_delete.gif' alt='<%=getTranNoLink("web","delete",sWebLanguage)%>' border='0' style='vertical-align:-2px;'>"+
                     "</a>"+
                     "<a href='javascript:editCC(rowCC"+iCCIndex+")'>"+
                      "<img src='<%=sCONTEXTPATH%>/_img/icons/icon_edit.gif' alt='<%=getTranNoLink("web","edit",sWebLanguage)%>' border='0' style='vertical-align:-3px;'>"+
                     "</a>";
      tr.appendChild(td);

      td = tr.insertCell(1);
      var duration = document.getElementById("addDuration").value;
      duration = replaceAll(duration,",",".");
      if(duration.indexOf(".")<0) duration = duration+".0";
      td.innerHTML = duration;
      tr.appendChild(td);
      
      td = tr.insertCell(2);
      td.innerHTML = document.getElementById("codeAndLabel").value;
      tr.appendChild(td);
      
      sCC+= "rowCC"+iCCIndex+"="+document.getElementById("addDuration").value+"|"+
                                 document.getElementById("addCode").value+"$";

      clearCCFields();
      setRowStyle(tr,iCCIndex+1);
    }
    
    return okToAdd;
  }
  
  <%-- OK TO ADD --%>
  function okToAdd(){
    var okToAdd = true;
    
    if(okToAdd){
      if(document.getElementById("addDuration").value.length==0){
        document.getElementById("addDuration").focus();
                  alertDialog("web.manage","dataMissing");
        okToAdd = false;
      }
    }
    
    if(okToAdd){
      if(document.getElementById("addCode").value.length==0){
        document.getElementById("codeAndLabel").focus();
                  alertDialog("web.manage","dataMissing");
        okToAdd = false;
      }
    }
    
    <%-- duration max 24 hrs --%>
    if(okToAdd){
      if(document.getElementById("addDuration").value.length > 0){
        var hrs = document.getElementById("addDuration").value*1;
        if(hrs > 24){
          document.getElementById("addDuration").focus();
          alertDialog("web","durationToLong");
          okToAdd = false;
        }
      }
    }
    
    return okToAdd;
  }
  
  <%-- DISPLAY Calculation Code --%>
  function displayCC(iCCIndex,duration,code,label){
    var tblCC = document.getElementById("tblCC"); // FF
    var tr = tblCC.insertRow(tblCC.rows.length);
    tr.id = "rowCC"+iCCIndex;

    var td = tr.insertCell(0);
    td.innerHTML = "<a href='javascript:deleteCC(rowCC"+iCCIndex+")'>"+
                    "<img src='<%=sCONTEXTPATH%>/_img/icons/icon_delete.gif' alt='<%=getTranNoLink("web","delete",sWebLanguage)%>' border='0' style='vertical-align:-2px;'>"+
                   "</a>"+
                   "<a href='javascript:editCC(rowCC"+iCCIndex+")'>"+
                    "<img src='<%=sCONTEXTPATH%>/_img/icons/icon_edit.gif' alt='<%=getTranNoLink("web","edit",sWebLanguage)%>' border='0' style='vertical-align:-3px;'>"+
                   "</a>";
    tr.appendChild(td);

    td = tr.insertCell(1);
    duration = replaceAll(duration,",",".");
    if(duration.indexOf(".")<0) duration = duration+".0";
    td.innerHTML = duration;
    tr.appendChild(td);
    
    td = tr.insertCell(2);
    td.innerHTML = code+" - "+label;
    tr.appendChild(td);

    setRowStyle(tr,iCCIndex);
  }

  <%-- EDIT CC --%>
  function editCC(rowid){
    var row = getRowFromArrayString(sCC,rowid.id);

    document.getElementById("addDuration").value = getCelFromRowString(row,0);
    document.getElementById("codeAndLabel").value = tblCC.rows[rowid.rowIndex].cells[2].innerHTML; // content of cell
    document.getElementById("addCode").value = getCelFromRowString(row,1);

    editCCRowid = rowid;
    document.getElementById("buttonUpdate").disabled = false;
    document.getElementById("addDuration").focus();
  }
  
  <%-- UPDATE Calculation Code --%>
  function updateCC(){
    if(okToAdd()){
      <%-- update arrayString --%>
      var newRow = editCCRowid.id+"="+document.getElementById("addDuration").value+"|"+
                                      document.getElementById("addCode").value;
      sCC = replaceRowInArrayString(sCC,newRow,editCCRowid.id);

      <%-- update table object --%>
      var tblCC = document.getElementById("tblCC"); // FF
      var row = tblCC.rows[editCCRowid.rowIndex];
      row.cells[0].innerHTML = "<a href='javascript:deleteCC("+editCCRowid.id+")'>"+
                                "<img src='<%=sCONTEXTPATH%>/_img/icons/icon_delete.gif' alt='<%=getTranNoLink("web","delete",sWebLanguage)%>' border='0' style='vertical-align:-2px;'>"+
                               "</a>"+
                               "<a href='javascript:editCC("+editCCRowid.id+")'>"+
                                "<img src='<%=sCONTEXTPATH%>/_img/icons/icon_edit.gif' alt='<%=getTranNoLink("web","edit",sWebLanguage)%>' border='0' style='vertical-align:-3px;'>"+
                               "</a>";

      var duration = document.getElementById("addDuration").value;
      duration = replaceAll(duration,",",".");
      if(duration.indexOf(".")<0) duration = duration+".0";
      row.cells[1].innerHTML = duration;
      
      row.cells[2].innerHTML = document.getElementById("codeAndLabel").value;
      
      <%-- reset --%>
      clearCCFields();
      document.getElementById("buttonUpdate").disabled = true;
    }
  }

  <%-- DELETE Calculation Code --%>
  function deleteCC(rowid){ 
      if(yesnoDeleteDialog()){
      sCC = deleteRowFromArrayString(sCC,rowid.id);
      tblCC.deleteRow(rowid.rowIndex);
      clearCCFields();
    }
  }
  
  <%-- CLEAR Calculation Code FIELDS --%>
  function clearCCFields(){
    document.getElementById("addDuration").value = "";
    document.getElementById("addCode").value = "";
    document.getElementById("codeAndLabel").value = "";
    
    document.getElementById("addDuration").focus();
  }
</script>
  