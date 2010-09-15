package be.openclinic.finance;

import net.admin.AdminPerson;

import java.util.Vector;
import java.util.Date;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.text.SimpleDateFormat;

import be.mxs.common.util.system.ScreenHelper;
import be.mxs.common.util.system.Debug;
import be.mxs.common.util.db.MedwanQuery;

public class PatientInvoice extends Invoice {
    private String patientUid;
    private AdminPerson patient;

    //--- S/GET PATIENT UID -----------------------------------------------------------------------
    public void setPatientUid(String patientUid) {
        this.patientUid = patientUid;
    }

    public String getPatientUid() {
        return patientUid;
    }

    //--- S/GET PATIENT ---------------------------------------------------------------------------
    public void setPatient(AdminPerson patient) {
        this.patient = patient;
    }

    public AdminPerson getPatient() {
        if(patient==null){
            if(ScreenHelper.checkString(patientUid).length()>0){
            	Connection ad_conn = MedwanQuery.getInstance().getAdminConnection();
                patient=AdminPerson.getAdminPerson(ad_conn,patientUid);
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

    public double getBalance(){
        double b=0;
        if(getDebets()==null){
            debets = Debet.getPatientDebetsViaInvoiceUid(getPatientUid(),getUid());
        }
        for(int n=0;n<getDebets().size();n++){
            Debet debet = (Debet)getDebets().elementAt(n);
            b+=debet.getAmount();
        }
        if(getCredits()==null){
            credits = PatientCredit.getPatientCreditsViaInvoiceUID(getUid());
        }
        for(int n=0;n<getCredits().size();n++){
            PatientCredit credit = PatientCredit.get((String)getCredits().elementAt(n));
            b-=credit.getAmount();
        }
        return b;
    }

    //--- GET -------------------------------------------------------------------------------------
    public static PatientInvoice get(String uid){
        PatientInvoice patientInvoice = new PatientInvoice();

        if(uid!=null && uid.length()>0){
            String [] ids = uid.split("\\.");

            if (ids.length==2){
                PreparedStatement ps = null;
                ResultSet rs = null;
                String sSelect = "SELECT * FROM OC_PATIENTINVOICES WHERE OC_PATIENTINVOICE_SERVERID = ? AND OC_PATIENTINVOICE_OBJECTID = ?";
                Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
                try{
                    ps = oc_conn.prepareStatement(sSelect);
                    ps.setInt(1,Integer.parseInt(ids[0]));
                    ps.setInt(2,Integer.parseInt(ids[1]));
                    rs = ps.executeQuery();

                    if(rs.next()){
                        patientInvoice.setUid(uid);
                        patientInvoice.setDate(rs.getTimestamp("OC_PATIENTINVOICE_DATE"));
                        patientInvoice.setInvoiceUid(rs.getInt("OC_PATIENTINVOICE_ID")+"");
                        patientInvoice.setPatientUid(rs.getString("OC_PATIENTINVOICE_PATIENTUID"));
                        patientInvoice.setCreateDateTime(rs.getTimestamp("OC_PATIENTINVOICE_CREATETIME"));
                        patientInvoice.setUpdateDateTime(rs.getTimestamp("OC_PATIENTINVOICE_UPDATETIME"));
                        patientInvoice.setUpdateUser(rs.getString("OC_PATIENTINVOICE_UPDATEUID"));
                        patientInvoice.setVersion(rs.getInt("OC_PATIENTINVOICE_VERSION"));
                        patientInvoice.setBalance(rs.getDouble("OC_PATIENTINVOICE_BALANCE"));
                        patientInvoice.setStatus(rs.getString("OC_PATIENTINVOICE_STATUS"));
                    }
                    rs.close();
                    ps.close();

                    patientInvoice.debets = Debet.getPatientDebetsViaInvoiceUid(patientInvoice.getPatientUid(),patientInvoice.getUid());
                    patientInvoice.credits = PatientCredit.getPatientCreditsViaInvoiceUID(patientInvoice.getUid());
                }
                catch(Exception e){
                    Debug.println("OpenClinic => PatientInvoice.java => get => "+e.getMessage());
                    e.printStackTrace();
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
            }
        }
        return patientInvoice;
    }

    public static PatientInvoice getViaInvoiceUID(String sInvoiceID){
        PatientInvoice patientInvoice = new PatientInvoice();

        PreparedStatement ps = null;
        ResultSet rs = null;

        String sSelect = "SELECT * FROM OC_PATIENTINVOICES WHERE OC_PATIENTINVOICE_OBJECTID = ? ";
        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            ps = oc_conn.prepareStatement(sSelect);
            ps.setInt(1,Integer.parseInt(sInvoiceID));
            rs = ps.executeQuery();
            if(rs.next()){
                patientInvoice.setUid(rs.getInt("OC_PATIENTINVOICE_SERVERID")+"."+rs.getInt("OC_PATIENTINVOICE_OBJECTID"));
                patientInvoice.setDate(rs.getTimestamp("OC_PATIENTINVOICE_DATE"));
                patientInvoice.setInvoiceUid(rs.getInt("OC_PATIENTINVOICE_ID")+"");
                patientInvoice.setPatientUid(rs.getString("OC_PATIENTINVOICE_PATIENTUID"));
                patientInvoice.setCreateDateTime(rs.getTimestamp("OC_PATIENTINVOICE_CREATETIME"));
                patientInvoice.setUpdateDateTime(rs.getTimestamp("OC_PATIENTINVOICE_UPDATETIME"));
                patientInvoice.setUpdateUser(rs.getString("OC_PATIENTINVOICE_UPDATEUID"));
                patientInvoice.setVersion(rs.getInt("OC_PATIENTINVOICE_VERSION"));
                patientInvoice.setBalance(rs.getDouble("OC_PATIENTINVOICE_BALANCE"));
                patientInvoice.setStatus(rs.getString("OC_PATIENTINVOICE_STATUS"));
            }
            rs.close();
            ps.close();

            patientInvoice.debets = Debet.getPatientDebetsViaInvoiceUid(patientInvoice.getPatientUid(),patientInvoice.getUid());
            patientInvoice.credits = PatientCredit.getPatientCreditsViaInvoiceUID(patientInvoice.getUid());
        }
        catch(Exception e){
            Debug.println("OpenClinic => PatientInvoice.java => getViaInvoiceUID => "+e.getMessage());
            e.printStackTrace();
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
        return patientInvoice;
    }

    public Vector getDebetStrings(){
        Vector d = new Vector();
        if(debets!=null){
            for(int n=0;n<debets.size();n++){
                d.add(((Debet)debets.elementAt(n)).getUid());
            }
        }
        return d;
    }

    public boolean store(){
        boolean bStored = true;
        String ids[];
        int iVersion = 1;
        PreparedStatement ps = null;
        ResultSet rs = null;
        String sSelect = "";
        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            if(this.getUid()!=null && this.getUid().length() > 0){
                ids = this.getUid().split("\\.");

                if(ids.length == 2){
                    sSelect = "SELECT OC_PATIENTINVOICE_VERSION FROM OC_PATIENTINVOICES WHERE OC_PATIENTINVOICE_SERVERID = ? AND OC_PATIENTINVOICE_OBJECTID = ?";
                    ps = oc_conn.prepareStatement(sSelect);
                    ps.setInt(1,Integer.parseInt(ids[0]));
                    ps.setInt(2,Integer.parseInt(ids[1]));
                    rs = ps.executeQuery();

                    if(rs.next()) {
                        iVersion = rs.getInt("OC_PATIENTINVOICE_VERSION") + 1;
                    }

                    rs.close();
                    ps.close();

                    sSelect = "INSERT INTO OC_PATIENTINVOICES_HISTORY SELECT * FROM OC_PATIENTINVOICES WHERE OC_PATIENTINVOICE_SERVERID = ? AND OC_PATIENTINVOICE_OBJECTID = ?";
                    ps = oc_conn.prepareStatement(sSelect);
                    ps.setInt(1,Integer.parseInt(ids[0]));
                    ps.setInt(2,Integer.parseInt(ids[1]));
                    ps.executeUpdate();
                    ps.close();

                    sSelect = " DELETE FROM OC_PATIENTINVOICES WHERE OC_PATIENTINVOICE_SERVERID = ? AND OC_PATIENTINVOICE_OBJECTID = ?";
                    ps = oc_conn.prepareStatement(sSelect);
                    ps.setInt(1,Integer.parseInt(ids[0]));
                    ps.setInt(2,Integer.parseInt(ids[1]));
                    ps.executeUpdate();
                    ps.close();
                }
                else{
                    ids = new String[] {MedwanQuery.getInstance().getConfigString("serverId"),MedwanQuery.getInstance().getOpenclinicCounter("OC_INVOICES")+""};
                    this.setUid(ids[0]+"."+ids[1]);
                    this.setInvoiceUid(ids[1]);
                }
            }
            else{
                ids = new String[] {MedwanQuery.getInstance().getConfigString("serverId"),MedwanQuery.getInstance().getOpenclinicCounter("OC_INVOICES")+""};
                this.setUid(ids[0]+"."+ids[1]);
                this.setInvoiceUid(ids[1]);
            }

            if(ids.length == 2){
               sSelect = " INSERT INTO OC_PATIENTINVOICES (" +
                          " OC_PATIENTINVOICE_SERVERID," +
                          " OC_PATIENTINVOICE_OBJECTID," +
                          " OC_PATIENTINVOICE_DATE," +
                          " OC_PATIENTINVOICE_ID," +
                          " OC_PATIENTINVOICE_PATIENTUID," +
                          " OC_PATIENTINVOICE_CREATETIME," +
                          " OC_PATIENTINVOICE_UPDATETIME," +
                          " OC_PATIENTINVOICE_UPDATEUID," +
                          " OC_PATIENTINVOICE_VERSION," +
                          " OC_PATIENTINVOICE_BALANCE," +
                          " OC_PATIENTINVOICE_STATUS" +
                        ") " +
                         " VALUES(?,?,?,?,?,?,?,?,?,?,?)";
                ps = oc_conn.prepareStatement(sSelect);
                while(!MedwanQuery.getInstance().validateNewOpenclinicCounter("OC_PATIENTINVOICES","OC_PATIENTINVOICE_OBJECTID",ids[1])){
                    ids[1] = MedwanQuery.getInstance().getOpenclinicCounter("OC_INVOICES") + "";
                }
                ps.setInt(1,Integer.parseInt(ids[0]));
                ps.setInt(2,Integer.parseInt(ids[1]));
                ps.setTimestamp(3,new Timestamp(this.getDate().getTime()));
                ps.setInt(4,Integer.parseInt(this.getInvoiceUid()));
                ps.setString(5,this.getPatientUid());
                ps.setTimestamp(6,new Timestamp(this.getCreateDateTime().getTime()));
                ps.setTimestamp(7,new Timestamp(this.getUpdateDateTime().getTime()));
                ps.setString(8,this.getUpdateUser());
                ps.setInt(9,iVersion);
                ps.setDouble(10,this.getBalance());
                ps.setString(11,this.getStatus());
                ps.executeUpdate();
                ps.close();

                sSelect = "UPDATE OC_DEBETS SET OC_DEBET_PATIENTINVOICEUID = NULL WHERE OC_DEBET_PATIENTINVOICEUID = ?";
                ps = oc_conn.prepareStatement(sSelect);
                ps.setString(1,this.getUid());
                ps.executeUpdate();
                ps.close();

                if (this.debets!=null){
                    String sDebetUID;
                    String[] aDebetUID;

                    for (int i=0;i<this.debets.size();i++){
                        sDebetUID = ScreenHelper.checkString(((Debet)this.debets.elementAt(i)).getUid());

                        if (sDebetUID.length()>0){
                            aDebetUID = sDebetUID.split("\\.");

                            if (aDebetUID.length==2){
                                sSelect = "UPDATE OC_DEBETS SET OC_DEBET_PATIENTINVOICEUID = ? WHERE OC_DEBET_SERVERID = ? AND OC_DEBET_OBJECTID = ? ";
                                ps = oc_conn.prepareStatement(sSelect);
                                ps.setString(1,this.getUid());
                                ps.setInt(2,Integer.parseInt(aDebetUID[0]));
                                ps.setInt(3,Integer.parseInt(aDebetUID[1]));
                                ps.executeUpdate();
                                ps.close();
                            }
                        }
                    }
                }

                sSelect = "UPDATE OC_PATIENTCREDITS SET OC_PATIENTCREDIT_INVOICEUID = NULL WHERE OC_PATIENTCREDIT_INVOICEUID = ? ";
                ps = oc_conn.prepareStatement(sSelect);
                ps.setString(1,this.getUid());
                ps.executeUpdate();
                ps.close();

                if (this.credits!=null){
                    String sCreditUID;
                    String[] aCreditUID;

                    for (int i=0;i<this.credits.size();i++){
                        sCreditUID = ScreenHelper.checkString((String)this.credits.elementAt(i));

                        if (sCreditUID.length()>0){
                            aCreditUID = sCreditUID.split("\\.");

                            if (aCreditUID.length==2){
                                sSelect = "UPDATE OC_PATIENTCREDITS SET OC_PATIENTCREDIT_INVOICEUID = ? WHERE OC_PATIENTCREDIT_SERVERID = ? AND OC_PATIENTCREDIT_OBJECTID = ? ";
                                ps = oc_conn.prepareStatement(sSelect);
                                ps.setString(1,this.getUid());
                                ps.setInt(2,Integer.parseInt(aCreditUID[0]));
                                ps.setInt(3,Integer.parseInt(aCreditUID[1]));
                                ps.executeUpdate();
                                ps.close();
                            }
                        }
                    }
                }
            }
        }
        catch(Exception e){
            e.printStackTrace();
            bStored = false;
            Debug.println("OpenClinic => PatientInvoice.java => store => "+e.getMessage()+" = "+sSelect);
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
        return bStored;
    }

    //--- SEARCH INVOICES -------------------------------------------------------------------------
    public static Vector searchInvoices(String sInvoiceDate, String sInvoiceNr, String sInvoicePatientUid, String sInvoiceStatus){
        return searchInvoices(sInvoiceDate,sInvoiceNr,sInvoicePatientUid,sInvoiceStatus,"","");
    }

    public static Vector searchInvoices(String sInvoiceDate, String sInvoiceNr, String sInvoicePatientUid,
                                        String sInvoiceStatus, String sInvoiceBalanceMin, String sInvoiceBalanceMax){
        Vector invoices = new Vector();
        PreparedStatement ps = null;
        ResultSet rs = null;

        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            // compose query
            String sSql = "SELECT * FROM OC_PATIENTINVOICES";
            if(sInvoiceDate.length() > 0){
                if(sSql.indexOf("WHERE")<0) sSql+= " WHERE";
                sSql+= " OC_PATIENTINVOICE_DATE = ? AND";
            }
            if(sInvoiceNr.length() > 0){
                if(sSql.indexOf("WHERE")<0) sSql+= " WHERE";
                sSql+= " OC_PATIENTINVOICE_OBJECTID = ? AND";
            }
            if(sInvoicePatientUid.length() > 0){
                if(sSql.indexOf("WHERE")<0) sSql+= " WHERE";
                sSql+= " OC_PATIENTINVOICE_PATIENTUID = ? AND";
            }
            if(sInvoiceStatus.length() > 0){
                if(sSql.indexOf("WHERE")<0) sSql+= " WHERE";
                sSql+= " OC_PATIENTINVOICE_STATUS = ? AND";
            }

            // balance range
            if(sInvoiceBalanceMin.length() > 0 && sInvoiceBalanceMax.length() > 0){
                sSql+= " (OC_PATIENTINVOICE_BALANCE >= ? AND OC_PATIENTINVOICE_BALANCE < ?)";
            }
            else if(sInvoiceBalanceMin.length() > 0){
                sSql+= " OC_PATIENTINVOICE_BALANCE >= ?";
            }
            else if(sInvoiceBalanceMax.length() > 0){
                sSql+= " OC_PATIENTINVOICE_BALANCE < ?";
            }
            else{
                // remove last AND
                if(sSql.endsWith("AND")){
                    sSql = sSql.substring(0,sSql.length()-3);
                }
            }

            sSql+= " ORDER BY OC_PATIENTINVOICE_DATE DESC,OC_PATIENTINVOICE_OBJECTID DESC";

            ps = oc_conn.prepareStatement(sSql);

            // set question marks
            int qmIdx = 1;
            SimpleDateFormat stdDateFormat = new SimpleDateFormat("dd/MM/yyyy");
            if(sInvoiceNr.length() > 0) ps.setInt(qmIdx++,Integer.parseInt(sInvoiceNr));
            if(sInvoiceDate.length() > 0) ps.setDate(qmIdx++,new java.sql.Date(stdDateFormat.parse(sInvoiceDate).getTime()));
            if(sInvoicePatientUid.length() > 0) ps.setString(qmIdx++,sInvoicePatientUid);
            if(sInvoiceStatus.length() > 0) ps.setString(qmIdx++,sInvoiceStatus);
            if(sInvoiceBalanceMin.length() > 0) ps.setDouble(qmIdx++,Double.parseDouble(sInvoiceBalanceMin));
            if(sInvoiceBalanceMax.length() > 0) ps.setDouble(qmIdx,Double.parseDouble(sInvoiceBalanceMax));

            rs = ps.executeQuery();

            PatientInvoice patientInvoice;
            while(rs.next()){
                patientInvoice = new PatientInvoice();

                patientInvoice.setUid(rs.getInt("OC_PATIENTINVOICE_SERVERID")+"."+rs.getInt("OC_PATIENTINVOICE_OBJECTID"));
                patientInvoice.setDate(rs.getTimestamp("OC_PATIENTINVOICE_DATE"));
                patientInvoice.setInvoiceUid(rs.getInt("OC_PATIENTINVOICE_ID")+"");
                patientInvoice.setPatientUid(rs.getString("OC_PATIENTINVOICE_PATIENTUID"));
                patientInvoice.setCreateDateTime(rs.getTimestamp("OC_PATIENTINVOICE_CREATETIME"));
                patientInvoice.setUpdateDateTime(rs.getTimestamp("OC_PATIENTINVOICE_UPDATETIME"));
                patientInvoice.setUpdateUser(rs.getString("OC_PATIENTINVOICE_UPDATEUID"));
                patientInvoice.setVersion(rs.getInt("OC_PATIENTINVOICE_VERSION"));
                patientInvoice.setBalance(rs.getDouble("OC_PATIENTINVOICE_BALANCE"));
                patientInvoice.setStatus(rs.getString("OC_PATIENTINVOICE_STATUS"));

                invoices.add(patientInvoice);
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

        return invoices;
    }

    public static Vector searchInvoices(String sInvoiceDateBegin, String sInvoiceDateEnd, String sInvoiceNr, String sInvoiceBalanceMin, String sInvoiceBalanceMax){
        Vector invoices = new Vector();
        PreparedStatement ps = null;
        ResultSet rs = null;

        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            // compose query
            String sSql = "SELECT * FROM OC_PATIENTINVOICES WHERE";

            if(sInvoiceDateBegin.length() > 0){
                sSql+= " OC_PATIENTINVOICE_DATE >= ? AND";
            }

            if(sInvoiceDateEnd.length() > 0){
                sSql+= " OC_PATIENTINVOICE_DATE <= ? AND";
            }

            if(sInvoiceNr.length() > 0){
                sSql+= " OC_PATIENTINVOICE_OBJECTID = ? AND";
            }

            // balance range
            if(sInvoiceBalanceMin.length() > 0 && sInvoiceBalanceMax.length() > 0){
                sSql+= " (OC_PATIENTINVOICE_BALANCE >= ? AND OC_PATIENTINVOICE_BALANCE < ?) AND";
            }
            else if(sInvoiceBalanceMin.length() > 0){
                sSql+= " OC_PATIENTINVOICE_BALANCE >= ? AND";
            }
            else if(sInvoiceBalanceMax.length() > 0){
                sSql+= " OC_PATIENTINVOICE_BALANCE =< ? AND";
            }
            // remove last AND
            if(sSql.endsWith("AND")){
                sSql = sSql.substring(0,sSql.length()-3);
            }

            sSql+= " ORDER BY OC_PATIENTINVOICE_DATE DESC";

            ps = oc_conn.prepareStatement(sSql);

            // set question marks
            int qmIdx = 1;
            if(sInvoiceDateBegin.length() > 0) ps.setDate(qmIdx++,ScreenHelper.getSQLDate(sInvoiceDateBegin));
            if(sInvoiceDateEnd.length() > 0) ps.setDate(qmIdx++,ScreenHelper.getSQLDate(sInvoiceDateEnd));
            if(sInvoiceNr.length() > 0) ps.setInt(qmIdx++,Integer.parseInt(sInvoiceNr));
            if(sInvoiceBalanceMin.length() > 0) ps.setDouble(qmIdx++,Double.parseDouble(sInvoiceBalanceMin));
            if(sInvoiceBalanceMax.length() > 0) ps.setDouble(qmIdx,Double.parseDouble(sInvoiceBalanceMax));

            rs = ps.executeQuery();

            PatientInvoice patientInvoice;
            while(rs.next()){
                patientInvoice = new PatientInvoice();

                patientInvoice.setUid(rs.getInt("OC_PATIENTINVOICE_SERVERID")+"."+rs.getInt("OC_PATIENTINVOICE_OBJECTID"));
                patientInvoice.setDate(rs.getTimestamp("OC_PATIENTINVOICE_DATE"));
                patientInvoice.setInvoiceUid(rs.getInt("OC_PATIENTINVOICE_ID")+"");
                patientInvoice.setPatientUid(rs.getString("OC_PATIENTINVOICE_PATIENTUID"));
                patientInvoice.setCreateDateTime(rs.getTimestamp("OC_PATIENTINVOICE_CREATETIME"));
                patientInvoice.setUpdateDateTime(rs.getTimestamp("OC_PATIENTINVOICE_UPDATETIME"));
                patientInvoice.setUpdateUser(rs.getString("OC_PATIENTINVOICE_UPDATEUID"));
                patientInvoice.setVersion(rs.getInt("OC_PATIENTINVOICE_VERSION"));
                patientInvoice.setBalance(rs.getDouble("OC_PATIENTINVOICE_BALANCE"));
                patientInvoice.setStatus(rs.getString("OC_PATIENTINVOICE_STATUS"));

                invoices.add(patientInvoice);
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

        return invoices;
    }

    //--- GET TOTAL BALANCE FOR PATIENT -----------------------------------------------------------
    public static double getTotalBalanceForPatient(String sInvoicePatientUid){
        return getTotalBalanceForPatient(sInvoicePatientUid,"","","");
    }

    public static double getTotalBalanceForPatient(String sInvoicePatientUid, String sInvoiceDateFrom, String sInvoiceDateTo){
        return getTotalBalanceForPatient(sInvoicePatientUid,sInvoiceDateFrom,sInvoiceDateTo,"");
    }

    public static double getTotalBalanceForPatient(String sInvoicePatientUid, String sInvoiceDateFrom, String sInvoiceDateTo, String sInvoiceStatus){
        PreparedStatement ps = null;
        ResultSet rs = null;
        double totalBalance = 0;

        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{                      
            // compose query
            String sSql = "SELECT OC_PATIENTINVOICE_BALANCE FROM OC_PATIENTINVOICES";

            if(sInvoicePatientUid.length() > 0){
                if(sSql.indexOf("WHERE")<0) sSql+= " WHERE";
                sSql+= " OC_PATIENTINVOICE_PATIENTUID = ? AND";
            }
            if(sInvoiceDateFrom.length() > 0){
                if(sSql.indexOf("WHERE")<0) sSql+= " WHERE";
                sSql+= " OC_PATIENTINVOICE_DATE = ? AND";
            }
            if(sInvoiceDateTo.length() > 0){
                if(sSql.indexOf("WHERE")<0) sSql+= " WHERE";
                sSql+= " OC_PATIENTINVOICE_DATE = ? AND";
            }
            if(sInvoiceStatus.length() > 0){
                if(sSql.indexOf("WHERE")<0) sSql+= " WHERE";
                sSql+= " OC_PATIENTINVOICE_STATUS = ? AND";
            }

            // remove last AND
            if(sSql.endsWith("AND")){
                sSql = sSql.substring(0,sSql.length()-3);
            }

            ps = oc_conn.prepareStatement(sSql);

            // set question marks
            int qmIdx = 1;
            SimpleDateFormat stdDateFormat = new SimpleDateFormat("dd/MM/yyyy");
            if(sInvoicePatientUid.length() > 0) ps.setString(qmIdx++,sInvoicePatientUid);
            if(sInvoiceDateFrom.length() > 0) ps.setDate(qmIdx++,new java.sql.Date(stdDateFormat.parse(sInvoiceDateFrom).getTime()));
            if(sInvoiceDateTo.length() > 0) ps.setDate(qmIdx++,new java.sql.Date(stdDateFormat.parse(sInvoiceDateTo).getTime()));
            if(sInvoiceStatus.length() > 0) ps.setString(qmIdx,sInvoiceStatus);

            rs = ps.executeQuery();

            while(rs.next()){
                totalBalance+= rs.getDouble("OC_PATIENTINVOICE_BALANCE");
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

        return totalBalance;
    }

    public static Vector getPatientInvoicesWhereDifferentStatus(String sPatientUid, String sStatus){
        Vector vPatientInvoices = new Vector();
        PreparedStatement ps = null;
        ResultSet rs = null;
        String sSelect = "";

        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            sSelect = "SELECT * FROM OC_PATIENTINVOICES WHERE OC_PATIENTINVOICE_PATIENTUID = ? AND OC_PATIENTINVOICE_STATUS not in ("+sStatus+")";
            ps = oc_conn.prepareStatement(sSelect);
            ps.setString(1,sPatientUid);

            rs = ps.executeQuery();
            PatientInvoice patientInvoice;
            while(rs.next()){
                patientInvoice = new PatientInvoice();

                patientInvoice.setUid(rs.getInt("OC_PATIENTINVOICE_SERVERID")+"."+rs.getInt("OC_PATIENTINVOICE_OBJECTID"));
                patientInvoice.setDate(rs.getTimestamp("OC_PATIENTINVOICE_DATE"));
                patientInvoice.setInvoiceUid(rs.getInt("OC_PATIENTINVOICE_ID")+"");
                patientInvoice.setPatientUid(rs.getString("OC_PATIENTINVOICE_PATIENTUID"));
                patientInvoice.setCreateDateTime(rs.getTimestamp("OC_PATIENTINVOICE_CREATETIME"));
                patientInvoice.setUpdateDateTime(rs.getTimestamp("OC_PATIENTINVOICE_UPDATETIME"));
                patientInvoice.setUpdateUser(rs.getString("OC_PATIENTINVOICE_UPDATEUID"));
                patientInvoice.setVersion(rs.getInt("OC_PATIENTINVOICE_VERSION"));
                patientInvoice.setBalance(rs.getDouble("OC_PATIENTINVOICE_BALANCE"));
                patientInvoice.setStatus(rs.getString("OC_PATIENTINVOICE_STATUS"));

                vPatientInvoices.add(patientInvoice);
            }
        }
        catch(Exception e){
            e.printStackTrace();
            Debug.println("OpenClinic => PatientInvoice.java => getPatientInvoicesWhereDifferentStatus => "+e.getMessage()+" = "+sSelect);
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

        return vPatientInvoices;
    }
      public static boolean setStatusOpen(String sInvoiceID,String UserId){

        PreparedStatement ps = null;
        ResultSet rs = null;
        boolean okQuery = false;
        String sSelect = "update OC_PATIENTINVOICES SET OC_PATIENTINVOICE_STATUS ='open',OC_PATIENTINVOICE_UPDATETIME=?,OC_PATIENTINVOICE_UPDATEUID=? WHERE OC_PATIENTINVOICE_OBJECTID = ? ";
        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            ps = oc_conn.prepareStatement(sSelect);
            ps.setTimestamp(1,new Timestamp(new java.util.Date().getTime())); // now
            ps.setString(2,UserId);
            ps.setInt(3,Integer.parseInt(sInvoiceID));

            okQuery = (ps.executeUpdate()>0);

            rs.close();
            ps.close();
      }
        catch(Exception e){
            Debug.println("OpenClinic => PatientInvoice.java => setStatusOpen => "+e.getMessage());
            e.printStackTrace();
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
        return okQuery;
    }
}
