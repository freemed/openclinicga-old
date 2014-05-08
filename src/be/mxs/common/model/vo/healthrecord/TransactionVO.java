package be.mxs.common.model.vo.healthrecord;

import be.dpms.medwan.common.model.vo.administration.PersonVO;
import be.dpms.medwan.common.model.vo.authentication.UserVO;
import be.mxs.common.model.vo.IIdentifiable;
import be.mxs.common.util.db.MedwanQuery;
import be.mxs.common.util.system.Debug;
import be.mxs.common.util.system.ScreenHelper;
import be.openclinic.adt.Encounter;
import be.openclinic.common.IObjectReference;
import be.openclinic.common.ObjectReference;
import be.openclinic.finance.Prestation;
import org.dom4j.Element;

import java.io.Serializable;
import java.text.SimpleDateFormat;
import java.util.*;

public class TransactionVO extends IObjectReference implements Serializable, IIdentifiable {
    private int healthrecordId;
    private Integer transactionId;
    private String transactionType;
    private Date creationDate;
    private Date updateTime;
    private int status;
    public UserVO user;
    private Collection items;
    private int serverId;
    private int version;
    private int versionserverid;
    private Date timestamp;
    private SimpleDateFormat extDateFormat = ScreenHelper.fullDateFormatSS;

    
    //--- CONSTRUCTOR 1 ---------------------------------------------------------------------------
    public TransactionVO(Integer transactionId, String transactionType, Date creationDate, Date updateTime,
    		             int status, UserVO user, Collection itemsVO, int serverid, int version,
    		             int versionserverid, Date timestamp) {
        this.transactionId = transactionId;
        this.transactionType = transactionType;
        this.creationDate = creationDate;
        this.updateTime = updateTime;
        this.status = status;
        this.user = user;
        this.items = itemsVO;
        this.serverId = serverid;
        this.version = version;
        this.versionserverid = versionserverid;
        this.timestamp = timestamp;
    }

    //--- CONSTRUCTOR 2 ---------------------------------------------------------------------------
    public TransactionVO(Integer transactionId, String transactionType, Date creationDate, Date updateTime, 
    		             int status, UserVO user, Collection itemsVO) {
        this.transactionId = transactionId;
        this.transactionType = transactionType;
        this.creationDate = creationDate;
        this.updateTime = updateTime;
        this.status = status;
        this.user = user;
        this.items = itemsVO;
        this.serverId = MedwanQuery.getInstance().getConfigInt("serverId");
        this.version = 1;
        this.versionserverid = this.serverId;
        this.timestamp = new Date();
        //Debug.println("New serverId="+this.serverId);
    }
    
    public String getObjectType(){
        return "Transaction";
    }

    public String getObjectUid(){
        return getServerId()+"."+getTransactionId();
    }

    public int getHealthrecordId() {
        return healthrecordId;
    }

    public void setHealthrecordId(int healthrecordId) {
        this.healthrecordId = healthrecordId;
    }

    public int getServerId() {
        return serverId;
    }

    public int getVersion() {
        return version;
    }

    public int getVersionserverId() {
        return versionserverid;
    }

    public void setServerId(int serverid) {
        this.serverId = serverid;
    }

    public void setVersion(int version) {
        this.version = version;
    }

    public void setVersionServerId(int versionserverid) {
        this.versionserverid = versionserverid;
    }

    public Integer getTransactionId() {
        return transactionId;
    }

    public String getTransactionType() {
        return transactionType;
    }

    public Date getTimestamp() {
        return creationDate;
    }

    public Date getCreationDate() {
        return creationDate;
    }

    public Date getUpdateTime() {
        return updateTime;
    }

    public int getStatus() {
        return status;
    }

    public UserVO getUser() {
        return user;
    }

    public Collection getItems() {
        return items;
    }

    public void setTransactionId(Integer transactionId) {
        this.transactionId = transactionId;
    }

    public void setTransactionType(String transactionType) {
        this.transactionType = transactionType;
    }

    public void setTimestamp(Date timestamp) {
        this.timestamp = timestamp;
    }

    public void setCreationDate(Date creationDate) {
        this.creationDate = creationDate;
    }
    
    //--- CONVERT ITEMS TO EU DATE ----------------------------------------------------------------
    public void convertItemsToEUDate(){
    	System.out.println("================================================="); //////////////////
    	System.out.println("============ CONVERTING ITEM-VALUES ============="); //////////////////
    	System.out.println("================================================="); //////////////////
    	Vector baseItemNames = this.getBaseItemNames();
    	String sBaseItemType;
    	ItemVO item;

		Debug.println("baseItemNames.size() : "+baseItemNames.size()); ////////
    	for(int i=0; i<baseItemNames.size(); i++){
    		sBaseItemType = (String)baseItemNames.get(i);
    		Debug.println("sBaseItemType : "+sBaseItemType); ////////
        	item = getItem(sBaseItemType);	
        	
        	// when the value _is_ a date
        	if(item.isDateItem()){
        		// convert to EU dateformat ANYWAY
        		item.setValue(ScreenHelper.convertToEUDate(item.getValue()));
        	}
        	else{
	        	String sItemValue = getItemSeriesValue(sBaseItemType);
	        	
	        	if(containsDateValue(sItemValue)){
                    item.setValue(ScreenHelper.convertToEUDateConcatinated(item.getValue()));	        		
	        	}
        	}
    	}
		Debug.println("done converting"); ////////
    }

    //--- CONTAINS DATE VALUE ---------------------------------------------------------------------
    // recognises dates in values concatinated with $ and £ (rows and cells)
    public boolean containsDateValue(String sValue){
    	boolean containsDateValue = false;
    	
    	// check for $ (row) in the value
    	if(sValue.indexOf("$") > -1){
            String sOrigValue = sValue;
            Vector rows = new Vector();
            String sCell;

            // run thru rows of the concatinated value
            while(sOrigValue.indexOf("$") > -1 && !containsDateValue){
            	// row by row
            	String sRow = sOrigValue.substring(0,sOrigValue.indexOf("$")+1);
                Vector cells = new Vector();
                
            	// cell by cell
                while(sRow.indexOf("$") > 0 && !containsDateValue){
                	if(sRow.indexOf("£") > -1){
                	    sCell = sRow.substring(0,sRow.indexOf("£"));
                	}
                	else{
                	    sCell = sRow.substring(0,sRow.indexOf("$"));
                	}
                	
                	// convert to EU date, which is the format to store dates in the DB
                	if(ScreenHelper.isDateValue(sCell)){
                    	containsDateValue = true;
                		break; // stop searching when date found
                	}
                	
                	// trim-off treated cell
                	if(sRow.indexOf("£") > -1){
                	    sRow = sRow.substring(sRow.indexOf("£")+1);
                	}
                	else{
                	    sRow = sRow.substring(sRow.indexOf("$"));
                	}
                    
                    // treat next cell
                }
            	
            	// trim-off treated row
                sOrigValue = sOrigValue.substring(sOrigValue.indexOf("$")+1);
                            	                
                // treat next row
            }
    	}

    	return containsDateValue;
    }
    
    //--- GET BASE ITEM NAMES ---------------------------------------------------------------------
    public Vector getBaseItemNames(){
    	Vector itemNames = new Vector();
    	
        Iterator itemIter = items.iterator();
        ItemVO itemVO;
        String sItemTypeBase;

        while(itemIter.hasNext()){
            itemVO = (ItemVO)itemIter.next();
            
            // all except those which extend another item
            sItemTypeBase = getItemTypeBase(itemVO.getType());
            if(!itemNames.contains(sItemTypeBase)){
                itemNames.add(sItemTypeBase);
                System.out.println("add baseitemname : "+sItemTypeBase); ////////                
            }
        }
        
    	return itemNames;
    }


    //--- GET ITEM TYPE BASE ----------------------------------------------------------------------
    private String getItemTypeBase(String sItemType){
        // check if last 2 chars are digits, and trim them off to get the base name
        int idx = sItemType.length()-2;

        if((int)sItemType.charAt(idx) >= 48 && (int)sItemType.charAt(idx) <= 57){
            return sItemType.substring(0,idx);
        }
        else{
            // check last char
            idx++;

            if((int)sItemType.charAt(idx) >= 48 && (int)sItemType.charAt(idx) <= 57){
                return sItemType.substring(0,idx);
            }
        }

        return sItemType;
    }

    //--- GET ITEM SERIES VALUE -------------------------------------------------------------------
    public String getItemSeriesValue(String sBaseItemType){
        StringBuffer sValue = new StringBuffer();

        // search for item with number-less name (the first item)
        sValue.append(this.getItemValue(sBaseItemType));
        
        // in case of "TAAK1" as first item.. (better not use number in name of first item)
        int i = 1;
        if(sBaseItemType.endsWith("1")){
            sBaseItemType = sBaseItemType.substring(0,sBaseItemType.length()-1); // remove number
            i = 2;
        }

        // search for items with a number at the end of the name (proceding items)
        String itemValue;
        while(i<=50){
            itemValue = this.getItemValue(sBaseItemType+i);

            // loop until the first empty item, but do not skip on "1"
            if(itemValue.length()==0){
                if(i > 1) break;
            }

            i++;
            sValue.append(itemValue);
        }
        
        return sValue.toString();
    }
    
    //--- GET CONTEXT ITEM ------------------------------------------------------------------------
    public ItemVO getContextItem(){
    	return getItem(ScreenHelper.ITEM_PREFIX+"ITEM_TYPE_CONTEXT_CONTEXT");
    }
    
    //--- SET UPDATE TIME -------------------------------------------------------------------------
    public void setUpdateTime(String sDate) {
	  String sSeparator = "/";
	  if (sDate.indexOf(sSeparator)<1){
	    sSeparator = "-";
	  }
      int iDay = Integer.parseInt(sDate.substring(0,sDate.indexOf(sSeparator)));
   	  int iMonth = Integer.parseInt(sDate.substring(sDate.indexOf(sSeparator)+1,sDate.lastIndexOf(sSeparator)));
      int iYear = Integer.parseInt(sDate.substring(sDate.lastIndexOf(sSeparator)+1, sDate.lastIndexOf(sSeparator)+5));
      Calendar c = Calendar.getInstance();
      c.set(iYear, iMonth-1, iDay);

      this.updateTime = new java.sql.Date(c.getTimeInMillis());
    }

    public void setUpdateTime(Date updateTime) {
        this.updateTime = updateTime;
    }

    public void setStatus(int status) {
        this.status = status;
    }

    //--- GET ITEM --------------------------------------------------------------------------------
    public ItemVO getItem(String itemType){
        Iterator iterator = items.iterator();
        ItemVO item;
        while (iterator.hasNext()){
            item = (ItemVO)iterator.next();
            if( item!=null && item.getType().equalsIgnoreCase(itemType)){
                return item;
            }
        }
        return null;
    }

    //--- GET ITEM VALUE --------------------------------------------------------------------------
    public String getItemValue(String itemType){
    	String sValue = "";
    	
    	ItemVO item = getItem(itemType); 
    	if(item!=null){
        	sValue = item.getValue();
        	
        	// convert date-value to EU-date for date-items
        	if(item.isDateItem()){
        		sValue = ScreenHelper.convertDate(sValue);
        	}
    	}
    	
    	return sValue;
    }

    public void setUser(UserVO user) {
        this.user = user;
    }

    public void setItems(Collection items) {
        this.items = items;
    }

    public int hashCode() {
        return transactionId.hashCode();
    }

    //--- CREATE XML ------------------------------------------------------------------------------
    public void createXML(Element element){
        Element transaction = element.addElement("Transaction");
        Element header = transaction.addElement("Header");
        header.addElement("TransactionId").addText(transactionId+"");
        header.addElement("TransactionType").addText(transactionType+"");
        header.addElement("CreationDate").addText(extDateFormat.format(creationDate));
        header.addElement("UpdateTime").addText(extDateFormat.format(updateTime));
        header.addElement("TimeStamp").addText(extDateFormat.format(timestamp));
        header.addElement("Status").addText(status+"");
        header.addElement("UserId").addText(user.getUserId()+"");
        header.addElement("ServerId").addText(serverId+"");
        header.addElement("Version").addText(version+"");
        header.addElement("VersionServerId").addText(versionserverid+"");
        Element itemsElement = transaction.addElement("Items");
        Iterator iterator = items.iterator();
        ItemVO itemVO;

        while(iterator.hasNext()){
            itemVO=(ItemVO)iterator.next();
            itemVO.createXML(itemsElement);
        }
    }

    //--- GET PRESTATIONS -------------------------------------------------------------------------
    public Vector getPrestations(){
        //We zoeken alle prestatiecodes op die werden gekoppeld aan deze transactie
        String sContext="";
        ItemVO contextItem = getItem("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CONTEXT_CONTEXT");
        if (contextItem!=null){
            sContext=contextItem.getValue();
        }
        Vector codes=MedwanQuery.getInstance().getActivityCodesWhereExists(getTransactionType()+" "+sContext);
        Vector prestations = new Vector();
        for(int n=0;n<codes.size();n++){
            prestations.add(Prestation.getByCode((String)codes.elementAt(n)));
        }
        return prestations;
    }

    //--- GET DEBET TRANSACTIONS ------------------------------------------------------------------
    public Vector getDebetTransactions(){
        int personid = MedwanQuery.getInstance().getPersonIdFromHealthrecordId(getHealthrecordId());
        PersonVO person = MedwanQuery.getInstance().getPerson(personid+"");
        Encounter encounter = Encounter.getActiveEncounter(personid+"");
        ObjectReference supplier=new ObjectReference("Person",getUser().getPersonVO().getPersonId()+"");

       Vector prestations = getPrestations();
        Vector debetTransactions = new Vector();
        for(int n=0;n<prestations.size();n++){
            Prestation prestation = (Prestation)prestations.elementAt(n);
            debetTransactions.add(prestation.getDebetTransaction(getUpdateTime(),person,encounter,this,supplier));
        }
        return debetTransactions;
    }

    //--- TO XML ----------------------------------------------------------------------------------
    public String toXML(){
        StringBuffer sXML=new StringBuffer();
        sXML.append("<Transaction>");

        sXML.append("<Header>")
             .append("<TransactionId>"+transactionId+"</TransactionId>")
             .append("<TransactionType>"+transactionType+"</TransactionType>")
             .append("<CreationDate>"+extDateFormat.format(creationDate)+"</CreationDate>")
             .append("<UpdateTime>"+extDateFormat.format(updateTime)+"</UpdateTime>")
             .append("<TimeStamp>"+extDateFormat.format(timestamp)+"</TimeStamp>")
             .append("<Status>"+status+"</Status>")
             .append("<UserId>"+user.getUserId()+"</UserId>")
             .append("<ServerId>"+serverId+"</ServerId>")
             .append("<Version>"+version+"</Version>")
             .append("<VersionServerId>").append(versionserverid).append("</VersionServerId>")
            .append("</Header>");

        sXML.append("<Items>");
        Iterator iterator=items.iterator();
        ItemVO itemVO;
        while(iterator.hasNext()){
            itemVO=(ItemVO)iterator.next();
            sXML.append(itemVO.toXML());
        }
        sXML.append("</Items>");

        sXML.append("</Transaction>");
        return sXML.toString();
    }
    
    //--- PRELOAD ---------------------------------------------------------------------------------
    // load a limited number of items, depending on the transactiontype
    // getItem() must be the one from MWQ !
    public void preload(){
        Vector items = new Vector();

        //*** a : COMMON ITEMS ******************
        ItemVO contextItem = MedwanQuery.getInstance().getItem(serverId,transactionId,IConstants.ITEM_TYPE_CONTEXT_CONTEXT);
        if(contextItem!=null){
        	items.add(contextItem);
        }
                
        //*** b : SPECIFIC ITEMS ****************
        // VACCINATION
        if(this.getTransactionType().equalsIgnoreCase(IConstants.TRANSACTION_TYPE_VACCINATION)){
            items.add(MedwanQuery.getInstance().getItem(serverId,transactionId,ScreenHelper.ITEM_PREFIX+"ITEM_TYPE_VACCINATION_TYPE"));
            items.add(MedwanQuery.getInstance().getItem(serverId,transactionId,ScreenHelper.ITEM_PREFIX+"ITEM_TYPE_VACCINATION_NAME"));
            items.add(MedwanQuery.getInstance().getItem(serverId,transactionId,ScreenHelper.ITEM_PREFIX+"ITEM_TYPE_VACCINATION_STATUS"));
        }
        // CONTACT
        if(this.getTransactionType().equalsIgnoreCase(ScreenHelper.ITEM_PREFIX+"TRANSACTION_TYPE_CONTACT")){
            items.add(MedwanQuery.getInstance().getItem(serverId,transactionId,ScreenHelper.ITEM_PREFIX+"ITEM_TYPE_CONTACTTYPE"));
            items.add(MedwanQuery.getInstance().getItem(serverId,transactionId,ScreenHelper.ITEM_PREFIX+"ITEM_TYPE_CONTACTPERSONS"));
        }
        // MIR2 (rx)
        if(this.getTransactionType().equalsIgnoreCase(IConstants.TRANSACTION_TYPE_MIR2)){
            items.add(MedwanQuery.getInstance().getItem(serverId,transactionId,ScreenHelper.ITEM_PREFIX+"ITEM_TYPE_MIR2_SCREEN_FIXED_UNIT"));
            items.add(MedwanQuery.getInstance().getItem(serverId,transactionId,ScreenHelper.ITEM_PREFIX+"ITEM_TYPE_MIR2_SCREEN_MOBILE_UNIT"));
        }
        // OPHTALMOLOGY
        if(this.getTransactionType().startsWith(IConstants.TRANSACTION_TYPE_OPHTALMOLOGY)){
            // ophta-type 
            items.add(MedwanQuery.getInstance().getItem(serverId,transactionId,ScreenHelper.ITEM_PREFIX+"ITEM_TYPE_OPTHALMOLOGY_SCREEN_ERGOVISION"));
            items.add(MedwanQuery.getInstance().getItem(serverId,transactionId,ScreenHelper.ITEM_PREFIX+"ITEM_TYPE_OPTHALMOLOGY_SCREEN_VISIOTEST"));
            items.add(MedwanQuery.getInstance().getItem(serverId,transactionId,ScreenHelper.ITEM_PREFIX+"ITEM_TYPE_OPTHALMOLOGY_SCREEN_VISIOPHY"));
            items.add(MedwanQuery.getInstance().getItem(serverId,transactionId,ScreenHelper.ITEM_PREFIX+"ITEM_TYPE_OPTHALMOLOGY_SCREEN_EXTERNAL"));
            
            // context
            items.add(MedwanQuery.getInstance().getItem(serverId,transactionId,ScreenHelper.ITEM_PREFIX+"ITEM_TYPE_CONTEXT_CONTEXT_ERGOVISION"));
            items.add(MedwanQuery.getInstance().getItem(serverId,transactionId,ScreenHelper.ITEM_PREFIX+"ITEM_TYPE_CONTEXT_CONTEXT_VISIOTEST"));
            items.add(MedwanQuery.getInstance().getItem(serverId,transactionId,ScreenHelper.ITEM_PREFIX+"ITEM_TYPE_CONTEXT_CONTEXT_VISIOPHY"));
            items.add(MedwanQuery.getInstance().getItem(serverId,transactionId,ScreenHelper.ITEM_PREFIX+"ITEM_TYPE_CONTEXT_CONTEXT_EXTERNAL"));
        }
        // OTHER EXAMINATION
        if(this.getTransactionType().equalsIgnoreCase(IConstants.TRANSACTION_TYPE_OTHER_REQUESTS)){
            items.add(MedwanQuery.getInstance().getItem(serverId,transactionId,IConstants.ITEM_TYPE_SPECIALIST_TYPE));
        }
        // DOCUMENT
        else if(this.getTransactionType().equalsIgnoreCase(IConstants.TRANSACTION_TYPE_DOCUMENT)){
            String sDocumentType = "";
            
            //*** a : for pdfs ***
            // document type or document id
            ItemVO documentType = MedwanQuery.getInstance().getItem(serverId,transactionId,IConstants.ITEM_TYPE_DOCUMENT_TYPE);
            if(documentType==null){
                documentType = MedwanQuery.getInstance().getItem(serverId,transactionId,"documentId");
            }
            items.add(documentType);
            sDocumentType = documentType.getValue();
            
            // template (to purge language)
            ItemVO templateType = MedwanQuery.getInstance().getItem(serverId,transactionId,"documentTemplateId");
            if(templateType!=null){
                items.add(templateType);
            }
        }
        
        this.setItems(items);
    }

    //--- IS NEW ----------------------------------------------------------------------------------
    public boolean isNew(){
        return (transactionId.intValue() < 0);
    }

    //--- GET CONTEXT ITEM VALUE ------------------------------------------------------------------
    public String getContextItemValue(){
        String sItemValue = "";

        ItemVO item = getContextItem();
        if(item!=null){
            sItemValue = ScreenHelper.checkString(item.getValue());
        }

        return sItemValue;
    }
    
    //--- IS IN SPECIFIED CONTEXT -----------------------------------------------------------------
    public boolean isInSpecifiedContext(String sContext){
        boolean isInSpecifiedContext = false;
        
        //String sSavedContext = this.getItemValue(ScreenHelper.ITEM_PREFIX+"ITEM_TYPE_CONTEXT_CONTEXT");
        String sSavedContext = this.getContextItemValue();
        if(sSavedContext.equalsIgnoreCase(sContext)){
            isInSpecifiedContext = true;
        }
        
        return isInSpecifiedContext;
    }
    
    //--- IS RECENT TRAN --------------------------------------------------------------------------
    // periodType = constant from java.util.Calendar
    // --> java.util.Calendar.YEAR
    public boolean isRecentTran(int periodType, int amount){
        boolean isRecentTran = false;
        
        java.util.Calendar cal = Calendar.getInstance();
        cal.setTime(new java.util.Date()); // now
        cal.add(periodType,-1*amount); // revert
        java.util.Date refDate = cal.getTime();
        if(this.updateTime.getTime() >= refDate.getTime()){
            isRecentTran = true;
        }
        
        return isRecentTran;
    }
    
}