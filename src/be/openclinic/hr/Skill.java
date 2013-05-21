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


public class Skill extends OC_Object {
    public int serverId;
    public int objectId;    
    public int personId;
    
    public String languages;
    public String drivingLicense;
    public String itOffice;
    public String itInternet;
    public String itOther;
    public String communicationSkills;
    public String stressResistance;
    public String comment;
    
    
    //--- CONSTRUCTOR ---
    public Skill(){
        serverId = -1;
        objectId = -1;        
        personId = -1;

        languages = "";
        drivingLicense = "";
        itOffice = "";
        itInternet = "";
        itOther = "";
        communicationSkills = "";
        stressResistance = "";
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
                // insert new skill
                sSql = "INSERT INTO hr_skills (HR_SKILL_SERVERID,HR_SKILL_OBJECTID,HR_SKILL_PERSONID,"+
                       "  HR_SKILL_LANGUAGES,HR_SKILL_DRIVINGLICENSE,HR_SKILL_IT_OFFICE,HR_SKILL_IT_INTERNET,"+
                       "  HR_SKILL_IT_OTHER,HR_SKILL_COMMUNICATION,HR_SKILL_STRESS,HR_SKILL_COMMENT,"+
                       "  HR_SKILL_UPDATETIME,HR_SKILL_UPDATEID)"+ // update-info
                       " VALUES(?,?,?,?,?,?,?,?,?,?,?,?,?)"; // 13
                ps = oc_conn.prepareStatement(sSql);
                
                int serverId = MedwanQuery.getInstance().getConfigInt("serverId"),
                    objectId = MedwanQuery.getInstance().getOpenclinicCounter("HR_CAREER");
                this.setUid(serverId+"."+objectId);
                
                int psIdx = 1;
                ps.setInt(psIdx++,serverId);
                ps.setInt(psIdx++,objectId);
                ps.setInt(psIdx++,personId);
                
                ps.setString(psIdx++,languages);
                ps.setString(psIdx++,drivingLicense);
                ps.setString(psIdx++,itOffice);
                ps.setString(psIdx++,itInternet);
                ps.setString(psIdx++,itOther);
                ps.setString(psIdx++,communicationSkills);
                ps.setString(psIdx++,stressResistance);
                ps.setString(psIdx++,comment);
                
                ps.setTimestamp(psIdx++,new Timestamp(new java.util.Date().getTime())); // now
                ps.setString(psIdx,userUid);
                
                ps.executeUpdate();
            } 
            else{
                // update existing record
                sSql = "UPDATE hr_skills SET"+
                       "  HR_SKILL_LANGUAGES = ?, HR_SKILL_DRIVINGLICENSE = ?, HR_SKILL_IT_OFFICE = ?,"+
                       "  HR_SKILL_IT_INTERNET = ?, HR_SKILL_IT_OTHER = ?, HR_SKILL_COMMUNICATION = ?,"+
                       "  HR_SKILL_STRESS = ?, HR_SKILL_COMMENT = ?,"+
                       "  HR_SKILL_UPDATETIME = ?, HR_SKILL_UPDATEID = ?"+ // update-info
                       " WHERE (HR_SKILL_SERVERID = ? AND HR_SKILL_OBJECTID = ?)"; // identification
                ps = oc_conn.prepareStatement(sSql);

                int psIdx = 1;

                ps.setString(psIdx++,languages);
                ps.setString(psIdx++,drivingLicense);
                ps.setString(psIdx++,itOffice);
                ps.setString(psIdx++,itInternet);
                ps.setString(psIdx++,itOther);
                ps.setString(psIdx++,communicationSkills);
                ps.setString(psIdx++,stressResistance);
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
    public static boolean delete(String sSkillUid){
    	boolean errorOccurred = false;
        PreparedStatement ps = null;
        ResultSet rs = null;
        
        Connection oc_conn = MedwanQuery.getInstance().getOpenclinicConnection();
        
        try{
            String sSql = "DELETE FROM hr_skills"+
                          " WHERE (HR_SKILL_SERVERID = ? AND HR_SKILL_OBJECTID = ?)";
            ps = oc_conn.prepareStatement(sSql);
            ps.setInt(1,Integer.parseInt(sSkillUid.substring(0,sSkillUid.indexOf("."))));
            ps.setInt(2,Integer.parseInt(sSkillUid.substring(sSkillUid.indexOf(".")+1)));
            
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
    public static Skill get(String sPersonId){
    	Skill skill = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        
        Connection oc_conn = MedwanQuery.getInstance().getOpenclinicConnection();
        
        try{
            String sSql = "SELECT * FROM hr_skills"+
                          " WHERE HR_SKILL_PERSONID = ?";
            ps = oc_conn.prepareStatement(sSql);
            ps.setInt(1,Integer.parseInt(sPersonId));

            // execute
            rs = ps.executeQuery();
            if(rs.next()){
                skill = new Skill();
                skill.setUid(rs.getString("HR_SKILL_SERVERID")+"."+rs.getString("HR_SKILL_OBJECTID"));
             
                skill.personId            = rs.getInt("HR_SKILL_PERSONID");
				skill.languages           = ScreenHelper.checkString(rs.getString("HR_SKILL_LANGUAGES"));
				skill.drivingLicense      = ScreenHelper.checkString(rs.getString("HR_SKILL_DRIVINGLICENSE"));
                skill.itOffice            = ScreenHelper.checkString(rs.getString("HR_SKILL_IT_OFFICE"));
                skill.itInternet          = ScreenHelper.checkString(rs.getString("HR_SKILL_IT_INTERNET"));
                skill.itOther             = ScreenHelper.checkString(rs.getString("HR_SKILL_IT_OTHER"));
                skill.communicationSkills = ScreenHelper.checkString(rs.getString("HR_SKILL_COMMUNICATION"));
                skill.stressResistance    = ScreenHelper.checkString(rs.getString("HR_SKILL_STRESS"));
                skill.comment             = ScreenHelper.checkString(rs.getString("HR_SKILL_COMMENT")); 

                // parent
                skill.setUpdateDateTime(rs.getTimestamp("HR_SKILL_UPDATETIME"));
                skill.setUpdateUser(rs.getString("HR_SKILL_UPDATEID"));
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
        
        return skill;
    }
        
}
