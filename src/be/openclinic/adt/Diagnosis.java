package be.openclinic.adt;

import be.openclinic.common.OC_Object;
import net.admin.AdminPerson;

import java.util.Date;

/**
 * Created by IntelliJ IDEA.
 * User: Frank Verbeke
 * Date: 10-sep-2006
 * Time: 21:32:46
 * To change this template use Options | File Templates.
 */
public class Diagnosis extends OC_Object{
    private Encounter encounter;
    private String code;
    private AdminPerson author;
    private int certainty;
    private int gravity;
    private Date date;

    public Encounter getEncounter() {
        return encounter;
    }

    public void setEncounter(Encounter encounter) {
        this.encounter = encounter;
    }

    public String getCode() {
        return code;
    }

    public void setCode(String code) {
        this.code = code;
    }

    public AdminPerson getAuthor() {
        return author;
    }

    public void setAuthor(AdminPerson author) {
        this.author = author;
    }

    public int getCertainty() {
        return certainty;
    }

    public void setCertainty(int certainty) {
        this.certainty = certainty;
    }

    public int getGravity() {
        return gravity;
    }

    public void setGravity(int gravity) {
        this.gravity = gravity;
    }

    public Date getDate() {
        return date;
    }

    public void setDate(Date date) {
        this.date = date;
    }
}
