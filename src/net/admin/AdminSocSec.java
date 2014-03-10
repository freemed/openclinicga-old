package net.admin;

import be.mxs.common.util.db.MedwanQuery;
import be.mxs.common.util.system.Debug;
import be.mxs.common.util.system.ScreenHelper;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.Hashtable;
import java.util.Enumeration;

public class AdminSocSec {
    public String socsecid;
    public String covered;
    public String enterprise;
    public String assurancenumber;
    public String assurancetype;
    public String start;
    public String stop;
    public String comment;

    public AdminSocSec() {
        socsecid = "";
        covered = "";
        enterprise = "";
        assurancenumber = "";
        assurancetype = "";
        start = "";
        stop = "";
        comment = "";
    }

    //--- SAVE TO DB ------------------------------------------------------------------------------
    public boolean saveToDB(String sPersonID, Connection connection) {

        boolean bReturn = true;
        String sSelect = "";
        try  {
            if (this.socsecid.length()>0){
                updateSocSec(this.socsecid,connection);
            }
            else {
                this.socsecid = MedwanQuery.getInstance().getOpenclinicCounter("SocSecID")+"";

                sSelect = " DELETE FROM AdminSocSec WHERE personid = ?";
                PreparedStatement ps = connection.prepareStatement(sSelect);
                ps.setInt(1,Integer.parseInt(sPersonID));
                ps.executeUpdate();
                ps.close();

                sSelect = " INSERT INTO AdminSocSec (socsecid, personid, covered, enterprise, assurancenumber"
                         +", assurancetype, start, stop, comment, updatetime, updateserverid)"
                         +" VALUES (?,?,?,?,?,?,?,?,?,?,?)";
                ps = connection.prepareStatement(sSelect);
                ps.setInt(1,Integer.parseInt(this.socsecid));
                ps.setInt(2,Integer.parseInt(sPersonID));
                ps.setString(3,this.covered);
                ps.setString(4,this.enterprise);
                ps.setString(5,this.assurancenumber);
                ps.setString(6,this.assurancetype);
                ScreenHelper.setSQLDate(ps,7,this.start);
                ScreenHelper.setSQLDate(ps,8,this.stop);
                ps.setString(9,this.comment);
                ps.setTimestamp(10,new java.sql.Timestamp(new java.util.Date().getTime()));
                ps.setInt(11, MedwanQuery.getInstance().getConfigInt("serverId"));
                ps.executeUpdate();
                ps.close();
            }
        }
        catch(SQLException e) {
        	Debug.printStackTrace(e);
            bReturn = false;
        }
        return bReturn;
    }

    //--- UPDATE PRIVATE --------------------------------------------------------------------------
    private boolean updateSocSec(String sSocSecID, Connection connection){
        boolean bReturn = true;
        Hashtable hSelect = new Hashtable();
        hSelect.put(" start = ? ",this.start);
        hSelect.put(" stop = ? ",this.stop);
        hSelect.put(" covered = ? ",this.covered);
        hSelect.put(" enterprise = ? ",this.enterprise);
        hSelect.put(" assurancenumber = ? ",this.assurancenumber);
        hSelect.put(" assurancetype = ? ",this.assurancetype);
        hSelect.put(" comment = ? ",this.comment);

        if (hSelect.size()>0) {
            String sSelect = "";
            try {
                PreparedStatement ps;
                sSelect = " UPDATE AdminSocSec SET updatetime = ?, updateserverid="+MedwanQuery.getInstance().getConfigInt("serverId");
                Enumeration e = hSelect.keys();
                String sKey;
                while (e.hasMoreElements()){
                    sKey = (String) e.nextElement();
                    sSelect += ","+sKey;
                }
                sSelect += " WHERE socsecid = ?";
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
                ps.setInt(iIndex,Integer.parseInt(sSocSecID));
                ps.executeUpdate();
                ps.close();
            }
            catch (Exception ex){
            	Debug.printStackTrace(ex);
                bReturn = false;
            }
        }
        return bReturn;
    }

    //--- INITIALIZE ------------------------------------------------------------------------------
    public boolean initialize (Connection connection) {
        boolean bReturn = false;
        String sSelect = "";
        if ((this.socsecid!=null)&&(this.socsecid.trim().length()>0)) {
            try {
                sSelect = "SELECT start, stop, covered, enterprise, assurancenumber, assurancetype, comment"
                         +" FROM AdminSocSec WHERE socsecid = ? ";
                PreparedStatement ps = connection.prepareStatement(sSelect);
                ps.setInt(1,Integer.parseInt(this.socsecid));
                ResultSet rs = ps.executeQuery();
                if (rs.next()) {
                    this.start = ScreenHelper.getSQLDate(rs.getDate("start"));
                    this.stop = ScreenHelper.getSQLDate(rs.getDate("stop"));
                    this.covered = ScreenHelper.checkString(rs.getString("covered"));
                    this.enterprise = ScreenHelper.checkString(rs.getString("enterprise"));
                    this.assurancenumber = ScreenHelper.checkString(rs.getString("assurancenumber"));
                    this.assurancetype = ScreenHelper.checkString(rs.getString("assurancetype"));
                    this.comment =ScreenHelper.checkString(rs.getString("comment"));
                }
                rs.close();
                ps.close();
            }
            catch(SQLException e) {
                Debug.println("AdminSocSec initialize error: "+e.getMessage()+" "+sSelect);
            }
        }
        return bReturn;
    }
}
