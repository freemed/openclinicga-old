package be.dpms.medwan.common.model.vo.occupationalmedicine;

import be.mxs.common.model.vo.IIdentifiable;

import java.io.Serializable;

/**
 * Created by IntelliJ IDEA.
 * User: Michaël
 * Date: 10-juin-2003
 * Time: 14:56:50
 */
public class PersonalExaminationVO implements Serializable, IIdentifiable {
    public String personId;
    public Integer examinationId;
    public Integer frequency;
    public Integer tolerance;
    public ExaminationVO examinationVO;

    public PersonalExaminationVO(String personId, Integer examinationId, Integer frequency, Integer tolerance, ExaminationVO examinationVO) {
        this.personId = personId;
        this.examinationId = examinationId;
        this.frequency = frequency;
        this.tolerance = tolerance;
        this.examinationVO = examinationVO;
    }

    public String getPersonId() {
        return personId;
    }

    public Integer getExaminationId() {
        return examinationId;
    }

    public Integer getFrequency() {
        return frequency;
    }

    public Integer getTolerance() {
        return tolerance;
    }

    public ExaminationVO getExaminationVO() {
        return examinationVO;
    }

    public void setPersonId(String personId) {
        this.personId = personId;
    }

    public void setExaminationId(Integer examinationId) {
        this.examinationId = examinationId;
    }

    public void setFrequency(Integer frequency) {
        this.frequency = frequency;
    }

    public void setTolerance(Integer tolerance) {
        this.tolerance = tolerance;
    }

    public void setExaminationVO(ExaminationVO examinationVO) {
        this.examinationVO = examinationVO;
    }

    public boolean equals(Object o) {
        if (this == o) return true;
        if (!(o instanceof PersonalExaminationVO)) return false;

        final PersonalExaminationVO personalExaminationVO = (PersonalExaminationVO) o;

        return examinationId.equals(personalExaminationVO.examinationId) && personId.equals(personalExaminationVO.personId);

    }

    public int hashCode() {
        int result;
        result = personId.hashCode();
        result = 29 * result + examinationId.hashCode();
        return result;
    }
}
