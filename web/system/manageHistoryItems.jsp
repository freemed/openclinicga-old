<%@page import="be.mxs.common.util.system.HTMLEntities"%>
<%@page import="be.mxs.common.model.vo.healthrecord.TransactionVO,
                be.mxs.common.model.vo.healthrecord.ItemContextVO,
                org.dom4j.io.XMLWriter,
                org.dom4j.io.SAXReader,
                org.dom4j.Element,
                org.dom4j.Document,
                org.dom4j.DocumentFactory,
                org.dom4j.io.OutputFormat,
                java.io.FileOutputStream"%>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>
<%=sJSSORTTABLE%>

<%!    
    private static Hashtable itemCombinations = null;

    /// INNER CLASS ItemAndLabel //////////////////////////////////////////////////////////////////
    private class ItemAndLabel implements Comparable {
        public ItemVO item;
        public String labelType, labelId;
        public String addFunction;
        public int order = 9999; // undefined order
        
        public ItemAndLabel(ItemVO item, String sLabelType, String sLabelId, String sOrder){
            this.item = item;
            this.labelType = sLabelType;
            this.labelId = sLabelId;  
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
    
            if(!item.getType().equals(itemAndLabel.item.getType()) && 
               !labelType.equals(itemAndLabel.labelType) &&
               !labelId.equals(itemAndLabel.labelId)){
                return false;
            }
    
            return true;
        }
    
        //--- COMPARE TO (order AND labeltype and labelid) --------------------
        public int compareTo(Object o){
            int comp;
    
            if(o.getClass().isInstance(this)){
            	//comp = this.order - ((ItemAndLabel)o).order;
                comp = (this.order+"$"+this.labelType+"$"+this.labelId).compareTo(((ItemAndLabel)o).order+"$"+((ItemAndLabel)o).labelType+"$"+((ItemAndLabel)o).labelId);
            }
            else{
                throw new ClassCastException();
            }
    
            return comp;
        }
    
    }

    //--- GET HISTORY ITEMS FROM XML --------------------------------------------------------------
    // the xml contains all available items (managed by us, directly in xml)
    public Vector getHistoryItemsFromXML(Document document, String sTranType, String sWebLanguage){
        Vector itemsAndLabels = new Vector();

        try{
        	/*
        	// TODO : writing the xml to file keeps having a delay due to 
        	//        which the read below comes to soon to pick up any changes,
            //        so pass along the document by parameter.. 
            
            // read xml
            String sXmlFile = getConfigString("templateSource")+"historyItems_"+sAppName+".xml";
            SAXReader xmlReader = new SAXReader(false);
            Document document = xmlReader.read(new URL(sXmlFile));
            */
                        
            Iterator itemElements = document.getRootElement().elementIterator("item");

            ItemContextVO itemContextVO = new ItemContextVO(new Integer(IdentifierFactory.getInstance().getTemporaryNewIdentifier()),"","");
            
            // varia declarations
            String sTmpTranTypeShort, sItemTypeShort, sLabelType, sLabelId,
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
                    sTmpTranTypeShort = itemElem.attribute("tranTypeShort").getValue();
                    
                    if(sTranType.equalsIgnoreCase(ScreenHelper.ITEM_PREFIX+sTmpTranTypeShort)){
                        sItemTypeShort = itemElem.attribute("itemTypeShort").getValue();                        
                        sLabel = ""; sLabelType = ""; sLabelId = ""; 
                        
                        // order, if any
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
                        
                        itemAndLabel = new ItemAndLabel(item,sLabelType,sLabelId,sOrder);
                        
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
    public boolean isCombinedItem(ItemVO item, Document combinationsDocument, String sTranType){
    	String sShortSearchedItemType = item.getType().substring(item.getType().toLowerCase().indexOf(ScreenHelper.ITEM_PREFIX.toLowerCase())+ScreenHelper.ITEM_PREFIX.length());
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
   				if(sTmpCombinedItemType.equalsIgnoreCase(sShortSearchedItemType)){
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
            if(itemAndLabel.item.getType().equalsIgnoreCase(sItemType)){
                return itemAndLabel;
            }
        }

        return null;
    }

    //--- SAVE ITEM TO XML ------------------------------------------------------------------------
    public Element saveItemToXML(Element rootElem, String sTranTypeShort, String sItemTypeShort,
    		                     String sLabelType, String sLabelId, String sOrder, String sAddFunction){
        // check existence
        Element searchedItem = getItemFromXML(rootElem,sTranTypeShort,sItemTypeShort);
        if(searchedItem==null){
            searchedItem = rootElem.addElement("item");
        } 
        searchedItem.addAttribute("tranTypeShort",sTranTypeShort);
        searchedItem.addAttribute("itemTypeShort",sItemTypeShort);
                
        searchedItem.addAttribute("actif","true"); // activate
        searchedItem.addAttribute("order",sOrder);
        	
       	// set label, if specified
       	if(sLabelType.length() > 0 && sLabelId.length() > 0){
       		// check existence of label
	       	Element labelElem = searchedItem.element("label");
	       	if(labelElem==null){
	       	    labelElem = searchedItem.addElement("label");
	       	}
	   		labelElem.addAttribute("type",sLabelType);
	   		labelElem.addAttribute("id",sLabelId);
       	}
    	
       	// set addFunction, if specified
       	if(sAddFunction.length() > 0){
       		// check existence of label
	       	Element addFunctionElem = searchedItem.element("addFunction");
	       	if(addFunctionElem==null){
	       		addFunctionElem = searchedItem.addElement("addFunction");
	       	}
	       	addFunctionElem.addAttribute("value",sAddFunction);
       	}
       	
    	return rootElem;
    }
    
    //--- REMOVE ITEM FROM XML --------------------------------------------------------------------
    public Element removeItemFromXML(Element rootElem, String sTranTypeShort, String sItemTypeShort){    	
        // check existence
        Element searchedItem = getItemFromXML(rootElem,sTranTypeShort,sItemTypeShort);       
        if(searchedItem!=null){
            rootElem.remove(searchedItem);   
        }
        
    	return rootElem;
    }
    
    //--- REMOVE ITEM FROM USERPARAMETERS ---------------------------------------------------------
    public void removeItemFromUserParameters(String sTranTypeShort, String sItemTypeShort){          
        PreparedStatement ps = null;
        Connection conn = null;
    
        try{
            conn = MedwanQuery.getInstance().getAdminConnection();
            String sSql = "DELETE FROM userparameters"+
                          " WHERE parameter = ? AND value LIKE ?";
            ps = conn.prepareStatement(sSql);
            ps.setString(1,"HistoryItem."+sTranTypeShort);
            ps.setString(2,sItemTypeShort+"$%");
            ps.executeUpdate();            
        }
        catch(Exception e){
            Debug.printStackTrace(e);
        }
        finally{
            try{
                if(ps!=null) ps.close();
                if(conn!=null) conn.close();
            }
            catch(Exception e){
                Debug.printStackTrace(e);
            }
        }
    }
    
    //--- GET ITEM FROM XML -----------------------------------------------------------------------
    public Element getItemFromXML(Element rootElem, String sTranTypeShort, String sItemTypeShort){
    	Element searchedItem = null;

        // run over "items" in xml
        Iterator itemElements = rootElem.elementIterator("item");
        Element itemElem;
        
        while(itemElements.hasNext()){
            itemElem = (Element)itemElements.next();
            
            // tranType and itemType = identifier
            if(sTranTypeShort.equalsIgnoreCase(itemElem.attribute("tranTypeShort").getValue())){
                if(sItemTypeShort.equalsIgnoreCase(itemElem.attribute("itemTypeShort").getValue())){
                	searchedItem = itemElem;
                	break;
                }
            }
        }

        return searchedItem;
    }
    
    //--- SAVE DOCUMENT TO XML --------------------------------------------------------------------
    // unsorted but that's OK because the file does not need to be managed manually
    public void saveDocumentToXML(Document document, String sProjectName){
    	try{
            String sXmlFile = ScreenHelper.getConfigString("templateDirectory");
            if(sProjectName.length() > 0){
            	sXmlFile+= "/historyItems_"+sProjectName+".xml";
            }
            else{
            	sXmlFile+= "/historyItems.xml";
            }
            Debug.println("Saving to xml-file : "+sXmlFile);
            
	        FileOutputStream fos = new FileOutputStream(sXmlFile);
	        OutputFormat format = OutputFormat.createPrettyPrint(); 
	        XMLWriter writer = new XMLWriter(fos,format);
	        writer.write(document); 

	        fos.flush();
	        fos.close();
	        writer.flush();
	        writer.close();
    	}
    	catch(Exception e){
    		e.printStackTrace();
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

    /// DEBUG /////////////////////////////////////////////////////////////////////////////////////
    if(Debug.enabled){
        Debug.println("\n******************** system/manageHistoryItems.jsp ********************");
        Debug.println("sAction : "+sAction); 
        Debug.println("sTranType : "+sTranType+"\n");
    }
    ///////////////////////////////////////////////////////////////////////////////////////////////

    String sMsg = "";
    int itemCount = 0;

    // 'delhaize', 'medwan' or empty
    String sAppName = sAPPDIR.endsWith("/")?sAPPDIR.substring(0,sAPPDIR.length()-1):sAPPDIR;
    sAppName = sAppName.substring(sAppName.indexOf("/")+1);

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
    	Element rootElem = itemsDocument.getRootElement();        
    	
        String sParamName, sParamValue, sTranTypeShort, sItemType, sItemTypeShort = "",
        	   sLabelType, sLabelId, sOrder, sAddFunction;
        int cbCount = 0;
        
        String sConcatCheckboxes = checkString(request.getParameter("ConcatCheckboxes"));
        if(sConcatCheckboxes.length() > 0){
        	String[] checkboxes = sConcatCheckboxes.split(";"); 
        			
        	for(int i=0; i<checkboxes.length; i++){
        		sParamName = checkboxes[i].split("=")[0];
        		sParamValue = checkboxes[i].split("=")[1]; 
                		
                cbCount = Integer.parseInt(sParamName.substring(sParamName.indexOf("_")+1));
                sItemType = checkString(request.getParameter("ItemType_"+cbCount));
                sOrder = checkString(request.getParameter("Order_"+cbCount));

                // shorten
                sTranTypeShort = sTranType.substring(sTranType.toLowerCase().indexOf(ScreenHelper.ITEM_PREFIX.toLowerCase())+ScreenHelper.ITEM_PREFIX.length()); 
                sItemTypeShort = sItemType.substring(sItemType.toLowerCase().indexOf(ScreenHelper.ITEM_PREFIX.toLowerCase())+ScreenHelper.ITEM_PREFIX.length());
                
                // checked
                if(sParamValue.equals("true")){	                      
	                sLabelType   = checkString(request.getParameter("LabelType_"+cbCount));
	                sLabelId     = checkString(request.getParameter("LabelId_"+cbCount));
	                sAddFunction = checkString(request.getParameter("AddFunction_"+cbCount));
	                	                
	                // save item to xml
	                rootElem = saveItemToXML(rootElem,sTranTypeShort,sItemTypeShort,sLabelType,sLabelId,sOrder,sAddFunction);
                }
                else{
	                // remove item from xml
	                rootElem = removeItemFromXML(rootElem,sTranTypeShort,sItemTypeShort);
	                
	                removeItemFromUserParameters(sTranTypeShort,sItemTypeShort);
                }
            }
        }
        
        saveDocumentToXML(itemsDocument,sAppName);
        	
        sMsg = "<font color='green'>"+getTran("web","dataIsSaved",sWebLanguage)+"</font>";
        sAction = "displayItems";
    }
%>

<form id="transactionForm" name="transactionForm" method="post">
    <input type="hidden" name="Action">
    <input type="hidden" name="ConcatCheckboxes" value="">

    <%-- TITLE --%>
    <%=writeTableHeader("web.manage","manageHistoryItems",sWebLanguage," doBack();")%>

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
                        
                        for(int i=0; i<tranLabels.size(); i++){
                        	sTranLabel = (String)tranLabels.get(i); 
                        	sTmpTranType = (String)tranTypesAndLabels.get(sTranLabel);
                            
                            // selected ?
                            sSelected = "";
                            if(sTmpTranType.equals(sTranType)){
                                sSelected = " selected";
                            }

                            %><option value="<%=sTmpTranType%>" <%=sSelected%>><%=sTranLabel%></option><%
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
        	SessionContainerWO sessionContainerWO = (SessionContainerWO)SessionContainerFactory.getInstance().getSessionContainerWO(request,SessionContainerWO.class.getName());
            ItemContextVO itemContextVO = new ItemContextVO(new Integer(IdentifierFactory.getInstance().getTemporaryNewIdentifier()),"","");            
            Vector defaultTranItems = MedwanQuery.getInstance().loadTransactionItems(sTranType,itemContextVO);

            //*** 1 : exclude some system-related items ***************
            Vector excludedItems = new Vector();
            excludedItems.add(ScreenHelper.ITEM_PREFIX+"ITEM_TYPE_TRANSACTION_RESULT");
            excludedItems.add(ScreenHelper.ITEM_PREFIX+"ITEM_TYPE_CONTEXT_DEPARTMENT");
            excludedItems.add(ScreenHelper.ITEM_PREFIX+"ITEM_TYPE_RECRUITMENT_CONVOCATION_ID");

            Vector newDefaultTranItems = new Vector();
            boolean exclItemFound;
            String sExclItem = "";
            ItemVO item;
         
            for(int i=0; i<defaultTranItems.size(); i++){
                item = (ItemVO)defaultTranItems.get(i);
                exclItemFound = false;

                for(int j=0; j<excludedItems.size(); j++){
                    sExclItem = (String)excludedItems.get(j);
                 
                    if(sExclItem.equals(item.getType())){
                        exclItemFound = true;
                        break;
                    }
                }             

                if(!exclItemFound){
                    newDefaultTranItems.add(item);
                }
            }        
            defaultTranItems = newDefaultTranItems;  
            
            //*** 2 : exclude composing items *************************
            newDefaultTranItems = new Vector();
            for(int i=0; i<defaultTranItems.size(); i++){
                item = (ItemVO)defaultTranItems.get(i);
                                     
                if(!sessionContainerWO.isComposingItem(item,defaultTranItems)){
                    newDefaultTranItems.add(item);
                }
            }    
            defaultTranItems = newDefaultTranItems;         
            
            //*** 3 : exclude combined items **************************
            newDefaultTranItems = new Vector();
            int combinedItemCount = 0;
            
            for(int i=0; i<defaultTranItems.size(); i++){
                item = (ItemVO)defaultTranItems.get(i);
                                     
                if(!isCombinedItem(item,combinationsDocument,sTranType)){
                    newDefaultTranItems.add(item);
                }
                else{
                    combinedItemCount++;
                }
            }    
            defaultTranItems = newDefaultTranItems;
            
            int tabIndex = 1;
            Collections.sort(defaultTranItems);            
            if(defaultTranItems.size() > 0){   
	            Vector xmlHistItems = getHistoryItemsFromXML(itemsDocument,sTranType,sWebLanguage);
	            Collections.sort(xmlHistItems);  

	            int historyItemCount = xmlHistItems.size()-combinedItemCount;
	                             		
                // header
                %>  
                    <%=historyItemCount%>/<%=defaultTranItems.size()%> <%=getTran("web","itemsSelected",sWebLanguage)%><br><br>
                    
                    <table class="sortable" id="searchresults" width="100%" cellspacing="1" cellpadding="0" style="border:1px solid #ccc;">
                        <%-- HEADER --%>
                        <tr>
                            <td class="admin" width="14"></td>
                            <td class="admin" width="320"><%=getTran("web","itemType",sWebLanguage)%></td>
                            <td class="admin" width="55"><SORTTYPE:NUM><%=HTMLEntities.htmlentities(getTran("web","savedOrder",sWebLanguage))%></SORTTYPE:NUM></td>
                            <td class="admin" width="55"><NOSORT><%=HTMLEntities.htmlentities(getTran("web","newOrder",sWebLanguage))%></NOSORT></td>
                            <td class="admin" width="95"><NOSORT><%=HTMLEntities.htmlentities(getTran("web","labeltype",sWebLanguage))%></NOSORT></td>
                            <td class="admin" width="240"><NOSORT><%=HTMLEntities.htmlentities(getTran("web","labelid",sWebLanguage))%></NOSORT></td>
                            <td class="admin" width="240"><NOSORT><%=HTMLEntities.htmlentities(getTran("web","existinglabel",sWebLanguage))%></NOSORT></td>
                        </tr>
                <%
                
                // display a checkbox for each defaultItem the admin CAN select
                String sItemType = "", sItemValue = "", sLabelType = "", sAddFunction = "",
                       sLabelId = "", sClass = "", sChecked = "", sImg = "";
                ItemAndLabel xmlItem;
                
                // check a checkbox for each histItem the admin HAS selected
                for(int i=0; i< defaultTranItems.size(); i++){
                    item = (ItemVO)defaultTranItems.get(i);
                    sItemType = item.getType();
                    itemCount++;

                    // checked ? + label
                    xmlItem = getItemFromVector(xmlHistItems,sItemType);
                    
                    sLabelType = "";
                    sLabelId = "";
                    sChecked = "";
                    int order = 0;
                    sAddFunction = "";
                    sImg = "uncheck.gif";
                    
                    if(xmlItem!=null){
                    	sLabelType = xmlItem.labelType;
                    	sLabelId = xmlItem.labelId;                    	
                        sChecked = " checked";
                        sImg = "check.gif";
                        order = xmlItem.order;
                        sAddFunction = xmlItem.getAddFunction();
                    }
                   
                    // alternate row-style
                    if(sClass.length()==0) sClass = "1";
                    else                   sClass = "";
                    
                    %>
                        <tr height="18" class="list<%=sClass%>" <%-- onmouseover="this.className='list_select';" onmouseout="this.className='list<%=sClass%>';"--%>>
                            <td align="center" nowrap>
                                <input type="hidden" name="ItemType_<%=itemCount%>" value="<%=sItemType%>">                                                                                                
                                <img src="<%=sCONTEXTPATH%>/_img/<%=sImg%>" name="cb_<%=itemCount%>" id="cb_<%=itemCount%>" onClick="clickCheckbox('cb_<%=itemCount%>');" style="vertical-align:-1px">
                            </td>
                            <td onClick="toggleCheckbox('cb_<%=itemCount%>');">&nbsp;<%=sItemType.substring(ScreenHelper.ITEM_PREFIX.length())%><br>
                                <%=listCombinedItems(sItemType.substring(ScreenHelper.ITEM_PREFIX.length()),sTranType,combinationsDocument,"<br>")%>
                            </td>
                            <td>&nbsp;<%=((order>=9999 || order==0)?"":order)%></td>
                            <td>&nbsp;<input type="text" class="text" size="3" maxLength="3" name="Order_<%=itemCount%>" value="<%=((order>=9999 || order==0)?"":order)%>"></td>
                            
                            <td>&nbsp;<input type="text" class="text" name="LabelType_<%=itemCount%>" tabIndex="<%=tabIndex++%>" onBlur="blurLabel('<%=itemCount%>');" size="15" maxLength="50" value="<%=sLabelType%>"></td>
                            <td>&nbsp;<input type="text" class="text" name="LabelId_<%=itemCount%>" tabIndex="<%=tabIndex++%>" onBlur="blurLabel('<%=itemCount%>');" size="63" maxLength="150" value="<%=sLabelId%>"></td>
                            <td>&nbsp;<span id="LabelField_<%=itemCount%>" style="width:160px"/></td>
                        </tr>
                    <%
                }
            }
            
            %>
                </table>
                
                <%
                    if(defaultTranItems.size() > 0){
                        %>
			                <%-- INSTRUCTIONS --%>
			                <%=getTran("web.manage","historyItemsManageInstructions",sWebLanguage)%><br>
			                <%=getTran("web.manage","historyItemsManageInstructions2",sWebLanguage)%>
			            <%
			        }
			    %>
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
                                <a href="javascript:checkAll(true);"><%=getTran("web.manage","checkAll",sWebLanguage)%></a>
                                <a href="javascript:checkAll(false);"><%=getTran("web.manage","uncheckAll",sWebLanguage)%></a>
                            </td>
                            
                            <%
                                if(itemCount > 10){
                                    %>
                                        <td align="right">
                                            <a href="#top"><img src="<c:url value='/_img/themes/default/top.gif'/>" class="link"></a>
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
  <%-- CHECK ALL --%>
  function checkAll(setchecked){	
	var imgs = document.getElementsByTagName("img");
    for(var i=0; i<imgs.length; i++){
      if(imgs[i].id.startsWith("cb_")){        
   	    if(setchecked==true) imgs[i].src = "<%=sCONTEXTPATH%>/_img/themes/default/check.gif";
   	    else                 imgs[i].src = "<%=sCONTEXTPATH%>/_img/themes/default/uncheck.gif";
   	
        autoBlurLabel(imgs[i].name);
      }
    }
  }
  
  <%-- CLICK CHECKBOX --%>
  function clickCheckbox(cbName){
    var cb = eval("transactionForm."+cbName);
    if(cb.src.endsWith("uncheck.gif")) cb.src = "<%=sCONTEXTPATH%>/_img/themes/default/check.gif";
    else                               cb.src = "<%=sCONTEXTPATH%>/_img/themes/default/uncheck.gif";
	
    autoBlurLabel(cbName);
  }
  
  <%-- TOGGLE CHECKBOX --%>
  function toggleCheckbox(cbName){
    var cb = eval("transactionForm."+cbName);
    if(cb.src.endsWith("uncheck.gif")) cb.src = "<%=sCONTEXTPATH%>/_img/themes/default/check.gif";
    else                               cb.src = "<%=sCONTEXTPATH%>/_img/themes/default/uncheck.gif";
    
    autoBlurLabel(cbName);
  }
  
  <%-- AUTO BLUR LABEL --%>
  function autoBlurLabel(cbName){
    var itemCount = cbName.substr(3); // remove cb_
    
    if(eval("transactionForm."+cbName+".src").endsWith("uncheck.gif")){
      eval("transactionForm.LabelType_"+itemCount+".value = '';");
      eval("transactionForm.LabelId_"+itemCount+".value = '';");
      document.getElementById("LabelField_"+itemCount).innerHTML = "";
    }
    else{
      eval("transactionForm.LabelType_"+itemCount+".value = 'web.occup';");
      eval("transactionForm.LabelId_"+itemCount+".value = transactionForm.ItemType_"+itemCount+".value");
      blurLabel(itemCount);   
    }
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
    transactionForm.Action.value = "saveItems";
    submitForm();
  }
 
  <%-- CONCAT CHECKBOXES --%>
  function concatCheckboxes(){
	var imgs = document.getElementsByTagName("img");
    for(var i=0; i<imgs.length; i++){
      if(imgs[i].id.startsWith("cb_")){
        transactionForm.ConcatCheckboxes.value+= imgs[i].id+"="+(!imgs[i].src.endsWith("uncheck.gif"))+";";	 
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

  <%-- BLUR LABEL --%>
  function blurLabel(itemId){
    var labelType = eval("transactionForm.LabelType_"+itemId+".value"),
        labelId   = eval("transactionForm.LabelId_"+itemId+".value");
      
    if(labelType.length > 0 && labelId.length > 0){
      var url = "<%=sCONTEXTPATH%>/system/ajax/blurLabel.jsp?skipRequestQueue=true&ts="+new Date().getTime();
      new Ajax.Request(url,
        {
          method: "GET",
          parameters: {
            LabelType: labelType,
            LabelId: labelId 
          },
          onSuccess: function(resp){
            var respText = convertSpecialCharsToHTML(resp.responseText);
            respText = trim(respText);

            if(respText.length > 0){
              document.getElementById("LabelField_"+itemId).innerHTML = respText;
            }
            else{
           	  document.getElementById("LabelField_"+itemId).innerHTML = "<font color='red'><%=getTranNoLink("web","labelNotFound",sWebLanguage)%></font>";

              eval("transactionForm.LabelType_"+itemId+".value = '';");
              eval("transactionForm.LabelId_"+itemId+".value = '';");
            }
          },
          onFailure: function(resp){
            alert("ERROR : "+resp.responseText);
          }
        }
      );
    }
    else{
      document.getElementById("LabelField_"+itemId).innerHTML = "";
    }
  }
  
  <%-- BLUR EXISTING LABELS --%>
  blurExistingLabels();
  
  function blurExistingLabels(){
    var imgs = document.getElementsByTagName("img");
    for(var i=0; i<imgs.length; i++){
      if(imgs[i].id.startsWith("cb_")){
        var itemId = (imgs[i].id).substring("cb_".length);
	    blurLabel(itemId);
	  }
	}
  }

  <%-- DO BACK --%>
  function doBack(){
    window.location.href = "<%=sCONTEXTPATH%>/main.jsp?Page=system/menu.jsp"+
    		               "&Tab=setup"+
    		               "&ts=<%=getTs()%>";
  }
</script>