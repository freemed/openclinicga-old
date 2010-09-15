package be.openclinic.finance;

import be.openclinic.common.OC_Object;
import be.mxs.common.util.db.MedwanQuery;
import be.mxs.common.util.system.Debug;
import be.mxs.common.util.system.ScreenHelper;

import java.util.Date;
import java.util.Vector;
import java.sql.Connection;
import java.sql.PreparedStatement;        
import java.sql.ResultSet;



public class InsurarCredit extends OC_Object {
    private Date date;
    private String invoiceUid;
    private double amount;
    private String type;
    private String comment;
    private String insurarUid;
    private String patientName;
    

    //--- GETTERS && SETTERS ----------------------------------------------------------------------
    public Date getDate() {
        return date;
    }

    public void setDate(Date date) {
        this.date = date;
    }

    public String getInvoiceUid() {
        return invoiceUid;
    }

    public void setInvoiceUid(String invoiceUid) {
        this.invoiceUid = invoiceUid;
    }

    public double getAmount() {
        return amount;
    }

    public void setAmount(double amount) {
        this.amount = amount;
    }

    public String getType() {
        return type;
    }

    public void setType(String type) {
        this.type = type;
    }

    public String getComment() {
        return comment;
    }

    public void setComment(String comment) {
        this.comment = comment;
    }

    public String getInsurarUid() {
        return insurarUid;
    }

    public void setInsurarUid(String insurarUid) {
        this.insurarUid = insurarUid;
    }

    public String getPatientName() {
        return patientName;
    }

    public void setPatientName(String patientName) {
        this.patientName = patientName;
    }

    //--- GET -------------------------------------------------------------------------------------

    public static InsurarCredit get(String uid){
        InsurarCredit insurarcredit = new InsurarCredit();

        if(uid!=null && uid.length()>0){
            String [] ids = uid.split("\\.");

            if (ids.length==2){
                PreparedStatement ps = null;
                ResultSet rs = null;

                Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
                try{
                    String sSelect = "SELECT * FROM OC_INSURARCREDITS WHERE OC_INSURARCREDIT_SERVERID = ? AND OC_INSURARCREDIT_OBJECTID = ?";
                    ps = oc_conn.prepareStatement(sSelect);
                    ps.setInt(1,Integer.parseInt(ids[0]));
                    ps.setInt(2,Integer.parseInt(ids[1]));
                    rs = ps.executeQuery();

                    if(rs.next()){
                        insurarcredit.setUid(uid);
                        insurarcredit.setDate(rs.getTimestamp("OC_INSURARCREDIT_DATE"));
                        insurarcredit.setInvoiceUid(rs.getString("OC_INSURARCREDIT_INVOICEUID"));
                        insurarcredit.setAmount(rs.getDouble("OC_INSURARCREDIT_AMOUNT"));
                        insurarcredit.setType(rs.getString("OC_INSURARCREDIT_TYPE"));
                        insurarcredit.setComment(rs.getString("OC_INSURARCREDIT_COMMENT"));
                        insurarcredit.setInsurarUid(rs.getString("OC_INSURARCREDIT_INSURARUID"));

                        insurarcredit.setCreateDateTime(rs.getTimestamp("OC_INSURARCREDIT_CREATETIME"));
                        insurarcredit.setUpdateDateTime(rs.getTimestamp("OC_INSURARCREDIT_UPDATETIME"));
                        insurarcredit.setUpdateUser(rs.getString("OC_INSURARCREDIT_UPDATEUID"));
                        insurarcredit.setVersion(rs.getInt("OC_INSURARCREDIT_VERSION"));
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
                    catch(Exception e){
                        e.printStackTrace();
                    }
                }
            }
        }

        return insurarcredit;
    }

    public boolean store(int userId){
        boolean bStored = true;
        PreparedStatement ps = null;
        ResultSet rs = null;
        String[] ids;
        boolean recordExists = false;
        String sQuery = "";
        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();

        // get ids if object does not have any
        if(this.getUid()==null || this.getUid().length()==0){
            ids = new String[]{
                      MedwanQuery.getInstance().getConfigString("serverId"),
                      MedwanQuery.getInstance().getOpenclinicCounter("OC_INSURARCREDITS")+""
                  };

            this.setUid(ids[0]+"."+ids[1]);
        }
        else{
            ids = this.getUid().split("\\.");

            // check existence when object allready has ids
            try{
                sQuery = "SELECT * FROM OC_INSURARCREDITS WHERE OC_INSURARCREDIT_SERVERID = ? AND OC_INSURARCREDIT_OBJECTID = ?";
                ps = oc_conn.prepareStatement(sQuery);
                ps.setInt(1,Integer.parseInt(ids[0]));
                ps.setInt(2,Integer.parseInt(ids[1]));
                rs = ps.executeQuery();
                if(rs.next()) recordExists = true;
            }
            catch(Exception e){
                e.printStackTrace();
            }
            finally{
                try{
                    if(rs!=null) rs.close();
                    if(ps!=null) ps.close();
                }
                catch(Exception e){
                    e.printStackTrace();
                }
            }
        }

        //*** SAVE OBJECT ***
        try{
            if(recordExists){
                //*** UPDATE ***
                sQuery = "UPDATE OC_INSURARCREDITS SET"+
                         "  OC_INSURARCREDIT_DATE = ?," +
                         "  OC_INSURARCREDIT_INVOICEUID = ?," +
                         "  OC_INSURARCREDIT_AMOUNT = ?," +
                         "  OC_INSURARCREDIT_TYPE = ?," +
                         "  OC_INSURARCREDIT_COMMENT = ?," +
                         "  OC_INSURARCREDIT_UPDATETIME = ?," +
                         "  OC_INSURARCREDIT_UPDATEUID = ?," +
                         "  OC_INSURARCREDIT_INSURARUID = ?," +
                         "  OC_INSURARCREDIT_VERSION = OC_INSURARCREDIT_VERSION+1" +
                         " WHERE OC_INSURARCREDIT_SERVERID = ? AND OC_INSURARCREDIT_OBJECTID = ?";
                ps = oc_conn.prepareStatement(sQuery);
                ps.setDate(1,new java.sql.Date(this.getDate().getTime()));
                ps.setString(2,this.getInvoiceUid());
                ps.setDouble(3,this.getAmount());
                ps.setString(4,this.getType());
                ps.setString(5,this.getComment());
                ps.setDate(6,new java.sql.Date(new java.util.Date().getTime())); // now
                ps.setInt(7,userId);
                ps.setString(8,this.getInsurarUid());
                ps.setInt(9,Integer.parseInt(ids[0]));
                ps.setInt(10,Integer.parseInt(ids[1]));
                ps.execute();
                ps.close();
            }
            else{
                //*** INSERT ***
                sQuery = "INSERT INTO OC_INSURARCREDITS("+
                         "  OC_INSURARCREDIT_SERVERID,"+
                         "  OC_INSURARCREDIT_OBJECTID,"+
                         "  OC_INSURARCREDIT_DATE," +
                         "  OC_INSURARCREDIT_INVOICEUID," +
                         "  OC_INSURARCREDIT_AMOUNT," +
                         "  OC_INSURARCREDIT_TYPE," +
                         "  OC_INSURARCREDIT_COMMENT," +
                         "  OC_INSURARCREDIT_CREATETIME," +
                         "  OC_INSURARCREDIT_UPDATETIME," +
                         "  OC_INSURARCREDIT_UPDATEUID," +
                         "  OC_INSURARCREDIT_VERSION," +
                         "  OC_INSURARCREDIT_INSURARUID" +
                         " )"+
                         " VALUES(?,?,?,?,?,?,?,?,?,?,1,?)";
                ps = oc_conn.prepareStatement(sQuery);
                ps.setInt(1,Integer.parseInt(ids[0]));
                ps.setInt(2,Integer.parseInt(ids[1]));
                ps.setDate(3,new java.sql.Date(this.getDate().getTime()));
                ps.setString(4,this.getInvoiceUid());
                ps.setDouble(5,this.getAmount());
                ps.setString(6,this.getType());
                ps.setString(7,this.getComment());
                ps.setDate(8,new java.sql.Date(new java.util.Date().getTime())); // now
                ps.setDate(9,new java.sql.Date(new java.util.Date().getTime())); // now
                ps.setInt(10,userId);
                ps.setString(11,this.getInsurarUid());
                ps.execute();
                ps.close();
            }
            //*** update invoice data if an invoice is selected for the this credit ***
            // (credits without an invoice can be attached to an invoice later))
            if(this.getInvoiceUid().length() > 0){
                InsurarInvoice invoice = InsurarInvoice.get(this.getInvoiceUid());
                invoice.setBalance(invoice.getBalance()-this.getAmount());
                invoice.store();
            }
        }
        catch(Exception e){
            e.printStackTrace();
            bStored = false;
            Debug.println("OpenClinic => Debet.java => store => "+e.getMessage()+" = "+sQuery);
        }
        finally{
            try{
                if(rs!=null) rs.close();
                if(ps!=null) ps.close();
                oc_conn.close();
            }
            catch(Exception e){
                e.printStackTrace();
            }
        }

        return bStored;
    }

    public static Vector getInsurarCreditsViaInvoiceUID(String sInvoiceUid){
        String sSelect = "";
        PreparedStatement ps = null;
        ResultSet rs = null;
        Vector vCredits = new Vector();

        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            sSelect = "SELECT * FROM OC_INSURARCREDITS WHERE OC_INSURARCREDIT_INVOICEUID = ?";
            ps = oc_conn.prepareStatement(sSelect);
            ps.setString(1,sInvoiceUid);
            rs = ps.executeQuery();

            while (rs.next()){
                vCredits.add(rs.getInt("OC_INSURARCREDIT_SERVERID")+"."+rs.getInt("OC_INSURARCREDIT_OBJECTID"));
            }
        }
        catch(Exception e){
            e.printStackTrace();
            Debug.println("OpenClinic => InsurarCredit.java => getInsurarCreditsViaInvoiceUID => "+e.getMessage()+" = "+sSelect);
        }
        finally{
            try{
                if(rs!=null)rs.close();
                if(ps!=null)ps.close();
                oc_conn.close();
            }
            catch(Exception e){
                e.printStackTrace();
            }
        }
        return vCredits;
    }

    //--- GET UNASSIGNED INSURAR CREDITS ---------------------------------------------------------- 
    public static Vector getUnassignedInsurarCredits(String sInsurarUid){
        String sSelect = "";
        PreparedStatement ps = null;
        ResultSet rs = null;
        Vector vUnassignedCredits = new Vector();

        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            sSelect = "SELECT * FROM OC_INSURARCREDITS"+
                      " WHERE OC_INSURARCREDIT_INSURARUID = ?"+
                      "  AND (OC_INSURARCREDIT_INVOICEUID IS NULL OR OC_INSURARCREDIT_INVOICEUID='')";
            ps = oc_conn.prepareStatement(sSelect);
            ps.setString(1,sInsurarUid);
            rs = ps.executeQuery();

            while (rs.next()){
                vUnassignedCredits.add(rs.getInt("OC_INSURARCREDIT_SERVERID")+"."+rs.getInt("OC_INSURARCREDIT_OBJECTID"));
            }
        }
        catch(Exception e){
            e.printStackTrace();
            Debug.println("OpenClinic => InsurarCredit.java => getUnassignedInsurarCredits => "+e.getMessage()+" = "+sSelect);
        }
        finally{
            try{
                if(rs!=null)rs.close();
                if(ps!=null)ps.close();
                oc_conn.close();
            }
            catch(Exception e){
                e.printStackTrace();
            }
        }
        return vUnassignedCredits;
    }

    public static Vector getInsurarCredits(String sInsurarUid, String sDateBegin, String sDateEnd, String sAmountMin, String sAmountMax){
        String sSelect = "";
        PreparedStatement ps = null;
        ResultSet rs = null;
        Vector vUnassignedDebets = new Vector();

        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            sSelect = "SELECT * FROM OC_INSURARCREDITS WHERE OC_INSURARCREDIT_INSURARUID = ? ";

            if ((sDateBegin.length()>0)&&(sDateEnd.length()>0)){
                sSelect +=" AND OC_INSURARCREDIT_DATE BETWEEN ? AND ? ";
            }
            else if (sDateBegin.length()>0){
                sSelect +=" AND OC_INSURARCREDIT_DATE >= ?  ";
            }
            else if (sDateEnd.length()>0){
                sSelect +=" AND OC_INSURARCREDIT_DATE <= ?  ";
            }

            if ((sAmountMin.length()>0)&&(sAmountMax.length()>0)){
                sSelect +=" AND OC_INSURARCREDIT_AMOUNT > ? AND OC_INSURARCREDIT_AMOUNT < ? ";
            }
            else if (sAmountMin.length()>0){
                sSelect +=" AND OC_INSURARCREDIT_AMOUNT > ?  ";
            }
            else if (sAmountMax.length()>0){
                sSelect +=" AND OC_INSURARCREDIT_AMOUNT < ?  ";
            }

            System.out.println(sSelect);
            ps = oc_conn.prepareStatement(sSelect);
            ps.setString(1,sInsurarUid);
            int iIndex = 2;
            if ((sDateBegin.length()>0)&&(sDateEnd.length()>0)){
                ps.setDate(iIndex++, ScreenHelper.getSQLDate(sDateBegin));
                ps.setDate(iIndex++, ScreenHelper.getSQLDate(ScreenHelper.getDateAdd(sDateEnd,"1")));
            }
            else if (sDateBegin.length()>0){
                ps.setDate(iIndex++,ScreenHelper.getSQLDate(sDateBegin));
            }
            else if (sDateEnd.length()>0){
                ps.setDate(iIndex++,ScreenHelper.getSQLDate(sDateEnd));
            }

            if ((sAmountMin.length()>0)&&(sAmountMax.length()>0)){
                ps.setDouble(iIndex++,Double.parseDouble(sAmountMin));
                ps.setDouble(iIndex++,Double.parseDouble(sAmountMax));
            }
            else if (sAmountMin.length()>0){
                ps.setDouble(iIndex++,Double.parseDouble(sAmountMin));
            }
            else if (sAmountMax.length()>0){
                ps.setDouble(iIndex++,Double.parseDouble(sAmountMax));
            }

            rs = ps.executeQuery();

            while (rs.next()){
                vUnassignedDebets.add(rs.getInt("OC_INSURARCREDIT_SERVERID")+"."+rs.getInt("OC_INSURARCREDIT_OBJECTID"));
            }
        }
        catch(Exception e){
            e.printStackTrace();
            Debug.println("OpenClinic => InsurarCredit.java => getInsurarCredits => "+e.getMessage()+" = "+sSelect);
        }
        finally{
            try{
                if(rs!=null)rs.close();
                if(ps!=null)ps.close();
                oc_conn.close();
            }
            catch(Exception e){
                e.printStackTrace();
            }
        }
        return vUnassignedDebets;
    }
}
