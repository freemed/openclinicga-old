package net.admin;

import be.mxs.common.util.db.MedwanQuery;
import be.mxs.common.util.system.Debug;
import be.mxs.common.util.system.ScreenHelper;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.Enumeration;
import java.util.Hashtable;
import java.util.Date;
import java.text.SimpleDateFormat;

public class AdminPrivateContact{
    public String privateid;
    public String begin;
    public String end;
    public String address;
    public String city;
    public String zipcode;
    public String country;
    public String telephone;
    public String fax;
    public String mobile;
    public String email;
    public String comment;
    public String type;
    public String district;
    public String sanitarydistrict;
    public String province;
    public String sector;
    public String cell;
    public String quarter;
    public String businessfunction;
    public String business;

    public AdminPrivateContact() {
        privateid = "";
        begin = "";
        end = "";
        address = "";
        city = "";
        zipcode = "";
        country = "";
        telephone = "";
        fax = "";
        mobile = "";
        email = "";
        comment = "";
        type = "";
        district = "";
        sanitarydistrict = "";
        province = "";
        sector = "";
        cell = "";
        quarter = "";
        businessfunction = "";
        business = "";
    }

    //--- SAVE TO DB ------------------------------------------------------------------------------
    public boolean saveToDB(String sPersonID, Connection connection) {
        boolean bReturn = true;
        if (this.begin==null || this.begin.length()==0){
            this.begin=new SimpleDateFormat("dd/MM/yyyy").format(new Date());
        }
        String sSelect = "";
        try  {
            if (this.privateid.length()==0){
                //Eens kijken of er geen record is met dezelfde startdatum
                sSelect = "SELECT privateid FROM AdminPrivate WHERE personid = ? AND "+ MedwanQuery.getInstance().datediff("d","start","?")+"=0 and stop is null";
                PreparedStatement ps = connection.prepareStatement(sSelect);
                ps.setInt(1,Integer.parseInt(sPersonID));
                ps.setDate(2,ScreenHelper.getSQLDate(this.begin));
                ResultSet rs = ps.executeQuery();
                if (rs.next()){
                    this.privateid=rs.getString("privateid");
                }
                else {
                    sSelect = "SELECT privateid FROM AdminPrivate WHERE personid = ? AND "+MedwanQuery.getInstance().datediff("d","start","?")+"=0";
                    rs.close();
                    ps.close();
                    ps = connection.prepareStatement(sSelect);
                    ps.setInt(1,Integer.parseInt(sPersonID));
                    ps.setDate(2,ScreenHelper.getSQLDate(this.begin));
                    rs = ps.executeQuery();
                    if (rs.next()){
                        this.privateid=rs.getString("privateid");
                    }
                }
                rs.close();
                ps.close();
            }
            //Updaten van het record
            if (this.privateid.length()>0){
                updatePrivate(this.privateid,connection);
            }
            else {
                this.privateid = MedwanQuery.getInstance().getOpenclinicCounter("PrivateID")+"";

                sSelect = " INSERT INTO AdminPrivate (privateid, personid, start, stop, address, "
                         +"  city, zipcode, country, telephone, fax, mobile, email, comment, updatetime, type, updateserverid, "
                         +"  district, sanitarydistrict, province, sector, cell, quarter, businessfunction, business)"
                         +" VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)";
                PreparedStatement ps = connection.prepareStatement(sSelect);
                ps.setInt(1,Integer.parseInt(this.privateid));
                ps.setInt(2,Integer.parseInt(sPersonID));
                ScreenHelper.setSQLDate(ps,3,this.begin);
                ScreenHelper.setSQLDate(ps,4,this.end);
                ps.setString(5,this.address);
                ps.setString(6,this.city);
                ps.setString(7,this.zipcode);
                ps.setString(8,this.country);
                ps.setString(9,this.telephone);
                ps.setString(10,this.fax);
                ps.setString(11,this.mobile);
                ps.setString(12,this.email);
                ps.setString(13,this.comment);
                ps.setTimestamp(14,new java.sql.Timestamp(new java.util.Date().getTime()));
                ps.setString(15,this.type);
                ps.setInt(16,MedwanQuery.getInstance().getConfigInt("serverId"));
                ps.setString(17,this.district);
                ps.setString(18,this.sanitarydistrict);
                ps.setString(19,this.province);
                ps.setString(20,this.sector);
                ps.setString(21,this.cell);
                ps.setString(22,this.quarter);
                ps.setString(23,this.businessfunction);
                ps.setString(24,this.business);
                ps.executeUpdate();
                ps.close();
            }

            //Het recentste record wordt het actieve record, de andere worden passief
            //Indien dit record het recentste record is en het ook afgesloten was, dan worden ze allen passief
            sSelect = "SELECT * FROM AdminPrivate WHERE personid = ? order by start DESC";
            PreparedStatement ps = connection.prepareStatement(sSelect);
            ps.setInt(1,Integer.parseInt(sPersonID));
            ResultSet rs = ps.executeQuery();
            boolean first=true;
            java.sql.Date previousStart=null;
            while (rs.next()){
                if (first){
                    //Dit is het recentste record, daar doen we niets mee
                    first=false;
                }
                else {
                    //De oudere records worden steeds afgesloten
                    if (rs.getDate("stop")==null || !rs.getDate("stop").equals(previousStart)){
                        PreparedStatement ps2=connection.prepareStatement("update AdminPrivate set stop=? where privateid=?");
                        ps2.setDate(1,previousStart);
                        ps2.setInt(2,rs.getInt("privateid"));
                        ps2.execute();
                        ps2.close();
                    }
                }
                previousStart=rs.getDate("start");
            }
            rs.close();
            ps.close();
        }
        catch(SQLException e) {
            e.printStackTrace();
            ScreenHelper.writeMessage(getClass()+" (1) "+e.getMessage()+" "+sSelect);
            bReturn = false;
        }
        return bReturn;
    }

    //--- UPDATE PRIVATE --------------------------------------------------------------------------
    private boolean updatePrivate(String sPrivateID, Connection connection){
        boolean bReturn = true;
        Hashtable hSelect = new Hashtable();
        hSelect.put(" start = ? ",this.begin);
        hSelect.put(" stop = ? ",this.end);
        hSelect.put(" address = ? ",this.address);
        hSelect.put(" city = ? ",this.city);
        hSelect.put(" zipcode = ? ",this.zipcode);
        hSelect.put(" country = ? ",this.country);
        hSelect.put(" telephone = ? ",this.telephone);
        hSelect.put(" fax = ? ",this.fax);
        hSelect.put(" mobile = ? ",this.mobile);
        hSelect.put(" email = ? ",this.email);
        hSelect.put(" comment = ? ",this.comment);
        hSelect.put(" type = ? ",this.type);
        hSelect.put(" district = ? ",this.district);
        hSelect.put(" sanitarydistrict = ? ",this.sanitarydistrict);
        hSelect.put(" province = ? ",this.province);
        hSelect.put(" sector = ? ",this.sector);
        hSelect.put(" cell = ? ",this.cell);
        hSelect.put(" quarter = ? ",this.quarter);
        hSelect.put(" businessfunction = ? ",this.businessfunction);
        hSelect.put(" business = ? ",this.business);

        if (hSelect.size()>0) {
            String sSelect = "";
            try {
                PreparedStatement ps;
                sSelect = " UPDATE AdminPrivate SET updatetime = ?, updateserverid="+MedwanQuery.getInstance().getConfigInt("serverId")+" ";
                Enumeration e = hSelect.keys();
                String sKey;
                while (e.hasMoreElements()){
                    sKey = (String) e.nextElement();
                    sSelect += ","+sKey;
                }
                sSelect += " WHERE privateid = ?";
                ps = connection.prepareStatement(sSelect);
                ps.setTimestamp(1,new java.sql.Timestamp(new java.util.Date().getTime()));
                int iIndex = 2;
                e = hSelect.keys();
                String sValue;
                while (e.hasMoreElements()){
                    sKey = (String) e.nextElement();
                    sValue = (String)hSelect.get(sKey);
                    if ( (sKey.equalsIgnoreCase(" start = ? ")) || (sKey.equalsIgnoreCase(" stop = ? "))){
                        ScreenHelper.setSQLDate(ps,iIndex,sValue);
                    }
                    else {
                        ps.setString(iIndex,sValue);
                    }
                    iIndex++;
                }
                ps.setInt(iIndex,Integer.parseInt(sPrivateID));
                ps.executeUpdate();
                ps.close();
            }
            catch (Exception ex){
                ScreenHelper.writeMessage(getClass()+" (2) "+ex.getMessage()+" "+sSelect);
                bReturn = false;
            }
        }
        return bReturn;
    }

    //--- INITIALIZE ------------------------------------------------------------------------------
    public boolean initialize (Connection connection) {
        boolean bReturn = false;
        String sSelect = "";
        if ((this.privateid!=null)&&(this.privateid.trim().length()>0)) {
            try {
                sSelect = "SELECT start, stop, address, zipcode, city, country, telephone, fax, "
                         +"  mobile, email, comment, type, district, sanitarydistrict, province, sector, cell, quarter, businessfunction, business"
                         +" FROM AdminPrivate WHERE privateid = ? ";
                PreparedStatement ps = connection.prepareStatement(sSelect);
                ps.setInt(1,Integer.parseInt(this.privateid));
                ResultSet rs = ps.executeQuery();
                if (rs.next()) {
                    this.begin = ScreenHelper.getSQLDate(rs.getDate("start"));
                    this.end = ScreenHelper.getSQLDate(rs.getDate("stop"));
                    this.address = ScreenHelper.checkString(rs.getString("address"));
                    this.zipcode = ScreenHelper.checkString(rs.getString("zipcode"));
                    this.city = ScreenHelper.checkString(rs.getString("city"));
                    this.country = ScreenHelper.checkString(rs.getString("country"));
                    this.telephone = ScreenHelper.checkString(rs.getString("telephone"));
                    this.fax = ScreenHelper.checkString(rs.getString("fax"));
                    this.mobile = ScreenHelper.checkString(rs.getString("mobile"));
                    this.email = ScreenHelper.checkString(rs.getString("email"));
                    this.comment =ScreenHelper.checkString(rs.getString("comment"));
                    this.type =ScreenHelper.checkString(rs.getString("type"));
                    this.district         = ScreenHelper.checkString(rs.getString("district"));
                    this.sanitarydistrict = ScreenHelper.checkString(rs.getString("sanitarydistrict"));
                    this.province         = ScreenHelper.checkString(rs.getString("province"));
                    this.sector           = ScreenHelper.checkString(rs.getString("sector"));
                    this.cell             = ScreenHelper.checkString(rs.getString("cell"));
                    this.quarter          = ScreenHelper.checkString(rs.getString("quarter"));
                    this.businessfunction = ScreenHelper.checkString(rs.getString("businessfunction"));
                    this.business         = ScreenHelper.checkString(rs.getString("business"));
                }
                rs.close();
                ps.close();
            }
            catch(SQLException e) {
                if(Debug.enabled) Debug.println("AdminPrivate initialize error: "+e.getMessage()+" "+sSelect);
            }
        }
        return bReturn;
    }

    public static String[] getPrivateDetails(String sPersonid, String[] privateDetails){
        PreparedStatement ps = null;
        ResultSet rs = null;

        StringBuffer query = new StringBuffer();
        query.append(" SELECT privateid,start,stop,address,city,zipcode,country,telephone,fax,")
             .append(" mobile,email,comment,updatetime,type,")
             .append(" district, sanitarydistrict, province, sector, cell, quarter, businessfunction, business")
             .append(" FROM AdminPrivate")
             .append(" WHERE personid = ? AND stop IS NULL AND type = 'Official'");
        String value;
    	Connection ad_conn = MedwanQuery.getInstance().getAdminConnection();
        try{
            ps = ad_conn.prepareStatement(query.toString());
            ps.setInt(1,Integer.parseInt(sPersonid));

            rs = ps.executeQuery();

            if(rs.next()){
                for(int i=0; i<privateDetails.length; i++){
                // dates should be formatted
                if(i==1 || i==2 || i==12) value = ScreenHelper.checkString(ScreenHelper.getSQLDate(rs.getDate((i+1))));
                else                      value = ScreenHelper.checkString(rs.getString((i+1)));

                if(value.length() > 0) privateDetails[i] = value;
            }
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
        return privateDetails;
    }
}
