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


public class Salary extends OC_Object {
    public int serverId;
    public int objectId;    
    public int personId;
    
    public String contractUid;    
    public java.util.Date begin;
    public java.util.Date end;    
    public float salary; // (text, numeric with priceFormat mask)
    public String salaryPeriod; // daily (working days only), weekly, monthly (default), yearly
    public String benefits; // multi-add
    public String bonuses; // multi-add
    public String otherIncome; // multi-add
    public String deductions; // multi-add
    public String comment;

    
    //--- CONSTRUCTOR ---
    public Salary(){
        serverId = -1;
        objectId = -1;        
        personId = -1;
        
        begin = null;
        end = null;
        contractUid = "";
        salary = -1f;
        salaryPeriod = "";

        // xmls
        benefits = "";
        bonuses = "";
        otherIncome = "";
        deductions = "";
        
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
                // insert new salary
                sSql = "INSERT INTO hr_salaries (HR_SALARY_SERVERID,HR_SALARY_OBJECTID,HR_SALARY_PERSONID,"+
                       "  HR_SALARY_CONTRACTUID,HR_SALARY_BEGINDATE,HR_SALARY_ENDDATE,HR_SALARY_SALARY,HR_SALARY_SALARYPERIOD,"+
                	   "  HR_SALARY_BENEFITS,HR_SALARY_BONUSES,HR_SALARY_OTHERINCOME,HR_SALARY_DEDUCTIONS,"+
                       "  HR_SALARY_COMMENT,HR_SALARY_UPDATETIME,HR_SALARY_UPDATEID)"+ // update-info
                       " VALUES(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)"; // 15
                ps = oc_conn.prepareStatement(sSql);
                
                int serverId = MedwanQuery.getInstance().getConfigInt("serverId"),
                    objectId = MedwanQuery.getInstance().getOpenclinicCounter("HR_SALARY");
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
    
                ps.setFloat(psIdx++,salary);
                ps.setString(psIdx++,salaryPeriod);

                // xmls
                ps.setString(psIdx++,benefits);
                ps.setString(psIdx++,bonuses);
                ps.setString(psIdx++,otherIncome);
                ps.setString(psIdx++,deductions);
                
                ps.setString(psIdx++,comment.replaceAll("\\'","´").replaceAll("\"","´"));
                ps.setTimestamp(psIdx++,new Timestamp(new java.util.Date().getTime())); // now
                ps.setString(psIdx,userUid);
                
                ps.executeUpdate();
            } 
            else{
                // update existing record
                sSql = "UPDATE hr_salaries SET"+
                       "  HR_SALARY_CONTRACTUID = ?, HR_SALARY_BEGINDATE = ?, HR_SALARY_ENDDATE = ?, HR_SALARY_SALARY = ?,"+
                       "  HR_SALARY_SALARYPERIOD = ?, HR_SALARY_BENEFITS = ?, HR_SALARY_BONUSES = ?, HR_SALARY_OTHERINCOME = ?,"+
                       "  HR_SALARY_DEDUCTIONS = ?, HR_SALARY_COMMENT = ?,"+
                       "  HR_SALARY_UPDATETIME = ?, HR_SALARY_UPDATEID = ?"+ // update-info
                       " WHERE (HR_SALARY_SERVERID = ? AND HR_SALARY_OBJECTID = ?)"; // identification
                ps = oc_conn.prepareStatement(sSql);

                int psIdx = 1;
                ps.setString(psIdx++,contractUid);
                ps.setDate(psIdx++,new java.sql.Date(begin.getTime()));
                
                // end date might be unspecified
                if(end!=null){
                    ps.setDate(psIdx++,new java.sql.Date(end.getTime()));
                }
                else{
                    ps.setDate(psIdx++,null);
                }

                ps.setFloat(psIdx++,salary);
                ps.setString(psIdx++,salaryPeriod);

                // xmls
                ps.setString(psIdx++,benefits);
                ps.setString(psIdx++,bonuses);
                ps.setString(psIdx++,otherIncome);
                ps.setString(psIdx++,deductions);
                
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
    public static boolean delete(String sCareerUid){
    	boolean errorOccurred = false;
        PreparedStatement ps = null;
        ResultSet rs = null;
        
        Connection oc_conn = MedwanQuery.getInstance().getOpenclinicConnection();
        
        try{
            String sSql = "DELETE FROM hr_salaries"+
                          " WHERE (HR_SALARY_SERVERID = ? AND HR_SALARY_OBJECTID = ?)";
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
    public static Salary get(Salary salary){
    	return get(salary.getUid());
    }
       
    public static Salary get(String sCareerUid){
    	Salary salary = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        
        Connection oc_conn = MedwanQuery.getInstance().getOpenclinicConnection();
        
        try{
            String sSql = "SELECT * FROM hr_salaries"+
                          " WHERE (HR_SALARY_SERVERID = ? AND HR_SALARY_OBJECTID = ?)";
            ps = oc_conn.prepareStatement(sSql);
            ps.setInt(1,Integer.parseInt(sCareerUid.substring(0,sCareerUid.indexOf("."))));
            ps.setInt(2,Integer.parseInt(sCareerUid.substring(sCareerUid.indexOf(".")+1)));

            // execute
            rs = ps.executeQuery();
            if(rs.next()){
                salary = new Salary();
                salary.setUid(rs.getString("HR_SALARY_SERVERID")+"."+rs.getString("HR_SALARY_OBJECTID"));

                salary.personId     = rs.getInt("HR_SALARY_PERSONID");
                salary.contractUid  = ScreenHelper.checkString(rs.getString("HR_SALARY_CONTRACTUID"));
                salary.begin        = rs.getDate("HR_SALARY_BEGINDATE");
                salary.end          = rs.getDate("HR_SALARY_ENDDATE");
                salary.salary       = rs.getFloat("HR_SALARY_SALARY");
                salary.salaryPeriod = ScreenHelper.checkString(rs.getString("HR_SALARY_SALARYPERIOD"));

                // xmls
                salary.benefits     = ScreenHelper.checkString(rs.getString("HR_SALARY_BENEFITS"));
                salary.bonuses      = ScreenHelper.checkString(rs.getString("HR_SALARY_BONUSES"));
                salary.otherIncome  = ScreenHelper.checkString(rs.getString("HR_SALARY_OTHERINCOME"));
                salary.deductions   = ScreenHelper.checkString(rs.getString("HR_SALARY_DEDUCTIONS"));
                
                salary.comment      = ScreenHelper.checkString(rs.getString("HR_SALARY_COMMENT")); 
                
                // parent
                salary.setUpdateDateTime(rs.getTimestamp("HR_SALARY_UPDATETIME"));
                salary.setUpdateUser(rs.getString("HR_SALARY_UPDATEID"));
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
        
        return salary;
    }
        
    //--- GET LIST --------------------------------------------------------------------------------
    public static List<Salary> getList(){
    	return getList(new Salary());     	
    }
    
    public static List<Salary> getList(Salary findItem){
        List<Salary> foundObjects = new LinkedList();
        PreparedStatement ps = null;
        ResultSet rs = null;
        
        Connection oc_conn = MedwanQuery.getInstance().getOpenclinicConnection();
        
        try{
        	// compose query
            String sSql = "SELECT * FROM hr_salaries WHERE 1=1"; // 'where' facilitates further composition of query

            if(findItem.personId > -1){
                sSql+= " AND HR_SALARY_PERSONID = "+findItem.personId;
            }
			if(ScreenHelper.checkString(findItem.contractUid).length() > 0){
			    sSql+= " AND HR_SALARY_CONTRACTUID = '"+findItem.contractUid+"'";
			}
			if(findItem.begin!=null){
			    sSql+= " AND HR_SALARY_BEGINDATE = '"+ScreenHelper.stdDateFormat.format(findItem.begin)+"'";
			}
			if(findItem.end!=null){
			    sSql+= " AND HR_SALARY_ENDDATE = '"+ScreenHelper.stdDateFormat.format(findItem.end)+"'";
			}
            if(findItem.salary > 0){
                sSql+= " AND HR_SALARY_SALARY = "+findItem.salary;
            }
            if(ScreenHelper.checkString(findItem.salaryPeriod).length() > 0){
                sSql+= " AND HR_SALARY_SALARYPERIOD = '"+findItem.salaryPeriod+"'";
            }
            if(ScreenHelper.checkString(findItem.comment).length() > 0){
                sSql+= " AND HR_SALARY_COMMENT LIKE '%"+findItem.comment+"%'";
            }
            sSql+= " ORDER BY HR_SALARY_BEGINDATE ASC";
            
            ps = oc_conn.prepareStatement(sSql);
            
            // execute query
            rs = ps.executeQuery();
            Salary item;
            
            while(rs.next()){
                item = new Salary();                
                item.setUid(rs.getString("HR_SALARY_SERVERID")+"."+rs.getString("HR_SALARY_OBJECTID"));

                item.personId     = rs.getInt("HR_SALARY_PERSONID");
                item.contractUid  = ScreenHelper.checkString(rs.getString("HR_SALARY_CONTRACTUID"));
                item.begin        = rs.getDate("HR_SALARY_BEGINDATE");
                item.end          = rs.getDate("HR_SALARY_ENDDATE");
                item.salary       = rs.getFloat("HR_SALARY_SALARY");
                item.salaryPeriod = ScreenHelper.checkString(rs.getString("HR_SALARY_SALARYPERIOD"));
                
                // xmls
                item.benefits     = ScreenHelper.checkString(rs.getString("HR_SALARY_BENEFITS"));
                item.bonuses      = ScreenHelper.checkString(rs.getString("HR_SALARY_BONUSES"));
                item.otherIncome  = ScreenHelper.checkString(rs.getString("HR_SALARY_OTHERINCOME"));
                item.deductions   = ScreenHelper.checkString(rs.getString("HR_SALARY_DEDUCTIONS"));
                
                item.comment      = ScreenHelper.checkString(rs.getString("HR_SALARY_COMMENT")); 
                                
                // parent
                item.setUpdateDateTime(rs.getTimestamp("HR_SALARY_UPDATETIME"));
                item.setUpdateUser(rs.getString("HR_SALARY_UPDATEID"));
                
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
