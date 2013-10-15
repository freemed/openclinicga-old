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


public class Training extends OC_Object {
    public int serverId;
    public int objectId;    
    public int personId;
    
    public java.util.Date begin;
    public java.util.Date end;
    public String institute;
    public String type;
    public String level;
    public String diploma;
    public java.util.Date diplomaDate;
    public String diplomaCode1;
    public String diplomaCode2;
    public String diplomaCode3;
    public String comment;

    
    //--- CONSTRUCTOR ---
    public Training(){
        serverId = -1;
        objectId = -1;        
        personId = -1;
        
        begin = null;
        end = null;
        institute = "";
        type = "";
        level = "";
        diploma = "";
        diplomaDate = null;
        diplomaCode1 = "";
        diplomaCode2 = "";
        diplomaCode3 = "";
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
                // insert new training
                sSql = "INSERT INTO hr_training (HR_TRAINING_SERVERID,HR_TRAINING_OBJECTID,HR_TRAINING_PERSONID,"+
                       "  HR_TRAINING_BEGINDATE,HR_TRAINING_ENDDATE,HR_TRAINING_INSTITUTE,HR_TRAINING_TYPE,HR_TRAINING_LEVEL,"+
                       "  HR_TRAINING_DIPLOMA,HR_TRAINING_DIPLOMADATE,HR_TRAINING_DIPLOMACODE1,HR_TRAINING_DIPLOMACODE2,"+
                       "  HR_TRAINING_DIPLOMACODE3,HR_TRAINING_COMMENT,"+
                       "  HR_TRAINING_UPDATETIME,HR_TRAINING_UPDATEID)"+ // update-info
                       " VALUES(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)"; // 16
                ps = oc_conn.prepareStatement(sSql);
                
                int serverId = MedwanQuery.getInstance().getConfigInt("serverId"),
                    objectId = MedwanQuery.getInstance().getOpenclinicCounter("HR_TRAINING");
                this.setUid(serverId+"."+objectId);
                
                int psIdx = 1;
                ps.setInt(psIdx++,serverId);
                ps.setInt(psIdx++,objectId);
                ps.setInt(psIdx++,personId);
                
                ps.setDate(psIdx++,new java.sql.Date(begin.getTime()));

                // end might be unspecified
                if(end!=null){
                    ps.setDate(psIdx++,new java.sql.Date(end.getTime()));
                }
                else{
                    ps.setDate(psIdx++,null);
                }
                
                ps.setString(psIdx++,institute.replaceAll("\\'","´").replaceAll("\"","´"));
                ps.setString(psIdx++,type.replaceAll("\\'","´").replaceAll("\"","´"));
                ps.setString(psIdx++,level.replaceAll("\\'","´").replaceAll("\"","´"));
                ps.setString(psIdx++,diploma.replaceAll("\\'","´").replaceAll("\"","´"));

                // diplomaDate might be unspecified
                if(diplomaDate!=null){
                    ps.setDate(psIdx++,new java.sql.Date(diplomaDate.getTime()));
                }
                else{
                    ps.setDate(psIdx++,null);
                }
                
                ps.setString(psIdx++,diplomaCode1);
                ps.setString(psIdx++,diplomaCode2);
                ps.setString(psIdx++,diplomaCode3);
                ps.setString(psIdx++,comment.replaceAll("\\'","´").replaceAll("\"","´"));
                ps.setTimestamp(psIdx++,new Timestamp(new java.util.Date().getTime())); // now
                ps.setString(psIdx,userUid);
                
                ps.executeUpdate();
            } 
            else{
                // update existing record
                sSql = "UPDATE hr_training SET"+
                       "  HR_TRAINING_BEGINDATE = ?, HR_TRAINING_ENDDATE = ?, HR_TRAINING_INSTITUTE = ?,"+
                       "  HR_TRAINING_TYPE = ?, HR_TRAINING_LEVEL = ?, HR_TRAINING_DIPLOMA = ?,"+
                       "  HR_TRAINING_DIPLOMADATE = ?, HR_TRAINING_DIPLOMACODE1 = ?, HR_TRAINING_DIPLOMACODE2 = ?,"+
                       "  HR_TRAINING_DIPLOMACODE3 = ?, HR_TRAINING_COMMENT = ?,"+
                       "  HR_TRAINING_UPDATETIME = ?, HR_TRAINING_UPDATEID = ?"+ // update-info
                       " WHERE (HR_TRAINING_SERVERID = ? AND HR_TRAINING_OBJECTID = ?)"; // identification
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

                ps.setString(psIdx++,institute.replaceAll("\\'","´").replaceAll("\"","´"));
                ps.setString(psIdx++,type.replaceAll("\\'","´").replaceAll("\"","´"));
                ps.setString(psIdx++,level.replaceAll("\\'","´").replaceAll("\"","´"));
                ps.setString(psIdx++,diploma.replaceAll("\\'","´").replaceAll("\"","´"));

                // diplomaDate might be unspecified
                if(diplomaDate!=null){
                    ps.setDate(psIdx++,new java.sql.Date(diplomaDate.getTime()));
                }
                else{
                    ps.setDate(psIdx++,null);
                }
                
                ps.setString(psIdx++,diplomaCode1);
                ps.setString(psIdx++,diplomaCode2);
                ps.setString(psIdx++,diplomaCode3);
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
    public static boolean delete(String sTrainingUid){
        boolean errorOccurred = false;
        PreparedStatement ps = null;
        ResultSet rs = null;
        
        Connection oc_conn = MedwanQuery.getInstance().getOpenclinicConnection();
        
        try{
            String sSql = "DELETE FROM hr_training"+
                          " WHERE (HR_TRAINING_SERVERID = ? AND HR_TRAINING_OBJECTID = ?)";
            ps = oc_conn.prepareStatement(sSql);
            ps.setInt(1,Integer.parseInt(sTrainingUid.substring(0,sTrainingUid.indexOf("."))));
            ps.setInt(2,Integer.parseInt(sTrainingUid.substring(sTrainingUid.indexOf(".")+1)));
            
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
    public static Training get(Training training){
        return get(training.getUid());
    }
       
    public static Training get(String sTrainingUid){
        Training training = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        
        Connection oc_conn = MedwanQuery.getInstance().getOpenclinicConnection();
        
        try{
            String sSql = "SELECT * FROM hr_training"+
                          " WHERE (HR_TRAINING_SERVERID = ? AND HR_TRAINING_OBJECTID = ?)";
            ps = oc_conn.prepareStatement(sSql);
            ps.setInt(1,Integer.parseInt(sTrainingUid.substring(0,sTrainingUid.indexOf("."))));
            ps.setInt(2,Integer.parseInt(sTrainingUid.substring(sTrainingUid.indexOf(".")+1)));

            // execute
            rs = ps.executeQuery();
            if(rs.next()){
                training = new Training();
                training.setUid(rs.getString("HR_TRAINING_SERVERID")+"."+rs.getString("HR_TRAINING_OBJECTID"));

                training.personId     = rs.getInt("HR_TRAINING_PERSONID");
                training.begin        = rs.getDate("HR_TRAINING_BEGINDATE");
                training.end          = rs.getDate("HR_TRAINING_ENDDATE");
                training.institute    = ScreenHelper.checkString(rs.getString("HR_TRAINING_INSTITUTE"));
                training.type         = ScreenHelper.checkString(rs.getString("HR_TRAINING_TYPE"));
                training.level        = ScreenHelper.checkString(rs.getString("HR_TRAINING_LEVEL"));
                training.diploma      = ScreenHelper.checkString(rs.getString("HR_TRAINING_DIPLOMA"));
                training.diplomaDate  = rs.getDate("HR_TRAINING_DIPLOMADATE");
                training.diplomaCode1 = ScreenHelper.checkString(rs.getString("HR_TRAINING_DIPLOMACODE1")); 
                training.diplomaCode2 = ScreenHelper.checkString(rs.getString("HR_TRAINING_DIPLOMACODE2")); 
                training.diplomaCode3 = ScreenHelper.checkString(rs.getString("HR_TRAINING_DIPLOMACODE3")); 
                training.comment      = ScreenHelper.checkString(rs.getString("HR_TRAINING_COMMENT")); 
                
                // parent
                training.setUpdateDateTime(rs.getTimestamp("HR_TRAINING_UPDATETIME"));
                training.setUpdateUser(rs.getString("HR_TRAINING_UPDATEID"));
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
        
        return training;
    }
        
    //--- GET LIST --------------------------------------------------------------------------------
    public static List<Training> getList(){
        return getList(new Training());         
    }
    
    public static List<Training> getList(Training findItem){
        List<Training> foundObjects = new LinkedList();
        PreparedStatement ps = null;
        ResultSet rs = null;
        
        Connection oc_conn = MedwanQuery.getInstance().getOpenclinicConnection();
        
        try{
            // compose query
            String sSql = "SELECT * FROM hr_training WHERE 1=1"; // 'where' facilitates further composition of query

            if(findItem.personId > -1){
                sSql+= " AND HR_TRAINING_PERSONID = "+findItem.personId;
            }
            if(findItem.begin!=null){
                sSql+= " AND HR_TRAINING_BEGINDATE = '"+ScreenHelper.stdDateFormat.format(findItem.begin)+"'";
            }
            if(findItem.end!=null){
                sSql+= " AND HR_TRAINING_ENDDATE = '"+ScreenHelper.stdDateFormat.format(findItem.end)+"'";
            }
            if(ScreenHelper.checkString(findItem.institute).length() > 0){
                sSql+= " AND HR_TRAINING_INSTITUTE = '"+findItem.institute+"'";
            }
            if(ScreenHelper.checkString(findItem.type).length() > 0){
                sSql+= " AND HR_TRAINING_TYPE = '"+findItem.type+"'";
            }
            if(ScreenHelper.checkString(findItem.level).length() > 0){
                sSql+= " AND HR_TRAINING_LEVEL = '"+findItem.level+"'";
            }
            if(ScreenHelper.checkString(findItem.diploma).length() > 0){
                sSql+= " AND HR_TRAINING_DIPLOMA = '"+findItem.diploma+"'";
            }
            if(ScreenHelper.checkString(findItem.diplomaCode1).length() > 0){
                sSql+= " AND HR_TRAINING_DIPLOMACODE1 = '"+findItem.diplomaCode1+"'";
            }
            if(ScreenHelper.checkString(findItem.diplomaCode2).length() > 0){
                sSql+= " AND HR_TRAINING_DIPLOMACODE2 = '"+findItem.diplomaCode2+"'";
            }
            if(ScreenHelper.checkString(findItem.diplomaCode3).length() > 0){
                sSql+= " AND HR_TRAINING_DIPLOMACODE3 = '"+findItem.diplomaCode3+"'";
            }
            if(ScreenHelper.checkString(findItem.comment).length() > 0){
                sSql+= " AND HR_TRAINING_COMMENT LIKE '%"+findItem.comment+"%'";
            }
            sSql+= " ORDER BY HR_TRAINING_BEGINDATE ASC";
            
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
                ps.setString(psIdx++,findItem.comment.replaceAll("\\'","´").replaceAll("\"","´"));
            }
            */
            
            // execute query
            rs = ps.executeQuery();
            Training item;
            
            while(rs.next()){
                item = new Training();                
                item.setUid(rs.getString("HR_TRAINING_SERVERID")+"."+rs.getString("HR_TRAINING_OBJECTID"));

                item.personId     = rs.getInt("HR_TRAINING_PERSONID");
                item.begin        = rs.getDate("HR_TRAINING_BEGINDATE");
                item.end          = rs.getDate("HR_TRAINING_ENDDATE");
                item.institute    = ScreenHelper.checkString(rs.getString("HR_TRAINING_INSTITUTE"));
                item.type         = ScreenHelper.checkString(rs.getString("HR_TRAINING_TYPE"));
                item.level        = ScreenHelper.checkString(rs.getString("HR_TRAINING_LEVEL"));
                item.diploma      = ScreenHelper.checkString(rs.getString("HR_TRAINING_DIPLOMA"));
                item.diplomaDate  = rs.getDate("HR_TRAINING_DIPLOMADATE");
                item.diplomaCode1 = ScreenHelper.checkString(rs.getString("HR_TRAINING_DIPLOMACODE1")); 
                item.diplomaCode2 = ScreenHelper.checkString(rs.getString("HR_TRAINING_DIPLOMACODE2")); 
                item.diplomaCode3 = ScreenHelper.checkString(rs.getString("HR_TRAINING_DIPLOMACODE3")); 
                item.comment      = ScreenHelper.checkString(rs.getString("HR_TRAINING_COMMENT"));  
                
                // parent
                item.setUpdateDateTime(rs.getTimestamp("HR_TRAINING_UPDATETIME"));
                item.setUpdateUser(rs.getString("HR_TRAINING_UPDATEID"));
                
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
    
    //--- GET DIPLOMA CODE ------------------------------------------------------------------------
    public String getDiplomaCode(int idx){
        switch(idx){
            case(1) : return this.diplomaCode1;
            case(2) : return this.diplomaCode2;
            case(3) : return this.diplomaCode3;
        }
            
        return ""; // not found
    }
     
}
