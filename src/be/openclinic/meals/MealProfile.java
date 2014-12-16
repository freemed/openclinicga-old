package be.openclinic.meals;

import be.openclinic.common.OC_Object;
import be.mxs.common.util.db.MedwanQuery;
import be.mxs.common.util.system.Debug;
import be.mxs.common.util.system.ScreenHelper;

import java.util.Date;
import java.util.List;
import java.util.Iterator;
import java.util.LinkedList;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Timestamp;
import java.sql.SQLException;

public class MealProfile extends OC_Object{
    public String name;
    public String mealUid;
    public Date mealDatetime;
    public String mealName;

    //--- CONSTRUCTOR (1) ---
    public MealProfile(){
        this.name = "";
        this.mealUid = "";
        this.mealDatetime = null;
        this.mealName = "";
        
        setUid("-1");
    }
   
    //--- CONSTRUCTOR (2) ---
    public MealProfile(String uid){
    	this();
        setUid(uid);
    }
    
    //--- GET PROFILE MEALS -----------------------------------------------------------------------
    public List getProfileMeals(){
        List profileMeals = new LinkedList();
        PreparedStatement ps = null;
        ResultSet rs = null;
        
        Connection conn = MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            if(!this.getUid().equals("-1")){
                String sSql = "SELECT * FROM OC_MEAL_PROFILES p, OC_MEAL m"+
                              " WHERE p.OC_MEAL_PROFILES_SERVERID = ? AND p.OC_MEAL_PROFILES_OBJECTID = ?"+
                              "  AND p.OC_MEAL_PROFILES_MEALUID = "+MedwanQuery.getInstance().convert("varchar(10)","m.OC_MEAL_SERVERID")+MedwanQuery.getInstance().concatSign()+"'.'"+MedwanQuery.getInstance().concatSign()+ MedwanQuery.getInstance().convert("varchar(10)","m.OC_MEAL_OBJECTID");
                sSql+= " ORDER BY p.OC_MEAL_PROFILES_DATETIME";
                Debug.println(sSql);
                ps = conn.prepareStatement(sSql);
                ps.setInt(1,Integer.parseInt(this.getUid().substring(0,this.getUid().indexOf("."))));
                ps.setInt(2,Integer.parseInt(this.getUid().substring(this.getUid().indexOf(".")+1)));

                MealProfile profile;
                rs = ps.executeQuery();
                while(rs.next()){
                    profile = new MealProfile(this.getUid());
                    
                    profile.name = rs.getString("OC_MEAL_PROFILES_NAME");
                    profile.mealUid = rs.getString("OC_MEAL_PROFILES_MEALUID");
                    profile.mealDatetime = rs.getTimestamp("OC_MEAL_PROFILES_DATETIME");
                    profile.mealName = rs.getString("OC_MEAL_NAME");
                    
                    profileMeals.add(profile);
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
                conn.close();
            }
            catch(SQLException e){
                Debug.printStackTrace(e);
            }
        }
        
        return profileMeals;
    }
    
    //--- UPDATE OR INSERT ------------------------------------------------------------------------
    public static void updateOrInsert(List profiles, String useruid){        
        if(profiles!=null && profiles.size() > 0){
            PreparedStatement ps = null;
            ResultSet rs = null;

            Connection conn = MedwanQuery.getInstance().getOpenclinicConnection();
            try{
                MealProfile.delete(((MealProfile)profiles.get(0)).getUid());
                
                String[] ids = new String[]{MedwanQuery.getInstance().getConfigString("serverId"),
                		                    MedwanQuery.getInstance().getOpenclinicCounter("OC_MEALPROFILE")+""};
                
                MealProfile profile;
                Iterator iter = profiles.iterator();
                while(iter.hasNext()){
                    profile =(MealProfile)iter.next();
                    
                    String sSql = "INSERT INTO OC_MEAL_PROFILES(OC_MEAL_PROFILES_SERVERID,OC_MEAL_PROFILES_OBJECTID,"+
                                  "  OC_MEAL_PROFILES_NAME,OC_MEAL_PROFILES_MEALUID,OC_MEAL_PROFILES_DATETIME,"+
                                  "  OC_MEAL_PROFILES_CREATETIME,OC_MEAL_PROFILES_UPDATEUID)"+
                                  " VALUES(?,?,?,?,?,?,?)";
                    Debug.println(sSql);
                    ps = conn.prepareStatement(sSql);

                    ps.setInt(1,Integer.parseInt(ids[0]));
                    ps.setInt(2,Integer.parseInt(ids[1]));
                    ps.setString(3,profile.name);
                    ps.setString(4,profile.mealUid);
                    ps.setTimestamp(5,new Timestamp((profile.mealDatetime.getTime())));
                    ps.setTimestamp(6,new Timestamp(new java.util.Date().getTime())); // now
                    ps.setString(7,useruid);
                    
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
                    conn.close();
                }
                catch(SQLException e){
                    Debug.printStackTrace(e);
                }
            }
        }
    }
    
    //--- GET PROFILE -----------------------------------------------------------------------------
    public static MealProfile getProfile(String sUID){
    	MealProfile profile = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        
        Connection conn = MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            String sSql = "SELECT * FROM OC_MEAL_PROFILES"+
                          " WHERE OC_MEAL_PROFILES_SERVERID = ? AND OC_MEAL_PROFILES_OBJECTID = ?";
            Debug.println(sSql);
            ps = conn.prepareStatement(sSql);
            ps.setInt(1,Integer.parseInt(sUID.substring(0,sUID.indexOf("."))));
            ps.setInt(2,Integer.parseInt(sUID.substring(sUID.indexOf(".")+1)));
            
            rs = ps.executeQuery();
            if(rs.next()){
                profile = new MealProfile(sUID);    
                
                profile.name = rs.getString("OC_MEAL_PROFILES_NAME");
                profile.mealUid = rs.getString("OC_MEAL_PROFILES_MEALUID");
                profile.mealDatetime = rs.getTimestamp("OC_MEAL_PROFILES_DATETIME");
            }
        } 
        catch(Exception e){
            Debug.printStackTrace(e);
        }
        finally{
            try{
                if(rs!=null) rs.close();
                if(ps!=null) ps.close();
                conn.close();
            }
            catch(SQLException e){
                Debug.printStackTrace(e);
            }
        }
        
        return profile;
    }
    
    //--- GET PROFILES ----------------------------------------------------------------------------
    public static List getProfiles(String sName){
        List profiles = new LinkedList();
        PreparedStatement ps = null;
        ResultSet rs = null;
        
        Connection conn = MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            String sSql = "SELECT * FROM OC_MEAL_PROFILES";
            if(sName!=null && sName.trim().length() > 0){
                sSql+= " WHERE OC_MEAL_PROFILES_NAME LIKE '%"+sName+"%'";
            }
            sSql+= " ORDER BY OC_MEAL_PROFILES_NAME";
            Debug.println(sSql);
            ps = conn.prepareStatement(sSql);

            rs = ps.executeQuery();
            String tmpUid = "", uid = "";
            while(rs.next()){
                tmpUid = rs.getString("OC_MEAL_PROFILES_SERVERID")+"."+rs.getString("OC_MEAL_PROFILES_OBJECTID");
                
                // only get the unique profiles (data is duplicated over meal_profile records with same profile name)
                if(!tmpUid.equals(uid)){
                    MealProfile profile = new MealProfile(tmpUid);
                    profile.name = ScreenHelper.checkString(rs.getString("OC_MEAL_PROFILES_NAME"));
                    profile.mealUid = ScreenHelper.checkString(rs.getString("OC_MEAL_PROFILES_MEALUID"));
                    
                    // get linked meal
                    Meal tmpMeal = new Meal();
                    tmpMeal.setUid(profile.mealUid);
                    
                    Meal meal = Meal.get(tmpMeal);
                    if(meal!=null){
                        profile.mealName = meal.name;
                    }
                    
                    if(rs.getTimestamp("OC_MEAL_PROFILES_DATETIME")!=null){
                        profile.mealDatetime = new java.util.Date(rs.getTimestamp("OC_MEAL_PROFILES_DATETIME").getTime());                        
                    }
                         
                    profiles.add(profile);
                    uid = tmpUid;
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
                conn.close();
            }
            catch(SQLException e){
                Debug.printStackTrace(e);
            }
        }
        
        return profiles;
    }
    
    //--- GET PROFILE MEALS -----------------------------------------------------------------------
    // OC_MEAL_PROFILES_NAME, OC_MEAL_PROFILES_MEALUID, OC_MEAL_PROFILES_DATETIME, OC_MEAL_PROFILES_OBJECTID, OC_MEAL_PROFILES_SERVERID, OC_MEAL_PROFILES_CREATETIME, OC_MEAL_PROFILES_UPDATETIME, OC_MEAL_PROFILES_UPDATEUID
    //
    //   'post-operatie', '2.3', '2014-12-15 13:00:17', 13, 2, '2014-12-15 16:02:17', '', '4'
    //   'post-operatie', '2.2', '2014-12-15 18:00:17', 13, 2, '2014-12-15 16:02:17', '', '4'
    //   'pre-operatie', '2.2', '2014-12-15 06:00:40', 14, 2, '2014-12-15 16:02:40', '', '4'
    //
    public static List getProfileMeals(String sName){
        List profiles = new LinkedList();
        PreparedStatement ps = null;
        ResultSet rs = null;
        
        Connection conn = MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            String sSql = "SELECT * FROM OC_MEAL_PROFILES";
            if(sName!=null && sName.trim().length() > 0){
                sSql+= " WHERE OC_MEAL_PROFILES_NAME LIKE '%"+sName+"%'";
            }
            sSql+= " ORDER BY OC_MEAL_PROFILES_NAME";
            Debug.println(sSql);
            ps = conn.prepareStatement(sSql);

            String tmpUid;
            rs = ps.executeQuery();
            while(rs.next()){
                tmpUid = rs.getString("OC_MEAL_PROFILES_SERVERID")+"."+rs.getString("OC_MEAL_PROFILES_OBJECTID");
                
                MealProfile profile = new MealProfile(tmpUid);
                profile.name = ScreenHelper.checkString(rs.getString("OC_MEAL_PROFILES_NAME"));
                profile.mealUid = ScreenHelper.checkString(rs.getString("OC_MEAL_PROFILES_MEALUID"));
                
                // get linked meal
                Meal tmpMeal = new Meal();
                tmpMeal.setUid(profile.mealUid);
                
                Meal meal = Meal.get(tmpMeal);
                if(meal!=null){
                    profile.mealName = meal.name;
                }
                
                if(rs.getTimestamp("OC_MEAL_PROFILES_DATETIME")!=null){
                    profile.mealDatetime = new java.util.Date(rs.getTimestamp("OC_MEAL_PROFILES_DATETIME").getTime());                        
                }
                     
                profiles.add(profile);
            }
        } 
        catch(Exception e){
            Debug.printStackTrace(e);
        }
        finally{
            try{
                if(rs!=null) rs.close();
                if(ps!=null) ps.close();
                conn.close();
            }
            catch(SQLException e){
                Debug.printStackTrace(e);
            }
        }
        
        return profiles;
    }
    
    //--- DELETE ----------------------------------------------------------------------------------
    public static void delete(String uid){
        PreparedStatement ps = null;
        ResultSet rs = null;
        
        Connection conn = MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            if(uid!=null && !uid.equals("-1")){
                String sSql = "DELETE FROM OC_MEAL_PROFILES"+
                              " WHERE OC_MEAL_PROFILES_SERVERID = ? AND OC_MEAL_PROFILES_OBJECTID = ?";
                ps = conn.prepareStatement(sSql);
                ps.setInt(1,Integer.parseInt(uid.substring(0,uid.indexOf("."))));
                ps.setInt(2,Integer.parseInt(uid.substring(uid.indexOf(".")+1)));
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
                conn.close();
            }
            catch(SQLException e){
                Debug.printStackTrace(e);
            }
        }
    }

}