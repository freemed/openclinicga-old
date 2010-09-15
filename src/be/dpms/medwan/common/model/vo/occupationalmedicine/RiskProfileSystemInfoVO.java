package be.dpms.medwan.common.model.vo.occupationalmedicine;

import be.mxs.common.model.vo.IIdentifiable;

import java.io.Serializable;
import java.util.Collection;

/**
 * Created by IntelliJ IDEA.
 * User: Michaël
 * Date: 17-juin-2003
 * Time: 13:42:57
 */
public class RiskProfileSystemInfoVO implements Serializable, IIdentifiable {

    public Collection allWorkplaces;
    public Collection allFunctionCategories;
    public Collection allFunctionGroups;

    public RiskProfileSystemInfoVO(Collection riskProfileWorkplaces, Collection riskProfileFunctionCategories, Collection riskProfileFunctionGroups) {
        this.allWorkplaces = riskProfileWorkplaces;
        this.allFunctionCategories = riskProfileFunctionCategories;
        this.allFunctionGroups = riskProfileFunctionGroups;
    }

    public Collection getAllWorkplaces() {
        return allWorkplaces;
    }

    public Collection getAllFunctionCategories() {
        return allFunctionCategories;
    }

    public Collection getAllFunctionGroups() {
        return allFunctionGroups;
    }

    public void setAllWorkplaces(Collection allWorkplaces) {
        this.allWorkplaces = allWorkplaces;
    }

    public void setAllFunctionCategories(Collection allFunctionCategories) {
        this.allFunctionCategories = allFunctionCategories;
    }

    public void setAllFunctionGroups(Collection allFunctionGroups) {
        this.allFunctionGroups = allFunctionGroups;
    }
}


