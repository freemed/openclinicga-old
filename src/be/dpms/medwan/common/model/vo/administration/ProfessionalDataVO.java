package be.dpms.medwan.common.model.vo.administration;

import be.mxs.common.model.vo.administration.IProfessionalDataVO;
import java.sql.Timestamp;

public class ProfessionalDataVO implements IProfessionalDataVO {

    public Integer        workId;
    public Integer        personId;
    public String         telephone;
    public String         fax;
    public String         email;
    public String         comment;
    public String         rankId;
    public java.util.Date start;
    public java.util.Date stop;
    public Timestamp      updateTime;

    public ProfessionalDataVO() {
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

    public Timestamp getUpdateTime() {
        return updateTime;
    }

    public void setUpdateTime(Timestamp updateTime) {
        this.updateTime = updateTime;
    }

    public boolean equals(Object o) {
        if (this == o) return true;
        if (!(o instanceof ProfessionalDataVO)) return false;

        final ProfessionalDataVO userContainer = (ProfessionalDataVO) o;

        return personId.equals(userContainer.personId);

    }

    public int hashCode() {
        return personId.hashCode();
    }
}
