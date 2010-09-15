package be.dpms.medwan.common.model.vo.occupationalmedicine;

/**
 * Created by IntelliJ IDEA.
 * User: Frank
 * Date: 20-jun-2005
 * Time: 17:56:02
 */
public class EnterpriseVisitItemVO implements Cloneable {
    public int itemId;
    public String itemType;
    public String itemValue;

    public EnterpriseVisitItemVO(int itemId,String itemType,String itemValue){
        this.itemId=itemId;
        this.itemType=itemType;
        this.itemValue=itemValue;
    }

    public EnterpriseVisitItemVO getClone(){
        try{
            return (EnterpriseVisitItemVO)super.clone();
        }
        catch(CloneNotSupportedException e){
            e.printStackTrace();
        }
        return null;
    }
}
