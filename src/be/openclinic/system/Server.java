package be.openclinic.system;

import be.mxs.common.util.db.MedwanQuery;
import be.mxs.common.util.system.ScreenHelper;

import java.sql.Connection;
import java.sql.Timestamp;
import java.sql.ResultSet;
import java.sql.PreparedStatement;
import java.util.Vector;

/**
 * Created by IntelliJ IDEA.
 * User: mxs_david
 * Date: 8-jan-2007
 * Time: 11:43:36
 * To change this template use Options | File Templates.
 */
public class Server {
    private String serverId;
    private String serverName;
    private String fromServerDirectory;
    private String toServerDirectory;
    private int updateuserid;
    private Timestamp updatetime;
    private Timestamp deletetime;


    public Timestamp getDeletetime() {
        return deletetime;
    }

    public void setDeletetime(Timestamp deletetime) {
        this.deletetime = deletetime;
    }

    public String getServerId() {
        return serverId;
    }

    public void setServerId(String serverId) {
        this.serverId = serverId;
    }

    public String getServerName() {
        return serverName;
    }

    public void setServerName(String serverName) {
        this.serverName = serverName;
    }

    public String getFromServerDirectory() {
        return fromServerDirectory;
    }

    public void setFromServerDirectory(String fromServerDirectory) {
        this.fromServerDirectory = fromServerDirectory;
    }

    public String getToServerDirectory() {
        return toServerDirectory;
    }

    public void setToServerDirectory(String toServerDirectory) {
        this.toServerDirectory = toServerDirectory;
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

    public static boolean exists(String sServerName){
        PreparedStatement ps = null;
        ResultSet rs = null;

        boolean bServerExists = false;

        String sSelect = "SELECT serverId FROM Servers WHERE serverName = ? AND deletetime IS NULL";

        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            ps = oc_conn.prepareStatement(sSelect);
            ps.setString(1,sServerName);

            rs = ps.executeQuery();

            if (rs.next()) {
            bServerExists = true;
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

        return bServerExists;
    }

    public static void addServer(Server objServer){
        PreparedStatement ps = null;

        String sInsert = " INSERT INTO Servers (serverId, serverName, fromServerDirectory, toServerDirectory,"+
                         " updateuserid, updatetime) VALUES (?,?,?,?,?,?)";

        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            ps = oc_conn.prepareStatement(sInsert);
            ps.setString(1,objServer.getServerId());
            ps.setString(2,objServer.getServerName());
            ps.setString(3,objServer.getFromServerDirectory());
            ps.setString(4,objServer.getToServerDirectory());
            ps.setInt(5,objServer.getUpdateuserid());
            ps.setTimestamp(6,objServer.getUpdatetime());

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

    public static void saveServer(Server objServer, String sFindID){
        PreparedStatement ps = null;

        String sUpdate = " UPDATE Servers SET serverId = ?, serverName = ?, fromServerDirectory = ?,"+
                         " toServerDirectory = ?, updateuserid = ?, updatetime = ?"+
                         " WHERE serverId = ? ";

        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{

            ps = oc_conn.prepareStatement(sUpdate);
            ps.setString(1,objServer.getServerId());
            ps.setString(2,objServer.getServerName());
            ps.setString(3,objServer.getFromServerDirectory());
            ps.setString(4,objServer.getToServerDirectory());
            ps.setInt(5,objServer.getUpdateuserid());
            ps.setTimestamp(6,objServer.getUpdatetime());
            ps.setString(7,sFindID);
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

    public static void deleteServer(String sServerId){
        PreparedStatement ps = null;

        String sDelete = "UPDATE Servers SET deletetime = ? WHERE serverId = ?";

        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            ps = oc_conn.prepareStatement(sDelete);
            ps.setDate(1,ScreenHelper.getSQLDate(ScreenHelper.getDate()));
            ps.setString(2,sServerId);
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

    public static Vector selectServersAsOption(){
        PreparedStatement ps = null;
        ResultSet rs = null;

        Vector vSO = new Vector();
        Server objServer;

        String sSelect = " SELECT serverId, serverName, fromServerDirectory, toServerDirectory FROM Servers"+
                         " WHERE deletetime is null ORDER BY serverId ";

        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            ps = oc_conn.prepareStatement(sSelect);
            rs = ps.executeQuery();

            while(rs.next()){
                objServer = new Server();

                objServer.setServerId(ScreenHelper.checkString(rs.getString("serverId")));
                objServer.setServerName(ScreenHelper.checkString(rs.getString("serverName")));
                objServer.setFromServerDirectory(ScreenHelper.checkString(rs.getString("fromServerDirectory")));
                objServer.setToServerDirectory(ScreenHelper.checkString(rs.getString("toServerDirectory")));

                vSO.addElement(objServer);
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

        return vSO;
    }

    public static String getServerNameByServerId(String serverid){
        PreparedStatement ps = null;
        ResultSet rs = null;

        String sSelect = "SELECT serverName FROM Servers WHERE serverId = ?";
        String sValue = "";

        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            ps = oc_conn.prepareStatement(sSelect);
            ps.setString(1,serverid);

            rs = ps.executeQuery();
            if(rs.next()){
                sValue = ScreenHelper.checkString(rs.getString("serverName"));
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
        return sValue;
    }

    public static Vector getServerUsers(String sServerNr){
        PreparedStatement ps = null;
        ResultSet rs = null;

        Vector vUsers = new Vector();

        String sSelect = "SELECT a.lastname,a.firstname " +
                         "FROM UserParameters up, Users u,Admin a " +
                         "WHERE up.parameter = 'computernumber' " +
                         "AND up.value = ? " +
                         "AND up.userid = u.userid " +
                         "AND u.personid = a.personid";

    	Connection ad_conn = MedwanQuery.getInstance().getAdminConnection();
        try{
            ps = ad_conn.prepareStatement(sSelect);
            ps.setString(1,sServerNr);
            rs = ps.executeQuery();
            String lastname, firstname;
            while(rs.next()){
                lastname = ScreenHelper.checkString(rs.getString("lastname"));
                firstname = ScreenHelper.checkString(rs.getString("firstname"));
                vUsers.addElement(lastname + " " + firstname);
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
        return vUsers;
    }

    public static Vector getServerEmails(String sServerNr){
        PreparedStatement ps = null;
        ResultSet rs = null;

        Vector vEmails = new Vector();

        String sSelect = "";

    	Connection ad_conn = MedwanQuery.getInstance().getAdminConnection();
        try{
            ps = ad_conn.prepareStatement(sSelect);
            ps.setString(1,sServerNr);
            rs = ps.executeQuery();

            while(rs.next()){
                vEmails.addElement(ScreenHelper.checkString(rs.getString("email")));
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
        return vEmails;
    }
}
