package be.dpms.medwan.webapp.wo.common.system;

import be.dpms.medwan.common.model.vo.administration.PersonVO;
import be.dpms.medwan.common.model.vo.authentication.UserVO;
import be.dpms.medwan.common.model.vo.occupationalmedicine.PlannedExamination;
import be.dpms.medwan.common.model.vo.occupationalmedicine.RiskProfileSystemInfoVO;
import be.dpms.medwan.common.model.vo.occupationalmedicine.RiskProfileVO;
import be.dpms.medwan.common.model.vo.recruitment.FullRecordVO;
import be.dpms.medwan.webapp.wo.occupationalmedicine.RiskProfileExaminationInfoWO;
import be.dpms.medwan.webapp.wo.occupationalmedicine.RiskProfileRiskCodeWO;
import be.dpms.medwan.webapp.wo.occupationalmedicine.RiskProfileRisksInfoWO;
import be.dpms.medwan.webapp.wo.occupationalmedicine.RiskProfileSystemInfoWO;
import be.mxs.common.model.vo.healthrecord.*;
import be.mxs.common.util.db.MedwanQuery;
import be.mxs.common.util.system.ScreenHelper;
import net.admin.User;

import javax.servlet.http.HttpServletRequest;

import java.util.*;

public class SessionContainerWO extends be.mxs.webapp.wo.common.system.SessionContainerWO {

    public static final String LAST_TRANSACTION_TYPE_BIOMETRY                       = "LAST_TRANSACTION_TYPE_BIOMETRY";
    public static final String LAST_TRANSACTION_TYPE_URINE_EXAMINATION              = "LAST_TRANSACTION_TYPE_URINE_EXAMINATION";
    public static final String LAST_TRANSACTION_TYPE_AUDIOMETRY                     = "LAST_TRANSACTION_TYPE_AUDIOMETRY";
    public static final String LAST_TRANSACTION_TYPE_OPHTALMOLOGY                   = "LAST_TRANSACTION_TYPE_OPHTALMOLOGY";
    public static final String LAST_TRANSACTION_TYPE_GENERAL_CLINICAL_EXAMINATION   = "LAST_TRANSACTION_TYPE_GENERAL_CLINICAL_EXAMINATION";
    public static final String RISK_PROFILE_OTHER_EXAMINATIONS                      = "RISK_PROFILE_OTHER_EXAMINATIONS";
    public static final String RECRUITMENT_CANDIDATES                               = "RECRUITMENT_CANDIDATES";
    public static final String RECRUITMENT_CANDIDATE_RECRUITMENTS                   = "RECRUITMENT_CANDIDATE_RECRUITMENTS";
    public static final String RECRUITMENT_CANDIDATES_IN_APPEAL                     = "RECRUITMENT_CANDIDATES_IN_APPEAL";
    public static final String RECRUITMENT_CANDIDATES_IN_APPEAL_BY_USER             = "RECRUITMENT_CANDIDATES_IN_APPEAL_BY_USER";
    public static final String RECRUITMENT_CANDIDATES_IN_APPEAL_WITH_3_DECISIONS    = "RECRUITMENT_CANDIDATES_IN_APPEAL_WITH_3_DECISIONS";
    public static final String RISK_PROFILE_VERIFIED_EXAMINATIONS                   = "RISK_PROFILE_VERIFIED_EXAMINATIONS";
    public static final String RECRUITMENT_CONVOCATIONS                             = "RECRUITMENT_CONVOCATIONS";
    public static final String RECRUITMENT_CONVOCATIONS_TODAY                       = "RECRUITMENT_CONVOCATIONS_TODAY";
    public static final String RECRUITMENT_CONVOCATIONS_NON_TODAY                   = "RECRUITMENT_CONVOCATIONS_NON_TODAY";
    public static final String ACTIVE_RECRUITMENT_CONVOCATION                       = "ACTIVE_RECRUITMENT_CONVOCATION";
    public static final String RECRUITMENT_CONVOCATION_CLINICAL_EXAMINATION         = "RECRUITMENT_CONVOCATION_CLINICAL_EXAMINATION";
    public static final String RECRUITMENT_CONVOCATION_AUDIOMETRIC_EXAMINATION      = "RECRUITMENT_CONVOCATION_AUDIOMETRIC_EXAMINATION";
    public static final String RECRUITMENT_CONVOCATION_BIOMETRIC_EXAMINATION        = "RECRUITMENT_CONVOCATION_BIOMETRIC_EXAMINATION";
    public static final String RECRUITMENT_CONVOCATION_OPHTALMOLOGY_EXAMINATION     = "RECRUITMENT_CONVOCATION_OPHTALMOLOGY_EXAMINATION";
    public static final String RECRUITMENT_CONVOCATION_URINE_EXAMINATION            = "RECRUITMENT_CONVOCATION_URINE_EXAMINATION";
    public static final String RECRUITMENT_CONVOCATION_MEDICATION_QUESTIONNAIRE     = "RECRUITMENT_CONVOCATION_MEDICATION_QUESTIONNAIRE";
    public static final String RECRUITMENT_CONVOCATION_PSYCHOLOGICAL_TEST           = "RECRUITMENT_CONVOCATION_PSYCHOLOGICAL_TEST";
    public static final String RECRUITMENT_CONVOCATION_DRUGANALYSIS                 = "RECRUITMENT_CONVOCATION_DRUGANALYSIS";
    public static final String RECRUITMENT_CONVOCATION_BLOODANALYSIS                = "RECRUITMENT_CONVOCATION_BLOODANALYSIS";
    public static final String RECRUITMENT_CONVOCATION_ECG                          = "RECRUITMENT_CONVOCATION_ECG";
    public static final String RECRUITMENT_CONVOCATION_PREVIOUS_EXAMINATIONS        = "RECRUITMENT_CONVOCATION_PREVIOUS_EXAMINATIONS";
    public static final String RECRUITMENT_CONVOCATION_ANNEX_A                      = "RECRUITMENT_CONVOCATION_ANNEX_A";
    public static final String RECRUITMENT_CONVOCATION_ANNEX_B                      = "RECRUITMENT_CONVOCATION_ANNEX_B";
    public static final String RECRUITMENT_CONVOCATION_DRIVING_LICENCE_DECLARATION  = "RECRUITMENT_CONVOCATION_DRIVING_LICENCE_DECLARATION";
    public static final String RECRUITMENT_CONVOCATION_EXPERTISE_DOCUMENTS          = "RECRUITMENT_CONVOCATION_EXPERTISE_DOCUMENTS";
    public static final String RECRUITMENT_CONVOCATION_CYCLO_ERGO_SPIROMETRY        = "RECRUITMENT_CONVOCATION_CYCLO_ERGO_SPIROMETRY";
    public static final String RECRUITMENT_CONVOCATION_DRIVING_LICENCE_CERTIFICATE  = "RECRUITMENT_CONVOCATION_DRIVING_LICENCE_CERTIFICATE";
    public static final String RECRUITMENT_CONVOCATION_TEMPORARY_CONCLUSION         = "RECRUITMENT_CONVOCATION_TEMPORARY_CONCLUSION";
    public static final String RECRUITMENT_CONVOCATION_EXAMINATOR_DECISION          = "RECRUITMENT_CONVOCATION_EXAMINATOR_DECISION";
    public static final String RECRUITMENT_CONVOCATION_SET_FIRST_APPEAL             = "RECRUITMENT_CONVOCATION_SET_FIRST_APPEAL";
    public static final String RECRUITMENT_CONVOCATION_FIRST_APPEAL                 = "RECRUITMENT_CONVOCATION_FIRST_APPEAL";
    public static final String RECRUITMENT_CONVOCATION_FIRST_APPEAL_DECISIONS       = "RECRUITMENT_CONVOCATION_FIRST_APPEAL_DECISIONS";
    public static final String RECRUITMENT_CONVOCATION_SET_SECOND_APPEAL            = "RECRUITMENT_CONVOCATION_SET_SECOND_APPEAL";
    public static final String RECRUITMENT_CONVOCATION_SECOND_APPEAL                = "RECRUITMENT_CONVOCATION_SECOND_APPEAL";
    public static final String RECRUITMENT_CONVOCATION_SECOND_APPEAL_DECISIONS      = "RECRUITMENT_CONVOCATION_SECOND_APPEAL_DECISIONS";
    public static final String RECRUITMENT_CONVOCATION_FIRST_APPEAL_COMMISSION_DECISION    = "RECRUITMENT_CONVOCATION_FIRST_APPEAL_COMMISSION_DECISION";
    public static final String RECRUITMENT_CONVOCATION_SECOND_APPEAL_COMMISSION_DECISION   = "RECRUITMENT_CONVOCATION_SECOND_APPEAL_COMMISSION_DECISION";
    public static final String RECRUITMENT_CONVOCATION_PV                           = "RECRUITMENT_CONVOCATION_PV";
    public static final String RECRUITMENT_CONVOCATION_MEDICAL_QUESTIONNAIRE        = "RECRUITMENT_CONVOCATION_MEDICAL_QUESTIONNAIRE";
    public static final String RECRUITMENT_POTENTIALITY_EXAMINATION                 = "RECRUITMENT_POTENTIALITY_EXAMINATION";
    public static final String RECRUITMENT_SET_PRESENT                              = "RECRUITMENT_SET_PRESENT";
    public static final String ACTIVITIES                                           = "ACTIVITIES";
    public static final String RISKCODES                                            = "RISKCODES";
    public static final String ITEM_DEFAULTS                                        = "ITEM_DEFAULTS";
    public static final String ITEM_PREVIOUS                                        = "ITEM_PREVIOUS";
    public static final String ITEM_PREVIOUSCONTEXT                                 = "ITEM_PREVIOUSCONTEXT";

    public Hashtable progressTable = new Hashtable();
    private Hashtable lastTransactions;
    private Hashtable plannedTransactions;

    //--- INNER CLASS : PROGRESS -------------------------------------------------------------------
    public class Progress {
        public String id = "";
        public Date start = new Date();
        public String status = "";
        public boolean updated = false;
        public int percent = 0;
        public String url = "";

        public Progress(String id){
            this.id = id;
        }

        public void addStatus(String status){
            this.status+= status+"\n";
            this.updated = true;
        }

        public void setStatus(String status,int percent){
            this.status = status;
            this.percent = percent;
            this.updated = true;
        }
    }
    //----------------------------------------------------------------------------------------------


    public void init(String personid){
        if (getPersonVO()==null || !getPersonVO().personId.equals(new Integer(personid))){
            setPersonVO(MedwanQuery.getInstance().getPerson(personid));
        }
        if(getHealthRecordVO()==null || getHealthRecordVO().getUpdated() || !getHealthRecordVO().getPerson().personId.equals(new Integer(personid))){
            setHealthRecordVO(MedwanQuery.getInstance().loadHealthRecord(getPersonVO(),null,this));
        }
    }

    public Progress getProgress(String id){
        return (Progress)progressTable.get(id);
    }

    public void initPlannedTransactions(){
        plannedTransactions=new Hashtable();
    }

    public void initLastTransactions(){
        lastTransactions=new Hashtable();
    }

    public HealthRecordVO verifyHealthRecord(String sortOrder){
        if (getPersonVO()==null){
            setHealthRecordVO(null);
            return null;
        }

        if (getPersonVO().getPersonId()==null){
            setPersonVO(null);
            setHealthRecordVO(null);
            return null;
        }

        if (getHealthRecordVO()!=null){
            if (!getHealthRecordVO().getUpdated()){
                if (sortOrder==null){
                    sortOrder="be.mxs.healthrecord.transactionVO.date";
                }

                if (getPersonVO().getPersonId().equals(getHealthRecordVO().getPerson().getPersonId()) && sortOrder.equals(getHealthRecordVO().getSortOrder())){
                    //Debug.println("Ja, ze zijn gelijk!");
                    return getHealthRecordVO();
                }
            }
        }
        setHealthRecordVO(MedwanQuery.getInstance().loadHealthRecord(getPersonVO(), sortOrder,this));

        return getHealthRecordVO();
    }

    public PersonVO verifyPerson(String personId){
        if (getPersonVO()!=null){
            if (getPersonVO().getPersonId().equals(new Integer(personId))){
                return getPersonVO();
            }
        }
        //Debug.println("verify personId="+personId);
        setPersonVO(MedwanQuery.getInstance().getPerson(personId));

        return getPersonVO();
    }

    public UserVO verifyUser(HttpServletRequest request ){
        Integer activeUserId=new Integer(((User)request.getSession().getAttribute("activeUser")).userid);
        if (getUserVO()!=null){
            if (getUserVO().getPersonVO().getPersonId().equals(activeUserId)){
                return getUserVO();
            }
        }
        //Debug.println("verify userId="+activeUserId);
        setUserVO(MedwanQuery.getInstance().getUser(activeUserId.toString()));

        return getUserVO();
    }

    public TransactionVO getLastTransaction(String transactionType){
        if (lastTransactions!=null && lastTransactions.size()>0){
            return (TransactionVO)lastTransactions.get(transactionType);
        }
        else {
            return null;
        }
    }

    public PlannedExamination getPlannedTransaction(String transactionType){
        if (plannedTransactions!=null && plannedTransactions.size()>0){
            return (PlannedExamination)plannedTransactions.get(transactionType);
        }
        else {
            return null;
        }
    }

    public void setPlannedTransaction(String transactionType, PlannedExamination plannedExamination){
        plannedTransactions.put(transactionType,plannedExamination);
    }

    public void setLastTransaction(TransactionVO transactionVO){
        String sCalculatableContexts = MedwanQuery.getInstance().getConfigString("calculatableContexts");
        if(sCalculatableContexts==null) sCalculatableContexts = "";

        if (sCalculatableContexts.length()==0 || transactionVO.getItem(IConstants.ITEM_TYPE_CONTEXT_CONTEXT)==null || sCalculatableContexts.indexOf(transactionVO.getItem(IConstants.ITEM_TYPE_CONTEXT_CONTEXT).getValue())>-1){
            TransactionVO oldTransactionVO = (TransactionVO)lastTransactions.get(transactionVO.getTransactionType());
            if (oldTransactionVO==null){
                lastTransactions.put(transactionVO.getTransactionType(),transactionVO);
            }
            else if(transactionVO.getUpdateTime().after(oldTransactionVO.getUpdateTime())){
                lastTransactions.put(transactionVO.getTransactionType(),transactionVO);
            }
            else if(transactionVO.getTransactionId().equals(oldTransactionVO.getTransactionId())){
                lastTransactions.put(transactionVO.getTransactionType(),transactionVO);
            }
        }
    }

    public Collection getTransactionsLimited() {
        if (getHealthRecordVO()!=null){
            Collection transactions = getHealthRecordVO().getTransactions();
            int numberOfTransToList = MedwanQuery.getInstance().getConfigInt("numberOfTransToListInSummary",25);
    //        if(numberOfTransToList < 0) numberOfTransToList = 25; // default
            if (transactions.size()<=numberOfTransToList){
                return transactions;
            }
            else {
                Vector limited = new Vector();
                Iterator iterator=transactions.iterator();
                while (limited.size()<numberOfTransToList){
                    limited.add(iterator.next());
                }
                return limited;
            }
        }
        return null;
    }

    public void setUserVO(UserVO userVO) {
        putObject(UserVO.class.getName(), userVO);
    }

    public FlagsVO getFlags(){
        if (getObject(FlagsVO.class.getName())==null){
            setFlags(new FlagsVO());
        }

        return (FlagsVO) getObject(FlagsVO.class.getName());
    }

    public void setFlags(FlagsVO flagsVO){
        putObject( FlagsVO.class.getName(), flagsVO );
    }

    public UserVO getUserVO() {
        return  ( UserVO ) getObject( UserVO.class.getName() );
    }

    public void setPersonVO(PersonVO PersonVO) {
        putObject( PersonVO.class.getName(), PersonVO );
    }

    public PersonVO getPersonVO() {
        return (PersonVO) getObject( PersonVO.class.getName() );
    }

    public void setRiskProfileVerifiedExaminations(Collection riskProfileVerifiedExaminations) {
        putObject( RISK_PROFILE_VERIFIED_EXAMINATIONS, riskProfileVerifiedExaminations);
    }

    public Collection getRiskProfileVerifiedExaminations() {

        return (Collection) getObject( RISK_PROFILE_VERIFIED_EXAMINATIONS );
    }

    public RiskProfileVO getRiskProfileVO(){
        return ( RiskProfileVO ) getObject( RiskProfileVO.class.getName() );
    }

    public void setRiskProfileVO( RiskProfileVO vo ) {
        putObject( RiskProfileVO.class.getName(), vo );
    }

    public void setRiskProfileSystemInfoVO( RiskProfileSystemInfoVO vo ) {
        putObject( RiskProfileSystemInfoVO.class.getName(), vo );
    }

    public RiskProfileSystemInfoWO getRiskProfileSystemInfoWO(){
        return ( RiskProfileSystemInfoWO ) getObject( RiskProfileSystemInfoWO.class.getName() );
    }

    public void setRiskProfileSystemInfoWO( RiskProfileSystemInfoWO wo ) {
        putObject( RiskProfileSystemInfoWO.class.getName(), wo );
    }

    public void setRiskProfileExaminationInfoWO( RiskProfileExaminationInfoWO wo ) {
        putObject( RiskProfileExaminationInfoWO.class.getName(), wo );
    }

    public void setRiskProfileOtherExaminations( Collection otherExaminations ) {
        putObject( RISK_PROFILE_OTHER_EXAMINATIONS, otherExaminations);
    }

    public void setRiskProfileRisksInfoWO( RiskProfileRisksInfoWO wo ) {
        putObject( RiskProfileRisksInfoWO.class.getName(), wo );
    }

    public void setLastTransactionTypeBiometry( TransactionVO transactionVO ) {
        putObject( LAST_TRANSACTION_TYPE_BIOMETRY, transactionVO);
    }

    public TransactionVO getLastTransactionTypeBiometry() {
        return ( TransactionVO ) getObject( LAST_TRANSACTION_TYPE_BIOMETRY );
    }

    public void setLastTransactionTypeAudiometry( TransactionVO transactionVO ) {
        putObject( LAST_TRANSACTION_TYPE_AUDIOMETRY, transactionVO);
    }

    public TransactionVO getLastTransactionTypeAudiometry() {
        return ( TransactionVO ) getObject( LAST_TRANSACTION_TYPE_AUDIOMETRY );
    }

    public void setLastTransactionTypeGeneralClinicalExamination( TransactionVO transactionVO ) {
        putObject( LAST_TRANSACTION_TYPE_GENERAL_CLINICAL_EXAMINATION, transactionVO);
    }

    public TransactionVO getLastTransactionTypeGeneralClinicalExamination() {
        return ( TransactionVO ) getObject( LAST_TRANSACTION_TYPE_GENERAL_CLINICAL_EXAMINATION );
    }

    public void setLastTransactionTypeOphtalmology( TransactionVO transactionVO ) {
        putObject( LAST_TRANSACTION_TYPE_OPHTALMOLOGY, transactionVO);
    }

    public TransactionVO getLastTransactionTypeOphtalmology() {
        return ( TransactionVO ) getObject( LAST_TRANSACTION_TYPE_OPHTALMOLOGY );
    }

    public void setLastTransactionTypeUrineExamination( TransactionVO transactionVO ) {
        putObject( LAST_TRANSACTION_TYPE_URINE_EXAMINATION, transactionVO);
    }

    public TransactionVO getLastTransactionTypeUrineExamination() {
        return ( TransactionVO ) getObject( LAST_TRANSACTION_TYPE_URINE_EXAMINATION );
    }

    public void setActivities(Vector activities){
        putObject( ACTIVITIES, activities);
    }

    public void setRiskCodesVO(Vector riskCodesVO){
        // sort the risks
        SortedSet set = new TreeSet();
        RiskProfileRiskCodeWO rwo;
        for (int n=0;n<riskCodesVO.size();n++){
            rwo = (RiskProfileRiskCodeWO)riskCodesVO.elementAt(n);
            set.add(rwo);
        }

        Iterator iterator = set.iterator();
        Vector v = new Vector();
        while (iterator.hasNext()){
            v.add(iterator.next());
        }

        putObject( RISKCODES, v);
    }

    public Vector getRiskCodesVO(){
        return (Vector)getObject( RISKCODES );
    }

    public void loadItemDefaults(){
        try{
            putObject( ITEM_DEFAULTS, MedwanQuery.getInstance().getItemDefaults(getUserVO().getUserId().intValue()));
        }
        catch (Exception e){
            // empty
        }
    }

    public Hashtable getItemDefaults(){
        if (getObject( ITEM_DEFAULTS )!=null){
            return ( Hashtable ) getObject( ITEM_DEFAULTS );
        }
        else {
            return null;
        }
    }

    public String getItemDefaultsHTML(){
        String html = "";
        if (getCurrentTransactionVO()!=null){
            Hashtable hashtable = getItemDefaults();
            if (hashtable!=null){
                Iterator iterator = getCurrentTransactionVO().getItems().iterator();
                ItemVO item;
                while (iterator.hasNext()){
                    item = (ItemVO)iterator.next();
                    if (hashtable.get(item.getType())!=null){
                        html += "<input type='hidden' name='DefaultValue_currentTransactionVO.items.<ItemVO[hashCode="+item.getItemId()+"]>.value' value='"+hashtable.get(item.getType())+"'/>";
                    }
                }
            }
        }

        return html;
    }

    public void loadItemPrevious(){
        if (getHealthRecordVO()!=null && getCurrentTransactionVO()!=null){
            TransactionVO transaction=MedwanQuery.getInstance().getLastTransactionVO(getHealthRecordVO().getHealthRecordId().toString(),getCurrentTransactionVO().getTransactionType());
            if (transaction!=null){
                TransactionVO tmpTransaction = MedwanQuery.getInstance().loadTransaction(transaction.getServerId(),transaction.getTransactionId().intValue());
                if (tmpTransaction!=null){
                    putObject( ITEM_PREVIOUS, tmpTransaction.getItems());
                }
            }
        }
    }

    public Collection getItemPrevious(){
        return ( Collection ) getObject( ITEM_PREVIOUS );
    }

    public String getItemPreviousHTML(){
        String html = "";
        String itemValue;
        if (getCurrentTransactionVO()!=null){
            try {
            	Hashtable historyItems=null;
                if(getCurrentTransactionVO().getTransactionId()<=0){
                	historyItems = MedwanQuery.getInstance().loadRepeatableTransactionItems(getCurrentTransactionVO().getTransactionType());
                }
                loadItemPrevious();
                Collection items = getItemPrevious();
                if (items!=null){
                    Iterator iterator = items.iterator();
                    ItemVO item, actualItem, subitem;
                    Iterator actualItems, itemsCheck;
                    String[] subitems;
                    while (iterator.hasNext()){
                        item = (ItemVO)iterator.next();
                        actualItems = getCurrentTransactionVO().getItems().iterator();
                        while (actualItems.hasNext()){
                            actualItem = (ItemVO)actualItems.next();
                            if (actualItem.getType().equals(item.getType())){
                                itemValue = item.getValue();
                                // We controleren of er nog bijkomende itemtypes moeten worden geladen
                                if (MedwanQuery.getInstance().getConfigString("compoundItemtype="+item.getType())!=null){
                                    subitems = MedwanQuery.getInstance().getConfigString("compoundItemtype="+item.getType()).split(";");
                                    for (int n=0; n<subitems.length; n++){
                                        if (getItemPrevious()!=null){
                                            itemsCheck = getItemPrevious().iterator();
                                            while (itemsCheck.hasNext()){
                                                subitem = (ItemVO)itemsCheck.next();
                                                if (subitem.getType().equalsIgnoreCase(subitems[n])){
                                                    itemValue+= subitem.getValue();
                                                }
                                            }
                                        }
                                    }
                                }
                                html += "<input type='hidden' name='PreviousValue_currentTransactionVO.items.<ItemVO[hashCode="+actualItem.getItemId()+"]>.value' value='"+itemValue.replaceAll("\\'","´")+"'/>";
                                if(getCurrentTransactionVO().getTransactionId()<=0){
	                                String repeat=(String)historyItems.get(actualItem.getType());
	                                if(repeat!=null){
	                                	if(repeat.indexOf("repeat-splitcheck")>-1 && repeat.split(";").length>1){
	                                		String name = repeat.split(";")[1];
	                                		String[] itemids = itemValue.replaceAll("\\'","´").replaceAll("\\*\\*", ";").replaceAll("\\*", "").split(";");
	                                		for(int i=0;i<itemids.length;i++){
	                                			html+="<script>if(document.getElementsByName('"+name+itemids[i]+"').length>0){document.getElementsByName('"+name+itemids[i]+"')[0].checked=true;document.getElementsByName('"+name+itemids[i]+"')[0].className='modified'}</script>";
	                                		}
	                                		
	                                	}
	                                	else if(repeat.indexOf("repeat")>-1){
		                                	html+=  "<script>if(document.getElementsByName('currentTransactionVO.items.<ItemVO[hashCode="+actualItem.getItemId()+"]>.value').length>0){"
		                                			+"if(document.getElementsByName('currentTransactionVO.items.<ItemVO[hashCode="+actualItem.getItemId()+"]>.value')[0].type=='text') {document.getElementsByName('currentTransactionVO.items.<ItemVO[hashCode="+actualItem.getItemId()+"]>.value')[0].value=document.getElementsByName('PreviousValue_currentTransactionVO.items.<ItemVO[hashCode="+actualItem.getItemId()+"]>.value')[0].value;document.getElementsByName('currentTransactionVO.items.<ItemVO[hashCode="+actualItem.getItemId()+"]>.value')[0].className='modified'}"
		                                            +"else if(document.getElementsByName('currentTransactionVO.items.<ItemVO[hashCode="+actualItem.getItemId()+"]>.value')[0].type=='textarea') {document.getElementsByName('currentTransactionVO.items.<ItemVO[hashCode="+actualItem.getItemId()+"]>.value')[0].value=document.getElementsByName('PreviousValue_currentTransactionVO.items.<ItemVO[hashCode="+actualItem.getItemId()+"]>.value')[0].value;document.getElementsByName('currentTransactionVO.items.<ItemVO[hashCode="+actualItem.getItemId()+"]>.value')[0].className='modified'}"
		                                            +"else if(document.getElementsByName('currentTransactionVO.items.<ItemVO[hashCode="+actualItem.getItemId()+"]>.value')[0].type=='radio' && document.getElementsByName('currentTransactionVO.items.<ItemVO[hashCode="+actualItem.getItemId()+"]>.value')[0].value==document.getElementsByName('PreviousValue_currentTransactionVO.items.<ItemVO[hashCode="+actualItem.getItemId()+"]>.value')[0].value) {document.getElementsByName('currentTransactionVO.items.<ItemVO[hashCode="+actualItem.getItemId()+"]>.value')[0].checked=true;document.getElementsByName('currentTransactionVO.items.<ItemVO[hashCode="+actualItem.getItemId()+"]>.value')[0].className='modified'}"
		                                            +"else if(document.getElementsByName('currentTransactionVO.items.<ItemVO[hashCode="+actualItem.getItemId()+"]>.value')[0].type=='checkbox' && document.getElementsByName('currentTransactionVO.items.<ItemVO[hashCode="+actualItem.getItemId()+"]>.value')[0].value==document.getElementsByName('PreviousValue_currentTransactionVO.items.<ItemVO[hashCode="+actualItem.getItemId()+"]>.value')[0].value) {document.getElementsByName('currentTransactionVO.items.<ItemVO[hashCode="+actualItem.getItemId()+"]>.value')[0].checked=true;document.getElementsByName('currentTransactionVO.items.<ItemVO[hashCode="+actualItem.getItemId()+"]>.value')[0].className='modified'}"
		                                            +"else if(document.getElementsByName('currentTransactionVO.items.<ItemVO[hashCode="+actualItem.getItemId()+"]>.value')[0].type=='select-one') {for(m=0;m<document.getElementsByName('currentTransactionVO.items.<ItemVO[hashCode="+actualItem.getItemId()+"]>.value')[0].options.length;m++){if(document.getElementsByName('currentTransactionVO.items.<ItemVO[hashCode="+actualItem.getItemId()+"]>.value')[0].options[m].value==document.getElementsByName('PreviousValue_currentTransactionVO.items.<ItemVO[hashCode="+actualItem.getItemId()+"]>.value')[0].value){document.getElementsByName('currentTransactionVO.items.<ItemVO[hashCode="+actualItem.getItemId()+"]>.value')[0].selectedIndex=m;document.getElementsByName('currentTransactionVO.items.<ItemVO[hashCode="+actualItem.getItemId()+"]>.value')[0].className='modified'}}}"
		                                            +"}</script>";
	                                	}
	                                }
                                }
                                break;
                            }
                        }
                    }
                }
            }
            catch(Exception e){
                e.printStackTrace();
            }
        }

        return html;
    }

    public String getItemPreviousContextHTML(){
        String html = "";
        String itemValue;
        if (getCurrentTransactionVO()!=null){
            try {
                loadItemPreviousContext();
                Collection items = getItemPreviousContext();
                if (items!=null){
                    Iterator iterator = items.iterator();
                    ItemVO item, actualItem, subitem;
                    Iterator actualItems, itemsCheck;
                    String[] subitems;
                    while (iterator.hasNext()){
                        item = (ItemVO)iterator.next();
                        actualItems = getCurrentTransactionVO().getItems().iterator();
                        while (actualItems.hasNext()){
                            actualItem = (ItemVO)actualItems.next();
                            if (actualItem.getType().equals(item.getType())){
                                itemValue = item.getValue();
                                // We controleren of er nog bijkomende itemtypes moeten worden geladen
                                if (MedwanQuery.getInstance().getConfigString("compoundItemtype="+item.getType())!=null){
                                    subitems = MedwanQuery.getInstance().getConfigString("compoundItemtype="+item.getType()).split(";");
                                    for (int n=0; n<subitems.length; n++){
                                        if(getItemPrevious()!=null){
                                            itemsCheck = getItemPrevious().iterator();
                                            while (itemsCheck.hasNext()){
                                                subitem = (ItemVO)itemsCheck.next();
                                                if (subitem.getType().equalsIgnoreCase(subitems[n])){
                                                    itemValue+= subitem.getValue();
                                                }
                                            }
                                        }
                                    }
                                }
                                html += "<input type='hidden' name='PreviousContextValue_currentTransactionVO.items.<ItemVO[hashCode="+actualItem.getItemId()+"]>.value' value='"+itemValue.replaceAll("\\'","´")+"'/>";
                                break;
                            }
                        }
                    }
                }
            }
            catch(Exception e){
                e.printStackTrace();
            }
        }

        return html;
    }

    public void loadItemPreviousContext(){
        TransactionVO currentTransaction = getCurrentTransactionVO();
        if (getHealthRecordVO()!=null && currentTransaction!=null){
            String currentContext = "", context;
            ItemVO itemVO = currentTransaction.getItem("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CONTEXT_CONTEXT");
            if (itemVO!=null){
                currentContext = ScreenHelper.checkString(itemVO.getValue());
            }

            TransactionVO transaction;
            Vector vTransactions = MedwanQuery.getInstance().getTransactionsByType(getHealthRecordVO(),currentTransaction.getTransactionType());

            for (int i=0; i<vTransactions.size();i++){
                transaction = (TransactionVO) vTransactions.elementAt(i);
                if (transaction!=null){
                    itemVO = transaction.getItem("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CONTEXT_CONTEXT");
                    context = "";

                    if (itemVO!=null){
                        context = ScreenHelper.checkString(itemVO.getValue());
                    }
                    if (currentContext.equals(context)){
                        TransactionVO tmpTransaction = MedwanQuery.getInstance().loadTransaction(transaction.getServerId(),transaction.getTransactionId().intValue());
                        if (tmpTransaction!=null){
                            putObject( ITEM_PREVIOUSCONTEXT, tmpTransaction.getItems());
                            return;
                        }
                    }
                }
            }
        }
    }

    public Collection getItemPreviousContext(){
        return ( Collection ) getObject( ITEM_PREVIOUSCONTEXT );
    }


    public void setFullRecord(FullRecordVO fullRecordVO) {
        putObject(FullRecordVO.class.getName(), fullRecordVO);
    }

    //--- IS COMPOSING ITEM -----------------------------------------------------------------------
    // the specified item is part of a group of composing items, with a numbered name, BUT not the first item
    public boolean isComposingItem(ItemVO item, Collection items){
        boolean isComposingItem = false;
                
        String sLastChar = item.getType().substring(item.getType().length()-1);
        try{
            int digit1 = Integer.parseInt(sLastChar);
                
            // check the second last char when the last char is an integer
            sLastChar = item.getType().substring(item.getType().length()-2,item.getType().length()-1);
            
            try{
                int digit2 = Integer.parseInt(sLastChar);
                isComposingItem = true;
            }
            catch(Exception e){
                isComposingItem = (digit1 > 1);
            }            
        }
        catch(Exception e){
            isComposingItem = false;
        }

        return isComposingItem; 
    }
    
}
