package be.openclinic.adt;

import be.openclinic.common.OC_Object;
import be.mxs.common.util.db.MedwanQuery;
import be.mxs.common.util.system.Debug;
import be.mxs.common.util.system.ScreenHelper;
import net.admin.Service;

import java.sql.*;
import java.util.Hashtable;
import java.util.Vector;
import java.util.Iterator;

public class Bed extends OC_Object{
    private String name;
    private Service service;
    private String serviceUID;
    private int priority;
    private String comment;
    private String location;

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public Service getService() {
        if(this.service == null){
            if(this.serviceUID != null && this.serviceUID.length() > 0){
                this.setService(Service.getService(this.serviceUID));
            }else{
                this.service = null;
            }
        }
        return service;
    }

    public void setService(Service service) {
        this.service = service;
    }

    public int getPriority() {
        return priority;
    }

    public void setPriority(int priority) {
        this.priority = priority;
    }

    public String getComment() {
        return comment;
    }

    public void setComment(String comment) {
        this.comment = comment;
    }

    public String getLocation() {
        return location;
    }

    public void setLocation(String location) {
        this.location = location;
    }

    public String getServiceUID(){
        return this.serviceUID;
    }

    public void setServiceUID(String serviceUID){
        this.serviceUID = serviceUID;
    }

    public void store(){
        PreparedStatement ps;
        ResultSet rs;
        String sInsert,sSelect,sDelete;
        int iVersion = 1;
        String[] ids;

        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            if ((this.getUid()!=null)&&(this.getUid().length()>0)){
                ids = this.getUid().split("\\.");

                if (ids.length==2){
                    sSelect = "SELECT * FROM OC_BEDS WHERE OC_BED_SERVERID = ? AND OC_BED_OBJECTID = ?";
                    ps = oc_conn.prepareStatement(sSelect);
                    ps.setInt(1,Integer.parseInt(ids[0]));
                    ps.setInt(2,Integer.parseInt(ids[1]));

                    rs = ps.executeQuery();

                    if(rs.next()){
                        iVersion = rs.getInt("OC_BED_VERSION") + 1;
                    }
                    rs.close();
                    ps.close();


                    sInsert = " INSERT INTO OC_BEDS_HISTORY " +
                              " SELECT OC_BED_SERVERID," +
                                     " OC_BED_OBJECTID," +
                                     " OC_BED_NAME," +
                                     " OC_BED_SERVICEUID," +
                                     " OC_BED_PRIORITY," +
                                     " OC_BED_COMMENT," +
                                     " OC_BED_LOCATION," +
                                     " OC_BED_CREATETIME," +
                                     " OC_BED_UPDATETIME," +
                                     " OC_BED_UPDATEUID," +
                                     " OC_BED_VERSION " +
                              " FROM OC_BEDS" +
                              " WHERE OC_BED_SERVERID = ?" +
                              " AND OC_BED_OBJECTID = ?";
                    ps = oc_conn.prepareStatement(sInsert);
                    ps.setInt(1,Integer.parseInt(ids[0]));
                    ps.setInt(2,Integer.parseInt(ids[1]));
                    ps.executeUpdate();
                    ps.close();

                    sDelete = "DELETE FROM OC_BEDS WHERE OC_BED_SERVERID = ? AND OC_BED_OBJECTID = ?";
                    ps = oc_conn.prepareStatement(sDelete);
                    ps.setInt(1,Integer.parseInt(ids[0]));
                    ps.setInt(2,Integer.parseInt(ids[1]));
                    ps.executeUpdate();
                    ps.close();
                }
            }else {
               ids = new String[] {MedwanQuery.getInstance().getConfigString("serverId"),MedwanQuery.getInstance().getOpenclinicCounter("OC_BEDS")+""};
            }
            if(ids.length == 2){
                sInsert = " INSERT INTO OC_BEDS ( OC_BED_SERVERID," +
                                                " OC_BED_OBJECTID," +
                                                " OC_BED_NAME," +
                                                " OC_BED_SERVICEUID," +
                                                " OC_BED_PRIORITY," +
                                                " OC_BED_COMMENT," +
                                                " OC_BED_LOCATION," +
                                                " OC_BED_CREATETIME," +
                                                " OC_BED_UPDATETIME," +
                                                " OC_BED_UPDATEUID," +
                                                " OC_BED_VERSION" +
                                               ") " +
                          " VALUES(?,?,?,?,?,?,?,?,?,?,?)";
                ps = oc_conn.prepareStatement(sInsert);
                ps.setInt(1,Integer.parseInt(ids[0]));
                ps.setInt(2,Integer.parseInt(ids[1]));
                ps.setString(3,this.getName());
                ps.setString(4,ScreenHelper.checkString(this.getService().code));
                ps.setInt(5,this.getPriority());
                ps.setString(6,this.getComment());
                ps.setString(7,this.getLocation());
                ps.setTimestamp(8,new Timestamp(this.getCreateDateTime().getTime()));
                ps.setTimestamp(9,new Timestamp(this.getUpdateDateTime().getTime()));
                ps.setString(10,this.getUpdateUser());
                ps.setInt(11,iVersion);
                ps.executeUpdate();
                ps.close();
                this.setUid(ids[0] + "." + ids[1]);
            }
        }catch(Exception e){
            Debug.println("OpenClinic => Bed.java => store => "+e.getMessage());
            e.printStackTrace();
        }
        try {
			oc_conn.close();
		} catch (SQLException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
    }

    public static Bed get(String uid){
        Bed bed = new Bed();
        if ((uid!=null)&&(uid.length()>0)){
            String [] ids = uid.split("\\.");
            Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
            try{
                if (ids.length==2){
                    String sSelect = "SELECT * FROM OC_BEDS WHERE OC_BED_SERVERID = ? AND OC_BED_OBJECTID = ? ";
                    PreparedStatement ps;
                    ResultSet rs;

                    ps = oc_conn.prepareStatement(sSelect);
                    ps.setInt(1,Integer.parseInt(ids[0]));
                    ps.setInt(2,Integer.parseInt(ids[1]));

                    rs = ps.executeQuery();

                    if(rs.next()){
                        bed.setUid(uid);
                        bed.setName(ScreenHelper.checkString(rs.getString("OC_BED_NAME")));
                        bed.setLocation(ScreenHelper.checkString(rs.getString("OC_BED_LOCATION")));
                        bed.setPriority(rs.getInt("OC_BED_PRIORITY"));
                        bed.setComment(ScreenHelper.checkString(rs.getString("OC_BED_COMMENT")));
                        bed.serviceUID = ScreenHelper.checkString(rs.getString("OC_BED_SERVICEUID"));
                        bed.setCreateDateTime(rs.getTimestamp("OC_BED_CREATETIME"));
                        bed.setUpdateDateTime(rs.getTimestamp("OC_BED_UPDATETIME"));
                        bed.setUpdateUser(ScreenHelper.checkString(rs.getString("OC_BED_UPDATEUID")));
                        bed.setVersion(rs.getInt("OC_BED_VERSION"));
                    }
                    rs.close();
                    ps.close();
                }
            }catch(Exception e){
                Debug.println("OpenClinic => Bed.java => get => "+e.getMessage());
                e.printStackTrace();
            }
            try {
				oc_conn.close();
			} catch (SQLException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}    
        }
        return bed;
    }

    public Hashtable isOccupied(){
        Hashtable hOccupied = new Hashtable();
        Boolean bStatus = Boolean.FALSE;
        String sPatientUid;
        String sEncounterUid;
        PreparedStatement ps;
        ResultSet rs;

        String sSelect = " SELECT a.* FROM OC_ENCOUNTERS a,OC_ENCOUNTER_SERVICES b " +
                " WHERE" +
                " a.OC_ENCOUNTER_SERVERID=b.OC_ENCOUNTER_SERVERID AND" +
                " a.OC_ENCOUNTER_OBJECTID=b.OC_ENCOUNTER_OBJECTID AND"+
                " b.OC_ENCOUNTER_BEDUID = ? AND " +
                " b.OC_ENCOUNTER_SERVICEENDDATE IS NULL AND" +
                " a.OC_ENCOUNTER_BEGINDATE <= ? AND " +
                " (a.OC_ENCOUNTER_ENDDATE >= ? OR a.OC_ENCOUNTER_ENDDATE IS NULL)";
        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            ps = oc_conn.prepareStatement(sSelect);
            ps.setString(1,this.getUid());
            ps.setTimestamp(2, ScreenHelper.getSQLTime());
            ps.setTimestamp(3, ScreenHelper.getSQLTime());
            rs = ps.executeQuery();

            if(rs.next()){
                bStatus = Boolean.TRUE;
                sEncounterUid = ScreenHelper.checkString(rs.getString("OC_ENCOUNTER_SERVERID")) + "." + ScreenHelper.checkString(rs.getString("OC_ENCOUNTER_OBJECTID"));
                sPatientUid = ScreenHelper.checkString(rs.getString("OC_ENCOUNTER_PATIENTUID"));
                hOccupied.put("status",bStatus);
                hOccupied.put("patientUid",sPatientUid);
                hOccupied.put("encounterUid",sEncounterUid);
            }else{
                hOccupied.put("status",bStatus);
                hOccupied.put("patientUid","");
                hOccupied.put("encounterUid","");
            }

            rs.close();
            ps.close();
        }catch(Exception e){
            e.printStackTrace();
        }
        try {
			oc_conn.close();
		} catch (SQLException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
        return hOccupied;
    }

    public static Vector selectBedsInService(String sServiceUID){
        PreparedStatement ps = null;
        ResultSet rs = null;

        Vector vChildServices = Service.getChildIds(sServiceUID);
        String sServiceUIDS = "";
        if(vChildServices.size() != 0){
            Iterator iter = vChildServices.iterator();

            while(iter.hasNext()){
                sServiceUIDS += "'" +iter.next() + "',";
            }
        }else{
            sServiceUIDS += "'" + sServiceUID + "',";
        }
        Vector vBeds = new Vector();

        String sSelect = "SELECT * FROM OC_BEDS WHERE OC_BED_SERVICEUID IN (" + sServiceUIDS.substring(0,sServiceUIDS.length()-1) + ")";

        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            ps = oc_conn.prepareStatement(sSelect);
            rs = ps.executeQuery();

            Bed bTmp;
            while(rs.next()){
                bTmp = new Bed();
                bTmp.setUid(ScreenHelper.checkString(rs.getString("OC_BED_SERVERID")) + "." + ScreenHelper.checkString(rs.getString("OC_BED_OBJECTID")));
                bTmp.setName(ScreenHelper.checkString(rs.getString("OC_BED_NAME")));
                if(rs.getInt("OC_BED_PRIORITY") != 0){
                    bTmp.setPriority(rs.getInt("OC_BED_PRIORITY"));
                }
                bTmp.serviceUID = ScreenHelper.checkString(rs.getString("OC_BED_SERVICEUID"));
                bTmp.setComment(ScreenHelper.checkString(rs.getString("OC_BED_COMMENT")));

                vBeds.addElement(bTmp);
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
        return vBeds;
    }

    public static Vector selectBeds(String serverID,String objectID,String name,String serviceID,String priority, String comment,String sortColumn){
        PreparedStatement ps;
        ResultSet rs;

        Vector vBeds = new Vector();

        String sSelect = "SELECT * FROM OC_BEDS";

        String sConditions = "";
        String sLower = MedwanQuery.getInstance().getConfigString("lowerCompare");

        //sLower.replaceAll("<param>","OC_BED_SERVERID") + " = " + sLower.replaceAll("<param>","?") + " AND";


        if(serverID.length() > 0 )  { sConditions += " OC_BED_SERVERID = ? AND";}
        if(objectID.length() > 0 )  { sConditions += " OC_BED_OBJECTID = ? AND";}
        if(name.length() > 0 )      { sConditions += " " + sLower.replaceAll("<param>","OC_BED_NAME") + " LIKE ? AND";}
        if(serviceID.length() > 0 ) { sConditions += " OC_BED_SERVICEUID = ? AND";}
        if(priority.length() > 0 )  { sConditions += " OC_BED_PRIORITY = ? AND";}
        if(comment.length() > 0 )   { sConditions += " " + sLower.replaceAll("<param>","OC_BED_COMMENT") + " LIKE ? AND";}

        if(sConditions.length() > 0){
            sSelect = sSelect + " WHERE " + sConditions;
            sSelect = sSelect.substring(0,sSelect.length() -3);
        }

        if(sortColumn.length() > 0){
            sSelect += " ORDER BY " + sortColumn;
        }


        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            ps = oc_conn.prepareStatement(sSelect);

            int i = 1;

            if(serverID.length() > 0 )  { ps.setInt(i++,Integer.parseInt(serverID));}
            if(objectID.length() > 0 )  { ps.setInt(i++,Integer.parseInt(objectID));}
            if(name.length() > 0 )      { ps.setString(i++,"%" + name.toLowerCase() + "%");}
            if(serviceID.length() > 0 ) { ps.setString(i++,serviceID);}
            if(priority.length() > 0 )  { ps.setInt(i++,Integer.parseInt(priority));}
            if(comment.length() > 0 )   { ps.setString(i++,"%" + comment.toLowerCase() + "%");}

            rs = ps.executeQuery();

            Bed bTmp;
            while(rs.next()){
                bTmp = new Bed();
                bTmp.setUid(ScreenHelper.checkString(rs.getString("OC_BED_SERVERID")) + "." + ScreenHelper.checkString(rs.getString("OC_BED_OBJECTID")));
                bTmp.setName(ScreenHelper.checkString(rs.getString("OC_BED_NAME")));
                if(rs.getInt("OC_BED_PRIORITY") != 0){
                    bTmp.setPriority(rs.getInt("OC_BED_PRIORITY"));
                }
                bTmp.serviceUID = ScreenHelper.checkString(rs.getString("OC_BED_SERVICEUID"));
                bTmp.setComment(ScreenHelper.checkString(rs.getString("OC_BED_COMMENT")));

                vBeds.addElement(bTmp);
            }

            rs.close();
            ps.close();
        }catch(Exception e){
            e.printStackTrace();
        }
        try {
			oc_conn.close();
		} catch (SQLException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
        return vBeds;
    }
}
