package be.mxs.common.util.system;

import be.mxs.common.util.db.MedwanQuery;

import javax.servlet.ServletRequest;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Timestamp;
import java.util.Date;

/**
 * User: stijn smets
 * Date: 8-mei-2006
 */
public class IntrusionDetector {

    // settings
    private static int maxIntrusionsAllowedAtLevel1 = 5, // default values
                       maxIntrusionsAllowedAtLevel2 = 6,
                       maxIntrusionsAllowedAtLevel3 = 7;

    private static int blockTimeLevel1 =  30, // default values
                       blockTimeLevel2 = 120;


    //--- SETTERS ---------------------------------------------------------------------------------
    static public void setMaxIntrusionsAllowedAtLevel1(int value){
        maxIntrusionsAllowedAtLevel1 = value;
    }

    static public void setMaxIntrusionsAllowedAtLevel2(int value){
        maxIntrusionsAllowedAtLevel2 = value;
    }

    static public void setMaxIntrusionsAllowedAtLevel3(int value){
        maxIntrusionsAllowedAtLevel3 = value;
    }

    static public void setBlockTimeLevel1(int value){
        blockTimeLevel1 = value;
    }

    static public void setBlockTimeLevel2(int value){
        blockTimeLevel2 = value;
    }

    //--- REGISTER INTRUSION ON IP ----------------------------------------------------------------
    static public int registerIntrusionOnIP(Connection conn, ServletRequest request, String sIntruderIP) {
        int value;

        // settings for IP-check
        value = MedwanQuery.getInstance().getConfigInt("IPIntrusion_MaxIntrusionsAllowedAtLevel1",5);
        if(value > -1){
            setMaxIntrusionsAllowedAtLevel1(value);
        }

        value = MedwanQuery.getInstance().getConfigInt("IPIntrusion_MaxIntrusionsAllowedAtLevel2",6);
        if(value > -1){
            setMaxIntrusionsAllowedAtLevel2(value);
        }

        value = MedwanQuery.getInstance().getConfigInt("IPIntrusion_MaxIntrusionsAllowedAtLevel3",7);
        if(value > -1){
            setMaxIntrusionsAllowedAtLevel3(value);
        }

        value = MedwanQuery.getInstance().getConfigInt("IPIntrusion_BlockTimeLevel1",30);
        if(value > -1){
            setBlockTimeLevel1(value);
        }

        value = MedwanQuery.getInstance().getConfigInt("IPIntrusion_BlockTimeLevel2",1440);
        if(value > -1){
            setBlockTimeLevel2(value);
        }

        return registerIntrusion(conn,request,sIntruderIP);
    }

    //--- REGISTER INTRUSION ON LOGIN -------------------------------------------------------------
    static public int registerIntrusionOnLogin(Connection conn, ServletRequest request, String sIntruderLogin) {
        int value;

        // settings for login-check
        value = MedwanQuery.getInstance().getConfigInt("LoginIntrusion_MaxIntrusionsAllowedAtLevel1",3);
        if(value > -1){
            setMaxIntrusionsAllowedAtLevel1(value);
        }

        value = MedwanQuery.getInstance().getConfigInt("LoginIntrusion_MaxIntrusionsAllowedAtLevel2",4);
        if(value > -1){
            setMaxIntrusionsAllowedAtLevel2(value);
        }

        value = MedwanQuery.getInstance().getConfigInt("LoginIntrusion_MaxIntrusionsAllowedAtLevel3",5);
        if(value > -1){
            setMaxIntrusionsAllowedAtLevel3(value);
        }

        value = MedwanQuery.getInstance().getConfigInt("LoginIntrusion_BlockTimeLevel1",30);
        if(value > -1){
            setBlockTimeLevel1(value);
        }

        value = MedwanQuery.getInstance().getConfigInt("LoginIntrusion_BlockTimeLevel2",1440);
        if(value > -1){
            setBlockTimeLevel2(value);
        }

        return registerIntrusion(conn,request,sIntruderLogin);
    }

    //--- REGISTER INTRUSION ----------------------------------------------------------------------
    static private int registerIntrusion(Connection conn, ServletRequest request, String sIntruderID){
        try{
            int intrusionCount = addIntrusion(conn,sIntruderID);

            // pay the bill
            if(intrusionCount >= maxIntrusionsAllowedAtLevel3){
                if(Debug.enabled){
                    Debug.println("####### INTRUSION ATTEMPT @ LEVEL 3 #######");
                    Debug.println(" intruder       : "+sIntruderID);
                    Debug.println(" intrusionCount : "+intrusionCount);
                    Debug.println(" sanction       : blocked permanently");
                    Debug.println("###########################################\n");
                }

                // only send mail when blocking the IP
                if(!isIntruderBlockedPermanently(conn,sIntruderID)){
                    blockIntruderPermanently(conn,sIntruderID);
                    String sIntrusionLocation = request.getServerName()+":"+request.getServerPort();
                    sendMailToAdmin(sIntruderID,sIntrusionLocation,0);
                }

                // blocked permanently
                return 0;
            }
            else if(intrusionCount >= maxIntrusionsAllowedAtLevel2){
                if(Debug.enabled){
                    Debug.println("####### INTRUSION ATTEMPT @ LEVEL 2 #######");
                    Debug.println(" intruder       : "+sIntruderID);
                    Debug.println(" intrusionCount : "+intrusionCount);
                    Debug.println(" sanction       : blocked for "+blockTimeLevel2+" minutes");
                    Debug.println("###########################################\n");
                }

                blockIntruderTemporarily(conn,sIntruderID,blockTimeLevel2);
                String sIntrusionLocation = request.getServerName()+":"+request.getServerPort();
                sendMailToAdmin(sIntruderID,sIntrusionLocation,blockTimeLevel2);

                return blockTimeLevel2;
            }
            else if(intrusionCount >= maxIntrusionsAllowedAtLevel1){
                if(Debug.enabled){
                    Debug.println("####### INTRUSION ATTEMPT @ LEVEL 1 #######");
                    Debug.println(" intruder       : "+sIntruderID);
                    Debug.println(" intrusionCount : "+intrusionCount);
                    Debug.println(" sanction       : blocked for "+blockTimeLevel1+" minutes");
                    Debug.println("###########################################\n");
                }

                blockIntruderTemporarily(conn,sIntruderID,blockTimeLevel1);
                String sIntrusionLocation = request.getServerName()+":"+request.getServerPort();
                sendMailToAdmin(sIntruderID,sIntrusionLocation,blockTimeLevel1);

                return blockTimeLevel1;
            }
        }
        catch(Exception e){
            e.printStackTrace();
        }

        // all OK
        return -1;
    }

    //--- SEND MAIL TO ADMIN ----------------------------------------------------------------------
    static public void sendMailToAdmin(String sIntruderID, String intrusionLocation, int blockTime) throws Exception {
        String sMailServer = MedwanQuery.getInstance().getConfigString("DefaultMailServerAddress");
        String sMailFrom   = MedwanQuery.getInstance().getConfigString("DefaultFromMailAddress");
        String sMailTo     = MedwanQuery.getInstance().getConfigString("SA.MailAddress");

        String sMailSubject = "Intrusionalert";
        String sMailMessage = "Intrusionalert at '"+intrusionLocation+"'\n"+
                              "Intruder '"+sIntruderID+"' is blocked";

        if(blockTime > 0) sMailMessage+= " for "+blockTime+" minutes.\n";
        else              sMailMessage+= " permanently.\n";

        Mail.sendMail(sMailServer,sMailFrom,sMailTo,sMailSubject,sMailMessage);
    }

    //--- ADD INTRUSION ---------------------------------------------------------------------------
    static public int addIntrusion(Connection conn, String sIntruderID) throws Exception {
        int intrusionCount = 0;

        // check if intrusion for the specified intruder allready exists
        boolean intrusionFound = false;
        String query = "SELECT 1 FROM intrusionAttempts WHERE intruderID = ?";
        PreparedStatement ps = conn.prepareStatement(query);
        ps.setString(1,sIntruderID);
        ResultSet rs = ps.executeQuery();
        if(rs.next()){
            intrusionFound = true;
        }
        if(rs!=null) rs.close();
        if(ps!=null) rs.close();

        if(!intrusionFound){
            // insert an intrusion
            query = "INSERT INTO intrusionAttempts(intruderID,intrusionCount,blocked) VALUES(?,?,?)";
            ps = conn.prepareStatement(query);
            ps.setString(1,sIntruderID);
            ps.setInt(2,1);
            ps.setString(3,"0");
            ps.executeUpdate();
            if(ps!=null) ps.close();

            intrusionCount = 1;
        }
        else{
            // update the intrusion
            query = "UPDATE intrusionAttempts SET intrusionCount = (intrusionCount + 1)"+
                    " WHERE intruderID = ?";
            ps = conn.prepareStatement(query);
            ps.setString(1,sIntruderID);
            ps.executeUpdate();
            if(ps!=null) ps.close();

            // get the new value of intrusionCount
            query = "SELECT intrusionCount FROM intrusionAttempts WHERE intruderID = ?";
            ps = conn.prepareStatement(query);
            ps.setString(1,sIntruderID);
            rs = ps.executeQuery();
            if(rs.next()){
                intrusionCount = rs.getInt("intrusionCount");
            }
            if(rs!=null) rs.close();
            if(ps!=null) ps.close();
        }

        return intrusionCount;
    }

    //--- BLOCK INTRUDER TEMPORARILY --------------------------------------------------------------
    static public void blockIntruderTemporarily(Connection conn, String sIntruderID, int blockTimeInMinutes) throws Exception {
        // set releaseTime = now + blockTimeInMinutes
        String query = "UPDATE intrusionAttempts SET releaseTime = ? WHERE intruderID = ?";
        PreparedStatement ps = conn.prepareStatement(query);
        ps.setTimestamp(1,new Timestamp(new Date().getTime()+(blockTimeInMinutes*60*1000)));
        ps.setString(2,sIntruderID);
        ps.executeUpdate();
        if(ps!=null) ps.close();
    }

    //--- BLOCK INTRUDER PERMANENTLY --------------------------------------------------------------
    static public void blockIntruderPermanently(Connection conn, String sIntruderID) throws Exception {
        // set blocked = now + blockTimeInMinutes
        String query = "UPDATE intrusionAttempts SET blocked = '1', releaseTime = NULL WHERE intruderID = ?";
        PreparedStatement ps = conn.prepareStatement(query);
        ps.setString(1,sIntruderID);
        ps.executeUpdate();
        if(ps!=null) ps.close();
    }

    //--- IS INTRUDER BLOCKED PERMANENTLY ---------------------------------------------------------
    static public boolean isIntruderBlockedPermanently(Connection conn, String sIntruderID) throws Exception {
        boolean isBlocked = false;

        String query = "SELECT 1 FROM intrusionAttempts WHERE intruderID = ? AND blocked = '1'";
        PreparedStatement ps = conn.prepareStatement(query);
        ps.setString(1,sIntruderID);
        ResultSet rs = ps.executeQuery();
        if(rs.next()){
            isBlocked = true;
        }
        if(rs!=null) rs.close();
        if(ps!=null) ps.close();

        return isBlocked;
    }

    //--- IS INTRUDER BLOCKED TEMPORARILY ---------------------------------------------------------
    static public boolean isIntruderBlockedTemporarily(Connection conn, String sIntruderID) throws Exception {
        boolean isBlocked = false;

        String query = "SELECT 1 FROM intrusionAttempts WHERE intruderID = ? AND releaseTime >= ? AND blocked <> '1'";
        PreparedStatement ps = conn.prepareStatement(query);
        ps.setString(1,sIntruderID);
        ps.setTimestamp(2,new Timestamp(new Date().getTime())); // now
        ResultSet rs = ps.executeQuery();
        if(rs.next()){
            isBlocked = true;
        }
        if(rs!=null) rs.close();
        if(ps!=null) ps.close();

        return isBlocked;
    }

    //--- CLEAR INTRUSION -------------------------------------------------------------------------
    static public void clearIntrusion(Connection conn, String sIntruderID) throws Exception {
        // reset intrusionCount for the specified intruder
        String query = "UPDATE intrusionAttempts SET intrusionCount = 0, releaseTime = NULL"+
                       " WHERE intruderID = ?";
        PreparedStatement ps = conn.prepareStatement(query);
        ps.setString(1,sIntruderID);
        ps.executeUpdate();
        if(ps!=null) ps.close();
    }

    //--- GET REMAINING BLOCK DURATION ------------------------------------------------------------
    static public int getRemainingBlockDuration(Connection conn, String sIntruderID) throws Exception {
        int remainingMinutes = -1;

        String query = "SELECT releaseTime FROM intrusionAttempts WHERE intruderID = ? AND blocked <> '1'";
        PreparedStatement ps = conn.prepareStatement(query);
        ps.setString(1,sIntruderID);
        ResultSet rs = ps.executeQuery();
        if(rs.next()){
            Timestamp releaseTime = rs.getTimestamp("releaseTime");
            if(releaseTime != null){
                Timestamp currentTime = new Timestamp((new Date()).getTime());
                remainingMinutes = 1+(int)((releaseTime.getTime() - currentTime.getTime())/60000);
            }
        }

        if(rs!=null) rs.close();
        if(ps!=null) ps.close();

        return remainingMinutes;
    }

}
