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


public class Contract extends OC_Object {
    public int serverId;
    public int objectId;    
    public int personId;    
    
    public java.util.Date beginDate;
    public java.util.Date endDate;

    public String functionCode;
    public String functionTitle;
    public String functionDescription;
    public String ref1;
    public String ref2;
    public String ref3;
    public String ref4;
    public String ref5;
    
    //--- CONSTRUCTOR ---
    public Contract(){
        serverId = -1;
        objectId = -1;        
        personId = -1;
        
        beginDate = null;
        endDate = null;        
        functionCode = "";
        functionTitle = "";
        functionDescription = "";
        ref1 = "";
        ref2 = "";
        ref3 = "";
        ref4 = "";
        ref5 = "";
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
                // insert new contract
                sSql = "INSERT INTO hr_contracts (HR_CONTRACT_SERVERID,HR_CONTRACT_OBJECTID,HR_CONTRACT_PERSONID,"+
                       " HR_CONTRACT_BEGINDATE,HR_CONTRACT_ENDDATE,HR_CONTRACT_FUNCTIONCODE,HR_CONTRACT_FUNCTIONTITLE,"+
                	   " HR_CONTRACT_FUNCTIONDESCRIPTION,HR_CONTRACT_REF1,HR_CONTRACT_REF2,HR_CONTRACT_REF3,HR_CONTRACT_REF4,HR_CONTRACT_REF5,"+
                       " HR_CONTRACT_UPDATETIME,HR_CONTRACT_UPDATEID)"+ // update-info
                       " VALUES(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)"; // 15
                ps = oc_conn.prepareStatement(sSql);
                
                int serverId = MedwanQuery.getInstance().getConfigInt("serverId"),
                    objectId = MedwanQuery.getInstance().getOpenclinicCounter("HR_CONTRACT");
                this.setUid(serverId+"."+objectId);
                
                int psIdx = 1;
                ps.setInt(psIdx++,serverId);
                ps.setInt(psIdx++,objectId);
                ps.setInt(psIdx++,personId);
                ps.setDate(psIdx++,new java.sql.Date(beginDate.getTime()));

                // end date might be unspecified
                if(endDate!=null){
                    ps.setDate(psIdx++,new java.sql.Date(endDate.getTime()));
                }
                else{
                    ps.setDate(psIdx++,null);
                }
                
                ps.setString(psIdx++,functionCode);
                ps.setString(psIdx++,functionTitle);
                ps.setString(psIdx++,functionDescription);
                ps.setString(psIdx++,ref1);
                ps.setString(psIdx++,ref2);
                ps.setString(psIdx++,ref3);
                ps.setString(psIdx++,ref4);
                ps.setString(psIdx++,ref5);                
                ps.setTimestamp(psIdx++,new Timestamp(new java.util.Date().getTime())); // now
                ps.setString(psIdx,userUid);
                
                ps.executeUpdate();
            } 
            else{
                // update existing record
                sSql = "UPDATE hr_contracts SET"+
                       "  HR_CONTRACT_BEGINDATE = ?, HR_CONTRACT_ENDDATE = ?, HR_CONTRACT_FUNCTIONCODE = ?,"+
                       "  HR_CONTRACT_FUNCTIONTITLE = ?, HR_CONTRACT_FUNCTIONDESCRIPTION = ?, HR_CONTRACT_REF1 = ?,"+
                       "  HR_CONTRACT_REF2 = ?, HR_CONTRACT_REF3 = ?, HR_CONTRACT_REF4 = ?, HR_CONTRACT_REF5 = ?,"+
                       "  HR_CONTRACT_UPDATETIME = ?, HR_CONTRACT_UPDATEID = ?"+ // update-info
                       " WHERE (HR_CONTRACT_SERVERID = ? AND HR_CONTRACT_OBJECTID = ?)"; // identification
                ps = oc_conn.prepareStatement(sSql);

                int psIdx = 1;
                ps.setDate(psIdx++,new java.sql.Date(beginDate.getTime()));
                
                // end date might be unspecified
                if(endDate!=null){
                    ps.setDate(psIdx++,new java.sql.Date(endDate.getTime()));
                }
                else{
                    ps.setDate(psIdx++,null);
                }

                ps.setString(psIdx++,functionCode);
                ps.setString(psIdx++,functionTitle);
                ps.setString(psIdx++,functionDescription);
                ps.setString(psIdx++,ScreenHelper.checkString(ref1));
                ps.setString(psIdx++,ScreenHelper.checkString(ref2));
                ps.setString(psIdx++,ScreenHelper.checkString(ref3));
                ps.setString(psIdx++,ScreenHelper.checkString(ref4));
                ps.setString(psIdx++,ScreenHelper.checkString(ref5));
                ps.setTimestamp(psIdx++,new Timestamp(new java.util.Date().getTime())); // now
                ps.setString(psIdx++,userUid);
                
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
    public static boolean delete(String sContractUid){
    	boolean errorOccurred = false;
        PreparedStatement ps = null;
        ResultSet rs = null;
        
        Connection oc_conn = MedwanQuery.getInstance().getOpenclinicConnection();
        
        try{
            String sSql = "DELETE FROM hr_contracts"+
                          " WHERE (HR_CONTRACT_SERVERID = ? AND HR_CONTRACT_OBJECTID = ?)";
            ps = oc_conn.prepareStatement(sSql);
            ps.setInt(1,Integer.parseInt(sContractUid.substring(0,sContractUid.indexOf("."))));
            ps.setInt(2,Integer.parseInt(sContractUid.substring(sContractUid.indexOf(".")+1)));
            
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
    public static Contract get(Contract contract){
    	return get(contract.getUid());
    }
       
    public static Contract get(String sContractUid){
    	Contract contract = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        
        Connection oc_conn = MedwanQuery.getInstance().getOpenclinicConnection();
        
        try{
            String sSql = "SELECT * FROM hr_contracts"+
                          " WHERE (HR_CONTRACT_SERVERID = ? AND HR_CONTRACT_OBJECTID = ?)";
            ps = oc_conn.prepareStatement(sSql);
            ps.setInt(1,Integer.parseInt(sContractUid.substring(0,sContractUid.indexOf("."))));
            ps.setInt(2,Integer.parseInt(sContractUid.substring(sContractUid.indexOf(".")+1)));

            // execute
            rs = ps.executeQuery();
            if(rs.next()){
            	contract = new Contract();
            	contract.objectId = rs.getInt("HR_CONTRACT_OBJECTID"); // exceptional      
            	contract.setUid(rs.getString("HR_CONTRACT_SERVERID")+"."+rs.getString("HR_CONTRACT_OBJECTID"));

            	contract.beginDate = rs.getDate("HR_CONTRACT_BEGINDATE");
                contract.endDate   = rs.getDate("HR_CONTRACT_ENDDATE");
                
            	contract.personId            = rs.getInt("HR_CONTRACT_PERSONID");
            	contract.functionCode        = ScreenHelper.checkString(rs.getString("HR_CONTRACT_FUNCTIONCODE"));
            	contract.functionTitle       = ScreenHelper.checkString(rs.getString("HR_CONTRACT_FUNCTIONTITLE"));
            	contract.functionDescription = ScreenHelper.checkString(rs.getString("HR_CONTRACT_FUNCTIONDESCRIPTION"));
                
            	contract.ref1 = ScreenHelper.checkString(rs.getString("HR_CONTRACT_REF1"));
            	contract.ref2 = ScreenHelper.checkString(rs.getString("HR_CONTRACT_REF2"));
            	contract.ref3 = ScreenHelper.checkString(rs.getString("HR_CONTRACT_REF3"));
                contract.ref4 = ScreenHelper.checkString(rs.getString("HR_CONTRACT_REF4"));
                contract.ref5 = ScreenHelper.checkString(rs.getString("HR_CONTRACT_REF5")); 
                
                // parent
                contract.setUpdateDateTime(rs.getTimestamp("HR_CONTRACT_UPDATETIME"));
                contract.setUpdateUser(rs.getString("HR_CONTRACT_UPDATEID"));
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
        
        return contract;
    }
        
    //--- GET LIST --------------------------------------------------------------------------------
    public static List<Contract> getList(){
    	return getList(new Contract());     	
    }
    
    public static List<Contract> getList(Contract findItem){
        List<Contract> foundObjects = new LinkedList();
        PreparedStatement ps = null;
        ResultSet rs = null;
        
        Connection oc_conn = MedwanQuery.getInstance().getOpenclinicConnection();
        
        try{
        	// compose query
            String sSql = "SELECT * FROM hr_contracts WHERE 1=1"; // 'where' facilitates further composition of query
            
            if(findItem.personId > -1){
                sSql+= " AND HR_CONTRACT_PERSONID = "+findItem.personId;
            }
            if(ScreenHelper.checkString(findItem.functionCode).length() > 0){
                sSql+= " AND HR_CONTRACT_FUNCTIONCODE = '"+findItem.functionCode+"'";
            }
            if(ScreenHelper.checkString(findItem.functionTitle).length() > 0){
                sSql+= " AND HR_CONTRACT_FUNCTIONTITLE LIKE '%"+findItem.functionTitle+"%'";
            }
            if(ScreenHelper.checkString(findItem.functionDescription).length() > 0){
                sSql+= " AND HR_CONTRACT_FUNCTIONDESCRIPTION LIKE '%"+findItem.functionDescription+"%'";
            }
            if(ScreenHelper.checkString(findItem.ref1).length() > 0){
                sSql+= " AND HR_CONTRACT_REF1 LIKE '%"+findItem.ref1+"%'";
            }
            if(ScreenHelper.checkString(findItem.ref1).length() > 0){
                sSql+= " AND HR_CONTRACT_REF2 LIKE '%"+findItem.ref2+"%'";
            }
            if(ScreenHelper.checkString(findItem.ref1).length() > 0){
                sSql+= " AND HR_CONTRACT_REF3 LIKE '%"+findItem.ref3+"%'";
            }
            if(ScreenHelper.checkString(findItem.ref1).length() > 0){
                sSql+= " AND HR_CONTRACT_REF4 LIKE '%"+findItem.ref4+"%'";
            }
            if(ScreenHelper.checkString(findItem.ref1).length() > 0){
                sSql+= " AND HR_CONTRACT_REF5 LIKE '%"+findItem.ref5+"%'";
            }
            sSql+= " ORDER BY HR_CONTRACT_BEGINDATE ASC";

            ps = oc_conn.prepareStatement(sSql);
            
            /*
            // set question marks            
            int psIdx = 1;
            
            if(findItem.personId > -1){
            	ps.setInt(psIdx++,findItem.personId);
            }
            if(ScreenHelper.checkString(findItem.functionCode).length() > 0){
            	ps.setString(psIdx++,findItem.functionCode);
            }
            if(ScreenHelper.checkString(findItem.functionTitle).length() > 0){
            	ps.setString(psIdx++,findItem.functionTitle);
            }
            if(ScreenHelper.checkString(findItem.functionDescription).length() > 0){
            	ps.setString(psIdx++,findItem.functionDescription);
            }
            if(ScreenHelper.checkString(findItem.ref1).length() > 0){
            	ps.setString(psIdx++,findItem.ref1);
            }
            if(ScreenHelper.checkString(findItem.ref2).length() > 0){
            	ps.setString(psIdx++,findItem.ref2);
            }
            if(ScreenHelper.checkString(findItem.ref3).length() > 0){
            	ps.setString(psIdx++,findItem.ref3);
            }
            if(ScreenHelper.checkString(findItem.ref4).length() > 0){
            	ps.setString(psIdx++,findItem.ref4);
            }
            if(ScreenHelper.checkString(findItem.ref5).length() > 0){
            	ps.setString(psIdx++,findItem.ref5);
            }
            */
            
            // execute query
            rs = ps.executeQuery();
            Contract item;
            
            while(rs.next()){
                item = new Contract();   
                item.objectId = rs.getInt("HR_CONTRACT_OBJECTID"); // exceptional            
                item.setUid(rs.getString("HR_CONTRACT_SERVERID")+"."+rs.getString("HR_CONTRACT_OBJECTID"));

                item.beginDate = rs.getDate("HR_CONTRACT_BEGINDATE");
                item.endDate   = rs.getDate("HR_CONTRACT_ENDDATE");

                item.personId            = rs.getInt("HR_CONTRACT_PERSONID");                
                item.functionCode        = ScreenHelper.checkString(rs.getString("HR_CONTRACT_FUNCTIONCODE"));
                item.functionTitle       = ScreenHelper.checkString(rs.getString("HR_CONTRACT_FUNCTIONTITLE"));
                item.functionDescription = ScreenHelper.checkString(rs.getString("HR_CONTRACT_FUNCTIONDESCRIPTION"));
                
                item.ref1 = ScreenHelper.checkString(rs.getString("HR_CONTRACT_REF1"));
                item.ref2 = ScreenHelper.checkString(rs.getString("HR_CONTRACT_REF2"));
                item.ref3 = ScreenHelper.checkString(rs.getString("HR_CONTRACT_REF3"));
                item.ref4 = ScreenHelper.checkString(rs.getString("HR_CONTRACT_REF4"));
                item.ref5 = ScreenHelper.checkString(rs.getString("HR_CONTRACT_REF5")); 
                
                // parent
                item.setUpdateDateTime(rs.getTimestamp("HR_CONTRACT_UPDATETIME"));
                item.setUpdateUser(rs.getString("HR_CONTRACT_UPDATEID"));
                
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
    
    //--- GET CONTRACTS FOR PERSON ----------------------------------------------------------------
    public static List<Contract> getContractsForPerson(int personId){
        List<Contract> foundObjects = new LinkedList();
        PreparedStatement ps = null;
        ResultSet rs = null;
        
        Connection oc_conn = MedwanQuery.getInstance().getOpenclinicConnection();
        
        try{
            String sSql = "SELECT * FROM hr_contracts WHERE HR_CONTRACT_PERSONID = ?";
            ps = oc_conn.prepareStatement(sSql);
            ps.setInt(1,personId);
            
            rs = ps.executeQuery();
            Contract item;
            
            while(rs.next()){
                item = new Contract();   
                item.objectId = rs.getInt("HR_CONTRACT_OBJECTID"); // exceptional            
                item.setUid(rs.getString("HR_CONTRACT_SERVERID")+"."+rs.getString("HR_CONTRACT_OBJECTID"));

                item.beginDate = rs.getDate("HR_CONTRACT_BEGINDATE");
                item.endDate   = rs.getDate("HR_CONTRACT_ENDDATE");

                item.personId            = rs.getInt("HR_CONTRACT_PERSONID");                
                item.functionCode        = ScreenHelper.checkString(rs.getString("HR_CONTRACT_FUNCTIONCODE"));
                item.functionTitle       = ScreenHelper.checkString(rs.getString("HR_CONTRACT_FUNCTIONTITLE"));
                item.functionDescription = ScreenHelper.checkString(rs.getString("HR_CONTRACT_FUNCTIONDESCRIPTION"));
                
                item.ref1 = ScreenHelper.checkString(rs.getString("HR_CONTRACT_REF1"));
                item.ref2 = ScreenHelper.checkString(rs.getString("HR_CONTRACT_REF2"));
                item.ref3 = ScreenHelper.checkString(rs.getString("HR_CONTRACT_REF3"));
                item.ref4 = ScreenHelper.checkString(rs.getString("HR_CONTRACT_REF4"));
                item.ref5 = ScreenHelper.checkString(rs.getString("HR_CONTRACT_REF5")); 
                
                // parent
                item.setUpdateDateTime(rs.getTimestamp("HR_CONTRACT_UPDATETIME"));
                item.setUpdateUser(rs.getString("HR_CONTRACT_UPDATEID"));
                
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
    
    //--- GET LEGAL REFERENCE CODE ----------------------------------------------------------------
    public String getLegalReferenceCode(int idx){
    	switch(idx){
			case(1) : return this.ref1;
			case(2) : return this.ref2;
			case(3) : return this.ref3;
			case(4) : return this.ref4;
			case(5) : return this.ref5;
	    }
			
		return ""; // not found
    }
     
}
