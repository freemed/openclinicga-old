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
 * Time: 15:57:53
 * To change this template use File | Settings | File Templates.
 */
public class ExternalPreventionService {
    private int EPSID;
    private String EPSName;
    private String EPSAddress;
    private String EPSZipcode;
    private String EPSCity;
    private String EPSPhone;
    private String EPSFax;
    private String EPSPhysicianLastname;
    private String EPSPhysicianFirstname;
    private Timestamp updatetime;
    private int updateuserid;
    private Timestamp deletedate;


    public int getEPSID() {
        return EPSID;
    }

    public void setEPSID(int EPSID) {
        this.EPSID = EPSID;
    }

    public String getEPSName() {
        return EPSName;
    }

    public void setEPSName(String EPSName) {
        this.EPSName = EPSName;
    }

    public String getEPSAddress() {
        return EPSAddress;
    }

    public void setEPSAddress(String EPSAddress) {
        this.EPSAddress = EPSAddress;
    }

    public String getEPSZipcode() {
        return EPSZipcode;
    }

    public void setEPSZipcode(String EPSZipcode) {
        this.EPSZipcode = EPSZipcode;
    }

    public String getEPSCity() {
        return EPSCity;
    }

    public void setEPSCity(String EPSCity) {
        this.EPSCity = EPSCity;
    }

    public String getEPSPhone() {
        return EPSPhone;
    }

    public void setEPSPhone(String EPSPhone) {
        this.EPSPhone = EPSPhone;
    }

    public String getEPSFax() {
        return EPSFax;
    }

    public void setEPSFax(String EPSFax) {
        this.EPSFax = EPSFax;
    }

    public String getEPSPhysicianLastname() {
        return EPSPhysicianLastname;
    }

    public void setEPSPhysicianLastname(String EPSPhysicianLastname) {
        this.EPSPhysicianLastname = EPSPhysicianLastname;
    }

    public String getEPSPhysicianFirstname() {
        return EPSPhysicianFirstname;
    }

    public void setEPSPhysicianFirstname(String EPSPhysicianFirstname) {
        this.EPSPhysicianFirstname = EPSPhysicianFirstname;
    }

    public Timestamp getUpdatetime() {
        return updatetime;
    }

    public void setUpdatetime(Timestamp updatetime) {
        this.updatetime = updatetime;
    }

    public int getUpdateuserid() {
        return updateuserid;
    }

    public void setUpdateuserid(int updateuserid) {
        this.updateuserid = updateuserid;
    }

    public Timestamp getDeletedate() {
        return deletedate;
    }

    public void setDeletedate(Timestamp deletedate) {
        this.deletedate = deletedate;
    }

    public static String getEPSName(String sEPSID){
        PreparedStatement ps = null;
        ResultSet rs = null;

        String sEPSName = "";

        String sSelect = "SELECT EPSName FROM ExternalPreventionServices WHERE EPSID = ?";

    	Connection ad_conn = MedwanQuery.getInstance().getAdminConnection();
        try{
            ps = ad_conn.prepareStatement(sSelect);
            ps.setInt(1,Integer.parseInt(sEPSID));
            rs = ps.executeQuery();

            if (rs.next()){
                sEPSName = ScreenHelper.checkString(rs.getString("EPSName"));
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
        return sEPSName;
    }
    
    public static String getEPSID(String sViewCode){
        PreparedStatement ps = null;
        ResultSet rs = null;

        String sServiceEPSID = "";

        String sSelect = " SELECT EPSID FROM EPSServices WHERE serviceid = ? AND deletedate is null ";

    	Connection ad_conn = MedwanQuery.getInstance().getAdminConnection();
        try{
            ps = ad_conn.prepareStatement(sSelect);
            ps.setString(1,sViewCode);
            rs = ps.executeQuery();
            if (rs.next()){
                sServiceEPSID = ScreenHelper.checkString(rs.getString("EPSID"));
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
        return sServiceEPSID;
    }
}
