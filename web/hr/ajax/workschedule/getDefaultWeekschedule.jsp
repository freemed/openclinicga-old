<%@page import="be.mxs.common.util.system.HTMLEntities"%>
<%@page import="org.dom4j.DocumentException,
                java.util.Vector"%>
<%@page import="java.io.StringReader"%>
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
    String sWeekScheduleId = checkString(request.getParameter("WeekScheduleId"));

    /// DEBUG //////////////////////////////////////////////////////////////////////
    if(Debug.enabled){
        Debug.println("\n********** hr/ajax/getWeekScheduleFromXML.jsp **********");
        Debug.println("sWeekScheduleId : "+sWeekScheduleId+"\n");
    }
    ////////////////////////////////////////////////////////////////////////////////

    Vector weekSchedules = parsePredefinedWeekSchedulesFromXMLConfigValue();
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
  "weekSchedule":"<%=HTMLEntities.htmlentities(sWeekSchedule)%>"
}