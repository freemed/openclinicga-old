package be.dpms.medwan.common.model.vo.occupationalmedicine;

import java.io.Serializable;

/**
 * Created by IntelliJ IDEA.
 * User: Michaël
 * Date: 02-juil.-2003
 * Time: 13:38:23
 */
public class FunctionGroupExaminationVO implements Serializable {
    public int tolerance;
    public int frequency;
    public Integer functionGroupExaminationId;
    public ExaminationVO examination;

    public FunctionGroupExaminationVO(int tolerance, int frequency, Integer functionGroupExaminationId, ExaminationVO examination) {
        this.tolerance = tolerance;
        this.frequency = frequency;
        this.functionGroupExaminationId = functionGroupExaminationId;
        this.examination = examination;
    }

    public int getTolerance() {
        return tolerance;
    }

    public int getFrequency() {
        return frequency;
    }

    public Integer getFunctionGroupExaminationId() {
        return functionGroupExaminationId;
    }

    public ExaminationVO getExamination() {
        return examination;
    }

    public void setTolerance(int tolerance) {
        this.tolerance = tolerance;
    }

    public void setFrequency(int frequency) {
        this.frequency = frequency;
    }

    public void setFunctionGroupExaminationId(Integer functionGroupExaminationId) {
        this.functionGroupExaminationId = functionGroupExaminationId;
    }

    public void setExamination(ExaminationVO examination) {
        this.examination = examination;
    }
}
