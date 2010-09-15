package be.dpms.medwan.common.model.vo.system;

import java.io.Serializable;

/**
 * Created by IntelliJ IDEA.
 * User: Michaël
 * Date: 30-sept.-2003
 * Time: 16:36:00
 */
public class ActiveContextVO implements Serializable {
    private String convocationId;
    private String department;
    private String context;

    public ActiveContextVO(String department, String context,String convocationId) {
        this.convocationId = convocationId;
        this.department = department;
        this.context = context;
    }

    public void setConvocationId(String convocationId){
        this.convocationId = convocationId;
    }

    public void setDepartment(String department){
        this.department = department;
    }

    public void setContext(String context){
        this.context = context;
    }

    public String getConvocationId() {
        return convocationId;
    }

    public String getDepartment() {
        return department;
    }

    public String getContext() {
        return context;
    }

}
