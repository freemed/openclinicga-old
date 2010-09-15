package be.openclinic.system;

import be.mxs.common.util.db.MedwanQuery;

import java.sql.Connection;
import java.sql.PreparedStatement;

/**
 * Created by IntelliJ IDEA.
 * User: mxs-rudy
 * Date: 1-mrt-2007
 * Time: 15:55:01
 * To change this template use File | Settings | File Templates.
 */
public class ItemTypeAttribute {
    private String itemType;
    private String name;
    private String value;
    private int userid;


    public String getItemType() {
        return itemType;
    }

    public void setItemType(String itemType) {
        this.itemType = itemType;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getValue() {
        return value;
    }

    public void setValue(String value) {
        this.value = value;
    }

    public int getUserid() {
        return userid;
    }

    public void setUserid(int userid) {
        this.userid = userid;
    }

    public int delete(){
        PreparedStatement ps = null;

        int updatedRows = 0;

        String sDelete = "DELETE FROM ItemTypeAttributes WHERE itemType=? AND name=? AND userid=?";
        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            ps = oc_conn.prepareStatement(sDelete);
            ps.setString(1, this.getItemType());
            ps.setString(2,this.getName());
            ps.setInt(3, this.getUserid());
            updatedRows = ps.executeUpdate();
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
        return updatedRows;
    }

    public int insert(){
        PreparedStatement ps = null;

        String sInsert = "INSERT INTO ItemTypeAttributes(itemType,name," + MedwanQuery.getInstance().getConfigString("valueColumn") + " ,userid) VALUES(?,?,?,?)";
        int updatedRows = 0;
        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            ps = oc_conn.prepareStatement(sInsert);
            ps.setString(1,this.getItemType());
            ps.setString(2,this.getName());
            ps.setString(3,this.getValue());
            ps.setInt(4,this.userid);
            updatedRows = ps.executeUpdate();
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
        return updatedRows;
    }
}
