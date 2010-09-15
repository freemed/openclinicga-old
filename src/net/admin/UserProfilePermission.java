package net.admin;

import be.mxs.common.util.db.MedwanQuery;
import be.mxs.common.util.system.ScreenHelper;

import java.sql.Connection;
import java.sql.Timestamp;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.Vector;

/**
 * Created by IntelliJ IDEA.
 * User: mxs-rudy
 * Date: 14-mrt-2007
 * Time: 10:51:05
 * To change this template use File | Settings | File Templates.
 */
public class UserProfilePermission {
    private int userprofileid;
    private String screenid;
    private String permission;
    private int active;
    private Timestamp updatetime;


    public int getUserprofileid() {
        return userprofileid;
    }

    public void setUserprofileid(int userprofileid) {
        this.userprofileid = userprofileid;
    }

    public String getScreenid() {
        return screenid;
    }

    public void setScreenid(String screenid) {
        this.screenid = screenid;
    }

    public String getPermission() {
        return permission;
    }

    public void setPermission(String permission) {
        this.permission = permission;
    }

    public int getActive() {
        return active;
    }

    public void setActive(int active) {
        this.active = active;
    }

    public Timestamp getUpdatetime() {
        return updatetime;
    }

    public void setUpdatetime(Timestamp updatetime) {
        this.updatetime = updatetime;
    }

    public static boolean activeUserProfilePermissions(String userprofileid, String screenid, String sPermission){
        PreparedStatement ps = null;
        ResultSet rs = null;

        boolean bActive = false;

        String sSelect = " SELECT permission FROM UserProfilePermissions" +
                         " WHERE userprofileid = ? AND screenid = ? AND permission = ? AND active = 1";

    	Connection ad_conn = MedwanQuery.getInstance().getAdminConnection();
        try{
            ps = ad_conn.prepareStatement(sSelect);
            ps.setInt(1,Integer.parseInt(userprofileid));
            ps.setString(2,screenid);
            ps.setString(3,sPermission);

            rs = ps.executeQuery();

            if(rs.next()){
                bActive = true;
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
        return bActive;
    }
    public static Vector getActiveUserProfilePermissions(String userprofileid,String screenid){
        PreparedStatement ps = null;
        ResultSet rs = null;

        Vector vPermissions = new Vector();

        String sSelect = " SELECT permission FROM UserProfilePermissions" +
                         " WHERE userprofileid = ? AND screenid = ? AND active = 1";

    	Connection ad_conn = MedwanQuery.getInstance().getAdminConnection();
        try{
            ps = ad_conn.prepareStatement(sSelect);
            ps.setInt(1,Integer.parseInt(userprofileid));
            ps.setString(2,screenid);

            rs = ps.executeQuery();

            String sPermission;

            while(rs.next()){
                sPermission = ScreenHelper.checkString(rs.getString("permission"));
                vPermissions.addElement(sPermission);
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
        return vPermissions;
    }

    public void setNonActiveProfilePermission(){
        PreparedStatement ps = null;

        String sUpdate = "UPDATE UserProfilePermissions SET active = 0, updatetime = ? WHERE userprofileid = ?";

    	Connection ad_conn = MedwanQuery.getInstance().getAdminConnection();
        try{
            ps = ad_conn.prepareStatement(sUpdate);
            ps.setTimestamp(1,this.updatetime);
            ps.setInt(2,this.userprofileid);
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

    public int setActiveProfilePermission(){
        PreparedStatement ps = null;

        String sUpdate = " UPDATE UserProfilePermissions SET active = 1"+
                         " WHERE userprofileid = ? AND screenid = ? AND permission = ?";

        int updatedRows = 0;
    	Connection ad_conn = MedwanQuery.getInstance().getAdminConnection();
        try{
            ps = ad_conn.prepareStatement(sUpdate);
            ps.setInt(1,this.userprofileid);
            ps.setString(2,this.screenid);
            ps.setString(3,this.permission);

            updatedRows = ps.executeUpdate();

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
        return updatedRows;
    }

    public void insert(){
        PreparedStatement ps = null;

        String sInsert = "INSERT INTO UserProfilePermissions (userprofileid, screenid, permission, active, updatetime) VALUES (?, ?, ?, 1, ?)";

    	Connection ad_conn = MedwanQuery.getInstance().getAdminConnection();
        try{
            ps = ad_conn.prepareStatement(sInsert);
            ps.setInt(1,this.getUserprofileid());
            ps.setString(2,this.getScreenid());
            ps.setString(3, this.getPermission());
            ps.setTimestamp(4,this.getUpdatetime());
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

    public void deleteByScreenAndId(){
        PreparedStatement ps = null;

        String sDelete = "DELETE FROM UserProfilePermissions WHERE userprofileid = ?"+
                              "  AND screenid = ?";

    	Connection ad_conn = MedwanQuery.getInstance().getAdminConnection();
        try{
            ps = ad_conn.prepareStatement(sDelete);
            ps.setInt(1,this.getUserprofileid());
            ps.setString(2,this.getScreenid());
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
