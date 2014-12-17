package be.openclinic.meals;

import be.mxs.common.util.db.MedwanQuery;
import be.mxs.common.util.system.Debug;
import be.openclinic.common.OC_Object;

import java.util.List;
import java.util.LinkedList;
import java.util.Iterator;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;


public class MealItem extends OC_Object{
    public String name;
    public String description;
    public String unit;
    public float quantity;
    public List nutricientItems;


    //--- CONSTRUCTOR (1) ---
    public MealItem(){        
        this.name = "";
        this.description = "";
        this.unit = "";
        this.quantity = Float.parseFloat("0");
        this.nutricientItems = new LinkedList();
    }

    //--- CONSTRUCTOR (2) ---
    public MealItem(String uid){
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
                sSql = "INSERT INTO OC_MEAL_ITEM(OC_MEAL_ITEM_SERVERID, OC_MEAL_ITEM_OBJECTID,"+
                       " OC_MEAL_ITEM_NAME, OC_MEAL_ITEM_DESCRIPTION, OC_MEAL_ITEM_UNIT,OC_MEAL_ITEM_CREATETIME,"+
                	   " OC_MEAL_ITEM_UPDATEUID) VALUES(?,?,?,?,?,?,?)";
                Debug.println(sSql);
                ps = oc_conn.prepareStatement(sSql);
                
                ids = new String[]{MedwanQuery.getInstance().getConfigString("serverId"),
                		           MedwanQuery.getInstance().getOpenclinicCounter("OC_MEALS_ITEMS")+""};
                ps.setInt(1,Integer.parseInt(ids[0]));
                ps.setInt(2,Integer.parseInt(ids[1]));
                ps.setString(3,this.name);
                ps.setString(4,this.description);
                ps.setString(5,this.unit);
                ps.setTimestamp(6,new Timestamp(new java.util.Date().getTime())); // now
                ps.setString(7,useruid);
                ps.executeUpdate();
                
                this.setUid(ids[0]+"."+ids[1]);
            }
            else{
                sSql = "UPDATE OC_MEAL_ITEM SET"+
                       "  OC_MEAL_ITEM_NAME=?, OC_MEAL_ITEM_UPDATETIME=?, OC_MEAL_ITEM_UPDATEUID=?,"+
                	   "  OC_MEAL_ITEM_DESCRIPTION=?, OC_MEAL_ITEM_UNIT=?"+
                       " WHERE OC_MEAL_ITEM_SERVERID = ? AND OC_MEAL_ITEM_OBJECTID = ?";
                Debug.println(sSql);
                ps = oc_conn.prepareStatement(sSql);
                
                ps.setString(1,this.name);
                ps.setTimestamp(2,new Timestamp(new java.util.Date().getTime())); // now
                ps.setString(3,useruid);
                ps.setString(4,this.description);
                ps.setString(5,this.unit);
                ps.setInt(6,Integer.parseInt(ids[0]));
                ps.setInt(7,Integer.parseInt(ids[1]));
                ps.executeUpdate();
            }
            
            setNutricientItems(useruid);
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
    
    //--- SET NUTRIENT ITEMS ----------------------------------------------------------------------
    public void setNutricientItems(String useruid){
        deleteAllNutricientItemsFromMealItem();
        
        if(this.nutricientItems!=null && this.nutricientItems.size() > 0){
            PreparedStatement ps = null;
            ResultSet rs = null;
            String sSql;
            
            Iterator iter = this.nutricientItems.iterator();
            while(iter.hasNext()){
                NutricientItem nutricientitem =(NutricientItem)iter.next();
            
                Connection oc_conn = MedwanQuery.getInstance().getOpenclinicConnection();
                try{
                    sSql = "INSERT INTO OC_NUTRICIENT_COMPONENT(OC_NUTRICIENT_MEAL_ITEMUID, OC_NUTRICIENT_ITEMUID,"+
                           "  OC_NUTRICIENT_ITEMQUANTITY,OC_NUTRICIENT_COMPONENT_CREATETIME,OC_NUTRICIENT_COMPONENT_UPDATEUID)"+
                           " VALUES(?,?,?,?,?)";
                    Debug.println(sSql);
                    ps = oc_conn.prepareStatement(sSql);
                    
                    ps.setString(1,this.getUid());
                    ps.setString(2,nutricientitem.getUid());
                    ps.setFloat(3,nutricientitem.quantity);
                    ps.setTimestamp(4,new Timestamp(new java.util.Date().getTime())); // now
                    ps.setString(5,useruid);
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
                    catch(SQLException e){
                        Debug.printStackTrace(e);
                    }
                }
            }
        }
    }
    
    //--- DELETE ALL NUTRIENT ITEMS ---------------------------------------------------------------
    public void deleteAllNutricientItemsFromMealItem(){
        PreparedStatement ps = null;
        ResultSet rs = null;
        
        Connection oc_conn = MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            String sSql = "DELETE FROM OC_NUTRICIENT_COMPONENT"+
                          " WHERE OC_NUTRICIENT_MEAL_ITEMUID = ?";
            Debug.println(sSql);
            ps = oc_conn.prepareStatement(sSql);
            ps.setString(1,this.getUid());
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
            catch(SQLException e){
                Debug.printStackTrace(e);
            }
        }
    }
    
    //--- DELETE ----------------------------------------------------------------------------------
    public void delete(){
        deleteAllNutricientItemsFromMealItem();
        
        PreparedStatement ps = null;
        ResultSet rs = null;
        
        Connection oc_conn = MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            String sSql = "DELETE FROM OC_MEAL_ITEM"+
                          " WHERE OC_MEAL_ITEM_SERVERID = ? AND OC_MEAL_ITEM_OBJECTID = ?";
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
            catch(SQLException e){
                Debug.printStackTrace(e);
            }
        }
    }
    
    //--- GET -------------------------------------------------------------------------------------
    public static MealItem get(MealItem item){
        boolean mealFound = false;
        PreparedStatement ps = null;
        ResultSet rs = null;
        
        Connection oc_conn = MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            String sSql = "SELECT * FROM OC_MEAL_ITEM"+
                          " WHERE OC_MEAL_ITEM_SERVERID = ? AND OC_MEAL_ITEM_OBJECTID = ?";
            Debug.println(sSql);
            ps = oc_conn.prepareStatement(sSql);
            ps.setInt(1,Integer.parseInt(item.getUid().substring(0, item.getUid().indexOf("."))));
            ps.setInt(2,Integer.parseInt(item.getUid().substring(item.getUid().indexOf(".")+1)));

            rs = ps.executeQuery();
            if(rs.next()){
                item.name = rs.getString("OC_MEAL_ITEM_NAME");
                item.description = rs.getString("OC_MEAL_ITEM_DESCRIPTION");
                item.unit = rs.getString("OC_MEAL_ITEM_UNIT");
                item = importNutricientItems(item);
                mealFound = true;
            }
        } 
        catch(Exception e){
            Debug.printProjectErr(e, Thread.currentThread().getStackTrace());
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
        
        if(mealFound){
            return item;
        }
        else{
            return null;
        }
    }
    
    //--- IMPORT NUTRIENT ITEMS -------------------------------------------------------------------
    public static MealItem importNutricientItems(MealItem item){
        PreparedStatement ps = null;
        ResultSet rs = null;
        Connection oc_conn = MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            String sSql = "SELECT * FROM OC_NUTRICIENT_COMPONENT"+
                          " WHERE OC_NUTRICIENT_MEAL_ITEMUID = ?";
            Debug.println(sSql);
            ps = oc_conn.prepareStatement(sSql);
            ps.setString(1,item.getUid());
            item.nutricientItems = new LinkedList();

            rs = ps.executeQuery();
            NutricientItem nutricientItem = null;
            while(rs.next()){
                nutricientItem = new NutricientItem(rs.getString("OC_NUTRICIENT_ITEMUID"));
                nutricientItem = NutricientItem.get(nutricientItem);
                
                if(nutricientItem!=null){
                    nutricientItem.quantity = rs.getFloat("OC_NUTRICIENT_ITEMQUANTITY");
                    item.nutricientItems.add(nutricientItem);
                }
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
    public static List getList(MealItem findItem){
        List foundObjects = new LinkedList();
        PreparedStatement ps = null;
        ResultSet rs = null;
        
        Connection oc_conn = MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            String sSql = "SELECT * FROM OC_MEAL_ITEM WHERE 1=1";
            if(findItem.name!=null && findItem.name.trim().length() > 0){
            	if(findItem.name.length()==1){
                    sSql+= " AND OC_MEAL_ITEM_NAME LIKE '"+findItem.name+"%'"; // search from begin
            	}
            	else{
                    sSql+= " AND OC_MEAL_ITEM_NAME LIKE '%"+findItem.name+"%'";
            	}
            }
            
            if(findItem.description!=null && findItem.description.trim().length() > 0){
                sSql+= " AND OC_MEAL_ITEM_DESCRIPTION LIKE '%"+findItem.description+"%'";
            }
            
            sSql+= " ORDER BY OC_MEAL_ITEM_NAME";
            Debug.println(sSql);
            ps = oc_conn.prepareStatement(sSql);
            
            rs = ps.executeQuery();
            while(rs.next()){
                MealItem item = new MealItem();
                
                item.setUid(rs.getString("OC_MEAL_ITEM_SERVERID")+"."+rs.getString("OC_MEAL_ITEM_OBJECTID"));
                item.name = rs.getString("OC_MEAL_ITEM_NAME");
                item.description = rs.getString("OC_MEAL_ITEM_DESCRIPTION");
                item.unit = rs.getString("OC_MEAL_ITEM_UNIT");
                item = importNutricientItems(item);
                
                foundObjects.add(item);
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
        
        return foundObjects;
    }
    
}