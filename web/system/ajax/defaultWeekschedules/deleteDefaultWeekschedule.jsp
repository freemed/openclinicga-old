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
        
    //--- REMOVE SCHEDULE -------------------------------------------------------------------------
    private void removeSchedule(String sScheduleId){        
        PredefinedWeekSchedule schedule;
        boolean removed = false;
        
        for(int i=0; i<weekSchedules.size() && !removed; i++){
            schedule = (PredefinedWeekSchedule)weekSchedules.get(i);
    
            if(schedule.id.equalsIgnoreCase(sScheduleId)){
            	weekSchedules.remove(i);
            	removed = true;
            }
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
    String sScheduleUid = checkString(request.getParameter("ScheduleUid"));
       
    /// DEBUG //////////////////////////////////////////////////////////////////////
    if(Debug.enabled){
        Debug.println("\n******* system/ajax/deleteDefaultWeekschedule.jsp *******");
        Debug.println("sScheduleUid : "+sScheduleUid+"\n");
    }
    ////////////////////////////////////////////////////////////////////////////////

    
    //*** 1 - build vector of schedule objects, from configValue ***
    weekSchedules = parsePredefinedWeekSchedulesFromXMLConfigValue();
    
    //*** 2 - remove object with specified uid from array
    removeSchedule(sScheduleUid);
    
    //*** 3 - save xml representing all the schedules as configValue ***
    MedwanQuery.getInstance().setConfigString("defaultWeekschedules",getSchedulesAsXml());
    
    String sMessage = "<font color='green'>"+getTran("web","dataIsDeleted",sWebLanguage)+"</font>";
%>

{
  "message":"<%=HTMLEntities.htmlentities(sMessage)%>"
}