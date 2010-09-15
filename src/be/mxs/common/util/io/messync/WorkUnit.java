package be.mxs.common.util.io.messync;

import org.w3c.dom.Node;

import java.util.Vector;

/**
 * Created by IntelliJ IDEA.
 * User: MXS
 * Date: 21-mrt-2005
 * Time: 16:23:00
 * To change this template use Options | File Templates.
 */
public class WorkUnit {
    private String type, address, city, zipcode, country, telephone, fax, email
    , contract, contracttype, contactperson, comment;
    private Vector ids, labels;

    public WorkUnit() {
        this.type = "";
        this.address = "";
        this.city = "";
        this.zipcode = "";
        this.country = "";
        this.telephone = "";
        this.fax = "";
        this.email = "";
        this.contract = "";
        this.contracttype = "";
        this.contactperson = "";
        this.comment = "";
        this.ids = new Vector();
        this.labels = new Vector();
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

    public String getComment() {
        return comment;
    }

    public void setComment(String comment) {
        this.comment = comment;
    }

    public Vector getIds() {
        return ids;
    }

    public void setIds(Vector ids) {
        this.ids = ids;
    }

    public Vector getLabels() {
        return labels;
    }

    public void setLabels(Vector labels) {
        this.labels = labels;
    }

    public void addID(ID id){
        if (id!=null){
            if (this.ids == null){
                this.ids = new Vector();
            }
            this.ids.add(id);
        }
    }

    public void addLabel(Label label){
        if (label!=null){
            if (this.labels == null){
                this.labels = new Vector();
            }
            this.labels.add(label);
        }
    }

    public void parse (Node n) {
        this.type = Helper.getAttribute(n,"type");
        this.address = Helper.getAttribute(n,"address");
        this.city = Helper.getAttribute(n,"city");
        this.zipcode = Helper.getAttribute(n,"zipcode");
        this.country = Helper.getAttribute(n,"country");
        this.telephone = Helper.getAttribute(n,"telephone");
        this.fax = Helper.getAttribute(n,"fax");
        this.email = Helper.getAttribute(n,"email");
        this.contract = Helper.getAttribute(n,"contract");
        this.contracttype = Helper.getAttribute(n,"contracttype");
        this.contactperson = Helper.getAttribute(n,"contactperson");
        this.comment = Helper.getAttribute(n,"comment");

        if (n.hasChildNodes()) {
            ID id;
            Label label;

            for (Node child = n.getFirstChild(); child != null; child = child.getNextSibling()) {
                if (child.getNodeName().toLowerCase().equals("id")) {
                    id = new ID();
                    id.parse(child);
                    this.ids.add(id);
                }
                else if (child.getNodeName().toLowerCase().equals("label")) {
                    label = new Label();
                    label.parse(child);
                    this.labels.add(label);
                }
            }
        }
    }

     public String toXML(int iIndent) {
        String sReturn = Helper.beginTag(this.getClass().getName(),iIndent)
            +Helper.writeTagAttribute("Type",this.type)
            +Helper.writeTagAttribute("Address",this.address)
            +Helper.writeTagAttribute("City",this.city)
            +Helper.writeTagAttribute("Zipcode",this.zipcode)
            +Helper.writeTagAttribute("Country",this.country)
            +Helper.writeTagAttribute("Telephone",this.telephone)
            +Helper.writeTagAttribute("Fax",this.fax)
            +Helper.writeTagAttribute("Email",this.email)
            +Helper.writeTagAttribute("Contract",this.contract)
            +Helper.writeTagAttribute("ContractType",this.contracttype)
            +Helper.writeTagAttribute("ContactPerson",this.contactperson)
            +Helper.writeTagAttribute("Comment",this.comment)
            +">\r\n";
        for (int i=0; i<labels.size();i++) {
          sReturn += ((Label)(labels.elementAt(i))).toXML(iIndent+1);
        }
        for (int i=0; i<ids.size();i++) {
          sReturn += ((ID)(ids.elementAt(i))).toXML(iIndent+1);
        }

        return sReturn+Helper.endTag(this.getClass().getName(),iIndent);
    }
}
