package be.mxs.common.model.vo.healthrecord;

import be.dpms.medwan.common.model.vo.administration.PersonVO;
import be.dpms.medwan.common.model.vo.authentication.UserVO;
import be.mxs.common.model.vo.IIdentifiable;
import be.mxs.common.util.db.MedwanQuery;
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
    private SimpleDateFormat extDateFormat = new SimpleDateFormat("dd/MM/yyyy hh:mm:ss");

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

    public TransactionVO(Integer transactionId, String transactionType, Date creationDate, Date updateTime, int status, UserVO user, Collection itemsVO,int serverid,int version, int versionserverid,Date timestamp) {
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

    public TransactionVO(Integer transactionId, String transactionType, Date creationDate, Date updateTime, int status, UserVO user, Collection itemsVO) {
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

    public void setUpdateTime(String sDate) {
	  String sSeparator = "/";
	  if (sDate.indexOf(sSeparator)<1)
	  {
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

    public String getItemValue(String itemType){
    	ItemVO item = getItem(itemType); 
    	if(item!=null){
    		return item.getValue();
    	}
    	return "";
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

    public String toXML(){
        StringBuffer sXML=new StringBuffer();
        sXML.append("<Transaction>");

        sXML.append("<Header>");
        sXML.append("<TransactionId>"+transactionId+"</TransactionId>");
        sXML.append("<TransactionType>"+transactionType+"</TransactionType>");
        sXML.append("<CreationDate>"+extDateFormat.format(creationDate)+"</CreationDate>");
        sXML.append("<UpdateTime>"+extDateFormat.format(updateTime)+"</UpdateTime>");
        sXML.append("<TimeStamp>"+extDateFormat.format(timestamp)+"</TimeStamp>");
        sXML.append("<Status>"+status+"</Status>");
        sXML.append("<UserId>"+user.getUserId()+"</UserId>");
        sXML.append("<ServerId>"+serverId+"</ServerId>");
        sXML.append("<Version>"+version+"</Version>");
        sXML.append("<VersionServerId>").append(versionserverid).append("</VersionServerId>");
        sXML.append("</Header>");

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
}