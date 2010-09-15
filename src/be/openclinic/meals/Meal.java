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
import java.text.SimpleDateFormat;

import net.admin.AdminPerson;
public class Meal extends OC_Object {
    public String name;
    public List mealItems;
    public Date mealDatetime;
    public boolean taken;
    public String patientMealUid;
    public Meal() {
        this.name = "";
        this.mealItems = new LinkedList();
        this.mealDatetime = new Date();
        this.mealDatetime.setMinutes(0);
        this.mealDatetime.setHours(7);
        this.taken = false;
        this.patientMealUid = "";
    }
    public Meal(String uid) {
        setUid(uid);
        this.name = "";
        this.mealItems = new LinkedList();
        this.mealDatetime = new Date();
        this.mealDatetime.setMinutes(0);
        this.mealDatetime.setHours(7);
        this.taken = false;
        this.patientMealUid = "";
    }
    public void updateOrInsert(String useruid) {
        PreparedStatement ps = null;
        ResultSet rs = null;
        String sSelect;
        String ids[];
        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try {
            ids = this.getUid().split("\\.");
            if (getUid().equals("-1")) {
                // insert new meal
                sSelect = "INSERT INTO OC_MEAL (OC_MEAL_SERVERID, OC_MEAL_OBJECTID," +
                        "  OC_MEAL_NAME,OC_MEAL_CREATETIME,OC_MEAL_UPDATEUID)" +
                        " VALUES(?,?,?,?,?)";
                ps = oc_conn.prepareStatement(sSelect);
                // OBJECT variables
                ids = new String[]{MedwanQuery.getInstance().getConfigString("serverId"), MedwanQuery.getInstance().getOpenclinicCounter("OC_MEAL") + ""};
                ps.setInt(1, Integer.parseInt(ids[0]));
                ps.setInt(2, Integer.parseInt(ids[1]));
                ps.setString(3, this.name);
                ps.setTimestamp(4, new Timestamp(new java.util.Date().getTime())); // now
                ps.setString(5, useruid);
                this.setUid(ids[0]+"."+ids[1]);
                ps.executeUpdate();
            } else {
                sSelect = "UPDATE OC_MEAL SET" +
                        "  OC_MEAL_NAME=?,OC_MEAL_UPDATETIME=?,OC_MEAL_UPDATEUID=?" +
                        " WHERE OC_MEAL_SERVERID=? AND OC_MEAL_OBJECTID=?";
                ps = oc_conn.prepareStatement(sSelect);
                ps.setString(1, this.name);
                ps.setTimestamp(2, new Timestamp(new java.util.Date().getTime())); // now
                ps.setString(3, useruid);
                ps.setInt(4, Integer.parseInt(ids[0]));
                ps.setInt(5, Integer.parseInt(ids[1]));
                ps.executeUpdate();
            }
            setMealItems(useruid);//update meal items
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
    public void setMealItems(String useruid) {
        deleteAllMealItemsFromMeal();//first delete all mealitems from meal
        if (this.mealItems != null && this.mealItems.size() > 0) {
            PreparedStatement ps = null;
            ResultSet rs = null;
            String sSelect;
            Iterator it = this.mealItems.iterator();
            while (it.hasNext()) {
                MealItem mealitem = (MealItem) it.next();
                //then insert mealitems from the list
                // insert mealitem
                Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
                try {
                    sSelect = "INSERT INTO OC_MEAL_COMPONENT (OC_MEALUID, OC_MEAL_ITEMUID," +
                            "  OC_MEAL_ITEMQUANTITY,OC_MEAL_COMPONENT_CREATETIME,OC_MEAL_COMPONENT_UPDATEUID)" +
                            " VALUES(?,?,?,?,?)";
                    ps = oc_conn.prepareStatement(sSelect);
                    // OBJECT variables
                    ps.setString(1, this.getUid());
                    ps.setString(2, mealitem.getUid());
                    ps.setFloat(3, mealitem.quantity);
                    ps.setTimestamp(4, new Timestamp(new java.util.Date().getTime())); // now
                    ps.setString(5, useruid);
                    ps.executeUpdate();
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
        }
    }
    public void deleteAllMealItemsFromMeal() {
        PreparedStatement ps = null;
        ResultSet rs = null;
        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try {
            String sSelect = "DELETE FROM OC_MEAL_COMPONENT" +
                    " WHERE OC_MEALUID = ?";
            ps = oc_conn.prepareStatement(sSelect);
            ps.setString(1, this.getUid());
            ps.executeUpdate();
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
    public void delete() {
        deleteAllMealItemsFromMeal();// first delete all mealitems
        PreparedStatement ps = null;
        ResultSet rs = null;
        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try {
            String sSelect = "DELETE FROM OC_MEAL" +
                    " WHERE OC_MEAL_SERVERID = ? AND OC_MEAL_OBJECTID = ?";
            ps = oc_conn.prepareStatement(sSelect);
            ps.setInt(1, Integer.parseInt(getUid().substring(0, getUid().indexOf("."))));
            ps.setInt(2, Integer.parseInt(getUid().substring(getUid().indexOf(".") + 1)));
            ps.executeUpdate();
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
    public static Meal get(Meal item) {
        PreparedStatement ps = null;
        ResultSet rs = null;
        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try {
            String sSelect = "SELECT * FROM OC_MEAL WHERE OC_MEAL_SERVERID = ? AND OC_MEAL_OBJECTID = ?";
            ps = oc_conn.prepareStatement(sSelect);
            ps.setInt(1, Integer.parseInt(item.getUid().substring(0, item.getUid().indexOf("."))));
            ps.setInt(2, Integer.parseInt(item.getUid().substring(item.getUid().indexOf(".") + 1)));

            // execute
            rs = ps.executeQuery();
            if (rs.next()) {
                item.name = rs.getString("OC_MEAL_NAME");
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
        return importMealItems(item);
    }
    public static Meal importMealItems(Meal meal) {
        PreparedStatement ps = null;
        ResultSet rs = null;
        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try {
            String sSelect = "SELECT * FROM OC_MEAL_COMPONENT WHERE OC_MEALUID = ? ";
            ps = oc_conn.prepareStatement(sSelect);
            ps.setString(1, meal.getUid());
            meal.mealItems = new LinkedList();
            // execute
            rs = ps.executeQuery();
            MealItem mealitem = null;
            while (rs.next()) {
                mealitem = new MealItem(rs.getString("OC_MEAL_ITEMUID"));
                mealitem = MealItem.get(mealitem);
                if(mealitem!=null){
                    mealitem.quantity = rs.getFloat("OC_MEAL_ITEMQUANTITY");
                    meal.mealItems.add(mealitem);
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
        return meal;
    }
    public static List getList(Meal findItem) {
        List foundObjects = new LinkedList();
        PreparedStatement ps = null;
        ResultSet rs = null;
        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try {
            String sSelect = "SELECT * FROM OC_MEAL WHERE 1=1";
            if (findItem.name != null && findItem.name.trim().length() > 0) {
                sSelect += " AND OC_MEAL_NAME LIKE '%" + findItem.name + "%'";
            }
            sSelect += " ORDER BY OC_MEAL_NAME";
            ps = oc_conn.prepareStatement(sSelect);
            // execute
            rs = ps.executeQuery();
            while (rs.next()) {
                Meal item = new Meal();
                item.setUid(rs.getString("OC_MEAL_SERVERID") + "." + rs.getString("OC_MEAL_OBJECTID"));
                item.name = rs.getString("OC_MEAL_NAME");
                foundObjects.add(item);
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
    public static List getPatientMeals(AdminPerson patient, String date, Meal meal) {
        List foundObjects = new LinkedList();
        PreparedStatement ps = null;
        ResultSet rs = null;
        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try {
            String sSelect = "SELECT * FROM OC_MEAL m, OC_PATIENT_MEALS p WHERE p.OC_PM_MEALUID = " + MedwanQuery.getInstance().convert("varchar(10)", "m.OC_MEAL_SERVERID") + MedwanQuery.getInstance().concatSign() + "'.'" + MedwanQuery.getInstance().concatSign() + MedwanQuery.getInstance().convert("varchar(10)", "m.OC_MEAL_OBJECTID") + " ";
            sSelect += " AND OC_PM_PATIENTUID=? AND p.OC_PM_DATETIME >= ? AND p.OC_PM_DATETIME< ?";
            if (meal != null) {
                sSelect += " AND p.OC_PM_MEALUID = ?";
            }
            sSelect += " ORDER BY p.OC_PM_DATETIME";
            ps = oc_conn.prepareStatement(sSelect);
            ps.setString(1, patient.personid);
            ps.setDate(2, ScreenHelper.getSQLDate(date));
            ps.setDate(3, ScreenHelper.getSQLDate(ScreenHelper.getDateAdd(date, "1")));
            if (meal != null) {
                ps.setString(4, meal.getUid());
            }
            // execute
            rs = ps.executeQuery();
            while (rs.next()) {
                Meal item = new Meal();
                item.setUid(rs.getString("OC_MEAL_SERVERID") + "." + rs.getString("OC_MEAL_OBJECTID"));
                item.name = rs.getString("OC_MEAL_NAME");
                item.mealDatetime = rs.getTime("OC_PM_DATETIME");
                item.taken = rs.getString("OC_PM_TAKEN").equals("1");
                item.patientMealUid = rs.getString("OC_PM_SERVERID")+"."+rs.getString("OC_PM_OBJECTID");
                foundObjects.add(item);
            }
        } catch (Exception e) {
            e.printStackTrace();
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
   
    public static void insertPatientProfil(List l, AdminPerson patient, String userUid) {
        Iterator it = l.iterator();
        while (it.hasNext()) {
            MealProfil mealprofil = (MealProfil) it.next();
            Meal meal = new Meal(mealprofil.mealUid);
            meal.patientMealUid = "-1";
            meal.insertOrUpdatePatientMeal(patient, null, null, userUid, false, mealprofil.mealDatetime);
        }
    }
    public void insertOrUpdatePatientMeal(AdminPerson patient, String date, String time, String userUid, boolean mealTaken, Date _date) {
        PreparedStatement ps = null;
        ResultSet rs = null;
        String sSelect;
        String ids[];
        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try {
            if (date == null && _date != null) {
                SimpleDateFormat simple = new SimpleDateFormat("dd/MM/yyyy");
                date = simple.format(_date);
            }
            if (this.patientMealUid.equals("-1")) {
                // insert new meal
                sSelect = "INSERT INTO OC_PATIENT_MEALS (OC_PM_SERVERID,OC_PM_OBJECTID,OC_PM_PATIENTUID, OC_PM_MEALUID,OC_PM_TAKEN," +
                        "  OC_PM_DATETIME,OC_PM_CREATETIME,OC_PM_UPDATEUID) VALUES(?,?,?,?,?,?,?,?)";
                ps = oc_conn.prepareStatement(sSelect);
                ids = new String[]{MedwanQuery.getInstance().getConfigString("serverId"), MedwanQuery.getInstance().getOpenclinicCounter("OC_PATIENT_MEAL") + ""};

                // OBJECT variables
                ps.setInt(1, Integer.parseInt(ids[0]));
                ps.setInt(2, Integer.parseInt(ids[1]));
                ps.setString(3, patient.personid);
                ps.setString(4, this.getUid());
                ps.setString(5, ((mealTaken) ? "1" : "0"));
                if (_date == null) {
                    ScreenHelper.getSQLTimestamp(ps, 6, date, time);
                } else {
                    ps.setTimestamp(6, new Timestamp(_date.getTime())); // now
                }
                ps.setTimestamp(7, new Timestamp(new java.util.Date().getTime())); // now
                ps.setString(8, userUid);
                ps.executeUpdate();

            } else {
                ids = this.patientMealUid.split("\\.");
                sSelect = "UPDATE OC_PATIENT_MEALS SET" +
                        "  OC_PM_DATETIME=? , OC_PM_TAKEN = ?,OC_PM_UPDATETIME =?,OC_PM_UPDATEUID=?" +
                        " WHERE OC_PM_SERVERID=? AND OC_PM_OBJECTID = ? ";
                ps = oc_conn.prepareStatement(sSelect);
                if (_date == null) {
                    ScreenHelper.getSQLTimestamp(ps, 1, date, time);
                } else {
                    ps.setTimestamp(1, new Timestamp(_date.getTime())); // now
                }
                ps.setString(2, ((mealTaken) ? "1" : "0"));
                ps.setTimestamp(3, new Timestamp(new java.util.Date().getTime())); // now
                ps.setString(4, this.getUid());
                ps.setInt(5, Integer.parseInt(ids[0]));
                ps.setInt(6, Integer.parseInt(ids[1]));
               
                ps.executeUpdate();
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
    public void updateMealTaken(String userUid, boolean mealTaken) {
        PreparedStatement ps = null;
        ResultSet rs = null;
        String sSelect;
        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try {
            sSelect = "UPDATE OC_PATIENT_MEALS SET" +
                    " OC_PM_TAKEN = ?,OC_PM_UPDATETIME =?,OC_PM_UPDATEUID=?" +
                    " WHERE OC_PM_SERVERID = ? AND OC_PM_OBJECTID = ?";
            ps = oc_conn.prepareStatement(sSelect);
            ps.setString(1, ((mealTaken) ? "1" : "0"));
            ps.setTimestamp(2, new Timestamp(new java.util.Date().getTime())); // now
            ps.setString(3, userUid);
            ps.setInt(4, Integer.parseInt(this.patientMealUid.substring(0, getUid().indexOf("."))));
            ps.setInt(5, Integer.parseInt(this.patientMealUid.substring(getUid().indexOf(".") + 1)));
            ps.executeUpdate();
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
    public void deleteMealFromPatient() {
        PreparedStatement ps = null;
        ResultSet rs = null;
        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try {
            String sSelect = "DELETE FROM OC_PATIENT_MEALS" +
                    " WHERE OC_PM_SERVERID = ? AND OC_PM_OBJECTID = ?";
            ps = oc_conn.prepareStatement(sSelect);
            ps.setInt(1, Integer.parseInt(getUid().substring(0, getUid().indexOf("."))));
            ps.setInt(2, Integer.parseInt(getUid().substring(getUid().indexOf(".") + 1)));
            ps.executeUpdate();
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
