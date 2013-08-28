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


public class MaintenanceOperation extends OC_Object {
    public int serverId;
    public int objectId;    

    public String maintenanceplanUID;
    public java.util.Date date;
    public String operator; // 255
    public String result; // 50
    public String comment; // 255
    public java.util.Date nextDate;
    
    // extra search-criteria
    public java.util.Date periodPerformedBegin;
    public java.util.Date periodPerformedEnd;
    
    
    //--- CONSTRUCTOR ---
    public MaintenanceOperation(){
        serverId = -1;
        objectId = -1;

        maintenanceplanUID = "";
        date = null;
        operator = ""; // 255
        result = ""; // 50
        comment = ""; // 255
        nextDate = null;
        
        periodPerformedBegin = null;
        periodPerformedEnd = null;
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
                // insert new operation
                sSql = "INSERT INTO OC_MAINTENANCEOPERATIONS(OC_MAINTENANCEOPERATION_SERVERID,OC_MAINTENANCEOPERATION_OBJECTID,"+
                       "  OC_MAINTENANCEOPERATION_MAINTENANCEPLANUID,OC_MAINTENANCEOPERATION_DATE,OC_MAINTENANCEOPERATION_OPERATOR,"+
                	   "  OC_MAINTENANCEOPERATION_RESULT,OC_MAINTENANCEOPERATION_COMMENT,OC_MAINTENANCEOPERATION_NEXTDATE,"+
                       "  OC_MAINTENANCEOPERATION_UPDATETIME,OC_MAINTENANCEOPERATION_UPDATEID)"+
                       " VALUES(?,?,?,?,?,?,?,?,?,?)"; // 10 
                ps = oc_conn.prepareStatement(sSql);
                
                int serverId = MedwanQuery.getInstance().getConfigInt("serverId"),
                    objectId = MedwanQuery.getInstance().getOpenclinicCounter("OC_MAINTENANCEOPERATIONS");
                this.setUid(serverId+"."+objectId);
                                
                int psIdx = 1;
                ps.setInt(psIdx++,serverId);
                ps.setInt(psIdx++,objectId);
                
                ps.setString(psIdx++,maintenanceplanUID);
                ps.setDate(psIdx++,new java.sql.Date(date.getTime()));
                ps.setString(psIdx++,operator);
                ps.setString(psIdx++,result);
                ps.setString(psIdx++,comment);
                
                // nextDate might be unspecified
                if(nextDate!=null){
                    ps.setDate(psIdx++,new java.sql.Date(nextDate.getTime()));
                }
                else{
                    ps.setDate(psIdx++,null);
                }
                
                // update-info
                ps.setTimestamp(psIdx++,new Timestamp(new java.util.Date().getTime())); // now
                ps.setString(psIdx,userUid);
                
                ps.executeUpdate();
            } 
            else{
                // update existing record
                sSql = "UPDATE OC_MAINTENANCEOPERATIONS SET"+
                       "  OC_MAINTENANCEOPERATION_MAINTENANCEPLANUID = ?, OC_MAINTENANCEOPERATION_DATE = ?,OC_MAINTENANCEOPERATION_OPERATOR = ?,"+
                	   "  OC_MAINTENANCEOPERATION_RESULT = ?, OC_MAINTENANCEOPERATION_COMMENT = ?, OC_MAINTENANCEOPERATION_NEXTDATE = ?,"+
                       "  OC_MAINTENANCEOPERATION_UPDATETIME = ?, OC_MAINTENANCEOPERATION_UPDATEID = ?"+ // update-info
                       " WHERE (OC_MAINTENANCEOPERATION_SERVERID = ? AND OC_MAINTENANCEOPERATION_OBJECTID = ?)"; // identification
                ps = oc_conn.prepareStatement(sSql);

                int psIdx = 1;
                ps.setString(psIdx++,maintenanceplanUID);
                ps.setDate(psIdx++,new java.sql.Date(date.getTime()));
                ps.setString(psIdx++,operator);
                ps.setString(psIdx++,result);
                ps.setString(psIdx++,comment);
                
                // nextDate might be unspecified
                if(nextDate!=null){
                    ps.setDate(psIdx++,new java.sql.Date(nextDate.getTime()));
                }
                else{
                    ps.setDate(psIdx++,null);
                }

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
    public static boolean delete(String sOperationUid){
    	boolean errorOccurred = false;
        PreparedStatement ps = null;
        ResultSet rs = null;
        
        Connection oc_conn = MedwanQuery.getInstance().getOpenclinicConnection();
        
        try{
            String sSql = "DELETE FROM OC_MAINTENANCEOPERATIONS"+
                          " WHERE (OC_MAINTENANCEOPERATION_SERVERID = ? AND OC_MAINTENANCEOPERATION_OBJECTID = ?)";
            ps = oc_conn.prepareStatement(sSql);
            ps.setInt(1,Integer.parseInt(sOperationUid.substring(0,sOperationUid.indexOf("."))));
            ps.setInt(2,Integer.parseInt(sOperationUid.substring(sOperationUid.indexOf(".")+1)));
            
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
    public static MaintenanceOperation get(MaintenanceOperation operation){
    	return get(operation.getUid());
    }
       
    public static MaintenanceOperation get(String sOperationUid){
    	MaintenanceOperation operation = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        
        Connection oc_conn = MedwanQuery.getInstance().getOpenclinicConnection();
        
        try{
            String sSql = "SELECT * FROM OC_MAINTENANCEOPERATIONS"+
                          " WHERE (OC_MAINTENANCEOPERATION_SERVERID = ? AND OC_MAINTENANCEOPERATION_OBJECTID = ?)";
            ps = oc_conn.prepareStatement(sSql);
            ps.setInt(1,Integer.parseInt(sOperationUid.substring(0,sOperationUid.indexOf("."))));
            ps.setInt(2,Integer.parseInt(sOperationUid.substring(sOperationUid.indexOf(".")+1)));

            // execute
            rs = ps.executeQuery();
            if(rs.next()){
                operation = new MaintenanceOperation();
                operation.setUid(rs.getString("OC_MAINTENANCEOPERATION_SERVERID")+"."+rs.getString("OC_MAINTENANCEOPERATION_OBJECTID"));
                operation.serverId = Integer.parseInt(rs.getString("OC_MAINTENANCEOPERATION_SERVERID"));
                operation.objectId = Integer.parseInt(rs.getString("OC_MAINTENANCEOPERATION_OBJECTID"));
                
                operation.maintenanceplanUID = ScreenHelper.checkString(rs.getString("OC_MAINTENANCEOPERATION_MAINTENANCEPLANUID"));
                operation.date               = rs.getDate("OC_MAINTENANCEOPERATION_DATE");
                operation.operator           = ScreenHelper.checkString(rs.getString("OC_MAINTENANCEOPERATION_OPERATOR"));
                operation.result             = ScreenHelper.checkString(rs.getString("OC_MAINTENANCEOPERATION_RESULT"));
                operation.comment            = ScreenHelper.checkString(rs.getString("OC_MAINTENANCEOPERATION_COMMENT"));
                operation.nextDate           = rs.getDate("OC_MAINTENANCEOPERATION_NEXTDATE");
                
                // update-info
                operation.setUpdateDateTime(rs.getTimestamp("OC_MAINTENANCEOPERATION_UPDATETIME"));
                operation.setUpdateUser(rs.getString("OC_MAINTENANCEOPERATION_UPDATEID"));
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
        
        return operation;
    }
        
    //--- GET LIST --------------------------------------------------------------------------------
    public static List<MaintenanceOperation> getList(){
    	return getList(new MaintenanceOperation());     	
    }
    
    public static List<MaintenanceOperation> getList(MaintenanceOperation findItem){
        List<MaintenanceOperation> foundObjects = new LinkedList();
        PreparedStatement ps = null;
        ResultSet rs = null;
        
        Connection oc_conn = MedwanQuery.getInstance().getOpenclinicConnection();
        
        try{
        	//*** compose query ***************************
            String sSql = "SELECT * FROM OC_MAINTENANCEOPERATIONS WHERE 1=1"; // 'where' facilitates further composition of query

            //*** search-criteria *** 
            if(findItem.maintenanceplanUID.length() > 0){
                sSql+= " AND OC_MAINTENANCEOPERATION_MAINTENANCEPLANUID = '"+findItem.maintenanceplanUID+"'";
            }

            // performed-period
            if(findItem.periodPerformedBegin!=null && findItem.periodPerformedEnd!=null){
                sSql+= " AND OC_MAINTENANCEOPERATION_DATE BETWEEN '"+findItem.periodPerformedBegin+"' AND '"+findItem.periodPerformedEnd+"'";
            }
            else if(findItem.periodPerformedBegin!=null){
                sSql+= " AND OC_MAINTENANCEOPERATION_DATE > '"+findItem.periodPerformedBegin+"'";
            }
            else if(findItem.periodPerformedEnd!=null){
                sSql+= " AND OC_MAINTENANCEOPERATION_DATE <= '"+findItem.periodPerformedEnd+"'";
            }
            
            if(ScreenHelper.checkString(findItem.operator).length() > 0){
                sSql+= " AND OC_MAINTENANCEOPERATION_OPERATOR LIKE '%"+findItem.operator+"%'";
            }
            if(ScreenHelper.checkString(findItem.result).length() > 0){
                sSql+= " AND OC_MAINTENANCEOPERATION_RESULT = '"+findItem.result+"'";
            }
            
            sSql+= " ORDER BY OC_MAINTENANCEOPERATION_MAINTENANCEPLANUID ASC";
            
            ps = oc_conn.prepareStatement(sSql);
            
                        
            //*** execute query ***************************
            rs = ps.executeQuery();
            MaintenanceOperation operation;
            
            while(rs.next()){
            	operation = new MaintenanceOperation();   
            	operation.setUid(rs.getString("OC_MAINTENANCEOPERATION_SERVERID")+"."+rs.getString("OC_MAINTENANCEOPERATION_OBJECTID"));
                operation.serverId = Integer.parseInt(rs.getString("OC_MAINTENANCEOPERATION_SERVERID"));
                operation.objectId = Integer.parseInt(rs.getString("OC_MAINTENANCEOPERATION_OBJECTID"));

                operation.maintenanceplanUID = ScreenHelper.checkString(rs.getString("OC_MAINTENANCEOPERATION_MAINTENANCEPLANUID"));
                operation.date               = rs.getDate("OC_MAINTENANCEOPERATION_DATE");
                operation.operator           = ScreenHelper.checkString(rs.getString("OC_MAINTENANCEOPERATION_OPERATOR"));
                operation.result             = ScreenHelper.checkString(rs.getString("OC_MAINTENANCEOPERATION_RESULT"));
                operation.comment            = ScreenHelper.checkString(rs.getString("OC_MAINTENANCEOPERATION_COMMENT"));
                operation.nextDate           = rs.getDate("OC_MAINTENANCEOPERATION_NEXTDATE");
               
                // update-info
                operation.setUpdateDateTime(rs.getTimestamp("OC_MAINTENANCEOPERATION_UPDATETIME"));
                operation.setUpdateUser(rs.getString("OC_MAINTENANCEOPERATION_UPDATEID"));
                
                foundObjects.add(operation);
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