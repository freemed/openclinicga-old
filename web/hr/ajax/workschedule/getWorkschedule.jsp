<%@page import="be.openclinic.hr.Workschedule,
                be.mxs.common.util.system.HTMLEntities,
                java.util.*"%>
<%@page import="java.io.*,
                org.dom4j.*"%>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>

<%!
    //--- PARSE WEEKSCHEDULE ----------------------------------------------------------------------
    // <WeekSchedule scheduleType='weekSchedule.2'>
    //  <TimeBlocks>
    //   <TimeBlock><DayIdx>1</DayIdx><BeginHour>09:00</BeginHour><EndHour>17:36</EndHour><Duration>08:36</Duration></TimeBlock>
    //   <TimeBlock><DayIdx>2</DayIdx><BeginHour>09:00</BeginHour><EndHour>17:36</EndHour><Duration>08:36</Duration></TimeBlock>
    //   <TimeBlock><DayIdx>3</DayIdx><BeginHour>09:00</BeginHour><EndHour>17:36</EndHour><Duration>08:36</Duration></TimeBlock>
    //  </TimeBlocks>
    // </WeekSchedule>
    //
    // to concat value : DayIdx+"|"+BeginHour+"|"+EndHour+"|"+Duration+"$"
    private String parseWeekschedule(Element weekSchedule){
        String sConcatValue = "";
        
        if(weekSchedule!=null){       
            Element timeBlocks = weekSchedule.element("TimeBlocks");
            if(timeBlocks!=null){
                Iterator timeBlockIter = timeBlocks.elementIterator("TimeBlock");

                String sTmpDayIdx, sTmpBeginHour, sTmpEndHour, sTmpDuration;
                Element timeBlock;
                
                while(timeBlockIter.hasNext()){
                    timeBlock = (Element)timeBlockIter.next();
                                            
                    sTmpDayIdx    = checkString(timeBlock.elementText("DayIdx"));
                    sTmpBeginHour = checkString(timeBlock.elementText("BeginHour"));
                    sTmpEndHour   = checkString(timeBlock.elementText("EndHour"));
                    sTmpDuration  = checkString(timeBlock.elementText("Duration"));
                    
                    sConcatValue+= sTmpDayIdx+"|"+sTmpBeginHour+"|"+sTmpEndHour+"|"+sTmpDuration+"$";
                }
            }
        }
        
        return sConcatValue;
    }
%>

<%
    String sScheduleUid = checkString(request.getParameter("ScheduleUid"));

    /// DEBUG /////////////////////////////////////////////////////////////////
    if(Debug.enabled){
        Debug.println("\n*************** getWorkschedule.jsp ***************");
        Debug.println("sScheduleUid : "+sScheduleUid+"\n");
    }
    ///////////////////////////////////////////////////////////////////////////
    
    /*
        <WorkSchedule uid="1.456">
            <BeginDate>01/01/2010</BeginDate>
            <EndDate>31/12/2012</EndDate>
            <FTE>50</FTE>
            
            <Schedule type="day">
                <BeginHour>09:30</BeginHour>
                <EndHour>15:00</EndHour>
                <HoursPerDay>07:30</HoursPerDay>
            </Schedule>

            <Schedule type="week">                    
                <WeekSchedule id="weekSchedule.1" scheduleType="type1">
                    <TimeBlocks>
                        <TimeBlock id="1.1">
                            <DayIdx>1</DayIdx>
                            <BeginHour>09:00</BeginHour>
                            <EndHour>12:00</EndHour>
                        </TimeBlock>
                        <TimeBlock id="1.2">
                            <DayIdx>1</DayIdx>
                            <BeginHour>15:00</BeginHour>
                            <EndHour>18:00</EndHour>
                        </TimeBlock>
                        
                        <TimeBlock id="2.1">
                            <DayIdx>2</DayIdx>
                            <BeginHour>09:30</BeginHour>
                            <EndHour>12:30</EndHour>
                        </TimeBlock>
                        <TimeBlock id="2.2">
                            <DayIdx>2</DayIdx>
                            <BeginHour>18:00</BeginHour>
                            <EndHour>20:00</EndHour>
                        </TimeBlock>
                    </TimeBlocks>
                    <HoursPerWeek>38</HoursPerWeek>
                </WeekSchedule>
            </Schedule>
                            
            <Schedule type="month">       
                <PredefinedHoursPerMonth>160</PredefinedHoursPerMonth>
                <HoursPerMonth>160</HoursPerMonth>
            </Schedule>
        </WorkSchedule>
    */
            
    Workschedule workschedule = Workschedule.get(sScheduleUid);

    if(workschedule!=null){
        String sScheduleXml = checkString(workschedule.scheduleXml);
        Debug.println("\n#####################################################################\n"+sScheduleXml+"\n#########################################################\n");
           
        if(sScheduleXml.length() > 0){
            // parse weekSchedule from xml            
            SAXReader reader = new SAXReader(false);
            Document document = reader.read(new StringReader(sScheduleXml));
            Element workScheduleElem = document.getRootElement();
            
            // attribute : type
            Element scheduleElem = workScheduleElem.element("Schedule");
            if(scheduleElem!=null){                 
                workschedule.scheduleXml = scheduleElem.asXML();
                workschedule.type = checkString(scheduleElem.attributeValue("type"));
            }
            
            // 3 childs
            String sBeginDate = checkString(workScheduleElem.elementText("BeginDate")),
                   sEndDate   = checkString(workScheduleElem.elementText("EndDate")),
                   sFTE       = checkString(workScheduleElem.elementText("FTE"));

            if(sBeginDate.length() > 0){
                workschedule.begin = ScreenHelper.stdDateFormat.parse(sBeginDate);
            }
            if(sEndDate.length() > 0){
                workschedule.end = ScreenHelper.stdDateFormat.parse(sEndDate);
            }
            if(sFTE.length() > 0){
                workschedule.fte = Integer.parseInt(sFTE);
            }
        }
    }
%>

{
  "begin":"<%=(workschedule.begin!=null?HTMLEntities.htmlentities(ScreenHelper.getSQLDate(workschedule.begin)):"")%>",
  "end":"<%=(workschedule.end!=null?HTMLEntities.htmlentities(ScreenHelper.getSQLDate(workschedule.end)):"")%>",
  "fte":"<%=workschedule.fte%>",
  "type":"<%=HTMLEntities.htmlentities(workschedule.type)%>",
  
  <%
      // specific values depending on schedule type
      if(workschedule.type.equalsIgnoreCase("day")){
          %>
            "dayScheduleStart":"<%=HTMLEntities.htmlentities(workschedule.getScheduleElementValue(workschedule.type,"BeginHour"))%>",
            "dayScheduleEnd":"<%=HTMLEntities.htmlentities(workschedule.getScheduleElementValue(workschedule.type,"EndHour"))%>",
            "dayScheduleHours":"<%=HTMLEntities.htmlentities(workschedule.getScheduleElementValue(workschedule.type,"HoursPerDay"))%>",
          <%
      }
      else if(workschedule.type.equalsIgnoreCase("week")){
          String sWeekSchedule = workschedule.getScheduleElementValue(workschedule.type,"WeekSchedule").replaceAll("\"","'");

          // parse weekSchedule from xml           
          SAXReader reader = new SAXReader(false);
          Document document = reader.read(new StringReader(sWeekSchedule));
          Element weekSchedule = document.getRootElement();

          sWeekSchedule = parseWeekschedule(weekSchedule);          
          
          %>
            "weekScheduleType":"<%=HTMLEntities.htmlentities(weekSchedule.attributeValue("scheduleType"))%>",
            "weekSchedule":"<%=HTMLEntities.htmlentities(sWeekSchedule)%>",
          <%
      }
      else if(workschedule.type.equalsIgnoreCase("month")){
          %>
            "monthScheduleType":"<%=HTMLEntities.htmlentities(workschedule.getScheduleElementValue(workschedule.type,"PredefinedHoursPerMonth"))%>",
            "monthScheduleHours":"<%=HTMLEntities.htmlentities(workschedule.getScheduleElementValue(workschedule.type,"HoursPerMonth"))%>",
          <%
      }
  %>
  "unused":""
}