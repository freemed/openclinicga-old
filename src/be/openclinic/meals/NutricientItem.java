package be.openclinic.meals;

import be.openclinic.common.OC_Object;
import be.mxs.common.util.db.MedwanQuery;
import be.mxs.common.util.system.Debug;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.util.List;
import java.util.LinkedList;

public class NutricientItem extends OC_Object{
    public String name;
    public String unit;
    public float quantity;
    
    //--- CONSTRUCTOR (1) ---
    public NutricientItem(){       
        this.name = "";
        this.unit = "";
        this.quantity = Float.parseFloat("0");
    }

    //--- CONSTRUCTOR (2) ---
    public NutricientItem(String uid){
    	this();
        setUid(uid);
    }
    
    //--- UPDATE OR INSERT ------------------------------------------------------------------------
    public void updateOrInsert(String useruid){
        PreparedStatement ps = null;
        ResultSet rs = null;
        String sSql;
        String ids[];
        
        Connection oc_conn = MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            ids = this.getUid().split("\\.");
            
            if(getUid().equals("-1")){
                sSql = "INSERT INTO OC_NUTRICIENT_ITEM (OC_NUTRICIENT_SERVERID,OC_NUTRICIENT_OBJECTID,"+
                       "  OC_NUTRICIENT_NAME,OC_NUTRICIENT_UNIT,OC_NUTRICIENT_ITEM_CREATETIME,"+
                	   "  OC_NUTRICIENT_ITEM_UPDATEUID)"+
                       " VALUES(?,?,?,?,?,?)";
                Debug.println(sSql);
                ps = oc_conn.prepareStatement(sSql);

                ids = new String[]{MedwanQuery.getInstance().getConfigString("serverId"),
                		           MedwanQuery.getInstance().getOpenclinicCounter("OC_NUTRICIENT_ITEM")+""};
                ps.setInt(1,Integer.parseInt(ids[0]));
                ps.setInt(2,Integer.parseInt(ids[1]));
                ps.setString(3,this.name);
                ps.setString(4,this.unit);
                ps.setTimestamp(5,new Timestamp(new java.util.Date().getTime())); // now
                ps.setString(6,useruid);
                ps.executeUpdate();
            }
            else{
                sSql = "UPDATE OC_NUTRICIENT_ITEM SET OC_NUTRICIENT_NAME=?, OC_NUTRICIENT_UNIT=?,"+
                       "  OC_NUTRICIENT_ITEM_UPDATETIME=?, OC_NUTRICIENT_ITEM_UPDATEUID=?"+
                	   " WHERE OC_NUTRICIENT_SERVERID = ? AND OC_NUTRICIENT_OBJECTID = ?";
                Debug.println(sSql);
                ps = oc_conn.prepareStatement(sSql);
                
                ps.setString(1,this.name);
                ps.setString(2,this.unit);
                ps.setTimestamp(3,new Timestamp(new java.util.Date().getTime())); // now
                ps.setString(4,useruid);
                ps.setInt(5,Integer.parseInt(ids[0]));
                ps.setInt(6,Integer.parseInt(ids[1]));
                ps.executeUpdate();
            }
        }
        catch(Exception e){
            Debug.printStackTrace(e);
        }
        finally{
            try{
                if(rs!=null) rs.close();
                if(ps!=null) ps.close();
                oc_conn.close();
            }
            catch(SQLException e){
                Debug.printStackTrace(e);
            }
        }
    }
    
    //--- DELETE ----------------------------------------------------------------------------------
    public void delete(){
        PreparedStatement ps = null;
        ResultSet rs = null;
        
        Connection oc_conn = MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            String sSql = "DELETE FROM OC_NUTRICIENT_ITEM"+
                          " WHERE OC_NUTRICIENT_SERVERID = ? AND OC_NUTRICIENT_OBJECTID = ?";
            Debug.println(sSql);
            ps = oc_conn.prepareStatement(sSql);
            ps.setInt(1,Integer.parseInt(getUid().substring(0,getUid().indexOf("."))));
            ps.setInt(2,Integer.parseInt(getUid().substring(getUid().indexOf(".")+1)));
            ps.executeUpdate();
        }
        catch(Exception e){
            Debug.printStackTrace(e);
        }
        finally{
            try{
                if(rs!=null) rs.close();
                if(ps!=null) ps.close();
                oc_conn.close();
            }
            catch (SQLException e){
                Debug.printStackTrace(e);
            }
        }
    }
    
    //--- GET -------------------------------------------------------------------------------------
    public static NutricientItem get(NutricientItem item){
        PreparedStatement ps = null;
        ResultSet rs = null;
        
        Connection oc_conn = MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            String sSql = "SELECT * FROM OC_NUTRICIENT_ITEM"+
                          " WHERE OC_NUTRICIENT_SERVERID = ? AND OC_NUTRICIENT_OBJECTID = ?";
            Debug.println(sSql);
            ps = oc_conn.prepareStatement(sSql);            
            ps.setInt(1,Integer.parseInt(item.getUid().substring(0,item.getUid().indexOf("."))));
            ps.setInt(2,Integer.parseInt(item.getUid().substring(item.getUid().indexOf(".")+1)));

            rs = ps.executeQuery();
            if(rs.next()){
                item.name = rs.getString("OC_NUTRICIENT_NAME");
                item.unit = rs.getString("OC_NUTRICIENT_UNIT");
            }
            else{
                item = null;
            }
        }
        catch(Exception e){
            Debug.printStackTrace(e);
        }
        finally{
            try{
                if(rs!=null) rs.close();
                if(ps!=null) ps.close();
                oc_conn.close();
            }
            catch(SQLException e){
                Debug.printStackTrace(e);
            }
        }
        
        return item;
    }
    
    //--- GET LIST --------------------------------------------------------------------------------
    public static List getList(NutricientItem findItem){
        List list = new LinkedList();
        PreparedStatement ps = null;
        ResultSet rs = null;
        
        Connection oc_conn = MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            String sSql = "SELECT * FROM OC_NUTRICIENT_ITEM";
            if(findItem.name!=null && findItem.name.trim().length() > 0){
            	if(findItem.name.length()==1){
                    sSql+= " WHERE OC_NUTRICIENT_NAME LIKE '"+findItem.name+"%'"; // search from begin
            	}
            	else{
                    sSql+= " WHERE OC_NUTRICIENT_NAME LIKE '%"+findItem.name+"%'";
            	}
            }
            sSql+= " ORDER BY OC_NUTRICIENT_NAME";
            Debug.println(sSql);
            ps = oc_conn.prepareStatement(sSql);

            rs = ps.executeQuery();
            while(rs.next()){
                NutricientItem item = new NutricientItem();
                item.setUid(rs.getString("OC_NUTRICIENT_SERVERID")+"."+rs.getString("OC_NUTRICIENT_OBJECTID"));
                item.name = rs.getString("OC_NUTRICIENT_NAME");
                item.unit = rs.getString("OC_NUTRICIENT_UNIT");
                
                list.add(item);
            }
        }
        catch(Exception e){
            Debug.printStackTrace(e);
        }
        finally{
            try{
                if(rs!=null) rs.close();
                if(ps!=null) ps.close();
                oc_conn.close();
            }
            catch(SQLException e){
                Debug.printStackTrace(e);
            }
        }
        
        return list;
    }

}