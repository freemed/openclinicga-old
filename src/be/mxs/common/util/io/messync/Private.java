package be.mxs.common.util.io.messync;

import org.w3c.dom.Node;

import java.util.Vector;

/**
 * Created by IntelliJ IDEA.
 * User: MXS
 * Date: 21-mrt-2005
 * Time: 16:23:45
 * To change this template use Options | File Templates.
 */
public class Private {
    private Vector privateUnits;

    public Private() {
        this.privateUnits = new Vector();
    }

    public Vector getPrivateUnits() {
        return privateUnits;
    }

    public void setPrivateUnits(Vector privateUnits) {
        this.privateUnits = privateUnits;
    }

    public void addPrivateUnit(PrivateUnit privateUnit){
        if (privateUnit!=null){
            if (this.privateUnits == null){
                this.privateUnits = new Vector();
            }
            this.privateUnits.add(privateUnit);
        }
    }

    public void parse (Node n) {

        if (n.hasChildNodes()) {
            PrivateUnit privateUnit;

            for (Node child = n.getFirstChild(); child != null; child = child.getNextSibling()) {
                if (child.getNodeName().toLowerCase().equals("id")) {
                    privateUnit = new PrivateUnit();
                    privateUnit.parse(child);
                    this.privateUnits.add(privateUnit);
                }
            }
        }
    }

    public String toXML(int iIndent) {
        String sReturn = Helper.beginTag(this.getClass().getName(),iIndent)+">\r\n";
        for (int i=0; i<privateUnits.size();i++) {
          sReturn += ((PrivateUnit)(privateUnits.elementAt(i))).toXML(iIndent+1);
        }
        return sReturn+Helper.endTag(this.getClass().getName(),iIndent);
    }
}
