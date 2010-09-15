package be.openclinic.system;

import be.mxs.common.util.db.MedwanQuery;

import java.sql.Connection;
import java.sql.Timestamp;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.Vector;
import java.util.HashSet;
import java.util.Iterator;



/**
 * Created by IntelliJ IDEA.
 * User: mxs-rudy
 * Date: 12-mrt-2007
 * Time: 10:36:34
 * To change this template use File | Settings | File Templates.
 */
public class ExternalContact {
    private String serviceid;
    private String address;
    private String city;
    private String zipcode;
    private String country;
    private String telephone;
    private String fax;
    private String comment;
    private Timestamp updatetime;
    private String email;
    private String parentid;
    private String serviceparentid;
    private String inscode;
    private String serviceorder;
    private String servicelanguage;
    private int updateuserid;
    private String parentserviceid;
    private String code1;
    private String code2;
    private String code3;
    private String code4;
    private String code5;
    private String contract;
    private String contracttype;
    private String contactperson;
    private Timestamp contractdate;
    private String portal_email;
    private String contactaddress;
    private String contactzipcode;
    private String contactcity;
    private String contactcountry;
    private String contacttelephone;
    private String contactfax;
    private String contactemail;
    private String ssn;
    private String code6;
    private String defaultcontext;


    public String getServiceid() {
        return serviceid;
    }

    public void setServiceid(String serviceid) {
        this.serviceid = serviceid;
    }

    public String getAddress() {
        return address;
    }

    public void setAddress(String address) {
        this.address = address;
    }

    public String getCity() {
        return city;
    }

    public void setCity(String city) {
        this.city = city;
    }

    public String getZipcode() {
        return zipcode;
    }

    public void setZipcode(String zipcode) {
        this.zipcode = zipcode;
    }

    public String getCountry() {
        return country;
    }

    public void setCountry(String country) {
        this.country = country;
    }

    public String getTelephone() {
        return telephone;
    }

    public void setTelephone(String telephone) {
        this.telephone = telephone;
    }

    public String getFax() {
        return fax;
    }

    public void setFax(String fax) {
        this.fax = fax;
    }

    public String getComment() {
        return comment;
    }

    public void setComment(String comment) {
        this.comment = comment;
    }

    public Timestamp getUpdatetime() {
        return updatetime;
    }

    public void setUpdatetime(Timestamp updatetime) {
        this.updatetime = updatetime;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public String getParentid() {
        return parentid;
    }

    public void setParentid(String parentid) {
        this.parentid = parentid;
    }

    public String getServiceparentid() {
        return serviceparentid;
    }

    public void setServiceparentid(String serviceparentid) {
        this.serviceparentid = serviceparentid;
    }

    public String getInscode() {
        return inscode;
    }

    public void setInscode(String inscode) {
        this.inscode = inscode;
    }

    public String getServiceorder() {
        return serviceorder;
    }

    public void setServiceorder(String serviceorder) {
        this.serviceorder = serviceorder;
    }

    public String getServicelanguage() {
        return servicelanguage;
    }

    public void setServicelanguage(String servicelanguage) {
        this.servicelanguage = servicelanguage;
    }

    public int getUpdateuserid() {
        return updateuserid;
    }

    public void setUpdateuserid(int updateuserid) {
        this.updateuserid = updateuserid;
    }

    public String getParentserviceid() {
        return parentserviceid;
    }

    public void setParentserviceid(String parentserviceid) {
        this.parentserviceid = parentserviceid;
    }

    public String getCode1() {
        return code1;
    }

    public void setCode1(String code1) {
        this.code1 = code1;
    }

    public String getCode2() {
        return code2;
    }

    public void setCode2(String code2) {
        this.code2 = code2;
    }

    public String getCode3() {
        return code3;
    }

    public void setCode3(String code3) {
        this.code3 = code3;
    }

    public String getCode4() {
        return code4;
    }

    public void setCode4(String code4) {
        this.code4 = code4;
    }

    public String getCode5() {
        return code5;
    }

    public void setCode5(String code5) {
        this.code5 = code5;
    }

    public String getContract() {
        return contract;
    }

    public void setContract(String contract) {
        this.contract = contract;
    }

    public String getContracttype() {
        return contracttype;
    }

    public void setContracttype(String contracttype) {
        this.contracttype = contracttype;
    }

    public String getContactperson() {
        return contactperson;
    }

    public void setContactperson(String contactperson) {
        this.contactperson = contactperson;
    }

    public Timestamp getContractdate() {
        return contractdate;
    }

    public void setContractdate(Timestamp contractdate) {
        this.contractdate = contractdate;
    }

    public String getPortal_email() {
        return portal_email;
    }

    public void setPortal_email(String portal_email) {
        this.portal_email = portal_email;
    }

    public String getContactaddress() {
        return contactaddress;
    }

    public void setContactaddress(String contactaddress) {
        this.contactaddress = contactaddress;
    }

    public String getContactzipcode() {
        return contactzipcode;
    }

    public void setContactzipcode(String contactzipcode) {
        this.contactzipcode = contactzipcode;
    }

    public String getContactcity() {
        return contactcity;
    }

    public void setContactcity(String contactcity) {
        this.contactcity = contactcity;
    }

    public String getContactcountry() {
        return contactcountry;
    }

    public void setContactcountry(String contactcountry) {
        this.contactcountry = contactcountry;
    }

    public String getContacttelephone() {
        return contacttelephone;
    }

    public void setContacttelephone(String contacttelephone) {
        this.contacttelephone = contacttelephone;
    }

    public String getContactfax() {
        return contactfax;
    }

    public void setContactfax(String contactfax) {
        this.contactfax = contactfax;
    }

    public String getContactemail() {
        return contactemail;
    }

    public void setContactemail(String contactemail) {
        this.contactemail = contactemail;
    }

    public String getSsn() {
        return ssn;
    }

    public void setSsn(String ssn) {
        this.ssn = ssn;
    }

    public String getCode6() {
        return code6;
    }

    public void setCode6(String code6) {
        this.code6 = code6;
    }

    public String getDefaultcontext() {
        return defaultcontext;
    }

    public void setDefaultcontext(String defaultcontext) {
        this.defaultcontext = defaultcontext;
    }

    public void ExternalContact(){
        serviceid = "";
        address = "";
        city = "";
        zipcode = "";
        country = "";
        telephone = "";
        fax = "";
        comment = "";
        email = "";
        parentid = "";
        serviceparentid = "";
        inscode = "";
        serviceorder = "";
        servicelanguage = "";
        parentserviceid = "";
        code1 = "";
        code2 = "";
        code3 = "";
        code4 = "";
        code5 = "";
        contract = "";
        contracttype = "";
        contactperson = "";
        portal_email = "";
        contactaddress = "";
        contactzipcode = "";
        contactcity = "";
        contactcountry = "";
        contacttelephone = "";
        contactfax = "";
        contactemail = "";
        ssn = "";
        code6 = "";
        defaultcontext = "";
    }

    public static Vector getChildIds(String parentId){
        HashSet childIds = new HashSet();
        String childId = "";
        PreparedStatement ps = null;
        ResultSet rs = null;

    	Connection ad_conn = MedwanQuery.getInstance().getAdminConnection();
        try{
            if(childId!=null && childId.trim().length()>0){
                childIds.add(childId);
            }

            String sSelect = "SELECT serviceid FROM OC_EXTERNALCONTACTS WHERE serviceparentid = ?";
            ps = ad_conn.prepareStatement(sSelect);
            ps.setString(1,parentId);

            rs = ps.executeQuery();
            while(rs.next()){
                childId = rs.getString("serviceid");

                if(childId!=null && childId.trim().length()>0){
                    childIds.add(childId);
                    childIds.addAll(getChildIds(childId)); // recursion
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
                ad_conn.close();
            }
            catch(SQLException se){
                se.printStackTrace();
            }
        }

        // Set to Vector
        Iterator iter = childIds.iterator();
        Vector ids = new Vector();
        while(iter.hasNext()){
            ids.add(iter.next());
        }

        return ids;
    }
}
