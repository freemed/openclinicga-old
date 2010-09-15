package be.mxs.common.model.util;

import be.mxs.common.model.vo.IIdentifiable;
import be.mxs.common.model.vo.IdentifierFactory;
import be.dpms.medwan.common.model.vo.occupationalmedicine.RiskCodeVO;

public class OptionBean {

    private boolean         selected = false;
    private RiskCodeVO riskCodeVO = null;
    private IIdentifiable   bean = null;

    public OptionBean(boolean selected, IIdentifiable bean) {
        this.selected = selected;
        this.bean = bean;
    }

    public OptionBean(boolean selected, IIdentifiable bean,RiskCodeVO riskCodeVO) {
        this.selected = selected;
        this.bean = bean;
        this.riskCodeVO=riskCodeVO;
    }

    public RiskCodeVO getRiskCodeVO(){
        return riskCodeVO;
    }

    public boolean isSelected() {
        return selected;
    }

    public void setSelected(boolean selected) {
        this.selected = selected;
    }

    public String getChecked() {

        if (isSelected()) return  "checked";

        return "";
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
        if (!(o instanceof OptionBean)) return false;

        final OptionBean optionBeanWO = (OptionBean) o;

        return this.getIdentifier().equals(optionBeanWO.getIdentifier());

    }

    public int hashCode() {
        return bean.hashCode();
    }
}
