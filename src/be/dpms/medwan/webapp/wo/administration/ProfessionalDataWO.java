package be.dpms.medwan.webapp.wo.administration;

import be.mxs.common.model.vo.IValueObject;

public class ProfessionalDataWO implements IValueObject {

    private Integer             workId;
    private Integer             personId;
    private String              telephone;
    private String              fax;
    private String              email;
    private String              comment;
    private String              rankId;
    private java.util.Date      start;
    private java.util.Date      stop;
    private java.sql.Timestamp  updateTime;

    public ProfessionalDataWO() {
    }

    public Integer getWorkId() {
        return workId;
    }

    public void setWorkId(Integer workId) {
        this.workId = workId;
    }

    public Integer getPersonId() {
        return personId;
    }

    public void setPersonId(Integer personId) {
        this.personId = personId;
    }

    public String getTelephone() {
        return telephone;
    }

    public void setTelephone(String telephone) {
        this.telephone = telephone;
    }

    public String getFax() {
        return fax;
    }

    public void setFax(String fax) {
        this.fax = fax;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public String getComment() {
        return comment;
    }

    public void setComment(String comment) {
        this.comment = comment;
    }

    public String getRankId() {
        return rankId;
    }

    public void setRankId(String rankId) {
        this.rankId = rankId;
    }

    public java.util.Date getStart() {
        return start;
    }

    public void setStart(java.util.Date start) {
        this.start = start;
    }

    public java.util.Date getStop() {
        return stop;
    }

    public void setStop(java.util.Date stop) {
        this.stop = stop;
    }

    public java.sql.Timestamp getUpdateTime() {
        return updateTime;
    }

    public void setUpdateTime(java.sql.Timestamp updateTime) {
        this.updateTime = updateTime;
    }

    public boolean equals(Object o) {
        if (this == o) return true;
        if (!(o instanceof ProfessionalDataWO)) return false;

        final ProfessionalDataWO userContainer = (ProfessionalDataWO) o;

        return personId.equals(userContainer.personId);

    }

    public int hashCode() {
        return personId.hashCode();
    }
}
