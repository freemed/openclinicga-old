package be.dpms.medwan.common.model.vo.recruitment;


import java.io.Serializable;
import java.util.Date;

/**
 * Created by IntelliJ IDEA.
 * User: Michaël
 * Date: 30-sept.-2003
 * Time: 16:36:00
 */
public class ConvocationVO implements Serializable {
    private final int convocationId;
    private final int personId;
    private final String natreg;
    private final String firstname;
    private final String lastname;
    private final Date invitationDateTime;
    private final Date visitDateTime;
    private final String status;
    private final String comment;
    private final Date updateTime;
    private String decision = "";

    public ConvocationVO(int convocationId, int personId, String natreg, String firstname, String lastname, Date invitationDateTime, Date visitDateTime, String status, String comment, Date updateTime) {
        this.convocationId = convocationId;
        this.personId = personId;
        this.natreg = natreg;
        this.firstname = firstname;
        this.lastname = lastname;
        this.invitationDateTime = invitationDateTime;
        this.visitDateTime = visitDateTime;
        this.status = status;
        this.comment = comment;
        this.updateTime = updateTime;
    }

    public ConvocationVO(int convocationId, int personId, String natreg, String firstname, String lastname, Date invitationDateTime, Date visitDateTime, String status, String comment, Date updateTime, String decision) {
        this.convocationId = convocationId;
        this.personId = personId;
        this.natreg = natreg;
        this.firstname = firstname;
        this.lastname = lastname;
        this.invitationDateTime = invitationDateTime;
        this.visitDateTime = visitDateTime;
        this.status = status;
        this.comment = comment;
        this.updateTime = updateTime;
        this.decision = decision;
    }

    public int getConvocationId() {
        return convocationId;
    }

    public Date getUpdateTime() {
        return updateTime;
    }

    public int getPersonId() {
        return personId;
    }

    public Date getInvitationDateTime() {
        return invitationDateTime;
    }

    public Date getVisitDateTime() {
        return visitDateTime;
    }

    public String getStatus() {
        return status;
    }

    public String getDecision() {
        return decision;
    }

    public String getComment() {
        return comment;
    }

    public String getNatreg() {
        return natreg;
    }

    public String getFirstname() {
        return firstname;
    }

    public String getLastname() {
        return lastname;
    }

}
