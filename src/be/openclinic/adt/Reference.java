package be.openclinic.adt;

import be.mxs.common.util.db.MedwanQuery;
import be.mxs.common.util.system.Debug;
import be.mxs.common.util.system.ScreenHelper;
import be.openclinic.common.OC_Object;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.util.Date;
import java.util.Vector;


public class Reference  extends OC_Object {
    private String patientUID;
    private Date requestDate;
    private String requestServiceUID;
    private String status;
    private Date executionDate;
    private String creationUserUID;

    private String creationServiceUID;

    public String getPatientUID() {
        return patientUID;
    }

    public void setPatientUID(String patientUID) {
        this.patientUID = patientUID;
    }

    public Date getRequestDate() {
        return requestDate;
    }

    public void setRequestDate(Date requestDate) {
        this.requestDate = requestDate;
    }

    public String getRequestServiceUID() {
        return requestServiceUID;
    }

    public void setRequestServiceUID(String requestServiceUID) {
        this.requestServiceUID = requestServiceUID;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public Date getExecutionDate() {
        return executionDate;
    }

    public void setExecutionDate(Date executionDate) {
        this.executionDate = executionDate;
    }

    public String getCreationUserUID() {
        return creationUserUID;
    }

    public void setCreationUserUID(String creationUserUID) {
        this.creationUserUID = creationUserUID;
    }

    public String getCreationServiceUID() {
        return creationServiceUID;
    }

    public void setCreationServiceUID(String creationServiceUID) {
        this.creationServiceUID = creationServiceUID;
    }

    public static Reference get(String sUId) {
        Reference reference = new Reference();
        reference.setUid(sUId);
        PreparedStatement ps = null;
        ResultSet rs = null;

        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try {
            String sSelect = "SELECT * FROM OC_REFERENCES " +
                    " WHERE OC_REFERENCE_SERVERID = ? AND OC_REFERENCE_OBJECTID = ?";
            ps = oc_conn.prepareStatement(sSelect);
            ps.setInt(1, Integer.parseInt(sUId.substring(0, sUId.indexOf("."))));
            ps.setInt(2, Integer.parseInt(sUId.substring(sUId.indexOf(".") + 1)));
            rs = ps.executeQuery();

            // get data from DB
            if (rs.next()) {
                reference.setPatientUID(rs.getString("OC_REFERENCE_PATIENTUID"));
                reference.setRequestDate(rs.getDate("OC_REFERENCE_REQUESTDATE"));
                reference.setRequestServiceUID(rs.getString("OC_REFERENCE_REQUESTSERVICEUID"));
                reference.setStatus(rs.getString("OC_REFERENCE_STATUS"));
                reference.setExecutionDate(rs.getDate("OC_REFERENCE_EXECUTIONDATE"));
                reference.setCreationUserUID(rs.getString("OC_REFERENCE_CREATEUSERUID"));
                reference.setCreationServiceUID(rs.getString("OC_REFERENCE_CREATESERVICEUID"));
                reference.setCreateDateTime(rs.getTimestamp("OC_REFERENCE_CREATETIME"));
                reference.setUpdateDateTime(rs.getTimestamp("OC_REFERENCE_UPDATETIME"));
                reference.setUpdateUser(ScreenHelper.checkString(rs.getString("OC_REFERENCE_UPDATEUID")));
            } else {
                throw new Exception("ERROR : REFERENCE " + sUId + " NOT FOUND");
            }
        }
        catch (Exception e) {
            reference = null;

            if (e.getMessage().endsWith("NOT FOUND")) {
                Debug.println(e.getMessage());
            } else {
                e.printStackTrace();
            }
        }
        finally {
            try {
                if (rs != null) rs.close();
                if (ps != null) ps.close();
                oc_conn.close();
            }
            catch (SQLException se) {
                se.printStackTrace();
            }
        }

        return reference;
    }

    public void store(){
        String[] ids;
        String sSelect = "";
        PreparedStatement ps = null;
        ResultSet rs = null;
        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            if(this.getUid() != null && this.getUid().length() > 0){
                ids = this.getUid().split("\\.");
                if(ids.length == 2){
                    sSelect = "DELETE FROM OC_REFERENCES WHERE OC_REFERENCE_SERVERID = ? AND OC_REFERENCE_OBJECTID = ? ";
                    ps = oc_conn.prepareStatement(sSelect);
                    ps.setInt(1,Integer.parseInt(ids[0]));
                    ps.setInt(2,Integer.parseInt(ids[1]));
                    ps.executeUpdate();
                    ps.close();
                }
            }
            else{
                ids = new String[] {MedwanQuery.getInstance().getConfigString("serverId"),MedwanQuery.getInstance().getOpenclinicCounter("OC_REFERENCE") + ""};
                this.setUid(ids[0]+"."+ids[1]);
            }

            if(ids.length == 2){
                sSelect = " INSERT INTO OC_REFERENCES ("+
                                " OC_REFERENCE_SERVERID,"+
                                " OC_REFERENCE_OBJECTID,"+
                                " OC_REFERENCE_PATIENTUID,"+
                                " OC_REFERENCE_REQUESTDATE,"+
                                " OC_REFERENCE_REQUESTSERVICEUID,"+
                                " OC_REFERENCE_STATUS,"+
                                " OC_REFERENCE_EXECUTIONDATE,"+
                                " OC_REFERENCE_CREATEUSERUID,"+
                                " OC_REFERENCE_CREATESERVICEUID,"+
                                " OC_REFERENCE_CREATETIME,"+
                                " OC_REFERENCE_UPDATETIME,"+
                                " OC_REFERENCE_UPDATEUID"+
                          ") " +
                          " VALUES(?,?,?,?,?,?,?,?,?,?,?,?)";

                ps = oc_conn.prepareStatement(sSelect);
                ps.setInt(1,Integer.parseInt(ids[0]));
                ps.setInt(2,Integer.parseInt(ids[1]));
                ps.setString(3,this.getPatientUID());
                ScreenHelper.getSQLTimestamp(ps,4,this.getRequestDate());
                ps.setString(5,this.getRequestServiceUID());
                ps.setString(6,this.getStatus());
                ScreenHelper.getSQLTimestamp(ps,7,this.getExecutionDate());
                ps.setString(8,this.getCreationUserUID());
                ps.setString(9,this.getCreationServiceUID());
                ScreenHelper.getSQLTimestamp(ps,10,this.getCreateDateTime());
                ps.setTimestamp(11,new Timestamp(this.getUpdateDateTime().getTime()));
                ps.setString(12,this.getUpdateUser());
                ps.executeUpdate();
                ps.close();
            }
        }
        catch(Exception e){
            e.printStackTrace();
        }
        finally{
            try{
                if(rs!=null)rs.close();
                if(ps!=null)ps.close();
                oc_conn.close();
            }
            catch(Exception e){
                Debug.println("OpenClinic => REFERENCE.java => store => "+e.getMessage()+" = "+sSelect);
                e.printStackTrace();
            }
        }
    }

    public static Vector searchByRequestServiceUID(String sFindBegin, String sFindEnd, String sRequestServiceUID){
        PreparedStatement ps = null;
        ResultSet rs = null;

        Vector vReferences = new Vector();

        String sSelect = " SELECT OC_REFERENCE_SERVERID, OC_REFERENCE_OBJECTID, OC_REFERENCE_PATIENTUID, OC_REFERENCE_REQUESTDATE, "
            +" OC_REFERENCE_STATUS, OC_REFERENCE_EXECUTIONDATE, OC_REFERENCE_CREATESERVICEUID, OC_REFERENCE_CREATEUSERUID "
            +" FROM OC_REFERENCES WHERE OC_REFERENCE_REQUESTSERVICEUID = ? AND ";
        String sSelect1 = " OC_REFERENCE_REQUESTDATE BETWEEN ? AND ?  ORDER BY OC_REFERENCE_REQUESTDATE ";
        String sSelect2 = " OC_REFERENCE_REQUESTDATE >= ? ORDER BY OC_REFERENCE_REQUESTDATE";
        String sSelect3 = " OC_REFERENCE_REQUESTDATE <= ? ORDER BY OC_REFERENCE_REQUESTDATE ";

        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            if ((sFindBegin.trim().length()>0)&&(sFindEnd.trim().length()>0)){
                java.sql.Date dEnd = ScreenHelper.getSQLDate(ScreenHelper.getDateAdd(sFindEnd, "2"));
                sSelect += sSelect1;
                ps = oc_conn.prepareStatement(sSelect);
                ps.setString(1,sRequestServiceUID);
                ps.setDate(2,ScreenHelper.getSQLDate(sFindBegin));
                ps.setDate(3,dEnd);
            }
            else if (sFindBegin.trim().length()>0){
                sSelect += sSelect2;
                ps = oc_conn.prepareStatement(sSelect);
                ps.setString(1,sRequestServiceUID);
                ps.setDate(2,ScreenHelper.getSQLDate(sFindBegin));
            }
            else if (sFindEnd.trim().length()>0){
                java.sql.Date dEnd = ScreenHelper.getSQLDate(ScreenHelper.getDateAdd(sFindEnd, "2"));
                sSelect += sSelect3;
                ps = oc_conn.prepareStatement(sSelect);
                ps.setString(1,sRequestServiceUID);
                ps.setDate(2,dEnd);
            }

            rs = ps.executeQuery();
            Reference reference;
            while(rs.next()){
                reference = new Reference();
                reference.setUid(rs.getString("OC_REFERENCE_SERVERID")+"."+rs.getString("OC_REFERENCE_OBJECTID"));
                reference.setPatientUID(rs.getString("OC_REFERENCE_PATIENTUID"));
                reference.setRequestDate(rs.getDate("OC_REFERENCE_REQUESTDATE"));
                reference.setRequestServiceUID(sRequestServiceUID);
                reference.setStatus(rs.getString("OC_REFERENCE_STATUS"));
                reference.setExecutionDate(rs.getDate("OC_REFERENCE_EXECUTIONDATE"));
                reference.setCreationServiceUID(rs.getString("OC_REFERENCE_CREATESERVICEUID"));
                reference.setCreationUserUID(rs.getString("OC_REFERENCE_CREATEUSERUID"));

                vReferences.addElement(reference);
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

        return vReferences;
    }

    public static Vector searchByCreateServiceUID(String sFindBegin, String sFindEnd, String sCreateServiceUID){
        PreparedStatement ps = null;
        ResultSet rs = null;

        Vector vReferences = new Vector();

        String sSelect = " SELECT OC_REFERENCE_SERVERID, OC_REFERENCE_OBJECTID, OC_REFERENCE_PATIENTUID, OC_REFERENCE_REQUESTDATE, "
            +" OC_REFERENCE_STATUS, OC_REFERENCE_EXECUTIONDATE, OC_REFERENCE_REQUESTSERVICEUID, OC_REFERENCE_CREATEUSERUID "
            +" FROM OC_REFERENCES WHERE OC_REFERENCE_CREATESERVICEUID = ? AND ";
        String sSelect1 = " OC_REFERENCE_REQUESTDATE BETWEEN ? AND ?  ORDER BY OC_REFERENCE_REQUESTDATE ";
        String sSelect2 = " OC_REFERENCE_REQUESTDATE >= ? ORDER BY OC_REFERENCE_REQUESTDATE";
        String sSelect3 = " OC_REFERENCE_REQUESTDATE <= ? ORDER BY OC_REFERENCE_REQUESTDATE ";

        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            if ((sFindBegin.trim().length()>0)&&(sFindEnd.trim().length()>0)){
                java.sql.Date dEnd = ScreenHelper.getSQLDate(ScreenHelper.getDateAdd(sFindEnd, "2"));
                sSelect += sSelect1;
                ps = oc_conn.prepareStatement(sSelect);
                ps.setString(1,sCreateServiceUID);
                ps.setDate(2,ScreenHelper.getSQLDate(sFindBegin));
                ps.setDate(3,dEnd);
            }
            else if (sFindBegin.trim().length()>0){
                sSelect += sSelect2;
                ps = oc_conn.prepareStatement(sSelect);
                ps.setString(1,sCreateServiceUID);
                ps.setDate(2,ScreenHelper.getSQLDate(sFindBegin));
            }
            else if (sFindEnd.trim().length()>0){
                java.sql.Date dEnd = ScreenHelper.getSQLDate(ScreenHelper.getDateAdd(sFindEnd, "2"));
                sSelect += sSelect3;
                ps = oc_conn.prepareStatement(sSelect);
                ps.setString(1,sCreateServiceUID);
                ps.setDate(2,dEnd);
            }

            rs = ps.executeQuery();
            Reference reference;
            while(rs.next()){
                reference = new Reference();
                reference.setUid(rs.getString("OC_REFERENCE_SERVERID")+"."+rs.getString("OC_REFERENCE_OBJECTID"));
                reference.setPatientUID(rs.getString("OC_REFERENCE_PATIENTUID"));
                reference.setRequestDate(rs.getDate("OC_REFERENCE_REQUESTDATE"));
                reference.setRequestServiceUID(rs.getString("OC_REFERENCE_REQUESTSERVICEUID"));
                reference.setStatus(rs.getString("OC_REFERENCE_STATUS"));
                reference.setExecutionDate(rs.getDate("OC_REFERENCE_EXECUTIONDATE"));
                reference.setCreationServiceUID(sCreateServiceUID);
                reference.setCreationUserUID(rs.getString("OC_REFERENCE_CREATEUSERUID"));

                vReferences.addElement(reference);
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

        return vReferences;
    }
}
