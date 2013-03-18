package be.openclinic.finance;

import be.openclinic.common.OC_Object;
import be.openclinic.common.ObjectReference;
import be.mxs.common.util.db.MedwanQuery;
import be.mxs.common.util.system.Debug;
import be.mxs.common.util.system.ScreenHelper;

import java.util.Date;
import java.util.Vector;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;

public class Balance extends OC_Object implements Comparable{
    private double balance;
    private double minimumBalance;
    private double maximumBalance;
    private ObjectReference owner; //Person or Service
    private Date date;
    private String remarks;
    private Date closedTime;

    //--- COMPARE TO ------------------------------------------------------------------------------
    public int compareTo(Object o){
        int comp;
        if (o.getClass().isInstance(this)){
            comp = this.getDate().compareTo(((Balance)o).getDate());
        }
        else {
            throw new ClassCastException();
        }
        return comp;
    }

    public double getBalance() {
        return getCurrency(balance);
    }

    public void setBalance(double balance) {
        this.balance = balance;
    }

    public double getMinimumBalance() {
        return minimumBalance;
    }

    public void setMinimumBalance(double minimumBalance) {
        this.minimumBalance = minimumBalance;
    }

    public double getMaximumBalance() {
        return maximumBalance;
    }

    public void setMaximumBalance(double maximumBalance) {
        this.maximumBalance = maximumBalance;
    }

    public ObjectReference getOwner() {
        return owner;
    }

    public void setOwner(ObjectReference owner) {
        this.owner = owner;
    }

    public Date getDate() {
        return date;
    }

    public void setDate(Date date) {
        this.date = date;
    }

    public String getRemarks() {
        return remarks;
    }

    public void setRemarks(String remarks) {
        this.remarks = remarks;
    }

    public Date getClosedTime() {
        return closedTime;
    }

    public void setClosedTime(Date date) {
        this.closedTime = date;
    }

    public static Balance get(String uid) throws ClassCastException {
        Balance balance = new Balance();
        if ((uid!=null)&&(uid.length()>0)){
            String [] ids = uid.split("\\.");
            ResultSet rs = null;
            PreparedStatement ps= null;
            String sSelect = "";
            Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
            try{
                if (ids.length==2){
                    sSelect = " SELECT * FROM OC_BALANCES WHERE OC_BALANCE_SERVERID = ? AND OC_BALANCE_OBJECTID = ? ";
                    ps = oc_conn.prepareStatement(sSelect);
                    ps.setInt(1,Integer.parseInt(ids[0]));
                    ps.setInt(2,Integer.parseInt(ids[1]));
                    rs = ps.executeQuery();
                    if (rs.next()){
                        balance.setUid(uid);
                        balance.setBalance(rs.getDouble("OC_BALANCE_VALUE"));
                        balance.setMaximumBalance(rs.getDouble("OC_BALANCE_MAXIMUMBALANCE"));
                        balance.setMinimumBalance(rs.getDouble("OC_BALANCE_MINIMUMBALANCE"));
                        balance.setDate(rs.getTimestamp("OC_BALANCE_DATE"));
                        ObjectReference or = new ObjectReference();
                        or.setObjectType(ScreenHelper.checkString(rs.getString("OC_BALANCE_OWNERTYPE")));
                        or.setObjectUid(ScreenHelper.checkString(rs.getString("OC_BALANCE_OWNERUID")));
                        balance.setOwner(or);
                        balance.setRemarks(ScreenHelper.checkString(rs.getString("OC_BALANCE_REMARKS")));
                        balance.setCreateDateTime(rs.getTimestamp("OC_BALANCE_CREATETIME"));
                        balance.setUpdateDateTime(rs.getTimestamp("OC_BALANCE_UPDATETIME"));
                        balance.setUpdateUser(ScreenHelper.checkString(rs.getString("OC_BALANCE_UPDATEUID")));
                        balance.setVersion(rs.getInt("OC_BALANCE_VERSION"));
                        balance.setClosedTime(rs.getTimestamp("OC_BALANCE_CLOSEDTIME"));
                    }
                    rs.close();
                    ps.close();
                }
            }
            catch(Exception e){
                Debug.println("OpenClinic => Balance.java => get => "+e.getMessage()+" = "+sSelect);
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
        return balance;
    }

    public void store(){
        String sSelect = "";
        PreparedStatement ps = null;
        ResultSet rs = null;
        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            int iVersion = 1;
            String[] ids;

            if ((this.getUid()!=null) && (this.getUid().length() >0)){
                ids = getUid().split("\\.");
                if (ids.length==2){
                    sSelect = " SELECT * FROM OC_BALANCES WHERE OC_BALANCE_SERVERID = ? AND OC_BALANCE_OBJECTID = ? ";
                    ps = oc_conn.prepareStatement(sSelect);
                    ps.setInt(1,Integer.parseInt(ids[0]));
                    ps.setInt(2,Integer.parseInt(ids[1]));
                    rs = ps.executeQuery();
                    if (rs.next()){
                        iVersion = rs.getInt("OC_BALANCE_VERSION")+1;
                    }
                    rs.close();
                    ps.close();

                    sSelect = " INSERT INTO OC_BALANCES_HISTORY SELECT * FROM OC_BALANCES WHERE OC_BALANCE_SERVERID = ? AND OC_BALANCE_OBJECTID = ? ";
                    ps = oc_conn.prepareStatement(sSelect);
                    ps.setInt(1,Integer.parseInt(ids[0]));
                    ps.setInt(2,Integer.parseInt(ids[1]));
                    ps.executeUpdate();
                    ps.close();

                    sSelect = " UPDATE OC_BALANCES SET    OC_BALANCE_SERVERID       = ?, " +
                                                         "OC_BALANCE_OBJECTID       = ?, " +
                                                         "OC_BALANCE_VALUE          = ?, " +
                                                         "OC_BALANCE_MINIMUMBALANCE = ?, " +
                                                         "OC_BALANCE_MAXIMUMBALANCE = ?, " +
                                                         "OC_BALANCE_OWNERTYPE      = ?, " +
                                                         "OC_BALANCE_OWNERUID       = ?, " +
                                                         "OC_BALANCE_DATE           = ?, " +
                                                         "OC_BALANCE_REMARKS        = ?, " +
                                                         "OC_BALANCE_CREATETIME     = ?, " +
                                                         "OC_BALANCE_UPDATETIME     = ?, " +
                                                         "OC_BALANCE_UPDATEUID      = ?, " +
                                                         "OC_BALANCE_VERSION        = ?, " +
                                                         "OC_BALANCE_CLOSEDTIME     = ?  " +
                              " WHERE OC_BALANCE_SERVERID = ? AND OC_BALANCE_OBJECTID = ? ";
                    ps = oc_conn.prepareStatement(sSelect);
                    ps.setInt(1,Integer.parseInt(ids[0]));
                    ps.setInt(2,Integer.parseInt(ids[1]));
                    ps.setDouble(3,this.getBalance());
                    ps.setDouble(4,this.getMinimumBalance());
                    ps.setDouble(5,this.getMaximumBalance());
                    ps.setString(6,this.getOwner().getObjectType());
                    ps.setString(7,this.getOwner().getObjectUid());
                    ScreenHelper.getSQLTimestamp(ps,8,this.getDate());
/*                    if(this.getDate() == null){
                        ps.setTimestamp(8,new Timestamp(ScreenHelper.getSQLDate(ScreenHelper.getDate()).getTime()));
                    }else{
                        ps.setTimestamp(8,new Timestamp(this.getDate().getTime()));
                    }*/
                    ps.setString(9,this.getRemarks());
                    ps.setTimestamp(10,new Timestamp(this.getCreateDateTime().getTime()));
                    ps.setTimestamp(11,new Timestamp(this.getUpdateDateTime().getTime()));
                    ps.setString(12,this.getUpdateUser());
                    ps.setInt(13,iVersion);
                    //ScreenHelper.getSQLTimestamp(ps,14, new SimpleDateFormat("dd/MM/yyyy").format(this.closedTime),new SimpleDateFormat("hh:mm").format(this.closedTime));
                    ScreenHelper.getSQLTimestamp(ps,14,this.closedTime);
                    ps.setInt(15,Integer.parseInt(ids[0]));
                    ps.setInt(16,Integer.parseInt(ids[1]));
                    ps.executeUpdate();
                    ps.close();
                }
            }else{
                ids = new String[] {MedwanQuery.getInstance().getConfigString("serverId"),MedwanQuery.getInstance().getOpenclinicCounter("OC_BALANCES")+""};
                this.setUid(ids[0]+"."+ids[1]);
                if (ids.length==2){
                    sSelect = " INSERT INTO OC_BALANCES (" +
                                                         "OC_BALANCE_SERVERID, " +
                                                         "OC_BALANCE_OBJECTID, " +
                                                         "OC_BALANCE_VALUE, " +
                                                         "OC_BALANCE_MINIMUMBALANCE, " +
                                                         "OC_BALANCE_MAXIMUMBALANCE, " +
                                                         "OC_BALANCE_OWNERTYPE, " +
                                                         "OC_BALANCE_OWNERUID, " +
                                                         "OC_BALANCE_DATE, " +
                                                         "OC_BALANCE_REMARKS, " +
                                                         "OC_BALANCE_CREATETIME, " +
                                                         "OC_BALANCE_UPDATETIME, " +
                                                         "OC_BALANCE_UPDATEUID, " +
                                                         "OC_BALANCE_VERSION" +
                                                       ") " +
                              " VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?) ";
                    ps = oc_conn.prepareStatement(sSelect);
                    ps.setInt(1,Integer.parseInt(ids[0]));
                    ps.setInt(2,Integer.parseInt(ids[1]));
                    ps.setDouble(3,this.getBalance());
                    ps.setDouble(4,this.getMinimumBalance());
                    ps.setDouble(5,this.getMaximumBalance());
                    ps.setString(6,this.getOwner().getObjectType());
                    ps.setString(7,this.getOwner().getObjectUid());
                    /*if(this.getDate() == null){
                        ps.setNull(8,java.sql.Types.TIMESTAMP);
                    }else{
                        ps.setTimestamp(8,new Timestamp(this.getDate().getTime()));
                    }*/
                    ScreenHelper.getSQLTimestamp(ps,8,this.getDate());
                    ps.setString(9,this.getRemarks());
                    ps.setTimestamp(10,new Timestamp(this.getCreateDateTime().getTime()));
                    ps.setTimestamp(11,new Timestamp(this.getUpdateDateTime().getTime()));
                    ps.setString(12,this.getUpdateUser());
                    ps.setInt(13,iVersion);
                    ps.executeUpdate();
                    ps.close();
                    this.setUid(ids[0] + "." + ids[1]);
                }
            }
        }
        catch(Exception e){
            Debug.println("OpenClinic => Balance.java => store => "+e.getMessage()+" = "+sSelect);
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

    public void updateBalanceValue(){
        double debet  = 0
              ,credit = 0;
        PreparedStatement ps = null;
        ResultSet rs = null;
        String sSelect = "";

        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            sSelect = " SELECT OC_DEBET_AMOUNT FROM OC_DEBETS WHERE OC_DEBET_BALANCEUID = ?";
            ps = oc_conn.prepareStatement(sSelect);
            ps.setString(1,this.getUid());
            rs = ps.executeQuery();

            while(rs.next()){
                debet += rs.getDouble("OC_DEBET_AMOUNT");
            }
            rs.close();
            ps.close();

            sSelect = " SELECT OC_CREDIT_AMOUNT FROM OC_CREDITS WHERE OC_CREDIT_BALANCEUID = ?";
            ps = oc_conn.prepareStatement(sSelect);
            ps.setString(1,this.getUid());
            rs = ps.executeQuery();

            while(rs.next()){
                credit += rs.getDouble("OC_CREDIT_AMOUNT");
            }
            rs.close();
            ps.close();
        }
        catch(Exception e){
            Debug.println("OpenClinic => Balance.java => updateBalanceValue => "+e.getMessage()+" = "+sSelect);
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

        this.setBalance(credit - debet);
        this.store();
        this.checkZeroBalance();
    }

    private void checkZeroBalance(){
        if(this.getBalance() == 0){
            PreparedStatement ps = null;
            ResultSet rs = null;
            String sSelect = "";

            String ids[] = this.getUid().split("\\.");
            Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
            try{

                sSelect = "UPDATE OC_BALANCES SET OC_BALANCE_CLOSEDTIME = ? WHERE OC_BALANCE_SERVERID = ? AND OC_BALANCE_OBJECTID = ? ";
                ps = oc_conn.prepareStatement(sSelect);

                ps.setTimestamp(1,new Timestamp(ScreenHelper.getSQLDate(ScreenHelper.getDate()).getTime()));
                ps.setInt(2,Integer.parseInt(ids[0]));
                ps.setInt(3,Integer.parseInt(ids[1]));
                ps.executeUpdate();
                ps.close();
                
                ids = new String[] {MedwanQuery.getInstance().getConfigString("serverId"),MedwanQuery.getInstance().getOpenclinicCounter("OC_BALANCES")+""};
                sSelect =  " INSERT INTO OC_BALANCES (" +
                                                     "OC_BALANCE_SERVERID, " +
                                                     "OC_BALANCE_OBJECTID, " +
                                                     "OC_BALANCE_VALUE, " +
                                                     "OC_BALANCE_MINIMUMBALANCE, " +
                                                     "OC_BALANCE_MAXIMUMBALANCE, " +
                                                     "OC_BALANCE_OWNERTYPE, " +
                                                     "OC_BALANCE_OWNERUID, " +
                                                     "OC_BALANCE_DATE, " +
                                                     "OC_BALANCE_REMARKS, " +
                                                     "OC_BALANCE_CREATETIME, " +
                                                     "OC_BALANCE_UPDATETIME, " +
                                                     "OC_BALANCE_UPDATEUID, " +
                                                     "OC_BALANCE_VERSION" +
                                                   ") " +
                          " VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?) ";
                ps = oc_conn.prepareStatement(sSelect);
                ps.setInt(1,Integer.parseInt(ids[0]));
                ps.setInt(2,Integer.parseInt(ids[1]));
                ps.setDouble(3,this.getBalance());
                ps.setDouble(4,this.getMinimumBalance());
                ps.setDouble(5,this.getMaximumBalance());
                ps.setString(6,this.getOwner().getObjectType());
                ps.setString(7,this.getOwner().getObjectUid());
                ps.setTimestamp(8,new Timestamp(ScreenHelper.getSQLDate(ScreenHelper.getDate()).getTime()));
                ps.setString(9,this.getRemarks());
                ps.setTimestamp(10,new Timestamp(new Date().getTime()));
                ps.setTimestamp(11,new Timestamp(this.getUpdateDateTime().getTime()));
                ps.setString(12,this.getUpdateUser());
                ps.setInt(13,1);
                ps.executeUpdate();
                ps.close();
            }
            catch(Exception e){
                Debug.println("OpenClinic => Balance.java => checkZeroBalance => "+e.getMessage()+" = "+sSelect);
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

    public static Balance getActiveBalance(String sUID){
        Balance balance = new Balance();
        PreparedStatement ps = null;
        ResultSet rs = null;
        String sSelect = "";

        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            sSelect = "SELECT * FROM OC_BALANCES WHERE OC_BALANCE_OWNERUID = ? AND OC_BALANCE_CLOSEDTIME IS NULL ";
            ps = oc_conn.prepareStatement(sSelect);
            ps.setString(1,sUID);
            rs = ps.executeQuery();

            if (rs.next()){
                String sBalanceUID = rs.getInt("OC_BALANCE_SERVERID")+"."+rs.getInt("OC_BALANCE_OBJECTID");
                balance = Balance.get(sBalanceUID);
            }

            rs.close();
            ps.close();
        }
        catch(Exception e){
            Debug.println("OpenClinic => Balance.java => getActiveBalance => "+e.getMessage()+" = "+sSelect);
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
        return balance;
    }

    public static double getCurrency(double d){
      /*  int decimalPlace = 2;
        BigDecimal bd = new BigDecimal(d);
        bd = bd.setScale(decimalPlace,BigDecimal.ROUND_UP);
        return (bd.doubleValue());*/

        return d;
    }

    public static double getPatientBalance(String personid){
        double total=0;
        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            String sSelect = "select sum(total) balance from" +
                    " (" +
                    " select sum(oc_patientcredit_amount) total from oc_patientcredits a,oc_encounters b" +
                    " where" +
                    " a.oc_patientcredit_encounteruid='"+MedwanQuery.getInstance().getConfigString("serverId")+".'"+MedwanQuery.getInstance().concatSign()+MedwanQuery.getInstance().convert("varchar", "b.oc_encounter_objectid")+" and" +
                    " b.oc_encounter_patientuid=?" +
                    " union" +
                    " select -sum(oc_debet_amount) total from oc_debets a,oc_encounters b" +
                    " where" +
                    " a.oc_debet_encounteruid='"+MedwanQuery.getInstance().getConfigString("serverId")+".'"+MedwanQuery.getInstance().concatSign()+MedwanQuery.getInstance().convert("varchar", "b.oc_encounter_objectid")+" and" +
                    " b.oc_encounter_patientuid=?" +
                    ") a";
            if(MedwanQuery.getInstance().getConfigString("convertDataTypeVarchar","").equalsIgnoreCase("char")){
            	//This is MySQL, no conversion to be used
            	sSelect = "select sum(total) balance from" +
                        " (" +
                        " select sum(oc_patientcredit_amount) total from oc_patientcredits a,oc_encounters b" +
                        " where" +
                        " a.oc_patientcredit_encounteruid='"+MedwanQuery.getInstance().getConfigString("serverId")+".'"+MedwanQuery.getInstance().concatSign()+"b.oc_encounter_objectid and" +
                        " b.oc_encounter_patientuid=?" +
                        " union" +
                        " select -sum(oc_debet_amount) total from oc_debets a,oc_encounters b" +
                        " where" +
                        " a.oc_debet_encounteruid='"+MedwanQuery.getInstance().getConfigString("serverId")+".'"+MedwanQuery.getInstance().concatSign()+"b.oc_encounter_objectid and" +
                        " b.oc_encounter_patientuid=?" +
                        ") a";
            }
            PreparedStatement ps = oc_conn.prepareStatement(sSelect);
            ps.setString(1,personid);
            ps.setString(2,personid);
            ResultSet rs = ps.executeQuery();
            if(rs.next()){
                total=rs.getDouble("balance");
            }
            rs.close();
            ps.close();
        }
        catch(Exception e){
            e.printStackTrace();
        }
        try {
			oc_conn.close();
		} catch (SQLException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
        return total;
    }

    public static Vector getDebets(String sBalanceID, Timestamp ts) {
        Vector vReturn = new Vector();
        String sSelect = "";
        ResultSet rs = null;
        PreparedStatement ps = null;
        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            sSelect = "SELECT * FROM OC_DEBETS WHERE OC_DEBET_BALANCEUID = ? AND OC_DEBET_CREATETIME >= ?";
            ps = oc_conn.prepareStatement(sSelect);
            ps.setString(1,sBalanceID);
            ps.setTimestamp(2,ts);
            rs = ps.executeQuery();

            DebetTransaction debet;

            while(rs.next()){
                debet = new DebetTransaction();
                debet.setAmount(rs.getDouble("OC_DEBET_AMOUNT"));
                debet.setDate(rs.getTimestamp("OC_DEBET_DATE"));
                debet.setUid(ScreenHelper.checkString(rs.getString("OC_DEBET_SERVERID")) + "." + ScreenHelper.checkString(rs.getString("OC_DEBET_OBJECTID")));
                debet.setDescription(ScreenHelper.checkString(rs.getString("OC_DEBET_DESCRIPTION")));
                debet.setReferenceObject(new ObjectReference(rs.getString("OC_DEBET_REFTYPE"),rs.getString("OC_DEBET_REFUID")));
                vReturn.add(debet);
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
                Debug.println("OpenClinic => Balance.java => getDebets => "+e.getMessage()+" = "+sSelect);
                e.printStackTrace();
            }
        }

        return vReturn;
    }

    public static Vector getCredits(String sBalanceID, Timestamp ts) {
        Vector vReturn = new Vector();
        String sSelect = "";
        ResultSet rs = null;
        PreparedStatement ps = null;
        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
           sSelect = "SELECT * FROM OC_CREDITS WHERE OC_CREDIT_BALANCEUID = ? AND OC_CREDIT_CREATETIME >= ?";

            ps = oc_conn.prepareStatement(sSelect);
            ps.setString(1,sBalanceID);
            ps.setTimestamp(2,ts);
            rs = ps.executeQuery();

            CreditTransaction credit;
            while(rs.next()){
                credit = new CreditTransaction();
                credit.setUid(ScreenHelper.checkString(rs.getString("OC_CREDIT_SERVERID")) + "." + ScreenHelper.checkString(rs.getString("OC_CREDIT_OBJECTID")));
                credit.setDate(rs.getTimestamp("OC_CREDIT_DATE"));
                credit.setDescription(ScreenHelper.checkString(rs.getString("OC_CREDIT_DESCRIPTION")));
                credit.setAmount(rs.getDouble("OC_CREDIT_AMOUNT"));
                credit.setType(rs.getString("OC_CREDIT_TYPE"));
                vReturn.add(credit);
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
                Debug.println("OpenClinic => Balance.java => getCredits => "+e.getMessage()+" = "+sSelect);
                e.printStackTrace();
            }
        }

        return vReturn;
    }

    public static Vector searchBalances(String sSelectOwner){
        PreparedStatement ps = null;
        ResultSet rs = null;

        Vector vResults = new Vector();
        Balance objBalance;

        String sSelect = "";

        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            // compose query
            if ((sSelectOwner.trim().length()>0)&&(sSelectOwner.trim().length()>0)) {
                sSelect+= " UPPER(OC_BALANCE_OWNERUID) like '"+sSelectOwner.toUpperCase()+"%' AND";
            }
            // complete query
            if(sSelect.length()>0) {
                sSelect = " SELECT * FROM OC_BALANCES " +
                          " WHERE " + sSelect.substring(0,sSelect.length()-3) +
                          " ORDER BY OC_BALANCE_DATE";

                ps = oc_conn.prepareStatement(sSelect);

                rs = ps.executeQuery();

                while(rs.next()){
                    objBalance = new Balance();
                    objBalance.setUid(ScreenHelper.checkString(rs.getString("OC_BALANCE_SERVERID")) + "." + ScreenHelper.checkString(rs.getString("OC_BALANCE_OBJECTID")));
                    objBalance.setBalance(rs.getDouble("OC_BALANCE_VALUE"));
                    objBalance.setMaximumBalance(rs.getDouble("OC_BALANCE_MAXIMUMBALANCE"));
                    objBalance.setMinimumBalance(rs.getDouble("OC_BALANCE_MINIMUMBALANCE"));
                    objBalance.setDate(rs.getTimestamp("OC_BALANCE_DATE"));
                    ObjectReference or = new ObjectReference();
                    or.setObjectType(ScreenHelper.checkString(rs.getString("OC_BALANCE_OWNERTYPE")));
                    or.setObjectUid(ScreenHelper.checkString(rs.getString("OC_BALANCE_OWNERUID")));
                    objBalance.setOwner(or);
                    objBalance.setRemarks(ScreenHelper.checkString(rs.getString("OC_BALANCE_REMARKS")));
                    objBalance.setCreateDateTime(rs.getTimestamp("OC_BALANCE_CREATETIME"));
                    objBalance.setUpdateDateTime(rs.getTimestamp("OC_BALANCE_UPDATETIME"));
                    objBalance.setUpdateUser(ScreenHelper.checkString(rs.getString("OC_BALANCE_UPDATEUID")));
                    objBalance.setVersion(rs.getInt("OC_BALANCE_VERSION"));
                    objBalance.setClosedTime(rs.getTimestamp("OC_BALANCE_CLOSEDTIME"));

                    vResults.addElement(objBalance);
                }
                rs.close();
                ps.close();
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
        return vResults;
    }

    public static Vector getNonClosedBalancesByOwnerDate(String sOwner, String sDate){
        PreparedStatement ps = null;
        ResultSet rs = null;

        Vector vBalances = new Vector();

        String sSelect = "SELECT * FROM OC_BALANCES WHERE OC_BALANCE_CLOSEDTIME IS NULL AND";

        if (sOwner.length() > 0 || sDate.length() > 0) {
            //sSelect += " WHERE";
            if (sOwner.length() > 0) sSelect += " OC_BALANCE_OWNERUID LIKE ? AND";
            if (sDate.length() > 0) sSelect += " OC_BALANCE_DATE >  ? AND";
        }
        sSelect = sSelect.substring(0, sSelect.length() - 3);
        if (Debug.enabled) {
            Debug.println("SELECT QUERY: " + sSelect);
        }
        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            ps = oc_conn.prepareStatement(sSelect);

            int iParams = 1;
            if (sOwner.length() > 0) ps.setString(iParams++, sOwner);
            if (sDate.length() > 0) ps.setDate(iParams++, ScreenHelper.getSQLDate(sDate));

            rs = ps.executeQuery();

            Balance objBalance;

            while(rs.next()){
                objBalance = new Balance();
                objBalance.setUid(ScreenHelper.checkString(rs.getString("OC_BALANCE_SERVERID")) + "." + ScreenHelper.checkString(rs.getString("OC_BALANCE_OBJECTID")));
                objBalance.setBalance(rs.getDouble("OC_BALANCE_VALUE"));
                objBalance.setMaximumBalance(rs.getDouble("OC_BALANCE_MAXIMUMBALANCE"));
                objBalance.setMinimumBalance(rs.getDouble("OC_BALANCE_MINIMUMBALANCE"));
                objBalance.setDate(rs.getTimestamp("OC_BALANCE_DATE"));
                ObjectReference or = new ObjectReference();
                or.setObjectType(ScreenHelper.checkString(rs.getString("OC_BALANCE_OWNERTYPE")));
                or.setObjectUid(ScreenHelper.checkString(rs.getString("OC_BALANCE_OWNERUID")));
                objBalance.setOwner(or);
                objBalance.setRemarks(ScreenHelper.checkString(rs.getString("OC_BALANCE_REMARKS")));
                objBalance.setCreateDateTime(rs.getTimestamp("OC_BALANCE_CREATETIME"));
                objBalance.setUpdateDateTime(rs.getTimestamp("OC_BALANCE_UPDATETIME"));
                objBalance.setUpdateUser(ScreenHelper.checkString(rs.getString("OC_BALANCE_UPDATEUID")));
                objBalance.setVersion(rs.getInt("OC_BALANCE_VERSION"));
                objBalance.setClosedTime(rs.getTimestamp("OC_BALANCE_CLOSEDTIME"));
                vBalances.addElement(objBalance);
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
        return vBalances;
    }
}