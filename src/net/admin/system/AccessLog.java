package net.admin.system;

import be.mxs.common.util.db.MedwanQuery;
import be.mxs.common.util.system.ScreenHelper;

import java.sql.Connection;
import java.sql.Timestamp;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.Vector;
import java.util.List;
import java.util.LinkedList;
public class AccessLog {

    private int accessid;
    private int userid;
    private Timestamp accesstime;
    private String lastname;
    private String firstname;

    public int getAccessid() {
        return accessid;
    }

    public void setAccessid(int accessid) {
        this.accessid = accessid;
    }

    public int getUserid() {
        return userid;
    }

    public void setUserid(int userid) {
        this.userid = userid;
    }

    public Timestamp getAccesstime() {
        return accesstime;
    }

    public void setAccesstime(Timestamp accesstime) {
        this.accesstime = accesstime;
    }

    public String getLastname() {
        return lastname;
    }

    public void setLastname(String lastname) {
        this.lastname = lastname;
    }

    public String getFirstname() {
        return firstname;
    }

    public void setFirstname(String firstname) {
        this.firstname = firstname;
    }


    public static Vector searchAccessLogs(String sFindBegin, String sFindEnd){
        PreparedStatement ps = null;
        ResultSet rs = null;

        Vector vAL = new Vector();

        String sSelect;
        String sSelect1 = " SELECT a.accessid, a.accesstime, b.lastname, b.firstname FROM AccessLogs a, Users u, Admin b WHERE "
                        + " a.accesstime BETWEEN ? AND ? AND u.userid = a.userid AND b.personid = u.personid "
                        + " ORDER BY a.accesstime, b.searchname ";
        String sSelect2 = " SELECT a.accessid, a.accesstime, b.lastname, b.firstname FROM AccessLogs a, Users u, Admin b WHERE "
                        +  " a.accesstime >= ? AND u.userid = a.userid AND b.personid = u.personid "
                        +  " ORDER BY a.accesstime, b.searchname ";
        String sSelect3 = " SELECT a.accessid, a.accesstime, b.lastname, b.firstname FROM AccessLogs a, Users u, Admin b WHERE "
                        + " a.accesstime <= ? AND u.userid = a.userid AND b.personid = u.personid "
                        + " ORDER BY a.accesstime, b.searchname ";


    	Connection ad_conn = MedwanQuery.getInstance().getAdminConnection();
    	try{
            if ((sFindBegin.trim().length()>0)&&(sFindEnd.trim().length()>0)){
                sSelect = sSelect1;
                ps = ad_conn.prepareStatement(sSelect);
                ps.setDate(1,ScreenHelper.getSQLDate(sFindBegin));
                ps.setDate(2,ScreenHelper.getSQLDate(ScreenHelper.getDateAdd(sFindEnd, "1")));
            }
            else if (sFindBegin.trim().length()>0){
                sSelect = sSelect2;
                ps = ad_conn.prepareStatement(sSelect);
                ps.setDate(1,ScreenHelper.getSQLDate(sFindBegin));
            }
            else if (sFindEnd.trim().length()>0){
                sSelect = sSelect3;
                ps = ad_conn.prepareStatement(sSelect);
                ps.setDate(1,ScreenHelper.getSQLDate(ScreenHelper.getDateAdd(sFindEnd, "1")));
            }

            rs = ps.executeQuery();
            AccessLog objAL;
            while(rs.next()){
                objAL = new AccessLog();
                objAL.setAccessid(rs.getInt("accessid"));
                objAL.setLastname(ScreenHelper.checkString(rs.getString("lastname")));
                objAL.setFirstname(ScreenHelper.checkString(rs.getString("firstname")));
                objAL.setAccesstime(rs.getTimestamp("accesstime"));

                vAL.addElement(objAL);
            }
            rs.close();
            ps.close();
        }catch(Exception e){
            e.printStackTrace();
        }finally{
            try{
                if(rs!=null)rs.close();
                if(ps!=null)ps.close();
                ad_conn.close();
            }catch(Exception e){
                e.printStackTrace();
            }
        }

        return vAL;

    }

    public static void logAccess(AccessLog objAL){
        PreparedStatement ps = null;

        String sInsert = "INSERT INTO AccessLogs (accessid, userid, accesstime) VALUES (?, ?, ?)";

    	Connection ad_conn = MedwanQuery.getInstance().getAdminConnection();
        try{
            ps = ad_conn.prepareStatement(sInsert);
            ps.setInt(1,MedwanQuery.getInstance().getCounter("AccessLogs"));
            ps.setInt(2,objAL.getUserid());
            ps.setTimestamp(3,objAL.getAccesstime());
            ps.execute();
            ps.close();
        }catch(Exception e){
            e.printStackTrace();
        }finally{
            try{
                if(ps!=null)ps.close();
                ad_conn.close();
            }catch(Exception e){
                e.printStackTrace();
            }
        }
    }

    public static void insert(String sUserID){
        PreparedStatement ps = null;

        String sInsert = "INSERT INTO AccessLogs (accessid, userid, accesstime) VALUES (?, ?, ?)";

    	Connection ad_conn = MedwanQuery.getInstance().getAdminConnection();
        try{
            ps = ad_conn.prepareStatement(sInsert);
            ps.setInt(1,MedwanQuery.getInstance().getCounter("AccessLogs"));
            ps.setInt(2,Integer.parseInt(sUserID));
            ps.setTimestamp(3,ScreenHelper.getSQLTime());
            ps.executeUpdate();
            ps.close();
        }catch(Exception e){
            e.printStackTrace();
        }finally{
            try{
                if(ps!=null)ps.close();
                ad_conn.close();
            }catch(Exception e){
                e.printStackTrace();
            }
        }
    }
    public static void insert(String sUserID,String accessCode){
        PreparedStatement ps = null;

        String sInsert = "INSERT INTO AccessLogs (accessid, userid, accesstime,accesscode) VALUES (?, ?, ?,?)";

    	Connection ad_conn = MedwanQuery.getInstance().getAdminConnection();
        try{
            ps = ad_conn.prepareStatement(sInsert);
            ps.setInt(1,MedwanQuery.getInstance().getCounter("AccessLogs"));
            ps.setInt(2,Integer.parseInt(sUserID));
            ps.setTimestamp(3,ScreenHelper.getSQLTime());
            ps.setString(4,accessCode);
            ps.executeUpdate();
            ps.close();
        }catch(Exception e){
            e.printStackTrace();
        }finally{
            try{
                if(ps!=null)ps.close();
                ad_conn.close();
            }catch(Exception e){
                e.printStackTrace();
            }
        }
    }
    public static List getLastAccess(String patientId,int nb){
            PreparedStatement ps = null;
            ResultSet rs = null;
            List l = new LinkedList();
            String sSelect = " SELECT * FROM AccessLogs a WHERE accesscode = ? ORDER BY accessid DESC";

        	Connection ad_conn = MedwanQuery.getInstance().getAdminConnection();
            try{
                ps = ad_conn.prepareStatement(sSelect);
                ps.setString(1,patientId);


                rs = ps.executeQuery();
                int i = 0;
                while(rs.next()){
                    if(nb==0 || i<=nb){
                        Object sReturn[] = {rs.getTimestamp("accesstime"),rs.getString("userid")};
                        l.add(sReturn);
                    }
                    i++;
                }
                rs.close();
                ps.close();
            }catch(Exception e){
                e.printStackTrace();
            }finally{
                try{
                    if(rs!=null)rs.close();
                    if(ps!=null)ps.close();
                    ad_conn.close();
                }catch(Exception e){
                    e.printStackTrace();
                }
            }
            return l;
        }

    public static Vector getAccessTimes(java.sql.Date dBegin,java.sql.Date dEnd,int iUserId){
        PreparedStatement ps = null;
        ResultSet rs = null;

        Vector vAccessTimes = new Vector();

        String sSelect = " SELECT a.accesstime FROM AccessLogs a WHERE a.accesstime BETWEEN ? AND ? AND userid = ?";

    	Connection ad_conn = MedwanQuery.getInstance().getAdminConnection();
        try{
            ps = ad_conn.prepareStatement(sSelect);
            ps.setDate(1,dBegin);
            ps.setDate(2,dEnd);
            ps.setInt(3,iUserId);

            rs = ps.executeQuery();

            while(rs.next()){
                vAccessTimes.addElement(rs.getDate("accesstime"));
            }
            rs.close();
            ps.close();
        }catch(Exception e){
            e.printStackTrace();
        }finally{
            try{
                if(rs!=null)rs.close();
                if(ps!=null)ps.close();
                ad_conn.close();
            }catch(Exception e){
                e.printStackTrace();
            }
        }
        return vAccessTimes;
    }

    public static void delete(String sAccessId){
        PreparedStatement ps = null;

    	Connection ad_conn = MedwanQuery.getInstance().getAdminConnection();
        try{
            String sQuery = "DELETE FROM AccessLogs WHERE accessid = ?";
            ps = ad_conn.prepareStatement(sQuery);
            ps.setString(1,sAccessId);
            ps.executeUpdate();
        }catch(Exception e){
            e.printStackTrace();
        }finally{
            try{
                if(ps!=null)ps.close();
                ad_conn.close();
            }catch(Exception e){
                e.printStackTrace();
            }
        }
    }

    public static void delete(java.util.Date delFromDate, java.util.Date delUntilDate){
        PreparedStatement ps = null;
        ResultSet rs = null;

        // compose query to retreive accessIds in interval
        String sQuery = "SELECT accessid FROM AccessLogs l, UsersView u, AdminView a ";

        if(delFromDate!=null && delUntilDate!=null){
            sQuery+= "WHERE l.accesstime BETWEEN ? AND ? ";
        }
        else if(delFromDate!=null){
            sQuery+= "WHERE l.accesstime >= ? ";
        }
        else if(delUntilDate!=null){
            sQuery+= "WHERE l.accesstime < ? ";
        }

        int questionMarkIdx = 1;
        sQuery+= "AND u.userid = l.userid "+
                 "AND a.personid = u.personid";

        StringBuffer accessIds = new StringBuffer();

    	Connection ad_conn = MedwanQuery.getInstance().getAdminConnection();
        try{
            ps = ad_conn.prepareStatement(sQuery);

            if(delFromDate!=null) ps.setDate(questionMarkIdx++,new java.sql.Date(delFromDate.getTime()));
            if(delUntilDate!=null) ps.setDate(questionMarkIdx,new java.sql.Date(delUntilDate.getTime()));

            int id;
            rs = ps.executeQuery();
            while(rs.next()){
                id = rs.getInt("accessid");
                if(id > 0){
                    accessIds.append("'").append(id).append("',");
                }
            }
        }catch(Exception e){
            e.printStackTrace();
        }finally{
            try{
                if(ps!=null)ps.close();
                if(rs!=null)rs.close();
            }catch(Exception e){
                e.printStackTrace();
            }
        }

        //*** delete accesss specified by accessIds-string ***
        try{
            if(accessIds.length() > 0){
                // remove last comma
                if(accessIds.toString().indexOf(",") > 0){
                    accessIds = accessIds.deleteCharAt(accessIds.length()-1);
                }

                // delete records
                sQuery = "DELETE FROM AccessLogs WHERE accessid IN ("+accessIds+")";
                ps = ad_conn.prepareStatement(sQuery);
                ps.executeUpdate();
            }
        }catch(Exception e){
            e.printStackTrace();
        }finally{
            try{
                if(ps!=null)ps.close();
                ad_conn.close();
            }catch(Exception e){
                e.printStackTrace();
            }
        }
    }

}
