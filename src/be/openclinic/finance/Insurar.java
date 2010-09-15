package be.openclinic.finance;

import be.openclinic.common.OC_Object;
import be.mxs.common.util.db.MedwanQuery;

import java.util.Vector;
import java.util.Date;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;


public class Insurar extends OC_Object {
    private String name;
    private String contact;
    private String language;
    private String contactPerson;
    private String officialName;
    private Vector insuranceCategories;
    private String type;
    private int userid;


    //--- CONSTRUCTOR ---
    public Insurar(){
        this.insuranceCategories = new Vector();
    }

    //--- GETTERS AND SETTERS ---------------------------------------------------------------------
    public String getName() {
        return name;
    }

    public String getType() {
        return type;
    }

    public void setType(String type) {
        this.type = type;
    }

    public void setName(String name) {
        this.name = name;
    }
    public String getLanguage() {
        return language;
    }

    public void setLanguage(String language) {
        this.language = language;
    }

    public String getContact() {
        return contact;
    }

    public void setContact(String contact) {
        this.contact = contact;
    }

    public String getContactPerson() {
        return contactPerson;
    }

    public void setContactPerson(String contactPerson) {
        this.contactPerson = contactPerson;
    }

    public void setOfficialName(String officialName) {
        this.officialName = officialName;
    }

    public String getOfficialName() {
        return officialName;
    }

    public Vector getInsuraceCategories() {
        return insuranceCategories;
    }

    public void setInsuraceCategories(Vector insuraceCategories) {
        this.insuranceCategories = insuraceCategories;
    }

    //--- GET INSURANCE CATEGORY ------------------------------------------------------------------
    public InsuranceCategory getInsuranceCategory(String category){
        InsuranceCategory insuranceCategory = new InsuranceCategory();
        for(int n=0;n<insuranceCategories.size();n++){
            InsuranceCategory insCat = (InsuranceCategory)insuranceCategories.elementAt(n);
            if(insCat.getCategory().equalsIgnoreCase(category)){
                return insCat;
            }
        }
        return insuranceCategory;
    }

    //--- ADD INSURANCE CATEGORY ------------------------------------------------------------------
    public void addInsuranceCategory(String uid,String category,String label,String patientShare){
        for(int n=0;n<insuranceCategories.size();n++){
            InsuranceCategory insCat = (InsuranceCategory)insuranceCategories.elementAt(n);
            if(insCat.getCategory().equalsIgnoreCase(category)){
                insCat.setUid(uid);
                insCat.setLabel(label);
                insCat.setPatientShare(patientShare);
                return;
            }
        }

        insuranceCategories.add(new InsuranceCategory(uid,category,label,patientShare,getUid()));
    }

    //--- GET INSURARS BY NAME --------------------------------------------------------------------
    public static Vector getInsurarsByName(String name){
        Vector insurars = new Vector();
        PreparedStatement ps = null;
        ResultSet rs = null;

        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            String sQuery = "SELECT * FROM OC_INSURARS"+
                            " WHERE OC_INSURAR_NAME LIKE ? order by OC_INSURAR_NAME";
            ps = oc_conn.prepareStatement(sQuery);
            ps.setString(1,name+"%");
            rs = ps.executeQuery();
            while(rs.next()){
                insurars.add(Insurar.get(rs.getInt("OC_INSURAR_SERVERID"),rs.getInt("OC_INSURAR_OBJECTID")));
            }
        }
        catch(Exception e){
            e.printStackTrace();
        }
        finally{
            try{
                if(ps!=null) ps.close();
                if(rs!=null) rs.close();
                oc_conn.close();
            }
            catch(SQLException e){
                e.printStackTrace();
            }
        }

        return insurars;
    }

    //--- GET -------------------------------------------------------------------------------------
    public static Insurar get(String uid){
        if ((uid!=null)&&(uid.length()>0)){
            String [] ids = uid.split("\\.");
            if (ids.length==2){
                return get(Integer.parseInt(ids[0]),Integer.parseInt(ids[1]));
            }
        }
        return new Insurar();
    }

    public static Insurar get(int serverid, int objectid){
        PreparedStatement ps = null;
        ResultSet rs = null;

        Insurar insurar = new Insurar();

        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            String sQuery = "SELECT * FROM OC_INSURARS"+
                            " WHERE OC_INSURAR_SERVERID=? AND OC_INSURAR_OBJECTID=?";
            ps = oc_conn.prepareStatement(sQuery);
            ps.setInt(1,serverid);
            ps.setInt(2,objectid);
            rs = ps.executeQuery();

            if(rs.next()){
                insurar.setUid(serverid+"."+objectid);
                insurar.setName(rs.getString("OC_INSURAR_NAME"));
                insurar.setLanguage(rs.getString("OC_INSURAR_LANGUAGE"));
                insurar.setContact(rs.getString("OC_INSURAR_CONTACT"));
                insurar.setContactPerson(rs.getString("OC_INSURAR_CONTACTPERSON"));
                insurar.setOfficialName(rs.getString("OC_INSURAR_OFFICIAL_NAME"));
                insurar.setCreateDateTime(rs.getTimestamp("OC_INSURAR_CREATETIME"));
                insurar.setUpdateDateTime(rs.getTimestamp("OC_INSURAR_UPDATETIME"));
                insurar.setUpdateUser(rs.getString("OC_INSURAR_UPDATEUID"));
                insurar.setVersion(rs.getInt("OC_INSURAR_VERSION"));
                insurar.setType(rs.getString("OC_INSURAR_TYPE"));
                rs.close();
                ps.close();

                // load categories
                sQuery = "SELECT * FROM OC_INSURANCECATEGORIES"+
                         " WHERE OC_INSURANCECATEGORY_INSURARUID=?"+
                         "  ORDER BY OC_INSURANCECATEGORY_CATEGORY";
                ps = oc_conn.prepareStatement(sQuery);
                ps.setString(1,insurar.getUid());
                rs = ps.executeQuery();
                while(rs.next()){
                    insurar.addInsuranceCategory(
                        rs.getString("OC_INSURANCECATEGORY_SERVERID")+"."+rs.getString("OC_INSURANCECATEGORY_OBJECTID"),
                        rs.getString("OC_INSURANCECATEGORY_CATEGORY"),
                        rs.getString("OC_INSURANCECATEGORY_LABEL"),
                        rs.getInt("OC_INSURANCECATEGORY_PATIENTSHARE")+""
                    );
                }
                rs.close();
                ps.close();
            }
        }
        catch(Exception e){
            e.printStackTrace();
        }
        finally{
            try{
                if(ps!=null) ps.close();
                if(rs!=null) rs.close();
                oc_conn.close();
            }
            catch(SQLException e){
                e.printStackTrace();
            }
        }

        return insurar;
    }

    //--- STORE -----------------------------------------------------------------------------------
    public void store(int userid){
        this.userid=userid;
        store();
    }

    public void store(){
        PreparedStatement ps = null;
        ResultSet rs = null;

        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            // check existence
            String sQuery = "SELECT * FROM OC_INSURARS"+
                            " WHERE OC_INSURAR_SERVERID=? AND OC_INSURAR_OBJECTID=?";
            ps = oc_conn.prepareStatement(sQuery);
            ps.setInt(1,Integer.parseInt(getUid().split("\\.")[0]));
            ps.setInt(2,Integer.parseInt(getUid().split("\\.")[1]));
            rs = ps.executeQuery();

            if(rs.next()){
                //*** UPDATE ***
                sQuery = "UPDATE OC_INSURARS SET"+
                         "  OC_INSURAR_UPDATETIME=?,"+
                         "  OC_INSURAR_UPDATEUID=?,"+
                         "  OC_INSURAR_VERSION=OC_INSURAR_VERSION+1,"+
                         "  OC_INSURAR_NAME=?,"+
                         "  OC_INSURAR_LANGUAGE=?,"+
                         "  OC_INSURAR_CONTACT=?,"+
                         "  OC_INSURAR_OFFICIAL_NAME=?,"+
                         "  OC_INSURAR_CONTACTPERSON=?,"+
                         "  OC_INSURAR_TYPE=?"+
                         " WHERE OC_INSURAR_SERVERID=? AND OC_INSURAR_OBJECTID=?";
                rs.close();
                ps.close();
                ps = oc_conn.prepareStatement(sQuery);
                ps.setDate(1, new java.sql.Date(new Date().getTime())); // now
                ps.setString(2,userid+"");
                ps.setString(3,getName());
                ps.setString(4,getLanguage());
                ps.setString(5,getContact());
                ps.setString(6,getOfficialName());
                ps.setString(7,getContactPerson());
                ps.setString(8,getType());
                ps.setInt(9,Integer.parseInt(getUid().split("\\.")[0]));
                ps.setInt(10,Integer.parseInt(getUid().split("\\.")[1]));
                ps.execute();
                ps.close();

                // delete and re-insert categories
                sQuery = "DELETE FROM OC_INSURANCECATEGORIES"+
                         " WHERE OC_INSURANCECATEGORY_INSURARUID=?";
                ps = oc_conn.prepareStatement(sQuery);
                ps.setString(1,getUid());
                ps.execute();
                ps.close();

                InsuranceCategory insuranceCategory;
                for(int n=0;n<insuranceCategories.size();n++){
                    insuranceCategory = (InsuranceCategory)insuranceCategories.elementAt(n);

                    sQuery = "INSERT INTO OC_INSURANCECATEGORIES("+
                             "  OC_INSURANCECATEGORY_CREATETIME,"+
                             "  OC_INSURANCECATEGORY_UPDATETIME,"+
                             "  OC_INSURANCECATEGORY_UPDATEUID,"+
                             "  OC_INSURANCECATEGORY_VERSION,"+
                             "  OC_INSURANCECATEGORY_SERVERID,"+
                             "  OC_INSURANCECATEGORY_OBJECTID,"+
                             "  OC_INSURANCECATEGORY_INSURARUID,"+
                             "  OC_INSURANCECATEGORY_CATEGORY,"+
                             "  OC_INSURANCECATEGORY_LABEL,"+
                             "  OC_INSURANCECATEGORY_PATIENTSHARE)"+
                             " VALUES (?,?,?,?,?,?,?,?,?,?)";
                    ps = oc_conn.prepareStatement(sQuery);
                    ps.setDate(1, new java.sql.Date(new Date().getTime()));
                    ps.setDate(2, new java.sql.Date(new Date().getTime()));
                    ps.setString(3,userid+"");
                    ps.setInt(4,1);
                    ps.setInt(5,Integer.parseInt(getUid().split("\\.")[0]));
                    ps.setInt(6,Integer.parseInt(insuranceCategory.getUid().split("\\.")[0])>-1?Integer.parseInt(insuranceCategory.getUid().split("\\.")[1]):MedwanQuery.getInstance().getOpenclinicCounter("InsuranceCategoryId"));
                    ps.setString(7,getUid());
                    ps.setString(8,insuranceCategory.getCategory());
                    ps.setString(9,insuranceCategory.getLabel());
                    ps.setInt(10,Integer.parseInt(insuranceCategory.getPatientShare()));
                    ps.execute();
                    ps.close();
                }
            }
            else{
                //*** INSERT ***
                int objectid = MedwanQuery.getInstance().getOpenclinicCounter("InsurarId");
                rs.close();
                ps.close();

                sQuery = "INSERT INTO OC_INSURARS("+
                         "  OC_INSURAR_CREATETIME,"+
                         "  OC_INSURAR_UPDATETIME,"+
                         "  OC_INSURAR_UPDATEUID,"+
                         "  OC_INSURAR_VERSION,"+
                         "  OC_INSURAR_SERVERID,"+
                         "  OC_INSURAR_OBJECTID,"+
                         "  OC_INSURAR_NAME,"+
                         "  OC_INSURAR_LANGUAGE,"+
                         "  OC_INSURAR_CONTACT,"+
                         "  OC_INSURAR_OFFICIAL_NAME,"+
                         "  OC_INSURAR_TYPE,"+
                         "  OC_INSURAR_CONTACTPERSON)"+
                         " VALUES(?,?,?,?,?,?,?,?,?,?,?,?)";
                ps = oc_conn.prepareStatement(sQuery);
                ps.setDate(1, new java.sql.Date(new Date().getTime()));
                ps.setDate(2, new java.sql.Date(new Date().getTime()));
                ps.setString(3,userid+"");
                ps.setInt(4,1);
                ps.setInt(5,Integer.parseInt(getUid().split("\\.")[0]));
                ps.setInt(6,objectid);
                ps.setString(7,getName());
                ps.setString(8,getLanguage());
                ps.setString(9,getContact());
                ps.setString(10,getOfficialName());
                ps.setString(11,getType());
                ps.setString(12,getContactPerson());
                ps.execute();
                ps.close();

                setUid(Integer.parseInt(getUid().split("\\.")[0])+"."+objectid);

                // add categories
                InsuranceCategory insuranceCategory;
                for(int n=0;n<insuranceCategories.size();n++){
                    insuranceCategory = (InsuranceCategory)insuranceCategories.elementAt(n);

                    sQuery = "INSERT INTO OC_INSURANCECATEGORIES("+
                             "  OC_INSURANCECATEGORY_CREATETIME,"+
                             "  OC_INSURANCECATEGORY_UPDATETIME,"+
                             "  OC_INSURANCECATEGORY_UPDATEUID,"+
                             "  OC_INSURANCECATEGORY_VERSION,"+
                             "  OC_INSURANCECATEGORY_SERVERID,"+
                             "  OC_INSURANCECATEGORY_OBJECTID,"+
                             "  OC_INSURANCECATEGORY_INSURARUID,"+
                             "  OC_INSURANCECATEGORY_CATEGORY,"+
                             "  OC_INSURANCECATEGORY_LABEL,"+
                             "  OC_INSURANCECATEGORY_PATIENTSHARE)"+
                             " VALUES (?,?,?,?,?,?,?,?,?,?)";
                    ps = oc_conn.prepareStatement(sQuery);
                    ps.setDate(1, new java.sql.Date(new Date().getTime()));
                    ps.setDate(2, new java.sql.Date(new Date().getTime()));
                    ps.setString(3,userid+"");
                    ps.setInt(4,1);
                    ps.setInt(5,Integer.parseInt(getUid().split("\\.")[0]));
                    ps.setInt(6,Integer.parseInt(insuranceCategory.getUid().split("\\.")[0])>-1?Integer.parseInt(insuranceCategory.getUid().split("\\.")[1]):MedwanQuery.getInstance().getOpenclinicCounter("InsuranceCategoryId"));
                    ps.setString(7,getUid());
                    ps.setString(8,insuranceCategory.getCategory());
                    ps.setString(9,insuranceCategory.getLabel());
                    ps.setInt(10,Integer.parseInt(insuranceCategory.getPatientShare()));
                    ps.execute();
                    ps.close();
                }
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
            catch(SQLException e){
                e.printStackTrace();
            }
        }
    }

    //--- DELETE ----------------------------------------------------------------------------------
    public static void delete(String uid){
        delete(Integer.parseInt(uid.split("\\.")[0]),Integer.parseInt(uid.split("\\.")[1]));
    }

    public static void delete(int serverid, int objectid){
        // delete insurar
        PreparedStatement ps = null;

        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            String sQuery = "DELETE FROM OC_INSURARS"+
                            " WHERE OC_INSURAR_SERVERID=?"+
                            "  AND OC_INSURAR_OBJECTID=?";
            ps = oc_conn.prepareStatement(sQuery);
            ps.setInt(1,serverid);
            ps.setInt(2,objectid);
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

        // delete its categories
        deleteCategories(serverid,objectid);
    }

    //--- DELETE CATEGORIES -----------------------------------------------------------------------
    public static void deleteCategories(int serverid, int objectid){
        deleteCategories(serverid+"."+objectid);
    }

    public static void deleteCategories(String insurarUid){
        PreparedStatement ps = null;

        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            String sQuery = "DELETE FROM OC_INSURANCECATEGORIES"+
                            " WHERE OC_INSURANCECATEGORY_INSURARUID=?";
            ps = oc_conn.prepareStatement(sQuery);
            ps.setString(1,insurarUid);
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

    //--- DELETE CATEGORY -------------------------------------------------------------------------
    // first copy category to history table
    public static void deleteCategory(int serverid, int objectid, String sCategoryLetter){
        deleteCategory(serverid+"."+objectid,sCategoryLetter);
    }

    public static void deleteCategory(String sInsurarUid, String sCategoryLetter){
        PreparedStatement ps = null;
        String sQuery;

        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            // copy to history
            sQuery = "INSERT INTO OC_INSURANCECATEGORIES_HISTORY"+
                     " SELECT * FROM OC_INSURANCECATEGORIES"+
                     "  WHERE OC_INSURANCECATEGORY_INSURARUID=?"+
                     "   AND OC_INSURANCECATEGORY_CATEGORY=?";
            ps = oc_conn.prepareStatement(sQuery);
            ps.setString(1,sInsurarUid);
            ps.setString(2,sCategoryLetter);
            ps.executeUpdate();
            ps.close();

            // delete
            sQuery = "DELETE FROM OC_INSURANCECATEGORIES"+
                     " WHERE OC_INSURANCECATEGORY_INSURARUID=?"+
                     "  AND OC_INSURANCECATEGORY_CATEGORY=?";
            ps = oc_conn.prepareStatement(sQuery);
            ps.setString(1,sInsurarUid);
            ps.setString(2,sCategoryLetter);
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
