package be.dpms.medwan.webapp.wo.healthrecord;

import be.dpms.medwan.webapp.wo.administration.PersonWO;

/**
 * Created by IntelliJ IDEA.
 * User: Michaël
 * Date: 24-avr.-2003
 * Time: 12:03:40
 * To change this template use Options | File Templates.
 */
public class HealthRecordWO {

    private PersonWO person;

    public HealthRecordWO(PersonWO person) {
        this.person = person;
    }

    public PersonWO getPerson() {
        return person;
    }

    public void setPerson(PersonWO person) {
        this.person = person;
    }

}
