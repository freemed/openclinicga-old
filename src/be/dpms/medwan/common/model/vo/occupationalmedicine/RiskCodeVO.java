package be.dpms.medwan.common.model.vo.occupationalmedicine;

import be.mxs.common.model.vo.IIdentifiable;
import java.io.Serializable;

/**
 * Created by IntelliJ IDEA.
 * User: Michaël
 * Date: 16-juin-2003
 * Time: 9:15:23
 */
public class RiskCodeVO implements Serializable, IIdentifiable {
    public Integer riskCodeId;
    public String code;
    public String messageKey;
    public String nl;
    public String fr;
    public String defaultVisible;
    public String language;

    public RiskCodeVO(Integer riskCodeId, String code, String messageKey) {
        this.riskCodeId = riskCodeId;
        this.code = code;
        this.messageKey = messageKey;
    }

    public RiskCodeVO(Integer riskCodeId, String code, String messageKey, String nl, String fr, String defaultVisible,String language) {
        this.riskCodeId = riskCodeId;
        this.code = code;
        this.messageKey = messageKey;
        this.nl=nl;
        this.fr=fr;
        this.defaultVisible=defaultVisible;
        this.language=language;
    }

    public String getLabel(){
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

    public String getNl(){
        return nl;
    }

    public String getFr(){
        return fr;
    }

    public String getDefaultVisible(){
        return defaultVisible;
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

    public void setRiskCodeId(Integer riskCodeId) {
        this.riskCodeId = riskCodeId;
    }

    public void setCode(String code) {
        this.code = code;
    }

    public void setMessageKey(String messageKey) {
        this.messageKey = messageKey;
    }

    public boolean equals(Object o){

        boolean equal = false;

        if (o instanceof RiskCodeVO) {

            RiskCodeVO riskCodeVO = (RiskCodeVO) o;

            if (riskCodeVO.getRiskCodeId().equals(this.getRiskCodeId())) equal = true;
        }

        return equal;
    }

    public int hashCode() {
        return riskCodeId.hashCode();
    }
}
