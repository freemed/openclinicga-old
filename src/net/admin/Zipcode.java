package net.admin;

import be.mxs.common.util.db.MedwanQuery;
import be.mxs.common.util.system.ScreenHelper;

import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.PreparedStatement;
import java.util.Vector;
import java.util.Hashtable;

public class Zipcode {
    private String zipcode;
    private String citynl;
    private String cityfr;
    private String cityen;

    public String getZipcode() {
        return zipcode;
    }

    public void setZipcode(String zipcode) {
        this.zipcode = zipcode;
    }

    public String getCitynl() {
        return citynl;
    }

    public void setCitynl(String citynl) {
        this.citynl = citynl;
    }

    public String getCityfr() {
        return cityfr;
    }

    public void setCityfr(String cityfr) {
        this.cityfr = cityfr;
    }

    public String getCityen() {
        return cityen;
    }

    public void setCityen(String cityen) {
        this.cityen = cityen;
    }

    public static Vector blurSelectCityTranslation(String sCityDisplayLang,String sZipcodeValue,String sCityValue){
        PreparedStatement ps = null;
        ResultSet rs = null;

        Vector vResults = new Vector();
        String sValue;
        String sSelect = "SELECT city"+sCityDisplayLang+" AS city FROM Zipcodes WHERE ";

        if(sZipcodeValue.length() > 0){
             sSelect += MedwanQuery.getInstance().getConfigParam("lowerCompare","zipcode")+" = '"+sZipcodeValue.toLowerCase()+"' AND ";
        }
        if(sCityValue.length() > 0){
             sSelect += MedwanQuery.getInstance().getConfigParam("lowerCompare","citynl")+" = '"+sCityValue.toLowerCase()+"' AND ";
        }

    	Connection ad_conn = MedwanQuery.getInstance().getAdminConnection();
        try{
            if(sZipcodeValue.length() > 0 || sCityValue.length() > 0){
                ps = ad_conn.prepareStatement(sSelect.substring(0,sSelect.length()-4));
                rs = ps.executeQuery();

                if(rs.next()){
                    sValue = ScreenHelper.checkString(rs.getString("city"));
                    vResults.addElement(sValue);
                }
                rs.close();
                ps.close();
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
        return vResults;
    }

    public static Vector searchZipcodes(String cityDisplayLang,String sFindTextLocal){
        PreparedStatement ps = null;
        ResultSet rs = null;

        Vector vResults = new Vector();
        Hashtable hResults;


        String sSelect = " SELECT zipcode, city"+cityDisplayLang+" AS city"+
                         " FROM Zipcodes"+
                         "  WHERE "+ScreenHelper.getConfigParam("lowerCompare","zipcode")+" LIKE ?"+
                         "   OR "+ScreenHelper.getConfigParam("lowerCompare","city"+cityDisplayLang)+" LIKE ? "+
                         " ORDER BY "+ScreenHelper.getConfigParam("lowerCompare","zipcode")+", "+
                         ScreenHelper.getConfigParam("lowerCompare","city"+cityDisplayLang);

    	Connection ad_conn = MedwanQuery.getInstance().getAdminConnection();
        try{
            ps = ad_conn.prepareStatement(sSelect);
            ps.setString(1,sFindTextLocal.toLowerCase()+"%");
            ps.setString(2,sFindTextLocal.toLowerCase()+"%");
            rs = ps.executeQuery();

            while(rs.next()){
                hResults = new Hashtable();

                hResults.put("zipcode",ScreenHelper.checkString(rs.getString("zipcode")));
                hResults.put("city",ScreenHelper.checkString(rs.getString("city")));

                vResults.addElement(hResults);
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
        return vResults;
    }

    public static Vector getDistricts() {
        PreparedStatement ps = null;
        ResultSet rs = null;

        Vector vResults = new Vector();
        String sSelect = " SELECT distinct district FROM RwandaZipcodes ";

    	Connection ad_conn = MedwanQuery.getInstance().getAdminConnection();
        try {
            ps = ad_conn.prepareStatement(sSelect);
            rs = ps.executeQuery();

            while (rs.next()) {
                vResults.addElement(ScreenHelper.checkString(rs.getString("district")));
            }
            rs.close();
            ps.close();
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            try {
                if (rs != null) rs.close();
                if (ps != null) ps.close();
                ad_conn.close();
            } catch (Exception e) {
                e.printStackTrace();
            }
        }
        return vResults;
    }

    public static Vector getRegions(String table) {
        PreparedStatement ps = null;
        ResultSet rs = null;

        Vector vResults = new Vector();
        String sSelect = " SELECT distinct region FROM "+table+" ";

    	Connection ad_conn = MedwanQuery.getInstance().getAdminConnection();
        try {
            ps = ad_conn.prepareStatement(sSelect);
            rs = ps.executeQuery();

            while (rs.next()) {
                vResults.addElement(ScreenHelper.checkString(rs.getString("region")));
            }
            rs.close();
            ps.close();
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            try {
                if (rs != null) rs.close();
                if (ps != null) ps.close();
                ad_conn.close();
            } catch (Exception e) {
                e.printStackTrace();
            }
        }
        return vResults;
    }

    public static Vector getDistricts(String region,String table) {
        PreparedStatement ps = null;
        ResultSet rs = null;

        Vector vResults = new Vector();
        String sSelect = " SELECT distinct district FROM "+table+" where region=?";
        if (ScreenHelper.checkString(region).length()>0){
	
	    	Connection ad_conn = MedwanQuery.getInstance().getAdminConnection();
	        try {
	            ps = ad_conn.prepareStatement(sSelect);
	            ps.setString(1, region);
	            rs = ps.executeQuery();
	
	            while (rs.next()) {
	                vResults.addElement(ScreenHelper.checkString(rs.getString("district")));
	            }
	            rs.close();
	            ps.close();
	        } catch (Exception e) {
	            e.printStackTrace();
	        } finally {
	            try {
	                if (rs != null) rs.close();
	                if (ps != null) ps.close();
	                ad_conn.close();
	            } catch (Exception e) {
	                e.printStackTrace();
	            }
	        }
        }
        return vResults;
    }

    public static Vector getDistricts(String table) {
        PreparedStatement ps = null;
        ResultSet rs = null;

        Vector vResults = new Vector();
        String sSelect = " SELECT distinct district FROM "+table+" ";

    	Connection ad_conn = MedwanQuery.getInstance().getAdminConnection();
        try {
            ps = ad_conn.prepareStatement(sSelect);
            rs = ps.executeQuery();

            while (rs.next()) {
                vResults.addElement(ScreenHelper.checkString(rs.getString("district")));
            }
            rs.close();
            ps.close();
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            try {
                if (rs != null) rs.close();
                if (ps != null) ps.close();
                ad_conn.close();
            } catch (Exception e) {
                e.printStackTrace();
            }
        }
        return vResults;
    }

    public static Vector getCities(String sDistrict, String table) {

        Vector vResults = new Vector();

        if (ScreenHelper.checkString(sDistrict).length()>0){
            PreparedStatement ps = null;
            ResultSet rs = null;

            String sSelect = " SELECT distinct city FROM "+table+" WHERE district = ?";

        	Connection ad_conn = MedwanQuery.getInstance().getAdminConnection();
            try {
                ps = ad_conn.prepareStatement(sSelect);
                ps.setString(1,sDistrict);
                rs = ps.executeQuery();

                while (rs.next()) {
                    vResults.addElement(ScreenHelper.checkString(rs.getString("city")));
                }
                rs.close();
                ps.close();
            } catch (Exception e) {
                e.printStackTrace();
            } finally {
                try {
                    if (rs != null) rs.close();
                    if (ps != null) ps.close();
                    ad_conn.close();
                } catch (Exception e) {
                    e.printStackTrace();
                }
            }
        }
        return vResults;
    }

    public static Vector getCities(String region, String sDistrict, String table) {

        Vector vResults = new Vector();

        if (ScreenHelper.checkString(region).length()>0 && ScreenHelper.checkString(sDistrict).length()>0){
            PreparedStatement ps = null;
            ResultSet rs = null;

            String sSelect = " SELECT distinct city FROM "+table+" WHERE district = ? and region=?";

        	Connection ad_conn = MedwanQuery.getInstance().getAdminConnection();
            try {
                ps = ad_conn.prepareStatement(sSelect);
                ps.setString(1,sDistrict);
                ps.setString(2, region);
                rs = ps.executeQuery();

                while (rs.next()) {
                    vResults.addElement(ScreenHelper.checkString(rs.getString("city")));
                }
                rs.close();
                ps.close();
            } catch (Exception e) {
                e.printStackTrace();
            } finally {
                try {
                    if (rs != null) rs.close();
                    if (ps != null) ps.close();
                    ad_conn.close();
                } catch (Exception e) {
                    e.printStackTrace();
                }
            }
        }
        return vResults;
    }

    public static Vector getQuarters(String region, String sDistrict, String sCity, String table) {

        Vector vResults = new Vector();

        if (ScreenHelper.checkString(region).length()>0 && ScreenHelper.checkString(sDistrict).length()>0 && ScreenHelper.checkString(sCity).length()>0){
            PreparedStatement ps = null;
            ResultSet rs = null;

            String sSelect = " SELECT distinct sector FROM "+table+" WHERE district = ? and region=? and city=?";

        	Connection ad_conn = MedwanQuery.getInstance().getAdminConnection();
            try {
                ps = ad_conn.prepareStatement(sSelect);
                ps.setString(1,sDistrict);
                ps.setString(2, region);
                ps.setString(3, sCity);
                rs = ps.executeQuery();

                while (rs.next()) {
                    vResults.addElement(ScreenHelper.checkString(rs.getString("sector")));
                }
                rs.close();
                ps.close();
            } catch (Exception e) {
                e.printStackTrace();
            } finally {
                try {
                    if (rs != null) rs.close();
                    if (ps != null) ps.close();
                    ad_conn.close();
                } catch (Exception e) {
                    e.printStackTrace();
                }
            }
        }
        return vResults;
    }

    public static String getZipcode(String sDistrict, String sCity) {

        String sZipcode = "";

        if ((ScreenHelper.checkString(sDistrict).length()>0)&&(ScreenHelper.checkString(sCity).length()>0)){
            PreparedStatement ps = null;
            ResultSet rs = null;

            String sSelect = " SELECT zipcode FROM RwandaZipcodes WHERE district = ? AND city = ?";

        	Connection ad_conn = MedwanQuery.getInstance().getAdminConnection();
            try {
                ps = ad_conn.prepareStatement(sSelect);
                ps.setString(1,sDistrict);
                ps.setString(2,sCity);
                rs = ps.executeQuery();

                if (rs.next()) {
                    sZipcode = ScreenHelper.checkString(rs.getString("zipcode"));
                }
                rs.close();
                ps.close();
            } catch (Exception e) {
                e.printStackTrace();
            } finally {
                try {
                    if (rs != null) rs.close();
                    if (ps != null) ps.close();
                    ad_conn.close();
                } catch (Exception e) {
                    e.printStackTrace();
                }
            }
        }
        return sZipcode;
    }

    public static String getZipcode(String sDistrict, String sCity, String table) {

        String sZipcode = "";

        if ((ScreenHelper.checkString(sDistrict).length()>0)&&(ScreenHelper.checkString(sCity).length()>0)){
            PreparedStatement ps = null;
            ResultSet rs = null;

            String sSelect = " SELECT zipcode FROM "+table+" WHERE district = ? AND city = ?";

        	Connection ad_conn = MedwanQuery.getInstance().getAdminConnection();
            try {
                ps = ad_conn.prepareStatement(sSelect);
                ps.setString(1,sDistrict);
                ps.setString(2,sCity);
                rs = ps.executeQuery();

                if (rs.next()) {
                    sZipcode = ScreenHelper.checkString(rs.getString("zipcode"));
                }
                rs.close();
                ps.close();
            } catch (Exception e) {
                e.printStackTrace();
            } finally {
                try {
                    if (rs != null) rs.close();
                    if (ps != null) ps.close();
                    ad_conn.close();
                } catch (Exception e) {
                    e.printStackTrace();
                }
            }
        }
        return sZipcode;
    }
    public static String getZipcode(String sRegion, String sDistrict, String sCity, String sQuarter,String table) {

        String sZipcode = "";

        if (ScreenHelper.checkString(sDistrict).length()>0 && ScreenHelper.checkString(sCity).length()>0){
            PreparedStatement ps = null;
            ResultSet rs = null;

            String sSelect = " SELECT zipcode FROM "+table+" WHERE district = ? AND city = ?";
            if(ScreenHelper.checkString(sRegion).length()>0){
            	sSelect+=" and region=? ";
            }
            if(ScreenHelper.checkString(sQuarter).length()>0){
            	sSelect+=" and sector=?";
            }
            
        	Connection ad_conn = MedwanQuery.getInstance().getAdminConnection();
            try {
                ps = ad_conn.prepareStatement(sSelect);
                int n=1;
                ps.setString(n,sDistrict);
                n++;
                ps.setString(n,sCity);
                n++;
                if(ScreenHelper.checkString(sRegion).length()>0){
                	ps.setString(n,sRegion);
                	n++;
                }
                if(ScreenHelper.checkString(sQuarter).length()>0){
                	ps.setString(n,sQuarter);
                	n++;
                } 
                rs = ps.executeQuery();

                if (rs.next()) {
                    sZipcode = ScreenHelper.checkString(rs.getString("zipcode"));
                }
                rs.close();
                ps.close();
            } catch (Exception e) {
                e.printStackTrace();
            } finally {
                try {
                    if (rs != null) rs.close();
                    if (ps != null) ps.close();
                    ad_conn.close();
                } catch (Exception e) {
                    e.printStackTrace();
                }
            }
        }
        return sZipcode;
    }
}
