package be.mxs.common.util.io.table;

import org.dom4j.Element;

public class SyncColumn {
    private String sColumnName;
    private String sColumnType;
    private String sColumnId;

    public String getName() {
        return sColumnName;
    }

    public void setName(String sColumnName) {
        this.sColumnName = sColumnName;
    }

    public String getType() {
        return sColumnType;
    }

    public void setType(String sColumnType) {
        this.sColumnType = sColumnType;
    }

    public String getId() {
        return sColumnId;
    }

    public void setId(String sColumnId) {
        this.sColumnId = sColumnId;
    }


    public SyncColumn(){
        this.sColumnName = "";
        this.sColumnType = "";
        this.sColumnId = "";
    }

    public void parse (Element column) {
        /*this.sColumnName = Helper.getAttribute(n,"name");
        this.sColumnType = Helper.getAttribute(n,"type");
        this.sColumnId = Helper.getAttribute(n,"id");
        this.sColumnSize = Helper.getAttribute(n,"size");*/
        if (column!=null){
            this.sColumnName = column.attributeValue("name");
            this.sColumnType = column.attributeValue("type");
            this.sColumnId = column.attributeValue("id");
        }
    }

/*    public String toXML(int iIndent){
        return Helper.beginTag("Column",iIndent)
            +Helper.writeTagAttribute("name",this.sColumnName)
            +Helper.writeTagAttribute("type",this.sColumnType)
            +Helper.writeTagAttribute("id",this.sColumnId)
            +"/>\r\n";
    }*/
    public void toXML(Element parent){
        parent.addElement("Column")
            .addAttribute("name", this.sColumnName)
            .addAttribute("type", this.sColumnType)
            .addAttribute("id", this.sColumnId);
    }
}
