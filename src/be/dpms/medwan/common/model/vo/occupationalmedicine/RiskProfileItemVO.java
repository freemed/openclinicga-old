package be.dpms.medwan.common.model.vo.occupationalmedicine;

import be.mxs.common.model.vo.IIdentifiable;

import java.io.Serializable;

/**
 * Created by IntelliJ IDEA.
 * User: Michaël
 * Date: 17-juin-2003
 * Time: 14:14:32
 */
public class RiskProfileItemVO implements Serializable, IIdentifiable {
    public Integer profileItemId;
    public String itemType;
    public Integer itemId;
    public Integer status;
    public String comment;

    public RiskProfileItemVO(Integer profileItemId, String itemType, Integer itemId, Integer status, String comment) {
        this.profileItemId = profileItemId;
        this.itemType = itemType;
        this.itemId = itemId;
        this.status = status;
        this.comment = comment;
    }

    public Integer getProfileItemId() {
        return profileItemId;
    }

    public String getItemType() {
        return itemType;
    }

    public Integer getItemId() {
        return itemId;
    }

    public Integer getStatus() {
        return status;
    }

    public String getComment() {
        return comment;
    }

    public void setProfileItemId(Integer profileItemId) {
        this.profileItemId = profileItemId;
    }

    public void setItemType(String itemType) {
        this.itemType = itemType;
    }

    public void setItemId(Integer itemId) {
        this.itemId = itemId;
    }

    public void setStatus(Integer status) {
        this.status = status;
    }

    public void setComment(String comment) {
        this.comment = comment;
    }

    public boolean equals(Object o) {
        if (this == o) return true;
        if (!(o instanceof RiskProfileItemVO)) return false;

        final RiskProfileItemVO riskProfileItemVO = (RiskProfileItemVO) o;

        return profileItemId.equals(riskProfileItemVO.profileItemId);

    }

    public int hashCode() {
        return profileItemId.hashCode();
    }
}
