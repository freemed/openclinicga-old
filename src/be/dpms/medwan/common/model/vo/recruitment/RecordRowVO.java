package be.dpms.medwan.common.model.vo.recruitment;

import java.io.Serializable;

public class RecordRowVO implements Serializable {
    private final int indent;
    private final int labelWidth;
    private final String label;
    private final int resultWidth;
    private final String result;
    private int transactionId=-1;
    private int healthrecordId=-1;
    private int serverId=-1;
    private String transactiontype="";

    public RecordRowVO(int indent, int labelWidth, String label, int resultWidth, String result) {
        this.indent = indent;
        this.labelWidth = labelWidth;
        this.label = label;
        this.resultWidth = resultWidth;
        this.result = result;
    }

    public void setTransactionType(String transactionType){
        this.transactiontype=transactionType;
    }

    public String getTransactionType(){
        return transactiontype;
    }

    public void setTransactionId(int transactionId){
        this.transactionId=transactionId;
    }

    public void setHealthrecordId(int healthrecordId){
        this.healthrecordId=healthrecordId;
    }

    public int getTransactionId(){
        return transactionId;
    }

    public int getHealthrecordId(){
        return healthrecordId;
    }

    public void setServerId(int serverId){
        this.serverId=serverId;
    }

    public int getServerId(){
        return serverId;
    }

    public int getIndent() {
        return indent;
    }

    public int getLabelWidth() {
        return labelWidth;
    }

    public String getLabel() {
        return label;
    }

    public int getResultWidth() {
        return resultWidth;
    }

    public String getResult() {
        return result;
    }
}
