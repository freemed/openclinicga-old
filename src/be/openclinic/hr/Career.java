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


public class Career extends OC_Object {
    public int serverId;
    public int objectId;    
    public int personId;
    
    public java.util.Date begin;
    public java.util.Date end;
    public String contractUid;
    public String position;
    public String serviceUid;
    public String grade;
    public String status;
    public String comment;
    
    
    //--- CONSTRUCTOR ---
    public Career(){
        serverId = -1;
        objectId = -1;        
        personId = -1;
        
        contractUid = "";
        begin = null;
        end = null;
        position = "";
        serviceUid = "";
        grade = "";
        status = "";
        comment = "";
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
                // insert new career
                sSql = "INSERT INTO hr_careers (HR_CAREER_SERVERID,HR_CAREER_OBJECTID,HR_CAREER_PERSONID,"+
                       "  HR_CAREER_CONTRACTUID,HR_CAREER_BEGIN,HR_CAREER_END,HR_CAREER_POSITION,"+
                       "  HR_CAREER_SERVICEUID,HR_CAREER_GRADE,HR_CAREER_STATUS,HR_CAREER_COMMENT,"+
                       "  HR_CAREER_UPDATETIME,HR_CAREER_UPDATEID)"+ // update-info
                       " VALUES(?,?,?,?,?,?,?,?,?,?,?,?,?)"; // 13
                ps = oc_conn.prepareStatement(sSql);
                
                int serverId = MedwanQuery.getInstance().getConfigInt("serverId"),
                    objectId = MedwanQuery.getInstance().getOpenclinicCounter("HR_CAREER");
                this.setUid(serverId+"."+objectId);
                
                int psIdx = 1;
                ps.setInt(psIdx++,serverId);
                ps.setInt(psIdx++,objectId);
                ps.setInt(psIdx++,personId);
                ps.setString(psIdx++,contractUid);
                ps.setDate(psIdx++,new java.sql.Date(begin.getTime()));

                // end date might be unspecified
                if(end!=null){
                    ps.setDate(psIdx++,new java.sql.Date(end.getTime()));
                }
                else{
                    ps.setDate(psIdx++,null);
                }
                
                ps.setString(psIdx++,position);
                ps.setString(psIdx++,serviceUid);
                ps.setString(psIdx++,grade);
                ps.setString(psIdx++,status);
                ps.setString(psIdx++,comment);
                ps.setTimestamp(psIdx++,new Timestamp(new java.util.Date().getTime())); // now
                ps.setString(psIdx,userUid);
                
                ps.executeUpdate();
            } 
            else{
                // update existing record
                sSql = "UPDATE hr_careers SET"+
                       "  HR_CAREER_BEGIN = ?, HR_CAREER_END = ?, HR_CAREER_CONTRACTUID = ?, HR_CAREER_POSITION = ?,"+
                       "  HR_CAREER_SERVICEUID = ?, HR_CAREER_GRADE = ?, HR_CAREER_STATUS = ?, HR_CAREER_COMMENT = ?,"+
                       "  HR_CAREER_UPDATETIME = ?, HR_CAREER_UPDATEID = ?"+ // update-info
                       " WHERE (HR_CAREER_SERVERID = ? AND HR_CAREER_OBJECTID = ?)"; // identification
                ps = oc_conn.prepareStatement(sSql);

                int psIdx = 1;
                ps.setDate(psIdx++,new java.sql.Date(begin.getTime()));
                
                // end date might be unspecified
                if(end!=null){
                    ps.setDate(psIdx++,new java.sql.Date(end.getTime()));
                }
                else{
                    ps.setDate(psIdx++,null);
                }

                ps.setString(psIdx++,contractUid);
                ps.setString(psIdx++,position);
                ps.setString(psIdx++,serviceUid);
                ps.setString(psIdx++,grade);
                ps.setString(psIdx++,status);
                ps.setString(psIdx++,comment);
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
    public static boolean delete(String sCareerUid){
    	boolean errorOccurred = false;
        PreparedStatement ps = null;
        ResultSet rs = null;
        
        Connection oc_conn = MedwanQuery.getInstance().getOpenclinicConnection();
        
        try{
            String sSql = "DELETE FROM hr_careers"+
                          " WHERE (HR_CAREER_SERVERID = ? AND HR_CAREER_OBJECTID = ?)";
            ps = oc_conn.prepareStatement(sSql);
            ps.setInt(1,Integer.parseInt(sCareerUid.substring(0,sCareerUid.indexOf("."))));
            ps.setInt(2,Integer.parseInt(sCareerUid.substring(sCareerUid.indexOf(".")+1)));
            
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
    public static Career get(Career career){
    	return get(career.getUid());
    }
       
    public static Career get(String sCareerUid){
    	Career career = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        
        Connection oc_conn = MedwanQuery.getInstance().getOpenclinicConnection();
        
        try{
            String sSql = "SELECT * FROM hr_careers"+
                          " WHERE (HR_CAREER_SERVERID = ? AND HR_CAREER_OBJECTID = ?)";
            ps = oc_conn.prepareStatement(sSql);
            ps.setInt(1,Integer.parseInt(sCareerUid.substring(0,sCareerUid.indexOf("."))));
            ps.setInt(2,Integer.parseInt(sCareerUid.substring(sCareerUid.indexOf(".")+1)));

            // execute
            rs = ps.executeQuery();
            if(rs.next()){
                career = new Career();
                career.setUid(rs.getString("HR_CAREER_SERVERID")+"."+rs.getString("HR_CAREER_OBJECTID"));

                career.personId    = rs.getInt("HR_CAREER_PERSONID");
                career.contractUid = ScreenHelper.checkString(rs.getString("HR_CAREER_CONTRACTUID"));
                career.begin       = rs.getDate("HR_CAREER_BEGIN");
                career.end         = rs.getDate("HR_CAREER_END");
                career.position    = ScreenHelper.checkString(rs.getString("HR_CAREER_POSITION"));
                career.serviceUid  = ScreenHelper.checkString(rs.getString("HR_CAREER_SERVICEUID"));
                career.grade       = ScreenHelper.checkString(rs.getString("HR_CAREER_GRADE"));
                career.status      = ScreenHelper.checkString(rs.getString("HR_CAREER_STATUS"));
                career.comment     = ScreenHelper.checkString(rs.getString("HR_CAREER_COMMENT")); 
                
                // parent
                career.setUpdateDateTime(rs.getTimestamp("HR_CAREER_UPDATETIME"));
                career.setUpdateUser(rs.getString("HR_CAREER_UPDATEID"));
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
        
        return career;
    }
        
    //--- GET LIST --------------------------------------------------------------------------------
    public static List<Career> getList(){
    	return getList(new Career());     	
    }
    
    public static List<Career> getList(Career findItem){
        List<Career> foundObjects = new LinkedList();
        PreparedStatement ps = null;
        ResultSet rs = null;
        
        Connection oc_conn = MedwanQuery.getInstance().getOpenclinicConnection();
        
        try{
        	// compose query
            String sSql = "SELECT * FROM hr_careers WHERE 1=1"; // 'where' facilitates further composition of query

            if(findItem.personId > -1){
                sSql+= " AND HR_CAREER_PERSONID = "+findItem.personId;
            }
            if(ScreenHelper.checkString(findItem.contractUid).length() > 0){
                sSql+= " AND HR_CAREER_CONTRACTUID = '"+findItem.contractUid+"'";
            }
            if(ScreenHelper.checkString(findItem.position).length() > 0){
                sSql+= " AND HR_CAREER_POSITION LIKE '%"+findItem.position+"%'";
            }
            if(ScreenHelper.checkString(findItem.serviceUid).length() > 0){
                sSql+= " AND HR_CAREER_SERVICEUID = '"+findItem.serviceUid+"'";
            }
            if(ScreenHelper.checkString(findItem.grade).length() > 0){
                sSql+= " AND HR_CAREER_GRADE = '"+findItem.grade+"'";
            }
            if(ScreenHelper.checkString(findItem.status).length() > 0){
                sSql+= " AND HR_CAREER_STATUS = '"+findItem.status+"'";
            }
            if(ScreenHelper.checkString(findItem.comment).length() > 0){
                sSql+= " AND HR_CAREER_COMMENT LIKE '%"+findItem.comment+"%'";
            }
            sSql+= " ORDER BY HR_CAREER_BEGIN ASC";
            
            ps = oc_conn.prepareStatement(sSql);
            
            /*
            // set question marks
            int psIdx = 1;
            
            if(findItem.personId > -1){
            	ps.setInt(psIdx++,findItem.personId);
            }
            if(ScreenHelper.checkString(findItem.contractUid).length() > 0){
            	ps.setString(psIdx++,findItem.contractUid);
            }
            if(ScreenHelper.checkString(findItem.position).length() > 0){
            	ps.setString(psIdx++,findItem.position);
            }
            if(ScreenHelper.checkString(findItem.serviceUid).length() > 0){
            	ps.setString(psIdx++,findItem.serviceUid);
            }
            if(ScreenHelper.checkString(findItem.grade).length() > 0){
            	ps.setString(psIdx++,findItem.grade);
            }
            if(ScreenHelper.checkString(findItem.status).length() > 0){
            	ps.setString(psIdx++,findItem.status);
            }
            if(ScreenHelper.checkString(findItem.comment).length() > 0){
            	ps.setString(psIdx++,findItem.comment);
            }
            */
            
            // execute query
            rs = ps.executeQuery();
            Career item;
            
            while(rs.next()){
                item = new Career();                
                item.setUid(rs.getString("HR_CAREER_SERVERID")+"."+rs.getString("HR_CAREER_OBJECTID"));

                item.personId    = rs.getInt("HR_CAREER_PERSONID");
                item.contractUid = ScreenHelper.checkString(rs.getString("HR_CAREER_CONTRACTUID"));
                item.begin       = rs.getDate("HR_CAREER_BEGIN");
                item.end         = rs.getDate("HR_CAREER_END");
                item.position    = ScreenHelper.checkString(rs.getString("HR_CAREER_POSITION"));
                item.serviceUid  = ScreenHelper.checkString(rs.getString("HR_CAREER_SERVICEUID"));
                item.grade       = ScreenHelper.checkString(rs.getString("HR_CAREER_GRADE"));
                item.status      = ScreenHelper.checkString(rs.getString("HR_CAREER_STATUS"));
                item.comment     = ScreenHelper.checkString(rs.getString("HR_CAREER_COMMENT")); 
                
                // parent
                item.setUpdateDateTime(rs.getTimestamp("HR_CAREER_UPDATETIME"));
                item.setUpdateUser(rs.getString("HR_CAREER_UPDATEID"));
                
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
