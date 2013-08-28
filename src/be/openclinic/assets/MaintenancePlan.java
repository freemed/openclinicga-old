package be.openclinic.assets;

import be.openclinic.common.OC_Object;
import be.mxs.common.util.db.MedwanQuery;
import be.mxs.common.util.system.Debug;
import be.mxs.common.util.system.ScreenHelper;

import java.text.DecimalFormat;
import java.text.SimpleDateFormat;
import java.util.*;
import java.io.StringReader;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;

import org.dom4j.Document;
import org.dom4j.Element;
import org.dom4j.io.SAXReader;


public class MaintenancePlan extends OC_Object {
    public int serverId;
    public int objectId;    

    public String name; // 255
    public String assetUID; // 50
    public java.util.Date startDate;
    public int frequency;
    public String operator; // 255
    public String planManager; // 255
    public String instructions; // text

    
    //--- CONSTRUCTOR ---
    public MaintenancePlan(){
        serverId = -1;
        objectId = -1;

        name = "";
        assetUID = "";
        startDate = null;
        frequency = -1;
        operator = "";
        planManager = "";
        instructions = "";
    }
    
    //--- GET NAME --------------------------------------------------------------------------------
    public static String getName(String sPlanUID){
    	String sPlanName = "";

        PreparedStatement ps = null;
        ResultSet rs = null;
        
        Connection oc_conn = MedwanQuery.getInstance().getOpenclinicConnection();
        
        try{
            String sSql = "SELECT OC_MAINTENANCEPLAN_NAME FROM OC_MAINTENANCEPLANS"+
                          " WHERE (OC_MAINTENANCEPLAN_SERVERID = ? AND OC_MAINTENANCEPLAN_OBJECTID = ?)";
            ps = oc_conn.prepareStatement(sSql);
            ps.setInt(1,Integer.parseInt(sPlanUID.substring(0,sPlanUID.indexOf("."))));
            ps.setInt(2,Integer.parseInt(sPlanUID.substring(sPlanUID.indexOf(".")+1)));

            // execute
            rs = ps.executeQuery();
            if(rs.next()){
                sPlanName = ScreenHelper.checkString(rs.getString("OC_MAINTENANCEPLAN_NAME"));
            }
        }
        catch(Exception e){
        	if(Debug.enabled) e.printStackTrace();
            Debug.printProjectErr(e,Thread.currentThread().getStackTrace());
        }
        finally{
            try{
                if(rs!=null) rs.close();
                if(ps!=null) ps.close();
                oc_conn.close();
            }
            catch(SQLException se){
                Debug.printProjectErr(se,Thread.currentThread().getStackTrace());
            }
        }
        
    	return sPlanName;
    }
        
    //--- STORE -----------------------------------------------------------------------------------
    public boolean store(String userUid){
    	boolean errorOccurred = false;
        PreparedStatement ps = null;
        ResultSet rs = null;
        String sSql;
        
        Connection oc_conn = MedwanQuery.getInstance().getOpenclinicConnection();
                
        try{            
            if(getUid().equals("-1")){            	  
                // insert new plan
                sSql = "INSERT INTO OC_MAINTENANCEPLANS(OC_MAINTENANCEPLAN_SERVERID,OC_MAINTENANCEPLAN_OBJECTID,"+
                       "  OC_MAINTENANCEPLAN_NAME,OC_MAINTENANCEPLAN_ASSETUID,OC_MAINTENANCEPLAN_STARTDATE,"+
                	   "  OC_MAINTENANCEPLAN_FREQUENCY,OC_MAINTENANCEPLAN_OPERATOR,OC_MAINTENANCEPLAN_PLANMANAGER,"+
                       "  OC_MAINTENANCEPLAN_INSTRUCTIONS,"+
                       "  OC_MAINTENANCEPLAN_UPDATETIME,OC_MAINTENANCEPLAN_UPDATEID)"+
                       " VALUES(?,?,?,?,?,?,?,?,?,?,?)"; // 11
                ps = oc_conn.prepareStatement(sSql);
                
                int serverId = MedwanQuery.getInstance().getConfigInt("serverId"),
                    objectId = MedwanQuery.getInstance().getOpenclinicCounter("OC_MAINTENANCEPLANS");
                this.setUid(serverId+"."+objectId);
                                
                int psIdx = 1;
                ps.setInt(psIdx++,serverId);
                ps.setInt(psIdx++,objectId);
                
                ps.setString(psIdx++,name);
                ps.setString(psIdx++,assetUID);

                // purchaseDate date might be unspecified
                if(startDate!=null){
                    ps.setDate(psIdx++,new java.sql.Date(startDate.getTime()));
                }
                else{
                    ps.setDate(psIdx++,null);
                }
                
                ps.setInt(psIdx++,frequency);
                ps.setString(psIdx++,operator);
                ps.setString(psIdx++,planManager);
                ps.setString(psIdx++,instructions);
                
                // update-info
                ps.setTimestamp(psIdx++,new Timestamp(new java.util.Date().getTime())); // now
                ps.setString(psIdx,userUid);
                
                ps.executeUpdate();
            } 
            else{
                // update existing record
                sSql = "UPDATE OC_MAINTENANCEPLANS SET"+
                       "  OC_MAINTENANCEPLAN_NAME = ?, OC_MAINTENANCEPLAN_ASSETUID = ?, OC_MAINTENANCEPLAN_STARTDATE = ?,"+
                	   "  OC_MAINTENANCEPLAN_FREQUENCY = ?, OC_MAINTENANCEPLAN_OPERATOR = ?, OC_MAINTENANCEPLAN_PLANMANAGER = ?,"+
                       "  OC_MAINTENANCEPLAN_INSTRUCTIONS = ?,"+
                       "  OC_MAINTENANCEPLAN_UPDATETIME = ?, OC_MAINTENANCEPLAN_UPDATEID = ?"+ // update-info
                       " WHERE (OC_MAINTENANCEPLAN_SERVERID = ? AND OC_MAINTENANCEPLAN_OBJECTID = ?)"; // identification
                ps = oc_conn.prepareStatement(sSql);

                int psIdx = 1;
                
                ps.setString(psIdx++,name);
                ps.setString(psIdx++,assetUID);

                // purchaseDate date might be unspecified
                if(startDate!=null){
                    ps.setDate(psIdx++,new java.sql.Date(startDate.getTime()));
                }
                else{
                    ps.setDate(psIdx++,null);
                }
                
                ps.setInt(psIdx++,frequency);
                ps.setString(psIdx++,operator);
                ps.setString(psIdx++,planManager);
                ps.setString(psIdx++,instructions);

                // update-info
                ps.setTimestamp(psIdx++,new Timestamp(new java.util.Date().getTime())); // now
                ps.setString(psIdx++,userUid);
                
                // where
                ps.setInt(psIdx++,Integer.parseInt(getUid().substring(0,getUid().indexOf("."))));
                ps.setInt(psIdx,Integer.parseInt(getUid().substring(getUid().indexOf(".")+1)));
                
                ps.executeUpdate();
            }            
        }
        catch(Exception e){
        	errorOccurred = true;
        	if(Debug.enabled) e.printStackTrace();
            Debug.printProjectErr(e,Thread.currentThread().getStackTrace());
        }
        finally{
            try{
                if(rs!=null) rs.close();
                if(ps!=null) ps.close();
                oc_conn.close();
            }
            catch(SQLException se){
                Debug.printProjectErr(se,Thread.currentThread().getStackTrace());
            }
        }
        
        return errorOccurred;
    }
    
    //--- DELETE ----------------------------------------------------------------------------------
    public static boolean delete(String sPlanUID){
    	boolean errorOccurred = false;
        PreparedStatement ps = null;
        ResultSet rs = null;
        
        Connection oc_conn = MedwanQuery.getInstance().getOpenclinicConnection();
        
        try{
            String sSql = "DELETE FROM OC_MAINTENANCEPLANS"+
                          " WHERE (OC_MAINTENANCEPLAN_SERVERID = ? AND OC_MAINTENANCEPLAN_OBJECTID = ?)";
            ps = oc_conn.prepareStatement(sSql);
            ps.setInt(1,Integer.parseInt(sPlanUID.substring(0,sPlanUID.indexOf("."))));
            ps.setInt(2,Integer.parseInt(sPlanUID.substring(sPlanUID.indexOf(".")+1)));
            
            ps.executeUpdate();
        }
        catch(Exception e){
        	errorOccurred = true;
        	if(Debug.enabled) e.printStackTrace();
            Debug.printProjectErr(e,Thread.currentThread().getStackTrace());
        }
        finally{
            try{
                if(rs!=null) rs.close();
                if(ps!=null) ps.close();
                oc_conn.close();
            }
            catch(SQLException se){
                Debug.printProjectErr(se,Thread.currentThread().getStackTrace());
            }
        }
        
        return errorOccurred;
    }
    
    //--- GET -------------------------------------------------------------------------------------
    public static MaintenancePlan get(MaintenancePlan plan){
    	return get(plan.getUid());
    }
       
    public static MaintenancePlan get(String splanUid){
    	MaintenancePlan plan = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        
        Connection oc_conn = MedwanQuery.getInstance().getOpenclinicConnection();
        
        try{
            String sSql = "SELECT * FROM OC_MAINTENANCEPLANS"+
                          " WHERE (OC_MAINTENANCEPLAN_SERVERID = ? AND OC_MAINTENANCEPLAN_OBJECTID = ?)";
            ps = oc_conn.prepareStatement(sSql);
            ps.setInt(1,Integer.parseInt(splanUid.substring(0,splanUid.indexOf("."))));
            ps.setInt(2,Integer.parseInt(splanUid.substring(splanUid.indexOf(".")+1)));

            // execute
            rs = ps.executeQuery();
            if(rs.next()){
                plan = new MaintenancePlan();
                plan.setUid(rs.getString("OC_MAINTENANCEPLAN_SERVERID")+"."+rs.getString("OC_MAINTENANCEPLAN_OBJECTID"));
                plan.serverId = Integer.parseInt(rs.getString("OC_MAINTENANCEPLAN_SERVERID"));
                plan.objectId = Integer.parseInt(rs.getString("OC_MAINTENANCEPLAN_OBJECTID"));
                
                plan.name         = ScreenHelper.checkString(rs.getString("OC_MAINTENANCEPLAN_NAME"));
                plan.assetUID     = ScreenHelper.checkString(rs.getString("OC_MAINTENANCEPLAN_ASSETUID"));
                plan.startDate    = rs.getDate("OC_MAINTENANCEPLAN_STARTDATE");
                plan.frequency    = rs.getInt("OC_MAINTENANCEPLAN_FREQUENCY");
                plan.operator     = ScreenHelper.checkString(rs.getString("OC_MAINTENANCEPLAN_OPERATOR"));
                plan.planManager  = ScreenHelper.checkString(rs.getString("OC_MAINTENANCEPLAN_PLANMANAGER"));
                plan.instructions = ScreenHelper.checkString(rs.getString("OC_MAINTENANCEPLAN_INSTRUCTIONS"));
                
                // update-info
                plan.setUpdateDateTime(rs.getTimestamp("OC_MAINTENANCEPLAN_UPDATETIME"));
                plan.setUpdateUser(rs.getString("OC_MAINTENANCEPLAN_UPDATEID"));
            }
        }
        catch(Exception e){
        	if(Debug.enabled) e.printStackTrace();
            Debug.printProjectErr(e,Thread.currentThread().getStackTrace());
        }
        finally{
            try{
                if(rs!=null) rs.close();
                if(ps!=null) ps.close();
                oc_conn.close();
            }
            catch(SQLException se){
                Debug.printProjectErr(se,Thread.currentThread().getStackTrace());
            }
        }
        
        return plan;
    }
        
    //--- GET LIST --------------------------------------------------------------------------------
    public static List<MaintenancePlan> getList(){
    	return getList(new MaintenancePlan());     	
    }
    
    public static List<MaintenancePlan> getList(MaintenancePlan findItem){
        List<MaintenancePlan> foundObjects = new LinkedList();
        PreparedStatement ps = null;
        ResultSet rs = null;
        
        Connection oc_conn = MedwanQuery.getInstance().getOpenclinicConnection();
        
        try{
        	//*** compose query ***************************
            String sSql = "SELECT * FROM OC_MAINTENANCEPLANS WHERE 1=1"; // 'where' facilitates further composition of query

            //*** search-criteria *** 
            if(findItem.name.length() > 0){
                sSql+= " AND OC_MAINTENANCEPLAN_NAME LIKE '%"+findItem.name+"%'";
            }
            if(ScreenHelper.checkString(findItem.assetUID).length() > 0){
                sSql+= " AND OC_MAINTENANCEPLAN_ASSETUID = '"+findItem.assetUID+"'";
            }
            if(ScreenHelper.checkString(findItem.operator).length() > 0){
                sSql+= " AND OC_MAINTENANCEPLAN_OPERATOR LIKE '%"+findItem.operator+"%'";
            }
            
            sSql+= " ORDER BY OC_MAINTENANCEPLAN_NAME ASC";
            
            ps = oc_conn.prepareStatement(sSql);
            
                        
            //*** execute query ***************************
            rs = ps.executeQuery();
            MaintenancePlan plan;
            
            while(rs.next()){
            	plan = new MaintenancePlan();   
            	plan.setUid(rs.getString("OC_MAINTENANCEPLAN_SERVERID")+"."+rs.getString("OC_MAINTENANCEPLAN_OBJECTID"));
                plan.serverId = Integer.parseInt(rs.getString("OC_MAINTENANCEPLAN_SERVERID"));
                plan.objectId = Integer.parseInt(rs.getString("OC_MAINTENANCEPLAN_OBJECTID"));

                plan.name         = ScreenHelper.checkString(rs.getString("OC_MAINTENANCEPLAN_NAME"));
                plan.assetUID     = ScreenHelper.checkString(rs.getString("OC_MAINTENANCEPLAN_ASSETUID"));
                plan.startDate    = rs.getDate("OC_MAINTENANCEPLAN_STARTDATE");
                plan.frequency    = rs.getInt("OC_MAINTENANCEPLAN_FREQUENCY");
                plan.operator     = ScreenHelper.checkString(rs.getString("OC_MAINTENANCEPLAN_OPERATOR"));
                plan.planManager  = ScreenHelper.checkString(rs.getString("OC_MAINTENANCEPLAN_PLANMANAGER"));
                plan.instructions = ScreenHelper.checkString(rs.getString("OC_MAINTENANCEPLAN_INSTRUCTIONS"));
                
                // update-info
                plan.setUpdateDateTime(rs.getTimestamp("OC_MAINTENANCEPLAN_UPDATETIME"));
                plan.setUpdateUser(rs.getString("OC_MAINTENANCEPLAN_UPDATEID"));
                
                foundObjects.add(plan);
            }
        }
        catch(Exception e){
        	if(Debug.enabled) e.printStackTrace();
            Debug.printProjectErr(e,Thread.currentThread().getStackTrace());
        }
        finally{
            try{
                if(rs!=null) rs.close();
                if(ps!=null) ps.close();
                oc_conn.close();
            }
            catch(SQLException se){
                Debug.printProjectErr(se,Thread.currentThread().getStackTrace());
            }
        }
        
        return foundObjects;
    }

}