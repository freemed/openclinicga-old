package be.openclinic.system;

import be.mxs.common.util.db.MedwanQuery;

import java.sql.Connection;
import java.sql.PreparedStatement;

public class ItemTypeAttribute {
	private int itemTypeAttributeId;
    private String itemType;
    private String name;
    private String value;
    private int userid;
    private java.util.Date updateTime;


    //--- GETTERS & SETTERS -----------------------------------------------------------------------
    public String getItemType(){
        return itemType;
    }

    public void setItemType(String itemType){
        this.itemType = itemType;
    }

    public String getName(){
        return name;
    }

    public void setName(String name){
        this.name = name;
    }

    public String getValue(){
        return value;
    }

    public void setValue(String value){
        this.value = value;
    }

    public int getUserid(){
        return userid;
    }

    public void setUserid(int userid){
        this.userid = userid;
    }
    
    public void setUpdateTime(java.util.Date updateTime){
    	this.updateTime = updateTime;
    }
    
    public java.util.Date getUpdateTime(){
    	return updateTime;
    }

    //--- DELETE ----------------------------------------------------------------------------------
    public int delete(){
        PreparedStatement ps = null;
        int updatedRows = 0;

        String sDelete = "DELETE FROM ItemTypeAttributes WHERE itemTypeAttributeId = ?";
        Connection oc_conn = MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            ps = oc_conn.prepareStatement(sDelete);
            ps.setInt(1,this.itemTypeAttributeId);
            
            updatedRows = ps.executeUpdate();
        }
        catch(Exception e){
            e.printStackTrace();
        }
        finally{
            try{
                if(ps!=null) ps.close();
                oc_conn.close();
            }
            catch(Exception e){
                e.printStackTrace();
            }
        }
        
        return updatedRows;
    }

    //--- INSERT ----------------------------------------------------------------------------------
    public int insert(){
        PreparedStatement ps = null;

        String sInsert = "INSERT INTO ItemTypeAttributes(itemTypeAttributeId,itemType,name,"+
                         MedwanQuery.getInstance().getConfigString("valueColumn")+",userid,updatetime)"+
                         " VALUES(?,?,?,?,?,?)";
        int updatedRows = 0;
        Connection oc_conn = MedwanQuery.getInstance().getOpenclinicConnection();
        try{
        	this.itemTypeAttributeId = MedwanQuery.getInstance().getOpenclinicCounter("ItemTypeAttributes");
            ps = oc_conn.prepareStatement(sInsert);
            ps.setInt(1,this.itemTypeAttributeId);
            ps.setString(2,this.getItemType());
            ps.setString(3,this.getName());
            ps.setString(4,this.getValue());
            ps.setInt(5,this.userid);
            this.updateTime = new java.util.Date();
            ps.setTimestamp(6,new java.sql.Timestamp(this.updateTime.getTime()));
            
            updatedRows = ps.executeUpdate();
        }
        catch(Exception e){
            e.printStackTrace();
        }
        finally{
            try{
                if(ps!=null) ps.close();
                oc_conn.close();
            }
            catch(Exception e){
                e.printStackTrace();
            }
        }
        
        return updatedRows;
    }
    
}
