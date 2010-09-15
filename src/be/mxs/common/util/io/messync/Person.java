package be.mxs.common.util.io.messync;

import org.w3c.dom.Node;

import java.util.Vector;

/**
 * Created by IntelliJ IDEA.
 * User: MXS
 * Date: 21-mrt-2005
 * Time: 16:22:31
 * To change this template use Options | File Templates.
 */
public class Person {
    private String begin, end, firstname, middlename, lastname, dateofbirth, gender, language
    , comment1, comment2, comment3, comment4, comment5;
    private Vector ids, works, privates, medicals;

    public Person() {
        this.begin = "";
        this.end = "";
        this.firstname = "";
        this.middlename = "";
        this.lastname = "";
        this.dateofbirth = "";
        this.gender = "";
        this.language = "";
        this.comment1 = "";
        this.comment2 = "";
        this.comment3 = "";
        this.comment4 = "";
        this.comment5 = "";
        this.ids = new Vector();
        this.works = new Vector();
        this.privates = new Vector();
        this.medicals = new Vector();
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

    public String getFirstname() {
        return firstname;
    }

    public void setFirstname(String firstname) {
        this.firstname = firstname;
    }

    public String getMiddlename() {
        return middlename;
    }

    public void setMiddlename(String middlename) {
        this.middlename = middlename;
    }

    public String getLastname() {
        return lastname;
    }

    public void setLastname(String lastname) {
        this.lastname = lastname;
    }

    public String getDateofbirth() {
        return dateofbirth;
    }

    public void setDateofbirth(String dateofbirth) {
        this.dateofbirth = dateofbirth;
    }

    public String getGender() {
        return gender;
    }

    public void setGender(String gender) {
        this.gender = gender;
    }

    public String getLanguage() {
        return language;
    }

    public void setLanguage(String language) {
        this.language = language;
    }

    public String getComment1() {
        return comment1;
    }

    public void setComment1(String comment1) {
        this.comment1 = comment1;
    }

    public String getComment2() {
        return comment2;
    }

    public void setComment2(String comment2) {
        this.comment2 = comment2;
    }

    public String getComment3() {
        return comment3;
    }

    public void setComment3(String comment3) {
        this.comment3 = comment3;
    }

    public String getComment4() {
        return comment4;
    }

    public void setComment4(String comment4) {
        this.comment4 = comment4;
    }

    public String getComment5() {
        return comment5;
    }

    public void setComment5(String comment5) {
        this.comment5 = comment5;
    }

    public Vector getIds() {
        return ids;
    }

    public void setIds(Vector ids) {
        this.ids = ids;
    }

    public Vector getWorks() {
        return works;
    }

    public void setWorks(Vector works) {
        this.works = works;
    }

    public Vector getPrivates() {
        return privates;
    }

    public void setPrivates(Vector privates) {
        this.privates = privates;
    }

    public Vector getMedicals() {
        return medicals;
    }

    public void setMedicals(Vector medicals) {
        this.medicals = medicals;
    }

    public void addID(ID id){
        if (id!=null){
            if (this.ids == null){
                this.ids = new Vector();
            }
            this.ids.add(id);
        }
    }

    public void addWork(Work work){
        if (work!=null){
            if (this.works == null){
                this.works = new Vector();
            }
            this.works.add(work);
        }
    }

    public void addPrivate(Private myPrivate){
        if (myPrivate!=null){
            if (this.privates == null){
                this.privates = new Vector();
            }
            this.privates.add(myPrivate);
        }
    }

    public void addMedical(Medical medical){
        if (medical!=null){
            if (this.medicals == null){
                this.medicals = new Vector();
            }
            this.medicals.add(medical);
        }
    }
    public void parse (Node n) {
        this.begin = Helper.getAttribute(n,"begin");
        this.end = Helper.getAttribute(n,"end");
        this.firstname = Helper.getAttribute(n,"firstname");
        this.middlename = Helper.getAttribute(n,"middlename");
        this.lastname = Helper.getAttribute(n,"lastname");
        this.dateofbirth = Helper.getAttribute(n,"dateofbirth");
        this.gender = Helper.getAttribute(n,"gender");
        this.language = Helper.getAttribute(n,"language");
        this.comment1 = Helper.getAttribute(n,"comment1");
        this.comment2 = Helper.getAttribute(n,"comment2");
        this.comment3 = Helper.getAttribute(n,"comment3");
        this.comment4 = Helper.getAttribute(n,"comment4");
        this.comment5 = Helper.getAttribute(n,"comment5");

        if (n.hasChildNodes()) {
            ID id;
            Work work;
            Private myPrivate;
            Medical medical;

            for (Node child = n.getFirstChild(); child != null; child = child.getNextSibling()) {
                if (child.getNodeName().toLowerCase().equals("id")) {
                    id = new ID();
                    id.parse(child);
                    this.ids.add(id);
                }
                else if (child.getNodeName().toLowerCase().equals("work")) {
                    work = new Work();
                    work.parse(child);
                    this.works.add(work);
                }
                else if (child.getNodeName().toLowerCase().equals("private")) {
                    myPrivate = new Private();
                    myPrivate.parse(child);
                    this.privates.add(myPrivate);
                }
                else if (child.getNodeName().toLowerCase().equals("medical")) {
                    medical = new Medical();
                    medical.parse(child);
                    this.medicals.add(medical);
                }
            }
        }
    }

     public String toXML(int iIndent) {
        String sReturn = Helper.beginTag(this.getClass().getName(),iIndent)
            +Helper.writeTagAttribute("Begin",this.begin)
            +Helper.writeTagAttribute("End",this.end)
            +Helper.writeTagAttribute("Firstname",this.firstname)
            +Helper.writeTagAttribute("Middlename",this.middlename)
            +Helper.writeTagAttribute("Lastname",this.lastname)
            +Helper.writeTagAttribute("Dateofbirth",this.dateofbirth)
            +Helper.writeTagAttribute("Gender",this.gender)
            +Helper.writeTagAttribute("Language",this.language)
            +Helper.writeTagAttribute("Comment1",this.comment1)
            +Helper.writeTagAttribute("Comment2",this.comment2)
            +Helper.writeTagAttribute("Comment3",this.comment3)
            +Helper.writeTagAttribute("Comment4",this.comment4)
            +Helper.writeTagAttribute("Comment5",this.comment5)
            +">\r\n";
        for (int i=0; i<ids.size();i++) {
            sReturn += ((ID)(ids.elementAt(i))).toXML(iIndent+1);
        }
        for (int i=0; i<works.size();i++) {
           sReturn += ((Work)(works.elementAt(i))).toXML(iIndent+1);
        }
        for (int i=0; i<privates.size();i++) {
           sReturn += ((Private)(privates.elementAt(i))).toXML(iIndent+1);
        }
        for (int i=0; i<medicals.size();i++) {
           sReturn += ((Medical)(medicals.elementAt(i))).toXML(iIndent+1);
        }

        return sReturn+Helper.endTag(this.getClass().getName(),iIndent);
    }
}
