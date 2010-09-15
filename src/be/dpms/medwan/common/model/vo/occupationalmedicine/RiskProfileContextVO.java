package be.dpms.medwan.common.model.vo.occupationalmedicine;

import be.mxs.common.model.vo.IIdentifiable;

import java.io.Serializable;

/**
 * Created by IntelliJ IDEA.
 * User: Michaël
 * Date: 17-juin-2003
 * Time: 14:14:01
 */
public class RiskProfileContextVO implements Serializable, IIdentifiable {
    public String itemType;
    public Integer itemId;
    public Integer profileContextId;

    public RiskProfileContextVO(String itemType, Integer itemId, Integer profileContextId) {
        this.itemType = itemType;
        this.itemId = itemId;
        this.profileContextId = profileContextId;
    }

    public String getItemType() {
        return itemType;
    }

    public Integer getItemId() {
        return itemId;
    }

    public Integer getProfileContextId() {
        return profileContextId;
    }

    public void setItemType(String itemType) {
        this.itemType = itemType;
    }

    public void setItemId(Integer itemId) {
        this.itemId = itemId;
    }

    public void setProfileContextId(Integer profileContextId) {
        this.profileContextId = profileContextId;
    }

    public boolean equals(Object o) {
        if (this == o) return true;
        if (!(o instanceof RiskProfileContextVO)) return false;

        final RiskProfileContextVO riskProfileContextVO = (RiskProfileContextVO) o;

        return profileContextId.equals(riskProfileContextVO.profileContextId);

    }

    public int hashCode() {
        return profileContextId.hashCode();
    }
}
