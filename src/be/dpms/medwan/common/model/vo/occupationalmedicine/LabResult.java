package be.dpms.medwan.common.model.vo.occupationalmedicine;

import be.mxs.common.util.io.MessageReader;
import be.mxs.common.util.io.MessageReaderMedidoc;

/**
 * Created by IntelliJ IDEA.
 * User: frank
 * Date: 29-aug-2005
 * Time: 11:01:44
 */
public class LabResult {
    String type="";
    String modifier="";
    String result="";
    String unit="";
    String normal="";
    String time="";
    String comment="";

    public LabResult(String result){
        try{
            MessageReader messageReader = new MessageReaderMedidoc();
            messageReader.lastline=result;
            type=messageReader.readField("|");
            if (type.equalsIgnoreCase("T") || type.equalsIgnoreCase("C")){
                comment=messageReader.readField("|");
            }
            else if (type.equalsIgnoreCase("N")||type.equalsIgnoreCase("D")||type.equalsIgnoreCase("H")||type.equalsIgnoreCase("M")||type.equalsIgnoreCase("S")){
                modifier=messageReader.readField("|");
                this.result=messageReader.readField("|");
                unit=messageReader.readField("|");
                normal=messageReader.readField("|");
                time=messageReader.readField("|");
                comment=messageReader.readField("|");
            }
        }
        catch (Exception e){
            e.printStackTrace();
        }
    }

    public String getType() {
        return type;
    }

    public void setType(String type) {
        this.type = type;
    }

    public String getModifier() {
        return modifier;
    }

    public void setModifier(String modifier) {
        this.modifier = modifier;
    }

    public String getResult() {
        return result;
    }

    public void setResult(String result) {
        this.result = result;
    }

    public String getUnit() {
        return unit;
    }

    public void setUnit(String unit) {
        this.unit = unit;
    }

    public String getNormal() {
        return normal;
    }

    public void setNormal(String normal) {
        this.normal = normal;
    }

    public String getTime() {
        return time;
    }

    public void setTime(String time) {
        this.time = time;
    }

    public String getComment() {
        return comment;
    }

    public void setComment(String comment) {
        this.comment = comment;
    }

}
