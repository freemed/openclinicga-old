package be.openclinic.meals;

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

import net.admin.AdminPerson;


public class Meal extends OC_Object{
    public String name;
    public List mealItems;
    public Date mealDatetime;
    public boolean taken;
    public String patientMealUid;
    
    //--- CONSTRUCTOR(1) ---
    public Meal(){
        this.name = "";
        this.mealItems = new LinkedList();
                
        // set date to now at 7:00
        Calendar cal = Calendar.getInstance();
        cal.set(Calendar.HOUR_OF_DAY,7);
        cal.set(Calendar.MINUTE,0);
        cal.set(Calendar.SECOND,0);
        cal.set(Calendar.MILLISECOND,0);
        this.mealDatetime = cal.getTime();
        
        this.taken = false;
        this.patientMealUid = "";
    }

    //--- CONSTRUCTOR(2) ---
    public Meal(String uid){
        this();
        setUid(uid);
    }

    //--- UPDATE OR INSERT ------------------------------------------------------------------------
    public void updateOrInsert(String useruid){
        PreparedStatement ps = null;
        ResultSet rs = null;
        String sSql;
        String ids[];
        
        Connection oc_conn = MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            ids = this.getUid().split("\\.");
            
            if(getUid().equals("-1")){
                // insert
                sSql = "INSERT INTO OC_MEAL(OC_MEAL_SERVERID, OC_MEAL_OBJECTID,"+
                       "  OC_MEAL_NAME,OC_MEAL_CREATETIME,OC_MEAL_UPDATEUID)"+
                       " VALUES(?,?,?,?,?)";
                Debug.println(sSql);
                ps = oc_conn.prepareStatement(sSql);
                
                ids = new String[]{MedwanQuery.getInstance().getConfigString("serverId"),
                		           MedwanQuery.getInstance().getOpenclinicCounter("OC_MEAL")+""};
                ps.setInt(1,Integer.parseInt(ids[0]));
                ps.setInt(2,Integer.parseInt(ids[1]));
                ps.setString(3,this.name);
                ps.setTimestamp(4,new Timestamp(new java.util.Date().getTime())); // now
                ps.setString(5,useruid);
                
                this.setUid(ids[0]+"."+ids[1]);
                ps.executeUpdate();
            }
            else{
            	// update
                sSql = "UPDATE OC_MEAL SET OC_MEAL_NAME=?, OC_MEAL_UPDATETIME=?, OC_MEAL_UPDATEUID=?"+
                       " WHERE OC_MEAL_SERVERID = ? AND OC_MEAL_OBJECTID = ?";
                Debug.println(sSql);
                ps = oc_conn.prepareStatement(sSql);
                ps.setString(1,this.name);
                ps.setTimestamp(2,new Timestamp(new java.util.Date().getTime())); // now
                ps.setString(3,useruid);
                ps.setInt(4,Integer.parseInt(ids[0]));
                ps.setInt(5,Integer.parseInt(ids[1]));
                ps.executeUpdate();
            }
            
            setMealItems(useruid);
        } 
        catch(Exception e){
            Debug.printStackTrace(e);
        }
        finally{
            try{
                if(rs!=null) rs.close();
                if(ps!=null) ps.close();
                oc_conn.close();
            }
            catch(SQLException e){
                Debug.printStackTrace(e);
            }
        }
    }
    
    //--- SET MEAL ITEMS --------------------------------------------------------------------------
    public void setMealItems(String useruid){
        deleteAllMealItemsFromMeal();
        
        if(this.mealItems!=null && this.mealItems.size() > 0){
            PreparedStatement ps = null;
            ResultSet rs = null;
            
            Iterator iter = this.mealItems.iterator();
            while(iter.hasNext()){
                MealItem mealitem =(MealItem)iter.next();
                
                // insert mealitem
                Connection oc_conn = MedwanQuery.getInstance().getOpenclinicConnection();
                try{
                    String sSql = "INSERT INTO OC_MEAL_COMPONENT(OC_MEALUID, OC_MEAL_ITEMUID,"+
                                  "  OC_MEAL_ITEMQUANTITY,OC_MEAL_COMPONENT_CREATETIME,OC_MEAL_COMPONENT_UPDATEUID)"+
                                  " VALUES(?,?,?,?,?)";
                    Debug.println(sSql);
                    ps = oc_conn.prepareStatement(sSql);
                    
                    ps.setString(1,this.getUid());
                    ps.setString(2,mealitem.getUid());
                    ps.setFloat(3,mealitem.quantity);
                    ps.setTimestamp(4,new Timestamp(new java.util.Date().getTime())); // now
                    ps.setString(5,useruid);
                    ps.executeUpdate();
                } 
                catch(Exception e){
                    Debug.printStackTrace(e);
                }
                finally{
                    try{
                        if(rs!=null) rs.close();
                        if(ps!=null) ps.close();
                        oc_conn.close();
                    }
                    catch(SQLException e){
                        Debug.printStackTrace(e);
                    }
                }
            }
        }
    }
    
    //--- DELETE ALL MEAL ITEMS FROM MEAL ---------------------------------------------------------
    public void deleteAllMealItemsFromMeal(){
        PreparedStatement ps = null;
        ResultSet rs = null;
        
        Connection oc_conn = MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            String sSql = "DELETE FROM OC_MEAL_COMPONENT"+
                          " WHERE OC_MEALUID = ?";
            Debug.println(sSql);
            ps = oc_conn.prepareStatement(sSql);
            ps.setString(1, this.getUid());
            ps.executeUpdate();
        }
        catch(Exception e){
            Debug.printStackTrace(e);
        }
        finally{
            try{
                if(rs!=null) rs.close();
                if(ps!=null) ps.close();
                oc_conn.close();
            }
            catch(SQLException e){
                Debug.printStackTrace(e);
            }
        }
    }
    
    //--- DELETE ----------------------------------------------------------------------------------
    public void delete(){
        deleteAllMealItemsFromMeal();
        
        PreparedStatement ps = null;
        ResultSet rs = null;
        
        Connection oc_conn = MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            String sSql = "DELETE FROM OC_MEAL"+
                          " WHERE OC_MEAL_SERVERID = ? AND OC_MEAL_OBJECTID = ?";
            Debug.println(sSql);
            ps = oc_conn.prepareStatement(sSql);
            ps.setInt(1,Integer.parseInt(getUid().substring(0,getUid().indexOf("."))));
            ps.setInt(2,Integer.parseInt(getUid().substring(getUid().indexOf(".")+1)));
            ps.executeUpdate();
        }
        catch(Exception e){
            Debug.printStackTrace(e);
        }
        finally{
            try{
                if(rs!=null) rs.close();
                if(ps!=null) ps.close();
                oc_conn.close();
            }
            catch(SQLException e){
                Debug.printStackTrace(e);
            }
        }
    }
    
    //--- GET -------------------------------------------------------------------------------------
    public static Meal get(Meal meal){
        PreparedStatement ps = null;
        ResultSet rs = null;
        
        Connection oc_conn = MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            String sSql = "SELECT * FROM OC_MEAL"+
                          " WHERE OC_MEAL_SERVERID = ? AND OC_MEAL_OBJECTID = ?";
            Debug.println(sSql);
            ps = oc_conn.prepareStatement(sSql);
            ps.setInt(1,Integer.parseInt(meal.getUid().substring(0,meal.getUid().indexOf("."))));
            ps.setInt(2,Integer.parseInt(meal.getUid().substring(meal.getUid().indexOf(".")+1)));

            rs = ps.executeQuery();
            if(rs.next()){
            	meal.name = rs.getString("OC_MEAL_NAME");
            	meal = importMealItems(meal);
            }
        } 
        catch(Exception e){
            Debug.printStackTrace(e);
        }
        finally{
            try{
                if(rs!=null) rs.close();
                if(ps!=null) ps.close();
                oc_conn.close();
            }
            catch(SQLException e){
                Debug.printStackTrace(e);
            }
        }
        
        return meal;
    }
    
    //--- IMPORT MEAL ITEMS -----------------------------------------------------------------------
    public static Meal importMealItems(Meal meal){
        PreparedStatement ps = null;
        ResultSet rs = null;
        
        Connection oc_conn = MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            String sSql = "SELECT * FROM OC_MEAL_COMPONENT WHERE OC_MEALUID = ?";
            Debug.println(sSql);
            ps = oc_conn.prepareStatement(sSql);
            ps.setString(1,meal.getUid());
            meal.mealItems = new LinkedList();
            
            rs = ps.executeQuery();
            MealItem mealitem = null;
            while(rs.next()){
                mealitem = new MealItem(rs.getString("OC_MEAL_ITEMUID"));
                mealitem = MealItem.get(mealitem);
                
                if(mealitem!=null){
                    mealitem.quantity = rs.getFloat("OC_MEAL_ITEMQUANTITY");
                    meal.mealItems.add(mealitem);
                }
            }
        } 
        catch(Exception e){
            Debug.printStackTrace(e);
        }
        finally{
            try{
                if(rs!=null) rs.close();
                if(ps!=null) ps.close();
                oc_conn.close();
            }
            catch(SQLException e){
                Debug.printStackTrace(e);
            }
        }
        
        return meal;
    }
    
    //--- GET LIST --------------------------------------------------------------------------------
    public static List getList(Meal findItem){
        List foundObjects = new LinkedList();
        PreparedStatement ps = null;
        ResultSet rs = null;
        
        Connection oc_conn = MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            String sSql = "SELECT * FROM OC_MEAL";
            if(findItem.name!=null && findItem.name.trim().length() > 0){
                if(findItem.name.length()==1){
                    sSql+= " WHERE OC_MEAL_NAME LIKE '"+findItem.name+"%'"; // search from begin
            	}
            	else{
                    sSql+= " WHERE OC_MEAL_NAME LIKE '%"+findItem.name+"%'";
            	}
            }
            sSql+= " ORDER BY OC_MEAL_NAME";
            Debug.println(sSql);
            ps = oc_conn.prepareStatement(sSql);
            
            // execute
            rs = ps.executeQuery();
            while(rs.next()){
                Meal meal = new Meal();
                meal.setUid(rs.getString("OC_MEAL_SERVERID")+"."+rs.getString("OC_MEAL_OBJECTID"));
                meal.name = rs.getString("OC_MEAL_NAME");                
                meal = importMealItems(meal);
                                
                foundObjects.add(meal);
            }
        }
        catch(Exception e){
            Debug.printStackTrace(e);
        }
        finally{
            try{
                if(rs!=null) rs.close();
                if(ps!=null) ps.close();
                oc_conn.close();
            }
            catch(SQLException e){
                Debug.printStackTrace(e);
            }
        }
        
        return foundObjects;
    }
    
    //--- GET PATIENT MEALS -----------------------------------------------------------------------
    public static List getPatientMeals(AdminPerson patient, String sDate, Meal meal){
        List foundObjects = new LinkedList();
        PreparedStatement ps = null;
        ResultSet rs = null;
        
        Connection oc_conn = MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            String sSql = "SELECT * FROM OC_MEAL m, OC_PATIENT_MEALS p"+
                          " WHERE p.OC_PM_MEALUID = "+MedwanQuery.getInstance().convert("varchar(10)","m.OC_MEAL_SERVERID")+MedwanQuery.getInstance().concatSign()+ "'.'"+ MedwanQuery.getInstance().concatSign()+ MedwanQuery.getInstance().convert("varchar(10)","m.OC_MEAL_OBJECTID");
            sSql+= " AND OC_PM_PATIENTUID = ? AND p.OC_PM_DATETIME >= ? AND p.OC_PM_DATETIME < ?";
            if(meal!=null){
                sSql+= " AND p.OC_PM_MEALUID = ?";
            }
            sSql+= " ORDER BY p.OC_PM_DATETIME";
            Debug.println(sSql);
            
            ps = oc_conn.prepareStatement(sSql);
            ps.setString(1,patient.personid);
            ps.setDate(2,ScreenHelper.getSQLDate(sDate));
            ps.setDate(3,ScreenHelper.getSQLDate(ScreenHelper.getDateAdd(sDate,"1")));
            if(meal!=null){
                ps.setString(4,meal.getUid());
            }
            
            // execute
            rs = ps.executeQuery();
            while(rs.next()){
                Meal item = new Meal();
                item.setUid(rs.getString("OC_MEAL_SERVERID")+"."+rs.getString("OC_MEAL_OBJECTID"));
                item.name = rs.getString("OC_MEAL_NAME");
                item.mealDatetime = rs.getTime("OC_PM_DATETIME");
                item.taken = rs.getString("OC_PM_TAKEN").equals("1");
                item.patientMealUid = rs.getString("OC_PM_SERVERID")+"."+rs.getString("OC_PM_OBJECTID");
                
                foundObjects.add(item);
            }
        }
        catch(Exception e){
            Debug.printStackTrace(e);
        }
        finally{
            try{
                if(rs!=null) rs.close();
                if(ps!=null) ps.close();
                oc_conn.close();
            }
            catch(SQLException e){
                Debug.printStackTrace(e);
            }
        }
        
        return foundObjects;
    }
   
    //--- INSERT PATIENT PROFILE ------------------------------------------------------------------
    public static void insertPatientProfile(List mealProfiles, AdminPerson patient, String userUid){
        Iterator iter = mealProfiles.iterator();
        while(iter.hasNext()){
            MealProfile mealProfile = (MealProfile)iter.next();
            Meal meal = new Meal(mealProfile.mealUid);
            meal.patientMealUid = "-1";
            
            meal.insertOrUpdatePatientMeal(patient,null,null,userUid,false,mealProfile.mealDatetime);
        }
    }
    
    //--- INSERT OR UPDATE PATIENT MEAL -----------------------------------------------------------
    public void insertOrUpdatePatientMeal(AdminPerson patient, String sDate, String time, String userUid,
    		                              boolean mealTaken, Date dDate){
        PreparedStatement ps = null;
        ResultSet rs = null;
        String sSql;
        String ids[];
        
        Connection oc_conn = MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            if(sDate==null && dDate!=null){
                sDate = ScreenHelper.formatDate(dDate);
            }
            
            if(this.patientMealUid.equals("-1")){
                sSql = "INSERT INTO OC_PATIENT_MEALS(OC_PM_SERVERID,OC_PM_OBJECTID,OC_PM_PATIENTUID,"+
                       " OC_PM_MEALUID,OC_PM_TAKEN,OC_PM_DATETIME,OC_PM_CREATETIME,OC_PM_UPDATEUID)"+
                	   "  VALUES(?,?,?,?,?,?,?,?)";
                Debug.println(sSql);
                ps = oc_conn.prepareStatement(sSql);
                ids = new String[]{MedwanQuery.getInstance().getConfigString("serverId"),
                		           MedwanQuery.getInstance().getOpenclinicCounter("OC_PATIENT_MEAL")+""};
                ps.setInt(1,Integer.parseInt(ids[0]));
                ps.setInt(2,Integer.parseInt(ids[1]));
                ps.setString(3,patient.personid);
                ps.setString(4,this.getUid());
                ps.setString(5,(mealTaken?"1":"0"));
                if(dDate==null){
                    ScreenHelper.getSQLTimestamp(ps,6,sDate,time);
                } 
                else{
                    ps.setTimestamp(6,new Timestamp(dDate.getTime())); // now
                }
                ps.setTimestamp(7,new Timestamp(new java.util.Date().getTime())); // now
                ps.setString(8,userUid);
                ps.executeUpdate();
            }
            else{
                ids = this.patientMealUid.split("\\.");
                
                sSql = "UPDATE OC_PATIENT_MEALS SET"+
                       "  OC_PM_DATETIME = ?, OC_PM_TAKEN = ?, OC_PM_UPDATETIME =?, OC_PM_UPDATEUID = ?"+
                       " WHERE OC_PM_SERVERID = ? AND OC_PM_OBJECTID = ?";
                Debug.println(sSql);
                ps = oc_conn.prepareStatement(sSql);
                if(dDate==null){
                    ScreenHelper.getSQLTimestamp(ps,1,sDate,time);
                }
                else{
                    ps.setTimestamp(1,new Timestamp(dDate.getTime())); // now
                }
                ps.setString(2,(mealTaken?"1":"0"));
                ps.setTimestamp(3,new Timestamp(new java.util.Date().getTime())); // now
                ps.setString(4,this.getUid());
                ps.setInt(5,Integer.parseInt(ids[0]));
                ps.setInt(6,Integer.parseInt(ids[1]));
               
                ps.executeUpdate();
            }
        }
        catch(Exception e){
            Debug.printStackTrace(e);
        }
        finally{
            try{
                if(rs!=null) rs.close();
                if(ps!=null) ps.close();
                oc_conn.close();
            }
            catch(SQLException e){
                Debug.printStackTrace(e);
            }
        }
    }
    
    //--- UPDATE MEAL TAKEN -----------------------------------------------------------------------
    public void updateMealTaken(String userUid, boolean mealTaken){
        PreparedStatement ps = null;
        ResultSet rs = null;
        
        Connection oc_conn = MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            String sSql = "UPDATE OC_PATIENT_MEALS SET"+
                          " OC_PM_TAKEN = ?, OC_PM_UPDATETIME =?, OC_PM_UPDATEUID = ?"+
                          "  WHERE OC_PM_SERVERID = ? AND OC_PM_OBJECTID = ?";
            Debug.println(sSql);
            ps = oc_conn.prepareStatement(sSql);
            ps.setString(1,(mealTaken?"1":"0"));
            ps.setTimestamp(2,new Timestamp(new java.util.Date().getTime())); // now
            ps.setString(3,userUid);
            ps.setInt(4,Integer.parseInt(this.patientMealUid.substring(0, getUid().indexOf("."))));
            ps.setInt(5,Integer.parseInt(this.patientMealUid.substring(getUid().indexOf(".")+ 1)));
            ps.executeUpdate();
        }
        catch(Exception e){
            Debug.printStackTrace(e);
        }
        finally{
            try{
                if(rs!=null) rs.close();
                if(ps!=null) ps.close();
                oc_conn.close();
            }
            catch(SQLException e){
                Debug.printStackTrace(e);
            }
        }
    }
    
    //--- DELETE MEAL FROM PATIENT ----------------------------------------------------------------
    public void deleteMealFromPatient(){
        PreparedStatement ps = null;
        ResultSet rs = null;
        
        Connection oc_conn = MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            String sSql = "DELETE FROM OC_PATIENT_MEALS"+
                          " WHERE OC_PM_SERVERID = ? AND OC_PM_OBJECTID = ?";
            Debug.println(sSql);
            ps = oc_conn.prepareStatement(sSql);
            ps.setInt(1,Integer.parseInt(getUid().substring(0,getUid().indexOf("."))));
            ps.setInt(2,Integer.parseInt(getUid().substring(getUid().indexOf(".")+1)));
            ps.executeUpdate();
        }
        catch(Exception e){
            Debug.printStackTrace(e);
        }
        finally{
            try{
                if(rs!=null) rs.close();
                if(ps!=null) ps.close();
                oc_conn.close();
            }
            catch(SQLException e){
                Debug.printStackTrace(e);
            }
        }
    }
 
}