package be.mxs.common.util.system;

import org.dom4j.Element;

public class ProjectParam {
    private String type;
    private String path;

    public String getType() {
        return type;
    }

    public void setType(String type) {
        this.type = type;
    }

    public String getPath() {
        return path;
    }

    public void setPath(String path) {
        this.path = path;
    }

    public ProjectParam(){
        this.type = "";
        this.path = "";
    }

    public ProjectParam(String type,String path){
        this.type = type;
        this.path = path;
    }

    public void parse(Element eParam){
        this.type = ScreenHelper.checkString(eParam.attributeValue("type"));
        this.path = ScreenHelper.checkString(eParam.getStringValue());
    }

    public void toXML(Element parent){
        parent.addElement("param").addAttribute("type",this.getType()).setText(this.getPath());
    }
}
