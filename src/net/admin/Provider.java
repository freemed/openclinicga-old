package net.admin;

import be.mxs.common.util.db.MedwanQuery;
import be.mxs.common.util.system.ScreenHelper;

import java.sql.Connection;
import java.sql.Timestamp;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

/**
 * Created by IntelliJ IDEA.
 * User: mxs_david
 * Date: 12-jan-2007
 * Time: 15:07:40
 * To change this template use Options | File Templates.
 */
public class Provider {
    private String code;
    private String name;
    private Timestamp updatetime;

    public String getCode() {
        return code;
    }

    public void setCode(String code) {
        this.code = code;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public Timestamp getUpdatetime() {
        return updatetime;
    }

    public void setUpdatetime(Timestamp updatetime) {
        this.updatetime = updatetime;
    }

    public static String blurSelectProviderName(String sLowerCode,String sSearchCode){
        PreparedStatement ps = null;
        ResultSet rs = null;

        String sValue = "";

        String sSelect = "SELECT name FROM Providers WHERE "+sLowerCode+" = ?";

    	Connection ad_conn = MedwanQuery.getInstance().getAdminConnection();
        try{
            ps = ad_conn.prepareStatement(sSelect);
            ps.setString(1,sSearchCode);
            rs = ps.executeQuery();

            if(rs.next()){
                sValue = ScreenHelper.checkString(rs.getString("name"));
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
        return sValue;
    }
}
