package be.mxs.common.model.util;

import be.mxs.common.model.vo.IIdentifiable;
import be.mxs.common.model.vo.IdentifierFactory;

public class ValueBean {

    private boolean         isNew = false;
    private IIdentifiable   bean = null;

    public ValueBean(boolean isNew, IIdentifiable bean) {
        this.isNew = isNew;
        this.bean = bean;
    }

    public boolean isNew() {
        return isNew;
    }

    public void setNew(boolean isNew) {
        this.isNew = isNew;
    }

    public IIdentifiable getBean() {
        return bean;
    }

    public void setBean(IIdentifiable bean) {
        this.bean = bean;
    }

    public String getIdentifier() {
        return IdentifierFactory.getInstance().getIdentifier(getBean(), null, null);
    }

    public boolean equals(Object o) {
        if (this == o) return true;
        if (!(o instanceof ValueBean)) return false;

        final ValueBean optionBeanWO = (ValueBean) o;

        return this.getIdentifier().equals(optionBeanWO.getIdentifier());

    }

    public int hashCode() {
        return bean.hashCode();
    }
}
