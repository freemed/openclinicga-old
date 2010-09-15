package be.mxs.common.model.vo.healthrecord;

import be.dpms.medwan.common.model.vo.administration.PersonVO;
import be.mxs.common.model.vo.IIdentifiable;

import java.io.Serializable;
import java.util.Collection;
import java.util.Vector;

public class PersonalVaccinationsInfoVO implements Serializable, IIdentifiable {

    private PersonVO personVO;
    private Collection vaccinationsInfoVO = new Vector();
    private Collection otherVaccinations = new Vector();

    public PersonalVaccinationsInfoVO(PersonVO personVO, Collection vaccinationsInfoVO, Collection otherVaccinations) {
        this.personVO = personVO;
        if (vaccinationsInfoVO != null) this.vaccinationsInfoVO = vaccinationsInfoVO;
        if (otherVaccinations != null) this.otherVaccinations = otherVaccinations;
    }

    public PersonVO getPersonVO() {
        return personVO;
    }


    public void setPersonVO(PersonVO personVO) {
        this.personVO = personVO;
    }


    public Collection getVaccinationsInfoVO() {
        return vaccinationsInfoVO;
    }

    public void setVaccinationsInfoVO(Collection vaccinationsInfoVO) {
        this.vaccinationsInfoVO = vaccinationsInfoVO;
    }

    public Collection getOtherVaccinations() {
        return otherVaccinations;
    }

    public void setOtherVaccinations(Collection otherVaccinations) {
        this.otherVaccinations = otherVaccinations;
    }

    public int hashCode() {
        return personVO.getPersonId().hashCode();
    }


}
