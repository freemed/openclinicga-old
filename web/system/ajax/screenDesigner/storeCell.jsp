<%@page import="be.openclinic.system.ScreenTransactionItem"%>
<%@page import="be.mxs.common.util.system.HTMLEntities"%>
<%@page import="be.openclinic.system.Screen"%>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>

<%!
    //--- PARSE PRINT-LABELS ----------------------------------------------------------------------
    private void parsePrintlabels(Hashtable itemAttributes, String sPrintlabels){
	    String sPrintlabel, sLanguage, sLabel;
	
	    while(sPrintlabels.length() > 0 && !sPrintlabels.equals("§")){
	    	if(sPrintlabels.endsWith("§")){
	    	    sPrintlabel = sPrintlabels.substring(0,sPrintlabels.indexOf("§"));
	    	}
	    	else{
	    		sPrintlabel = sPrintlabels;
	    	}

	    	// required : language
	    	sLanguage = sPrintlabel.split("_")[0];

	    	// required : label
	    	sLabel = sPrintlabel.split("_")[1];
	    	sLabel = sLabel.substring(0,sLabel.length()-1); // trim-off hyphen
	    	
	        itemAttributes.put("Attr_printlabel_"+sLanguage,sLabel);
	    	
	        sPrintlabels = sPrintlabels.substring(sPrintlabels.indexOf("§")+1);
	    }   
    }
%>

<%	
    Screen screen = (Screen)session.getAttribute("screen");

	String sCellId     = checkString(request.getParameter("CellId")),
		   sWidth      = checkString(request.getParameter("Width")),
		   sColspan    = checkString(request.getParameter("Colspan")),
		   sItems      = checkString(request.getParameter("Items")),
		   sClass      = checkString(request.getParameter("Class")),
	       sTranTypeId = checkString(request.getParameter("TranTypeId"));
	
    /// DEBUG /////////////////////////////////////////////////////////////////////////////////////
    if(Debug.enabled){
        Debug.println("\n############### system/ajax/screenDesigner/storeCell.jsp ###############");
        Debug.println("sCellId     : "+sCellId);
        Debug.println("sWidth      : "+sWidth);
        Debug.println("sColspan    : "+sColspan);
        Debug.println("sItems      : "+sItems);
        Debug.println("sClass      : "+sClass);
        Debug.println("sTranTypeId : "+sTranTypeId+"\n"); // common for all items
    }
    ///////////////////////////////////////////////////////////////////////////////////////////////

    //*** 1 - data on cell-level **************************
    Hashtable cell = screen.getCell(sCellId);
        		
    if(sWidth.length() > 0) cell.put("Attr_width",sWidth);
    else cell.remove("Attr_width");
    
    if(sColspan.length() > 0) cell.put("Attr_colspan",sColspan);
    else cell.remove("Attr_colspan");
    
    if(sClass.length() > 0) cell.put("Attr_class",sClass);
    else cell.remove("Attr_class");
    
    //*** 2 - data on items-level *************************
    cell.remove("Items");
    
    if(sItems.length() > 0){
	    Vector items = new Vector();
	    ScreenTransactionItem item;
	    String sItem, sItemTypeId, sHtmlElement, sSize = "", sDefaultValue = "", sAttrValue;
	    Hashtable itemAttributes = new Hashtable();
	    int itemIdx = 0;
	    
	    while(sItems.length() > 0 && !sItems.equals("$")){
	    	if(sItems.endsWith("$")){
	    	    sItem = sItems.substring(0,sItems.indexOf("$"));
	    	}
	    	else{
	    		sItem = sItems;
	    	}
	    	
	    	// required : itemTypeId
	    	sItemTypeId = sItem.split("£")[0];
	    	sItemTypeId = sItemTypeId.substring(0,sItemTypeId.length()-1); // trim-off pound
	    	
	    	// required : htmlEmlement
	    	sHtmlElement = sItem.split("£")[1];
	    	sHtmlElement = sHtmlElement.substring(0,sHtmlElement.length()-1); // trim-off pound

	    	// optional : size
	    	if(sItem.split("£").length > 2){
	    	    sAttrValue = sItem.split("£")[2];
	    	    sAttrValue = sAttrValue.substring(0,sAttrValue.length()-1);
	    	    
	    	    if(sAttrValue.length() > 0){
	    	        itemAttributes.put("Attr_size",sAttrValue);
	    	    }
	    	}
	    	
	    	// optional : defaultValue
	    	if(sItem.split("£").length > 3){
	    	    sDefaultValue = sItem.split("£")[3];
	    	    sDefaultValue = sDefaultValue.substring(0,sDefaultValue.length()-1);
	    	}
	    	
	    	// optional : required
	    	if(sItem.split("£").length > 4){
	    	    sAttrValue = sItem.split("£")[4];
	    	    sAttrValue = sAttrValue.substring(0,sAttrValue.length()-1);
	    	    itemAttributes.put("Attr_required",sAttrValue);
	    	}

	    	// optional : followedBy
	    	if(sItem.split("£").length > 5){
	    		sAttrValue = sItem.split("£")[5];
	    	    sAttrValue = sAttrValue.substring(0,sAttrValue.length()-1);
	    		
	    	    if(sAttrValue.length() > 0){
	    	        itemAttributes.put("Attr_followedBy",sAttrValue);
	    	    }
	    	}

	    	// optional : printLabels
	    	if(sItem.split("£").length > 6){
	    		String sPrintlabels = sItem.split("£")[6];
	    		
	    	    if(sPrintlabels.length() > 0){
	    	        parsePrintlabels(itemAttributes,sPrintlabels);
	    	    }
	    	}
	    	
	        screen.putItemInCell(sTranTypeId,sItemTypeId,sCellId,sDefaultValue,sHtmlElement,itemAttributes);
	        
	    	sItems = sItems.substring(sItems.indexOf("$")+1);
	    	itemIdx++;
	    }
    }
    	
    // store
    screen.store(sWebLanguage,session);	
    session.setAttribute("screen",screen);
%>

{
  "msg":"<%=HTMLEntities.htmlentities(getTranNoLink("web","dataSaved",sWebLanguage))%>"
}