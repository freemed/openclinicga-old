package be.mxs.common.util.io.messync;

import org.w3c.dom.Node;

/**
 * Created by IntelliJ IDEA.
 * User: MXS
 * Date: 21-mrt-2005
 * Time: 16:22:47
 * To change this template use Options | File Templates.
 */
public class Label {
    private String language, labelValue;

    public Label(String language, String labelValue) {
        this.language = language;
        this.labelValue = labelValue;
    }

    public Label(){
        this.language = "";
        this.labelValue = "";
    }

    public String getLanguage() {
        return language;
    }

    public void setLanguage(String language) {
        this.language = language;
    }

    public String getLabelValue() {
        return labelValue;
    }

    public void setLabelValue(String labelValue) {
        this.labelValue = labelValue;
    }

    public void parse (Node n) {
        this.language = Helper.getAttribute(n,"language");
        this.labelValue = Helper.getValue(n);
    }

    public String toXML(int iIndent) {
        return Helper.beginTag(this.getClass().getName(),iIndent)
            +Helper.writeTagAttribute("Language",this.language)
            +">"+this.labelValue+Helper.endTag(this.getClass().getName(),iIndent);
    }
}
