package be.dpms.medwan.common.model.vo.occupationalmedicine;

import be.mxs.common.model.vo.IIdentifiable;
import be.mxs.common.util.db.MedwanQuery;
import be.dpms.medwan.webapp.wo.occupationalmedicine.RiskProfileRiskCodeWO;

import java.io.Serializable;
import java.util.*;


/**
 * User: Michaël
 * Date: 17-juin-2003
 */
public class RiskProfileVO implements Serializable, IIdentifiable {
    public Date dateBegin;
    public Date dateEnd;
    public Long personId;
    public Integer profileId;

    public Collection riskProfileContexts;
    public Collection riskProfileItems;

    public Collection riskProfileExaminations;
    public Collection riskCodes;

    public Vector systemRiskProfileExaminationsVO;
    public Vector systemRiskProfileRiskCodesVO;

    public Vector personalRiskProfileExaminationsVO;
    public Vector personalRiskProfileRiskCodesVO;


    public Collection riskProfileWorkplaces;
    public Collection riskProfileFunctionCategories;
    public Collection riskProfileFunctionGroups;

    public RiskProfileLabAnalysisVO riskProfileLabAnalysisVO=new RiskProfileLabAnalysisVO();

    public RiskProfileVO(Date dateBegin, Date dateEnd, Long personId, Integer profileId, Collection riskProfileContexts, Collection riskProfileItems, Collection riskProfileExaminations, Collection riskCodes, Vector systemRiskProfileExaminationsVO, Vector systemRiskProfileRiskCodesVO, Vector personalRiskProfileExaminationsVO, Vector personalRiskProfileRiskCodesVO, Collection riskProfileWorkplaces, Collection riskProfileFunctionCategories, Collection riskProfileFunctionGroups) {
        this.dateBegin = dateBegin;
        this.dateEnd = dateEnd;
        this.personId = personId;
        this.profileId = profileId;
        this.riskProfileContexts = riskProfileContexts;
        this.riskProfileItems = riskProfileItems;
        this.riskProfileExaminations = riskProfileExaminations;
        this.riskCodes = riskCodes;
        this.systemRiskProfileExaminationsVO = systemRiskProfileExaminationsVO;
        this.systemRiskProfileRiskCodesVO = systemRiskProfileRiskCodesVO;
        this.personalRiskProfileExaminationsVO = personalRiskProfileExaminationsVO;
        this.personalRiskProfileRiskCodesVO = personalRiskProfileRiskCodesVO;
        this.riskProfileWorkplaces = riskProfileWorkplaces;
        this.riskProfileFunctionCategories = riskProfileFunctionCategories;
        this.riskProfileFunctionGroups = riskProfileFunctionGroups;
    }

    public double getRiskProfileFrequency(){
        double frequency=-1;
        RiskProfileExaminationVO examination;
        for (int n=0;n<riskProfileExaminations.size();n++){
            examination = (RiskProfileExaminationVO)((Vector)riskProfileExaminations).elementAt(n);
            if (frequency==-1 || (examination.getPersonalFrequency()>0 && examination.getPersonalFrequency()<frequency)){
                frequency=examination.getPersonalFrequency();
            }
        }
        return frequency;
    }

    public RiskProfileLabAnalysisVO getRiskProfileLabAnalysisVO(){
        return riskProfileLabAnalysisVO;
    }

    public void setRiskProfileLabAnalysisVO(RiskProfileLabAnalysisVO riskProfileLabAnalysisVO){
        this.riskProfileLabAnalysisVO=riskProfileLabAnalysisVO;
    }

    public Hashtable getRiskCodesTable(){
        Hashtable hashTable=new Hashtable();
        for (int n=0;n<riskCodes.size();n++){
            RiskProfileRiskCodeVO code=(RiskProfileRiskCodeVO)((Vector)riskCodes).elementAt(n);
            if (!code.getStatusMessageKey().equalsIgnoreCase(be.dpms.medwan.common.model.IConstants.RISK_PROFILE_MESSSAGE_KEY_ITEM__STATUS_REMOVED)){
                hashTable.put(code.getCode(),((Vector)riskCodes).elementAt(n));
            }
        }
        return hashTable;
    }

    public boolean hasRiskCode(String code){
        for (int n=0;n<riskCodes.size();n++){
            if(((RiskProfileRiskCodeVO)(((Vector)riskCodes).elementAt(n))).getCode().equalsIgnoreCase(code)){
                return true;
            }
        }
        return false;
    }

    public boolean hasRiskcategory(String category){
        for (int n=0;n<riskCodes.size();n++){
            RiskProfileRiskCodeVO code = (RiskProfileRiskCodeVO)(((Vector)riskCodes).elementAt(n));
            if (!code.getStatusMessageKey().equalsIgnoreCase(be.dpms.medwan.common.model.IConstants.RISK_PROFILE_MESSSAGE_KEY_ITEM__STATUS_REMOVED)){
                if(MedwanQuery.getInstance().getRiskCategories().get(category.toLowerCase()+"."+code.getRiskCodeId())!=null){
                    return true;
                }
            }
        }
        return false;
    }

    public Date getDateBegin() {
        return dateBegin;
    }

    public Date getDateEnd() {
        return dateEnd;
    }

    public Long getPersonId() {
        return personId;
    }

    public Integer getProfileId() {
        return profileId;
    }

    public Collection getRiskProfileContexts() {
        return riskProfileContexts;
    }

    public Collection getRiskProfileItems() {
        return riskProfileItems;
    }

    public Collection getRiskProfileExaminations() {
        return riskProfileExaminations;
    }

    public Collection getRiskCodes() {
        return riskCodes;
    }

    public Collection getRiskCodesWO(String language) {
        Vector riskCodesWO = new Vector();
        for (int n=0; n<riskCodes.size(); n++){
            riskCodesWO.add(new RiskProfileRiskCodeWO((RiskProfileRiskCodeVO)(((Vector)riskCodes).elementAt(n)),language));
        }

        Collections.sort(riskCodesWO);
        return riskCodesWO;
    }

    public Collection getRiskProfileWorkplaces() {
        return riskProfileWorkplaces;
    }

    public Collection getRiskProfileFunctionCategories() {
        return riskProfileFunctionCategories;
    }

    public Collection getRiskProfileFunctionGroups() {
        return riskProfileFunctionGroups;
    }

    public Vector getSystemRiskProfileExaminationsVO() {
        return systemRiskProfileExaminationsVO;
    }

    public Vector getSystemRiskProfileRiskCodesVO() {
        return systemRiskProfileRiskCodesVO;
    }

    public Vector getPersonalRiskProfileExaminationsVO() {
        return personalRiskProfileExaminationsVO;
    }

    public Vector getPersonalRiskProfileRiskCodesVO() {
        return personalRiskProfileRiskCodesVO;
    }

    public void setDateBegin(Date dateBegin) {
        this.dateBegin = dateBegin;
    }

    public void setDateEnd(Date dateEnd) {
        this.dateEnd = dateEnd;
    }

    public void setPersonId(Long personId) {
        this.personId = personId;
    }

    public void setProfileId(Integer profileId) {
        this.profileId = profileId;
    }

    public void setRiskProfileContexts(Collection riskProfileContexts) {
        this.riskProfileContexts = riskProfileContexts;
    }

    public void setRiskProfileItems(Collection riskProfileItems) {
        this.riskProfileItems = riskProfileItems;
    }

    public void setRiskProfileExaminations(Collection riskProfileExaminations) {
        this.riskProfileExaminations = riskProfileExaminations;
    }

    public void setRiskCodes(Collection riskCodes) {
        this.riskCodes = riskCodes;
    }

    public void setSystemRiskProfileExaminationsVO(Vector systemRiskProfileExaminationsVO) {
        this.systemRiskProfileExaminationsVO = systemRiskProfileExaminationsVO;
    }

    public void setSystemRiskProfileRiskCodesVO(Vector systemRiskProfileRiskCodesVO) {
        this.systemRiskProfileRiskCodesVO = systemRiskProfileRiskCodesVO;
    }

    public void setPersonalRiskProfileExaminationsVO(Vector personalRiskProfileExaminationsVO) {
        this.personalRiskProfileExaminationsVO = personalRiskProfileExaminationsVO;
    }

    public void setPersonalRiskProfileRiskCodesVO(Vector personalRiskProfileRiskCodesVO) {
        this.personalRiskProfileRiskCodesVO = personalRiskProfileRiskCodesVO;
    }

    public void setRiskProfileWorkplaces(Collection riskProfileWorkplaces) {
        this.riskProfileWorkplaces = riskProfileWorkplaces;
    }

    public void setRiskProfileFunctionCategories(Collection riskProfileFunctionCategories) {
        this.riskProfileFunctionCategories = riskProfileFunctionCategories;
    }

    public void setRiskProfileFunctionGroups(Collection riskProfileFunctionGroups) {
        this.riskProfileFunctionGroups = riskProfileFunctionGroups;
    }

    public boolean equals(Object o) {
        if (this == o) return true;
        if (!(o instanceof RiskProfileVO)) return false;

        final RiskProfileVO riskProfileVO = (RiskProfileVO) o;

        return personId.equals(riskProfileVO.personId) && profileId.equals(riskProfileVO.profileId);

    }

    public int hashCode() {
        int result=0;
        if ((personId != null) && (profileId != null)){
            result = personId.hashCode();
            result = 29 * result + profileId.hashCode();
        }
        return result;
    }
}


