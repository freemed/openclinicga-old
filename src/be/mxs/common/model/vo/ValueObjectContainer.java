package be.mxs.common.model.vo;

import java.io.Serializable;

/**
 * Created by IntelliJ IDEA.
 * User: Michaël
 * Date: 09-juil.-2003
 * Time: 11:37:33
 * To change this template use Options | File Templates.
 */
public class ValueObjectContainer implements Serializable{

    private String valueObjectPath;
    private Object valueObject;

    public ValueObjectContainer(String valueObjectPath, Object valueObject) {
        this.valueObjectPath = valueObjectPath;
        this.valueObject = valueObject;
    }

    public String getValueObjectPath() {
        return valueObjectPath;
    }

    public void setValueObjectPath(String valueObjectPath) {
        this.valueObjectPath = valueObjectPath;
    }

    public Object getValueObject() {
        return valueObject;
    }

    public void setValueObject(Object valueObject) {
        this.valueObject = valueObject;
    }
}
