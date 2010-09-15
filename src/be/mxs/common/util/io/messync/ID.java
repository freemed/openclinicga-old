package be.mxs.common.util.io.messync;

import org.w3c.dom.Node;

/**
 * Created by IntelliJ IDEA.
 * User: MXS
 * Date: 21-mrt-2005
 * Time: 16:22:40
 * To change this template use Options | File Templates.
 */
public class ID {
    private String type, alternatetype, idValue;

    public ID() {
        this.type = "";
        this.alternatetype = "";
        this.idValue = "";
    }

    public String getType() {
        return type;
    }

    public void setType(String type) {
        this.type = type;
    }

    public String getAlternatetype() {
        return alternatetype;
    }

    public void setAlternatetype(String alternatetype) {
        this.alternatetype = alternatetype;
    }

    public String getIdValue() {
        return idValue;
    }

    public void setIdValue(String idValue) {
        this.idValue = idValue;
    }

    public void parse (Node n) {
        this.type = Helper.getAttribute(n,"type");
        this.alternatetype = Helper.getAttribute(n,"alternatetype");
        this.idValue = Helper.getValue(n);
    }

    public String toXML(int iIndent) {
        return Helper.beginTag(this.getClass().getName(),iIndent)
            +Helper.writeTagAttribute("Type",this.type)
            +Helper.writeTagAttribute("AlternateType",this.alternatetype)
            +">"+this.idValue+Helper.endTag(this.getClass().getName(),iIndent);
    }
}
