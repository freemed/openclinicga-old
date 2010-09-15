package be.openclinic.system;

import be.mxs.common.util.db.MedwanQuery;
import be.mxs.common.util.system.ScreenHelper;

import java.sql.Connection;
import java.sql.Timestamp;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.Vector;

public class Error {
    private int errorId;
    private Timestamp updatetime;
    private int updateuserid;
    private String errorpage;
    private byte[] errortext;
    private String lastname;
    private String firstname;

    public int getErrorId() {
        return errorId;
    }

    public void setErrorId(int errorId) {
        this.errorId = errorId;
    }

    public String getLastname() {
        return lastname;
    }

    public void setLastname(String lastname) {
        this.lastname = lastname;
    }

    public String getFirstname() {
        return firstname;
    }

    public void setFirstname(String firstname) {
        this.firstname = firstname;
    }

    public Timestamp getUpdatetime() {
        return updatetime;
    }

    public void setUpdatetime(Timestamp updatetime) {
        this.updatetime = updatetime;
    }

    public int getUpdateuserid() {
        return updateuserid;
    }

    public void setUpdateuserid(int updateuserid) {
        this.updateuserid = updateuserid;
    }

    public String getErrorpage() {
        return errorpage;
    }

    public void setErrorpage(String errorpage) {
        this.errorpage = errorpage;
    }

    public byte[] getErrortext() {
        return errortext;
    }

    public void setErrortext(byte[] errortext) {
        this.errortext = errortext;
    }

    public static Vector searchErrors(String sFindBegin, String sFindEnd){

        PreparedStatement ps = null;
        ResultSet rs = null;

        Vector vErrors = new Vector();

        String sSelect;
        Connection loc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            // BEGIN & END provided
            if(sFindBegin.length()>0 && sFindEnd.length()>0){
                sSelect = "SELECT e.errorid, e.updatetime, e.updateuserid, e.errorpage, a.lastname, a.firstname, e.errortext"
                         +" FROM Errors e, UsersView u, AdminView a"
                         +"  WHERE e.updatetime BETWEEN ? AND ? AND u.userid = e.updateuserid AND a.personid = u.personid"
                         +" ORDER BY e.updatetime, a.searchname";
                ps = loc_conn.prepareStatement(sSelect);
                ps.setDate(1,ScreenHelper.getSQLDate(sFindBegin));
                ps.setDate(2,ScreenHelper.getSQLDate(ScreenHelper.getDateAdd(sFindEnd,"2")));
            }
            // only BEGIN provided
            else if(sFindBegin.length()>0){
                sSelect = "SELECT e.errorid, e.updatetime, e.updateuserid, e.errorpage, a.lastname, a.firstname, e.errortext"
                         +" FROM Errors e, UsersView u, AdminView a"
                         +"  WHERE e.updatetime >= ? AND u.userid = e.updateuserid AND a.personid = u.personid"
                         +" ORDER BY e.updatetime, a.searchname";
                ps = loc_conn.prepareStatement(sSelect);
                ps.setDate(1,ScreenHelper.getSQLDate(sFindBegin));
            }
            // only END provided
            else if(sFindEnd.length()>0){
                sSelect = "SELECT e.errorid, e.updatetime, e.updateuserid, e.errorpage, a.lastname, a.firstname, e.errortext"
                         +" FROM Errors e, UsersView u, AdminView a"
                         +"  WHERE e.updatetime <= ? AND u.userid = e.updateuserid AND a.personid = u.personid"
                         +" ORDER BY e.updatetime, a.searchname";
                ps = loc_conn.prepareStatement(sSelect);
                ps.setDate(1,ScreenHelper.getSQLDate(ScreenHelper.getDateAdd(sFindEnd,"2")));
            }

            rs = ps.executeQuery();

            Error objError;

            while(rs.next()){
                objError = new Error();

                objError.setErrorId(rs.getInt("errorid"));
                objError.setErrorpage(ScreenHelper.checkString(rs.getString("errorpage")));
                objError.setUpdatetime(rs.getTimestamp("updatetime"));
                objError.setUpdateuserid(rs.getInt("updateuserid"));
                objError.setErrortext(rs.getBytes("errortext"));
                objError.setLastname(ScreenHelper.checkString(rs.getString("lastname")));
                objError.setFirstname(ScreenHelper.checkString(rs.getString("firstname")));

                vErrors.addElement(objError);
            }
            rs.close();
            ps.close();
        }catch(Exception e){
            e.printStackTrace();
        }finally{
            try{
                if(rs!=null)rs.close();
                if(ps!=null)ps.close();
                loc_conn.close();
            }catch(Exception e){
                e.printStackTrace();
            }
        }

        return vErrors;
    }

    public void insert(){
        PreparedStatement ps = null;

        String sInsert = "INSERT INTO Errors(errorid, updatetime, updateuserid, errorpage, errortext) VALUES(?,?,?,?,?)";

        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            this.errorId = MedwanQuery.getInstance().getOpenclinicCounter("Errors");
            
            ps = oc_conn.prepareStatement(sInsert);
            ps.setInt(1,this.errorId);
            ps.setTimestamp(2,this.updatetime);
            ps.setInt(3,this.updateuserid);
            ps.setString(4,this.getErrorpage());
            ps.setBytes(5,this.getErrortext());
            ps.execute();
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

    public static void delete(String sErrorId){
        PreparedStatement ps = null;

        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            String sQuery = "DELETE FROM Errors WHERE errorId = ?";
            ps = oc_conn.prepareStatement(sQuery);
            ps.setString(1,sErrorId);
            ps.executeUpdate();
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

    public static void delete(java.util.Date delFromDate, java.util.Date delUntilDate){  
        PreparedStatement ps = null;
        ResultSet rs = null;

        // compose query to retreive errorIds in interval
        String sQuery = "SELECT errorid FROM Errors e, UsersView u, AdminView a ";

        if(delFromDate!=null && delUntilDate!=null){
            sQuery+= "WHERE e.updatetime BETWEEN ? AND ? ";
        }
        else if(delFromDate!=null){
            sQuery+= "WHERE e.updatetime >= ? ";
        }
        else if(delUntilDate!=null){
            sQuery+= "WHERE e.updatetime < ? ";
        }

        int questionMarkIdx = 1;
        sQuery+= "AND u.userid = e.updateuserid "+
                 "AND a.personid = u.personid";

        StringBuffer errorIds = new StringBuffer();

        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            ps = oc_conn.prepareStatement(sQuery);

            if(delFromDate!=null) ps.setDate(questionMarkIdx++,new java.sql.Date(delFromDate.getTime()));
            if(delUntilDate!=null) ps.setDate(questionMarkIdx,new java.sql.Date(delUntilDate.getTime()));

            int id;
            rs = ps.executeQuery();
            while(rs.next()){
                id = rs.getInt("errorid");
                if(id > 0){
                    errorIds.append("'").append(id).append("',");
                }
            }
        }catch(Exception e){
            e.printStackTrace();
        }finally{
            try{
                if(ps!=null)ps.close();
                if(rs!=null)rs.close();
            }catch(Exception e){
                e.printStackTrace();
            }
        }

        //*** delete errors specified by errorIds-string ***
        try{
            if(errorIds.length() > 0){
                // remove last comma
                if(errorIds.toString().indexOf(",") > 0){
                    errorIds = errorIds.deleteCharAt(errorIds.length()-1);
                }

                // delete records
                sQuery = "DELETE FROM Errors WHERE errorid IN ("+errorIds+")";
                ps = oc_conn.prepareStatement(sQuery);
                ps.executeUpdate();
            }
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