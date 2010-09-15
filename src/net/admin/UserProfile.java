package net.admin;

import be.mxs.common.util.db.MedwanQuery;
import be.mxs.common.util.system.ScreenHelper;

import java.sql.Connection;
import java.sql.Timestamp;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.Vector;
import java.util.Hashtable;


/**
 * Created by IntelliJ IDEA.
 * User: mxs-rudy
 * Date: 13-mrt-2007
 */
public class UserProfile {
    private int userprofileid;
    private String userprofilename;
    private Timestamp updatetime;


    public int getUserprofileid() {
        return userprofileid;
    }

    public void setUserprofileid(int userprofileid) {
        this.userprofileid = userprofileid;
    }

    public String getUserprofilename() {
        return userprofilename;
    }

    public void setUserprofilename(String userprofilename) {
        this.userprofilename = userprofilename;
    }

    public Timestamp getUpdatetime() {
        return updatetime;
    }

    public void setUpdatetime(Timestamp updatetime) {
        this.updatetime = updatetime;
    }

    public static Vector getUserProfiles(){
        PreparedStatement ps = null;
        ResultSet rs = null;

        Vector vUserProfiles = new Vector();

        String sSelect = "SELECT userprofileid, userprofilename FROM UserProfiles ORDER by userprofilename";

    	Connection ad_conn = MedwanQuery.getInstance().getAdminConnection();
        try{
            ps = ad_conn.prepareStatement(sSelect);
            rs = ps.executeQuery();

            UserProfile userProfile;

            while(rs.next()){
                userProfile = new UserProfile();
                userProfile.setUserprofileid(rs.getInt("userprofileid"));
                userProfile.setUserprofilename(ScreenHelper.checkString(rs.getString("userprofilename")));

                vUserProfiles.addElement(userProfile);
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
        return vUserProfiles;
    }

    public static Vector getProfileOwnersByProfileId(String sProfileId, String sOrderField){
        PreparedStatement ps = null;
        ResultSet rs = null;

        Vector vProfileOwners = new Vector();
        Hashtable hProfileOwner;

        String sSelect = "SELECT a.personid, a.lastname, a.firstname, u.userid AS userID"
                                  +" FROM Admin a, Users u, UserParameters p"
                                  +"  WHERE p.parameter = 'userprofileid'"
                                  +"   AND p.value = ? AND u.userid = p.userid AND a.personid = u.personid "
                                  +"   AND p.active = 1";

        if(sOrderField.length() > 0) sSelect+= " ORDER BY "+sOrderField;
        else                         sSelect+= " ORDER BY a.searchname";

    	Connection ad_conn = MedwanQuery.getInstance().getAdminConnection();
        try{
            ps = ad_conn.prepareStatement(sSelect);
            ps.setString(1, sProfileId);
            rs = ps.executeQuery();

            while(rs.next()){
                hProfileOwner = new Hashtable();
                hProfileOwner.put("personid",ScreenHelper.checkString(rs.getString("personid")));
                hProfileOwner.put("lastname",ScreenHelper.checkString(rs.getString("lastname")));
                hProfileOwner.put("firstname",ScreenHelper.checkString(rs.getString("firstname")));
                hProfileOwner.put("userid",ScreenHelper.checkString(rs.getString("userID")));

                vProfileOwners.addElement(hProfileOwner);
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
        return vProfileOwners;
    }

    public static Vector getProfileOwnersByApplication(String sApplication, String sOrderField){
        PreparedStatement ps = null;
        ResultSet rs = null;

        Vector vProfileOwners = new Vector();
        Hashtable hProfileOwner;

        String sSelect = "SELECT a.personid, a.lastname, a.firstname, u.userid AS userID"
                                 +" FROM Admin a, Users u, AccessRights p"
                                 +"  WHERE "+MedwanQuery.getInstance().getConfigParam("lowerCompare","p.accessright")+" LIKE ?"
                                 +"   AND u.userid = p.userid AND a.personid = u.personid"
                                 +"   AND p.active = 1 ";

        if(sOrderField.length() > 0) sSelect+= " ORDER BY "+sOrderField;
        else                         sSelect+= " ORDER BY a.searchname";

    	Connection ad_conn = MedwanQuery.getInstance().getAdminConnection();
        try{
            ps = ad_conn.prepareStatement(sSelect);
            ps.setString(1,sApplication.toLowerCase()+"%");
            rs = ps.executeQuery();

            while(rs.next()){
                hProfileOwner = new Hashtable();
                hProfileOwner.put("personid",ScreenHelper.checkString(rs.getString("personid")));
                hProfileOwner.put("lastname",ScreenHelper.checkString(rs.getString("lastname")));
                hProfileOwner.put("firstname",ScreenHelper.checkString(rs.getString("firstname")));
                hProfileOwner.put("userid",ScreenHelper.checkString(rs.getString("userID")));

                vProfileOwners.addElement(hProfileOwner);
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
        return vProfileOwners;
    }

    public void insert(){
        PreparedStatement ps = null;

        String sInsert = "INSERT INTO UserProfiles (userprofilename, updatetime, userprofileid) VALUES (?,?,?)";

    	Connection ad_conn = MedwanQuery.getInstance().getAdminConnection();
        try{
            ps = ad_conn.prepareStatement(sInsert);
            ps.setString(1,this.userprofilename);
            ps.setTimestamp(2,this.updatetime);
            ps.setInt(3,this.userprofileid);

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

    public void update(){
        PreparedStatement ps = null;

        String sUpdate = "UPDATE UserProfiles SET userprofilename = ?, updatetime = ? WHERE userprofileid = ?";

    	Connection ad_conn = MedwanQuery.getInstance().getAdminConnection();
        try{
            ps = ad_conn.prepareStatement(sUpdate);
            ps.setString(1,this.userprofilename);
            ps.setTimestamp(2,this.updatetime);
            ps.setInt(3,this.userprofileid);

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

    //--- REMOVE PREMISSIONS ----------------------------------------------------------------------
    public void removePermissions(){
        PreparedStatement ps = null;

    	Connection ad_conn = MedwanQuery.getInstance().getAdminConnection();
        try{
            String sUpdate = "DELETE FROM UserProfilePermissions"+
                             " WHERE userprofileid = ?";
            ps = ad_conn.prepareStatement(sUpdate);
            ps.setInt(1,this.userprofileid);

            ps.executeUpdate();
            ps.close();
        }
        catch(Exception e){
            e.printStackTrace();
        }
        finally{
            try{
                if(ps!=null) ps.close();
                ad_conn.close();
            }
            catch(Exception e){
                e.printStackTrace();
            }
        }
    }
     //--- REMOVE USER PREMISSION ----------------------------------------------------------------------
    public static int removeUserPermissionByPermissionId(String permissionId){
        PreparedStatement ps = null;
        int valid = 0;
    	Connection ad_conn = MedwanQuery.getInstance().getAdminConnection();
        try{
            Vector vProfiles = UserProfile.getProfileOwnersByProfileId(permissionId,"");
             if(vProfiles.size()==0){
             String sUpdate = "DELETE FROM UserProfiles"+
                             " WHERE userprofileid = ?";
              ps = ad_conn.prepareStatement(sUpdate);
              ps.setInt(1, Integer.parseInt(permissionId));
              ps.executeUpdate();
              ps.close();
              valid = 1;
            }
        }
        catch(Exception e){
            valid = 0;
            e.printStackTrace();
        }
        finally{
            try{
                if(ps!=null) ps.close();
                ad_conn.close();
            }
            catch(Exception e){
                e.printStackTrace();
            }
        }
         return valid;
    }
}
