package be.openclinic.statistics.chin;

import org.dom4j.Element;

import java.util.Vector;
import java.util.Iterator;

/**
 * User: Frank Verbeke
 * Date: 30-jul-2007
 * Time: 8:18:40
 */
public class DiagnosisTrend extends Indicator{
    private int duration;
    private String codetype;
    private String code;
    private Vector alerts=new Vector();

    public int getPeriod() {
        return duration;
    }

    public void setPeriod(int period) {
        this.duration = period;
    }

    public String getCodetype() {
        return codetype;
    }

    public void setCodetype(String codetype) {
        this.codetype = codetype;
    }

    public String getCode() {
        return code;
    }

    public void setCode(String code) {
        this.code = code;
    }

    public Vector getAlerts() {
        return alerts;
    }

    public void setAlerts(Vector alerts) {
        this.alerts = alerts;
    }

    public DiagnosisTrend(Element indicator){
        super(indicator);
        Element diagnosis = indicator.element("diagnosis");
        codetype=diagnosis.attributeValue("codetype");
        code=diagnosis.attributeValue("code");
        duration=Integer.parseInt(diagnosis.attributeValue("duration"));
        Iterator iAlerts = indicator.elementIterator("alert");
        while (iAlerts.hasNext()){
            Element thisAlert=(Element)iAlerts.next();
            Alert alert = new Alert(thisAlert.attributeValue("type"),Integer.parseInt(thisAlert.attributeValue("timeunit")),Double.parseDouble(thisAlert.attributeValue("level")),thisAlert.attributeValue("destination"));
            alerts.add(alert);
        }
    }

    public void analyse(){
        for(int n=0;n<alerts.size();n++){
            Alert alert=(Alert)alerts.elementAt(n);
            alert.analyse(duration,codetype,code);
        }
    }
}
