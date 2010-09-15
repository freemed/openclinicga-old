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
 * Date: 19-feb-2007
 * Time: 16:57:48
 * To change this template use File | Settings | File Templates.
 */
public class UserService {
    private int userid;
    private String serviceid;
    private Timestamp updatetime;
    private int activeservice;


    public int getUserid() {
        return userid;
    }

    public void setUserid(int userid) {
        this.userid = userid;
    }

    public String getServiceid() {
        return serviceid;
    }

    public void setServiceid(String serviceid) {
        this.serviceid = serviceid;
    }

    public Timestamp getUpdatetime() {
        return updatetime;
    }

    public void setUpdatetime(Timestamp updatetime) {
        this.updatetime = updatetime;
    }

    public int getActiveservice() {
        return activeservice;
    }

    public void setActiveservice(int activeservice) {
        this.activeservice = activeservice;
    }

    public static boolean exists(String userid, String serviceid){
        PreparedStatement ps = null;
        ResultSet rs = null;

        boolean bExists = false;

        String sSelect = "SELECT serviceid FROM UserServices WHERE userid = ? AND serviceid = ?";

    	Connection ad_conn = MedwanQuery.getInstance().getAdminConnection();
        try{
            ps = ad_conn.prepareStatement(sSelect);
            ps.setInt(1,Integer.parseInt(userid));
            ps.setString(2,serviceid);
            rs = ps.executeQuery();

            if(rs.next()){
                bExists = true;
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
        return bExists;
    }

    public void saveToDB(){
        PreparedStatement ps = null;

        String sInsert = "INSERT INTO UserServices (userid, updatetime, serviceid,activeservice) VALUES (?,?,?,?)";

    	Connection ad_conn = MedwanQuery.getInstance().getAdminConnection();
        try{
            ps = ad_conn.prepareStatement(sInsert);
            ps.setInt(1,this.getUserid());
            ps.setTimestamp(2, ScreenHelper.getSQLTime());
            ps.setString(3,this.getServiceid());
            ps.setInt(4,this.getActiveservice());
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

    public void update(){
        this.deactivateService();
        PreparedStatement ps = null;

        String sUpdate = "UPDATE UserServices SET updatetime=?, activeservice=? WHERE userid=? AND serviceid=?";

    	Connection ad_conn = MedwanQuery.getInstance().getAdminConnection();
        try{
            ps = ad_conn.prepareStatement(sUpdate);
            ps.setTimestamp(1,ScreenHelper.getSQLTime());
            ps.setInt(2,this.getActiveservice());
            ps.setInt(3,this.getUserid());
            ps.setString(4,this.getServiceid());
            
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

    private void deactivateService(){
        PreparedStatement ps = null;

        String sUpdate = "UPDATE UserServices SET activeservice = 0 WHERE userid = ?";

    	Connection ad_conn = MedwanQuery.getInstance().getAdminConnection();
        try{
            ps = ad_conn.prepareStatement(sUpdate);
            ps.setInt(1,this.userid);
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

    public void delete(){
        PreparedStatement ps = null;
        String sDelete = "DELETE FROM UserServices WHERE userid = ? AND serviceid = ?";

    	Connection ad_conn = MedwanQuery.getInstance().getAdminConnection();
        try{
            ps = ad_conn.prepareStatement(sDelete);
            ps.setInt(1,this.userid);
            ps.setString(2,this.getServiceid());
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
