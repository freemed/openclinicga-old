package be.dpms.medwan.common.model.vo.administration;

import be.mxs.common.model.vo.IIdentifiable;
import be.openclinic.common.IObjectReference;

import java.io.Serializable;
import java.util.Date;

public class PersonVO extends IObjectReference implements Serializable, IIdentifiable {
    public static Integer INVALID_PERSON_VO = new Integer(-1);
    public String natreg;
    public String immatOld;
    public String immatNew;
    public String candidate;
    public String lastname;
    public String firstname;
    public String gender;
    public String language;
    public Integer personId;
    public Date dateofbirth;

    public PersonVO(String natreg, String immatOld, String immatNew, String candidate, String lastname, String firstname, String gender, String language, Integer personid) {
        this.natreg = natreg;
        this.immatOld = immatOld;
        this.immatNew = immatNew;
        this.candidate = candidate;
        this.lastname = lastname;
        this.firstname = firstname;
        this.gender = gender;
        this.language = language;
        this.personId = personid;
    }

    public String getObjectType(){
        return "Person";
    }

    public String getFullName(){
        return firstname+" "+lastname;
    }

    public String getObjectUid(){
        return getPersonId()+"";
    }

    public Date getDateofbirth() {
        return dateofbirth;
    }

    public void setDateofbirth(Date dateofbirth) {
        this.dateofbirth = dateofbirth;
    }

    public String getNatreg() {
        return natreg;
    }

    public String getImmatOld() {
        return immatOld;
    }

    public String getImmatNew() {
        return immatNew;
    }

    public String getCandidate() {
        return candidate;
    }

    public String getLastname() {
        return lastname;
    }

    public String getFirstname() {
        return firstname;
    }

    public String getGender() {
        return gender;
    }

    public String getLanguage() {
        return language;
    }

    public Integer getPersonId() {
        return personId;
    }

    public static void setINVALID_PERSON_VO(Integer INVALID_PERSON_VO) {
        PersonVO.INVALID_PERSON_VO = INVALID_PERSON_VO;
    }

    public void setNatreg(String natreg) {
        this.natreg = natreg;
    }

    public void setImmatOld(String immatOld) {
        this.immatOld = immatOld;
    }

    public void setImmatNew(String immatNew) {
        this.immatNew = immatNew;
    }

    public void setCandidate(String candidate) {
        this.candidate = candidate;
    }

    public void setLastname(String lastname) {
        this.lastname = lastname;
    }

    public void setFirstname(String firstname) {
        this.firstname = firstname;
    }

    public void setGender(String gender) {
        this.gender = gender;
    }

    public void setLanguage(String language) {
        this.language = language;
    }

    public void setPersonId(Integer personId) {
        this.personId = personId;
    }

    public boolean equals(Object o) {
        if (this == o) return true;
        if (!(o instanceof PersonVO)) return false;

        PersonVO personVO = (PersonVO) o;

        return personId.equals(personVO.personId);

    }

    public int hashCode() {
        return personId.hashCode();
    }
}
