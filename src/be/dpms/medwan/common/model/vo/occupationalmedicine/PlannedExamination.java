package be.dpms.medwan.common.model.vo.occupationalmedicine;

import java.util.Date;

public class PlannedExamination {
    String personId;
    String userId;
    Date plannedDate;
    Date effectiveDate;
    Date cancelationdate;
    String contactType;
    String contactUid;
    String transactionUid;
    String description;

    public String getTransactionUid() {
        return transactionUid;
    }

    public void setTransactionUid(String transactionUid) {
        this.transactionUid = transactionUid;
    }

    public String getPersonId() {
        return personId;
    }

    public void setPersonId(String personId) {
        this.personId = personId;
    }

    public String getUserId() {
        return userId;
    }

    public void setUserId(String userId) {
        this.userId = userId;
    }

    public Date getPlannedDate() {
        return plannedDate;
    }

    public void setPlannedDate(Date plannedDate) {
        this.plannedDate = plannedDate;
    }

    public Date getEffectiveDate() {
        return effectiveDate;
    }

    public void setEffectiveDate(Date effectiveDate) {
        this.effectiveDate = effectiveDate;
    }

    public Date getCancelationdate() {
        return cancelationdate;
    }

    public void setCancelationdate(Date cancelationdate) {
        this.cancelationdate = cancelationdate;
    }

    public String getContactType() {
        return contactType;
    }

    public void setContactType(String contactType) {
        this.contactType = contactType;
    }

    public String getContactUid() {
        return contactUid;
    }

    public void setContactUid(String contactUid) {
        this.contactUid = contactUid;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public PlannedExamination(String personId, String userId, Date plannedDate, Date effectiveDate, Date cancelationdate, String contactType, String contactUid, String transactionUid, String description) {
        this.personId = personId;
        this.userId = userId;
        this.plannedDate = plannedDate;
        this.effectiveDate = effectiveDate;
        this.cancelationdate = cancelationdate;
        this.contactType = contactType;
        this.contactUid = contactUid;
        this.transactionUid = transactionUid;
        this.description = description;
    }
}
