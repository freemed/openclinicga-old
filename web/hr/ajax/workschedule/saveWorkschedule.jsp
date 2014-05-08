<%@page import="be.mxs.common.util.system.HTMLEntities,
                be.openclinic.hr.Workschedule,
                java.util.*"%>
<%@page import="java.io.*,
                org.dom4j.*"%>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>

<%!
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
%>

<%
    String sEditScheduleUid = checkString(request.getParameter("EditScheduleUid")),
           sPersonId        = checkString(request.getParameter("PersonId"));

    String sBegin        = checkString(request.getParameter("begin")),
           sEnd          = checkString(request.getParameter("end")),
           sFTE          = checkString(request.getParameter("fte")),
           sScheduleType = checkString(request.getParameter("scheduleType")),

           // type1 - day
           sDayStart = checkString(request.getParameter("dayStart")),
           sDayEnd   = checkString(request.getParameter("dayEnd")),
           sDayHours = checkString(request.getParameter("dayHours")),

           // type2 - week
           sWeekScheduleType = checkString(request.getParameter("weekScheduleType")),
           sWeekSchedule     = checkString(request.getParameter("weekSchedule")),           
           sWeekHours        = checkString(request.getParameter("weekHours")),

           // type3 - month
           sMonthScheduleType = checkString(request.getParameter("monthScheduleType")),
           sMonthHours        = checkString(request.getParameter("monthHours"));


    /// DEBUG /////////////////////////////////////////////////////////////////
    if(Debug.enabled){
        Debug.println("\n*************** saveWorkschedule.jsp **************");
        Debug.println("sEditScheduleUid : "+sEditScheduleUid);
        Debug.println("sPersonId        : "+sPersonId);
        Debug.println("sBegin           : "+sBegin);
        Debug.println("sEnd             : "+sEnd);
        Debug.println("sFTE             : "+sFTE);
        Debug.println("sScheduleType    : "+sScheduleType);

        // type1 - day
        Debug.println("sDayStart : "+sDayStart);
        Debug.println("sDayEnd   : "+sDayEnd);
        Debug.println("sDayHours : "+sDayHours);

        // type2 - week
        Debug.println("sWeekScheduleType : "+sWeekScheduleType);        
        Debug.println("sWeekSchedule     : "+sWeekSchedule);
        Debug.println("sWeekHours        : "+sWeekHours);

        // type3 - month
        Debug.println("sMonthScheduleType : "+sMonthScheduleType);
        Debug.println("sMonthHours        : "+sMonthHours+"\n");
    }

    Workschedule workschedule = new Workschedule();
    workschedule.personId = Integer.parseInt(sPersonId);
    String sMessage = "";
    
    if(sEditScheduleUid.length() > 0){
        workschedule.setUid(sEditScheduleUid);
    }
    else{
        workschedule.setUid("-1");
        workschedule.setCreateDateTime(getSQLTime());
    }

    if(sBegin.length() > 0){
        workschedule.begin = ScreenHelper.parseDate(sBegin);
    }
    if(sEnd.length() > 0){
        workschedule.end = ScreenHelper.parseDate(sEnd);
    }

    if(sFTE.length() > 0){
        workschedule.fte = Integer.parseInt(getTranNoLink("hr.workschedule.fte",sFTE,sWebLanguage));
    }
    
    ///////////////////////////////////////////////////////////////////////////
    /// XML-BOUND DATA ////////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////
    if(sScheduleType.length() > 0){           
        org.dom4j.Document document = DocumentHelper.createDocument();
        Element wsElem = document.addElement("WorkSchedule"); 
            
        //*** type1 - day ***************************
        if(sScheduleType.equals("day")){
            Element schedule = wsElem.addElement("Schedule");    
            schedule.addAttribute("type",sScheduleType);
            
            if(sDayStart.length() > 0){
                schedule.addElement("BeginHour").setText(sDayStart);
            }
    
            if(sDayEnd.length() > 0){
                schedule.addElement("EndHour").setText(sDayEnd);
            }
    
            if(sDayHours.length() > 0){
                schedule.addElement("HoursPerDay").setText(sDayHours);
            }
        }
        //*** type2 - week **************************
        else if(sScheduleType.equals("week")){
            Element schedule = wsElem.addElement("Schedule");
            schedule.addAttribute("type",sScheduleType);

            Element weekSchedule = schedule.addElement("WeekSchedule");
            weekSchedule.addAttribute("scheduleType",sWeekScheduleType);
            
            if(sWeekHours.length() > 0){
                weekSchedule.addElement("HoursPerWeek").setText(sWeekHours);
            }
    
            if(sWeekSchedule.length() > 0){
                weekSchedule = timeblocksToWeekschedule(sWeekSchedule,weekSchedule);
            }
        }
        //*** type3 - month *************************
        else if(sScheduleType.equals("month")){
            Element schedule = wsElem.addElement("Schedule");
            schedule.addAttribute("type",sScheduleType);
    
            if(sMonthScheduleType.length() > 0){
                schedule.addElement("PredefinedHoursPerMonth").setText(sMonthHours);
            }        
            if(sMonthHours.length() > 0){
                schedule.addElement("HoursPerMonth").setText(sMonthHours);
            }        
        }
        
        Debug.println("\n"+wsElem.asXML()+"\n");
        
        workschedule.scheduleXml = wsElem.asXML();
    }
    ///////////////////////////////////////////////////////////////////////////
    
    workschedule.setUpdateDateTime(ScreenHelper.getSQLDate(getDate()));
    workschedule.setUpdateUser(activeUser.userid);
    
    boolean errorOccurred = workschedule.store(activeUser.userid);
    
    if(!errorOccurred){
        sMessage = "<font color='green'>"+getTran("web","dataIsSaved",sWebLanguage)+"</font>";
    }
    else{
        sMessage = getTran("web","error",sWebLanguage);
    }
%>

{
  "message":"<%=HTMLEntities.htmlentities(sMessage)%>",
  "newUid":"<%=workschedule.getUid()%>"
}