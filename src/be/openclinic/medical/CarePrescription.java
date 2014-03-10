package be.openclinic.medical;

import be.mxs.common.util.db.MedwanQuery;
import be.mxs.common.util.system.Debug;
import be.mxs.common.util.system.ScreenHelper;
import be.openclinic.common.OC_Object;
import net.admin.AdminPerson;

import java.sql.*;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.Vector;

public class CarePrescription extends OC_Object{
    private AdminPerson patient;
    private AdminPerson prescriber;
    private String careUid;
    private Date begin;
    private Date end;
    private String timeUnit; // (Hour|Day|Week|Month)
    private int timeUnitCount = -1;
    private double unitsPerTimeUnit = -1;

    // non-db data
    private String patientUid;
    private String prescriberUid;

    //--- PATIENT ---------------------------------------------------------------------------------
    public AdminPerson getPatient() {
        if(patientUid!=null && patientUid.length() > 0){
            if(patient==null){
            	Connection ad_conn = MedwanQuery.getInstance().getAdminConnection();
                this.setPatient(AdminPerson.getAdminPerson(ad_conn,patientUid));
                try {
					ad_conn.close();
				} 
                catch (SQLException e) {
					e.printStackTrace();
				}
            }
        }

        return patient;
    }

    public void setPatient(AdminPerson patient) {
        this.patient = patient;
    }

    //--- PRESCRIBER ------------------------------------------------------------------------------
    public AdminPerson getPrescriber() {
        if(prescriberUid!=null && prescriberUid.length()>0){
            if(prescriber==null){
            	Connection ad_conn = MedwanQuery.getInstance().getAdminConnection();
                this.setPrescriber(AdminPerson.getAdminPerson(ad_conn,prescriberUid));
                try {
					ad_conn.close();
				} 
                catch (SQLException e) {
					e.printStackTrace();
				}
            }
        }

        return prescriber;
    }

    public void setPrescriber(AdminPerson prescriber) {
        this.prescriber = prescriber;
    }

    //--- BEGIN -----------------------------------------------------------------------------------
    public Date getBegin() {
        return begin;
    }

    public void setBegin(Date begin) {
        this.begin = begin;
    }

    //--- END -------------------------------------------------------------------------------------
    public Date getEnd() {
        return end;
    }

    public void setEnd(Date end) {
        this.end = end;
    }

    //--- TIMEUNIT --------------------------------------------------------------------------------
    public String getTimeUnit() {
        return timeUnit;
    }

    public void setTimeUnit(String timeUnit) {
        this.timeUnit = timeUnit;
    }

    //--- TIMEUNIT COUNT --------------------------------------------------------------------------
    public int getTimeUnitCount() {
        return timeUnitCount;
    }

    public void setTimeUnitCount(int timeUnitCount) {
        this.timeUnitCount = timeUnitCount;
    }

    //--- UNITS PER TIMEUNIT ----------------------------------------------------------------------
    public double getUnitsPerTimeUnit() {
        return unitsPerTimeUnit;
    }

    public void setUnitsPerTimeUnit(double unitsPerTimeUnit) {
        this.unitsPerTimeUnit = unitsPerTimeUnit;
    }

     //--- Care --------------------------------------------------------------------------------
    public String getCareUid() {
        return careUid;
    }

    public void setCareUid(String uid) {
        this.careUid = uid;
    }
    //--- NON-DB DATA : PATIENT UID ---------------------------------------------------------------
    public void setPatientUid(String uid){
        this.patientUid = uid;
    }

    public String getPatientUid(){
        return this.patientUid;
    }

    //--- NON-DB DATA : PRESCRIBER UID ------------------------------------------------------------
    public void setPrescriberUid(String uid){
        this.prescriberUid = uid;
    }

    public String getPrescriberUid(){
        return this.prescriberUid;
    }

    //--- GET -------------------------------------------------------------------------------------
    public static CarePrescription get(String prescrUid){
        CarePrescription careprescr = new CarePrescription();
        careprescr.setUid(prescrUid);
        PreparedStatement ps = null;
        ResultSet rs = null;

        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            String sSelect = "SELECT * FROM OC_CAREPRESCRIPTIONS"+
                             " WHERE OC_CAREPRESCR_SERVERID = ? AND OC_CAREPRESCR_OBJECTID = ?";
            ps = oc_conn.prepareStatement(sSelect);
            ps.setInt(1,Integer.parseInt(prescrUid.substring(0,prescrUid.indexOf("."))));
            ps.setInt(2,Integer.parseInt(prescrUid.substring(prescrUid.indexOf(".")+1)));
            rs = ps.executeQuery();

            // get data from DB
            if(rs.next()){
                careprescr.setPatientUid(rs.getString("OC_CAREPRESCR_PATIENTUID"));
                careprescr.setPrescriberUid(rs.getString("OC_CAREPRESCR_PRESCRIBERUID"));
                careprescr.setCareUid(rs.getString("OC_CAREPRESCR_CAREUID"));

                // begin date
                java.util.Date tmpDate = rs.getDate("OC_CAREPRESCR_BEGIN");
                if(tmpDate!=null) careprescr.setBegin(tmpDate);

                // end date
                tmpDate = rs.getDate("OC_CAREPRESCR_END");
                if(tmpDate!=null) careprescr.setEnd(tmpDate);

                // units
                careprescr.setTimeUnit(rs.getString("OC_CAREPRESCR_TIMEUNIT"));
                careprescr.setTimeUnitCount(rs.getInt("OC_CAREPRESCR_TIMEUNITCOUNT"));
                careprescr.setUnitsPerTimeUnit(rs.getDouble("OC_CAREPRESCR_UNITSPERTIMEUNIT"));

                // OBJECT variables
                careprescr.setCreateDateTime(rs.getTimestamp("OC_CAREPRESCR_CREATETIME"));
                careprescr.setUpdateDateTime(rs.getTimestamp("OC_CAREPRESCR_UPDATETIME"));
                careprescr.setUpdateUser(ScreenHelper.checkString(rs.getString("OC_CAREPRESCR_UPDATEUID")));
                careprescr.setVersion(rs.getInt("OC_CAREPRESCR_VERSION"));
            }
            else{
                throw new Exception("ERROR : CAREPRESCRIPTION "+prescrUid+" NOT FOUND");
            }
        }
        catch(Exception e){
            careprescr = null;

            if(e.getMessage().endsWith("NOT FOUND")){
                Debug.println(e.getMessage());
            }
            else{
                e.printStackTrace();
            }
        }
        finally{
            try{
                if(rs!=null) rs.close();
                if(ps!=null) ps.close();
                oc_conn.close();
            }
            catch(SQLException se){
                se.printStackTrace();
            }
        }

        return careprescr;
    }

    //--- STORE -----------------------------------------------------------------------------------
    public void store(){
        store(true);
    }

    public void store(boolean checkExistence){
        PreparedStatement ps = null;
        ResultSet rs = null;
        String sSelect;
        boolean prescrWithSameDataExists = false;

        // check existence if needed
        if(checkExistence){
            prescrWithSameDataExists = this.exists().length()>0;
        }

        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            if(this.getUid().equals("-1") && !prescrWithSameDataExists){
                //***** INSERT *****
                Debug.println("@@@ CAREPRECRIPTION insert @@@");

                sSelect = "INSERT INTO OC_CAREPRESCRIPTIONS (OC_CAREPRESCR_SERVERID,OC_CAREPRESCR_OBJECTID,OC_CAREPRESCR_PATIENTUID,"+
                          "  OC_CAREPRESCR_PRESCRIBERUID,OC_CAREPRESCR_CAREUID,OC_CAREPRESCR_BEGIN,OC_CAREPRESCR_END,OC_CAREPRESCR_TIMEUNIT,"+
                          "  OC_CAREPRESCR_TIMEUNITCOUNT,OC_CAREPRESCR_UNITSPERTIMEUNIT,"+
                          "  OC_CAREPRESCR_CREATETIME,OC_CAREPRESCR_UPDATETIME,OC_CAREPRESCR_UPDATEUID,OC_CAREPRESCR_VERSION)"+
                          " VALUES(?,?,?,?,?,?,?,?,?,?,?,?,?,1)";

                ps = oc_conn.prepareStatement(sSelect);

                // set new prescriptionuid
                int serverId = MedwanQuery.getInstance().getConfigInt("serverId");
                int prescrCounter = MedwanQuery.getInstance().getOpenclinicCounter("OC_CAREPRESCRIPTIONS");
                ps.setInt(1,serverId);
                ps.setInt(2,prescrCounter);
                this.setUid(serverId+"."+prescrCounter);

                ps.setString(3,this.getPatientUid());
                ps.setString(4,this.getPrescriberUid());
                ps.setString(5,this.getCareUid());

                // date begin
                if(this.begin!=null) ps.setTimestamp(6,new java.sql.Timestamp(this.begin.getTime()));
                else                 ps.setNull(6,Types.TIMESTAMP);

                // date end
                if(this.end!=null) ps.setTimestamp(7,new java.sql.Timestamp(end.getTime()));
                else               ps.setNull(7,Types.TIMESTAMP);

                if(this.getTimeUnit().length() > 0) ps.setString(8,this.getTimeUnit());
                else                                ps.setNull(8,Types.VARCHAR);

                if(this.getTimeUnitCount() > -1) ps.setInt(9,this.getTimeUnitCount());
                else                             ps.setNull(9,Types.INTEGER);

                if(this.getUnitsPerTimeUnit() > -1) ps.setDouble(10,this.getUnitsPerTimeUnit());
                else                                ps.setNull(10,Types.DOUBLE);

                // OBJECT variables
                ps.setTimestamp(11,new Timestamp(new java.util.Date().getTime())); // now
                ps.setTimestamp(12,new Timestamp(new java.util.Date().getTime())); // now
                ps.setString(13,this.getUpdateUser());

                ps.executeUpdate();
            }
            else{
                //***** UPDATE *****
                Debug.println("@@@ CAREPRECRIPTION update @@@");

                sSelect = "UPDATE OC_CAREPRESCRIPTIONS SET OC_CAREPRESCR_PATIENTUID=?, OC_CAREPRESCR_PRESCRIBERUID=?,"+
                          "  OC_CAREPRESCR_CAREUID=?, OC_CAREPRESCR_BEGIN=?, OC_CAREPRESCR_END=?, OC_CAREPRESCR_TIMEUNIT=?,"+
                          "  OC_CAREPRESCR_TIMEUNITCOUNT=?, OC_CAREPRESCR_UNITSPERTIMEUNIT=?,"+
                          "  OC_CAREPRESCR_UPDATETIME=?, OC_CAREPRESCR_UPDATEUID=?, OC_CAREPRESCR_VERSION=(OC_CAREPRESCR_VERSION+1)"+
                          " WHERE OC_CAREPRESCR_SERVERID=? AND OC_CAREPRESCR_OBJECTID=?";

                ps = oc_conn.prepareStatement(sSelect);
                ps.setString(1,this.getPatientUid());
                ps.setString(2,this.getPrescriberUid());
                ps.setString(3,this.getCareUid());

                // date begin
                if(this.begin!=null) ps.setTimestamp(4,new java.sql.Timestamp(this.begin.getTime()));
                else                 ps.setNull(4,Types.TIMESTAMP);

                // date end
                if(this.end!=null) ps.setTimestamp(5,new java.sql.Timestamp(end.getTime()));
                else               ps.setNull(5,Types.TIMESTAMP);

                if(this.getTimeUnit().length() > 0) ps.setString(6,this.getTimeUnit());
                else                                ps.setNull(6,Types.VARCHAR);

                if(this.getTimeUnitCount() > -1) ps.setInt(7,this.getTimeUnitCount());
                else                             ps.setNull(7,Types.INTEGER);

                if(this.getUnitsPerTimeUnit() > -1) ps.setDouble(8,this.getUnitsPerTimeUnit());
                else                                ps.setNull(8,Types.DOUBLE);

                // OBJECT variables
                ps.setTimestamp(9,new Timestamp(new java.util.Date().getTime())); // now
                ps.setString(10,this.getUpdateUser());

                ps.setInt(11,Integer.parseInt(this.getUid().substring(0,this.getUid().indexOf("."))));
                ps.setInt(12,Integer.parseInt(this.getUid().substring(this.getUid().indexOf(".")+1)));

                ps.executeUpdate();
            }
        }
        catch(Exception e){
            e.printStackTrace();
        }
        finally{
            try{
                if(rs!=null) rs.close();
                if(ps!=null) ps.close();
                oc_conn.close();
            }
            catch(SQLException se){
                se.printStackTrace();
            }
        }
    }

    //--- EXISTS ----------------------------------------------------------------------------------
    // checks the database for a record with the same UNIQUE KEYS as 'this'.
    public String exists(){
        PreparedStatement ps = null;
        ResultSet rs = null;
        String uid = "";

        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            //***** check existence *****
            String sSelect = "SELECT OC_CAREPRESCR_SERVERID,OC_CAREPRESCR_OBJECTID FROM OC_CAREPRESCRIPTIONS"+
                             " WHERE OC_CAREPRESCR_PATIENTUID=?"+
                             "  AND OC_CAREPRESCR_CAREUID=?"+
                             "  AND OC_CAREPRESCR_BEGIN=?"+
                             "  AND OC_CAREPRESCR_END=?";

            ps = oc_conn.prepareStatement(sSelect);
            int questionmarkIdx = 1;
            ps.setString(questionmarkIdx++,this.getPatientUid());

            // care
            if(this.begin!=null) ps.setString(questionmarkIdx++,this.careUid);
            else                 ps.setNull(questionmarkIdx++,Types.VARCHAR);

            // date begin
            if(this.begin!=null) ps.setTimestamp(questionmarkIdx++,new java.sql.Timestamp(this.begin.getTime()));
            else                 ps.setNull(questionmarkIdx++,Types.TIMESTAMP);

            // date end
            if(this.end!=null) ps.setTimestamp(questionmarkIdx++,new java.sql.Timestamp(end.getTime()));
            else               ps.setNull(questionmarkIdx++,Types.TIMESTAMP);

            rs = ps.executeQuery();
            if(rs.next()){
                uid = rs.getInt("OC_CAREPRESCR_SERVERID")+"."+rs.getInt("OC_CAREPRESCR_OBJECTID");
            }
        }
        catch(Exception e){
            e.printStackTrace();
        }
        finally{
            try{
                if(rs!=null) rs.close();
                if(ps!=null) ps.close();
                oc_conn.close();
            }
            catch(SQLException se){
                se.printStackTrace();
            }
        }

        return uid;
    }

    //--- CHANGED ---------------------------------------------------------------------------------
    // checks the database for a record with the same DATA as 'this'.
    public boolean changed(){
        PreparedStatement ps = null;
        ResultSet rs = null;
        boolean changed = true;

        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            //***** check existence *****
            String sSelect = "SELECT OC_CAREPRESCR_SERVERID,OC_CAREPRESCR_OBJECTID FROM OC_CAREPRESCRIPTIONS"+
                             " WHERE OC_CAREPRESCR_PATIENTUID=?"+
                             "  AND OC_CAREPRESCR_PRESCRIBERUID=?"+
                             "  AND OC_CAREPRESCR_CAREUID=?"+
                             "  AND OC_CAREPRESCR_BEGIN=?"+
                             "  AND OC_CAREPRESCR_END=?"+
                             "  AND OC_CAREPRESCR_TIMEUNIT=?"+
                             "  AND OC_CAREPRESCR_TIMEUNITCOUNT=?"+
                             "  AND OC_CAREPRESCR_UNITSPERTIMEUNIT=?";

            ps = oc_conn.prepareStatement(sSelect);
            int questionmarkIdx = 1;

            ps.setString(questionmarkIdx++,this.getPatientUid()); // required
            ps.setString(questionmarkIdx++,this.getPrescriberUid()); // required

            // care
            if(this.begin!=null) ps.setString(questionmarkIdx++,this.careUid);
            else                 ps.setNull(questionmarkIdx++,Types.VARCHAR);

            // date begin
            if(this.begin!=null) ps.setTimestamp(questionmarkIdx++,new java.sql.Timestamp(this.begin.getTime()));
            else                 ps.setNull(questionmarkIdx++,Types.TIMESTAMP);

            // date end
            if(this.end!=null) ps.setTimestamp(questionmarkIdx++,new java.sql.Timestamp(end.getTime()));
            else               ps.setNull(questionmarkIdx++,Types.TIMESTAMP);

            // timeUnit
            if(this.getTimeUnit().length() > 0) ps.setString(questionmarkIdx++,this.getTimeUnit());
            else                                ps.setNull(questionmarkIdx++,Types.VARCHAR);

            // timeUnitCount
            if(this.timeUnitCount > -1) ps.setInt(questionmarkIdx++,this.timeUnitCount);
            else                        ps.setNull(questionmarkIdx++,Types.INTEGER);

            // unitsPerTimeUnit
            if(this.unitsPerTimeUnit > -1) ps.setDouble(questionmarkIdx++,this.unitsPerTimeUnit);
            else                           ps.setNull(questionmarkIdx++,Types.DOUBLE);

            rs = ps.executeQuery();
            if(rs.next()) changed = false;
        }
        catch(Exception e){
            e.printStackTrace();
        }
        finally{
            try{
                if(rs!=null) rs.close();
                if(ps!=null) ps.close();
                oc_conn.close();
            }
            catch(SQLException se){
                se.printStackTrace();
            }
        }

        return changed;
    }

    //--- DELETE ----------------------------------------------------------------------------------
    public static void delete(String prescrUid){
        PreparedStatement ps = null;

        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            String sSelect = "DELETE FROM OC_CAREPRESCRIPTIONS"+
                             " WHERE OC_CAREPRESCR_SERVERID = ? AND OC_CAREPRESCR_OBJECTID = ?";
            ps = oc_conn.prepareStatement(sSelect);
            ps.setInt(1,Integer.parseInt(prescrUid.substring(0,prescrUid.indexOf("."))));
            ps.setInt(2,Integer.parseInt(prescrUid.substring(prescrUid.indexOf(".")+1)));
            ps.executeUpdate();
        }
        catch(Exception e){
            e.printStackTrace();
        }
        finally{
            try{
                if(ps!=null) ps.close();
                oc_conn.close();
            }
            catch(SQLException se){
                se.printStackTrace();
            }
        }
    }

    //--- GET ACTIVE PRESCRIPTIONS ----------------------------------------------------------------
    // get all active prescriptions for the specified patient
    //---------------------------------------------------------------------------------------------
    public static Vector getActivePrescriptions(String patientuid){
        Vector activePrescriptions = new Vector();
        CarePrescription careprescr;
        PreparedStatement ps = null;
        ResultSet rs = null;

        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            String sSelect = "SELECT * FROM OC_CAREPRESCRIPTIONS"+
                             " WHERE OC_CAREPRESCR_PATIENTUID = ? AND (OC_CAREPRESCR_END IS NULL OR OC_CAREPRESCR_END >= ?)";
            ps = oc_conn.prepareStatement(sSelect);
            ps.setString(1,patientuid);
            ps.setTimestamp(2,new Timestamp(new SimpleDateFormat("dd/MM/yyyy").parse(new SimpleDateFormat("dd/MM/yyyy").format(new Date())).getTime()));
            rs = ps.executeQuery();

            // get data from DB
            while(rs.next()){
                careprescr = new CarePrescription();
                careprescr.setUid(rs.getString("OC_CAREPRESCR_SERVERID")+"."+rs.getString("OC_CAREPRESCR_OBJECTID"));

                careprescr.setPatientUid(rs.getString("OC_CAREPRESCR_PATIENTUID"));
                careprescr.setPrescriberUid(rs.getString("OC_CAREPRESCR_PRESCRIBERUID"));
                careprescr.setCareUid(rs.getString("OC_PRESCR_PRODUCTUID"));

                java.util.Date tmpDate = rs.getDate("OC_PRESCR_BEGIN");
                if(tmpDate!=null) careprescr.setBegin(tmpDate);

                tmpDate = rs.getDate("OC_PRESCR_END");
                if(tmpDate!=null) careprescr.setEnd(tmpDate);

                careprescr.setTimeUnit(rs.getString("OC_PRESCR_TIMEUNIT"));
                careprescr.setTimeUnitCount(rs.getInt("OC_PRESCR_TIMEUNITCOUNT"));
                careprescr.setUnitsPerTimeUnit(rs.getDouble("OC_PRESCR_UNITSPERTIMEUNIT"));

                // object variables
                careprescr.setCreateDateTime(rs.getTimestamp("OC_PRESCR_CREATETIME"));
                careprescr.setUpdateDateTime(rs.getTimestamp("OC_PRESCR_UPDATETIME"));
                careprescr.setUpdateUser(ScreenHelper.checkString(rs.getString("OC_PRESCR_UPDATEUID")));
                careprescr.setVersion(rs.getInt("OC_PRESCR_VERSION"));

                activePrescriptions.add(careprescr);
            }
        }
        catch(Exception e){
            e.printStackTrace();
        }
        finally{
            try{
                if(rs!=null) rs.close();
                if(ps!=null) ps.close();
                oc_conn.close();
            }
            catch(SQLException se){
                se.printStackTrace();
            }
        }

        return activePrescriptions;
    }

    //--- FIND ------------------------------------------------------------------------------------
    public static Vector find(String sFindPatientUid, String sFindPrescriberUid, String sFindCareUid,
                              String sFindDateBegin, String sFindDateEnd, String sFindSupplyingServiceUid,
                              String sSortCol, String sSortDir){
        Vector foundObjects = new Vector();
        PreparedStatement ps = null;
        ResultSet rs = null;

        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            String sSelect = "SELECT OC_CAREPRESCR_SERVERID, OC_CAREPRESCR_OBJECTID"+
                             " FROM OC_CAREPRESCRIPTIONS ";

            if(sFindPatientUid.length()>0 || sFindPrescriberUid.length()>0 || sFindCareUid.length()>0 ||
               sFindDateBegin.length()>0 || sFindDateEnd.length()>0 || sFindSupplyingServiceUid.length()>0){
                sSelect+= "WHERE ";

                if(sFindPatientUid.length() > 0)    sSelect+= "OC_CAREPRESCR_PATIENTUID = ? AND ";
                if(sFindPrescriberUid.length() > 0) sSelect+= "OC_CAREPRESCR_PRESCRIBERUID = ? AND ";
                if(sFindCareUid.length() > 0)    sSelect+= "OC_CAREPRESCR_CAREUID = ? AND ";
                if(sFindDateBegin.length() > 0)     sSelect+= "OC_CAREPRESCR_BEGIN <= ? AND ";
                if(sFindDateEnd.length() > 0)       sSelect+= "(OC_CAREPRESCR_END IS NULL OR OC_CAREPRESCR_END >= ?) AND ";

                // remove last AND if any
                if(sSelect.indexOf("AND ")>0){
                    sSelect = sSelect.substring(0,sSelect.lastIndexOf("AND "));
                }
            }

            if(sSortCol.length()==0){
                sSortCol="OC_CAREPRESCR_BEGIN";
            }
            if(sSortDir.length()==0){
                sSortDir="ASC";
            }
            // order by selected col or default col
            sSelect+= "ORDER BY "+sSortCol+" "+sSortDir;

            ps = oc_conn.prepareStatement(sSelect);

            // set questionmark values
            int questionMarkIdx = 1;
            if(sFindPatientUid.length() > 0)    ps.setString(questionMarkIdx++,sFindPatientUid);
            if(sFindPrescriberUid.length() > 0) ps.setString(questionMarkIdx++,sFindPrescriberUid);
            if(sFindCareUid.length() > 0)    ps.setString(questionMarkIdx++,sFindCareUid);
            if(sFindDateBegin.length() > 0)     ps.setDate(questionMarkIdx++,ScreenHelper.getSQLDate(sFindDateBegin));
            if(sFindDateEnd.length() > 0)       ps.setDate(questionMarkIdx++,ScreenHelper.getSQLDate(sFindDateEnd));

            // execute
            rs = ps.executeQuery();

            while(rs.next()){
                foundObjects.add(get(rs.getString("OC_CAREPRESCR_SERVERID")+"."+rs.getString("OC_CAREPRESCR_OBJECTID")));
            }
        }
        catch(Exception e){
            e.printStackTrace();
        }
        finally{
            try{
                if(rs!=null) rs.close();
                if(ps!=null) ps.close();
                oc_conn.close();
            }
            catch(SQLException se){
                se.printStackTrace();
            }
        }

        return foundObjects;
    }

    //--- FIND ACTIVE -----------------------------------------------------------------------------
    public static Vector findActive(String sFindPatientUid, String sFindPrescriberUid, String sFindCareUid,
                                    String sFindDateBegin, String sFindDateEnd, String sFindSupplyingServiceUid,
                                    String sSortCol, String sSortDir){
        Vector foundObjects = new Vector();
        PreparedStatement ps = null;
        ResultSet rs = null;

        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            // compose query
            String sSelect = "SELECT * FROM OC_CAREPRESCRIPTIONS"+
                             " WHERE (OC_CAREPRESCR_END >= ? OR OC_CAREPRESCR_END IS NULL)"; // difference

            if(sFindPatientUid.length()>0 || sFindPrescriberUid.length()>0 || sFindCareUid.length()>0 ||
               sFindDateBegin.length()>0 || sFindDateEnd.length()>0 || sFindSupplyingServiceUid.length()>0){
                sSelect+= " AND ";

                if(sFindPatientUid.length() > 0)    sSelect+= "OC_CAREPRESCR_PATIENTUID = ? AND ";
                if(sFindPrescriberUid.length() > 0) sSelect+= "OC_CAREPRESCR_PRESCRIBERUID = ? AND ";
                if(sFindCareUid.length() > 0)    sSelect+= "OC_CAREPRESCR_CAREUID = ? AND ";
                if(sFindDateEnd.length() > 0)     sSelect+= "OC_CAREPRESCR_BEGIN <= ? AND ";

                // remove last AND if any
                if(sSelect.indexOf("AND ")>0){
                    sSelect = sSelect.substring(0,sSelect.lastIndexOf("AND "));
                }
            }

            if(sSortCol.length()==0){
                sSortCol="OC_CAREPRESCR_BEGIN";
            }
            if(sSortDir.length()==0){
                sSortDir="ASC";
            }
            // order by selected col or default col
            sSelect+= "ORDER BY "+sSortCol+" "+sSortDir;

            ps = oc_conn.prepareStatement(sSelect);

            // set questionmark values
            int questionMarkIdx = 1;
            ps.setDate(questionMarkIdx++,sFindDateBegin.length()>0?ScreenHelper.getSQLDate(sFindDateBegin):new java.sql.Date(new java.util.Date().getTime()));
            if(sFindPatientUid.length() > 0)    ps.setString(questionMarkIdx++,sFindPatientUid);
            if(sFindPrescriberUid.length() > 0) ps.setString(questionMarkIdx++,sFindPrescriberUid);
            if(sFindCareUid.length() > 0)    ps.setString(questionMarkIdx++,sFindCareUid);
            if(sFindDateEnd.length() > 0)     ps.setDate(questionMarkIdx++,ScreenHelper.getSQLDate(sFindDateEnd));

            // execute
            rs = ps.executeQuery();

            while(rs.next()){
                foundObjects.add(get(rs.getString("OC_CAREPRESCR_SERVERID")+"."+rs.getString("OC_CAREPRESCR_OBJECTID")));
            }
        }
        catch(Exception e){
            e.printStackTrace();
        }
        finally{
            try{
                if(rs!=null) rs.close();
                if(ps!=null) ps.close();
                oc_conn.close();
            }
            catch(SQLException se){
                se.printStackTrace();
            }
        }
        return foundObjects;
    }

    //--- IS ACTIVE -------------------------------------------------------------------------------
    public boolean isActive(){
        boolean isActive = false;

        if(this.getEnd()==null || this.getEnd().after(new java.util.Date())){
            isActive = true;
        }

        return isActive;
    }

    public static Vector getCarePrescriptionsByPatient(String sPatientUID){
        PreparedStatement ps = null;
        ResultSet rs = null;

        String sSelect = "SELECT * FROM OC_CAREPRESCRIPTIONS"+
                         " WHERE OC_CAREPRESCR_PATIENTUID = ? ORDER BY OC_CAREPRESCR_BEGIN DESC";

        Vector vPrescriptions = new Vector();

        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            ps = oc_conn.prepareStatement(sSelect);
            ps.setString(1,sPatientUID);
            rs = ps.executeQuery();

            CarePrescription careprescr;

            while(rs.next()){
                careprescr = new CarePrescription();

                careprescr.setUid(ScreenHelper.checkString(rs.getString("OC_CAREPRESCR_SERVERID")) + "." + ScreenHelper.checkString(rs.getString("OC_CAREPRESCR_OBJECTID")));
                careprescr.setPatientUid(rs.getString("OC_CAREPRESCR_PATIENTUID"));
                careprescr.setPrescriberUid(rs.getString("OC_CAREPRESCR_PRESCRIBERUID"));
                careprescr.setCareUid(rs.getString("OC_CAREPRESCR_CAREUID"));

                // begin date
                java.util.Date tmpDate = rs.getDate("OC_CAREPRESCR_BEGIN");
                if(tmpDate!=null) careprescr.setBegin(tmpDate);

                // end date
                tmpDate = rs.getDate("OC_CAREPRESCR_END");
                if(tmpDate!=null) careprescr.setEnd(tmpDate);

                // units
                careprescr.setTimeUnit(rs.getString("OC_CAREPRESCR_TIMEUNIT"));
                careprescr.setTimeUnitCount(rs.getInt("OC_CAREPRESCR_TIMEUNITCOUNT"));
                careprescr.setUnitsPerTimeUnit(rs.getDouble("OC_CAREPRESCR_UNITSPERTIMEUNIT"));

                // OBJECT variables
                careprescr.setCreateDateTime(rs.getTimestamp("OC_CAREPRESCR_CREATETIME"));
                careprescr.setUpdateDateTime(rs.getTimestamp("OC_CAREPRESCR_UPDATETIME"));
                careprescr.setUpdateUser(ScreenHelper.checkString(rs.getString("OC_CAREPRESCR_UPDATEUID")));
                careprescr.setVersion(rs.getInt("OC_CAREPRESCR_VERSION"));

                vPrescriptions.addElement(careprescr);
            }

            rs.close();
            ps.close();
        }catch(Exception e){
            e.printStackTrace();
        }finally{
            try{
                if(rs!=null)rs.close();
                if(ps!=null)ps.close();
                oc_conn.close();
            }catch(Exception e){
                e.printStackTrace();
            }
        }
        return vPrescriptions;
    }
}

