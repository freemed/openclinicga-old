package be.openclinic.finance;

import be.openclinic.common.OC_Object;
import be.openclinic.common.ObjectReference;
import be.openclinic.adt.Encounter;
import be.mxs.common.util.db.MedwanQuery;
import be.mxs.common.util.system.Debug;
import be.mxs.common.util.system.ScreenHelper;

import java.util.Date;
import java.util.Vector;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Timestamp;

public class DebetTransaction extends OC_Object implements Comparable{
    private String description;
    private double amount;
    private Date date;
    private Encounter encounter;
    private String encounterUID;
    private Prestation prestation;
    private String prestationUID;
    private Balance balance;
    private String balanceUID;
    private ObjectReference supplier; //Med, Service
    private ObjectReference referenceObject; //Transaction, ProductStockOperation...

    //--- COMPARE TO ------------------------------------------------------------------------------
    public int compareTo(Object o){
        int comp;
        if (o.getClass().isInstance(this)){
            comp = this.date.compareTo(((DebetTransaction)o).date);
        }
        else {
            throw new ClassCastException();
        }
        return comp;
    }

    public DebetTransaction(){

    }

    public String getEncounterUID() {
        return encounterUID;
    }

    public void setEncounterUID(String encounterUID) {
        this.encounterUID = encounterUID;
    }

    public String getPrestationUID() {
        return prestationUID;
    }

    public void setPrestationUID(String prestationUID) {
        this.prestationUID = prestationUID;
    }

    public String getBalanceUID() {
        return balanceUID;
    }

    public void setBalanceUID(String balanceUID) {
        this.balanceUID = balanceUID;
    }

    public DebetTransaction(String description, double amount, Date date, String encounterUID, String prestationUID, String balanceUID, ObjectReference supplier, ObjectReference referenceObject,String patientUid) {
        this.description = description;
        this.amount = amount;
        this.date = date;
        this.encounterUID = encounterUID;
        if(this.encounterUID==null){
            this.encounter=Encounter.getActiveEncounter(patientUid);
            this.encounterUID=this.encounter.getUid();
        }
        this.prestationUID = prestationUID;
        this.balanceUID = balanceUID;
        if(this.balanceUID==null){
            this.balance=Balance.getActiveBalance(patientUid);
            this.balanceUID=this.balance.getUid();
        }
        this.supplier = supplier;
        this.referenceObject = referenceObject;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public double getAmount() {
        return Balance.getCurrency(amount);
    }

    public void setAmount(double amount) {
        this.amount = amount;
    }

    public Date getDate() {
        return date;
    }

    public void setDate(Date date) {
        this.date = date;
    }

    public Encounter getEncounter() {
        if(this.encounter == null){
            if(ScreenHelper.checkString(this.encounterUID).length() > 0){
                this.setEncounter(Encounter.get(this.encounterUID));
            }
            else{
                this.encounter = null;
            }
        }
        return encounter;
    }

    public void setEncounter(Encounter encounter) {
        this.encounter = encounter;
    }

    public Prestation getPrestation() {

        if(this.prestation == null){

            if (ScreenHelper.checkString(this.prestationUID).length() > 0){
                this.setPrestation(Prestation.get(this.prestationUID,this.date));
            }
            else{
                this.prestation = null;
            }
        }

        return prestation;
    }

    public void setPrestation(Prestation prestation) {
        this.prestation = prestation;
    }

    public Balance getBalance() {
        if(this.balance == null){
            if(ScreenHelper.checkString(this.balanceUID).length() > 0){
                this.setBalance(Balance.get(this.balanceUID));
            }
            else{
                this.balance = null;
            }
        }
        return balance;
    }

    public void setBalance(Balance balance) {
        this.balance = balance;
    }

    public ObjectReference getSupplier() {
        return supplier;
    }

    public void setSupplier(ObjectReference supplier) {
        this.supplier = supplier;
    }

    public ObjectReference getReferenceObject() {
        return referenceObject;
    }

    public void setReferenceObject(ObjectReference referenceObject) {
        this.referenceObject = referenceObject;
    }

    public static DebetTransaction get(String uid){
        DebetTransaction debet = new DebetTransaction();
        if ((uid!=null)&&(uid.length()>0)){
            String [] ids = uid.split("\\.");
            if (ids.length==2){
                PreparedStatement ps = null;
                ResultSet rs = null;
                String sSelect = "SELECT * FROM OC_DEBETS WHERE OC_DEBET_SERVERID = ? AND OC_DEBET_OBJECTID = ?";
                Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
                try{
                    ps = oc_conn.prepareStatement(sSelect);
                    ps.setInt(1,Integer.parseInt(ids[0]));
                    ps.setInt(2,Integer.parseInt(ids[1]));
                    rs = ps.executeQuery();

                    if(rs.next()){
                        debet.setUid(uid);

                        debet.setAmount(rs.getDouble("OC_DEBET_AMOUNT"));
                        debet.balanceUID = rs.getString("OC_DEBET_BALANCEUID");
                        debet.setDate(rs.getTimestamp("OC_DEBET_DATE"));
                        debet.setDescription(rs.getString("OC_DEBET_DESCRIPTION"));
                        debet.encounterUID = rs.getString("OC_DEBET_ENCOUNTERUID");
                        debet.prestationUID = rs.getString("OC_DEBET_PRESTATIONUID");

                        ObjectReference or1 = new ObjectReference();
                        or1.setObjectType(rs.getString("OC_DEBET_REFTYPE"));
                        or1.setObjectUid(rs.getString("OC_DEBET_REFUID"));
                        debet.setReferenceObject(or1);

                        ObjectReference or2 = new ObjectReference();
                        or2.setObjectType(rs.getString("OC_DEBET_SUPPLIERTYPE"));
                        or2.setObjectUid(rs.getString("OC_DEBET_SUPPLIERUID"));
                        debet.setSupplier(or2);

                        debet.setCreateDateTime(rs.getTimestamp("OC_DEBET_CREATETIME"));
                        debet.setUpdateDateTime(rs.getTimestamp("OC_DEBET_UPDATETIME"));
                        debet.setUpdateUser(rs.getString("OC_DEBET_UPDATEUID"));
                        debet.setVersion(rs.getInt("OC_DEBET_VERSION"));
                    }

                }
                catch(Exception e){
                    Debug.println("OpenClinic => DebetTransaction.java => get => "+e.getMessage());
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
        return debet;
    }

    public void storeUnique(){
        PreparedStatement ps = null;
        ResultSet rs = null;
        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            ps=oc_conn.prepareStatement("select * from OC_DEBETS where OC_DEBET_REFTYPE=? and OC_DEBET_REFUID=?");
            ps.setString(1,this.getReferenceObject().getObjectType());
            ps.setString(2,this.getReferenceObject().getObjectUid());
            rs=ps.executeQuery();
            if(!rs.next()){
                store();
            }
            rs.close();
            ps.close();
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
                e.printStackTrace();
            }
        }
    }

    public void store(){
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
                    sSelect = "SELECT OC_DEBET_VERSION FROM OC_DEBETS WHERE OC_DEBET_SERVERID = ? AND OC_DEBET_OBJECTID = ?";
                    ps = oc_conn.prepareStatement(sSelect);
                    ps.setInt(1,Integer.parseInt(ids[0]));
                    ps.setInt(2,Integer.parseInt(ids[1]));
                    rs = ps.executeQuery();

                    if(rs.next()) {
                        iVersion = rs.getInt("OC_DEBET_VERSION") + 1;
                    }

                    rs.close();
                    ps.close();

                    sSelect = "INSERT INTO OC_DEBETS_HISTORY SELECT * FROM OC_DEBETS WHERE OC_DEBET_SERVERID = ? AND OC_DEBET_OBJECTID = ?";
                    ps = oc_conn.prepareStatement(sSelect);
                    ps.setInt(1,Integer.parseInt(ids[0]));
                    ps.setInt(2,Integer.parseInt(ids[1]));
                    ps.executeUpdate();
                    ps.close();

                    sSelect = " DELETE FROM OC_DEBETS WHERE OC_DEBET_SERVERID = ? AND OC_DEBET_OBJECTID = ?";
                    ps = oc_conn.prepareStatement(sSelect);
                    ps.setInt(1,Integer.parseInt(ids[0]));
                    ps.setInt(2,Integer.parseInt(ids[1]));
                    ps.executeUpdate();
                    ps.close();
                }
            }
            else{
                ids = new String[] {MedwanQuery.getInstance().getConfigString("serverId"),MedwanQuery.getInstance().getOpenclinicCounter("OC_DEBETS")+""};
                this.setUid(ids[0]+"."+ids[1]);
            }
            if(ids.length == 2){
               sSelect = " INSERT INTO OC_DEBETS (" +
                                                  " OC_DEBET_SERVERID," +
                                                  " OC_DEBET_OBJECTID," +
                                                  " OC_DEBET_AMOUNT," +
                                                  " OC_DEBET_BALANCEUID," +
                                                  " OC_DEBET_DATE," +
                                                  " OC_DEBET_DESCRIPTION," +
                                                  " OC_DEBET_ENCOUNTERUID," +
                                                  " OC_DEBET_PRESTATIONUID," +
                                                  " OC_DEBET_SUPPLIERTYPE," +
                                                  " OC_DEBET_SUPPLIERUID," +
                                                  " OC_DEBET_REFTYPE," +
                                                  " OC_DEBET_REFUID," +
                                                  " OC_DEBET_CREATETIME," +
                                                  " OC_DEBET_UPDATETIME," +
                                                  " OC_DEBET_UPDATEUID," +
                                                  " OC_DEBET_VERSION" +
                                                ") " +
                         " VALUES(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)";
                ps = oc_conn.prepareStatement(sSelect);
                ps.setInt(1,Integer.parseInt(ids[0]));
                ps.setInt(2,Integer.parseInt(ids[1]));
                ps.setDouble(3,this.getAmount());
                ps.setString(4,this.getBalanceUID()!=null?this.getBalanceUID():this.getBalance().getUid());
                ps.setTimestamp(5,new Timestamp(this.getDate().getTime()));
                ps.setString(6,this.getDescription());

                if (this.getEncounterUID()!=null){
                    ps.setString(7,this.getEncounterUID());
                }
                else if (this.getEncounter()!=null){
                    ps.setString(7,this.getEncounter().getUid());
                }
                else {
                    ps.setString(7,"");
                }

                ps.setString(8,this.getPrestationUID()!=null?this.getPrestationUID():this.getPrestation().getUid());
                ps.setString(9,this.getSupplier().getObjectType());
                ps.setString(10,this.getSupplier().getObjectUid());
                ps.setString(11,this.getReferenceObject().getObjectType());
                ps.setString(12,this.getReferenceObject().getObjectUid());
                ps.setTimestamp(13,new Timestamp(this.getCreateDateTime().getTime()));
                ps.setTimestamp(14,new Timestamp(this.getUpdateDateTime().getTime()));
                ps.setString(15,this.getUpdateUser());
                ps.setInt(16,iVersion);
                ps.executeUpdate();
                ps.close();
            }

            this.getBalance().updateBalanceValue();

        }
        catch(Exception e){
            e.printStackTrace();
            Debug.println("OpenClinic => DebetTransaction.java => store => "+e.getMessage()+" = "+sSelect);
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

    public static Vector getDebetTransactionsForBalance(String balanceUID){
        PreparedStatement ps = null;
        ResultSet rs = null;

        Vector vDebets = new Vector();

        DebetTransaction debet;

        String sSelect = "SELECT * FROM OC_DEBETS WHERE OC_DEBET_BALANCEUID = ? AND OC_DEBET_CREATETIME > ?";

        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            ps = oc_conn.prepareStatement(sSelect);

            ps.setString(1, balanceUID);
            ps.setTimestamp(2, new Timestamp(Balance.get(balanceUID).getDate().getTime()));

            rs = ps.executeQuery();

            while(rs.next()){
                debet = new DebetTransaction();
                debet.setUid(ScreenHelper.checkString(rs.getString("OC_DEBET_SERVERID")) + "." + ScreenHelper.checkString(rs.getString("OC_DEBET_OBJECTID")));

                debet.setAmount(rs.getDouble("OC_DEBET_AMOUNT"));
                debet.balanceUID = rs.getString("OC_DEBET_BALANCEUID");
                debet.setDate(rs.getTimestamp("OC_DEBET_DATE"));
                debet.setDescription(rs.getString("OC_DEBET_DESCRIPTION"));
                debet.encounterUID = rs.getString("OC_DEBET_ENCOUNTERUID");
                debet.prestationUID = rs.getString("OC_DEBET_PRESTATIONUID");

                ObjectReference or1 = new ObjectReference();
                or1.setObjectType(rs.getString("OC_DEBET_REFTYPE"));
                or1.setObjectUid(rs.getString("OC_DEBET_REFUID"));
                debet.setReferenceObject(or1);

                ObjectReference or2 = new ObjectReference();
                or2.setObjectType(rs.getString("OC_DEBET_SUPPLIERTYPE"));
                or2.setObjectUid(rs.getString("OC_DEBET_SUPPLIERUID"));
                debet.setSupplier(or2);

                debet.setCreateDateTime(rs.getTimestamp("OC_DEBET_CREATETIME"));
                debet.setUpdateDateTime(rs.getTimestamp("OC_DEBET_UPDATETIME"));
                debet.setUpdateUser(rs.getString("OC_DEBET_UPDATEUID"));
                debet.setVersion(rs.getInt("OC_DEBET_VERSION"));
                vDebets.addElement(debet);
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
        return vDebets;
    }

    public static Vector getPersonSupplierDebetTransactionByID(String sId){
        PreparedStatement ps = null;
        ResultSet rs = null;

        Vector vPersonIDs = new Vector();

        String sSelect = "SELECT * FROM OC_DEBETS WHERE OC_DEBET_BALANCEUID = ?  AND OC_DEBET_SUPPLIERTYPE = 'Person' ";

        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            ps = oc_conn.prepareStatement(sSelect);
            ps.setString(1, sId);
            rs = ps.executeQuery();

            String sTmp;
            while (rs.next()) {
                sTmp = rs.getString("OC_DEBET_SUPPLIERUID");
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
