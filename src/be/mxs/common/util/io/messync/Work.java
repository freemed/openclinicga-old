package be.mxs.common.util.io.messync;

import org.w3c.dom.Node;

import java.util.Vector;

/**
 * Created by IntelliJ IDEA.
 * User: MXS
 * Date: 21-mrt-2005
 * Time: 16:22:52
 * To change this template use Options | File Templates.
 */
public class Work {
    private String begin, end, status, statussituation, companybegin
    , companyend, companyendreason, category;
    private Vector workUnits, functions;

    public Work() {
        this.begin = "";
        this.end = "";
        this.status = "";
        this.statussituation = "";
        this.companybegin = "";
        this.companyend = "";
        this.companyendreason = "";
        this.category = "";
        this.workUnits = new Vector();
        this.functions = new Vector();
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

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public String getStatussituation() {
        return statussituation;
    }

    public void setStatussituation(String statussituation) {
        this.statussituation = statussituation;
    }

    public String getCompanybegin() {
        return companybegin;
    }

    public void setCompanybegin(String companybegin) {
        this.companybegin = companybegin;
    }

    public String getCompanyend() {
        return companyend;
    }

    public void setCompanyend(String companyend) {
        this.companyend = companyend;
    }

    public String getCompanyendreason() {
        return companyendreason;
    }

    public void setCompanyendreason(String companyendreason) {
        this.companyendreason = companyendreason;
    }

    public String getCategory() {
        return category;
    }

    public void setCategory(String category) {
        this.category = category;
    }

    public Vector getWorkUnits() {
        return workUnits;
    }

    public void setWorkUnits(Vector workUnits) {
        this.workUnits = workUnits;
    }

    public Vector getFunctions() {
        return functions;
    }

    public void setFunctions(Vector functions) {
        this.functions = functions;
    }

    public void addWorkUnit(WorkUnit workUnit){
        if (workUnit!=null){
            if (this.workUnits == null){
                this.workUnits = new Vector();
            }
            this.workUnits.add(workUnit);
        }
    }

    public void addFunction(Function function){
        if (function!=null){
            if (this.functions == null){
                this.functions = new Vector();
            }
            this.functions.add(function);
        }
    }
    public void parse (Node n) {
        this.begin = Helper.getAttribute(n,"begin");
        this.end = Helper.getAttribute(n,"end");
        this.status = Helper.getAttribute(n,"status");
        this.statussituation = Helper.getAttribute(n,"statussituation");
        this.companybegin = Helper.getAttribute(n,"companybegin");
        this.companyend = Helper.getAttribute(n,"companyend");
        this.companyendreason = Helper.getAttribute(n,"companyendreason");
        this.category = Helper.getAttribute(n,"category");

        if (n.hasChildNodes()) {
            WorkUnit workUnit;
            Function function;

            for (Node child = n.getFirstChild(); child != null; child = child.getNextSibling()) {
                if (child.getNodeName().toLowerCase().equals("workunit")) {
                    workUnit = new WorkUnit();
                    workUnit.parse(child);
                    this.workUnits.add(workUnit);
                }
                else if (child.getNodeName().toLowerCase().equals("function")) {
                    function = new Function();
                    function.parse(child);
                    this.functions.add(function);
                }
            }
        }
    }

    public String toXML(int iIndent) {
        String sReturn = Helper.beginTag(this.getClass().getName(),iIndent)
            +Helper.writeTagAttribute("Begin",this.begin)
            +Helper.writeTagAttribute("End",this.end)
            +Helper.writeTagAttribute("Status",this.status)
            +Helper.writeTagAttribute("StatusSituation",this.statussituation)
            +Helper.writeTagAttribute("CompanyBegin",this.companybegin)
            +Helper.writeTagAttribute("CompanyEnd",this.companyend)
            +Helper.writeTagAttribute("CompanyendReason",this.companyendreason)
            +Helper.writeTagAttribute("Category",this.category)
            +">\r\n";
        for (int i=0; i<workUnits.size();i++) {
          sReturn += ((WorkUnit)(workUnits.elementAt(i))).toXML(iIndent+1);
        }
        for (int i=0; i<functions.size();i++) {
          sReturn += ((Function)(functions.elementAt(i))).toXML(iIndent+1);
        }

        return sReturn+Helper.endTag(this.getClass().getName(),iIndent);
    }
}
