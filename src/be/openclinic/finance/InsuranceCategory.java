package be.openclinic.finance;

import be.mxs.common.util.db.MedwanQuery;
import be.mxs.common.util.system.ScreenHelper;
import be.openclinic.common.OC_Object;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

/**
 * Created by IntelliJ IDEA.
 * User: Frank
 * Date: 18-feb-2008
 * Time: 14:40:40
 * To change this template use File | Settings | File Templates.
 */
public class InsuranceCategory extends OC_Object {
    private String category="";
    private String label="";
    private String patientShare="";
    private String insurarUid;
    private Insurar insurar;

    public String getInsurarUid() {
        return insurarUid;
    }

    public void setInsurarUid(String insurarUid) {
        this.insurarUid = insurarUid;
    }

    public Insurar getInsurar() {
        if(insurar==null){
            if(ScreenHelper.checkString(insurarUid).length()>0){
                insurar=Insurar.get(insurarUid);
            }
        }
        return insurar;
    }

    public void setInsurar(Insurar insurar) {
        this.insurar = insurar;
    }

    public InsuranceCategory() {
    }

    public InsuranceCategory(String uid,String category, String label, String patientShare, String insurarUid) {
        this.setUid(uid);
        this.category = category;
        this.label = label;
        this.patientShare = patientShare;
        this.insurarUid = insurarUid;
    }

    public InsuranceCategory(String category, String label, String patientShare) {
        this.category = category;
        this.label = label;
        this.patientShare = patientShare;
    }

    public String getCategory() {
        return category;
    }

    public void setCategory(String category) {
        this.category = category;
    }

    public String getLabel() {
        return label;
    }

    public void setLabel(String label) {
        this.label = label;
    }

    public String getPatientShare() {
        return patientShare;
    }

    public void setPatientShare(String patientShare) {
        this.patientShare = patientShare;
    }

    public static InsuranceCategory get(String uid){
        return get(Integer.parseInt(uid.split("\\.")[0]),Integer.parseInt(uid.split("\\.")[1]));
    }

    public static InsuranceCategory get(int serverid,int objectid){
        InsuranceCategory insuranceCategory = new InsuranceCategory();
        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            String sQuery="select * from OC_INSURANCECATEGORIES where OC_INSURANCECATEGORY_SERVERID=? and OC_INSURANCECATEGORY_OBJECTID=?";
            PreparedStatement ps = oc_conn.prepareStatement(sQuery);
            ps.setInt(1,serverid);
            ps.setInt(2,objectid);
            ResultSet rs = ps.executeQuery();
            if(rs.next()){
                insuranceCategory.setUid(serverid+"."+objectid);
                insuranceCategory.setCategory(rs.getString("OC_INSURANCECATEGORY_CATEGORY"));
                insuranceCategory.setLabel(rs.getString("OC_INSURANCECATEGORY_LABEL"));
                insuranceCategory.setPatientShare(rs.getInt("OC_INSURANCECATEGORY_PATIENTSHARE")+"");
                insuranceCategory.setInsurarUid(rs.getString("OC_INSURANCECATEGORY_INSURARUID"));
                insuranceCategory.setCreateDateTime(rs.getTimestamp("OC_INSURANCECATEGORY_CREATETIME"));
                insuranceCategory.setUpdateDateTime(rs.getTimestamp("OC_INSURANCECATEGORY_UPDATETIME"));
                insuranceCategory.setUpdateUser(rs.getString("OC_INSURANCECATEGORY_UPDATEUID"));
                insuranceCategory.setVersion(rs.getInt("OC_INSURANCECATEGORY_VERSION"));
            }
            rs.close();
            ps.close();
        }
        catch(Exception e){
            e.printStackTrace();
        }
        try {
			oc_conn.close();
		} catch (SQLException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
        return insuranceCategory;
    }

    public static InsuranceCategory get(String insurarUid,String categoryLetter){
        InsuranceCategory insuranceCategory = new InsuranceCategory();
        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            String sQuery="select * from OC_INSURANCECATEGORIES where OC_INSURANCECATEGORY_INSURARUID=? and OC_INSURANCECATEGORY_CATEGORY=?";
            PreparedStatement ps = oc_conn.prepareStatement(sQuery);
            ps.setString(1,insurarUid);
            ps.setString(2,categoryLetter);
            ResultSet rs = ps.executeQuery();
            if(rs.next()){
                insuranceCategory.setUid(rs.getInt("OC_INSURANCECATEGORY_SERVERID")+"."+rs.getInt("OC_INSURANCECATEGORY_OBJECTID"));
                insuranceCategory.setCategory(rs.getString("OC_INSURANCECATEGORY_CATEGORY"));
                insuranceCategory.setLabel(rs.getString("OC_INSURANCECATEGORY_LABEL"));
                insuranceCategory.setPatientShare(rs.getInt("OC_INSURANCECATEGORY_PATIENTSHARE")+"");
                insuranceCategory.setInsurarUid(rs.getString("OC_INSURANCECATEGORY_INSURARUID"));
                insuranceCategory.setCreateDateTime(rs.getTimestamp("OC_INSURANCECATEGORY_CREATETIME"));
                insuranceCategory.setUpdateDateTime(rs.getTimestamp("OC_INSURANCECATEGORY_UPDATETIME"));
                insuranceCategory.setUpdateUser(rs.getString("OC_INSURANCECATEGORY_UPDATEUID"));
                insuranceCategory.setVersion(rs.getInt("OC_INSURANCECATEGORY_VERSION"));
            }
            rs.close();
            ps.close();
        }
        catch(Exception e){
            e.printStackTrace();
        }
        try {
			oc_conn.close();
		} catch (SQLException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
        return insuranceCategory;
    }
}

