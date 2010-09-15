package net.admin.system;

import be.mxs.common.util.db.MedwanQuery;
import be.mxs.common.util.system.ScreenHelper;

import java.sql.Connection;
import java.sql.Timestamp;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.Vector;


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

    public static Vector getExternalPreventionServices(){
        PreparedStatement ps = null;
        ResultSet rs = null;

        Vector vEPS = new Vector();

        ExternalPreventionService objEPS;

        String sSelect = " SELECT * FROM ExternalPreventionServices WHERE deletedate IS NULL"+
                         " ORDER BY "+ScreenHelper.getConfigParam("lowerCompare","EPSName");

    	Connection ad_conn = MedwanQuery.getInstance().getAdminConnection();
        try{
            ps = ad_conn.prepareStatement(sSelect);

            rs = ps.executeQuery();

            while(rs.next()){
                objEPS = new ExternalPreventionService();

                objEPS.setEPSID(rs.getInt("EPSID"));
                objEPS.setEPSName(ScreenHelper.checkString(rs.getString("EPSName")));
                objEPS.setEPSAddress(ScreenHelper.checkString(rs.getString("EPSAddress")));
                objEPS.setEPSZipcode(ScreenHelper.checkString(rs.getString("EPSZipcode")));
                objEPS.setEPSCity(ScreenHelper.checkString(rs.getString("EPSCity")));
                objEPS.setEPSPhone(ScreenHelper.checkString(rs.getString("EPSPhone")));
                objEPS.setEPSFax(ScreenHelper.checkString(rs.getString("EPSFax")));
                objEPS.setEPSPhysicianLastname(ScreenHelper.checkString(rs.getString("EPSPhysicianLastname")));
                objEPS.setEPSPhysicianFirstname(ScreenHelper.checkString(rs.getString("EPSPhysicianFirstname")));
                objEPS.setUpdateuserid(rs.getInt("updateuserid"));
                objEPS.setUpdatetime(rs.getTimestamp("updatetime"));
                objEPS.setDeletedate(rs.getTimestamp("deletedate"));

                vEPS.addElement(objEPS);
            }
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

        return vEPS;
    }

    public static void addExternalPreventionService(ExternalPreventionService objEPS){
        PreparedStatement ps = null;

        String sInsert = " INSERT INTO ExternalPreventionServices (EPSName, EPSAddress, EPSZipcode, EPSCity, EPSPhone, "+
                         " EPSFax, EPSPhysicianLastname, EPSPhysicianFirstname, updateuserid, updatetime, EPSID)"+
                         " VALUES (?,?,?,?,?,?,?,?,?,?,?)";

    	Connection ad_conn = MedwanQuery.getInstance().getAdminConnection();
        try{
            ps = ad_conn.prepareStatement(sInsert);
            ps.setString(1,objEPS.getEPSName());
            ps.setString(2,objEPS.getEPSAddress());
            ps.setString(3,objEPS.getEPSZipcode());
            ps.setString(4,objEPS.getEPSCity());
            ps.setString(5,objEPS.getEPSPhone());
            ps.setString(6,objEPS.getEPSFax());
            ps.setString(7,objEPS.getEPSPhysicianLastname());
            ps.setString(8,objEPS.getEPSPhysicianFirstname());
            ps.setInt(9,objEPS.getUpdateuserid());
            ps.setTimestamp(10,objEPS.getUpdatetime());
            ps.setInt(11,objEPS.getEPSID());

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

    public static void saveExternalPreventionService(ExternalPreventionService objEPS){
        PreparedStatement ps = null;

        String sUpdate = " UPDATE ExternalPreventionServices SET EPSName = ?, EPSAddress = ?, EPSZipcode = ?,"+
                         " EPSCity = ?, EPSPhone = ?, EPSFax = ?, EPSPhysicianLastname = ?, EPSPhysicianFirstname = ?,"+
                         " updateuserid = ?, updatetime = ? WHERE EPSID = ?";

    	Connection ad_conn = MedwanQuery.getInstance().getAdminConnection();
        try{
            ps = ad_conn.prepareStatement(sUpdate);
            ps.setString(1,objEPS.getEPSName());
            ps.setString(2,objEPS.getEPSAddress());
            ps.setString(3,objEPS.getEPSZipcode());
            ps.setString(4,objEPS.getEPSCity());
            ps.setString(5,objEPS.getEPSPhone());
            ps.setString(6,objEPS.getEPSFax());
            ps.setString(7,objEPS.getEPSPhysicianLastname());
            ps.setString(8,objEPS.getEPSPhysicianFirstname());
            ps.setInt(9,objEPS.getUpdateuserid());
            ps.setTimestamp(10,objEPS.getUpdatetime());
            ps.setInt(11,objEPS.getEPSID());

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

    public static void deleteExternalPreventionService(Timestamp deletedate, String sEPSId){
        PreparedStatement ps = null;

        String sDelete = " UPDATE ExternalPreventionServices SET deletedate = ? WHERE EPSID = ?";

    	Connection ad_conn = MedwanQuery.getInstance().getAdminConnection();
        try{
            ps = ad_conn.prepareStatement(sDelete);
            ps.setTimestamp(1,deletedate);
            ps.setInt(2, Integer.parseInt(sEPSId));

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
