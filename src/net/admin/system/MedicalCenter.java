package net.admin.system;

import be.mxs.common.util.db.MedwanQuery;
import be.mxs.common.util.system.ScreenHelper;
import be.mxs.common.util.system.Debug;

import java.sql.Connection;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.Vector;
import java.util.Hashtable;

public class MedicalCenter {
    private String code;
    private String name;
    private Timestamp updatetime;
    private String address;
    private String zipcode;
    private String city;
    private String country;
    private String telephone;
    private String email;
    private String fax;
    private String comment;

    public String getCode(){
        return code;
    }

    public void setCode(String code){
        this.code = code;
    }

    public String getName(){
        return name;
    }

    public void setName(String name){
        this.name = name;
    }

    public Timestamp getUpdatetime(){
        return updatetime;
    }

    public void setUpdatetime(Timestamp updatetime){
        this.updatetime = updatetime;
    }

    public String getAddress(){
        return address;
    }

    public void setAddress(String address){
        this.address = address;
    }

    public String getZipcode(){
        return zipcode;
    }

    public void setZipcode(String zipcode){
        this.zipcode = zipcode;
    }

    public String getCity(){
        return city;
    }

    public void setCity(String city){
        this.city = city;
    }

    public String getCountry(){
        return country;
    }

    public void setCountry(String country){
        this.country = country;
    }

    public String getTelephone(){
        return telephone;
    }

    public void setTelephone(String telephone){
        this.telephone = telephone;
    }

    public String getEmail(){
        return email;
    }

    public void setEmail(String email){
        this.email = email;
    }

    public String getFax(){
        return fax;
    }

    public void setFax(String fax){
        this.fax = fax;
    }

    public String getComment(){
        return comment;
    }

    public void setComment(String comment){
        this.comment = comment;
    }

    //--- EXISTS ----------------------------------------------------------------------------------
    public static boolean exists(String sCode){
        boolean bExists = false;
        PreparedStatement ps = null;
        ResultSet rs = null;

    	Connection conn = MedwanQuery.getInstance().getAdminConnection();
        try{
            String sSQL = "SELECT 1 FROM MedicalCenters WHERE code = ?";
            ps = conn.prepareStatement(sSQL);
            ps.setString(1,sCode);
            rs = ps.executeQuery();

            if(rs.next()){
                bExists = true;
            }
        }
        catch(Exception e){
            e.printStackTrace();
        }
        finally{
            try{
                if(rs!=null) rs.close();
                if(ps!=null) ps.close();
                conn.close();
            }
            catch(Exception e){
                e.printStackTrace();
            }
        }

        return bExists;
    }

    //--- ADD MEDICAL CENTER ----------------------------------------------------------------------
    public static void addMedicalCenter(MedicalCenter objMC){
        PreparedStatement ps = null;

        String sSQL = "INSERT INTO MedicalCenters (code,name,updatetime,address,zipcode,city,country,"+
                      " telephone,email,fax,comment)"+
        		      " VALUES (?,?,?,?,?,?,?,?,?,?,?)";

    	Connection conn = MedwanQuery.getInstance().getAdminConnection();
        try{
            ps = conn.prepareStatement(sSQL);
            ps.setString(1,objMC.getCode());
            ps.setString(2,objMC.getName());
            ps.setTimestamp(3,ScreenHelper.getSQLTime()); // now
            ps.setString(4,objMC.getAddress());
            ps.setString(5,objMC.getZipcode());
            ps.setString(6,objMC.getCity());
            ps.setString(7,objMC.getCountry());
            ps.setString(8,objMC.getTelephone());
            ps.setString(9,objMC.getEmail());
            ps.setString(10,objMC.getFax());
            ps.setString(11,objMC.getComment());

            ps.executeUpdate();
        }
        catch(Exception e){
            e.printStackTrace();
        }
        finally{
            try{
                if(ps!=null) ps.close();
                conn.close();
            }
            catch(Exception e){
                e.printStackTrace();
            }
        }
    }

    //--- SAVE MEDICAL CENTER ---------------------------------------------------------------------
    public static void saveMedicalCenter(MedicalCenter objMC){
        PreparedStatement ps = null;

        String sSQL = "UPDATE MedicalCenters SET code=?, name=?, updatetime=?, address=?, zipcode=?, city=?,"+
                      " country=?, telephone=?, email=?, fax=?, comment=?"+
                      " WHERE code = ?";

    	Connection conn = MedwanQuery.getInstance().getAdminConnection();
        try{
            ps = conn.prepareStatement(sSQL);
            
            ps.setString(1,objMC.getCode());
            ps.setString(2,objMC.getName());
            ps.setTimestamp(3,ScreenHelper.getSQLTime()); // now
            ps.setString(4,objMC.getAddress());
            ps.setString(5,objMC.getZipcode());
            ps.setString(6,objMC.getCity());
            ps.setString(7,objMC.getCountry());
            ps.setString(8,objMC.getTelephone());
            ps.setString(9,objMC.getEmail());
            ps.setString(10,objMC.getFax());
            ps.setString(11,objMC.getComment());
            ps.setString(12,objMC.getCode());

            ps.executeUpdate();
        }
        catch(Exception e){
            e.printStackTrace();
        }
        finally{
            try{
                if(ps!=null) ps.close();
                conn.close();
            }
            catch(Exception e){
                e.printStackTrace();
            }
        }
    }

    //--- DELETE MEDICAL CENTER -------------------------------------------------------------------
    public static void deleteMedicalCenter(String sCode){
        PreparedStatement ps = null;

    	Connection conn = MedwanQuery.getInstance().getAdminConnection();
        try{
            String sSQL = "DELETE FROM MedicalCenters WHERE code = ?";
            ps = conn.prepareStatement(sSQL);
            ps.setString(1,sCode);

            ps.executeUpdate();
        }
        catch(Exception e){
            e.printStackTrace();
        }
        finally{
            try{
                if(ps!=null) ps.close();
                conn.close();
            }
            catch(Exception e){
                e.printStackTrace();
            }
        }
    }

    //--- SELECT MEDICAL CENTERS ------------------------------------------------------------------
    public static Vector selectMedicalCenters(String sFindCenterCode, String sFindCenterName,
    		                                  String sFindCenterAddress, String sFindCenterZipcode, 
    		                                  String sFindCenterCity, String sSortCol){
        PreparedStatement ps = null;
        ResultSet rs = null;

        Vector vMC = new Vector();
        MedicalCenter objMC;

    	Connection conn = MedwanQuery.getInstance().getAdminConnection();
        try{
            String sSQL = "SELECT * FROM MedicalCenters";
            
            if(sFindCenterCode.length()>0 || sFindCenterName.length()>0 || sFindCenterAddress.length()>0 ||
               sFindCenterZipcode.length()>0 || sFindCenterCity.length()>0){
            	sSQL+= " WHERE ";

                if(sFindCenterCode.length() > 0)    sSQL+= "code LIKE ? AND ";
                if(sFindCenterName.length() > 0)    sSQL+= "name LIKE ? AND ";
                if(sFindCenterAddress.length() > 0) sSQL+= "address LIKE ? AND ";
                if(sFindCenterZipcode.length() > 0) sSQL+= "zipcode LIKE ? AND ";
                if(sFindCenterCity.length() > 0)    sSQL+= "city LIKE ? AND ";
            }

            // remove last AND if any
            if(sSQL.indexOf("AND ")>0){
            	sSQL = sSQL.substring(0,sSQL.lastIndexOf("AND "));
            }

            // order by selected col or default col
            sSQL+= " ORDER BY "+sSortCol;
            ps = conn.prepareStatement(sSQL);

            // set questionmark values
            int questionMarkIdx = 1;
            if(sFindCenterCode.length() > 0)    ps.setString(questionMarkIdx++,sFindCenterCode+"%");
            if(sFindCenterName.length() > 0)    ps.setString(questionMarkIdx++,sFindCenterName+"%");
            if(sFindCenterAddress.length() > 0) ps.setString(questionMarkIdx++,sFindCenterAddress+"%");
            if(sFindCenterZipcode.length() > 0) ps.setString(questionMarkIdx++,sFindCenterZipcode+"%");
            if(sFindCenterCity.length() > 0)    ps.setString(questionMarkIdx++,sFindCenterCity+"%");

            rs = ps.executeQuery();

            while(rs.next()){
                objMC = new MedicalCenter();

                objMC.setCode(ScreenHelper.checkString(rs.getString("code")));
                objMC.setName(ScreenHelper.checkString(rs.getString("name")));
                objMC.setUpdatetime(rs.getTimestamp("updatetime"));
                objMC.setAddress(ScreenHelper.checkString(rs.getString("address")));
                objMC.setZipcode(ScreenHelper.checkString(rs.getString("zipcode")));
                objMC.setCity(ScreenHelper.checkString(rs.getString("city")));
                objMC.setCountry(ScreenHelper.checkString(rs.getString("country")));
                objMC.setTelephone(ScreenHelper.checkString(rs.getString("telephone")));
                objMC.setEmail(ScreenHelper.checkString(rs.getString("email")));
                objMC.setFax(ScreenHelper.checkString(rs.getString("fax")));
                objMC.setComment(ScreenHelper.checkString(rs.getString("comment")));

                vMC.addElement(objMC);
            }
        }
        catch(Exception e){
            e.printStackTrace();
        }
        finally{
            try{
                if(rs!=null) rs.close();
                if(ps!=null) ps.close();
                conn.close();
            }
            catch(Exception e){
                e.printStackTrace();
            }
        }

        return vMC;
    }

    //--- SHOW DETAILS ----------------------------------------------------------------------------
    public static MedicalCenter showDetails(String sCode){
        MedicalCenter objMC = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

    	Connection conn = MedwanQuery.getInstance().getAdminConnection();
        try{
            String sSQL = "SELECT * FROM MedicalCenters WHERE code = ?";
            ps = conn.prepareStatement(sSQL);
            ps.setString(1,sCode);
            rs = ps.executeQuery();

            if(rs.next()){
                objMC =  new MedicalCenter();

                objMC.setCode(ScreenHelper.checkString(rs.getString("code")));
                objMC.setName(ScreenHelper.checkString(rs.getString("name")));
                objMC.setAddress(ScreenHelper.checkString(rs.getString("address")));
                objMC.setCity(ScreenHelper.checkString(rs.getString("city")));
                objMC.setZipcode(ScreenHelper.checkString(rs.getString("zipcode")));
                objMC.setCountry(ScreenHelper.checkString(rs.getString("country")));
                objMC.setEmail(ScreenHelper.checkString(rs.getString("email")));
                objMC.setFax(ScreenHelper.checkString(rs.getString("fax")));
                objMC.setTelephone(ScreenHelper.checkString(rs.getString("telephone")));
                objMC.setUpdatetime(rs.getTimestamp("updatetime"));
                objMC.setComment(ScreenHelper.checkString(rs.getString("comment")));
            }
        }
        catch(Exception e){
            e.printStackTrace();
        }
        finally{
            try{
                if(rs!=null) rs.close();
                if(ps!=null) ps.close();
                conn.close();
            }
            catch(Exception e){
                e.printStackTrace();
            }
        }

        return objMC;
    }

    //--- BLUR SELECT MEDICAL CENTER INFO ---------------------------------------------------------
    public static Hashtable blurSelectMedicalCenterInfo(String sLowerCode,String sSearchCode){
        Hashtable hResults = new Hashtable();
        PreparedStatement ps = null;
        ResultSet rs = null;

    	Connection conn = MedwanQuery.getInstance().getAdminConnection();
        try{
            String sSQL = "SELECT name,address,zipcode,city,telephone"+
                          " FROM MedicalCenters WHERE "+sLowerCode+" = ?";
            ps = conn.prepareStatement(sSQL);
            ps.setString(1,sSearchCode);
            rs = ps.executeQuery();

            if(rs.next()){
                hResults.put("name",ScreenHelper.checkString(rs.getString("name")));
                hResults.put("address",ScreenHelper.checkString(rs.getString("address")));
                hResults.put("zipcode",ScreenHelper.checkString(rs.getString("zipcode")));
                hResults.put("city",ScreenHelper.checkString(rs.getString("city")));
                hResults.put("telephone",ScreenHelper.checkString(rs.getString("telephone")));
            }
        }
        catch(Exception e){
            e.printStackTrace();
        }
        finally{
            try{
                if(rs!=null) rs.close();
                if(ps!=null) ps.close();
                conn.close();
            }
            catch(Exception e){
                e.printStackTrace();
            }
        }
        
        return hResults;
    }

    //--- GET MEDICAL CENTER BY CODE --------------------------------------------------------------
    public static MedicalCenter getMedicalCenterByCode(String sCode){
        MedicalCenter medicalCenter = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

    	Connection conn = MedwanQuery.getInstance().getAdminConnection();
        try{
            String sSelect = "SELECT * FROM MedicalCenters WHERE code = ?";
            ps = conn.prepareStatement(sSelect);
            ps.setString(1,sCode);
            rs = ps.executeQuery();

            if(rs.next()){
                medicalCenter = new MedicalCenter();
                
                medicalCenter.setCode(ScreenHelper.checkString(rs.getString("code")));
                medicalCenter.setName(ScreenHelper.checkString(rs.getString("name")));
                medicalCenter.setAddress(ScreenHelper.checkString(rs.getString("address")));
                medicalCenter.setCity(ScreenHelper.checkString(rs.getString("city")));
                medicalCenter.setZipcode(ScreenHelper.checkString(rs.getString("zipcode")));
                medicalCenter.setCountry(ScreenHelper.checkString(rs.getString("country")));
                medicalCenter.setEmail(ScreenHelper.checkString(rs.getString("email")));
                medicalCenter.setFax(ScreenHelper.checkString(rs.getString("fax")));
                medicalCenter.setTelephone(ScreenHelper.checkString(rs.getString("telephone")));
                medicalCenter.setUpdatetime(rs.getTimestamp("updatetime"));
                medicalCenter.setComment(ScreenHelper.checkString(rs.getString("comment")));
            }
        }
        catch(Exception e){
            e.printStackTrace();
        }
        finally{
            try{
                if(rs!=null) rs.close();
                if(ps!=null) ps.close();
                conn.close();
            }
            catch(Exception e){
                e.printStackTrace();
            }
        }
        
        return medicalCenter;
    }
    
}