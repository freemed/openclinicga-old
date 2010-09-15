package be.openclinic.healthrecord;

import be.mxs.common.util.db.MedwanQuery;
import be.mxs.common.util.system.ScreenHelper;

import java.sql.Connection;
import java.sql.Timestamp;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.Hashtable;
import java.util.Vector;


public class FunctionCategory {
    private int id;
    private String messageKey;
    private int updateuserid;
    private Timestamp updatetime;
    private Timestamp deletedate;
    private String  NL;
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

    public int getUpdateuserid() {
        return updateuserid;
    }

    public void setUpdateuserid(int updateuserid) {
        this.updateuserid = updateuserid;
    }

    public Timestamp getUpdatetime() {
        return updatetime;
    }

    public void setUpdatetime(Timestamp updatetime) {
        this.updatetime = updatetime;
    }

    public Timestamp getDeletedate() {
        return deletedate;
    }

    public void setDeletedate(Timestamp deletedate) {
        this.deletedate = deletedate;
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

    public void updateFunctionCategory(String sId){
        PreparedStatement ps = null;

        String sUpdate = "UPDATE FunctionCategories SET NL=?, FR=?, updatetime=?, updateuserid=?, serviceId=? WHERE id=?";

        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            ps = oc_conn.prepareStatement(sUpdate);
            ps.setString(1,this.getNL());
            ps.setString(1,this.getFR());
            ps.setTimestamp(3,this.getUpdatetime());
            ps.setInt(4,this.getUpdateuserid());
            ps.setString(5,this.getServiceId());
            ps.setInt(6,Integer.parseInt(sId));
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

    public static Hashtable selectLanguages(String sId){
        PreparedStatement ps = null;
        ResultSet rs = null;

        Hashtable hResult = new Hashtable();


        String sSelect = "SELECT NL,FR FROM FunctionCategories WHERE id = ?";

        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            ps = oc_conn.prepareStatement(sSelect);
            ps.setInt(1,Integer.parseInt(sId));
            rs = ps.executeQuery();

            if(rs.next()){
                hResult.put("NL",ScreenHelper.checkString(rs.getString("NL")));
                hResult.put("FR",ScreenHelper.checkString(rs.getString("FR")));
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
        return hResult;
    }

    public static Vector searchFunctionCategories(String sFindCategory,String sTblLanguage,String sSearchContractID){
        PreparedStatement ps = null;
        ResultSet rs = null;

        Vector vCategories = new Vector();
        FunctionCategory objFC;

        Connection loc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            String sSelect = "SELECT * FROM FunctionCategories WHERE deletedate IS NULL ";

            if(sFindCategory.length() > 0){
                sSelect+= " AND "+ScreenHelper.getConfigParam("lowerCompare",sTblLanguage)+" LIKE ?";
            }
            if(sSearchContractID.length() > 0){
                sSelect+= " AND serviceId = ?";
            }
            else {
                sSelect+= " AND (serviceId is null or serviceId='')";
            }

            sSelect+= " ORDER BY "+ScreenHelper.getConfigParam("lowerCompare",sTblLanguage);

            ps = loc_conn.prepareStatement(sSelect);

            if(sFindCategory.length() > 0){
               ps.setString(1,sFindCategory.toLowerCase()+"%");
            }

            if(sSearchContractID.length() > 0){
                if(sFindCategory.length() > 0) ps.setString(2,sSearchContractID);
                else                           ps.setString(1,sSearchContractID);
            }

            rs = ps.executeQuery();

            while(rs.next()){
                objFC = new FunctionCategory();
                objFC.setId(rs.getInt("id"));
                objFC.setMessageKey(ScreenHelper.checkString(rs.getString("messageKey")));
                objFC.setActive(rs.getInt("active"));
                objFC.setNL(ScreenHelper.checkString(rs.getString("NL")));
                objFC.setFR(ScreenHelper.checkString(rs.getString("FR")));
                objFC.setServiceId(ScreenHelper.checkString(rs.getString("serviceId")));
                objFC.setUpdatetime(rs.getTimestamp("updatetime"));
                objFC.setUpdateuserid(rs.getInt("updateuserid"));
                objFC.setDeletedate(rs.getTimestamp("deletedate"));

                vCategories.addElement(objFC);
            }
            rs.close();
            ps.close();
        }catch(Exception e){
            e.printStackTrace();
        }finally{
            try{
                if(rs!=null)rs.close();
                if(ps!=null)ps.close();
                loc_conn.close();
            }catch(Exception e){
                e.printStackTrace();
            }
        }
        return vCategories;
    }
}
