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
 * Date: 19-feb-2007
 * Time: 16:32:04
 * To change this template use File | Settings | File Templates.
 */
public class UserParameter {
    private int userid;
    private String parameter;
    private String value;
    private Timestamp updatetime;
    private int active;


    public int getUserid() {
        return userid;
    }

    public void setUserid(int userid) {
        this.userid = userid;
    }

    public String getParameter() {
        return parameter;
    }

    public void setParameter(String parameter) {
        this.parameter = parameter;
    }

    public String getValue() {
        return value;
    }

    public void setValue(String value) {
        this.value = value;
    }

    public Timestamp getUpdatetime() {
        return updatetime;
    }

    public void setUpdatetime(Timestamp updatetime) {
        this.updatetime = updatetime;
    }

    public int getActive() {
        return active;
    }

    public void setActive(int active) {
        this.active = active;
    }

    public static void saveUserParameter(Parameter parameter, int userid){
        PreparedStatement ps = null,ps2 = null;

        String sUpdate = "UPDATE UserParametersView SET active = 1"+
                          " WHERE userid = ? AND parameter = ? AND myvalue = ?";

    	Connection ad_conn = MedwanQuery.getInstance().getAdminConnection();
        try{
            ps = ad_conn.prepareStatement(sUpdate);
            ps.setInt(1,userid);
            ps.setString(2,parameter.parameter);
            ps.setString(3,parameter.value);

            if (ps.executeUpdate()==0) {
                String sInsert = "INSERT INTO UserParameters VALUES (?,?,?,?,1)";
                ps2 = ad_conn.prepareStatement(sInsert);
                ps2.setInt(1,userid);
                ps2.setString(2,parameter.parameter);
                ps2.setString(3,parameter.value);
                ps2.setTimestamp(4, ScreenHelper.getSQLTime());
                ps2.executeUpdate();
                ps2.close();
            }
            ps.close();

        }catch(Exception e){
            e.printStackTrace();
        }finally{
            try{
                if(ps!=null)ps.close();
                if(ps2!=null)ps.close();
                ad_conn.close();
            }catch(Exception e){
                e.printStackTrace();
            }
        }
    }

    public static void saveUserParameter(String parameter, String value, int userid){
        PreparedStatement ps = null,ps2 = null;

        String sUpdate = "UPDATE UserParametersView SET active = 1"+
                          " WHERE userid = ? AND parameter = ? AND myvalue = ?";

    	Connection ad_conn = MedwanQuery.getInstance().getAdminConnection();
        try{
            ps = ad_conn.prepareStatement(sUpdate);
            ps.setInt(1,userid);
            ps.setString(2,parameter);
            ps.setString(3,value);

            if (ps.executeUpdate()==0) {
                String sInsert = "INSERT INTO UserParameters VALUES (?,?,?,?,1)";
                ps2 = ad_conn.prepareStatement(sInsert);
                ps2.setInt(1,userid);
                ps2.setString(2,parameter);
                ps2.setString(3,value);
                ps2.setTimestamp(4, ScreenHelper.getSQLTime());
                ps2.executeUpdate();
                ps2.close();
            }
            ps.close();

        }catch(Exception e){
            e.printStackTrace();
        }finally{
            try{
                if(ps!=null)ps.close();
                if(ps2!=null)ps.close();
                ad_conn.close();
            }catch(Exception e){
                e.printStackTrace();
            }
        }
    }

    public static void updateParameter(String parameter, String value, String oldValue){
        PreparedStatement ps = null;
        
        String sUpdate = " UPDATE UserParametersView SET myvalue = ?, updatetime = ?" +
                         " WHERE parameter = 'favorite' AND myvalue = ?";

    	Connection ad_conn = MedwanQuery.getInstance().getAdminConnection();
        try{
            ps = ad_conn.prepareStatement(sUpdate);
            ps.setString(1, value);
            ps.setTimestamp(2, ScreenHelper.getSQLTime()); // NOW
            ps.setString(3, parameter);
            ps.setString(4,oldValue);
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

    public static void deleteUserParameter(Parameter parameter){
        PreparedStatement ps = null;

        String sUpdate = "UPDATE UserParametersView SET active = 0 WHERE parameter = ? AND myvalue = ?";

    	Connection ad_conn = MedwanQuery.getInstance().getAdminConnection();
        try{
            ps = ad_conn.prepareStatement(sUpdate);
            ps.setString(1, parameter.parameter);
            ps.setString(2, parameter.value);
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

    public static Vector getUserIds(String sParameter,String sValue){
        PreparedStatement ps = null;
        ResultSet rs = null;

        Vector vIds = new Vector();

        String sSelect = "SELECT userid FROM UserParameters WHERE parameter = ? AND value = ? and active=1";

    	Connection ad_conn = MedwanQuery.getInstance().getAdminConnection();
        try{
            ps = ad_conn.prepareStatement(sSelect);
            ps.setString(1,sParameter);
            ps.setString(2,sValue);
            rs = ps.executeQuery();

            while(rs.next()){
                vIds.addElement(ScreenHelper.checkString(rs.getString("userid")));
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
        return vIds;
    }
    
    public static String getParameter(String sUserId,String sParameter){
        PreparedStatement ps = null;
        ResultSet rs = null;

        String value="";

        String sSelect = "SELECT * FROM UserParameters WHERE userid = ? AND parameter = ?";

    	Connection ad_conn = MedwanQuery.getInstance().getAdminConnection();
        try{
            ps = ad_conn.prepareStatement(sSelect);
            ps.setString(1,sUserId);
            ps.setString(2,sParameter);
            rs = ps.executeQuery();

            if(rs.next()){
                value=ScreenHelper.checkString(rs.getString("value"));
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
        return value;
    }
}
