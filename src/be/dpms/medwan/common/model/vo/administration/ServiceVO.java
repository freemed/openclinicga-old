package be.dpms.medwan.common.model.vo.administration;

import be.mxs.common.model.vo.IIdentifiable;

import java.io.Serializable;

public class ServiceVO implements Serializable, IIdentifiable {

    public String              serviceId;
    public String              address;
    public String              city;
    public String              zipcode;
    public String              country;
    public String              telephone;
    public String              fax;
    public String              comment;
    public java.sql.Timestamp  updatetime;

    public ServiceVO() {
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

    public boolean equals(Object o) {
        if (this == o) return true;
        if (!(o instanceof ServiceVO)) return false;

        final ServiceVO serviceVO = (ServiceVO) o;

        return serviceId.equals(serviceVO.serviceId);

    }

    public int hashCode() {
        return serviceId.hashCode();
    }
}
