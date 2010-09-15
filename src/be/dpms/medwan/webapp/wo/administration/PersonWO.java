package be.dpms.medwan.webapp.wo.administration;

import be.mxs.common.model.vo.IValueObject;
import java.util.Date;

public class PersonWO implements IValueObject {

    private Integer                     personId;
    private String                      nationalNumber;
    private String                      matriculeNumberOld;
    private String                      matriculeNumberNew;
    private String                      candidateNumber;
    private String                      lastname;
    private String                      firstname;
    private String                      gender;
    private java.util.Date              dateOfBirth;
    private String                      comment;
    private String                      sourceId;
    private String                      language;
    private String                      engagement;
    private String                      pension;
    private java.util.Date              updateTime;
    private String                      statute;
    private String                      claimant;
    private String                      searchName;

    private ProfessionalDataWO          professionalData;

    public PersonWO() {
    }

    public Long getAge() {
        return new Long((new Date().getTime() - dateOfBirth.getTime()) / (1000*60*60*24*365));
    }

    public String getAgeString() {
        return getAge().toString();
    }

    public String getDisplayName(){

        return getFirstname() + " " + getLastname();
    }

    public Integer getPersonId() {
        return personId;
    }

    public void setPersonId(Integer personId) {
        this.personId = personId;
    }

    public String getNationalNumber() {
        return nationalNumber;
    }

    public void setNationalNumber(String nationalNumber) {
        this.nationalNumber = nationalNumber;
    }

    public String getMatriculeNumberOld() {
        return matriculeNumberOld;
    }

    public void setMatriculeNumberOld(String matriculeNumberOld) {
        this.matriculeNumberOld = matriculeNumberOld;
    }

    public String getMatriculeNumberNew() {
        return matriculeNumberNew;
    }

    public void setMatriculeNumberNew(String matriculeNumberNew) {
        this.matriculeNumberNew = matriculeNumberNew;
    }

    public String getCandidateNumber() {
        return candidateNumber;
    }

    public void setCandidateNumber(String candidateNumber) {
        this.candidateNumber = candidateNumber;
    }

    public String getLastname() {
        return lastname;
    }

    public void setLastname(String lastname) {
        this.lastname = lastname;
    }

    public String getFirstname() {
        return firstname;
    }

    public void setFirstname(String firstname) {
        this.firstname = firstname;
    }

    public String getGender() {
        return gender;
    }

    public void setGender(String gender) {
        this.gender = gender;
    }

    public java.util.Date getDateOfBirth() {
        return dateOfBirth;
    }

    public void setDateOfBirth(java.util.Date dateOfBirth) {
        this.dateOfBirth = dateOfBirth;
    }

    public String getComment() {
        return comment;
    }

    public void setComment(String comment) {
        this.comment = comment;
    }

    public String getSourceId() {
        return sourceId;
    }

    public void setSourceId(String sourceId) {
        this.sourceId = sourceId;
    }

    public String getLanguage() {
        return language;
    }

    public void setLanguage(String language) {
        this.language = language;
    }

    public String getEngagement() {
        return engagement;
    }

    public void setEngagement(String engagement) {
        this.engagement = engagement;
    }

    public String getPension() {
        return pension;
    }

    public void setPension(String pension) {
        this.pension = pension;
    }

    public java.util.Date getUpdateTime() {
        return updateTime;
    }

    public void setUpdateTime(java.util.Date updateTime) {
        this.updateTime = updateTime;
    }

    public String getStatute() {
        return statute;
    }

    public void setStatute(String statute) {
        this.statute = statute;
    }

    public String getClaimant() {
        return claimant;
    }

    public void setClaimant(String claimant) {
        this.claimant = claimant;
    }

    public String getSearchName() {
        return searchName;
    }

    public void setSearchName(String searchName) {
        this.searchName = searchName;
    }

    public ProfessionalDataWO getProfessionalData() {
        return professionalData;
    }

    public void setProfessionalData(ProfessionalDataWO professionalData) {
        this.professionalData = professionalData;
    }

    public boolean equals(Object o) {
        if (this == o) return true;
        if (!(o instanceof PersonWO)) return false;

        final PersonWO userContainer = (PersonWO) o;

        if (!personId.equals(userContainer.personId)) return false;

        return true;
    }

    public int hashCode() {
        return personId.hashCode();
    }
}
