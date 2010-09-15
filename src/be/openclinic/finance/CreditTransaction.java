package be.openclinic.finance;

import be.openclinic.common.OC_Object;
import be.openclinic.common.ObjectReference;
import be.openclinic.adt.Encounter;
import be.mxs.common.util.db.MedwanQuery;
import be.mxs.common.util.system.ScreenHelper;
import be.mxs.common.util.system.Debug;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Timestamp;
import java.util.Date;
import java.util.Vector;


public class CreditTransaction extends OC_Object implements Comparable{
    private String description;
    private String type;
    private ObjectReference source; //Patient, Service (verzekering, kwijtschelding, annulatie...)
    private double amount;
    private Date date;
    private Encounter encounter;
    private String encounterUID;
    private Balance balance;
    private String balanceUID;

    //--- COMPARE TO ------------------------------------------------------------------------------
    public int compareTo(Object o){
        int comp;
        if (o.getClass().isInstance(this)){
            comp = this.date.compareTo(((CreditTransaction)o).date);
        }
        else {
            throw new ClassCastException();
        }
        return comp;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public ObjectReference getSource() {
        return source;
    }

    public void setSource(ObjectReference source) {
        this.source = source;
    }

    public double getAmount() {
        return Balance.getCurrency(amount);
    }

    public void setAmount(double amount) {
        this.amount = amount;
    }

    public Encounter getEncounter() {
        if(this.encounter == null){
            if(ScreenHelper.checkString(this.encounterUID).length() > 0){
                this.setEncounter(Encounter.get(this.encounterUID));
            }else{
                this.encounter = null;
            }
        }
        return encounter;
    }

    public void setEncounter(Encounter encounter) {
        this.encounter = encounter;
    }

    public Balance getBalance() {
        if(this.balance == null){
            if(ScreenHelper.checkString(this.balanceUID).length() > 0){
                this.setBalance(Balance.get(this.balanceUID));
            }else{
                this.balance = null;
            }
        }
        return balance;
    }

    public void setBalance(Balance balance) {
        this.balance = balance;
    }

    public Date getDate(){
        return this.date;
    }

    public void setDate(Date date){
        this.date = date;
    }

    public String getType() {
        return type;
    }

    public void setType(String type) {
        this.type = type;
    }


    public static CreditTransaction get(String uid){
        CreditTransaction credit = new CreditTransaction();
        if(uid!=null && uid.length() > 0){
            String ids[] = uid.split("\\.");
            if(ids.length == 2){
                PreparedStatement ps = null;
                ResultSet rs = null;
                Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
                try{
                    String sSelect = "SELECT * FROM OC_CREDITS WHERE OC_CREDIT_SERVERID = ? AND OC_CREDIT_OBJECTID = ?";

                    ps = oc_conn.prepareStatement(sSelect);
                    ps.setInt(1,Integer.parseInt(ids[0]));
                    ps.setInt(2,Integer.parseInt(ids[1]));

                    rs = ps.executeQuery();

                    String sBalanceUID,sEncounterUID;
                    if(rs.next()){
                        sBalanceUID = rs.getString("OC_CREDIT_BALANCEUID");
                        sEncounterUID = rs.getString("OC_CREDIT_ENCOUNTERUID");

                        credit.setUid(uid);
                        credit.setAmount(rs.getDouble("OC_CREDIT_AMOUNT"));
                        credit.setDescription(rs.getString("OC_CREDIT_DESCRIPTION"));
                        credit.setType(ScreenHelper.checkString(rs.getString("OC_CREDIT_TYPE")));
                        credit.balanceUID = sBalanceUID;
                        credit.encounterUID = sEncounterUID;
//                        credit.setBalance(Balance.get(sBalanceUID));
  //                      credit.setEncounter(Encounter.get(sEncounterUID));
                        credit.setDate(rs.getTimestamp("OC_CREDIT_DATE"));

                        ObjectReference or = new ObjectReference();
                        or.setObjectType(rs.getString("OC_CREDIT_SOURCETYPE"));
                        or.setObjectUid(rs.getString("OC_CREDIT_SOURCEUID"));
                        credit.setSource(or);

                        credit.setCreateDateTime(rs.getTimestamp("OC_CREDIT_CREATETIME"));
                        credit.setUpdateDateTime(rs.getTimestamp("OC_CREDIT_UPDATETIME"));
                        credit.setUpdateUser(rs.getString("OC_CREDIT_UPDATEUID"));
                        credit.setVersion(rs.getInt("OC_CREDIT_VERSION"));
                    }
                }
                catch(Exception e){
                    e.printStackTrace();
                }
                finally{
                    try{
                        if(rs!=null)rs.close();
                        if(ps!=null)ps.close();
                        oc_conn.close();
                    }
                    catch(Exception e){
                        Debug.println("OpenClinic => creditTransaction.java => get => "+e.getMessage());
                        e.printStackTrace();
                    }
                }
            }
        }
        return credit;
    }

    public void store(){
        String[] ids;
        int iVersion = 1;
        String sSelect = "";
        PreparedStatement ps = null;
        ResultSet rs = null;
        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            if(this.getUid() != null && this.getUid().length() > 0){
                ids = this.getUid().split("\\.");
                if(ids.length == 2){
                        sSelect = "SELECT OC_CREDIT_VERSION FROM OC_CREDITS WHERE OC_CREDIT_SERVERID = ? AND OC_CREDIT_OBJECTID = ?";
                        ps = oc_conn.prepareStatement(sSelect);
                        ps.setInt(1,Integer.parseInt(ids[0]));
                        ps.setInt(2,Integer.parseInt(ids[1]));
                        rs = ps.executeQuery();

                        if(rs.next()){
                            iVersion = rs.getInt("OC_CREDIT_VERSION")+1;
                        }

                        rs.close();
                        ps.close();

                        sSelect = "INSERT INTO OC_CREDITS_HISTORY SELECT * FROM OC_CREDITS WHERE OC_CREDIT_SERVERID = ? AND OC_CREDIT_OBJECTID = ?";
                        ps = oc_conn.prepareStatement(sSelect);
                        ps.setInt(1,Integer.parseInt(ids[0]));
                        ps.setInt(2,Integer.parseInt(ids[1]));
                        ps.executeUpdate();
                        ps.close();

                        sSelect = "DELETE FROM OC_CREDITS WHERE OC_CREDIT_SERVERID = ? AND OC_CREDIT_OBJECTID = ? ";
                        ps = oc_conn.prepareStatement(sSelect);
                        ps.setInt(1,Integer.parseInt(ids[0]));
                        ps.setInt(2,Integer.parseInt(ids[1]));
                        ps.executeUpdate();
                        ps.close();
                }
            }
            else{
                ids = new String[] {MedwanQuery.getInstance().getConfigString("serverId"),MedwanQuery.getInstance().getOpenclinicCounter("OC_CREDITS") + ""};
            }

            if(ids.length == 2){
                sSelect = " INSERT INTO OC_CREDITS (" +
                                                    " OC_CREDIT_SERVERID," +
                                                    " OC_CREDIT_OBJECTID," +
                                                    " OC_CREDIT_AMOUNT," +
                                                    " OC_CREDIT_BALANCEUID," +
                                                    " OC_CREDIT_DATE," +
                                                    " OC_CREDIT_DESCRIPTION," +
                                                    " OC_CREDIT_TYPE," +
                                                    " OC_CREDIT_ENCOUNTERUID," +
                                                    " OC_CREDIT_SOURCETYPE," +
                                                    " OC_CREDIT_SOURCEUID," +
                                                    " OC_CREDIT_CREATETIME," +
                                                    " OC_CREDIT_UPDATETIME," +
                                                    " OC_CREDIT_UPDATEUID," +
                                                    " OC_CREDIT_VERSION" +
                                                  ") " +
                          " VALUES(?,?,?,?,?,?,?,?,?,?,?,?,?,?)";

                ps = oc_conn.prepareStatement(sSelect);
                ps.setInt(1,Integer.parseInt(ids[0]));
                ps.setInt(2,Integer.parseInt(ids[1]));
                ps.setDouble(3,this.getAmount());
                ps.setString(4,this.getBalance().getUid());
                ps.setTimestamp(5,new Timestamp(this.getDate().getTime()));
                ps.setString(6,this.getDescription());
                ps.setString(7,this.getType());
                ps.setString(8,this.getEncounter().getUid());
                ps.setString(9,this.getSource().getObjectType());
                ps.setString(10,this.getSource().getObjectUid());
                ps.setTimestamp(11,new Timestamp(this.getCreateDateTime().getTime()));
                ps.setTimestamp(12,new Timestamp(this.getUpdateDateTime().getTime()));
                ps.setString(13,this.getUpdateUser());
                ps.setInt(14,iVersion);
                ps.executeUpdate();
                ps.close();
            }

            this.getBalance().updateBalanceValue();

        }
        catch(Exception e){
            e.printStackTrace();
        }
        finally{
            try{
                if(rs!=null)rs.close();
                if(ps!=null)ps.close();
                oc_conn.close();
            }
            catch(Exception e){
                Debug.println("OpenClinic => CreditTransaction.java => store => "+e.getMessage()+" = "+sSelect);
                e.printStackTrace();
            }
        }
    }

    public static Vector getCreditTransactionsForBalance(String balanceUID){
        PreparedStatement ps = null;
        ResultSet rs = null;

        Vector vCredits = new Vector();

        CreditTransaction credit;

        String sSelect = "SELECT * FROM OC_CREDITS WHERE OC_CREDIT_BALANCEUID = ? AND OC_CREDIT_CREATETIME > ?";

        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            ps = oc_conn.prepareStatement(sSelect);

            ps.setString(1, balanceUID);
            ps.setTimestamp(2, new Timestamp(Balance.get(balanceUID).getDate().getTime()));

            rs = ps.executeQuery();

            while(rs.next()){
                credit =  new CreditTransaction();
                credit.setUid(ScreenHelper.checkString(rs.getString("OC_CREDIT_SERVERID")) + "." + ScreenHelper.checkString(rs.getString("OC_CREDIT_OBJECTID")));
                credit.setAmount(rs.getDouble("OC_CREDIT_AMOUNT"));
                credit.setDescription(rs.getString("OC_CREDIT_DESCRIPTION"));
                credit.setType(ScreenHelper.checkString(rs.getString("OC_CREDIT_TYPE")));
                credit.balanceUID = rs.getString("OC_CREDIT_BALANCEUID");
                credit.encounterUID = rs.getString("OC_CREDIT_ENCOUNTERUID");
                credit.setDate(rs.getTimestamp("OC_CREDIT_DATE"));

                ObjectReference or = new ObjectReference();
                or.setObjectType(rs.getString("OC_CREDIT_SOURCETYPE"));
                or.setObjectUid(rs.getString("OC_CREDIT_SOURCEUID"));
                credit.setSource(or);

                credit.setCreateDateTime(rs.getTimestamp("OC_CREDIT_CREATETIME"));
                credit.setUpdateDateTime(rs.getTimestamp("OC_CREDIT_UPDATETIME"));
                credit.setUpdateUser(rs.getString("OC_CREDIT_UPDATEUID"));
                credit.setVersion(rs.getInt("OC_CREDIT_VERSION"));
                vCredits.addElement(credit);
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
        return vCredits;
    }

    public static Vector getServiceCreditTransactionByID(String sID){
        PreparedStatement ps = null;
        ResultSet rs = null;

        Vector vCredits = new Vector();

        String sSelect = "SELECT * FROM OC_CREDITS WHERE OC_CREDIT_BALANCEUID = ? AND OC_CREDIT_SOURCETYPE = 'Service' ";

        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            ps = oc_conn.prepareStatement(sSelect);
            ps.setString(1, sID);
            rs = ps.executeQuery();

            CreditTransaction credit;

            while(rs.next()){
                credit =  new CreditTransaction();
                credit.setUid(ScreenHelper.checkString(rs.getString("OC_CREDIT_SERVERID")) + "." + ScreenHelper.checkString(rs.getString("OC_CREDIT_OBJECTID")));
                credit.setAmount(rs.getDouble("OC_CREDIT_AMOUNT"));
                credit.setDescription(rs.getString("OC_CREDIT_DESCRIPTION"));
                credit.setType(ScreenHelper.checkString(rs.getString("OC_CREDIT_TYPE")));
                credit.balanceUID = rs.getString("OC_CREDIT_BALANCEUID");
                credit.encounterUID = rs.getString("OC_CREDIT_ENCOUNTERUID");
                credit.setDate(rs.getTimestamp("OC_CREDIT_DATE"));

                ObjectReference or = new ObjectReference();
                or.setObjectType(rs.getString("OC_CREDIT_SOURCETYPE"));
                or.setObjectUid(rs.getString("OC_CREDIT_SOURCEUID"));
                credit.setSource(or);

                credit.setCreateDateTime(rs.getTimestamp("OC_CREDIT_CREATETIME"));
                credit.setUpdateDateTime(rs.getTimestamp("OC_CREDIT_UPDATETIME"));
                credit.setUpdateUser(rs.getString("OC_CREDIT_UPDATEUID"));
                credit.setVersion(rs.getInt("OC_CREDIT_VERSION"));
                vCredits.addElement(credit);    
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

        return vCredits;
    }

    public static Vector getPersonSupplierCreditTransactionByID(String sId){
        PreparedStatement ps = null;
        ResultSet rs = null;

        Vector vPersonIDs = new Vector();

        String sSelect = "SELECT * FROM OC_CREDITS WHERE OC_CREDIT_BALANCEUID = ?  AND OC_CREDIT_SOURCETYPE = 'Person' ";

        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            ps = oc_conn.prepareStatement(sSelect);
            ps.setString(1, sId);
            rs = ps.executeQuery();

            String sTmp;
            while (rs.next()) {
                sTmp = rs.getString("OC_CREDIT_SOURCEUID");
                vPersonIDs.add(sTmp.substring(sTmp.indexOf(".") + 1));
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
        return vPersonIDs;
    }
}
