package be.openclinic.hr;

import be.openclinic.common.OC_Object;
import be.mxs.common.util.db.MedwanQuery;
import be.mxs.common.util.system.Debug;
import be.mxs.common.util.system.ScreenHelper;

import java.util.*;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.io.*;

import org.dom4j.*;
import org.dom4j.io.SAXReader;


public class Workschedule extends OC_Object {
    public int serverId;
    public int objectId;    
    public int personId;
    
    public java.util.Date begin;
    public java.util.Date end;
    public int fte;
    public String scheduleXml;
    
    public String type; // only for convenience
    public Vector parsedTimeBlocks = null; // only for convenience
    

    //#############################################################################################
    //### INNER CLASS : TimeBlock #################################################################
    //#############################################################################################
    class TimeBlock {
        //************************************************
        //******** THIS IS JUST A DATA_CONTAINER *********
        //************************************************
        
        // <WeekSchedule scheduleType='weekSchedule.2'>
        //  <TimeBlocks>
        //   <TimeBlock><DayIdx>1</DayIdx><BeginHour>09:00</BeginHour><EndHour>17:36</EndHour><Duration>08:36</Duration></TimeBlock>
        //   <TimeBlock><DayIdx>2</DayIdx><BeginHour>09:00</BeginHour><EndHour>17:36</EndHour><Duration>08:36</Duration></TimeBlock>
        //   <TimeBlock><DayIdx>3</DayIdx><BeginHour>09:00</BeginHour><EndHour>17:36</EndHour><Duration>08:36</Duration></TimeBlock>
        //  </TimeBlocks>
        // </WeekSchedule>
       
        public String dayIdx;
        public String beginHour;
        public String endHour;
        public String duration;
        
        //--- CONSTRUCTOR ---
        public TimeBlock(){
            dayIdx = "";
            beginHour = "";        
            endHour = "";
            duration = "";
        }
               
    }
    //#############################################################################################
    //#############################################################################################
    //#############################################################################################

    //--- CONSTRUCTOR ---
    public Workschedule(){
        serverId = -1;
        objectId = -1;        
        personId = -1;
        
        begin = null;
        end = null;
        fte = -1;
        scheduleXml = ""; 
        type = ""; // only for convenience
    }
    
    //--- IS ACTIVE -------------------------------------------------------------------------------
    public boolean isActive(){
        Calendar cal = Calendar.getInstance();
        cal.setTime(new java.util.Date()); // now
        cal.set(Calendar.HOUR_OF_DAY,0);
        cal.set(Calendar.MINUTE,0);
        cal.set(Calendar.SECOND,0);
        cal.set(Calendar.MILLISECOND,0);
        
        return isActive(cal.getTime()); // the very beginning of today
    }
       
    public boolean isActive(java.util.Date date){
        boolean isActive = false;
                
        // both dates exist
        if(this.begin!=null && this.end!=null){
            if(this.begin.getTime() <= date.getTime() && this.end.getTime() >= date.getTime()){
                isActive = true;
            }
        }
        // only begin exists
        else if(this.begin!=null){
            if(this.begin.getTime() <= date.getTime()){
                isActive = true;
            }
        }
        // only end exists
        else if(this.end!=null){
            if(this.end.getTime() >= date.getTime()){
                isActive = true;
            }
        }

        return isActive;
    }
    
    //--- GET WORK DAYS ---------------------------------------------------------------------------
    // only applicable for type = 'week'
    public boolean[] getWorkDays(){
        boolean[] workDays = new boolean[7];
        
        // ATTENTION : you should set 'type' yourself --> getWorkscheduleType()
        if(this.type.equals("week")){
            // init to false (not working)
            workDays[0] = false; // Monday
            workDays[1] = false; // Tuesday
            workDays[2] = false; // Wednesday
            workDays[3] = false; // Thursday
            workDays[4] = false; // Friday
            workDays[5] = false; // Saturday
            workDays[6] = false; // Sunday
            
            try{
                Vector timeBlocks = parseWeekschedule();
                TimeBlock timeBlock;
                
                for(int t=0; t<timeBlocks.size(); t++){
                    timeBlock = (TimeBlock)timeBlocks.get(t);
                    workDays[Integer.parseInt(timeBlock.dayIdx)-1] = true;
                }
            }
            catch(Exception e){
                if(Debug.enabled) e.printStackTrace();
                Debug.printProjectErr(e,Thread.currentThread().getStackTrace());
            }
        }
        else{
            // do not work in the weekend for daySchedule and monthSchedule
            workDays[0] = true;  // Monday
            workDays[1] = true;  // Tuesday
            workDays[2] = true;  // Wednesday
            workDays[3] = true;  // Thursday
            workDays[4] = true;  // Friday
            workDays[5] = false; // Saturday
            workDays[6] = false; // Sunday
        }

        return workDays;
    }
    
    //--- GET DURATION ----------------------------------------------------------------------------
    // return duration of specified day (day-index of that day) according to workschedule (xml)
    /*
        *** DAY ***
        <WorkSchedule>
          <Schedule type="day">
            <BeginHour>10:00</BeginHour>
            <EndHour>15:00</EndHour>
            <HoursPerDay>05:00</HoursPerDay>
          </Schedule>
        </WorkSchedule>
        
        *** WEEK ***
        <WorkSchedule>
          <Schedule type="week">
            <WeekSchedule scheduleType="weekSchedule.0">
              <HoursPerWeek>08:00</HoursPerWeek>
              <TimeBlocks>
                <TimeBlock>
                  <DayIdx>7</DayIdx>
                  <BeginHour>08:00</BeginHour>
                  <EndHour>10:00</EndHour>
                  <Duration>02:00</Duration>
                </TimeBlock>
                ...
              </TimeBlocks>
            </WeekSchedule>
          </Schedule>
        </WorkSchedule>
        
        *** MONTH ***
        <WorkSchedule>
          <Schedule type="month">
            <PredefinedHoursPerMonth>160</PredefinedHoursPerMonth>
            <HoursPerMonth>160</HoursPerMonth>
          </Schedule>
        </WorkSchedule>
    */
    public float getDuration(java.util.Date date){
        float duration = -1;
        Calendar cal = Calendar.getInstance();
        cal.setTime(date);
        
        //*** 1 : DAY *******************************************        
        if(this.type.equals("day")){
            String sHoursPerDay = this.getScheduleElementValue(this.type,"HoursPerDay");
            
            if(sHoursPerDay.length() > 0){
                duration = toDecimalHour(sHoursPerDay);
            }
        }        
        //*** 2 : WEEK ******************************************
        else if(this.type.equals("week")){
            try{
                Vector timeBlocks = parseWeekschedule();
                TimeBlock timeBlock;

                int targetDayIdx = cal.get(Calendar.DAY_OF_WEEK)-2;        
                if(targetDayIdx < 0) targetDayIdx = 6;
                
                for(int t=0; t<timeBlocks.size(); t++){
                    timeBlock = (TimeBlock)timeBlocks.get(t);
                    
                    // get duration when day-indexes equal
                    if(Integer.parseInt(timeBlock.dayIdx)-1==targetDayIdx){                        
                        duration = toDecimalHour(timeBlock.duration);
                        break;
                    }
                }
            }
            catch(Exception e){
                if(Debug.enabled) e.printStackTrace();
                Debug.printProjectErr(e,Thread.currentThread().getStackTrace());
            }
        }        
        //*** 3 : MONTH *****************************************
        else if(this.type.equals("month")){
            String sHoursPerMonth = this.getScheduleElementValue(this.type,"HoursPerMonth");
                         
            if(sHoursPerMonth.length() > 0){
                int workdaysInMonth = countWorkdaysInMonth(date);
                duration = toDecimalHour(sHoursPerMonth)/workdaysInMonth;
            }
        }
        
        return duration;
    }
    
    //---- COUNT WORKDAYS IN MONTH ----------------------------------------------------------------
    private int countWorkdaysInMonth(java.util.Date month){
        int workdayCount = 0;
        
        Calendar cal = Calendar.getInstance();
        cal.setTime(month);
        
        // start at first midnight of that month 
        cal.set(Calendar.DAY_OF_MONTH,1);
        cal.set(Calendar.HOUR,0);
        cal.set(Calendar.MINUTE,0);
        cal.set(Calendar.SECOND,0);
        cal.set(Calendar.MILLISECOND,0);
        
        int daysInMonth = cal.getMaximum(Calendar.DAY_OF_MONTH);
        
        for(int i=0; i<daysInMonth; i++){ 
        	// skip weekend
            if(cal.get(Calendar.DAY_OF_WEEK)!=Calendar.SATURDAY && cal.get(Calendar.DAY_OF_WEEK)!=Calendar.SUNDAY){
                workdayCount++;    
            }
            
            cal.add(Calendar.DAY_OF_MONTH,1); // proceed one day
        }
        
        return workdayCount;
    }
    
    //--- TO DECIMAL HOUR -------------------------------------------------------------------------
    // "04:15" --> 4,25f
    private float toDecimalHour(String sHour){
        float value = 0;
        
        if(sHour.length() > 0){
            // ":" available
            if(sHour.indexOf(":") > -1){
                String[] hourParts = sHour.split(":");
                
                // 1 : parse hour-value
                if(ScreenHelper.checkString(hourParts[0]).length() > 0){
                    while(hourParts[0].startsWith("0") && hourParts[0].length() > 1){
                        hourParts[0] = hourParts[0].substring(1);
                    }
                    value+= Float.parseFloat(hourParts[0].replaceAll(",","."));    
                }
                
                // 2 : parse minutes-value
                if(ScreenHelper.checkString(hourParts[1]).length() > 0){
                    while(hourParts[1].startsWith("0") && hourParts[1].length() > 1){
                        hourParts[1] = hourParts[1].substring(1);
                    }            
                    value+= (Float.parseFloat(hourParts[1].replaceAll(",","."))/60f);    
                }
            }
            else{
                value = Float.parseFloat(sHour.replaceAll(",","."));
            }
        }

        return value;
    }
    
    //--- PARSE WEEKSCHEDULE ----------------------------------------------------------------------
    // <WeekSchedule scheduleType='weekSchedule.2'>
    //  <TimeBlocks>
    //   <TimeBlock><DayIdx>1</DayIdx><BeginHour>09:00</BeginHour><EndHour>17:36</EndHour><Duration>08:36</Duration></TimeBlock>
    //   <TimeBlock><DayIdx>2</DayIdx><BeginHour>09:00</BeginHour><EndHour>17:36</EndHour><Duration>08:36</Duration></TimeBlock>
    //   <TimeBlock><DayIdx>3</DayIdx><BeginHour>09:00</BeginHour><EndHour>17:36</EndHour><Duration>08:36</Duration></TimeBlock>
    //  </TimeBlocks>
    // </WeekSchedule>
    //
    // to a Vector of TimeBlocks
    public Vector parseWeekschedule() throws Exception {
        // check whether data was already parsed, reuse when possible
        Vector timeBlocks = parsedTimeBlocks;
        
        if(timeBlocks==null){
            timeBlocks = new Vector();
        
            // ATTENTION : you should set 'type' yourself --> getWorkscheduleType()
            if(this.type.equals("week")){
                if(this.scheduleXml!=null && this.scheduleXml.length() > 0){
                    /*
                      <WorkSchedule>
                        <Schedule type="week">
                          <WeekSchedule scheduleType="weekSchedule.2">
                            <HoursPerWeek>07:00</HoursPerWeek>
                            <TimeBlocks>
                              <TimeBlock><DayIdx>4</DayIdx><BeginHour>08:00</BeginHour><EndHour>09:00</EndHour><Duration>01:00</Duration></TimeBlock>
                              <TimeBlock><DayIdx>2</DayIdx><BeginHour>09:00</BeginHour><EndHour>15:00</EndHour><Duration>06:00</Duration></TimeBlock>
                            </TimeBlocks>
                          </WeekSchedule>
                        </Schedule>
                      </WorkSchedule>
                    */
                    
                    SAXReader reader = new SAXReader(false);
                    Document document = reader.read(new StringReader(this.scheduleXml));
                    Element rootElem = document.getRootElement(); // WorkSchedule
                    Element workScheduleElem = rootElem.element("Schedule");
                    Element weekScheduleElem = workScheduleElem.element("WeekSchedule");
                             
                    Element timeBlockElems = weekScheduleElem.element("TimeBlocks");
                    if(timeBlocks!=null){
                        Iterator timeBlockIter = timeBlockElems.elementIterator("TimeBlock");
        
                        String sTmpDayIdx, sTmpBeginHour, sTmpEndHour, sTmpDuration;
                        Element timeBlockElem;
                        
                        while(timeBlockIter.hasNext()){
                            timeBlockElem = (Element)timeBlockIter.next();
                                                    
                            sTmpDayIdx    = ScreenHelper.checkString(timeBlockElem.elementText("DayIdx"));
                            sTmpBeginHour = ScreenHelper.checkString(timeBlockElem.elementText("BeginHour"));
                            sTmpEndHour   = ScreenHelper.checkString(timeBlockElem.elementText("EndHour"));
                            sTmpDuration  = ScreenHelper.checkString(timeBlockElem.elementText("Duration"));
                            
                            TimeBlock timeBlock = new TimeBlock();
                            timeBlock.dayIdx    = sTmpDayIdx;
                            timeBlock.beginHour = sTmpBeginHour;
                            timeBlock.endHour   = sTmpEndHour;
                            timeBlock.duration  = sTmpDuration;
                            
                            timeBlocks.add(timeBlock);
                        }
                    }
                }
            }
            else{
                Debug.println("WARNING : Workschedule.parseWeekschedule() only applicable for type = 'week' while type is '"+this.type+"'.");
            }
            
            parsedTimeBlocks = timeBlocks; // store on class-level for future use
        }
        
        return timeBlocks;
    }
            
    //--- STORE -----------------------------------------------------------------------------------
    public boolean store(String userUid){
        boolean errorOccurred = false;
        PreparedStatement ps = null;
        ResultSet rs = null;
        String sSql;
        
        Connection oc_conn = MedwanQuery.getInstance().getOpenclinicConnection();
                
        try{            
            if(getUid().equals("-1")){
                // insert new record
                sSql = "INSERT INTO hr_workschedule (HR_WORKSCHEDULE_SERVERID,HR_WORKSCHEDULE_OBJECTID,HR_WORKSCHEDULE_PERSONID,"+
                       "  HR_WORKSCHEDULE_BEGINDATE,HR_WORKSCHEDULE_ENDDATE,HR_WORKSCHEDULE_FTE,HR_WORKSCHEDULE_SCHEDULE,"+
                       "  HR_WORKSCHEDULE_UPDATETIME, HR_WORKSCHEDULE_UPDATEID)"+ // update-info
                       " VALUES(?,?,?,?,?,?,?,?,?)"; // 9
                ps = oc_conn.prepareStatement(sSql);
                
                int serverId = MedwanQuery.getInstance().getConfigInt("serverId"),
                    objectId = MedwanQuery.getInstance().getOpenclinicCounter("HR_WORKSCHEDULE");
                this.setUid(serverId+"."+objectId);
                
                int psIdx = 1;
                ps.setInt(psIdx++,serverId);
                ps.setInt(psIdx++,objectId);
                ps.setInt(psIdx++,personId);

                // begin date might be unspecified
                if(begin!=null){
                    ps.setDate(psIdx++,new java.sql.Date(begin.getTime()));
                }
                else{
                    ps.setDate(psIdx++,null);
                }
                
                // end date might be unspecified
                if(end!=null){
                    ps.setDate(psIdx++,new java.sql.Date(end.getTime()));
                }
                else{
                    ps.setDate(psIdx++,null);
                }

                ps.setInt(psIdx++,fte);
                ps.setString(psIdx++,scheduleXml);
                ps.setTimestamp(psIdx++,new Timestamp(new java.util.Date().getTime())); // now
                ps.setString(psIdx,userUid);
                
                ps.executeUpdate();
            } 
            else{
                // update existing record
                sSql = "UPDATE hr_workschedule SET"+
                       "  HR_WORKSCHEDULE_BEGINDATE = ?, HR_WORKSCHEDULE_ENDDATE = ?,"+
                       "  HR_WORKSCHEDULE_FTE = ?, HR_WORKSCHEDULE_SCHEDULE = ?,"+
                       "  HR_WORKSCHEDULE_UPDATETIME = ?, HR_WORKSCHEDULE_UPDATEID = ?"+ // update-info
                       " WHERE (HR_WORKSCHEDULE_SERVERID = ? AND HR_WORKSCHEDULE_OBJECTID = ?)"; // identification
                ps = oc_conn.prepareStatement(sSql);

                int psIdx = 1;
                
                // begin date might be unspecified
                if(begin!=null){
                    ps.setDate(psIdx++,new java.sql.Date(begin.getTime()));
                }
                else{
                    ps.setDate(psIdx++,null);
                }
                
                // end date might be unspecified
                if(end!=null){
                    ps.setDate(psIdx++,new java.sql.Date(end.getTime()));
                }
                else{
                    ps.setDate(psIdx++,null);
                }

                ps.setInt(psIdx++,fte);
                ps.setString(psIdx++,scheduleXml);
                ps.setTimestamp(psIdx++,new Timestamp(new java.util.Date().getTime())); // now
                ps.setString(psIdx++,userUid);
                
                // where
                ps.setInt(psIdx++,Integer.parseInt(getUid().substring(0,getUid().indexOf("."))));
                ps.setInt(psIdx,Integer.parseInt(getUid().substring(getUid().indexOf(".")+1)));
                
                ps.executeUpdate();
            }            
        }
        catch(Exception e){
            errorOccurred = true;
            if(Debug.enabled) e.printStackTrace();
            Debug.printProjectErr(e,Thread.currentThread().getStackTrace());
        }
        finally{
            try{
                if(rs!=null) rs.close();
                if(ps!=null) ps.close();
                oc_conn.close();
            }
            catch(SQLException se){
                Debug.printProjectErr(se,Thread.currentThread().getStackTrace());
            }
        }
        
        return errorOccurred;
    }
    
    //--- GET SCHEDULE ELEMENT VALUE --------------------------------------------------------------
    public String getScheduleElementValue(String scheduleType, String sElementName){
        /*
            *** DAY ***
            <WorkSchedule>
              <Schedule type="day">
                <BeginHour>10:00</BeginHour>
                <EndHour>15:00</EndHour>
                <HoursPerDay>05:00</HoursPerDay>
              </Schedule>
            </WorkSchedule>
            
            *** WEEK ***
            <WorkSchedule>
              <Schedule type="week">
                <WeekSchedule scheduleType="weekSchedule.0">
                  <HoursPerWeek>08:00</HoursPerWeek>
                  <TimeBlocks>
                    <TimeBlock>
                      <DayIdx>7</DayIdx>
                      <BeginHour>08:00</BeginHour>
                      <EndHour>10:00</EndHour>
                      <Duration>02:00</Duration>
                    </TimeBlock>
                    ...
                  </TimeBlocks>
                </WeekSchedule>
              </Schedule>
            </WorkSchedule>
            
            *** MONTH ***
            <WorkSchedule>
              <Schedule type="month">
                <PredefinedHoursPerMonth>160</PredefinedHoursPerMonth>
                <HoursPerMonth>160</HoursPerMonth>
              </Schedule>
            </WorkSchedule>
        */
        
        String sValue = "";
        
        try{
            // parse schedule from xml            
            SAXReader reader = new SAXReader(false);
            Document document = reader.read(new StringReader(scheduleXml));
            Element scheduleElem = document.getRootElement();
                    
            if(scheduleType.equalsIgnoreCase("day")){
                Element schedule = scheduleElem.element("Schedule");
                if(schedule!=null){
                    sValue = ScreenHelper.checkString(schedule.elementText(sElementName));
                }
                else{
                    sValue = ScreenHelper.checkString(scheduleElem.elementText(sElementName));
                }
            }
            else if(scheduleType.equalsIgnoreCase("week")){
                Element weekSchedule = scheduleElem.element("WeekSchedule");
                if(weekSchedule!=null){
                    sValue = weekSchedule.asXML();
                }
            }
            else if(scheduleType.equalsIgnoreCase("month")){
                Element schedule = scheduleElem.element("Schedule");
                if(schedule!=null){
                    sValue = ScreenHelper.checkString(schedule.elementText(sElementName));
                }
                else{
                    sValue = ScreenHelper.checkString(scheduleElem.elementText(sElementName));
                }
            }
        }
        catch(Exception e){
            e.printStackTrace();
            Debug.printProjectErr(e,Thread.currentThread().getStackTrace());
        }
        
        return sValue;
    }

    
    //#############################################################################################
    //#################################          STATIC          ##################################
    //#############################################################################################

    //--- DELETE ----------------------------------------------------------------------------------
    public static boolean delete(String sScheduleUid){
        boolean errorOccurred = false;
        PreparedStatement ps = null;
        ResultSet rs = null;
        
        Connection oc_conn = MedwanQuery.getInstance().getOpenclinicConnection();
        
        try{
            String sSql = "DELETE FROM hr_workschedule"+
                          " WHERE (HR_WORKSCHEDULE_SERVERID = ? AND HR_WORKSCHEDULE_OBJECTID = ?)";
            ps = oc_conn.prepareStatement(sSql);
            ps.setInt(1,Integer.parseInt(sScheduleUid.substring(0,sScheduleUid.indexOf("."))));
            ps.setInt(2,Integer.parseInt(sScheduleUid.substring(sScheduleUid.indexOf(".")+1)));
            
            ps.executeUpdate();
        }
        catch(Exception e){
            errorOccurred = true;
            if(Debug.enabled) e.printStackTrace();
            Debug.printProjectErr(e,Thread.currentThread().getStackTrace());
        }
        finally{
            try{
                if(rs!=null) rs.close();
                if(ps!=null) ps.close();
                oc_conn.close();
            }
            catch(SQLException se){
                Debug.printProjectErr(se,Thread.currentThread().getStackTrace());
            }
        }
        
        return errorOccurred;
    }
    
    //--- GET -------------------------------------------------------------------------------------
    public static Workschedule get(Workschedule schedule){
        return get(schedule.getUid());
    }
       
    public static Workschedule get(String sScheduleUid){
        Workschedule schedule = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        
        Connection oc_conn = MedwanQuery.getInstance().getOpenclinicConnection();
        
        try{
            String sSql = "SELECT * FROM hr_workschedule"+
                          " WHERE (HR_WORKSCHEDULE_SERVERID = ? AND HR_WORKSCHEDULE_OBJECTID = ?)";
            ps = oc_conn.prepareStatement(sSql);
            ps.setInt(1,Integer.parseInt(sScheduleUid.substring(0,sScheduleUid.indexOf("."))));
            ps.setInt(2,Integer.parseInt(sScheduleUid.substring(sScheduleUid.indexOf(".")+1)));

            // execute
            rs = ps.executeQuery();
            if(rs.next()){
                schedule = new Workschedule();
                schedule.setUid(rs.getString("HR_WORKSCHEDULE_SERVERID")+"."+rs.getString("HR_WORKSCHEDULE_OBJECTID"));

                schedule.personId    = rs.getInt("HR_WORKSCHEDULE_PERSONID");
                schedule.begin       = rs.getDate("HR_WORKSCHEDULE_BEGINDATE");
                schedule.end         = rs.getDate("HR_WORKSCHEDULE_ENDDATE");
                schedule.fte         = rs.getInt("HR_WORKSCHEDULE_FTE");
                schedule.scheduleXml = ScreenHelper.checkString(rs.getString("HR_WORKSCHEDULE_SCHEDULE")); 
                //schedule.type        = getWorkscheduleType(schedule); // too time-consuming ?
                
                // parent
                schedule.setUpdateDateTime(rs.getTimestamp("HR_WORKSCHEDULE_UPDATETIME"));
                schedule.setUpdateUser(rs.getString("HR_WORKSCHEDULE_UPDATEID"));
            }
        }
        catch(Exception e){
            if(Debug.enabled) e.printStackTrace();
            Debug.printProjectErr(e,Thread.currentThread().getStackTrace());
        }
        finally{
            try{
                if(rs!=null) rs.close();
                if(ps!=null) ps.close();
                oc_conn.close();
            }
            catch(SQLException se){
                Debug.printProjectErr(se,Thread.currentThread().getStackTrace());
            }
        }
        
        return schedule;
    }
        
    //--- GET LIST --------------------------------------------------------------------------------
    public static List<Workschedule> getList(){
        return getList(new Workschedule());         
    }
    
    public static List<Workschedule> getList(Workschedule findItem){
        List<Workschedule> foundObjects = new LinkedList();
        PreparedStatement ps = null;
        ResultSet rs = null;
        
        Connection oc_conn = MedwanQuery.getInstance().getOpenclinicConnection();
        
        try{
            // compose query
            String sSql = "SELECT * FROM hr_workschedule WHERE 1=1"; // 'where' facilitates further composition of query

            if(findItem.personId > -1){
                sSql+= " AND HR_WORKSCHEDULE_PERSONID = "+findItem.personId;
            }            
            if(findItem.fte > -1){
                sSql+= " AND HR_WORKSCHEDULE_FTE = "+findItem.fte;
            }
            
            // dates
            if(findItem.begin!=null && findItem.end!=null){
                sSql+= " AND ("+
                       "   (HR_WORKSCHEDULE_BEGINDATE IS NULL OR HR_WORKSCHEDULE_BEGINDATE <= ?)"+ // end !!
                       "  AND"+
                       "   (HR_WORKSCHEDULE_ENDDATE IS NULL OR HR_WORKSCHEDULE_ENDDATE >= ?)"+ // begin !!
                       " )";
            }
            else if(findItem.begin!=null){
                sSql+= " AND (HR_WORKSCHEDULE_BEGINDATE IS NULL OR HR_WORKSCHEDULE_BEGINDATE <= ?)"; // end !!
            }
            else if(findItem.end!=null){
                sSql+= " AND (HR_WORKSCHEDULE_ENDDATE IS NULL OR HR_WORKSCHEDULE_ENDDATE >= ?)"; // begin !!
            }
            
            sSql+= " ORDER BY HR_WORKSCHEDULE_OBJECTID ASC";
            
            //Debug.println("\n"+sSql+"\n");
            ps = oc_conn.prepareStatement(sSql);

            // dates
            if(findItem.begin!=null && findItem.end!=null){
                ps.setTimestamp(1,new java.sql.Timestamp(findItem.end.getTime())); // end !!
                ps.setTimestamp(2,new java.sql.Timestamp(findItem.begin.getTime())); // begin !!
            }
            else if(findItem.begin!=null){
                ps.setTimestamp(1,new java.sql.Timestamp(findItem.end.getTime())); // end !!
            }
            else if(findItem.end!=null){
                ps.setTimestamp(1,new java.sql.Timestamp(findItem.begin.getTime())); // begin !!
            }
                       
            // execute query
            rs = ps.executeQuery();
            Workschedule schedule;
            
            while(rs.next()){
                schedule = new Workschedule();                
                schedule.setUid(rs.getString("HR_WORKSCHEDULE_SERVERID")+"."+rs.getString("HR_WORKSCHEDULE_OBJECTID"));

                schedule.personId    = rs.getInt("HR_WORKSCHEDULE_PERSONID");
                schedule.begin       = rs.getDate("HR_WORKSCHEDULE_BEGINDATE");
                schedule.end         = rs.getDate("HR_WORKSCHEDULE_ENDDATE");
                schedule.fte         = rs.getInt("HR_WORKSCHEDULE_FTE");
                schedule.scheduleXml = ScreenHelper.checkString(rs.getString("HR_WORKSCHEDULE_SCHEDULE"));
                //schedule.type        = getWorkscheduleType(schedule); // too time-consuming ? 
                
                // parent
                schedule.setUpdateDateTime(rs.getTimestamp("HR_WORKSCHEDULE_UPDATETIME"));
                schedule.setUpdateUser(rs.getString("HR_WORKSCHEDULE_UPDATEID"));
                
                foundObjects.add(schedule);
            }
        }
        catch(Exception e){
            if(Debug.enabled) e.printStackTrace();
            Debug.printProjectErr(e,Thread.currentThread().getStackTrace());
        }
        finally{
            try{
                if(rs!=null) rs.close();
                if(ps!=null) ps.close();
                oc_conn.close();
            }
            catch(SQLException se){
                Debug.printProjectErr(se,Thread.currentThread().getStackTrace());
            }
        }
        
        return foundObjects;
    }

    //--- GET WORKSCHEDULE TYPE -------------------------------------------------------------------
    public static String getWorkscheduleType(Workschedule schedule){
        String sType = "";
        
        try{
            // parse weekSchedule from xml            
            SAXReader reader = new SAXReader(false);
            Document document = reader.read(new StringReader(schedule.scheduleXml));
            Element workScheduleElem = document.getRootElement();
            
            // attribute : type
            Element scheduleElem = workScheduleElem.element("Schedule");
            if(scheduleElem!=null){                 
                sType = ScreenHelper.checkString(scheduleElem.attributeValue("type"));
            }
        }
        catch(Exception e){
            if(Debug.enabled) e.printStackTrace();
            Debug.printProjectErr(e,Thread.currentThread().getStackTrace());
        }
        
        return sType;
    }
     
}
