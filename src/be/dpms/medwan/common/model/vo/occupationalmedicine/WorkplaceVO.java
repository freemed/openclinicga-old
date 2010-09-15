package be.dpms.medwan.common.model.vo.occupationalmedicine;

import be.mxs.common.model.vo.IIdentifiable;

import java.io.Serializable;

/**
 * Created by IntelliJ IDEA.
 * User: Michaël
 * Date: 16-juin-2003
 * Time: 10:42:09
 */
public class WorkplaceVO implements Serializable, IIdentifiable {
    public Integer workplaceId;
    public String messageKey;

    public WorkplaceVO(Integer workplaceId, String messageKey) {
        this.workplaceId = workplaceId;
        this.messageKey = messageKey;
    }

    public Integer getWorkplaceId() {
        return workplaceId;
    }

    public String getMessageKey() {
        return messageKey;
    }

    public void setWorkplaceId(Integer workplaceId) {
        this.workplaceId = workplaceId;
    }

    public void setMessageKey(String messageKey) {
        this.messageKey = messageKey;
    }

    public boolean equals(Object o) {
        if (this == o) return true;
        if (!(o instanceof WorkplaceVO)) return false;

        final WorkplaceVO workplaceVO = (WorkplaceVO) o;

        return workplaceId.equals(workplaceVO.workplaceId);

    }

    public int hashCode() {
        return workplaceId.hashCode();
    }
}
