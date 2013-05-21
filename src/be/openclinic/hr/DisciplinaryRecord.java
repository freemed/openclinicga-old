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


public class DisciplinaryRecord extends OC_Object {
    public int serverId;
    public int objectId;    
    public int personId;
    
    public java.util.Date date;
    public String title;
    public String description;
    public String decision;
    public int duration;
    public String decisionBy;
    public String followUp;
    
    
    //--- CONSTRUCTOR ---
    public DisciplinaryRecord(){
        serverId = -1;
        objectId = -1;        
        personId = -1;
        
        date = null;
        title = "";
        description = "";
        decision = "";
        duration = -1;
        decisionBy = "";
        followUp = "";
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
                // insert new disciplinary record
                sSql = "INSERT INTO hr_disciplinary_records (HR_DISREC_SERVERID,HR_DISREC_OBJECTID,"+
                       "  HR_DISREC_PERSONID,HR_DISREC_DATE,HR_DISREC_TITLE,HR_DISREC_DESCRIPTION,"+
                       "  HR_DISREC_DECISION,HR_DISREC_DURATION,HR_DISREC_DECISIONBY,"+
                       "  HR_DISREC_FOLLOWUP,HR_DISREC_UPDATETIME,HR_DISREC_UPDATEID)"+ // update-info
                       " VALUES(?,?,?,?,?,?,?,?,?,?,?,?)"; // 12
                ps = oc_conn.prepareStatement(sSql);
                
                int serverId = MedwanQuery.getInstance().getConfigInt("serverId"),
                    objectId = MedwanQuery.getInstance().getOpenclinicCounter("HR_DISCIPLINARY_RECORD");
                this.setUid(serverId+"."+objectId);
                
                int psIdx = 1;
                ps.setInt(psIdx++,serverId);
                ps.setInt(psIdx++,objectId);
                ps.setInt(psIdx++,personId);
                ps.setDate(psIdx++,new java.sql.Date(date.getTime()));
                ps.setString(psIdx++,title);
                ps.setString(psIdx++,description);
                ps.setString(psIdx++,decision);
                ps.setInt(psIdx++,duration);
                ps.setString(psIdx++,decisionBy);
                ps.setString(psIdx++,followUp);                
                
                ps.setTimestamp(psIdx++,new Timestamp(new java.util.Date().getTime())); // now
                ps.setString(psIdx,userUid);
                
                ps.executeUpdate();
            } 
            else{            
                // update existing record
                sSql = "UPDATE hr_disciplinary_records SET"+
                       "  HR_DISREC_DATE = ?, HR_DISREC_TITLE = ?, HR_DISREC_DESCRIPTION = ?,"+
                       "  HR_DISREC_DECISION = ?, HR_DISREC_DURATION = ?, HR_DISREC_DECISIONBY = ?,"+
                       "  HR_DISREC_FOLLOWUP = ?, HR_DISREC_UPDATETIME = ?, HR_DISREC_UPDATEID = ?"+ // update-info
                       " WHERE (HR_DISREC_SERVERID = ? AND HR_DISREC_OBJECTID = ?)"; // identification
                ps = oc_conn.prepareStatement(sSql);

                int psIdx = 1;
                ps.setDate(psIdx++,new java.sql.Date(date.getTime()));
                ps.setString(psIdx++,title);
                ps.setString(psIdx++,description);
                ps.setString(psIdx++,decision);
                ps.setInt(psIdx++,duration);
                ps.setString(psIdx++,decisionBy);
                ps.setString(psIdx++,followUp);   
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
    public static boolean delete(String sDisRecUid){
    	boolean errorOccurred = false;
        PreparedStatement ps = null;
        ResultSet rs = null;
        
        Connection oc_conn = MedwanQuery.getInstance().getOpenclinicConnection();
        
        try{
            String sSql = "DELETE FROM hr_disciplinary_records"+
                          " WHERE (HR_DISREC_SERVERID = ? AND HR_DISREC_OBJECTID = ?)";
            ps = oc_conn.prepareStatement(sSql);
            ps.setInt(1,Integer.parseInt(sDisRecUid.substring(0,sDisRecUid.indexOf("."))));
            ps.setInt(2,Integer.parseInt(sDisRecUid.substring(sDisRecUid.indexOf(".")+1)));
            
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
    public static DisciplinaryRecord get(DisciplinaryRecord disRec){
    	return get(disRec.getUid());
    }
       
    public static DisciplinaryRecord get(String sDisRecUid){
    	DisciplinaryRecord disRec = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        
        Connection oc_conn = MedwanQuery.getInstance().getOpenclinicConnection();
        
        try{
            String sSql = "SELECT * FROM hr_disciplinary_records"+
                          " WHERE (HR_DISREC_SERVERID = ? AND HR_DISREC_OBJECTID = ?)";
            ps = oc_conn.prepareStatement(sSql);
            ps.setInt(1,Integer.parseInt(sDisRecUid.substring(0,sDisRecUid.indexOf("."))));
            ps.setInt(2,Integer.parseInt(sDisRecUid.substring(sDisRecUid.indexOf(".")+1)));

            // execute
            rs = ps.executeQuery();
            if(rs.next()){
            	disRec = new DisciplinaryRecord();
            	disRec.setUid(rs.getString("HR_DISREC_SERVERID")+"."+rs.getString("HR_DISREC_OBJECTID"));

            	disRec.personId    = rs.getInt("HR_DISREC_PERSONID");
                disRec.date        = rs.getDate("HR_DISREC_DATE");
                disRec.title       = ScreenHelper.checkString(rs.getString("HR_DISREC_TITLE"));
                disRec.description = ScreenHelper.checkString(rs.getString("HR_DISREC_DESCRIPTION"));
                disRec.decision    = ScreenHelper.checkString(rs.getString("HR_DISREC_DECISION"));
                disRec.duration    = rs.getInt("HR_DISREC_DURATION");
                disRec.decisionBy  = ScreenHelper.checkString(rs.getString("HR_DISREC_DECISIONBY"));
                disRec.followUp    = ScreenHelper.checkString(rs.getString("HR_DISREC_FOLLOWUP")); 
               
                // parent
                disRec.setUpdateDateTime(rs.getTimestamp("HR_DISREC_UPDATETIME"));
                disRec.setUpdateUser(rs.getString("HR_DISREC_UPDATEID"));
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
        
        return disRec;
    }
        
    //--- GET LIST --------------------------------------------------------------------------------
    public static List<DisciplinaryRecord> getList(){
    	return getList(new DisciplinaryRecord());     	
    }
    
    public static List<DisciplinaryRecord> getList(DisciplinaryRecord findItem){
        List<DisciplinaryRecord> foundObjects = new LinkedList();
        PreparedStatement ps = null;
        ResultSet rs = null;
        
        Connection oc_conn = MedwanQuery.getInstance().getOpenclinicConnection();
        
        try{
        	// compose query
            String sSql = "SELECT * FROM hr_disciplinary_records WHERE 1=1"; // 'where' facilitates further composition of query 

            if(findItem.personId > -1){
                sSql+= " AND HR_DISREC_PERSONID = "+findItem.personId;
            }
            if(ScreenHelper.checkString(findItem.title).length() > 0){
                sSql+= " AND HR_DISREC_TITLE LIKE '%"+findItem.title+"%'";
            }
            if(ScreenHelper.checkString(findItem.description).length() > 0){
                sSql+= " AND HR_DISREC_DESCRIPTION LIKE '%"+findItem.description+"%'";
            }
            if(ScreenHelper.checkString(findItem.decision).length() > 0){
                sSql+= " AND HR_DISREC_DECISION = '"+findItem.decision+"'";
            }
            if(findItem.duration > -1){
                sSql+= " AND HR_DISREC_DURATION = "+findItem.duration;
            }
            if(ScreenHelper.checkString(findItem.decisionBy).length() > 0){
                sSql+= " AND HR_DISREC_DECISIONBY LIKE '%"+findItem.decisionBy+"%'";
            }
            if(ScreenHelper.checkString(findItem.followUp).length() > 0){
                sSql+= " AND HR_DISREC_FOLLOWUP LIKE '%"+findItem.followUp+"%'";
            }
            sSql+= " ORDER BY HR_DISREC_DATE ASC";

            ps = oc_conn.prepareStatement(sSql);
            
            /*
            // set question marks            
            int psIdx = 1;
            
            if(findItem.personId > -1){
            	ps.setInt(psIdx++,findItem.personId);
            }
            if(ScreenHelper.checkString(findItem.title).length() > 0){
            	ps.setString(psIdx++,findItem.title);
            }
            if(ScreenHelper.checkString(findItem.description).length() > 0){
            	ps.setString(psIdx++,findItem.description);
            }
            if(ScreenHelper.checkString(findItem.decision).length() > 0){
            	ps.setString(psIdx++,findItem.decision);
            }
            if(findItem.duration > -1){
            	ps.setInt(psIdx++,findItem.duration);
            }
            if(ScreenHelper.checkString(findItem.decisionBy).length() > 0){
            	ps.setString(psIdx++,findItem.decisionBy);
            }
            if(ScreenHelper.checkString(findItem.followUp).length() > 0){
            	ps.setString(psIdx++,findItem.followUp);
            }
            */
            
            // execute query
            rs = ps.executeQuery();
            DisciplinaryRecord item;
            
            while(rs.next()){
                item = new DisciplinaryRecord();                
                item.setUid(rs.getString("HR_DISREC_SERVERID")+"."+rs.getString("HR_DISREC_OBJECTID"));

                item.personId    = rs.getInt("HR_DISREC_PERSONID");
                item.date        = rs.getDate("HR_DISREC_DATE");
                item.title       = ScreenHelper.checkString(rs.getString("HR_DISREC_TITLE"));
                item.description = ScreenHelper.checkString(rs.getString("HR_DISREC_DESCRIPTION"));
                item.decision    = ScreenHelper.checkString(rs.getString("HR_DISREC_DECISION"));
                item.duration    = rs.getInt("HR_DISREC_DURATION");
                item.decisionBy  = ScreenHelper.checkString(rs.getString("HR_DISREC_DECISIONBY"));
                item.followUp    = ScreenHelper.checkString(rs.getString("HR_DISREC_FOLLOWUP")); 
                
                // parent
                item.setUpdateDateTime(rs.getTimestamp("HR_DISREC_UPDATETIME"));
                item.setUpdateUser(rs.getString("HR_DISREC_UPDATEID"));
                
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
