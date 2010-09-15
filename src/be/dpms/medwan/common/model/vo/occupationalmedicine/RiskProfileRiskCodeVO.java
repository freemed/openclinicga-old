package be.dpms.medwan.common.model.vo.occupationalmedicine;

import be.mxs.common.model.vo.IIdentifiable;
import be.mxs.common.util.db.MedwanQuery;

import java.io.Serializable;

/**
 * User: Michaël
 * Date: 16-juin-2003
 */
public class RiskProfileRiskCodeVO implements Serializable, IIdentifiable, Comparable {
    public Integer riskCodeId;
    public String code;
    public String messageKey;
    public String type;
    public Integer status;

    //--- COMPARE TO ------------------------------------------------------------------------------
    public int compareTo(Object o){
        int comp;
        if (o.getClass().isInstance(this)){
            comp = this.code.compareTo(((RiskProfileRiskCodeVO)o).code);
        }
        else {
            throw new ClassCastException();
        }
        return comp;
    }

    //--- RISKPROFILE RISKCODE --------------------------------------------------------------------
    public RiskProfileRiskCodeVO(Integer riskCodeId, String code, String messageKey, String type, Integer status) {
        this.riskCodeId = riskCodeId;
        this.code = code;
        this.messageKey = messageKey;
        this.type = type;
        this.status = status;
    }

    public Integer getRiskCodeId() {
        return riskCodeId;
    }

    public String getCode() {
        return code;
    }

    public String getMessageKey() {
        return messageKey;
    }

    public String getTranslatedType(String language){
        return MedwanQuery.getInstance().getLabel("web.occup",getType(),language);
    }

    public String getType() {
        return type;
    }

    public Integer getStatus() {
        return status;
    }

    public String getTranslatedStatusMessageKey(String language){
        return MedwanQuery.getInstance().getLabel("web.occup",getStatusMessageKey(),language);
    }

    //--- GET STATUS MESSAGE KEY ------------------------------------------------------------------
    public String getStatusMessageKey() {
        if (getStatus().intValue() == be.dpms.medwan.common.model.IConstants.RISK_PROFILE_ITEM__STATUS_DEFAULT) {
            return be.dpms.medwan.common.model.IConstants.RISK_PROFILE_MESSSAGE_KEY_ITEM__STATUS_DEFAULT;
        }
        else if (getStatus().intValue() == be.dpms.medwan.common.model.IConstants.RISK_PROFILE_ITEM__STATUS_ADDED) {
            return be.dpms.medwan.common.model.IConstants.RISK_PROFILE_MESSSAGE_KEY_ITEM__STATUS_ADDED;
        }
        else if (getStatus().intValue() == be.dpms.medwan.common.model.IConstants.RISK_PROFILE_ITEM__STATUS_NONE) {
            return be.dpms.medwan.common.model.IConstants.RISK_PROFILE_MESSSAGE_KEY_ITEM__STATUS_NONE;
        }
        // else getStatus().intValue() == be.dpms.medwan.common.model.IConstants.RISK_PROFILE_MESSSAGE_KEY_ITEM__STATUS_REMOVED

        return be.dpms.medwan.common.model.IConstants.RISK_PROFILE_MESSSAGE_KEY_ITEM__STATUS_REMOVED;
    }

    public void setRiskCodeId(Integer riskCodeId) {
        this.riskCodeId = riskCodeId;
    }

    public void setCode(String code) {
        this.code = code;
    }

    public void setMessageKey(String messageKey) {
        this.messageKey = messageKey;
    }

    public void setType(String type) {
        this.type = type;
    }

    public void setStatus(Integer status) {
        this.status = status;
    }

    //--- EQUALS ----------------------------------------------------------------------------------
    public boolean equals(Object o) {
        if (this == o) return true;
        if (!(o instanceof RiskProfileRiskCodeVO)) return false;

        final RiskProfileRiskCodeVO riskProfileRiskCodeVO = (RiskProfileRiskCodeVO)o;

        return riskCodeId.equals(riskProfileRiskCodeVO.riskCodeId);

    }

    public int hashCode() {
        return riskCodeId.hashCode();
    }
}
