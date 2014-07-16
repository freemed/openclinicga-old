package be.openclinic.system;

import java.io.BufferedWriter;
import java.io.File;
import java.io.FileOutputStream;
import java.io.OutputStreamWriter;
import java.io.StringReader;
import java.net.URL;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.util.*;
import javax.servlet.http.HttpSession;
import net.admin.Label;

import org.dom4j.DocumentHelper;
import org.dom4j.Element;
import org.dom4j.Document;
import org.dom4j.io.OutputFormat;
import org.dom4j.io.SAXReader;
import org.dom4j.io.XMLWriter;
import org.dom4j.tree.DefaultAttribute;

import be.mxs.common.util.db.MedwanQuery;
import be.mxs.common.util.system.Debug;
import be.mxs.common.util.system.ScreenHelper;
import be.mxs.common.util.system.UpdateSystem;
import be.openclinic.common.OC_Object;

/*
    CREATE TABLE oc_screens (
        OC_SCREEN_SERVERID int(10),
        OC_SCREEN_OBJECTID int(10),
        OC_SCREEN_TRANSACTIONTYPE varchar(100),
        OC_SCREEN_XMLDATA longblob,
        OC_SCREEN_CREATIONDATE datetime,
        OC_SCREEN_UPDATETIME datetime,
        OC_SCREEN_UPDATEID int(10)
    )
    
    CREATE TABLE oc_screens_history (
        OC_SCREEN_SERVERID int(10),
        OC_SCREEN_OBJECTID int(10),
        OC_SCREEN_TRANSACTIONTYPE varchar(100),
        OC_SCREEN_XMLDATA longblob,
        OC_SCREEN_CREATIONDATE datetime,
        OC_SCREEN_UPDATETIME datetime,
        OC_SCREEN_UPDATEID int(10)
    )
*/

public class Screen extends OC_Object {  
    public int serverId;
    public int objectId;    

    public int widthInCells = -1;
    public int heightInRows = -1;

    public java.util.Date creationDate;
    public java.util.Date updateTime;
    public int userID;

    private Document xmlData; 
    private String examId;
    private String transactionType;
    private Vector rows;
    private Hashtable labels;
    
    
    //--- CONSTRUCTOR ---
    public Screen(){
        super();
        serverId = -1;
        objectId = -1;

        //widthInCells = MedwanQuery.getInstance().getConfigInt("defaultWidthInCells",2);
        //heightInRows = MedwanQuery.getInstance().getConfigInt("defaultHeightInRows",3);
        
        examId = "-1";
        transactionType = "";
        creationDate = new java.util.Date();
        updateTime = new java.util.Date();
        userID = -1;

        xmlData = null;
        setUid("-1");
        rows = new Vector();
        labels = new Hashtable();
    }
    
    //--- SET XML DATA ----------------------------------------------------------------------------
    public void setXmlData(Document xmlDocument){
        this.xmlData = xmlDocument;
    }

    //--- GET XML DATA ----------------------------------------------------------------------------
    public Document getXmlData(){
        return this.xmlData;
    }
    
    //--- GET TRANSACTION TYPE --------------------------------------------------------------------
    public String getTransactionType(){
        return this.transactionType;
    } 
        
    //--- GET ROWS --------------------------------------------------------------------------------
    // for testing only
    public Vector getRows(){
        return this.rows;
    }
    
    //--- GET EXAM ID -----------------------------------------------------------------------------
    public String getExamId(){
        return this.examId;
    }
    
    //--- GET LABEL -------------------------------------------------------------------------------
    public String getLabel(String sLanguage){
        return ScreenHelper.checkString((String)this.labels.get(sLanguage));
    }
    
    //--- ADD LABEL -------------------------------------------------------------------------------
    public void addLabel(String sLanguage, String sValue){
        this.labels.put(sLanguage,sValue);
    }
    
    //--- GET REQUIRED FIELD ----------------------------------------------------------------------
    public Vector getRequiredFields(){
        Vector requiredFields = new Vector();
        Debug.println("\n************************* getRequiredFields **********************");

        Iterator rowIter = this.rows.iterator();
        Hashtable row, cell;
        String sRowId, sRowHeight, sCellID, sCellWidth;
        ScreenTransactionItem item;
        
        //*** 1 - rows ***
        while(rowIter.hasNext()){
            row = (Hashtable)rowIter.next();
            
            //*** 2 - cells ***
            Vector cells = (Vector)row.get("Cells");
            Iterator cellIter = cells.iterator();
            
            while(cellIter.hasNext()){
                cell = (Hashtable)cellIter.next();
               
                //*** 3 - items ***
                LinkedHashMap items = (LinkedHashMap)cell.get("Items");
                if(items!=null){
                    Iterator itemIter = items.keySet().iterator();
                    String key;
                    
                    while(itemIter.hasNext()){
                        key = (String)itemIter.next();
                        item = (ScreenTransactionItem)items.get(key);

                        if(item.getAttribute("Attr_required").equals("true")){
                            requiredFields.add(item.getItemTypeId());
                            Debug.println("REQUIRED "+item.getItemTypeId());
                        }
                    }
                }
            }
        }

        Debug.println("--> requiredFields : "+requiredFields.size()+"\n");
        return requiredFields;
    }
    
    //--- GET CELL ATTRIBUTE ----------------------------------------------------------------------
    public String getCellAttribute(Hashtable cell, String sAttrName){
        return getCellAttribute(cell,sAttrName,"");
    }
    
    public String getCellAttribute(Hashtable cell, String sAttrName, String sDefaultValue){
        String sAttribute = ScreenHelper.checkString((String)cell.get("Attr_"+sAttrName));
        
        if(sAttribute.length()==0 && sDefaultValue.length() > 0){
            sAttribute = sDefaultValue;    
        }
        
        return sAttribute;
    }
    
    //--- GET ROW (BY ID) -------------------------------------------------------------------------
    public Hashtable getRow(String sRowId){
        Hashtable row = null;
        
        Iterator rowIter = this.rows.iterator();
        Element rowElem;
        String sTmpRowId;
        boolean rowFound = false;
        
        //*** 1 - rows ***
        while(rowIter.hasNext() && !rowFound){
            row = (Hashtable)rowIter.next();
                
            sTmpRowId = ScreenHelper.checkString((String)row.get("Attr_id"));
            if(sTmpRowId.equalsIgnoreCase(sRowId)){
            	rowFound = true;
                break;
            }
        }        
        if(!rowFound) row = null;
        return row;
    }    
    
    //--- DELETE ROW ------------------------------------------------------------------------------
    public void deleteRow(String sRowId, int userId, String sWebLanguage, HttpSession session){
    	String sTmpRowId;
    	Hashtable row;
    	Vector newRows = new Vector();

    	for(int i=0; i<rows.size(); i++){
            row = (Hashtable)rows.get(i);
            sTmpRowId = (String)row.get("Attr_id");
            
            if(!sTmpRowId.equals(sRowId)){
            	newRows.add(row);
            }
            else{
            	Debug.println("Removing row '"+sTmpRowId+"'"); 
            }
    	}
    	
    	this.rows = new Vector();
    	this.rows.addAll(newRows);
    	    	
    	//this.store(sWebLanguage,session);
    }
    
    //--- MOVE ROW --------------------------------------------------------------------------------
    // sDirectionAndStep : usually -1 or 1, but 2 or -3 is possible too
    public void moveRow(String sRowId, int directionAndStep, int userId, String sWebLanguage, HttpSession session){
    	Hashtable specifiedRow = getRow(sRowId);
        if(specifiedRow==null){
            return;
        }

    	Vector newRows = new Vector();
    	String sTmpRowId;
    	Hashtable tmpRow;
    	int specifiedRowIdx = -1;
    	
    	for(int i=0; i<rows.size(); i++){
    		tmpRow = (Hashtable)rows.get(i);
            sTmpRowId = (String)tmpRow.get("Attr_id");
            
            if(!sTmpRowId.equals(sRowId)){
            	newRows.add(tmpRow);
            }
            else{
            	specifiedRowIdx = i; 
            }
    	}

    	int newIdx = specifiedRowIdx-directionAndStep; // minus !
    	if(newIdx > 0 && newIdx<rows.size()){
	    	Debug.println("Moving row '"+sRowId+"' from "+specifiedRowIdx+" to "+newIdx+" ("+directionAndStep+")");
	    	newRows.insertElementAt(specifiedRow,newIdx);
    	}
    	else{
	    	Debug.println("Invalid new index '"+newIdx+"' for row '"+sRowId+"' currently at "+specifiedRowIdx+" ("+directionAndStep+")");
    	}
    	
    	this.rows = new Vector();
    	this.rows.addAll(newRows);
    	    	    	
    	//this.store(sWebLanguage,session);
    }
    
    //--- GET CELL --------------------------------------------------------------------------------
    public Hashtable getCell(String sCellId){
        Hashtable cell = null;
        
        Iterator rowIter = this.rows.iterator();
        Element rowElem, cellElem;
        Hashtable row;
        String sTmpCellId;
        boolean cellFound = false;
        
        //*** 1 - rows ***
        while(rowIter.hasNext() && !cellFound){
            row = (Hashtable)rowIter.next();
            
            //*** 2 - cells ***
            Vector cells = (Vector)row.get("Cells");
            Iterator cellIter = cells.iterator();
            
            while(cellIter.hasNext()){
                cell = (Hashtable)cellIter.next();
                
                sTmpCellId = getCellAttribute(cell,"id");
                if(sTmpCellId.equalsIgnoreCase(sCellId)){
                    cellFound = true;
                    break;
                }
            }
        }        

        if(!cellFound) cell = null;
        return cell;
    }
    
    //--- CONSTRUCT ROWS --------------------------------------------------------------------------
    // generate inner vector of hashtables
    private Vector constructRows(){
        Debug.println("\n**************************** CONSTRUCT ROWS ***************************");
        Debug.println("heightInRows : "+heightInRows);
        Debug.println("widthInCells : "+widthInCells);
        Vector rows = new Vector();
        
        //*** 1 - rows ***
        Hashtable row;
        for(int r=0; r<heightInRows; r++){
            row = new Hashtable();
            row.put("Attr_id","row_"+r);

            //*** 2 - cells ***
            Vector cells = new Vector();
            Hashtable cell; 
            for(int c=0; c<widthInCells; c++){
                cell = new Hashtable();
                cell.put("Attr_id","cell_"+r+"_"+c);
                
                // default attributes (can be overwritten later)
                //cell.put("Attr_width",MedwanQuery.getInstance().getConfigString("defaultCellWidth",(c==0?"admin":"admin2")));
                if(c==0){
                    cell.put("Attr_width",MedwanQuery.getInstance().getConfigString("defaultCellWidth","200"));
                }
                cell.put("Attr_class",MedwanQuery.getInstance().getConfigString("defaultCellClass",(c==0?"admin":"admin2")));
                //cell.put("Attr_colspan",MedwanQuery.getInstance().getConfigString("defaultCellColspan","1"));
                            
                cells.add(cell);
            }
            
            row.put("Cells",cells);
            
            rows.add(row);            
        }
        
        return rows;
    }
    
    //--- EXPAND ROWS -----------------------------------------------------------------------------
    public Vector expandRows(){
        Debug.println("\n****************************** EXPAND ROWS ****************************");
        Debug.println("heightInRows : "+this.heightInRows);
        Debug.println("widthInCells : "+this.widthInCells);
    	
        Vector rows = new Vector();
        
        //*** 1 - rows ***
        Hashtable row = null;;
        for(int r=0; r<heightInRows; r++){
        	String sRowId = "";
        	
        	// respect the actual order
        	if(r<this.rows.size()){
                row = (Hashtable)this.rows.get(r);
                sRowId = ScreenHelper.checkString((String)row.get("Attr_id"));
                row = getRow(sRowId);
        	}
        			
            if(row==null){
            	row = new Hashtable();
            	row.put("Attr_id","row_"+r);
            	sRowId = "cell_"+r;
            }
            
            //*** 2 - cells ***
            Vector cells = new Vector();
            Hashtable cell; 
            for(int c=0; c<widthInCells; c++){
                cell = getCell((sRowId.replaceAll("row","cell"))+"_"+c);
                
                if(cell==null){
                    cell = new Hashtable();
                    cell.put("Attr_id",(sRowId.replaceAll("row","cell"))+"_"+c);
                    
                    // default attributes (can be overwritten later)
                    //cell.put("Attr_width",MedwanQuery.getInstance().getConfigString("defaultCellWidth",(c==0?"admin":"admin2")));
                    if(c==0){
                        cell.put("Attr_width",MedwanQuery.getInstance().getConfigString("defaultCellWidth","200"));
                    }
                    cell.put("Attr_class",MedwanQuery.getInstance().getConfigString("defaultCellClass",(c==0?"admin":"admin2")));
                    //cell.put("Attr_colspan",MedwanQuery.getInstance().getConfigString("defaultCellColspan","1"));                                
                }
                
                cells.add(cell);
            }
            
            row.put("Cells",cells);
            
            rows.add(row);            
        }
    	
        return rows;
    }
    
    //--- PARSE ROWS ------------------------------------------------------------------------------
    // from xml to inner vector of hashtables
    private Vector parseRows(){
        Debug.println("\n****************************** PARSE ROWS *****************************");
        
        if(this.xmlData==null){
            Debug.println("NO XML DATA TO PARSE");
            return new Vector();
        }
        else{
            Debug.println("\nasXML : "+this.xmlData.asXML()+"\n");    
        }
        
        Vector rows = new Vector();
                
        try{
            // parse rows from xml           
            SAXReader reader = new SAXReader(false);
            Element rowsElem = xmlData.getRootElement();
     
            if(rowsElem!=null){  
                Iterator rowsIter = rowsElem.elementIterator("Row");
    
                String sAttributeName, sAttributeValue;
                Element rowElem;
                Hashtable row;
                int rowIdx = 0;
                
                //*** 1 - rows ***
                while(rowsIter.hasNext()){
                    rowElem = (Element)rowsIter.next();
                    row = new Hashtable();
                    row.put("Attr_id","row_"+rowIdx);
                    rowIdx++;

                    // parse row-attributes
                    Iterator attrIter = rowElem.attributeIterator();
                    DefaultAttribute attribute;
                    while(attrIter.hasNext()){
                        attribute = (DefaultAttribute)attrIter.next();
                        
                        sAttributeName = ScreenHelper.checkString(attribute.getName());
                        sAttributeValue = ScreenHelper.checkString(attribute.getValue());
                                                    
                        row.put("Attr_"+sAttributeName,sAttributeValue);
                    }
                    
                    //*** 2 - cells ***
                    Iterator cellIter = rowElem.elementIterator("Cell");
                    Vector cells = new Vector();
                    Element cellElem;
                    Hashtable cell; 
                   
                    int cellIdx = 0;
                    while(cellIter.hasNext()){
                        cellElem = (Element)cellIter.next();                            
                        cell = parseCell(cellElem,rowIdx,cellIdx);
                        cells.add(cell);    
                        cellIdx++;
                        
                        //*** 3 - items ***
                        Element itemsElem = cellElem.element("Items");
                        if(itemsElem!=null){
                            Iterator itemIter = itemsElem.elementIterator("Item");
                            LinkedHashMap items = new LinkedHashMap();
                            Element itemElem;
                            ScreenTransactionItem item; 
                           
                            int itemIdx = 0;
                            while(itemIter.hasNext()){
                                itemElem = (Element)itemIter.next();                            
                                item = parseItem(itemElem,rowIdx,cellIdx,itemIdx);
                                items.put("Item_"+item.getItemTypeId(),item);    
                                itemIdx++;
                            }
                            
                            cell.put("Items",items);
                        }
                    }
                    
                    row.put("Cells",cells);                    
                    rows.add(row);
                }
            }
        }
        catch(Exception e){
            if(Debug.enabled) e.printStackTrace();
            Debug.printProjectErr(e,Thread.currentThread().getStackTrace());
        }
        
        return rows;
    }
    
    //--- PUT ITEM IN CELL (1) --------------------------------------------------------------------
    public void putItemInCell(String sTranTypeId, String sItemTypeId, String sCellId, 
                              String sDefaultValue, String sHtmlElement, Hashtable attributes){        
        ScreenTransactionItem item = new ScreenTransactionItem();
        item.setTransactionTypeId(sTranTypeId);
        item.setItemTypeId(sItemTypeId);
        item.setDefaultValue(sDefaultValue);
        //item.setModifier(modifier);
        
        // extended variables
        item.setCellId(sCellId);
        item.setHtmlElement(sHtmlElement);
        item.addAttributes(attributes);
        
        putItemInCell(item);        
    }

    //--- PUT ITEM IN CELL (2) --------------------------------------------------------------------
    public void putItemInCell(ScreenTransactionItem item){
        Debug.println("\n************************** PUT ITEM IN CELL ***************************");
        Debug.println("getCellId       : "+item.getCellId());
        Debug.println("getTranTypeId   : "+item.getTransactionTypeId());
        Debug.println("getItemTypeId   : "+item.getItemTypeId());
        Debug.println("getDefaultValue : "+item.getDefaultValue());
        Debug.println("getHtmlElement  : "+item.getHtmlElement());
        
        Hashtable cell = getCell(item.getCellId());
        if(cell!=null){
            LinkedHashMap items = (LinkedHashMap)cell.get("Items");
            if(items==null){
                items = new LinkedHashMap();
            }

            items.put("Item_"+item.getItemTypeId(),item);            
            Debug.println("--> items in cell (after) : "+items.size());
            
            cell.put("Items",items);
        }
    }
    
    //--- DISPLAY ITEMS PER CELL (Debug) ----------------------------------------------------------
    private void displayItemsPerCell(){
        Debug.println("\n@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@");
        Debug.println("@@@@@@@@@@@@@@@@@@@ displayItemsPerCell @@@@@@@@@@@@@@@@@@@");
        Debug.println("@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@");

        Iterator rowIter = this.rows.iterator();
        Hashtable row, cell;
        String sRowId, sRowHeight, sCellID, sCellWidth;
        
        //*** 1 - rows ***
        while(rowIter.hasNext()){
            row = (Hashtable)rowIter.next();
            sRowId = (String)row.get("Attr_id");

            //*** 2 - cells ***
            Vector cells = (Vector)row.get("Cells");
            Iterator cellIter = cells.iterator();
            
            while(cellIter.hasNext()){
                cell = (Hashtable)cellIter.next();
                sCellID = getCellAttribute(cell,"id");
                
                //*** 3 - items ***
                LinkedHashMap items = (LinkedHashMap)cell.get("Items");
                if(items!=null){
                    Debug.println("\nCell ("+sCellID+") has "+items.size()+" items");
                    Iterator itemIter = items.keySet().iterator();
                    String key;
                    
                    while(itemIter.hasNext()){
                        key = (String)itemIter.next();
                        ScreenTransactionItem item = (ScreenTransactionItem)items.get(key);

                        Debug.println("item : "+item.getItemTypeId()+" - "+item.getHtmlElement()+" ("+item.getDefaultValue()+")");
                    }
                }
            }
        }
        
        Debug.println("@@@@@@@@@@@@@@@@@@@@@@@@@@ done @@@@@@@@@@@@@@@@@@@@@@@@@@@\n");
    }
    
    //--- SCREEN TO XML ---------------------------------------------------------------------------
    // from inner vector of hashtables to xml
    private Document screenToXML(){        
        Debug.println("\n@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ screenToXML @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@");
        Document document = DocumentHelper.createDocument();
        Element root = document.addElement("Screen");

        // screen attributes
        root.addAttribute("widthInCells",Integer.toString(this.widthInCells));
        root.addAttribute("heightInRows",Integer.toString(this.heightInRows));
        root.addAttribute("creationDate",ScreenHelper.fullDateFormatSS.format(this.creationDate));
        root.addAttribute("updateTime",ScreenHelper.fullDateFormatSS.format(this.updateTime));
                
        Iterator rowIter = this.rows.iterator();
        Hashtable row, cell;
        ScreenTransactionItem item; 
        String key, sRowId, sRowHeight, sCellID, sCellWidth;
        
        //*** 1 - rows ***
        while(rowIter.hasNext()){
            row = (Hashtable)rowIter.next();
            
            // default row-attributes
            sRowId = (String)row.get("Attr_id");

            // element
            Element rowElem = root.addElement("Row");
            rowElem.addAttribute("id",sRowId);

            //*** 2 - cells ***
            Vector cells = (Vector)row.get("Cells");
            Iterator cellIter = cells.iterator();
            
            while(cellIter.hasNext()){
                cell = (Hashtable)cellIter.next();

                sCellID = getCellAttribute(cell,"id");

                // element
                Element cellElem = rowElem.addElement("Cell");
                cellElem.addAttribute("id",sCellID);

                // cell-attributes                
                Enumeration cellAttrEnum = cell.keys();                        
                while(cellAttrEnum.hasMoreElements()){
                    key = (String)cellAttrEnum.nextElement();
                    
                    if(key.startsWith("Attr_")){
                        cellElem.addAttribute(key,ScreenHelper.checkString((String)cell.get(key)));
                    }    
                }
                
                //*** 3 - items ***
                LinkedHashMap items = (LinkedHashMap)cell.get("Items");
                if(items!=null){
                    Iterator itemIter = items.keySet().iterator();
                    
                    // element
                    Element itemsElem = cellElem.addElement("Items");

                    while(itemIter.hasNext()){
                        key = (String)itemIter.next();
                        item = (ScreenTransactionItem)items.get(key);
                        
                        //*** a - to element : item variables ***
                        Element itemElem = itemsElem.addElement("Item");
                        itemElem.addAttribute("transactionTypeId",item.getTransactionTypeId());
                        itemElem.addAttribute("itemTypeId",item.getItemTypeId());
                        itemElem.addAttribute("htmlElement",item.getHtmlElement());
                        itemElem.addAttribute("defaultValue",item.getDefaultValue());
                        itemElem.addAttribute("cellId",item.getCellId());
                        
                        //*** b - to element : item attributes ***
                        Enumeration itemAttrEnum = item.getAttributes().keys();
                        
                        while(itemAttrEnum.hasMoreElements()){
                            key = (String)itemAttrEnum.nextElement();
                            itemElem.addAttribute(key,item.getAttribute(key));
                            
                            if(key.startsWith("Attr_printlabel_")){
                            	Label label = new Label();
                                label.value = item.getAttribute(key);
                                
                                if(label.value.length() > 0){
                                    label.type = "web.occup";
                                    label.id = ScreenHelper.ITEM_PREFIX+"ITEM_TYPE_CUSTOMEXAM_"+sCellID+"_"+item.getItemTypeId();
                                    label.showLink = "1";
                                    label.updateUserId = Integer.toString(this.userID);
                                    
                                    String sLabelLang = key.substring(key.lastIndexOf("_")+1);
                                    label.language = sLabelLang;

                                    if(Debug.enabled){
		                                Debug.println("##################### SAVE LABEL TO DB #####################");
		                                Debug.println("label.lang  = "+label.language);
		                                Debug.println("label.id    = "+label.id);
		                                Debug.println("label.value = "+label.value+"\n");
                                    }
                                    
	                                label.saveToDB();
	                            }
                            }
                        }
                    }
                }
            }            
        }
        
        return document;       
    }
    
    //--- STORE -----------------------------------------------------------------------------------
    public boolean store(String sWebLanguage, HttpSession session){
        Debug.println("\n******************************* STORE *********************************");
        if(this.rows.size()==0){
            rows = constructRows();
        }
        
        // first convert the object to xml
        this.setXmlData(screenToXML());            
                
        boolean errorOccurred = false;
        PreparedStatement ps = null;
        ResultSet rs = null;
        String sSql;
        
        Connection oc_conn = MedwanQuery.getInstance().getOpenclinicConnection();
                
        try{                           
            //*** 1 - INSERT or UPDATE ****************************************
            if(getUid().equals("-1")){
                //*** 2 - REGISTER EXAMINATION and TRANSACTIONITEMS ***********
                // (only when creating screen) 
                registerExamination(sWebLanguage,session); // label is saved here too
                registerExaminationInXML();
                
                // insert new cell-record
                sSql = "INSERT INTO oc_screens (OC_SCREEN_SERVERID,OC_SCREEN_OBJECTID,"+
                       "  OC_SCREEN_TRANSACTIONTYPE,OC_SCREEN_XMLDATA,OC_SCREEN_UPDATETIME,"+
                       "  OC_SCREEN_CREATIONDATE,OC_SCREEN_UPDATEID)"+
                       " VALUES(?,?,?,?,?,?,?)"; // 7
                ps = oc_conn.prepareStatement(sSql);
                
                int serverId = MedwanQuery.getInstance().getConfigInt("serverId"),
                    objectId = MedwanQuery.getInstance().getOpenclinicCounter("OC_SCREENS");
                this.setUid(serverId+"."+objectId);
                
                int psIdx = 1;
                ps.setInt(psIdx++,serverId);
                ps.setInt(psIdx++,objectId);
                ps.setString(psIdx++,transactionType);
                ps.setBytes(psIdx++,convertStringToByteArray(xmlData.asXML()));
                ps.setDate(psIdx++,new java.sql.Date(new java.util.Date().getTime())); // now
                ps.setDate(psIdx++,new java.sql.Date(new java.util.Date().getTime())); // now
                ps.setInt(psIdx,userID);
                
                ps.executeUpdate();
            } 
            else{
            	copyScreenRecordToHistory(getUid());
            	
                // update existing cell-record
                sSql = "UPDATE oc_screens SET"+
                       "  OC_SCREEN_TRANSACTIONTYPE = ?, OC_SCREEN_XMLDATA = ?,"+
                       "  OC_SCREEN_UPDATETIME = ?, OC_SCREEN_UPDATEID = ?"+
                       " WHERE (OC_SCREEN_SERVERID = ? AND OC_SCREEN_OBJECTID = ?)"; // identification
                ps = oc_conn.prepareStatement(sSql);

                int psIdx = 1;
                ps.setString(psIdx++,transactionType);
                ps.setBytes(psIdx++,convertStringToByteArray(xmlData.asXML()));
                ps.setDate(psIdx++,new java.sql.Date(new java.util.Date().getTime())); // now
                ps.setInt(psIdx++,userID);
                
                // where
                ps.setInt(psIdx++,Integer.parseInt(getUid().substring(0,getUid().indexOf("."))));
                ps.setInt(psIdx,Integer.parseInt(getUid().substring(getUid().indexOf(".")+1)));
                
                ps.executeUpdate();
                
                // update name in labels
                updateLabels(session,"examination",this.examId);
                updateLabels(session,"web.occup",ScreenHelper.ITEM_PREFIX+"TRANSACTION_TYPE_CUSTOMEXAMINATION"+this.examId); 
            }  
            
            //*** 3 - register transaction-items in cells *********************
            registerTransactionItems();     
        }
        catch(Exception e){
            errorOccurred = true;
            if(Debug.enabled) e.printStackTrace();
            Debug.printProjectErr(e,Thread.currentThread().getStackTrace());
        }
        finally{
            try{
                if(rs!=null) rs.close();
                if(ps!=null) ps.close();
                oc_conn.close();
            }
            catch(SQLException se){
                Debug.printProjectErr(se,Thread.currentThread().getStackTrace());
            }
        }
        
        return errorOccurred;
    }
    
    //--- COPY SCREEN RECORD TO HISTORY -----------------------------------------------------------
    private void copyScreenRecordToHistory(String sUid){
    	System.out.println("**************** copyScreenRecordToHistory ("+sUid+") ****************"); /////////////////
    	        
        Connection oc_conn = MedwanQuery.getInstance().getOpenclinicConnection();
        PreparedStatement ps = null;
                
        try{
        	//*** 1 : delete other record changed today ***
	        String sSql = "DELETE FROM oc_screens_history"+ 
                          " WHERE (OC_SCREEN_SERVERID = ? AND OC_SCREEN_OBJECTID = ?)"+ // identification
                          "  AND OC_SCREEN_UPDATETIME = ?";
	        ps = oc_conn.prepareStatement(sSql);
	        int psIdx = 1;
	        
            // where
            ps.setInt(psIdx++,Integer.parseInt(getUid().substring(0,getUid().indexOf("."))));
            ps.setInt(psIdx++,Integer.parseInt(getUid().substring(getUid().indexOf(".")+1)));
            ps.setDate(psIdx,new java.sql.Date(new java.util.Date().getTime())); // now
          
            ps.executeUpdate();
            
            //*** 2 : insert ***
	        sSql = "INSERT INTO oc_screens_history"+
                   " SELECT * FROM oc_screens"+
	               "  WHERE (OC_SCREEN_SERVERID = ? AND OC_SCREEN_OBJECTID = ?)"; // identification
	        ps = oc_conn.prepareStatement(sSql);
	        psIdx = 1;
	        
            // where
            ps.setInt(psIdx++,Integer.parseInt(getUid().substring(0,getUid().indexOf("."))));
            ps.setInt(psIdx,Integer.parseInt(getUid().substring(getUid().indexOf(".")+1)));
            
            ps.execute();
	    }
	    catch(Exception e){
	        if(Debug.enabled) e.printStackTrace();
	        Debug.printProjectErr(e,Thread.currentThread().getStackTrace());
	    }
	    finally{
	        try{
	            if(ps!=null) ps.close();
	            oc_conn.close();
	        }
	        catch(SQLException se){
	            Debug.printProjectErr(se,Thread.currentThread().getStackTrace());
	        }
	    }             	
    }
        
    //--- UPDATE LABELS ---------------------------------------------------------------------------
    private void updateLabels(HttpSession session, String sLabelType, String sLabelId){
        // create label object for examination and save it
        Enumeration labelEnum = this.labels.keys();
        String sLabelLang;
        Label label;
        
        while(labelEnum.hasMoreElements()){
            sLabelLang = (String)labelEnum.nextElement();  
            
            label = new Label();
            label.type = sLabelType;
            label.id = sLabelId;
            label.showLink = "1";
            label.updateUserId = Integer.toString(this.userID);
            
            label.value = (String)this.labels.get(sLabelLang);
            label.language = sLabelLang;

            label.saveToDB();
        }
        
        reloadSingleton(session);
    }
            
    //--- DISPLAY ---------------------------------------------------------------------------------
    // design-mode (customExamination.jsp renders the form for real)
    public String display(String sWebLanguage, String sCONTEXTPATH){  
        return display(sWebLanguage,true,sCONTEXTPATH);    
    }
    
    public String display(String sWebLanguage, boolean cellsEditable, String sCONTEXTPATH){  
        if(this.rows.size()==0){
        	this.rows = constructRows();
        }
        else{
            this.rows = expandRows();
        }

        String sNewLineChar = "\n";
        StringBuffer sHtml = new StringBuffer();        
        sHtml.append("<table class='list' width='100%' cellpadding='0' cellspacing='1'>")
             .append(sNewLineChar);
        
        Hashtable row, cell, prevCell;
        Iterator rowAttrKeyIter;
        Enumeration cellAttrEnum;
        String sRowId;

    	/////////////////////////////////
    	for(int i=0; i<this.getRows().size(); i++){
    		Hashtable roww = (Hashtable)this.getRows().get(i);
    	}
    	
        for(int r=0; r<this.rows.size(); r++){
            row = (Hashtable)this.rows.get(r);
            sRowId = ScreenHelper.checkString((String)row.get("Attr_id"));
            sHtml.append("<tr");

            // sort attributes
            Vector rowAttrKeys = new Vector(row.keySet());
            Collections.sort(rowAttrKeys);
            rowAttrKeyIter = rowAttrKeys.iterator(); 
            
            //***** 1 - tr-attributes *****
            String key;
            while(rowAttrKeyIter.hasNext()){
                key = (String)rowAttrKeyIter.next();
                
                if(key.startsWith("Attr_")){
                    sHtml.append(" "+key.substring(key.indexOf("_")+1)+"='"+(String)row.get(key)+"'");
                }
            }
            
            sHtml.append(">"+sNewLineChar);

            // add some utility-icons : delete, moveUp, moveDown
            sHtml.append("<td width='50' class='admin2' style='padding:0 2px 0 2px'>");

            sHtml.append("<img src='"+sCONTEXTPATH+"/_img/icon_delete.gif' class='link'")
                 .append(" alt='"+ScreenHelper.getTranNoLink("web","delete",sWebLanguage)+"'")
                 .append(" onClick=deleteRow('"+sRowId+"')> ");
            
            if(r > 0){
	            sHtml.append("<img src='"+sCONTEXTPATH+"/_img/top.jpg' class='link'")
	                 .append(" alt='"+ScreenHelper.getTranNoLink("web","moveUp",sWebLanguage)+"'")
	                 .append(" onClick=moveRow(1,'"+sRowId+"')> ");
            }
            else{
	            sHtml.append("<span style='width:16px'> </span>");
            }

            if(r < rows.size()-1){
	            sHtml.append("<img src='"+sCONTEXTPATH+"/_img/bottom.jpg' class='link'")
	                 .append(" alt='"+ScreenHelper.getTranNoLink("web","moveDown",sWebLanguage)+"'")
	                 .append(" onClick=moveRow(-1,'"+sRowId+"')> ");
            }
            
            sHtml.append("</td>");
            
            //***** 2 - cells *****
            prevCell = null;
            Vector cells = (Vector)row.get("Cells");
            Iterator cellIter = cells.iterator(); 
            String sCellId;
            
            while(cellIter.hasNext()){  
                cell = (Hashtable)cellIter.next();
                sCellId = getCellAttribute(cell,"id");
                
                // skip cell when previous cell has colspan
                if(prevCell!=null && getColspan(prevCell)>1){
                    continue;                    
                }                

                //*** cell attributes as cell title ***************************
                StringBuffer cellAttributes = new StringBuffer();
                
                cellAttrEnum = cell.keys();
                while(cellAttrEnum.hasMoreElements()){
                    key = (String)cellAttrEnum.nextElement();
                    
                    if(key.startsWith("Attr_")){
                        cellAttributes.append(key.substring(key.indexOf("_")+1)+" = "+(String)cell.get(key)+", ");                                
                    }
                }
                
                // trim-off last separator
                if(cellAttributes.length() > 0){
                    if(cellAttributes.toString().endsWith(", ")){
                        cellAttributes = new StringBuffer(cellAttributes.substring(0,cellAttributes.length()-2));
                    }
                }
                
                sHtml.append("<td");
                if(cellsEditable){
                    sHtml.append(" onDblClick=editCell('"+sCellId+"','"+this.getUid()+"')");
                }
                 
                sHtml.append(" title='CELL: ").append(cellAttributes).append("'");
                
                //*** cell attributes *******************************
                cellAttrEnum = cell.keys();
                while(cellAttrEnum.hasMoreElements()){
                    key = (String)cellAttrEnum.nextElement();
                    
                    if(key.startsWith("Attr_")){
                        sHtml.append(" "+key.substring(key.indexOf("_")+1)+"='"+(String)cell.get(key)+"'");                                
                    }
                }
                
                if(cellsEditable){
                    sHtml.append(" style='cursor:hand'>");
                }
                else{
                    sHtml.append(">");
                }
                
                // list items
                LinkedHashMap items = (LinkedHashMap)cell.get("Items");
                if(items!=null){
                    Iterator itemIter = items.keySet().iterator();
                    ScreenTransactionItem item;

                    while(itemIter.hasNext()){
                        key = (String)itemIter.next();
                        item = (ScreenTransactionItem)items.get(key);

                        //*** label ***
                        if(item.getHtmlElement().equals("label")){
                            String sTran = item.getDefaultValue(); // consider default value as label, if any
                            if(item.getDefaultValue().length()==0){
                                sTran = ScreenHelper.getTran("web",item.getItemTypeId(),sWebLanguage);
                            }
                            
                            sTran = sTran.replaceAll("\"","");
                            sTran = sTran.replaceAll("\\\"","'");
                            sHtml.append(sTran);
                        }
                        //*** text ***
                        else if(item.getHtmlElement().equals("text")){
                            sHtml.append("<input type='text' class='text' maxLength='255'");
                            
                            String sSize = item.getAttribute("Attr_size");
                            if(sSize.length() > 0){
                                sHtml.append(" size='"+sSize+"'");
                            }
                            
                            sHtml.append(" value='"+item.getDefaultValue()+"'>");
                        }
                        //*** text:only-integer ***
                        else if(item.getHtmlElement().equals("integer")){
                            sHtml.append("<input type='text' class='text' maxLength='255'");
                            
                            String sSize = item.getAttribute("Attr_size");
                            if(sSize.length() > 0){
                                sHtml.append(" size='"+sSize+"'");
                            }
                            
                            sHtml.append(" value='"+item.getDefaultValue()+"'")
                                 .append(" onBlur=checkIntegerField(this)>");
                        }
                        //*** date ***
                        else if(item.getHtmlElement().equals("date")){
                            sHtml.append("<input type='text' class='text'")
                            	 .append(" id='item_"+item.getItemTypeId()+"'")
                                 .append(" value='"+item.getDefaultValue()+"'")
                                 .append(" size='11' maxLength='10'")
                                 .append(" onblur='checkDate(this);'")
                                 .append(">");
                            
                            sHtml.append("<script>writeMyDate('item_"+item.getItemTypeId()+"');</script>");
                        }
                        //*** select ***
                        else if(item.getHtmlElement().equals("select")){
                            sHtml.append("<select class='text'>");
                            
                            // add options
                            sHtml.append("<option value=''>").append(ScreenHelper.getTranNoLink("web","choose",sWebLanguage)).append("</option>");
                            sHtml.append(ScreenHelper.writeSelect("CUSTOMEXAMINATION"+this.getExamId()+"."+item.getItemTypeId(),item.getDefaultValue(),sWebLanguage,false,false));
                            
                            sHtml.append("</select>");
                        }
                        //*** textArea ***
                        else if(item.getHtmlElement().equals("textArea")){
                            sHtml.append("<textArea rows='"+item.getAttribute("Attr_rows","3")+"'");
                            
                            String sSize = item.getAttribute("Attr_size");
                            if(sSize.length() > 0){
                                sHtml.append(" cols='"+sSize+"'");
                            }
                            
                            sHtml.append(" class='text' onKeyup='resizeTextarea(this,10);limitChars(this,255)'>")
                                 .append(item.getDefaultValue());
                            
                            sHtml.append("</textArea>");
                        }
                        //*** radio (yes/no) ***
                        else if(item.getHtmlElement().equals("radio")){
                        	// yes
                            sHtml.append("<input type='radio' name='"+item.getItemTypeId()+"' id='radio_"+item.getItemTypeId()+"_yes' style='vertical-align:-2px'")
                                 .append(" value='yes' "+(item.getDefaultValue().equalsIgnoreCase("yes")?"checked":"")+">")
                                 .append("<label for='radio_"+item.getItemTypeId()+"_yes'>"+ScreenHelper.getTran("web","yes",sWebLanguage)+"</label>");

	                        // followedBy
	                        if(item.getAttribute("Attr_followedBy").equals("newline")){
	                            sHtml.append("</br>");
	                        }
	                        else if(item.getAttribute("Attr_followedBy").equals("space")){
	                            sHtml.append(" ");
	                        }
	                        
                            // no
                            sHtml.append("<input type='radio' name='"+item.getItemTypeId()+"' id='radio_"+item.getItemTypeId()+"_no' style='vertical-align:-2px'")
                                 .append(" value='no' "+(item.getDefaultValue().equalsIgnoreCase("no")?"checked":"")+">")
                                 .append("<label for='radio_"+item.getItemTypeId()+"_no'>"+ScreenHelper.getTran("web","no",sWebLanguage)+"</label>");
                        }
                        //*** checkBox ***
                        else if(item.getHtmlElement().equals("checkBox")){
                            sHtml.append("<input type='checkBox' id='cb_"+item.getItemTypeId()+"' style='vertical-align:-2px'")
                                 .append(" value='"+item.getDefaultValue()+"' "+(item.getDefaultValue().equalsIgnoreCase(item.getItemTypeId())?"checked":"")+">")
                                 .append(ScreenHelper.getTran("CUSTOMEXAMINATION"+this.getExamId(),item.getItemTypeId(),sWebLanguage));
                        }
                        
                        // required ? --> asterisk
                        boolean requiredField = ScreenHelper.checkString((String)item.getAttribute("Attr_required")).equalsIgnoreCase("true");
                        if(requiredField){
                        	sHtml.append("<span style='vertical-align:top'> * </span>");
                        }

                        // followedBy
                        if(item.getAttribute("Attr_followedBy").equals("newline")){
                            sHtml.append("</br>");
                        }
                        else if(item.getAttribute("Attr_followedBy").equals("space")){
                            sHtml.append(" ");
                        }
                    }
                }
                else{
                    sHtml.append("<i><font color='#999999'>"+ScreenHelper.getTranNoLink("web","empty",sWebLanguage)+"</font></i>");
                }
                
                sHtml.append("</td>"+sNewLineChar);
                
                prevCell = cell;
            }
            
            //***** 4 - close row *****
            sHtml.append("</tr>"+sNewLineChar);
        }
        
        sHtml.append("</table>"+sNewLineChar);
    	
        return sHtml.toString();
    }
    
    //--- GET COLSPAN -----------------------------------------------------------------------------
    public int getColspan(Hashtable cell){
        int colspan = 1;
        
        String sColspan = ScreenHelper.checkString((String)cell.get("Attr_colspan"));
        if(sColspan.length() > 0){
            colspan = Integer.parseInt(sColspan);
        }
        
        return colspan;
    }


    //#############################################################################################
    //### STATIC ##################################################################################
    //#############################################################################################

    //--- GET -------------------------------------------------------------------------------------
    public static Screen get(Screen screen){
        return get(screen.getUid());
    }    
       
    public static Screen get(String sScreenUID){
        Debug.println("\n************************** GET (sScreenUID:"+sScreenUID+") ****************************");
        Screen screen = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        
        Connection oc_conn = MedwanQuery.getInstance().getOpenclinicConnection();
        
        try{
            String sSql = "SELECT * FROM oc_screens"+
                          " WHERE (OC_SCREEN_SERVERID = ? AND OC_SCREEN_OBJECTID = ?)";
            ps = oc_conn.prepareStatement(sSql);
            ps.setInt(1,Integer.parseInt(sScreenUID.substring(0,sScreenUID.indexOf("."))));
            ps.setInt(2,Integer.parseInt(sScreenUID.substring(sScreenUID.indexOf(".")+1)));

            // execute
            rs = ps.executeQuery();
            if(rs.next()){
                screen = new Screen();
                screen.setUid(rs.getString("OC_SCREEN_SERVERID")+"."+rs.getString("OC_SCREEN_OBJECTID"));

                // xml
                byte[] xmlBytes = rs.getBytes("OC_SCREEN_XMLDATA");
                if(xmlBytes!=null){
                    SAXReader reader = new SAXReader(false);
                    screen.xmlData = reader.read(new StringReader(convertByteArrayToString(xmlBytes)));
                    
                    screen.parseScreenFromXML();
                }
                
                // database-stored attributes
                screen.transactionType = ScreenHelper.checkString(rs.getString("OC_SCREEN_TRANSACTIONTYPE"));
                screen.examId = screen.transactionType.substring((ScreenHelper.ITEM_PREFIX+"TRANSACTION_TYPE_CUSTOMEXAMINATION").length());
                screen.creationDate = rs.getDate("OC_SCREEN_CREATIONDATE");
                
                //*** set labels ***
                // supported languages
                String supportedLanguages = MedwanQuery.getInstance().getConfigString("supportedLanguages");
                if(supportedLanguages.length() == 0) supportedLanguages = "nl,fr";
                supportedLanguages = supportedLanguages.toLowerCase();
                
                // print language selector
                StringTokenizer tokenizer = new StringTokenizer(supportedLanguages,",");
                String sTmpLang, sValue = "";
                
                while(tokenizer.hasMoreTokens()){
                    sTmpLang = tokenizer.nextToken().toUpperCase();
                 
                    if(Integer.parseInt(screen.getExamId()) > -1){
                        screen.addLabel(sTmpLang,ScreenHelper.getTranNoLink("examination",screen.getExamId(),sTmpLang));
                    }
                }                
                                
                // parent
                screen.setUpdateDateTime(rs.getTimestamp("OC_SCREEN_UPDATETIME"));
                screen.setUpdateUser(rs.getString("OC_SCREEN_UPDATEID"));
            }
        }
        catch(Exception e){
            if(Debug.enabled) e.printStackTrace();
            Debug.printProjectErr(e,Thread.currentThread().getStackTrace());
        }
        finally{
            try{
                if(rs!=null) rs.close();
                if(ps!=null) ps.close();
                oc_conn.close();
            }
            catch(SQLException se){
                Debug.printProjectErr(se,Thread.currentThread().getStackTrace());
            }
        }
        
        return screen;
    }
    
    //--- GET BY EXAMID ---------------------------------------------------------------------------
    // examId ~ examType ~ tranType
    public static Screen getByExamId(String sExamId, java.util.Date saveDate){
    	return getByExamId(sExamId,"oc_screens",saveDate);	
    }
    
    public static Screen getByExamId(String sExamId, String sScreensTable, java.util.Date saveDate){
        Debug.println("\n*************************************************************************************");
        Debug.println("******************** GET BY EXAM ID ("+sExamId+", "+sScreensTable+", "+saveDate+") *********************");
        Debug.println("*************************************************************************************");
        Screen screen = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        
        Connection oc_conn = MedwanQuery.getInstance().getOpenclinicConnection();
        
        try{
            String sSql = "SELECT * FROM "+sScreensTable+
                          " WHERE OC_SCREEN_TRANSACTIONTYPE = ?"+
            		      "  AND ? = OC_SCREEN_UPDATETIME"+
                          " ORDER BY OC_SCREEN_UPDATETIME desc"; // most recent version first
            ps = oc_conn.prepareStatement(sSql);
            ps.setString(1,ScreenHelper.ITEM_PREFIX+"TRANSACTION_TYPE_CUSTOMEXAMINATION"+sExamId);
            System.out.println("@@@@@@@@@@@@@@@@@@@@@@@@@@@@ new java.sql.Date(saveDate.getTime()) : "+new java.sql.Date(saveDate.getTime())); ///////////
            ps.setDate(2,new java.sql.Date(saveDate.getTime()));

            // execute
            rs = ps.executeQuery();
            if(rs.next()){                
                screen = new Screen();
                screen.setUid(rs.getString("OC_SCREEN_SERVERID")+"."+rs.getString("OC_SCREEN_OBJECTID"));

                Debug.println("--> Transaction found : "+screen.getUid());

                // xml
                byte[] xmlBytes = rs.getBytes("OC_SCREEN_XMLDATA");
                if(xmlBytes!=null){
                    SAXReader reader = new SAXReader(false);
                    screen.xmlData = reader.read(new StringReader(convertByteArrayToString(xmlBytes)));
                    
                    screen.parseScreenFromXML();
                }
                
                // database-stored attributes
                screen.transactionType = ScreenHelper.checkString(rs.getString("OC_SCREEN_TRANSACTIONTYPE"));
                screen.examId = screen.transactionType.substring((ScreenHelper.ITEM_PREFIX+"TRANSACTION_TYPE_CUSTOMEXAMINATION").length());
                screen.creationDate = rs.getDate("OC_SCREEN_CREATIONDATE");

                //*** set labels ***
                // supported languages
                String supportedLanguages = MedwanQuery.getInstance().getConfigString("supportedLanguages");
                if(supportedLanguages.length() == 0) supportedLanguages = "nl,fr";
                supportedLanguages = supportedLanguages.toLowerCase();
                
                // print language selector
                StringTokenizer tokenizer = new StringTokenizer(supportedLanguages,",");
                String sTmpLang, sValue = "";
                
                while(tokenizer.hasMoreTokens()){
                    sTmpLang = tokenizer.nextToken().toUpperCase();
                 
                    if(Integer.parseInt(screen.getExamId()) > -1){
                        screen.addLabel(sTmpLang,ScreenHelper.getTranNoLink("examination",screen.getExamId(),sTmpLang));
                    }
                }               
                                
                // parent
                screen.setUpdateDateTime(rs.getTimestamp("OC_SCREEN_UPDATETIME"));
                screen.setUpdateUser(rs.getString("OC_SCREEN_UPDATEID"));
            }
            else{
            	if(sScreensTable.equalsIgnoreCase("oc_screens")){
	            	// search in history
	            	screen = getByExamId(sExamId,"oc_screens_history",saveDate);
            	}
            	else{
                    Debug.println("--> Transaction not found");            		
            	}
            }
        }
        catch(Exception e){
            if(Debug.enabled) e.printStackTrace();
            Debug.printProjectErr(e,Thread.currentThread().getStackTrace());
        }
        finally{
            try{
                if(rs!=null) rs.close();
                if(ps!=null) ps.close();
                oc_conn.close();
            }
            catch(SQLException se){
                Debug.printProjectErr(se,Thread.currentThread().getStackTrace());
            }
        }
        
        return screen;
    }
    
    //--- GET LIST --------------------------------------------------------------------------------
    public static List<Screen> getList(){
        return getList(true);
    }
    
    public static List<Screen> getList(boolean parseRowsToo){
        return getList(new Screen(),parseRowsToo);         
    }
    
    public static List<Screen> getList(Screen findItem, boolean parseRowsToo){
        List<Screen> foundObjects = new LinkedList();
        PreparedStatement ps = null;
        ResultSet rs = null;
        
        Connection oc_conn = MedwanQuery.getInstance().getOpenclinicConnection();
        
        try{
            // compose query
            String sSql = "SELECT * FROM oc_screens WHERE 1=1"; // 'where' facilitates further composition of query

            if(findItem.userID > 0){
                sSql+= " AND OC_SCREEN_UPDATEID = '"+findItem.userID+"'";
            }        
                            
            sSql+= " ORDER BY OC_SCREEN_CREATIONDATE ASC";
            
            ps = oc_conn.prepareStatement(sSql);

            // execute query
            rs = ps.executeQuery();
            Screen screen;
            
            while(rs.next()){
                screen = new Screen();
                screen.setUid(rs.getString("OC_SCREEN_SERVERID")+"."+rs.getString("OC_SCREEN_OBJECTID"));

                // xml
                byte[] xmlBytes = rs.getBytes("OC_SCREEN_XMLDATA");
                if(xmlBytes!=null){
                    SAXReader reader = new SAXReader(false);
                    screen.xmlData = reader.read(new StringReader(convertByteArrayToString(xmlBytes)));
                    
                    screen.parseScreenFromXML(parseRowsToo);
                }
                
                // database-stored attributes
                screen.transactionType = ScreenHelper.checkString(rs.getString("OC_SCREEN_TRANSACTIONTYPE"));
                screen.examId = screen.transactionType.substring((ScreenHelper.ITEM_PREFIX+"TRANSACTION_TYPE_CUSTOMEXAMINATION").length());
                screen.creationDate = rs.getDate("OC_SCREEN_CREATIONDATE");

                //*** set labels ***
                // supported languages
                String supportedLanguages = MedwanQuery.getInstance().getConfigString("supportedLanguages");
                if(supportedLanguages.length() == 0) supportedLanguages = "nl,fr";
                supportedLanguages = supportedLanguages.toLowerCase();
                
                // print language selector
                StringTokenizer tokenizer = new StringTokenizer(supportedLanguages,",");
                String sTmpLang, sValue = "";
                
                while(tokenizer.hasMoreTokens()){
                    sTmpLang = tokenizer.nextToken().toUpperCase();
                 
                    if(Integer.parseInt(screen.getExamId()) > -1){
                        screen.addLabel(sTmpLang,ScreenHelper.getTranNoLink("examination",screen.getExamId(),sTmpLang));
                    }
                }                  
                                                
                // parent
                screen.setUpdateDateTime(rs.getTimestamp("OC_SCREEN_UPDATETIME"));
                screen.setUpdateUser(rs.getString("OC_SCREEN_UPDATEID"));
                
                foundObjects.add(screen);
            }
        }
        catch(Exception e){
            if(Debug.enabled) e.printStackTrace();
            Debug.printProjectErr(e,Thread.currentThread().getStackTrace());
        }
        finally{
            try{
                if(rs!=null) rs.close();
                if(ps!=null) ps.close();
                oc_conn.close();
            }
            catch(SQLException se){
                Debug.printProjectErr(se,Thread.currentThread().getStackTrace());
            }
        }
        
        return foundObjects;
    }
    
    //--- DELETE ----------------------------------------------------------------------------------
    public boolean delete(String sScreenUID, String sExamId, int userId){
        boolean errorOccurred = false;
        PreparedStatement ps = null;
        ResultSet rs = null;
        
        Connection oc_conn = MedwanQuery.getInstance().getOpenclinicConnection();
        
        try{
            //*** 1 - DELETE SCREEN *******************************************
            String sSql = "DELETE FROM oc_screens"+
                          " WHERE (OC_SCREEN_SERVERID = ? AND OC_SCREEN_OBJECTID = ?)";
            ps = oc_conn.prepareStatement(sSql);
            ps.setInt(1,Integer.parseInt(sScreenUID.substring(0,sScreenUID.indexOf("."))));
            ps.setInt(2,Integer.parseInt(sScreenUID.substring(sScreenUID.indexOf(".")+1)));            
            ps.executeUpdate();
            
            //*** 1b - DELETE SCREEN HISTORY **********************************
            sSql = "DELETE FROM oc_screens_history"+
                   " WHERE (OC_SCREEN_SERVERID = ? AND OC_SCREEN_OBJECTID = ?)";
            ps = oc_conn.prepareStatement(sSql);
            ps.setInt(1,Integer.parseInt(sScreenUID.substring(0,sScreenUID.indexOf("."))));
            ps.setInt(2,Integer.parseInt(sScreenUID.substring(sScreenUID.indexOf(".")+1)));            
            ps.executeUpdate();
                        
            //*** 2 - UN-REGISTER EXAMINATION and TRANSACTIONITEMS ************
            unregisterExamination(sExamId,userId); // in database
            boolean examFound = unregisterExaminationInXML(sExamId); // in xml
            if(examFound){
                unregisterTransactionItems();
            }
            
            //*** 3 - DELETE LABELS *******************************************
            sSql = "DELETE FROM oc_labels"+
                   " WHERE (OC_LABEL_TYPE = ? AND OC_LABEL_ID = ?)";
            ps = oc_conn.prepareStatement(sSql);
            ps.setString(1,"examination");
            ps.setString(2,this.examId);                        
            ps.executeUpdate();
             
            sSql = "DELETE FROM oc_labels"+
                   " WHERE (OC_LABEL_TYPE = ? AND OC_LABEL_ID = ?)";
            ps = oc_conn.prepareStatement(sSql);
            ps.setString(1,"web.occup");
            ps.setString(2,this.examId);                        
            ps.executeUpdate();
        }
        catch(Exception e){
            errorOccurred = true;
            if(Debug.enabled) e.printStackTrace();
            Debug.printProjectErr(e,Thread.currentThread().getStackTrace());
        }
        finally{
            try{
                if(rs!=null) rs.close();
                if(ps!=null) ps.close();
                oc_conn.close();
            }
            catch(SQLException se){
                Debug.printProjectErr(se,Thread.currentThread().getStackTrace());
            }
        }
        
        return errorOccurred;
    }   
    
    //--- REGISTER EXAMINATION --------------------------------------------------------------------
    // each screen represents an examination (transaction)
    // add record to database
    private String registerExamination(String sWebLanguage, HttpSession session){
        boolean bQueryInsert = false;
        String msg, sExamID = "-1";
        
        boolean examinationWithSameNameExists = Label.existsBasedOnName("examination",this.examId,sWebLanguage),
                examinationWithSameTypeExists = (Examination.getByType(this.transactionType)!=null);

        if(!examinationWithSameNameExists && !examinationWithSameTypeExists){
            sExamID = MedwanQuery.getInstance().getOpenclinicCounter("ExaminationID")+"";
            this.examId = sExamID;
            this.transactionType = ScreenHelper.ITEM_PREFIX+"TRANSACTION_TYPE_CUSTOMEXAMINATION"+sExamID;
            bQueryInsert = true;
            msg = ScreenHelper.getTranNoLink("web.manage","examinationadded",sWebLanguage);

            //*** create labels for examination and save them (examination + web.occup) ***
            updateLabels(session,"examination",this.examId);
            updateLabels(session,"web.occup",ScreenHelper.ITEM_PREFIX+"TRANSACTION_TYPE_CUSTOMEXAMINATION"+this.examId);            
        }
        else{
            if(examinationWithSameTypeExists){
                msg = "<font color='red'>"+ScreenHelper.getTranNoLink("web.manage","examinationOfSameTypeExists",sWebLanguage)+"</script>";
            }
            else{
                msg = "<font color='red'>"+ScreenHelper.getTranNoLink("web.manage","examinationWithSameNameExists",sWebLanguage)+"</script>";
            }
        }

        // add examination
        if(bQueryInsert){
            Examination exam = new Examination();

            exam.setUpdatetime(ScreenHelper.getSQLTime());
            exam.setUpdateuserid(this.userID);
            byte[] dataBytes = convertStringToByteArray(this.xmlData.asXML());
            exam.setData(dataBytes.length > 0?dataBytes:null);
            exam.setPriority(Integer.parseInt("999")); // todo
            exam.setTransactionType(this.transactionType);
            exam.setId(Integer.parseInt(sExamID));
            
            Examination.addExamination(exam);
        }
        
        return msg;
    }
    
    //--- REGISTER EXAMINATION IN XML -------------------------------------------------------------
    // examinations.xml
    /*
        <?xml version="1.0" encoding="UTF-8"?>
        <Examinations>
            <Row>
                <id>1001</id>
                <creationDate></creationDate>
                <userId></userId>
                <class>imaging</class>
                <transactiontype>be.mxs.common.model.vo.healthrecord.IConstants.TRANSACTION_TYPE_MIR2</transactiontype>
                <fr>Imagerie m&#233;dicale</fr>
                <en>Medical imaging</en>
            </Row>
        </Examinations>
    */
    private void registerExaminationInXML(){
        Debug.println("\n*******************************************************************");
        Debug.println("********************* registerExaminationInXml ********************");
        Debug.println("*******************************************************************");
        
        try{
            SAXReader xmlReader = new SAXReader();
            String sMenuXML = MedwanQuery.getInstance().getConfigString("examinationsXMLFile","examinations.xml");
            String sMenuXMLUrl = MedwanQuery.getInstance().getConfigString("templateSource")+sMenuXML;
            
            // Check if menu file exists, else use file at templateSource location.
            Debug.println("Reading XML : "+sMenuXMLUrl);
            Document document = xmlReader.read(new URL(sMenuXMLUrl));
            if(document!=null){
                Element root = document.getRootElement();
                
                if(root!=null){                    
                    Element rowElem = (Element)root.addElement("Row");

                    //*** childs ***
                    // add 'id'
                    Element tmpElem = rowElem.addElement("id");
                    tmpElem.setText(this.examId);                    
                    
                    // add 'creationDate'
                    tmpElem = rowElem.addElement("creationDate");
                    tmpElem.setText(ScreenHelper.euDateFormat.format(new java.util.Date()));

                    // add 'userId'
                    tmpElem = rowElem.addElement("userId");
                    tmpElem.setText(Integer.toString(this.userID));
                    
                    // add 'class'
                    tmpElem = rowElem.addElement("class");
                    tmpElem.setText("customExamination");
                    
                    // add 'transactionType'
                    tmpElem = rowElem.addElement("transactiontype");
                    tmpElem.setText(this.transactionType);              
                                        
                    //*** labels (when applicable) ***
                    if(Label.get("examination",this.examId,"fr")!=null){
                        tmpElem = rowElem.addElement("fr");
                        tmpElem.setText(ScreenHelper.getTranNoLink("examination",this.examId,"fr"));
                    }
                    if(Label.get("examination",this.examId,"en")!=null){
                        tmpElem = rowElem.addElement("en");
                        tmpElem.setText(ScreenHelper.getTranNoLink("examination",this.examId,"en"));
                    }
                    if(Label.get("examination",this.examId,"es")!=null){
                        tmpElem = rowElem.addElement("es");
                        tmpElem.setText(ScreenHelper.getTranNoLink("examination",this.examId,"es"));
                    }
                    if(Label.get("examination",this.examId,"nl")!=null){
                        tmpElem = rowElem.addElement("nl");
                        tmpElem.setText(ScreenHelper.getTranNoLink("examination",this.examId,"nl"));
                    }
                    if(Label.get("examination",this.examId,"pt")!=null){
                        tmpElem = rowElem.addElement("pt");
                        tmpElem.setText(ScreenHelper.getTranNoLink("examination",this.examId,"pt"));
                    }

                    //*** write document to xml-file ***
                    String sMenuXMLUri = MedwanQuery.getInstance().getConfigString("templateDirectory")+"/"+sMenuXML;
                    
                    BufferedWriter fileWriter = new BufferedWriter(new OutputStreamWriter(new FileOutputStream(new File(sMenuXMLUri)),"UTF-8"));
                    OutputFormat format = OutputFormat.createPrettyPrint();                             
                    XMLWriter writer = new XMLWriter(fileWriter,format);
                    writer.write(document);
                    
                    Debug.println("\n"+document.asXML()+"\n");
                    writer.close();
                    fileWriter.close();
                    
                    Debug.println(" ---> Examination (id:"+this.examId+") added to 'examinations.xml'");
                }
            }
        }
        catch(Exception e){
            e.printStackTrace();
        }
                
        // update examinations-table and labels, based on examinations.xml
        UpdateSystem.updateExaminations();
    }
    
    //--- UNREGISTER EXAMINATION ------------------------------------------------------------------
    // delete record from database
    private void unregisterExamination(String sExamId, int userId){        
        // mark examination as deleted
        Examination exam = new Examination();
        exam.setDeletedate(ScreenHelper.getSQLTime());
        exam.setUpdatetime(ScreenHelper.getSQLTime());
        exam.setUpdateuserid(userId);
        exam.setId(Integer.parseInt(sExamId));

        Examination.deleteExamination(exam);

        // remove labels
        /*
        // supported languages
        String supportedLanguages = MedwanQuery.getInstance().getConfigString("supportedLanguages");
        if(supportedLanguages.length() == 0) supportedLanguages = "nl,fr";
        supportedLanguages = supportedLanguages.toLowerCase();
        
        // print language selector
        StringTokenizer tokenizer = new StringTokenizer(supportedLanguages,",");
        String sTmpLang, sValue = "";
        
        while(tokenizer.hasMoreTokens()){
            sTmpLang = tokenizer.nextToken().toUpperCase();
            Label.delete("examination",sExamId,sTmpLang);
            Label.delete("web.occup",ScreenHelper.ITEM_PREFIX+"TRANSACTION_TYPE_CUSTOMEXAMINATION"+sExamId,sTmpLang);
        }    
        */
    }
    
    //--- UNREGISTER EXAMINATION IN XML -------------------------------------------------------------
    // examinations.xml
    private boolean unregisterExaminationInXML(String sExamId){
        Debug.println("\n************* unregisterExaminationInXml ("+sExamId+") ***********");
        boolean examFound = false;

        try{
            SAXReader xmlReader = new SAXReader();
            String sMenuXML = MedwanQuery.getInstance().getConfigString("examinationsXMLFile","examinations.xml");
            String sMenuXMLUrl = MedwanQuery.getInstance().getConfigString("templateSource")+sMenuXML;
            
            // Check if menu file exists, else use file at templateSource location.
            Debug.println("Reading XML : "+sMenuXMLUrl);
            Document document = xmlReader.read(new URL(sMenuXMLUrl));
            if(document!=null){
                Element root = document.getRootElement();
                if(root!=null){
                    Element rowElem, idElem;
    
                    Iterator rowElems = root.elementIterator("Row");
                    while(rowElems.hasNext() && !examFound){
                        rowElem = (Element)rowElems.next();
                                   
                        if(rowElem.elementText("id").equalsIgnoreCase(sExamId)){
                            root.remove(rowElem);
                            examFound = true;
                                                        
                            // write document to xml-file
                            String sMenuXMLUri = MedwanQuery.getInstance().getConfigString("templateDirectory")+"/"+sMenuXML;
                            
                            BufferedWriter fileWriter = new BufferedWriter(new OutputStreamWriter(new FileOutputStream(new File(sMenuXMLUri)),"UTF-8"));
                            OutputFormat format = OutputFormat.createPrettyPrint();                             
                            XMLWriter writer = new XMLWriter(fileWriter,format);
                            writer.write(document);
                            
                            Debug.println("\n"+document.asXML()+"\n");
                            writer.close();
                            fileWriter.close();
                            
                            Debug.println(" ---> Examination (id:"+this.examId+") removed from 'examinations.xml'");
                        }
                    }
                }
            }    
        }
        catch(Exception e){
            e.printStackTrace();
        }        

        // update examinations-table and labels, based on examinations.xml
        UpdateSystem.updateExaminations();
        
        return examFound;
    }
    
    //--- REGISTER TRANSACTIONITEMS ---------------------------------------------------------------
    // each cell represents a transaction-item
    private void registerTransactionItems(){
        //*** 1 - rows ***
        Iterator rowIter = this.rows.iterator();
        Hashtable row, cell;
        String sCellID;
        
        while(rowIter.hasNext()){
            row = (Hashtable)rowIter.next();

            //*** 2 - cells ***
            if(row.get("Cells")!=null){
                Vector cells = (Vector)row.get("Cells");
                Iterator cellIter = cells.iterator();
                 
                while(cellIter.hasNext()){
                    cell = (Hashtable)cellIter.next();
                    sCellID = getCellAttribute(cell,"id");

                    //*** 3 - items ***
                    LinkedHashMap items = (LinkedHashMap)cell.get("Items");
                    if(items!=null){
                        Iterator itemIter = items.keySet().iterator();
                        TransactionItem item; 
                        String key;
                        
                        while(itemIter.hasNext()){
                            key = (String)itemIter.next();
                            item = (TransactionItem)items.get(key);
                            
                            registerTransactionItem(this.transactionType,ScreenHelper.ITEM_PREFIX+"ITEM_TYPE_CUSTOMEXAM_"+sCellID+"_"+item.getItemTypeId(),item.getDefaultValue());
                        }
                    }
                 }
            }
        }        
    }
        
    //--- REGISTER TRANSACTION ITEM ---------------------------------------------------------------
    private void registerTransactionItem(String sTranTypeId, String sItemTypeId, String sDefaultValue){
        boolean bExists = false;
        bExists = TransactionItem.exists(sTranTypeId,sItemTypeId);

        if(!bExists){
            TransactionItem tranItem = new TransactionItem();
            tranItem.setTransactionTypeId(sTranTypeId);
            tranItem.setItemTypeId(sItemTypeId);
            tranItem.setDefaultValue(sDefaultValue);
            //tranItem.setModifier(modifier);

            TransactionItem.addTransactionItem(tranItem);
        }
    }
    
    //--- UN-REGISTER TRANSACTIONITEMS ------------------------------------------------------------
    // each cell represents a transaction-item
    private void unregisterTransactionItems(){
        Iterator rowIter = this.rows.iterator();
        Hashtable row, cell;
        String sCellID;
        
        while(rowIter.hasNext()){
            row = (Hashtable)rowIter.next();

            if(row.get("Cells")!=null){
                Vector cells = (Vector)row.get("Cells");
                Iterator cellIter = cells.iterator();
                 
                 while(cellIter.hasNext()){
                     cell = (Hashtable)cellIter.next();
                     sCellID = getCellAttribute(cell,"id");
                     
                     // items
                     LinkedHashMap items = (LinkedHashMap)cell.get("Items");
                     if(items!=null){
                         Iterator itemIter = items.keySet().iterator();
                         ScreenTransactionItem item;
                         String key;
                         
                         while(itemIter.hasNext()){
                            key = (String)itemIter.next();
                            item = (ScreenTransactionItem)items.get(key);
                              
                            unregisterTransactionItem(item.getTransactionTypeId(),ScreenHelper.ITEM_PREFIX+"ITEM_TYPE_CUSTOMEXAM_"+sCellID+"_"+item.getItemTypeId());    
                         }
                     }
                 }
            }
        }        
    }
    
    //--- UN-REGISTER TRANSACTION ITEM ------------------------------------------------------------
    private void unregisterTransactionItem(String sTranTypeId, String sItemTypeId){
        Debug.println("\n********************** unregisterTransactionItem **********************");
        Debug.println("sTranTypeId : "+sTranTypeId);
        Debug.println("sItemTypeId : "+sItemTypeId);
            
        if(TransactionItem.exists(sTranTypeId,sItemTypeId)){
            TransactionItem.deleteTransactionItem(sTranTypeId,sItemTypeId);
            Debug.println("--> unregistered transaction item : "+sTranTypeId+", "+sItemTypeId);
        }
    }


    //#############################################################################################
    //### PRIVATE #################################################################################
    //#############################################################################################

    //--- RELOAD SINGLETON ------------------------------------------------------------------------
    private static void reloadSingleton(HttpSession session){
        Hashtable labelLanguages = new Hashtable();
        Hashtable labelTypes = new Hashtable();
        Hashtable labelIds;
        net.admin.Label label;

        // only load labels in memory that are service nor function.
        Vector vLabels = net.admin.Label.getNonServiceFunctionLabels();
        Iterator iter = vLabels.iterator();

        Debug.println("About to (re)load labels.");
        
        while(iter.hasNext()){
            label = (net.admin.Label)iter.next();
            
            // type
            labelTypes = (Hashtable)labelLanguages.get(label.language);
            if(labelTypes==null){
                labelTypes = new Hashtable();
                labelLanguages.put(label.language,labelTypes);
            }

            // id
            labelIds = (Hashtable)labelTypes.get(label.type);
            if(labelIds==null){
                labelIds = new Hashtable();
                labelTypes.put(label.type,labelIds);
            }

            labelIds.put(label.id,label);
        }

        // status info
        if(Debug.enabled){
            Debug.println("Labels (re)loaded.");

            Debug.println(" * "+labelLanguages.size()+" languages");
            Debug.println(" * "+labelTypes.size()+" types per language");
        }

        MedwanQuery.getInstance().putLabels(labelLanguages);
    }
    
    //--- PARSE SCREEN FROM XML -------------------------------------------------------------------
    private void parseScreenFromXML(){  
        parseScreenFromXML(true);
    }
    
    private void parseScreenFromXML(boolean parseRowsToo){        
        Element screenElem = this.xmlData.getRootElement();
        
        //*** 1 - parse screen-attributes *****************
        Iterator attrIter = screenElem.attributeIterator();
        String sAttributeName, sAttributeValue;
        DefaultAttribute attribute;
        Element attrElem;
        
        while(attrIter.hasNext()){
            attribute = (DefaultAttribute)attrIter.next();

            sAttributeName = ScreenHelper.checkString(attribute.getName());
            
            if(sAttributeName.equals("widthInCells")){
                sAttributeValue = ScreenHelper.checkString(attribute.getValue());
                if(sAttributeValue.length() > 0){
                    this.widthInCells = Integer.parseInt(sAttributeValue);
                }
            } 
            
            if(sAttributeName.equals("heightInRows")){
                sAttributeValue = ScreenHelper.checkString(attribute.getValue());
                if(sAttributeValue.length() > 0){
                    this.heightInRows = Integer.parseInt(sAttributeValue);
                }
            }
            
            //*** labels ***
            
        }
        
        //*** 2 - parse rows (and cells, and items) *******
        if(parseRowsToo){
            this.rows = parseRows();
        }
    }
    
    //--- PARSE CELL ------------------------------------------------------------------------------
    private Hashtable parseCell(Element cellElem, int rowIdx, int cellIdx){
        Hashtable cell = new Hashtable();
        cell.put("Attr_id","cell_"+rowIdx+"_"+cellIdx);
                
        // cell-attributes
        Iterator attrIter = cellElem.attributeIterator();
        String sAttributeName, sAttributeValue;
        DefaultAttribute attribute;
        
        while(attrIter.hasNext()){
            attribute = (DefaultAttribute)attrIter.next();

            sAttributeName = ScreenHelper.checkString(attribute.getName());
            sAttributeValue = ScreenHelper.checkString(attribute.getValue());
            
            cell.put(sAttributeName,sAttributeValue);
        }
        
        return cell;
    }
    
    //--- PARSE ITEM ------------------------------------------------------------------------------
    private ScreenTransactionItem parseItem(Element itemElem, int rowIdx, int cellIdx, int itemIdx){
        Debug.println("\n***************** parseItem ("+rowIdx+"."+cellIdx+"."+itemIdx+") *******************");
        Debug.println("itemElem.asXML : "+itemElem.asXML());
        ScreenTransactionItem item = new ScreenTransactionItem();
        
        // item-attributes
        Iterator attrIter = itemElem.attributeIterator();
        String sAttributeName, sAttributeValue;
        DefaultAttribute attribute;
        
        while(attrIter.hasNext()){
            attribute = (DefaultAttribute)attrIter.next();

            sAttributeName = ScreenHelper.checkString(attribute.getName());
            sAttributeValue = ScreenHelper.checkString(attribute.getValue());
            Debug.println("sAttributeName : "+sAttributeName+" = "+sAttributeValue);

            //*** 1 - to variables ***
            if(sAttributeName.equalsIgnoreCase("transactionTypeId")){
                item.setTransactionTypeId(sAttributeValue);
            }
            else if(sAttributeName.equalsIgnoreCase("itemTypeId")){
                item.setItemTypeId(sAttributeValue);
            }
            else if(sAttributeName.equalsIgnoreCase("defaultValue")){
                item.setDefaultValue(sAttributeValue);
            }
            else if(sAttributeName.equalsIgnoreCase("htmlElement")){
                item.setHtmlElement(sAttributeValue);
            }    
            else if(sAttributeName.equalsIgnoreCase("cellId")){
                item.setCellId(sAttributeValue);
            }           
            //*** 2 - to attributes hash ***
            // like : required
            else{
                item.addAttribute(sAttributeName,sAttributeValue);
            }
        }
        
        return item;
    }
    
    //--- CONVERT BYTE ARRAY TO STRING ------------------------------------------------------------
    // Represent each byte as a 3 chars and append them to a large String.
    //---------------------------------------------------------------------------------------------
    private static String convertByteArrayToString(byte[] byteArray){
        return new String(byteArray);
    }

    //--- CONVERT STRING TO BYTE ARRAY ------------------------------------------------------------
    // Represent each 3 chars in a String as a byte.
    //---------------------------------------------------------------------------------------------
    private static byte[] convertStringToByteArray(String sStringToConvert){
        return sStringToConvert.getBytes();
    }
    
}
