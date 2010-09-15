package be.mxs.common.model.vo.healthrecord;

import be.mxs.common.model.vo.IIdentifiable;

import java.io.Serializable;
import java.util.*;

/**
 * Created by IntelliJ IDEA.
 * User: Michaël
 * Date: 01-août-2003
 * Time: 11:19:32
 * To change this template use Options | File Templates.
 */
public class VaccinationInfoVO implements Serializable, IIdentifiable {

    TransactionVO transactionVO = null;
    long nextMinInterval = 0;
    String nextStatus = null;
    Date nextDate = null;
    String comment = null;
    String color = null;
    Collection valueList = new Vector();
    String type=null;

    public String getType(){
        return type;
    }

    public void setType(String type){
        this.type = type;
    }

    public VaccinationInfoVO() {
        setColor(getGreenCode());
    }

    public Date getNextVaccinationDate(Date newDate) {

        return new Date( newDate.getTime() + nextMinInterval*24*60*60*1000 );
    }

    public long getNextMinInterval() {
        return nextMinInterval;
    }

    public void setNextMinInterval(long nextMinInterval) {
        this.nextMinInterval = nextMinInterval;
    }

    public TransactionVO getTransactionVO() {
        return transactionVO;
    }

    public void setTransactionVO(TransactionVO transactionVO) {
        this.transactionVO = transactionVO;
    }

    public String getNextStatus() {
        return nextStatus;
    }

    public void setNextStatus(String nextStatus) {
        this.nextStatus = nextStatus;
    }

    public Date getNextDate() {
        return nextDate;
    }

    public void setNextDate(Date nextDate) {
        this.nextDate = nextDate;
    }

    public String getComment() {
        return comment;
    }

    public void setComment(String comment) {
        this.comment = comment;
    }

    public String getColor() {
        return color;
    }

    public void setColor(String color) {
        this.color = color;
    }

    public String getGreenCode() {
        return "#99cc99";
    }

    public String getRedCode() {
        return "#ff9999";
    }

    public Collection getValueList() {
        return valueList;
    }

    public void setValueList(Collection valueList) {
        this.valueList = valueList;
    }

    public int hashCode() {
        return transactionVO.getTransactionId().hashCode();
    }

    public String toString(){
        String vi = "Type: "+type+"\n";
        vi += "NextDate: "+nextDate+"\n";
        vi += "NextStatus: "+nextStatus+"\n";
        vi += "Comment: "+comment+"\n";
        vi += "Color: "+color+"\n";
        vi += "NextMinInterval: "+nextMinInterval+"\n";
        vi += "TransactionDate: "+transactionVO.getCreationDate()+"\n";
        return vi;
    }

}
