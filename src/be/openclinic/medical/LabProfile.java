package be.openclinic.medical;

import be.mxs.common.util.db.MedwanQuery;
import be.mxs.common.util.system.ScreenHelper;

import java.sql.Connection;
import java.sql.Timestamp;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.Hashtable;
import java.util.Vector;

/**
 * Created by IntelliJ IDEA.
 * User: mxs-rudy
 * Date: 19-feb-2007
 * Time: 13:15:54
 * To change this template use File | Settings | File Templates.
 */
public class LabProfile {
    private int profileID;
    private String profilecode;
    private String comment;
    private int updateuserid;
    private Timestamp updatetime;
    private Timestamp deletetime;


    public int getProfileID() {
        return profileID;
    }

    public void setProfileID(int profileID) {
        this.profileID = profileID;
    }

    public String getProfilecode() {
        return profilecode;
    }

    public void setProfilecode(String profilecode) {
        this.profilecode = profilecode;
    }

    public String getComment() {
        return comment;
    }

    public void setComment(String comment) {
        this.comment = comment;
    }

    public int getUpdateuserid() {
        return updateuserid;
    }

    public void setUpdateuserid(int updateuserid) {
        this.updateuserid = updateuserid;
    }

    public Timestamp getUpdatetime() {
        return updatetime;
    }

    public void setUpdatetime(Timestamp updatetime) {
        this.updatetime = updatetime;
    }

    public Timestamp getDeletetime() {
        return deletetime;
    }

    public void setDeletetime(Timestamp deletetime) {
        this.deletetime = deletetime;
    }

    public static String getProfileNameForCode(String sCode,String sWebLanguage){
        PreparedStatement ps = null;
        ResultSet rs = null;
        StringBuffer sQuery=new StringBuffer();
        String sName=sCode;
        sQuery.append("SELECT OC_LABEL_VALUE as name")
            .append(" FROM LabProfiles p, OC_LABELS l")
            .append(" WHERE "+ MedwanQuery.getInstance().convert("varchar(255)","p.profileID")+" = l.OC_LABEL_ID")
            .append("  AND l.OC_LABEL_TYPE = 'labprofiles'")
            .append("  AND l.OC_LABEL_LANGUAGE = ?")
            .append("  AND p.deletetime IS NULL")
        	.append("  AND p.profilecode=?");

        Connection loc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            ps = loc_conn.prepareStatement(sQuery.toString());
            ps.setString(1,sWebLanguage.toLowerCase());
            ps.setString(2,sCode);
            rs = ps.executeQuery();

            if(rs.next()){
            	sName=rs.getString("name");
            }
            rs.close();
            ps.close();
        }catch(Exception e){
            e.printStackTrace();
        }finally{
            try{
                if(rs!=null)rs.close();
                if(ps!=null)ps.close();
                loc_conn.close();
            }catch(Exception e){
                e.printStackTrace();
            }
        }
        return sName;
    	
    }
    
    public static Hashtable getProfiles(String sWebLanguage){
        PreparedStatement ps = null;
        ResultSet rs = null;

        Hashtable hProfiles = new Hashtable();
        LabProfile objLabProf;
        String sLabel;
        StringBuffer sQuery = new StringBuffer();
        sQuery.append("SELECT p.profileID,p.profilecode,p.profilecode"+MedwanQuery.getInstance().concatSign()+"' '"+MedwanQuery.getInstance().concatSign()+"OC_LABEL_VALUE as OC_LABEL_VALUE")
            .append(" FROM LabProfiles p, OC_LABELS l")
            .append(" WHERE "+ MedwanQuery.getInstance().convert("varchar(255)","p.profileID")+" = l.OC_LABEL_ID")
            .append("  AND l.OC_LABEL_TYPE = 'labprofiles'")
            .append("  AND l.OC_LABEL_LANGUAGE = ?")
            .append("  AND p.deletetime IS NULL order by p.profilecode");

        Connection loc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            ps = loc_conn.prepareStatement(sQuery.toString());
            ps.setString(1,sWebLanguage.toLowerCase());
            rs = ps.executeQuery();

            while(rs.next()){
                objLabProf = new LabProfile();
                objLabProf.setProfileID(rs.getInt("profileID"));
                objLabProf.setProfilecode(rs.getString("profilecode"));
                sLabel = ScreenHelper.checkString(rs.getString("OC_LABEL_VALUE"));
                hProfiles.put(sLabel,objLabProf);
            }
            rs.close();
            ps.close();
        }catch(Exception e){
            e.printStackTrace();
        }finally{
            try{
                if(rs!=null)rs.close();
                if(ps!=null)ps.close();
                loc_conn.close();
            }catch(Exception e){
                e.printStackTrace();
            }
        }
        return hProfiles;
    }

    public static boolean[] existsByProfileCode(String sProfileCode){
        PreparedStatement ps = null;
        ResultSet rs = null;

        String sSelect = "SELECT deletetime FROM LabProfiles WHERE profilecode = ?";

        int deletedRecordFound = 0;
        int unDeletedRecordFound = 1;
        boolean records[] = new boolean[2];
        records[deletedRecordFound] = false;
        records[unDeletedRecordFound] = false;

        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            ps = oc_conn.prepareStatement(sSelect);
            ps.setString(1, sProfileCode);
            rs = ps.executeQuery();

            if(rs.next()){
                if (rs.getDate("deletetime") != null) records[deletedRecordFound] = true;
                else records[unDeletedRecordFound] = true;
            }
            rs.close();
            ps.close();
        }catch(Exception e){
            e.printStackTrace();
        }finally{
            try{
                if(rs!=null)rs.close();
                if(ps!=null)ps.close();
                oc_conn.close();
            }catch(Exception e){
                e.printStackTrace();
            }
        }
        return records;
    }

    public boolean exists(){
        PreparedStatement ps = null;
        ResultSet rs = null;

        String sSelect = "SELECT 1 FROM LabProfiles WHERE profileID = ?";

        boolean bExists = false;

        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            ps = oc_conn.prepareStatement(sSelect);
            ps.setInt(1,this.getProfileID());
            rs = ps.executeQuery();

            if(rs.next()){
                bExists = true;
            }
            rs.close();
            ps.close();
        }catch(Exception e){
            e.printStackTrace();
        }finally{
            try{
                if(rs!=null)rs.close();
                if(ps!=null)ps.close();
                oc_conn.close();
            }catch(Exception e){
                e.printStackTrace();
            }
        }
        return bExists;
    }

    public void save(){
        if(this.exists()){
            this.update(this.getProfileID());
        }else{
            this.insert();
        }
    }

    public void insert(){
        PreparedStatement ps = null;

        String sInsert = " INSERT INTO LabProfiles(profileID,profilecode,comment,updateuserid,updatetime,deletetime)" +
                         " VALUES (?,?,?,?,?,?)";
        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            ps = oc_conn.prepareStatement(sInsert);
            ps.setInt(1, this.getProfileID());
            ps.setString(2,this.getProfilecode());
            ps.setString(3, ScreenHelper.setSQLString(this.getComment()));
            ps.setInt(4, this.getUpdateuserid()); // updateuserid
            ps.setTimestamp(5, ScreenHelper.getSQLTime());
            ps.setTimestamp(6, null);

            ps.executeUpdate();
            ps.close();
        }catch(Exception e){
            e.printStackTrace();
        }finally{
            try{
                if(ps!=null)ps.close();
                oc_conn.close();
            }catch(Exception e){
                e.printStackTrace();
            }
        }
    }

    public void update(int iProfileID){
        PreparedStatement ps = null;

        String sUpdate = "UPDATE LabProfiles SET" +
                        " profileID=?, profilecode=?, comment=?, updateuserid=?, updatetime=?, deletetime=?" +
                        " WHERE profileID = ?";
        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            ps = oc_conn.prepareStatement(sUpdate);
            ps.setInt(1, this.getProfileID());
            ps.setString(2,this.getProfilecode());
            ps.setString(3, ScreenHelper.setSQLString(this.getComment()));
            ps.setInt(4, this.getUpdateuserid()); // updateuserid
            ps.setTimestamp(5, ScreenHelper.getSQLTime());
            ps.setTimestamp(6, null);
            ps.setInt(7, iProfileID);

            ps.executeUpdate();
            ps.close();
        }catch(Exception e){
            e.printStackTrace();
        }finally{
            try{
                if(ps!=null)ps.close();
                oc_conn.close();
            }catch(Exception e){
                e.printStackTrace();
            }
        }
    }

    public void delete(){
        PreparedStatement ps = null;

        String sUpdate = "UPDATE LabProfiles SET deletetime = ?, updatetime = ? WHERE profileID = ?";

        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            ps = oc_conn.prepareStatement(sUpdate);
            ps.setTimestamp(1, new Timestamp(new java.util.Date().getTime())); // now
            ps.setTimestamp(2, new Timestamp(new java.util.Date().getTime())); // now
            ps.setInt(3, this.getProfileID());
            ps.executeUpdate();

            ps.close();
        }catch(Exception e){
            e.printStackTrace();
        }finally{
            try{
                if(ps!=null)ps.close();
                oc_conn.close();
            }catch(Exception e){
                e.printStackTrace();
            }
        }
    }

    public static boolean checkLabProfileLabAnalysisConnection(String sLabCodeOther,String sLabComment,String sLabID, String sProfileID, String sLabCode){
        PreparedStatement ps = null;
        ResultSet rs = null;

        String sSelect= " SELECT 1 FROM LabAnalysis la, LabProfilesAnalysis lpa" +
                        " WHERE la.labID = lpa.labID" +
                        "  AND lpa.profileID = ? and la.deletetime is null" +
                        "  AND la.labcode = ?";

        if (sLabCodeOther.equals("1")) {
            // check if labanalysis with this comment allready exists
            sSelect += " AND lpa.comment = '" + sLabComment + "'";
        } else {
            // check if labanalysis with this labID allready exists
            sSelect += " AND lpa.labID = " + sLabID;
        }

        boolean bConnected = false;

        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            ps = oc_conn.prepareStatement(sSelect);
            ps.setInt(1, Integer.parseInt(sProfileID));
            ps.setString(2, sLabCode);
            rs = ps.executeQuery();
            if (rs.next()) bConnected = true;
            rs.close();
            ps.close();
        }catch(Exception e){
            e.printStackTrace();
        }finally{
            try{
                if(rs!=null)rs.close();
                if(ps!=null)ps.close();
                oc_conn.close();
            }catch(Exception e){
                e.printStackTrace();
            }
        }

        return bConnected;
    }

    public static void updateUpdateTime(int iProfileID){
        PreparedStatement ps = null;

        String sUpdate = "UPDATE LabProfiles SET updatetime = ? where profileID = ?";

        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            ps = oc_conn.prepareStatement(sUpdate);
            ps.setTimestamp(1,ScreenHelper.getSQLTime());
            ps.setInt(2,iProfileID);

            ps.executeUpdate();
            ps.close();
        }catch(Exception e){
            e.printStackTrace();
        }finally{
            try{
                if(ps!=null)ps.close();
                oc_conn.close();
            }catch(Exception e){
                e.printStackTrace();
            }
        }
    }

    public static LabProfile getProfilesByProfileIDLabID(String sProfileCode, int iProfileID){
        PreparedStatement ps = null;
        ResultSet rs = null;

        String sSelect = "SELECT profilecode,comment FROM LabProfiles WHERE profilecode = ? AND profileID = ?";

        LabProfile labProfile = null;


        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            ps = oc_conn.prepareStatement(sSelect);
            ps.setString(1,sProfileCode);
            ps.setInt(2,iProfileID);
            rs = ps.executeQuery();

            if(rs.next() ){
                labProfile = new LabProfile();
                labProfile.setProfileID(iProfileID);
                labProfile.setProfilecode(ScreenHelper.checkString(rs.getString("profilecode")));
                labProfile.setComment(ScreenHelper.checkString(rs.getString("comment")));
            }
            rs.close();
            ps.close();
        }catch(Exception e){
            e.printStackTrace();
        }finally{
            try{
                if(rs!=null)rs.close();
                if(ps!=null)ps.close();
                oc_conn.close();
            }catch(Exception e){
                e.printStackTrace();
            }
        }

        return labProfile;
    }

    public static Vector getActiveLabProfilesByProfileCode(String sProfileCode){
        PreparedStatement ps = null;
        ResultSet rs = null;

        String profilecode = MedwanQuery.getInstance().getConfigParam("lowerCompare","profilecode");

        String sSelect = " SELECT profileID,profilecode,comment FROM LabProfiles"+
                         " WHERE "+profilecode+" LIKE ?  AND deletetime IS NULL ORDER BY "+profilecode;

        Vector vLabProfiles = new Vector();

        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            ps = oc_conn.prepareStatement(sSelect);
            ps.setString(1,"%"+sProfileCode.toLowerCase()+"%");
            rs = ps.executeQuery();
            
            LabProfile labProfile;
            while(rs.next()){
                labProfile = new LabProfile();
                labProfile.setProfileID(rs.getInt("profileID"));
                labProfile.setProfilecode(ScreenHelper.checkString(rs.getString("profilecode")));
                labProfile.setComment(ScreenHelper.checkString(rs.getString("comment")));

                vLabProfiles.addElement(labProfile);
            }
            rs.close();
            ps.close();
        }catch(Exception e){
            e.printStackTrace();
        }finally{
            try{
                if(rs!=null)rs.close();
                if(ps!=null)ps.close();
                oc_conn.close();
            }catch(Exception e){
                e.printStackTrace();
            }
        }
        return vLabProfiles;
    }

    public static Vector searchLabProfilesDataByProfileID(String sProfileID){
        PreparedStatement ps = null;
        ResultSet rs = null;

        String labcodeLower = MedwanQuery.getInstance().getConfigParam("lowerCompare","la.labcode"),
                             commentLower = MedwanQuery.getInstance().getConfigParam("lowerCompare","lap.comment");

        Vector vLabProfiles = new Vector();

        String sSelect = "SELECT lap.labID,la.labcode,la.labtype,la.labcodeother,lap.comment"+
                                " FROM LabProfiles lp, LabProfilesAnalysis lap, LabAnalysis la"+
                                " WHERE lap.profileID = lp.profileID"+
                                "  AND lap.labID = la.labID"+
                                "  AND lp.profileID = ? and la.deletetime is null"+
                                " ORDER BY "+labcodeLower+","+commentLower;

        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            ps = oc_conn.prepareStatement(sSelect);
            ps.setInt(1,Integer.parseInt(sProfileID));
            rs = ps.executeQuery();

            Hashtable hLabProfileData;

            while(rs.next()){
                hLabProfileData = new Hashtable();
                hLabProfileData.put("labID",ScreenHelper.checkString(rs.getString("labID")));
                hLabProfileData.put("labcode",ScreenHelper.checkString(rs.getString("labcode")));
                hLabProfileData.put("labtype",ScreenHelper.checkString(rs.getString("labtype")));
                hLabProfileData.put("labcodeother",ScreenHelper.checkString(rs.getString("labcodeother")));
                hLabProfileData.put("comment",ScreenHelper.checkString(rs.getString("comment")));

                vLabProfiles.addElement(hLabProfileData);
            }
            rs.close();
            ps.close();
        }catch(Exception e){
            e.printStackTrace();
        }finally{
            try{
                if(rs!=null)rs.close();
                if(ps!=null)ps.close();
                oc_conn.close();
            }catch(Exception e){
                e.printStackTrace();
            }
        }
        return vLabProfiles;
    }
    
    public static Vector searchLabProfilesDataByProfileCode(String sProfileCode){
        PreparedStatement ps = null;
        ResultSet rs = null;

        String labcodeLower = MedwanQuery.getInstance().getConfigParam("lowerCompare","la.labcode"),
                             commentLower = MedwanQuery.getInstance().getConfigParam("lowerCompare","lap.comment");

        Vector vLabProfiles = new Vector();

        String sSelect = "SELECT distinct lap.labID,la.labcode,la.labtype,la.labcodeother,lap.comment,la.monster"+
                                " FROM LabProfiles lp, LabProfilesAnalysis lap, LabAnalysis la"+
                                " WHERE lap.profileID = lp.profileID"+
                                "  AND lap.labID = la.labID"+
                                "  AND lp.profileCode = ? and la.deletetime is null"+
                                " ORDER BY "+labcodeLower+","+commentLower;

        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            ps = oc_conn.prepareStatement(sSelect);
            ps.setString(1,sProfileCode);
            rs = ps.executeQuery();

            Hashtable hLabProfileData;

            while(rs.next()){
                hLabProfileData = new Hashtable();
                hLabProfileData.put("labID",ScreenHelper.checkString(rs.getString("labID")));
                hLabProfileData.put("labcode",ScreenHelper.checkString(rs.getString("labcode")));
                hLabProfileData.put("labtype",ScreenHelper.checkString(rs.getString("labtype")));
                hLabProfileData.put("labcodeother",ScreenHelper.checkString(rs.getString("labcodeother")));
                hLabProfileData.put("comment",ScreenHelper.checkString(rs.getString("comment")));
                hLabProfileData.put("monster",ScreenHelper.checkString(rs.getString("monster")));

                vLabProfiles.addElement(hLabProfileData);
            }
            rs.close();
            ps.close();
        }catch(Exception e){
            e.printStackTrace();
        }finally{
            try{
                if(rs!=null)rs.close();
                if(ps!=null)ps.close();
                oc_conn.close();
            }catch(Exception e){
                e.printStackTrace();
            }
        }
        return vLabProfiles;
    }
}
