package be.openclinic.finance;

import be.openclinic.common.OC_Object;
import be.openclinic.adt.Encounter;
import be.mxs.common.util.system.ScreenHelper;
import be.mxs.common.util.system.Debug;
import be.mxs.common.util.db.MedwanQuery;

import java.util.Date;
import java.util.Vector;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

import net.admin.AdminPerson;

public class PatientCredit extends OC_Object {
    private Date date;
    private String invoiceUid;
    private double amount;
    private String type;
    private String encounterUid;
    private Encounter encounter;
    private String comment;
    private String sPatientUid;

    public AdminPerson getPatient(){
    	return getEncounter().getPatient();
	}

	public Date getDate(){
        return date;
    }

    public void setDate(Date date){
        this.date = date;
    }

    public String getInvoiceUid(){
        return invoiceUid;
    }

    public void setInvoiceUid(String invoiceUid){
        this.invoiceUid = invoiceUid;
    }

    public double getAmount(){
        return amount;
    }

    public void setAmount(double amount){
        this.amount = amount;
    }

    public String getType(){
        return type;
    }

    public void setType(String type){
        this.type = type;
    }

    public String getEncounterUid(){
        return encounterUid;
    }

    public void setEncounterUid(String encounterUid){
        this.encounterUid = encounterUid;
    }

    public String getComment(){
        return comment;
    }

    public void setComment(String comment){
        this.comment = comment;
    }

    public String getPatientUid(){
        return sPatientUid;
    }

    public void setPatientUid(String sPatientUid){
        this.sPatientUid = sPatientUid;
    }
    
    //--- GET ENCOUNTER ---------------------------------------------------------------------------
    public Encounter getEncounter(){
        if(this.encounter == null){
            if(ScreenHelper.checkString(this.encounterUid).length() > 0){
                this.setEncounter(Encounter.get(this.encounterUid));
            }
            else{
                this.encounter = null;
            }
        }
        return encounter;
    }

    public void setEncounter(Encounter encounter){
        this.encounter = encounter;
    }

    //--- GET PATIENT CREDIT ----------------------------------------------------------------------
    public static PatientCredit get(String uid){
        PatientCredit patientcredit = new PatientCredit();

        if(uid!=null && uid.length()>0){
            String [] ids = uid.split("\\.");

            if (ids.length==2){
                PreparedStatement ps = null;
                ResultSet rs = null;

                Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
                try{
                    String sSelect = "SELECT * FROM OC_PATIENTCREDITS WHERE OC_PATIENTCREDIT_SERVERID = ?"+
                                     " AND OC_PATIENTCREDIT_OBJECTID = ?";
                    ps = oc_conn.prepareStatement(sSelect);
                    ps.setInt(1,Integer.parseInt(ids[0]));
                    ps.setInt(2,Integer.parseInt(ids[1]));
                    rs = ps.executeQuery();

                    if(rs.next()){
                        patientcredit.setUid(uid);
                        patientcredit.setDate(rs.getTimestamp("OC_PATIENTCREDIT_DATE"));
                        patientcredit.setInvoiceUid(rs.getString("OC_PATIENTCREDIT_INVOICEUID"));
                        patientcredit.setAmount(rs.getDouble("OC_PATIENTCREDIT_AMOUNT"));
                        patientcredit.setType(rs.getString("OC_PATIENTCREDIT_TYPE"));
                        patientcredit.setEncounterUid(rs.getString("OC_PATIENTCREDIT_ENCOUNTERUID"));
                        patientcredit.setComment(rs.getString("OC_PATIENTCREDIT_COMMENT"));

                        patientcredit.setCreateDateTime(rs.getTimestamp("OC_PATIENTCREDIT_CREATETIME"));
                        patientcredit.setUpdateDateTime(rs.getTimestamp("OC_PATIENTCREDIT_UPDATETIME"));
                        patientcredit.setUpdateUser(rs.getString("OC_PATIENTCREDIT_UPDATEUID"));
                        patientcredit.setVersion(rs.getInt("OC_PATIENTCREDIT_VERSION"));
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

        return patientcredit;
    }

    //--- GET PATIENT CREDITS VIA INVOICE UID -----------------------------------------------------
    public static Vector getPatientCreditsViaInvoiceUID(String sInvoiceUid){
        String sSelect = "";
        PreparedStatement ps = null;
        ResultSet rs = null;
        Vector vCredits = new Vector();

        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            sSelect = "SELECT * FROM OC_PATIENTCREDITS WHERE OC_PATIENTCREDIT_INVOICEUID = ?"+
                      " ORDER BY OC_PATIENTCREDIT_DATE DESC";
            ps = oc_conn.prepareStatement(sSelect);
            ps.setString(1,sInvoiceUid);
            rs = ps.executeQuery();

            while (rs.next()){
                vCredits.add(rs.getInt("OC_PATIENTCREDIT_SERVERID")+"."+rs.getInt("OC_PATIENTCREDIT_OBJECTID"));
            }
        }
        catch(Exception e){
            e.printStackTrace();
            Debug.println("OpenClinic => PatientCredit.java => getPatientCreditsViaInvoiceUID => "+e.getMessage()+" = "+sSelect);
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

    //--- GET ENCOUNTER CREDITS -------------------------------------------------------------------
    public static Vector getEncounterCredits(String sEncounterUID){
        String sSelect = "";
        PreparedStatement ps = null;
        ResultSet rs = null;
        Vector vUnassignedCredits = new Vector();

        Connection oc_conn = MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            sSelect = "SELECT * FROM OC_PATIENTCREDITS WHERE "
                +" OC_PATIENTCREDIT_ENCOUNTERUID = ? ORDER BY OC_PATIENTCREDIT_DATE DESC";
            ps = oc_conn.prepareStatement(sSelect);
            ps.setString(1,sEncounterUID);
            rs = ps.executeQuery();

            while (rs.next()){
                vUnassignedCredits.add(rs.getInt("OC_PATIENTCREDIT_SERVERID")+"."+rs.getInt("OC_PATIENTCREDIT_OBJECTID"));
            }
        }
        catch(Exception e){
            e.printStackTrace();
            Debug.println("OpenClinic => PatientCredit.java => getUnassignedPatientCredits => "+e.getMessage()+" = "+sSelect);
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

    //--- GET UNASSIGNED PATIENT CREDITS ----------------------------------------------------------
    public static Vector getUnassignedPatientCredits(String sPatientId){
        String sSelect = "";
        PreparedStatement ps = null;
        ResultSet rs = null;
        Vector vUnassignedCredits = new Vector();

        Connection oc_conn = MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            sSelect = "SELECT * FROM OC_ENCOUNTERS e, OC_PATIENTCREDITS d WHERE e.OC_ENCOUNTER_PATIENTUID = ?"+
                      "  AND e.oc_encounter_objectid = replace(d.OC_PATIENTCREDIT_ENCOUNTERUID,'"+ MedwanQuery.getInstance().getConfigString("serverId")+".','')"+
                      "  AND (d.OC_PATIENTCREDIT_INVOICEUID is null or d.OC_PATIENTCREDIT_INVOICEUID='')"+
                      " ORDER BY OC_PATIENTCREDIT_DATE DESC";
            ps = oc_conn.prepareStatement(sSelect);
            ps.setString(1,sPatientId);
            rs = ps.executeQuery();

            while (rs.next()){
                vUnassignedCredits.add(rs.getInt("OC_PATIENTCREDIT_SERVERID")+"."+rs.getInt("OC_PATIENTCREDIT_OBJECTID"));
            }
        }
        catch(Exception e){
            e.printStackTrace();
            Debug.println("OpenClinic => PatientCredit.java => getUnassignedPatientCredits => "+e.getMessage()+" = "+sSelect);
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

    //--- STORE -----------------------------------------------------------------------------------
    public void store(){
        PreparedStatement ps = null;
        ResultSet rs = null;
        String[] ids;
        boolean recordExists = false;
        String sQuery;
        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();

        // get ids if object does not have any
        if(this.getUid()==null || this.getUid().length()==0){
            ids = new String[]{
                      MedwanQuery.getInstance().getConfigString("serverId"),
                      MedwanQuery.getInstance().getOpenclinicCounter("OC_PATIENTCREDITS")+""
                  };

            this.setUid(ids[0]+"."+ids[1]);
        }
        else{
            ids = this.getUid().split("\\.");

            // check existence when object allready has ids
            try{
                sQuery = "SELECT * FROM OC_PATIENTCREDITS"+
                         " WHERE OC_PATIENTCREDIT_SERVERID = ? AND OC_PATIENTCREDIT_OBJECTID = ?";
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
                sQuery = "UPDATE OC_PATIENTCREDITS SET"+
                         "  OC_PATIENTCREDIT_DATE = ?," +
                         "  OC_PATIENTCREDIT_INVOICEUID = ?," +
                         "  OC_PATIENTCREDIT_AMOUNT = ?," +
                         "  OC_PATIENTCREDIT_TYPE = ?," +
                         "  OC_PATIENTCREDIT_ENCOUNTERUID = ?," +
                         "  OC_PATIENTCREDIT_COMMENT = ?," +
                         "  OC_PATIENTCREDIT_UPDATETIME = ?," +
                         "  OC_PATIENTCREDIT_UPDATEUID = ?," +
                         "  OC_PATIENTCREDIT_VERSION = OC_PATIENTCREDIT_VERSION+1" +
                         " WHERE OC_PATIENTCREDIT_SERVERID = ? AND OC_PATIENTCREDIT_OBJECTID = ?";
                ps = oc_conn.prepareStatement(sQuery);
                ps.setDate(1,new java.sql.Date(this.getDate().getTime()));
                ps.setString(2,this.getInvoiceUid());
                ps.setDouble(3,this.getAmount());
                ps.setString(4,this.getType());
                ps.setString(5,this.getEncounterUid());
                ps.setString(6,this.getComment());
                ps.setTimestamp(7,new java.sql.Timestamp(new Date().getTime())); // now
                ps.setString(8,this.getUpdateUser());
                ps.setInt(9,Integer.parseInt(ids[0]));
                ps.setInt(10,Integer.parseInt(ids[1]));
                ps.execute();
                ps.close();
            }
            else{
                //*** INSERT ***
                sQuery = "INSERT INTO OC_PATIENTCREDITS("+
                         "  OC_PATIENTCREDIT_SERVERID,"+
                         "  OC_PATIENTCREDIT_OBJECTID,"+
                         "  OC_PATIENTCREDIT_DATE," +
                         "  OC_PATIENTCREDIT_INVOICEUID," +
                         "  OC_PATIENTCREDIT_AMOUNT," +
                         "  OC_PATIENTCREDIT_TYPE," +
                         "  OC_PATIENTCREDIT_ENCOUNTERUID," +
                         "  OC_PATIENTCREDIT_COMMENT," +
                         "  OC_PATIENTCREDIT_CREATETIME," +
                         "  OC_PATIENTCREDIT_UPDATETIME," +
                         "  OC_PATIENTCREDIT_UPDATEUID," +
                         "  OC_PATIENTCREDIT_VERSION" +
                         " )"+
                         " VALUES(?,?,?,?,?,?,?,?,?,?,?,1)";
                ps = oc_conn.prepareStatement(sQuery);
                while(!MedwanQuery.getInstance().validateNewOpenclinicCounter("OC_PATIENTCREDITS","OC_PATIENTCREDIT_OBJECTID",ids[1])){
                    ids[1] = MedwanQuery.getInstance().getOpenclinicCounter("OC_PATIENTCREDITS") + "";
                }
                ps.setInt(1,Integer.parseInt(ids[0]));
                ps.setInt(2,Integer.parseInt(ids[1]));
                ps.setDate(3,new java.sql.Date(this.getDate().getTime()));
                ps.setString(4,this.getInvoiceUid());
                ps.setDouble(5,this.getAmount());
                ps.setString(6,this.getType());
                ps.setString(7,this.getEncounterUid());
                ps.setString(8,this.getComment());
                ps.setTimestamp(9,new java.sql.Timestamp(new Date().getTime())); // now
                ps.setTimestamp(10,new java.sql.Timestamp(new Date().getTime())); // now
                ps.setString(11,this.getUpdateUser());
                ps.execute();
                ps.close();
                this.setUid(Integer.parseInt(ids[0])+"."+Integer.parseInt(ids[1]));
            }

            //*** update invoice data if an invoice is selected for the this credit ***
            // (credits without an invoice can be attached to an invoice later))
            if(this.getInvoiceUid()!=null && this.getInvoiceUid().length() > 0){
                PatientInvoice invoice = PatientInvoice.get(this.getInvoiceUid());
                invoice.setBalance(invoice.getBalance()-this.getAmount());
                if(invoice.getBalance()>0 && invoice.getBalance()<Double.parseDouble(MedwanQuery.getInstance().getConfigString("minimumInvoiceBalance","1"))){
                	invoice.setBalance(0);
                }
                if(invoice.getBalance()==0){
                    invoice.setStatus(MedwanQuery.getInstance().getConfigString("patientInvoiceClosedStatus","closed"));
                }
                invoice.store();
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

    //--- DELETE PATIENT INVOICE REDUCTIONS -------------------------------------------------------
    public static void deletePatientInvoiceReductions(String patientInvoiceUid){
        Connection oc_conn = MedwanQuery.getInstance().getOpenclinicConnection();
        PreparedStatement ps = null;
        
        try{
        	ps = oc_conn.prepareStatement("DELETE FROM OC_PATIENTCREDITS"+
                                          " WHERE OC_PATIENTCREDIT_INVOICEUID = ?"+
                                          "  AND OC_PATIENTCREDIT_TYPE = 'reduction'");
        	ps.setString(1, patientInvoiceUid);
        	ps.execute();
        	ps.close();
        	
        	ps = oc_conn.prepareStatement("DELETE FROM OC_PATIENTCREDITS"+
        	                              " WHERE OC_PATIENTCREDIT_INVOICEUID IS NULL"+
        	                              "  AND OC_PATIENTCREDIT_TYPE = 'reduction'");
        	ps.execute();
        }
        catch(Exception e){
        	e.printStackTrace();
        }
        finally{
            try{
                if(ps!=null)ps.close();
                oc_conn.close();
            }
            catch(Exception e){
                e.printStackTrace();
            }
        }
    }
    
    //--- GET PATIENT CREDITS ---------------------------------------------------------------------
    public static Vector getPatientCredits(String sPatientUid){
        return getPatientCredits(sPatientUid,"","","","");   	
    }
    public static Vector getPatientCredits(String sPatientUid, String sDateBegin, String sDateEnd){
        return getPatientCredits(sPatientUid,sDateBegin,sDateEnd,"","");   	
    }
    
    public static Vector getPatientCredits(String sPatientUid, String sDateBegin, String sDateEnd, String sAmountMin, String sAmountMax){
        String sSelect = "";
        PreparedStatement ps = null;
        ResultSet rs = null;
        Vector vUnassignedCredits = new Vector();

        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            sSelect = "SELECT DISTINCT oc_patientcredit_objectid, a.* FROM OC_PATIENTCREDITS a,OC_ENCOUNTERS b WHERE "
                    +" a.OC_PATIENTCREDIT_ENCOUNTERUID = "+ MedwanQuery.getInstance().convert("varchar(10)","b.oc_encounter_serverid")+MedwanQuery.getInstance().concatSign()+"'.'"+MedwanQuery.getInstance().concatSign()+ MedwanQuery.getInstance().convert("varchar(10)","b.oc_encounter_objectid")
                    +" AND b.OC_ENCOUNTER_PATIENTUID = ? ";
            if ((sDateBegin.length()>0)&&(sDateEnd.length()>0)){
                sSelect +=" AND OC_PATIENTCREDIT_DATE BETWEEN ? AND ? ";
            }
            else if (sDateBegin.length()>0){
                sSelect +=" AND OC_PATIENTCREDIT_DATE >= ?  ";
            }
            else if (sDateEnd.length()>0){
                sSelect +=" AND OC_PATIENTCREDIT_DATE <= ?  ";
            }

            if ((sAmountMin.length()>0)&&(sAmountMax.length()>0)){
                sSelect +=" AND OC_PATIENTCREDIT_AMOUNT > ? AND OC_PATIENTCREDIT_AMOUNT < ? ";
            }
            else if (sAmountMin.length()>0){
                sSelect +=" AND OC_PATIENTCREDIT_AMOUNT > ?  ";
            }
            else if (sAmountMax.length()>0){
                sSelect +=" AND OC_PATIENTCREDIT_AMOUNT < ?  ";
            }
           
            ps = oc_conn.prepareStatement(sSelect);
            ps.setString(1,sPatientUid);
            int iIndex = 2;
            if ((sDateBegin.length()>0)&&(sDateEnd.length()>0)){
                ps.setDate(iIndex++,ScreenHelper.getSQLDate(sDateBegin));
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
                vUnassignedCredits.add(rs.getInt("OC_PATIENTCREDIT_SERVERID")+"."+rs.getInt("OC_PATIENTCREDIT_OBJECTID"));
            }
        }
        catch(Exception e){
            e.printStackTrace();
            Debug.println("OpenClinic => PatientCredit.java => getPatientCredits => "+e.getMessage()+" = "+sSelect);
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
    
}

