package be.dpms.medwan.webapp.wo.occupationalmedicine;

import be.dpms.medwan.common.model.vo.occupationalmedicine.RiskProfileRiskCodeVO;
import be.dpms.medwan.common.model.vo.occupationalmedicine.RiskCodeVO;
import be.mxs.common.model.vo.IIdentifiable;
import be.mxs.common.util.db.MedwanQuery;

import java.io.Serializable;

public class RiskProfileRiskCodeWO implements Serializable, IIdentifiable, Comparable {
    public RiskProfileRiskCodeVO riskProfileRiskCodeVO;
    public RiskCodeVO riskCodeVO;

    public int compareTo(Object o){
        int comp;
        if (o.getClass().isInstance(this)){
            comp = this.getRiskCodeVO().getLabel().compareTo(((RiskProfileRiskCodeWO)o).getRiskCodeVO().getLabel());
        }
        else {
            throw new ClassCastException();
        }
        return comp;
    }

    public RiskProfileRiskCodeWO(RiskProfileRiskCodeVO riskProfileRiskCodeVO,String language) {
        this.riskProfileRiskCodeVO = riskProfileRiskCodeVO;
        this.riskCodeVO = MedwanQuery.getInstance().findRiskCode(riskProfileRiskCodeVO.riskCodeId.toString(),language);
    }

    public RiskProfileRiskCodeVO getRiskProfileRiskCodeVO(){
        return riskProfileRiskCodeVO;
    }
    public RiskCodeVO getRiskCodeVO(){
        return riskCodeVO;
    }
}
