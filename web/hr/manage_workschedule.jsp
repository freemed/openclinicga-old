<%@page import="be.openclinic.hr.Workschedule,
                org.dom4j.DocumentException,
                java.util.Vector,
                java.text.*"%>
<%@page import="java.io.StringReader"%>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>
<%@include file="../hr/includes/commonFunctions.jsp"%>
<%=checkPermission("hr.workschedule.edit","edit",activeUser)%>

<script src="<%=sCONTEXTPATH%>/hr/includes/commonFunctions.js"></script> 

<%!
	//### INNER CLASS : PredefinedWeekSchedule ####################################################
	private class PredefinedWeekSchedule implements Comparable {
	    public String id;
	    public String type;  
	    public String xml;  
	    
	    Vector timeBlocks = new Vector();
	
	    //--- COMPARE TO ------------------------------------------------------
	    public int compareTo(Object o){
	        int comp;
	        if(o.getClass().isInstance(this)){
	            comp = this.type.compareTo(((PredefinedWeekSchedule)o).type);
	        }
	        else{
	            throw new ClassCastException();
	        }
	
	        return comp;
	    }
	    
	    //--- AS CONCAT VALUE -------------------------------------------------
	    public String asConcatValue(){
	        String sConcatValue = "";
	        
	        TimeBlock timeBlock;
	        for(int i=0; i<timeBlocks.size(); i++){
	            timeBlock = (TimeBlock)timeBlocks.get(i);
	            
	            sConcatValue+= checkString(timeBlock.dayIdx)+"|"+
	                           checkString(timeBlock.beginHour)+"|"+
	                           checkString(timeBlock.endHour)+"|"+
	                           calculateDuration(timeBlock.beginHour,timeBlock.endHour)+"$";
	        }
	        
	        return sConcatValue;
	    }
	    
	    //--- CALCULATE DURATION ----------------------------------------------
	    private String calculateDuration(String sBeginHour, String sEndHour){
	        String sDuration = "";
	
	        if(sBeginHour.length()>0 && sEndHour.length()>0){          
	            // begin
	            String[] beginParts = sBeginHour.split(":");
	            String beginHour = checkString(beginParts[0]);
	            if(beginHour.length()==0) beginHour = "0";
	            String beginMinute = checkString(beginParts[1]);
	            if(beginMinute.length()==0) beginMinute = "0";
	
	            // end
	            String[] endParts = sEndHour.split(":");
	            String endHour = checkString(endParts[0]);
	            if(endHour.length()==0) endHour = "0";
	            String endMinute = checkString(endParts[1]);
	            if(endMinute.length()==0) endMinute = "0";
	
	            try{
	                java.util.Date dateFrom  = ScreenHelper.fullDateFormat.parse("01/01/2000 "+beginHour+":"+beginMinute),
	                               dateUntil = ScreenHelper.fullDateFormat.parse("01/01/2000 "+endHour+":"+endMinute);
	
	                long millisDiff = dateUntil.getTime() - dateFrom.getTime();
	                int totalMinutes = (int)(millisDiff/(60*1000));
	                
	                int hour    = totalMinutes/60,
	                    minutes = (totalMinutes%60);
	
	                sDuration = (hour<10?"0"+hour:hour)+":"+(minutes<10?"0"+minutes:minutes);
	            }
	            catch(Exception e){
	                if(Debug.enabled) e.printStackTrace();
	                Debug.printProjectErr(e,Thread.currentThread().getStackTrace());
	            }
	        }
	        
	        return sDuration;
	    }
	   
	}
	
	//### INNER CLASS : TimeBlock #################################################################
	private class TimeBlock implements Comparable {
	    public String id;
	    public String dayIdx;
	    public String beginHour;
	    public String endHour;
	    
	    //--- COMPARE TO ------------------------------------------------------
	    public int compareTo(Object o){
	        int comp;
	        if(o.getClass().isInstance(this)){
	            comp = this.dayIdx.compareTo(((TimeBlock)o).dayIdx);
	        }
	        else{
	            throw new ClassCastException();
	        }
	
	        return comp;
	    }
	}

    //--- WRITE WEEK SCHEDULE OPTIONS -------------------------------------------------------------
    private String writeWeekScheduleOptions(HttpServletRequest request, String sSelectedScheduleId, String sWebLanguage){
        String sOptions = ""; // html
        
        Vector weekSchedules = parsePredefinedWeekSchedulesFromXMLConfigValue();
        PredefinedWeekSchedule schedule;
        for(int i=0; i<weekSchedules.size(); i++){
            schedule = (PredefinedWeekSchedule)weekSchedules.get(i);

            // compose html
            sOptions+= "<option value='"+schedule.id+"'";
            if(sSelectedScheduleId.toLowerCase().equals(schedule.id.toLowerCase())){
                sOptions+= " selected";
            }
        
            sOptions+= ">"+getTranNoLink("hr.workschedule.weekschedules",schedule.type,sWebLanguage)+"</option>";
        }
        
        return sOptions;
    }

    /*
    //--- PARSE PREDEFINED WEEK SCHEDULES ---------------------------------------------------------
    private Vector parsePredefinedWeekSchedules(HttpServletRequest request, String sWebLanguage){
        Vector schedules = new Vector();
        
        // read xml containing predefined weekSchedules
        Document document;
        SAXReader xmlReader = new SAXReader();
        String sXmlFile = checkString(MedwanQuery.getInstance().getConfigString("weekSchedulesXMLFile"));

        if(sXmlFile.length() > 0){
            String sXmlFileUrl = "";

            try{
                try{
                    sXmlFileUrl = "http://"+request.getServerName()+request.getRequestURI().replaceAll(request.getServletPath(),"")+"/"+sAPPDIR+"/_common/xml/"+sXmlFile;
                    document = xmlReader.read(new URL(sXmlFileUrl));
                    Debug.println("Using 'weekScheduleXMLFile' : "+sXmlFileUrl);
                }
                catch(DocumentException e){
                    sXmlFileUrl = MedwanQuery.getInstance().getConfigString("templateSource")+"/"+sXmlFile;
                    document = xmlReader.read(new URL(sXmlFileUrl));
                    Debug.println("Using 'weekScheduleXMLFile' : "+sXmlFileUrl);
                }
    
                if(document!=null){
                    Element root = document.getRootElement();
                    Iterator scheduleElems = root.elementIterator("WeekSchedule");
    
                    PredefinedWeekSchedule schedule;
                    Element scheduleElem, timeBlockElem;
                    while(scheduleElems.hasNext()){
                        schedule = new PredefinedWeekSchedule();
                        
                        scheduleElem = (Element)scheduleElems.next();
                        schedule.id = scheduleElem.attributeValue("id");
                        schedule.type = scheduleElem.attributeValue("scheduleType");
                        schedule.xml = scheduleElem.asXML();
                        
                        schedules.add(schedule);
                    }
                }
            }
            catch(Exception e){
                if(Debug.enabled) e.printStackTrace();
                Debug.printProjectErr(e,Thread.currentThread().getStackTrace());
            }
        }

        return schedules;
    }
    */
    
    //--- PARSE PREDEFINED WEEK SCHEDULES FROM XML CONFIGVALUE ------------------------------------
    private Vector parsePredefinedWeekSchedulesFromXMLConfigValue(){
        Vector schedules = new Vector();
        
        // read xml containing predefined weekSchedules
        try{
            SAXReader xmlReader = new SAXReader();
        	String sXMLValue = MedwanQuery.getInstance().getConfigString("defaultWeekschedules");
        	Document document = xmlReader.read(new StringReader(sXMLValue));
            
            if(document!=null){
                Element root = document.getRootElement();
                Iterator scheduleElems = root.elementIterator("WeekSchedule");

                PredefinedWeekSchedule schedule;
                Element scheduleElem, timeBlockElem;
                while(scheduleElems.hasNext()){
                    schedule = new PredefinedWeekSchedule();
                    
                    scheduleElem = (Element)scheduleElems.next();
                    schedule.id = scheduleElem.attributeValue("id");
                    schedule.type = scheduleElem.attributeValue("scheduleType");
                    schedule.xml = scheduleElem.asXML();

                    // timeblocks
                    Iterator timeBlockElems = scheduleElem.element("TimeBlocks").elementIterator("TimeBlock");
                    while(timeBlockElems.hasNext()){
                        timeBlockElem = (Element)timeBlockElems.next();
                        
                        TimeBlock timeBlock = new TimeBlock();
                        timeBlock.id        = checkString(timeBlockElem.attributeValue("id"));
                        timeBlock.dayIdx    = checkString(timeBlockElem.elementText("DayIdx"));
                        timeBlock.beginHour = checkString(timeBlockElem.elementText("BeginHour"));
                        timeBlock.endHour   = checkString(timeBlockElem.elementText("EndHour"));
                                
                        schedule.timeBlocks.add(timeBlock);    
                    }

                    Collections.sort(schedule.timeBlocks); // on day     
                    schedules.add(schedule);
                }
            }
        }
        catch(Exception e){
            if(Debug.enabled) e.printStackTrace();
            Debug.printProjectErr(e,Thread.currentThread().getStackTrace());
        }

        return schedules;
    }
%>

<%=sJSPROTOTYPE%>
<%=sJSNUMBER%> 
<%=sJSSTRINGFUNCTIONS%>
<%=sJSSORTTABLE%>

<%
    /// DEBUG /////////////////////////////////////////////////////////////////
    if(Debug.enabled){
        Debug.println("\n************* manage_workschedule.jsp *************");
        Debug.println("no parameters\n");
    }
    ///////////////////////////////////////////////////////////////////////////    
%>            

<%=writeTableHeader("web","workschedule",sWebLanguage,"")%><br>
<div id="divWorkschedules" class="searchResults" style="width:100%;height:160px;"></div>

<form name="EditForm" id="EditForm" method="POST">
    <input type="hidden" id="EditScheduleUid" name="EditScheduleUid" value="-1">
                
    <table class="list" border="0" width="100%" cellspacing="1">
        <%-- begin --%>
        <tr>
            <td class="admin" width="<%=sTDAdminWidth%>"><%=getTran("web.hr","begin",sWebLanguage)%>&nbsp;</td>
            <td class="admin2" nowrap> 
                <%=writeDateField("begin","EditForm","",sWebLanguage)%>            
            </td>                        
        </tr>
        
        <%-- end --%>
        <tr>
            <td class="admin"><%=getTran("web.hr","end",sWebLanguage)%>&nbsp;</td>
            <td class="admin2" nowrap> 
                <%=writeDateField("end","EditForm","",sWebLanguage)%>            
            </td>                        
        </tr>
                 
        <%-- FTE (full-time equivalent) (*) --%>
        <tr>
            <td class="admin"><%=getTran("web.hr","fte",sWebLanguage)%>&nbsp;*&nbsp;</td>
            <td class="admin2">
                <select class="text" id="fte" name="fte">
                    <option/>
                    <%=ScreenHelper.writeSelectUnsorted("hr.workschedule.fte","",sWebLanguage)%>
                </select> <%=getTran("web","percent",sWebLanguage)%>
            </td>
        </tr>
        
        <%-- 3 types of schedules -----------------------------------------------------------%>
        <tr>
            <td class="admin"><%=getTran("web.hr","scheduleType",sWebLanguage)%>&nbsp;</td>
            <td class="admin2">
                <input type="radio" name="scheduleType" id="scheduleTypeDay" value="day" onDblClick="uncheckRadio(this);hideAllSchedules();" onClick="displayDaySchedule();"/><%=getLabel("web.hr","daySchedule",sWebLanguage,"scheduleTypeDay")%>&nbsp;
                <input type="radio" name="scheduleType" id="scheduleTypeWeek" value="week" onDblClick="uncheckRadio(this);hideAllSchedules();" onClick="displayWeekSchedule();"/><%=getLabel("web.hr","weekSchedule",sWebLanguage,"scheduleTypeWeek")%>&nbsp;
                <input type="radio" name="scheduleType" id="scheduleTypeMonth" value="month" onDblClick="uncheckRadio(this);hideAllSchedules();" onClick="displayMonthSchedule();"/><%=getLabel("web.hr","monthSchedule",sWebLanguage,"scheduleTypeMonth")%>&nbsp;
            </td>
        </tr>
        
        <%-- type1 - daySchedule ----------------------------------------%>
        <tr id="dayScheduleTr" style="display:none;">
            <td class="admin"/>
            <td class="admin2" style="padding:5px;">
                <table width="40%" cellpadding="0" cellspacing="1" class="list">
                    <%-- startHour --%>
                    <tr>
                        <td class="admin" width="150" nowrap><%=getTran("web.hr","startHour",sWebLanguage)%>&nbsp;</td>
                        <td class="admin2">
                            <input type="text" class="text" id="dayScheduleStart" name="dayScheduleStart" size="2" maxLength="5" value="" onKeypress="keypressTime(this);" onBlur="checkTime(this);calculateInterval('dayScheduleStart','dayScheduleEnd','dayScheduleHours');">
                        </td>
                    </tr>
                    
                    <%-- endHour --%>
                    <tr>
                        <td class="admin" nowrap><%=getTran("web.hr","endHour",sWebLanguage)%>&nbsp;</td>
                        <td class="admin2">
                            <input type="text" class="text" id="dayScheduleEnd" name="dayScheduleEnd" size="2" maxLength="5" value="" onKeypress="keypressTime(this);" onBlur="checkTime(this);calculateInterval('dayScheduleStart','dayScheduleEnd','dayScheduleHours');">
                        </td>
                    </tr>                    
                    
                    <%-- hours (*) --%>
                    <tr>
                        <td class="admin" nowrap><%=getTran("web.hr","hoursPerDay",sWebLanguage)%>&nbsp;*&nbsp;</td>
                        <td class="admin2">
                            <input type="text" class="text" id="dayScheduleHours" name="dayScheduleHours" size="2" maxLength="3" onKeypress="keypressTime(this);" onBlur="checkTime(this);" value="">&nbsp;<%=getTran("web","hours",sWebLanguage)%>
                        </td>
                    </tr>
                </table>
            </td>
        </tr>
                
        <%-- type2 - weekSchedule ---------------------------------------%>
        <tr id="weekScheduleTr" style="display:none;">
            <td class="admin" width="<%=sTDAdminWidth%>">&nbsp;</td>
            <td class="admin2" style="padding:5px;">
                <table width="40%" cellpadding="0" cellspacing="1" class="list">
                    <%-- weekScheduleType (predefines weekSchedule) --%>
                    <tr>
                        <td class="admin" width="150" nowrap><%=getTran("web.hr","weekScheduleType",sWebLanguage)%>&nbsp;</td>
                        <td class="admin2">
                            <select class="text" id="weekScheduleType" name="weekScheduleType" onChange="setTimeBlocksString(this.options[this.selectedIndex].value);">
                                <option/>
                                <%=writeWeekScheduleOptions(request,"",sWebLanguage)%>
                            </select>
                        </td>
                    </tr>
                                    
                    <%-- weekSchedule/timeBlocks (multi-add) --%>
                    <tr>
                        <td class="admin" nowrap><%=getTran("web.hr","timeBlocks",sWebLanguage)%></td>
                        <td class="admin2">
                            <input type="hidden" id="timeBlocks" name="timeBlocks" value="">
                                                 
                            <table width="100%" class="sortable" id="tblTB" cellspacing="1" headerRowCount="2"> 
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
                                    <td class="admin" nowrap>
                                        <input type="button" class="button" name="ButtonAddTB" value="<%=getTran("web","add",sWebLanguage)%>" onclick="addTB();">
                                        <input type="button" class="button" name="ButtonUpdateTB" value="<%=getTran("web","edit",sWebLanguage)%>" onclick="updateTB();" disabled>&nbsp;
                                    </td>    
                                </tr>
                            </table>                    
                        </td>
                    </tr>
                </table>
            </td>
        </tr>
           
        <%-- type3 - monthSchedule --------------------------------------%>  
        <tr id="monthScheduleTr" style="display:none;">
            <td class="admin"/>
            <td class="admin2" style="padding:5px;">
                <table width="40%" cellpadding="0" cellspacing="1" class="list">
                    <%-- monthScheduleType (predefines total hours per month) --%>
                    <tr>
                        <td class="admin" width="150" nowrap><%=getTran("web.hr","monthScheduleType",sWebLanguage)%>&nbsp;</td>
                        <td class="admin2">
                            <select class="text" id="monthScheduleType" name="monthScheduleType" onChange="setMonthScheduleHours(this.options[this.selectedIndex].value);"> 
                                <option/>
                                <%=ScreenHelper.writeSelect("hr.workschedule.monthscheduletype","",sWebLanguage,true)%>
                            </select>
                        </td>
                    </tr>    
                    
                    <%-- hours (*) --%>
                    <tr>
                        <td class="admin"><%=getTran("web.hr","hoursPerMonth",sWebLanguage)%>&nbsp;*&nbsp;</td>
                        <td class="admin2">
                            <input type="text" class="text" id="monthScheduleHours" name="monthScheduleHours" size="2" maxLength="3" onKeypress="keypressTime(this);" onBlur="checkTime(this);" value="">&nbsp;<%=getTran("web","hours",sWebLanguage)%>
                        </td>
                    </tr>
                </table>
            </td>
        </tr>
            
        <%-- BUTTONS --%>
        <tr>     
            <td class="admin"/>
            <td class="admin2" colspan="2">
                <input class="button" type="button" name="buttonSave" value="<%=getTranNoLink("web","save",sWebLanguage)%>" onclick="saveWorkschedule();">&nbsp;
                <input class="button" type="button" name="buttonDelete" value="<%=getTranNoLink("web","delete",sWebLanguage)%>" onclick="deleteWorkschedule();" style="visibility:hidden;">&nbsp;
                <input class="button" type="button" name="buttonNew" value="<%=getTranNoLink("web","new",sWebLanguage)%>" onclick="newWorkschedule();" style="visibility:hidden;">&nbsp;
            </td>
        </tr>
    </table>
    <i><%=getTran("web","colored_fields_are_obligate",sWebLanguage)%></i>
    
    <div id="divMessage" style="padding-top:10px;"></div>
</form>
    
<script>  
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
  
  <%-- CHECK INTERFERENCE --%>
  function checkInterference(){
	var interference = false;
	    
    var beginDate = null;
    if(document.getElementById("begin").value.length > 0){
      beginDate = makeDate(document.getElementById("begin").value);
    }

    var endDate = null;
    if(document.getElementById("end").value.length > 0){
      endDate = makeDate(document.getElementById("end").value);
    }
       
    for(var i=0; i<periodsWithSchedule.length && interference==false; i++){
      var scheduleUid = periodsWithSchedule[i].split("_")[0];
  	
      <%-- do not consider the period of the schedule currently being edited --%>
      if(scheduleUid!=EditForm.EditScheduleUid.value){        	
        var periodBegin = periodsWithSchedule[i].split("_")[1],
       	    periodEnd   = periodsWithSchedule[i].split("_")[2];

     	<%-- begin- and end of period specified --%>
     	if((periodBegin!=null && periodBegin.length > 0) && (periodEnd!=null && periodEnd.length > 0)){
          var periodBeginDate = makeDate(periodBegin),
              periodEndDate   = makeDate(periodEnd);

          //alert("begin- and end of period specified"); /////////
          //alert("beginDate : "+beginDate+" <= periodEndDate : "+periodEndDate); ////////
          //alert("endDate : "+endDate+" > periodBeginDate : "+periodBeginDate); ////////
          if((beginDate==null || (beginDate!=null && (beginDate <= periodEndDate))) && (endDate==null || (endDate!=null && endDate > periodBeginDate))){
            alertDialog("web","periodsInterfere");
            document.getElementById("begin").focus();
            okToSubmit = false;                	
            interference = true;  
          }
        }
        <%-- only begin of period specified --%>
        else if(periodBegin.length > 0){
          var periodBeginDate = makeDate(periodBegin);

          //alert("only begin of period specified"); /////////
          //alert("endDate : "+endDate+" >= periodBeginDate : "+periodBeginDate); ////////
          if(endDate==null || (endDate!=null && endDate >= periodBeginDate)){
            alertDialog("web","periodsInterfere");
            document.getElementById("begin").focus();
            okToSubmit = false;
            interference = true;                  	
          }
        }
        <%-- only end of period specified --%>
        else if(periodEnd.length > 0){
          var periodEndDate = makeDate(periodEnd);

          //alert("only end of period specified"); /////////
          //alert("beginDate : "+beginDate+" <= periodEndDate : "+periodEndDate); ////////
          if(beginDate==null || (beginDate!=null && beginDate <= periodEndDate)){
            alertDialog("web","periodsInterfere");
            document.getElementById("begin").focus();
            okToSubmit = false;
            interference = true;                  	
          }
        }
      }
    }
    
    return interference;
  } 
  
  <%-- SAVE WORKSCHEDULE --%>
  function saveWorkschedule(){
    var okToSubmit = true;
    
    if(document.getElementById("fte").selectedIndex > 0){     
      <%-- begin can not be after end --%>
      if(document.getElementById("end").value.length > 8){
        var begin = makeDate(document.getElementById("begin").value),
            end   = makeDate(document.getElementById("end").value);
        
        if(begin > end){
          okToSubmit = false;
          alertDialog("web","beginMustComeBeforeEnd");
          document.getElementById("begin").focus();
        }  
      }

      <%-- periods can not interfere (max 1 schedule at all times) --%>
      if(okToSubmit){
    	okToSubmit = !checkInterference();
      }
      
      <%-- required fields depending on chosen schedule type --%>
      if(okToSubmit){
        <%-- schedule type --%>
        if(document.getElementById("scheduleTypeDay").checked){          
          <%-- day : begin & end hour --%>
          if(okToSubmit){
            <%-- begin --%>
            var aTimeBegin = document.getElementById("dayScheduleStart").value.split(":");
            var startHour = aTimeBegin[0];
            if(startHour.length==0) startHour = 0;
            var startMinute = aTimeBegin[1];
            if(startMinute.length==0) startMinute = 0;

            <%-- end --%>
            var aTimeEnd = document.getElementById("dayScheduleEnd").value.split(":");
            var stopHour = aTimeEnd[0];
            if(stopHour.length==0) stopHour = 0;
            var stopMinute = aTimeEnd[1];
            if(stopMinute.length==0) stopMinute = 0;

            var dateFrom = new Date(2000,1,1,startHour,startMinute,0),
                dateUntil = new Date(2000,1,1,stopHour,stopMinute,0);

            if(dateFrom.getTime() > dateUntil.getTime()){
              alertDialog("web.hr","beginHourMustComeBeforeEndHour");
              document.getElementById("dayScheduleStart").focus();
              okToSubmit = false;
            }
          }

          <%-- day : hours --%>
          if(okToSubmit){
            if(document.getElementById("dayScheduleHours").value.length==0){
              alertDialog("web.manage","dataMissing");
              document.getElementById("dayScheduleHours").focus();
              okToSubmit = false;
            }
          }
        }  
        else if(document.getElementById("scheduleTypeWeek").checked){
          <%-- week : hours
          if(okToSubmit){
            if(document.getElementById("tbDuration").value.length==0){
              alertDialog("web.manage","dataMissing");
              document.getElementById("tbDuration").focus();  
              okToSubmit = false;                    
            }
          }
          --%>
        }
        else if(document.getElementById("scheduleTypeMonth").checked){
          <%-- month : hours --%>
          if(okToSubmit){
            if(document.getElementById("monthScheduleHours").value.length==0){
              alertDialog("web.manage","dataMissing");
              document.getElementById("monthScheduleHours").focus();    
              okToSubmit = false;
            }
          }                
        }                
      }
      
      if(okToSubmit){
        document.getElementById("divMessage").innerHTML = "<img src=\"<c:url value='/_img/ajax-loader.gif'/>\"/><br>Saving";  
        var url = "<c:url value='/hr/ajax/workschedule/saveWorkschedule.jsp'/>?ts="+new Date().getTime();

        document.getElementById("buttonSave").disabled = true;
        document.getElementById("buttonDelete").disabled = true;
        document.getElementById("buttonNew").disabled = true;
        
        <%-- parameters --%>
        var sParameters = "EditScheduleUid="+EditForm.EditScheduleUid.value+
                          "&PersonId=<%=activePatient.personid%>"+
                          "&begin="+document.getElementById("begin").value+
                          "&end="+document.getElementById("end").value+
                          "&fte="+document.getElementById("fte").options[document.getElementById("fte").selectedIndex].text;

        if(document.getElementById("scheduleTypeDay").checked){
          sParameters+= "&dayStart="+document.getElementById("dayScheduleStart").value+ // type1 - day
                        "&dayEnd="+document.getElementById("dayScheduleEnd").value+
                        "&dayHours="+document.getElementById("dayScheduleHours").value;
        }
        else if(document.getElementById("scheduleTypeWeek").checked){
          sParameters+= "&weekScheduleType="+document.getElementById("weekScheduleType").value+ // type2 - week
                        "&weekSchedule="+removeTRIndexes(sTB)+
                        "&weekHours="+decimalToHour(calculateHoursPerWeek(sTB));
        }
        else if(document.getElementById("scheduleTypeMonth").checked){
          sParameters+= "&monthScheduleType="+document.getElementById("monthScheduleType").value+ // type3 - month
                        "&monthHours="+document.getElementById("monthScheduleHours").value;
        }
                                                  
        <%-- schedule type --%>
        if(document.getElementById("scheduleTypeDay").checked){
          sParameters+= "&scheduleType=day";
        }
        else if(document.getElementById("scheduleTypeWeek").checked){
          sParameters+= "&scheduleType=week";
        }
        else if(document.getElementById("scheduleTypeMonth").checked){
          sParameters+= "&scheduleType=month";
        }
        
        new Ajax.Request(url,
          {
            method: "POST",
            postBody: sParameters,                        
            onSuccess: function(resp){
              var data = eval("("+resp.responseText+")");
              $("divMessage").innerHTML = data.message;

              if(document.getElementById("EditScheduleUid").value=="-1"){
            	addSchedulePeriod(document.getElementById("EditScheduleUid").value);
              }
              else{
            	var sPeriod = document.getElementById("begin").value+"_"+document.getElementById("end").value;
                updateSchedulePeriod(document.getElementById("EditScheduleUid").value,sPeriod);
              }
              
              loadWorkschedules();
              newWorkschedule();
              
              //EditForm.EditScheduleUid.value = data.newUid;
              document.getElementById("buttonSave").disabled = false;
              document.getElementById("buttonDelete").disabled = false;
              document.getElementById("buttonNew").disabled = false;
            },
            onFailure: function(resp){
              $("divMessage").innerHTML = "Error in 'hr/ajax/workschedule/saveWorkschedule.jsp' : "+resp.responseText.trim();
            }
          }
        );
      }
    }
    else{
      alertDialog("web.manage","dataMissing");
      
      <%-- focus empty field --%>
      if(document.getElementById("fte").selectedIndex==0) document.getElementById("fte").focus();          
    }
  }
    
  <%-- LOAD WORKSCHEDULES --%>
  function loadWorkschedules(){
    document.getElementById("divWorkschedules").innerHTML = "<img src=\"<c:url value='/_img/ajax-loader.gif'/>\"/><br>Loading";            
    var url = "<c:url value='/hr/ajax/workschedule/getWorkschedules.jsp'/>?ts="+new Date().getTime();
  
    new Ajax.Updater("divWorkschedules",url,
      {
        method: "GET",
        evalScripts: true,
        parameters: "PatientId=<%=activePatient.personid%>",
        onSuccess: function(resp){
          $("divWorkschedules").innerHTML = resp.responseText;
          sortables_init();
        },
        onFailure: function(resp){
          $("divMessage").innerHTML = "Error in 'hr/ajax/workschedule/getWorkschedules.jsp' : "+resp.responseText.trim();
        }
      }
    );
  }  
  
  var periodsWithSchedule = new Array();

  <%-- ADD SCHEDULE PERIOD --%>
  function addSchedulePeriod(scheduleUid,sPeriod){
	var scheduleFound = false;
	
    for(var i=0; i<periodsWithSchedule.length && scheduleFound==false; i++){
      if(periodsWithSchedule[i].indexOf(scheduleUid+"_")==0){
    	  scheduleFound = true;
      }
    }

    if(scheduleFound==false){
      periodsWithSchedule.push(scheduleUid+"_"+sPeriod);
    }
  }

  <%-- REMOVE SCHEDULE PERIOD --%>
  function removeSchedulePeriod(scheduleUid){
	for(var i=0; periodsWithSchedule.length; i++){
      if(periodsWithSchedule[i].indexOf(scheduleUid+"_")==0){
    	periodsWithSchedule.splice(i,1);
      	break;
      }
	}
  }

  <%-- UPDATE SCHEDULE PERIOD --%>
  function updateSchedulePeriod(scheduleUid,sPeriod){
	for(var i=0; periodsWithSchedule.length; i++){
	  if(periodsWithSchedule[i].indexOf(scheduleUid+"_")==0){
	  	periodsWithSchedule.splice(i,1);
	  	periodsWithSchedule.push(scheduleUid+"_"+sPeriod);
	   	break;
	  }
    }
  }
  
  <%-- DISPLAY WORKSCHEDULE --%>
  function displayWorkschedule(scheduleUid){          
    hideAllSchedules();
    var url = "<c:url value='/hr/ajax/workschedule/getWorkschedule.jsp'/>?ts="+new Date().getTime();
    
    new Ajax.Request(url,
      {
        method: "GET",
        parameters: "ScheduleUid="+scheduleUid,
        onSuccess: function(resp){
          var data = eval("("+resp.responseText+")");

          $("EditScheduleUid").value = scheduleUid;
          $("begin").value = data.begin;
          $("end").value = data.end;
          
          <%-- fte --%>
          for(var i=0; i<$("fte").options.length; i++){
            if($("fte").options[i].text==data.fte){
              $("fte").selectedIndex = i;
            }
          }
          
          <%-- open tr --%>
               if(data.type=="day")   document.getElementById("dayScheduleTr").style.display = "block";
          else if(data.type=="week")  document.getElementById("weekScheduleTr").style.display = "block";
          else if(data.type=="month") document.getElementById("monthScheduleTr").style.display = "block";
                    
          <%-- type --%>
               if(data.type=="day")   document.getElementById("scheduleTypeDay").checked = true;
          else if(data.type=="week")  document.getElementById("scheduleTypeWeek").checked = true;
          else if(data.type=="month") document.getElementById("scheduleTypeMonth").checked = true;
          
          <%-- schedule --%>
          if(data.type=="day"){
            $("dayScheduleStart").value = data.dayScheduleStart; 
            $("dayScheduleEnd").value = data.dayScheduleEnd; 
            $("dayScheduleHours").value = data.dayScheduleHours;              
          }
          else if(data.type=="week"){
            <%-- weekScheduleType --%>
            for(var i=0; i<$("weekScheduleType").options.length; i++){
              if($("weekScheduleType").options[i].value==data.weekScheduleType){
                $("weekScheduleType").selectedIndex = i;
              }
            }
              
            document.getElementById("timeBlocks").value = data.weekSchedule;
            displayTimeBlocks();
          }
          else if(data.type=="month"){
            <%-- monthScheduleType --%>
            for(var i=0; i<$("monthScheduleType").options.length; i++){
              if($("monthScheduleType").options[i].value==data.monthScheduleType){
                $("monthScheduleType").selectedIndex = i;
              }
            }
               
            $("monthScheduleHours").value = data.monthScheduleHours;
          }
          
          document.getElementById("divMessage").innerHTML = ""; 
          resizeAllTextareas(8);

          <%-- display hidden buttons --%>
          document.getElementById("buttonDelete").style.visibility = "visible";
          document.getElementById("buttonNew").style.visibility = "visible";
        },
        onFailure: function(resp){
          $("divMessage").innerHTML = "Error in 'hr/ajax/workschedule/getWorkschedule.jsp' : "+resp.responseText.trim();
        }
      }
    );
  }
  
  <%-- DELETE WORKSCHEDULE --%>
  function deleteWorkschedule(){
    var answer = yesnoDialog("web","areYouSureToDelete");   
    if(answer==1){                 
      var url = "<c:url value='/hr/ajax/workschedule/deleteWorkschedule.jsp'/>?ts="+new Date().getTime();

      document.getElementById("buttonSave").disabled = true;
      document.getElementById("buttonDelete").disabled = true;
      document.getElementById("buttonNew").disabled = true;
    
      new Ajax.Request(url,
        {
          method: "GET",
          parameters: "ScheduleUid="+document.getElementById("EditScheduleUid").value,
          onSuccess: function(resp){
            var data = eval("("+resp.responseText+")");
            $("divMessage").innerHTML = data.message;

            removeSchedulePeriod(document.getElementById("EditScheduleUid").value);
            loadWorkschedules();
            newWorkschedule();
          
            document.getElementById("buttonSave").disabled = false;
            document.getElementById("buttonDelete").disabled = false;
            document.getElementById("buttonNew").disabled = false;
          },
          onFailure: function(resp){
            $("divMessage").innerHTML = "Error in 'hr/ajax/workschedule/deleteWorkschedule.jsp' : "+resp.responseText.trim();
          }  
        }
      );
    }
  }
  
  <%-- NEW WORKSCHEDULE --%>
  function newWorkschedule(){   
    hideAllSchedules();
      
    <%-- hide irrelevant buttons --%>
    document.getElementById("buttonDelete").style.visibility = "hidden";
    document.getElementById("buttonNew").style.visibility = "hidden";

    $("EditScheduleUid").value = "-1";
    $("begin").value = "";
    $("end").value = "";
    $("fte").selectedIndex = 0;
    $("timeBlocks").value = "";   
    
    $("begin").focus();
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
  
  <%-- UPDATE ROW STYLES --%>
  function updateRowStyles(){
    <%-- searchresults --%>
    if(document.getElementById("searchresults")!=null){
      for(var i=1; i<searchresults.rows.length; i++){
        searchresults.rows[i].className = "";
        searchresults.rows[i].style.cursor = "hand";
      }

      for(var i=1; i<searchresults.rows.length; i++){
        if(i%2==0){
          searchresults.rows[i].className = "list";
        }
        else{
          searchresults.rows[i].className = "list1";
        }
      }
    }

    <%-- tblTB --%>
    for(var i=2; i<tblTB.rows.length; i++){        
      setRowStyle(tblTB.rows[i],i);
    }
  }
  
  <%-- DISPLAY DAY SCHEDULE --%>
  function displayDaySchedule(){
    document.getElementById("dayScheduleTr").style.display = "block";
    document.getElementById("weekScheduleTr").style.display = "none";
    document.getElementById("monthScheduleTr").style.display = "none";

    clearWeekScheduleFields();
    clearMonthScheduleFields();
    
    document.getElementById("dayScheduleStart").focus();
  }
  
  <%-- DISPLAY WEEK SCHEDULE --%>
  function displayWeekSchedule(){
    document.getElementById("dayScheduleTr").style.display = "none";
    document.getElementById("weekScheduleTr").style.display = "block";
    document.getElementById("monthScheduleTr").style.display = "none";

    clearDayScheduleFields();
    clearMonthScheduleFields();
    
    document.getElementById("weekScheduleType").focus();
  }
  
  <%-- DISPLAY MONTH SCHEDULE --%>
  function displayMonthSchedule(){
    document.getElementById("dayScheduleTr").style.display = "none";
    document.getElementById("weekScheduleTr").style.display = "none";
    document.getElementById("monthScheduleTr").style.display = "block";
    
    clearDayScheduleFields();
    clearWeekScheduleFields();
    
    document.getElementById("monthScheduleType").focus();
  }
  
  <%-- HIDE ALL SCHEDULES --%>
  function hideAllSchedules(){
    document.getElementById("scheduleTypeDay").checked = false;
    document.getElementById("scheduleTypeWeek").checked = false;
    document.getElementById("scheduleTypeMonth").checked = false;
        
    document.getElementById("dayScheduleTr").style.display = "none";
    document.getElementById("weekScheduleTr").style.display = "none";
    document.getElementById("monthScheduleTr").style.display = "none";
       
    clearDayScheduleFields();
    clearWeekScheduleFields();
    clearMonthScheduleFields();
  }

  <%-- CLEAR DAY SCHEDULE FIELDS --%>
  function clearDayScheduleFields(){
    document.getElementById("dayScheduleStart").value = "";
    document.getElementById("dayScheduleEnd").value = "";
    document.getElementById("dayScheduleHours").value = "";
  }
  
  <%-- CLEAR WEEK SCHEDULE FIELDS --%>
  function clearWeekScheduleFields(){
    document.getElementById("weekScheduleType").selectedIndex = 0;
    document.getElementById("timeBlocks").value = "";
    clearTimeBlockTable();
    displayTimeBlocks();

    <%-- clear add-fields --%>
	document.getElementById("tbDayIdx").selectedIndex = 0;
	document.getElementById("tbBeginHour").value = "";
	document.getElementById("tbEndHour").value = "";
	document.getElementById("tbDuration").value = "";
  }
  
  <%-- CLEAR MONTH SCHEDULE FIELDS --%>
  function clearMonthScheduleFields(){
    document.getElementById("monthScheduleType").selectedIndex = 0;
    document.getElementById("monthScheduleHours").value = "";      
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
  
  <%-- SET MONTH SCHEDULE HOURS --%>
  function setMonthScheduleHours(value){
    document.getElementById("monthScheduleHours").value = value;      
  }
  
  <%-- TIME BLOCK FUNCTIONS ---------------------------------------------------------------------%>
  var editTBRowid = "", iTBIndex = 1, sTB = "";

  <%-- SET TIME BLOCKS STRING --%>
  function setTimeBlocksString(weekScheduleId){
    clearTimeBlockTable();
      
    document.getElementById("divMessage").innerHTML = "<img src=\"<c:url value='/_img/ajax-loader.gif'/>\"/><br>Loading";            
    var url = "<c:url value='/hr/ajax/workschedule/getDefaultWeekschedule.jsp'/>?ts="+new Date().getTime();
      
    new Ajax.Request(url,
      {
        method: "GET",
        parameters: "WeekScheduleId="+weekScheduleId,
        onSuccess: function(resp){
          var data = eval("("+resp.responseText+")");
          
          document.getElementById("timeBlocks").value = data.weekSchedule;
          document.getElementById("divMessage").innerHTML = "";    
          
          displayTimeBlocks();
        },
        onFailure: function(resp){
          $("divMessage").innerHTML = "Error in 'hr/ajax/workschedule/getDefaultWeekschedule.jsp' : "+resp.responseText.trim();
        }
      }
    );      
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
                    "<img src='<%=sCONTEXTPATH%>/_img/icon_delete.gif' alt='<%=getTranNoLink("web","delete",sWebLanguage)%>' border='0' style='vertical-align:-2px;'>"+
                   "</a> "+
                   "<a href='javascript:editTB(rowTB"+iTBIndex+")'>"+
                    "<img src='<%=sCONTEXTPATH%>/_img/icon_edit.gif' alt='<%=getTranNoLink("web","edit",sWebLanguage)%>' border='0' style='vertical-align:-3px;'>"+
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
                        "<img src='<%=sCONTEXTPATH%>/_img/icon_delete.gif' alt='<%=getTranNoLink("web","delete",sWebLanguage)%>' border='0'>"+
                       "</a> "+
                       "<a href='javascript:editTB(rowTB"+iTBIndex+")'>"+
                        "<img src='<%=sCONTEXTPATH%>/_img/icon_edit.gif' alt='<%=getTranNoLink("web","edit",sWebLanguage)%>' border='0'>"+
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
      alertDialog("web.manage","dataMissing");
      
      <%-- focus empty field --%>
      /*
           if(EditForm.tbDayIdx.selectedIndex==0)   EditForm.tbDayIdx.focus();
      else if(EditForm.tbBeginHour.value.length==0) EditForm.tbBeginHour.focus();
      else if(EditForm.tbEndHour.value.length==0)   EditForm.tbEndHour.focus();
      else if(EditForm.tbDuration.value.length==0)  EditForm.tbDuration.focus();
      */
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
                                  "<img src='<%=sCONTEXTPATH%>/_img/icon_delete.gif' alt='<%=getTranNoLink("web","delete",sWebLanguage)%>' border='0'>"+
                                 "</a> "+
                                 "<a href='javascript:editTB("+editTBRowid.id+")'>"+
                                  "<img src='<%=sCONTEXTPATH%>/_img/icon_edit.gif' alt='<%=getTranNoLink("web","edit",sWebLanguage)%>' border='0'>"+
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
      alertDialog("web.manage","dataMissing");
    
      <%-- focus empty field --%>
      /*
           if(EditForm.tbDayIdx.selectedIndex==0)   EditForm.tbDayIdx.focus();
      else if(EditForm.tbBeginHour.value.length==0) EditForm.tbBeginHour.focus();
      else if(EditForm.tbEndHour.value.length==0)   EditForm.tbEndHour.focus();
      else if(EditForm.tbDuration.value.length==0)  EditForm.tbDuration.focus();
      */
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
    var answer = yesnoDialog("web","areYouSureToDelete"); 
    if(answer==1){
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

  EditForm.ButtonUpdateTB.disabled = true;
  
  EditForm.begin.focus();
  loadWorkschedules();
  resizeAllTextareas(8);
</script>