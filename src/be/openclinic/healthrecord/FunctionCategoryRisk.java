package be.openclinic.healthrecord;

import be.mxs.common.util.db.MedwanQuery;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Timestamp;

public class FunctionCategoryRisk {
    private int functionCategoryId;
    private int riskId;
    private Timestamp updatetime;

    public int getFunctionCategoryId() {
        return functionCategoryId;
    }

    public void setFunctionCategoryId(int functionCategoryId) {
        this.functionCategoryId = functionCategoryId;
    }

    public int getRiskId() {
        return riskId;
    }

    public void setRiskId(int riskId) {
        this.riskId = riskId;
    }

    public Timestamp getUpdatetime() {
        return updatetime;
    }

    public void setUpdatetime(Timestamp updatetime) {
        this.updatetime = updatetime;
    }

    public void deleteCategoryRisk(){
        PreparedStatement ps = null;

        String sDelete = "DELETE FROM FunctionCategoryRisks WHERE functionCategoryId = ?";

        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            ps = oc_conn.prepareStatement(sDelete);
            ps.setInt(1,this.getFunctionCategoryId());
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

    public void addCategoryRisk(){
        PreparedStatement ps = null;

        String sUpdate = " INSERT INTO FunctionCategoryRisks(riskId,functionCategoryId,updatetime)"+
                         " VALUES(?,?,?)";
        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            ps = oc_conn.prepareStatement(sUpdate);
            ps.setInt(1,this.getRiskId());
            ps.setInt(2,this.getFunctionCategoryId());
            ps.setTimestamp(3,this.getUpdatetime());
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

    public static boolean isChecked(String sRiskId,String sFunctionCategoryId){
        PreparedStatement ps = null;
        ResultSet rs = null;

        boolean bChecked = false;

        String sSelect = " SELECT functionCategoryId FROM FunctionCategoryRisks"+
                         " WHERE riskId = ? AND functionCategoryId = ?";

        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            ps = oc_conn.prepareStatement(sSelect);
            ps.setInt(1,Integer.parseInt(sRiskId));
            ps.setInt(2,Integer.parseInt(sFunctionCategoryId));

            rs = ps.executeQuery();
            if(rs.next()){
                bChecked = true;
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
        return bChecked;
    }
}
