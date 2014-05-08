package be.openclinic.hr;

import be.mxs.common.util.db.MedwanQuery;
import be.mxs.common.util.system.Debug;
import be.mxs.common.util.system.ScreenHelper;

import java.util.*;
import java.sql.*;

import net.admin.User;


public class SalaryCalculationManager /*extends OC_Object*/ {

    
    ///////////////////////////////////////////////////////////////////////////////////////////////
    ///////////////////                    FOR WORKSCHEDULES                       ////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////
	
    //--- CREATE SALARY CALCULATIONS FOR WORKSCHEDULES --------------------------------------------
    // for each employee, create a salary calculation for each day he is supposed to work in the 
    // specified period, according to his work schedule(s).
    public static int[] createSalaryCalculationsForWorkschedules(java.util.Date periodBegin, 
    		                                                     java.util.Date periodEnd,
                                                                 User activeUser) throws Exception {        
        // currMonth : begin and end
        Calendar now = Calendar.getInstance();        
        int month = now.get(Calendar.MONTH)+1;
        String sMonth = Integer.toString(month);
        if(month < 10){
            sMonth = "0"+sMonth;
        }
        
        String sCurrMonthBegin = "01/"+sMonth+"/"+now.get(Calendar.YEAR),
               sCurrMonthEnd   = now.getActualMaximum(Calendar.DAY_OF_MONTH)+"/"+sMonth+"/"+now.get(Calendar.YEAR);

        java.util.Date currMonthBegin = ScreenHelper.parseDate(sCurrMonthBegin),
                       currMonthEnd   = ScreenHelper.parseDate(sCurrMonthEnd);

        if(periodBegin==null) periodBegin = currMonthBegin;
        if(periodEnd==null) periodEnd = currMonthEnd;

        Debug.println("\n###############################################################################");
        Debug.println("##############     createSalaryCalculationsForWorkschedules     ###############");
        Debug.println("###############################################################################");
        Debug.println("periodBegin : "+ScreenHelper.stdDateFormat.format(periodBegin));
        Debug.println("periodEnd   : "+ScreenHelper.stdDateFormat.format(periodEnd));

        Vector personIds = new Vector(getEmployeePersonIds().keySet()); 
        Debug.println("personIds   : "+personIds.size());
        
        int personId;
        int[] counters;
        int calculationsCreated = 0, calculationsExisted = 0;
        
        for(int i=0; i<personIds.size(); i++){
            personId = ((Integer)personIds.get(i)).intValue();
            
            counters = createSalaryCalculationsForWorkschedulesForPerson(i,personId,periodBegin,periodEnd,activeUser);
            calculationsCreated+= counters[0];
            calculationsExisted+= counters[1]; 
        }        
        
        return new int[]{calculationsCreated,calculationsExisted};
    }
    
    //--- CREATE SALARY CALCULATIONS FOR WORKSCHEDULES FOR PERSON ---------------------------------
    // return : number of calculations created/existing
    public static int[] createSalaryCalculationsForWorkschedulesForPerson(int personId, java.util.Date begin, 
                                                                          java.util.Date end, User activeUser){
        return createSalaryCalculationsForWorkschedulesForPerson(0,personId,begin,end,activeUser);	
    }
    
    public static int[] createSalaryCalculationsForWorkschedulesForPerson(int idx, int personId, java.util.Date begin, 
                                                                          java.util.Date end, User activeUser){
        Debug.println("\n***** ["+idx+"] createSalaryCalculationsForWorkschedulesForPerson *************");
        Debug.println("personId : "+personId);
        Debug.println("begin    : "+ScreenHelper.stdDateFormat.format(begin));
        Debug.println("end      : "+ScreenHelper.stdDateFormat.format(end));
        
        int calculationsCreated = 0, calculationsExisted = 0;
        
        // search workschedules : compose object to pass search-criteria with
        Workschedule findObject = new Workschedule();
        findObject.personId = personId; // required
        findObject.begin = begin;
        findObject.end = end;
        List workSchedules = Workschedule.getList(findObject);
        
        // these are the workschedules which apply to the specified person, in the specified period
        Debug.println("--> found "+workSchedules.size()+" workschedules (active in specified period)");
        
        if(workSchedules.size() > 0){
            Workschedule workschedule;
            SalaryCalculation calculation;
        
            // run through schedules, saving a salarycalculation for each day in the specified period 
            // in which the person is expected to work according to the schedule
            for(int i=0; i<workSchedules.size(); i++){
                Debug.println("\n### [Schedule "+i+"] ###################################################");
                
                workschedule = (Workschedule)workSchedules.get(i);
                workschedule.type = Workschedule.getWorkscheduleType(workschedule);
                Debug.println("type : "+workschedule.type);
        
                // for weekSchedules, write down the days in which the employee works (might differ per schedule)
                boolean[] workDays = workschedule.getWorkDays();
                
                Debug.println("\nworkDays : ");
                for(int w=0; w<workDays.length; w++){
                    Debug.println("workDays["+w+"] : "+workDays[w]);
                }
                Debug.println("");

                //*** determine period to create salary calculations for ***
                // period begin
                Calendar periodBegin = Calendar.getInstance();    
                periodBegin.setTime(begin);
                        
                if(workschedule.begin!=null && workschedule.begin.getTime() >= periodBegin.getTime().getTime()){
                    periodBegin.setTime(workschedule.begin);
                    Debug.println("schedule begin : "+ScreenHelper.stdDateFormat.format(workschedule.begin));
                }
                else{
                    // when the schedule has no begin, or a begin before the specified period, use the beginning of specified period
                    Debug.println("schedule has no begin");
                }

                // period end
                Calendar periodEnd = Calendar.getInstance();
                periodEnd.setTime(end);
                
                if(workschedule.end!=null && workschedule.end.getTime() <= periodEnd.getTime().getTime()){
                    periodEnd.setTime(workschedule.end);
                    Debug.println("schedule end : "+ScreenHelper.stdDateFormat.format(workschedule.end));
                }
                else{
                    // when the schedule has no end, or an end after the specified period, use the end of specified period
                    Debug.println("schedule has no end");
                }

                Debug.println("\nperiodBegin : "+ScreenHelper.stdDateFormat.format(periodBegin.getTime()));
                Debug.println("periodEnd   : "+ScreenHelper.stdDateFormat.format(periodEnd.getTime())+"\n");

                //*** create a salarycalculation for each day in the workschedule ***
                java.util.Date tmpDate;            
                while(periodBegin.getTime().getTime() <= periodEnd.getTime().getTime()){
                	tmpDate = periodBegin.getTime();
                    Calendar cal = Calendar.getInstance();
                    cal.setTime(tmpDate);

                    int dayIdx = cal.get(Calendar.DAY_OF_WEEK)-2;
                    if(dayIdx < 0) dayIdx = 6;
                    
                    if(workDays[dayIdx]==false){
                        System.out.println("[INFO] : "+ScreenHelper.stdDateFormat.format(tmpDate)+" [dayIdx "+(dayIdx)+"] is defined by the workschedule, as a day not to work."); /////////
                        periodBegin.add(Calendar.DATE,1); // proceed one day                        
                    }
                    else{
                        System.out.println("###### tmpDate : "+ScreenHelper.stdDateFormat.format(tmpDate)+" [dayIdx "+(dayIdx)+"] ###############"); /////////                
                                       
                        // check existence of calculation
                        calculation = SalaryCalculation.getCalculationOnDate(tmpDate,personId);
                        if(calculation==null){
                        	// create new calculation
                            calculation = new SalaryCalculation();
                            calculation.setUid("-1"); // new
                            
                            calculation.personId = personId;
                            calculation.begin = tmpDate;
                            calculation.end = tmpDate; // same as begin --> one calculation per day
                            String sSalCalUID = calculation.store(activeUser.userid); // first store calculation to obtain UID
                            
                            // add codes
                            float duration = workschedule.getDuration(tmpDate);
                            Debug.println("duration ("+ScreenHelper.stdDateFormat.format(tmpDate)+") : "+duration);
                            
                            calculation.codes = getDefaultWorkscheduleSalaryCodes(sSalCalUID,duration);
                            Debug.println(" Saving "+calculation.codes.size()+" codes");
                            
                            // save calculation
                            calculation.source = "script"; // color differs according to source (purple is 'manual', blue is 'script')
                            calculation.type = "workschedule";
                            calculation.store(activeUser.userid); // save again, the calculation now contains codes
                            
                            calculationsCreated++;   
                        }
                        else{
                            System.out.println(" A calculation on '"+ScreenHelper.stdDateFormat.format(tmpDate)+"' exists, no action taken"); //////////
                            calculationsExisted++;
                        }
                        
                        periodBegin.add(Calendar.DATE,1); // proceed one day                        
                    }
                }            
            }
        }

        Debug.println("--> calculationsCreated : "+calculationsCreated);
        Debug.println("--> calculationsExisted : "+calculationsExisted);
        return new int[]{calculationsCreated,calculationsExisted};
    }

    //--- GET DEFAULT WORKSCHEDULE SALARY CODES ---------------------------------------------------
    private static Vector getDefaultWorkscheduleSalaryCodes(String sSalCalUID, float durationAccordingToSchedule){
        Vector codes = new Vector();
        
        SalaryCalculationCode salCalCode = new SalaryCalculationCode();
        salCalCode.setUid("-1"); // new
        salCalCode.calculationUid = sSalCalUID;
        salCalCode.code = MedwanQuery.getInstance().getConfigString("hr.salarycalculationcode.workday","workday");
        salCalCode.duration = durationAccordingToSchedule;
        codes.add(salCalCode);
        
        return codes;
    }
    
    
    ///////////////////////////////////////////////////////////////////////////////////////////////
    ///////////////////                      FOR LEAVES                            ////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    //--- CREATE SALARY CALCULATIONS FOR LEAVES ---------------------------------------------------
    // for each employee, create a salary calculation for each day he is NOT supposed to work in the 
    // specified period, according to his leave(s).
    public static int[] createSalaryCalculationsForLeaves(java.util.Date periodBegin, 
    		                                              java.util.Date periodEnd,
                                                          User activeUser) throws Exception {        
        // currMonth : begin and end
        Calendar now = Calendar.getInstance();        
        int month = now.get(Calendar.MONTH)+1;
        String sMonth = Integer.toString(month);
        if(month < 10){
            sMonth = "0"+sMonth;
        }
        
        String sCurrMonthBegin = "01/"+sMonth+"/"+now.get(Calendar.YEAR),
               sCurrMonthEnd   = now.getActualMaximum(Calendar.DAY_OF_MONTH)+"/"+sMonth+"/"+now.get(Calendar.YEAR);

        java.util.Date currMonthBegin = ScreenHelper.parseDate(sCurrMonthBegin),
                       currMonthEnd   = ScreenHelper.parseDate(sCurrMonthEnd);

        if(periodBegin==null) periodBegin = currMonthBegin;
        if(periodEnd==null) periodEnd = currMonthEnd;

        Debug.println("\n###############################################################################");
        Debug.println("#################     createSalaryCalculationsForLeaves     ###################");
        Debug.println("###############################################################################");
        Debug.println("periodBegin : "+ScreenHelper.stdDateFormat.format(periodBegin));
        Debug.println("periodEnd   : "+ScreenHelper.stdDateFormat.format(periodEnd));
        
        Vector personIds = new Vector(getEmployeePersonIds().keySet()); 
        Debug.println("personIds   : "+personIds.size());
        
        int personId, counters[];
        int calculationsCreated = 0, calculationsExisted = 0, calculationsOverruled = 0;
        
        for(int i=0; i<personIds.size(); i++){
            personId = ((Integer)personIds.get(i)).intValue();
            
            counters = createSalaryCalculationsForLeavesForPerson(i,personId,periodBegin,periodEnd,activeUser);
            
            calculationsCreated+= counters[0];
            calculationsExisted+= counters[1]; 
            calculationsOverruled+= counters[2];
        }        
        
        return new int[]{calculationsCreated,calculationsExisted,calculationsOverruled};
    }
    
    //--- CREATE SALARY CALCULATIONS FOR LEAVES FOR PERSON ----------------------------------------
    // return : number of calculations created/existing/overruled
    public static int[] createSalaryCalculationsForLeavesForPerson(int personId, java.util.Date begin, 
                                                                   java.util.Date end, User activeUser){
        return createSalaryCalculationsForLeavesForPerson(0,personId,begin,end,activeUser);    	
    }
    
    public static int[] createSalaryCalculationsForLeavesForPerson(int idx, int personId, java.util.Date begin, 
                                                                   java.util.Date end, User activeUser){
        Debug.println("\n***** ["+idx+"] createSalaryCalculationsForLeavesForPerson ********************");
        Debug.println("personId : "+personId);
        Debug.println("begin    : "+ScreenHelper.stdDateFormat.format(begin));
        Debug.println("end      : "+ScreenHelper.stdDateFormat.format(end));
        
        int calculationsCreated = 0, calculationsExisted = 0, calculationsOverruled = 0;
        
        // search leaves : compose object to pass search-criteria with
        Leave findObject = new Leave();
        findObject.personId = personId; // required
        findObject.begin = begin;
        findObject.end = end;
        List leaves = Leave.getList(findObject);
        
        // these are the leaves which apply to the specified person, in the specified period
        Debug.println("--> found "+leaves.size()+" leaves (active in specified period)");
        
        if(leaves.size() > 0){
            Leave leave;
            SalaryCalculation calculation;
            boolean[] workDays = null;
        
            // run through leaves, saving a salary calculation for each day in the specified period 
            // in which the person is expected not to work according to the leave
            for(int i=0; i<leaves.size(); i++){
                Debug.println("\n### [Leave "+i+"] ###################################################");
                
                leave = (Leave)leaves.get(i);
                Debug.println("type : "+leave.type);

                // display workdays according to leave
                if(i==0){
	                workDays = leave.getWorkDays();
	                
	                Debug.println("\nworkDays : ");
	                for(int w=0; w<workDays.length; w++){
	                    Debug.println("workDays["+w+"] : "+workDays[w]);
	                }
	                Debug.println("");
                }
                
                //*** determine period to create salary calculations for ***
                // period begin
                Calendar periodBegin = Calendar.getInstance();    
                periodBegin.setTime(begin);
                        
                if(leave.begin!=null && leave.begin.getTime() >= periodBegin.getTime().getTime()){
                    periodBegin.setTime(leave.begin);
                    Debug.println("leave begin : "+ScreenHelper.stdDateFormat.format(leave.begin));
                }
                else{
                    // when the leave has no begin, or a begin before the specified period, use the beginning of specified period
                    Debug.println("leave has no begin");
                }

                // period end
                Calendar periodEnd = Calendar.getInstance();
                periodEnd.setTime(end);
                
                if(leave.end!=null && leave.end.getTime() <= periodEnd.getTime().getTime()){
                    periodEnd.setTime(leave.end);
                    Debug.println("leave end : "+ScreenHelper.stdDateFormat.format(leave.end));
                }
                else{
                    // when the leave has no end, or an end after the specified period, use the end of specified period
                    Debug.println("leave has no end");
                }

                Debug.println("\nperiodBegin : "+ScreenHelper.stdDateFormat.format(periodBegin.getTime()));
                Debug.println("periodEnd   : "+ScreenHelper.stdDateFormat.format(periodEnd.getTime())+"\n");
                
                String sLeaveDuration = MedwanQuery.getInstance().getConfigString("hr.salarycalculation.leaveduration","7,6");
                sLeaveDuration = sLeaveDuration.replaceAll("\\,",".");
                Debug.println("sLeaveDuration : "+sLeaveDuration+"\n");
                float leaveDuration = Float.parseFloat(sLeaveDuration.replaceAll(",",".")); // hours

                //*** create a salary calculation for each day in the leave ***
                java.util.Date tmpDate;            
                while(periodBegin.getTime().getTime() <= periodEnd.getTime().getTime()){
                	tmpDate = periodBegin.getTime();
                    Calendar cal = Calendar.getInstance();
                    cal.setTime(tmpDate);
                                    
                    int dayIdx = cal.get(Calendar.DAY_OF_WEEK)-2;
                    if(dayIdx < 0) dayIdx = 6;
                    
                    if(workDays[dayIdx]==false){
                        System.out.println("[INFO] : "+ScreenHelper.stdDateFormat.format(tmpDate)+" [dayIdx "+cal.get(dayIdx)+"] is defined by the leave, as a day not to work."); /////////
                        periodBegin.add(Calendar.DATE,1); // proceed one day                        
                    }
                    else{
                        System.out.println("###### tmpDate : "+ScreenHelper.stdDateFormat.format(tmpDate)+" [dayIdx "+cal.get(dayIdx)+"] ###############"); /////////                
                                       
                        // check existence of calculation
                        calculation = SalaryCalculation.getCalculationOnDate(tmpDate,personId);
                        if(calculation==null || calculation.type.equalsIgnoreCase("workschedule")){
                            calculationsCreated++;
                            
                        	if(calculation!=null){
                                calculationsOverruled++;
                                SalaryCalculation.delete(calculation.getUid());
                        	}     
                            
                        	// create new calculation
                            calculation = new SalaryCalculation();
                            calculation.setUid("-1"); // new
                            
                            calculation.personId = personId;
                            calculation.begin = tmpDate;
                            calculation.end = tmpDate; // same as begin --> one calculation per day
                            String sSalCalUID = calculation.store(activeUser.userid); // first store calculation to obtain UID
                            
                            // add codes 
                            calculation.codes = getDefaultLeaveSalaryCodes(sSalCalUID,leaveDuration,leave.type);
                            Debug.println(" Saving "+calculation.codes.size()+" codes");
                            
                            // save calculation
                            calculation.source = "script"; // color differs according to source (purple is 'manual', blue is 'script')
                            calculation.type = "leave";
                            calculation.store(activeUser.userid); // save again, the calculation now contains codes 
                        }
                        else{
                            System.out.println(" A calculation on '"+ScreenHelper.stdDateFormat.format(tmpDate)+"' existed; overruled because not of type 'leave'"); //////////
                            calculationsExisted++;
                        }
                        
                        periodBegin.add(Calendar.DATE,1); // proceed one day                        
                    }
                }            
            }
        }

        Debug.println("--> calculationsCreated   : "+calculationsCreated);
        Debug.println("--> calculationsExisted   : "+calculationsExisted);
        Debug.println("--> calculationsOverruled : "+calculationsOverruled);
        return new int[]{calculationsCreated,calculationsExisted,calculationsOverruled};
    }
    
    //--- GET DEFAULT LEAVE SALARY CODES ----------------------------------------------------------
    private static Vector getDefaultLeaveSalaryCodes(String sSalCalUID, float durationAccordingToLeave, String leaveType){
        Vector codes = new Vector();
        
        SalaryCalculationCode salCalCode = new SalaryCalculationCode();
        salCalCode.setUid("-1"); // new
        salCalCode.calculationUid = sSalCalUID;
        salCalCode.code = MedwanQuery.getInstance().getConfigString("hr.salarycalculationcode."+leaveType,leaveType);
          // hr.salarycalculationcode.illness
          // hr.salarycalculationcode.vacation
        salCalCode.duration = durationAccordingToLeave;
        codes.add(salCalCode);
        
        return codes;
    }
   

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ///////////////////                         VARIA                              ////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////
    
    //--- GET EMPLOYEE PERSON IDS -----------------------------------------------------------------
    // only personnel --> dossiers with category and/or statute
    public static Hashtable getEmployeePersonIds(){
    	Hashtable personIds = new Hashtable();
    
        PreparedStatement ps = null;
        ResultSet rs = null;
        
        Connection conn = MedwanQuery.getInstance().getAdminConnection();
        
        try{
            // compose query
            String sSql = "SELECT DISTINCT(a.personId), searchname FROM admin a, adminextends e"+
            		      " WHERE a.personId = e.personId"+
            	          "  AND (e.labelid = 'category' OR e.labelid = 'statut')"+
            		      "  AND "+MedwanQuery.getInstance().getConfigString("lengthFunction","len")+"(e.extendvalue) > 0";
            ps = conn.prepareStatement(sSql);                       
            rs = ps.executeQuery();
                        
            while(rs.next()){
                personIds.put(rs.getInt("personId"),ScreenHelper.checkString(rs.getString("searchname")));
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
                conn.close();
            }
            catch(SQLException se){
                Debug.printProjectErr(se,Thread.currentThread().getStackTrace());
            }
        }
        
        return personIds;
    }
    
}
