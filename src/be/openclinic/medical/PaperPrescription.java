package be.openclinic.medical;

import net.admin.AdminPerson;
import net.admin.Service;

import java.util.Date;
import java.util.Vector;
import java.sql.*;

import be.mxs.common.util.db.MedwanQuery;
import be.mxs.common.util.system.ScreenHelper;
import be.mxs.common.util.system.Debug;
import be.openclinic.common.OC_Object;

public class PaperPrescription extends OC_Object {
    private AdminPerson patient;
    private AdminPerson prescriber;
    private Date begin;
    private String content;

    public String getContent() {
        return content;
    }

    public void setContent(String content) {
        this.content = content;
    }// non-db data
    private String patientUid;
    private String prescriberUid;

    public AdminPerson getPatient() {
        if(patientUid!=null && patientUid.length() > 0){
            if(patient==null){
            	Connection ad_conn = MedwanQuery.getInstance().getAdminConnection();
                this.setPatient(AdminPerson.getAdminPerson(ad_conn,patientUid));
                try {
					ad_conn.close();
				} catch (SQLException e) {
					// TODO Auto-generated catch block
					e.printStackTrace();
				}
            }
        }

        return patient;
    }

    public void setPatient(AdminPerson patient) {
        this.patient = patient;
    }

    public AdminPerson getPrescriber() {
        if(prescriberUid!=null && prescriberUid.length()>0){
            if(prescriber==null){
            	Connection ad_conn = MedwanQuery.getInstance().getAdminConnection();
                this.setPrescriber(AdminPerson.getAdminPerson(ad_conn,MedwanQuery.getInstance().getPersonIdFromUserId(Integer.parseInt(prescriberUid))+""));
                try {
					ad_conn.close();
				} catch (SQLException e) {
					// TODO Auto-generated catch block
					e.printStackTrace();
				}
            }
        }

        return prescriber;
    }

    public void setPrescriber(AdminPerson prescriber) {
        this.prescriber = prescriber;
    }

    public Date getBegin() {
        return begin;
    }

    public void setBegin(Date begin) {
        this.begin = begin;
    }

    public String getPatientUid() {
        return patientUid;
    }

    public void setPatientUid(String patientUid) {
        this.patientUid = patientUid;
    }

    public String getPrescriberUid() {
        return prescriberUid;
    }

    public void setPrescriberUid(String prescriberUid) {
        this.prescriberUid = prescriberUid;
    }

    public static PaperPrescription get(String prescrUid){
        PaperPrescription prescr = new PaperPrescription();
        prescr.setUid(prescrUid);
        PreparedStatement ps = null;
        ResultSet rs = null;

        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            String sSelect = "SELECT * FROM OC_PAPERPRESCRIPTIONS"+
                             " WHERE OC_PP_SERVERID = ? AND OC_PP_OBJECTID = ?";
            ps = oc_conn.prepareStatement(sSelect);
            ps.setInt(1,Integer.parseInt(prescrUid.substring(0,prescrUid.indexOf("."))));
            ps.setInt(2,Integer.parseInt(prescrUid.substring(prescrUid.indexOf(".")+1)));
            rs = ps.executeQuery();

            // get data from DB
            if(rs.next()){
                prescr.setPatientUid(rs.getString("OC_PP_PATIENTUID"));
                prescr.setPrescriberUid(rs.getString("OC_PP_PRESCRIBERUID"));

                // begin date
                java.util.Date tmpDate = rs.getDate("OC_PP_DATE");
                if(tmpDate!=null) prescr.setBegin(tmpDate);

                // OBJECT variables
                prescr.setCreateDateTime(rs.getTimestamp("OC_PP_CREATETIME"));
                prescr.setUpdateDateTime(rs.getTimestamp("OC_PP_UPDATETIME"));
                prescr.setUpdateUser(ScreenHelper.checkString(rs.getString("OC_PP_UPDATEUID")));
                prescr.setVersion(rs.getInt("OC_PP_VERSION"));
                prescr.setContent(rs.getString("OC_PP_CONTENT"));
            }
            else{
                throw new Exception("ERROR : PAPERPRESCRIPTION "+prescrUid+" NOT FOUND");
            }
        }
        catch(Exception e){
            prescr = null;

            if(e.getMessage().endsWith("NOT FOUND")){
                Debug.println(e.getMessage());
            }
            else{
                e.printStackTrace();
            }
        }
        finally{
            try{
                if(rs!=null) rs.close();
                if(ps!=null) ps.close();
                oc_conn.close();
            }
            catch(SQLException se){
                se.printStackTrace();
            }
        }

        return prescr;
    }

    public void store(){
        PreparedStatement ps = null;
        ResultSet rs = null;
        String sSelect;

        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            if(this.getUid().equals("-1")){
                //***** INSERT *****
                if(Debug.enabled) Debug.println("@@@ PAPERPRESCRIPTION insert @@@");

                sSelect = "INSERT INTO OC_PAPERPRESCRIPTIONS (OC_PP_SERVERID,OC_PP_OBJECTID,OC_PP_PATIENTUID,"+
                          "  OC_PP_PRESCRIBERUID,OC_PP_DATE,"+
                          "  OC_PP_CREATETIME,OC_PP_UPDATETIME,OC_PP_UPDATEUID,OC_PP_VERSION,OC_PP_CONTENT)"+
                          " VALUES(?,?,?,?,?,?,?,?,1,?)";

                ps = oc_conn.prepareStatement(sSelect);

                // set new prescriptionuid
                int serverId = MedwanQuery.getInstance().getConfigInt("serverId");
                int prescrCounter = MedwanQuery.getInstance().getOpenclinicCounter("OC_PAPERPRESCRIPTIONS");
                ps.setInt(1,serverId);
                ps.setInt(2,prescrCounter);
                this.setUid(serverId+"."+prescrCounter);

                ps.setString(3,this.getPatientUid());
                ps.setString(4,this.getPrescriberUid());

                // date begin
                if(this.begin!=null) ps.setTimestamp(5,new java.sql.Timestamp(this.begin.getTime()));
                else                 ps.setNull(5, Types.TIMESTAMP);

                // OBJECT variables
                ps.setTimestamp(6,new Timestamp(new java.util.Date().getTime())); // now
                ps.setTimestamp(7,new Timestamp(new java.util.Date().getTime())); // now
                ps.setString(8,this.getUpdateUser());
                ps.setString(9,this.getContent());

                ps.executeUpdate();
            }
            else{
                //***** UPDATE *****
                if(Debug.enabled) Debug.println("@@@ PAPERPRESCRIPTION update @@@");

                sSelect = "UPDATE OC_PAPERPRESCRIPTIONS SET OC_PP_PATIENTUID=?, OC_PP_PRESCRIBERUID=?,"+
                          "  OC_PP_DATE=?,"+
                          "  OC_PP_UPDATETIME=?, OC_PP_UPDATEUID=?, OC_PP_VERSION=(OC_PP_VERSION+1),OC_PP_CONTENT=?"+
                          " WHERE OC_PP_SERVERID=? AND OC_PP_OBJECTID=?";

                ps = oc_conn.prepareStatement(sSelect);
                ps.setString(1,this.getPatientUid());
                ps.setString(2,this.getPrescriberUid());

                // date begin
                if(this.begin!=null) ps.setTimestamp(3,new java.sql.Timestamp(this.begin.getTime()));
                else                 ps.setNull(3,Types.TIMESTAMP);

                // OBJECT variables
                ps.setTimestamp(4,new Timestamp(new java.util.Date().getTime())); // now
                ps.setString(5,this.getUpdateUser());
                ps.setString(6,this.getContent());

                ps.setInt(7,Integer.parseInt(this.getUid().substring(0,this.getUid().indexOf("."))));
                ps.setInt(8,Integer.parseInt(this.getUid().substring(this.getUid().indexOf(".")+1)));

                ps.executeUpdate();
            }
        }
        catch(Exception e){
            e.printStackTrace();
        }
        finally{
            try{
                if(rs!=null) rs.close();
                if(ps!=null) ps.close();
                oc_conn.close();
            }
            catch(SQLException se){
                se.printStackTrace();
            }
        }
    }

    public static void delete(String prescrUid){
        PreparedStatement ps = null;

        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            String sSelect = "DELETE FROM OC_PAPERPRESCRIPTIONS"+
                             " WHERE OC_PP_SERVERID = ? AND OC_PP_OBJECTID = ?";
            ps = oc_conn.prepareStatement(sSelect);
            ps.setInt(1,Integer.parseInt(prescrUid.substring(0,prescrUid.indexOf("."))));
            ps.setInt(2,Integer.parseInt(prescrUid.substring(prescrUid.indexOf(".")+1)));
            ps.executeUpdate();
        }
        catch(Exception e){
            e.printStackTrace();
        }
        finally{
            try{
                if(ps!=null) ps.close();
                oc_conn.close();
            }
            catch(SQLException se){
                se.printStackTrace();
            }
        }
    }

    public static Vector find(String sFindPatientUid, String sFindPrescriberUid,
                              String sFindDateBegin, String sFindDateEnd,
                              String sSortCol, String sSortDir){
        Vector foundObjects = new Vector();
        PreparedStatement ps = null;
        ResultSet rs = null;

        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            String sSelect = "SELECT OC_PP_SERVERID, OC_PP_OBJECTID"+
                             " FROM OC_PAPERPRESCRIPTIONS ";

            if(sFindPatientUid.length()>0 || sFindPrescriberUid.length()>0 ||
               sFindDateBegin.length()>0){
                sSelect+= "WHERE ";

                if(sFindPatientUid.length() > 0)    sSelect+= "OC_PP_PATIENTUID = ? AND ";
                if(sFindPrescriberUid.length() > 0) sSelect+= "OC_PP_PRESCRIBERUID = ? AND ";
                if(sFindDateBegin.length() > 0)     sSelect+= "OC_PP_DATE >= ? AND ";
                if(sFindDateEnd.length() > 0)     sSelect+= "OC_PP_DATE <= ? AND ";

                // remove last AND if any
                if(sSelect.indexOf("AND ")>0){
                    sSelect = sSelect.substring(0,sSelect.lastIndexOf("AND "));
                }
            }

            if(sSortCol.length()==0){
                sSortCol="OC_PP_DATE";
            }
            if(sSortDir.length()==0){
                sSortDir="ASC";
            }
            // order by selected col or default col
            sSelect+= "ORDER BY "+sSortCol+" "+sSortDir;
            ps = oc_conn.prepareStatement(sSelect);

            // set questionmark values
            int questionMarkIdx = 1;
            if(sFindPatientUid.length() > 0)    ps.setString(questionMarkIdx++,sFindPatientUid);
            if(sFindPrescriberUid.length() > 0) ps.setString(questionMarkIdx++,sFindPrescriberUid);
            if(sFindDateBegin.length() > 0)     ps.setDate(questionMarkIdx++,ScreenHelper.getSQLDate(sFindDateBegin));
            if(sFindDateEnd.length() > 0)     ps.setDate(questionMarkIdx++,ScreenHelper.getSQLDate(sFindDateEnd));

            // execute
            rs = ps.executeQuery();

            while(rs.next()){
                foundObjects.add(get(rs.getString("OC_PP_SERVERID")+"."+rs.getString("OC_PP_OBJECTID")));
            }
        }
        catch(Exception e){
            e.printStackTrace();
        }
        finally{
            try{
                if(rs!=null) rs.close();
                if(ps!=null) ps.close();
                oc_conn.close();
            }
            catch(SQLException se){
                se.printStackTrace();
            }
        }

        return foundObjects;
    }

    public PaperPrescription() {
    }

    public PaperPrescription(Date begin, String content, String patientUid, String prescriberUid) {
        this.begin = begin;
        this.content = content;
        this.patientUid = patientUid;
        this.prescriberUid = prescriberUid;
        this.setCreateDateTime(new Date());
        this.setUpdateDateTime(new Date());
        this.setUpdateUser(getPrescriberUid());
        this.setUid("-1");
        this.setVersion(1);
    }

    public Vector getProducts(){
        Vector products = new Vector();
        String[] lines = content.split("\n");
        for(int n=0;n<lines.length;n++){
            if(lines[n].toUpperCase().startsWith("R/")){
                products.add(lines[n].substring(2));
            }
        }
        return products;
    }
}
