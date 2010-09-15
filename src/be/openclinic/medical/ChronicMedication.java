package be.openclinic.medical;

import net.admin.AdminPerson;
import be.openclinic.pharmacy.Product;
import be.openclinic.common.OC_Object;
import be.mxs.common.util.db.MedwanQuery;
import be.mxs.common.util.system.ScreenHelper;
import be.mxs.common.util.system.Debug;

import java.util.Date;
import java.util.Vector;
import java.sql.*;

/**
 * User: Stijn Smets
 * Date: 13-dec-2006
 */
public class ChronicMedication extends OC_Object {

    private AdminPerson patient;
    private Product product;
    private Date begin;
    private String timeUnit; // (Hour|Day|Week|Month)
    private int timeUnitCount = -1;
    private double unitsPerTimeUnit = -1;
    private AdminPerson prescriber;
    private String comment;

    // non-db data
    private String patientUid;
    private String prescriberUid;
    private String productUid;


    //--- PATIENT ---------------------------------------------------------------------------------
    public AdminPerson getPatient() {
        if(patientUid!=null && patientUid.length() > 0){
            if(patient==null){
            	Connection ad_conn = MedwanQuery.getInstance().getAdminConnection();
                this.setPatient(AdminPerson.getAdminPerson(ad_conn,patientUid));
                try {
					ad_conn.close();
				} catch (SQLException e) {
					// TODO Auto-generated catch block
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
				} catch (SQLException e) {
					// TODO Auto-generated catch block
					e.printStackTrace();
				}
            }
        }

        return prescriber;
    }

    public void setPrescriber(AdminPerson prescriber) {
        this.prescriber = prescriber;
    }

    //--- PRODUCT ---------------------------------------------------------------------------------
    public Product getProduct() {
        if(productUid!=null && productUid.length() > 0){
            if(product==null){
                this.setProduct(Product.get(productUid));
            }
        }

        return product;
    }

    public void setProduct(Product product) {
        this.product = product;
    }

    //--- BEGIN -----------------------------------------------------------------------------------
    public Date getBegin() {
        return begin;
    }

    public void setBegin(Date begin) {
        this.begin = begin;
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

    //--- COMMENT ---------------------------------------------------------------------------------
    public String getComment() {
        return comment;
    }

    public void setComment(String comment) {
        this.comment = comment;
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

    //--- NON-DB DATA : PRODUCT UID ---------------------------------------------------------------
    public void setProductUid(String uid){
        this.productUid = uid;
    }

    public String getProductUid(){
        return this.productUid;
    }

    //--- GET -------------------------------------------------------------------------------------
    public static ChronicMedication get(String medicationUid){
        ChronicMedication medication = new ChronicMedication();
        medication.setUid(medicationUid);
        PreparedStatement ps = null;
        ResultSet rs = null;

        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            String sSelect = "SELECT * FROM OC_CHRONICMEDICATIONS"+
                             " WHERE OC_CHRONICMED_SERVERID = ? AND OC_CHRONICMED_OBJECTID = ?";
            ps = oc_conn.prepareStatement(sSelect);
            ps.setInt(1,Integer.parseInt(medicationUid.substring(0,medicationUid.indexOf("."))));
            ps.setInt(2,Integer.parseInt(medicationUid.substring(medicationUid.indexOf(".")+1)));
            rs = ps.executeQuery();

            // get data from DB
            if(rs.next()){
                medication.setPatientUid(rs.getString("OC_CHRONICMED_PATIENTUID"));
                medication.setPrescriberUid(rs.getString("OC_CHRONICMED_PRESCRIBERUID"));
                medication.setProductUid(rs.getString("OC_CHRONICMED_PRODUCTUID"));
                medication.setComment(rs.getString("OC_CHRONICMED_COMMENT"));

                // begin date
                java.util.Date tmpDate = rs.getDate("OC_CHRONICMED_BEGIN");
                if(tmpDate!=null) medication.setBegin(tmpDate);

                // units
                medication.setTimeUnit(rs.getString("OC_CHRONICMED_TIMEUNIT"));
                medication.setTimeUnitCount(rs.getInt("OC_CHRONICMED_TIMEUNITCOUNT"));
                medication.setUnitsPerTimeUnit(rs.getDouble("OC_CHRONICMED_UNITSPERTIMEUNIT"));

                // OBJECT variables
                medication.setCreateDateTime(rs.getTimestamp("OC_CHRONICMED_CREATETIME"));
                medication.setUpdateDateTime(rs.getTimestamp("OC_CHRONICMED_UPDATETIME"));
                medication.setUpdateUser(ScreenHelper.checkString(rs.getString("OC_CHRONICMED_UPDATEUID")));
                medication.setVersion(rs.getInt("OC_CHRONICMED_VERSION"));
            }
            else{
                throw new Exception("ERROR : CHRONICMEDICATION "+medicationUid+" NOT FOUND");
            }
        }
        catch(Exception e){
            medication = null;

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

        return medication;
    }

    //--- STORE -----------------------------------------------------------------------------------
    public void store(){
        store(true);
    }

    public void store(boolean checkExistence){
        PreparedStatement ps = null;
        ResultSet rs = null;
        String sSelect;
        boolean medicationWithSameDataExists = false;

        // check existence if needed
        if(checkExistence){
            medicationWithSameDataExists = this.exists().length()>0;
        }

        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            if(this.getUid().equals("-1") && !medicationWithSameDataExists){
                //***** INSERT *****
                if(Debug.enabled) Debug.println("@@@ PRECRIPTION insert @@@");

                sSelect = "INSERT INTO OC_CHRONICMEDICATIONS (OC_CHRONICMED_SERVERID,OC_CHRONICMED_OBJECTID,"+
                          "  OC_CHRONICMED_PATIENTUID,OC_CHRONICMED_PRESCRIBERUID,OC_CHRONICMED_PRODUCTUID,"+
                          "  OC_CHRONICMED_BEGIN,OC_CHRONICMED_TIMEUNIT,OC_CHRONICMED_TIMEUNITCOUNT,"+
                          "  OC_CHRONICMED_UNITSPERTIMEUNIT,OC_CHRONICMED_COMMENT,"+
                          "  OC_CHRONICMED_CREATETIME,OC_CHRONICMED_UPDATETIME,OC_CHRONICMED_UPDATEUID,OC_CHRONICMED_VERSION)"+
                          " VALUES(?,?,?,?,?,?,?,?,?,?,?,?,?,1)";

                ps = oc_conn.prepareStatement(sSelect);

                // set new medicationUid
                int serverId = MedwanQuery.getInstance().getConfigInt("serverId");
                int prescrCounter = MedwanQuery.getInstance().getOpenclinicCounter("OC_CHRONICMEDICATIONS");
                ps.setInt(1,serverId);
                ps.setInt(2,prescrCounter);
                this.setUid(serverId+"."+prescrCounter);

                ps.setString(3,this.getPatientUid());
                ps.setString(4,this.getPrescriberUid());
                ps.setString(5,this.getProductUid());

                // date begin
                if(this.begin!=null) ps.setTimestamp(6,new java.sql.Timestamp(this.begin.getTime()));
                else                 ps.setNull(6,Types.TIMESTAMP);

                // rule elements
                if(this.getTimeUnit().length() > 0) ps.setString(7,this.getTimeUnit());
                else                                ps.setNull(7,Types.VARCHAR);

                if(this.getTimeUnitCount() > -1) ps.setInt(8,this.getTimeUnitCount());
                else                             ps.setNull(8,Types.INTEGER);

                if(this.getUnitsPerTimeUnit() > -1) ps.setDouble(9,this.getUnitsPerTimeUnit());
                else                                ps.setNull(9,Types.DOUBLE);

                ps.setString(10,this.getComment());

                // OBJECT variables
                ps.setTimestamp(11,new Timestamp(new java.util.Date().getTime())); // now
                ps.setTimestamp(12,new Timestamp(new java.util.Date().getTime())); // now
                ps.setString(13,this.getUpdateUser());

                ps.executeUpdate();
            }
            else{
                if(!medicationWithSameDataExists){
                    //***** UPDATE *****
                    if(Debug.enabled) Debug.println("@@@ MEDICATION update @@@");

                    sSelect = "UPDATE OC_CHRONICMEDICATIONS SET OC_CHRONICMED_PATIENTUID=?, OC_CHRONICMED_PRESCRIBERUID=?,"+
                              "  OC_CHRONICMED_PRODUCTUID=?, OC_CHRONICMED_BEGIN=?, OC_CHRONICMED_TIMEUNIT=?,"+
                              "  OC_CHRONICMED_TIMEUNITCOUNT=?, OC_CHRONICMED_UNITSPERTIMEUNIT=?, OC_CHRONICMED_COMMENT=?,"+
                              "  OC_CHRONICMED_UPDATETIME=?, OC_CHRONICMED_UPDATEUID=?, OC_CHRONICMED_VERSION=(OC_CHRONICMED_VERSION+1)"+
                              " WHERE OC_CHRONICMED_SERVERID=? AND OC_CHRONICMED_OBJECTID=?";

                    ps = oc_conn.prepareStatement(sSelect);
                    ps.setString(1,this.getPatientUid());
                    ps.setString(2,this.getPrescriberUid());
                    ps.setString(3,this.getProductUid());

                    // date begin
                    if(this.begin!=null) ps.setTimestamp(4,new java.sql.Timestamp(this.begin.getTime()));
                    else                 ps.setNull(4,Types.TIMESTAMP);

                    if(this.getTimeUnit().length() > 0) ps.setString(5,this.getTimeUnit());
                    else                                ps.setNull(5,Types.VARCHAR);

                    if(this.getTimeUnitCount() > -1) ps.setInt(6,this.getTimeUnitCount());
                    else                             ps.setNull(6,Types.INTEGER);

                    if(this.getUnitsPerTimeUnit() > -1) ps.setDouble(7,this.getUnitsPerTimeUnit());
                    else                                ps.setNull(7,Types.DOUBLE);

                    ps.setString(8,this.getComment());

                    // OBJECT variables
                    ps.setTimestamp(9,new Timestamp(new java.util.Date().getTime())); // now
                    ps.setString(10,this.getUpdateUser());

                    ps.setInt(11,Integer.parseInt(this.getUid().substring(0,this.getUid().indexOf("."))));
                    ps.setInt(12,Integer.parseInt(this.getUid().substring(this.getUid().indexOf(".")+1)));

                    ps.executeUpdate();
                }
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
        if(Debug.enabled) Debug.println("@@@ CHRONICMEDICATION exists ? @@@");

        PreparedStatement ps = null;
        ResultSet rs = null;
        String uid = "";

        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            //***** check existence *****
            String sSelect = "SELECT OC_CHRONICMED_SERVERID,OC_CHRONICMED_OBJECTID FROM OC_CHRONICMEDICATIONS"+
                             " WHERE OC_CHRONICMED_PATIENTUID=?"+
                             //"  AND OC_CHRONICMED_PRESCRIBERUID=?"+
                             "  AND OC_CHRONICMED_PRODUCTUID=?"+
                             "  AND OC_CHRONICMED_BEGIN=?";
                             //"  AND OC_CHRONICMED_TIMEUNIT=?"+
                             //"  AND OC_CHRONICMED_TIMEUNITCOUNT=?"+
                             //"  AND OC_CHRONICMED_UNITSPERTIMEUNIT=?"+
                             //"  AND OC_CHRONICMED_COMMENT=?"

            ps = oc_conn.prepareStatement(sSelect);
            int questionmarkIdx = 1;
            ps.setString(questionmarkIdx++,this.getPatientUid());
            //ps.setString(questionmarkIdx++,this.getPrescriberUid());
            ps.setString(questionmarkIdx++,this.getProductUid());

            // date begin
            if(this.begin!=null) ps.setTimestamp(questionmarkIdx++,new java.sql.Timestamp(this.begin.getTime()));
            else                 ps.setNull(questionmarkIdx++,Types.TIMESTAMP);

            //ps.setString(questionmarkIdx++,this.getTimeUnit());
            //ps.setInt(questionmarkIdx++,this.getTimeUnitCount());
            //ps.setDouble(questionmarkIdx++,this.getUnitsPerTimeUnit());

            rs = ps.executeQuery();
            if(rs.next()){
                uid = rs.getInt("OC_CHRONICMED_SERVERID")+"."+rs.getInt("OC_CHRONICMED_OBJECTID");
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
        if(Debug.enabled) Debug.println("@@@ CHRONICMEDICATION changed ? @@@");

        PreparedStatement ps = null;
        ResultSet rs = null;
        boolean changed = true;

        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            //***** check existence *****
            String sSelect = "SELECT OC_CHRONICMED_SERVERID,OC_CHRONICMED_OBJECTID FROM OC_CHRONICMEDICATIONS"+
                             " WHERE OC_CHRONICMED_PATIENTUID=?"+
                             "  AND OC_CHRONICMED_PRESCRIBERUID=?"+
                             "  AND OC_CHRONICMED_PRODUCTUID=?"+
                             "  AND OC_CHRONICMED_BEGIN=?"+
                             "  AND OC_CHRONICMED_TIMEUNIT=?"+
                             "  AND OC_CHRONICMED_TIMEUNITCOUNT=?"+
                             "  AND OC_CHRONICMED_UNITSPERTIMEUNIT=?"+
                             "  AND OC_CHRONICMED_COMMENT=?";

            ps = oc_conn.prepareStatement(sSelect);
            int questionmarkIdx = 1;

            ps.setString(questionmarkIdx++,this.getPatientUid()); // required
            ps.setString(questionmarkIdx++,this.getPrescriberUid()); // required
            ps.setString(questionmarkIdx++,this.getProductUid()); // required

            // date begin
            if(this.begin!=null) ps.setTimestamp(questionmarkIdx++,new java.sql.Timestamp(this.begin.getTime()));
            else                 ps.setNull(questionmarkIdx++,Types.TIMESTAMP);

            // timeUnit
            if(this.getTimeUnit().length() > 0) ps.setString(questionmarkIdx++,this.getTimeUnit());
            else                                ps.setNull(questionmarkIdx++,Types.VARCHAR);

            // timeUnitCount
            if(this.timeUnitCount > -1) ps.setInt(questionmarkIdx++,this.timeUnitCount);
            else                        ps.setNull(questionmarkIdx++,Types.INTEGER);

            // unitsPerTimeUnit
            if(this.unitsPerTimeUnit > -1) ps.setDouble(questionmarkIdx++,this.unitsPerTimeUnit);
            else                           ps.setNull(questionmarkIdx++,Types.DOUBLE);

            // comment
            ps.setString(questionmarkIdx++,this.getComment());

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
    public static void delete(String medicationUid){
        PreparedStatement ps = null;

        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            String sSelect = "DELETE FROM OC_CHRONICMEDICATIONS"+
                             " WHERE OC_CHRONICMED_SERVERID = ? AND OC_CHRONICMED_OBJECTID = ?";
            ps = oc_conn.prepareStatement(sSelect);
            ps.setInt(1,Integer.parseInt(medicationUid.substring(0,medicationUid.indexOf("."))));
            ps.setInt(2,Integer.parseInt(medicationUid.substring(medicationUid.indexOf(".")+1)));
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

    //--- FIND ------------------------------------------------------------------------------------
    public static Vector find(String sFindPatientUid, String sFindPrescriberUid, String sFindProductUid,
                              String sFindDateBegin, String sSortCol, String sSortDir){
        PreparedStatement ps = null;
        ResultSet rs = null;
        Vector foundRecords = new Vector();

        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            String sSelect = "SELECT OC_CHRONICMED_SERVERID,OC_CHRONICMED_OBJECTID"+
                             " FROM OC_CHRONICMEDICATIONS cm, OC_PRODUCTS p "+
                             "  WHERE ";

            // bind the serviceStock table
            String convertServerId = MedwanQuery.getInstance().convert("varchar(16)","p.OC_PRODUCT_SERVERID");
            String convertObjectId = MedwanQuery.getInstance().convert("varchar(16)","p.OC_PRODUCT_OBJECTID");;
            sSelect+= " cm.OC_CHRONICMED_PRODUCTUID = ("+convertServerId+MedwanQuery.getInstance().concatSign()+"'.'"+MedwanQuery.getInstance().concatSign()+convertObjectId+") ";

            // match search criteria

            if(sFindPatientUid.length()>0 || sFindPrescriberUid.length()>0 || sFindProductUid.length()>0 ||
               sFindDateBegin.length()>0){
                sSelect+= "AND ";

                if(sFindPatientUid.length() > 0)    sSelect+= "OC_CHRONICMED_PATIENTUID = ? AND ";
                if(sFindPrescriberUid.length() > 0) sSelect+= "OC_CHRONICMED_PRESCRIBERUID = ? AND ";
                if(sFindProductUid.length() > 0)    sSelect+= "OC_CHRONICMED_PRODUCTUID = ? AND ";
                if(sFindDateBegin.length() > 0)     sSelect+= "OC_CHRONICMED_BEGIN >= ? AND ";

                // remove last AND if any
                if(sSelect.indexOf("AND ")>0){
                    sSelect = sSelect.substring(0,sSelect.lastIndexOf("AND "));
                }
            }

            // order by selected col or default col
            sSelect+= "ORDER BY "+sSortCol+" "+sSortDir;

            // set questionmark values
            ps = oc_conn.prepareStatement(sSelect);
            int questionMarkIdx = 1;
            if(sFindPatientUid.length() > 0)    ps.setString(questionMarkIdx++,sFindPatientUid);
            if(sFindPrescriberUid.length() > 0) ps.setString(questionMarkIdx++,sFindPrescriberUid);
            if(sFindProductUid.length() > 0)    ps.setString(questionMarkIdx++,sFindProductUid);
            if(sFindDateBegin.length() > 0)     ps.setDate(questionMarkIdx++,ScreenHelper.getSQLDate(sFindDateBegin));

            // execute
            rs = ps.executeQuery();
            while(rs.next()){
                foundRecords.add(get(rs.getString("OC_CHRONICMED_SERVERID")+"."+rs.getString("OC_CHRONICMED_OBJECTID")));
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

        return foundRecords;
    }

}
