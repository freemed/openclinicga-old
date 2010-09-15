package be.mxs.common.model.vo.healthrecord;

import be.dpms.medwan.common.model.vo.administration.PersonVO;
import be.dpms.medwan.common.model.vo.occupationalmedicine.ExaminationVO;
import be.dpms.medwan.common.model.vo.occupationalmedicine.VerifiedExaminationVO;
import be.dpms.medwan.webapp.wo.common.system.SessionContainerWO;
import be.mxs.common.model.vo.IIdentifiable;

import java.io.Serializable;
import java.util.Collection;
import java.util.Date;
import java.util.Vector;

public class HealthRecordVO implements Serializable, IIdentifiable {

    private final PersonVO person;
    private final Collection transactions;
    private final Integer healthRecordId;
    private final Date dateBegin;
    private final Date dateEnd;
    private boolean updated=false;
    private String sortOrder;
    private Vector verifiedExaminations=null,otherverifiedExaminations=null;

    public Vector getVerifiedExaminations(SessionContainerWO sessionContainerWO,Vector myExaminations){
        if(verifiedExaminations==null || updated){
            verifiedExaminations=new Vector();
            for(int n=0;n<myExaminations.size();n++){
                ExaminationVO examinationVO = (ExaminationVO)myExaminations.elementAt(n);
                verifiedExaminations.add(new VerifiedExaminationVO(examinationVO.id.intValue(),healthRecordId+"",examinationVO.getMessageKey(),examinationVO.getTransactionType(),sessionContainerWO));
            }
        }
        return verifiedExaminations;
    }

    public Vector getOtherVerifiedExaminations(SessionContainerWO sessionContainerWO,Vector myExaminations){
        if(otherverifiedExaminations==null || updated){
            otherverifiedExaminations=new Vector();
            for(int n=0;n<myExaminations.size();n++){
                ExaminationVO examinationVO = (ExaminationVO)myExaminations.elementAt(n);
                otherverifiedExaminations.add(new VerifiedExaminationVO(examinationVO.id.intValue(),healthRecordId+"",examinationVO.getMessageKey(),examinationVO.getTransactionType(),sessionContainerWO));
            }
        }
        return otherverifiedExaminations;
    }

    public String getSortOrder(){
        return sortOrder;
    }
    public void setSortOrder(String sortOrder){
        this.sortOrder=sortOrder;
    }
    public boolean getUpdated(){
        return updated;
    }

    public void setUpdated(boolean updated){
        this.updated=updated;
    }

    public HealthRecordVO(PersonVO person, Collection transactionsVO, Integer healthRecordId, Date dateBegin, Date dateEnd) {
        this.person = person;
        this.transactions = transactionsVO;
        this.healthRecordId = healthRecordId;
        this.dateBegin = dateBegin;
        this.dateEnd = dateEnd;
    }

    public PersonVO getPerson() {
        return person;
    }

    public Collection getTransactions() {
        return transactions;
    }

    public Integer getHealthRecordId() {
        return healthRecordId;
    }

    public Date getDateBegin() {
        return dateBegin;
    }

    public Date getDateEnd() {
        return dateEnd;
    }

    public int hashCode() {

        if (healthRecordId != null){
            return healthRecordId.hashCode();
        }
        return 0;
    }
}
