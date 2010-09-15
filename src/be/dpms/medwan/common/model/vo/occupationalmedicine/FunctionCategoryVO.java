package be.dpms.medwan.common.model.vo.occupationalmedicine;

import be.mxs.common.model.vo.IIdentifiable;
import java.io.Serializable;

/**
 * User: Michaël
 * Date: 20-mai-2003
 */
public class FunctionCategoryVO implements Serializable, IIdentifiable {
    public Integer id;
    public String messageKey;
    public String serviceId;

    public FunctionCategoryVO(Integer id, String messageKey, String serviceId) {
        this.id = id;
        this.messageKey = messageKey;
        this.serviceId = serviceId;
    }

    public Integer getId() {
        return id;
    }

    public String getMessageKey() {
        return messageKey;
    }

    public String getServiceId() {
        return serviceId;
    }

    public void setId(Integer id) {
        this.id = id;
    }

    public void setMessageKey(String messageKey) {
        this.messageKey = messageKey;
    }

    public void setServiceId(String serviceId) {
        this.serviceId = serviceId;
    }

    public boolean equals(Object o) {
        if (this == o) return true;
        if (!(o instanceof FunctionCategoryVO)) return false;

        final FunctionCategoryVO functionCategoryVO = (FunctionCategoryVO) o;

        return id.equals(functionCategoryVO.id);

    }

    public int hashCode() {
        return id.hashCode();
    }
}
