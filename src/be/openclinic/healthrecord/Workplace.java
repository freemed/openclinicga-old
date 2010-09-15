package be.openclinic.healthrecord;

import be.mxs.common.util.db.MedwanQuery;
import be.mxs.common.util.system.ScreenHelper;

import java.sql.Connection;
import java.sql.Timestamp;
import java.sql.PreparedStatement;
import java.sql.ResultSet;


/**
 * Created by IntelliJ IDEA.
 * User: mxs_david
 * Date: 15-jan-2007
 * Time: 11:14:06
 * To change this template use Options | File Templates.
 */
public class Workplace {
    private int id;
    private String messageKey;
    private Timestamp deletedate;
    private Timestamp updatetime;
    private int updateuserid;
    private String NL;
    private String FR;
    private int active;
    private String serviceId;

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public String getMessageKey() {
        return messageKey;
    }

    public void setMessageKey(String messageKey) {
        this.messageKey = messageKey;
    }

    public Timestamp getDeletedate() {
        return deletedate;
    }

    public void setDeletedate(Timestamp deletedate) {
        this.deletedate = deletedate;
    }

    public Timestamp getUpdatetime() {
        return updatetime;
    }

    public void setUpdatetime(Timestamp updatetime) {
        this.updatetime = updatetime;
    }

    public int getUpdateuserid() {
        return updateuserid;
    }

    public void setUpdateuserid(int updateuserid) {
        this.updateuserid = updateuserid;
    }

    public String getNL() {
        return NL;
    }

    public void setNL(String NL) {
        this.NL = NL;
    }

    public String getFR() {
        return FR;
    }

    public void setFR(String FR) {
        this.FR = FR;
    }

    public int getActive() {
        return active;
    }

    public void setActive(int active) {
        this.active = active;
    }

    public String getServiceId() {
        return serviceId;
    }

    public void setServiceId(String serviceId) {
        this.serviceId = serviceId;
    }

    public static void saveWorkplaceById( int iId,String sMessageKey,Timestamp deletedate,String sUpdateuserid,String sNL,String sFR,Integer intActive,String sServiceId){
        PreparedStatement ps = null;

        String sUpdateSet = "";

        if(sMessageKey.length() > 0){
            sUpdateSet += " messageKey = ?,";
        }
        if(deletedate!=null){
            sUpdateSet += " deletedate = ?,";
        }
        if(sUpdateuserid.length() > 0){
            sUpdateSet += " updateuserid = ?,";
        }
        if(sNL.length() > 0){
            sUpdateSet += " NL = ?,";
        }
        if(sFR.length() > 0){
            sUpdateSet += " FR = ?,";
        }
        if(intActive!=null){
            sUpdateSet += " active = ?,";
        }
        if(sServiceId.length() > 0){
            sUpdateSet += " serviceId = ?,";
        }

        String sUpdate = "UPDATE Workplaces SET " + sUpdateSet + "  updatetime=? WHERE id=?";

        int iIndex = 1;
        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            ps = oc_conn.prepareStatement(sUpdate);
            if(sMessageKey.length() > 0){
                ps.setString(iIndex++,sMessageKey);
            }
            if(deletedate!=null){
                ps.setTimestamp(iIndex++,deletedate);
            }
            if(sUpdateuserid.length() > 0){
                ps.setInt(iIndex++,Integer.parseInt(sUpdateuserid));
            }
            if(sNL.length() > 0){
                ps.setString(iIndex++,sNL);
            }
            if(sFR.length() > 0){
                ps.setString(iIndex++,sFR);
            }
            if(intActive!=null){
                ps.setInt(iIndex++,intActive.intValue());
            }
            if(sServiceId.length() > 0){
                ps.setString(iIndex++,sServiceId);
            }
            ps.setTimestamp(iIndex++,ScreenHelper.getSQLTime());
            ps.setInt(iIndex++,iId);
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

    public static Workplace selectWorkplace(int iId){
        PreparedStatement ps = null;
        ResultSet rs = null;

        Workplace objWP = null;

        String sSelect = " SELECT * FROM Workplaces WHERE id = ?";

        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            ps = oc_conn.prepareStatement(sSelect);
            ps.setInt(1,iId);
            rs = ps.executeQuery();

            if(rs.next()){
                objWP = new Workplace();

                objWP.setId(iId);
                objWP.setActive(rs.getInt("active"));
                objWP.setDeletedate(rs.getTimestamp("deletedate"));
                objWP.setFR(ScreenHelper.checkString("FR"));
                objWP.setNL(ScreenHelper.checkString("NL"));
                objWP.setMessageKey(ScreenHelper.checkString(rs.getString("messageKey")));
                objWP.setServiceId(ScreenHelper.checkString(rs.getString("serviceId")));
                objWP.setUpdatetime(rs.getTimestamp("updatetime"));
                objWP.setUpdateuserid(rs.getInt("updateuserid"));
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
        return objWP;
    }
}
