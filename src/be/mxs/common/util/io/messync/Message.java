package be.mxs.common.util.io.messync;

import org.w3c.dom.Node;

import java.util.Vector;

/**
 * Created by IntelliJ IDEA.
 * User: MXS
 * Date: 21-mrt-2005
 * Time: 16:24:28
 * To change this template use Options | File Templates.
 */
public class Message {
    private String type;
    private Vector persons;

    public Message() {
        this.type = "";
        this.persons = new Vector();
    }

    public String getType() {
        return type;
    }

    public void setType(String type) {
        this.type = type;
    }

    public Vector getPersons() {
        return persons;
    }

    public void setPersons(Vector persons) {
        this.persons = persons;
    }

    public void addPerson(Person person){
        if (person!=null){
            if (this.persons == null){
                this.persons = new Vector();
            }
            this.persons.add(person);
        }
    }

    public void parse (Node n) {
        this.type = Helper.getAttribute(n,"type");

        if (n.hasChildNodes()) {
            Person person;
            for (Node child = n.getFirstChild(); child != null; child = child.getNextSibling()) {
                if (child.getNodeName().toLowerCase().equals("person")) {
                    person = new Person();
                    person.parse(child);
                    this.persons.add(person);
                }
            }
        }
    }

    public String toXML() {
        String sReturn = Helper.beginTag(this.getClass().getName(),0)
            +Helper.writeTagAttribute("Type",this.type)
            +">\r\n";
        for (int i=0; i<persons.size();i++) {
          sReturn += ((Person)(persons.elementAt(i))).toXML(1);
        }
        return sReturn+Helper.endTag(this.getClass().getName(),0);
    }
}
