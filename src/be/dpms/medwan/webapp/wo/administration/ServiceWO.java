package be.dpms.medwan.webapp.wo.administration;

import be.mxs.common.model.vo.IValueObject;

/**
 * Created by IntelliJ IDEA.
 * User: Michaël
 * Date: 19-avr.-2003
 * Time: 21:48:09
 * To change this template use Options | File Templates.
 */
public class ServiceWO implements IValueObject {

    private String              serviceId;
    private String              address;
    private String              city;
    private String              zipcode;
    private String              country;
    private String              telephone;
    private String              fax;
    private String              comment;
    private java.sql.Timestamp  updatetime;

    public ServiceWO() {
    }

    public String getServiceId() {
        return serviceId;
    }

    public void setServiceId(String serviceId) {
        this.serviceId = serviceId;
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

    public java.sql.Timestamp getUpdatetime() {
        return updatetime;
    }

    public void setUpdatetime(java.sql.Timestamp updatetime) {
        this.updatetime = updatetime;
    }
}
