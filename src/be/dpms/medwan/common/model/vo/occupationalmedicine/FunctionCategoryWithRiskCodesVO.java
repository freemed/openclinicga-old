package be.dpms.medwan.common.model.vo.occupationalmedicine;

import be.mxs.common.model.vo.IIdentifiable;

import java.util.*;
import java.io.Serializable;

/**
 * Created by IntelliJ IDEA.
 * User: Michaël
 * Date: 20-mai-2003
 * Time: 16:03:42
 */
public class FunctionCategoryWithRiskCodesVO implements Serializable, IIdentifiable {
    public Integer id;
    public String messageKey;
    public Collection riskCode;

    public FunctionCategoryWithRiskCodesVO() {
    }

    public FunctionCategoryWithRiskCodesVO(Integer id, String messageKey, Collection riskCode) {
        this.id = id;
        this.messageKey = messageKey;
        if (riskCode !=null) {
            this.riskCode = new Vector(riskCode);
        } else {
            this.riskCode = new Vector();
        }
    }

    public Integer getId() {
        return id;
    }

    public String getMessageKey() {
        return messageKey;
    }

    //--- GET MESSAGE KEY EXTENDED ----------------------------------------------------------------
    // return the messagekey, extended with a sorted, commaseparated list of the risks of this functioncategory.
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

    public void setId(Integer id) {
        this.id = id;
    }

    public void setMessageKey(String messageKey) {
        this.messageKey = messageKey;
    }

    public void setRiskCode(Collection riskCode) {
        this.riskCode = riskCode;
    }

    public boolean equals(Object o) {
        if (this == o) return true;
        if (!(o instanceof FunctionCategoryWithRiskCodesVO)) return false;

        final FunctionCategoryWithRiskCodesVO functionCategoryWithRiskCodesVO = (FunctionCategoryWithRiskCodesVO) o;

        return id.equals(functionCategoryWithRiskCodesVO.id);

    }

    public int hashCode() {
        return id.hashCode();
    }
}
