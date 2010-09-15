package be.dpms.medwan.common.model.vo.occupationalmedicine;

import java.util.Hashtable;
import java.util.Vector;
import java.util.Enumeration;

/**
 * Created by IntelliJ IDEA.
 * User: frank
 * Date: 5-aug-2005
 * Time: 16:45:21
 */
public class RiskProfileLabAnalysisVO {
    private Hashtable analyses = new Hashtable();

    public RiskProfileLabAnalysisVO(){

    }

    public void addAnalysis(LabAnalysisVO analysis){
        LabAnalysisVO oldAnalysis = (LabAnalysisVO)analyses.get(analysis.getCode());
        if (oldAnalysis==null){
            analyses.put(analysis.getCode(),analysis);
        }
        else {
            if (analysis.getNextDate().before(oldAnalysis.getNextDate())){
                analyses.put(analysis.getCode(),analysis);
            }
        }
    }

    public Vector getAnalysis(){
        Vector allAnalyses = new Vector();
        Enumeration enumeration = analyses.elements();
        LabAnalysisVO labAnalysisVO;
        while (enumeration.hasMoreElements()){
            labAnalysisVO = (LabAnalysisVO)enumeration.nextElement();
            allAnalyses.add(labAnalysisVO);
        }
        return allAnalyses;
    }

    public Vector getDueAnalysis(java.util.Date date){
        Vector dueAnalyses = new Vector();
        Enumeration enumeration = analyses.elements();
        LabAnalysisVO labAnalysisVO;
        while (enumeration.hasMoreElements()){
            labAnalysisVO = (LabAnalysisVO)enumeration.nextElement();
            if (labAnalysisVO.getNextDate()!=null && labAnalysisVO.getNextDate().before(date)){
                dueAnalyses.add(labAnalysisVO);
            }
        }
        return dueAnalyses;
    }
}
