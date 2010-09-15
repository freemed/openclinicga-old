package be.mxs.common.model.vo.healthrecord;

import be.mxs.common.model.vo.IIdentifiable;
import org.dom4j.Element;

import java.io.Serializable;
import java.text.SimpleDateFormat;
import java.util.Date;

public class ItemVO implements Serializable, IIdentifiable {
    private Integer itemId;
    private String type="";
    private String value="";
    private Date date;
    private ItemContextVO itemContext;
    private int priority;
    private Date inactiveDate;
    private int serverid;

    public ItemVO(Integer itemId, String type, String value, Date date, ItemContextVO itemContextVO) {
        this.itemId = itemId;
        this.type = type;
        this.value = value;
        this.date = date;
        this.itemContext = itemContextVO;
    }

    public ItemVO(Integer itemId, String type, String value, Date date, ItemContextVO itemContextVO,int priority) {
        this.itemId = itemId;
        this.type = type;
        this.value = value;
        this.date = date;
        this.itemContext = itemContextVO;
        this.priority=priority;
    }

    public int getServerId(){
        return serverid;
    }

    public void setServerId(int serverid){
        this.serverid=serverid;
    }

    public Date getInactiveDate() {
        return inactiveDate;
    }

    public Integer getItemId() {
        return itemId;
    }

    public int getPriority() {
        return priority;
    }

    public String getType() {
        return type;
    }

    public String getValue() {
        return (value==null?value:value.trim().replaceAll("\"","´"));
    }

    public Date getDate() {
        return date;
    }

    public ItemContextVO getItemContext() {
        return itemContext;
    }

    public void setItemId(Integer itemId) {
        this.itemId = itemId;
    }

    public void setType(String type) {
        this.type = type;
    }
    public void setPriority(int priority) {
        this.priority = priority;
    }

    public void setValue(String value) {
        this.value = value;
    }

    public void setInactiveDate (Date inactiveDate){
        this.inactiveDate=inactiveDate;
    }

    public void setDate(Date date) {
        this.date = date;
    }

    public void setItemContext(ItemContextVO itemContext) {
        this.itemContext = itemContext;
    }

    public int hashCode() {
        return itemId.hashCode();
    }

    public void createXML(Element element){
        Element item = element.addElement("Item");
        item.addElement("ItemId").addText(itemId+"");
        item.addElement("ItemType").addText(type);
        item.addElement("ItemValue").addText(value);
        item.addElement("ItemDate").addText(new SimpleDateFormat("dd/MM/yyyy hh:mm:ss").format(date));
    }

    public String toXML(){
        StringBuffer sXML=new StringBuffer();
        sXML.append("<Item>");
        sXML.append("<ItemId>").append(itemId).append("</ItemId>");
        sXML.append("<ItemType>").append(type).append("</ItemType>");
        sXML.append("<ItemValue>").append(value).append("</ItemValue>");
        sXML.append("<ItemDate>").append(new SimpleDateFormat("dd/MM/yyyy hh:mm:ss").format(date)).append("</ItemDate>");
        sXML.append("</Item>");
        return sXML.toString();
    }
}
