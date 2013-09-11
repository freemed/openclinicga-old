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
    }

    //--- GET WEEK SCHEDULE OPTIONS ---------------------------------------------------------------
    private String getWeekScheduleOptions(String sSelectedScheduleId, String sWebLanguage){
        String sOptions = "<option value=''>"+getTranNoLink("web","new",sWebLanguage)+"</option>"; // html
        
        Vector weekSchedules = parsePredefinedWeekSchedulesFromXMLConfigValue();
        PredefinedWeekSchedule schedule;
        
        Collections.sort(weekSchedules); // on type
        
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
                    
                    // timeBlocks not parsed, no need to
                    
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
    /// DEBUG /////////////////////////////////////////////////////////////////
    if(Debug.enabled){
        Debug.println("\n*********** getWeekscheduleOptions.jsp ************");
        Debug.println("No parameters\n");
    }
    ///////////////////////////////////////////////////////////////////////////
    
    String sHtml = "<select class='text' id='weekScheduleTypeSelect' name='weekScheduleTypeSelect' onChange='setWeekScheduleType(this.options[this.selectedIndex].text);setTimeBlocksString(this.options[this.selectedIndex].value);'>"+
                       getWeekScheduleOptions("",sWebLanguage)+
                   "</select> "+
                   "<input class='button' type='button' value="+getTran("web","back",sWebLanguage)+" onclick='doBack();'>";    
%>

<%=HTMLEntities.htmlentities(sHtml)%>