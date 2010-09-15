package net.admin;

import be.mxs.common.util.db.MedwanQuery;
import be.mxs.common.util.system.ScreenHelper;

import java.sql.Connection;
import java.sql.Timestamp;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

/**
 * Created by IntelliJ IDEA.
 * User: mxs-rudy
 * Date: 16-mrt-2007
 * Time: 17:59:14
 * To change this template use File | Settings | File Templates.
 */
public class UserProfileMotivation {
    private int userid;
    private int patientid;
    private Timestamp updatetime;
    private String motivation;
    private String screenid;


    public int getUserid() {
        return userid;
    }

    public void setUserid(int userid) {
        this.userid = userid;
    }

    public int getPatientid() {
        return patientid;
    }

    public void setPatientid(int patientid) {
        this.patientid = patientid;
    }

    public Timestamp getUpdatetime() {
        return updatetime;
    }

    public void setUpdatetime(Timestamp updatetime) {
        this.updatetime = updatetime;
    }

    public String getMotivation() {
        return motivation;
    }

    public void setMotivation(String motivation) {
        this.motivation = motivation;
    }

    public String getScreenid() {
        return screenid;
    }

    public void setScreenid(String screenid) {
        this.screenid = screenid;
    }

    public static String getMotivation(String sUserid, String sPatientid){
        PreparedStatement ps = null;
        ResultSet rs = null;

        String sSelect = "SELECT motivation FROM UserProfileMotivations WHERE userid = ?"
          +" AND patientid = ? AND motivation <> 'empty' "
          +" AND motivation <> '' ORDER BY updatetime DESC";

        String sMotivation = "";

    	Connection ad_conn = MedwanQuery.getInstance().getAdminConnection();
        try{
            ps = ad_conn.prepareStatement(sSelect);
            ps.setString(1,sUserid);
            ps.setString(2,sPatientid);
            rs = ps.executeQuery();
            if (rs.next())
            {
                sMotivation = ScreenHelper.checkString(rs.getString("motivation"));
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
        return sMotivation;
    }

    public void insert(){
        PreparedStatement ps = null;

        String sInsert = "INSERT INTO UserProfileMotivations (userid, patientid, updatetime, motivation, screenid) VALUES (?,?,?,?,?)";        

    	Connection ad_conn = MedwanQuery.getInstance().getAdminConnection();
        try{
            ps = ad_conn.prepareStatement(sInsert);
            ps.setInt(1,this.getUserid());
            ps.setInt(2,this.getPatientid());
            ps.setTimestamp(3,this.getUpdatetime());
            ps.setString(4,this.getMotivation());
            ps.setString(5,this.getScreenid());
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

    public static void update(String sUserid,String sPatientId, String sMotivation,String sScreenId,String sOldMotivation){
        PreparedStatement ps = null;

        String sUpdate = "UPDATE UserProfileMotivations SET motivation = ? WHERE userid = ? AND patientid = ? AND screenid = ? AND motivation = ?"; 

    	Connection ad_conn = MedwanQuery.getInstance().getAdminConnection();
        try{
            ps = ad_conn.prepareStatement(sUpdate);
            ps.setString(1,sMotivation);
            ps.setInt(2,Integer.parseInt(sUserid));
            ps.setInt(3,Integer.parseInt(sPatientId));
            ps.setString(4,sScreenId);
            ps.setString(5,sOldMotivation);
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
}


