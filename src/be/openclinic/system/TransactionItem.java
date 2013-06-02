package be.openclinic.system;

import be.mxs.common.util.db.MedwanQuery;
import be.mxs.common.util.system.ScreenHelper;

import java.sql.Connection;
import java.sql.Timestamp;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.Vector;

public class TransactionItem {
    private String transactionTypeId;
    private String itemTypeId;
    private String defaultValue;
    private String modifier;
    private int priority;
    private Timestamp updatetime;

    public String getTransactionTypeId() {
        return transactionTypeId;
    }

    public void setTransactionTypeId(String transactionTypeId) {
        this.transactionTypeId = transactionTypeId;
    }

    public String getItemTypeId() {
        return itemTypeId;
    }

    public void setItemTypeId(String itemTypeId) {
        this.itemTypeId = itemTypeId;
    }

    public String getDefaultValue() {
        return defaultValue;
    }

    public void setDefaultValue(String defaultValue) {
        this.defaultValue = defaultValue;
    }

    public String getModifier() {
        return modifier;
    }

    public void setModifier(String modifier) {
        this.modifier = modifier;
    }

    public int getPriority() {
        return priority;
    }

    public void setPriority(int priority) {
        this.priority = priority;
    }

    public Timestamp getUpdatetime() {
        return updatetime;
    }

    public void setUpdatetime(Timestamp updatetime) {
        this.updatetime = updatetime;
    }

    public static boolean exists(String sTranid,String sItemid){
        PreparedStatement ps = null;
        ResultSet rs = null;

        boolean bExists = false;

        String sSelect = "SELECT 1 FROM TransactionItems WHERE transactionTypeId=? AND itemTypeId=?";

        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            ps = oc_conn.prepareStatement(sSelect);
            ps.setString(1,sTranid);
            ps.setString(2,sItemid);

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

    public static TransactionItem  selectTransactionItem(String sTranid, String sItemid){
        PreparedStatement ps = null;
        ResultSet rs = null;

        TransactionItem objTI = new TransactionItem();

        String sSelect =" SELECT defaultValue,modifier FROM TransactionItems WHERE transactionTypeId=? AND itemTypeId=?";

        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            ps = oc_conn.prepareStatement(sSelect);
            ps.setString(1,sTranid);
            ps.setString(2,sItemid);

            rs = ps.executeQuery();

            if(rs.next()){
                objTI.setItemTypeId(sItemid);
                objTI.setTransactionTypeId(sTranid);
                objTI.setDefaultValue(ScreenHelper.checkString(rs.getString("defaultValue")));
                objTI.setModifier(ScreenHelper.checkString(rs.getString("modifier")));
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

        return objTI;
    }

    public static void addTransactionItem(TransactionItem objTI){
        PreparedStatement ps = null;


        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            String sQuery= "DELETE from TransactionItems where transactionTypeId=? and itemTypeId=?"; 
            ps = oc_conn.prepareStatement(sQuery);
            ps.setString(1,objTI.getTransactionTypeId());
            ps.setString(2,objTI.getItemTypeId());
            ps.executeUpdate();
            ps.close();
            
            sQuery  = "INSERT INTO TransactionItems(transactionTypeId,itemTypeId,defaultValue,modifier) VALUES(?,?,?,?)";
            ps = oc_conn.prepareStatement(sQuery);
            ps.setString(1,objTI.getTransactionTypeId());
            ps.setString(2,objTI.getItemTypeId());
            ps.setString(3,objTI.getDefaultValue());
            ps.setString(4,objTI.getModifier());

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

    public static void deleteTransactionItem(String tranid, String itemid){
        PreparedStatement ps = null;

        String sDelete = " DELETE FROM TransactionItems WHERE transactionTypeId=? AND itemTypeId=?";

        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            ps = oc_conn.prepareStatement(sDelete);
            ps.setString(1,tranid);
            ps.setString(2,itemid);

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

    public static Vector selectTransactionItems(){
        PreparedStatement ps = null;
        ResultSet rs = null;

        Vector vTI = new Vector();

        String sSelect = "SELECT * FROM TransactionItems ORDER BY transactionTypeId";

        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            ps = oc_conn.prepareStatement(sSelect);

            rs = ps.executeQuery();

            TransactionItem objTI;

            while(rs.next()){
                objTI = new TransactionItem();

                objTI.setTransactionTypeId(ScreenHelper.checkString(rs.getString("transactionTypeId")));
                objTI.setItemTypeId(ScreenHelper.checkString(rs.getString("itemTypeId")));
                objTI.setDefaultValue(ScreenHelper.checkString(rs.getString("defaultValue")));
                objTI.setModifier(ScreenHelper.checkString(rs.getString("priority")));
                if(ScreenHelper.checkString(rs.getString("priority")).length() > 0){
                    objTI.setPriority(Integer.parseInt(rs.getString("priority")));
                }
                objTI.setUpdatetime(rs.getTimestamp("updatetime"));
                vTI.add(objTI);
            }
            rs.close();
            ps.close();
        }catch(Exception e){
            e.printStackTrace();
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

        return vTI;
    }

    public static Vector selectDistinctTransactionTypeId(){
        PreparedStatement ps = null;
        ResultSet rs = null;

        Vector vTI = new Vector();

        String sSelect = "SELECT DISTINCT transactionTypeId FROM TransactionItems ORDER BY 1";

        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            ps = oc_conn.prepareStatement(sSelect);
            rs = ps.executeQuery();

            while(rs.next()){
                vTI.addElement(ScreenHelper.checkString(rs.getString(1)));
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
        return vTI;
    }

    public static Vector selectByTransactionTypeId(String tranid){
        PreparedStatement ps = null;
        ResultSet rs = null;

        Vector vTI = new Vector();

        TransactionItem objTI;

        String sSelect = "SELECT itemTypeId, defaultValue, modifier FROM TransactionItems WHERE transactionTypeId=? ORDER BY 1";

        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            ps = oc_conn.prepareStatement(sSelect);
            ps.setString(1,tranid);

            rs = ps.executeQuery();

            while(rs.next()){
                objTI = new TransactionItem();
                objTI.setItemTypeId(ScreenHelper.checkString(rs.getString("itemTypeId")));
                objTI.setDefaultValue(ScreenHelper.checkString(rs.getString("defaultvalue")));
                objTI.setModifier(ScreenHelper.checkString(rs.getString("modifier")));

                vTI.addElement(objTI);
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

        return vTI;
    }

    public static void saveTransactionItem(TransactionItem objTI,String oldTranID,String oldItemID){
        PreparedStatement ps = null;

        String sUpdate = " UPDATE TransactionItems SET transactionTypeId=?,itemTypeId=?,defaultValue=?,modifier=?"+
                         " WHERE transactionTypeId=? AND itemTypeId=?";

        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            ps = oc_conn.prepareStatement(sUpdate);
            ps.setString(1,objTI.getTransactionTypeId());
            ps.setString(2,objTI.getItemTypeId());
            ps.setString(3,objTI.getDefaultValue());
            ps.setString(4,objTI.getModifier());
            ps.setString(5,oldTranID);
            ps.setString(6,oldItemID);
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
}
