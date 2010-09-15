package be.dpms.medwan.webapp.wo.occupationalmedicine;

import be.mxs.common.model.vo.IIdentifiable;

import java.io.Serializable;
import java.util.Collection;

/**
 * User: Michaël
 * Date: 17-juin-2003
 */
public class RiskProfileExaminationInfoWO implements Serializable, IIdentifiable {

    private final Collection allExaminationsOptionBean;

    public RiskProfileExaminationInfoWO(Collection riskProfileExaminationsOptionBean) {
        this.allExaminationsOptionBean = riskProfileExaminationsOptionBean;
    }

    public Collection getAllExaminationsOptionBean() {
        return allExaminationsOptionBean;
    }

}


