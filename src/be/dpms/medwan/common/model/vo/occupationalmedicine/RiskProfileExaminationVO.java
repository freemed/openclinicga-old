package be.dpms.medwan.common.model.vo.occupationalmedicine;

import be.mxs.common.model.vo.IIdentifiable;

import java.io.Serializable;

/**
 * Created by IntelliJ IDEA.
 * User: Michaël
 * Date: 20-mai-2003
 * Time: 16:03:05
 */
public class RiskProfileExaminationVO implements Serializable, IIdentifiable {
    public Integer id;
    public String  messageKey;
    public Integer priority;
    public byte[]  data;
    public double defaultFrequency;
    public double defaultTolerance;
    public double personalFrequency;
    public double personalTolerance;
    public String  type;
    public Integer status;
    public String  transactionType;
    public String nl;
    public String fr;
    public String language;

    public RiskProfileExaminationVO() {
    }

    public RiskProfileExaminationVO(Integer id, String messageKey, Integer priority, byte[] data, double defaultFrequency, double defaultTolerance, double personalFrequency, double personalTolerance, String type, Integer status, String transactionType,String nl,String fr,String language) {
        this.id = id;
        this.messageKey = messageKey;
        this.priority = priority;
        this.data = data;
        this.defaultFrequency = defaultFrequency;
        this.defaultTolerance = defaultTolerance;
        this.personalFrequency = personalFrequency;
        this.personalTolerance = personalTolerance;
        this.type = type;
        this.status = status;
        this.transactionType = transactionType;
        this.nl=nl;
        this.fr=fr;
        this.language=language;
    }
    public String getLabel(){
        //Debug.println("*"+messageKey+"*");
        if (language.equalsIgnoreCase("N")){
            if (nl==null || nl.equals("")){
                return messageKey;
            }
            else{
                return nl;
            }
        }
        else {
            if (fr==null || fr.equals("")){
                return messageKey;
            }
            else{
                return fr;
            }
        }

    }

    public String getLabel(String language){
        //Debug.println("*"+messageKey+"*");
        if (language.equalsIgnoreCase("N")){
            if (nl==null || nl.equals("")){
                return messageKey;
            }
            else{
                return nl;
            }
        }
        else {
            if (fr==null || fr.equals("")){
                return messageKey;
            }
            else{
                return fr;
            }
        }

    }

    public Integer getId() {
        return id;
    }

    public String getTransactionType() {
        return transactionType;
    }

    public void setTransactionType(String transactionType) {
        this.transactionType = transactionType;
    }

    public String getMessageKey() {
        return messageKey;
    }

    public Integer getPriority() {
        return priority;
    }

    public byte[] getData() {
        return data;
    }

    public double getDefaultFrequency() {
        return defaultFrequency;
    }

    public double getDefaultTolerance() {
        return defaultTolerance;
    }

    public double getPersonalFrequency() {
        return personalFrequency;
    }

    public double getPersonalTolerance() {
        return personalTolerance;
    }

    public String getType() {
        return type;
    }

    public Integer getStatus() {
        return status;
    }

    public String getStatusMessageKey() {

        if (getStatus().intValue() == be.dpms.medwan.common.model.IConstants.RISK_PROFILE_ITEM__STATUS_DEFAULT) {

            return be.dpms.medwan.common.model.IConstants.RISK_PROFILE_MESSSAGE_KEY_ITEM__STATUS_DEFAULT;

        } else if (getStatus().intValue() == be.dpms.medwan.common.model.IConstants.RISK_PROFILE_ITEM__STATUS_ADDED) {

            return be.dpms.medwan.common.model.IConstants.RISK_PROFILE_MESSSAGE_KEY_ITEM__STATUS_ADDED;

        } else if (getStatus().intValue() == be.dpms.medwan.common.model.IConstants.RISK_PROFILE_ITEM__STATUS_NONE) {

            return be.dpms.medwan.common.model.IConstants.RISK_PROFILE_MESSSAGE_KEY_ITEM__STATUS_NONE;

        } else if (getStatus().intValue() == be.dpms.medwan.common.model.IConstants.RISK_PROFILE_ITEM__STATUS_UPDATED) {

            return be.dpms.medwan.common.model.IConstants.RISK_PROFILE_MESSSAGE_KEY_ITEM__STATUS_UPDATED;
        }

        // else getStatus().intValue() == be.dpms.medwan.common.model.IConstants.RISK_PROFILE_MESSSAGE_KEY_ITEM__STATUS_REMOVED


        return be.dpms.medwan.common.model.IConstants.RISK_PROFILE_MESSSAGE_KEY_ITEM__STATUS_REMOVED;
    }

    public void setId(Integer id) {
        this.id = id;
    }

    public void setMessageKey(String messageKey) {
        this.messageKey = messageKey;
    }

    public void setPriority(Integer priority) {
        this.priority = priority;
    }

    public void setData(byte[] data) {
        this.data = data;
    }

    public void setDefaultFrequency(double defaultFrequency) {
        this.defaultFrequency = defaultFrequency;
    }

    public void setDefaultTolerance(double defaultTolerance) {
        this.defaultTolerance = defaultTolerance;
    }

    public void setPersonalFrequency(double personalFrequency) {
        this.personalFrequency = personalFrequency;
    }

    public void setPersonalTolerance(double personalTolerance) {
        this.personalTolerance = personalTolerance;
    }

    public void setType(String type) {
        this.type = type;
    }

    public void setStatus(Integer status) {
        this.status = status;
    }

    public boolean equals(Object o) {
        if (this == o) return true;
        if (!(o instanceof RiskProfileExaminationVO)) return false;

        final RiskProfileExaminationVO riskProfileExaminationVO = (RiskProfileExaminationVO) o;

        return id.equals(riskProfileExaminationVO.id);

    }

    public int hashCode() {
        return id.hashCode();
    }
}
