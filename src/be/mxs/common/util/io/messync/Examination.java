package be.mxs.common.util.io.messync;

import org.w3c.dom.Node;
import java.util.Vector;


/**
 * Created by IntelliJ IDEA.
 * User: MXS
 * Date: 21-mrt-2005
 * Time: 16:24:18
 * To change this template use Options | File Templates.
 */
public class Examination {
    private String date;
    private Vector ids, labels;

    public String getDate() {
        return date;
    }

    public void setDate(String date) {
        this.date = date;
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

    public Examination() {
        this.date = "";
        this.ids = new Vector();
        this.labels = new Vector();
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
        this.date = Helper.getAttribute(n,"date");

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
            +Helper.writeTagAttribute("Date",this.date)+">\r\n";
        for (int i=0; i<labels.size();i++) {
          sReturn += ((Label)(labels.elementAt(i))).toXML(iIndent+1);
        }
        return sReturn+Helper.endTag(this.getClass().getName(),iIndent);
    }
}
