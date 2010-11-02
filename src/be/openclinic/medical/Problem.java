package be.openclinic.medical;

import be.mxs.common.util.db.MedwanQuery;
import be.mxs.common.util.system.Debug;
import be.mxs.common.util.system.ScreenHelper;
import be.openclinic.common.OC_Object;
import net.admin.AdminPerson;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.util.Date;
import java.util.Vector;

public class Problem extends OC_Object {
    private AdminPerson patient;
    private String patientuid;
    private String codeType;
    private String code;
    private String comment;
    private Date begin;
    private Date end;
    private int gravity;
    private int certainty;

    public Problem(String patientuid, String codeType, String code, String comment, Date begin, Date end) {
        this.patientuid = patientuid;
        this.codeType = codeType;
        this.code = code;
        this.comment = comment;
        this.begin = begin;
        this.end = end;
    }

    public Problem(){
        super();
    }

    public AdminPerson getPatient() {
        if(patient==null && patientuid!=null){
        	Connection ad_conn = MedwanQuery.getInstance().getAdminConnection();
            patient = AdminPerson.getAdminPerson(ad_conn,patientuid);
            try {
				ad_conn.close();
			} catch (SQLException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
        }
        return patient;
    }

    public void setPatient(AdminPerson patient) {
        this.patient = patient;
    }

    public String getCodeType() {
        return codeType;
    }

    public void setCodeType(String codeType) {
        this.codeType = codeType;
    }

    public String getCode() {
        return code;
    }

    public void setCode(String code) {
        this.code = code;
    }

    public String getComment() {
        return comment;
    }

    public void setComment(String comment) {
        this.comment = comment;
    }

    public Date getBegin() {
        return begin;
    }

    public void setBegin(Date begin) {
        this.begin = begin;
    }

    public Date getEnd() {
        return end;
    }

    public void setEnd(Date end) {
        this.end = end;
    }

    public String getPatientuid() {
        return patientuid;
    }

    public void setPatientuid(String patientuid) {
        this.patientuid = patientuid;
    }

    public int getGravity() {
        return gravity;
    }

    public void setGravity(int gravity) {
        this.gravity = gravity;
    }

    public int getCertainty() {
        return certainty;
    }

    public void setCertainty(int certainty) {
        this.certainty = certainty;
    }

    public void store(){
        PreparedStatement ps;
        ResultSet rs;

        String sSelect,sInsert,sDelete;

        int iVersion = 1;
        String ids[];
        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            if(this.getUid()!=null && this.getUid().length() >0){
                ids = this.getUid().split("\\.");
                if(ids.length == 2){
                    sSelect = " SELECT * FROM OC_PROBLEMS " +
                              " WHERE OC_PROBLEM_SERVERID = ? " +
                              " AND OC_PROBLEM_OBJECTID = ?";
                    ps = oc_conn.prepareStatement(sSelect);
                    ps.setInt(1,Integer.parseInt(ids[0]));
                    ps.setInt(2,Integer.parseInt(ids[1]));

                    rs = ps.executeQuery();

                    if(rs.next()){
                        iVersion = rs.getInt("OC_PROBLEM_VERSION") + 1;
                    }

                    rs.close();
                    ps.close();

                    sInsert = " INSERT INTO OC_PROBLEMS_HISTORY " +
                              " SELECT OC_PROBLEM_PATIENTUID," +
                                     " OC_PROBLEM_CODETYPE," +
                                     " OC_PROBLEM_CODE," +
                                     " OC_PROBLEM_BEGIN," +
                                     " OC_PROBLEM_END," +
                                     " OC_PROBLEM_SERVERID," +
                                     " OC_PROBLEM_OBJECTID," +
                                     " OC_PROBLEM_CREATETIME," +
                                     " OC_PROBLEM_UPDATETIME," +
                                     " OC_PROBLEM_UPDATEUID,"  +
                                     " OC_PROBLEM_VERSION," +
                                     " OC_PROBLEM_GRAVITY," +
                                     " OC_PROBLEM_CERTAINTY," +
                                     " OC_PROBLEM_COMMENT" +
                              " FROM OC_PROBLEMS " +
                              " WHERE OC_PROBLEM_SERVERID = ?" +
                              " AND OC_PROBLEM_OBJECTID = ?";
                    ps = oc_conn.prepareStatement(sInsert);
                    ps.setInt(1,Integer.parseInt(ids[0]));
                    ps.setInt(2,Integer.parseInt(ids[1]));
                    ps.executeUpdate();
                    ps.close();

                    sDelete = " DELETE FROM OC_PROBLEMS " +
                              " WHERE OC_PROBLEM_SERVERID = ? " +
                              " AND OC_PROBLEM_OBJECTID = ? ";

                    ps = oc_conn.prepareStatement(sDelete);
                    ps.setInt(1,Integer.parseInt(ids[0]));
                    ps.setInt(2,Integer.parseInt(ids[1]));
                    ps.executeUpdate();
                    ps.close();
                }
            }else{
                ids = new String[] {MedwanQuery.getInstance().getConfigString("serverId"),MedwanQuery.getInstance().getOpenclinicCounter("OC_PROBLEMS")+""};
            }
            if(ids.length == 2){
                sInsert = " INSERT INTO OC_PROBLEMS" +
                                      "(" +
                                      " OC_PROBLEM_SERVERID," +
                                      " OC_PROBLEM_OBJECTID," +
                                      " OC_PROBLEM_CODETYPE," +
                                      " OC_PROBLEM_CODE," +
                                      " OC_PROBLEM_CERTAINTY," +
                                      " OC_PROBLEM_GRAVITY," +
                                      " OC_PROBLEM_BEGIN," +
                                      " OC_PROBLEM_END," +
                                      " OC_PROBLEM_PATIENTUID," +
                                      " OC_PROBLEM_COMMENT," +
                                      " OC_PROBLEM_CREATETIME," +
                                      " OC_PROBLEM_UPDATETIME," +
                                      " OC_PROBLEM_UPDATEUID,"  +
                                      " OC_PROBLEM_VERSION" +
                                      ") " +
                          " VALUES(?,?,?,?,?,?,?,?,?,?,?,?,?,?)";

                ps = oc_conn.prepareStatement(sInsert);
                ps.setInt(1,Integer.parseInt(ids[0]));
                ps.setInt(2,Integer.parseInt(ids[1]));
                ps.setString(3,this.getCodeType());
                ps.setString(4,this.getCode());
                ps.setInt(5,this.getCertainty());
                ps.setInt(6,this.getGravity());
                if(this.getBegin() == null){
                    ps.setNull(7, java.sql.Types.TIMESTAMP);
                }else{
                    ps.setTimestamp(7, new Timestamp(this.getBegin().getTime()));
                }
                if(this.getEnd() == null){
                    ps.setNull(8, java.sql.Types.TIMESTAMP);
                }else{
                    ps.setTimestamp(8, new Timestamp(this.getEnd().getTime()));
                }
                if(this.getPatient() != null){
                    ps.setString(9,ScreenHelper.checkString(this.getPatient().personid));
                }else{
                    ps.setString(9,"");
                }
                ps.setString(10,this.getComment());
                if(this.getCreateDateTime() != null){
                    ps.setTimestamp(11,new Timestamp(this.getCreateDateTime().getTime()));
                }else{
                    ps.setTimestamp(11,new Timestamp(ScreenHelper.getSQLDate(ScreenHelper.getDate()).getTime()));
                }
                ps.setTimestamp(12,new Timestamp(this.getUpdateDateTime().getTime()));
                ps.setString(13,this.getUpdateUser());
                ps.setInt(14,iVersion);
                ps.executeUpdate();
                ps.close();
                this.setUid(ids[0] + "." + ids[1]);
            }
        }catch(Exception e){
            Debug.println("OpenClinic => Problem.java => store => "+e.getMessage());
            e.printStackTrace();
        }
        try {
			oc_conn.close();
		} catch (SQLException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
    }

    public static Problem get(String uid){
        PreparedStatement ps;
        ResultSet rs;

        Problem  problem= new Problem();

        if(uid != null && uid.length() > 0){
            String sUids[] = uid.split("\\.");
            if(sUids.length == 2){
                Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
                try{
                    String sSelect = " SELECT * FROM OC_PROBLEMS " +
                                     " WHERE OC_PROBLEM_SERVERID = ? " +
                                     " AND OC_PROBLEM_OBJECTID = ?";
                    ps = oc_conn.prepareStatement(sSelect);
                    ps.setInt(1,Integer.parseInt(sUids[0]));
                    ps.setInt(2,Integer.parseInt(sUids[1]));

                    rs = ps.executeQuery();

                    if(rs.next()){
                        problem.patientuid = ScreenHelper.checkString(rs.getString("OC_PROBLEM_PATIENTUID"));

                        problem.setUid(ScreenHelper.checkString(rs.getString("OC_PROBLEM_SERVERID")) + "." + ScreenHelper.checkString(rs.getString("OC_PROBLEM_OBJECTID")));
                        problem.setCreateDateTime(rs.getTimestamp("OC_PROBLEM_CREATETIME"));
                        problem.setUpdateDateTime(rs.getTimestamp("OC_PROBLEM_UPDATETIME"));
                        problem.setUpdateUser(ScreenHelper.checkString(rs.getString("OC_PROBLEM_UPDATEUID")));
                        problem.setVersion(rs.getInt("OC_PROBLEM_VERSION"));
                        problem.setBegin(rs.getDate("OC_PROBLEM_BEGIN"));
                        problem.setEnd(rs.getDate("OC_PROBLEM_END"));
                        problem.setCodeType(ScreenHelper.checkString(rs.getString("OC_PROBLEM_CODETYPE")));
                        problem.setCode(ScreenHelper.checkString(rs.getString("OC_PROBLEM_CODE")));
                        problem.setComment(ScreenHelper.checkString(rs.getString("OC_PROBLEM_COMMENT")));
                        problem.setGravity(rs.getInt("OC_PROBLEM_GRAVITY"));
                        problem.setCertainty(rs.getInt("OC_PROBLEM_CERTAINTY"));
                    }
                    rs.close();
                    ps.close();
                    
                }catch(Exception e){
                    Debug.println("OpenClinic =>Problem.java => get => "+e.getMessage());
                    e.printStackTrace();
                }
                try {
					oc_conn.close();
				} catch (SQLException e) {
					// TODO Auto-generated catch block
					e.printStackTrace();
				}
            }
        }
        return problem;
    }

    public void delete(){
        PreparedStatement ps;

        String ids[];
        String sInsert,sDelete;

        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            if(this.getUid() != null && this.getUid().length() > 0){
                ids = this.getUid().split("\\.");
                if(ids.length == 2){
                    sInsert = " INSERT INTO OC_PROBLEMS_HISTORY " +
                              " SELECT OC_PROBLEM_PATIENTUID," +
                                     " OC_PROBLEM_CODETYPE," +
                                     " OC_PROBLEM_CODE," +
                                     " OC_PROBLEM_BEGIN," +
                                     " OC_PROBLEM_END," +
                                     " OC_PROBLEM_SERVERID," +
                                     " OC_PROBLEM_OBJECTID," +
                                     " OC_PROBLEM_CREATETIME," +
                                     " OC_PROBLEM_UPDATETIME," +
                                     " OC_PROBLEM_UPDATEUID,"  +
                                     " OC_PROBLEM_VERSION," +
                                     " OC_PROBLEM_GRAVITY," +
                                     " OC_PROBLEM_CERTAINTY," +
                                     " OC_PROBLEM_COMMENT" +
                              " FROM OC_PROBLEMS " +
                              " WHERE OC_PROBLEM_SERVERID = ?" +
                              " AND OC_PROBLEM_OBJECTID = ?";
                    ps = oc_conn.prepareStatement(sInsert);
                    ps.setInt(1,Integer.parseInt(ids[0]));
                    ps.setInt(2,Integer.parseInt(ids[1]));
                    ps.executeUpdate();
                    ps.close();

                    sDelete = " DELETE FROM OC_PROBLEMS " +
                              " WHERE OC_PROBLEM_SERVERID = ? " +
                              " AND OC_PROBLEM_OBJECTID = ? ";

                    ps = oc_conn.prepareStatement(sDelete);
                    ps.setInt(1,Integer.parseInt(ids[0]));
                    ps.setInt(2,Integer.parseInt(ids[1]));
                    ps.executeUpdate();
                    ps.close();
                }
            }
        }catch(Exception e){
            e.printStackTrace();
        }
        try {
			oc_conn.close();
		} catch (SQLException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
    }

    public static Vector selectProblems(String serverID,String objectID,String codeType, String code, String comment,
                                        String patientID, String beginDate, String endDate, String certainty,String gravity, String sortColumn){

        Vector vProblems = new Vector();

        PreparedStatement ps;
        ResultSet rs;

        String sConditions = "";
        String sSelect = "SELECT * FROM OC_PROBLEMS ";

        if(serverID.length()  > 0)   {sConditions += " OC_PROBLEM_SERVERID = ? AND";}
        if(objectID.length()  > 0)   {sConditions += " OC_PROBLEM_OBJECTID = ? AND";}
        if(certainty.length() > 0)   {sConditions += " OC_PROBLEM_CERTAINTY = ? AND";}
        if(gravity.length()   > 0)   {sConditions += " OC_PROBLEM_GRAVITY = ? AND";}
        if(codeType.length()  > 0)   {sConditions += " " + MedwanQuery.getInstance().getConfigString("lowerCompare").replaceAll("<param>","OC_PROBLEM_CODETYPE") + " LIKE ? AND";}
        if(code.length()      > 0)   {sConditions += " " + MedwanQuery.getInstance().getConfigString("lowerCompare").replaceAll("<param>","OC_PROBLEM_CODE") + " LIKE ? AND";}
        if(comment.length()   > 0)   {sConditions += " " + MedwanQuery.getInstance().getConfigString("lowerCompare").replaceAll("<param>","OC_PROBLEM_COMMENT") + " LIKE ? AND";}
        if(patientID.length() > 0)   {sConditions += " OC_PROBLEM_PATIENTUID = ? AND";}
        if(beginDate.length() > 0)   {sConditions += " OC_PROBLEM_BEGIN >= ? AND";}
        if(endDate.length()   > 0)   {sConditions += " OC_PROBLEM_END < ? AND";}

        if(sConditions.length() > 0){
            sSelect += " WHERE " + sConditions;
            sSelect = sSelect.substring(0,sSelect.length()-3);
        }

        if(sortColumn.length() > 0){
            sSelect += " ORDER BY " + sortColumn;
        }


        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            int i = 1;

            ps = oc_conn.prepareStatement(sSelect);
            if(serverID.length() > 0)   {ps.setInt(i++,Integer.parseInt(serverID));}
            if(objectID.length() > 0)   {ps.setInt(i++,Integer.parseInt(objectID));}
            if(certainty.length() > 0)  {ps.setInt(i++,Integer.parseInt(certainty));}
            if(gravity.length() > 0)    {ps.setInt(i++,Integer.parseInt(gravity));}
            if(codeType.length() > 0)   {ps.setString(i++,codeType.toLowerCase() + "%");}
            if(code.length() > 0)       {ps.setString(i++,code.toLowerCase() +"%");}
            if(comment.length() > 0)    {ps.setString(i++,"%" + comment.toLowerCase() + "%");}
            if(patientID.length() > 0)  {ps.setString(i++,patientID);}
            if(beginDate.length() > 0)  {ps.setTimestamp(i++,new Timestamp(ScreenHelper.getSQLDate(beginDate).getTime()));}
            if(endDate.length() > 0)    {ps.setTimestamp(i++,new Timestamp(ScreenHelper.getSQLDate(endDate).getTime()));}

            rs = ps.executeQuery();

            Problem pTmp;
            String sUID;
            while(rs.next()){
                pTmp = new Problem();
                sUID = ScreenHelper.checkString(rs.getString("OC_PROBLEM_SERVERID")) + "." + ScreenHelper.checkString(rs.getString("OC_PROBLEM_OBJECTID"));
                pTmp.setUid(sUID);
                pTmp.setCodeType(ScreenHelper.checkString(rs.getString("OC_PROBLEM_CODETYPE")));
                pTmp.setCode(ScreenHelper.checkString(rs.getString("OC_PROBLEM_CODE")));
                pTmp.setComment(ScreenHelper.checkString(rs.getString("OC_PROBLEM_COMMENT")));
                pTmp.setPatientuid(ScreenHelper.checkString(rs.getString("OC_PROBLEM_PATIENTUID")));
                pTmp.setCertainty(rs.getInt("OC_PROBLEM_CERTAINTY"));
                pTmp.setGravity(rs.getInt("OC_PROBLEM_GRAVITY"));
                pTmp.setBegin(rs.getDate("OC_PROBLEM_BEGIN"));
                pTmp.setEnd(rs.getDate("OC_PROBLEM_END"));

                vProblems.addElement(pTmp);
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
        return vProblems;
    }

    public static Vector getActiveProblems(String personid){
        Vector activeProblems = new Vector();
        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try {
            PreparedStatement ps = oc_conn.prepareStatement("select * from OC_PROBLEMS where OC_PROBLEM_PATIENTUID=? and OC_PROBLEM_END is null ORDER BY OC_PROBLEM_BEGIN DESC");
            ps.setString(1,personid);
            ResultSet rs = ps.executeQuery();
            while (rs.next()){
                activeProblems.add(new Problem(rs.getString("OC_PROBLEM_PATIENTUID"),rs.getString("OC_PROBLEM_CODETYPE"),rs.getString("OC_PROBLEM_CODE"),rs.getString("OC_PROBLEM_COMMENT"),rs.getDate("OC_PROBLEM_BEGIN"),rs.getDate("OC_PROBLEM_END")));
            }
            rs.close();
            ps.close();
        } catch (SQLException e) {
            e.printStackTrace();
        }
        try {
			oc_conn.close();
		} catch (SQLException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
        return activeProblems;
    }
}
