package be.dpms.medwan.common.model.vo.occupationalmedicine;

import be.mxs.common.model.vo.IIdentifiable;

import java.io.Serializable;

/**
 * Created by IntelliJ IDEA.
 * User: Michaël
 * Date: 26-juin-2003
 * Time: 8:38:51
 */
public class FunctionGroupVO implements Serializable, IIdentifiable {
    public Integer functionGroupId;
    public String messageKey;
    public String functionGroupServiceId;

    public FunctionGroupVO(Integer functionGroupId, String messageKey, String functionGroupServiceId) {
        this.functionGroupId = functionGroupId;
        this.messageKey = messageKey;
        this.functionGroupServiceId = functionGroupServiceId;
    }

    public Integer getFunctionGroupId() {
        return functionGroupId;
    }

    public String getMessageKey() {
        return messageKey;
    }

    public String getFunctionGroupServiceId() {
        return functionGroupServiceId;
    }

    public void setFunctionGroupId(Integer functionGroupId) {
        this.functionGroupId = functionGroupId;
    }

    public void setMessageKey(String messageKey) {
        this.messageKey = messageKey;
    }

    public void setFunctionGroupServiceId(String functionGroupServiceId) {
        this.functionGroupServiceId = functionGroupServiceId;
    }

    public boolean equals(Object o) {
        if (this == o) return true;
        if (!(o instanceof FunctionGroupVO)) return false;

        final FunctionGroupVO functionGroupVO = (FunctionGroupVO) o;

        return functionGroupId == functionGroupVO.functionGroupId;

    }

    public int hashCode() {
        return functionGroupId.hashCode();
    }
}
