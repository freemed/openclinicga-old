package be.dpms.medwan.webapp.wo.authentication;

import be.mxs.common.model.vo.IValueObject;
import be.dpms.medwan.webapp.wo.administration.PersonWO;

/**
 * Created by IntelliJ IDEA.
 * User: Michaël
 * Date: 10-avr.-2003
 * Time: 11:15:19
 * To change this template use Options | File Templates.
 */
public class UserWO implements IValueObject {

    private Integer             userId;
    private Integer             personId;
    private String              password;
    private java.util.Date      start;
    private java.util.Date      stop;
    private java.util.Date      updateTime;

    private PersonWO            person          = null;           // Administrative data (private & private)

    public UserWO() {
    }

    public Integer getUserId() {
        return userId;
    }

    public void setUserId(Integer userId) {
        this.userId = userId;
    }

    public PersonWO getPerson() {
        return person;
    }

    public void setPerson(PersonWO person) {
        this.person = person;
    }

    public Integer getPersonId() {
        return personId;
    }

    public void setPersonId(Integer personId) {
        this.personId = personId;
    }

    public String getPassword() {
        return password;
    }

    public void setPassword(String password) {
        this.password = password;
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

    public java.util.Date getUpdateTime() {
        return updateTime;
    }

    public void setUpdateTime(java.util.Date updateTime) {
        this.updateTime = updateTime;
    }
}
