package net.admin.system;

import be.mxs.common.util.db.MedwanQuery;
import be.mxs.common.util.system.ScreenHelper;

import java.sql.Connection;
import java.sql.Timestamp;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.Vector;

/**
 * Created by IntelliJ IDEA.
 * User: mxs_david
 * Date: 5-jan-2007
 * Time: 16:12:54
 * To change this template use Options | File Templates.
 */
public class IntrusionAttempt {
    private String intruderID;
    private int intrusionCount;
    private String blocked;
    private Timestamp releaseTime;


    public String getIntruderID() {
        return intruderID;
    }

    public void setIntruderID(String intruderID) {
        this.intruderID = intruderID;
    }

    public int getIntrusionCount() {
        return intrusionCount;
    }

    public void setIntrusionCount(int intrusionCount) {
        this.intrusionCount = intrusionCount;
    }

    public String getBlocked() {
        return blocked;
    }

    public void setBlocked(String blocked) {
        this.blocked = blocked;
    }

    public Timestamp getReleaseTime() {
        return releaseTime;
    }

    public void setReleaseTime(Timestamp releaseTime) {
        this.releaseTime = releaseTime;
    }

    public static void saveIntrusionAttempt(IntrusionAttempt objIA){
        PreparedStatement ps = null;

        String sUpdate = "UPDATE intrusionAttempts SET intrusionCount = ?, blocked = ? WHERE intruderID = ?";

    	Connection ad_conn = MedwanQuery.getInstance().getAdminConnection();
        try{
            ps = ad_conn.prepareStatement(sUpdate);
            ps.setInt(1,objIA.getIntrusionCount());
            ps.setString(2,objIA.getBlocked());
            ps.setString(3,objIA.getIntruderID());

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

    public static void deleteIntrusionAttempt(String sIntruderID){
        PreparedStatement ps = null;

        String sDelete = "DELETE FROM intrusionAttempts WHERE intruderID = ?";

    	Connection ad_conn = MedwanQuery.getInstance().getAdminConnection();
        try{
            ps = ad_conn.prepareStatement(sDelete);
            ps.setString(1,sIntruderID);

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

    public static void unblockAccount(String sIntruderID,String sLogin,String sIP){
        PreparedStatement ps = null;

        String sDelete = "DELETE FROM intrusionAttempts WHERE intruderID = ?";

    	Connection ad_conn = MedwanQuery.getInstance().getAdminConnection();
        try{
            if(sLogin.length() > 0 && sIP.length() > 0) sDelete+= " OR intruderID = ?";
            ps = ad_conn.prepareStatement(sDelete);
            ps.setString(1,sIntruderID);
            if(sLogin.length() > 0 && sIP.length() > 0) ps.setString(2,sIP);
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

    public static Vector selectNonIPIntrusionAttempts(){
        PreparedStatement ps = null;
        ResultSet rs = null;

        Vector vIA = new Vector();
        IntrusionAttempt objIA;

        String sSelect = " SELECT * FROM intrusionAttempts"+
                         " WHERE intruderID NOT LIKE '%.%.%.%'"+
                         " ORDER BY intruderID";

    	Connection ad_conn = MedwanQuery.getInstance().getAdminConnection();
        try{
            ps = ad_conn.prepareStatement(sSelect);

            rs = ps.executeQuery();

            while(rs.next()){
                objIA = new IntrusionAttempt();
                objIA.setIntruderID(ScreenHelper.checkString(rs.getString("intruderID")));
                objIA.setIntrusionCount(rs.getInt("intrusionCount"));
                objIA.setBlocked(ScreenHelper.checkString(rs.getString("blocked")));
                objIA.setReleaseTime(rs.getTimestamp("releasetime"));

                vIA.addElement(objIA);
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

        return vIA;
    }

    public static Vector selectIPIntrusionAttempts(){
        PreparedStatement ps = null;
        ResultSet rs = null;

        Vector vIA = new Vector();
        IntrusionAttempt objIA;

        String sSelect = " SELECT * FROM intrusionAttempts"+
                         " WHERE intruderID LIKE '%.%.%.%'"+
                         " ORDER BY intruderID";

    	Connection ad_conn = MedwanQuery.getInstance().getAdminConnection();
        try{
            ps = ad_conn.prepareStatement(sSelect);

            rs = ps.executeQuery();

            while(rs.next()){
                objIA = new IntrusionAttempt();
                objIA.setIntruderID(ScreenHelper.checkString(rs.getString("intruderID")));
                objIA.setIntrusionCount(rs.getInt("intrusionCount"));
                objIA.setBlocked(ScreenHelper.checkString(rs.getString("blocked")));
                objIA.setReleaseTime(rs.getTimestamp("releasetime"));

                vIA.addElement(objIA);
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

        return vIA;
    }
}
