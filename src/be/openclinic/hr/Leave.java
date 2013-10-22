package be.openclinic.hr;

import be.openclinic.common.OC_Object;
import be.openclinic.hr.Workschedule.TimeBlock;
import be.mxs.common.util.db.MedwanQuery;
import be.mxs.common.util.system.Debug;
import be.mxs.common.util.system.ScreenHelper;

import java.util.*;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;


public class Leave extends OC_Object {
    public int serverId;
    public int objectId;
    public int personId;
    
    public java.util.Date begin;
    public java.util.Date end;
    public double duration; // 2 decimals max
    public String type; // hr.leave.type
    public java.util.Date requestDate;
    public java.util.Date authorizationDate;
    public String authorizedBy;
    public String episodeCode;
    public String comment;
    
    
    //--- CONSTRUCTOR ---
    public Leave(){
        serverId = -1;
        objectId = -1;        
        personId = -1;
        
        begin = null;
        end = null;
        duration = -1;
        type = "";
        requestDate = null;
        authorizationDate = null;
        authorizedBy = "";
        episodeCode = "";
        comment = "";
    }    
    
    //--- IS ACTIVE -------------------------------------------------------------------------------
    public boolean isActive(){
        Calendar cal = Calendar.getInstance();
        cal.setTime(new java.util.Date()); // now
        cal.set(Calendar.HOUR_OF_DAY,0);
        cal.set(Calendar.MINUTE,0);
        cal.set(Calendar.SECOND,0);
        cal.set(Calendar.MILLISECOND,0);
        
        return isActive(cal.getTime()); // the very beginning of today
    }
    
    public boolean isActive(java.util.Date date){
        boolean isActive = false;
                 
        // both dates exist
        if(this.begin!=null && this.end!=null){
            if(this.begin.getTime() <= date.getTime() && this.end.getTime() >= date.getTime()){
                isActive = true;
            }
        }
        // only begin exists
        else if(this.begin!=null){
            if(this.begin.getTime() <= date.getTime()){
                isActive = true;
            }
        }
        // only end exists
        else if(this.end!=null){
            if(this.end.getTime() >= date.getTime()){
                isActive = true;
            }
        }
    
        return isActive;
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
                // insert new leave
            	sSql = "INSERT INTO hr_leave (HR_LEAVE_SERVERID,HR_LEAVE_OBJECTID,HR_LEAVE_PERSONID,"+
                       "  HR_LEAVE_BEGINDATE,HR_LEAVE_ENDDATE,HR_LEAVE_DURATION,HR_LEAVE_TYPE,HR_LEAVE_REQUESTDATE,"+
            		   "  HR_LEAVE_AUTHORIZATIONDATE,HR_LEAVE_AUTHORIZEDBY,HR_LEAVE_EPISODECODE,HR_LEAVE_COMMENT,"+
                       "  HR_LEAVE_UPDATETIME,HR_LEAVE_UPDATEID)"+ // update-info
                       " VALUES(?,?,?,?,?,?,?,?,?,?,?,?,?,?)"; // 14
                ps = oc_conn.prepareStatement(sSql);
                
                int serverId = MedwanQuery.getInstance().getConfigInt("serverId"),
                    objectId = MedwanQuery.getInstance().getOpenclinicCounter("HR_LEAVE");
                this.setUid(serverId+"."+objectId);
                
                int psIdx = 1;
                ps.setInt(psIdx++,serverId);
                ps.setInt(psIdx++,objectId);
                ps.setInt(psIdx++,personId);
                
                ps.setDate(psIdx++,new java.sql.Date(begin.getTime()));
                ps.setDate(psIdx++,new java.sql.Date(end.getTime()));
                
                ps.setDouble(psIdx++,duration);
                ps.setString(psIdx++,type);

                // requestDate might be unspecified
                if(requestDate!=null){
                    ps.setDate(psIdx++,new java.sql.Date(requestDate.getTime()));
                }
                else{
                    ps.setDate(psIdx++,null);
                }

                // authorizationDate might be unspecified
                if(authorizationDate!=null){
                    ps.setDate(psIdx++,new java.sql.Date(authorizationDate.getTime()));
                }
                else{
                    ps.setDate(psIdx++,null);
                }
                
                ps.setString(psIdx++,authorizedBy.replaceAll("\\'","´").replaceAll("\"","´"));
                ps.setString(psIdx++,episodeCode.replaceAll("\\'","´").replaceAll("\"","´"));
                ps.setString(psIdx++,comment.replaceAll("\\'","´").replaceAll("\"","´"));
                ps.setTimestamp(psIdx++,new Timestamp(new java.util.Date().getTime())); // now
                ps.setString(psIdx,userUid);
                
                ps.executeUpdate();
            } 
            else{
                // update existing record
                sSql = "UPDATE hr_leave SET"+
                       "  HR_LEAVE_BEGINDATE = ?, HR_LEAVE_ENDDATE = ?, HR_LEAVE_DURATION = ?, HR_LEAVE_TYPE = ?,"+
                       "  HR_LEAVE_REQUESTDATE = ?, HR_LEAVE_AUTHORIZATIONDATE = ?, HR_LEAVE_AUTHORIZEDBY = ?,"+
                       "  HR_LEAVE_EPISODECODE = ?, HR_LEAVE_COMMENT = ?,"+
                       "  HR_LEAVE_UPDATETIME = ?, HR_LEAVE_UPDATEID = ?"+ // update-info
                       " WHERE (HR_LEAVE_SERVERID = ? AND HR_LEAVE_OBJECTID = ?)"; // identification
                ps = oc_conn.prepareStatement(sSql);

                int psIdx = 1;
                ps.setDate(psIdx++,new java.sql.Date(begin.getTime()));
                ps.setDate(psIdx++,new java.sql.Date(end.getTime()));

                ps.setDouble(psIdx++,duration);
                ps.setString(psIdx++,type);

                // requestDate might be unspecified
                if(requestDate!=null){
                    ps.setDate(psIdx++,new java.sql.Date(requestDate.getTime()));
                }
                else{
                    ps.setDate(psIdx++,null);
                }

                // authorizationDate might be unspecified
                if(authorizationDate!=null){
                    ps.setDate(psIdx++,new java.sql.Date(authorizationDate.getTime()));
                }
                else{
                    ps.setDate(psIdx++,null);
                }

                ps.setString(psIdx++,authorizedBy.replaceAll("\\'","´").replaceAll("\"","´"));
                ps.setString(psIdx++,episodeCode.replaceAll("\\'","´").replaceAll("\"","´"));
                ps.setString(psIdx++,comment.replaceAll("\\'","´").replaceAll("\"","´"));
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
    public static boolean delete(String sLeaveUid){
    	boolean errorOccurred = false;
        PreparedStatement ps = null;
        ResultSet rs = null;
        
        Connection oc_conn = MedwanQuery.getInstance().getOpenclinicConnection();
        
        try{
            String sSql = "DELETE FROM hr_leave"+
                          " WHERE (HR_LEAVE_SERVERID = ? AND HR_LEAVE_OBJECTID = ?)";
            ps = oc_conn.prepareStatement(sSql);
            ps.setInt(1,Integer.parseInt(sLeaveUid.substring(0,sLeaveUid.indexOf("."))));
            ps.setInt(2,Integer.parseInt(sLeaveUid.substring(sLeaveUid.indexOf(".")+1)));
            
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
    public static Leave get(Leave leave){
    	return get(leave.getUid());
    }
       
    public static Leave get(String sLeaveUid){
    	Leave leave = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        
        Connection oc_conn = MedwanQuery.getInstance().getOpenclinicConnection();
        
        try{
            String sSql = "SELECT * FROM hr_leave"+
                          " WHERE (HR_LEAVE_SERVERID = ? AND HR_LEAVE_OBJECTID = ?)";
            ps = oc_conn.prepareStatement(sSql);
            ps.setInt(1,Integer.parseInt(sLeaveUid.substring(0,sLeaveUid.indexOf("."))));
            ps.setInt(2,Integer.parseInt(sLeaveUid.substring(sLeaveUid.indexOf(".")+1)));

            // execute
            rs = ps.executeQuery();
            if(rs.next()){
                leave = new Leave();
                leave.setUid(rs.getString("HR_LEAVE_SERVERID")+"."+rs.getString("HR_LEAVE_OBJECTID"));
                leave.personId = rs.getInt("HR_LEAVE_PERSONID");

                leave.begin    = rs.getDate("HR_LEAVE_BEGINDATE");
                leave.end      = rs.getDate("HR_LEAVE_ENDDATE");
                leave.duration = rs.getFloat("HR_LEAVE_DURATION");
                leave.type              = ScreenHelper.checkString(rs.getString("HR_LEAVE_TYPE"));
                leave.requestDate       = rs.getDate("HR_LEAVE_REQUESTDATE");
                leave.authorizationDate = rs.getDate("HR_LEAVE_AUTHORIZATIONDATE");
                leave.authorizedBy      = ScreenHelper.checkString(rs.getString("HR_LEAVE_AUTHORIZEDBY"));
                leave.episodeCode       = ScreenHelper.checkString(rs.getString("HR_LEAVE_EPISODECODE"));
                leave.comment           = ScreenHelper.checkString(rs.getString("HR_LEAVE_COMMENT"));  
                
                // parent
                leave.setUpdateDateTime(rs.getTimestamp("HR_LEAVE_UPDATETIME"));
                leave.setUpdateUser(rs.getString("HR_LEAVE_UPDATEID"));
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
        
        return leave;
    }
        
    //--- GET LIST --------------------------------------------------------------------------------
    public static List<Leave> getList(){
    	return getList(new Leave());     	
    }
    
    public static List<Leave> getList(Leave findItem){
        List<Leave> foundObjects = new LinkedList();
        PreparedStatement ps = null;
        ResultSet rs = null;
        
        Connection oc_conn = MedwanQuery.getInstance().getOpenclinicConnection();
        
        try{
        	// compose query
            String sSql = "SELECT * FROM hr_leave WHERE 1=1"; // 'where' facilitates further composition of query

            if(findItem.personId > -1){
                sSql+= " AND HR_LEAVE_PERSONID = "+findItem.personId;
            }
            /*
			if(findItem.begin!=null){
			    sSql+= " AND HR_LEAVE_BEGINDATE = '"+ScreenHelper.stdDateFormat.format(findItem.begin)+"'";
			}
			if(findItem.end!=null){
			    sSql+= " AND HR_LEAVE_ENDDATE = '"+ScreenHelper.stdDateFormat.format(findItem.end)+"'";
			}
			*/
            if(findItem.duration > -1){
                sSql+= " AND HR_LEAVE_DURATION = "+findItem.duration;
            }			
			if(ScreenHelper.checkString(findItem.type).length() > 0){
			    sSql+= " AND HR_LEAVE_TYPE = '"+findItem.type+"'";
			}
			/*
            if(findItem.requestDate!=null){
                sSql+= " AND HR_LEAVE_REQUESTDATE = '"+ScreenHelper.stdDateFormat.format(findItem.requestDate)+"'";
            }
            if(findItem.authorizationDate!=null){
                sSql+= " AND HR_LEAVE_AUTHORIZATIONDATE = '"+ScreenHelper.stdDateFormat.format(findItem.authorizationDate)+"'";
            }
            */
            if(ScreenHelper.checkString(findItem.authorizedBy).length() > 0){
                sSql+= " AND HR_LEAVE_AUTHORIZEDBY = '"+findItem.authorizedBy+"'";
            }
            if(ScreenHelper.checkString(findItem.episodeCode).length() > 0){
                sSql+= " AND HR_LEAVE_EPISODECODE = '"+findItem.episodeCode+"'";
            }
            if(ScreenHelper.checkString(findItem.comment).length() > 0){
                sSql+= " AND HR_LEAVE_COMMENT LIKE '%"+findItem.comment+"%'";
            }
            sSql+= " ORDER BY HR_LEAVE_BEGINDATE ASC";
            
            ps = oc_conn.prepareStatement(sSql);
            
            /*
            // set question marks
            int psIdx = 1;
            
            if(findItem.personId > -1){
            	ps.setInt(psIdx++,findItem.personId);
            }
            if(ScreenHelper.checkString(findItem.leaveUid).length() > 0){
            	ps.setString(psIdx++,findItem.leaveUid);
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
            	ps.setString(psIdx++,findItem.comment.replaceAll("\\'","´").replaceAll("\"","´"));
            }
            */
            
            // execute query
            rs = ps.executeQuery();
            Leave item;
            
            while(rs.next()){
                item = new Leave();                
                item.setUid(rs.getString("HR_LEAVE_SERVERID")+"."+rs.getString("HR_LEAVE_OBJECTID"));
                item.personId = rs.getInt("HR_LEAVE_PERSONID");
                
                item.begin    = rs.getDate("HR_LEAVE_BEGINDATE");
                item.end      = rs.getDate("HR_LEAVE_ENDDATE");
                item.duration = rs.getFloat("HR_LEAVE_DURATION");
                item.type              = ScreenHelper.checkString(rs.getString("HR_LEAVE_TYPE"));
                item.requestDate       = rs.getDate("HR_LEAVE_REQUESTDATE");
                item.authorizationDate = rs.getDate("HR_LEAVE_AUTHORIZATIONDATE");
                item.authorizedBy      = ScreenHelper.checkString(rs.getString("HR_LEAVE_AUTHORIZEDBY"));
                item.episodeCode       = ScreenHelper.checkString(rs.getString("HR_LEAVE_EPISODECODE"));
                item.comment           = ScreenHelper.checkString(rs.getString("HR_LEAVE_COMMENT")); 

                // parent
                item.setUpdateDateTime(rs.getTimestamp("HR_LEAVE_UPDATETIME"));
                item.setUpdateUser(rs.getString("HR_LEAVE_UPDATEID"));
                
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
    
    
    ///////////////////////////////////////////////////////////////////////////////////////////////
    ///////////////////////////                   VARIA                 ///////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////
    
    //--- GET WORK DAYS ---------------------------------------------------------------------------
    public boolean[] getWorkDays(){
        boolean[] workDays = new boolean[7];
        
        // init to false (not working)
        workDays[0] = true;  // Monday
        workDays[1] = true;  // Tuesday
        workDays[2] = true;  // Wednesday
        workDays[3] = true;  // Thursday
        workDays[4] = true;  // Friday
        workDays[5] = false; // Saturday
        workDays[6] = false; // Sunday
        
        return workDays;
    }
     
}
