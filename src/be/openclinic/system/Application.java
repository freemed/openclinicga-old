package be.openclinic.system;

import be.mxs.common.util.system.Debug;
import be.mxs.common.util.system.ScreenHelper;
import be.mxs.common.util.db.MedwanQuery;

import java.security.MessageDigest;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;

public class Application {

    public static byte[] encrypt(String sValue) {
        try {
            MessageDigest md = MessageDigest.getInstance("SHA-1");
            return md.digest(sValue.getBytes());
        }
        catch (Exception e) {
            Debug.println("Application encryption error: "+e.getMessage());
        }
        return null;
    }

    public static boolean checkPassword(byte[] aPassword)  {
        try {
            if (MessageDigest.isEqual(aPassword,encrypt("ditisgeenpaswoord"))) {
                return true;
            }
        }
        catch (Exception e) {
	        Debug.println("Application checkPassword error: "+e.getMessage());
        }
        return false;
    }

    public static boolean isDisabled(String sScreenId){

        if (sScreenId.endsWith(".edit")){
            sScreenId = sScreenId.substring(0,sScreenId.length()-5);
        }
        else if (sScreenId.endsWith(".select")){
            sScreenId = sScreenId.substring(0,sScreenId.length()-7);
        }
        else if (sScreenId.endsWith(".delete")){
            sScreenId = sScreenId.substring(0,sScreenId.length()-7);
        }
        else if (sScreenId.endsWith(".add")){
            sScreenId = sScreenId.substring(0,sScreenId.length()-5);
        }
        return MedwanQuery.getInstance().getDisabledApplications().get(sScreenId)!=null;
    }

    public static boolean storeScreenId(String sScreenId){
        if (ScreenHelper.checkString(sScreenId).length()>0){
            Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
            try{
                String sSQL = "INSERT INTO Applications (ScreenId, UpdateTime) VALUES (?,?)";
                PreparedStatement ps = oc_conn.prepareStatement(sSQL);
                ps.setString(1,sScreenId.toLowerCase());
                ps.setTimestamp(2,new Timestamp(new java.util.Date().getTime()));
                ps.executeUpdate();
                ps.close();
    			oc_conn.close();
                return true;
            }
            catch (Exception e){
                e.printStackTrace();
            }
            try {
				oc_conn.close();
			} catch (SQLException e) {
				e.printStackTrace();
			}
        }
        return false;
    }

    public static boolean deleteScreens(){
        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            String sSQL = "DELETE FROM Applications";
            PreparedStatement ps = oc_conn.prepareStatement(sSQL);
            ps.executeUpdate();
            ps.close();
			oc_conn.close();
            return true;
        }
        catch (Exception e){
            e.printStackTrace();
        }
        try {
			oc_conn.close();
		} catch (SQLException e) {
			e.printStackTrace();
		}

        return false;
    }
}
