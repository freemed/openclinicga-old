package be.openclinic.hr;

import be.mxs.common.util.db.MedwanQuery;
import be.mxs.common.util.system.Debug;
import be.mxs.common.util.system.ScreenHelper;

import java.util.*;
import java.sql.*;

import net.admin.User;


public class SalaryCalculationManager /*extends OC_Object*/ {
    
    //--- CREATE SALARY CALCULATIONS --------------------------------------------------------------
    // for each employee, create a salarycalculation for each day he is supposed to work in the 
    // specified period, according to his workschedule(s).
    public static int createSalaryCalculations(java.util.Date periodBegin, java.util.Date periodEnd,
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

        java.util.Date currMonthBegin = ScreenHelper.stdDateFormat.parse(sCurrMonthBegin),
                       currMonthEnd   = ScreenHelper.stdDateFormat.parse(sCurrMonthEnd);

        if(periodBegin==null) periodBegin = currMonthBegin;
        if(periodEnd==null) periodEnd = currMonthEnd;

        Debug.println("\n###############################################################################");
        Debug.println("######################     createSalaryCalculations     #######################");
        Debug.println("###############################################################################");
        Debug.println("periodBegin : "+ScreenHelper.stdDateFormat.format(periodBegin));
        Debug.println("periodEnd   : "+ScreenHelper.stdDateFormat.format(periodEnd));
        
        //Vector personIds = /*MedwanQuery.getInstance().*/getPersonIds(); // TODO ooooooooooooooooooooooooooo
        Vector personIds = new Vector();
        personIds.add(new Integer(9967)); // TODO ooooooooooooooooooooooooooooooooooooooooo
        personIds.add(new Integer(9968)); // TODO ooooooooooooooooooooooooooooooooooooooooo
        
        int personId, calculationsCreated = 0;    
        for(int i=0; i<personIds.size(); i++){
            personId = ((Integer)personIds.get(i)).intValue();
            
            calculationsCreated+= createSalaryCalculationsForPerson(personId,periodBegin,periodEnd,activeUser);
        }        
        
        return calculationsCreated;
    }
    
    //--- CREATE SALARY CALCULATIONS FOR PERSON ---------------------------------------------------
    // return : number of calculations created
    public static int createSalaryCalculationsForPerson(int personId, java.util.Date begin, 
                                                        java.util.Date end, User activeUser){
        Debug.println("\n***** createSalaryCalculationsForPerson *****************************");
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
        
                // for weekSchedules, write down the days in which the employee does not work
                boolean[] workDays = workschedule.getWorkDays();
                
                Debug.println("\nworkDays : "); //////////
                for(int w=0; w<workDays.length; w++){
                    Debug.println("workDays["+w+"] : "+workDays[w]);
                }
                Debug.println(""); //////////

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
                java.util.Date currDate;            
                while(periodBegin.getTime().getTime() <= periodEnd.getTime().getTime()){
                    currDate = periodBegin.getTime();
                    Calendar cal = Calendar.getInstance();
                    cal.setTime(currDate);
                                    
                    if(workDays[cal.get(Calendar.DAY_OF_WEEK)-1]==false){
                        System.out.println("[INFO] : "+ScreenHelper.stdDateFormat.format(currDate)+" ["+(cal.get(Calendar.DAY_OF_WEEK)-1)+"] is defined as a day not to work by the workschedule."); /////////
                        periodBegin.add(Calendar.DATE,1); // proceed one day                        
                    }
                    else{
                        System.out.println("###### currDate : "+ScreenHelper.stdDateFormat.format(currDate)+" ["+(cal.get(Calendar.DAY_OF_WEEK)-1)+"] ###############"); /////////                
                        periodBegin.add(Calendar.DATE,1); // proceed one day
                                        
                        // check existence of calculation
                        calculation = SalaryCalculation.getOnDate(currDate);
                        if(calculation==null){
                            calculation = new SalaryCalculation();
                            calculation.setUid("-1"); // new
                            
                            calculation.personId = personId;
                            calculation.begin = currDate;
                            calculation.end = currDate;
                            String sSalCalUID = calculation.store(activeUser.userid); // first store calculation to obtain UID
                            
                            // add codes
                            calculation.codes = getDefaultSalaryCodes(sSalCalUID);
                            Debug.println(" Saving "+calculation.codes.size()+" codes");
                            
                            // save calculation
                            calculation.source = "workschedule"; // color differs according to type (purple is manual, blue is by script)
                            calculation.store(activeUser.userid); // save again, the calculation now contains codes
                            
                            calculationsCreated++;   
                        }
                        else{
                            System.out.println(" A calculation on '"+ScreenHelper.stdDateFormat.format(currDate)+"' exists, no action taken"); //////////
                            calculationsExisted++;
                        }                        
                    }
                }            
            }
        }

        Debug.println("--> calculationsCreated : "+calculationsCreated);
        Debug.println("--> calculationsExisted : "+calculationsExisted);
        return calculationsCreated;
    }
    
    //--- GET PERSON IDS --------------------------------------------------------------------------
    private Vector getPersonIds(){
        Vector personIds = new Vector();

        // TODO : how to obtain these employees ? //////////////////////////////////////////////////////////////// todo    
        PreparedStatement ps = null;
        ResultSet rs = null;
        
        Connection oc_conn = MedwanQuery.getInstance().getOpenclinicConnection();
        
        try{
            // compose query
            String sSql = "SELECT personId FROM OC_PERSONNEL";            
            ps = oc_conn.prepareStatement(sSql);
            
            /*
            // where
            int psIdx = 1;
            ps.setInt(psIdx++,Integer.parseInt(sSalCalUID.substring(0,sSalCalUID.indexOf("."))));
            ps.setInt(psIdx,Integer.parseInt(sSalCalUID.substring(sSalCalUID.indexOf(".")+1)));
            */
            
            rs = ps.executeQuery();
                        
            while(rs.next()){
                personIds.add(rs.getInt("personId"));
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
        
        return personIds;
    }

    //--- GET DEFAULT SALARY CODES ----------------------------------------------------------------
    private static Vector getDefaultSalaryCodes(String sSalCalUID){
        Vector codes = new Vector();

        // TODO : how to obtain these codes ? //////////////////////////////////////////////////////////////// todo        
        SalaryCalculationCode salCalCode = new SalaryCalculationCode();
        salCalCode.setUid("-1"); // new
        salCalCode.calculationUid = sSalCalUID;
        salCalCode.code = "100";
        salCalCode.duration = 5.3f;
        codes.add(salCalCode);
        
        salCalCode = new SalaryCalculationCode();
        salCalCode.setUid("-1"); // new
        salCalCode.calculationUid = sSalCalUID;
        salCalCode.code = "101";
        salCalCode.duration = 2f;
        codes.add(salCalCode);
        
        salCalCode = new SalaryCalculationCode();
        salCalCode.setUid("-1"); // new
        salCalCode.calculationUid = sSalCalUID;
        salCalCode.code = "102";
        salCalCode.duration = 8.1f;
        codes.add(salCalCode);
        
        return codes;
    }
    
}
