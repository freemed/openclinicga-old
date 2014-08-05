<%@page import="java.io.FileNotFoundException"%>
<%@page import="be.mxs.common.model.vo.healthrecord.TransactionVO,
                be.mxs.common.model.vo.healthrecord.ItemContextVO"%>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>
<%=sJSSORTTABLE%>

<%!    
    private static Hashtable itemCombinations = null;

    /// INNER CLASS : ItemAndLabel ////////////////////////////////////////////////////////////////
    private class ItemAndLabel implements Comparable {
        public ItemVO item;
        public String label;
        public String addFunction;
        public int order = 9999; // undefined order
        
        public ItemAndLabel(ItemVO item, String sLabel, String sOrder){
            this.item = item;
            this.label = sLabel;    
            this.addFunction = "";      
            
            if(sOrder.length() > 0){
                this.order = Integer.parseInt(sOrder);
                if(this.order==0) this.order = 9999; // last position
            }      
        }

        //--- SET ADD FUNCTION ------------------------------------------------
        public void setAddFunction(String sAddFunction){
        	this.addFunction = sAddFunction;
        }
        //--- GET ADD FUNCTION ------------------------------------------------
        public String getAddFunction(){
        	return this.addFunction;
        }
        
        //--- EQUALS ----------------------------------------------------------
        public boolean equals(Object o){
            if(this==o) return true;
            if(!(o instanceof ItemAndLabel)) return false;
    
            final ItemAndLabel itemAndLabel = (ItemAndLabel)o;
    
            if(!item.getType().equals(itemAndLabel.item.getType()) && !label.equals(itemAndLabel.label)) return false;
    
            return true;
        }
    
        //--- COMPARE TO (order) ----------------------------------------------
        public int compareTo(Object o){
            int comp;
    
            if(o.getClass().isInstance(this)){
                comp = this.order - ((ItemAndLabel)o).order; // different sorting
            }
            else{
                throw new ClassCastException();
            }
    
            return comp;
        }
    
    }

    //--- GET USER SELECTED ITEMS -----------------------------------------------------------------
    public Vector getUserSelectedItems(int userId){
        return getUserSelectedItems(userId,""); // load items for any type of transaction       
    }
    
    public Vector getUserSelectedItems(int userId, String sTranType){
        Vector userSelectedItems = new Vector();
    
        String sTranTypeShort = sTranType.substring(sTranType.indexOf(ScreenHelper.ITEM_PREFIX)+ScreenHelper.ITEM_PREFIX.length());
        ItemContextVO itemContextVO = new ItemContextVO(new Integer(IdentifierFactory.getInstance().getTemporaryNewIdentifier()),"","");
        PreparedStatement ps = null;
        ResultSet rs = null;
    
        try{
            Connection conn = MedwanQuery.getInstance().getAdminConnection();
            String sSql = "SELECT value FROM userparameters"+
                          " WHERE parameter LIKE ?"+
                          "  AND userid = ?"+
                          "  AND active = 1"+
                          " ORDER BY parameter DESC, value DESC";
            ps = conn.prepareStatement(sSql);
            ps.setString(1,"HistoryItem."+sTranTypeShort+"%");
            ps.setInt(2,userId);
            rs = ps.executeQuery();
            
            String sValue, sItemTypeShort, sUserDefLabel, sOrder = "", sAddFunction = "";
            ItemAndLabel itemAndLabel;
            String[] valueParts;
            ItemVO item;
            
            while(rs.next()){
                sValue = checkString(rs.getString("value"));                
                if(sValue.length() > 0){
                    valueParts = sValue.split("\\$"); // sItemTypeShort $ user defined label $ order
                    
                    sItemTypeShort = checkString(valueParts[0]);
                    sUserDefLabel  = checkString(valueParts[1]);
                    
                    // order                    
                    if(valueParts.length > 2) sOrder = checkString(valueParts[2]);
                    else                      sOrder = ""; // keep value from being copied
                    
                    item = new ItemVO(new Integer(IdentifierFactory.getInstance().getTemporaryNewIdentifier()),
		                    		  ScreenHelper.ITEM_PREFIX+sItemTypeShort.toUpperCase(),
		                              "", // default value
		                              new java.util.Date(),
		                              itemContextVO);
                    
                    itemAndLabel = new ItemAndLabel(item,sUserDefLabel,sOrder);   
                   
                    // addFunction
                    if(valueParts.length > 3){
                        sAddFunction = checkString(valueParts[3]);
                        
                        if(sAddFunction.length() > 0){
                        	itemAndLabel.setAddFunction(sAddFunction);
                        }
                    }
                    
                    userSelectedItems.add(itemAndLabel);    
                }                
            }
        }
        catch(Exception e){
            Debug.printStackTrace(e);
        }
        finally{
            try{
                if(rs!=null) rs.close();
                if(ps!=null) ps.close();
            }
            catch(Exception e){
                Debug.printStackTrace(e);
            }
        }
        
        return userSelectedItems;
    }

    //--- GET HISTORY ITEMS FROM XML --------------------------------------------------------------
    // the xml contains all available items (managed by us, directly in xml)
    public Vector getHistoryItemsFromXML(String sTranType, Document itemsDocument, Document combinationsDocument, String sWebLanguage){
        Vector itemsAndLabels = new Vector();

        try{
            Iterator itemElements = itemsDocument.getRootElement().elementIterator("item");

            ItemContextVO itemContextVO = new ItemContextVO(new Integer(IdentifierFactory.getInstance().getTemporaryNewIdentifier()),"","");
            
            // varia declarations
            String sTranTypeShort, sItemTypeShort, sLabelType, sLabelId,
                   sLabel = "", sActif, sOrder = "", sAddFunction = "";
            ItemAndLabel itemAndLabel;
            Element itemElem, labelElem;
            org.dom4j.Node labelNode, addFunctionNode; // dom4j-full.jar
            ItemVO item;
    
            // run over "items" in xml
            while(itemElements.hasNext()){
                itemElem = (Element)itemElements.next();
                
                // only process when not indicated as actif
                sActif = itemElem.attribute("actif").getValue();
                
                if(!sActif.equalsIgnoreCase("false")){
                    // only process when it is the specified trantype
                    sTranTypeShort = itemElem.attribute("tranTypeShort").getValue();
                    
                    if(sTranType.equalsIgnoreCase(ScreenHelper.ITEM_PREFIX+sTranTypeShort)){
                        sItemTypeShort = itemElem.attribute("itemTypeShort").getValue();

                        //*** exclude combined items ***                                               
                        if(isCombinedItem(sItemTypeShort,combinationsDocument,sTranType)){
                        	continue;
                        }
                        
                        sLabel = ""; sLabelType = ""; sLabelId = ""; 

                        // (default) order, if any
                        if(itemElem.attribute("order")!=null){
                            sOrder = itemElem.attribute("order").getValue();
                        }
                        
                        // fetch label info from xml (not obligate)
                        labelNode = itemElem.selectSingleNode("label");
                        
                        if(labelNode!=null){
                            sLabelType = labelNode.valueOf("@type");
                            sLabelId = labelNode.valueOf("@id");
                        
                            sLabel = ScreenHelper.getTranNoId(sLabelType,sLabelId,sWebLanguage);
                        }

                        if(sLabel.length()==0){
                            sLabel = sItemTypeShort;
                        }

                        // create ItemAndLabel object to add to vector
                        item = new ItemVO(new Integer(IdentifierFactory.getInstance().getTemporaryNewIdentifier()),
                        		          ScreenHelper.ITEM_PREFIX+sItemTypeShort.toUpperCase(),
                                          "", // default value
                                          new java.util.Date(),
                                          itemContextVO);        
                                                
                        itemAndLabel = new ItemAndLabel(item,sLabel,sOrder);
                        
                        // addFunction
                        addFunctionNode = itemElem.selectSingleNode("addFunction");                        
                        if(addFunctionNode!=null){
                            sAddFunction = addFunctionNode.valueOf("@value");
                            
                            if(sAddFunction.length() > 0){
                                itemAndLabel.setAddFunction(sAddFunction);
                            }
                        }
                        
                        itemsAndLabels.add(itemAndLabel);
                    }
                }
            }
        }
        catch(Exception e){
            e.printStackTrace();
        }
        
        return itemsAndLabels;
    }
    
    //--- GET ITEMCOMBINATIONS FROM XML -----------------------------------------------------------
    // the xml contains all item-combinations (managed by us, directly in xml)
    /*    
		<item tranTypeShort="CLINICAL_EXAMINATION_DSW" itemTypeShort="BLOODPRESSURE_SYSTOLIC" actif="true">
			<combinedItems>
			    <combinedItem itemTypeShort="BLOODPRESSURE_DIASTOLIC" actif="true"/>
			    <combinedItem itemTypeShort="BLOODPRESSURE_ARM" actif="true"/>
		    </combinedItems>
		</item>	
    */
    public Hashtable getItemCombinationsFromXML(Document document, String sTranType){
    	Hashtable itemCombinations = new Hashtable();

        try{                        
            Iterator itemElements = document.getRootElement().elementIterator("item");

            ItemContextVO itemContextVO = new ItemContextVO(new Integer(IdentifierFactory.getInstance().getTemporaryNewIdentifier()),"","");
            
            // varia declarations
            String sLeadingTranTypeShort, sTranTypeShort, sLeadingItemTypeShort, sActif = "";
            Element itemElem;
            org.dom4j.Node combinedItemsNode, combinedItemNode; // dom4j-full.jar
            ItemVO item;
    
            // run over "items" in xml
            while(itemElements.hasNext()){
                itemElem = (Element)itemElements.next();
                
                // only process when not indicated as actif
                sActif = itemElem.attribute("actif").getValue();
                
                if(!sActif.equalsIgnoreCase("false")){
                    // only process when it is the specified trantype
                    sLeadingTranTypeShort = itemElem.attribute("tranTypeShort").getValue();
                    
                    if(sTranType.equalsIgnoreCase(ScreenHelper.ITEM_PREFIX+sLeadingTranTypeShort)){
                        sLeadingItemTypeShort = itemElem.attribute("itemTypeShort").getValue();                        
                                      
                        Vector combinedItemTypes = (Vector)itemCombinations.get(sLeadingTranTypeShort);
                        if(combinedItemTypes==null) combinedItemTypes = new Vector();

                        // fetch combined items as childs of the leading item in the xml
                        combinedItemsNode = itemElem.selectSingleNode("combinedItems");
                        if(combinedItemsNode!=null){
                            List combinedItemsList = combinedItemsNode.selectNodes("combinedItem");
                            Iterator combinedItemsIter = combinedItemsList.iterator();
                            while(combinedItemsIter.hasNext()){
                                combinedItemNode = (org.dom4j.Node)combinedItemsIter.next();

                                sTranTypeShort = combinedItemNode.valueOf("@itemTypeShort");
                                combinedItemTypes.add(sTranTypeShort);
                            }                            
                        }                        
                        
                        itemCombinations.put(sLeadingItemTypeShort,combinedItemTypes);                                                             
                    }
                }
            }
        }
        catch(Exception e){
            e.printStackTrace();
        }

        return itemCombinations;
    }
    
    //--- GET ITEM COMBINATIONS -------------------------------------------------------------------
    // make caching transparent
    public Hashtable getItemCombinations(Document combinationsDocument, String sTranType){    	
    	//if(itemCombinations==null){
    		itemCombinations = getItemCombinationsFromXML(combinationsDocument,sTranType);
    	//}    	
    	return itemCombinations;
    }
    
    //--- LIST COMBINED ITEMS ---------------------------------------------------------------------
    // for the specified itemType, list the combined items
    public String listCombinedItems(String sLeadingItemType, String sTranType, Document combinationsDocument, String sSeparator){
    	String sCombination = "";
    	
    	Hashtable itemCombinations = getItemCombinations(combinationsDocument,sTranType);
    	Enumeration combinationsEnum = itemCombinations.keys();
    	Element leadingItem, combinedItem;
    	Vector combinedItems;
    	String sTmpLeadingItemType;
    	
    	while(combinationsEnum.hasMoreElements()){
    		sTmpLeadingItemType = (String)combinationsEnum.nextElement(); 				
    		
    		if(sTmpLeadingItemType.equalsIgnoreCase(sLeadingItemType)){
    			combinedItems = (Vector)itemCombinations.get(sTmpLeadingItemType);

    			// add combined item-types to the list
    			for(int i=0; i<combinedItems.size(); i++){
    				sCombination+= "&nbsp;&nbsp;"+(String)combinedItems.get(i)+sSeparator;
    			}
    			
    			break;
    		}
    	}
    	
    	return "<font color='green'><i>"+sCombination+"</i></font>";
    }
    
    //--- IS COMBINED ITEM ------------------------------------------------------------------------
    public boolean isCombinedItem(String sItemTypeShort, Document combinationsDocument, String sTranType){
    	boolean isCombinedItem = false;
    	
    	Hashtable itemCombinations = getItemCombinations(combinationsDocument,sTranType);
    	Enumeration combinationsEnum = itemCombinations.keys();
    	Element leadingItem, combinedItem;
    	Vector combinedItems;
    	String sTmpLeadingItemType, sTmpCombinedItemType;
    	
    	while(combinationsEnum.hasMoreElements()){
    		sTmpLeadingItemType = (String)combinationsEnum.nextElement(); 				
    		
   			combinedItems = (Vector)itemCombinations.get(sTmpLeadingItemType);
   			for(int i=0; i<combinedItems.size(); i++){
   				sTmpCombinedItemType = (String)combinedItems.get(i);
   				if(sTmpCombinedItemType.equalsIgnoreCase(sItemTypeShort)){
   					isCombinedItem = true; // item found as child of some leading item
   					break;
   				}
   			}
    	}
    	
    	return isCombinedItem;
    }
        
    //--- GET ITEM FROM VECTOR --------------------------------------------------------------------
    private ItemAndLabel getItemFromVector(Vector userHistItems, String sItemType){
        ItemAndLabel itemAndLabel;
        
        for(int i=0; i< userHistItems.size(); i++){
            itemAndLabel = (ItemAndLabel)userHistItems.get(i);
            if(itemAndLabel.item.getType().equals(sItemType)){
                return itemAndLabel;
            }
        }
        
        return null;
    }
    
    //--- REMOVE PARAMETERS STARTING WITH ---------------------------------------------------------
    public void removeParametersStartingWith(String sParameterBegin, int userId){
        PreparedStatement ps = null;
    
        try{
            Connection conn = MedwanQuery.getInstance().getAdminConnection();
            String sSql = "DELETE FROM userparameters"+
                          " WHERE parameter LIKE ?"+
                          "  AND userid = ?";
            ps = conn.prepareStatement(sSql);
            ps.setString(1,sParameterBegin+"%");
            ps.setInt(2,userId);
            ps.executeUpdate();
        }
        catch(Exception e){
            Debug.printStackTrace(e);
        }
        finally{
            try{
                if(ps!=null) ps.close();
            }
            catch(Exception e){
                Debug.printStackTrace(e);
            }
        }
    }
    
    /*
    //--- GET ORDER SELECT ------------------------------------------------------------------------
    private String getOrderSelect(String sSelectName, int optionCount, int selectedValue){
    	String sSelect = "<select name='"+sSelectName+"' class='text'>";
    	sSelect+= "<option value=''></option>";  
    	
    	// options
    	String sSelected = "";
    	for(int i=1; i<=optionCount; i++){
    		sSelected = "";
    		if(i==selectedValue) sSelected = "selected";
    		
    		sSelect+= "<option value='"+i+"' "+sSelected+">"+i+"</option>";    		
    	}
    	
    	sSelect+= "</select>";
    	    	
    	return sSelect;
    }
    */
%>

<%
    String sAction = checkString(request.getParameter("Action"));

    String sTranType = checkString(request.getParameter("TranType"));

    /// DEBUG /////////////////////////////////////////////////////////////////
    if(Debug.enabled){
        Debug.println("\n******* userprofile/manageHistoryItems.jsp ********");
        Debug.println("sAction : "+sAction); 
        Debug.println("sTranType : "+sTranType+"\n");
    }
    ///////////////////////////////////////////////////////////////////////////

    // 'delhaize' or 'medwan'
    String sAppName = sAPPDIR.endsWith("/")?sAPPDIR.substring(0,sAPPDIR.length()-1):sAPPDIR;
    sAppName = sAppName.substring(sAppName.indexOf("/")+1);
    
    String sMsg = "";
    int itemCount = 0;

    //*** 1 - read historyItems-xml ***********************
    String sXmlFile = ScreenHelper.getConfigString("templateSource");
    if(sAppName.length() > 0){
    	sXmlFile+= "historyItems_"+sAppName+".xml";
    }
    else{
    	sXmlFile+= "historyItems.xml";
    }
    
    URL xmlUrl = new URL(sXmlFile);
    SAXReader xmlReader = new SAXReader(false);
    Document itemsDocument;
    try{
        Debug.println("Using historyItems-xml-file : '"+sXmlFile+"'");
        itemsDocument = xmlReader.read(xmlUrl);
    }
	catch(Exception e){
		// use default xml
        Debug.println("Using default historyItems-xml-file : 'historyItems.xml' ("+sXmlFile+" not found)");
    	itemsDocument = xmlReader.read(new URL(ScreenHelper.getConfigString("templateSource")+"historyItems.xml"));
    }
    
    //*** 2 - read combinations-xml ***********************
    String sCombinationXmlFile = ScreenHelper.getConfigString("templateSource");
    if(sAppName.length() > 0){
    	sCombinationXmlFile+= "historyItems_combinations_"+sAppName+".xml";
    }
    else{
    	sCombinationXmlFile+= "historyItems_combinations.xml";
    }
    
    URL combinationsUrl = new URL(sCombinationXmlFile);
    xmlReader = new SAXReader(false);    
    Document combinationsDocument;
    try{
        combinationsDocument = xmlReader.read(combinationsUrl);
        Debug.println("Using combinations-xml-file : '"+sCombinationXmlFile+"'");
    }
	catch(Exception e){
		// use default xml
        Debug.println("Using default combinations-xml-file : 'historyItems_combinations.xml' ("+sCombinationXmlFile+" not found)");
		combinationsDocument = xmlReader.read(new URL(ScreenHelper.getConfigString("templateSource")+"historyItems_combinations.xml"));
	}  
    
    //--- SAVE ITEMS ------------------------------------------------------------------------------
    if(sAction.equals("saveItems")){  
        String sParamName, sParamValue, sTranTypeShort, sItemType, sItemTypeShort = "", 
        	   sItemLabel, sOrder, sAddFunction;
        boolean updateNeeded = false;
        int cbCount = 0;
        
        // first remove all items concerning the specified transaction
        sTranTypeShort = sTranType.substring(sTranType.indexOf(ScreenHelper.ITEM_PREFIX)+ScreenHelper.ITEM_PREFIX.length());
        removeParametersStartingWith("HistoryItem."+sTranTypeShort,Integer.parseInt(activeUser.userid));
        
        // run over parameters and save checked items to the userparameters-table
        String sConcatCheckboxes = checkString(request.getParameter("ConcatCheckboxes"));
        if(sConcatCheckboxes.length() > 0){
        	String[] checkboxes = sConcatCheckboxes.split(";"); 
        			
        	for(int i=0; i<checkboxes.length; i++){
        		sParamName = checkboxes[i];

	            if(sParamName.startsWith("cb_")){
                    cbCount = Integer.parseInt(sParamName.substring(sParamName.indexOf("_")+1));
                    
                    sItemLabel = checkString(request.getParameter("UserDefinedLabel_"+cbCount));
                    sItemType = checkString(request.getParameter("ItemType_"+cbCount));

                    sOrder = checkString(request.getParameter("Order_"+cbCount));
                    sAddFunction = checkString(request.getParameter("AddFunction_"+cbCount));
                    
                    updateNeeded = true;
                                        
                    // sItemTypeShort $ user defined label
                    sItemTypeShort = sItemType.substring(sItemType.indexOf(ScreenHelper.ITEM_PREFIX)+ScreenHelper.ITEM_PREFIX.length()); 
                    
                    // save userparameter
                    Parameter parameter = new Parameter("HistoryItem."+sTranTypeShort,
                    		                            sItemTypeShort+"$"+sItemLabel+"$"+sOrder+"$"+sAddFunction,
                    		                            activeUser.userid);
                    activeUser.updateParameter(parameter);
                }
            }
        }
        
        if(updateNeeded){
            // update parameters in user object
            session.setAttribute("activeUser",activeUser);
        }
        
        sMsg = "<font color='green'>"+getTran("web","dataIsSaved",sWebLanguage)+"</font>";
        sAction = "displayItems";
    }
%>

<form id="transactionForm" name="transactionForm" method="post">
    <input type="hidden" name="Action">
    <input type="hidden" name="ConcatCheckboxes" value="">

    <%-- TITLE --%>
    <%=writeTableHeader("web.userProfile","manageHistoryItems",sWebLanguage," doBack();")%>

    <%-- TRAN TYPE SELECT --%>
    <table width="100%" cellspacing="1" cellpadding="0" class="list">
        <tr height="20">
            <td class="admin" width="<%=sTDAdminWidth%>"><%=getTran("web","examinationType",sWebLanguage)%></td>
            <td class="admin2">
                <select name="TranType" class="text" onChange="displayHistItems();">
                    <option value=""><%=getTranNoLink("web","choose",sWebLanguage)%></option>
                    <%
                        String sTmpTranType, sSelected, sTranLabel;
                        String sLangCol = sWebLanguage.equalsIgnoreCase("N")?"NL":"FR";
                        
                        Hashtable tranTypesAndLabels = new Hashtable();
                        PreparedStatement ps = null;
                        ResultSet rs = null;

                        try{
                            String sSql = "SELECT transactiontype, "+sLangCol+
                                          " FROM Examinations"+
                                          "  WHERE deleteDate IS NULL";
                            ps = MedwanQuery.getInstance().getOpenclinicConnection().prepareStatement(sSql);
                            rs = ps.executeQuery();
    
                            while(rs.next()){
                                sTmpTranType = checkString(rs.getString("transactionType"));

                                if(sTmpTranType.indexOf("&") > -1){
                                    sTmpTranType = sTmpTranType.substring(0,sTmpTranType.indexOf("&"));
                                    sTranLabel = getTranNoLink("web.occup",sTmpTranType,sWebLanguage);
                                }
                                else{
                                    // label from examinations-table
                                    sTranLabel = getTranNoLink("web.occup",sTmpTranType,sWebLanguage);
                                }

                                tranTypesAndLabels.put(sTranLabel,sTmpTranType); // value, key !
                            }
                        }   
                        catch(Exception e){
                            e.printStackTrace();
                        }
                        finally {
                            if(rs!=null) rs.close();
                            if(ps!=null) ps.close();   
                        }
                        
                        Vector tranLabels = new Vector(tranTypesAndLabels.keySet()); 
                        Collections.sort(tranLabels);
                        
                        Vector xmlHistItems;
                        for(int i=0; i<tranLabels.size(); i++){
                            sTranLabel = (String)tranLabels.get(i); 
                            sTmpTranType = (String)tranTypesAndLabels.get(sTranLabel);

                            xmlHistItems = getHistoryItemsFromXML(sTmpTranType,itemsDocument,combinationsDocument,sWebLanguage);
                            
                            // only display transaction-option when some of its fields are indicated as history-item
                            if(xmlHistItems.size() > 0){                                
                                // selected ?
                                sSelected = "";
                                if(sTmpTranType.equals(sTranType)){
                                    sSelected = " selected";
                                }

                                %><option value="<%=sTmpTranType%>" <%=sSelected%>><%=sTranLabel%> (<%=xmlHistItems.size()%>)</option><%
                            }
                        }
                    %>
                </select>                
            </td>
        </tr>
    </table>

    <%    
        // action message
        if(sMsg.length() > 0){
            %><%=sMsg%><br><%
        }
    
        //--- DISPLAY ITEMS -----------------------------------------------------------------------
        if(sAction.equals("displayItems")){                
            xmlHistItems = getHistoryItemsFromXML(sTranType,itemsDocument,combinationsDocument,sWebLanguage);
            Collections.sort(xmlHistItems);
    
            if(xmlHistItems.size() > 0){
                // check a checkbox for each histItem the user HAS selected              
                Vector userHistItems = getUserSelectedItems(Integer.parseInt(activeUser.userid),sTranType);
                        
                // header
                %>
                    <%=userHistItems.size()%>/<%=xmlHistItems.size()%> <%=getTran("web","itemsSelected",sWebLanguage)%><br><br>
                    
                    <table class="sortable" id="tblHistItems" width="100%" cellspacing="1" cellpadding="0" style="border:1px solid #ccc;">
                        <%-- HEADER --%>
                        <tr>
                            <td class="admin" width="14"></td>
                            <td class="admin" width="300"><%=getTran("web","itemType",sWebLanguage)%></td>
                            <td class="admin" width="125"><%=getTran("web","defaultOrder",sWebLanguage)%></td>
                            <td class="admin" width="125"><%=getTran("web","savedOrder",sWebLanguage)%></td>
                            <td class="admin" width="125">
                                <NOSORT>
                                    <%=getTran("web","newOrder",sWebLanguage)%><br>
                                    <img src="<c:url value='/_img/icon_delete.gif'/>" class="link" alt="<%=getTranNoLink("web","clear",sWebLanguage)%>" onClick="clearOrder();">
                                    <img src="<c:url value='/_img/icon_default.gif'/>" class="link" alt="<%=getTranNoLink("web","setDefaultValues",sWebLanguage)%>" onClick="setDefaultOrder();">
                                </NOSORT>
                            </td>
                            <td class="admin" width="200"><%=getTran("web","label",sWebLanguage)%></td>
                        </tr>
                <%
                
                // display a checkbox for each histItem the user CAN select
                String sItemType = "", sItemValue = "", sItemLabel = "", sClass = "", sChecked = "", sImg = "";
                ItemAndLabel xmlItem, userItem;
                int tabIndex = 1, defaultOrder;
                ItemVO item;
                
                for(int i=0; i< xmlHistItems.size(); i++){
                    xmlItem = (ItemAndLabel)xmlHistItems.get(i);
                    
                    item = xmlItem.item;
                    sItemType = item.getType();
                    defaultOrder = xmlItem.order;  
                    itemCount++;
                   
                    // checked ? + label
                    userItem = getItemFromVector(userHistItems,sItemType);
                    sChecked = "";
                    int order = 0, savedOrder = 0;
                    sImg = "uncheck.gif";

                    if(userItem!=null){
                        sItemLabel = userItem.label;
                        sChecked = " checked";
                        sImg = "check.gif";
                        
                        order = userItem.order;  
                        savedOrder = userItem.order;
                    }
                    else{
                        sItemLabel = xmlItem.label;
                        
                        if(sItemLabel.startsWith("ITEM_TYPE_")){
                            sItemLabel = sItemLabel.substring("ITEM_TYPE_".length()); // shorten even more
                        }

                        order = xmlItem.order;
                        savedOrder = 9999;
                    }
                   
                    // alternate row-style
                    if(sClass.length()==0) sClass = "1";
                    else                   sClass = "";
                    
                    %>
                        <tr height="18" class="list<%=sClass%>" onmouseover="this.className='list_select';" onmouseout="this.className='list<%=sClass%>';">
                            <td align="center">
                                <input type="hidden" name="ItemType_<%=itemCount%>" value="<%=sItemType%>">
                                <input type="hidden" name="DefaultOrder_<%=itemCount%>" value="<%=((defaultOrder>=9999 || defaultOrder==0)?"":defaultOrder)%>">
                                <input type="hidden" name="AddFunction_<%=itemCount%>" value="<%=xmlItem.getAddFunction()%>">
                                              
                                <img src="<%=sCONTEXTPATH%>/_img/<%=sImg%>" name="cb_<%=itemCount%>" id="cb_<%=itemCount%>" onClick="clickCheckbox('cb_<%=itemCount%>');" style="vertical-align:-1px">
                            </td>
                            <td onClick="toggleCheckbox('cb_<%=itemCount%>');" nowrap>&nbsp;<%=sItemType.substring(ScreenHelper.ITEM_PREFIX.length())%><br>
                                <%=listCombinedItems(sItemType.substring(ScreenHelper.ITEM_PREFIX.length()),sTranType,combinationsDocument,"<br>")%>
                            </td>
                            <td>&nbsp;<%=((defaultOrder>=9999 || defaultOrder==0)?"":defaultOrder)%></td> 
                            <td>&nbsp;<%=((savedOrder>=9999 || savedOrder==0)?"":savedOrder)%></td>
                            <td>&nbsp;<input type="text" class="text" size="3" maxLength="3" name="Order_<%=itemCount%>" value="<%=((order>=9999 || order==0)?"":order)%>"></td>
                            <%-- <td>&nbsp;<%=getOrderSelect("Order_"+itemCount,xmlHistItems.size(),((order>=9999 || order==0)?defaultOrder:order))%></td> --%>
                            <td>
                                &nbsp;<input type="text" class="text" name="UserDefinedLabel_<%=itemCount%>" tabIndex="<%=tabIndex++%>" size="70" maxLength="80" value="<%=sItemLabel%>">                        
                            </td>
                        </tr>
                    <%
                }
            }
            
            %>
                </table>
                
                <%-- INSTRUCTIONS --%>
                <%=getTran("web.userprofile","historyItemsManageInstructions",sWebLanguage)%><br>
                <%=getTran("web.userprofile","historyItemsAreManagedByAdmin",sWebLanguage)%>
            <%
        }

        // records found message
        if(sAction.length() > 0){
            if(itemCount > 0){
                %>
                    <%-- BUTTONS at BOTTOM --------------------------------------------------------------------------%>
                    <table width="100%" cellspacing="0" cellpadding="0">
                        <tr>
                            <td>
                                <a href="#" onclick="checkAll(true);"><%=getTran("web.manage","checkAll",sWebLanguage)%></a>
                                <a href="#" onclick="checkAll(false);"><%=getTran("web.manage","uncheckAll",sWebLanguage)%></a>
                            </td>
                            
                            <%
                                if(itemCount > 10){
                                    %>
                                        <td align="right">
                                            <a href="#top"><img src="<c:url value='/_img/top.jpg'/>" class="link"></a>
                                        </td>
                                    <%
                                }
                            %>
                        </tr>
                    </table>
                <%
            }
            else{
                %>&nbsp;<%=getTran("web","noItemsToSelectFound",sWebLanguage)%><%
            }
        }
    %>

    <%-- BUTTONS --%>
    <div style="text-align:center;padding-top:10px;">
        <%
            if(itemCount > 0){
                %>
                    <%=ScreenHelper.writeSaveButton("doSave();",sWebLanguage)%>
                    <%=ScreenHelper.writeResetButton(sWebLanguage)%>
                <%
            }
        %>
        <%=ScreenHelper.writeBackButton(sWebLanguage)%>
    </div>
</form>

<script>
  <%-- CLEAR ORDER --%>
  function clearOrder(){
    for(var i=0; i<transactionForm.elements.length; i++){
      if(transactionForm.elements[i].type=="text"){ 
        if(transactionForm.elements[i].name.startsWith("Order_")){
          transactionForm.elements[i].value = "";
        }
      }
    }
  }
  
  <%-- SET DEFAULT ORDER --%>
  function setDefaultOrder(){
    for(var i=0; i<transactionForm.elements.length; i++){
      if(transactionForm.elements[i].type=="text"){ 
    	if(transactionForm.elements[i].name.startsWith("Order_")){
    	  var id = transactionForm.elements[i].name.substring("Order_".length);
          transactionForm.elements[i].value = eval("transactionForm.DefaultOrder_"+id+".value");
    	}
      }
    }
  }

  <%-- CHECK ALL --%>
  function checkAll(setchecked){	
	var imgs = document.getElementsByTagName("img");
    for(var i=0; i<imgs.length; i++){
      if(imgs[i].id.startsWith("cb_")){        
   	    if(setchecked==true) imgs[i].src = "<%=sCONTEXTPATH%>/_img/check.gif";
   	    else                 imgs[i].src = "<%=sCONTEXTPATH%>/_img/uncheck.gif";
      }
    }
  }
  
  <%-- CLICK CHECKBOX --%>
  function clickCheckbox(cbName){
    var cb = eval("transactionForm."+cbName);
    if(cb.src.endsWith("uncheck.gif")) cb.src = "<%=sCONTEXTPATH%>/_img/check.gif";
    else                               cb.src = "<%=sCONTEXTPATH%>/_img/uncheck.gif";
  }

  <%-- TOGGLE CHECKBOX --%>
  function toggleCheckbox(cbName){
    var cb = eval("transactionForm."+cbName);
    if(cb.src.endsWith("uncheck.gif")) cb.src = "<%=sCONTEXTPATH%>/_img/check.gif";
    else                               cb.src = "<%=sCONTEXTPATH%>/_img/uncheck.gif";
  }

  <%-- DISPLAY HIST ITEMS --%>
  function displayHistItems(){
    if(transactionForm.TranType.value.length > 0){
      transactionForm.Action.value = "displayItems";
      submitForm(); 
    }
  }
  
  <%-- DO SAVE --%>
  function doSave(){
	if(countCheckedItems() > 0){
      transactionForm.Action.value = "saveItems";
      submitForm();
	}
	else{
      if(confirmPopup("<%=getTranNoLink("web","noItemsSelectedContinue",sWebLanguage)%>")==1){
        transactionForm.Action.value = "saveItems";
    	submitForm();
      }
	}
  }
  
  <%-- COUNT CHECKED ITEMS --%>
  function countCheckedItems(){
	var itemCount = 0;

    var imgs = document.getElementsByTagName("img");
    for(var i=0; i<imgs.length; i++){
      if(imgs[i].id.startsWith("cb_")){        
   	    if(!imgs[i].src.endsWith("uncheck.gif")){
   	      itemCount++;	
   	    }
      }
    }
	
	return itemCount;
  }
  
  <%-- CONCAT CHECKBOXES --%>
  function concatCheckboxes(){
	var imgs = document.getElementsByTagName("img");
    for(var i=0; i<imgs.length; i++){
      if(imgs[i].id.startsWith("cb_") && !imgs[i].src.endsWith("uncheck.gif")){
        transactionForm.ConcatCheckboxes.value+= imgs[i].id+";";
	  }
	}
  }
     
  <%-- SUBMIT FORM --%>
  function submitForm(){   
	concatCheckboxes();
		
    <%-- disable buttons --%>
    <%
        if(itemCount > 0){
            %>
              transactionForm.saveButton.disabled = true;
              transactionForm.resetButton.disabled = true;
            <%
        }
    %>
    transactionForm.backButton.disabled = true;
      
    transactionForm.submit();  
  }
  
  <%-- DO BACK --%>
  function doBack(){
    window.location.href = "<c:url value='/main.jsp'/>?Page=userprofile/index.jsp"; 
  }
    
  <%-- INITIAL SORT --%>
  function initialSort(){
  }
</script>