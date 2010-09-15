package be.mxs.common.model.vo.healthrecord;

import be.mxs.common.model.vo.IIdentifiable;

import java.io.Serializable;

/**
 * Created by IntelliJ IDEA.
 * User: Michaël
 * Date: 01-août-2003
 * Time: 11:20:43
 * To change this template use Options | File Templates.
 */
public class ItemContextVO implements Serializable, IIdentifiable {
    private Integer itemContextId;
    private String info;
    private String type;

    public ItemContextVO(Integer itemContextId, String info, String type) {
        this.itemContextId = itemContextId;
        this.info = info;
        this.type = type;
    }

    public Integer getItemContextId() {
        return itemContextId;
    }

    public String getInfo() {
        return info;
    }

    public String getType() {
        return type;
    }

    public void setItemContextId(Integer itemContextId) {
        this.itemContextId = itemContextId;
    }

    public void setInfo(String info) {
        this.info = info;
    }

    public void setType(String type) {
        this.type = type;
    }

    public int hashCode() {
        return itemContextId.hashCode();
    }

}
