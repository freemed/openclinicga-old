<%@page import="be.mxs.common.util.system.HTMLEntities"%>
<%@page import="org.dom4j.DocumentException,
                java.util.Vector"%>
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
                    sXmlFileUrl = "http://"+request.getServerName()+":"+request.getServerPort()+request.getRequestURI().replaceAll(request.getServletPath(),"")+"/"+sAPPDIR+"/_common/xml/"+sXmlFile;
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
                        
                        /*
                            <WeekSchedules>
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
                                        ...
                                    </TimeBlocks>
                                </WeekSchedule>
                                ...
                            </WeekSchedules>
                        */
                        
                        scheduleElem = (Element)scheduleElems.next();
                        schedule.id = scheduleElem.attributeValue("id");
                        schedule.type = scheduleElem.attributeValue("scheduleType");
                        schedule.xml = scheduleElem.asXML();

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
        }

        return schedules;
    }
%>

<%
    String sWeekScheduleId = checkString(request.getParameter("WeekScheduleId"));

    /// DEBUG /////////////////////////////////////////////////////////////////
    if(Debug.enabled){
        Debug.println("\n*********** getWeekScheduleFromXML.jsp ************");
        Debug.println("sWeekScheduleId : "+sWeekScheduleId+"\n");
    }
    ///////////////////////////////////////////////////////////////////////////

    Vector weekSchedules = parsePredefinedWeekSchedules(request,sWebLanguage);
    PredefinedWeekSchedule weekSchedule;
    String sWeekSchedule = "";

    if(weekSchedules.size() > 0){
        for(int i=0; i<weekSchedules.size(); i++){
            weekSchedule = (PredefinedWeekSchedule)weekSchedules.get(i);
            
            if(weekSchedule.id.equalsIgnoreCase(sWeekScheduleId)){
                sWeekSchedule = weekSchedule.asConcatValue();
                break;
            }
        }
    }
%>

{
  "weekSchedule":"<%=sWeekSchedule%>"
}