<%@page import="be.mxs.common.util.system.HTMLEntities"%>
<%@page import="java.io.StringReader"%>
<%@page import="org.dom4j.DocumentException,
                java.util.Vector,
                java.text.*,
                java.io.*,
                org.dom4j.*"%>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>

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
    
    
    private Vector weekSchedules = new Vector();
    
    
    //--- GET SCHEDULES AS XML --------------------------------------------------------------------
    private String getSchedulesAsXml(){
        StringBuffer sXml = new StringBuffer();
        sXml.append("<WeekSchedules>");

        PredefinedWeekSchedule schedule;
        for(int i=0; i<weekSchedules.size(); i++){
            schedule = (PredefinedWeekSchedule)weekSchedules.get(i);            
            sXml.append(schedule.xml);
        }        

        sXml.append("</WeekSchedules>");
        
        return sXml.toString();
    }
    
    //--- TIMEBLOCKS TO WEEKSCHEDULE --------------------------------------------------------------
    private Element timeblocksToWeekschedule(String sTimeBlocks, Element weekschedule){        
        if(sTimeBlocks.length() > 0){
            Element timeBlocksElem = weekschedule.addElement("TimeBlocks");

            if(sTimeBlocks.indexOf("$") > -1){
                String sTmpTB = sTimeBlocks;
                sTimeBlocks = "";
                  
                String sTmpDayIdx, sTmpBeginHour, sTmpEndHour, sTmpDuration;

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

                    Element timeBlockElem = timeBlocksElem.addElement("TimeBlock");
                    timeBlockElem.addElement("DayIdx").addText(sTmpDayIdx);
                    timeBlockElem.addElement("BeginHour").addText(sTmpBeginHour);
                    timeBlockElem.addElement("EndHour").addText(sTmpEndHour);
                    timeBlockElem.addElement("Duration").addText(sTmpDuration);
                }
            }            
        }
        
        return weekschedule;
    }

    //--- GET NEXT SCHEDULE ID --------------------------------------------------------------------
    private int getNextScheduleId(){
        int id = -1;
        
        PredefinedWeekSchedule schedule;
        String sId;
        
        for(int i=0; i<weekSchedules.size(); i++){
            schedule = (PredefinedWeekSchedule)weekSchedules.get(i);
            
            sId = schedule.id.substring(schedule.id.indexOf(".")+1); // "weekSchedule.x"
            if(sId.length() > 0){
                id = Integer.parseInt(sId);
            }
        }

        return id+1; // next id
    }
    
    //--- UPDATE SCHEDULE -------------------------------------------------------------------------
    private Element updateSchedule(String sScheduleId, String sScheduleType, Element scheduleElem){        
        PredefinedWeekSchedule schedule;
        
        if(sScheduleId.equalsIgnoreCase("new")){
            schedule = new PredefinedWeekSchedule();
            schedule.id = "weekSchedule."+getNextScheduleId();
            scheduleElem.setAttributeValue("id",schedule.id); // !!
            schedule.type = sScheduleType;
            
            schedule.xml = scheduleElem.asXML(); 
            
            Collections.sort(schedule.timeBlocks); // on day           
            weekSchedules.add(schedule);
        }
        else{
            for(int i=0; i<weekSchedules.size(); i++){
                schedule = (PredefinedWeekSchedule)weekSchedules.get(i);
        
                if(schedule.id.equalsIgnoreCase(sScheduleId)){
                    schedule.xml = scheduleElem.asXML();
                }
            }
        }
        
        return scheduleElem;
    }

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

<%
    String sScheduleUid  = checkString(request.getParameter("ScheduleUid")),
           sScheduleType = checkString(request.getParameter("ScheduleType")),
           sTimeBlocks   = checkString(request.getParameter("TimeBlocks"));
       
    /// DEBUG /////////////////////////////////////////////////////////////////
    if(Debug.enabled){
        Debug.println("\n***** system/ajax/saveDefaultWeekschedule.jsp *****");
        Debug.println("sScheduleUid  : "+sScheduleUid);
        Debug.println("sScheduleType : "+sScheduleType);
        Debug.println("sTimeBlocks   : "+sTimeBlocks+"\n");
    }
    ///////////////////////////////////////////////////////////////////////////

    
    //*** 1 - build vector of schedule objects, from configValue ***
    weekSchedules = parsePredefinedWeekSchedulesFromXMLConfigValue();
    
    //*** 2 - create XML element for schedule-data *** 
    // <WeekSchedule id="weekSchedule.1" scheduleType="type1">...</WeekSchedule>
    org.dom4j.Document document = DocumentHelper.createDocument();
    Element scheduleElem = document.addElement("WeekSchedule"); 
    scheduleElem.addAttribute("id",sScheduleUid); 
    scheduleElem.addAttribute("scheduleType",sScheduleType);
    
    //*** 2b - set timeblocks in schedule element ***
    scheduleElem = timeblocksToWeekschedule(sTimeBlocks,scheduleElem);
    
    //*** 3 - update schedule object in vector ***
    updateSchedule(sScheduleUid,sScheduleType,scheduleElem);
    
    //*** 4 - save xml representing all the schedules as configValue ***
    MedwanQuery.getInstance().setConfigString("defaultWeekschedules",getSchedulesAsXml());
    
    String sMessage = "<font color='green'>"+getTran("web","dataIsSaved",sWebLanguage)+"</font>";
%>

{
  "message":"<%=HTMLEntities.htmlentities(sMessage)%>"
}