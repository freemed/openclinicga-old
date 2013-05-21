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


public class Workschedule extends OC_Object {
    public int serverId;
    public int objectId;    
    public int personId;
    
    public java.util.Date begin;
    public java.util.Date end;
    public int fte;
    public String scheduleXml;
    public String type; // only for convenience

    
    //--- CONSTRUCTOR ---
    public Workschedule(){
        serverId = -1;
        objectId = -1;        
        personId = -1;
        
        begin = null;
        end = null;
        fte = -1;
        scheduleXml = ""; 
        type = ""; // only for convenience
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
                // insert new schedule
                sSql = "INSERT INTO hr_workschedule (HR_WORKSCHEDULE_SERVERID,HR_WORKSCHEDULE_OBJECTID,HR_WORKSCHEDULE_PERSONID,"+
                       "  HR_WORKSCHEDULE_BEGINDATE,HR_WORKSCHEDULE_ENDDATE,HR_WORKSCHEDULE_FTE,HR_WORKSCHEDULE_SCHEDULE,"+
                	   "  HR_WORKSCHEDULE_UPDATETIME, HR_WORKSCHEDULE_UPDATEID)"+ // update-info
                       " VALUES(?,?,?,?,?,?,?,?,?)"; // 9
                ps = oc_conn.prepareStatement(sSql);
                
                int serverId = MedwanQuery.getInstance().getConfigInt("serverId"),
                    objectId = MedwanQuery.getInstance().getOpenclinicCounter("HR_WORKSCHEDULE");
                this.setUid(serverId+"."+objectId);
                
                int psIdx = 1;
                ps.setInt(psIdx++,serverId);
                ps.setInt(psIdx++,objectId);
                ps.setInt(psIdx++,personId);

                // begin date might be unspecified
                if(begin!=null){
                    ps.setDate(psIdx++,new java.sql.Date(begin.getTime()));
                }
                else{
                    ps.setDate(psIdx++,null);
                }
                
                // end date might be unspecified
                if(end!=null){
                    ps.setDate(psIdx++,new java.sql.Date(end.getTime()));
                }
                else{
                    ps.setDate(psIdx++,null);
                }

                ps.setInt(psIdx++,fte);
                ps.setString(psIdx++,scheduleXml);
                ps.setTimestamp(psIdx++,new Timestamp(new java.util.Date().getTime())); // now
                ps.setString(psIdx,userUid);
                
                ps.executeUpdate();
            } 
            else{
                // update existing record
                sSql = "UPDATE hr_workschedule SET"+
                       "  HR_WORKSCHEDULE_BEGINDATE = ?, HR_WORKSCHEDULE_ENDDATE = ?,"+
                	   "  HR_WORKSCHEDULE_FTE = ?, HR_WORKSCHEDULE_SCHEDULE = ?,"+
                       "  HR_WORKSCHEDULE_UPDATETIME = ?, HR_WORKSCHEDULE_UPDATEID = ?"+ // update-info
                       " WHERE (HR_WORKSCHEDULE_SERVERID = ? AND HR_WORKSCHEDULE_OBJECTID = ?)"; // identification
                ps = oc_conn.prepareStatement(sSql);

                int psIdx = 1;
                
                // begin date might be unspecified
                if(begin!=null){
                    ps.setDate(psIdx++,new java.sql.Date(begin.getTime()));
                }
                else{
                    ps.setDate(psIdx++,null);
                }
                
                // end date might be unspecified
                if(end!=null){
                    ps.setDate(psIdx++,new java.sql.Date(end.getTime()));
                }
                else{
                    ps.setDate(psIdx++,null);
                }

                ps.setInt(psIdx++,fte);
                ps.setString(psIdx++,scheduleXml);
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
    public static boolean delete(String sCareerUid){
    	boolean errorOccurred = false;
        PreparedStatement ps = null;
        ResultSet rs = null;
        
        Connection oc_conn = MedwanQuery.getInstance().getOpenclinicConnection();
        
        try{
            String sSql = "DELETE FROM hr_workschedule"+
                          " WHERE (HR_WORKSCHEDULE_SERVERID = ? AND HR_WORKSCHEDULE_OBJECTID = ?)";
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
    public static Workschedule get(Workschedule schedule){
    	return get(schedule.getUid());
    }
       
    public static Workschedule get(String sCareerUid){
    	Workschedule schedule = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        
        Connection oc_conn = MedwanQuery.getInstance().getOpenclinicConnection();
        
        try{
            String sSql = "SELECT * FROM hr_workschedule"+
                          " WHERE (HR_WORKSCHEDULE_SERVERID = ? AND HR_WORKSCHEDULE_OBJECTID = ?)";
            ps = oc_conn.prepareStatement(sSql);
            ps.setInt(1,Integer.parseInt(sCareerUid.substring(0,sCareerUid.indexOf("."))));
            ps.setInt(2,Integer.parseInt(sCareerUid.substring(sCareerUid.indexOf(".")+1)));

            // execute
            rs = ps.executeQuery();
            if(rs.next()){
                schedule = new Workschedule();
                schedule.setUid(rs.getString("HR_WORKSCHEDULE_SERVERID")+"."+rs.getString("HR_WORKSCHEDULE_OBJECTID"));

                schedule.personId    = rs.getInt("HR_WORKSCHEDULE_PERSONID");
                schedule.begin       = rs.getDate("HR_WORKSCHEDULE_BEGINDATE");
                schedule.end         = rs.getDate("HR_WORKSCHEDULE_ENDDATE");
                schedule.fte         = rs.getInt("HR_WORKSCHEDULE_FTE");
                schedule.scheduleXml = ScreenHelper.checkString(rs.getString("HR_WORKSCHEDULE_SCHEDULE")); 
                
                // parent
                schedule.setUpdateDateTime(rs.getTimestamp("HR_WORKSCHEDULE_UPDATETIME"));
                schedule.setUpdateUser(rs.getString("HR_WORKSCHEDULE_UPDATEID"));
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
        
        return schedule;
    }
        
    //--- GET LIST --------------------------------------------------------------------------------
    public static List<Workschedule> getList(){
    	return getList(new Workschedule());     	
    }
    
    public static List<Workschedule> getList(Workschedule findItem){
        List<Workschedule> foundObjects = new LinkedList();
        PreparedStatement ps = null;
        ResultSet rs = null;
        
        Connection oc_conn = MedwanQuery.getInstance().getOpenclinicConnection();
        
        try{
        	// compose query
            String sSql = "SELECT * FROM hr_workschedule WHERE 1=1"; // 'where' facilitates further composition of query

            if(findItem.personId > -1){
                sSql+= " AND HR_WORKSCHEDULE_PERSONID = "+findItem.personId;
            }
            /*
            if(findItem.begin!=null){
                sSql+= " AND HR_WORKSCHEDULE_BEGINDATE = '"+ScreenHelper.stdDateFormat.format(findItem.begin)+"'";
            }
            if(findItem.end!=null){
                sSql+= " AND HR_WORKSCHEDULE_ENDDATE = '"+ScreenHelper.stdDateFormat.format(findItem.end)+"'";
            }
            */
            if(findItem.fte > -1){
                sSql+= " AND HR_WORKSCHEDULE_FTE = "+findItem.fte;
            }
            
            sSql+= " ORDER BY HR_WORKSCHEDULE_OBJECTID ASC";
            
            ps = oc_conn.prepareStatement(sSql);
                       
            // execute query
            rs = ps.executeQuery();
            Workschedule item;
            
            while(rs.next()){
                item = new Workschedule();                
                item.setUid(rs.getString("HR_WORKSCHEDULE_SERVERID")+"."+rs.getString("HR_WORKSCHEDULE_OBJECTID"));

                item.personId    = rs.getInt("HR_WORKSCHEDULE_PERSONID");
                item.begin       = rs.getDate("HR_WORKSCHEDULE_BEGINDATE");
                item.end         = rs.getDate("HR_WORKSCHEDULE_ENDDATE");
                item.fte         = rs.getInt("HR_WORKSCHEDULE_FTE");
                item.scheduleXml = ScreenHelper.checkString(rs.getString("HR_WORKSCHEDULE_SCHEDULE")); 
                
                // parent
                item.setUpdateDateTime(rs.getTimestamp("HR_WORKSCHEDULE_UPDATETIME"));
                item.setUpdateUser(rs.getString("HR_WORKSCHEDULE_UPDATEID"));
                
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
    
    //--- GET SCHEDULE ELEMENT VALUE --------------------------------------------------------------
    public String getScheduleElementValue(String scheduleType, String sElementName){
    	String sValue = "";
    	
    	try{
	    	// parse schedule from xml        	
	        SAXReader reader = new SAXReader(false);
	        Document document = reader.read(new StringReader(scheduleXml));
	        Element scheduleElem = document.getRootElement();
	            	
	    	if(scheduleType.equalsIgnoreCase("day")){
	    		sValue = ScreenHelper.checkString(scheduleElem.elementText(sElementName));
	    	}
	    	else if(scheduleType.equalsIgnoreCase("week")){
	    		Element weekSchedule = scheduleElem.element("WeekSchedule");
	    		if(weekSchedule!=null){
	    		    sValue = weekSchedule.asXML();
	    		}
	    	}
	    	else if(scheduleType.equalsIgnoreCase("month")){
	    		sValue = ScreenHelper.checkString(scheduleElem.elementText(sElementName));
	    	}
    	}
    	catch(Exception e){
    		e.printStackTrace();
            Debug.printProjectErr(e,Thread.currentThread().getStackTrace());
    	}
    	
    	return sValue;
    }
     
}
