package be.openclinic.medical;

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

public class AnesthesieControl extends OC_Object implements Comparable {
    private Date acDate;
    private String acBeginHour;
    private String acEndHour;
    private String acDuration;
    private String acControlPerformedById;
    private String acEquipmentAnesthesie;
    private String acEquipmentAnesthesieRemark;
    private String acEquipmentMonitor;
    private String acEquipmentMonitorRemark;
    private String acManageMedicines;
    private String acManageMedicinesRemark;
    private String acVacuumCleaner;
    private String acVacuumCleanerRemark;
    private String acOxygen;
    private String acOxygenRemark;
    private String acOther;
    private String acOtherRemark;

    public int compareTo(Object o){
        int comp;
        if (o.getClass().isInstance(this)){
            comp = this.acDate.compareTo(((AnesthesieControl)o).acDate);
        }
        else {
            throw new ClassCastException();
        }
        return comp;
    }

    public Date getDate(){
        return this.acDate;
    }

    public void setDate(Date date){
        this.acDate = date;
    }

    public String getBeginHour() {
        return ScreenHelper.checkString(acBeginHour);
    }

    public void setBeginHour(String acBeginHour) {
        this.acBeginHour = acBeginHour;
    }

    public String getEndHour() {
        return ScreenHelper.checkString(acEndHour);
    }

    public void setEndHour(String acEndHour) {
        this.acEndHour = acEndHour;
    }

    public String getDuration() {
        return ScreenHelper.checkString(acDuration);
    }

    public void setDuration(String acDuration) {
        this.acDuration = acDuration;
    }

    public String getControlPerformedById() {
        return ScreenHelper.checkString(acControlPerformedById);
    }

    public void setControlPerformedById(String acControlPerformedById) {
        this.acControlPerformedById = acControlPerformedById;
    }

    public String getEquipmentAnesthesie() {
        return ScreenHelper.checkString(acEquipmentAnesthesie);
    }

    public void setEquipmentAnesthesie(String acEquipmentAnesthesie) {
        this.acEquipmentAnesthesie = acEquipmentAnesthesie;
    }

    public String getEquipmentAnesthesieRemark() {
        return ScreenHelper.checkString(acEquipmentAnesthesieRemark);
    }

    public void setEquipmentAnesthesieRemark(String acEquipmentAnesthesieRemark) {
        this.acEquipmentAnesthesieRemark = acEquipmentAnesthesieRemark;
    }

    public String getEquipmentMonitor() {
        return ScreenHelper.checkString(acEquipmentMonitor);
    }

    public void setEquipmentMonitor(String acEquipmentMonitor) {
        this.acEquipmentMonitor = acEquipmentMonitor;
    }

    public String getEquipmentMonitorRemark() {
        return ScreenHelper.checkString(acEquipmentMonitorRemark);
    }

    public void setEquipmentMonitorRemark(String acEquipmentMonitorRemark) {
        this.acEquipmentMonitorRemark = acEquipmentMonitorRemark;
    }

    public String getManageMedicines() {
        return ScreenHelper.checkString(acManageMedicines);
    }

    public void setManageMedicines(String acManageMedicines) {
        this.acManageMedicines = acManageMedicines;
    }

    public String getManageMedicinesRemark() {
        return ScreenHelper.checkString(acManageMedicinesRemark);
    }

    public void setManageMedicinesRemark(String acManageMedicinesRemark) {
        this.acManageMedicinesRemark = acManageMedicinesRemark;
    }

    public String getVacuumCleaner() {
        return ScreenHelper.checkString(acVacuumCleaner);
    }

    public void setVacuumCleaner(String acVacuumCleaner) {
        this.acVacuumCleaner = acVacuumCleaner;
    }

    public String getVacuumCleanerRemark() {
        return ScreenHelper.checkString(acVacuumCleanerRemark);
    }

    public void setVacuumCleanerRemark(String acVacuumCleanerRemark) {
        this.acVacuumCleanerRemark = acVacuumCleanerRemark;
    }

    public String getOxygen() {
        return ScreenHelper.checkString(acOxygen);
    }

    public void setOxygen(String acOxygen) {
        this.acOxygen = acOxygen;
    }

    public String getOxygenRemark() {
        return ScreenHelper.checkString(acOxygenRemark);
    }

    public void setOxygenRemark(String acOxygenRemark) {
        this.acOxygenRemark = acOxygenRemark;
    }

    public String getOther() {
        return ScreenHelper.checkString(acOther);
    }

    public void setOther(String acOther) {
        this.acOther = acOther;
    }

    public String getOtherRemark() {
        return ScreenHelper.checkString(acOtherRemark);
    }

    public void setOtherRemark(String acOtherRemark) {
        this.acOtherRemark = acOtherRemark;
    }

    public static AnesthesieControl get(String sAcId) {
        AnesthesieControl ac = new AnesthesieControl();
        ac.setUid(sAcId);
        PreparedStatement ps = null;
        ResultSet rs = null;

        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try {
            String sSelect = "SELECT * FROM OC_ANESTHESIE_CONTROLS" +
                    " WHERE OC_AC_SERVERID = ? AND OC_AC_OBJECTID = ?";
            ps = oc_conn.prepareStatement(sSelect);
            ps.setInt(1, Integer.parseInt(sAcId.substring(0, sAcId.indexOf("."))));
            ps.setInt(2, Integer.parseInt(sAcId.substring(sAcId.indexOf(".") + 1)));
            rs = ps.executeQuery();

            // get data from DB
            if (rs.next()) {
                ac.setDate(rs.getTimestamp("OC_AC_DATE"));
                ac.setBeginHour(rs.getString("OC_AC_BEGIN_HOUR"));
                ac.setEndHour(rs.getString("OC_AC_END_HOUR"));
                ac.setDuration(rs.getString("OC_AC_DURATION"));
                ac.setControlPerformedById(rs.getString("OC_AC_CONTROL_PERFORMED_BY_ID"));
                ac.setEquipmentAnesthesie(rs.getString("OC_AC_EQUIPMENT_ANESTHESIE"));
                ac.setEquipmentAnesthesieRemark(rs.getString("OC_AC_EQUIPMENT_ANESTHESIE_REMARK"));
                ac.setEquipmentMonitor(rs.getString("OC_AC_EQUIPMENT_MONITOR"));
                ac.setEquipmentMonitorRemark(rs.getString("OC_AC_EQUIPMENT_MONITOR_REMARK"));
                ac.setManageMedicines(rs.getString("OC_AC_MANAGE_MEDICINES"));
                ac.setManageMedicinesRemark(rs.getString("OC_AC_MANAGE_MEDICINES_REMARK"));
                ac.setVacuumCleaner(rs.getString("OC_AC_VACUUM_CLEANER"));
                ac.setVacuumCleanerRemark(rs.getString("OC_AC_VACUUM_CLEANER_REMARK"));
                ac.setOxygen(rs.getString("OC_AC_OXYGEN"));
                ac.setOxygenRemark(rs.getString("OC_AC_OXYGEN_REMARK"));
                ac.setOther(rs.getString("OC_AC_OTHER"));
                ac.setOtherRemark(rs.getString("OC_AC_OTHER_REMARK"));
                ac.setCreateDateTime(rs.getTimestamp("OC_AC_CREATETIME"));
                ac.setUpdateDateTime(rs.getTimestamp("OC_AC_UPDATETIME"));
                ac.setUpdateUser(ScreenHelper.checkString(rs.getString("OC_AC_UPDATEUID")));
            } else {
                throw new Exception("ERROR : ANESTHESIE CONTROL " + sAcId + " NOT FOUND");
            }
        }
        catch (Exception e) {
            ac = null;

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

        return ac;
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
                    sSelect = "DELETE FROM OC_ANESTHESIE_CONTROLS WHERE OC_AC_SERVERID = ? AND OC_AC_OBJECTID = ? ";
                    ps = oc_conn.prepareStatement(sSelect);
                    ps.setInt(1,Integer.parseInt(ids[0]));
                    ps.setInt(2,Integer.parseInt(ids[1]));
                    ps.executeUpdate();
                    ps.close();
                }
            }
            else{
                ids = new String[] {MedwanQuery.getInstance().getConfigString("serverId"),MedwanQuery.getInstance().getOpenclinicCounter("OC_ANESTHESIE_CONTROLS") + ""};
                this.setUid(ids[0]+"."+ids[1]);
            }

            if(ids.length == 2){
                sSelect = " INSERT INTO OC_ANESTHESIE_CONTROLS ("+
                                " OC_AC_SERVERID,"+
                                " OC_AC_OBJECTID,"+
                                " OC_AC_DATE,"+
                                " OC_AC_BEGIN_HOUR,"+
                                " OC_AC_END_HOUR,"+
                                " OC_AC_DURATION,"+
                                " OC_AC_CONTROL_PERFORMED_BY_ID,"+
                                " OC_AC_EQUIPMENT_ANESTHESIE,"+
                                " OC_AC_EQUIPMENT_ANESTHESIE_REMARK,"+
                                " OC_AC_EQUIPMENT_MONITOR,"+
                                " OC_AC_EQUIPMENT_MONITOR_REMARK,"+
                                " OC_AC_MANAGE_MEDICINES,"+
                                " OC_AC_MANAGE_MEDICINES_REMARK,"+
                                " OC_AC_VACUUM_CLEANER,"+
                                " OC_AC_VACUUM_CLEANER_REMARK,"+
                                " OC_AC_OXYGEN,"+
                                " OC_AC_OXYGEN_REMARK,"+
                                " OC_AC_OTHER,"+
                                " OC_AC_OTHER_REMARK,"+
                                " OC_AC_CREATETIME,"+
                                " OC_AC_UPDATETIME,"+
                                " OC_AC_UPDATEUID"+
                              ") " +
                          " VALUES(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)";

                ps = oc_conn.prepareStatement(sSelect);
                ps.setInt(1,Integer.parseInt(ids[0]));
                ps.setInt(2,Integer.parseInt(ids[1]));
                ps.setTimestamp(3,new Timestamp(this.getDate().getTime()));
                ps.setString(4,this.getBeginHour());
                ps.setString(5,this.getEndHour());
                ps.setString(6,this.getDuration());
                ps.setString(7,this.getControlPerformedById());
                ps.setString(8,this.getEquipmentAnesthesie());
                ps.setString(9,this.getEquipmentAnesthesieRemark());
                ps.setString(10,this.getEquipmentMonitor());
                ps.setString(11,this.getEquipmentMonitorRemark());
                ps.setString(12,this.getManageMedicines());
                ps.setString(13,this.getManageMedicinesRemark());
                ps.setString(14,this.getVacuumCleaner());
                ps.setString(15,this.getVacuumCleanerRemark());
                ps.setString(16,this.getOxygen());
                ps.setString(17,this.getOxygenRemark());
                ps.setString(18,this.getOther());
                ps.setString(19,this.getOtherRemark());
                ps.setTimestamp(20,new Timestamp(this.getCreateDateTime().getTime()));
                ps.setTimestamp(21,new Timestamp(this.getUpdateDateTime().getTime()));
                ps.setString(22,this.getUpdateUser());
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
                Debug.println("OpenClinic => ANESTHESIE CONTROL.java => store => "+e.getMessage()+" = "+sSelect);
                e.printStackTrace();
            }
        }
    }

    public static Vector searchAnesthesieControls(String sFindBegin, String sFindEnd){
        PreparedStatement ps = null;
        ResultSet rs = null;

        Vector vACs = new Vector();

        String sSelect = " SELECT OC_AC_DATE, OC_AC_CONTROL_PERFORMED_BY_ID, OC_AC_SERVERID, OC_AC_OBJECTID FROM OC_ANESTHESIE_CONTROLS WHERE ";
        String sSelect1 = " OC_AC_DATE BETWEEN ? AND ?  ORDER BY OC_AC_DATE ";
        String sSelect2 = " OC_AC_DATE >= ? ORDER BY OC_AC_DATE";
        String sSelect3 = " OC_AC_DATE <= ? ORDER BY OC_AC_DATE ";

        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            if ((sFindBegin.trim().length()>0)&&(sFindEnd.trim().length()>0)){
                java.sql.Date dEnd = ScreenHelper.getSQLDate(ScreenHelper.getDateAdd(sFindEnd, "2"));
                sSelect += sSelect1;
                ps = oc_conn.prepareStatement(sSelect);
                ps.setDate(1,ScreenHelper.getSQLDate(sFindBegin));
                ps.setDate(2,dEnd);
            }
            else if (sFindBegin.trim().length()>0){
                sSelect += sSelect2;
                ps = oc_conn.prepareStatement(sSelect);
                ps.setDate(1,ScreenHelper.getSQLDate(sFindBegin));
            }
            else if (sFindEnd.trim().length()>0){
                java.sql.Date dEnd = ScreenHelper.getSQLDate(ScreenHelper.getDateAdd(sFindEnd, "2"));
                sSelect += sSelect3;
                ps = oc_conn.prepareStatement(sSelect);
                ps.setDate(1,dEnd);
            }

            rs = ps.executeQuery();
            AnesthesieControl ac;
            while(rs.next()){
                ac = new AnesthesieControl();
                ac.setUid(rs.getString("OC_AC_SERVERID")+"."+rs.getString("OC_AC_OBJECTID"));
                ac.setDate(rs.getDate("OC_AC_DATE"));
                ac.setControlPerformedById(ScreenHelper.checkString(rs.getString("OC_AC_CONTROL_PERFORMED_BY_ID")));

                vACs.addElement(ac);
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

        return vACs;
    }
}
