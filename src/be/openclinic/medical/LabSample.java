package be.openclinic.medical;

import java.util.Date;
import java.util.Vector;


public class LabSample {
    public int id;
    public String type;
    public Date sampleDate;
    public Date receptionDate;
    public int sampler;
    public Vector analyses=new Vector();
}
