package be.openclinic.system;

import java.util.Hashtable;

import be.mxs.common.util.system.ScreenHelper;

public class ScreenTransactionItem extends TransactionItem {
    private String cellId; // common attributes are hard-coded
    private String htmlElement;
    private Hashtable attributes; // to store htmlElement-specific attributes, rather than hard-coding them
    
    
    //--- constructor ---
    public ScreenTransactionItem(){
    	super();
    	attributes = new Hashtable();
    }

    //--- cellId ----------------------------------------------------------------------------------
    public void setCellId(String sCellId){
        this.cellId = sCellId;
    }
    
    public String getCellId(){
        return this.cellId;
    }
    
    //--- htmlElement -----------------------------------------------------------------------------
    public void setHtmlElement(String sHtmlElement){
        this.htmlElement = sHtmlElement;
    }
    
    public String getHtmlElement(){
        return this.htmlElement;
    }
    
    //--- attribute -------------------------------------------------------------------------------
    public String getAttribute(String sAttrName){
    	return getAttribute(sAttrName,"");
    }
    
    public String getAttribute(String sAttrName, String sDefaultValue){
    	String sValue = ScreenHelper.checkString((String)attributes.get(sAttrName));
    	if(sValue.length()==0){
    		sValue = sDefaultValue;
    	}
    	
    	return sValue;
    }
        
    public void addAttribute(String sAttrName, String sAttrValue){
    	this.attributes.put(sAttrName,sAttrValue);
    }
    
    public Hashtable getAttributes(){
    	return this.attributes;
    }
    
    public void addAttributes(Hashtable attributes){
    	this.attributes.putAll(attributes);
    }
    
}
