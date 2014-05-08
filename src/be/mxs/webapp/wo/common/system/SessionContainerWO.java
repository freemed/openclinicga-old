package be.mxs.webapp.wo.common.system;

import be.dpms.medwan.webapp.wo.authentication.UserWO;
import be.dpms.medwan.webapp.wo.authentication.AuthenticationTokenWO;
import be.dpms.medwan.webapp.wo.common.navigation.URLHistory;
import be.dpms.medwan.webapp.wo.common.system.FolderWO;
import be.dpms.medwan.webapp.wo.administration.PersonWO;
import be.dpms.medwan.webapp.wo.healthrecord.HealthRecordWO;
import be.mxs.common.model.vo.healthrecord.*;
import be.mxs.common.model.vo.IdentifierFactory;
import be.mxs.common.util.system.ScreenHelper;

import java.util.*;
import java.text.SimpleDateFormat;

public class SessionContainerWO {
    public  static final String SESSION_KEY_CONTAINER_WO = "SESSION_KEY_CONTAINER_WO";

    private String    sessionKey = null;
    private Hashtable container = null;
    private String    currentFoldername = null;
    private Vector    errorMessages = new Vector();

    private static final String WO_AUTHENTICATION_TOKEN = "WO_AUTHENTICATION_TOKEN";
    private static final String WO_USER                 = "WO_USER";
    private static final String HISTORY                 = "HISTORY";
    private static final String EXCEPTION               = "EXCEPTION";
    private static final String FOLDER                  = "FOLDER";
    private static final String BROWSER_TITLE           = "BROWSER_TITLE";
    private static final String ACTIVE_VIEW             = "ACTIVE_VIEW";

    public static final String ACTIONS_VIEW             = "ACTIONS_VIEW";
    public static final String SUMMARY_VIEW             = "SUMMARY_VIEW";

    public static final String ALERT_TRANSACTIONS       = "ALERT_TRANSACTIONS";

    public SessionContainerWO() {
        this.container = new Hashtable();
    }

    public SessionContainerWO(String sessionKey) {
        this.sessionKey = sessionKey;
        this.container = new Hashtable();
    }
/*
    public void put(Object key, Object value) {
        container.put(key, value);
    }

    public Object get(Object key) {
        return container.get(key);
    }
 */

    public Vector getErrorMessages() {
        return errorMessages;
    }

    public void resetErrorMessage() {
        errorMessages.clear();
    }

    public void addErrorMessage(String errorMessage) {

        errorMessages.add(errorMessage);
    }

    public String getSessionKey() {
        return sessionKey;
    }

    public void setSessionKey(String sessionKey) {
        this.sessionKey = sessionKey;
    }

    public String getActiveView() {
        return (String) container.get(this.ACTIVE_VIEW);
    }

    public void setActiveView(String activeView) {
        container.put(this.ACTIVE_VIEW, activeView);
    }

    public UserWO getUser(){
        return (UserWO) container.get(this.WO_USER);
    }

    public void setUser(UserWO userWO){
        container.put(this.WO_USER, userWO);
    }

    public void setCurrentTransactionVO(TransactionVO transactionVO) {

        putObject("Current." + TransactionVO.class.getName(), transactionVO);
    }

    public TransactionVO getCurrentTransactionVO() {

        TransactionVO newTransactionVO = ( TransactionVO ) getObject("Current." + TransactionVO.class.getName());
        return newTransactionVO;
    }
    
    public void populateTransaction(TransactionVO targetTransactionVO, TransactionVO sourceTransactionVO) {
        if ( (sourceTransactionVO == null) || (targetTransactionVO == null) ) return;

        Hashtable items_target = new Hashtable();

        Iterator iterator_target = targetTransactionVO.getItems().iterator();

        //We will iterate through all the items of the Target transaction
         ItemVO itemVO;
        while (iterator_target.hasNext()) {
            itemVO = (ItemVO) iterator_target.next();
            items_target.put( itemVO.getType() , itemVO);
        }

        Iterator iterator_source = sourceTransactionVO.getItems().iterator();

        targetTransactionVO.setCreationDate(sourceTransactionVO.getCreationDate());
        targetTransactionVO.setStatus(sourceTransactionVO.getStatus());
        targetTransactionVO.setTransactionId(sourceTransactionVO.getTransactionId());
        targetTransactionVO.setTransactionType(sourceTransactionVO.getTransactionType());
        targetTransactionVO.setUpdateTime(sourceTransactionVO.getUpdateTime());
        targetTransactionVO.setUser(sourceTransactionVO.getUser());
        targetTransactionVO.setServerId(sourceTransactionVO.getServerId());
        targetTransactionVO.setVersion(sourceTransactionVO.getVersion());
        targetTransactionVO.setVersionServerId(sourceTransactionVO.getVersionserverId());

        ItemVO itemVO_source, itemVO_target;
        while (iterator_source.hasNext()) {
            itemVO_source = (ItemVO) iterator_source.next();
            itemVO_target = (ItemVO) items_target.get( itemVO_source.getType() );

            if ( itemVO_target == null  ) {
                targetTransactionVO.getItems().add( itemVO_source );

            } else {
                if ( itemVO_target.getType().equals( itemVO_source.getType())  ) {
                    if (itemVO_source.getValue()==null){
                        itemVO_target.setItemId(new Integer( IdentifierFactory.getInstance().getTemporaryNewIdentifier() ));
                    }
                    else {
                        itemVO_target.setItemId( itemVO_source.getItemId() );
                    }
                    itemVO_target.setType( itemVO_source.getType() );
                    itemVO_target.setDate( itemVO_source.getDate() );
                    itemVO_target.setValue( itemVO_source.getValue() );
                    itemVO_target.setItemContext( itemVO_source.getItemContext() );

                }
            }
        }

    }
    public void setHealthRecordVO(HealthRecordVO healthRecordVO) {
        putObject(HealthRecordVO.class.getName(), healthRecordVO);
    }

    public HealthRecordVO getHealthRecordVO() {

        return  ( HealthRecordVO ) getObject( HealthRecordVO.class.getName() );
    }

    public void setPersonalVaccinationsInfoVO(PersonalVaccinationsInfoVO personalVaccinationsInfoVO) {
        putObject(PersonalVaccinationsInfoVO.class.getName(), personalVaccinationsInfoVO);
    }

    public PersonalVaccinationsInfoVO getPersonalVaccinationsInfoVO() {

        return  ( PersonalVaccinationsInfoVO ) getObject( PersonalVaccinationsInfoVO.class.getName() );
    }

    public VaccinationInfoVO getCurrentVaccinationInfoVO() {

        return  ( VaccinationInfoVO ) getObject( VaccinationInfoVO.class.getName() );
    }

    public void setCurrentVaccinationInfoVO(VaccinationInfoVO vaccinationInfoVO) {
        putObject(VaccinationInfoVO.class.getName(), vaccinationInfoVO);
    }

    public void setAlerts(Collection alertTransactions) {
        putObject(this.ALERT_TRANSACTIONS, alertTransactions);
    }

    public Collection getAlerts() {
        return ( Collection ) container.get( this.ALERT_TRANSACTIONS );
    }

    public Collection getActiveAlerts() {
        Vector activeAlerts = new Vector();
        Collection alerts = (Collection) container.get( this.ALERT_TRANSACTIONS );
        Iterator i = alerts.iterator();
        boolean denied;
        TransactionVO t;
        Iterator items;
        ItemVO item;
        Date expiration;

        while (i.hasNext()){
            denied = false;
            t = (TransactionVO)i.next();
            if (t!=null){
                items = t.getItems().iterator();
                while (items.hasNext()){
                    item = (ItemVO) items.next();
                    //Debug.println("type="+item.getType());
                    if (item.getType().equals(be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ALERTS_EXPIRATION_DATE)){
                        try{
                            //Debug.println("value="+item.getValue());
                            expiration = ScreenHelper.parseDate(item.getValue());
                            if (expiration.before(new Date())){
                                denied = true;
                            }
                        }
                        catch (Exception e){
                            e.printStackTrace();
                        }
                    }
                }
                if (!denied){
                    activeAlerts.add(t);
                }
            }
        }
        return activeAlerts;
    }

    public void setAuthenticationToken(AuthenticationTokenWO authenticationTokenWO) {
        container.put(this.WO_AUTHENTICATION_TOKEN, authenticationTokenWO);
    }

    public AuthenticationTokenWO getAuthenticationToken() {
        return (AuthenticationTokenWO) container.get(this.WO_AUTHENTICATION_TOKEN);
    }

    public URLHistory getURLHistory(){
        return (URLHistory) container.get(this.HISTORY);
    }

    public void setURLHistory(URLHistory urlHistory){
        container.put(this.HISTORY, urlHistory);
    }

    public Exception getLastException() {
        return (Exception) container.get(this.EXCEPTION);
    }

    public void setLastException(Exception exception) {
        container.put(this.EXCEPTION, exception);
    }

    public void setCurrentFolder(String name) {
        currentFoldername = name;
    }

    public FolderWO getCurrentFolder() {
        FolderWO folderWO = null;
        if (currentFoldername != null) folderWO = getFolder(currentFoldername);
        return folderWO;
    }

    public FolderWO getFolder(String name){
        FolderWO folderWO = null;
        String foldername = this.FOLDER + name;
        folderWO = (FolderWO) container.get(foldername);
        return folderWO;
    }

    public void addFolder(String name, FolderWO folderWO){
        String foldername = this.FOLDER + name;
        container.put(foldername, folderWO);
    }

    public void removeFolder(String name){
        String foldername = this.FOLDER + name;
        container.remove(foldername);
    }

    public PersonWO getCurrentPatient() {
        PersonWO personWO = null;

        Object o = getCurrentFolder();
        if ( (o != null) && (o instanceof HealthRecordWO) ) {
            HealthRecordWO healthRecordWO = (HealthRecordWO) o;
            personWO = healthRecordWO.getPerson();
        }

        return personWO;
    }

    public Object getObject(String key) {
    	return this.container.get(key);
    }

    public void putObject(String key, Object o) {
        if (o==null){
            this.container.remove(key);
        }
        else {
            this.container.put(key, o);
        }
    }

    public String getBrowserTitle(){
        return (String)container.get(this.BROWSER_TITLE);
    }

    public void setBrowserTitle(String title){
        container.put(this.BROWSER_TITLE, title);
    }
}