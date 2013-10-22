package be.openclinic.hr;

import be.openclinic.common.OC_Object;
import be.mxs.common.util.db.MedwanQuery;
import be.mxs.common.util.system.Debug;
import be.mxs.common.util.system.ScreenHelper;

import java.text.SimpleDateFormat;
import java.util.*;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.io.*;

import org.dom4j.*;
import org.dom4j.io.SAXReader;


public class SalaryCalculation extends OC_Object {
    /*
	    <table name="OC_SALARYCALCULATIONS" db="openclinic" sync="NONE">
	      <columns>
	        <column name="OC_CALCULATION_SERVERID" dbtype="int" javatype="integer"/>
	    	<column name="OC_CALCULATION_OBJECTID" dbtype="int" javatype="integer"/>
	    	<column name="OC_CALCULATION_BEGIN" dbtype="datetime" javatype="date"/>
	    	<column name="OC_CALCULATION_END" dbtype="datetime" javatype="date"/>
	    	<column name="OC_CALCULATION_PERSONID" dbtype="int" javatype="integer"/>  
	    	<column name="OC_CALCULATION_SOURCE" dbtype="varchar(50)" javatype="String"/>  
	    	<column name="OC_CALCULATION_TYPE" dbtype="varchar(50)" javatype="String"/>  	     
		    <column name="OC_CALCULATION_UPDATETIME" dbtype="datetime" javatype="date"/>
	    	<column name="OC_CALCULATION_UPDATEID" dbtype="int" javatype="integer"/>
	      </columns>
	    </table>
    */
	
    public int serverId;
    public int objectId;    
    public int personId;
    
    public java.util.Date begin;
    public java.util.Date end;

    public String source; // 'script' or 'manual'
    public String type; // 'leave' or 'workschedule'
    
    public Vector codes; // not in DB
    
    //--- CONSTRUCTOR ---
    public SalaryCalculation(){
        serverId = -1;
        objectId = -1;        
        personId = -1;
        
        begin = null;
        end = null;
        
        source = "";
        type = "";

        codes = new Vector();
    }
    
    //--- GET CODES FROM DB -----------------------------------------------------------------------
    // the calculation codes belonging to this calculation
    public static Vector getCodesFromDB(String sSalCalUID){
    	Vector codes = new Vector();
    	
        PreparedStatement ps = null;
        ResultSet rs = null;
        
        Connection oc_conn = MedwanQuery.getInstance().getOpenclinicConnection();
        
        try{
        	// compose query
            String sSql = "SELECT s2.* FROM OC_SALARYCALCULATIONS s1, OC_SALARYCALCULATIONCODES s2"+
        	              " WHERE s2.OC_CALCULATIONCODE_CALCULATIONUID = CONCAT(s1.OC_CALCULATION_SERVERID,'.',s1.OC_CALCULATION_OBJECTID)"+
                          "  AND (s1.OC_CALCULATION_SERVERID = ? AND s1.OC_CALCULATION_OBJECTID = ?)"+ // identification
        	              " ORDER BY s2.OC_CALCULATIONCODE_DATE ASC, s2.OC_CALCULATIONCODE_DURATION DESC";            
            ps = oc_conn.prepareStatement(sSql);
            
            // where
            int psIdx = 1;
            ps.setInt(psIdx++,Integer.parseInt(sSalCalUID.substring(0,sSalCalUID.indexOf("."))));
            ps.setInt(psIdx,Integer.parseInt(sSalCalUID.substring(sSalCalUID.indexOf(".")+1)));
                       
            rs = ps.executeQuery();
            
            SalaryCalculationCode code;            
            while(rs.next()){
            	code = new SalaryCalculationCode();                
            	code.setUid(rs.getString("OC_CALCULATIONCODE_SERVERID")+"."+rs.getString("OC_CALCULATIONCODE_OBJECTID"));

                code.calculationUid = rs.getString("OC_CALCULATIONCODE_CALCULATIONUID");
                code.date           = rs.getDate("OC_CALCULATIONCODE_DATE");
                code.duration       = rs.getFloat("OC_CALCULATIONCODE_DURATION");
                code.code           = rs.getString("OC_CALCULATIONCODE_CODE");  

                // parent
                code.setUpdateDateTime(rs.getTimestamp("OC_CALCULATIONCODE_UPDATETIME"));
                code.setUpdateUser(rs.getString("OC_CALCULATIONCODE_UPDATEID"));
                
                codes.add(code);
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
            	
    	return codes;
    }
        
    //--- STORE -----------------------------------------------------------------------------------
    // returns UID after saving
    public String store(String sUserUid){
    	boolean errorOccurred = false;
        PreparedStatement ps = null;
        ResultSet rs = null;
        String sSql;
        
        Connection oc_conn = MedwanQuery.getInstance().getOpenclinicConnection();
                
        try{            
            if(getUid().equals("-1")){
                // insert new record for each day in the specified range
            	Calendar periodBegin = Calendar.getInstance();
            	periodBegin.setTime(begin);
            	
            	java.util.Date currDate;
            	while(periodBegin.getTime().getTime() <= end.getTime()){
            		currDate = periodBegin.getTime();
            		periodBegin.add(Calendar.DATE,1); // proceed one day
            		
                    sSql = "INSERT INTO OC_SALARYCALCULATIONS (OC_CALCULATION_SERVERID,OC_CALCULATION_OBJECTID,"+
                           "  OC_CALCULATION_BEGIN,OC_CALCULATION_END,OC_CALCULATION_PERSONID,"+
                    	   "  OC_CALCULATION_SOURCE,OC_CALCULATION_TYPE,"+
                    	   "  OC_CALCULATION_UPDATETIME, OC_CALCULATION_UPDATEID)"+ // update-info
                           " VALUES(?,?,?,?,?,?,?,?,?)"; // 9
                    ps = oc_conn.prepareStatement(sSql);
                    
                    int serverId = MedwanQuery.getInstance().getConfigInt("serverId"),
                        objectId = MedwanQuery.getInstance().getOpenclinicCounter("OC_SALARYCALCULATIONS");
                    this.setUid(serverId+"."+objectId);
                    
                    int psIdx = 1;
                    ps.setInt(psIdx++,serverId);
                    ps.setInt(psIdx++,objectId);
                               
                    // begin date might be unspecified
                    if(begin!=null){
                        ps.setDate(psIdx++,new java.sql.Date(currDate.getTime()));
                    }
                    else{
                        ps.setDate(psIdx++,null);
                    }
                    
                    // TODO : why providing an end-date when for each day in the period a calculation-record must exist ? ////////// TODO
                    // end date might be unspecified
                    if(end!=null){
                        ps.setDate(psIdx++,new java.sql.Date(currDate.getTime()));
                    }
                    else{
                        ps.setDate(psIdx++,null);
                    }
                    
                    ps.setInt(psIdx++,personId);
                    ps.setString(psIdx++,source);
                    ps.setString(psIdx++,type);

                    ps.setTimestamp(psIdx++,new Timestamp(new java.util.Date().getTime())); // now
                    ps.setString(psIdx,sUserUid);
                    
                    ps.executeUpdate();
                    
                    //***** INSERT CODES *****
                    SalaryCalculationCode salCalCode;
                    for(int i=0; i<codes.size(); i++){
                    	salCalCode = (SalaryCalculationCode)codes.get(i);
                    	salCalCode.store(sUserUid);
                    }

	                if(codes.size() > 0){
                        Debug.println("Added "+codes.size()+" codes to DB at "+ScreenHelper.stdDateFormat.format(currDate));
	                }
                } 
            }    
            else{    	            	
                // update existing record, for each day in the specified range
            	Calendar periodBegin = Calendar.getInstance();
            	periodBegin.setTime(begin);
            	
            	java.util.Date currDate;
            	while(periodBegin.getTime().getTime() <= end.getTime()){
            		currDate = periodBegin.getTime();
            		periodBegin.add(Calendar.DATE,1); // proceed one day
            		
	                sSql = "UPDATE OC_SALARYCALCULATIONS SET"+
	                       "  OC_CALCULATION_BEGIN = ?, OC_CALCULATION_END = ?, OC_CALCULATION_PERSONID = ?,"+
	                       "  OC_CALCULATION_SOURCE = ?, OC_CALCULATION_TYPE = ?,"+
	                       "  OC_CALCULATION_UPDATETIME = ?, OC_CALCULATION_UPDATEID = ?"+ // update-info
	                       " WHERE (OC_CALCULATION_SERVERID = ? AND OC_CALCULATION_OBJECTID = ?)"; // identification
	                ps = oc_conn.prepareStatement(sSql);
	
	                int psIdx = 1;
	                
	                // begin date might be unspecified
	                if(begin!=null){
                        ps.setDate(psIdx++,new java.sql.Date(currDate.getTime()));
	                }
	                else{
	                    ps.setDate(psIdx++,null);
	                }

                    // TODO : why providing an end-date when for each day in the period a calculation-record must exist ? ////////// TODO
	                // end date might be unspecified
	                if(end!=null){
                        ps.setDate(psIdx++,new java.sql.Date(currDate.getTime()));
	                }
	                else{
	                    ps.setDate(psIdx++,null);
	                }
	
	                ps.setInt(psIdx++,personId);
                    ps.setString(psIdx++,source);
                    ps.setString(psIdx++,type);
	                ps.setTimestamp(psIdx++,new Timestamp(new java.util.Date().getTime())); // now
	                ps.setString(psIdx++,sUserUid);
	                
	                // where
	                ps.setInt(psIdx++,Integer.parseInt(getUid().substring(0,getUid().indexOf("."))));
	                ps.setInt(psIdx,Integer.parseInt(getUid().substring(getUid().indexOf(".")+1)));
	                
	                ps.executeUpdate();
	                
	                //***** REPLACE CODES *****
	                int deletedCodes = deleteCodesFromDB(getUid());
	                SalaryCalculationCode salCalCode;
	                for(int i=0; i<codes.size(); i++){
	                	salCalCode = (SalaryCalculationCode)codes.get(i);
	                	salCalCode.store(sUserUid);
	                }  
	                
	                if(codes.size() > 0){
	                    Debug.println("Replaced "+codes.size()+" codes to DB at "+ScreenHelper.stdDateFormat.format(currDate));
	                }
            	}
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
        
        return getUid();
    }

    //--- DELETE CODES FROM DB --------------------------------------------------------------------
    private static int deleteCodesFromDB(String sSalCalUID){
    	int deletedCodes = 0;
        PreparedStatement ps = null;
        ResultSet rs = null;
        
        Connection oc_conn = MedwanQuery.getInstance().getOpenclinicConnection();

        try{
            String sSql = "DELETE FROM OC_SALARYCALCULATIONCODES"+
                          " WHERE OC_CALCULATIONCODE_CALCULATIONUID = ?";
            ps = oc_conn.prepareStatement(sSql);
            ps.setString(1,sSalCalUID);
            
            deletedCodes = ps.executeUpdate();
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
        
        return deletedCodes;
    }
    
    //--- DELETE ----------------------------------------------------------------------------------
    public static boolean delete(String sSalCalUID){
    	boolean errorOccurred = false;
        PreparedStatement ps = null;
        ResultSet rs = null;
        
        Connection oc_conn = MedwanQuery.getInstance().getOpenclinicConnection();

        try{
            String sSql = "DELETE FROM OC_SALARYCALCULATIONS"+
                          " WHERE (OC_CALCULATION_SERVERID = ? AND OC_CALCULATION_OBJECTID = ?)";
            ps = oc_conn.prepareStatement(sSql);
            ps.setInt(1,Integer.parseInt(sSalCalUID.substring(0,sSalCalUID.indexOf("."))));
            ps.setInt(2,Integer.parseInt(sSalCalUID.substring(sSalCalUID.indexOf(".")+1)));

            // delete linked codes
            int deletedCodes = deleteCodesFromDB(sSalCalUID);
            Debug.println("Deleted "+deletedCodes+" codes from DB");
            
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
            	errorOccurred = true;
                Debug.printProjectErr(se,Thread.currentThread().getStackTrace());
            }
        }
        
        return errorOccurred;
    }
    
    //--- GET -------------------------------------------------------------------------------------
    public static SalaryCalculation get(String sSalCalUID){
    	SalaryCalculation calculation = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        
        Connection oc_conn = MedwanQuery.getInstance().getOpenclinicConnection();
        
        try{
            String sSql = "SELECT * FROM OC_SALARYCALCULATIONS"+
                          " WHERE (OC_CALCULATION_SERVERID = ? AND OC_CALCULATION_OBJECTID = ?)";
            ps = oc_conn.prepareStatement(sSql);
            ps.setInt(1,Integer.parseInt(sSalCalUID.substring(0,sSalCalUID.indexOf("."))));
            ps.setInt(2,Integer.parseInt(sSalCalUID.substring(sSalCalUID.indexOf(".")+1)));

            // execute
            rs = ps.executeQuery();
            if(rs.next()){
            	calculation = new SalaryCalculation();
                calculation.setUid(rs.getString("OC_CALCULATION_SERVERID")+"."+rs.getString("OC_CALCULATION_OBJECTID"));

                calculation.personId = rs.getInt("OC_CALCULATION_PERSONID");
            	calculation.source   = rs.getString("OC_CALCULATION_SOURCE");
            	calculation.type     = rs.getString("OC_CALCULATION_TYPE");
                calculation.begin    = rs.getDate("OC_CALCULATION_BEGIN");
                calculation.end      = rs.getDate("OC_CALCULATION_END");
                
                calculation.codes = getCodesFromDB(calculation.getUid());
                
                // parent
                calculation.setUpdateDateTime(rs.getTimestamp("OC_CALCULATION_UPDATETIME"));
                calculation.setUpdateUser(rs.getString("OC_CALCULATION_UPDATEID"));
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
        
        return calculation;
    }
    
    //--- GET CALCULATION ON DATE -----------------------------------------------------------------
    public static SalaryCalculation getCalculationOnDate(java.util.Date date, int personId){
    	SalaryCalculation calculation = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        
        Connection oc_conn = MedwanQuery.getInstance().getOpenclinicConnection();
        
        try{
            String sSql = "SELECT * FROM OC_SALARYCALCULATIONS"+
                          " WHERE OC_CALCULATION_PERSONID = ?"+
            		      "  AND OC_CALCULATION_BEGIN = ?";
            ps = oc_conn.prepareStatement(sSql);
            ps.setInt(1,personId);
            ps.setDate(2,new java.sql.Date(date.getTime()));

            // execute
            rs = ps.executeQuery();
            if(rs.next()){
            	calculation = new SalaryCalculation();
                calculation.setUid(rs.getString("OC_CALCULATION_SERVERID")+"."+rs.getString("OC_CALCULATION_OBJECTID"));
    	    	
                calculation.personId = personId;
            	calculation.source   = rs.getString("OC_CALCULATION_SOURCE");
            	calculation.type     = rs.getString("OC_CALCULATION_TYPE");
                calculation.begin    = rs.getDate("OC_CALCULATION_BEGIN");
                calculation.end      = rs.getDate("OC_CALCULATION_END");
                
                calculation.codes = getCodesFromDB(calculation.getUid());
                
                // parent
                calculation.setUpdateDateTime(rs.getTimestamp("OC_CALCULATION_UPDATETIME"));
                calculation.setUpdateUser(rs.getString("OC_CALCULATION_UPDATEID"));
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
        
        return calculation;
    }
        
    //--- GET LIST --------------------------------------------------------------------------------
    public static List<SalaryCalculation> getList(){
    	return getList(new SalaryCalculation());     	
    }
    
    public static List<SalaryCalculation> getList(SalaryCalculation findItem){
        List<SalaryCalculation> foundObjects = new LinkedList();
        PreparedStatement ps = null;
        ResultSet rs = null;
        
        Connection oc_conn = MedwanQuery.getInstance().getOpenclinicConnection();
        SimpleDateFormat sqlDateFormat = new SimpleDateFormat("yyyy/MM/dd");
        
        try{
        	// compose query
            String sSql = "SELECT * FROM OC_SALARYCALCULATIONS WHERE 1=1"; // 'where' facilitates further composition of query

            if(findItem.personId > -1){
                sSql+= " AND OC_CALCULATION_PERSONID = "+findItem.personId;
            }
            
            if(findItem.begin!=null && findItem.end!=null){
                sSql+= " AND ("+
                       "  OC_CALCULATION_BEGIN >= '"+sqlDateFormat.format(findItem.begin)+"' AND"+
                       "  OC_CALCULATION_END <= '"+sqlDateFormat.format(findItem.end)+"'"+
                       " )";
            }
            else if(findItem.begin!=null){
                sSql+= " AND OC_CALCULATION_BEGIN >= '"+sqlDateFormat.format(findItem.begin)+"'";
            }
            else if(findItem.end!=null){
                sSql+= " AND OC_CALCULATION_END <= '"+sqlDateFormat.format(findItem.end)+"'";
            }
            
            if(findItem.source.length() > 0){
                sSql+= " AND OC_CALCULATION_SOURCE = '"+findItem.source+"'";
            }
            
            if(findItem.type.length() > 0){
                sSql+= " AND OC_CALCULATION_TYPE = '"+findItem.type+"'";
            }
            
            sSql+= " ORDER BY OC_CALCULATION_OBJECTID ASC";
            
            ps = oc_conn.prepareStatement(sSql);
                       
            // execute query
            rs = ps.executeQuery();
            SalaryCalculation calculation;
            
            while(rs.next()){
            	calculation = new SalaryCalculation();                
            	calculation.setUid(rs.getString("OC_CALCULATION_SERVERID")+"."+rs.getString("OC_CALCULATION_OBJECTID"));

            	calculation.personId = rs.getInt("OC_CALCULATION_PERSONID");
            	calculation.source   = rs.getString("OC_CALCULATION_SOURCE");
            	calculation.type     = rs.getString("OC_CALCULATION_TYPE");
            	calculation.begin    = rs.getDate("OC_CALCULATION_BEGIN");
            	calculation.end      = rs.getDate("OC_CALCULATION_END");
                
                // parent
            	calculation.setUpdateDateTime(rs.getTimestamp("OC_CALCULATION_UPDATETIME"));
                calculation.setUpdateUser(rs.getString("OC_CALCULATION_UPDATEID"));

                calculation.codes = getCodesFromDB(calculation.getUid());
                
                foundObjects.add(calculation);
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
