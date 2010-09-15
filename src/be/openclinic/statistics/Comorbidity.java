package be.openclinic.statistics;

/**
 * Created by IntelliJ IDEA.
 * User: Frank Verbeke
 * Date: 10-jul-2007
 * Time: 17:46:12
 * To change this template use File | Settings | File Templates.
 */
public class Comorbidity {
    public String diagnosisCode;
    public int cases;

    public Comorbidity(String diagnosisCode, int cases) {
        this.diagnosisCode = diagnosisCode;
        this.cases = cases;
    }
}
