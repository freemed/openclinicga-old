package be.openclinic.system;

import be.mxs.common.util.db.MedwanQuery;
import be.mxs.common.util.system.ScreenHelper;

import java.sql.Connection;
import java.sql.Timestamp;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.Vector;
import java.util.Hashtable;

/**
 * Created by IntelliJ IDEA.
 * User: mxs_david
 * Date: 10-jan-2007
 * Time: 14:07:15
 * To change this template use Options | File Templates.
 */
public class Healthrecord {
    private int healthRecordId;
    private Timestamp dateBegin;
    private Timestamp dateEnd;
    private int personId;
    private int serverid;
    private int version;
    private int versionserverid;

    public int getHealthRecordId() {
        return healthRecordId;
    }

    public void setHealthRecordId(int healthRecordId) {
        this.healthRecordId = healthRecordId;
    }

    public Timestamp getDateBegin() {
        return dateBegin;
    }

    public void setDateBegin(Timestamp dateBegin) {
        this.dateBegin = dateBegin;
    }

    public Timestamp getDateEnd() {
        return dateEnd;
    }

    public void setDateEnd(Timestamp dateEnd) {
        this.dateEnd = dateEnd;
    }

    public int getPersonId() {
        return personId;
    }

    public void setPersonId(int personId) {
        this.personId = personId;
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

    public static void updateServerId(String serverid){
        PreparedStatement ps = null;

        String sUpdate = "UPDATE Healthrecord SET serverid = ?,versionserverid=?";

        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            ps = oc_conn.prepareStatement(sUpdate);
            ps.setInt(1,Integer.parseInt(serverid));
            ps.setInt(2,Integer.parseInt(serverid));
            ps.executeUpdate();
            ps.close();
        }catch(Exception e){
            e.printStackTrace();
        }finally{
            try{
                if(ps!=null)ps.close();
                oc_conn.close();
            }catch(Exception e){
                e.printStackTrace();
            }
        }
    }

    public static Vector getAudiometricData(String sPersonId){
        PreparedStatement ps = null;
        ResultSet rs = null;

        Vector vAudiometric = new Vector();
        Hashtable hAudiometric;

        String sSelect = " SELECT t.transactionId, i.type, i.value, updateTime"
                        +" FROM Healthrecord h, Transactions t, Items i WHERE "
                        +" h.personId = "+sPersonId+" AND t.healthRecordId = h.healthRecordId "
                        +" AND t.transactionType = 'be.mxs.common.model.vo.healthrecord.IConstants.TRANSACTION_TYPE_AUDIOMETRY'"
                        +" AND i.transactionId = t.transactionId and i.serverid=t.serverid"
                        +" AND i.type like 'be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_AUDIOMETRY_%' ORDER BY updateTime DESC ";

        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            ps = oc_conn.prepareStatement(sSelect);
            rs = ps.executeQuery();

            while(rs.next()){
                hAudiometric = new Hashtable();
                hAudiometric.put("transactionid", ScreenHelper.checkString(rs.getString("transactionId")));
                hAudiometric.put("type", ScreenHelper.checkString(rs.getString("type")));
                hAudiometric.put("value", ScreenHelper.checkString(rs.getString("value")));
                hAudiometric.put("updatetime", rs.getDate("updateTime"));

                vAudiometric.addElement(hAudiometric);
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
        return vAudiometric;
    }

    public static Vector getApplyingPhysicians(){
        PreparedStatement ps = null;
        ResultSet rs = null;

        Vector vMedicalImagingRequest = new Vector();
        Hashtable hMedicalImagingRequest;
        String sSelect = "SELECT lastname, firstname, p.value AS medCode FROM UserParameters p, Admin a, Users u"
                            +" WHERE "+MedwanQuery.getInstance().getConfigParam("lowerCompare","parameter")+" = 'organisationid' "
                            +" AND value like '9__' AND u.userid = p.userid AND a.personid = u.personid ORDER BY a.searchname ";

    	Connection ad_conn = MedwanQuery.getInstance().getAdminConnection();
        try{
            ps = ad_conn.prepareStatement(sSelect);
            rs = ps.executeQuery();

            while(rs.next()){
                hMedicalImagingRequest = new Hashtable();
                hMedicalImagingRequest.put("lastname",ScreenHelper.checkString(rs.getString("lastname")));
                hMedicalImagingRequest.put("firstname",ScreenHelper.checkString(rs.getString("firstname")));
                hMedicalImagingRequest.put("medcode",ScreenHelper.checkString(rs.getString("medCode")));

                vMedicalImagingRequest.addElement(hMedicalImagingRequest);
            }
            rs.close();
            ps.close();

        }catch(Exception e){
            e.printStackTrace();
        }finally{
            try{
                if(rs!=null)rs.close();
                if(ps!=null)ps.close();
                ad_conn.close();
            }catch(Exception e){
                e.printStackTrace();
            }
        }
        return vMedicalImagingRequest;
    }

    public static Vector getRespiratoryFunctionLengthData(String sPersonId){
        PreparedStatement ps = null;
        ResultSet rs = null;

        Vector vRespiratoryFunction = new Vector();

        String sSelect = "SELECT i.value AS ow_value FROM Healthrecord h, Transactions t, Items i"+
                     " WHERE personId = ?"+
                     "  AND t.healthRecordId = h.healthRecordId AND i.transactionId = t.transactionId AND i.serverid=t.serverid"+
                     "  AND i.type = 'be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_BIOMETRY_HEIGHT'"+
                     " ORDER BY t.updateTime DESC";

        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            ps = oc_conn.prepareStatement(sSelect);
            ps.setInt(1,Integer.parseInt(sPersonId));
            rs = ps.executeQuery();

            while(rs.next()){
                vRespiratoryFunction.addElement(ScreenHelper.checkString(rs.getString("ow_value")));
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
        return vRespiratoryFunction;
    }

    public static Vector getRespiratoryFunctionFev1Data(String sPersonId){
        PreparedStatement ps = null;
        ResultSet rs = null;

        Vector vRespiratoryFunction = new Vector();

        String sSelect = "SELECT t.updateTime AS ut, i.value AS ow_value FROM Healthrecord h, Transactions t, Items i WHERE "
            + " h.personId = " + sPersonId + " AND h.healthRecordId = t.healthRecordId "
            + " AND t.transactionType = 'be.mxs.common.model.vo.healthrecord.IConstants.TRANSACTION_TYPE_RESP_FUNC_EX'"
            + " AND i.transactionId = t.transactionId "
            + " AND i.type = 'be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_RESP_FUNC_EX_FEV1'"
            + " ORDER BY t.updateTime ASC ";

        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            ps = oc_conn.prepareStatement(sSelect);
            ps.setInt(1,Integer.parseInt(sPersonId));
            rs = ps.executeQuery();

            Hashtable hRespiratoryFunction;

            while(rs.next()){
                hRespiratoryFunction = new Hashtable();
                hRespiratoryFunction.put("ow_value",ScreenHelper.checkString(rs.getString("ow_value")));
                hRespiratoryFunction.put("updatetime",rs.getDate("ut"));
                vRespiratoryFunction.addElement(hRespiratoryFunction);
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
        return vRespiratoryFunction;
    }

    public static Vector getRespiratoryFunctionFVCData(String sPersonId){
        PreparedStatement ps = null;
        ResultSet rs = null;

        Vector vRespiratoryFunction = new Vector();

        String sSelect =  " SELECT t.updateTime AS ut, i.value AS ow_value FROM Healthrecord h, Transactions t, Items i WHERE "
                        + " h.personId = " + sPersonId + " AND h.healthRecordId = t.healthRecordId "
                        + " AND t.transactionType = 'be.mxs.common.model.vo.healthrecord.IConstants.TRANSACTION_TYPE_RESP_FUNC_EX'"
                        + " AND i.transactionId = t.transactionId "
                        + " AND i.type = 'be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_RESP_FUNC_EX_FVC'"
                        + " ORDER BY t.updateTime ASC ";

        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            ps = oc_conn.prepareStatement(sSelect);
            ps.setInt(1,Integer.parseInt(sPersonId));
            rs = ps.executeQuery();

            Hashtable hRespiratoryFunction;

            while(rs.next()){
                hRespiratoryFunction = new Hashtable();
                hRespiratoryFunction.put("ow_value",ScreenHelper.checkString(rs.getString("ow_value")));
                hRespiratoryFunction.put("updatetime",rs.getDate("ut"));
                vRespiratoryFunction.addElement(hRespiratoryFunction);
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
        return vRespiratoryFunction;
    }

    public static Vector getVaccinationHistoryData(String sPersonId, String sVaccinationType){
        PreparedStatement ps = null;
        ResultSet rs = null;

        Vector vVaccinationHistory = new Vector();

        String sSelect = "SELECT i2.* FROM Healthrecord h, Transactions t, Items i,Items i2 WHERE "
            + " h.personId = ? AND "
            + "t.healthRecordId = h.healthRecordId AND "
            + "t.transactionType = 'be.mxs.common.model.vo.healthrecord.IConstants.TRANSACTION_TYPE_VACCINATION' AND "
            + "i.transactionId = t.transactionId AND "
            + "i.serverid = t.serverid AND "
            + "i2.transactionId = t.transactionId AND "
            + "i2.serverid = t.serverid AND "
            + "i.type = 'be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_VACCINATION_TYPE' AND "
            + "i.value = ? order by i2.transactionId,i2.serverid";



        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            ps = oc_conn.prepareStatement(sSelect);
            ps.setString(1,sPersonId);
            ps.setString(2,sVaccinationType);
            rs = ps.executeQuery();

            Item item;

            while(rs.next()){
                item = new Item();
                item.setType(ScreenHelper.checkString(rs.getString("type")));
                item.setValue(ScreenHelper.checkString(rs.getString("value")));
                item.setServerid(rs.getInt("serverid"));
                item.setTransactionId(rs.getInt("transactionId"));

                vVaccinationHistory.addElement(item);
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
        return vVaccinationHistory;
    }
}
