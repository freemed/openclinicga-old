package be.dpms.medwan.webapp.wo.occupationalmedicine;

import be.mxs.common.model.vo.IIdentifiable;

import java.io.Serializable;
import java.util.Collection;

/**
 * User: Michaël
 * Date: 17-juin-2003
 */
public class RiskProfileRisksInfoWO implements Serializable, IIdentifiable {

    private final Collection allRiskCodesOptionBean;

    public RiskProfileRisksInfoWO(Collection riskProfileRiskCodesOptionBean) {
        this.allRiskCodesOptionBean = riskProfileRiskCodesOptionBean;
    }

    public Collection getAllRiskCodesOptionBean() {
        return allRiskCodesOptionBean;
    }

}


