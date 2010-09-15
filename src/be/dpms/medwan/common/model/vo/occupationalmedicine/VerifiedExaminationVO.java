package be.dpms.medwan.common.model.vo.occupationalmedicine;

import be.mxs.common.model.vo.IIdentifiable;
import be.mxs.common.model.vo.healthrecord.TransactionVO;
import be.dpms.medwan.webapp.wo.common.system.SessionContainerWO;

import java.io.Serializable;
import java.util.Date;
import java.text.SimpleDateFormat;

/**
 * Created by IntelliJ IDEA.
 * User: Michaël
 * Date: 20-mai-2003
 */
public class VerifiedExaminationVO implements Serializable, IIdentifiable {
    public int examinationId;
    public String messageKey;
    public String transactionType;
    public String lastExamination;
    public Date   lastExaminationDate;
    public String lastExaminationId;
    public String lastExaminationServerId;
    public String newExaminationDue;
    public String healthRecordId;
    public Date newExaminationDueDate;
    public PlannedExamination plannedExamination;
    private SessionContainerWO sessionContainerWO;


    //--- constructors ----------------------------------------------------------------------------
    public VerifiedExaminationVO(int examinationId, String healthRecordId, String messageKey, String transactionType, SessionContainerWO sessionContainerWO) {
        this.examinationId = examinationId;
        this.healthRecordId = healthRecordId;
        this.messageKey = messageKey;
        this.transactionType = transactionType;
        this.sessionContainerWO = sessionContainerWO;

        if(transactionType.indexOf("be.mxs.common.model.vo.healthrecord.IConstants.TRANSACTION_TYPE_VACCINATION")==-1){
            findLastExamination();
            findPlannedExamination();
        }
    }

    public VerifiedExaminationVO() {
    }


    public String getPlannedExaminationDue() {
        if(plannedExamination!=null && plannedExamination.getEffectiveDate()==null && plannedExamination.getPlannedDate()!=null && !plannedExamination.getPlannedDate().after(new Date())){
            return "medwan.common.true";
        }
        return "";
    }

    public Date getPlannedExaminationDueDate() {
        if(plannedExamination!=null){
            return plannedExamination.getPlannedDate();
        }
        return null;
    }

    public String getPlannedExaminationDueDateString() {
        if(plannedExamination!=null && plannedExamination.getPlannedDate()!=null){
            return new SimpleDateFormat("dd/MM/yyyy").format(plannedExamination.getPlannedDate());
        }
        return "";
    }

    public Date getNewExaminationDueDate(){
        return newExaminationDueDate;
    }

    public void setNewExaminationDueDate(Date newExaminationDueDate){
        this.newExaminationDueDate = newExaminationDueDate;
    }

    public String getLastExaminationServerId() {
        return lastExaminationServerId;
    }

    public String getLastExaminationId() {
        return lastExaminationId;
    }

    public String getNewExaminationDue() {
        return newExaminationDue;
    }

    public String getMessageKey() {
        return messageKey;
    }

    public Date getLastExaminationDate() {
        return lastExaminationDate;
    }

    public String getNewExaminationDueDateMinus() {
        try{
            return new SimpleDateFormat("dd-MM-yyyy").format(newExaminationDueDate);
        }
        catch (Exception e){
            e.printStackTrace();
        }
        return null;
    }

    public String getHealthRecordId() {
        return healthRecordId;
    }

    public String getLastExamination() {
        return lastExamination;
    }

    public String getTransactionType() {
        return transactionType;
    }

    public void setTransactionType(String transactionType) {
        this.transactionType = transactionType;
        findLastExamination();
    }

    public void setLastExaminationDate(Date lastExaminationDate) {
        this.lastExaminationDate = lastExaminationDate;
    }

    public void setLastExaminationId(String lastExaminationId) {
        this.lastExaminationId = lastExaminationId;
    }

    public void setNewExaminationDue(String newExaminationDue) {
        this.newExaminationDue = newExaminationDue;
    }

    public void setHealthRecordId(String healthRecordId) {
        this.healthRecordId = healthRecordId;
    }

    public void setLastExamination(String lastExamination) {
        this.lastExamination = lastExamination;
    }

    public void setMessageKey(String messageKey) {
        this.messageKey = messageKey;
    }

    private void findPlannedExamination(){
        String tt = transactionType.split("&")[0];
        PlannedExamination plannedExamination = this.sessionContainerWO.getPlannedTransaction(tt);
        if(plannedExamination!=null){
            this.plannedExamination=plannedExamination;
        }
        else {
            this.plannedExamination=null;
        }
    }

    public PlannedExamination getPlannedExamination(){
        return plannedExamination;
    }

    private void findLastExamination(){
        String tt = transactionType.split("&")[0];
        TransactionVO transactionVO = this.sessionContainerWO.getLastTransaction(tt);
        if (transactionVO != null){
            lastExamination = new SimpleDateFormat("dd/MM/yyyy").format(transactionVO.getUpdateTime());
            lastExaminationDate = transactionVO.getUpdateTime();
            lastExaminationId = transactionVO.getTransactionId().toString();
            lastExaminationServerId = Integer.toString(transactionVO.getServerId());
            newExaminationDue = "";
        }
        else{
            lastExaminationDate = null;
            lastExamination="";
            lastExaminationId="";
            lastExaminationServerId="";
            newExaminationDue = "medwan.common.true";
        }
    }

    public boolean equals(Object o) {
        return this == o || o instanceof VerifiedExaminationVO;
    }

}
