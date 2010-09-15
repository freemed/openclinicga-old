package be.mxs.common.util.io.messync;

import org.w3c.dom.Node;

import java.util.Vector;

/**
 * Created by IntelliJ IDEA.
 * User: MXS
 * Date: 21-mrt-2005
 * Time: 16:24:06
 * To change this template use Options | File Templates.
 */
public class Medical {
    private String begin, end, interval, comment;
    private Vector risks, examinations;

    public Medical() {
        this.begin = "";
        this.end = "";
        this.interval = "";
        this.comment = "";
        this.risks = new Vector();
        this.examinations = new Vector();
    }

    public String getBegin() {
        return begin;
    }

    public void setBegin(String begin) {
        this.begin = begin;
    }

    public String getEnd() {
        return end;
    }

    public void setEnd(String end) {
        this.end = end;
    }

    public String getInterval() {
        return interval;
    }

    public void setInterval(String interval) {
        this.interval = interval;
    }

    public String getComment() {
        return comment;
    }

    public void setComment(String comment) {
        this.comment = comment;
    }

    public Vector getRisks() {
        return risks;
    }

    public void setRisks(Vector risks) {
        this.risks = risks;
    }

    public Vector getExaminations() {
        return examinations;
    }

    public void setExaminations(Vector examinations) {
        this.examinations = examinations;
    }

    public void addRisk(Risk risk){
        if (risk!=null){
            if (this.risks == null){
                this.risks = new Vector();
            }
            this.risks.add(risk);
        }
    }

    public void addExamination(Examination examination){
        if (examination!=null){
            if (this.examinations == null){
                this.examinations = new Vector();
            }
            this.examinations.add(examination);
        }
    }

    public void parse (Node n) {
        this.begin = Helper.getAttribute(n,"begin");
        this.end = Helper.getAttribute(n,"end");
        this.interval = Helper.getAttribute(n,"interval");
        this.comment = Helper.getAttribute(n,"comment");

        if (n.hasChildNodes()) {
            Risk risk;
            Examination examination;
            for (Node child = n.getFirstChild(); child != null; child = child.getNextSibling()) {
                if (child.getNodeName().toLowerCase().equals("risk")) {
                    risk = new Risk();
                    risk.parse(child);
                    this.risks.add(risk);
                }
                else if (child.getNodeName().toLowerCase().equals("examination")) {
                    examination = new Examination();
                    examination.parse(child);
                    this.examinations.add(examination);
                }
            }
        }
    }

    public String toXML(int iIndent) {
        String sReturn = Helper.beginTag(this.getClass().getName(),iIndent)
            +Helper.writeTagAttribute("Begin",this.begin)
            +Helper.writeTagAttribute("End",this.end)
            +Helper.writeTagAttribute("Interval",this.interval)
            +Helper.writeTagAttribute("Comment",this.comment)
            +">\r\n";
        for (int i=0; i<risks.size();i++) {
          sReturn += ((Risk)(risks.elementAt(i))).toXML(iIndent+1);
        }
        for (int i=0; i<examinations.size();i++) {
          sReturn += ((Examination)(examinations.elementAt(i))).toXML(iIndent+1);
        }

        return sReturn+Helper.endTag(this.getClass().getName(),iIndent);
    }
}
