package be.openclinic.system;

import be.mxs.common.util.db.MedwanQuery;
import be.mxs.common.util.system.ScreenHelper;

import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.PreparedStatement;
import java.sql.SQLException;
import java.util.Vector;

/**
 * Created by IntelliJ IDEA.
 * User: mxs_david
 * Date: 9-jan-2007
 * Time: 9:46:11
 * To change this template use Options | File Templates.
 */
public class ServiceExamination {
    private String serviceid;
    private String examinationid;

    public String getServiceid() {
        return serviceid;
    }

    public void setServiceid(String serviceid) {
        this.serviceid = serviceid;
    }

    public String getExaminationid() {
        return examinationid;
    }

    public void setExaminationid(String examinationid) {
        this.examinationid = examinationid;
    }

    public static boolean exists(ServiceExamination objSE){
        PreparedStatement ps = null;
        ResultSet rs = null;

        boolean bExists = false;

        String sSelect = "SELECT examinationid FROM ServiceExaminations where serviceid = ? and examinationid  = ?";

        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            ps = oc_conn.prepareStatement(sSelect);
            ps.setString(1,objSE.getServiceid());
            ps.setString(2,objSE.getExaminationid());

            rs = ps.executeQuery();

            if(rs.next()){
                bExists = true;
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
        return bExists;
    }

    public static void addServiceExamination(ServiceExamination objSE){
        PreparedStatement ps = null;

        String sInsert = "INSERT INTO ServiceExaminations(serviceid,examinationid) VALUES(?,?)";

        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            ps = oc_conn.prepareStatement(sInsert);
            ps.setString(1,objSE.getServiceid());
            ps.setString(2,objSE.getExaminationid());

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

    public static void deleteServiceExamination(ServiceExamination objSE){
        PreparedStatement ps = null;

        String sDelete = " DELETE FROM ServiceExaminations WHERE serviceid = ? AND examinationid = ?";

        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            ps = oc_conn.prepareStatement(sDelete);
            ps.setString(1,objSE.getServiceid());
            ps.setString(2,objSE.getExaminationid());

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

    public static Vector selectServiceExaminations(String sServiceId){
        PreparedStatement ps = null;
        ResultSet rs = null;

        Vector vSE = new Vector();

        String sSelect = "SELECT * FROM ServiceExaminations WHERE serviceid = ?";

        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            ps = oc_conn.prepareStatement(sSelect);
            ps.setString(1,sServiceId);

            rs = ps.executeQuery();

            ServiceExamination objSE;

            while(rs.next()){
                objSE = new ServiceExamination();

                objSE.setServiceid(ScreenHelper.checkString(rs.getString("serviceid")));
                objSE.setExaminationid(ScreenHelper.checkString(rs.getString("examinationid")));

                vSE.addElement(objSE);
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

        return vSE;
    }

    //--- DELETE ALL EXAMINATIONS FOR SERVICE -----------------------------------------------------
    public static void deleteAllExaminationsForService(String serviceId){
        PreparedStatement ps = null;

        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            String sQuery = "DELETE FROM ServiceExaminations WHERE serviceid = ?";
            ps = oc_conn.prepareStatement(sQuery);
            ps.setString(1,serviceId);

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
            catch(SQLException e){
                e.printStackTrace();
            }
        }
    }

    //--- SAVE TO DB ------------------------------------------------------------------------------
    public void saveToDB(){
        PreparedStatement ps = null;

        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            String sQuery = "INSERT INTO ServiceExaminations(serviceid,examinationid) VALUES(?,?)";
            ps = oc_conn.prepareStatement(sQuery);
            ps.setString(1,this.getServiceid());
            ps.setString(2,this.getExaminationid());

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
            catch(SQLException e){
                e.printStackTrace();
            }
        }
    }
}
