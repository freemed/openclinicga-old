package be.openclinic.system;

import be.mxs.common.util.db.MedwanQuery;
import be.mxs.common.util.system.ScreenHelper;
import be.mxs.common.util.system.Debug;

import java.sql.Connection;
import java.sql.Timestamp;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.Vector;
import java.util.Hashtable;

public class Examination {
    private int id;
    private String transactionType;
    private String messageKey;
    private int priority;
    private byte[] data;
    private Timestamp updatetime;
    private Timestamp deletedate;
    private int updateuserid;
    private int cost;
    private int income;

    //--- CONSTRUCTOR (1) -------------------------------------------------------------------------
    public Examination(){
    	// empty
    }
    
    //--- CONSTRUCTOR (2) -------------------------------------------------------------------------
    public Examination(String transactionType){
        this.transactionType = transactionType;
        cost = 0;
        income = 0;
        
        // set cost and income
        Connection oc_conn = MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            PreparedStatement ps = oc_conn.prepareStatement("select * from ExaminationCosts where transactionType=?");
            ps.setString(1,transactionType);
            ResultSet rs = ps.executeQuery();
            if(rs.next()){
                cost = rs.getInt("cost");
                income = rs.getInt("income");
            }
            rs.close();
            ps.close();
        }
        catch(Exception e){
            e.printStackTrace();
        }
        
        // close connection
        try {
			oc_conn.close();
		}
        catch (SQLException e) {
			e.printStackTrace();
		}
    }

    //--- COST ------------------------------------------------------------------------------------
    public int getCost() {
        return cost;
    }

    public void setCost(int cost) {
        this.cost = cost;
    }

    //--- INCOME ----------------------------------------------------------------------------------
    public int getIncome() {
        return income;
    }

    public void setIncome(int income) {
        this.income = income;
    }
    
    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public String getTransactionType() {
        return transactionType;
    }

    public void setTransactionType(String transactionType) {
        this.transactionType = transactionType;
    }

    public String getMessageKey() {
        return messageKey;
    }

    public void setMessageKey(String messageKey) {
        this.messageKey = messageKey;
    }

    public int getPriority() {
        return priority;
    }

    public void setPriority(int priority) {
        this.priority = priority;
    }

    public byte[] getData() {
        return data;
    }

    public void setData(byte[] data) {
        this.data = data;
    }

    public Timestamp getUpdatetime() {
        return updatetime;
    }

    public void setUpdatetime(Timestamp updatetime) {
        this.updatetime = updatetime;
    }

    public Timestamp getDeletedate() {
        return deletedate;
    }

    public void setDeletedate(Timestamp deletedate) {
        this.deletedate = deletedate;
    }

    public int getUpdateuserid() {
        return updateuserid;
    }

    public void setUpdateuserid(int updateuserid) {
        this.updateuserid = updateuserid;
    }

    //--- ADD EXAMINATION -------------------------------------------------------------------------
    public static void addExamination(Examination objExam){
        PreparedStatement ps = null;

        String sInsert = "INSERT INTO Examinations(updatetime,updateuserid,data,priority,transactionType,messageKey,id)"+
                         " VALUES(?,?,?,?,?,?,?)";
        Connection oc_conn = MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            ps = oc_conn.prepareStatement(sInsert);
            ps.setTimestamp(1,objExam.getUpdatetime());
            ps.setInt(2,objExam.getUpdateuserid());
            ps.setBytes(3,objExam.getData());
            ps.setInt(4,objExam.getPriority());
            ps.setString(5,objExam.getTransactionType());
            ps.setString(6,ScreenHelper.checkString(objExam.getMessageKey()));
            ps.setInt(7,objExam.getId());

            ps.executeUpdate();
        }
        catch(Exception e){
            e.printStackTrace();
        }
        finally{
            try{
                if(ps!=null)ps.close();
                oc_conn.close();
            }
            catch(Exception e){
                e.printStackTrace();
            }
        }
        
        MedwanQuery.getInstance().removeExamination(objExam.getId()+"");
    }

    //--- SAVE EXAMINATION ------------------------------------------------------------------------
    public static void saveExamination(Examination objExam){
        PreparedStatement ps = null;

        String sUpdate = "UPDATE Examinations SET updatetime = ?, updateuserid = ?, data = ?,"+
                         "  priority = ?, transactionType = ?, messageKey = ?"+
                         " WHERE id = ?";
        Connection oc_conn = MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            ps = oc_conn.prepareStatement(sUpdate);
            ps.setTimestamp(1,objExam.getUpdatetime());
            ps.setInt(2,objExam.getUpdateuserid());
            ps.setBytes(3,objExam.getData());
            ps.setInt(4,objExam.getPriority());
            ps.setString(5,objExam.getTransactionType());
            ps.setString(6,ScreenHelper.checkString(objExam.getMessageKey()));
            ps.setInt(7,objExam.getId());

            ps.executeUpdate();
        }
        catch(Exception e){
            e.printStackTrace();
        }
        finally{
            try{
                if(ps!=null)ps.close();
                oc_conn.close();
            }
            catch(Exception e){
                e.printStackTrace();
            }
        }
        
        MedwanQuery.getInstance().removeExamination(objExam.getId()+"");
    }

    //--- DELETE EXAMINATION ----------------------------------------------------------------------
    public static void deleteExamination(Examination objExam){
        PreparedStatement ps = null;

        String sDelete = "UPDATE Examinations SET deletedate=?, updatetime=?, updateuserid=?"+
                         " WHERE id=?";
        Connection oc_conn = MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            ps = oc_conn.prepareStatement(sDelete);
            ps.setTimestamp(1,objExam.getDeletedate());
            ps.setTimestamp(2,objExam.getUpdatetime());
            ps.setInt(3,objExam.getUpdateuserid());
            ps.setInt(4,objExam.getId());
            
            ps.executeUpdate();
        }
        catch(Exception e){
            e.printStackTrace();
        }
        finally{
            try{
                if(ps!=null)ps.close();
                oc_conn.close();
            }
            catch(Exception e){
                e.printStackTrace();
            }
        }
        
        MedwanQuery.getInstance().removeExamination(objExam.getId()+"");
    }

    //--- SELECT EXAMINATIONS ---------------------------------------------------------------------
    public static Vector SelectExaminations(){
        PreparedStatement ps = null;
        ResultSet rs = null;

        String sSelect = "SELECT * FROM Examinations WHERE deletedate IS NULL";

        Vector vExams = new Vector();
        Examination objExam;

        Connection oc_conn = MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            ps = oc_conn.prepareStatement(sSelect);
            rs = ps.executeQuery();

            while(rs.next()){
                objExam = new Examination();

                objExam.setUpdatetime(rs.getTimestamp("updatetime"));
                objExam.setUpdateuserid(rs.getInt("updateuserid"));
                objExam.setDeletedate(rs.getTimestamp("deletedate"));
                objExam.setData(rs.getBytes("data"));
                objExam.setId(rs.getInt("id"));
                objExam.setPriority(rs.getInt("priority"));
                objExam.setTransactionType(ScreenHelper.checkString(rs.getString("transactionType")));
                objExam.setMessageKey(ScreenHelper.checkString(rs.getString("messagekey")));

                vExams.addElement(objExam);
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
                e.printStackTrace();
            }
        }
        
        return vExams;
    }

    //--- SEARCH ALL EXAMINATIONS -----------------------------------------------------------------
    public static Vector searchAllExaminations(){
        PreparedStatement ps = null;
        ResultSet rs = null;

        String sSelect = "SELECT id,transactionType FROM Examinations";

        Vector vResults = new Vector();
        Hashtable hResults;
        Connection oc_conn = MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            ps = oc_conn.prepareStatement(sSelect);
            rs = ps.executeQuery();

            while(rs.next()){
                hResults = new Hashtable();
                hResults.put("id",Integer.toString(rs.getInt("id")));
                hResults.put("transactionType",ScreenHelper.checkString(rs.getString("transactionType")));
                vResults.addElement(hResults);
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
                e.printStackTrace();
            }
        }
        
        return vResults;
    }

    //--- SEARCH EXAMINATION ----------------------------------------------------------------------
    public static String searchExamination(int id){
        PreparedStatement ps = null;
        ResultSet rs = null;

        String sSelect = "SELECT transactionType FROM Examinations where id = ?";
        String sValue = "";

        Connection oc_conn = MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            ps = oc_conn.prepareStatement(sSelect);
            ps.setInt(1,id);
            rs = ps.executeQuery();

            if(rs.next()){
                sValue = ScreenHelper.checkString(rs.getString("transactionType"));
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
                e.printStackTrace();
            }
        }
        
        return sValue;
    }

    //--- GET -------------------------------------------------------------------------------------
    public static Examination get(String examinationId){
        Examination examination = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        Connection oc_conn = MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            String sSelect = "SELECT * FROM Examinations WHERE id = ?";
            ps = oc_conn.prepareStatement(sSelect);
            ps.setInt(1,Integer.parseInt(examinationId));
            rs = ps.executeQuery();

            // get data from DB
            if(rs.next()){
                examination = new Examination();

                examination.setUpdatetime(rs.getTimestamp("updatetime"));
                examination.setUpdateuserid(rs.getInt("updateuserid"));
                examination.setDeletedate(rs.getTimestamp("deletedate"));
                examination.setData(rs.getBytes("data"));
                examination.setId(rs.getInt("id"));
                examination.setPriority(rs.getInt("priority"));
                examination.setTransactionType(ScreenHelper.checkString(rs.getString("transactionType")));
                examination.setMessageKey(ScreenHelper.checkString(rs.getString("messagekey")));
            }
            else{
                throw new Exception("ERROR : EXAMINATION "+examinationId+" NOT FOUND");
            }
        }
        catch(Exception e){
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

        return examination;
    }

    //--- GET BY TYPE -----------------------------------------------------------------------------
    public static Examination getByType(String examinationType){
        Examination examination = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            String sSelect = "SELECT * FROM Examinations WHERE transactionType = ?";
            ps = oc_conn.prepareStatement(sSelect);
            ps.setString(1,examinationType);
            rs = ps.executeQuery();

            // get data from DB
            if(rs.next()){
                examination = new Examination();

                examination.setUpdatetime(rs.getTimestamp("updatetime"));
                examination.setUpdateuserid(rs.getInt("updateuserid"));
                examination.setDeletedate(rs.getTimestamp("deletedate"));
                examination.setData(rs.getBytes("data"));
                examination.setId(rs.getInt("id"));
                examination.setPriority(rs.getInt("priority"));
                examination.setTransactionType(ScreenHelper.checkString(rs.getString("transactionType")));
                examination.setMessageKey(ScreenHelper.checkString(rs.getString("messagekey")));
            }
            else{
                throw new Exception("INFO : EXAMINATION of type '"+examinationType+"' NOT FOUND");
            }
        }
        catch(Exception e){
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

        return examination;
    }
}
