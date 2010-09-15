package be.openclinic.medical;

import be.mxs.common.util.db.MedwanQuery;
import be.mxs.common.util.system.ScreenHelper;

import java.sql.Connection;
import java.sql.Timestamp;
import java.sql.PreparedStatement;

/**
 * Created by IntelliJ IDEA.
 * User: mxs-rudy
 * Date: 22-mrt-2007
 * Time: 16:43:27
 * To change this template use File | Settings | File Templates.
 */
public class LabProfileAnalysis {
    private int profileID;
    private int labID;
    private int updateuserid;
    private Timestamp updatetime;
    private String comment;


    public int getProfileID() {
        return profileID;
    }

    public void setProfileID(int profileID) {
        this.profileID = profileID;
    }

    public int getLabID() {
        return labID;
    }

    public void setLabID(int labID) {
        this.labID = labID;
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

    public String getComment() {
        return comment;
    }

    public void setComment(String comment) {
        this.comment = comment;
    }

    public static void deleteByProfileID(int iProfileID){
        PreparedStatement ps = null;

        String sDelete = "DELETE FROM LabProfilesAnalysis WHERE profileID = ?";

        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            ps = oc_conn.prepareStatement(sDelete);
            ps.setInt(1,iProfileID);

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

    public static void deleteByProfileIDLabID(int iProfileID, int iLabID){
        PreparedStatement ps = null;

        String sDelete = "DELETE FROM LabProfilesAnalysis WHERE profileID = ? AND labID = ?";

        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            ps = oc_conn.prepareStatement(sDelete);
            ps.setInt(1,iProfileID);
            ps.setInt(2,iLabID);

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

    public void insert(){
        PreparedStatement ps = null;

        String sInsert = " INSERT INTO LabProfilesAnalysis(profileID,labID,updateuserid,updatetime,comment)" +
                         " VALUES(?,?,?,?,?)";
        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{

            ps = oc_conn.prepareStatement(sInsert);

            ps.setInt(1, this.getProfileID());
            ps.setInt(2, this.getLabID());
            ps.setInt(3, this.getUpdateuserid());
            ps.setTimestamp(4, ScreenHelper.getSQLTime());
            ps.setString(5, this.getComment());
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
}
