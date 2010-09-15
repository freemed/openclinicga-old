package be.dpms.medwan.common.model.vo.occupationalmedicine;

import be.mxs.common.model.vo.IIdentifiable;

import java.io.Serializable;

/**
 * Created by IntelliJ IDEA.
 * User: Michaël
 * Date: 19-juin-2003
 * Time: 13:10:35
 */
public class RiskExaminationVO implements Serializable, IIdentifiable {
    public Integer riskExaminationId;
    public int frequency;
    public int tolerance;
    public ExaminationVO examination;

    public RiskExaminationVO(Integer riskExaminationId, int frequency, int tolerance, ExaminationVO examination) {
        this.riskExaminationId = riskExaminationId;
        this.frequency = frequency;
        this.tolerance = tolerance;
        this.examination = examination;
    }

    public Integer getRiskExaminationId() {
        return riskExaminationId;
    }

    public int getFrequency() {
        return frequency;
    }

    public int getTolerance() {
        return tolerance;
    }

    public ExaminationVO getExamination() {
        return examination;
    }

    public void setRiskExaminationId(Integer riskExaminationId) {
        this.riskExaminationId = riskExaminationId;
    }

    public void setFrequency(int frequency) {
        this.frequency = frequency;
    }

    public void setTolerance(int tolerance) {
        this.tolerance = tolerance;
    }

    public void setExamination(ExaminationVO examination) {
        this.examination = examination;
    }

    public boolean equals(Object o) {
        if (this == o) return true;
        if (!(o instanceof RiskExaminationVO)) return false;

        final RiskExaminationVO riskExaminationVO = (RiskExaminationVO) o;

        return riskExaminationId == riskExaminationVO.riskExaminationId;

    }

    public int hashCode() {
        return riskExaminationId.hashCode();
    }
}
