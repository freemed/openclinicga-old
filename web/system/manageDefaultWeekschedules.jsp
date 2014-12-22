<%@page import="org.dom4j.DocumentException,
                java.util.Vector,
                java.text.*"%>
<%@page import="java.io.StringReader"%>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>
<%@include file="/includes/commonFunctions.jsp"%>
<%=checkPermission("hr.workschedule.edit","edit",activeUser)%>

<script src="<%=sCONTEXTPATH%>/hr/includes/commonFunctions.js"></script> 

<%=sJSPROTOTYPE%>
<%=sJSNUMBER%> 
<%=sJSSTRINGFUNCTIONS%>
<%=sJSSORTTABLE%>

<%
    /// DEBUG //////////////////////////////////////////////////////////////////////
    if(Debug.enabled){
        Debug.println("\n********* system/manageDefaultWeekschedules.jsp *********");
        Debug.println("no parameters\n");
    }
    ////////////////////////////////////////////////////////////////////////////////    
%>            

<form name="EditForm">
    <%=writeTableHeader("web.manage","manageDefaultWeekschedules",sWebLanguage,"")%>
    <input type="hidden" name="EditScheduleUid" value="new">

    <table border="0" width="100%" cellspacing="1">
        <%-- weekScheduleType select --%>
        <tr>
            <td class="admin" width="150" nowrap><%=getTran("web.hr","weekSchedule",sWebLanguage)%>&nbsp;</td>
            <td class="admin2" id="weekScheduleTypeSelectTR"><%-- ajax --%></td>
        </tr>
        
        <%-- weekScheduleType (new value) --%>
        <tr>
            <td class="admin" nowrap><%=getTran("web.hr","weekScheduleType",sWebLanguage)%>&nbsp;</td>
            <td class="admin2">
                <input type="text" class="text" id="weekScheduleType" name="weekScheduleType" size="20" maxLength="50" value="">
            </td>
        </tr>
                                        
        <%-- weekSchedule/timeBlocks (multi-add) --%>
        <tr>
            <td class="admin" nowrap><%=getTran("web.hr","timeBlocks",sWebLanguage)%></td>
            <td class="admin2">
                <input type="hidden" id="timeBlocks" name="timeBlocks" value="">
                                     
                <table width="500" class="sortable" id="tblTB" cellspacing="1" headerRowCount="2"> 
                    <%-- header --%>                        
                    <tr class="admin">
                        <%-- 0 - empty --%>
                        <td width="40" nowrap/>
                        <%-- 1 - timeBlockDay --%>
                        <td width="100" nowrap style="padding-left:0px;">
                            <%=getTran("web.hr","timeBlockDay",sWebLanguage)%>&nbsp;
                        </td>
                        <%-- 2 - timeBlockStart --%>
                        <td width="70" nowrap style="padding-left:0px;">
                            <%=getTran("web.hr","timeBlockStart",sWebLanguage)%>&nbsp;
                        </td>
                        <%-- 3 - timeBlockEnd --%>
                        <td width="70" nowrap style="padding-left:0px;">
                            <%=getTran("web.hr","timeBlockEnd",sWebLanguage)%>&nbsp;
                        </td>    
                        <%-- 4 - timeBlockHours --%>
                        <td width="80" nowrap style="padding-left:0px;">
                            <%=getTran("web.hr","timeBlockHours",sWebLanguage)%>&nbsp;*&nbsp;
                        </td>    
                        <%-- 5 - empty --%>
                        <td width="100" nowrap/>    
                    </tr>
            
                    <%-- content by ajax and javascript --%>
                    
                    <%-- add-row --%>                          
                    <tr>
                        <%-- 0 - empty --%>
                        <td class="admin"/>
                        <%-- 1 - tbDayIdx --%>
                        <td class="admin"> 
                            <select class="text" id="tbDayIdx" name="tbDayIdx">
                                <option/>
                                <%=ScreenHelper.writeSelectUnsorted("hr.workschedule.days","",sWebLanguage)%>
                            </select>&nbsp;
                        </td>
                        <%-- 2 - tbBeginHour --%>
                        <td class="admin" nowrap> 
                            <input type="text" class="text" id="tbBeginHour" name="tbBeginHour" size="2" maxLength="5" value="" onKeypress="keypressTime(this);" onBlur="checkTime(this);calculateInterval('tbBeginHour','tbEndHour','tbDuration');">&nbsp;
                        </td>
                        <%-- 3 - tbEndHour --%>
                        <td class="admin" nowrap>
                            <input type="text" class="text" id="tbEndHour" name="tbEndHour" size="2" maxLength="5" value="" onKeypress="keypressTime(this);" onBlur="checkTime(this);calculateInterval('tbBeginHour','tbEndHour','tbDuration');">&nbsp;
                        </td>    
                        <%-- 4 - tbDuration --%>
                        <td class="admin" nowrap> 
                            <input type="text" class="text" id="tbDuration" name="tbDuration" size="2" maxLength="5" onKeypress="keypressTime(this);" onBlur="checkTime(this);" value="">&nbsp;<%=getTran("web","hours",sWebLanguage)%>&nbsp;
                        </td>
                        <%-- 5 - buttons --%>
                        <td class="admin">
                            <input type="button" class="button" name="ButtonAddTB" value="<%=getTranNoLink("web","add",sWebLanguage)%>" onclick="addTB();">
                            <input type="button" class="button" name="ButtonUpdateTB" value="<%=getTranNoLink("web","edit",sWebLanguage)%>" onclick="updateTB();" disabled>&nbsp;
                        </td>    
                    </tr>
                </table>
            </td>
        </tr>
                       
        <%-- BUTTONS --%>
        <tr>     
            <td class="admin"/>
            <td class="admin2">
                <input class="button" type="button" name="buttonSave" value=" <%=getTranNoLink("web","save",sWebLanguage)%> " onclick="saveWeekschedule();">&nbsp;&nbsp;
                <input class="button" type="button" name="buttonAdd" value="<%=getTranNoLink("web","add",sWebLanguage)%>" onclick="addWeekschedule();" style="visibility:hidden;">&nbsp;
                <input class="button" type="button" name="buttonDelete" value="<%=getTranNoLink("web","delete",sWebLanguage)%>" onclick="deleteWeekschedule();" style="visibility:hidden;">&nbsp;
            </td>
        </tr>
    </table>
    
    <i><%=getTran("web","colored_fields_are_obligate",sWebLanguage)%></i><br>
    
    <div id="divMessage" style="padding-top:10px;"></div><br>
    
    <i>This value is saved as config-value 'defaultWeekSchedules'.</i><br>
    
    <%-- link to manageConfig --%>
    <img src='<c:url value="/_img/themes/default/pijl.gif"/>'>
    <a  href="<c:url value='/main.do'/>?Page=system/manageConfig.jsp?ts=<%=getTs()%>" onMouseOver="window.status='';return true;"><%=getTran("Web.Manage","manageConfiguration",sWebLanguage)%></a>&nbsp;    
</form>
    
<script>  
  <%-- WRITE WEEKSCHEDULE OPTIONS --%>
  function writeWeekScheduleOptions(){
    var url = "<c:url value='/system/ajax/defaultWeekschedules/getWeekscheduleOptions.jsp'/>?ts="+new Date().getTime();
    
    new Ajax.Request(url,
      {                     
        onSuccess: function(resp){
          $("weekScheduleTypeSelectTR").innerHTML = resp.responseText.trim();
        },
        onFailure: function(resp){
          $("divMessage").innerHTML = "Error in 'system/ajax/defaultWeekschedules/getWeekscheduleOptions.jsp' : "+resp.responseText.trim();
        }
      }
    );
  }

  <%-- CALCULATE HOURS PER WEEK --%>
  function calculateHoursPerWeek(sTableArrayString){
    var hoursPerWeek = 0, oneRow, hours;
    
    while(sTableArrayString.indexOf("$") > -1){
      oneRow = sTableArrayString.substring(0,sTableArrayString.indexOf("$"));
      oneRow = oneRow.substring(oneRow.indexOf("=")+1); // trim off index

      sTableArrayString = sTableArrayString.substring(sTableArrayString.indexOf("$")+1);
      
      hours = oneRow.split("|")[3]; // duration
      hours = hourToDecimal(hours);    
      hoursPerWeek+= hours;
    }
    
    return hoursPerWeek;
  }
  
  <%-- HOUR TO DECIMAL --%>
  function hourToDecimal(hourValue){
    var hoursDeci = 0;
    
    if(hourValue.indexOf(":") > -1){ 
      var hours = hourValue.split(":")[0],
          mins  = hourValue.split(":")[1];

      hoursDeci = (hours*1)+((mins*1)/60);
    }
    
    return hoursDeci;
  }
  
  <%-- DECIMAL TO HOUR --%>
  function decimalToHour(hoursDeci){
    hoursDeci = (hoursDeci+"").replace(",",".");
    if(hoursDeci.indexOf(".")==-1){
      hoursDeci = hoursDeci+".0";
    }
    
    var hours = hoursDeci.substring(0,hoursDeci.indexOf("."));
    var mins = ((hoursDeci.substring(hoursDeci.indexOf(".")+1))/100)*60;
    if((""+mins).length > 2) mins = (""+mins).substring(0,2);

    if(hours<10) hours = "0"+hours;
    if(mins<10) mins = "0"+mins;

    return hours+":"+mins;
  }
    
  <%-- SET WEEKSCHEDULE TYPE --%>
  function setWeekScheduleType(value){
    if(value=="New"){
      document.getElementById("buttonAdd").style.visibility = "hidden";
      document.getElementById("buttonDelete").style.visibility = "hidden";
        
      document.getElementById("weekScheduleType").value = "";
      document.getElementById("weekScheduleType").focus();
    }
    else{
      document.getElementById("weekScheduleType").value = value;
    }
  }
    
  <%-- SAVE WEEKSCHEDULE --%>
  function saveWeekschedule(resetId){
    if(resetId==undefined) resetId = false;
    
    <%-- for 'new' 'save' acts as 'add' --%>
    if(document.getElementById("weekScheduleTypeSelect").selectedIndex==0){
      resetId = true;
    }
    
    var okToSubmit = true;

    if(okToSubmit){
      if(document.getElementById("weekScheduleType").value.length==0){
        okToSubmit = false;
        document.getElementById("weekScheduleType").focus();
                  window.showModalDialog?alertDialog("web.manage","dataMissing"):alertDialogDirectText('<%=getTran("web.manage","dataMissing",sWebLanguage)%>');
      }
    }
    
    if(okToSubmit){
      if(tblTB.rows.length==2){
        okToSubmit = false;
        alertDialog("web.manage","atLeastOneTimeBlockRequired");
      }
    }
    
    if(okToSubmit){
      if(resetId==true){
        EditForm.EditScheduleUid.value = "new";
      }
      
      document.getElementById("divMessage").innerHTML = "<img src='<%=sCONTEXTPATH%>/_img/themes/<%=sUserTheme%>/ajax-loader.gif'/><br>Saving";  

      <%-- disable buttons --%>
      document.getElementById("buttonSave").disabled = true;
      document.getElementById("buttonAdd").disabled = true;
      document.getElementById("buttonDelete").disabled = true;

      var url = "<c:url value='/system/ajax/defaultWeekschedules/saveDefaultWeekschedule.jsp'/>?ts="+new Date().getTime();
      
      <%-- parameters --%>
      var sParameters = "ScheduleUid="+EditForm.EditScheduleUid.value+
                        "&ScheduleType="+EditForm.weekScheduleType.value+
                        "&TimeBlocks="+removeTRIndexes(sTB);  
      
      new Ajax.Request(url,
        {
          method: "POST",
          postBody: sParameters,                        
          onSuccess: function(resp){
            var data = eval("("+resp.responseText+")");
            $("divMessage").innerHTML = data.message;
            writeWeekScheduleOptions();
            clearWeekScheduleFields();
                            
            <%-- enable buttons --%>
            document.getElementById("buttonSave").disabled = false;
            document.getElementById("buttonAdd").disabled = false;
            document.getElementById("buttonDelete").disabled = false;
          },
          onFailure: function(resp){
            $("divMessage").innerHTML = "Error in 'system/ajax/defaultWeekschedules/saveDefaultWeekschedule.jsp' : "+resp.responseText.trim();
          }
        }
      );
    }
  }
  
  <%-- ADD WEEKSCHEDULE --%>
  function addWeekschedule(){
    saveWeekschedule(true); 
  }
  
  <%-- REMOVE TR INDEXES --%>
  function removeTRIndexes(sTableArrayString){
    var oneRow, sArrayString = "";
      
    while(sTableArrayString.indexOf("$") > -1){
      oneRow = sTableArrayString.substring(0,sTableArrayString.indexOf("$"));
      oneRow = oneRow.substring(oneRow.indexOf("=")+1); // trim off index
      
      sTableArrayString = sTableArrayString.substring(sTableArrayString.indexOf("$")+1);
      sArrayString+= oneRow+"$";
    }

    return sArrayString;
  }   
        
  <%-- DELETE WEEKSCHEDULE --%>
  function deleteWeekschedule(){
      if(yesnoDeleteDialog()){
      var url = "<c:url value='/system/ajax/defaultWeekschedules/deleteDefaultWeekschedule.jsp'/>?ts="+new Date().getTime();

      <%-- disable buttons --%>
      document.getElementById("buttonSave").disabled = true;
      document.getElementById("buttonAdd").disabled = true;
      document.getElementById("buttonDelete").disabled = true;
    
      new Ajax.Request(url,
        {
          method: "GET",
          parameters: "ScheduleUid="+EditForm.EditScheduleUid.value,
          onSuccess: function(resp){
            var data = eval("("+resp.responseText+")");
            $("divMessage").innerHTML = data.message;
            writeWeekScheduleOptions();
            clearWeekScheduleFields();

            <%-- enable buttons --%>
            document.getElementById("buttonSave").disabled = false;
            document.getElementById("buttonAdd").disabled = false;
            document.getElementById("buttonDelete").disabled = false;
          },
          onFailure: function(resp){
            $("divMessage").innerHTML = "Error in 'system/ajax/defaultWeekschedules/deleteDefaultWeekschedule.jsp' : "+resp.responseText.trim();
          }  
        }
      );
    }
  }
       
  <%-- CLEAR WEEK SCHEDULE FIELDS --%>
  function clearWeekScheduleFields(){
    document.getElementById("weekScheduleTypeSelect").selectedIndex = 0;
    document.getElementById("weekScheduleType").value = "";
    document.getElementById("timeBlocks").value = "";
    clearTimeBlockTable();
    displayTimeBlocks();

    <%-- clear add-fields --%>
    document.getElementById("tbDayIdx").selectedIndex = 0;
    document.getElementById("tbBeginHour").value = "";
    document.getElementById("tbEndHour").value = "";
    document.getElementById("tbDuration").value = "";
    
    <%-- hide buttons --%>
    document.getElementById("buttonAdd").style.visibility = "hidden";
    document.getElementById("buttonDelete").style.visibility = "hidden";
  }
 
  <%-- CALCULATE INTERVAL --%>
  function calculateInterval(sBeginField,sEndField,sResultField){
    document.getElementById(sResultField).value = "";
      
    if(document.getElementById(sBeginField).value.length>0 && document.getElementById(sEndField).value.length>0){          
      <%-- begin --%>
      var aTimeBegin = document.getElementById(sBeginField).value.split(":");
      var startHour = aTimeBegin[0];
      if(startHour.length==0) startHour = 0;
      var startMinute = aTimeBegin[1];
      if(startMinute.length==0) startMinute = 0;

      <%-- end --%>
      var aTimeEnd = document.getElementById(sEndField).value.split(":");
      var stopHour = aTimeEnd[0];
      if(stopHour.length==0) stopHour = 0;
      var stopMinute = aTimeEnd[1];
      if(stopMinute.length==0) stopMinute = 0;

      var dateFrom = new Date(2000,1,1,startHour,startMinute,0),
          dateUntil = new Date(2000,1,1,stopHour,stopMinute,0);

      var iMinutes = getMinutesInInterval(dateFrom,dateUntil);
      var sHour = parseInt(iMinutes / 60);
      var sMinutes = (iMinutes % 60)+"";

      document.getElementById(sResultField).value = sHour+":"+sMinutes; 
      checkTime(document.getElementById(sResultField));
    }
  }

  <%-- GET MINUTES IN INTERVAL --%>
  function getMinutesInInterval(from,until){
    var millisDiff = until.getTime() - from.getTime();
    return (millisDiff/(60*1000));
  }
  
  <%-- TIME BLOCK FUNCTIONS ---------------------------------------------------------------------%>
  var editTBRowid = "", iTBIndex = 1, sTB = "";

  <%-- SET TIME BLOCKS STRING --%>
  function setTimeBlocksString(weekScheduleId){
    clearTimeBlockTable();
      
    if(weekScheduleId.length > 0){
      document.getElementById("divMessage").innerHTML = "<img src='<%=sCONTEXTPATH%>/_img/themes/<%=sUserTheme%>/ajax-loader.gif'/><br>Loading..";            
      var url = "<c:url value='/system/ajax/defaultWeekschedules/getDefaultWeekschedule.jsp'/>?ts="+new Date().getTime();
      
      new Ajax.Request(url,
        {
          method: "GET",
          parameters: "WeekScheduleId="+weekScheduleId,
          onSuccess: function(resp){
            var data = eval("("+resp.responseText+")");
          
            document.getElementById("timeBlocks").value = data.weekSchedule;
            document.getElementById("divMessage").innerHTML = "";    

            if(weekScheduleId=="New"){
              document.getElementById("buttonAdd").style.visibility = "hidden";
              document.getElementById("buttonDelete").style.visibility = "hidden";
              clearWeekScheduleFields();
            }
            else{
              document.getElementById("buttonAdd").style.visibility = "visible";
              document.getElementById("buttonDelete").style.visibility = "visible";
            }
          
            EditForm.EditScheduleUid.value = weekScheduleId;
            displayTimeBlocks();
          },
          onFailure: function(resp){
            $("divMessage").innerHTML = "Error in 'system/ajax/defaultWeekschedules/getDefaultWeekschedule.jsp' : "+resp.responseText.trim();
          }
        }
      );
    }
  }
  
  <%-- DISPLAY TIME BLOCKS --%>
  function displayTimeBlocks(){
    sTB = document.getElementById("timeBlocks").value;
        
    if(sTB.indexOf("|") > -1){
      var sTmpTB = sTB;
      sTB = "";
      
      var sTmpDayIdx, sTmpBeginHour, sTmpEndHour, sTmpDuration;
 
      while(sTmpTB.indexOf("$") > -1){
        sTmpDayIdx = "";
        sTmpBeginHour = "";
        sTmpEndHour = "";
        sTmpDuration = "";

        if(sTmpTB.indexOf("|") > -1){
          sTmpDayIdx = sTmpTB.substring(0,sTmpTB.indexOf("|"));
          sTmpTB = sTmpTB.substring(sTmpTB.indexOf("|")+1);
        }
        
        if(sTmpTB.indexOf("|") > -1){
          sTmpBeginHour = sTmpTB.substring(0,sTmpTB.indexOf("|"));
          sTmpTB = sTmpTB.substring(sTmpTB.indexOf("|")+1);
        }
            
        if(sTmpTB.indexOf("|") > -1){
          sTmpEndHour = sTmpTB.substring(0,sTmpTB.indexOf("|"));
          sTmpTB = sTmpTB.substring(sTmpTB.indexOf("|")+1);
        }

        if(sTmpTB.indexOf("$") > -1){
          sTmpDuration = sTmpTB.substring(0,sTmpTB.indexOf("$"));
          sTmpTB = sTmpTB.substring(sTmpTB.indexOf("$")+1);
        }

        sTB+= "rowTB"+iTBIndex+"="+sTmpDayIdx+"|"+
                                   sTmpBeginHour+"|"+
                                   sTmpEndHour+"|"+
                                   sTmpDuration+"$";
        displayTimeBlock(iTBIndex++,sTmpDayIdx,sTmpBeginHour,sTmpEndHour,sTmpDuration);
      }
    }
  }
  
  <%-- DISPLAY TIME BLOCK --%>
  function displayTimeBlock(iTBIndex,sTmpDayIdx,sTmpBeginHour,sTmpEndHour,sTmpDuration){
    var tr = tblTB.insertRow(tblTB.rows.length);
    tr.id = "rowTB"+iTBIndex;

    var td = tr.insertCell(0);
    td.innerHTML = "<a href='javascript:deleteTB(rowTB"+iTBIndex+")'>"+
                    "<img src='<%=sCONTEXTPATH%>/_img/icons/icon_delete.gif' alt='<%=getTranNoLink("web","delete",sWebLanguage)%>' border='0' style='vertical-align:-2px;'>"+
                   "</a> "+
                   "<a href='javascript:editTB(rowTB"+iTBIndex+")'>"+
                    "<img src='<%=sCONTEXTPATH%>/_img/icons/icon_edit.gif' alt='<%=getTranNoLink("web","edit",sWebLanguage)%>' border='0' style='vertical-align:-3px;'>"+
                   "</a>";
    tr.appendChild(td);

    <%-- day name --%>
    td = tr.insertCell(1);
         if(sTmpDayIdx=="1") td.innerHTML = "&nbsp;<%=getTranNoLink("hr.workschedule.days","day1",sWebLanguage)%>";
    else if(sTmpDayIdx=="2") td.innerHTML = "&nbsp;<%=getTranNoLink("hr.workschedule.days","day2",sWebLanguage)%>";
    else if(sTmpDayIdx=="3") td.innerHTML = "&nbsp;<%=getTranNoLink("hr.workschedule.days","day3",sWebLanguage)%>";
    else if(sTmpDayIdx=="4") td.innerHTML = "&nbsp;<%=getTranNoLink("hr.workschedule.days","day4",sWebLanguage)%>";
    else if(sTmpDayIdx=="5") td.innerHTML = "&nbsp;<%=getTranNoLink("hr.workschedule.days","day5",sWebLanguage)%>";
    else if(sTmpDayIdx=="6") td.innerHTML = "&nbsp;<%=getTranNoLink("hr.workschedule.days","day6",sWebLanguage)%>";
    else if(sTmpDayIdx=="7") td.innerHTML = "&nbsp;<%=getTranNoLink("hr.workschedule.days","day7",sWebLanguage)%>";
    tr.appendChild(td);

    td = tr.insertCell(2);
    td.innerHTML = "&nbsp;"+sTmpBeginHour;
    tr.appendChild(td);

    td = tr.insertCell(3);
    td.innerHTML = "&nbsp;"+sTmpEndHour;
    tr.appendChild(td);

    td = tr.insertCell(4);
    td.innerHTML = "&nbsp;"+sTmpDuration;
    tr.appendChild(td);
      
    <%-- empty cell --%>
    td = tr.insertCell(5);
    td.innerHTML = "&nbsp;";
    tr.appendChild(td);
    
    setRowStyle(tr,iTBIndex);
  }
  
  <%-- ADD TIME BLOCK --%>
  function addTB(){
    if(areRequiredTBFieldsFilled()){
      var okToAdd = true;
      
      <%-- check hours --%>
      if(EditForm.tbBeginHour.value.length > 0 && EditForm.tbEndHour.value.length > 0){
        <%-- begin --%>
        var beginHour = EditForm.tbBeginHour.value.split(":")[0];
        if(beginHour.length==0) beginHour = 0;
        var beginMinute = EditForm.tbBeginHour.value.split(":")[1];
        if(beginMinute.length==0) beginMinute = 0;

        <%-- end --%>
        var endHour = EditForm.tbEndHour.value.split(":")[0];
        if(endHour.length==0) endHour = 0;
        var endMinute = EditForm.tbEndHour.value.split(":")[1];
        if(endMinute.length==0) endMinute = 0;
        
        var beginHour = new Date(2000,1,1,beginHour,beginMinute,0),
            endHour   = new Date(2000,1,1,endHour,endMinute,0);

        if(beginHour.getTime() > endHour.getTime()){
          okToAdd = false;
        }
      }
    
      if(okToAdd==true){
        iTBIndex++;

        <%-- update arrayString --%>
        sTB+="rowTB"+iTBIndex+"="+EditForm.tbDayIdx.selectedIndex+"|"+
                                  EditForm.tbBeginHour.value+"|"+
                                  EditForm.tbEndHour.value+"|"+
                                  EditForm.tbDuration.value+"$";
      
        var tr = tblTB.insertRow(tblTB.rows.length);
        tr.id = "rowTB"+iTBIndex;

        var td = tr.insertCell(0);
        td.innerHTML = "<a href='javascript:deleteTB(rowTB"+iTBIndex+")'>"+
                        "<img src='<%=sCONTEXTPATH%>/_img/icons/icon_delete.gif' alt='<%=getTranNoLink("web","delete",sWebLanguage)%>' border='0'>"+
                       "</a> "+
                       "<a href='javascript:editTB(rowTB"+iTBIndex+")'>"+
                        "<img src='<%=sCONTEXTPATH%>/_img/icons/icon_edit.gif' alt='<%=getTranNoLink("web","edit",sWebLanguage)%>' border='0'>"+
                       "</a>";
        tr.appendChild(td);

        <%-- day name --%>
        td = tr.insertCell(1);
             if(EditForm.tbDayIdx.selectedIndex=="1") td.innerHTML = "&nbsp;<%=getTranNoLink("hr.workschedule.days","day1",sWebLanguage)%>";
        else if(EditForm.tbDayIdx.selectedIndex=="2") td.innerHTML = "&nbsp;<%=getTranNoLink("hr.workschedule.days","day2",sWebLanguage)%>";
        else if(EditForm.tbDayIdx.selectedIndex=="3") td.innerHTML = "&nbsp;<%=getTranNoLink("hr.workschedule.days","day3",sWebLanguage)%>";
        else if(EditForm.tbDayIdx.selectedIndex=="4") td.innerHTML = "&nbsp;<%=getTranNoLink("hr.workschedule.days","day4",sWebLanguage)%>";
        else if(EditForm.tbDayIdx.selectedIndex=="5") td.innerHTML = "&nbsp;<%=getTranNoLink("hr.workschedule.days","day5",sWebLanguage)%>";
        else if(EditForm.tbDayIdx.selectedIndex=="6") td.innerHTML = "&nbsp;<%=getTranNoLink("hr.workschedule.days","day6",sWebLanguage)%>";
        else if(EditForm.tbDayIdx.selectedIndex=="7") td.innerHTML = "&nbsp;<%=getTranNoLink("hr.workschedule.days","day7",sWebLanguage)%>";
        tr.appendChild(td);

        td = tr.insertCell(2);
        td.innerHTML = "&nbsp;"+EditForm.tbBeginHour.value;
        tr.appendChild(td);

        td = tr.insertCell(3);
        td.innerHTML = "&nbsp;"+EditForm.tbEndHour.value;
        tr.appendChild(td);

        td = tr.insertCell(4);
        td.innerHTML = "&nbsp;"+EditForm.tbDuration.value;
        tr.appendChild(td);
      
        <%-- empty cell --%>
        td = tr.insertCell(5);
        td.innerHTML = "&nbsp;";
        tr.appendChild(td);

        setRowStyle(tr,iTBIndex);
      
        <%-- reset --%>
        clearTBFields()
        EditForm.ButtonUpdateTB.disabled = true;
      }
      else{
        alertDialog("web.hr","beginHourMustComeBeforeEndHour");
        EditForm.tbBeginHour.focus();
      }
    }
    else{
                window.showModalDialog?alertDialog("web.manage","dataMissing"):alertDialogDirectText('<%=getTran("web.manage","dataMissing",sWebLanguage)%>');
      
      <%-- focus empty field --%>
      if(EditForm.tbDuration.value.length==0) EditForm.tbDuration.focus();
    }
    
    return true;
  }

  <%-- UPDATE TIME BLOCK --%>
  function updateTB(){
    if(areRequiredTBFieldsFilled()){
      var okToAdd = true;
      
      <%-- check hours --%>
      if(EditForm.tbBeginHour.value.length > 0 && EditForm.tbEndHour.value.length > 0){
        <%-- begin --%>
        var beginHour = EditForm.tbBeginHour.value.split(":")[0];
        if(beginHour.length==0) beginHour = 0;
        var beginMinute = EditForm.tbBeginHour.value.split(":")[1];
        if(beginMinute.length==0) beginMinute = 0;

        <%-- end --%>
        var endHour = EditForm.tbEndHour.value.split(":")[0];
        if(endHour.length==0) endHour = 0;
        var endMinute = EditForm.tbEndHour.value.split(":")[1];
        if(endMinute.length==0) endMinute = 0;
        
        var beginHour = new Date(2000,1,1,beginHour,beginMinute,0),
            endHour   = new Date(2000,1,1,endHour,endMinute,0);

        if(beginHour.getTime() > endHour.getTime()){
          okToAdd = false;
        }
      }
    
      if(okToAdd==true){        
        <%-- update arrayString --%>
        var newRow = editTBRowid.id+"="+EditForm.tbDayIdx.selectedIndex+"|"+
                                        EditForm.tbBeginHour.value+"|"+
                                        EditForm.tbEndHour.value+"|"+
                                        EditForm.tbDuration.value;

        sTB = replaceRowInArrayString(sTB,newRow,editTBRowid.id);

        <%-- update table object --%>
        var row = tblTB.rows[editTBRowid.rowIndex];
        row.cells[0].innerHTML = "<a href='javascript:deleteTB("+editTBRowid.id+")'>"+
                                  "<img src='<%=sCONTEXTPATH%>/_img/icons/icon_delete.gif' alt='<%=getTranNoLink("web","delete",sWebLanguage)%>' border='0'>"+
                                 "</a> "+
                                 "<a href='javascript:editTB("+editTBRowid.id+")'>"+
                                  "<img src='<%=sCONTEXTPATH%>/_img/icons/icon_edit.gif' alt='<%=getTranNoLink("web","edit",sWebLanguage)%>' border='0'>"+
                                 "</a>";

        <%-- day name --%>
             if(EditForm.tbDayIdx.selectedIndex=="1") row.cells[1].innerHTML = "&nbsp;<%=getTranNoLink("hr.workschedule.days","day1",sWebLanguage)%>";
        else if(EditForm.tbDayIdx.selectedIndex=="2") row.cells[1].innerHTML = "&nbsp;<%=getTranNoLink("hr.workschedule.days","day2",sWebLanguage)%>";
        else if(EditForm.tbDayIdx.selectedIndex=="3") row.cells[1].innerHTML = "&nbsp;<%=getTranNoLink("hr.workschedule.days","day3",sWebLanguage)%>";
        else if(EditForm.tbDayIdx.selectedIndex=="4") row.cells[1].innerHTML = "&nbsp;<%=getTranNoLink("hr.workschedule.days","day4",sWebLanguage)%>";
        else if(EditForm.tbDayIdx.selectedIndex=="5") row.cells[1].innerHTML = "&nbsp;<%=getTranNoLink("hr.workschedule.days","day5",sWebLanguage)%>";
        else if(EditForm.tbDayIdx.selectedIndex=="6") row.cells[1].innerHTML = "&nbsp;<%=getTranNoLink("hr.workschedule.days","day6",sWebLanguage)%>";
        else if(EditForm.tbDayIdx.selectedIndex=="7") row.cells[1].innerHTML = "&nbsp;<%=getTranNoLink("hr.workschedule.days","day7",sWebLanguage)%>";

        row.cells[2].innerHTML = "&nbsp;"+EditForm.tbBeginHour.value;
        row.cells[3].innerHTML = "&nbsp;"+EditForm.tbEndHour.value;
        row.cells[4].innerHTML = "&nbsp;"+EditForm.tbDuration.value;

        <%-- empty cell --%>
        row.cells[5].innerHTML = "&nbsp;";

        <%-- reset --%>
        clearTBFields();
        EditForm.ButtonUpdateTB.disabled = true;
      }
      else{
        alertDialog("web.hr","beginHourMustComeBeforeEndHour");
        EditForm.tbBeginHour.focus();
      }
    }
    else{
                window.showModalDialog?alertDialog("web.manage","dataMissing"):alertDialogDirectText('<%=getTran("web.manage","dataMissing",sWebLanguage)%>');
    
      <%-- focus empty field --%>
      if(EditForm.tbDuration.value.length==0) EditForm.tbDuration.focus();
    }
  }
  
  <%-- ARE REQUIRED TB FIELDS FILLED --%>
  function areRequiredTBFieldsFilled(){
    return (EditForm.tbDuration.value.length > 0);
  }

  <%-- CLEAR TB FIELDS --%>
  function clearTBFields(){
    EditForm.tbDayIdx.selectedIndex = 0;
    EditForm.tbBeginHour.value = "";
    EditForm.tbEndHour.value = "";
    EditForm.tbDuration.value = "";
  }

  <%-- CLEAR TIME BLOCK TABLE --%>
  function clearTimeBlockTable(){
    var table = document.getElementById("tblTB");
    
    for(var i=table.rows.length; i>2; i--){
      table.deleteRow(i-1);
    }
  }
  
  <%-- DELETE TIME BLOCK --%>
  function deleteTB(rowid){
      if(yesnoDeleteDialog()){
      sTB = deleteRowFromArrayString(sTB,rowid.id);
      tblTB.deleteRow(rowid.rowIndex);
      clearTBFields();
    }
  }

  <%-- EDIT TIME BLOCK --%>
  function editTB(rowid){
    var row = getRowFromArrayString(sTB,rowid.id);

    <%-- day --%>
    var dayIdx = getCelFromRowString(row,0);
    EditForm.tbDayIdx.selectedIndex = dayIdx;    

    EditForm.tbBeginHour.value = getCelFromRowString(row,1);
    EditForm.tbEndHour.value   = getCelFromRowString(row,2);
    EditForm.tbDuration.value  = getCelFromRowString(row,3);

    editTBRowid = rowid;
    EditForm.ButtonUpdateTB.disabled = false;
  }
  
  <%-- DO BACK --%>
  function doBack(){
    window.location.href = "<%=sCONTEXTPATH%>/main.do?Page=system/menu.jsp";
  }

  writeWeekScheduleOptions();
  EditForm.ButtonUpdateTB.disabled = true;
</script>