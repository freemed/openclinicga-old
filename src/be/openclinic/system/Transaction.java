package be.openclinic.system;

import be.mxs.common.util.db.MedwanQuery;
import be.mxs.common.util.system.ScreenHelper;

import java.sql.Timestamp;
import java.sql.ResultSet;
import java.sql.PreparedStatement;
import java.sql.Connection;
import java.util.Vector;
import java.util.Hashtable;

/**
 * Created by IntelliJ IDEA.
 * User: mxs_david
 * Date: 10-jan-2007
 * Time: 13:43:41
 * To change this template use Options | File Templates.
 */
public class Transaction {

    private int transactionId;
    private Timestamp creationDate;
    private String transactionType;
    private Timestamp updatetime;
    private int status;
    private int healthRecordId;
    private int userId;
    private int serverid;
    private int version;
    private int versionserverid;
    private Timestamp ts;

    public int getTransactionId() {
        return transactionId;
    }

    public void setTransactionId(int transactionId) {
        this.transactionId = transactionId;
    }

    public Timestamp getCreationDate() {
        return creationDate;
    }

    public void setCreationDate(Timestamp creationDate) {
        this.creationDate = creationDate;
    }

    public String getTransactionType() {
        return transactionType;
    }

    public void setTransactionType(String transactionType) {
        this.transactionType = transactionType;
    }

    public Timestamp getUpdatetime() {
        return updatetime;
    }

    public void setUpdatetime(Timestamp updatetime) {
        this.updatetime = updatetime;
    }

    public int getStatus() {
        return status;
    }

    public void setStatus(int status) {
        this.status = status;
    }

    public int getHealthRecordId() {
        return healthRecordId;
    }

    public void setHealthRecordId(int healthRecordId) {
        this.healthRecordId = healthRecordId;
    }

    public int getUserId() {
        return userId;
    }

    public void setUserId(int userId) {
        this.userId = userId;
    }

    public int getServerid() {
        return serverid;
    }

    public void setServerid(int serverid) {
        this.serverid = serverid;
    }

    public int getVersion() {
        return version;
    }

    public void setVersion(int version) {
        this.version = version;
    }

    public int getVersionserverid() {
        return versionserverid;
    }

    public void setVersionserverid(int versionserverid) {
        this.versionserverid = versionserverid;
    }

    public Timestamp getTs() {
        return ts;
    }

    public void setTs(Timestamp ts) {
        this.ts = ts;
    }

    public static String selectMaxTransactionIdByServer(String serverid){
        PreparedStatement ps = null;
        ResultSet rs = null;

        String sSelect = "SELECT max(transactionId) AS MaxId FROM Transactions WHERE serverid = ? ";

        String value = "";

        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            ps = oc_conn.prepareStatement(sSelect);
            ps.setInt(1, Integer.parseInt(serverid));
            rs = ps.executeQuery();

            if(rs.next()){
                value = ScreenHelper.checkString(rs.getString("MaxId"));
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
        return value;
    }

    public static Transaction getSummaryTransaction(String sItemTypes,String sPersonId){
        PreparedStatement ps = null;
        ResultSet rs = null;

        String sSelect = "SELECT t.updateTime, t.transactionId, t.serverid FROM Transactions t, Items i WHERE"
                    + " t.healthRecordId = ? AND i.transactionId = t.transactionId AND i.serverid=t.serverid AND "
                    + "i.type in (" + sItemTypes + ") ORDER BY t.updateTime DESC, t.transactionId DESC ";

        Transaction transaction = null;

        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            ps = oc_conn.prepareStatement(sSelect);
            ps.setInt(1, MedwanQuery.getInstance().getHealthRecordIdFromPersonId(Integer.parseInt(sPersonId)));
            rs = ps.executeQuery();

            if(rs.next()){
                transaction = new Transaction();
                transaction.setUpdatetime(rs.getTimestamp("updateTime"));
                transaction.setTransactionId(rs.getInt("transactionId"));
                transaction.setServerid(rs.getInt("serverid"));
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
        return transaction;
    }

    public static Transaction getTransaction(int iTransactionId,int iServerId){
        PreparedStatement ps = null;
        ResultSet rs = null;

        Transaction transaction = null;

        String sSelect = "SELECT * FROM Transactions WHERE transactionId = ? AND serverid = ?";

        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            ps = oc_conn.prepareStatement(sSelect);
            ps.setInt(1,iTransactionId);
            ps.setInt(2,iServerId);

            rs = ps.executeQuery();



            if(rs.next()){
                transaction = new Transaction();
                transaction.setTransactionId(rs.getInt("transactionId"));
                transaction.setServerid(rs.getInt("serverid"));
                transaction.setTransactionType(ScreenHelper.checkString(rs.getString("transactionType")));
                transaction.setUserId(rs.getInt("userId"));
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
        return transaction;
    }

    public static String getTransactionContext(int iTransactionId,int iHealthRecordId, String sTransactionType){
        PreparedStatement ps = null;
        ResultSet rs = null;

        String sSelect = "SELECT " + ScreenHelper.getConfigString("valueColumn") +
                                " from Transactions a,Items b" +
                                "  where a.transactionId = ?" +
                                "   and a.healthRecordId = ?" +
                                "   and a.transactionType = ?" +
                                "   and a.serverid=b.serverid" +
                                "   and a.transactionId=b.transactionId" +
                                "   and b.type = 'be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CONTEXT_CONTEXT'" +
                                "  order by updateTime DESC,a.serverid,a.transactionId";
        String sContext = null;
        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            ps = oc_conn.prepareStatement(sSelect);
            ps.setInt(1,iTransactionId);
            ps.setInt(2,iHealthRecordId);
            ps.setString(3,sTransactionType);
            rs = ps.executeQuery();

            if(rs.next()){
                sContext = ScreenHelper.checkString(rs.getString(ScreenHelper.getConfigString("valueColumn")));
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
        return sContext;
    }

    public static Vector getLabHistoryListTransactionData(String sHealthRecordId){
        PreparedStatement ps = null;
        ResultSet rs = null;

        Vector vTranData = new Vector();
        Hashtable hTranData;

        String sSelect = " SELECT transactionId,serverId,updateTime " +
                         " FROM Transactions " +
                         " WHERE healthRecordId=? " +
                         " AND transactionType='be.mxs.common.model.vo.healthrecord.IConstants.TRANSACTION_TYPE_LAB_RESULT'" +
                         " ORDER BY updateTime DESC";
        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            ps = oc_conn.prepareStatement(sSelect);
            ps.setInt(1, Integer.parseInt(sHealthRecordId));
            rs = ps.executeQuery();

            while(rs.next()){
                hTranData = new Hashtable();
                hTranData.put("transactionId",ScreenHelper.checkString(rs.getString("transactionId")));
                hTranData.put("serverId",ScreenHelper.checkString(rs.getString("serverId")));
                hTranData.put("updateTime",rs.getDate("updateTime"));

                vTranData.addElement(hTranData);
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
        return vTranData;
    }

    public static Vector getUpdateTimes(java.sql.Date dBegin,java.sql.Date dEnd,int iUserId){
        PreparedStatement ps = null;
        ResultSet rs = null;

        Vector vUpdatetimes = new Vector();

        String sSelect = "Select updateTime FROM Transactions WHERE updateTime BETWEEN ? AND ? AND userId = ? ";

        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            ps =  oc_conn.prepareStatement(sSelect);
            ps.setDate(1,dBegin);
            ps.setDate(2,dEnd);
            ps.setInt(3,iUserId);

            rs = ps.executeQuery();

            while(rs.next()){
                vUpdatetimes.addElement(rs.getDate("updateTime"));
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
        return vUpdatetimes;
    }
}
