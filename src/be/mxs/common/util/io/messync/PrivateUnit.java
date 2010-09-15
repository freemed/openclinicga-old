package be.mxs.common.util.io.messync;

import org.w3c.dom.Node;

/**
 * Created by IntelliJ IDEA.
 * User: MXS
 * Date: 21-mrt-2005
 * Time: 16:24:01
 * To change this template use Options | File Templates.
 */
public class PrivateUnit {
    private String begin, end, type, address, city
    , zipcode, country, telephone, fax, email, comment;

    public PrivateUnit() {
        this.begin = "";
        this.end = "";
        this.type = "";
        this.address = "";
        this.city = "";
        this.zipcode = "";
        this.country = "";
        this.telephone = "";
        this.fax = "";
        this.email = "";
        this.comment = "";
    }

    public String getBegin() {
        return begin;
    }

    public void setBegin(String begin) {
        this.begin = begin;
    }

    public String getEnd() {
        return end;
    }

    public void setEnd(String end) {
        this.end = end;
    }

    public String getType() {
        return type;
    }

    public void setType(String type) {
        this.type = type;
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

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public String getComment() {
        return comment;
    }

    public void setComment(String comment) {
        this.comment = comment;
    }

    public void parse (Node n) {
        this.begin = Helper.getAttribute(n,"begin");
        this.end = Helper.getAttribute(n,"end");
        this.type = Helper.getAttribute(n,"type");
        this.address = Helper.getAttribute(n,"address");
        this.city = Helper.getAttribute(n,"city");
        this.zipcode = Helper.getAttribute(n,"zipcode");
        this.country = Helper.getAttribute(n,"country");
        this.telephone = Helper.getAttribute(n,"telephone");
        this.fax = Helper.getAttribute(n,"fax");
        this.email = Helper.getAttribute(n,"email");
        this.comment = Helper.getAttribute(n,"comment");
    }

    public String toXML(int iIndent) {
        return Helper.beginTag(this.getClass().getName(),iIndent)
            +Helper.writeTagAttribute("Begin",this.begin)
            +Helper.writeTagAttribute("End",this.end)
            +Helper.writeTagAttribute("Type",this.type)
            +Helper.writeTagAttribute("Address",this.address)
            +Helper.writeTagAttribute("City",this.city)
            +Helper.writeTagAttribute("Zipcode",this.zipcode)
            +Helper.writeTagAttribute("Country",this.country)
            +Helper.writeTagAttribute("Telephone",this.telephone)
            +Helper.writeTagAttribute("Fax",this.fax)
            +Helper.writeTagAttribute("Email",this.email)
            +Helper.writeTagAttribute("Comment",this.comment)
            +"/>\r\n";
    }
}
