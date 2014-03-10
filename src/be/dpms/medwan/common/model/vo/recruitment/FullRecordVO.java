package be.dpms.medwan.common.model.vo.recruitment;

import java.io.Serializable;
import java.util.Vector;

public class FullRecordVO implements Serializable {
    public Vector recordRows;
    public Vector diagnosisRows;

    public FullRecordVO(){
        recordRows=new Vector();
        diagnosisRows=new Vector();
    }
    
    public Vector getRecordRows(){
        return recordRows;
    }

    public Vector getDiagnosisRows(){
        return diagnosisRows;
    }

}
