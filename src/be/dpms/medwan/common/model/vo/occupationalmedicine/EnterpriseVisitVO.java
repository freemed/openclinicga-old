package be.dpms.medwan.common.model.vo.occupationalmedicine;

import be.dpms.medwan.common.model.vo.authentication.UserVO;
import be.mxs.common.util.db.MedwanQuery;

import java.util.Date;
import java.util.Vector;
import java.util.Iterator;

import net.admin.Service;

/**
 * User: Frank
 * Date: 20-jun-2005
 */
public class EnterpriseVisitVO implements Cloneable {
    public int visitId;
    public String serviceId = "";
    public int userId;
    public Date updateTime = null;
    public Date creationDate = null;
    public Date ts = null;
    public int serverId;
    public Vector items = new Vector();

    public EnterpriseVisitVO(int visitId, String serviceId, int userId, Date updateTime, Date creationDate, Date ts, int serverId){
        this.visitId = visitId;
        this.serviceId = serviceId;
        this.userId = userId;
        this.updateTime = updateTime;
        this.creationDate = creationDate;
        this.ts = ts;
        this.serverId = serverId;
    }

    public void addItem(EnterpriseVisitItemVO item){
        Iterator itemIter = items.iterator();
        EnterpriseVisitItemVO tmpItem;
        boolean found = false;

        // Make sure only one item per itemType exists. (itemType must be unique)
        // If many items of the same itemType,
        // keep only the itemValue of the most recent one. (update itemValue)
        while(itemIter.hasNext() && !found){
            tmpItem = (EnterpriseVisitItemVO)itemIter.next();
            if(tmpItem.itemType.equals(item.itemType)){
                // update itemValue
                tmpItem.itemValue = item.itemValue;
                found = true;
            }
        }

        // add the item if not yet in the items array.
        if(!found){
            items.add(item);
        }
    }

    public String getItemValue(String itemType){
        if (getItem(itemType)!=null){
            return getItem(itemType).itemValue;
        }
        return "";
    }

    public String getLastItemValue(String itemType){
        if (getItem(itemType)!=null){
            return getItem(itemType).itemValue;
        }
        return MedwanQuery.getInstance().getLastEnterpriseItemValue(serviceId,itemType);
    }

    public EnterpriseVisitItemVO getItem(String itemType){
        EnterpriseVisitItemVO item;
        for (int n=0;n<items.size();n++){
            item = (EnterpriseVisitItemVO)items.elementAt(n);
            if (item.itemType.equalsIgnoreCase(itemType)){
                return item;
            }
        }
        return null;
    }

    public UserVO getUser(){
        return MedwanQuery.getInstance().getUser(Integer.toString(userId));
    }

    public Service getService(){
        Service service = new Service();
        try {
            if (serviceId.length()>0){
                return MedwanQuery.getInstance().getService(serviceId);
            }
        }
        catch (Exception e){
            e.printStackTrace();
        }
        return service;
    }

    public EnterpriseVisitVO getClone(){
        // clone visit
        EnterpriseVisitVO clone = null;
        try{ clone = (EnterpriseVisitVO)super.clone(); }
        catch(CloneNotSupportedException e){
            e.printStackTrace();
        }

        if(clone!=null){
            clone.items = new Vector();

            // clone its items
            Iterator itemIter = this.items.iterator();
            EnterpriseVisitItemVO item;
            while(itemIter.hasNext()){
                item = (EnterpriseVisitItemVO)itemIter.next();
                clone.addItem(item.getClone());
            }
        }
        return clone;
    }

    public void saveToDB(){
        EnterpriseVisitVO newVisit = MedwanQuery.getInstance().saveEnterpriseVisit(this);
        this.visitId = newVisit.visitId;
        this.ts = newVisit.ts;
        this.items = newVisit.items;
        this.serverId=newVisit.serverId;
    }
}
