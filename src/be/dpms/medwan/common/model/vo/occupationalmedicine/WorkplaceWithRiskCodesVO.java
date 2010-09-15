package be.dpms.medwan.common.model.vo.occupationalmedicine;

import be.mxs.common.model.vo.IIdentifiable;

import java.io.Serializable;
import java.util.Collection;
import java.util.Vector;
import java.util.Arrays;

/**
 * Created by IntelliJ IDEA.
 * User: Michaël
 * Date: 16-juin-2003
 * Time: 10:42:09
 */
public class WorkplaceWithRiskCodesVO implements Serializable, IIdentifiable {
    public Integer workplaceId;
    public String messageKey;
    public Collection riskCode;

    public WorkplaceWithRiskCodesVO(Integer workplaceId, String messageKey, Collection riskCode) {
        this.workplaceId = workplaceId;
        this.messageKey = messageKey;
        if (riskCode !=null) {
            this.riskCode = new Vector(riskCode);
        }
        else {
            this.riskCode = new Vector();
        }
    }

    public Integer getWorkplaceId() {
        return workplaceId;
    }

    public String getMessageKey() {
        return messageKey;
    }

    //--- GET MESSAGE KEY EXTENDED ----------------------------------------------------------------
    // return the messagekey, extended with a sorted, commaseparated list of the risks of this workplace.
    public String getMessageKeyExtended() {
        if(riskCode.size() > 0){
            String messageKeyExtended = messageKey+" (";
            boolean inited = false;

            Object[] riskCodeVOArray = riskCode.toArray();
            Arrays.sort(riskCodeVOArray);
            for(int i=0; i<riskCodeVOArray.length; i++){
                if (!inited){
                    inited = true;
                }
                else {
                    messageKeyExtended+= ", ";
                }
                messageKeyExtended+= ((RiskProfileRiskCodeVO)riskCodeVOArray[i]).code;
            }
            messageKeyExtended+= ")";

            return messageKeyExtended;
        }
        else{
            return messageKey;
        }
    }

    public Collection getRiskCodeVO() {
        return riskCode;
    }

    public void setWorkplaceId(Integer workplaceId) {
        this.workplaceId = workplaceId;
    }

    public void setMessageKey(String messageKey) {
        this.messageKey = messageKey;
    }

    public void setRiskCode(Collection riskCode) {
        this.riskCode = riskCode;
    }

    public boolean equals(Object o) {
        if (this == o) return true;
        if (!(o instanceof WorkplaceWithRiskCodesVO)) return false;

        final WorkplaceWithRiskCodesVO workplaceWithRiskCodesVO = (WorkplaceWithRiskCodesVO) o;

        return riskCode.equals(workplaceWithRiskCodesVO.riskCode) && workplaceId.equals(workplaceWithRiskCodesVO.workplaceId);

    }

    public int hashCode() {
        int result;
        result = workplaceId.hashCode();
        result = 29 * result + riskCode.hashCode();
        return result;
    }
}
