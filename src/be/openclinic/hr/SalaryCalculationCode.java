package be.openclinic.hr;

import be.openclinic.common.OC_Object;
import be.mxs.common.util.db.MedwanQuery;
import be.mxs.common.util.system.Debug;
import be.mxs.common.util.system.ScreenHelper;

import java.util.*;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.io.*;

import org.dom4j.*;
import org.dom4j.io.SAXReader;


public class SalaryCalculationCode extends OC_Object {
    /*    
	    <table name="OC_SALARYCALCULATIONCODES" db="openclinic" sync="NONE">
	      <columns>
	        <column name="OC_CALCULATIONCODE_SERVERID" dbtype="int" javatype="integer"/>
	    	<column name="OC_CALCULATIONCODE_OBJECTID" dbtype="int" javatype="integer"/>
	        <column name="OC_CALCULATIONCODE_CALCULATIONUID" dbtype="varchar" javatype="string" size="50"/> 
	    	<column name="OC_CALCULATIONCODE_DATE" dbtype="datetime" javatype="date"/>
	    	<column name="OC_CALCULATIONCODE_DURATION" dbtype="float" javatype="float"/> 
	        <column name="OC_CALCULATIONCODE_CODE" dbtype="varchar" javatype="string" size="50"/>  	     
		    <column name="OC_CALCULATIONCODE_UPDATETIME" dbtype="datetime" javatype="date"/>
	    	<column name="OC_CALCULATIONCODE_UPDATEID" dbtype="int" javatype="integer"/>
	      </columns>
	    </table> 
    */
	
    public int serverId;
    public int objectId;    
    public String calculationUid;
    
    public java.util.Date date;
    public float duration; // hours
    public String code;
    
    //--- CONSTRUCTOR ---
    public SalaryCalculationCode(){
        serverId = -1;
        objectId = -1;        
        calculationUid = "";
        
        date = null;
        duration = -1;
        code = "";
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
                // insert new record
                sSql = "INSERT INTO OC_SALARYCALCULATIONCODES (OC_CALCULATIONCODE_SERVERID,OC_CALCULATIONCODE_OBJECTID,"+
                       "  OC_CALCULATIONCODE_CALCULATIONUID, OC_CALCULATIONCODE_DATE, OC_CALCULATIONCODE_DURATION, OC_CALCULATIONCODE_CODE,"+
                	   "  OC_CALCULATIONCODE_UPDATETIME, OC_CALCULATIONCODE_UPDATEID)"+ // update-info
                       " VALUES(?,?,?,?,?,?,?,?)"; // 8
                ps = oc_conn.prepareStatement(sSql);
                
                int serverId = MedwanQuery.getInstance().getConfigInt("serverId"),
                    objectId = MedwanQuery.getInstance().getOpenclinicCounter("OC_SALARYCALCULATIONCODES");
                this.setUid(serverId+"."+objectId);
                
                int psIdx = 1;
                ps.setInt(psIdx++,serverId);
                ps.setInt(psIdx++,objectId);
                ps.setString(psIdx++,calculationUid);
                                
                // date might be unspecified
                if(date!=null){
                    ps.setDate(psIdx++,new java.sql.Date(date.getTime()));
                }
                else{
                    ps.setDate(psIdx++,null);
                }
                
                ps.setFloat(psIdx++,duration);
                ps.setString(psIdx++,code);
                ps.setTimestamp(psIdx++,new Timestamp(new java.util.Date().getTime())); // now
                ps.setString(psIdx,userUid);
                
                ps.executeUpdate();
            } 
            else{
	            //*** UPDATE ACTUALLY IS NEVER USED : codes are always deleted and re-inserted ***
            	
                // update existing record
                sSql = "UPDATE OC_SALARYCALCULATIONCODES SET"+
                       "  OC_CALCULATIONCODE_CALCULATIONUID = ?, OC_CALCULATIONCODE_DATE = ?,"+
                	   "  OC_CALCULATIONCODE_DURATION = ?, OC_CALCULATIONCODE_CODE = ?,"+
                       "  OC_CALCULATIONCODE_UPDATETIME = ?, OC_CALCULATIONCODE_UPDATEID = ?"+ // update-info
                       " WHERE (OC_CALCULATIONCODE_SERVERID = ? AND OC_CALCULATIONCODE_OBJECTID = ?)"; // identification
                ps = oc_conn.prepareStatement(sSql);

                int psIdx = 1;
                ps.setString(psIdx++,calculationUid);
                
                // date might be unspecified
                if(date!=null){
                    ps.setDate(psIdx++,new java.sql.Date(date.getTime()));
                }
                else{
                    ps.setDate(psIdx++,null);
                }

                ps.setFloat(psIdx++,duration);
                ps.setString(psIdx++,code);
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
    public static boolean delete(String sSalCalCodeUid){
    	boolean errorOccurred = false;
        PreparedStatement ps = null;
        ResultSet rs = null;
        
        Connection oc_conn = MedwanQuery.getInstance().getOpenclinicConnection();

        try{
            String sSql = "DELETE FROM OC_SALARYCALCULATIONCODES"+
                          " WHERE (OC_CALCULATIONCODE_SERVERID = ? AND OC_CALCULATIONCODE_OBJECTID = ?)";
            ps = oc_conn.prepareStatement(sSql);
            ps.setInt(1,Integer.parseInt(sSalCalCodeUid.substring(0,sSalCalCodeUid.indexOf("."))));
            ps.setInt(2,Integer.parseInt(sSalCalCodeUid.substring(sSalCalCodeUid.indexOf(".")+1)));
            
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
    public static SalaryCalculationCode get(String sSalCalCodeUid){
    	SalaryCalculationCode code = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        
        Connection oc_conn = MedwanQuery.getInstance().getOpenclinicConnection();
        
        try{
            String sSql = "SELECT * FROM OC_SALARYCALCULATIONCODES"+
                          " WHERE (OC_CALCULATIONCODE_SERVERID = ? AND OC_CALCULATIONCODE_OBJECTID = ?)";
            ps = oc_conn.prepareStatement(sSql);
            ps.setInt(1,Integer.parseInt(sSalCalCodeUid.substring(0,sSalCalCodeUid.indexOf("."))));
            ps.setInt(2,Integer.parseInt(sSalCalCodeUid.substring(sSalCalCodeUid.indexOf(".")+1)));
                       
            // execute
            rs = ps.executeQuery();
            if(rs.next()){
                code = new SalaryCalculationCode();
                code.setUid(rs.getString("OC_CALCULATIONCODE_SERVERID")+"."+rs.getString("OC_CALCULATIONCODE_OBJECTID"));
    	    	
                code.calculationUid = rs.getString("OC_CALCULATIONCODE_CALCULATIONUID");
                code.date           = rs.getDate("OC_CALCULATIONCODE_DATE");
                code.duration       = rs.getFloat("OC_CALCULATIONCODE_DURATION");
                code.code           = rs.getString("OC_CALCULATIONCODE_CODE"); 
                
                // parent
                code.setUpdateDateTime(rs.getTimestamp("OC_CALCULATIONCODE_UPDATETIME"));
                code.setUpdateUser(rs.getString("OC_CALCULATIONCODE_UPDATEID"));
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
        
        return code;
    }
        
    //--- GET LIST --------------------------------------------------------------------------------
    public static List<SalaryCalculationCode> getList(){
    	return getList(new SalaryCalculationCode());     	
    }
    
    public static List<SalaryCalculationCode> getList(SalaryCalculationCode findItem){
        List<SalaryCalculationCode> foundObjects = new LinkedList();
        PreparedStatement ps = null;
        ResultSet rs = null;
        
        Connection oc_conn = MedwanQuery.getInstance().getOpenclinicConnection();
        
        try{
        	// compose query
            String sSql = "SELECT * FROM OC_SALARYCALCULATIONCODES WHERE 1=1"; // 'where' facilitates further composition of query

            if(findItem.calculationUid.length() > -1){
                sSql+= " AND OC_CALCULATIONCODE_CALCULATIONUID = "+findItem.calculationUid;
            }
            if(findItem.date!=null){
                sSql+= " AND OC_CALCULATIONCODE_DATE = '"+ScreenHelper.stdDateFormat.format(findItem.date)+"'";
            }
            if(findItem.duration > -1){
                sSql+= " AND OC_CALCULATIONCODE_DURATION = "+findItem.duration;
            }
            if(findItem.code!=null){
                sSql+= " AND OC_CALCULATIONCODE_CODE = '"+findItem.code+"'";
            }
            
            sSql+= " ORDER BY OC_CALCULATIONCODE_DATE ASC";
            
            ps = oc_conn.prepareStatement(sSql);
                       
            // execute query
            rs = ps.executeQuery();
            SalaryCalculationCode item;
            
            while(rs.next()){
                item = new SalaryCalculationCode();                
                item.setUid(rs.getString("OC_CALCULATIONCODE_SERVERID")+"."+rs.getString("OC_CALCULATIONCODE_OBJECTID"));

                item.calculationUid = rs.getString("OC_CALCULATIONCODE_CALCULATIONUID");
                item.date           = rs.getDate("OC_CALCULATIONCODE_DATE");
                item.duration       = rs.getFloat("OC_CALCULATIONCODE_DURATION");
                item.code           = rs.getString("OC_CALCULATIONCODE_CODE"); 
                
                // parent
                item.setUpdateDateTime(rs.getTimestamp("OC_CALCULATIONCODE_UPDATETIME"));
                item.setUpdateUser(rs.getString("OC_CALCULATIONCODE_UPDATEID"));
                
                foundObjects.add(item);
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
