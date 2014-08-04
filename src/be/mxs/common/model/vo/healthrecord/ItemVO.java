package be.mxs.common.model.vo.healthrecord;

import be.mxs.common.model.vo.IIdentifiable;
import be.mxs.common.util.system.Debug;
import be.mxs.common.util.system.ScreenHelper;

import org.dom4j.Element;

import java.io.Serializable;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.Vector;

public class ItemVO implements Serializable, IIdentifiable, Comparable {
    private Integer itemId;
    private String type = "";
    private String value = "";
    private Date date;
    private ItemContextVO itemContext;
    private int priority;
    private Date inactiveDate;
    private int serverid;

    //--- CONSTRUCTOR -----------------------------------------------------------------------------
    public ItemVO(Integer itemId, String type, String value, Date date, ItemContextVO itemContextVO){
        this.itemId = itemId;
        this.type = type;
        this.value = value;
        this.date = date;
        this.itemContext = itemContextVO;
    }

    //--- CONSTRUCTOR -----------------------------------------------------------------------------
    public ItemVO(Integer itemId, String type, String value, Date date, ItemContextVO itemContextVO, int priority){
        this.itemId = itemId;
        this.type = type;
        this.value = value;
        this.date = date;
        this.itemContext = itemContextVO;
        this.priority = priority;
    }

    public int getServerId(){
        return serverid;
    }

    public void setServerId(int serverid){
        this.serverid = serverid;
    }

    public Date getInactiveDate(){
        return inactiveDate;
    }

    public Integer getItemId(){
        return itemId;
    }

    public int getPriority(){
        return priority;
    }

    public String getType(){
        return type;
    }

    public String getValue(){
        String sValue = (value==null?value:value.trim().replaceAll("\"","´"));
    	
    	// convert date-value to EU-date for date-items
    	if(isDateItem()){
    		sValue = ScreenHelper.convertDate(sValue);
    	}
    	
    	return sValue;
    }

    public Date getDate(){
        return date;
    }

    public ItemContextVO getItemContext(){
        return itemContext;
    }

    public void setItemId(Integer itemId){
        this.itemId = itemId;
    }

    public void setType(String type){
        this.type = type;
    }
    
    public void setPriority(int priority){
        this.priority = priority;
    }

    public void setValue(String value){
        this.value = value;
    }

    public void setInactiveDate (Date inactiveDate){
        this.inactiveDate = inactiveDate;
    }

    public void setDate(Date date){
        this.date = date;
    }

    public void setItemContext(ItemContextVO itemContext){
        this.itemContext = itemContext;
    }

    public int hashCode(){
        return itemId.hashCode();
    }

    //--- EQUALS ----------------------------------------------------------------------------------
     public boolean equals(Object o){
        if(this==o) return true;
        if(!(o instanceof ItemVO)) return false;

        ItemVO otherItem = (ItemVO)o;

        return (itemId==otherItem.itemId && type.equals(otherItem.type) && value.equals(otherItem.value));
    }

    //--- COMPARE TO ------------------------------------------------------------------------------
    // to sort on type (not the translation for it, just the English name)
    public int compareTo(Object o){
        int comparison;

        if(o.getClass().isInstance(this)){
            comparison = this.type.compareTo(((ItemVO)o).type);
        }
        else{
            throw new ClassCastException();
        }

        return comparison;
    }

    //--- CREATE XML ------------------------------------------------------------------------------
    public void createXML(Element element){
        Element item = element.addElement("Item");
        
        item.addElement("ItemId").addText(itemId+"");
        item.addElement("ItemType").addText(type);
        item.addElement("ItemValue").addText(value);
        item.addElement("ItemDate").addText(ScreenHelper.fullDateFormatSS.format(date));
    }

    //--- TO XML ----------------------------------------------------------------------------------
    public String toXML(){
        StringBuffer sXML = new StringBuffer();
        sXML.append("<Item>");
         sXML.append("<ItemId>").append(itemId).append("</ItemId>");
         sXML.append("<ItemType>").append(type).append("</ItemType>");
         sXML.append("<ItemValue>").append(value).append("</ItemValue>");
         sXML.append("<ItemDate>").append(ScreenHelper.fullDateFormatSS.format(date)).append("</ItemDate>");
        sXML.append("</Item>");
        
        return sXML.toString();
    }
    
    //--- IS DATE ITEM ----------------------------------------------------------------------------
    // recognises dates based on the type ot the item
    public boolean isDateItem(){
    	boolean isDateItem = false;
    	
    	/*
    	// strict listing
    	if(this.getType().equalsIgnoreCase(ScreenHelper.ITEM_PREFIX+"ITEM_TYPE_ALERTS_EXPIRATION_DATE")){
    	  	isDateItem = true; // todo
    	}
    	*/
    	
    	// any item of which the type contains "date"
    	if(this.getType().toUpperCase().indexOf("DATE") > -1){
    		isDateItem = true;
    	}
    	
    	return isDateItem;
    }
    
}
