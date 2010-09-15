package be.openclinic.meals;
import be.openclinic.common.OC_Object;
import be.mxs.common.util.db.MedwanQuery;
import be.mxs.common.util.system.Debug;
import java.util.Date;
import java.util.List;
import java.util.Iterator;
import java.util.LinkedList;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Timestamp;
import java.sql.SQLException;
public class MealProfil extends OC_Object {
    public String name;
    public String mealUid;
    public Date mealDatetime;
    public String mealName;
    public MealProfil(String uid) {
        setUid(uid);
        this.name = "";
        this.mealUid = "";
        this.mealDatetime = null;
        this.mealName = "";
    }
    public List getMealProfil(){
         List foundObjects = new LinkedList();
           PreparedStatement ps = null;
        ResultSet rs = null;
        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try {
            if(!this.getUid().equals("-1")){
                String sSelect = "SELECT * FROM OC_MEAL_PROFILES p,OC_MEAL m WHERE p.OC_MEAL_PROFILES_SERVERID = ? AND p.OC_MEAL_PROFILES_OBJECTID = ?";
                sSelect+=" AND p.OC_MEAL_PROFILES_MEALUID="+ MedwanQuery.getInstance().convert("varchar(10)","m.OC_MEAL_SERVERID")+MedwanQuery.getInstance().concatSign()+"'.'"+MedwanQuery.getInstance().concatSign()+ MedwanQuery.getInstance().convert("varchar(10)","m.OC_MEAL_OBJECTID");

                sSelect += " ORDER BY p.OC_MEAL_PROFILES_DATETIME";
                ps = oc_conn.prepareStatement(sSelect);
                ps.setInt(1, Integer.parseInt(this.getUid().substring(0, this.getUid().indexOf("."))));
                ps.setInt(2, Integer.parseInt(this.getUid().substring(this.getUid().indexOf(".") + 1)));
                // execute
                rs = ps.executeQuery();

                while (rs.next()) {

                        MealProfil item = new MealProfil(this.getUid());
                        item.name = rs.getString("OC_MEAL_PROFILES_NAME");
                        item.mealUid = rs.getString("OC_MEAL_PROFILES_MEALUID");
                        item.mealDatetime = rs.getTimestamp("OC_MEAL_PROFILES_DATETIME");
                        item.mealName = rs.getString("OC_MEAL_NAME");
                        foundObjects.add(item);

                }
            }
        } catch (Exception e) {
            Debug.printProjectErr(e, Thread.currentThread().getStackTrace());
        }
        finally {
            try {
                if (rs != null) rs.close();
                if (ps != null) ps.close();
                oc_conn.close();
            }
            catch (SQLException se) {
                Debug.printProjectErr(se, Thread.currentThread().getStackTrace());
            }
        }
        return foundObjects;

    }
    public static void updateOrInsert(List mealProfiles, String useruid) {
        PreparedStatement ps = null;
        ResultSet rs = null;
        String sSelect;
        String ids[];
        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try {
            if (mealProfiles != null && mealProfiles.size() > 0) {
                MealProfil.delete(((MealProfil)mealProfiles.get(0)).getUid());
                ids = new String[]{MedwanQuery.getInstance().getConfigString("serverId"), MedwanQuery.getInstance().getOpenclinicCounter("OC_MEALPROFILE") + ""};
                Iterator it = mealProfiles.iterator();
                while (it.hasNext()) {
                    MealProfil profil = (MealProfil) it.next();
                    // insert new meal
                    sSelect = "INSERT INTO OC_MEAL_PROFILES (OC_MEAL_PROFILES_SERVERID,OC_MEAL_PROFILES_OBJECTID,OC_MEAL_PROFILES_NAME, OC_MEAL_PROFILES_MEALUID," +
                            "  OC_MEAL_PROFILES_DATETIME,OC_MEAL_PROFILES_CREATETIME,OC_MEAL_PROFILES_UPDATEUID)" +
                            " VALUES(?,?,?,?,?,?,?)";
                    ps = oc_conn.prepareStatement(sSelect);
                    // OBJECT variables
                    ps.setInt(1, Integer.parseInt(ids[0]));
                    ps.setInt(2, Integer.parseInt(ids[1]));
                    ps.setString(3, profil.name);
                    ps.setString(4, profil.mealUid);
                    ps.setTimestamp(5, new Timestamp((profil.mealDatetime.getTime())));
                    ps.setTimestamp(6, new Timestamp(new java.util.Date().getTime())); // now
                    ps.setString(7, useruid);
                    ps.executeUpdate();
                }
            }
        } catch (Exception e) {
            Debug.printProjectErr(e, Thread.currentThread().getStackTrace());
        }
        finally {
            try {
                if (rs != null) rs.close();
                if (ps != null) ps.close();
                oc_conn.close();
            }
            catch (SQLException se) {
                Debug.printProjectErr(se, Thread.currentThread().getStackTrace());
            }
        }
    }
    public static List getMeals(String findName) {
        List foundObjects = new LinkedList();
           PreparedStatement ps = null;
        ResultSet rs = null;
        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try {
            String sSelect = "SELECT * FROM OC_MEAL_PROFILES WHERE 1=1";
            if (findName != null && findName.trim().length() > 0) {
                sSelect += " AND OC_MEAL_PROFILES_NAME LIKE '%" + findName + "%'";
            }
            sSelect += " ORDER BY OC_MEAL_PROFILES_NAME";
            ps = oc_conn.prepareStatement(sSelect);
            // execute
            rs = ps.executeQuery();
            String tmpUid = "";
            String uid = "";
            while (rs.next()) {
                tmpUid = rs.getString("OC_MEAL_PROFILES_SERVERID") + "." + rs.getString("OC_MEAL_PROFILES_OBJECTID");
                if(!tmpUid.equals(uid)){
                    MealProfil item = new MealProfil(tmpUid);
                    item.name = rs.getString("OC_MEAL_PROFILES_NAME");
                    item.mealUid = rs.getString("OC_MEAL_PROFILES_MEALUID");
                    foundObjects.add(item);
                    uid = tmpUid;
                }
            }
        } catch (Exception e) {
            Debug.printProjectErr(e, Thread.currentThread().getStackTrace());
        }
        finally {
            try {
                if (rs != null) rs.close();
                if (ps != null) ps.close();
                oc_conn.close();
            }
            catch (SQLException se) {
                Debug.printProjectErr(se, Thread.currentThread().getStackTrace());
            }
        }
        return foundObjects;
    }
     public static void delete(String uid) {
        PreparedStatement ps = null;
        ResultSet rs = null;
        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try {
            if(uid!=null && !uid.equals("-1")){
                String sSelect = "DELETE FROM OC_MEAL_PROFILES" +
                        " WHERE OC_MEAL_PROFILES_SERVERID = ? AND OC_MEAL_PROFILES_OBJECTID = ?";
                ps = oc_conn.prepareStatement(sSelect);
                ps.setInt(1, Integer.parseInt(uid.substring(0, uid.indexOf("."))));
                ps.setInt(2, Integer.parseInt(uid.substring(uid.indexOf(".") + 1)));
                ps.executeUpdate();
            }
        }
        catch (Exception e) {
            Debug.printProjectErr(e, Thread.currentThread().getStackTrace());
        }
        finally {
            try {
                if (rs != null) rs.close();
                if (ps != null) ps.close();
                oc_conn.close();
            }
            catch (SQLException se) {
                Debug.printProjectErr(se, Thread.currentThread().getStackTrace());
            }
        }
    }

}

