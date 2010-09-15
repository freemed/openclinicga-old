package be.dpms.medwan.webapp.wo.occupationalmedicine;

import be.mxs.common.model.vo.IIdentifiable;

import java.io.Serializable;
import java.util.Collection;

/**
 * User: Michaël
 * Date: 17-juin-2003
 */
public class RiskProfileSystemInfoWO implements Serializable, IIdentifiable {

    private final Collection allWorkplacesOptionBean;
    private final Collection allFunctionCategoriesOptionBean;
    private final Collection allFunctionGroupsOptionBean;
    private String comment;

    public RiskProfileSystemInfoWO(Collection riskProfileWorkplacesOptionBean, Collection riskProfileFunctionCategoriesOptionBean, Collection riskProfileFunctionGroupsOptionBean) {
        this.allWorkplacesOptionBean = riskProfileWorkplacesOptionBean;
        this.allFunctionCategoriesOptionBean = riskProfileFunctionCategoriesOptionBean;
        this.allFunctionGroupsOptionBean = riskProfileFunctionGroupsOptionBean;
    }

    public Collection getAllWorkplacesOptionBean() {
        return allWorkplacesOptionBean;
    }

    public Collection getAllFunctionCategoriesOptionBean() {
        return allFunctionCategoriesOptionBean;
    }

    public Collection getAllFunctionGroupsOptionBean() {
        return allFunctionGroupsOptionBean;
    }

    public void setComment(String comment){
        this.comment = comment;
    }

    public String getComment(){
        return comment;
    }
}


