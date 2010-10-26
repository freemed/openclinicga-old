package be.openclinic.medical;

import be.openclinic.common.OC_Object;
import be.openclinic.common.ObjectReference;
import be.openclinic.pharmacy.Product;
import be.openclinic.pharmacy.ServiceStock;
import be.mxs.common.util.db.MedwanQuery;
import be.mxs.common.util.system.ScreenHelper;
import be.mxs.common.util.system.Debug;
import net.admin.AdminPerson;
import net.admin.Service;

import java.util.Date;
import java.util.Vector;
import java.util.Calendar;
import java.util.GregorianCalendar;
import java.sql.*;
import java.text.SimpleDateFormat;

/**
 * User: Frank Verbeke, Stijn Smets
 * Date: 10-sep-2006
 */
public class Prescription extends OC_Object{
    private AdminPerson patient;
    private AdminPerson prescriber;
    private Product product;
    private Date begin;
    private Date end;
    private String timeUnit; // (Hour|Day|Week|Month)
    private int timeUnitCount = -1;
    private double unitsPerTimeUnit = -1;
    private Service supplyingService;
    private ServiceStock serviceStock;
    private int requiredPackages = -1;

    // non-db data
    private String patientUid;
    private String prescriberUid;
    private String productUid;
    private String supplyingServiceUid;
    private String serviceStockUid;


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
                this.setPrescriber(AdminPerson.getAdminPerson(ad_conn,MedwanQuery.getInstance().getPersonIdFromUserId(Integer.parseInt(prescriberUid))+""));
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

    //--- SUPPLYING SERVICE -----------------------------------------------------------------------
    public Service getSupplyingService() {
        if(supplyingServiceUid!=null && supplyingServiceUid.length() > 0){
            if(supplyingService==null){
                this.setSupplyingService(Service.getService(supplyingServiceUid));
            }
        }

        return supplyingService;
    }

    public void setSupplyingService(Service supplyingService) {
        this.supplyingService = supplyingService;
    }

    //--- SERVICE STOCK ---------------------------------------------------------------------------
    public ServiceStock getServiceStock() {
        if(serviceStockUid!=null && serviceStockUid.length() > 0){
            if(serviceStock==null){
                this.setServiceStock(ServiceStock.get(serviceStockUid));
            }
        }

        return serviceStock;
    }

    public void setServiceStock(ServiceStock serviceStock) {
        this.serviceStock = serviceStock;
    }

    //--- REQUIRED PACKAGES -----------------------------------------------------------------------
    public int getRequiredPackages() {
        return requiredPackages;
    }

    public void setRequiredPackages(int requiredPackages) {
        this.requiredPackages = requiredPackages;
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

    //--- NON-DB DATA : SUPPLYING SERVICE UID -----------------------------------------------------
    public void setSupplyingServiceUid(String uid){
        this.supplyingServiceUid = uid;
    }

    public String getSupplyingServiceUid(){
        return this.supplyingServiceUid;
    }

    //--- NON-DB DATA : SERVICE STOCK UID ---------------------------------------------------------
    public void setServiceStockUid(String uid){
        this.serviceStockUid = uid;
    }

    public String getServiceStockUid(){
        return this.serviceStockUid;
    }

    //--- GET -------------------------------------------------------------------------------------
    public static Prescription get(String prescrUid){
        Prescription prescr = new Prescription();
        prescr.setUid(prescrUid);
        PreparedStatement ps = null;
        ResultSet rs = null;

        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            String sSelect = "SELECT * FROM OC_PRESCRIPTIONS"+
                             " WHERE OC_PRESCR_SERVERID = ? AND OC_PRESCR_OBJECTID = ?";
            ps = oc_conn.prepareStatement(sSelect);
            ps.setInt(1,Integer.parseInt(prescrUid.substring(0,prescrUid.indexOf("."))));
            ps.setInt(2,Integer.parseInt(prescrUid.substring(prescrUid.indexOf(".")+1)));
            rs = ps.executeQuery();

            // get data from DB
            if(rs.next()){
                prescr.setPatientUid(rs.getString("OC_PRESCR_PATIENTUID"));
                prescr.setPrescriberUid(rs.getString("OC_PRESCR_PRESCRIBERUID"));
                prescr.setProductUid(rs.getString("OC_PRESCR_PRODUCTUID"));
                prescr.setSupplyingServiceUid(rs.getString("OC_PRESCR_SUPPLYINGSERVICEUID"));
                prescr.setServiceStockUid(rs.getString("OC_PRESCR_SERVICESTOCKUID"));
                prescr.setRequiredPackages(rs.getInt("OC_PRESCR_REQUIREDPACKAGES"));

                // begin date
                java.util.Date tmpDate = rs.getDate("OC_PRESCR_BEGIN");
                if(tmpDate!=null) prescr.setBegin(tmpDate);

                // end date
                tmpDate = rs.getDate("OC_PRESCR_END");
                if(tmpDate!=null) prescr.setEnd(tmpDate);

                // units
                prescr.setTimeUnit(rs.getString("OC_PRESCR_TIMEUNIT"));
                prescr.setTimeUnitCount(rs.getInt("OC_PRESCR_TIMEUNITCOUNT"));
                prescr.setUnitsPerTimeUnit(rs.getDouble("OC_PRESCR_UNITSPERTIMEUNIT"));

                // OBJECT variables
                prescr.setCreateDateTime(rs.getTimestamp("OC_PRESCR_CREATETIME"));
                prescr.setUpdateDateTime(rs.getTimestamp("OC_PRESCR_UPDATETIME"));
                prescr.setUpdateUser(ScreenHelper.checkString(rs.getString("OC_PRESCR_UPDATEUID")));
                prescr.setVersion(rs.getInt("OC_PRESCR_VERSION"));
            }
            else{
                throw new Exception("ERROR : PRESCRIPTION "+prescrUid+" NOT FOUND");
            }
        }
        catch(Exception e){
            prescr = null;

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

        return prescr;
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
                if(Debug.enabled) Debug.println("@@@ PRECRIPTION insert @@@");

                sSelect = "INSERT INTO OC_PRESCRIPTIONS (OC_PRESCR_SERVERID,OC_PRESCR_OBJECTID,OC_PRESCR_PATIENTUID,"+
                          "  OC_PRESCR_PRESCRIBERUID,OC_PRESCR_PRODUCTUID,OC_PRESCR_BEGIN,OC_PRESCR_END,OC_PRESCR_TIMEUNIT,"+
                          "  OC_PRESCR_TIMEUNITCOUNT,OC_PRESCR_UNITSPERTIMEUNIT,OC_PRESCR_SUPPLYINGSERVICEUID,"+
                          "  OC_PRESCR_SERVICESTOCKUID,OC_PRESCR_REQUIREDPACKAGES,"+
                          "  OC_PRESCR_CREATETIME,OC_PRESCR_UPDATETIME,OC_PRESCR_UPDATEUID,OC_PRESCR_VERSION)"+
                          " VALUES(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,1)";

                ps = oc_conn.prepareStatement(sSelect);

                // set new prescriptionuid
                int serverId = MedwanQuery.getInstance().getConfigInt("serverId");
                int prescrCounter = MedwanQuery.getInstance().getOpenclinicCounter("OC_PRESCRIPTIONS");
                ps.setInt(1,serverId);
                ps.setInt(2,prescrCounter);
                this.setUid(serverId+"."+prescrCounter);

                ps.setString(3,this.getPatientUid());
                ps.setString(4,this.getPrescriberUid());
                ps.setString(5,this.getProductUid());

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

                if(this.getSupplyingServiceUid().length() > 0) ps.setString(11,this.getSupplyingServiceUid());
                else                                           ps.setNull(11,Types.VARCHAR);

                if(this.getServiceStockUid().length() > 0) ps.setString(12,this.getServiceStockUid());
                else                                       ps.setNull(12,Types.VARCHAR);

                if(this.getRequiredPackages() > -1) ps.setDouble(13,this.getRequiredPackages());
                else                                ps.setNull(13,Types.INTEGER);

                // OBJECT variables
                ps.setTimestamp(14,new Timestamp(new java.util.Date().getTime())); // now
                ps.setTimestamp(15,new Timestamp(new java.util.Date().getTime())); // now
                ps.setString(16,this.getUpdateUser());

                ps.executeUpdate();
            }
            else{
                if(!prescrWithSameDataExists){
                    //***** UPDATE *****
                    if(Debug.enabled) Debug.println("@@@ PRECRIPTION update @@@");

                    sSelect = "UPDATE OC_PRESCRIPTIONS SET OC_PRESCR_PATIENTUID=?, OC_PRESCR_PRESCRIBERUID=?,"+
                              "  OC_PRESCR_PRODUCTUID=?, OC_PRESCR_BEGIN=?, OC_PRESCR_END=?, OC_PRESCR_TIMEUNIT=?,"+
                              "  OC_PRESCR_TIMEUNITCOUNT=?, OC_PRESCR_UNITSPERTIMEUNIT=?, OC_PRESCR_SUPPLYINGSERVICEUID=?,"+
                              "  OC_PRESCR_SERVICESTOCKUID=?, OC_PRESCR_REQUIREDPACKAGES=?,"+
                              "  OC_PRESCR_UPDATETIME=?, OC_PRESCR_UPDATEUID=?, OC_PRESCR_VERSION=(OC_PRESCR_VERSION+1)"+
                              " WHERE OC_PRESCR_SERVERID=? AND OC_PRESCR_OBJECTID=?";

                    ps = oc_conn.prepareStatement(sSelect);
                    ps.setString(1,this.getPatientUid());
                    ps.setString(2,this.getPrescriberUid());
                    ps.setString(3,this.getProductUid());

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

                    if(this.getSupplyingServiceUid().length() > 0) ps.setString(9,this.getSupplyingServiceUid());
                    else                                           ps.setNull(9,Types.VARCHAR);

                    if(this.getServiceStockUid().length() > 0) ps.setString(10,this.getServiceStockUid());
                    else                                       ps.setNull(10,Types.VARCHAR);

                    if(this.getRequiredPackages() > -1) ps.setDouble(11,this.getRequiredPackages());
                    else                                ps.setNull(11,Types.INTEGER);

                    // OBJECT variables
                    ps.setTimestamp(12,new Timestamp(new java.util.Date().getTime())); // now
                    ps.setString(13,this.getUpdateUser());

                    ps.setInt(14,Integer.parseInt(this.getUid().substring(0,this.getUid().indexOf("."))));
                    ps.setInt(15,Integer.parseInt(this.getUid().substring(this.getUid().indexOf(".")+1)));

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
        if(Debug.enabled) Debug.println("@@@ PRECRIPTION exists ? @@@");

        PreparedStatement ps = null;
        ResultSet rs = null;
        String uid = "";

        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            //***** check existence *****
            String sSelect = "SELECT OC_PRESCR_SERVERID,OC_PRESCR_OBJECTID FROM OC_PRESCRIPTIONS"+
                             " WHERE OC_PRESCR_PATIENTUID=?"+
                             //"  AND OC_PRESCR_PRESCRIBERUID=?"+
                             "  AND OC_PRESCR_PRODUCTUID=?"+
                             "  AND OC_PRESCR_BEGIN=?"+
                             "  AND OC_PRESCR_END=?";
                             //"  AND OC_PRESCR_TIMEUNIT=?"+
                             //"  AND OC_PRESCR_TIMEUNITCOUNT=?"+
                             //"  AND OC_PRESCR_UNITSPERTIMEUNIT=?"+
                             //"  AND OC_PRESCR_SUPPLYINGSERVICEUID=?"+
                             //"  AND OC_PRESCR_SERVICESTOCKUID=?"+
                             //"  AND OC_PRESCR_REQUIREDPACKAGES=?";

            ps = oc_conn.prepareStatement(sSelect);
            int questionmarkIdx = 1;
            ps.setString(questionmarkIdx++,this.getPatientUid());
            //ps.setString(questionmarkIdx++,this.getPrescriberUid());
            ps.setString(questionmarkIdx++,this.getProductUid());

            // date begin
            if(this.begin!=null) ps.setTimestamp(questionmarkIdx++,new java.sql.Timestamp(this.begin.getTime()));
            else                 ps.setNull(questionmarkIdx++,Types.TIMESTAMP);

            // date end
            if(this.end!=null) ps.setTimestamp(questionmarkIdx++,new java.sql.Timestamp(end.getTime()));
            else               ps.setNull(questionmarkIdx++,Types.TIMESTAMP);

            //ps.setString(questionmarkIdx++,this.getTimeUnit());
            //ps.setInt(questionmarkIdx++,this.getTimeUnitCount());
            //ps.setDouble(questionmarkIdx++,this.getUnitsPerTimeUnit());
            //ps.setString(questionmarkIdx++,this.getSupplyingServiceUid());
            //ps.setString(questionmarkIdx++,this.getServiceStockUid());
            //ps.setInt(questionmarkIdx++,this.getRequiredPackages());

            rs = ps.executeQuery();
            if(rs.next()){
                uid = rs.getInt("OC_PRESCR_SERVERID")+"."+rs.getInt("OC_PRESCR_OBJECTID");
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
        if(Debug.enabled) Debug.println("@@@ PRECRIPTION changed ? @@@");

        PreparedStatement ps = null;
        ResultSet rs = null;
        boolean changed = true;

        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            //***** check existence *****
            String sSelect = "SELECT OC_PRESCR_SERVERID,OC_PRESCR_OBJECTID FROM OC_PRESCRIPTIONS"+
                             " WHERE OC_PRESCR_PATIENTUID=?"+
                             "  AND OC_PRESCR_PRESCRIBERUID=?"+
                             "  AND OC_PRESCR_PRODUCTUID=?"+
                             "  AND OC_PRESCR_BEGIN=?"+
                             "  AND OC_PRESCR_END=?"+
                             "  AND OC_PRESCR_TIMEUNIT=?"+
                             "  AND OC_PRESCR_TIMEUNITCOUNT=?"+
                             "  AND OC_PRESCR_UNITSPERTIMEUNIT=?"+
                             "  AND OC_PRESCR_SUPPLYINGSERVICEUID=?"+
                             "  AND OC_PRESCR_SERVICESTOCKUID=?"+
                             "  AND OC_PRESCR_REQUIREDPACKAGES=?";

            ps = oc_conn.prepareStatement(sSelect);
            int questionmarkIdx = 1;

            ps.setString(questionmarkIdx++,this.getPatientUid()); // required
            ps.setString(questionmarkIdx++,this.getPrescriberUid()); // required
            ps.setString(questionmarkIdx++,this.getProductUid()); // required

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

            // supplyingServiceUid
            if(this.getSupplyingServiceUid().length() > 0) ps.setString(questionmarkIdx++,this.getSupplyingServiceUid());
            else                                           ps.setNull(questionmarkIdx++,Types.VARCHAR);

            // serviceStockUid
            if(this.getServiceStockUid().length() > 0) ps.setString(questionmarkIdx++,this.getServiceStockUid());
            else                                       ps.setNull(questionmarkIdx++,Types.VARCHAR);

            // requiredPackages
            if(this.requiredPackages > -1) ps.setDouble(questionmarkIdx++,this.requiredPackages);
            else                           ps.setNull(questionmarkIdx++,Types.INTEGER);

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
            String sSelect = "DELETE FROM OC_PRESCRIPTIONS"+
                             " WHERE OC_PRESCR_SERVERID = ? AND OC_PRESCR_OBJECTID = ?";
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
        Prescription prescr;
        PreparedStatement ps = null;
        ResultSet rs = null;

        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            String sSelect = "SELECT * FROM OC_PRESCRIPTIONS"+
                             " WHERE OC_PRESCR_PATIENTUID = ? AND (OC_PRESCR_END IS NULL OR OC_PRESCR_END >= ?)";
            ps = oc_conn.prepareStatement(sSelect);
            ps.setString(1,patientuid);
            long latencydays=1000*MedwanQuery.getInstance().getConfigInt("activeMedicationLatency",60);
            latencydays*=24*3600;
        	Timestamp ts = new Timestamp(new SimpleDateFormat("dd/MM/yyyy").parse(new SimpleDateFormat("dd/MM/yyyy").format(new java.util.Date())).getTime()-latencydays);
            ps.setTimestamp(2,ts);
            rs = ps.executeQuery();

            // get data from DB
            while(rs.next()){
                prescr = new Prescription();
                prescr.setUid(rs.getString("OC_PRESCR_SERVERID")+"."+rs.getString("OC_PRESCR_OBJECTID"));

                prescr.setPatientUid(rs.getString("OC_PRESCR_PATIENTUID"));
                prescr.setPrescriberUid(rs.getString("OC_PRESCR_PRESCRIBERUID"));
                prescr.setProductUid(rs.getString("OC_PRESCR_PRODUCTUID"));
                prescr.setSupplyingServiceUid(rs.getString("OC_PRESCR_SUPPLYINGSERVICEUID"));
                prescr.setServiceStockUid(rs.getString("OC_PRESCR_SERVICESTOCKUID"));
                prescr.setRequiredPackages(rs.getInt("OC_PRESCR_REQUIREDPACKAGES"));

                java.util.Date tmpDate = rs.getDate("OC_PRESCR_BEGIN");
                if(tmpDate!=null) prescr.setBegin(tmpDate);

                tmpDate = rs.getDate("OC_PRESCR_END");
                if(tmpDate!=null) prescr.setEnd(tmpDate);

                prescr.setTimeUnit(rs.getString("OC_PRESCR_TIMEUNIT"));
                prescr.setTimeUnitCount(rs.getInt("OC_PRESCR_TIMEUNITCOUNT"));
                prescr.setUnitsPerTimeUnit(rs.getDouble("OC_PRESCR_UNITSPERTIMEUNIT"));

                // object variables
                prescr.setCreateDateTime(rs.getTimestamp("OC_PRESCR_CREATETIME"));
                prescr.setUpdateDateTime(rs.getTimestamp("OC_PRESCR_UPDATETIME"));
                prescr.setUpdateUser(ScreenHelper.checkString(rs.getString("OC_PRESCR_UPDATEUID")));
                prescr.setVersion(rs.getInt("OC_PRESCR_VERSION"));

                activePrescriptions.add(prescr);
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
    public static Vector find(String sFindPatientUid, String sFindPrescriberUid, String sFindProductUid,
                              String sFindDateBegin, String sFindDateEnd, String sFindSupplyingServiceUid,
                              String sSortCol, String sSortDir){
        Vector foundObjects = new Vector();
        PreparedStatement ps = null;
        ResultSet rs = null;

        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            String sSelect = "SELECT OC_PRESCR_SERVERID, OC_PRESCR_OBJECTID"+
                             " FROM OC_PRESCRIPTIONS ";

            if(sFindPatientUid.length()>0 || sFindPrescriberUid.length()>0 || sFindProductUid.length()>0 ||
               sFindDateBegin.length()>0 || sFindDateEnd.length()>0 || sFindSupplyingServiceUid.length()>0){
                sSelect+= "WHERE ";

                if(sFindPatientUid.length() > 0)    sSelect+= "OC_PRESCR_PATIENTUID = ? AND ";
                if(sFindPrescriberUid.length() > 0) sSelect+= "OC_PRESCR_PRESCRIBERUID = ? AND ";
                if(sFindProductUid.length() > 0)    sSelect+= "OC_PRESCR_PRODUCTUID = ? AND ";
                if(sFindDateBegin.length() > 0)     sSelect+= "OC_PRESCR_END >= ? AND ";
                if(sFindDateEnd.length() > 0)       sSelect+= "(OC_PRESCR_BEGIN<= ?) AND ";

                if(sFindSupplyingServiceUid.length() > 0){
                    // search all service and its child-services
                    Vector childIds = Service.getChildIds(sFindSupplyingServiceUid);
                    String sChildIds = ScreenHelper.tokenizeVector(childIds,",","'");
                    if(sChildIds.length() > 0){
                        sSelect+= "OC_PRESCR_SUPPLYINGSERVICEUID IN ("+sChildIds+") AND ";
                    }
                    else{
                        sSelect+= "OC_PRESCR_SUPPLYINGSERVICEUID IN ('') AND ";
                    }
                }

                // remove last AND if any
                if(sSelect.indexOf("AND ")>0){
                    sSelect = sSelect.substring(0,sSelect.lastIndexOf("AND "));
                }
            }

            if(sSortCol.length()==0){
                sSortCol="OC_PRESCR_BEGIN";
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
            if(sFindProductUid.length() > 0)    ps.setString(questionMarkIdx++,sFindProductUid);
            if(sFindDateBegin.length() > 0)     ps.setDate(questionMarkIdx++,ScreenHelper.getSQLDate(sFindDateBegin));
            if(sFindDateEnd.length() > 0)       ps.setDate(questionMarkIdx++,ScreenHelper.getSQLDate(sFindDateEnd));

            // execute
            rs = ps.executeQuery();

            while(rs.next()){
                foundObjects.add(get(rs.getString("OC_PRESCR_SERVERID")+"."+rs.getString("OC_PRESCR_OBJECTID")));
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
    public static Vector findActive(String sFindPatientUid, String sFindPrescriberUid, String sFindProductUid,
                                    String sFindDateBegin, String sFindDateEnd, String sFindSupplyingServiceUid,
                                    String sSortCol, String sSortDir){
        Vector foundObjects = new Vector();
        PreparedStatement ps = null;
        ResultSet rs = null;

        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            // compose query
            String sSelect = "SELECT * FROM OC_PRESCRIPTIONS"+
                             " WHERE (OC_PRESCR_END >= ? OR OC_PRESCR_END IS NULL)"; // difference

            if(sFindPatientUid.length()>0 || sFindPrescriberUid.length()>0 || sFindProductUid.length()>0 ||
               sFindDateBegin.length()>0 || sFindDateEnd.length()>0 || sFindSupplyingServiceUid.length()>0){
                sSelect+= " AND ";

                if(sFindPatientUid.length() > 0)    sSelect+= "OC_PRESCR_PATIENTUID = ? AND ";
                if(sFindPrescriberUid.length() > 0) sSelect+= "OC_PRESCR_PRESCRIBERUID = ? AND ";
                if(sFindProductUid.length() > 0)    sSelect+= "OC_PRESCR_PRODUCTUID = ? AND ";
                if(sFindDateBegin.length() > 0)     sSelect+= "OC_PRESCR_BEGIN <= ? AND ";

                if(sFindSupplyingServiceUid.length() > 0){
                    // search all service and its child-services
                    Vector childIds = Service.getChildIds(sFindSupplyingServiceUid);
                    String sChildIds = ScreenHelper.tokenizeVector(childIds,",","'");
                    if(sChildIds.length() > 0){
                        sSelect+= "OC_PRESCR_SUPPLYINGSERVICEUID IN ("+sChildIds+") AND ";
                    }
                    else{
                        sSelect+= "OC_PRESCR_SUPPLYINGSERVICEUID IN ('') AND ";
                    }
                }

                // remove last AND if any
                if(sSelect.indexOf("AND ")>0){
                    sSelect = sSelect.substring(0,sSelect.lastIndexOf("AND "));
                }
            }

            if(sSortCol.length()==0){
                sSortCol="OC_PRESCR_BEGIN";
            }
            if(sSortDir.length()==0){
                sSortDir="ASC";
            }
            // order by selected col or default col
            sSelect+= "ORDER BY "+sSortCol+" "+sSortDir;
            ps = oc_conn.prepareStatement(sSelect);

            // set questionmark values
            int questionMarkIdx = 1;
            ps.setDate(questionMarkIdx++,new java.sql.Date(new java.util.Date().getTime()));
            if(sFindPatientUid.length() > 0)    ps.setString(questionMarkIdx++,sFindPatientUid);
            if(sFindPrescriberUid.length() > 0) ps.setString(questionMarkIdx++,sFindPrescriberUid);
            if(sFindProductUid.length() > 0)    ps.setString(questionMarkIdx++,sFindProductUid);
            if(sFindDateBegin.length() > 0)     ps.setDate(questionMarkIdx++,ScreenHelper.getSQLDate(sFindDateBegin));

            // execute
            rs = ps.executeQuery();

            while(rs.next()){
                foundObjects.add(get(rs.getString("OC_PRESCR_SERVERID")+"."+rs.getString("OC_PRESCR_OBJECTID")));
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

    //--- GET PRESCRIPTION COUNT FOR PRODUCTSTOCK -------------------------------------------------
    // Count active prescriptions prescribing the specified product taken from the specified sullying service.
    //---------------------------------------------------------------------------------------------
    public static int getPrescrCountForProductStock(String productUid, String supplServiceUid){
        int prescrCount = 0;
        PreparedStatement ps = null;
        ResultSet rs = null;

        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            String sSelect = "SELECT COUNT(*) AS prescrCount FROM OC_PRESCRIPTIONS"+
                             " WHERE OC_PRESCR_PRODUCTUID = ? AND OC_PRESCR_SUPPLYINGSERVICEUID = ?"+
                             "  AND (OC_PRESCR_BEGIN <= ? AND (OC_PRESCR_END IS NULL OR OC_PRESCR_END >= ?))";
            ps = oc_conn.prepareStatement(sSelect);
            ps.setString(1,productUid);
            ps.setString(2,supplServiceUid);
            ps.setDate(3,new java.sql.Date(new java.util.Date().getTime())); // now
            ps.setDate(4,new java.sql.Date(new java.util.Date().getTime())); // now

            // get data from DB
            rs = ps.executeQuery();
            if(rs.next()){
                prescrCount = rs.getInt("prescrCount");
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

        return prescrCount;
    }

    //--- IS ACTIVE -------------------------------------------------------------------------------
    public boolean isActive(){
        boolean isActive = false;

        if(this.getEnd()==null || this.getEnd().after(new java.util.Date())){
            isActive = true;
        }

        return isActive;
    }

    public static Vector getPrescriptionsByPatient(String sPatientUID){
        PreparedStatement ps = null;
        ResultSet rs = null;

        String sSelect = "SELECT * FROM OC_PRESCRIPTIONS"+
                         " WHERE OC_PRESCR_PATIENTUID = ? ORDER BY OC_PRESCR_BEGIN DESC";

        Vector vPrescriptions = new Vector();

        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            ps = oc_conn.prepareStatement(sSelect);
            ps.setString(1,sPatientUID);
            rs = ps.executeQuery();

            Prescription prescr;

            while(rs.next()){
                prescr = new Prescription();

                prescr.setUid(ScreenHelper.checkString(rs.getString("OC_PRESCR_SERVERID")) + "." + ScreenHelper.checkString(rs.getString("OC_PRESCR_OBJECTID")));
                prescr.setPatientUid(rs.getString("OC_PRESCR_PATIENTUID"));
                prescr.setPrescriberUid(rs.getString("OC_PRESCR_PRESCRIBERUID"));
                prescr.setProductUid(rs.getString("OC_PRESCR_PRODUCTUID"));
                prescr.setSupplyingServiceUid(rs.getString("OC_PRESCR_SUPPLYINGSERVICEUID"));
                prescr.setServiceStockUid(rs.getString("OC_PRESCR_SERVICESTOCKUID"));
                prescr.setRequiredPackages(rs.getInt("OC_PRESCR_REQUIREDPACKAGES"));

                // begin date
                java.util.Date tmpDate = rs.getDate("OC_PRESCR_BEGIN");
                if(tmpDate!=null) prescr.setBegin(tmpDate);

                // end date
                tmpDate = rs.getDate("OC_PRESCR_END");
                if(tmpDate!=null) prescr.setEnd(tmpDate);

                // units
                prescr.setTimeUnit(rs.getString("OC_PRESCR_TIMEUNIT"));
                prescr.setTimeUnitCount(rs.getInt("OC_PRESCR_TIMEUNITCOUNT"));
                prescr.setUnitsPerTimeUnit(rs.getDouble("OC_PRESCR_UNITSPERTIMEUNIT"));

                // OBJECT variables
                prescr.setCreateDateTime(rs.getTimestamp("OC_PRESCR_CREATETIME"));
                prescr.setUpdateDateTime(rs.getTimestamp("OC_PRESCR_UPDATETIME"));
                prescr.setUpdateUser(ScreenHelper.checkString(rs.getString("OC_PRESCR_UPDATEUID")));
                prescr.setVersion(rs.getInt("OC_PRESCR_VERSION"));

                vPrescriptions.addElement(prescr);
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

    public static Vector getActivePrescriptionsByPeriodForStock(String sServiceStockUid, Calendar untilDate){
        PreparedStatement ps = null;
        ResultSet rs = null;


        Vector vPrescriptions = new Vector();

        String sSelect =    " SELECT OC_PRESCR_SERVERID, OC_PRESCR_OBJECTID, OC_PRESCR_BEGIN, OC_PRESCR_END," +
                            "       OC_PRESCR_TIMEUNIT, OC_PRESCR_TIMEUNITCOUNT, OC_PRESCR_UNITSPERTIMEUNIT," +
                            "       OC_PRESCR_PRODUCTUID" +
                            " FROM OC_PRESCRIPTIONS " +
                            "  WHERE OC_PRESCR_SERVICESTOCKUID = ?" +
                            "   AND NOT (" +
                            "        (OC_PRESCR_BEGIN < ? AND OC_PRESCR_END < ?)" + // begin < now && end < now == past prescriptions
                            "       OR" +
                            "        (OC_PRESCR_BEGIN > ? AND OC_PRESCR_END > ?)" + // begin > until && end > until == future prescriptions
                            "       )" +
                            "   OR (OC_PRESCR_SERVICESTOCKUID = ? AND (OC_PRESCR_END IS NULL AND OC_PRESCR_BEGIN < ?))"; // end is null && begin < until

        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            Calendar now = new GregorianCalendar();

            ps = oc_conn.prepareStatement(sSelect);

            //*** set questionmarks ***
            int questionMarkIdx = 1;
            ps.setString(questionMarkIdx++, sServiceStockUid);

            // set now with millis = 0
            now.setTime(new java.util.Date());
            now.set(now.get(Calendar.YEAR), now.get(Calendar.MONTH), now.get(Calendar.DATE), 0, 0, 0);
            now.setTimeInMillis(now.getTimeInMillis() - (now.getTimeInMillis() % 1000));
            ps.setTimestamp(questionMarkIdx++, new Timestamp(now.getTimeInMillis())); // begin
            ps.setTimestamp(questionMarkIdx++, new Timestamp(now.getTimeInMillis())); // end

            // set untilDate with millis = 0
            ps.setTimestamp(questionMarkIdx++, new Timestamp(untilDate.getTimeInMillis())); // begin
            ps.setTimestamp(questionMarkIdx++, new Timestamp(untilDate.getTimeInMillis())); // end
            ps.setString(questionMarkIdx++, sServiceStockUid);
            ps.setTimestamp(questionMarkIdx++, new Timestamp(untilDate.getTimeInMillis())); // end

            rs = ps.executeQuery();

            Prescription prescr;
            while(rs.next()){
                prescr = new Prescription();

                prescr.setUid(ScreenHelper.checkString(rs.getString("OC_PRESCR_SERVERID")) + "." + ScreenHelper.checkString(rs.getString("OC_PRESCR_OBJECTID")));;
                prescr.setProductUid(rs.getString("OC_PRESCR_PRODUCTUID"));

                // begin date
                java.util.Date tmpDate = rs.getDate("OC_PRESCR_BEGIN");
                if(tmpDate!=null) prescr.setBegin(tmpDate);

                // end date
                tmpDate = rs.getDate("OC_PRESCR_END");
                if(tmpDate!=null) prescr.setEnd(tmpDate);

                // units
                prescr.setTimeUnit(rs.getString("OC_PRESCR_TIMEUNIT"));
                prescr.setTimeUnitCount(rs.getInt("OC_PRESCR_TIMEUNITCOUNT"));
                prescr.setUnitsPerTimeUnit(rs.getDouble("OC_PRESCR_UNITSPERTIMEUNIT"));

                vPrescriptions.addElement(prescr);
            }



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

    public double getDeliveredQuantity(){
        double quantity=0;
        PreparedStatement ps=null;
        ResultSet rs=null;
        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            String sQuery="select sum(OC_OPERATION_UNITSCHANGED) as total from OC_PRODUCTSTOCKOPERATIONS " +
                    " where OC_OPERATION_DESCRIPTION like 'medicationdelivery%' and OC_OPERATION_PRESCRIPTIONUID=?";
            ps = oc_conn.prepareStatement(sQuery);
            ps.setString(1,getUid());
            rs = ps.executeQuery();
            if(rs.next()){
                quantity=rs.getDouble("total");
            }
        }
        catch(Exception e){
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
        return quantity;
    }

}

