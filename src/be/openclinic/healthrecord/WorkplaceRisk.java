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
 * Time: 10:58:21
 * To change this template use Options | File Templates.
 */
public class WorkplaceRisk {
    private int riskId;
    private int workplaceId;
    private int active;
    private Timestamp updatetime;

    public int getRiskId() {
        return riskId;
    }

    public void setRiskId(int riskId) {
        this.riskId = riskId;
    }

    public int getWorkplaceId() {
        return workplaceId;
    }

    public void setWorkplaceId(int workplaceId) {
        this.workplaceId = workplaceId;
    }

    public int getActive() {
        return active;
    }

    public void setActive(int active) {
        this.active = active;
    }

    public Timestamp getUpdatetime() {
        return updatetime;
    }

    public void setUpdatetime(Timestamp updatetime) {
        this.updatetime = updatetime;
    }

    public static void saveWorkplaceRiskByWorkplace(Integer intRiskId,Integer intActive,int iWorkplaceId){
        PreparedStatement ps = null;

        String sUpdateSet = "";

        if(intRiskId!=null){
            sUpdateSet += " riskId = ?,";
        }
        if(intActive!=null){
            sUpdateSet += " active = ?,";
        }

        String sUpdate = " UPDATE WorkplaceRisks SET " + sUpdateSet + " updatetime=? WHERE workplaceId=?";

        int iIndex = 1;

        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            ps = oc_conn.prepareStatement(sUpdate);
            if(intRiskId!=null){
                ps.setInt(iIndex++,intRiskId.intValue());
            }
            if(intActive!=null){
                ps.setInt(iIndex++,intActive.intValue());
            }
            ps.setTimestamp(iIndex++,ScreenHelper.getSQLTime());
            ps.setInt(iIndex++,iWorkplaceId);
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

    public static boolean saveWorkplaceRiskByWorkplaceAndRisk(int iRiskId, int iWorkplaceId, Integer intActive){
        PreparedStatement ps = null;

        boolean bUpdated = true;

        String sUpdateSet = "";

        if(intActive!=null){
            sUpdateSet += " active = ?,";
        }

        String sUpdate = "UPDATE WorkplaceRisks SET " + sUpdateSet + " updatetime=? WHERE riskId=? AND workplaceId=?";

        int iIndex = 1;
        int iUpdate;
        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            ps = oc_conn.prepareStatement(sUpdate);
            if(intActive!=null){
                ps.setInt(iIndex++,intActive.intValue());
            }
            ps.setTimestamp(iIndex++,ScreenHelper.getSQLTime());
            ps.setInt(iIndex++,iRiskId);
            ps.setInt(iIndex++,iWorkplaceId);
            iUpdate = ps.executeUpdate();
            ps.close();
            if(iUpdate == 0){
                bUpdated = false;
            }
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
        return bUpdated;
    }

    public static void addWorkplaceRisk(int iRiskId,int iWorkplaceId){
        PreparedStatement ps = null;

        String sInsert = "INSERT INTO WorkplaceRisks(riskId,workplaceId,active,updatetime) VALUES(?,?,1,?)";

        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            ps = oc_conn.prepareStatement(sInsert);
            ps.setInt(1,iRiskId);
            ps.setInt(2,iWorkplaceId);
            ps.setTimestamp(4,ScreenHelper.getSQLTime());
            ps.execute();
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

    public static boolean existsActive(int iRiskId, int iWorkplaceId){
        PreparedStatement ps = null;
        ResultSet rs = null;

        boolean bExists = false;

        String sSelect = " SELECT 1 FROM WorkplaceRisks WHERE riskId = ? AND workplaceId = ? and active = 1";

        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            ps = oc_conn.prepareStatement(sSelect);
            ps.setInt(1,iRiskId);
            ps.setInt(2,iWorkplaceId);

            rs = ps.executeQuery();
            if(rs.next()){
                bExists = true;
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
        return bExists;
    }

}
