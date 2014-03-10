package be.dpms.medwan.common.model.vo.occupationalmedicine;

import be.mxs.common.model.vo.IIdentifiable;

import java.io.Serializable;

public class ExaminationVO implements Serializable, IIdentifiable {
    public Integer id;
    public String messageKey;
    public Integer priority;
    public byte[] data;
    public String transactionType;
    public String nl;
    public String fr;
    public String language;

    //--- CONSTRUCTOR -----------------------------------------------------------------------------
    public ExaminationVO(Integer examinationId, String messageKey, Integer priority, byte[] data,
    		             String transactionType, String nl, String fr, String language) {
        this.id = examinationId;
        this.messageKey = messageKey;
        this.priority = priority;
        this.data = data;
        this.transactionType = transactionType;
        this.nl = nl;
        this.fr = fr;
        this.language = language;
    }

    //--- GET LABEL -------------------------------------------------------------------------------
    public String getLabel(){
        if(language.equalsIgnoreCase("n") || language.equalsIgnoreCase("nl")){
            if(nl==null || nl.equals("")){
                return messageKey;
            }
            else{
                return nl;
            }
        }
        else{
            if(fr==null || fr.equals("")){
                return messageKey;
            }
            else{
                return fr;
            }
        }
    }

    public Integer getId(){
        return id;
    }

    public String getMessageKey(){
        return messageKey;
    }

    public Integer getPriority(){
        return priority;
    }

    public byte[] getData(){
        return data;
    }

    public String getTransactionType(){
        return transactionType;
    }

    public void setTransactionType(String transactionType){
        this.transactionType = transactionType;
    }

    public void setId(Integer id){
        this.id = id;
    }

    public void setMessageKey(String messageKey){
        this.messageKey = messageKey;
    }

    public void setPriority(Integer priority){
        this.priority = priority;
    }

    public void setData(byte[] data){
        this.data = data;
    }

    public boolean equals(Object o){
        if(this == o) return true;
        if(!(o instanceof ExaminationVO)) return false;

        final ExaminationVO examinationVO = (ExaminationVO)o;

        return id.equals(examinationVO.id);
    }

    public int hashCode(){
        return id.hashCode();
    }
    
}
