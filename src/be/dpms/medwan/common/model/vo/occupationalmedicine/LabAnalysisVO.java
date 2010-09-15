package be.dpms.medwan.common.model.vo.occupationalmedicine;

import be.mxs.common.util.db.MedwanQuery;

/**
 * Created by IntelliJ IDEA.
 * User: frank
 * Date: 5-aug-2005
 * Time: 16:48:54
 */
public class LabAnalysisVO {
    private String id="";
    private String code="";
    private String medidocCode="";
    private String lastVal="";
    private java.util.Date lastDate=null;
    private java.util.Date nextDate=null;
    private String type="";
    private String sample="";

    public LabAnalysisVO(){

    }

    public LabAnalysisVO(String code,String medidocCode,String lastVal,java.util.Date lastDate,java.util.Date nextDate){
        this.code=code;
        this.medidocCode=medidocCode;
        this.lastVal=lastVal;
        this.lastDate=lastDate;
        this.nextDate=nextDate;
    }

    public boolean due(){
        return due(new java.util.Date());
    }

    public boolean due(java.util.Date date){
        return nextDate.before(date);
    }

    public String getSample(){
        return sample;
    }

    public String getType(){
        return type;
    }

    public String getId(){
        return id;
    }

    public void setId(String id){
        this.id=id;
    }

    public String getLabel(String sLanguage){
        return MedwanQuery.getInstance().getLabel("labanalysis",id,sLanguage);
    }

    public void setSample(String sample){
        this.sample=sample;
    }

    public void setType(String type){
        this.type = type;
    }

    public String getCode(){
        return code;
    }

    public String getMedidocCode(){
        return medidocCode;
    }

    public String getLastVal(){
        return lastVal;
    }

    public void setLastVal(String lastval){
        this.lastVal=lastval;
    }

    public void setLastDate(java.util.Date lastDate){
        this.lastDate=lastDate;
    }

    public void setNextDate(java.util.Date nextDate){
        this.nextDate=nextDate;
    }

    public java.util.Date getLastDate(){
        return lastDate;
    }

    public java.util.Date getNextDate(){
        return nextDate;
    }
}
