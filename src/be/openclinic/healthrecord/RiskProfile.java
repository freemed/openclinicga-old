package be.openclinic.healthrecord;

import be.mxs.common.util.system.ScreenHelper;
import java.sql.*;

public class RiskProfile {
    private int profileId;
    private Date dateBegin;
    private Date dateEnd;
    private int personId;
    private Date updatetime;
    private String comment;
    private int updateserverid;

    public int getProfileId() {
        return profileId;
    }

    public void setProfileId(int profileId) {
        this.profileId = profileId;
    }

    public Date getDateBegin() {
        return dateBegin;
    }

    public void setDateBegin(Date dateBegin) {
        this.dateBegin = dateBegin;
    }

    public Date getDateEnd() {
        return dateEnd;
    }

    public void setDateEnd(Date dateEnd) {
        this.dateEnd = dateEnd;
    }

    public int getPersonId() {
        return personId;
    }

    public void setPersonId(int personId) {
        this.personId = personId;
    }

    public Date getUpdatetime() {
        return updatetime;
    }

    public void setUpdatetime(Date updatetime) {
        this.updatetime = updatetime;
    }

    public String getComment() {
        return comment;
    }

    public void setComment(String comment) {
        this.comment = comment;
    }

    public int getUpdateserverid() {
        return updateserverid;
    }

    public void setUpdateserverid(int updateserverid) {
        this.updateserverid = updateserverid;
    }

    public static RiskProfile selectActiveRiskProfile(int personId, Connection destination){
        PreparedStatement ps = null;
        ResultSet rs = null;

        RiskProfile rProfile  = null;

        String sSelect = "select * from RiskProfiles where dateEnd is null and personId=?";

        try{
            ps = destination.prepareStatement(sSelect);
            ps.setInt(1,personId);
            rs = ps.executeQuery();

            if(rs.next()){
                rProfile.setProfileId(rs.getInt("profileId"));
                rProfile.setDateBegin(rs.getDate("dateBegin"));
                rProfile.setDateEnd(rs.getDate("dateEnd"));
                rProfile.setComment(rs.getString("comment"));
                rProfile.setPersonId(rs.getInt("personID"));
                rProfile.setUpdateserverid(rs.getInt("updateserverid"));
                rProfile.setUpdatetime(rs.getDate("updatetime"));
            }
            rs.close();
            ps.close();

        }catch(Exception e){
            e.printStackTrace();
        }finally{
            try{
                if(rs!=null)rs.close();
                if(ps!=null)ps.close();
            }catch(Exception e){
                e.printStackTrace();
            }
        }

        return rProfile;
    }

    public static void archiveRiskProfile(int personId, String dateEnd,Connection destination){
        PreparedStatement ps = null;

        String sUpdate = "update RiskProfiles set dateEnd = ? where personId = ?";

        try{
            ps = destination.prepareStatement(sUpdate);
            ps.setInt(1,personId);
            ps.setTimestamp(2,new Timestamp(ScreenHelper.getSQLDate(dateEnd).getTime()));

            ps.executeUpdate();
            ps.close();
        }catch(Exception e){
            e.printStackTrace();
        }finally{
            try{
                if(ps!=null)ps.close();
            }catch(Exception e){
                e.printStackTrace();
            }
        }
    }
}
