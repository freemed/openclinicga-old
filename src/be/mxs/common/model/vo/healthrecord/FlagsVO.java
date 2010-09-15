package be.mxs.common.model.vo.healthrecord;
import be.dpms.medwan.common.model.vo.occupationalmedicine.VerifiedExaminationVO;

import java.io.Serializable;

public class FlagsVO implements Serializable {

    private String overalVaccinationStatus = "";
    private VerifiedExaminationVO lastDrivingCertificate = null;
    private VerifiedExaminationVO lastExaminationReport = null;
    private VerifiedExaminationVO lastAO = null;
    private String recruitmentCycloDue = "";
    private float age=0;
    private String department = "";
    private String context = "";

    public String getDepartment(){
        return department;
    }

    public void setDepartment(String department){
        this.department=department;
    }

    public String getContext(){
        return context;
    }

    public void setContext(String context){
        this.context=context;
    }

    public String getAge(){
        return Integer.toString(new Float(age).intValue());
    }

    public String getAgeDecimal(){
        return Float.toString(age);
    }

    public String getOveralVaccinationStatus() {
        return overalVaccinationStatus;
    }

    public String getRecruitmentCycloDue() {
        return recruitmentCycloDue;
    }

    public VerifiedExaminationVO getLastDrivingCertificate() {
        return lastDrivingCertificate;
    }

    public VerifiedExaminationVO getLastAO() {
        return lastAO;
    }

    public VerifiedExaminationVO getLastExaminationReport() {
        return lastExaminationReport;
    }

    public void setOveralVaccinationStatus(String status) {
        overalVaccinationStatus = status;
    }

    public void setRecruitmentCycloDue(String status) {
        recruitmentCycloDue = status;
    }

    public void setLastDrivingCertificate(VerifiedExaminationVO certificate){
        lastDrivingCertificate = certificate;
    }
    public void setLastAO(VerifiedExaminationVO ao){
        lastAO = ao;
    }

    public void setLastExaminationReport(VerifiedExaminationVO report){
        lastExaminationReport = report;
    }

    public void setAge(float age){
        this.age = age;
    }
}

