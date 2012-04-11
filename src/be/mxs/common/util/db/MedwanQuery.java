package be.mxs.common.util.db;
import be.dpms.medwan.common.model.vo.administration.PersonVO;
import be.dpms.medwan.common.model.vo.authentication.UserVO;
import be.dpms.medwan.common.model.vo.occupationalmedicine.*;
import be.dpms.medwan.common.model.vo.recruitment.FullRecordVO;
import be.dpms.medwan.common.model.vo.recruitment.RecordRowVO;
import be.dpms.medwan.services.exceptions.InternalServiceException;
import be.dpms.medwan.webapp.wo.common.system.SessionContainerWO;
import be.mxs.common.model.vo.IdentifierFactory;
import be.mxs.common.model.vo.healthrecord.*;
import be.mxs.common.util.broker.BrokerScheduler;
import be.mxs.common.util.io.MessageReader;
import be.mxs.common.util.io.MessageReaderMedidoc;
import be.mxs.common.util.system.Debug;
import be.mxs.common.util.system.ScreenHelper;
import be.openclinic.finance.Prestation;

import com.inzoom.oledb.Session;
import com.jpos.POStest.DS6708;

import net.admin.Label;
import net.admin.Service;
import net.admin.User;

import org.dom4j.Document;
import org.dom4j.DocumentException;
import org.dom4j.DocumentHelper;
import org.dom4j.Element;
import org.dom4j.io.SAXReader;

import javax.naming.Context;
import javax.naming.InitialContext;
import javax.naming.NamingException;
import javax.servlet.http.HttpSession;
import javax.sql.DataSource;
import java.io.File;
import java.net.URL;
import java.net.InetAddress;
import java.net.UnknownHostException;
import java.sql.*;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.*;
import java.util.Date;

import jpos.JposException;
import be.openclinic.adt.Encounter;
import be.openclinic.common.OC_Object;
import be.openclinic.datacenter.Scheduler;
public class MedwanQuery {
	private static DataSource dsOpenClinic=null;
	private static DataSource dsLongOpenClinic=null;
	private static DataSource dsAdmin=null;
	private static DataSource dsLongAdmin=null;
	private static DataSource dsStats=null;
    private static MedwanQuery medwanQuery = null;
    private static Hashtable sessions = new Hashtable();
    private String dsAdminName = "admindb";
    private String dsConfigName = "configdb";
    private String dsLongAdminName = "longadmindb";
    private String dsOpenclinicName = "openclinicdb";
    private String dsLongOpenclinicName = "longopenclinicdb";
    private String dsStatsName = "statsdb";
    private Hashtable activities = new Hashtable();
    private Hashtable config;
    private Hashtable restrictedDiagnoses;
    private Hashtable labels;
    private Hashtable labelsCache = new Hashtable();
    private SortedMap labelsCacheDates = new TreeMap();
    private Hashtable forwards;
    private Hashtable riskExaminationLabcodes;
    private Hashtable sessionValues = new Hashtable();
    private Hashtable riskCategories;
    private String uri;
    private SimpleDateFormat stdDateFormat;
    private List autocompletionItemTypes;
    private String accomodationprestationuids = null;
    public Hashtable services = new Hashtable();
    public Hashtable barcodeids = new Hashtable();
    private ObjectCache objectCache = ObjectCacheFactory.getInstance().getObjectCache();
    private Hashtable usedCounters = new Hashtable();
    private Hashtable progressValues = new Hashtable();
    private Hashtable disabledApplications = new Hashtable();
    private Hashtable examinations = new Hashtable();
    private Hashtable serviceexaminations = new Hashtable();
    private Hashtable serviceexaminationsincludingparent = new Hashtable();
    private static Scheduler scheduler;
    private static BrokerScheduler brokerScheduler;
    private Hashtable datacenterparametertypes=new Hashtable();

    public Hashtable getDatacenterparametertypes() {
		return datacenterparametertypes;
	}

	public void setDatacenterparametertypes(Hashtable datacenterparametertypes) {
		this.datacenterparametertypes = datacenterparametertypes;
	}

	public static Hashtable getSessions() {
		return sessions;
	}

	public static void setSessions(Hashtable s) {
		sessions = s;
	}
	
	public void runScheduler(){
		if(scheduler!=null){
			scheduler.runScheduler();
		}
	}
	
	public void removeExamination(String id){
    	Enumeration e = examinations.keys();
    	while(e.hasMoreElements()){
    		String key=(String)e.nextElement();
    		ExaminationVO examinationVO = (ExaminationVO)examinations.get(key);
    		if(examinationVO!=null && key.startsWith(id+".")){
    			examinations.remove(key);
    		}
    	}
    }
    
    public static void setSession(HttpSession session,User user){
    	Enumeration e = sessions.keys();
    	while(e.hasMoreElements()){
    		HttpSession s = (HttpSession)e.nextElement();
    		try{
	    		if(s!=null && (new Date().getTime()-s.getLastAccessedTime())>=1200000){
	    			sessions.remove(s);
	    		}
    		}
    		catch(Exception e2){
    			sessions.remove(s);
    		}
    	}
    	if(session!=null && (new Date().getTime()-session.getLastAccessedTime())<1200000 && user!=null){
    		sessions.put(session, user);
    	}
    }
    
    public void removeServiceExaminations(String id){
    	Enumeration e = serviceexaminations.keys();
    	while(e.hasMoreElements()){
    		String key=(String)e.nextElement();
    		Vector exams = (Vector)serviceexaminations.get(key);
    		if(exams!=null && key.startsWith(id+".")){
    			serviceexaminations.remove(key);
    		}
    	}
    	e = serviceexaminationsincludingparent.keys();
    	while(e.hasMoreElements()){
    		String key=(String)e.nextElement();
    		Vector exams = (Vector)serviceexaminationsincludingparent.get(key);
    		if(exams!=null && key.startsWith(id+".")){
    			serviceexaminationsincludingparent.remove(key);
    		}
    	}
    }
    public Hashtable getServiceexaminations() {
		return serviceexaminations;
	}

	public void setServiceexaminations(Hashtable serviceexaminations) {
		this.serviceexaminations = serviceexaminations;
	}

	public Hashtable getServiceexaminationsincludingparent() {
		return serviceexaminationsincludingparent;
	}

	public void setServiceexaminationsincludingparent(Hashtable serviceexaminationsincludingparent) {
		this.serviceexaminationsincludingparent = serviceexaminationsincludingparent;
	}

	public Hashtable getExaminations() {
		return examinations;
	}

	public void setExaminations(Hashtable examinations) {
		this.examinations = examinations;
	}

	public Hashtable getDisabledApplications() {
		return disabledApplications;
	}

	public void setDisabledApplications(Hashtable disabledApplications) {
		this.disabledApplications = disabledApplications;
	}

	public Hashtable getUsedCounters() {
		return usedCounters;
	}

	public void setUsedCounters(Hashtable usedCounters) {
		this.usedCounters = usedCounters;
	}

	public ObjectCache getObjectCache() {
        return objectCache;
    }
    
    public void setProgressValue(String id, int value){
    	progressValues.put(id, Integer.valueOf(value));
    }
    
    public int getProgressValue(String id){
    	Integer value = (Integer)progressValues.get(id);
    	if(value==null){
    		return 0;
    	}
    	else {
    		return value.intValue();
    	}
    }
    
    public String getAccomodationPrestationUIDs() {
        if (accomodationprestationuids == null) {
            accomodationprestationuids = "";
            String[] prestationcodes = getConfigString("accomodationPrestations", "").split(";");
            for (int n = 0; n < prestationcodes.length; n++) {
                Prestation prestation = Prestation.getByCode(prestationcodes[n]);
                if (prestation != null) {
                    if (accomodationprestationuids.length() > 0) {
                        accomodationprestationuids += ";";
                    }
                    accomodationprestationuids += prestation.getUid();
                }
            }
        }
        return accomodationprestationuids;
    }
    public class NationalBarcodeID {
        public String id;
        public String lastname;
        public String firstname;
        public Date date;
    }
    public void setNationalBarcodeId(String ip, String id, String lastname, String firstname) {
        NationalBarcodeID nationalBarcodeID = new NationalBarcodeID();
        nationalBarcodeID.id = id;
        nationalBarcodeID.lastname = lastname;
        nationalBarcodeID.firstname = firstname;
        nationalBarcodeID.date = new Date();
        barcodeids.put(ip, nationalBarcodeID);
    }
    public NationalBarcodeID getNationalBarcodeID(String ip) {
        return (NationalBarcodeID) barcodeids.get(ip);
    }
    public void removeNationalBarcodeID(String ip) {
        barcodeids.remove(ip);
    }
    public class Activity {
        public boolean md;
        public boolean provider;
    }
    public boolean isRestrictedDiagnosis(String codetype, String code) {
        if (restrictedDiagnoses.get(codetype + "|" + code) != null) return true;
        Enumeration keys = restrictedDiagnoses.keys();
        while (keys.hasMoreElements()) {
            String key = (String) keys.nextElement();
            if ((codetype + "|" + code).startsWith(key)) {
                return true;
            }
        }
        return false;
    }
    public String concatSign() {
        //For MySQL (in ANSI mode): ||
        return getConfigString("concatSign", "+");
    }
    public String datediff(String interval, String begindate, String enddate) {
        //For MySql: datediff($enddate$,$begindate$)
        String s = getConfigString("datediffFunction", "datediff($interval$,$begindate$,$enddate$)");
        return s.replaceAll("\\$interval\\$", interval).replaceAll("\\$begindate\\$", begindate).replaceAll("\\$enddate\\$", enddate);
    }
    public String convert(String datatype, String value) {
        //Now replace the datatypes when needed
        //For MySql: varchar --> char, float --> decimal, int --> signed
    	String s=getConfigString("convertFunction", "convert($datatype$,$value$)");
    	if(datatype.equalsIgnoreCase("varchar")){
            //For MySQL: concat($value$)
    		String s2 = getConfigString("varcharConvertFunction","---");
    		if(!s2.equalsIgnoreCase("---")){
    			s = s2;
    		}
    	}
    	datatype = datatype.replaceAll("varchar", getConfigString("convertDataTypeVarchar", "varchar"));
        datatype = datatype.replaceAll("float", getConfigString("convertDataTypeFloat", "float"));
        datatype = datatype.replaceAll("int", getConfigString("convertDataTypeInt", "int"));
        datatype = datatype.replaceAll("smalldatetime", getConfigString("convertDataTypeSmalldatetime", "smalldatetime"));
        return s.replaceAll("\\$datatype\\$", datatype).replaceAll("\\$value\\$", value);
    }
    public String iif(String condition, String ifTrue, String ifFalse) {
        //For MySQL: if($condition$,$iftrue$,$iffalse$)
        String s = getConfigString("iifFunction", "case when $condition$ then $iftrue$ else $iffalse$ end");
        return s.replaceAll("\\$condition\\$", condition).replaceAll("\\$iftrue\\$", ifTrue).replaceAll("\\$iffalse\\$", ifFalse);
    }
    public String topFunction(String rows) {
        if (getConfigString("topFunction", "top").equals("top")) {
            return " top " + rows + " ";
        } else {
            return "";
        }
    }
    public String limitFunction(String rows) {
        if (getConfigString("limitFunction", "").equals("")) {
            return "";
        } else {
            return " limit " + rows + " ";
        }
    }
    public String convertExtended(String datatype, String value, String extended) {
        String s = getConfigString("convertFunctionExtended", "convert($datatype$,$value$,$extended$)");
        return (s.replaceAll("\\$datatype\\$", datatype).replaceAll("\\$value\\$", value).replaceAll("\\$extended\\$", extended));
    }
    public String convertStringToDate(String date) {
        //For MySQL: str_to_date($date$,'%d/%m/%Y')
        String s = getConfigString("convertStringToDateFunction", "convert(datetime,$date$,103)");
        return s.replaceAll("\\$date\\$", date);
    }
    public String convertDateToString(String date) {
        //For MySQL: date_format($date$,'%d/%m/%Y')
        String s = getConfigString("convertDateToStringFunction", "convert(char(10),$date$,103)");
        return s.replaceAll("\\$date\\$", date);
    }
    public void initializeBarcodeScanner() {
        if (MedwanQuery.getInstance().getConfigInt("JPOSenabled", 0) == 1) {
            DS6708 ds6708 = new DS6708();
        }
    }
    public MedwanQuery(String uri) {
        config = new Hashtable();
        restrictedDiagnoses = new Hashtable();
        labels = new Hashtable();
        forwards = new Hashtable();
        SAXReader reader = new SAXReader(false);
        stdDateFormat = new SimpleDateFormat("dd/MM/yyyy");

        //First let's try to find out which databases we need to use
        //Database specs are optionally defined in application.xml

		Context ctx;
		try {
			ctx = new InitialContext();
			dsOpenClinic = (DataSource)ctx.lookup("java:comp/env/openclinic");
			dsLongOpenClinic = (DataSource)ctx.lookup("java:comp/env/longopenclinic");
			dsAdmin = (DataSource)ctx.lookup("java:comp/env/admin");
			dsLongAdmin = (DataSource)ctx.lookup("java:comp/env/longadmin");
			dsStats = (DataSource)ctx.lookup("java:comp/env/stats");
		} catch (NamingException e1) {
			// TODO Auto-generated catch block
			e1.printStackTrace();
		}


        this.uri = uri;

        // load config values from DB
        Statement configStatement = null;
        ResultSet rs = null;
        Connection oc_conn=getOpenclinicConnection();
        try {
        	configStatement = oc_conn.createStatement();
            rs = configStatement.executeQuery("select * from OC_Config order by oc_key");
            while (rs.next()) {
                config.put(rs.getString("oc_key") + "", rs.getString("oc_value") + "");
            }
            // set Debug
            Debug.enabled = getConfigString("Debug").equalsIgnoreCase("on");
        }
        catch (Exception e) {
            //e.printStackTrace();
        }
        finally {
            try {
                if (rs != null) rs.close();
                if (configStatement != null) configStatement.close();
                oc_conn.close();
            }
            catch (SQLException se) {
                se.printStackTrace();
            }
        }

        // load config values from XML
        try {
            String sDoc = getConfigString("templateSource") + "config.xml";
            Document document = reader.read(new URL(sDoc));
            Element root = document.getRootElement();
            Iterator elements = root.elementIterator("parameter");
            Element parameter;
            while (elements.hasNext()) {
                parameter = (Element) elements.next();
                config.put(parameter.attributeValue("name"), parameter.getTextTrim());
            }
        }
        catch (Exception e) {
            if (Debug.enabled) Debug.println(e.getMessage());
        }

        // load restricted diagnoses from XML
        try {
            String sDoc = getConfigString("templateSource") + "restrictedDiagnosis.xml";
            Document document = reader.read(new URL(sDoc));
            Element root = document.getRootElement();
            Iterator elements = root.elementIterator("diagnosis");
            Element parameter;
            while (elements.hasNext()) {
                parameter = (Element) elements.next();
                restrictedDiagnoses.put(parameter.attributeValue("codetype") + "|" + parameter.attributeValue("code"), parameter.getTextTrim());
            }
        }
        catch (Exception e) {
            if (Debug.enabled) Debug.println(e.getMessage());
        }
        try {
            String sDoc = getConfigString("templateSource") + "activities.xml";
            Document document = reader.read(new URL(sDoc));
            Element root = document.getRootElement();
            Iterator elements = root.elementIterator("activity");
            Element parameter;
            while (elements.hasNext()) {
                parameter = (Element) elements.next();
                Activity activity = new Activity();
                activity.md = parameter.attributeValue("md") != null;
                activity.provider = parameter.attributeValue("provider") != null;
                activities.put(parameter.attribute("code").getValue(), activity);
            }
        }
        catch (Exception e) {
            //if(Debug.enabled) Debug.println(e.getMessage());
        }

        // load forwards from XML
        try {
            String sDoc = getConfigString("templateSource") + "forwards.xml";
            Document document = reader.read(new URL(sDoc));
            Element root = document.getRootElement();
            Iterator elements = root.elementIterator("mapping");
            Element mapping;
            while (elements.hasNext()) {
                mapping = (Element) elements.next();
                forwards.put(mapping.attributeValue("id"), mapping.attributeValue("path"));
            }
        }
        catch (Exception e) {
            //if(Debug.enabled) Debug.println(e.getMessage());
        }
        
        // Load disabledApplications
        oc_conn=getOpenclinicConnection();
        try{
            String sSQL = "SELECT * FROM Applications";
            PreparedStatement ps = oc_conn.prepareStatement(sSQL);
            rs = ps.executeQuery();
            while (rs.next()){
            	disabledApplications.put(rs.getString("ScreenId"),"1");
            }
            rs.close();
            ps.close();

        }
        catch(Exception e){
            e.printStackTrace();
        }
        try {
			oc_conn.close();
		} catch (SQLException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
        loadRiskExaminationLabcodes();
        loadRiskCategories();
        ObjectCacheFactory.getInstance().setObjectCacheSize(getConfigInt("objectCacheSize",10000));
        
        // load DataCenter data
        try {
            String sDoc = getConfigString("datacenterTemplateSource",getConfigString("templateSource")) + "datacenterschedule.xml";
            Document document = reader.read(new URL(sDoc));
            Element root = document.getRootElement();
            Element parameters = root.element("parameters");
            Iterator elements = parameters.elementIterator("parameter");
            Element parameter;
            while (elements.hasNext()) {
                parameter = (Element) elements.next();
                datacenterparametertypes.put(parameter.attributeValue("param"), parameter.attributeValue("type"));
            }
        }
        catch (Exception e) {
            if (Debug.enabled) Debug.println(e.getMessage());
        }
        if(scheduler==null){
        	scheduler=new Scheduler();
        }
        if(brokerScheduler==null){
        	brokerScheduler=new BrokerScheduler();
        }
    }
    
    public void stopScheduler(){
    	if(scheduler!=null){
    		scheduler.setStopped(true);
    	}
    }
    
    public void resetBrokerScheduler(){
    	if(brokerScheduler!=null){
    		brokerScheduler.setStopped(true);
    	}
		brokerScheduler=new BrokerScheduler();
    }
    
    public String getValue(String parameter) {
        if (sessionValues.get(parameter) != null) {
            return (String) sessionValues.get(parameter);
        }
        return "";
    }
    public void setValue(String parameter, String value) {
        sessionValues.put(parameter, value);
    }
    public String getAdminDatasourceName() {
        return dsAdminName;
    }
    public Vector getAlternativeDiagnosisCodes(String sCodeType, String sCode) {
        Vector result = new Vector();
        try {
            Connection oc_conn=getOpenclinicConnection();
            String sQuery = "select distinct " + (sCodeType.equalsIgnoreCase("icpc") ? "icd10" : "icpc") + " as code from Classifications where " + sCodeType.toLowerCase() + " like '" + sCode + "%'";
            PreparedStatement ps = oc_conn.prepareStatement(sQuery);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                result.add(rs.getString("code"));
            }
            rs.close();
            ps.close();
            oc_conn.close();
        }
        catch (Exception e) {
            e.printStackTrace();
        }
        return result;
    }
    public String getDiagnosisLabel(String sCodeType, String sCode, String sLanguage) {
        String result = "";
        try {
            String sQuery = "select * from ICPC2 where code=?";
            if (sCodeType.equalsIgnoreCase("icd10")) {
                sQuery = "select * from ICD10 where code=?";
            }
            Connection oc_conn=getOpenclinicConnection();
            PreparedStatement ps = oc_conn.prepareStatement(sQuery);
            ps.setString(1, sCode);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                if (sLanguage.toLowerCase().startsWith("n")) {
                    result = rs.getString("labelnl");
                } else if (sLanguage.toLowerCase().startsWith("f")) {
                    result = rs.getString("labelfr");
                } else if (sLanguage.toLowerCase().startsWith("e") || sLanguage.toLowerCase().startsWith("p")) {
                    result = rs.getString("labelen");
                } else {
                    result = rs.getString("labelfr");
                }
            }
            rs.close();
            ps.close();
            oc_conn.close();
        }
        catch (Exception e) {
            e.printStackTrace();
        }
        return result;
    }
    public String getOpenclinicDatasourceName() {
        return dsOpenclinicName;
    }
    public String getStatsDatasourceName() {
        return dsStatsName;
    }
    public String getLongOpenclinicDatasourceName() {
        return dsLongOpenclinicName;
    }
    public String getConfigDatasourceName() {
        return dsConfigName;
    }
    public Activity getActivity(String code) {
        Activity activity = new Activity();
        if (activities.get(code) != null) {
            activity = (Activity) activities.get(code);
        }
        return activity;
    }
    public Hashtable getRiskCategories() {
        return riskCategories;
    }
    public String getForward(String action) {
        return (String) forwards.get(action);
    }
    public void setConfigString(String oc_key, String oc_value) {
        Connection connection;
        try {
            connection = getOpenclinicConnection();

            // delete
            PreparedStatement ps = connection.prepareStatement("delete from OC_Config where oc_key=?");
            ps.setString(1, oc_key);
            ps.execute();
            ps.close();

            // insert
            ps = connection.prepareStatement("insert into OC_Config(oc_key,oc_value,updatetime) values(?,?,?)");
            ps.setString(1, oc_key);
            ps.setString(2, oc_value);
            ps.setTimestamp(3, new Timestamp(new java.util.Date().getTime()));
            ps.execute();
            ps.close();
            config.put(oc_key, oc_value);
            connection.close();
        }
        catch (Exception e) {
            e.printStackTrace();
        }
    }
    public void deleteRow(String table, String primaryKey, String primaryKeyValue) {
        Connection AdmindbConnection;
        try {
            AdmindbConnection = getAdminConnection();
            PreparedStatement ps = AdmindbConnection.prepareStatement("insert into Deleted(ow_tablename,ow_primarykey,ow_primarykey_value,updatetime) values(?,?,?,?)");
            ps.setString(1, table);
            ps.setString(2, primaryKey);
            ps.setString(3, primaryKeyValue);
            ps.setTimestamp(4, new Timestamp(new java.util.Date().getTime()));
            ps.execute();
            ps.close();
            AdmindbConnection.close();
        }
        catch (Exception e) {
            e.printStackTrace();
        }
    }
    public boolean userHasMessages(int userid) {
        boolean result = false;
        Connection AdmindbConnection;
        try {
            AdmindbConnection = getAdminConnection();
            PreparedStatement ps = AdmindbConnection.prepareStatement("select * from UserMessages where userid=?");
            ps.setInt(1, userid);
            ResultSet rs = ps.executeQuery();
            result = rs.next();
            rs.close();
            ps.close();
            AdmindbConnection.close();

        }
        catch (Exception e) {
            e.printStackTrace();
        }
        return result;
    }
    public void getSubServices(String serviceid, Vector services) {
        services.add(serviceid);
        Connection AdmindbConnection;
        try {
            AdmindbConnection = getAdminConnection();
            PreparedStatement ps = AdmindbConnection.prepareStatement("select serviceid from Services where serviceparentid=?");
            ps.setString(1, serviceid);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                getSubServices(rs.getString("serviceid"), services);
            }
            rs.close();
            ps.close();
            AdmindbConnection.close();

        }
        catch (Exception e) {
            e.printStackTrace();
        }
    }
    public String getImmatnew(int personid) {
        String sImmatnew = "";
        Connection AdmindbConnection;
        try {
            AdmindbConnection = getAdminConnection();
            PreparedStatement ps = AdmindbConnection.prepareStatement("select immatnew from Admin where personid=?");
            ps.setInt(1, personid);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                sImmatnew = rs.getString("immatnew");
            }
            rs.close();
            ps.close();
            AdmindbConnection.close();

        }
        catch (Exception e) {
            e.printStackTrace();
        }
        return sImmatnew;
    }
    public String getRisksForExamination(RiskProfileVO riskProfileVO, String transactionType) {
        HashSet risks = new HashSet();
        Connection OccupdbConnection;
        try {
            OccupdbConnection = getOpenclinicConnection();
            PreparedStatement ps = OccupdbConnection.prepareStatement("select riskId from RiskExaminations a,Examinations b where a.examinationId=b.id and b.transactionType like ?");
            ps.setString(1, transactionType + '%');
            ResultSet rs = ps.executeQuery();
            int riskId;
            while (rs.next()) {
                riskId = rs.getInt("riskId");
                Iterator iterator = riskProfileVO.getRiskCodes().iterator();
                while (iterator.hasNext()) {
                    RiskProfileRiskCodeVO riskCodeVO = (RiskProfileRiskCodeVO) iterator.next();
                    if (riskCodeVO.getRiskCodeId().intValue() == riskId) {
                        if (!risks.contains(riskCodeVO.getRiskCodeId())) {
                            risks.add(riskCodeVO.getRiskCodeId());
                        }
                    }
                }
            }
            rs.close();
            ps.close();
            OccupdbConnection.close();
        }
        catch (Exception e) {
            e.printStackTrace();
        }
        String riskString = "";
        Iterator iterator = risks.iterator();
        while (iterator.hasNext()) {
            if (riskString.length() > 0) {
                riskString += ",";
            }
            riskString += (iterator.next()).toString();
        }
        return riskString;
    }
    public LabAnalysisVO getLabAnalysisVOByCode(String code) {
        Connection OccupdbConnection;
        LabAnalysisVO labAnalysisVO = null;
        try {
            OccupdbConnection = getOpenclinicConnection();
            PreparedStatement ps = OccupdbConnection.prepareStatement("select * from LabAnalysis where labcode=? and deletetime is null");
            ps.setString(1, code);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                labAnalysisVO = new LabAnalysisVO(code, rs.getString("medidoccode"), null, null, null);
                labAnalysisVO.setSample(rs.getString("monster"));
                labAnalysisVO.setType(rs.getString("labtype"));
                labAnalysisVO.setId(rs.getString("labID"));
            }
            rs.close();
            ps.close();
            OccupdbConnection.close();
        }
        catch (Exception e) {
            e.printStackTrace();
        }
        return labAnalysisVO;
    }
    //--- GET TRANSACTION FOR ITEM ----------------------------------------------------------------
    public TransactionVO getTransactionForItem(String type, String value) {
        TransactionVO transaction = null;
        try {
            Connection loc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
            String sQuery = "select * from Items where valuehash=? and type=? and value=?";
            PreparedStatement ps = loc_conn.prepareStatement(sQuery);
            ps.setInt(1, (type + value).hashCode());
            ps.setString(2, type);
            ps.setString(3, value);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                transaction = loadTransaction(rs.getInt("serverid"), rs.getInt("transactionId"));
            }
            rs.close();
            ps.close();
            loc_conn.close();
        }
        catch (Exception e) {
            e.printStackTrace();
        }
        return transaction;
    }
    public void loadRiskCategories() {
        riskCategories = new Hashtable();
        PreparedStatement ps = null;
        ResultSet rs = null;
        Connection OccupdbConnection = getOpenclinicConnection();
        try {
            ps = OccupdbConnection.prepareStatement("select groupType,linkId from RiskGroups where groupName='Basic' and active=1");
            rs = ps.executeQuery();
            while (rs.next()) {
                riskCategories.put(rs.getString("groupType").toLowerCase() + "." + new Integer(rs.getInt("linkId")), "1");
            }
        }
        catch (Exception e) {
            if (Debug.enabled) Debug.println(e.getMessage());
        }
        finally {
            try {
                if (rs != null) rs.close();
                if (ps != null) ps.close();
                OccupdbConnection.close();
            }
            catch (SQLException se) {
                se.printStackTrace();
            }
        }
    }
    public void loadRiskExaminationLabcodes() {
        riskExaminationLabcodes = new Hashtable();
        Vector labcodes = new Vector();
        PreparedStatement ps = null;
        ResultSet rs = null;
        Connection OccupdbConnection = getOpenclinicConnection();
        try {
            ps = OccupdbConnection.prepareStatement("select a.riskExaminationId,b.* from LabRiskExaminationAnalyses a,LabAnalysis b where a.code=b.labcode  and b.deletetime is null order by riskExaminationId");
            rs = ps.executeQuery();
            int activeRiskExaminationId = -1;
            while (rs.next()) {
                if (activeRiskExaminationId != -1 && activeRiskExaminationId != rs.getInt("riskExaminationId")) {
                    riskExaminationLabcodes.put(new Integer(activeRiskExaminationId), labcodes);
                    labcodes = new Vector();
                }
                labcodes.add(new LabAnalysisVO(rs.getString("labcode"), rs.getString("medidoccode"), null, null, null));
                activeRiskExaminationId = rs.getInt("riskExaminationId");
            }
            if (labcodes.size() > 0) {
                riskExaminationLabcodes.put(new Integer(activeRiskExaminationId), labcodes);
            }
        }
        catch (Exception e) {
            if (Debug.enabled) Debug.println(e.getMessage());
        }
        finally {
            try {
                if (rs != null) rs.close();
                if (ps != null) ps.close();
                OccupdbConnection.close();
            }
            catch (SQLException se) {
                se.printStackTrace();
            }
        }
    }
    public Vector getRiskExaminationLabcodes(int riskExaminationId) {
        return (Vector) riskExaminationLabcodes.get(new Integer(riskExaminationId));
    }
    public Connection getConfigConnection() {
    	Connection conn=null;
    	try {
    		conn=dsOpenClinic.getConnection();
		} catch (Exception e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
    	return conn;
    }
    public void out(String msg) {
        // nothing
    }
    public Hashtable getItemDefaults(int userid) {
        Hashtable hashtable = new Hashtable();
        Connection OccupdbConnection;
        try {
            OccupdbConnection = getOpenclinicConnection();
            PreparedStatement ps = OccupdbConnection.prepareStatement("select * from ItemTypeAttributes where name='DefaultValue' and userid=?");
            ps.setInt(1, userid);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                hashtable.put(rs.getString("itemType"), rs.getString("value"));
            }
            rs.close();
            ps.close();
            OccupdbConnection.close();
        } catch (Exception e) {
            e.printStackTrace();
        }
        return hashtable;
    }
    public void putLabels(Hashtable tmpLabels) {
        this.labels = tmpLabels;
    }
    public Hashtable getLabels() {
        return this.labels;
    }
    //--- REMOVE LABEL FROM CACHE -----------------------------------------------------------------
    public void removeLabelFromCache(String type, String id, String lang) {
        Object removedObj = labelsCache.remove((type + "." + id + "." + lang).toLowerCase());
        if (Debug.enabled) {
            if (removedObj != null) {
                Debug.println("*** removeLabelFromCache : Label '" + (type + "." + id + "." + lang).toLowerCase() + "' removed from labelCache");
            } else {
                Debug.println("*** removeLabelFromCache : Label '" + (type + "." + id + "." + lang).toLowerCase() + "' not found in labelCache");
            }
            Debug.println("*** Labels in cache : " + labelsCache.size());
        }
    }
    //--- GET LABEL -------------------------------------------------------------------------------
    public String getLabel(String type, String id, String lang) {
        type = type.toLowerCase();
        id = id.toLowerCase();
        lang = lang.toLowerCase();
        String labelValue = id;
        if (type.equalsIgnoreCase("service") || type.equalsIgnoreCase("externalservice") || type.equalsIgnoreCase("function")) {
            String uid = type + "." + id + "." + lang;
            labelValue = (String) labelsCache.get(uid);
            if (labelValue == null || labelValue.length() == 0) {
                labelValue = ScreenHelper.getTranDb(type, id, lang);
                labelsCache.put(uid, labelValue);
                labelsCacheDates.put(new Date(), uid);
                if (labelsCacheDates.size() > 1000) {
                    String oldestLabel = (String) labelsCacheDates.get(labelsCacheDates.firstKey());
                    labelsCacheDates.remove(labelsCacheDates.firstKey());
                    labelsCache.remove(oldestLabel);
                }
            }
        } else {
            if (labels != null) {
                Hashtable langHashtable = MedwanQuery.getInstance().getLabels();
                if (langHashtable == null) {
                    return id;
                }
                Hashtable typeHashtable = (Hashtable) langHashtable.get(lang.toLowerCase());
                if (typeHashtable == null) {
                    return id;
                }
                Hashtable idHashtable = (Hashtable) typeHashtable.get(type.toLowerCase());
                if (idHashtable == null) {
                    return id;
                }
                Label label = (Label) idHashtable.get(id.toLowerCase());
                if (label == null) {
                    return id;
                }
                labelValue = label.value;
            }
        }
        return labelValue;
    }
    //--- GET LABEL (with or without seek) --------------------------------------------------------
    public String getLabel(String type, String id, String lang, boolean seek) {
        String labelValue = id;
        if (type.equalsIgnoreCase("service") || type.equalsIgnoreCase("externalservice") || type.equalsIgnoreCase("function")) {
            labelValue = ScreenHelper.getTranDb(type, id, lang);
        } else {
            boolean labelFound = true;
            if (labels != null) {
                Hashtable typeHashtable = (Hashtable) labels.get(lang.toLowerCase());
                if (typeHashtable == null) {
                    labelValue = id;
                    labelFound = false;
                }
                if (labelFound) {
                    Hashtable idHashtable = (Hashtable) typeHashtable.get(type.toLowerCase());
                    if (idHashtable == null) {
                        labelValue = id;
                        labelFound = false;
                    }
                    if (labelFound) {
                        Label label = (Label) idHashtable.get(id.toLowerCase());
                        if (label == null) {
                            labelValue = id;
                            labelFound = false;
                        } else {
                            labelValue = label.value;
                            labelFound = true;
                        }
                    }
                }
            }
            if (!labelFound & seek) {
                String sTmp = ScreenHelper.getTranNoLink(type, id, lang);
                if (sTmp.trim().length() > 0) {
                    labelValue = sTmp;
                }
            }
        }
        return labelValue;
    }
    //--- STORE LABEL -----------------------------------------------------------------------------
    public void storeLabel(String labelType, String labelId, String labelLang, String labelValue, int updateUserId) {
        PreparedStatement ps = null;
        ResultSet rs = null;
        Connection oc_conn=getOpenclinicConnection();
        try {
            // check existence
            boolean labelFound = false;
            String lcaseLabelType = getConfigParam("lowerCompare", "OC_LABEL_TYPE"),
                    lcaseLabelID = getConfigParam("lowerCompare", "OC_LABEL_ID"),
                    lcaseLabelLang = getConfigParam("lowerCompare", "OC_LABEL_LANGUAGE");
            String sSelect = "SELECT * FROM OC_LABELS " +
                    " WHERE " + lcaseLabelType + " = ?" +
                    "  AND " + lcaseLabelID + " = ?" +
                    "  AND " + lcaseLabelLang + " = ?";
            ps = oc_conn.prepareStatement(sSelect);
            ps.setString(1, labelType.toLowerCase());
            ps.setString(2, labelId.toLowerCase());
            ps.setString(3, labelLang.toLowerCase());
            rs = ps.executeQuery();
            if (rs.next()) labelFound = true;
            if (rs != null) rs.close();
            if (ps != null) ps.close();
            if (!labelFound) {
                // insert label
                String sQuery = "INSERT INTO OC_LABELS (OC_LABEL_TYPE, OC_LABEL_ID, OC_LABEL_LANGUAGE," +
                        "  OC_LABEL_VALUE, OC_LABEL_SHOWLINK, OC_LABEL_UPDATEUSERID, OC_LABEL_UPDATETIME)" +
                        " VALUES (?,?,?,?,?,?,?)";
                ps = oc_conn.prepareStatement(sQuery);
                ps.setString(1, labelType.toLowerCase());
                ps.setString(2, labelId.toLowerCase());
                ps.setString(3, labelLang.toLowerCase());
                ps.setString(4, labelValue);
                ps.setBoolean(5, false);
                ps.setInt(6, updateUserId);
                ps.setTimestamp(7, new Timestamp(new java.util.Date().getTime())); // NOW
                ps.execute();
            }
        }
        catch (Exception e) {
            e.printStackTrace();
        }
        finally {
            try {
                if (rs != null) rs.close();
                if (ps != null) ps.close();
                oc_conn.close();
            }
            catch (SQLException se) {
                se.printStackTrace();
            }
        }
    }
    //--- GET CONFIG PARAM (single parameter) -----------------------------------------------------
    public String getConfigParam(String key, String param) {
        return getConfigString(key).replaceAll("<param>", param);
    }
    //--- GET CONFIG PARAM (multiple parameters) --------------------------------------------------
    public String getConfigParam(String key, String[] params) {
        String result = getConfigString(key);
        for (int i = 0; i < params.length; i++) {
            result = result.replaceAll("<param" + (i + 1) + ">", params[i]);
        }
        return result;
    }
    //--- GET CONFIG STRING -----------------------------------------------------------------------
    public String getConfigString(String key) {
        if (config.get(key) == null) {
            return "";
        }
        return (String) config.get(key);
    }
    //--- GET CONFIG STRING -----------------------------------------------------------------------
    public String getConfigString(String key, String defaultValue) {
        String configString = (String) config.get(key);
        if (configString == null) {
            return defaultValue;
        } else {
            return configString;
        }
    }
    //--- GET CONFIG INT --------------------------------------------------------------------------
    public int getConfigInt(String key) {
        String configString = (String) config.get(key);
        if (configString != null) {
            try {
                return Integer.parseInt(configString);
            }
            catch (Exception e) {
                Debug.println("WARNING : ConfigInt \"" + key + "\" requested but NO INTEGER. (Value = '" + configString + "')");
                return -1;
            }
        }

        //Debug.println("WARNING : ConfigInt \""+key+"\" requested but NOT FOUND.");
        return -1;
    }
    //--- GET CONFIG INT --------------------------------------------------------------------------
    public int getConfigInt(String key, int defaultValue) {
        String configString = (String) config.get(key);
        if (configString != null) {
            try {
                return Integer.parseInt(configString);
            }
            catch (Exception e) {
                Debug.println("WARNING : ConfigInt \"" + key + "\" requested but NO INTEGER. (Value = '" + configString + "')");
                return -1;
            }
        }

        //Debug.println("WARNING : ConfigInt \""+key+"\" requested but NOT FOUND.");
        return defaultValue;
    }
    public String getIdsToUpdateXml() {
        String ids = "<idrequest>\n";
        Connection adminConnection;
        PreparedStatement ps;
        ResultSet rs;
        try {
            adminConnection = getAdminConnection();
            ps = adminConnection.prepareStatement("select personid from Admin where personid<0");
            rs = ps.executeQuery();
            while (rs.next()) {
                ids += "<id type='admin' localid='" + rs.getInt("personid") + "'/>\n";
            }
            rs.close();
            ps.close();
            ps = adminConnection.prepareStatement("select privateid from AdminPrivate where privateid<0");
            rs = ps.executeQuery();
            while (rs.next()) {
                ids += "<id type='private' localid='" + rs.getInt("privateid") + "'/>\n";
            }
            rs.close();
            ps.close();
            ps = adminConnection.prepareStatement("select userid from Users where userid<0");
            rs = ps.executeQuery();
            while (rs.next()) {
                ids += "<id type='user' localid='" + rs.getInt("userid") + "'/>\n";
            }
            rs.close();
            ps.close();
            adminConnection.close();
        } catch (Exception e) {
            e.printStackTrace();
        }
        ids += "</idrequest>";
        return ids;
    }
    
    public void spdSendMail(String to, String from, String subject, String message) {
        Connection OccupdbConnection;
        try {
            OccupdbConnection = getOpenclinicConnection();
            CallableStatement cs = OccupdbConnection.prepareCall(getConfigString("spdSendMailCommand"));
            cs.setString(1, to);
            cs.setString(2, from);
            cs.setString(3, subject);
            cs.setString(4, message);
            cs.execute();
            cs.close();
            OccupdbConnection.close();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
    public void exportPerson(int personId) {
        if (MedwanQuery.getInstance().getConfigInt("exportEnabled") == 1) {
            Connection OccupdbConnection;
            try {
                OccupdbConnection = getOpenclinicConnection();
                PreparedStatement ps = OccupdbConnection.prepareStatement("select * from exportPersons where personId=? and exportDate is null");
                ps.setInt(1, personId);
                ResultSet rs = ps.executeQuery();
                if (!rs.next()) {
                	rs.close();
                    ps.close();
                    ps = OccupdbConnection.prepareStatement("insert into exportPersons(personId,requestDate) values(?,?)");
                    ps.setInt(1, personId);
                    ps.setTimestamp(2, new Timestamp(new java.util.Date().getTime()));
                    ps.execute();
                }
                else {
                	rs.close();
                }
                ps.close();
                OccupdbConnection.close();
            }
            catch (Exception e) {
                e.printStackTrace();
            }
        }
    }
    public boolean removeActivity(String activityId, boolean forceRemove) {
        Connection OccupdbConnection;
        try {
            OccupdbConnection = getOpenclinicConnection();
            PreparedStatement ps;
            if (!forceRemove) {
                ps = OccupdbConnection.prepareStatement("select * from exportActivities where activityId=? and validated is not null");
                ps.setString(1, activityId);
                ResultSet rs = ps.executeQuery();
                if (rs.next()) {
                	rs.close();
                	ps.close();
                	OccupdbConnection.close();
                    return false;
                }
                rs.close();
                ps.close();
            }
            ps = OccupdbConnection.prepareStatement("delete from exportActivities where activityId=?");
            ps.setString(1, activityId);
            ps.execute();
            ps.close();
            OccupdbConnection.close();
        }
        catch (Exception e) {
            e.printStackTrace();
        }
        return true;
    }
    public boolean storeActivity(int personId, int userId, java.util.Date activityDateTime, String activityCode,
                                 String activityId, String provider, String value, String MD, String workinguserid, String medicalCenter, String activePara) {
        Connection OccupdbConnection;
        try {
            OccupdbConnection = getOpenclinicConnection();
            PreparedStatement ps = OccupdbConnection.prepareStatement("select * from exportActivities where activityId=?");
            ps.setString(1, activityId);
            ResultSet rs = ps.executeQuery();
            if (!rs.next()) {
            	rs.close();
            	ps.close();
                ps = OccupdbConnection.prepareStatement("insert exportActivities(personId,userId,activityDateTime,activityCode,activityId,medicalCenter,MD,para,ts,provider," + getConfigString("valueColumn") + ") values(?,?,?,?,?,?,?,?,?,?,?)");
                ps.setInt(1, personId);
                ps.setInt(2, userId);
                ps.setDate(3, new java.sql.Date(activityDateTime.getTime()));
                ps.setString(4, checkString(activityCode));
                ps.setString(5, checkString(activityId));
                ps.setString(6, checkString(medicalCenter));
                ps.setString(7, checkString(MD));
                /*if(MD.length() > 0){
                    ps.setString(7, MD);
                }*/
                ps.setString(8, checkString(activePara));
                ps.setTimestamp(9, new Timestamp(new java.util.Date().getTime()));
                ps.setString(10, provider);
                ps.setString(11, value);
                ps.execute();
            }
            else {
            	rs.close();
            }
            ps.close();
            OccupdbConnection.close();

            return true;
        }
        catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }
    public boolean updateActivity(int personId, int userId, java.util.Date activityDateTime, String activityCode, String activityId, String medicalCenter, String md, String para, String provider, String value) {
        Connection OccupdbConnection;
        try {
            OccupdbConnection = getOpenclinicConnection();
            String query = "UPDATE exportActivities SET personId=?,userId=?,activityDateTime=?,activityCode=?," +
                    " medicalCenter=?,MD=?,para=?,ts=?,provider=?," + getConfigString("valueColumn") + "=?" +
                    " WHERE activityId=?";
            PreparedStatement ps = OccupdbConnection.prepareStatement(query);
            ps.setInt(1, personId);
            ps.setInt(2, userId);
            ps.setDate(3, new java.sql.Date(activityDateTime.getTime()));
            ps.setString(4, activityCode);
            ps.setString(5, medicalCenter);
            ps.setString(6, md);
            ps.setString(7, para);
            ps.setTimestamp(8, new Timestamp(new java.util.Date().getTime()));
            ps.setString(9, provider);
            ps.setString(10, value);
            ps.setString(11, activityId);
            ps.execute();
            ps.close();
            OccupdbConnection.close();
            return true;
        }
        catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }
    public String getActivityCodeWhereExists(String elementType) {
        String code = null;
        Connection OccupdbConnection;
        try {
            OccupdbConnection = getOpenclinicConnection();
            PreparedStatement ps = OccupdbConnection.prepareStatement("select * from exportSpecifications where " + getConfigString("lowerCompare").replaceAll("<param>", "elementType") + "=?");
            ps.setString(1, elementType.toLowerCase());
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                code = rs.getString("exportCode");
            }
            rs.close();
            ps.close();
            OccupdbConnection.close();
        }
        catch (Exception e) {
            e.printStackTrace();
        }
        return code;
    }
    public Vector getActivityCodesWhereExists(String elementType) {
        Vector codes = new Vector();
        Connection OccupdbConnection;
        try {
            OccupdbConnection = getOpenclinicConnection();
            PreparedStatement ps = OccupdbConnection.prepareStatement("select * from exportSpecifications where " + getConfigString("lowerCompare").replaceAll("<param>", "elementType") + "=?");
            ps.setString(1, elementType.toLowerCase());
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                codes.add(rs.getString("exportCode"));
            }
            rs.close();
            ps.close();
            OccupdbConnection.close();
        }
        catch (Exception e) {
            e.printStackTrace();
        }
        return codes;
    }
    public String getActivityCodeWhereValueLike(String elementType, String elementValue) {
        String code = null;
        Connection OccupdbConnection;
        try {
            OccupdbConnection = getOpenclinicConnection();
            PreparedStatement ps = OccupdbConnection.prepareStatement("select * from exportSpecifications where " + getConfigString("lowerCompare").replaceAll("<param>", "elementType") + "=? and " + getConfigString("lowerCompare").replaceAll("<param>", "elementContent") + " like ?");
            ps.setString(1, elementType.toLowerCase());
            ps.setString(2, elementValue.toLowerCase());
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                code = rs.getString("exportCode");
            }
            rs.close();
            ps.close();
            OccupdbConnection.close();
        }
        catch (Exception e) {
            e.printStackTrace();
        }
        return code;
    }
    public void exportTransaction(int personid, TransactionVO transactionVO, String userid, boolean nightShift, String activeMedicalCenter, String activeMD, String activePara) {
        try {
            if (activeMedicalCenter == null) activeMedicalCenter = "";
            if (activeMD == null) activeMD = "";
            if (activePara == null) activePara = "";
            //Eerst het transactionType controleren
            //We zijn vooreerst geïnteresseerd in de formulieren voor gezondheidsbeoordeling
            //De volgende activiteiten worden geregeld via de contexts:
            //500 601 602 609 615
            if (transactionVO.getTransactionType().equalsIgnoreCase("be.mxs.common.model.vo.healthrecord.IConstants.TRANSACTION_TYPE_MER")) {
                //We creeren een activiteit met de context van dit formulier
                ExportActivityVO exportActivityVO = new ExportActivityVO(personid, transactionVO.getUser().getUserId().intValue(), stdDateFormat.format(transactionVO.getUpdateTime()), null, "MER-CONTEXT." + transactionVO.getServerId() + "." + transactionVO.getTransactionId().toString());
                exportActivityVO.setMedicalCenter(activeMedicalCenter);
                exportActivityVO.setMD(activeMD);
                exportActivityVO.setPara(activePara);
                //De oude context van het formulier wissen
                exportActivityVO.remove();
                //De nieuwe context van het formulier opvragen
                ItemVO contextItem = transactionVO.getItem("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CONTEXT_CONTEXT");
                if (contextItem != null) {
                    //We stockeren de context-gebonden prestatiecode
                    if (exportActivityVO.setCodeWhereValueLike("MER-CONTEXT", contextItem.getValue())) {
                        exportActivityVO.store(false, userid);

                        // also add nightshift-activity if required
                        if (nightShift) {
                            addNightShiftActivity(personid, transactionVO, activeMedicalCenter, activeMD, activePara);
                        }
                    }
                }
            } else
            if (transactionVO.getTransactionType().equalsIgnoreCase("be.mxs.common.model.vo.healthrecord.IConstants.TRANSACTION_TYPE_GENERAL_CLINICAL_EXAMINATION")) {
                //We creeren een activiteit met de context van dit formulier
                ExportActivityVO exportActivityVO = new ExportActivityVO(personid, transactionVO.getUser().getUserId().intValue(), stdDateFormat.format(transactionVO.getUpdateTime()), null, "CLINICAL-EXAMINATION-CONTEXT." + transactionVO.getServerId() + "." + transactionVO.getTransactionId().toString());
                exportActivityVO.setMedicalCenter(activeMedicalCenter);
                exportActivityVO.setMD(activeMD);
                exportActivityVO.setPara(activePara);
                //De oude context van het formulier wissen
                exportActivityVO.remove();
                //De nieuwe context van het formulier opvragen
                ItemVO contextItem = transactionVO.getItem("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CONTEXT_CONTEXT");
                if (contextItem != null) {
                    //We stockeren de context-gebonden prestatiecode
                    if (exportActivityVO.setCodeWhereValueLike("CLINICAL-EXAMINATION-CONTEXT", contextItem.getValue())) {
                        exportActivityVO.store(false, userid);

                        // also add nightshift-activity if required
                        if (nightShift) {
                            addNightShiftActivity(personid, transactionVO, activeMedicalCenter, activeMD, activePara);
                        }
                    }
                }
            } else
            if (transactionVO.getTransactionType().equalsIgnoreCase("be.mxs.common.model.vo.healthrecord.IConstants.TRANSACTION_TYPE_ABSENT")) {
                //Controleer op afwezigheid (max 1 afwezigheid per persoon per dag)
                //De volgende activiteiten worden geregeld via het transactietype:
                //638
                ExportActivityVO exportActivityVO = new ExportActivityVO(personid, transactionVO.getUser().getUserId().intValue(), stdDateFormat.format(transactionVO.getUpdateTime()), null, "ABSENT." + personid + "." + stdDateFormat.format(transactionVO.getUpdateTime()));
                exportActivityVO.setMedicalCenter(activeMedicalCenter);
                exportActivityVO.setMD(activeMD);
                exportActivityVO.setPara(activePara);
                if (exportActivityVO.setCodeWhereExists("ABSENT")) {
                    //De oude afwezigheid uniek stockeren
                    exportActivityVO.store(true, userid);

                    // also add nightshift-activity if required
                    if (nightShift) {
                        addNightShiftActivity(personid, transactionVO, activeMedicalCenter, activeMD, activePara);
                    }
                }
            } else
            if (transactionVO.getTransactionType().equals("be.mxs.common.model.vo.healthrecord.IConstants.TRANSACTION_TYPE_VACCINATION")) {
                ExportActivityVO exportActivityVO;
                ItemVO itemVO, prestationActionItem, prestationProductItem;
                Iterator iterator;

                // 1 : prestation is an action (vaccination)
                prestationActionItem = transactionVO.getItem("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OTHER_REQUESTS_PRESTATION_ACTION");
                if (prestationActionItem != null && prestationActionItem.getValue().equalsIgnoreCase("medwan.common.true")) {
                    // We stockeren maximaal 1 prestatie per vaccin per persoon per dag
                    iterator = transactionVO.getItems().iterator();
                    String vaccinationType = "";
                    String vaccinationStatus = "";
                    while (iterator.hasNext()) {
                        itemVO = (ItemVO) iterator.next();
                        if (itemVO.getValue() != null && itemVO.getValue().length() > 0) {
                            if (itemVO.getType().equals("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_VACCINATION_TYPE")) {
                                vaccinationType = itemVO.getValue();
                            }
                            if (itemVO.getType().equals("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_VACCINATION_STATUS")) {
                                vaccinationStatus = itemVO.getValue();
                            }
                        }
                    }

                    // vaccination (action)
                    exportActivityVO = new ExportActivityVO(personid, transactionVO.getUser().getUserId().intValue(), stdDateFormat.format(transactionVO.getUpdateTime()), null, "VACCINATION." + vaccinationType + "." + personid + "." + stdDateFormat.format(transactionVO.getUpdateTime()));
                    exportActivityVO.setMedicalCenter(activeMedicalCenter);
                    exportActivityVO.setMD(activeMD);
                    exportActivityVO.setPara(activePara);
                    if (exportActivityVO.setCodeWhereValueLike("VACCINATION." + vaccinationType, vaccinationStatus)) {
                        exportActivityVO.store(true, userid);

                        // also add nightshift-activity if required
                        if (nightShift) {
                            addNightShiftActivity(personid, transactionVO, activeMedicalCenter, activeMD, activePara);
                        }
                    }
                }

                // 2 : prestation is a product (vaccin)
                prestationProductItem = transactionVO.getItem("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OTHER_REQUESTS_PRESTATION_PRODUCT");
                if (prestationProductItem != null && prestationProductItem.getValue().equalsIgnoreCase("medwan.common.true")) {
                    // We stockeren maximaal 1 prestatie per vaccin per persoon per dag
                    iterator = transactionVO.getItems().iterator();
                    String vaccinationType = "";
                    while (iterator.hasNext()) {
                        itemVO = (ItemVO) iterator.next();
                        if (itemVO.getValue() != null && itemVO.getValue().length() > 0) {
                            if (itemVO.getType().equals("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_VACCINATION_TYPE")) {
                                vaccinationType = itemVO.getValue();
                            }
                        }
                    }

                    // vaccin (product)
                    exportActivityVO = new ExportActivityVO(personid, transactionVO.getUser().getUserId().intValue(), stdDateFormat.format(transactionVO.getUpdateTime()), null, "VACCIN." + vaccinationType + "." + personid + "." + stdDateFormat.format(transactionVO.getUpdateTime()));
                    exportActivityVO.setMedicalCenter(activeMedicalCenter);
                    exportActivityVO.setMD(activeMD);
                    exportActivityVO.setPara(activePara);
                    if (exportActivityVO.setCodeWhereExists("VACCIN." + vaccinationType)) {
                        exportActivityVO.store(true, userid);

                        // also add nightshift-activity if required
                        if (nightShift) {
                            addNightShiftActivity(personid, transactionVO, activeMedicalCenter, activeMD, activePara);
                        }
                    }
                }
            } else
            if (transactionVO.getTransactionType().equals("be.mxs.common.model.vo.healthrecord.IConstants.TRANSACTION_TYPE_DLC")) {
                //We stockeren maximaal 1 prestatie certificaat rijbewijs per persoon per dag
                ExportActivityVO exportActivityVO = new ExportActivityVO(personid, transactionVO.getUser().getUserId().intValue(), stdDateFormat.format(transactionVO.getUpdateTime()), null, "DRIVING-LICENCE." + personid + "." + stdDateFormat.format(transactionVO.getUpdateTime()));
                exportActivityVO.setMedicalCenter(activeMedicalCenter);
                exportActivityVO.setMD(activeMD);
                exportActivityVO.setPara(activePara);
                if (exportActivityVO.setCodeWhereExists("DRIVING-LICENCE")) {
                    exportActivityVO.store(true, userid);

                    // also add nightshift-activity if required
                    if (nightShift) {
                        addNightShiftActivity(personid, transactionVO, activeMedicalCenter, activeMD, activePara);
                    }
                }
            } else
            if (transactionVO.getTransactionType().equals("be.mxs.common.model.vo.healthrecord.IConstants.TRANSACTION_TYPE_OPHTALMOLOGY")) {
                //We stockeren maximaal 1 prestatie ergovision per transactie
                ExportActivityVO exportActivityVO = new ExportActivityVO(personid, transactionVO.getUser().getUserId().intValue(), stdDateFormat.format(transactionVO.getUpdateTime()), null, "ERGOVISION." + transactionVO.getServerId() + "." + transactionVO.getTransactionId().toString());
                exportActivityVO.setMedicalCenter(activeMedicalCenter);
                exportActivityVO.setMD(activeMD);
                exportActivityVO.setPara(activePara);
                //De oude prestatie wissen
                exportActivityVO.remove();
                ItemVO item = transactionVO.getItem("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_ERGOVISION");
                if (item != null) {
                    item = transactionVO.getItem("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_TYPE_PRESTATION");
                    if (item != null && exportActivityVO.setCodeWhereValueLike("ITEM_TYPE_OPTHALMOLOGY_TYPE_PRESTATION", item.getValue())) {
                        exportActivityVO.store(false, userid);
                    } else if (item != null && exportActivityVO.setCodeWhereValueLike("ERGOVISION", item.getValue())) {
                        exportActivityVO.store(false, userid);

                        // also add nightshift-activity if required
                        if (nightShift) {
                            addNightShiftActivity(personid, transactionVO, activeMedicalCenter, activeMD, activePara);
                        }
                    }
                }
                //We stockeren maximaal 1 prestatie visiotest per transactie
                exportActivityVO = new ExportActivityVO(personid, transactionVO.getUser().getUserId().intValue(), stdDateFormat.format(transactionVO.getUpdateTime()), null, "VISIOTEST." + transactionVO.getServerId() + "." + transactionVO.getTransactionId().toString());
                exportActivityVO.setMedicalCenter(activeMedicalCenter);
                exportActivityVO.setMD(activeMD);
                exportActivityVO.setPara(activePara);
                //De oude prestatie wissen
                exportActivityVO.remove();
                item = transactionVO.getItem("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_VISIOTEST");
                if (item != null && exportActivityVO.setCodeWhereValueLike("VISIOTEST", item.getValue())) {
                    exportActivityVO.store(false, userid);

                    // also add nightshift-activity if required
                    if (nightShift) {
                        addNightShiftActivity(personid, transactionVO, activeMedicalCenter, activeMD, activePara);
                    }
                }
            } else
            if (transactionVO.getTransactionType().equals("be.mxs.common.model.vo.healthrecord.IConstants.TRANSACTION_TYPE_AUDIOMETRY")) {
                //We stockeren maximaal 1 prestatie audiometrie per transactie
                ExportActivityVO exportActivityVO = new ExportActivityVO(personid, transactionVO.getUser().getUserId().intValue(), stdDateFormat.format(transactionVO.getUpdateTime()), null, "AUDIOMETRY." + transactionVO.getServerId() + "." + transactionVO.getTransactionId().toString());
                exportActivityVO.setMedicalCenter(activeMedicalCenter);
                exportActivityVO.setMD(activeMD);
                exportActivityVO.setPara(activePara);
                if (exportActivityVO.setCodeWhereExists("AUDIOMETRY")) {
                    exportActivityVO.store(true, userid);

                    // also add nightshift-activity if required
                    if (nightShift) {
                        addNightShiftActivity(personid, transactionVO, activeMedicalCenter, activeMD, activePara);
                    }
                }
            } else
            if (transactionVO.getTransactionType().equals("be.mxs.common.model.vo.healthrecord.IConstants.TRANSACTION_TYPE_ECG")) {
                //We stockeren maximaal 1 prestatie audiometrie per transactie
                ExportActivityVO exportActivityVO = new ExportActivityVO(personid, transactionVO.getUser().getUserId().intValue(), stdDateFormat.format(transactionVO.getUpdateTime()), null, "ECG." + transactionVO.getServerId() + "." + transactionVO.getTransactionId().toString());
                exportActivityVO.setMedicalCenter(activeMedicalCenter);
                exportActivityVO.setMD(activeMD);
                exportActivityVO.setPara(activePara);
                if (exportActivityVO.setCodeWhereExists("ECG")) {
                    exportActivityVO.store(true, userid);

                    // also add nightshift-activity if required
                    if (nightShift) {
                        addNightShiftActivity(personid, transactionVO, activeMedicalCenter, activeMD, activePara);
                    }
                }
            } else
            if (transactionVO.getTransactionType().equals("be.mxs.common.model.vo.healthrecord.IConstants.TRANSACTION_TYPE_MIR")) {
                //We stockeren maximaal 1 prestatie per transactie
                ItemVO item = transactionVO.getItem("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_MIR_TYPE");
                if (item != null) {
                    ExportActivityVO exportActivityVO = new ExportActivityVO(personid, transactionVO.getUser().getUserId().intValue(), stdDateFormat.format(transactionVO.getUpdateTime()), null, "MEDICAL-IMAGING." + transactionVO.getServerId() + "." + transactionVO.getTransactionId().toString());
                    exportActivityVO.setMedicalCenter(activeMedicalCenter);
                    exportActivityVO.setMD(activeMD);
                    exportActivityVO.setPara(activePara);
                    if (exportActivityVO.setCodeWhereExists("MEDICAL-IMAGING." + item.getValue())) {
                        if (transactionVO.getItem("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OTHER_REQUESTS_SUPPLIER") != null) {
                            exportActivityVO.setProvider(transactionVO.getItem("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OTHER_REQUESTS_SUPPLIER").getValue());
                        }
                        if (transactionVO.getItem("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OTHER_REQUESTS_VALUE") != null) {
                            exportActivityVO.setValue(transactionVO.getItem("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OTHER_REQUESTS_VALUE").getValue());
                        }
                        exportActivityVO.store(true, userid);

                        // also add nightshift-activity if required
                        if (nightShift) {
                            addNightShiftActivity(personid, transactionVO, activeMedicalCenter, activeMD, activePara);
                        }
                    }
                }
            } else
            if (transactionVO.getTransactionType().equals("be.mxs.common.model.vo.healthrecord.IConstants.TRANSACTION_TYPE_MIR_MOBILE_UNIT")) {
                //We stockeren maximaal 1 prestatie per transactie
                if (transactionVO.getItem("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OTHER_REQUESTS_PRESTATION") != null) {
                    ItemVO item = transactionVO.getItem("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_MIR_TYPE");
                    if (item != null) {
                        ExportActivityVO exportActivityVO = new ExportActivityVO(personid, transactionVO.getUser().getUserId().intValue(), stdDateFormat.format(transactionVO.getUpdateTime()), null, "MEDICAL-IMAGING." + transactionVO.getServerId() + "." + transactionVO.getTransactionId().toString());
                        exportActivityVO.setMedicalCenter(activeMedicalCenter);
                        exportActivityVO.setMD(activeMD);
                        exportActivityVO.setPara(activePara);
                        if (exportActivityVO.setCodeWhereExists("MEDICAL-IMAGING." + item.getValue())) {
                            if (transactionVO.getItem("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OTHER_REQUESTS_SUPPLIER") != null) {
                                exportActivityVO.setProvider(transactionVO.getItem("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OTHER_REQUESTS_SUPPLIER").getValue());
                            }
                            if (transactionVO.getItem("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OTHER_REQUESTS_VALUE") != null) {
                                exportActivityVO.setValue(transactionVO.getItem("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OTHER_REQUESTS_VALUE").getValue());
                            }
                            exportActivityVO.store(true, userid);

                            // also add nightshift-activity if required
                            if (nightShift) {
                                addNightShiftActivity(personid, transactionVO, activeMedicalCenter, activeMD, activePara);
                            }
                        }
                    }
                }
            } else
            if (transactionVO.getTransactionType().equals("be.mxs.common.model.vo.healthrecord.IConstants.TRANSACTION_TYPE_MIR2")) {
                //We stockeren maximaal 1 prestatie per transactie
                if (transactionVO.getItem("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OTHER_REQUESTS_PRESTATION") != null) {
                    ItemVO item = transactionVO.getItem("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_MIR2_TYPE");
                    if (item != null) {
                        ExportActivityVO exportActivityVO = new ExportActivityVO(personid, transactionVO.getUser().getUserId().intValue(), stdDateFormat.format(transactionVO.getUpdateTime()), null, "MEDICAL-IMAGING." + transactionVO.getServerId() + "." + transactionVO.getTransactionId().toString());
                        exportActivityVO.setMedicalCenter(activeMedicalCenter);
                        exportActivityVO.setMD(activeMD);
                        exportActivityVO.setPara(activePara);
                        if (exportActivityVO.setCodeWhereExists("MEDICAL-IMAGING." + item.getValue())) {
                            if (transactionVO.getItem("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OTHER_REQUESTS_SUPPLIER") != null) {
                                exportActivityVO.setProvider(transactionVO.getItem("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OTHER_REQUESTS_SUPPLIER").getValue());
                            }
                            if (transactionVO.getItem("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OTHER_REQUESTS_VALUE") != null) {
                                exportActivityVO.setValue(transactionVO.getItem("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OTHER_REQUESTS_VALUE").getValue());
                            }
                            exportActivityVO.store(true, userid);

                            // also add nightshift-activity if required
                            if (nightShift) {
                                addNightShiftActivity(personid, transactionVO, activeMedicalCenter, activeMD, activePara);
                            }
                        }
                    }
                }
            } else
            if (transactionVO.getTransactionType().equals("be.mxs.common.model.vo.healthrecord.IConstants.TRANSACTION_TYPE_OTHER_REQUESTS")) {
                //We stockeren maximaal 1 prestatie per transactie
                if (transactionVO.getItem("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OTHER_REQUESTS_PRESTATION") != null) {
                    ItemVO item = transactionVO.getItem("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_SPECIALIST_TYPE");
                    if (item != null) {
                        ExportActivityVO exportActivityVO = new ExportActivityVO(personid, transactionVO.getUser().getUserId().intValue(), stdDateFormat.format(transactionVO.getUpdateTime()), null, "SPECIALIST." + transactionVO.getServerId() + "." + transactionVO.getTransactionId().toString());
                        exportActivityVO.setMedicalCenter(activeMedicalCenter);
                        exportActivityVO.setMD(activeMD);
                        exportActivityVO.setPara(activePara);
                        if (exportActivityVO.setCodeWhereExists("SPECIALIST." + item.getValue())) {
                            if (transactionVO.getItem("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OTHER_REQUESTS_SUPPLIER") != null) {
                                exportActivityVO.setProvider(transactionVO.getItem("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OTHER_REQUESTS_SUPPLIER").getValue());
                            }
                            if (transactionVO.getItem("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OTHER_REQUESTS_VALUE") != null) {
                                exportActivityVO.setValue(transactionVO.getItem("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OTHER_REQUESTS_VALUE").getValue());
                            }
                            exportActivityVO.store(true, userid);

                            // also add nightshift-activity if required
                            if (nightShift) {
                                addNightShiftActivity(personid, transactionVO, activeMedicalCenter, activeMD, activePara);
                            }
                        }
                    }
                }
            } else
            if (transactionVO.getTransactionType().equals("be.mxs.common.model.vo.healthrecord.IConstants.TRANSACTION_TYPE_RESP_FUNC_EX")) {
                //We stockeren maximaal 1 prestatie per transactie
                if (transactionVO.getItem("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OTHER_REQUESTS_PRESTATION") != null) {
                    ExportActivityVO exportActivityVO = new ExportActivityVO(personid, transactionVO.getUser().getUserId().intValue(), stdDateFormat.format(transactionVO.getUpdateTime()), null, "SPIRO." + transactionVO.getServerId() + "." + transactionVO.getTransactionId().toString());
                    exportActivityVO.setMedicalCenter(activeMedicalCenter);
                    exportActivityVO.setMD(activeMD);
                    exportActivityVO.setPara(activePara);
                    if (transactionVO.getItem("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_RESP_FUNC_EX_FEV1") != null) {
                        if (exportActivityVO.setCodeWhereExists("SPIRO")) {
                            exportActivityVO.store(true, userid);

                            // also add nightshift-activity if required
                            if (nightShift) {
                                addNightShiftActivity(personid, transactionVO, activeMedicalCenter, activeMD, activePara);
                            }
                        }
                    } else
                    if (transactionVO.getItem("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_RESP_FUNC_EX_PEF") != null) {
                        if (exportActivityVO.setCodeWhereExists("PEAKFLOW")) {
                            exportActivityVO.store(true, userid);

                            // also add nightshift-activity if required
                            if (nightShift) {
                                addNightShiftActivity(personid, transactionVO, activeMedicalCenter, activeMD, activePara);
                            }
                        }
                    }
                }
            } else
            if (transactionVO.getTransactionType().equals("be.mxs.common.model.vo.healthrecord.IConstants.TRANSACTION_TYPE_LAB_REQUEST")) {
                //We stockeren maximaal 1 prestatie per analyseaanvraag per dag
                //We vragen eers het Item met alle aangevraagde analyses op
                String analyses = "";
                ItemVO item = transactionVO.getItem("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LAB_ANALYSIS1");
                if (item != null) {
                    analyses += item.getValue();
                }
                item = transactionVO.getItem("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LAB_ANALYSIS2");
                if (item != null) {
                    analyses += item.getValue();
                }
                item = transactionVO.getItem("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LAB_ANALYSIS3");
                if (item != null) {
                    analyses += item.getValue();
                }
                item = transactionVO.getItem("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LAB_ANALYSIS4");
                if (item != null) {
                    analyses += item.getValue();
                }
                item = transactionVO.getItem("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LAB_ANALYSIS5");
                if (item != null) {
                    analyses += item.getValue();
                }
                String provider = "";
                item = transactionVO.getItem("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OTHER_REQUESTS_SUPPLIER");
                if (item != null) {
                    provider = item.getValue();
                }
                String value = "";
                item = transactionVO.getItem("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OTHER_REQUESTS_VALUE");
                if (item != null) {
                    value = item.getValue();
                }
                String MD = "";
                item = transactionVO.getItem("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LAB_APPLYING_PHYSICIAN");
                if (item != null) {
                    MD = item.getValue();
                }
                String labcode;
                ExportActivityVO exportActivityVO;
                while (analyses.indexOf("$") > -1) {
                    if (analyses.indexOf("£") > -1) {
                        labcode = analyses.substring(0, analyses.indexOf("£"));
                        analyses = analyses.substring(analyses.indexOf("$") + 1);
                        exportActivityVO = new ExportActivityVO(personid, transactionVO.getUser().getUserId().intValue(), stdDateFormat.format(transactionVO.getUpdateTime()), null, "LABCODE." + personid + "." + labcode + "." + stdDateFormat.format(transactionVO.getUpdateTime()));
                        exportActivityVO.setProvider(provider);
                        exportActivityVO.setValue(value);
                        exportActivityVO.setMD(MD);
                        exportActivityVO.setMedicalCenter(activeMedicalCenter);
                        exportActivityVO.setPara(activePara);
                        if (exportActivityVO.setCodeWhereExists("LABCODE." + labcode)) {
                            exportActivityVO.store(true, userid);

                            // also add nightshift-activity if required
                            if (nightShift) {
                                addNightShiftActivity(personid, transactionVO, activeMedicalCenter, activeMD, activePara);
                            }
                        }
                    }
                }
            } else {
                //Andere dagcode-gebaseerde prestatiecodes
                ExportActivityVO exportActivityVO = new ExportActivityVO(personid, transactionVO.getUser().getUserId().intValue(), stdDateFormat.format(transactionVO.getUpdateTime()), null, null);
                exportActivityVO.setMedicalCenter(activeMedicalCenter);
                exportActivityVO.setMD(activeMD);
                exportActivityVO.setPara(activePara);
                if (exportActivityVO.setCodeWhereExists("DAYCODE." + transactionVO.getTransactionType())) {
                    exportActivityVO.setId("DAYCODE." + exportActivityVO.getActivityCode() + "." + stdDateFormat.format(transactionVO.getUpdateTime()));
                    exportActivityVO.store(true, userid);

                    // also add nightshift-activity if required
                    if (nightShift) {
                        addNightShiftActivity(personid, transactionVO, activeMedicalCenter, activeMD, activePara);
                    }
                }
                //Andere transactie-gebaseerde prestatiecodes
                //We stockeren maximaal 1 prestatie per transactie
                exportActivityVO = new ExportActivityVO(personid, transactionVO.getUser().getUserId().intValue(), stdDateFormat.format(transactionVO.getUpdateTime()), null, "TRANSACTION." + transactionVO.getServerId() + "." + transactionVO.getTransactionId().toString());
                exportActivityVO.setMedicalCenter(activeMedicalCenter);
                exportActivityVO.setMD(activeMD);
                exportActivityVO.setPara(activePara);
                if (exportActivityVO.setCodeWhereExists("TRANSACTIONCODE." + transactionVO.getTransactionType())) {
                    exportActivityVO.store(true, userid);

                    // also add nightshift-activity if required
                    if (nightShift) {
                        addNightShiftActivity(personid, transactionVO, activeMedicalCenter, activeMD, activePara);
                    }
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
    public static void reload() {
        Hashtable labels = getInstance().labels;
        medwanQuery = new MedwanQuery(medwanQuery.uri);
        medwanQuery.labels = labels;
    }
    public void reloadConfigValues() {
        // load values from "OC_Config"
        try {
            Connection oc_conn=getOpenclinicConnection();
        	Statement st = oc_conn.createStatement();
            ResultSet rs = st.executeQuery("select * from OC_Config order by oc_key");
            while (rs.next()) {
                config.put(rs.getString("oc_key") + "", rs.getString("oc_value") + "");
            }
            rs.close();
            st.close();
            oc_conn.close();
            // set Debug
            Debug.enabled = getConfigString("Debug").equalsIgnoreCase("on");
        }
        catch (Exception e) {
            //e.printStackTrace();
            if (Debug.enabled) Debug.println(e.getMessage());
        }

        // load values from "config.xml"
        try {
            SAXReader reader = new SAXReader(false);
            String sDoc = getConfigString("templateSource") + "config.xml";
            Document document = reader.read(new URL(sDoc));
            Element root = document.getRootElement();
            Iterator elements = root.elementIterator("parameter");
            Element parameter;
            while (elements.hasNext()) {
                parameter = (Element) elements.next();
                config.put(parameter.attributeValue("name"), parameter.getTextTrim());
            }
        }
        catch (Exception e) {
            //e.printStackTrace();
            if (Debug.enabled) Debug.println(e.getMessage());
        }
    }
    public static MedwanQuery getInstance() {
        if (medwanQuery == null) {
            medwanQuery = new MedwanQuery(null);
        }
        return medwanQuery;
    }
    public static MedwanQuery getInstance(String uri) {
        if (medwanQuery == null) {
            medwanQuery = new MedwanQuery(uri);
        } else
        if ((medwanQuery.uri == null && uri != null) || (medwanQuery.uri != null && !medwanQuery.uri.equalsIgnoreCase(uri))) {
            Hashtable labels = medwanQuery.labels;
            medwanQuery = new MedwanQuery(uri);
            medwanQuery.labels = labels;
        }
        return medwanQuery;
    }
    public Connection getAdminConnection() {
    	Connection conn=null;
    	try {
    		conn=dsAdmin.getConnection();
		} catch (Exception e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
    	return conn;
    }
    public Connection getOpenclinicConnection() {
    	Connection conn=null;
    	try {
    		conn=dsOpenClinic.getConnection();
		} catch (Exception e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
    	return conn;
    }
    public Connection getLongOpenclinicConnection() {
    	Connection conn=null;
    	try {
    		conn=dsLongOpenClinic.getConnection();
		} catch (Exception e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
    	return conn;
    }
    public Connection getLongAdminConnection() {
    	Connection conn=null;
    	try {
    		conn=dsLongAdmin.getConnection();
		} catch (Exception e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
    	return conn;
    }
    public Connection getStatsConnection() {
    	Connection conn=null;
    	try {
    		conn=dsStats.getConnection();
		} catch (Exception e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
    	return conn;
    }
    public boolean storeDocument(String type, String format, String name, String filename, int userid, String folder, java.util.Date updatetime, int personId) {
        Connection OccupdbConnection;
        try {
            OccupdbConnection = getOpenclinicConnection();
            PreparedStatement ps = OccupdbConnection.prepareStatement("select * from Documents where name=? and type=?");
            ps.setString(1, name);
            ps.setString(2, type);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                int id = rs.getInt("id");
                String oldFilename = rs.getString("filename");
                File oldFile = new File(oldFilename);
                oldFile.delete();
                rs.close();
                ps.close();
                ps = OccupdbConnection.prepareStatement("update Documents set type=?,format=?,filename=?,userid=?,folder=?,updatetime=? where id=?");
                ps.setString(1, type);
                ps.setString(2, format);
                ps.setString(3, filename);
                ps.setInt(4, userid);
                ps.setString(5, folder);
                ps.setDate(6, new java.sql.Date(updatetime.getTime()));
                ps.setInt(7, id);
            } else {
            	rs.close();
            	ps.close();
                ps = OccupdbConnection.prepareStatement("insert Documents(id,type,format,name,filename,userid,folder,updatetime,personid) values (?,?,?,?,?,?,?,?,?)");
                ps.setInt(1, getOpenclinicCounter("DocumentID"));
                ps.setString(2, type);
                ps.setString(3, format);
                ps.setString(4, name);
                ps.setString(5, filename);
                ps.setInt(6, userid);
                ps.setString(7, folder);
                ps.setDate(8, new java.sql.Date(updatetime.getTime()));
                if (type.equalsIgnoreCase("template")) {
                    ps.setInt(9, 0);
                } else {
                    ps.setInt(9, personId);
                }
            }
            ps.execute();
            ps.close();
            OccupdbConnection.close();
            return true;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }
    public void fillTransactionItems(TransactionVO transactionVO) {
        try {
            Connection OccupdbConnection = getOpenclinicConnection();
            PreparedStatement ps = OccupdbConnection.prepareStatement("delete from TransactionItems where transactionTypeId=?");
            ps.setString(1, transactionVO.getTransactionType());
            ps.execute();
            ps.close();
            Iterator items = transactionVO.getItems().iterator();
            ItemVO itemVO;
            while (items.hasNext()) {
                itemVO = (ItemVO) items.next();
                ps = OccupdbConnection.prepareStatement("insert into TransactionItems(transactionTypeId,itemTypeId,defaultValue,modifier) values(?,?,?,?)");
                ps.setString(1, transactionVO.getTransactionType());
                ps.setString(2, itemVO.getType());
                ps.setString(3, itemVO.getValue());
                ps.setString(4, "");
                ps.execute();
                ps.close();
            }
            OccupdbConnection.close();

        } catch (Exception e) {
            e.printStackTrace();
        }
    }
    public Vector loadTransactionItems(String transactionTypeId, ItemContextVO itemContextVO) {
        Vector items = new Vector();
        PreparedStatement ps;
        Connection OccupdbConnection;
        try {
            OccupdbConnection = getOpenclinicConnection();
            ps = OccupdbConnection.prepareStatement("select * from TransactionItems where transactionTypeId=?");
            ps.setString(1, transactionTypeId);
            ResultSet rs = ps.executeQuery();
            ItemVO item;
            while (rs.next()) {
                item = new ItemVO(new Integer(IdentifierFactory.getInstance().getTemporaryNewIdentifier()),
                        rs.getString("itemTypeId"), rs.getString("defaultValue"), new Date(), itemContextVO);
                items.add(item);
            }
            rs.close();
            ps.close();
            OccupdbConnection.close();

        } catch (Exception e) {
            e.printStackTrace();
        }
        return items;
    }
    public Vector loadTransactionItems(String transactionTypeId, ItemContextVO itemContextVO, String sItemType) {
        Vector items = new Vector();
        PreparedStatement ps;
        Connection OccupdbConnection;
        try {
            OccupdbConnection = getOpenclinicConnection();
            ps = OccupdbConnection.prepareStatement("SELECT * FROM TransactionItems WHERE transactionTypeId=? AND itemTypeId like ?");
            ps.setString(1, transactionTypeId);
            ps.setString(2, sItemType + '%');
            ResultSet rs = ps.executeQuery();
            ItemVO item;
            while (rs.next()) {
                item = new ItemVO(new Integer(IdentifierFactory.getInstance().getTemporaryNewIdentifier()),
                        rs.getString("itemTypeId"), rs.getString("defaultValue"), new Date(), itemContextVO);
                items.add(item);
            }
            rs.close();
            ps.close();
            OccupdbConnection.close();

        } catch (Exception e) {
            e.printStackTrace();
        }
        return items;
    }
    public Vector findICPCCodes(String keywords, String language) {
        Vector codes = new Vector();
        Hashtable counters = new Hashtable();
        String label = "labelen";
        if (language.equalsIgnoreCase("FR")) {
            language = "F";
        }
        if (language.equalsIgnoreCase("EN")) {
            language = "E";
        }
        if (language.equalsIgnoreCase("NL")) {
            language = "N";
        }
        if (language.equalsIgnoreCase("F")) {
            label = "labelfr";
        }
        if (language.equalsIgnoreCase("N")) {
            label = "labelnl";
        }
        //First find all keywords
        String[] keys = keywords.toUpperCase().split(" ");
        String sQuery = "";
        for (int n = 0; n < keys.length; n++) {
            if (keys[n].length() > 0) {
                sQuery = " select distinct code as code" +
                        " from ICPC2 where " + label + " like '%" + ScreenHelper.normalizeSpecialCharacters(keys[n].toLowerCase()).toUpperCase() + "%' or code like '" + ScreenHelper.normalizeSpecialCharacters(keys[n].toLowerCase()).toUpperCase() + "%'";
                if (getConfigInt("cacheDB") == 1) {
                    sQuery += " union" +
                            " select distinct icpc as code" +
                            " from Concepts b,Keywords c" +
                            " where c.language='" + language + "' and" +
                            " b.icpc is not null and" +
                            " b.concept=c.concept and" +
                            " c.keyword like '" + ScreenHelper.normalizeSpecialCharacters(keys[n].toLowerCase()).toUpperCase() + "%'";
                } else {
                    sQuery += " union" +
                            " select distinct icpc as code" +
                            " from Concepts b,Keywords c" +
                            " where c.language='" + language + "' and" +
                            " b.icpc is not null and" +
                            " b.concept=c.concept and" +
                            " c.keyword like '" + ScreenHelper.normalizeSpecialCharacters(keys[n].toLowerCase()).toUpperCase() + "%'";
                }
                sQuery += " order by code";
                PreparedStatement ps;
                Connection OccupdbConnection;
                try {
                    OccupdbConnection = getOpenclinicConnection();
                    ps = OccupdbConnection.prepareStatement(sQuery);
                    ResultSet rs = ps.executeQuery();
                    while (rs.next()) {
                        String c = rs.getString("code");
                        if (c != null) {
                            if (counters.get(c) == null) {
                                counters.put(c, new Integer(1));
                                codes.add(c);
                            } else {
                                counters.put(c, new Integer(((Integer) counters.get(c)).intValue() + 1));
                            }
                        }
                    }
                    rs.close();
                    ps.close();
                    OccupdbConnection.close();
                } catch (Exception e) {
                    e.printStackTrace();
                }
            }
        }
        Vector returncodes = new Vector();
        Hashtable existing = new Hashtable();
        for (int n = 0; n < codes.size(); n++) {
            String code = (String) codes.elementAt(n);
            if (((Integer) counters.get(code)).intValue() >= keys.length) {
                ICPCCode icpc = new ICPCCode(code, label, "icpc2");
                if (icpc.label.length() > 0 && existing.get(icpc.code) == null) {
                    existing.put(icpc.code, "1");
                    returncodes.add(icpc);
                }
            }
        }
        return returncodes;
    }
    public Vector findICD10Codes(String keywords, String language) {
        Vector codes = new Vector();
        Hashtable counters = new Hashtable();
        String label = "labelen";
        if (language.equalsIgnoreCase("FR")) {
            language = "F";
        }
        if (language.equalsIgnoreCase("EN")) {
            language = "E";
        }
        if (language.equalsIgnoreCase("NL")) {
            language = "N";
        }
        if (language.equalsIgnoreCase("F")) {
            label = "labelfr";
        }
        if (language.equalsIgnoreCase("N")) {
            label = "labelnl";
        }
        //First find all keywords
        String[] keys = keywords.toUpperCase().split(" ");
        String sQuery = "";
        for (int n = 0; n < keys.length; n++) {
            if (keys[n].length() > 0) {
                sQuery = " select distinct code as code from ICD10 where " + label + " like '%" + ScreenHelper.normalizeSpecialCharacters(keys[n].toLowerCase()).toUpperCase() + "%' or code like '%" + ScreenHelper.normalizeSpecialCharacters(keys[n].toLowerCase()).toUpperCase() + "%'";
                sQuery += " union select distinct b.icd10 as code from Concepts b,Keywords c where c.language='" + language + "' and b.icd10 is not null and b.concept=c.concept and c.keyword like '" + ScreenHelper.normalizeSpecialCharacters(keys[n].toLowerCase()).toUpperCase() + "%'";
                sQuery += " order by code";
                PreparedStatement ps;
                Connection OccupdbConnection;
                try {
                    OccupdbConnection = getOpenclinicConnection();
                    ps = OccupdbConnection.prepareStatement(sQuery);
                    ResultSet rs = ps.executeQuery();
                    while (rs.next()) {
                        String c = rs.getString("code");
                        if (c != null) {
                            if (counters.get(c) == null) {
                                counters.put(c, new Integer(1));
                                codes.add(c);
                            } else {
                                counters.put(c, new Integer(((Integer) counters.get(c)).intValue() + 1));
                            }
                        }
                    }
                    rs.close();
                    ps.close();
                    OccupdbConnection.close();
                } catch (Exception e) {
                    e.printStackTrace();
                }
            }
        }
        Vector returncodes = new Vector();
        Hashtable existing = new Hashtable();
        for (int n = 0; n < codes.size(); n++) {
            String code = (String) codes.elementAt(n);
            if (((Integer) counters.get(code)).intValue() >= keys.length) {
                ICPCCode icpc = new ICPCCode(code, label, "icd10");
                if (icpc.label.length() > 0 && existing.get(icpc.code) == null) {
                	existing.put(icpc.code, "1");
                    returncodes.add(icpc);
                }
            }
        }
        return returncodes;
    }
 
    public EnterpriseVisitVO saveEnterpriseVisit(EnterpriseVisitVO visit) {
        PreparedStatement ps;
        Connection OccupdbConnection;
        try {
            OccupdbConnection = getOpenclinicConnection();
            if (visit.visitId < 0) {
                visit.visitId = getOpenclinicCounter("EnterpriseVisitID");
            }
            ps = OccupdbConnection.prepareStatement("delete from EnterpriseVisits where visitId=? and serverid=?");
            ps.setInt(1, visit.visitId);
            ps.setInt(2, visit.serverId);
            ps.execute();
            ps.close();
            ps = OccupdbConnection.prepareStatement("delete from EnterpriseVisitItems where visitId=? and serverId=?");
            ps.setInt(1, visit.visitId);
            ps.setInt(2, visit.serverId);
            ps.execute();
            ps.close();
            ps = OccupdbConnection.prepareStatement("insert EnterpriseVisits(visitId,serviceId,userId,updateTime,creationDate,ts,serverid) values(?,?,?,?,?,?,?)");
            ps.setInt(1, visit.visitId);
            ps.setString(2, visit.serviceId);
            ps.setInt(3, visit.userId);
            if (visit.updateTime == null) visit.updateTime = new java.util.Date();
            ps.setTimestamp(4, new Timestamp(visit.updateTime.getTime()));
            ps.setTimestamp(5, new Timestamp(visit.creationDate.getTime()));
            ps.setTimestamp(6, new Timestamp(new java.util.Date().getTime()));
            ps.setInt(7, visit.serverId);
            ps.execute();
            ps.close();
            EnterpriseVisitItemVO item;
            for (int n = 0; n < visit.items.size(); n++) {
                item = (EnterpriseVisitItemVO) visit.items.elementAt(n);
                ps = OccupdbConnection.prepareStatement("insert EnterpriseVisitItems(visitId,itemId,itemType,itemValue,serverId) values(?,?,?,?,?)");
                ps.setInt(1, visit.visitId);
                if (item.itemId < 0) {
                    item.itemId = getOpenclinicCounter("EnterpriseVisitItemID");
                }
                ps.setInt(1, visit.visitId);
                ps.setInt(2, item.itemId);
                ps.setString(3, item.itemType);
                if (item.itemValue.length() > 3000) {
                    item.itemValue = item.itemValue.substring(0, 3000);
                }
                ps.setString(4, item.itemValue);
                ps.setInt(5, visit.serverId);
                ps.execute();
                ps.close();
            }
            OccupdbConnection.close();
        } catch (Exception e) {
            e.printStackTrace();
        }
        return visit;
    }
    public String getLastEnterpriseItemValue(String serviceId, String itemType) {
        String itemValue = "";
        PreparedStatement ps;
        Connection OccupdbConnection;
        try {
            OccupdbConnection = getOpenclinicConnection();
            ps = OccupdbConnection.prepareStatement("select * from EnterpriseVisits a,EnterpriseVisitItems b where a.visitId=b.visitId and a.serverid=b.serverid and a.serviceId=? and b.itemType=? order by a.updateTime DESC");
            ps.setString(1, serviceId);
            ps.setString(2, itemType);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                itemValue = rs.getString("itemValue");
            }
            rs.close();
            ps.close();
            OccupdbConnection.close();

        } catch (Exception e) {
            e.printStackTrace();
        }
        return itemValue;
    }
    public EnterpriseVisitVO getEnterpriseVisit(int visitId, int serverId) {
        EnterpriseVisitVO visit = null;
        PreparedStatement ps;
        Connection OccupdbConnection;
        try {
            OccupdbConnection = getOpenclinicConnection();
            ps = OccupdbConnection.prepareStatement("select * from EnterpriseVisits where visitId=? and serverid=?");
            ps.setInt(1, visitId);
            ps.setInt(2, serverId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                visit = new EnterpriseVisitVO(visitId, rs.getString("serviceId"), rs.getInt("userId"), rs.getTimestamp("updateTime"), rs.getTimestamp("creationDate"), rs.getTimestamp("ts"), rs.getInt("serverid"));
                rs.close();
                ps.close();
                ps = OccupdbConnection.prepareStatement("select * from EnterpriseVisitItems where visitId=? and serverId=?");
                ps.setInt(1, visitId);
                ps.setInt(2, serverId);
                rs = ps.executeQuery();
                while (rs.next()) {
                    visit.addItem(new EnterpriseVisitItemVO(rs.getInt("itemId"), rs.getString("itemType"), rs.getString("itemValue")));
                }
                rs.close();
                ps.close();
            }
            else {
            	ps.close();
            }
            OccupdbConnection.close();

        } catch (Exception e) {
            e.printStackTrace();
        }
        return visit;
    }
    //--- GET SERVICE -----------------------------------------------------------------------------
    public Service getService(String serviceId) {
        Service service = new Service();
        PreparedStatement ps;
        Connection AdmindbConnection;
        try {
            AdmindbConnection = getAdminConnection();
            ps = AdmindbConnection.prepareStatement("select * from Services where serviceid=?");
            ps.setString(1, serviceId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                service = new Service();
                service.address = rs.getString("address");
                service.city = rs.getString("city");
                service.code = rs.getString("serviceid");
                service.comment = rs.getString("comment");
                service.contactperson = rs.getString("contactperson");
                service.contract = rs.getString("contract");
                service.contractdate = rs.getString("contractdate");
                service.country = rs.getString("country");
                service.email = rs.getString("email");
                service.fax = rs.getString("fax");
                service.inscode = rs.getString("inscode");
                service.labels = service.getServiceLabels();
                service.language = rs.getString("servicelanguage");
                service.parentcode = rs.getString("serviceparentid");
                service.telephone = rs.getString("telephone");
                service.type = rs.getString("contracttype");
                service.zipcode = rs.getString("zipcode");
            }
            rs.close();
            ps.close();
            AdmindbConnection.close();

        } catch (Exception e) {
            e.printStackTrace();
        }
        return service;
    }
    public void inactivateDiagnosis(int personId, String diagnosis, java.util.Date date) {
        PreparedStatement ps;
        Connection OccupdbConnection;
        try {
            OccupdbConnection = getOpenclinicConnection();
            ps = OccupdbConnection.prepareStatement("update patientDiagnosis set endDate=? where personId=? and diagnose=? and endDate is null and beginDate<=?");
            ps.setDate(1, new java.sql.Date(date.getTime()));
            ps.setInt(2, personId);
            ps.setString(3, diagnosis);
            ps.setDate(4, new java.sql.Date(date.getTime()));
            ps.execute();
            ps.close();
            OccupdbConnection.close();

        } catch (Exception e) {
            e.printStackTrace();
        }
    }
    public void activateDiagnosis(int personId, int transactionId, int serverId, java.util.Date transactionDate) {
        PreparedStatement ps;
        Connection OccupdbConnection;
        try {
            OccupdbConnection = getOpenclinicConnection();
            ps = OccupdbConnection.prepareStatement("select a.*,c.updateTime from Items a,diagnoses b,Transactions c where a.transactionId=c.transactionId and a.serverid=c.serverid and a.transactionId=? and a.serverid=? and a.type like b.itemTypeId and type not in (select diagnose from patientDiagnosis where personId=? and endDate is null or (beginDate<=? and endDate>=?))");
            ps.setInt(1, transactionId);
            ps.setInt(2, serverId);
            ps.setInt(3, personId);
            ps.setDate(4, new java.sql.Date(transactionDate.getTime()));
            ps.setDate(5, new java.sql.Date(transactionDate.getTime()));
            ResultSet rs = ps.executeQuery();
            PreparedStatement ps2;
            while (rs.next()) {
                ps2 = OccupdbConnection.prepareStatement("insert into patientDiagnosis(personId,diagnose,comment,beginDate,endDate) values(?,?,?,?,null)");
                ps2.setInt(1, personId);
                ps2.setString(2, rs.getString("type"));
                ps2.setString(3, rs.getString("value"));
                ps2.setTimestamp(4, rs.getTimestamp("updateTime"));
                ps2.execute();
                ps2.close();
            }
            rs.close();
            ps.close();
            OccupdbConnection.close();

        } catch (Exception e) {
            e.printStackTrace();
        }
    }
    public Vector getInactiveDiagnosis(int personId) {
        PreparedStatement ps;
        Connection OccupdbConnection;
        Vector items = new Vector();
        try {
            OccupdbConnection = getOpenclinicConnection();
            ps = OccupdbConnection.prepareStatement("select * from patientDiagnosis where personId=? and endDate is not null order by endDate DESC");
            ps.setInt(1, personId);
            ResultSet rs = ps.executeQuery();
            ItemContextVO itemContextVO;
            ItemVO itemVO;
            while (rs.next()) {
                itemContextVO = new ItemContextVO(new Integer(IdentifierFactory.getInstance().getTemporaryNewIdentifier()), "", "");
                itemVO = new ItemVO(new Integer(IdentifierFactory.getInstance().getTemporaryNewIdentifier()), rs.getString("diagnose"), rs.getString("comment"), rs.getDate("beginDate"), itemContextVO);
                itemVO.setInactiveDate(rs.getDate("endDate"));
                items.add(itemVO);
            }
            rs.close();
            ps.close();
            OccupdbConnection.close();

        } catch (Exception e) {
            e.printStackTrace();
        }
        return items;
    }
    public Vector getActiveDiagnosis(int personId) {
        PreparedStatement ps;
        Connection OccupdbConnection;
        Vector items = new Vector();
        try {
            Hashtable hDiagnosis = new Hashtable();
            OccupdbConnection = getOpenclinicConnection();
            ps = OccupdbConnection.prepareStatement("select * from patientDiagnosis where personId=? and endDate is null order by beginDate DESC");
            ps.setInt(1, personId);
            ResultSet rs = ps.executeQuery();
            ItemContextVO itemContextVO;
            ItemVO itemVO;
            while (rs.next()) {
                if (hDiagnosis.get(rs.getString("diagnose")) == null) {
                    itemContextVO = new ItemContextVO(new Integer(IdentifierFactory.getInstance().getTemporaryNewIdentifier()), "", "");
                    itemVO = new ItemVO(new Integer(0), rs.getString("diagnose"), rs.getString("comment"), rs.getDate("beginDate"), itemContextVO);
                    items.add(itemVO);
                    hDiagnosis.put(rs.getString("diagnose"), "OK");
                }
            }
            rs.close();
            ps.close();
            OccupdbConnection.close();

        } catch (Exception e) {
            e.printStackTrace();
        }
        return items;
    }
    /*    public Vector getActiveCardioDiagnosis(int personId) {
            PreparedStatement ps;
            Connection OccupdbConnection;
            Vector items = new Vector();
            try {
                Hashtable hDiagnosis = new Hashtable();
                OccupdbConnection = getOpenclinicConnection();
                ps = OccupdbConnection.prepareStatement("select * from patientDiagnosis a, cardiorisk b where a.diagnose like b.code+'%' and personId=? and endDate is null order by beginDate DESC");
                ps.setInt(1, personId);
                ResultSet rs = ps.executeQuery();
                ItemContextVO itemContextVO;
                ItemVO itemVO;
                while (rs.next()) {
                    if (hDiagnosis.get(rs.getString("diagnose")) == null) {
                        itemContextVO = new ItemContextVO(new Integer(IdentifierFactory.getInstance().getTemporaryNewIdentifier()), "", "");
                        itemVO = new ItemVO(new Integer(0), rs.getString("diagnose"), rs.getString("comment"), rs.getDate("beginDate"), itemContextVO);
                        items.add(itemVO);
                        hDiagnosis.put(rs.getString("diagnose"), "OK");
                    }
                }
                ps.close();
            } catch (Exception e) {
                e.printStackTrace();
            }
            return items;
        }
    */
    public boolean existSubServices(String serviceid) {
        boolean bExist = false;
        PreparedStatement ps;
        Connection occupDb;
        try {
            occupDb = getAdminConnection();
            ps = occupDb.prepareStatement("select count(*) total from Services where serviceparentid=?");
            ps.setString(1, serviceid);
            ResultSet rs = ps.executeQuery();
            bExist = rs.next() && rs.getInt("total") > 0;
            rs.close();
            ps.close();
            occupDb.close();
        }
        catch (Exception e) {
            e.printStackTrace();
        }
        return bExist;
    }
    public String getCodeTran(String code, String language) {
        PreparedStatement ps = null;
        Connection OccupdbConnection;
        String label = "labelen";
        String result = code;
        if (language.equalsIgnoreCase("f") || language.equalsIgnoreCase("fr")) {
            label = "labelfr";
        } else if (language.equalsIgnoreCase("n") || language.equalsIgnoreCase("nl")) {
            label = "labelnl";
        }
        try {
            OccupdbConnection = getOpenclinicConnection();
            if (code.toLowerCase().indexOf("icpccode") == 0) {
                ps = OccupdbConnection.prepareStatement("select " + label + " from ICPC2 where code=?");
                ps.setString(1, code.toLowerCase().trim().replaceAll("icpccode", "").toUpperCase());
                ResultSet rs = ps.executeQuery();
                if (rs.next()) {
                    result = rs.getString(label);
                }
                rs.close();
                ps.close();
            } else if (code.toLowerCase().indexOf("icd10code") == 0) {
                ps = OccupdbConnection.prepareStatement("select " + label + " from ICD10 where code=?");
                ps.setString(1, code.toLowerCase().trim().replaceAll("icd10code", "").toUpperCase());
                ResultSet rs = ps.executeQuery();
                if (rs.next()) {
                    result = rs.getString(label);
                }
                rs.close();
                ps.close();
            } else if (code.toLowerCase().indexOf("prestation") == 0) {
                ps = OccupdbConnection.prepareStatement("select OC_PRESTATION_DESCRIPTION from OC_PRESTATIONS where OC_PRESTATION_CODE=?");
                ps.setString(1, code.toLowerCase().trim().replaceAll("prestation", "").toUpperCase());
                ResultSet rs = ps.executeQuery();
                if (rs.next()) {
                    result = rs.getString("OC_PRESTATION_DESCRIPTION");
                }
                rs.close();
                ps.close();
            }
            OccupdbConnection.close();

        } catch (Exception e) {
            e.printStackTrace();
        }
        return result;
    }
    public Vector getVaccinations(int healthRecordId) {
        PreparedStatement ps;
        Connection OccupdbConnection;
        Vector transactions = new Vector();
        try {
            OccupdbConnection = getOpenclinicConnection();
            String sQuery = getConfigString("getVaccinationQuery");
            if (sQuery != null && sQuery.length() > 0) {
                ps = OccupdbConnection.prepareStatement(sQuery);
                ps.setInt(1, healthRecordId);
                ResultSet rs = ps.executeQuery();
                while (rs.next()) {
                    transactions.add(loadTransaction(rs.getInt("serverid"), rs.getInt("transactionId")));
                }
                rs.close();
                ps.close();
            } else {
                throw new Exception("MedwanQuery.getVaccinations() : configString 'getVaccinationQuery' not found or no content.");
            }
            OccupdbConnection.close();

        }
        catch (Exception e) {
            e.printStackTrace();
        }
        return transactions;
    }
    public HealthRecordVO loadHealthRecord(PersonVO personVO, String sortOrder, SessionContainerWO sessionContainerWO) {
        if (personVO == null)
            return null;
        sessionContainerWO.initLastTransactions();
        sessionContainerWO.initPlannedTransactions();
        PreparedStatement Occupstatement;
        if (sortOrder == null)
            sortOrder = "be.mxs.healthrecord.transactionVO.date";
        Vector transactions = new Vector();
        HealthRecordVO healthRecord = new HealthRecordVO(personVO, new Vector(), new Integer(0), null, null);
        int healthRecordId = 0;
        Connection OccupdbConnection;
        try {
            OccupdbConnection = getOpenclinicConnection();
            String sQuery;
            if (sortOrder.equals("be.mxs.healthrecord.transactionVO.date"))
                sQuery = "SELECT c.*,c.updateTime as ow_updateTime,a.start,a.stop,b.* from UsersView a, AdminView b, Transactions c,Healthrecord d where c.healthRecordId=d.healthRecordId and a.personid=b.personid and a.userid=c.userId and d.personId=? order by c.updateTime DESC,c.transactionId DESC";
            else if (sortOrder.equals("be.mxs.healthrecord.transactionVO.transactionType"))
                sQuery = "SELECT c.*,c.updateTime as ow_updateTime,a.start,a.stop,b.* from UsersView a, AdminView b, Transactions c,Healthrecord d where c.healthRecordId=d.healthRecordId and a.personid=b.personid and a.userid=c.userId and d.personId=? order by c.transactionType";
            else if (sortOrder.equals("be.mxs.healthrecord.transactionVO.userVO.userId"))
                sQuery = "SELECT c.*,c.updateTime as ow_updateTime,a.start,a.stop,b.* from UsersView a, AdminView b, Transactions c,Healthrecord d where c.healthRecordId=d.healthRecordId and a.personid=b.personid and a.userid=c.userId and d.personId=? order by a.userid,c.updateTime DESC,c.transactionId DESC";
            else
                sQuery = "SELECT c.*,c.updateTime as ow_updateTime,a.start,a.stop,b.* from UsersView a, AdminView b, Transactions c,Healthrecord d where c.healthRecordId=d.healthRecordId and a.personid=b.personid and a.userid=c.userId and d.personId=? order by c.updateTime DESC,c.transactionId DESC";
            Occupstatement = OccupdbConnection.prepareStatement(sQuery);
            Occupstatement.setInt(1, personVO.getPersonId().intValue());
            ResultSet Occuprs;
            int transactionId, status, userId, personId, serverId, version, versionServerId;
            String transactionType, password, natreg, immatOld, immatNew, candidate, lastname, firstname, gender, language;
            Date creationDate, updateTime, start, stop, timestamp, dateBegin, dateEnd;
            TransactionVO transactionVO;
            Vector items;
            for (Occuprs = Occupstatement.executeQuery(); Occuprs.next();) {
                transactionId = Occuprs.getInt("transactionId");
                transactionType = Occuprs.getString("transactionType");
                creationDate = Occuprs.getDate("creationDate");
                updateTime = Occuprs.getDate("ow_updateTime");
                status = Occuprs.getInt("status");
                start = Occuprs.getDate("start");
                stop = Occuprs.getDate("stop");
                userId = Occuprs.getInt("userid");
                password = "";
                natreg = Occuprs.getString("natreg");
                immatOld = Occuprs.getString("immatold");
                immatNew = Occuprs.getString("immatnew");
                candidate = Occuprs.getString("candidate");
                lastname = Occuprs.getString("lastname");
                firstname = Occuprs.getString("firstname");
                gender = Occuprs.getString("gender");
                language = Occuprs.getString("language");
                personId = Occuprs.getInt("personid");
                serverId = Occuprs.getInt("serverid");
                version = Occuprs.getInt("version");
                versionServerId = Occuprs.getInt("versionserverid");
                timestamp = Occuprs.getDate("ts");
                transactionVO = new TransactionVO(new Integer(transactionId), transactionType, creationDate, updateTime, status, null, new Vector(), serverId, version, versionServerId, timestamp);
                transactionVO.setUpdateDateTime(updateTime);
                transactionVO.setCreateDateTime(creationDate);
                dateBegin = null;
                dateEnd = null;
                if (start != null)
                    dateBegin = start;
                if (stop != null)
                    dateEnd = stop;
                transactionVO.setUser(new UserVO(new Integer(userId), password, dateBegin, dateEnd, new PersonVO(natreg, immatOld, immatNew, candidate, lastname, firstname, gender, language, new Integer(personId))));
                items = new Vector();
                items.add(getItem(serverId, transactionId, IConstants.ITEM_TYPE_CONTEXT_CONTEXT));
                items.add(getItem(serverId, transactionId, "be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CONTEXT_ENCOUNTERUID"));
                if (transactionVO.getTransactionType().equalsIgnoreCase(IConstants.TRANSACTION_TYPE_VACCINATION)) {
                    items.add(getItem(serverId, transactionId, IConstants.ITEM_TYPE_VACCINATION_TYPE));
                }
                if (transactionVO.getTransactionType().equalsIgnoreCase(IConstants.TRANSACTION_TYPE_DOCUMENT)) {
                    ItemVO documentType = getItem(serverId, transactionId, IConstants.ITEM_TYPE_DOCUMENT_TYPE);
                    if (documentType == null) {
                        documentType = getItem(serverId, transactionId, "documentId");
                    }
                    items.add(documentType);
                }
                transactionVO.setItems(items);
                transactions.add(transactionVO);
                sessionContainerWO.setLastTransaction(transactionVO);
                healthRecordId = Occuprs.getInt("healthRecordId");
            }
            Occuprs.close();
            Occupstatement.close();

            //Now also load the planned transactions
            sQuery = "select * from OC_PLANNING where OC_PLANNING_EFFECTIVEDATE is null and OC_PLANNING_CONTACTTYPE='examination' and OC_PLANNING_PATIENTUID=? order by OC_PLANNING_PLANNEDDATE DESC";
            Occupstatement = OccupdbConnection.prepareStatement(sQuery);
            Occupstatement.setString(1, personVO.getPersonId() + "");
            Occuprs = Occupstatement.executeQuery();
            while (Occuprs.next()) {
                String examinationuid = Occuprs.getString("OC_PLANNING_CONTACTUID");
                if (examinationuid != null && examinationuid.trim().length() > 0 && sessionContainerWO.getUserVO()!=null && sessionContainerWO.getUserVO().getPersonVO()!=null) {
                    ExaminationVO examinationVO = getExamination(examinationuid, sessionContainerWO.getUserVO().getPersonVO().language);
                    String type = examinationVO.getTransactionType();
                    if (type != null) {
                        PlannedExamination plannedExamination = new PlannedExamination(Occuprs.getString("OC_PLANNING_PATIENTUID"), Occuprs.getString("OC_PLANNING_USERUID"), Occuprs.getDate("OC_PLANNING_PLANNEDDATE"), Occuprs.getDate("OC_PLANNING_EFFECTIVEDATE"), Occuprs.getDate("OC_PLANNING_CANCELATIONDATE"), Occuprs.getString("OC_PLANNING_CONTACTTYPE"), Occuprs.getString("OC_PLANNING_CONTACTUID"), Occuprs.getString("OC_PLANNING_TRANSACTIONUID"), Occuprs.getString("OC_PLANNING_DESCRIPTION"));
                        sessionContainerWO.setPlannedTransaction(type.split("&")[0], plannedExamination);
                    }
                }
            }
            healthRecord = new HealthRecordVO(personVO, transactions, new Integer(healthRecordId), new java.util.Date(), new java.util.Date());
            healthRecord.setSortOrder(sortOrder);
            Occuprs.close();
            Occupstatement.close();
            OccupdbConnection.close();

        } catch (Exception e) {
            e.printStackTrace();
        }
        return healthRecord;
    }
    public HealthRecordVO getMedicalRecord(PersonVO personVO, java.util.Date begin, java.util.Date end) {
        if (personVO == null)
            return null;
        PreparedStatement Occupstatement;
        Vector transactions = new Vector();
        HealthRecordVO healthRecord = new HealthRecordVO(personVO, new Vector(), new Integer(0), null, null);
        int healthRecordId = 0;
        Connection OccupdbConnection;
        try {
            OccupdbConnection = getOpenclinicConnection();
            Occupstatement = OccupdbConnection.prepareStatement("SELECT c.*,c.updateTime as ow_updateTime,a.start,a.stop,b.* from UsersView a, AdminView b, Transactions c,Healthrecord d where c.healthRecordId=d.healthRecordId and a.personid=b.personid and a.userid=c.userId and d.personId=? and c.updateTime>=? and c.updateTime<=? order by c.updateTime DESC,c.transactionId DESC");
            Occupstatement.setInt(1, personVO.getPersonId().intValue());
            Occupstatement.setDate(2, new java.sql.Date(begin.getTime()));
            Occupstatement.setDate(3, new java.sql.Date(end.getTime()));
            ResultSet Occuprs;
            int transactionId, status, userId, personId, serverId, version, versionServerId;
            String transactionType, password, natreg, immatOld, immatNew, candidate, lastname, firstname, gender, language;
            Date creationDate, updateTime, start, stop, timestamp, dateBegin, dateEnd;
            TransactionVO transactionVO;
            for (Occuprs = Occupstatement.executeQuery(); Occuprs.next();) {
                transactionId = Occuprs.getInt("transactionId");
                transactionType = Occuprs.getString("transactionType");
                creationDate = Occuprs.getDate("creationDate");
                updateTime = Occuprs.getDate("ow_updateTime");
                status = Occuprs.getInt("status");
                start = Occuprs.getDate("start");
                stop = Occuprs.getDate("stop");
                userId = Occuprs.getInt("userid");
                password = "";
                natreg = Occuprs.getString("natreg");
                immatOld = Occuprs.getString("immatold");
                immatNew = Occuprs.getString("immatnew");
                candidate = Occuprs.getString("candidate");
                lastname = Occuprs.getString("lastname");
                firstname = Occuprs.getString("firstname");
                gender = Occuprs.getString("gender");
                language = Occuprs.getString("language");
                personId = Occuprs.getInt("personid");
                serverId = Occuprs.getInt("serverid");
                version = Occuprs.getInt("version");
                versionServerId = Occuprs.getInt("versionserverid");
                timestamp = Occuprs.getDate("ts");
                transactionVO = new TransactionVO(new Integer(transactionId), transactionType, creationDate, updateTime, status, null, new Vector(), serverId, version, versionServerId, timestamp);
                dateBegin = null;
                dateEnd = null;
                if (start != null)
                    dateBegin = start;
                if (stop != null)
                    dateEnd = stop;
                transactionVO.setUser(new UserVO(new Integer(userId), password, dateBegin, dateEnd, new PersonVO(natreg, immatOld, immatNew, candidate, lastname, firstname, gender, language, new Integer(personId))));
                transactions.add(transactionVO);
                healthRecordId = Occuprs.getInt("healthRecordId");
            }
            healthRecord = new HealthRecordVO(personVO, transactions, new Integer(healthRecordId), new java.util.Date(), new java.util.Date());
            Occuprs.close();
            Occupstatement.close();
            OccupdbConnection.close();

        } catch (Exception e) {
            e.printStackTrace();
        }
        return healthRecord;
    }
   
    public boolean hasUnvalidateActivities(int personId) {
        Connection OccupdbConnection;
        try {
            OccupdbConnection = getOpenclinicConnection();
            PreparedStatement ps = OccupdbConnection.prepareStatement("select * from exportActivities where validated is null and personId=?");
            ps.setInt(1, personId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
            	rs.close();
            	ps.close();
            	OccupdbConnection.close();
                return true;
            }
            ps.close();
            OccupdbConnection.close();

        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }
    public void addNightShiftActivity(int personid, TransactionVO transactionVO, String activeMedicalCenter, String activeMD, String activePara) {
        try {
            ExportActivityVO exportActivityVO = new ExportActivityVO(personid, transactionVO.getUser().getUserId().intValue(), stdDateFormat.format(transactionVO.getUpdateTime()), null, "NIGHTSHIFT." + personid + "." + stdDateFormat.format(transactionVO.getUpdateTime()));
            exportActivityVO.setMedicalCenter(activeMedicalCenter);
            exportActivityVO.setMD(activeMD);
            exportActivityVO.setPara(activePara);
            if (exportActivityVO.setCodeWhereExists("NIGHTSHIFT")) {
                exportActivityVO.store(true, transactionVO.getUser().getUserId().intValue() + "");
            }
        }
        catch (Exception e) {
            e.printStackTrace();
        }
    }
  
    public int getHealthRecordIdFromPersonId(int personId) {
        int healthRecordId = 0;
        Connection OccupdbConnection;
        try {
            OccupdbConnection = getOpenclinicConnection();
            PreparedStatement Occupstatement = OccupdbConnection.prepareStatement("select * from Healthrecord where personId=?");
            Occupstatement.setInt(1, personId);
            ResultSet Occuprs = Occupstatement.executeQuery();
            if (Occuprs.next()){
            	healthRecordId = Occuprs.getInt("healthRecordId");
            }
            Occuprs.close();
            Occupstatement.close();
            OccupdbConnection.close();

        } catch (Exception e) {
            e.printStackTrace();
        }
        return healthRecordId;
    }
    public int getPersonIdFromHealthrecordId(int healthRecordId) {
        int personId = 0;
        Connection OccupdbConnection;
        try {
            OccupdbConnection = getOpenclinicConnection();
            PreparedStatement Occupstatement = OccupdbConnection.prepareStatement("select * from Healthrecord where healthRecordId=?");
            Occupstatement.setInt(1, healthRecordId);
            ResultSet Occuprs = Occupstatement.executeQuery();
            if (Occuprs.next()){
            	personId = Occuprs.getInt("personId");
            }
            Occuprs.close();
            Occupstatement.close();
            OccupdbConnection.close();

        } catch (Exception e) {
            e.printStackTrace();
        }
        return personId;
    }
    public int getPersonIdFromUserId(int userId) {
        int personId = 0;
        Connection OccupdbConnection;
        try {
            OccupdbConnection = getAdminConnection();
            PreparedStatement Occupstatement = OccupdbConnection.prepareStatement("select * from Users where userid=?");
            Occupstatement.setInt(1, userId);
            ResultSet Occuprs = Occupstatement.executeQuery();
            if (Occuprs.next()){
            	personId = Occuprs.getInt("personId");
            }
            Occuprs.close();
            Occupstatement.close();
            OccupdbConnection.close();
        } catch (Exception e) {
            e.printStackTrace();
        }
        return personId;
    }
    public void updateCounter(Connection connection, String table, String column, String counterid, String criteria) {
        try {
            PreparedStatement ps = connection.prepareStatement("select max(" + column + ") maxvalue from " + table + " " + (criteria != null ? criteria : ""));
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                int counter = rs.getInt("maxvalue") + 1;
                rs.close();
                ps.close();
                ps = connection.prepareStatement("update counters set counter=? where name=?");
                ps.setInt(1, counter);
                ps.setString(2, counterid);
                ps.execute();
                ps.close();
            }
            else{
            	rs.close();
            	ps.close();
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
    public void deleteTransaction(String transactionId, String serverId) {
        Connection OccupdbConnection;
        try {
            OccupdbConnection = getOpenclinicConnection();
            PreparedStatement Occupstatement = OccupdbConnection.prepareStatement("insert into TransactionsHistory(transactionId,creationDate,transactionType,updateTime,status,healthRecordId,userId,serverid,versionserverid,version) select transactionId,creationDate,transactionType,updateTime,status,healthRecordId,userId,serverid,versionserverid,version from Transactions where serverid=? and transactionId=?");
            Occupstatement.setInt(1, Integer.parseInt(serverId));
            Occupstatement.setInt(2, Integer.parseInt(transactionId));
            Occupstatement.execute();
            Occupstatement.close();
            Occupstatement = OccupdbConnection.prepareStatement("insert into ItemsHistory(itemId,type," + getConfigString("valueColumn") + "," + getConfigString("dateColumn") + ",transactionId,serverid,versionserverid,version) select itemId,type," + getConfigString("valueColumn") + "," + getConfigString("dateColumn") + ",transactionId,serverid,versionserverid,version from Items where serverid=? and transactionId=?");
            Occupstatement.setInt(1, Integer.parseInt(serverId));
            Occupstatement.setInt(2, Integer.parseInt(transactionId));
            Occupstatement.execute();
            Occupstatement.close();
            Occupstatement = OccupdbConnection.prepareStatement("delete from Transactions where serverid=? and transactionId=?");
            Occupstatement.setInt(1, Integer.parseInt(serverId));
            Occupstatement.setInt(2, Integer.parseInt(transactionId));
            Occupstatement.execute();
            Occupstatement.close();
            Occupstatement = OccupdbConnection.prepareStatement("delete from Items where serverid=? and transactionId=?");
            Occupstatement.setInt(1, Integer.parseInt(serverId));
            Occupstatement.setInt(2, Integer.parseInt(transactionId));
            Occupstatement.execute();
            Occupstatement.close();
            deleteRow("Transactions", "serverid.transactionId", serverId + "." + transactionId);

            // Telkens er op de server een Transaction wordt verwijderd, een entry toevoegen in DeleteObjects
            if (getConfigInt("isSyncServer") == 1) {
                addToDeleteObjects("Transaction", serverId + "." + transactionId);
            }
            OccupdbConnection.close();

        }
        catch (Exception e) {
            e.printStackTrace();
        }
    }
    private void addToDeleteObjects(String ow_objectname, String ow_objectid) {
        try {
            Connection oc_conn=getOpenclinicConnection();
        	PreparedStatement ps = oc_conn.prepareStatement("INSERT INTO DeleteObjects(ow_objectname,ow_objectid,updatetime) VALUES(?,?,?)");
            ps.setString(1, ow_objectname);
            ps.setString(2, ow_objectid);
            ps.setTimestamp(3, new Timestamp(new java.util.Date().getTime()));
            ps.execute();
            ps.close();
            oc_conn.close();
        }
        catch (Exception e) {
            e.printStackTrace();
        }
    }
    public float getNrYears(java.util.Date startDate, java.util.Date endDate) {
        if (startDate == null || endDate == null) {
            return 0;
        }
        Calendar start = new GregorianCalendar();
        Calendar end = new GregorianCalendar();
        start.setTime(startDate);
        end.setTime(endDate);
        long millis = end.getTimeInMillis() - start.getTimeInMillis();
        long days = millis / (1000 * 60 * 60 * 24) + 1;
        out("Days=" + days);
        // +1 to make the end inclusive
        // Count number of february 29's between cal1 and cal2
        int startyear = start.get(Calendar.YEAR);
        int endyear = end.get(Calendar.YEAR);
        if (start.get(Calendar.MONTH) > Calendar.FEBRUARY) {
            startyear++;
        }
        if (end.get(Calendar.MONTH) < Calendar.FEBRUARY || (end.get(Calendar.MONTH) == Calendar.FEBRUARY && end.get(Calendar.DAY_OF_MONTH) < 29)) {
            endyear--;
        }
        int feb29s = 0;
        for (int i = startyear; i <= endyear; i++) {
            if ((i % 4 == 0) && (i % 100 != 0) || (i % 400 == 0)) {
                feb29s++;
            }
        }
        out("Feb29s=" + feb29s);
        return (float) (days - feb29s) / 365;
    }
    public float getAgeDecimal(int personId) {
        Connection OccupdbConnection;
        try {
            OccupdbConnection = getOpenclinicConnection();
            PreparedStatement Occupstatement = OccupdbConnection.prepareStatement("SELECT dateofbirth from AdminView where personid=?");
            Occupstatement.setInt(1, personId);
            ResultSet Occuprs = Occupstatement.executeQuery();
            if (Occuprs.next()) {
                Date dateOfBirth = Occuprs.getDate("dateofbirth");
                float age = getNrYears(dateOfBirth, new java.util.Date());
                Occuprs.close();
                Occupstatement.close();
                OccupdbConnection.close();
                return age;
            }
            Occuprs.close();
            Occupstatement.close();
            OccupdbConnection.close();

        } catch (Exception e) {
            e.printStackTrace();
        }
        return -1;
    }
    public int getAge(int personId) {
        Connection OccupdbConnection;
        try {
            OccupdbConnection = getOpenclinicConnection();
            PreparedStatement Occupstatement = OccupdbConnection.prepareStatement("SELECT dateofbirth from AdminView where personid=?");
            Occupstatement.setInt(1, personId);
            ResultSet Occuprs = Occupstatement.executeQuery();
            if (Occuprs.next()) {
                Date dateOfBirth = Occuprs.getDate("dateofbirth");
                int age = new Double(getNrYears(dateOfBirth, new java.util.Date())).intValue();
                Occuprs.close();
                Occupstatement.close();
                OccupdbConnection.close();
                return age;
            }
            Occuprs.close();
            Occupstatement.close();
            OccupdbConnection.close();

        } catch (Exception e) {
            e.printStackTrace();
        }
        return -1;
    }
    /*    public String getAutomaticAppealCommissionDecision(int convocationId, int firstOrSecond) {
            String decision = "";

            PreparedStatement Occupstatement;
            Connection OccupdbConnection;
            try {
                OccupdbConnection = getOpenclinicConnection();
                if (firstOrSecond == 1)
                    Occupstatement = OccupdbConnection.prepareStatement("select count(b."+getConfigString("valueColumn")+") as total,b."+getConfigString("valueColumn")+" as decision from Items a, Items b where a.serverid=b.serverid and a.transactionId=b.transactionId and a.type='be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_RECRUITMENT_CONVOCATION_ID' and b.type='be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_RECRUITMENT_FIRST_APPEAL_EXAMINATOR_DECISION' and a."+getConfigString("valueColumn")+"=? group by b."+getConfigString("valueColumn")+" order by count(b."+getConfigString("valueColumn")+") DESC");
                else
                    Occupstatement = OccupdbConnection.prepareStatement("select count(b."+getConfigString("valueColumn")+") as total,b."+getConfigString("valueColumn")+" as decision from Items a, Items b where a.serverid=b.serverid and a.transactionId=b.transactionId and a.type='be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_RECRUITMENT_CONVOCATION_ID' and b.type='be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_RECRUITMENT_SECOND_APPEAL_EXAMINATOR_DECISION' and a."+getConfigString("valueColumn")+"=? group by b."+getConfigString("valueColumn")+" order by count(b."+getConfigString("valueColumn")+") DESC");
                Occupstatement.setString(1, Integer.toString(convocationId));
                ResultSet Occuprs = Occupstatement.executeQuery();
                if (Occuprs.next() && Occuprs.getInt("total") > 1)
                    decision = Occuprs.getString("decision");
                Occupstatement.close();
            } catch (Exception e) {
                e.printStackTrace();
            }
            return decision;
        }

        public TransactionVO getLastPeriodicExamination(int personid) {
            Connection OccupdbConnection;
            try {
                OccupdbConnection = getOpenclinicConnection();
                PreparedStatement Occupstatement = OccupdbConnection.prepareStatement("select b.transactionId,b.serverid from Healthrecord a,Transactions b,Items c where a.personId=? and a.healthRecordId=b.healthRecordId and b.transactionType='be.mxs.common.model.vo.healthrecord.IConstants.TRANSACTION_TYPE_MER' and b.transactionId=c.transactionId and b.serverid=c.serverid and c.type='be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CONTEXT_CONTEXT' and c."+getConfigString("valueColumn")+"='context.context.periodic-examinations' order by b.updateTime DESC");
                Occupstatement.setInt(1, personid);
                ResultSet Occuprs = Occupstatement.executeQuery();
                if (Occuprs.next()) {
                    return loadTransaction(Occuprs.getInt("serverid"), Occuprs.getInt("transactionid"));
                }
            } catch (Exception e) {
                e.printStackTrace();
            }
            return null;
        }

        public TransactionVO getLastDrivingLicenseExamination(int personid) {
            Connection OccupdbConnection;
            try {
                OccupdbConnection = getOpenclinicConnection();
                PreparedStatement Occupstatement = OccupdbConnection.prepareStatement("select b.transactionId,b.serverid from Healthrecord a,Transactions b,Items c where a.personId=? and a.healthRecordId=b.healthRecordId and b.transactionType='be.mxs.common.model.vo.healthrecord.IConstants.TRANSACTION_TYPE_DLC' and b.transactionId=c.transactionId and b.serverid=c.serverid order by b.updateTime DESC");
                Occupstatement.setInt(1, personid);
                ResultSet Occuprs = Occupstatement.executeQuery();
                if (Occuprs.next()) {
                    return loadTransaction(Occuprs.getInt("serverid"), Occuprs.getInt("transactionid"));
                }
            } catch (Exception e) {
                e.printStackTrace();
            }
            return null;
        }
    */
    /*public int getCounter(String name) {
        int newCounter = 0;
        Connection OccupdbConnection;
        try {
            OccupdbConnection = getOpenclinicConnection();
            PreparedStatement Occupstatement = OccupdbConnection.prepareStatement("select counter from counters where name=?");
            Occupstatement.setString(1, name);
            ResultSet Occuprs = Occupstatement.executeQuery();
            if (Occuprs.next()) {
                newCounter = Occuprs.getInt("counter");
                Occuprs.close();
                Occupstatement.close();
            } else {
                Occuprs.close();
                Occupstatement.close();
                newCounter = 1;
                Occupstatement = OccupdbConnection.prepareStatement("insert into counters(name,counter) values(?,1)");
                Occupstatement.setString(1, name);
                Occupstatement.execute();
                Occupstatement.close();
            }
            Occupstatement = OccupdbConnection.prepareStatement("update counters set counters.counter=? where counters.name=?");
            Occupstatement.setInt(1, newCounter + 1);
            Occupstatement.setString(2, name);
            Occupstatement.execute();
            Occupstatement.close();
            OccupdbConnection.close();

        } catch (Exception e) {
            e.printStackTrace();
        }
        return newCounter;
    }
    */
    public boolean updateArchiveFile(int personid) {
    	Connection ad_conn = MedwanQuery.getInstance().getAdminConnection();
        try {
            PreparedStatement ps = ad_conn.prepareStatement("select * from Admin where personid=?");
            ps.setInt(1, personid);
            ResultSet rs = ps.executeQuery();
            if (rs.next() && (rs.getString("archiveFileCode") == null || rs.getString("archiveFileCode").length() == 0)) {
                rs.close();
                ps.close();
                ps = ad_conn.prepareStatement("select personid from Admin where archiveFileCode=?");
                String sArchiveID = ScreenHelper.convertToAlfabeticalCode("" + MedwanQuery.getInstance().getOpenclinicCounter("ArchiveFileID"));
                ps.setString(1, sArchiveID);
                rs=ps.executeQuery();
                if(!rs.next()){
                	rs.close();
                	ps.close();
	                ps = ad_conn.prepareStatement("update Admin set archiveFileCode=? where personid=?");
	                ps.setString(1, sArchiveID);
	                ps.setInt(2, personid);
	                ps.execute();
                }
                else {
                	rs.close();
                }
                ps.close();
                objectCache.removeObject("person", personid+"");
                ad_conn.close();
                return true;
            } else {
                rs.close();
                ps.close();
                ad_conn.close();
                return false;
            }
        }
        catch (Exception e) {
            e.printStackTrace();
        }
        try {
			ad_conn.close();
		} catch (SQLException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
        return false;
    }
    public int getOpenclinicCounter(String name) {
        int newCounter = 0;
        try {
            Connection oc_conn=getOpenclinicConnection();
        	PreparedStatement ps = oc_conn.prepareStatement("select OC_COUNTER_VALUE from OC_COUNTERS where OC_COUNTER_NAME=?");
            ps.setString(1, name);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                newCounter = rs.getInt("OC_COUNTER_VALUE");
                rs.close();
                ps.close();
            } else {
                rs.close();
                ps.close();
                newCounter = 1;
                ps = oc_conn.prepareStatement("insert into OC_COUNTERS(OC_COUNTER_NAME,OC_COUNTER_VALUE) values(?,1)");
                ps.setString(1, name);
                ps.execute();
                ps.close();
            }
            ps = oc_conn.prepareStatement("update OC_COUNTERS set OC_COUNTER_VALUE=? where OC_COUNTER_NAME=?");
            ps.setInt(1, newCounter + 1);
            ps.setString(2, name);
            ps.execute();
            ps.close();
            oc_conn.close();
        }
        catch (Exception e) {
            e.printStackTrace();
        }
        if (usedCounters.get(name) != null && newCounter <= ((Integer) usedCounters.get(name)).intValue()) {
            newCounter = getOpenclinicCounter(name);
        }
        usedCounters.put(name, new Integer(newCounter));
        return newCounter;
    }
    public boolean validateNewOpenclinicCounter(String table, String column, String counter) {
        boolean result = true;
        try {
            String s = "select * from " + table + " where " + column + "=" + counter;
            Connection oc_conn=getOpenclinicConnection();
            PreparedStatement ps = oc_conn.prepareStatement(s);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                result = false;
            }
            rs.close();
            ps.close();
            oc_conn.close();
        }
        catch (Exception e) {
            e.printStackTrace();
        }
        return result;
    }
    /*public int getCounter(String name, Connection connection) {
        int newCounter = 0;
        Connection OccupdbConnection;
        try {
            OccupdbConnection = connection;
            PreparedStatement Occupstatement = OccupdbConnection.prepareStatement("select counter from counters where name=?");
            Occupstatement.setString(1, name);
            ResultSet Occuprs = Occupstatement.executeQuery();
            if (Occuprs.next()){
            	newCounter = Occuprs.getInt("counter");
            }
            Occuprs.close();
            Occupstatement.close();
            Occupstatement = OccupdbConnection.prepareStatement("update counters set counters.counter=? where counters.name=?");
            Occupstatement.setInt(1, newCounter + 1);
            Occupstatement.setString(2, name);
            Occupstatement.execute();
            Occupstatement.close();
        } catch (Exception e) {
            e.printStackTrace();
        }
        return newCounter;
    }
    */
    public ItemVO getItem(int serverId, int transactionId, String itemType) {
        ItemVO itemVO = null;
        Connection OccupdbConnection;
        try {
            OccupdbConnection = getOpenclinicConnection();
            PreparedStatement Occupstatement = OccupdbConnection.prepareStatement("SELECT * from Items where serverid=? and transactionId=? and type=?");
            Occupstatement.setInt(1, serverId);
            Occupstatement.setInt(2, transactionId);
            Occupstatement.setString(3, itemType);
            ResultSet Occuprs = Occupstatement.executeQuery();
            if (Occuprs.next()) {
                ItemContextVO itemContextVO = new ItemContextVO(new Integer(IdentifierFactory.getInstance().getTemporaryNewIdentifier()), "", "");
                itemVO = new ItemVO(new Integer(Occuprs.getInt("itemId")), Occuprs.getString("type"), Occuprs.getString("value"), Occuprs.getDate("date"), itemContextVO);
            }
            Occuprs.close();
            Occupstatement.close();
            OccupdbConnection.close();
        } catch (Exception e) {
            e.printStackTrace();
        }
        return itemVO;
    }
    public ItemVO getItem(int serverId, int itemId) {
        ItemVO itemVO = null;
        Connection OccupdbConnection;
        try {
            OccupdbConnection = getOpenclinicConnection();
            PreparedStatement Occupstatement = OccupdbConnection.prepareStatement("SELECT * from Items where serverid=? and itemId=?");
            Occupstatement.setInt(1, serverId);
            Occupstatement.setInt(2, itemId);
            ResultSet Occuprs = Occupstatement.executeQuery();
            if (Occuprs.next()) {
                ItemContextVO itemContextVO = new ItemContextVO(new Integer(IdentifierFactory.getInstance().getTemporaryNewIdentifier()), "", "");
                itemVO = new ItemVO(new Integer(Occuprs.getInt("itemId")), Occuprs.getString("type"), Occuprs.getString("value"), Occuprs.getDate("date"), itemContextVO);
            }
            Occuprs.close();
            Occupstatement.close();
            OccupdbConnection.close();

        } catch (Exception e) {
            e.printStackTrace();
        }
        return itemVO;
    }
    public Hashtable getLastItems(String healthRecordId) {
        Hashtable hashtable = new Hashtable();
        Connection OccupdbConnection;
        try {
            OccupdbConnection = getOpenclinicConnection();
            PreparedStatement Occupstatement = OccupdbConnection.prepareStatement("SELECT a.updateTime,b.* from Transactions a,Items b where a.healthRecordId>0 and a.healthRecordId=? and a.transactionId=b.transactionId and a.serverid=b.serverid order by a.updateTime DESC,itemId DESC");
            Occupstatement.setInt(1, Integer.parseInt(healthRecordId));
            ResultSet Occuprs = Occupstatement.executeQuery();
            ItemContextVO itemContextVO;
            int itemId;
            String type, value;
            Date date;
            ItemVO hashItem;
            while (Occuprs.next()) {
                itemId = Occuprs.getInt("itemId");
                type = Occuprs.getString("type");
                value = Occuprs.getString("value").replaceAll("\\'", "´").replaceAll("\"", "´");
                date = Occuprs.getDate("updateTime");
                hashItem = (ItemVO) hashtable.get(type);
                if (hashItem == null || hashItem.getDate().before(date)) {
                    itemContextVO = new ItemContextVO(new Integer(IdentifierFactory.getInstance().getTemporaryNewIdentifier()), "", "");
                    hashtable.put(type, new ItemVO(new Integer(itemId), type, value, date, itemContextVO));
                }
            }
            Occuprs.close();
            Occupstatement.close();
            OccupdbConnection.close();

        } catch (Exception e) {
            e.printStackTrace();
        }
        return hashtable;
    }
    public ItemVO getLastItemVO(String healthRecordId, String itemType) {
        String sSelect;
        ItemVO itemVO = null;
        Connection OccupdbConnection;
        PreparedStatement Occupstatement;
        try {
            OccupdbConnection = getOpenclinicConnection();
            if (itemType.indexOf("%") > -1) {
                sSelect = "SELECT * from Transactions a,Items b where a.healthRecordId=? and a.transactionId=b.transactionId and a.serverid=b.serverid and b.type like ? order by a.updateTime DESC,itemId DESC";
            } else {
                sSelect = "SELECT * from Transactions a,Items b where a.healthRecordId=? and a.transactionId=b.transactionId and a.serverid=b.serverid and b.type = ? order by a.updateTime DESC,itemId DESC";
            }
            Occupstatement = OccupdbConnection.prepareStatement(sSelect);
            Occupstatement.setInt(1, Integer.parseInt(healthRecordId));
            Occupstatement.setString(2, itemType);
            ResultSet Occuprs = Occupstatement.executeQuery();
            if (Occuprs.next()) {
                ItemContextVO itemContextVO = new ItemContextVO(new Integer(IdentifierFactory.getInstance().getTemporaryNewIdentifier()), "", "");
                itemVO = new ItemVO(new Integer(Occuprs.getInt("itemId")), Occuprs.getString("type"), Occuprs.getString("value"), Occuprs.getDate("date"), itemContextVO);
            }
            Occuprs.close();
            Occupstatement.close();
            OccupdbConnection.close();

        } catch (Exception e) {
            e.printStackTrace();
        }
        return itemVO;
    }
    public ItemVO getLastItemVO(int personId, String itemType) {
        ItemVO itemVO = null;
        Connection OccupdbConnection;
        try {
            OccupdbConnection = getOpenclinicConnection();
            PreparedStatement Occupstatement = OccupdbConnection.prepareStatement("SELECT * from Transactions a,Items b, Healthrecord c where a.healthRecordId=c.healthRecordId and c.personId=? and a.transactionId=b.transactionId and a.serverid=b.serverid and b.type = ? order by a.creationDate DESC,itemId DESC");
            Occupstatement.setInt(1, personId);
            Occupstatement.setString(2, itemType);
            ResultSet Occuprs = Occupstatement.executeQuery();
            if (Occuprs.next()) {
                ItemContextVO itemContextVO = new ItemContextVO(new Integer(IdentifierFactory.getInstance().getTemporaryNewIdentifier()), "", "");
                itemVO = new ItemVO(new Integer(Occuprs.getInt("itemId")), Occuprs.getString("type"), Occuprs.getString("value"), Occuprs.getDate("date"), itemContextVO);
            }
            Occuprs.close();
            Occupstatement.close();
            OccupdbConnection.close();

        } catch (Exception e) {
            e.printStackTrace();
        }
        return itemVO;
    }
    public String getLastItemValue(int personId, String itemType) {
        ItemVO item = getLastItemVO(personId, itemType);
        if (item != null) {
            return item.getValue();
        }
        return "";
    }
    public TransactionVO getLastTransactionVO(String healthRecordId, String transactionType) {
        TransactionVO transactionVO = null;
        Connection OccupdbConnection;
        try {
            OccupdbConnection = getOpenclinicConnection();
            PreparedStatement Occupstatement = OccupdbConnection.prepareStatement("SELECT * from Transactions where healthRecordId=? and transactionType=? order by updateTime DESC,transactionId DESC");
            Occupstatement.setInt(1, Integer.parseInt(healthRecordId));
            Occupstatement.setString(2, transactionType);
            ResultSet Occuprs = Occupstatement.executeQuery();
            if (Occuprs.next()) {
                java.sql.Date timestamp = Occuprs.getDate("ts");
                java.util.Date ts = null;
                if (timestamp != null) {
                    ts = new java.util.Date(timestamp.getTime());
                }
                transactionVO = new TransactionVO(new Integer(Occuprs.getInt("transactionId")), Occuprs.getString("transactionType"), Occuprs.getDate("creationdate"), Occuprs.getDate("updateTime"), Occuprs.getInt("Status"), null, null, Occuprs.getInt("serverid"), Occuprs.getInt("version"), Occuprs.getInt("versionserverid"), ts);
                return transactionVO;
            }
            Occuprs.close();
            Occupstatement.close();
            OccupdbConnection.close();

        } catch (Exception e) {
            e.printStackTrace();
        }
        return transactionVO;
    }
    public TransactionVO getLastTransactionVO(int personId, String transactionType) {
        TransactionVO transactionVO = null;
        Connection OccupdbConnection;
        try {
            OccupdbConnection = getOpenclinicConnection();
            PreparedStatement Occupstatement = OccupdbConnection.prepareStatement("SELECT a.* from Transactions a,Healthrecord b where a.healthRecordId=b.healthRecordId and b.personId=? and transactionType=? order by updateTime DESC,transactionId DESC");
            Occupstatement.setInt(1, personId);
            Occupstatement.setString(2, transactionType);
            ResultSet Occuprs = Occupstatement.executeQuery();
            if (Occuprs.next()) {
                transactionVO = new TransactionVO(new Integer(Occuprs.getInt("transactionId")), Occuprs.getString("transactionType"), Occuprs.getDate("creationdate"), Occuprs.getDate("updateTime"), Occuprs.getInt("Status"), null, null, Occuprs.getInt("serverid"), Occuprs.getInt("version"), Occuprs.getInt("versionserverid"), new java.util.Date(Occuprs.getDate("ts").getTime()));
                return transactionVO;
            }
            Occuprs.close();
            Occupstatement.close();
            OccupdbConnection.close();

        } catch (Exception e) {
            e.printStackTrace();
        }
        return transactionVO;
    }
    public PersonalVaccinationsInfoVO getPersonalVaccinationsInfo(PersonVO personVO, UserVO userVO) {
        return getPersonalVaccinationsInfo(personVO, userVO.getPersonVO().getLanguage());
    }
    public PersonalVaccinationsInfoVO getPersonalVaccinationsInfo(PersonVO personVO, String language) {
        PersonalVaccinationsInfoVO personalVaccinationsInfoVO = new PersonalVaccinationsInfoVO(personVO, null, null);
        Vector personalVaccinations = new Vector();
        Vector otherVaccinations = new Vector();
        String sStartedVaccinations = "'*'";
        Connection OccupdbConnection;
        try {
            String transactionType;
            int activeTransactionId = -1, status, version, versionserverid, activeServerId = -1;
            PreparedStatement Occupstatement2;
            ResultSet Occuprs2;
            TransactionVO activeTransaction = null;
            Date creationDate, updateTime;
            ItemContextVO itemContextVO;
            Element element, root;
            Document document;
            VaccinationInfoVO vaccinationInfoVO;
            Iterator elements;
            OccupdbConnection = getOpenclinicConnection();
            ResultSet Occuprs;
            //Eerst laden we alle vaccinatietransacties die er voor deze patient ooit geweest zijn.
            //We maken tevens een Hashtable aan met voor elke vaccinnaam de recentste vaccinatie
            PreparedStatement Occupstatement = OccupdbConnection.prepareStatement("select a.*,b.* from Transactions a,Items b,Healthrecord c where a.serverid=b.serverid and a.healthRecordId=c.healthRecordId and a.transactionId=b.transactionId and transactionType='be.mxs.common.model.vo.healthrecord.IConstants.TRANSACTION_TYPE_VACCINATION' and c.personId=? order by a.serverid,a.transactionId");
            Occupstatement.setInt(1, personVO.getPersonId().intValue());
            Occuprs = Occupstatement.executeQuery();
//            Vector persVacs = new Vector();
            Hashtable hPersVacs = new Hashtable();
            int tranId, serId;
            ItemVO vacType, vacDate, vacName;
            String sVacType;
            while (Occuprs.next()) {
                tranId = Occuprs.getInt("transactionId");
                serId = Occuprs.getInt("serverid");
                if (activeTransactionId != tranId || activeServerId != serId) {
                    //A new transaction starts!
                    //First check if the previous vaccination is the most recent one for its name
                    if (activeTransaction != null) {
                        vacType = activeTransaction.getItem("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_VACCINATION_TYPE");
                        vacDate = activeTransaction.getItem("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_VACCINATION_DATE");
                        vacName = activeTransaction.getItem("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_VACCINATION_NAME");
                        if (vacType != null && vacDate != null) {
                            sVacType = vacType.getValue();
                            if (vacName != null) {
                                sVacType += "." + vacName.getValue();
                            }
                            try {
                                java.util.Date dVacDate = stdDateFormat.parse(vacDate.getValue().replaceAll("-", "/"));
                                if (hPersVacs.get(sVacType) == null || (stdDateFormat.parse(((TransactionVO) hPersVacs.get(sVacType)).getItem("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_VACCINATION_DATE").getValue().replaceAll("-", "/")).before(dVacDate))) {
                                    hPersVacs.put(sVacType, activeTransaction);
                                }
                            } catch (Exception e) {
                                e.printStackTrace();
                            }
                        }
                    }
                    transactionType = Occuprs.getString("transactionType");
                    creationDate = new Date(Occuprs.getDate("creationDate").getTime());
                    updateTime = new Date(Occuprs.getDate("updateTime").getTime());
                    status = Occuprs.getInt("status");
                    version = Occuprs.getInt("version");
                    versionserverid = Occuprs.getInt("versionserverid");
                    activeTransaction = new TransactionVO(new Integer(tranId), transactionType, creationDate, updateTime, status, null, new Vector(), serId, version, versionserverid, creationDate);
                    //if(Debug.enabled) Debug.println("transactionId="+activeTransaction.getTransactionId()+"  serverId="+serId);
//                    persVacs.add(activeTransaction);
                }
                activeTransactionId = tranId;
                activeServerId = serId;
                itemContextVO = new ItemContextVO(new Integer(IdentifierFactory.getInstance().getTemporaryNewIdentifier()), "", "");
                activeTransaction.getItems().add(new ItemVO(new Integer(Occuprs.getInt("itemId")), Occuprs.getString("type"), Occuprs.getString("value"), Occuprs.getDate("date"), itemContextVO));
            }
            Occuprs.close();
            Occupstatement.close();
            if (activeTransaction != null) {
                vacType = activeTransaction.getItem("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_VACCINATION_TYPE");
                vacDate = activeTransaction.getItem("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_VACCINATION_DATE");
                vacName = activeTransaction.getItem("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_VACCINATION_NAME");
                if (vacType != null && vacDate != null) {
                    sVacType = vacType.getValue();
                    if (vacName != null) {
                        sVacType += "." + vacName.getValue();
                    }
                    try {
                        java.util.Date dVacDate = stdDateFormat.parse(vacDate.getValue().replaceAll("-", "/"));
                        if (hPersVacs.get(sVacType) == null || (stdDateFormat.parse(((TransactionVO) hPersVacs.get(sVacType)).getItem("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_VACCINATION_DATE").getValue().replaceAll("-", "/")).before(dVacDate))) {
                            hPersVacs.put(sVacType, activeTransaction);
                            //if(Debug.enabled) Debug.println("transactionId="+activeTransaction.getTransactionId()+"  serverId="+activeTransaction.getServerId());
                        }
                    } catch (Exception e) {
                        e.printStackTrace();
                    }
                }
            }
            Hashtable examinations = new Hashtable();
            Occupstatement = OccupdbConnection.prepareStatement("select * from Examinations");
            Occuprs = Occupstatement.executeQuery();
            while (Occuprs.next()) {
                if (Occuprs.getString("messageKey") != null && Occuprs.getBytes("data") != null) {
                    examinations.put(Occuprs.getString("messageKey").toLowerCase(), Occuprs.getBytes("data"));
                }
            }
            Occuprs.close();
            Occupstatement.close();
            Iterator iterator = new TreeSet(hPersVacs.keySet()).iterator();
            while (iterator.hasNext()) {
                activeTransaction = (TransactionVO) hPersVacs.get(iterator.next());
//                element = null;
                try {
                    //if (Debug.enabled) Debug.println("vacc201");
                    document = DocumentHelper.parseText(new String((byte[]) examinations.get(activeTransaction.getItem("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_VACCINATION_TYPE").getValue().toLowerCase())));
                    root = document.getRootElement();
                    //if (Debug.enabled) Debug.println("vacc202");
                    for (elements = root.elements().iterator(); elements.hasNext();) {
                        element = (Element) elements.next();
                        if (element.valueOf("@ID").equals("Vaccination")) {
                            sStartedVaccinations = sStartedVaccinations + ",'" + element.valueOf("@Label") + "'";
                            //if (Debug.enabled) Debug.println("vacc21");
                            vaccinationInfoVO = getVaccinationInfoVO(activeTransaction, element);
                            personalVaccinations.add(vaccinationInfoVO);
                            if (Debug.enabled) Debug.println(vaccinationInfoVO.toString());
                            //if (Debug.enabled) Debug.println("vacc22");
                            break;
                        }
                    }
                } catch (DocumentException e) {
                    e.printStackTrace();
                }
            }
            String sQ = "queryPersonalVaccinations";
            if (getConfigString("personalVaccinationsQuery") != null && getConfigString("personalVaccinationsQuery").length() > 0) {
                sQ = getConfigString("personalVaccinationsQuery");
            }
            Occupstatement = OccupdbConnection.prepareStatement(getConfigString(sQ));
            Occupstatement.setInt(1, personVO.getPersonId().intValue());
            Occupstatement.setInt(2, personVO.getPersonId().intValue());
            Occupstatement.setInt(3, personVO.getPersonId().intValue());
            Occupstatement.setInt(4, personVO.getPersonId().intValue());
            Occupstatement.setInt(5, personVO.getPersonId().intValue());
            Occupstatement.setInt(6, personVO.getPersonId().intValue());
            Occupstatement.setInt(7, personVO.getPersonId().intValue());
            Occupstatement.setInt(8, personVO.getPersonId().intValue());
            Occuprs = Occupstatement.executeQuery();
            String messageKey;
            Vector items;
            TransactionVO noneTransaction;
            while (Occuprs.next()) {
                messageKey = Occuprs.getString("messageKey") == null ? null : Occuprs.getString("messageKey").toLowerCase();
                if (sStartedVaccinations.toLowerCase().indexOf(messageKey) < 0) {
                    Occupstatement2 = OccupdbConnection.prepareStatement("select data from Examinations where messageKey=?");
                    Occupstatement2.setString(1, messageKey);
                    Occuprs2 = Occupstatement2.executeQuery();
                    if (Occuprs2.next()) {
                        try {
                            if (Debug.enabled) Debug.println("parsing document");
                            document = DocumentHelper.parseText(new String(Occuprs2.getBytes("data")));
                            if (Debug.enabled) Debug.println("document parsed");
                            root = document.getRootElement();
                            for (elements = root.elements().iterator(); elements.hasNext();) {
                                element = (Element) elements.next();
                                if (element.valueOf("@ID").equals("Vaccination")) {
                                    sStartedVaccinations = sStartedVaccinations + ",'" + element.valueOf("@Label") + "'";
                                    itemContextVO = new ItemContextVO(new Integer(IdentifierFactory.getInstance().getTemporaryNewIdentifier()), "", "");
                                    items = new Vector();
                                    items.add(new ItemVO(new Integer(IdentifierFactory.getInstance().getTemporaryNewIdentifier()), "be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_VACCINATION_TYPE", element.valueOf("@Label"), new java.util.Date(), itemContextVO));
                                    items.add(new ItemVO(new Integer(IdentifierFactory.getInstance().getTemporaryNewIdentifier()), "be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_VACCINATION_STATUS", "be.mxs.healthrecord.vaccination.status-none", new java.util.Date(), itemContextVO));
                                    items.add(new ItemVO(new Integer(IdentifierFactory.getInstance().getTemporaryNewIdentifier()), "be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_VACCINATION_DATE", null, new java.util.Date(), itemContextVO));
                                    items.add(new ItemVO(new Integer(IdentifierFactory.getInstance().getTemporaryNewIdentifier()), "be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_VACCINATION_NEXT_DATE", null, new java.util.Date(), itemContextVO));
                                    items.add(new ItemVO(new Integer(IdentifierFactory.getInstance().getTemporaryNewIdentifier()), "be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_COMMENT", "", new java.util.Date(), itemContextVO));
                                    noneTransaction = new TransactionVO(new Integer(IdentifierFactory.getInstance().getTemporaryNewIdentifier()), "be.mxs.common.model.vo.healthrecord.IConstants.TRANSACTION_TYPE_VACCINATION", new java.util.Date(), new java.util.Date(), 1, null, items);
                                    vaccinationInfoVO = getVaccinationInfoVO(noneTransaction, element);
                                    personalVaccinations.add(vaccinationInfoVO);
                                    break;
                                }
                            }
                        } catch (DocumentException e) {
                            e.printStackTrace();
                        }
                    }
                    Occuprs2.close();
                    Occupstatement2.close();
                }
            }
            Occuprs.close();
            Occupstatement.close();
            personalVaccinationsInfoVO.setVaccinationsInfoVO(personalVaccinations);
            Occupstatement = OccupdbConnection.prepareStatement("select * from Examinations where transactionType like 'be.mxs.common.model.vo.healthrecord.IConstants.TRANSACTION_TYPE_VACCINATION%' and (messageKey like '%Other' or messageKey not in (" + sStartedVaccinations + "))");
            Occuprs = Occupstatement.executeQuery();
            while (Occuprs.next()) {
                otherVaccinations.add(getExamination(Occuprs.getString("id"), language));
                if (Debug.enabled) Debug.println("other vaccination: " + Occuprs.getString("messageKey"));
            }
            Occuprs.close();
            personalVaccinationsInfoVO.setOtherVaccinations(otherVaccinations);
            Occupstatement.close();
            OccupdbConnection.close();

        } catch (Exception e) {
            e.printStackTrace();
        }
        return personalVaccinationsInfoVO;
    }
    
    public TransactionVO loadTransaction(int serverId, int transactionId) {
        TransactionVO transactionVO = (TransactionVO)MedwanQuery.getInstance().getObjectCache().getObject("transaction",serverId+"."+transactionId);
        if(transactionVO!=null){
            return transactionVO;
        }
        Connection OccupdbConnection;
        try {
            OccupdbConnection = getOpenclinicConnection();
            String sItemType;
            PreparedStatement Occupstatement = OccupdbConnection.prepareStatement("SELECT c.start,c.stop,d.*,a.transactionType,a.creationDate,a.updateTime as ut,a.status,a.userId,b.*,a.healthRecordId from Transactions a,Items b,UsersView c,AdminView d where a.userId=c.userid and c.personid=d.personid and a.transactionId=b.transactionId and a.serverid=b.serverid and a.serverid=? and a.transactionId=? order by b.priority");
            Occupstatement.setInt(1, serverId);
            Occupstatement.setInt(2, transactionId);
            ResultSet Occuprs = Occupstatement.executeQuery();
            boolean bInitialized = false;
            String transactionType, userid;
            Date creationDate, updateTime, dateBegin, dateEnd, dateStart;
            int status, version, versionserverid;
            UserVO userVO;
            ItemContextVO itemContextVO;
            while (Occuprs.next()) {
                if (!bInitialized) {
                    if (Debug.enabled) Debug.println("Initializing transactionId=" + transactionId);
                    transactionType = Occuprs.getString("transactionType");
                    if (Debug.enabled) Debug.println("Type=" + transactionType);
                    creationDate = new Date(Occuprs.getDate("creationDate").getTime());
                    updateTime = new Date(Occuprs.getDate("ut").getTime());
                    status = Occuprs.getInt("status");
                    version = Occuprs.getInt("version");
                    versionserverid = Occuprs.getInt("versionserverid");
                    userid = Occuprs.getString("userId");
                    transactionVO = new TransactionVO(new Integer(transactionId), transactionType, creationDate, updateTime, status, null, new Vector(), serverId, version, versionserverid, creationDate);
                    transactionVO.setHealthrecordId(Occuprs.getInt("healthRecordId"));
                    dateBegin = null;
                    dateEnd = null;
                    dateStart = Occuprs.getDate("start");
                    if (dateStart != null) {
                        dateBegin = new Date(dateStart.getTime());
                    }
                    if (Occuprs.getDate("stop") != null)
                        dateEnd = new Date(Occuprs.getDate("stop").getTime());
                    userVO = new UserVO(new Integer(userid), "", dateBegin, dateEnd, new PersonVO(Occuprs.getString("natreg"), Occuprs.getString("immatold"), Occuprs.getString("immatnew"), Occuprs.getString("candidate"), Occuprs.getString("lastname"), Occuprs.getString("firstname"), Occuprs.getString("gender"), Occuprs.getString("language"), new Integer(Occuprs.getInt("personid"))));
                    transactionVO.setUser(userVO);
                    bInitialized = true;
                }
                itemContextVO = new ItemContextVO(new Integer(IdentifierFactory.getInstance().getTemporaryNewIdentifier()), "", "");
                sItemType = Occuprs.getString("type");
                transactionVO.getItems().add(new ItemVO(new Integer(Occuprs.getInt("itemId")), sItemType, Occuprs.getString("value"), Occuprs.getDate("date"), itemContextVO, Occuprs.getInt("priority")));
            }
            Occuprs.close();
            Occupstatement.close();
            OccupdbConnection.close();

        } catch (Exception e) {
            e.printStackTrace();
        }
        MedwanQuery.getInstance().getObjectCache().putObject("transaction",transactionVO);
        return transactionVO;
    }

    public TransactionVO loadTransaction(String serverId, String transactionId, String version, String versionServerId) {
        if (version == null || versionServerId == null)
            return loadTransaction((Integer.parseInt(serverId)), Integer.parseInt(transactionId));
        TransactionVO transactionVO = null;
        Connection OccupdbConnection;
        try {
            OccupdbConnection = getOpenclinicConnection();
            PreparedStatement Occupstatement = OccupdbConnection.prepareStatement("SELECT * from Transactions where serverid=? and transactionId=? and version=? and versionserverid=?");
            Occupstatement.setInt(1, Integer.parseInt(serverId));
            Occupstatement.setInt(2, Integer.parseInt(transactionId));
            Occupstatement.setInt(3, Integer.parseInt(version));
            Occupstatement.setInt(4, Integer.parseInt(versionServerId));
            ResultSet Occuprs = Occupstatement.executeQuery();
            String transactionType, userid;
            Date creationDate, updateTime;
            int status;
            ItemContextVO itemContextVO;
            if (Occuprs.next()) {
                transactionType = Occuprs.getString("transactionType");
                creationDate = new Date(Occuprs.getDate("creationDate").getTime());
                updateTime = new Date(Occuprs.getDate("updateTime").getTime());
                status = Occuprs.getInt("status");
                userid = Occuprs.getString("userId");
                transactionVO = new TransactionVO(new Integer(transactionId), transactionType, creationDate, updateTime, status, null, new Vector(), Integer.parseInt(serverId), Integer.parseInt(version), Integer.parseInt(versionServerId), creationDate);
                transactionVO.setUser(getUser(userid));
                Occuprs.close();
                Occupstatement.close();
                Occupstatement = OccupdbConnection.prepareStatement("select * from Items where serverid=? and transactionId=?");
                Occupstatement.setInt(1, Integer.parseInt(serverId));
                Occupstatement.setInt(2, Integer.parseInt(transactionId));
                for (Occuprs = Occupstatement.executeQuery(); Occuprs.next();) {
                    itemContextVO = new ItemContextVO(new Integer(IdentifierFactory.getInstance().getTemporaryNewIdentifier()), "", "");
                    transactionVO.getItems().add(new ItemVO(new Integer(Occuprs.getInt("itemId")), Occuprs.getString("type"), Occuprs.getString("value"), Occuprs.getDate("date"), itemContextVO));
                }
            } else {
                transactionVO = loadTransactionHistory(transactionId, serverId, version, versionServerId);
            }
            Occuprs.close();
            Occupstatement.close();
            OccupdbConnection.close();

        } catch (Exception e) {
            e.printStackTrace();
        }
        return transactionVO;
    }
    public TransactionVO loadTransactionHistory(String serverId, String transactionId, String version, String versionServerId) {
        TransactionVO transactionVO = null;
        Connection OccupdbConnection;
        try {
            OccupdbConnection = getOpenclinicConnection();
            PreparedStatement Occupstatement = OccupdbConnection.prepareStatement("SELECT * from TransactionsHistory where serverid=? and transactionId=? and version=? and versionserverid=?");
            Occupstatement.setInt(1, Integer.parseInt(serverId));
            Occupstatement.setInt(2, Integer.parseInt(transactionId));
            Occupstatement.setInt(3, Integer.parseInt(version));
            Occupstatement.setInt(4, Integer.parseInt(versionServerId));
            ResultSet Occuprs = Occupstatement.executeQuery();
            String transactionType, userid;
            int status;
            Date creationDate, updateTime;
            if (Occuprs.next()) {
                transactionType = Occuprs.getString("transactionType");
                creationDate = new Date(Occuprs.getDate("creationDate").getTime());
                updateTime = new Date(Occuprs.getDate("updateTime").getTime());
                status = Occuprs.getInt("status");
                userid = Occuprs.getString("userId");
                transactionVO = new TransactionVO(new Integer(transactionId), transactionType, creationDate, updateTime, status, null, new Vector(), Integer.parseInt(serverId), Integer.parseInt(version), Integer.parseInt(versionServerId), creationDate);
                transactionVO.setUser(getUser(userid));
                Occuprs.close();
                Occupstatement.close();
                Occupstatement = OccupdbConnection.prepareStatement("select * from ItemsHistory where serverid=? and transactionId=? and version=? and versionserverid=?");
                Occupstatement.setInt(1, Integer.parseInt(serverId));
                Occupstatement.setInt(2, Integer.parseInt(transactionId));
                Occupstatement.setInt(3, Integer.parseInt(version));
                Occupstatement.setInt(4, Integer.parseInt(versionServerId));
                for (Occuprs = Occupstatement.executeQuery(); Occuprs.next(); transactionVO.getItems().add(getItem(Integer.parseInt(serverId), Occuprs.getInt("itemId")))) {
                }
            }
            Occuprs.close();
            Occupstatement.close();
            OccupdbConnection.close();

        } catch (Exception e) {
            e.printStackTrace();
        }
        return transactionVO;
    }
    public PersonVO getPerson(String personId) {
        PersonVO personVO = null;
        if (personId != null && !personId.equals("")) {
            Connection OccupdbConnection;
            try {
                OccupdbConnection = getOpenclinicConnection();
                PreparedStatement Occupstatement = OccupdbConnection.prepareStatement("SELECT * from AdminView where personid=?");
                Occupstatement.setInt(1, Integer.parseInt(personId));
                ResultSet Occuprs = Occupstatement.executeQuery();
                if (Occuprs.next()) {
                    personVO = new PersonVO(Occuprs.getString("natreg"), Occuprs.getString("immatold"), Occuprs.getString("immatnew"), Occuprs.getString("candidate"), Occuprs.getString("lastname"), Occuprs.getString("firstname"), Occuprs.getString("gender"), Occuprs.getString("language"), new Integer(personId));
                    personVO.setDateofbirth(Occuprs.getDate("dateofbirth"));
                }
                Occuprs.close();
                Occupstatement.close();
                OccupdbConnection.close();

            } catch (Exception e) {
                e.printStackTrace();
            }
        }
        return personVO;
    }
    public UserVO getUser(String userId) {
        UserVO userVO = null;
        Connection OccupdbConnection;
        try {
            OccupdbConnection = getOpenclinicConnection();
            PreparedStatement Occupstatement = OccupdbConnection.prepareStatement("SELECT a.userid,a.start,a.stop,b.* from UsersView a, AdminView b where a.personid=b.personid and userid=?");
            Occupstatement.setInt(1, Integer.parseInt(userId));
            ResultSet Occuprs = Occupstatement.executeQuery();
            if (Occuprs.next()) {
                Date dateBegin = null;
                Date dateEnd = null;
                Date dateStart = Occuprs.getDate("start");
                if (dateStart != null) {
                    dateBegin = new Date(dateStart.getTime());
                }
                if (Occuprs.getDate("stop") != null)
                    dateEnd = new Date(Occuprs.getDate("stop").getTime());
                userVO = new UserVO(new Integer(userId), "", dateBegin, dateEnd, new PersonVO(Occuprs.getString("natreg"), Occuprs.getString("immatold"), Occuprs.getString("immatnew"), Occuprs.getString("candidate"), Occuprs.getString("lastname"), Occuprs.getString("firstname"), Occuprs.getString("gender"), Occuprs.getString("language"), new Integer(Occuprs.getInt("personid"))));
            }
            Occuprs.close();
            Occupstatement.close();
            OccupdbConnection.close();

        } catch (Exception e) {
            e.printStackTrace();
        }
        return userVO;
    }
    public ExaminationVO getExamination(String examinationId, String language) {
        ExaminationVO examinationVO = (ExaminationVO)examinations.get(examinationId+"."+language);
        if(examinationVO==null){
	        Connection OccupdbConnection;
	        try {
	            OccupdbConnection = getOpenclinicConnection();
	            PreparedStatement Occupstatement = OccupdbConnection.prepareStatement("SELECT * from Examinations where id=?");
	            Occupstatement.setInt(1, Integer.parseInt(examinationId));
	            ResultSet Occuprs = Occupstatement.executeQuery();
	            if (Occuprs.next()){
	            	examinationVO = new ExaminationVO(new Integer(examinationId), Occuprs.getString("messageKey") == null ? null : Occuprs.getString("messagekey").toLowerCase(), new Integer(Occuprs.getInt("priority")), Occuprs.getBytes("data"), Occuprs.getString("transactionType"), Occuprs.getString("NL"), Occuprs.getString("FR"), language);
	            	examinations.put(examinationId+"."+language, examinationVO);
	            }
	            Occuprs.close();
	            Occupstatement.close();
	            OccupdbConnection.close();
	
	        } catch (Exception e) {
	            e.printStackTrace();
	        }
        }
        return examinationVO;
    }
    public Collection findAllRiskCodes(String language) {
        Vector riskCodes = new Vector();
        Connection OccupdbConnection;
        try {
            OccupdbConnection = getOpenclinicConnection();
            Statement Occupstatement = OccupdbConnection.createStatement();
            ResultSet Occuprs;
            Occuprs = Occupstatement.executeQuery("SELECT * FROM RiskCodes WHERE deletedate IS NULL ORDER BY code");
            String messageKey;
            while (Occuprs.next()) {
                messageKey = Occuprs.getString("messageKey") == null ? null : Occuprs.getString("messageKey").toLowerCase();
                riskCodes.add(new RiskCodeVO(new Integer(Occuprs.getInt("id")), Occuprs.getString("code"), messageKey, Occuprs.getString("NL"), Occuprs.getString("FR"), Occuprs.getString("showDefault"), language));
            }
            Occuprs.close();
            Occupstatement.close();
            OccupdbConnection.close();

        } catch (Exception e) {
            e.printStackTrace();
        }
        return riskCodes;
    }
    public RiskCodeVO findRiskCode(String riskCodeId, String language) {
        RiskCodeVO riskCode = null;
        Connection OccupdbConnection;
        try {
            OccupdbConnection = getOpenclinicConnection();
            PreparedStatement Occupstatement = OccupdbConnection.prepareStatement("SELECT * from RiskCodes where id=?");
            Occupstatement.setInt(1, Integer.parseInt(riskCodeId));
            ResultSet Occuprs = Occupstatement.executeQuery();
            if (Occuprs.next()){
            	riskCode = new RiskCodeVO(new Integer(riskCodeId), Occuprs.getString("code"), Occuprs.getString("messageKey") == null ? null : Occuprs.getString("messageKey").toLowerCase(), Occuprs.getString("NL"), Occuprs.getString("FR"), Occuprs.getString("showDefault"), language);
            }
            Occuprs.close();
            Occupstatement.close();
            OccupdbConnection.close();

        } catch (Exception e) {
            e.printStackTrace();
        }
        return riskCode;
    }
    public Collection getAllExaminations(String language) {
        Vector allExaminations = new Vector();
        Connection OccupdbConnection;
        try {
            OccupdbConnection = getOpenclinicConnection();
            Statement Occupstatement = OccupdbConnection.createStatement();
            ResultSet Occuprs = Occupstatement.executeQuery("SELECT * from Examinations where deletedate is null order by priority");
            while (Occuprs.next()) {
                allExaminations.add(new ExaminationVO(new Integer(Occuprs.getInt("id")), Occuprs.getString("messageKey") == null ? null : Occuprs.getString("messageKey").toLowerCase(), new Integer(Occuprs.getInt("priority")), Occuprs.getBytes("data"), Occuprs.getString("transactionType"), Occuprs.getString("NL"), Occuprs.getString("FR"), language));
            }
            Occuprs.close();
            Occupstatement.close();
            OccupdbConnection.close();

        }
        catch (Exception e) {
            e.printStackTrace();
        }
        return allExaminations;
    }
    public String getRiskProfileComment(SessionContainerWO sessionContainerWO) {
        String comment = "";
        Integer personId = sessionContainerWO.getPersonVO().getPersonId();
        String sSelect = "SELECT comment FROM RiskProfiles WHERE personId = " + personId + " AND dateEnd IS NULL";
        Connection OccupdbConnection;
//        OccupdbConnection = getOpenclinicConnection();
        ResultSet Occuprs;
        try {
            OccupdbConnection = getOpenclinicConnection();
            Statement Occupstatement = OccupdbConnection.createStatement();
            Occuprs = Occupstatement.executeQuery(sSelect);
            if (Occuprs.next()) {
                comment = Occuprs.getString("comment");
            }
            Occuprs.close();
            Occupstatement.close();
            OccupdbConnection.close();

        } catch (Exception e) {
            e.printStackTrace();
        }
        return comment;
    }
    public RiskProfileSystemInfoVO getRiskProfileSystemInfo(SessionContainerWO sessionContainerWO, String language) {
        Vector allWorkplaces = new Vector();
        Vector allFunctionCategories = new Vector();
        Vector allFunctionGroups = new Vector();
//        Vector allExaminations = new Vector();
        String activeLanguage;
        if (sessionContainerWO.getUserVO().getPersonVO().getLanguage().equalsIgnoreCase("N"))
            activeLanguage = "NL";
        else
            activeLanguage = "FR";
        Connection OccupdbConnection;
        try {
            OccupdbConnection = getOpenclinicConnection();
            Statement Occupstatement = OccupdbConnection.createStatement();
            ResultSet Occuprs;
            String languageCol = "NL";
            if (language.equalsIgnoreCase("F") || language.equalsIgnoreCase("FR")) languageCol = "FR";
            String sSelect = "SELECT * from Workplaces where deletedate is null ORDER BY " + languageCol;
            for (Occuprs = Occupstatement.executeQuery(sSelect); Occuprs.next(); allWorkplaces.add(new WorkplaceVO(new Integer(Occuprs.getInt("id")), Occuprs.getString(activeLanguage)))) {
            }
            Occuprs.close();
            Occupstatement.close();
            sSelect = "SELECT * from FunctionCategories where deletedate is null ORDER BY " + languageCol;
            for (Occuprs = Occupstatement.executeQuery(sSelect); Occuprs.next(); allFunctionCategories.add(new FunctionCategoryVO(new Integer(Occuprs.getInt("id")), Occuprs.getString(activeLanguage), Occuprs.getString("serviceId")))) {
            }
            Occuprs.close();
            Occupstatement.close();
            sSelect = "SELECT * from FunctionGroups where deletedate is null ORDER BY " + languageCol;
            for (Occuprs = Occupstatement.executeQuery(sSelect); Occuprs.next(); allFunctionGroups.add(new FunctionGroupVO(new Integer(Occuprs.getInt("id")), Occuprs.getString(activeLanguage), Occuprs.getString("serviceId")))) {
            }
            Occuprs.close();
            Occupstatement.close();
            OccupdbConnection.close();

        } catch (Exception e) {
            e.printStackTrace();
        }
        return new RiskProfileSystemInfoVO(allWorkplaces, allFunctionCategories, allFunctionGroups);
    }
    public RiskProfileVO updateRiskProfileRiskCodes(long personId, Hashtable updatedRiskcodes, SessionContainerWO sessionContainerWO, String comment) {
        exportPerson(new Long(personId).intValue());
        try {
            Connection OccupdbConnection = getOpenclinicConnection();
            PreparedStatement Occupstatement;
            int newProfileId;
            if (sessionContainerWO.getRiskProfileVO().getProfileId() == null) {
                newProfileId = getOpenclinicCounter("RiskProfileID");
                Occupstatement = OccupdbConnection.prepareStatement("insert into RiskProfiles(profileId,dateBegin,dateEnd,personId,updatetime,comment,updateserverid) values(?,?,null,?,?,?," + MedwanQuery.getInstance().getConfigInt("serverId") + ")");
                Occupstatement.setInt(1, newProfileId);
                Occupstatement.setDate(2, new java.sql.Date(new java.util.Date().getTime()));
                Occupstatement.setInt(3, new Long(personId).intValue());
                Occupstatement.setTimestamp(4, new Timestamp(new java.util.Date().getTime()));
                Occupstatement.setString(5, comment);
                Occupstatement.execute();
                Occupstatement.close();
            } else {
                Occupstatement = OccupdbConnection.prepareStatement("update RiskProfiles set updatetime=?, comment=?,updateserverid=" + MedwanQuery.getInstance().getConfigInt("serverId") + " where profileId=?");
                Occupstatement.setTimestamp(1, new Timestamp(new java.util.Date().getTime()));
                Occupstatement.setString(2, comment);
                Occupstatement.setInt(3, sessionContainerWO.getRiskProfileVO().getProfileId().intValue());
                Occupstatement.execute();
                Occupstatement.close();
                newProfileId = sessionContainerWO.getRiskProfileVO().getProfileId().intValue();
            }
            Occupstatement = OccupdbConnection.prepareStatement("delete from RiskProfileItems where itemType like '%RISK' and profileId=?");
            Occupstatement.setInt(1, newProfileId);
            Occupstatement.execute();
            Occupstatement.close();
            RiskProfileRiskCodeVO riskProfileRiskCodeVO;
            RiskProfileRiskCodeVO systemRiskCodeVO;
            boolean exists;
            Iterator iterator;
            for (Enumeration elements = updatedRiskcodes.elements(); elements.hasMoreElements();) {
                riskProfileRiskCodeVO = (RiskProfileRiskCodeVO) elements.nextElement();
                exists = false;
                for (iterator = sessionContainerWO.getRiskProfileVO().getSystemRiskProfileRiskCodesVO().iterator(); iterator.hasNext();) {
                    systemRiskCodeVO = (RiskProfileRiskCodeVO) iterator.next();
                    if (systemRiskCodeVO.getRiskCodeId().equals(riskProfileRiskCodeVO.getRiskCodeId())) {
                        exists = true;
                        break;
                    }
                }
                if (!exists) {
                    Occupstatement = OccupdbConnection.prepareStatement("insert into RiskProfileItems(profileItemId,itemType,itemId,status,comment,profileId,frequency,tolerance,ageGenderControl) values(?,'be.dpms.medwan.common.model.IConstants.PERSONAL_RISK',?,1,null,?,null,null,null)");
                    Occupstatement.setInt(1, getOpenclinicCounter("RiskProfileItemID"));
                    Occupstatement.setInt(2, riskProfileRiskCodeVO.getRiskCodeId().intValue());
                    Occupstatement.setInt(3, newProfileId);
                    Occupstatement.execute();
                    Occupstatement.close();
                }
            }
            boolean removed;
            Enumeration elements;
            for (iterator = sessionContainerWO.getRiskProfileVO().getSystemRiskProfileRiskCodesVO().iterator(); iterator.hasNext();) {
                systemRiskCodeVO = (RiskProfileRiskCodeVO) iterator.next();
                removed = true;
                for (elements = updatedRiskcodes.elements(); elements.hasMoreElements();) {
                    riskProfileRiskCodeVO = (RiskProfileRiskCodeVO) elements.nextElement();
                    if (systemRiskCodeVO.getRiskCodeId().equals(riskProfileRiskCodeVO.getRiskCodeId())) {
                        removed = false;
                        break;
                    }
                }
                if (removed) {
                    Occupstatement = OccupdbConnection.prepareStatement("insert into RiskProfileItems(profileItemId,itemType,itemId,status,comment,profileId,frequency,tolerance,ageGenderControl) values(?,'be.dpms.medwan.common.model.IConstants.SYSTEM_RISK',?,-1,null,?,null,null,null)");
                    Occupstatement.setInt(1, getOpenclinicCounter("RiskProfileItemID"));
                    Occupstatement.setInt(2, systemRiskCodeVO.getRiskCodeId().intValue());
                    Occupstatement.setInt(3, newProfileId);
                    Occupstatement.execute();
                    Occupstatement.close();
                }
            }
            Occupstatement.close();
            OccupdbConnection.close();

        } catch (Exception e) {
            e.printStackTrace();
        }
        return getRiskProfileVO(new Long(personId), sessionContainerWO);
    }
    public RiskProfileVO updateRiskProfileExaminations(long personId, Hashtable updatedExaminations, SessionContainerWO sessionContainerWO, String comment) {
        exportPerson(new Long(personId).intValue());
        Connection OccupdbConnection;
        try {
            OccupdbConnection = getOpenclinicConnection();
            PreparedStatement Occupstatement;
            int newProfileId;
            if (sessionContainerWO.getRiskProfileVO().getProfileId() == null) {
                newProfileId = getOpenclinicCounter("RiskProfileID");
                Occupstatement = OccupdbConnection.prepareStatement("insert into RiskProfiles(profileId,dateBegin,dateEnd,personId,updatetime,comment,updateserverid) values(?,?,null,?,?,?," + MedwanQuery.getInstance().getConfigInt("serverId") + ")");
                Occupstatement.setInt(1, newProfileId);
                Occupstatement.setDate(2, new java.sql.Date(new java.util.Date().getTime()));
                Occupstatement.setInt(3, new Long(personId).intValue());
                Occupstatement.setTimestamp(4, new Timestamp(new java.util.Date().getTime()));
                Occupstatement.setString(5, comment);
                Occupstatement.execute();
                Occupstatement.close();
            } else {
                Occupstatement = OccupdbConnection.prepareStatement("update RiskProfiles set updatetime=?, comment=?,updateserverid=" + MedwanQuery.getInstance().getConfigInt("serverId") + " where profileId=?");
                Occupstatement.setTimestamp(1, new Timestamp(new java.util.Date().getTime()));
                Occupstatement.setString(2, comment);
                Occupstatement.setInt(3, sessionContainerWO.getRiskProfileVO().getProfileId().intValue());
                Occupstatement.execute();
                Occupstatement.close();
                newProfileId = sessionContainerWO.getRiskProfileVO().getProfileId().intValue();
            }
            Occupstatement = OccupdbConnection.prepareStatement("delete from RiskProfileItems where itemType in('be.dpms.medwan.common.model.IConstants.PERSONAL_EXAMINATION','be.dpms.medwan.common.model.IConstants.SYSTEM_EXAMINATION') and profileId=?");
            Occupstatement.setInt(1, newProfileId);
            Occupstatement.execute();
            Occupstatement.close();
            String userLanguage;
            if (sessionContainerWO.getUserVO().getPersonVO().getLanguage().equalsIgnoreCase("N"))
                userLanguage = "NL";
            else
                userLanguage = "FR";
            Vector personalRiskExaminations = new Vector();
            String risksArray = "0";
            for (int n = 0; n < sessionContainerWO.getRiskProfileVO().getPersonalRiskProfileRiskCodesVO().size(); n++) {
                if (!((RiskProfileRiskCodeVO) sessionContainerWO.getRiskProfileVO().getPersonalRiskProfileRiskCodesVO().elementAt(n)).getStatus().equals(new Integer(be.dpms.medwan.common.model.IConstants.RISK_PROFILE_ITEM__STATUS_DELETED)))
                    risksArray = risksArray + "," + ((RiskProfileRiskCodeVO) sessionContainerWO.getRiskProfileVO().getPersonalRiskProfileRiskCodesVO().elementAt(n)).getRiskCodeId();
            }
            ResultSet Occuprs;
            Occupstatement = OccupdbConnection.prepareStatement("Select a.*,b.* from RiskExaminations a, Examinations b where a.examinationId=b.id and a.riskId in (" + risksArray + ")");
            double personalFrequency, personalTolerance, freq, tol, riskExaminationId, age;
            String ageGenderControl, nl, fr, var;
            PreparedStatement Occupstatement2;
            RiskProfileExaminationVO riskProfileExaminationVO;
            for (Occuprs = Occupstatement.executeQuery(); Occuprs.next();) {
                personalFrequency = Occuprs.getDouble("frequency");
                personalTolerance = Occuprs.getDouble("tolerance");
                freq = personalFrequency;
                tol = personalTolerance;
                riskExaminationId = Occuprs.getInt("riskExaminationId");
                ageGenderControl = Occuprs.getString("ageGenderControl");
                if (ageGenderControl != null && ageGenderControl.equals("1")) {
                    age = (Integer.parseInt(sessionContainerWO.getFlags().getAge()));
                    Occupstatement2 = OccupdbConnection.prepareStatement("select * from AgeGenderControl where type='RiskExaminations' and id=?");
                    Occupstatement2.setDouble(1, riskExaminationId);
                    ResultSet Occuprs2=null;
                    for (Occuprs2 = Occupstatement2.executeQuery(); Occuprs2.next();){
                        if (Occuprs2.getDouble("minAge") <= age && Occuprs2.getDouble("maxAge") >= age && Occuprs2.getString("gender").indexOf(sessionContainerWO.getPersonVO().getGender()) >= 0) {
                            personalFrequency = Occuprs2.getDouble("frequency");
                            personalTolerance = Occuprs2.getDouble("tolerance");
                        }
                    }
                    Occuprs2.close();
                    Occupstatement2.close();
                }
                nl = Occuprs.getString("NL");
                fr = Occuprs.getString("FR");
//                var = "";
                if (userLanguage.equals("NL")) {
                    var = nl;
                } else {
                    var = fr;
                }
                riskProfileExaminationVO = new RiskProfileExaminationVO(new Integer(Occuprs.getInt("id")), var, new Integer(Occuprs.getInt("priority")), Occuprs.getBytes("data"), freq, tol, personalFrequency, personalTolerance, "be.dpms.medwan.common.model.IConstants.PERSONAL_EXAMINATION", new Integer(be.dpms.medwan.common.model.IConstants.RISK_PROFILE_ITEM__STATUS_ADDED), Occuprs.getString("transactionType"), nl, fr, sessionContainerWO.getUserVO().getPersonVO().getLanguage());
                addRiskProfileExamination(personalRiskExaminations, riskProfileExaminationVO);
            }
            Occuprs.close();
            boolean exists, modified;
            double frequency, tolerance;
            RiskProfileExaminationVO systemExaminationVO;
            Iterator iterator;
            String sQuery;
            for (Enumeration elements = updatedExaminations.elements(); elements.hasMoreElements();) {
                riskProfileExaminationVO = (RiskProfileExaminationVO) elements.nextElement();
                exists = false;
                modified = false;
                frequency = riskProfileExaminationVO.getPersonalFrequency();
                tolerance = riskProfileExaminationVO.getPersonalTolerance();
                //Eerst verifiëren tegen de reeds bestaand systeemOnderzoeken
                for (iterator = sessionContainerWO.getRiskProfileVO().getSystemRiskProfileExaminationsVO().iterator(); iterator.hasNext();) {
                    systemExaminationVO = (RiskProfileExaminationVO) iterator.next();
                    if (riskProfileExaminationVO.getId().equals(systemExaminationVO.getId())) {
                        exists = true;
                        if (exists) {
                            if (riskProfileExaminationVO.getPersonalFrequency() > 0 && riskProfileExaminationVO.getPersonalFrequency() != riskProfileExaminationVO.getDefaultFrequency()) {
                                modified = true;
                                frequency = riskProfileExaminationVO.getPersonalFrequency();
                            }
                            if (riskProfileExaminationVO.getPersonalTolerance() != riskProfileExaminationVO.getDefaultTolerance()) {
                                modified = true;
                                tolerance = riskProfileExaminationVO.getPersonalTolerance();
                            }
                        }
                        break;
                    }
                }
                //Maar nu ook nog verifiëren tegen de bestaande persoonlijke onderzoeken op basis van persoonlijke risico's
                for (iterator = personalRiskExaminations.iterator(); iterator.hasNext();) {
                    systemExaminationVO = (RiskProfileExaminationVO) iterator.next();
                    if (riskProfileExaminationVO.getId().equals(systemExaminationVO.getId())) {
                        exists = true;
                        if (exists) {
                            if (riskProfileExaminationVO.getPersonalFrequency() > 0 && riskProfileExaminationVO.getPersonalFrequency() != riskProfileExaminationVO.getDefaultFrequency()) {
                                modified = true;
                                frequency = riskProfileExaminationVO.getPersonalFrequency();
                            }
                            if (riskProfileExaminationVO.getPersonalTolerance() != riskProfileExaminationVO.getDefaultTolerance()) {
                                modified = true;
                                tolerance = riskProfileExaminationVO.getPersonalTolerance();
                            }
                        }
                        break;
                    }
                }
                if (!exists) {
                    sQuery = "insert into RiskProfileItems(profileItemId,itemType,itemId,status,comment,profileId,frequency,tolerance,ageGenderControl) values(?,'be.dpms.medwan.common.model.IConstants.PERSONAL_EXAMINATION',?,1,null,?,?,?,null)";
                    Occupstatement = OccupdbConnection.prepareStatement(sQuery);
                    Occupstatement.setInt(1, getOpenclinicCounter("RiskProfileItemID"));
                    Occupstatement.setInt(2, riskProfileExaminationVO.getId().intValue());
                    Occupstatement.setInt(3, newProfileId);
                    Occupstatement.setDouble(4, frequency);
                    Occupstatement.setDouble(5, tolerance);
                    Occupstatement.execute();
                    Occupstatement.close();
                } else if (modified) {
                    sQuery = "insert into RiskProfileItems(profileItemId,itemType,itemId,status,comment,profileId,frequency,tolerance,ageGenderControl) values(?,'be.dpms.medwan.common.model.IConstants.SYSTEM_EXAMINATION',?,1,null,?,?,?,null)";
                    if (Debug.enabled) Debug.println(sQuery);
                    Occupstatement = OccupdbConnection.prepareStatement(sQuery);
                    Occupstatement.setInt(1, getOpenclinicCounter("RiskProfileItemID"));
                    Occupstatement.setInt(2, riskProfileExaminationVO.getId().intValue());
                    Occupstatement.setInt(3, newProfileId);
                    Occupstatement.setDouble(4, frequency);
                    Occupstatement.setDouble(5, tolerance);
                    Occupstatement.execute();
                    Occupstatement.close();
                }
            }
            boolean removed;
            for (iterator = sessionContainerWO.getRiskProfileVO().getSystemRiskProfileExaminationsVO().iterator(); iterator.hasNext();) {
                removed = true;
                systemExaminationVO = (RiskProfileExaminationVO) iterator.next();
                for (Enumeration elements = updatedExaminations.elements(); elements.hasMoreElements();) {
                    riskProfileExaminationVO = (RiskProfileExaminationVO) elements.nextElement();
                    if (systemExaminationVO.getId().equals(riskProfileExaminationVO.getId())) {
                        removed = false;
                        break;
                    }
                }
                if (removed) {
                    Occupstatement = OccupdbConnection.prepareStatement("insert into RiskProfileItems(profileItemId,itemType,itemId,status,comment,profileId,frequency,tolerance,ageGenderControl) values(?,'be.dpms.medwan.common.model.IConstants.SYSTEM_EXAMINATION',?,-1,null,?,null,null,null)");
                    Occupstatement.setInt(1, getOpenclinicCounter("RiskProfileItemID"));
                    Occupstatement.setInt(2, systemExaminationVO.getId().intValue());
                    Occupstatement.setInt(3, newProfileId);
                    Occupstatement.execute();
                    Occupstatement.close();
                }
            }
            Enumeration elements;
            for (iterator = personalRiskExaminations.iterator(); iterator.hasNext();) {
                removed = true;
                systemExaminationVO = (RiskProfileExaminationVO) iterator.next();
                for (elements = updatedExaminations.elements(); elements.hasMoreElements();) {
                    riskProfileExaminationVO = (RiskProfileExaminationVO) elements.nextElement();
                    if (systemExaminationVO.getId().equals(riskProfileExaminationVO.getId())) {
                        removed = false;
                        break;
                    }
                }
                if (removed) {
                    Occupstatement = OccupdbConnection.prepareStatement("insert into RiskProfileItems(profileItemId,itemType,itemId,status,comment,profileId,frequency,tolerance,ageGenderControl) values(?,'be.dpms.medwan.common.model.IConstants.PERSONAL_EXAMINATION',?,-1,null,?,null,null,null)");
                    Occupstatement.setInt(1, getOpenclinicCounter("RiskProfileItemID"));
                    Occupstatement.setInt(2, systemExaminationVO.getId().intValue());
                    Occupstatement.setInt(3, newProfileId);
                    Occupstatement.execute();
                    Occupstatement.close();
                }
            }
            Occupstatement.close();
            OccupdbConnection.close();

        } catch (Exception e) {
            e.printStackTrace();
        }
        return getRiskProfileVO(new Long(personId), sessionContainerWO);
    }
    public RiskProfileVO getRiskProfileVO(Long personId, SessionContainerWO sessionContainerWO) {
        String userLanguage;
        Date profileBegin = null;
        Integer profileId = null;
        Vector riskProfileContexts = new Vector();
        Vector riskProfileItems = new Vector();
        Vector riskProfileExaminations = new Vector();
        Vector riskCodes = new Vector();
        Vector systemRiskProfileExaminationsVO = new Vector();
        Vector systemRiskProfileRiskCodesVO = new Vector();
        Vector personalRiskProfileExaminationsVO = new Vector();
        Vector personalRiskProfileRiskCodesVO = new Vector();
        Vector riskProfileWorkplaces = new Vector();
        Vector riskProfileFunctionCategories = new Vector();
        Vector riskProfileFunctionGroups = new Vector();
        RiskProfileLabAnalysisVO riskProfileLabAnalysisVO = new RiskProfileLabAnalysisVO();
        RiskProfileVO riskProfileVO;
        Connection OccupdbConnection;
        try {
            OccupdbConnection = getOpenclinicConnection();
            if (sessionContainerWO.getUserVO().getPersonVO().getLanguage().equalsIgnoreCase("N")) {
                userLanguage = "NL";
            } else {
                userLanguage = "FR";
            }
            PreparedStatement Occupstatement = OccupdbConnection.prepareStatement("SELECT * from RiskProfiles where dateEnd is null and personId=?");
            Occupstatement.setInt(1, personId.intValue());
            ResultSet Occuprs = Occupstatement.executeQuery();
            if (Occuprs.next()) {
                // Laden van het systeemprofiel
                profileBegin = new Date(Occuprs.getDate("dateBegin").getTime());
                profileId = new Integer(Occuprs.getInt("profileId"));
                Occupstatement = OccupdbConnection.prepareStatement("select * from RiskProfileContexts where profileId=?");
                Occupstatement.setInt(1, profileId.intValue());
                String itemType, ageGenderControl, nl, fr, var, examinationType;
                int itemId, profileContextId,  functionGroupExaminationId, age,  riskId, iageGenderControl;
                double frequency, tolerance,personalFrequency, personalTolerance;
                PreparedStatement Occupstatement2, Occupstatement3;
                ResultSet Occuprs2, Occuprs3;
                RiskProfileRiskCodeVO riskProfileRiskCodeVO;
                RiskProfileExaminationVO riskProfileExaminationVO;
                Iterator iterator;
                Integer iexaminationStatus;
                Occuprs.close();
                Occupstatement.close();
                for (Occuprs = Occupstatement.executeQuery(); Occuprs.next();) {
                    itemType = Occuprs.getString("itemType");
                    itemId = Occuprs.getInt("itemId");
                    profileContextId = Occuprs.getInt("profileContextId");
                    riskProfileContexts.add(new RiskProfileContextVO(itemType, new Integer(itemId), new Integer(profileContextId)));

                    // systeemprofiel - FUNCTION CATEGORY
                    if (itemType.equals("be.dpms.medwan.common.model.IConstants.FUNCTION_CATEGORY")) {
                        Occupstatement2 = OccupdbConnection.prepareStatement("select * from FunctionCategories where id=?");
                        Occupstatement2.setInt(1, itemId);
                        Occuprs2 = Occupstatement2.executeQuery();
                        if (Occuprs2.next()) {
                            FunctionCategoryWithRiskCodesVO functionCategory = new FunctionCategoryWithRiskCodesVO(new Integer(itemId), Occuprs2.getString(userLanguage), new Vector());
                            riskProfileFunctionCategories.add(functionCategory);
                            Occuprs2.close();
                            Occupstatement2.close();
                            Occupstatement2 = OccupdbConnection.prepareStatement("select b.* from FunctionCategoryRisks a,RiskCodes b where a.riskId=b.id and a.functionCategoryId=?");
                            Occupstatement2.setInt(1, itemId);
                            for (Occuprs2 = Occupstatement2.executeQuery(); Occuprs2.next(); addRiskProfileRisk(riskCodes, riskProfileRiskCodeVO)) {
                                riskProfileRiskCodeVO = new RiskProfileRiskCodeVO(new Integer(Occuprs2.getInt("id")), Occuprs2.getString("code"), Occuprs2.getString(userLanguage), "be.dpms.medwan.common.model.IConstants.SYSTEM_RISK", new Integer(0));
                                functionCategory.getRiskCodeVO().add(riskProfileRiskCodeVO);
                            }
                            Occuprs2.close();
                            Occupstatement2.close();
                        }
                        else{
	                        Occuprs2.close();
	                        Occupstatement2.close();
                        }
                    }
                    // systeemprofiel - FUNCTION GROUP
                    else if (itemType.equals("be.dpms.medwan.common.model.IConstants.FUNCTION_GROUP")) {
                        Occupstatement2 = OccupdbConnection.prepareStatement("select * from FunctionGroups where id=?");
                        Occupstatement2.setInt(1, itemId);
                        Occuprs2 = Occupstatement2.executeQuery();
                        if (Occuprs2.next()) {
                            riskProfileFunctionGroups.add(new FunctionGroupVO(new Integer(itemId), Occuprs2.getString(userLanguage), Occuprs2.getString("serviceId")));
                            Occuprs2.close();
                            Occupstatement2.close();
                            Occupstatement2 = OccupdbConnection.prepareStatement("select a.functionGroupExaminationId as functionGroupExaminationId, b.id, b.NL, b.FR, b.priority, b.data, a.frequency, a.tolerance,b.transactionType,a.ageGenderControl from FunctionGroupExaminations a, Examinations b where a.examinationId=b.id and contactTypeId>1 and functionGroupId=?");
                            Occupstatement2.setInt(1, itemId);
                            for (Occuprs2 = Occupstatement2.executeQuery(); Occuprs2.next(); addRiskProfileExamination(riskProfileExaminations, riskProfileExaminationVO)) {
                                frequency = Occuprs2.getInt("frequency");
                                tolerance = Occuprs2.getInt("tolerance");
                                ageGenderControl = Occuprs2.getString("ageGenderControl");
                                functionGroupExaminationId = Occuprs2.getInt("functionGroupExaminationId");
                                if (ageGenderControl != null && ageGenderControl.equals("1")) {
                                    age = Integer.parseInt(sessionContainerWO.getFlags().getAge());
                                    Occupstatement3 = OccupdbConnection.prepareStatement("select * from AgeGenderControl where type='FunctionGroupExaminations' and id=?");
                                    Occupstatement3.setInt(1, functionGroupExaminationId);
                                    for (Occuprs3 = Occupstatement3.executeQuery(); Occuprs3.next();)
                                        if (Occuprs3.getDouble("minAge") <= age && Occuprs3.getDouble("maxAge") >= age && Occuprs3.getString("gender").indexOf(sessionContainerWO.getPersonVO().getGender()) >= 0) {
                                            frequency = Occuprs3.getDouble("frequency");
                                            tolerance = Occuprs3.getDouble("tolerance");
                                        }
                                }
                                nl = Occuprs2.getString("NL");
                                fr = Occuprs2.getString("FR");
                                if (userLanguage.equals("NL")) var = nl;
                                else var = fr;
                                riskProfileExaminationVO = new RiskProfileExaminationVO(new Integer(Occuprs2.getInt("id")), var, new Integer(Occuprs2.getInt("priority")), Occuprs2.getBytes("data"), frequency, tolerance, frequency, tolerance, "be.dpms.medwan.common.model.IConstants.SYSTEM_EXAMINATION", new Integer(0), Occuprs2.getString("transactionType"), nl, fr, sessionContainerWO.getUserVO().personVO.language);
                            }
                            Occuprs2.close();
                            Occupstatement2.close();
                        }
                        else{
                            Occuprs2.close();
                            Occupstatement2.close();
                        }
                    }
                    // systeemprofiel - WORKPLACE
                    else if (itemType.equals("be.dpms.medwan.common.model.IConstants.WORKPLACE")) {
                        Occupstatement2 = OccupdbConnection.prepareStatement("select * from Workplaces where id=?");
                        Occupstatement2.setInt(1, itemId);
                        Occuprs2 = Occupstatement2.executeQuery();
                        if (Occuprs2.next()) {
                            WorkplaceWithRiskCodesVO workplace = new WorkplaceWithRiskCodesVO(new Integer(itemId), Occuprs2.getString(userLanguage), new Vector());
                            riskProfileWorkplaces.add(workplace);
                            Occuprs2.close();
                            Occupstatement2.close();
                            Occupstatement2 = OccupdbConnection.prepareStatement("select b.* from WorkplaceRisks a,RiskCodes b where a.riskId=b.id and a.workplaceId=? and a.active=1");
                            Occupstatement2.setInt(1, itemId);
                            for (Occuprs2 = Occupstatement2.executeQuery(); Occuprs2.next(); addRiskProfileRisk(riskCodes, riskProfileRiskCodeVO)) {
                                riskProfileRiskCodeVO = new RiskProfileRiskCodeVO(new Integer(Occuprs2.getInt("id")), Occuprs2.getString("code"), Occuprs2.getString(userLanguage), "be.dpms.medwan.common.model.IConstants.SYSTEM_RISK", new Integer(0));
                                workplace.getRiskCodeVO().add(riskProfileRiskCodeVO);
                            }
                            Occuprs2.close();
                            Occupstatement2.close();
                        }
                        else {
                            Occuprs2.close();
                            Occupstatement2.close();
                        }
                    }
                }
                Occuprs.close();
                Occupstatement.close();

                // Laden van de onderzoeken die gepaard gaan met de systeemRisico's
                // Eerst kijken welke systeemRisico's verwijderd werden
                Occupstatement = OccupdbConnection.prepareStatement("select a.status,a.itemType , b.* from RiskProfileItems a,RiskCodes b where a.itemId=b.id and (a.itemType='be.dpms.medwan.common.model.IConstants.PERSONAL_RISK' or a.itemType='be.dpms.medwan.common.model.IConstants.SYSTEM_RISK') and a.status=-1 and a.profileId=?");
                Occupstatement.setInt(1, profileId.intValue());
                Occuprs = Occupstatement.executeQuery();
                String deletedRisksArray = "0";
                while (Occuprs.next()) {
                    deletedRisksArray = deletedRisksArray + "," + Occuprs.getString("id");
                }
                Occuprs.close();
                Occupstatement.close();
                
                String risksArray = "0";
                for (iterator = riskCodes.iterator(); iterator.hasNext();) {
                    riskProfileRiskCodeVO = (RiskProfileRiskCodeVO) iterator.next();
                    if (!riskProfileRiskCodeVO.getStatus().equals(new Integer(-1)))
                        risksArray = risksArray + "," + riskProfileRiskCodeVO.getRiskCodeId();
                }
                Occupstatement = OccupdbConnection.prepareStatement("Select * from RiskExaminations a, Examinations b where a.examinationId=b.id and a.riskId in (" + risksArray + ") and a.riskId not in (" + deletedRisksArray + ")");
                for (Occuprs = Occupstatement.executeQuery(); Occuprs.next(); addRiskProfileExamination(riskProfileExaminations, riskProfileExaminationVO)) {
                    int riskExaminationId = Occuprs.getInt("riskExaminationId");
                    personalFrequency = Occuprs.getInt("frequency");
                    personalTolerance = Occuprs.getInt("tolerance");
                    frequency = personalFrequency;
                    tolerance = personalTolerance;
                    ageGenderControl = Occuprs.getString("ageGenderControl");
                    if (ageGenderControl != null && ageGenderControl.equals("1")) {
                        age = Integer.parseInt(sessionContainerWO.getFlags().getAge());
                        Occupstatement2 = OccupdbConnection.prepareStatement("select * from AgeGenderControl where type='RiskExaminations' and id=?");
                        Occupstatement2.setInt(1, Occuprs.getInt("riskExaminationId"));
                        for (Occuprs2 = Occupstatement2.executeQuery(); Occuprs2.next();){
                            if (Occuprs2.getDouble("minAge") <= age && Occuprs2.getDouble("maxAge") >= age && Occuprs2.getString("gender").indexOf(sessionContainerWO.getPersonVO().getGender()) >= 0) {
                                personalFrequency = Occuprs2.getDouble("frequency");
                                personalTolerance = Occuprs2.getDouble("tolerance");
                            }
                        }
                        Occuprs2.close();
                        Occupstatement2.close();
                    }
                    nl = Occuprs.getString("NL");
                    fr = Occuprs.getString("FR");
                    if (userLanguage.equals("NL")) var = nl;
                    else var = fr;
                    riskProfileExaminationVO = new RiskProfileExaminationVO(new Integer(Occuprs.getInt("id")), var, new Integer(Occuprs.getInt("priority")), Occuprs.getBytes("data"), frequency, tolerance, personalFrequency, personalTolerance, "be.dpms.medwan.common.model.IConstants.SYSTEM_EXAMINATION", new Integer(0), Occuprs.getString("transactionType"), nl, fr, sessionContainerWO.getUserVO().personVO.language);

                    // Laden van labcodes die gepaard gaan met dit onderzoek voor dit risico (op basis van riskExaminationId)
                    Vector labcodes = getRiskExaminationLabcodes(riskExaminationId);
                    if (labcodes != null) {
                        LabAnalysisVO labAnalysisVO;
                        ItemVO itemVO;
                        MessageReader messageReader;
                        String type;
                        double extraTime;
                        for (int n = 0; n < labcodes.size(); n++) {
                            labAnalysisVO = (LabAnalysisVO) labcodes.elementAt(n);
                            itemVO = getLastItemVO(sessionContainerWO.getHealthRecordVO().getHealthRecordId().toString(), "be.mxs.common.model.vo.healthrecord.IConstants.EXT_MEDIDOC_" + labAnalysisVO.getMedidocCode());
                            labAnalysisVO.setNextDate(new java.util.Date());
                            if (itemVO != null) {
                                messageReader = new MessageReaderMedidoc();
                                messageReader.lastline = itemVO.getValue();
                                type = messageReader.readField("|");
                                if (type.equalsIgnoreCase("N") || type.equalsIgnoreCase("D") || type.equalsIgnoreCase("H") || type.equalsIgnoreCase("M") || type.equalsIgnoreCase("S")) {
                                    messageReader.readField("|");
                                    labAnalysisVO.setLastVal(messageReader.readField("|"));
                                    labAnalysisVO.setLastDate(itemVO.getDate());
                                    extraTime = (personalFrequency - personalTolerance) * 24 * 60;
                                    extraTime *= 365 * 60000 / 12;
                                    labAnalysisVO.setNextDate(new java.util.Date(itemVO.getDate().getTime() + new Double(extraTime).longValue()));
                                }
                            }
                            riskProfileLabAnalysisVO.addAnalysis(labAnalysisVO);
                        }
                    }
                }
                Occuprs.close();
                Occupstatement.close();
                systemRiskProfileExaminationsVO = (Vector) riskProfileExaminations.clone();
                systemRiskProfileRiskCodesVO = (Vector) riskCodes.clone();

                // Laden van de persoonlijke risico's
                Occupstatement = OccupdbConnection.prepareStatement("select a.status,a.itemType , b.* from RiskProfileItems a,RiskCodes b where a.itemId=b.id and (a.itemType='be.dpms.medwan.common.model.IConstants.PERSONAL_RISK' or a.itemType='be.dpms.medwan.common.model.IConstants.SYSTEM_RISK') and a.profileId=?");
                Occupstatement.setInt(1, profileId.intValue());
                Occuprs = Occupstatement.executeQuery();
                for (risksArray = "0"; Occuprs.next(); risksArray = risksArray + "," + riskProfileRiskCodeVO.getRiskCodeId()) {
                    riskProfileRiskCodeVO = new RiskProfileRiskCodeVO(new Integer(Occuprs.getInt("id")), Occuprs.getString("code"), Occuprs.getString(userLanguage), Occuprs.getString("itemType"), new Integer(Occuprs.getInt("status")));
                    addRiskProfileRisk(riskCodes, riskProfileRiskCodeVO);
                    addRiskProfileRisk(personalRiskProfileRiskCodesVO, riskProfileRiskCodeVO);
                }
                Occuprs.close();
                Occupstatement.close();

                // Laden van de onderzoeken die gepaard gaan met de persoonlijke risico's
                int riskExaminationId;
                Occupstatement = OccupdbConnection.prepareStatement("Select a.*,b.* from RiskExaminations a, Examinations b where a.examinationId=b.id and a.active=1 and a.riskId in (" + risksArray + ") and a.riskId not in (" + deletedRisksArray + ")");
                for (Occuprs = Occupstatement.executeQuery(); Occuprs.next(); addRiskProfileExamination(personalRiskProfileExaminationsVO, riskProfileExaminationVO)) {
                    personalFrequency = Occuprs.getInt("frequency");
                    personalTolerance = Occuprs.getInt("tolerance");
                    frequency = personalFrequency;
                    tolerance = personalTolerance;
                    ageGenderControl = Occuprs.getString("ageGenderControl");
                    riskId = Occuprs.getInt("riskId");
                    riskExaminationId = Occuprs.getInt("riskExaminationId");
                    if (ageGenderControl != null && ageGenderControl.equals("1")) {
                        age = Integer.parseInt(sessionContainerWO.getFlags().getAge());
                        Occupstatement2 = OccupdbConnection.prepareStatement("select * from AgeGenderControl where type='RiskExaminations' and id=?");
                        Occupstatement2.setInt(1, riskExaminationId);
                        for (Occuprs2 = Occupstatement2.executeQuery(); Occuprs2.next();) {
                            if (Occuprs2.getDouble("minAge") <= age && Occuprs2.getDouble("maxAge") >= age && Occuprs2.getString("gender").indexOf(sessionContainerWO.getPersonVO().getGender()) >= 0) {
                                personalFrequency = Occuprs2.getDouble("frequency");
                                personalTolerance = Occuprs2.getDouble("tolerance");
                            }
                        }
                        Occuprs2.close();
                        Occupstatement2.close();
                    }
                    examinationType = null;
                    iexaminationStatus = null;
                    for (iterator = riskCodes.iterator(); iterator.hasNext();) {
                        riskProfileRiskCodeVO = (RiskProfileRiskCodeVO) iterator.next();
                        if (riskProfileRiskCodeVO.getRiskCodeId().intValue() == riskId) {
                            if (riskProfileRiskCodeVO.getType().equals("be.dpms.medwan.common.model.IConstants.PERSONAL_RISK")) {
                                examinationType = "be.dpms.medwan.common.model.IConstants.PERSONAL_EXAMINATION";
                            } else {
                                examinationType = "be.dpms.medwan.common.model.IConstants.SYSTEM_EXAMINATION";
                            }
                            iexaminationStatus = riskProfileRiskCodeVO.getStatus();
                        }
                    }
                    nl = Occuprs.getString("NL");
                    fr = Occuprs.getString("FR");
                    if (userLanguage.equals("NL")) var = nl;
                    else var = fr;
                    riskProfileExaminationVO = new RiskProfileExaminationVO(new Integer(Occuprs.getInt("id")), var, new Integer(Occuprs.getInt("priority")), Occuprs.getBytes("data"), frequency, tolerance, personalFrequency, personalTolerance, examinationType, iexaminationStatus, Occuprs.getString("transactionType"), nl, fr, sessionContainerWO.getUserVO().personVO.language);
                    addRiskProfileExamination(riskProfileExaminations, riskProfileExaminationVO);

                    // Laden van labcodes die gepaard gaan met dit onderzoek voor dit risico (op basis van riskExaminationId)
                    Vector labcodes = getRiskExaminationLabcodes(riskExaminationId);
                    if (labcodes != null) {
                        LabAnalysisVO labAnalysisVO;
                        ItemVO itemVO;
                        MessageReader messageReader;
                        String type;
                        double extraTime;
                        for (int n = 0; n < labcodes.size(); n++) {
                            labAnalysisVO = (LabAnalysisVO) labcodes.elementAt(n);
                            itemVO = getLastItemVO(sessionContainerWO.getHealthRecordVO().getHealthRecordId().toString(), "be.mxs.common.model.vo.healthrecord.IConstants.EXT_MEDIDOC_" + labAnalysisVO.getMedidocCode());
                            labAnalysisVO.setNextDate(new java.util.Date());
                            if (itemVO != null) {
                                messageReader = new MessageReaderMedidoc();
                                messageReader.lastline = itemVO.getValue();
                                type = messageReader.readField("|");
                                if (type.equalsIgnoreCase("N") || type.equalsIgnoreCase("D") || type.equalsIgnoreCase("H") || type.equalsIgnoreCase("M") || type.equalsIgnoreCase("S")) {
                                    messageReader.readField("|");
                                    labAnalysisVO.setLastVal(messageReader.readField("|"));
                                    labAnalysisVO.setLastDate(itemVO.getDate());
                                    extraTime = (personalFrequency - personalTolerance) * 24 * 60;
                                    extraTime *= 365 * 60000 / 12;
                                    labAnalysisVO.setNextDate(new java.util.Date(itemVO.getDate().getTime() + new Double(extraTime).longValue()));
                                }
                            }
                            riskProfileLabAnalysisVO.addAnalysis(labAnalysisVO);
                        }
                    }
                }
                Occuprs.close();
                Occupstatement.close();

                // Laden van de persoonlijke onderzoeken
                Occupstatement = OccupdbConnection.prepareStatement("select a.*,b.* from RiskProfileItems a,Examinations b where a.itemId=b.id and (a.itemType='be.dpms.medwan.common.model.IConstants.PERSONAL_EXAMINATION' or a.itemType='be.dpms.medwan.common.model.IConstants.SYSTEM_EXAMINATION') and a.profileId=?");
                Occupstatement.setInt(1, profileId.intValue());
                for (Occuprs = Occupstatement.executeQuery(); Occuprs.next(); addRiskProfileExamination(personalRiskProfileExaminationsVO, riskProfileExaminationVO)) {
                    personalFrequency = Occuprs.getInt("frequency");
                    personalTolerance = Occuprs.getInt("tolerance");
                    frequency = 0;
                    tolerance = 0;
                    iageGenderControl = Occuprs.getInt("ageGenderControl");
                    if (iageGenderControl == 1) {
                        age = Integer.parseInt(sessionContainerWO.getFlags().getAge());
                        Occupstatement2 = OccupdbConnection.prepareStatement("select * from AgeGenderControl where type='RiskExaminations' and id=?");
                        Occupstatement2.setInt(1, Occuprs.getInt("riskExaminationId"));
                        for (Occuprs2 = Occupstatement2.executeQuery(); Occuprs2.next();) {
                            if (Occuprs2.getDouble("minAge") <= age && Occuprs2.getDouble("maxAge") >= age && Occuprs2.getString("gender").indexOf(sessionContainerWO.getPersonVO().getGender()) >= 0) {
                                personalFrequency = Occuprs2.getDouble("frequency");
                                personalTolerance = Occuprs2.getDouble("tolerance");
                            }
                        }
                        Occuprs2.close();
                        Occupstatement2.close();
                    }
                    nl = Occuprs.getString("NL");
                    fr = Occuprs.getString("FR");
                    if (userLanguage.equals("NL")) var = nl;
                    else var = fr;
                    riskProfileExaminationVO = new RiskProfileExaminationVO(new Integer(Occuprs.getInt("id")), var, new Integer(Occuprs.getInt("priority")), Occuprs.getBytes("data"), frequency, tolerance, personalFrequency, personalTolerance, Occuprs.getString("itemType"), new Integer(Occuprs.getInt("status")), Occuprs.getString("transactionType"), nl, fr, sessionContainerWO.getUserVO().personVO.language);
                    addForcedRiskProfileExamination(riskProfileExaminations, riskProfileExaminationVO);
                }
                pushRiskProfileExaminationParameters(riskProfileExaminations, "be.mxs.common.model.vo.healthrecord.IConstants.TRANSACTION_TYPE_DLC", "be.mxs.common.model.vo.healthrecord.IConstants.TRANSACTION_TYPE_DRIVING_LICENCE_DECLARATION");
                Occuprs.close();
                Occupstatement.close();
            }
            if (Occuprs!=null) Occuprs.close();
            if (Occupstatement!=null) Occupstatement.close();
            OccupdbConnection.close();

        }
        catch (Exception e) {
            e.printStackTrace();
        }
        riskProfileVO = new RiskProfileVO(profileBegin, null, personId, profileId, riskProfileContexts, riskProfileItems, riskProfileExaminations, riskCodes, systemRiskProfileExaminationsVO, systemRiskProfileRiskCodesVO, personalRiskProfileExaminationsVO, personalRiskProfileRiskCodesVO, riskProfileWorkplaces, riskProfileFunctionCategories, riskProfileFunctionGroups);
        riskProfileVO.setRiskProfileLabAnalysisVO(riskProfileLabAnalysisVO);
        return riskProfileVO;
    }
    public RiskProfileVO getRiskProfileVOExport(Long personId) {
        Date profileBegin = new Date();
        Integer profileId = null;
        Vector riskProfileContexts = new Vector();
        Vector riskProfileItems = new Vector();
        Vector riskProfileExaminations = new Vector();
        Vector riskCodes = new Vector();
        Vector systemRiskProfileExaminationsVO = new Vector();
        Vector systemRiskProfileRiskCodesVO = new Vector();
        Vector personalRiskProfileExaminationsVO = new Vector();
        Vector personalRiskProfileRiskCodesVO = new Vector();
        Vector riskProfileWorkplaces = new Vector();
        Vector riskProfileFunctionCategories = new Vector();
        Vector riskProfileFunctionGroups = new Vector();
        RiskProfileLabAnalysisVO riskProfileLabAnalysisVO = new RiskProfileLabAnalysisVO();
        RiskProfileVO riskProfileVO;
        Connection OccupdbConnection;
        try {
            OccupdbConnection = getOpenclinicConnection();
            PreparedStatement Occupstatement = OccupdbConnection.prepareStatement("SELECT * from RiskProfiles where dateEnd is null and personId=?");
            Occupstatement.setInt(1, personId.intValue());
            ResultSet Occuprs = Occupstatement.executeQuery();
            if (Occuprs.next()) {
                //Laden van het systeemprofiel
                profileBegin = new Date(Occuprs.getDate("dateBegin").getTime());
                profileId = new Integer(Occuprs.getInt("profileId"));
                Occuprs.close();
                Occupstatement.close();
                Occupstatement = OccupdbConnection.prepareStatement("select * from RiskProfileContexts where profileId=?");
                Occupstatement.setInt(1, profileId.intValue());
                String itemType, var, examinationType;
                int itemId, profileContextId, frequency, tolerance, personalFrequency, personalTolerance, riskId;
                PreparedStatement Occupstatement2;
                ResultSet Occuprs2;
                RiskProfileRiskCodeVO riskProfileRiskCodeVO;
                RiskProfileExaminationVO riskProfileExaminationVO;
                Iterator iterator;
                Integer iexaminationStatus;
                for (Occuprs = Occupstatement.executeQuery(); Occuprs.next();) {
                    itemType = Occuprs.getString("itemType");
                    itemId = Occuprs.getInt("itemId");
                    profileContextId = Occuprs.getInt("profileContextId");
                    riskProfileContexts.add(new RiskProfileContextVO(itemType, new Integer(itemId), new Integer(profileContextId)));
                    if (itemType.equals("be.dpms.medwan.common.model.IConstants.FUNCTION_CATEGORY")) {
                        Occupstatement2 = OccupdbConnection.prepareStatement("select * from FunctionCategories where id=?");
                        Occupstatement2.setInt(1, itemId);
                        Occuprs2 = Occupstatement2.executeQuery();
                        if (Occuprs2.next()) {
                            riskProfileFunctionCategories.add(new FunctionCategoryWithRiskCodesVO(new Integer(itemId), "NL", new Vector()));
                            Occupstatement2 = OccupdbConnection.prepareStatement("select b.* from FunctionCategoryRisks a,RiskCodes b where a.riskId=b.id and a.functionCategoryId=?");
                            Occupstatement2.setInt(1, itemId);
                            for (Occuprs2 = Occupstatement2.executeQuery(); Occuprs2.next(); addRiskProfileRisk(riskCodes, riskProfileRiskCodeVO)) {
                                riskProfileRiskCodeVO = new RiskProfileRiskCodeVO(new Integer(Occuprs2.getInt("id")), Occuprs2.getString("code"), "NL", "be.dpms.medwan.common.model.IConstants.SYSTEM_RISK", new Integer(0));
                            }
                        }
                        Occuprs2.close();
                        Occupstatement2.close();
                    } else if (itemType.equals("be.dpms.medwan.common.model.IConstants.FUNCTION_GROUP")) {
                        Occupstatement2 = OccupdbConnection.prepareStatement("select * from FunctionGroups where id=?");
                        Occupstatement2.setInt(1, itemId);
                        Occuprs2 = Occupstatement2.executeQuery();
                        if (Occuprs2.next()) {
                            riskProfileFunctionGroups.add(new FunctionGroupVO(new Integer(itemId), "NL", Occuprs2.getString("serviceId")));
                            Occupstatement2 = OccupdbConnection.prepareStatement("select a.functionGroupExaminationId as functionGroupExaminationId, b.id, b.NL, b.FR, b.priority, b.data, a.frequency, a.tolerance,b.transactionType,a.ageGenderControl from FunctionGroupExaminations a, Examinations b where a.examinationId=b.id and contactTypeId>1 and functionGroupId=?");
                            Occupstatement2.setInt(1, itemId);
                            for (Occuprs2 = Occupstatement2.executeQuery(); Occuprs2.next(); addRiskProfileExamination(riskProfileExaminations, riskProfileExaminationVO)) {
                                frequency = Occuprs2.getInt("frequency");
                                tolerance = Occuprs2.getInt("tolerance");
                                var = Occuprs2.getString("NL");
                                riskProfileExaminationVO = new RiskProfileExaminationVO(new Integer(Occuprs2.getInt("id")), var, new Integer(Occuprs2.getInt("priority")), Occuprs2.getBytes("data"), frequency, tolerance, frequency, tolerance, "be.dpms.medwan.common.model.IConstants.SYSTEM_EXAMINATION", new Integer(0), Occuprs2.getString("transactionType"), var, var, "N");
                            }
                        }
                        Occuprs2.close();
                        Occupstatement2.close();
                    } else if (itemType.equals("be.dpms.medwan.common.model.IConstants.WORKPLACE")) {
                        Occupstatement2 = OccupdbConnection.prepareStatement("select * from Workplaces where id=?");
                        Occupstatement2.setInt(1, itemId);
                        Occuprs2 = Occupstatement2.executeQuery();
                        if (Occuprs2.next()) {
                            riskProfileWorkplaces.add(new WorkplaceWithRiskCodesVO(new Integer(itemId), "NL", new Vector()));
                            Occupstatement2 = OccupdbConnection.prepareStatement("select b.* from WorkplaceRisks a,RiskCodes b where a.riskId=b.id and a.workplaceId=? and a.active=1");
                            Occupstatement2.setInt(1, itemId);
                            for (Occuprs2 = Occupstatement2.executeQuery(); Occuprs2.next(); addRiskProfileRisk(riskCodes, riskProfileRiskCodeVO))
                                riskProfileRiskCodeVO = new RiskProfileRiskCodeVO(new Integer(Occuprs2.getInt("id")), Occuprs2.getString("code"), "NL", "be.dpms.medwan.common.model.IConstants.SYSTEM_RISK", new Integer(0));
                        }
                        Occuprs2.close();
                        Occupstatement2.close();
                    }
                }
                Occuprs.close();
                Occupstatement.close();

                //Laden van de onderzoeken die gepaard gaan met de systeemRisico's
                //Eerst kijken welke systeemRisico's verwijderd werden
                Occupstatement = OccupdbConnection.prepareStatement("select a.status,a.itemType , b.* from RiskProfileItems a,RiskCodes b where a.itemId=b.id and (a.itemType='be.dpms.medwan.common.model.IConstants.PERSONAL_RISK' or a.itemType='be.dpms.medwan.common.model.IConstants.SYSTEM_RISK') and a.status=-1 and a.profileId=?");
                Occupstatement.setInt(1, profileId.intValue());
                Occuprs = Occupstatement.executeQuery();
                String deletedRisksArray = "0";
                while (Occuprs.next()) {
                    deletedRisksArray = deletedRisksArray + "," + Occuprs.getString("id");
                }
                Occuprs.close();
                Occupstatement.close();
                String risksArray = "0";
                for (iterator = riskCodes.iterator(); iterator.hasNext();) {
                    riskProfileRiskCodeVO = (RiskProfileRiskCodeVO) iterator.next();
                    if (!riskProfileRiskCodeVO.getStatus().equals(new Integer(-1)))
                        risksArray = risksArray + "," + riskProfileRiskCodeVO.getRiskCodeId();
                }
                Occupstatement = OccupdbConnection.prepareStatement("Select * from RiskExaminations a, Examinations b where a.examinationId=b.id and a.riskId in (" + risksArray + ") and a.riskId not in (" + deletedRisksArray + ")");
                for (Occuprs = Occupstatement.executeQuery(); Occuprs.next(); addRiskProfileExamination(riskProfileExaminations, riskProfileExaminationVO)) {
                    personalFrequency = Occuprs.getInt("frequency");
                    personalTolerance = Occuprs.getInt("tolerance");
                    frequency = personalFrequency;
                    tolerance = personalTolerance;
                    var = Occuprs.getString("NL");
                    riskProfileExaminationVO = new RiskProfileExaminationVO(new Integer(Occuprs.getInt("id")), var, new Integer(Occuprs.getInt("priority")), Occuprs.getBytes("data"), frequency, tolerance, personalFrequency, personalTolerance, "be.dpms.medwan.common.model.IConstants.SYSTEM_EXAMINATION", new Integer(0), Occuprs.getString("transactionType"), var, var, "N");
                }
                Occuprs.close();
                Occupstatement.close();
                systemRiskProfileExaminationsVO = (Vector) riskProfileExaminations.clone();
                systemRiskProfileRiskCodesVO = (Vector) riskCodes.clone();

                //Laden van de persoonlijke risico's
                Occupstatement = OccupdbConnection.prepareStatement("select a.status,a.itemType , b.* from RiskProfileItems a,RiskCodes b where a.itemId=b.id and (a.itemType='be.dpms.medwan.common.model.IConstants.PERSONAL_RISK' or a.itemType='be.dpms.medwan.common.model.IConstants.SYSTEM_RISK') and a.profileId=?");
                Occupstatement.setInt(1, profileId.intValue());
                Occuprs = Occupstatement.executeQuery();
                for (risksArray = "0"; Occuprs.next(); risksArray = risksArray + "," + riskProfileRiskCodeVO.getRiskCodeId()) {
                    riskProfileRiskCodeVO = new RiskProfileRiskCodeVO(new Integer(Occuprs.getInt("id")), Occuprs.getString("code"), "NL", Occuprs.getString("itemType"), new Integer(Occuprs.getInt("status")));
                    addRiskProfileRisk(riskCodes, riskProfileRiskCodeVO);
                    addRiskProfileRisk(personalRiskProfileRiskCodesVO, riskProfileRiskCodeVO);
                }
                Occuprs.close();
                Occupstatement.close();

                //Laden van de onderzoeken die gepaard gaan met de persoonlijke risico's
                Occupstatement = OccupdbConnection.prepareStatement("Select a.*,b.* from RiskExaminations a, Examinations b where a.examinationId=b.id and a.active=1 and a.riskId in (" + risksArray + ") and a.riskId not in (" + deletedRisksArray + ")");
                for (Occuprs = Occupstatement.executeQuery(); Occuprs.next(); addRiskProfileExamination(personalRiskProfileExaminationsVO, riskProfileExaminationVO)) {
                    personalFrequency = Occuprs.getInt("frequency");
                    personalTolerance = Occuprs.getInt("tolerance");
                    frequency = personalFrequency;
                    tolerance = personalTolerance;
                    riskId = Occuprs.getInt("riskId");
                    examinationType = null;
                    iexaminationStatus = null;
                    for (iterator = riskCodes.iterator(); iterator.hasNext();) {
                        riskProfileRiskCodeVO = (RiskProfileRiskCodeVO) iterator.next();
                        if (riskProfileRiskCodeVO.getRiskCodeId().intValue() == riskId) {
                            if (riskProfileRiskCodeVO.getType().equals("be.dpms.medwan.common.model.IConstants.PERSONAL_RISK"))
                                examinationType = "be.dpms.medwan.common.model.IConstants.PERSONAL_EXAMINATION";
                            else
                                examinationType = "be.dpms.medwan.common.model.IConstants.SYSTEM_EXAMINATION";
                            iexaminationStatus = riskProfileRiskCodeVO.getStatus();
                        }
                    }
                    var = Occuprs.getString("NL");
                    riskProfileExaminationVO = new RiskProfileExaminationVO(new Integer(Occuprs.getInt("id")), var, new Integer(Occuprs.getInt("priority")), Occuprs.getBytes("data"), frequency, tolerance, personalFrequency, personalTolerance, examinationType, iexaminationStatus, Occuprs.getString("transactionType"), var, var, "N");
                    addRiskProfileExamination(riskProfileExaminations, riskProfileExaminationVO);
                }
                Occuprs.close();
                Occupstatement.close();

                //Laden van de persoonlijke onderzoeken
                Occupstatement = OccupdbConnection.prepareStatement("select a.*,b.* from RiskProfileItems a,Examinations b where a.itemId=b.id and (a.itemType='be.dpms.medwan.common.model.IConstants.PERSONAL_EXAMINATION' or a.itemType='be.dpms.medwan.common.model.IConstants.SYSTEM_EXAMINATION') and a.profileId=?");
                Occupstatement.setInt(1, profileId.intValue());
                for (Occuprs = Occupstatement.executeQuery(); Occuprs.next(); addRiskProfileExamination(personalRiskProfileExaminationsVO, riskProfileExaminationVO)) {
                    personalFrequency = Occuprs.getInt("frequency");
                    personalTolerance = Occuprs.getInt("tolerance");
                    frequency = 0;
                    tolerance = 0;
                    var = Occuprs.getString("NL");
                    riskProfileExaminationVO = new RiskProfileExaminationVO(new Integer(Occuprs.getInt("id")), var, new Integer(Occuprs.getInt("priority")), Occuprs.getBytes("data"), frequency, tolerance, personalFrequency, personalTolerance, Occuprs.getString("itemType"), new Integer(Occuprs.getInt("status")), Occuprs.getString("transactionType"), var, var, "N");
                    addForcedRiskProfileExamination(riskProfileExaminations, riskProfileExaminationVO);
                }
                pushRiskProfileExaminationParameters(riskProfileExaminations, "be.mxs.common.model.vo.healthrecord.IConstants.TRANSACTION_TYPE_DLC", "be.mxs.common.model.vo.healthrecord.IConstants.TRANSACTION_TYPE_DRIVING_LICENCE_DECLARATION");
                Occuprs.close();
                Occupstatement.close();
            }
            if (Occuprs!=null) Occuprs.close();
            if (Occupstatement!=null) Occupstatement.close();
            OccupdbConnection.close();

        } catch (Exception e) {
            e.printStackTrace();
        }
        riskProfileVO = new RiskProfileVO(profileBegin, null, personId, profileId, riskProfileContexts, riskProfileItems, riskProfileExaminations, riskCodes, systemRiskProfileExaminationsVO, systemRiskProfileRiskCodesVO, personalRiskProfileExaminationsVO, personalRiskProfileRiskCodesVO, riskProfileWorkplaces, riskProfileFunctionCategories, riskProfileFunctionGroups);
        riskProfileVO.setRiskProfileLabAnalysisVO(riskProfileLabAnalysisVO);
        return riskProfileVO;
    }
    private void addRiskProfileRisk(Vector riskCodes, RiskProfileRiskCodeVO riskProfileRiskCodeVO) {
        boolean exists = false;
        RiskProfileRiskCodeVO existingRiskProfileRiskCodeVO;
        for (int n = 0; n < riskCodes.size(); n++) {
            existingRiskProfileRiskCodeVO = (RiskProfileRiskCodeVO) riskCodes.elementAt(n);
            if (!existingRiskProfileRiskCodeVO.getRiskCodeId().equals(riskProfileRiskCodeVO.getRiskCodeId()))
                continue;
            riskCodes.setElementAt(riskProfileRiskCodeVO, n);
            exists = true;
            break;
        }
        if (!exists && (riskProfileRiskCodeVO.getStatus().equals(new Integer(1)) || riskProfileRiskCodeVO.getStatus().equals(new Integer(0))))
            riskCodes.add(riskProfileRiskCodeVO);
    }
    private void pushRiskProfileExaminationParameters(Collection riskProfileExaminations, String fromType, String toType) {
        RiskProfileExaminationVO from = null;
        RiskProfileExaminationVO to = null;
        Iterator iterator = riskProfileExaminations.iterator();
        RiskProfileExaminationVO source;
        while (iterator.hasNext()) {
            source = (RiskProfileExaminationVO) iterator.next();
            if (source.getType().equalsIgnoreCase(fromType)) {
                from = source;
            }
            if (source.getType().equalsIgnoreCase(toType)) {
                to = source;
            }
        }
        if (from != null && to != null) {
            to.setDefaultFrequency(from.getDefaultFrequency());
            to.setDefaultTolerance(from.getDefaultTolerance());
            to.setPersonalFrequency(from.getPersonalFrequency());
            to.setPersonalTolerance(from.getPersonalTolerance());
        }
    }
    private void addRiskProfileExamination(Collection riskProfileExaminations, RiskProfileExaminationVO riskProfileExaminationVO) {
        Iterator iterator = riskProfileExaminations.iterator();
        boolean exists = false;
        boolean updated = false;
        RiskProfileExaminationVO existingProfileExaminationVO;
        while (iterator.hasNext()) {
            existingProfileExaminationVO = (RiskProfileExaminationVO) iterator.next();
            if (existingProfileExaminationVO.getId().equals(riskProfileExaminationVO.getId())) {
                exists = true;
                if (riskProfileExaminationVO.getType().equals("be.dpms.medwan.common.model.IConstants.SYSTEM_EXAMINATION") && riskProfileExaminationVO.getStatus().equals(new Integer(0))) {
                    if (existingProfileExaminationVO.getDefaultFrequency() > riskProfileExaminationVO.getDefaultFrequency() && riskProfileExaminationVO.getDefaultFrequency() > 0) {
                        existingProfileExaminationVO.setDefaultFrequency(riskProfileExaminationVO.getDefaultFrequency());
                        updated = true;
                    }
                    if (existingProfileExaminationVO.getPersonalFrequency() > riskProfileExaminationVO.getPersonalFrequency() && riskProfileExaminationVO.getPersonalFrequency() > 0) {
                        existingProfileExaminationVO.setPersonalFrequency(riskProfileExaminationVO.getPersonalFrequency());
                        updated = true;
                    }
                    if (existingProfileExaminationVO.getDefaultTolerance() > riskProfileExaminationVO.getDefaultTolerance()) {
                        existingProfileExaminationVO.setDefaultTolerance(riskProfileExaminationVO.getDefaultTolerance());
                        updated = true;
                    }
                    if (existingProfileExaminationVO.getPersonalTolerance() > riskProfileExaminationVO.getPersonalTolerance()) {
                        existingProfileExaminationVO.setPersonalTolerance(riskProfileExaminationVO.getPersonalTolerance());
                        updated = true;
                    }
                } else {
                    if (riskProfileExaminationVO.getStatus().equals(new Integer(-1)))
                        updated = true;
                    if (existingProfileExaminationVO.getDefaultFrequency() != riskProfileExaminationVO.getPersonalFrequency() && riskProfileExaminationVO.getPersonalFrequency() > 0 && existingProfileExaminationVO.getPersonalFrequency() > riskProfileExaminationVO.getPersonalFrequency()) {
                        existingProfileExaminationVO.setPersonalFrequency(riskProfileExaminationVO.getPersonalFrequency());
                        updated = true;
                    }
                    if (existingProfileExaminationVO.getDefaultTolerance() != riskProfileExaminationVO.getPersonalTolerance() && existingProfileExaminationVO.getPersonalTolerance() > riskProfileExaminationVO.getPersonalTolerance()) {
                        existingProfileExaminationVO.setPersonalTolerance(riskProfileExaminationVO.getPersonalTolerance());
                        updated = true;
                    }
                }
                if (updated)
                    existingProfileExaminationVO.setStatus(riskProfileExaminationVO.getStatus());
                break;
            }
        }
        if (!exists && (riskProfileExaminationVO.getStatus().equals(new Integer(1)) || riskProfileExaminationVO.getStatus().equals(new Integer(0)))) {
            riskProfileExaminations.add(riskProfileExaminationVO);
        }
    }
    private void addForcedRiskProfileExamination(Collection riskProfileExaminations, RiskProfileExaminationVO riskProfileExaminationVO) {
        Iterator iterator = riskProfileExaminations.iterator();
        boolean exists = false;
        boolean updated = false;
        RiskProfileExaminationVO existingProfileExaminationVO;
        while (iterator.hasNext()) {
            existingProfileExaminationVO = (RiskProfileExaminationVO) iterator.next();
            if (existingProfileExaminationVO.getId().equals(riskProfileExaminationVO.getId())) {
                exists = true;
                if (riskProfileExaminationVO.getStatus().equals(new Integer(-1)))
                    updated = true;
                if (existingProfileExaminationVO.getDefaultFrequency() != riskProfileExaminationVO.getPersonalFrequency() && riskProfileExaminationVO.getPersonalFrequency() > 0) {
                    existingProfileExaminationVO.setPersonalFrequency(riskProfileExaminationVO.getPersonalFrequency());
                    updated = true;
                }
                if (existingProfileExaminationVO.getDefaultTolerance() != riskProfileExaminationVO.getPersonalTolerance()) {
                    existingProfileExaminationVO.setPersonalTolerance(riskProfileExaminationVO.getPersonalTolerance());
                    updated = true;
                }
                if (updated)
                    existingProfileExaminationVO.setStatus(riskProfileExaminationVO.getStatus());
                break;
            }
        }
        if (!exists && (riskProfileExaminationVO.getStatus().equals(new Integer(1)) || riskProfileExaminationVO.getStatus().equals(new Integer(0)))) {
            riskProfileExaminations.add(riskProfileExaminationVO);
        }
    }
    public VaccinationInfoVO getVaccinationInfoVO(TransactionVO transactionVO, ExaminationVO examinationVO)
            throws InternalServiceException {
        Element element = null;
        try {
            Document document = DocumentHelper.parseText(new String(examinationVO.getData()));
            Element root = document.getRootElement();
            for (Iterator elements = root.elements().iterator(); elements.hasNext();) {
                element = (Element) elements.next();
                if (element.valueOf("@ID").equals("Vaccination")) {
                    break;
                }
            }
        } catch (DocumentException e) {
            e.printStackTrace();
        }
        return getVaccinationInfoVO(transactionVO, element);
    }
    public java.util.Date calculateNextVaccination(String type, String subType, java.util.Date date) {
        //Eerst het vaccinatieschema ophalen
        PreparedStatement ps;
        Connection OccupdbConnection;
        try {
            OccupdbConnection = getOpenclinicConnection();
            ps = OccupdbConnection.prepareStatement("select * from Examinations where transactionType=?");
            ps.setString(1, "be.mxs.common.model.vo.healthrecord.IConstants.TRANSACTION_TYPE_VACCINATION&vaccination=" + type);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                Document document = DocumentHelper.parseText(new String(rs.getBytes("data")));
                Element root = document.getRootElement();
                Element element, modifier, item, item2;
                List modifiers, items;
                long numberOfDays;
                for (Iterator elements = root.elements().iterator(); elements.hasNext();) {
                    element = (Element) elements.next();
                    if (element.attribute("ID").getValue().equalsIgnoreCase("Vaccination")) {
                        modifiers = element.elements("Modifier");
                        for (int n = 0; n < modifiers.size(); n++) {
                            modifier = (Element) modifiers.get(n);
                            if (modifier.attribute("Type").getValue().equalsIgnoreCase("Rule")) {
                                //Check if this is the correct subtype
                                items = modifier.elements("Item");
                                for (int m = 0; m < items.size(); m++) {
                                    item = (Element) items.get(m);
                                    if (item.attribute("ID").getValue().equalsIgnoreCase("Subtype") && item.getText().equalsIgnoreCase(subType)) {
                                        //This is the one and only!
                                        //if(Debug.enabled) Debug.println(item.asXML());
                                        for (int o = 0; o < items.size(); o++) {
                                            item2 = (Element) items.get(o);
                                            if (item2.attribute("ID").getValue().equalsIgnoreCase("MinInterval")) {
                                                numberOfDays = Long.parseLong(item2.getText());
                                                return new Date(date.getTime() + numberOfDays * 24 * 60 * 60 * 1000);
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
            rs.close();
            ps.close();
            OccupdbConnection.close();

        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }
    private VaccinationInfoVO getVaccinationInfoVO(TransactionVO transactionVO, Element element)
            throws InternalServiceException {
        out("getVaccinationInfoVO start");
        String vaccinationType = null;
        String vaccinationStatus = "-";
        String nextDate = "";
        java.util.Date vaccinationDate = null;
        boolean bCommentExists = false;
        boolean bNextDateExists = false;
        boolean bNameExists = false;
        Iterator iTransactionItems = transactionVO.getItems().iterator();
        ItemVO transactionItemVO;
        while (iTransactionItems.hasNext()) {
            transactionItemVO = (ItemVO) iTransactionItems.next();
            if (transactionItemVO.getType().equals("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_VACCINATION_STATUS")) {
                vaccinationStatus = transactionItemVO.getValue();
            }
            if (transactionItemVO.getType().equals("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_VACCINATION_TYPE")) {
                vaccinationType = transactionItemVO.getValue();
            }
            if (transactionItemVO.getType().equals("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_COMMENT")) {
                bCommentExists = true;
            }
            if (transactionItemVO.getType().equals("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_VACCINATION_NEXT_DATE")) {
                bNextDateExists = true;
                nextDate = transactionItemVO.getValue();
            }
            if (transactionItemVO.getType().equals("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_VACCINATION_NAME")) {
                bNameExists = true;
            } else
            if (transactionItemVO.getType().equals("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_VACCINATION_DATE")) {
                try {
                    if (transactionItemVO.getValue() != null) {
                        vaccinationDate = stdDateFormat.parse(transactionItemVO.getValue().replaceAll("-", "/"));
                    }
                } catch (ParseException e) {
                    e.printStackTrace();
                }
            }
        }
        if (!bCommentExists) {
            ItemContextVO itemContextVO = new ItemContextVO(new Integer(IdentifierFactory.getInstance().getTemporaryNewIdentifier()), "", "");
            transactionVO.getItems().add(new ItemVO(new Integer(IdentifierFactory.getInstance().getTemporaryNewIdentifier()), "be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_COMMENT", "", new java.util.Date(), itemContextVO));
        }
        if (!bNameExists) {
            ItemContextVO itemContextVO = new ItemContextVO(new Integer(IdentifierFactory.getInstance().getTemporaryNewIdentifier()), "", "");
            transactionVO.getItems().add(new ItemVO(new Integer(IdentifierFactory.getInstance().getTemporaryNewIdentifier()), "be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_VACCINATION_NAME", "", new java.util.Date(), itemContextVO));
        }
        if (!bNextDateExists) {
            ItemContextVO itemContextVO = new ItemContextVO(new Integer(IdentifierFactory.getInstance().getTemporaryNewIdentifier()), "", "");
            transactionVO.getItems().add(new ItemVO(new Integer(IdentifierFactory.getInstance().getTemporaryNewIdentifier()), "be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_VACCINATION_NEXT_DATE", "", new java.util.Date(), itemContextVO));
        }
        VaccinationInfoVO vaccinationInfoVO = new VaccinationInfoVO();
        vaccinationInfoVO.setTransactionVO(transactionVO);
        vaccinationInfoVO.setType(vaccinationType);
        vaccinationInfoVO.setNextStatus("-");
        try {
            vaccinationInfoVO.setNextDate(new SimpleDateFormat("dd/MM/yyyy").parse(nextDate));
        }
        catch (Exception e) {
            //
        }
        if (element != null) {
            //if(Debug.enabled) Debug.println("OK, Vaccination element not null");
            Hashtable hModifierItem;
            int minInterval = 0;
            int maxInterval = 0;
            Iterator iModifiers = element.elementIterator("Modifier");
            Element modifier, modifierItem;
            Iterator iModifierItems;
            long miliseconds, seconds, minutes, hours, days;
            while (iModifiers.hasNext()) {
                modifier = (Element) iModifiers.next();
                if (modifier.valueOf("@Type").equals("Rule")) {
                    hModifierItem = new Hashtable();
                    for (iModifierItems = modifier.elementIterator("Item"); iModifierItems.hasNext();) {
                        modifierItem = (Element) iModifierItems.next();
                        hModifierItem.put(modifierItem.valueOf("@ID"), modifierItem.getText());
                    }
                    if (!((String) hModifierItem.get("Subtype")).equalsIgnoreCase(vaccinationStatus))
                        continue;
                    //if(Debug.enabled) Debug.println("OK, found correct subtype: "+vaccinationStatus);
                    if (vaccinationDate != null) {
                        miliseconds = (new java.util.Date()).getTime() - vaccinationDate.getTime();
                        seconds = 0L;
                        minutes = 0L;
                        hours = 0L;
                        days = 0L;
                        if (miliseconds > 1000L)
                            seconds = ((new java.util.Date()).getTime() - vaccinationDate.getTime()) / 1000L;
                        if (seconds > 60L)
                            minutes = seconds / 60L;
                        if (minutes > 60L)
                            hours = minutes / 60L;
                        if (hours > 24L)
                            days = hours / 24L;
                        if (hModifierItem.get("MinInterval") != null) {
                            minInterval = Integer.parseInt((String) hModifierItem.get("MinInterval"));
                        }
                        if (hModifierItem.get("MaxInterval") != null) {
                            maxInterval = Integer.parseInt((String) hModifierItem.get("MaxInterval"));
                        }
                        if (hModifierItem.get("NextSubtype") != null) {
                            vaccinationInfoVO.setNextStatus((String) hModifierItem.get("NextSubtype"));
                        } else {
                            throw new InternalServiceException("NextSubtype is missing for Vaccination Element [ID=" + element.valueOf("@ID") + ", label=" + element.valueOf("Label") + "] at Modifier [" + hModifierItem.get("Subtype") + "]");
                        }
                        //if(Debug.enabled) Debug.println("OK, next subtype: "+(String)hModifierItem.get("NextSubtype"));
                        if (hModifierItem.get("Comment") != null)
                            vaccinationInfoVO.setComment((String) hModifierItem.get("Comment"));
                        if (maxInterval > 0 && days > (long) maxInterval)
                            continue;
                    } else {
                        if (hModifierItem.get("NextSubtype") != null)
                            vaccinationInfoVO.setNextStatus((String) hModifierItem.get("NextSubtype"));
                        else
                            throw new InternalServiceException("NextSubtype is missing for Vaccination Element [ID=" + element.valueOf("@ID") + ", label=" + element.valueOf("Label") + "] at Modifier [" + hModifierItem.get("Subtype") + "]");
                        if (hModifierItem.get("Comment") != null)
                            vaccinationInfoVO.setComment((String) hModifierItem.get("Comment"));
                    }
                    break;
                }
                if (modifier.valueOf("@Type").equals("ValueList")) {
                    for (iModifierItems = modifier.elementIterator("Item"); iModifierItems.hasNext();) {
                        modifierItem = (Element) iModifierItems.next();
                        if (modifierItem.getText() != null)
                            vaccinationInfoVO.getValueList().add(modifierItem.getText());
                    }
                }
            }
            iModifiers = element.elementIterator("Modifier");
            while (iModifiers.hasNext()) {
                modifier = (Element) iModifiers.next();
                if (!modifier.valueOf("@Type").equals("Rule"))
                    continue;
                hModifierItem = new Hashtable();
                for (iModifierItems = modifier.elementIterator("Item"); iModifierItems.hasNext();) {
                    modifierItem = (Element) iModifierItems.next();
                    hModifierItem.put(modifierItem.valueOf("@ID"), modifierItem.getText());
                }
                if (!((String) hModifierItem.get("Subtype")).equalsIgnoreCase(vaccinationInfoVO.getNextStatus()))
                    continue;
                //if(Debug.enabled) Debug.println("OK, let's calculate the date of next subtype: "+vaccinationInfoVO.getNextStatus());
                if (hModifierItem.get("MinInterval") != null) {
                    vaccinationInfoVO.setNextMinInterval((new Long((String) hModifierItem.get("MinInterval"))).longValue());
                    //if(Debug.enabled) Debug.println("OK, interval of next subtype is "+vaccinationInfoVO.getNextMinInterval());
                }
                break;
            }
            if (vaccinationDate == null) {
                vaccinationInfoVO.setColor(vaccinationInfoVO.getRedCode());
            } else {
                if (vaccinationInfoVO.getNextDate() != null) {
                    Debug.println("vaccinationInfoVO.getNextDate()=" + vaccinationInfoVO.getNextDate());
                    vaccinationInfoVO.setColor(vaccinationInfoVO.getGreenCode());
                    if (vaccinationInfoVO.getNextDate().before(new java.util.Date())) {
                        vaccinationInfoVO.setColor(vaccinationInfoVO.getRedCode());
                    }
                } else {
                    miliseconds = (new java.util.Date()).getTime() - vaccinationDate.getTime();
                    seconds = 0L;
                    minutes = 0L;
                    hours = 0L;
                    days = 0L;
                    if (miliseconds > 1000L)
                        seconds = ((new java.util.Date()).getTime() - vaccinationDate.getTime()) / 1000L;
                    if (seconds > 60L)
                        minutes = seconds / 60L;
                    if (minutes > 60L)
                        hours = minutes / 60L;
                    if (hours > 24L)
                        days = hours / 24L;
                    if (days <= (long) maxInterval && days < (long) minInterval) {
                        vaccinationInfoVO.setColor(vaccinationInfoVO.getGreenCode());
                    } else if (days <= (long) maxInterval && days >= (long) minInterval) {
                        vaccinationInfoVO.setColor(vaccinationInfoVO.getRedCode());
                    }
                    vaccinationInfoVO.setNextDate(new Date(vaccinationDate.getTime() + vaccinationInfoVO.getNextMinInterval()));
                }
            }
            out("getVaccinationInfoVO stop");
        }
        return vaccinationInfoVO;
    }
    /*    public RiskProfileVO updateRiskProfileContext(long personId, Vector newRiskProfileContexts, SessionContainerWO sessionContainerWO, String comment) {
            exportPerson(new Long(personId).intValue());

            Connection OccupdbConnection;
            try {
                OccupdbConnection = getOpenclinicConnection();
                PreparedStatement Occupstatement = OccupdbConnection.prepareStatement("update RiskProfiles set dateEnd=?, comment=?, updateserverid="+MedwanQuery.getInstance().getConfigInt("serverId")+" where personId=? and dateEnd is null");
                Occupstatement.setDate(1, new java.sql.Date(new java.util.Date().getTime()));
                Occupstatement.setString(2, comment);
                Occupstatement.setInt(3, new Long(personId).intValue());
                Occupstatement.execute();
                int newProfileId = getCounter("RiskProfileID");

                Occupstatement = OccupdbConnection.prepareStatement("insert into RiskProfiles(profileId,dateBegin,dateEnd,personId,updatetime,comment,updateserverid) values(?,?,null,?,?,?,"+MedwanQuery.getInstance().getConfigInt("serverId")+")");
                Occupstatement.setInt(1, newProfileId);
                Occupstatement.setTimestamp(2, new Timestamp(new java.util.Date().getTime()));
                Occupstatement.setInt(3, new Long(personId).intValue());
                Occupstatement.setTimestamp(4, new Timestamp(new java.util.Date().getTime()));
                Occupstatement.setString(5, comment);
                Occupstatement.execute();
                if (sessionContainerWO != null && sessionContainerWO.getRiskProfileVO() != null && sessionContainerWO.getRiskProfileVO().getProfileId() != null) {
                    Occupstatement = OccupdbConnection.prepareStatement("select * from RiskProfileItems where profileId=?");
                    Occupstatement.setInt(1, sessionContainerWO.getRiskProfileVO().getProfileId().intValue());
                    PreparedStatement Occupstatement2;
                    for (ResultSet Occuprs = Occupstatement.executeQuery(); Occuprs.next();) {
                        Occupstatement2 = OccupdbConnection.prepareStatement("insert into RiskProfileItems(profileItemId,itemType,itemId,status,comment,profileId,frequency,tolerance,ageGenderControl) values(?,?,?,?,?,?,?,?,?)");
                        Occupstatement2.setInt(1, getCounter("RiskProfileItemID)"));
                        Occupstatement2.setString(2, Occuprs.getString("itemType"));
                        Occupstatement2.setInt(3, Occuprs.getInt("itemId"));
                        Occupstatement2.setInt(4, Occuprs.getInt("status"));
                        Occupstatement2.setString(5, Occuprs.getString("comment"));
                        Occupstatement2.setInt(6, newProfileId);
                        Occupstatement2.setInt(7, Occuprs.getInt("frequency"));
                        Occupstatement2.setInt(8, Occuprs.getInt("tolerance"));
                        Occupstatement2.setString(9, Occuprs.getInt("ageGenderControl")+"");
                        Occupstatement2.execute();
                        Occupstatement2.close();
                    }
                }
                RiskProfileContextVO riskProfileContextVO;
                for (int n = 0; n < newRiskProfileContexts.size(); n++) {
                    riskProfileContextVO = (RiskProfileContextVO) newRiskProfileContexts.elementAt(n);

                    Occupstatement = OccupdbConnection.prepareStatement("insert into RiskProfileContexts(profileContextId,itemType,itemId,profileId) values(?,?,?,?)");
                    Occupstatement.setInt(1, getCounter("RiskProfileContextID)"));
                    Occupstatement.setString(2, riskProfileContextVO.getItemType());
                    Occupstatement.setInt(3, riskProfileContextVO.getItemId().intValue());
                    Occupstatement.setInt(4, newProfileId);
                    Occupstatement.execute();
                }
                Occupstatement.close();
            } catch (Exception e) {
                e.printStackTrace();
            }
            if (sessionContainerWO != null) {
                return getRiskProfileVO(new Long(personId), sessionContainerWO);
            }
            return null;
        }

        public RiskProfileVO updateRiskProfileContextClean(long personId, Vector newRiskProfileContexts, SessionContainerWO sessionContainerWO, String comment) {
            exportPerson(new Long(personId).intValue());

            Connection OccupdbConnection;
            try {
                OccupdbConnection = getOpenclinicConnection();
                PreparedStatement Occupstatement = OccupdbConnection.prepareStatement("update RiskProfiles set dateEnd=?, comment=?,updateserverid="+MedwanQuery.getInstance().getConfigInt("serverId")+" where personId=? and dateEnd is null");
                Occupstatement.setDate(1, new java.sql.Date(new java.util.Date().getTime()));
                Occupstatement.setString(2, comment);
                Occupstatement.setInt(3, new Long(personId).intValue());
                Occupstatement.execute();
                int newProfileId = getCounter("RiskProfileID");

                Occupstatement = OccupdbConnection.prepareStatement("insert into RiskProfiles(profileId,dateBegin,dateEnd,personId,updatetime,comment,updateserverid) values(?,?,null,?,?,?,"+MedwanQuery.getInstance().getConfigInt("serverId")+")");
                Occupstatement.setInt(1, newProfileId);
                Occupstatement.setTimestamp(2, new Timestamp(new java.util.Date().getTime()));
                Occupstatement.setInt(3, new Long(personId).intValue());
                Occupstatement.setTimestamp(4, new Timestamp(new java.util.Date().getTime()));
                Occupstatement.setString(5, comment);
                Occupstatement.execute();
                RiskProfileContextVO riskProfileContextVO;
                for (int n = 0; n < newRiskProfileContexts.size(); n++) {
                    riskProfileContextVO = (RiskProfileContextVO) newRiskProfileContexts.elementAt(n);

                    Occupstatement = OccupdbConnection.prepareStatement("insert into RiskProfileContexts(profileContextId,itemType,itemId,profileId) values(?,?,?,?)");
                    Occupstatement.setInt(1, getCounter("RiskProfileContextID)"));
                    Occupstatement.setString(2, riskProfileContextVO.getItemType());
                    Occupstatement.setInt(3, riskProfileContextVO.getItemId().intValue());
                    Occupstatement.setInt(4, newProfileId);
                    Occupstatement.execute();
                }
                Occupstatement.close();
            } catch (Exception e) {
                e.printStackTrace();
            }
            if (sessionContainerWO != null) {
                return getRiskProfileVO(new Long(personId), sessionContainerWO);
            }
            return null;
        }
    */
    //--- UPDATE TRANSACTION ----------------------------------------------------------------------
    public TransactionVO updateTransaction(int personid, TransactionVO transactionVO) {
        try {
            String sSelect = "select healthRecordId from Transactions where serverid=? and transactionId=?";
            Connection oc_conn=getOpenclinicConnection();
            PreparedStatement ps = oc_conn.prepareStatement(sSelect);
            ps.setInt(1, transactionVO.getServerId());
            ps.setInt(2, transactionVO.getTransactionId().intValue());
            ResultSet rs = ps.executeQuery();
            int healthRecordId = 0;
            if (rs.next()) {
                healthRecordId = rs.getInt("healthRecordId");
                sSelect = "insert into TransactionsHistory(transactionId,creationDate,transactionType," +
                        "  updateTime,status,healthRecordId,userId,serverid,versionserverid,version)" +
                        " select transactionId,creationDate,transactionType,updateTime,status,healthRecordId," +
                        "        userId,serverid,versionserverid,version" +
                        " from Transactions where serverid=? and transactionId=?";
                rs.close();
                ps.close();
                ps = oc_conn.prepareStatement(sSelect);
                ps.setInt(1, transactionVO.getServerId());
                ps.setInt(2, transactionVO.getTransactionId().intValue());
                ps.execute();
                ps.close();
                sSelect = "insert into ItemsHistory(itemId,type," + getConfigString("valueColumn") + ","
                        + getConfigString("dateColumn") + ",transactionId,serverid,versionserverid,version)" +
                        " select itemId,type," + getConfigString("valueColumn") + "," + getConfigString("dateColumn") + "," +
                        "        transactionId,serverid,versionserverid,version" +
                        " from Items where serverid=? and transactionId=?";
                ps = oc_conn.prepareStatement(sSelect);
                ps.setInt(1, transactionVO.getServerId());
                ps.setInt(2, transactionVO.getTransactionId().intValue());
                ps.execute();
                ps.close();
                ps = oc_conn.prepareStatement("delete from Transactions where serverid=? and transactionId=?");
                ps.setInt(1, transactionVO.getServerId());
                ps.setInt(2, transactionVO.getTransactionId().intValue());
                ps.execute();
                ps.close();
                ps = oc_conn.prepareStatement("delete from Items where serverid=? and transactionId=?");
                ps.setInt(1, transactionVO.getServerId());
                ps.setInt(2, transactionVO.getTransactionId().intValue());
                ps.execute();
                ps.close();
            } else
            if (!transactionVO.getTransactionType().equals("be.mxs.common.model.vo.healthrecord.IConstants.TRANSACTION_TYPE_WORKPLACE_VISIT_AND_OTHER_ACTIVITIES")) {
                sSelect = "SELECT healthRecordId from Healthrecord" +
                        " where (dateEnd is null or dateEnd>?) and serverid=? and personId=?";
                rs.close();
                ps.close();
                ps = oc_conn.prepareStatement(sSelect);
                ps.setDate(1, new java.sql.Date(new java.util.Date().getTime()));
                ps.setInt(2, getConfigInt("serverId"));
                ps.setInt(3, personid);
                rs = ps.executeQuery();
                if (rs.next()) {
                    healthRecordId = rs.getInt("healthRecordId");
                    rs.close();
                    ps.close();
                } else {
                    rs.close();
                    ps.close();
                    healthRecordId = getOpenclinicCounter("HealthRecordID");
                    sSelect = "insert into Healthrecord(healthRecordId,dateBegin,dateEnd,personId," +
                            " serverid,version,versionserverid) values(?,?,null,?,?,1,?)";
                    ps = oc_conn.prepareStatement(sSelect);
                    ps.setInt(1, healthRecordId);
                    ps.setDate(2, new java.sql.Date(new java.util.Date().getTime()));
                    ps.setInt(3, personid);
                    ps.setInt(4, getConfigInt("serverId"));
                    ps.setInt(5, getConfigInt("serverId"));
                    ps.execute();
                    ps.close();
                }
                if (transactionVO.getTransactionId().intValue() < 0) {
                    transactionVO.setTransactionId(new Integer(getOpenclinicCounter("TransactionID")));
                }
                ps = oc_conn.prepareStatement("update PermanentItems set transactionId=? where transactionId=? and serverid=?");
                ps.setInt(1, transactionVO.getTransactionId().intValue());
                ps.setInt(2, transactionVO.getTransactionId().intValue());
                ps.setInt(3, transactionVO.getServerId());
                ps.execute();
                ps.close();
                transactionVO.setVersion(0);
            } else {
                Integer newTransactionId = new Integer(getOpenclinicCounter("TransactionID"));
                transactionVO.setTransactionId(newTransactionId);
                transactionVO.setVersion(0);
                Iterator iterator = transactionVO.getItems().iterator();
                ItemVO itemVO;
                while (iterator.hasNext()) {
                    itemVO = (ItemVO) iterator.next();
                    if (itemVO.getType().equals(IConstants.ITEM_TYPE_VISITS_ACTIVITIES_PROVINCE)) {
                        setValue(transactionVO.getUser().getUserId() + ".activeProvince", itemVO.getValue());
                    }
                }
            }
            transactionVO.setVersion(transactionVO.getVersion() + 1);
            transactionVO.setVersionServerId(getConfigInt("serverId"));
            sSelect = "insert into Transactions(transactionId,creationDate,transactionType,updateTime," +
                    "  status,healthRecordId,userId,serverid,version,versionserverid,ts)" +
                    " values(?,?,?,?,?,?,?,?,?,?," + getConfigString("timeStamp") + ")";
            if (rs!=null) rs.close();
            if (ps!=null) ps.close();
            ps = oc_conn.prepareStatement(sSelect);
            ps.setInt(1, transactionVO.getTransactionId().intValue());
            ps.setDate(2, new java.sql.Date(transactionVO.getCreationDate().getTime()));
            ps.setString(3, transactionVO.getTransactionType());
            ps.setDate(4, new java.sql.Date(transactionVO.getUpdateTime().getTime()));
            ps.setInt(5, transactionVO.getStatus());
            if (transactionVO.getTransactionType().equals("be.mxs.common.model.vo.healthrecord.IConstants.TRANSACTION_TYPE_WORKPLACE_VISIT_AND_OTHER_ACTIVITIES")) {
                healthRecordId = 0;
            }
            ps.setInt(6, healthRecordId);
            ps.setInt(7, transactionVO.getUser().getUserId().intValue());
            ps.setInt(8, transactionVO.getServerId());
            ps.setInt(9, transactionVO.getVersion());
            ps.setInt(10, transactionVO.getVersionserverId());
            ps.execute();
            ps.close();
            ItemVO itemVO;
            for (Iterator iterator = transactionVO.getItems().iterator(); iterator.hasNext();) {
                itemVO = (ItemVO) iterator.next();
                if (itemVO.getValue().trim().length() > 0) {
                    sSelect = "insert into Items(itemId,type," + getConfigString("valueColumn") + "," +
                            getConfigString("dateColumn") + ",transactionId,serverid,version,versionserverid,valuehash)" +
                            " values(?,?,?,?,?,?,?,?,?)";
                    ps = oc_conn.prepareStatement(sSelect);
                    if (itemVO.getItemId().intValue() < 0) {
                        itemVO.setItemId(new Integer(getOpenclinicCounter("ItemID")));
                    }
                    ps.setInt(1, itemVO.getItemId().intValue());
                    ps.setString(2, itemVO.getType());
                    ps.setString(3, itemVO.getValue());
                    ps.setDate(4, new java.sql.Date(itemVO.getDate().getTime()));
                    ps.setInt(5, transactionVO.getTransactionId().intValue());
                    ps.setInt(6, transactionVO.getServerId());
                    ps.setInt(7, transactionVO.getVersion());
                    ps.setInt(8, transactionVO.getVersionserverId());
                    ps.setInt(9, (itemVO.getType() + itemVO.getValue()).hashCode());
                    ps.execute();
                    ps.close();
                }
            }
            oc_conn.close();
        }
        catch (Exception e) {
            e.printStackTrace();
        }
        MedwanQuery.getInstance().getObjectCache().putObject("transaction",transactionVO);
        return transactionVO;
    }
    public Vector getItemHistory(int healthRecordId, String itemType) {
        Vector hs = new Vector();
        Connection OccupdbConnection;
        try {
            OccupdbConnection = getOpenclinicConnection();
            PreparedStatement ps = OccupdbConnection.prepareStatement("select b.itemId,a.updateTime,b." + getConfigString("valueColumn") + ",b.serverid from Transactions a,Items b where a.healthRecordId=? and a.serverid=b.serverid and a.transactionId=b.transactionId and b.type=? order by updateTime DESC");
            ps.setInt(1, healthRecordId);
            ps.setString(2, itemType);
            ResultSet rs = ps.executeQuery();
            ItemVO historyItem;
            while (rs.next()) {
                historyItem = new ItemVO(new Integer(rs.getInt("itemId")), itemType, rs.getString("value"), new java.util.Date(rs.getDate("updateTime").getTime()), null);
                historyItem.setServerId(rs.getInt("serverid"));
                hs.add(historyItem);
            }
            rs.close();
            ps.close();
            OccupdbConnection.close();
            
        } catch (Exception e) {
            e.printStackTrace();
        }
        return hs;
    }
    private String checkString(String value) {
        // om geen 'null' weer te geven
        if (value == null || value.equalsIgnoreCase("null")) {
            return "";
        } else {
            value = value.trim();
        }
        return value;
    }
    public String getNewResultCounterValue(String sCounterName) {
        PreparedStatement ps, ps2, ps3, ps4;
        ResultSet rs, rs3;
    	Connection ad_conn = MedwanQuery.getInstance().getAdminConnection();
        try {
            String sSelect = " SELECT counter FROM Counters WHERE name = ? ";
            ps = ad_conn.prepareStatement(sSelect);
            ps.setString(1, sCounterName);
            rs = ps.executeQuery();
            String sCounterValue;
            if (rs.next()) {
                sCounterValue = rs.getString("counter");
                sSelect = " UPDATE Counters SET counter = counter + 1 WHERE name = ? ";
                ps2 = ad_conn.prepareStatement(sSelect);
                ps2.setString(1, sCounterName);
                ps2.executeUpdate();
                ps2.close();
                sSelect = " SELECT counter-1 AS CounterValue FROM Counters WHERE name = ? ";
                ps3 = ad_conn.prepareStatement(sSelect);
                ps3.setString(1, sCounterName);
                rs3 = ps3.executeQuery();
                if (rs3.next()) {
                    String sNewCounterValue = rs3.getInt("CounterValue") + "";
                    if (!sNewCounterValue.equals(sCounterValue)) {
                        try {
                            Thread.sleep(new Random().nextInt(500));
                        }
                        catch (InterruptedException e) {
                            Debug.println("Helper (newCounter 1) " + e.getMessage());
                        }
                        sCounterValue = getNewResultCounterValue(sCounterName);
                    }
                }
                rs3.close();
                ps3.close();
            } else {
                sSelect = " INSERT Counters (name, counter) VALUES (?,2) ";
                sCounterValue = "1";
                ps4 = ad_conn.prepareStatement(sSelect);
                ps4.setString(1, sCounterName);
                ps4.executeUpdate();
                ps4.close();
            }
            rs.close();
            ps.close();
            return sCounterValue;
        }
        catch (SQLException e) {
            Debug.println("MedwanQuery ResultDb (getNewResultCounterValue) " + e.getMessage());
        }
        try {
			ad_conn.close();
		} catch (SQLException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
        return "";
    }
    public String getNewOccupCounterValue(String sCounterName) {
        PreparedStatement ps = null;
        ResultSet rs = null;
        Connection oc_conn=getOpenclinicConnection();
        try {
            String sSelect = " SELECT counter FROM counters WHERE name = ? ";
            ps = oc_conn.prepareStatement(sSelect);
            ps.setString(1, sCounterName);
            rs = ps.executeQuery();
            String sCounterValue;
            if (rs.next()) {
                sCounterValue = rs.getString("counter");
                sSelect = " UPDATE counters SET counter = counter + 1 WHERE name = ? ";
                rs.close();
                ps.close();
                ps = oc_conn.prepareStatement(sSelect);
                ps.setString(1, sCounterName);
                ps.executeUpdate();
                if (ps != null) ps.close();
                sSelect = " SELECT counter-1 AS CounterValue FROM counters WHERE name = ? ";
                ps = oc_conn.prepareStatement(sSelect);
                ps.setString(1, sCounterName);
                rs = ps.executeQuery();
                if (rs.next()) {
                    String sNewCounterValue = rs.getInt("CounterValue") + "";
                    if (!sNewCounterValue.equals(sCounterValue)) {
                        try {
                            Thread.sleep(new Random().nextInt(500));
                        }
                        catch (InterruptedException e) {
                            Debug.println("Helper (newCounter 1) " + e.getMessage());
                        }
                        sCounterValue = getNewOccupCounterValue(sCounterName);
                    }
                }
                if (rs != null) rs.close();
                if (ps != null) ps.close();
            } else {
                sSelect = " INSERT counters (name, counter) VALUES (?,2) ";
                sCounterValue = "1";
                rs.close();
                ps.close();
                ps = oc_conn.prepareStatement(sSelect);
                ps.setString(1, sCounterName);
                ps.executeUpdate();
                if (ps != null) ps.close();
            }
            return sCounterValue;
        }
        catch (SQLException e) {
            Debug.println("MedwanQurey OccupDb (getNewOccupCounterValue) " + e.getMessage());
        }
        finally {
            try {
                if (rs != null) rs.close();
                if (ps != null) ps.close();
                oc_conn.close();
            }
            catch (SQLException se) {
                se.printStackTrace();
            }
        }
        return "";
    }
    public static Hashtable getGlycemyShots(String sPersonId, java.util.Date dateFrom, java.util.Date dateUntil) {
        Hashtable datesAndValues = new Hashtable();
        PreparedStatement ps = null;
        ResultSet rs = null;
        String sSelect;

        // get values of the specified item from all examinations in the given interval
        sSelect = "SELECT t.transactionId, i.type, i.value, updateTime" +
                "  FROM Healthrecord h, Transactions t, Items i" +
                " WHERE h.personId = ?" +
                "  AND t.healthRecordId = h.healthRecordId" +
                "  AND t.transactionType = 'be.mxs.common.model.vo.healthrecord.IConstants.TRANSACTION_TYPE_DIABETES_FOLLOWUP'" +
                "  AND i.transactionId = t.transactionId" +
                "  AND i.serverid = t.serverid";
        if (dateFrom != null) sSelect += " AND t.updateTime > ?";
        if (dateUntil != null) sSelect += " AND t.updateTime <= ?";
        sSelect += " AND i.type LIKE 'be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DIABETES_FOLLOWUP_GLYCEMY_SHOT_%'" +
                " ORDER BY updateTime ASC";
        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try {
            int questionMarkIdx = 1;
            ps = oc_conn.prepareStatement(sSelect);

            // set questionMark values
            ps.setInt(questionMarkIdx++, Integer.parseInt(sPersonId));
            if (dateFrom != null) ps.setDate(questionMarkIdx++, new java.sql.Date(dateFrom.getTime()));
            if (dateUntil != null) ps.setDate(questionMarkIdx++, new java.sql.Date(dateUntil.getTime()));
            rs = ps.executeQuery();
            Calendar calendar = new GregorianCalendar();
            String sType, value;
            java.util.Date date;

            // run thru found values
            while (rs.next()) {
                sType = ScreenHelper.checkString(rs.getString("type"));

                // get date from DB and set the right hour based on the type
                date = rs.getDate("updateTime");
                calendar.setTime(date);
                if (sType.endsWith("_MORNING")) {
                    calendar.set(Calendar.HOUR, 8); // 08h00
                    calendar.set(Calendar.MINUTE, 0);
                    calendar.set(Calendar.SECOND, 0);
                } else if (sType.endsWith("_NOON")) {
                    calendar.set(Calendar.HOUR, 12); // 12h00
                    calendar.set(Calendar.MINUTE, 0);
                    calendar.set(Calendar.SECOND, 0);
                } else if (sType.endsWith("_EVENING")) {
                    calendar.set(Calendar.HOUR, 17); // 17h00
                    calendar.set(Calendar.MINUTE, 0);
                    calendar.set(Calendar.SECOND, 0);
                }
                value = ScreenHelper.checkString(rs.getString("value"));
                if (value.length() > 0) {
                    datesAndValues.put(calendar.getTime(), value);
                }
            }
        }
        catch (SQLException sqle) {
            sqle.printStackTrace();
        }
        finally {
            try {
                if (rs != null) rs.close();
                if (ps != null) ps.close();
                oc_conn.close();
            }
            catch (SQLException se) {
                se.printStackTrace();
            }
        }
        return datesAndValues;
    }
    public static Hashtable getInsulineShots(String sPersonId, String insulineType, java.util.Date dateFrom, java.util.Date dateUntil) {
        Hashtable datesAndValues = new Hashtable();
        PreparedStatement ps = null;
        ResultSet rs = null;
        String sSelect;

        // itemType allways uppercase
        insulineType = insulineType.toUpperCase();

        // get values of the specified item from all examinations in the given interval
        sSelect = "SELECT t.transactionId, i.type, i.value, updateTime" +
                "  FROM Healthrecord h, Transactions t, Items i" +
                " WHERE h.personId = ?" +
                "  AND t.healthRecordId = h.healthRecordId" +
                "  AND t.transactionType = 'be.mxs.common.model.vo.healthrecord.IConstants.TRANSACTION_TYPE_DIABETES_FOLLOWUP'" +
                "  AND i.transactionId = t.transactionId" +
                "  AND i.serverid = t.serverid";
        if (dateFrom != null) sSelect += " AND t.updateTime > ?";
        if (dateUntil != null) sSelect += " AND t.updateTime <= ?";
        if (insulineType.length() > 0) {
            sSelect += " AND i.type LIKE 'be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DIABETES_FOLLOWUP_INSULINE_SHOT_" + insulineType + "%'";
        } else {
            sSelect += " AND i.type LIKE 'be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DIABETES_FOLLOWUP_INSULINE_SHOT_%'";
        }
        sSelect += " ORDER BY updateTime ASC";
        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try {
            int questionMarkIdx = 1;
            ps = oc_conn.prepareStatement(sSelect);

            // set questionMark values
            ps.setInt(questionMarkIdx++, Integer.parseInt(sPersonId));
            if (dateFrom != null) ps.setDate(questionMarkIdx++, new java.sql.Date(dateFrom.getTime()));
            if (dateUntil != null) ps.setDate(questionMarkIdx++, new java.sql.Date(dateUntil.getTime()));
            rs = ps.executeQuery();
            Calendar calendar = new GregorianCalendar();
            String sType, value;
            java.util.Date date;

            // run thru found values
            while (rs.next()) {
                sType = ScreenHelper.checkString(rs.getString("type"));

                // get date from DB and set the right hour based on the type
                date = rs.getDate("updateTime");
                calendar.setTime(date);
                if (sType.endsWith("_MORNING")) {
                    calendar.set(Calendar.HOUR, 8); // 08h00
                    calendar.set(Calendar.MINUTE, 0);
                    calendar.set(Calendar.SECOND, 0);
                } else if (sType.endsWith("_EVENING")) {
                    calendar.set(Calendar.HOUR, 17); // 17h00
                    calendar.set(Calendar.MINUTE, 0);
                    calendar.set(Calendar.SECOND, 0);
                }
                value = ScreenHelper.checkString(rs.getString("value"));
                if (value.length() > 0) {
                    datesAndValues.put(calendar.getTime(), value);
                }
            }
        }
        catch (SQLException sqle) {
            sqle.printStackTrace();
        }
        finally {
            try {
                if (rs != null) rs.close();
                if (ps != null) ps.close();
                oc_conn.close();
            }
            catch (SQLException se) {
                se.printStackTrace();
            }
        }
        return datesAndValues;
    }
    //--- GET ITEMS IN ITEM-TYPE-GROUP ---------------------------------------------------------------------------------
    public static Vector getItemTypesInItemTypeGroup(String sDestinationItemType) {
        Vector sourceItemTypes = new Vector();
        PreparedStatement ps = null;
        ResultSet rs = null;
        String sSelect;

        // get all sourceItemType belonging to the specified destinationItemType
        sSelect = "SELECT sourceItemType FROM LastItemGroups" +
                "  WHERE destinationItemType = ?" +
                " ORDER BY sourceItemType DESC";
        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try {
            ps = oc_conn.prepareStatement(sSelect);
            ps.setString(1, sDestinationItemType);
            rs = ps.executeQuery();

            // run thru found values
            while (rs.next()) {
                sourceItemTypes.add(ScreenHelper.checkString(rs.getString("sourceItemType")));
            }
        }
        catch (SQLException sqle) {
            sqle.printStackTrace();
        }
        finally {
            try {
                if (rs != null) rs.close();
                if (ps != null) ps.close();
                oc_conn.close();
            }
            catch (SQLException se) {
                se.printStackTrace();
            }
        }
        return sourceItemTypes;
    }
    //--- DELETE LAST ITEM GROUP ---------------------------------------------------------------------------------------
    public static void deleteLastItemGroup(String sDestinationItemType) {
        PreparedStatement ps = null;
        String sSelect = "DELETE FROM LastItemGroups WHERE destinationItemType = ?";
        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try {
            ps = oc_conn.prepareStatement(sSelect);
            ps.setString(1, sDestinationItemType);
            ps.executeUpdate();
        }
        catch (SQLException sqle) {
            sqle.printStackTrace();
        }
        finally {
            try {
                if (ps != null) ps.close();
                oc_conn.close();
            }
            catch (SQLException se) {
                se.printStackTrace();
            }
        }
    }
    //--- DELETE LAST ITEM GROUP ---------------------------------------------------------------------------------------
    public static void addSourceItemToLastItemGroup(String sSourceItemType, String sDestinationItemType) {
        PreparedStatement ps = null;
        String sSelect = "INSERT INTO LastItemGroups(sourceItemType,destinationItemType,updatetime)" +
                " VALUES(?,?,?)";
        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try {
            ps = oc_conn.prepareStatement(sSelect);
            ps.setString(1, sSourceItemType);
            ps.setString(2, sDestinationItemType);
            ps.setTimestamp(3, new Timestamp(new java.util.Date().getTime())); // now
            ps.executeUpdate();
        }
        catch (SQLException sqle) {
            sqle.printStackTrace();
        }
        finally {
            try {
                if (ps != null) ps.close();
                oc_conn.close();
            }
            catch (SQLException se) {
                se.printStackTrace();
            }
        }
    }
    public FullRecordVO getHistory(int healthRecordId, String transactionType) {
        FullRecordVO fullRecordVO = new FullRecordVO();
        String transactionUID = "";
        String sTransactionType;
        String sContext1 = "";
        String sContext2 = "";
        String sContext3 = "";
        Connection OccupdbConnection;
        try {
            OccupdbConnection = getOpenclinicConnection();
            String sQuery = "select updateTime,a.serverid as activeServerId,a.transactionId as activeTransactionId,a.healthRecordId as activeHealthrecordId,a.*,b.*,c.*" +
                    " from Transactions a,Items b,ItemViewList c" +
                    "  where a.healthRecordId=? and" +
                    "   a.transactionType like ? and " +
                    "   a.serverid=b.serverid and " +
                    "   a.transactionId=b.transactionId and " +
                    "   b.type like 'be.mxs.common.model.vo.healthrecord.IConstants.'+c.itemType" +
                    " order by updateTime DESC,a.serverid,a.transactionId,context1,context2,context3,itemType";
            PreparedStatement Occupstatement = OccupdbConnection.prepareStatement(sQuery);
            Occupstatement.setInt(1, healthRecordId);
            Occupstatement.setString(2, transactionType + "%");
            ResultSet Occuprs;
            int serverId, transactionId, activeTransactionId, activeHealthrecordId, activeServerId, showValue;
            String transType, context1, context2, context3, label, value;
            java.util.Date updateTime;
            RecordRowVO recordRowVO;
            for (Occuprs = Occupstatement.executeQuery(); Occuprs.next();) {
                serverId = Occuprs.getInt("serverid");
                transactionId = Occuprs.getInt("transactionId");
                transType = Occuprs.getString("transactiontype");
                updateTime = Occuprs.getDate("updateTime");
                activeTransactionId = Occuprs.getInt("activeTransactionId");
                activeHealthrecordId = Occuprs.getInt("activeHealthrecordId");
                activeServerId = Occuprs.getInt("activeServerId");
                context1 = Occuprs.getString("context1");
                context2 = Occuprs.getString("context2");
                context3 = Occuprs.getString("context3");
                showValue = Occuprs.getInt("showValue");
                label = Occuprs.getString("label");
                if (label.equalsIgnoreCase("labresult")) {
                    label = Occuprs.getString("type");
                }
                value = Occuprs.getString("value");
                if (!(serverId + "." + transactionId).equals(transactionUID)) {
                    sTransactionType = transType;
                    transactionUID = serverId + "." + transactionId;
                    recordRowVO = new RecordRowVO(0, 6, sTransactionType, 0, (stdDateFormat).format(updateTime));
                    recordRowVO.setTransactionId(activeTransactionId);
                    recordRowVO.setHealthrecordId(activeHealthrecordId);
                    recordRowVO.setServerId(activeServerId);
                    recordRowVO.setTransactionType(transType);
                    fullRecordVO.getRecordRows().add(recordRowVO);
                }
                if (context1 != null && !context1.equals(sContext1)) {
                    sContext1 = context1;
                    sContext2 = "";
                    sContext3 = "";
                    fullRecordVO.getRecordRows().add(new RecordRowVO(1, 5, sContext1, 0, null));
                }
                if (context2 != null && !context2.equals(sContext2)) {
                    sContext2 = context2;
                    sContext3 = "";
                    fullRecordVO.getRecordRows().add(new RecordRowVO(2, 4, sContext2, 0, null));
                }
                if (context3 != null && !context3.equals(sContext3)) {
                    sContext3 = context3;
                    fullRecordVO.getRecordRows().add(new RecordRowVO(3, 3, sContext3, 0, null));
                }
                if (showValue == 1) { //  && !value.equals("medwan.common.true")
                    fullRecordVO.getRecordRows().add(new RecordRowVO(4, 1, label, 1, value));
                } else {
                    fullRecordVO.getRecordRows().add(new RecordRowVO(4, 2, label, 0, null));
                }
            }
            Occuprs.close();
            Occupstatement.close();
            OccupdbConnection.close();
        }
        catch (Exception e) {
            e.printStackTrace();
            medwanQuery = null;
            medwanQuery = getInstance();
        }
        return fullRecordVO;
    }
    public String getUserName(int userid) {
        String username = "";
    	Connection ad_conn = MedwanQuery.getInstance().getAdminConnection();
        try {
            String sQuery = "select firstname,lastname from Admin a,Users u where u.userid=? and a.personid=u.personid";
            PreparedStatement ps = ad_conn.prepareStatement(sQuery);
            ps.setInt(1, userid);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                username = rs.getString("firstname") + " " + rs.getString("lastname");
            }
            rs.close();
            ps.close();
        }
        catch (Exception e) {
            e.printStackTrace();
        }
        try {
			ad_conn.close();
		} catch (SQLException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
        return username;
    }
    public Vector getTransactionsByType(HealthRecordVO healthRecord, String transactionType) {
        return getTransactionsByType(healthRecord.getPerson().getPersonId().intValue(), transactionType);
    }
    public Vector getTransactionsByType(int personId, String transactionType) {
        Vector transactionList = new Vector();
        Connection OccupdbConnection;
        try {
            OccupdbConnection = getOpenclinicConnection();
            PreparedStatement Occupstatement = OccupdbConnection.prepareStatement("SELECT a.* FROM Transactions a, Healthrecord b "
                    + " WHERE a.healthRecordId=b.healthRecordId AND personId=? AND transactionType=? ORDER BY updateTime DESC");
            Occupstatement.setInt(1, personId);
            Occupstatement.setString(2, transactionType);
            ResultSet Occuprs;
            for (Occuprs = Occupstatement.executeQuery(); Occuprs.next();) {
                transactionList.add(loadTransaction(Occuprs.getInt("serverid"), Occuprs.getInt("transactionId")));
            }
            Occuprs.close();
            Occupstatement.close();
            OccupdbConnection.close();

        }
        catch (Exception e) {
            e.printStackTrace();
        }
        return transactionList;
    }

    public Vector getTransactionsAfter(int personId, Date date) {
        Vector transactionList = new Vector();
        Connection OccupdbConnection;
        try {
            OccupdbConnection = getOpenclinicConnection();
            PreparedStatement Occupstatement = OccupdbConnection.prepareStatement("SELECT a.* FROM Transactions a, Healthrecord b "
                    + " WHERE a.healthRecordId=b.healthRecordId AND personId=? AND updatetime>=? ORDER BY updateTime DESC");
            Occupstatement.setInt(1, personId);
            Occupstatement.setTimestamp(2, new java.sql.Timestamp(date.getTime()));
            ResultSet Occuprs;
            for (Occuprs = Occupstatement.executeQuery(); Occuprs.next();) {
                transactionList.add(loadTransaction(Occuprs.getInt("serverid"), Occuprs.getInt("transactionId")));
            }
            Occuprs.close();
            Occupstatement.close();
            OccupdbConnection.close();

        }
        catch (Exception e) {
            e.printStackTrace();
        }
        return transactionList;
    }

    /*public Vector getTransactionsByType(HealthRecordVO healthRecord, String transactionType) {

        Vector transactionList = new Vector();
        Connection OccupdbConnection;
        try {
            OccupdbConnection = getOpenclinicConnection();
            PreparedStatement Occupstatement = OccupdbConnection.prepareStatement("SELECT a.* from Transactions a,Healthrecord b where a.healthRecordId=b.healthRecordId and personId=? and transactionType=? order by updateTime DESC");
            Occupstatement.setInt(1, healthRecord.getPerson().getPersonId().intValue());
            Occupstatement.setString(2, transactionType);
            ResultSet Occuprs;
            for (Occuprs = Occupstatement.executeQuery(); Occuprs.next();) {
                transactionList.add(loadTransaction(Occuprs.getInt("serverid"), Occuprs.getInt("transactionId")));
            }
            Occupstatement.close();
        } catch (Exception e) {
            e.printStackTrace();
        }
        return transactionList;
    } */

    //--- GET TRANSACTION ITEMS ----------------------------------------------------------------------------------------
    public static Vector getTransactionItems() {
        Vector itemTypes = new Vector();
        PreparedStatement ps = null;
        ResultSet rs = null;
        String sSelect;

        // compose query
        sSelect = "SELECT DISTINCT itemTypeId FROM TransactionItems" +
                " ORDER BY itemTypeId ASC";
        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try {
            ps = oc_conn.prepareStatement(sSelect);
            rs = ps.executeQuery();

            // run thru found values
            while (rs.next()) {
                itemTypes.add(ScreenHelper.checkString(rs.getString("itemTypeId")));
            }
        }
        catch (SQLException sqle) {
            sqle.printStackTrace();
        }
        finally {
            try {
                if (rs != null) rs.close();
                if (ps != null) ps.close();
                oc_conn.close();
            }
            catch (SQLException se) {
                se.printStackTrace();
            }
        }
        return itemTypes;
    }
    public static Hashtable getAllTransactionItems() {
        Hashtable itemTypes = new Hashtable();
        PreparedStatement ps = null;
        ResultSet rs = null;
        String sSelect;

        // compose query
        sSelect = "SELECT * FROM TransactionItems";
        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try {
            ps = oc_conn.prepareStatement(sSelect);
            rs = ps.executeQuery();

            // run thru found values
            while (rs.next()) {
                itemTypes.put(ScreenHelper.checkString(rs.getString("transactionTypeId"))+"$"+ScreenHelper.checkString(rs.getString("itemTypeId")),ScreenHelper.checkString(rs.getString("defaultValue"))+"$"+ScreenHelper.checkString(rs.getString("modifier")));
            }
        }
        catch (SQLException sqle) {
            sqle.printStackTrace();
        }
        finally {
            try {
                if (rs != null) rs.close();
                if (ps != null) ps.close();
                oc_conn.close();
            }
            catch (SQLException se) {
                se.printStackTrace();
            }
        }
        return itemTypes;
    }
    //--- GET ALL ITEMS TYPES BY LETTERS ----------------------------------------------------------------------------------------
    public static Vector getAllItemsTypesByLetters(String letters, int iMaxRows) {
        Vector itemTypes = new Vector();
        PreparedStatement ps = null;
        ResultSet rs = null;
        String sSelect;
        sSelect = "SELECT type FROM AutoCompleteItems" +
                " ORDER BY type ASC";
        // compose query
        sSelect = "SELECT " + MedwanQuery.getInstance().topFunction("" + iMaxRows) + " itemTypeId FROM TransactionItems  where itemTypeId like '%" + letters + "%' group by itemTypeId order by itemTypeId";
        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try {
            ps = oc_conn.prepareStatement(sSelect);
            rs = ps.executeQuery();

            // run thru found values
            while (rs.next()) {
                itemTypes.add(ScreenHelper.checkString(rs.getString("itemTypeId")));
            }
        }
        catch (SQLException sqle) {
            sqle.printStackTrace();
        }
        finally {
            try {
                if (rs != null) rs.close();
                if (ps != null) ps.close();
                oc_conn.close();
            }
            catch (SQLException se) {
                se.printStackTrace();
            }
        }
        return itemTypes;
    }
    //---DELETE AUTOCOMPLETION ITEMS ----------------------------------------------------------------------------
    public void delAutocompletionItems(String type) {
        Connection connection;
        try {
            connection = getOpenclinicConnection();
            // insert
            PreparedStatement ps = connection.prepareStatement("DELETE FROM AutoCompleteItems WHERE type = ?");
            ps.setString(1, type);
            ps.execute();
            ps.close();
            connection.close();
            this.autocompletionItemTypes.remove(type);
        }
        catch (Exception e) {
            e.printStackTrace();
        }
    }
    //--- GET ALL TYPE ITEMS FROM AUTOCOMPLETE ITEMS ---------------------------------------------------------------------------------
    public List getAllAutocompleteTypeItems() {
        List itemTypes = new ArrayList();
        if (this.autocompletionItemTypes == null) {
            PreparedStatement ps = null;
            ResultSet rs = null;
            String sSelect;
            this.autocompletionItemTypes = new ArrayList();
            sSelect = "SELECT type FROM AutoCompleteItems" +
                    " ORDER BY type DESC";
            Connection oc_conn = MedwanQuery.getInstance().getOpenclinicConnection();
            try {
                ps = oc_conn.prepareStatement(sSelect);
                rs = ps.executeQuery();

                // run thru found values
                while (rs.next()) {
                    itemTypes.add(ScreenHelper.checkString(rs.getString("type")));
                    this.autocompletionItemTypes.add(ScreenHelper.checkString(rs.getString("type")));
                }
            }
            catch (SQLException sqle) {
                sqle.printStackTrace();
            }
            finally {
                try {
                    if (rs != null) rs.close();
                    if (ps != null) ps.close();
                    oc_conn.close();
                }
                catch (SQLException se) {
                    se.printStackTrace();
                }
            }
        } else {
            itemTypes = this.autocompletionItemTypes;
        }
        return itemTypes;
    }
    //---SET AUTOCOMPLETION ITEMS VALUES ----------------------------------------------------------------------------
    public void setAutocompletionItemsValues(String type, String value, int user_id, int counter) {
        Connection connection;
        try {
            if (!type.trim().equals("")) {
                connection = getOpenclinicConnection();
                PreparedStatement ps = connection.prepareStatement("insert into AutoCompleteItemValues (type,value,userid,counter,itemid) values (?,?,?,?,?)");
                ps.setString(1, type);
                ps.setString(2, value);
                ps.setInt(3, user_id);
                ps.setInt(4, counter);
                ps.setInt(5, getOpenclinicCounter("AutoCompletionId"));
                ps.execute();
                ps.close();
                connection.close();
            }
        }
        catch (Exception e) {
            e.printStackTrace();
        }
    }
    //---INCREMENT AUTOCOMPLETION ITEMS VALUES COUNTER ----------------------------------------------------------------------------
    public void setAutocompletionCounterValues(int itemid, int counter) {
        Connection connection;
        try {
            connection = getOpenclinicConnection();
            PreparedStatement ps = connection.prepareStatement("UPDATE AutoCompleteItemValues " +
                    "SET counter = ? WHERE itemid=? ");
            ps.setInt(1, counter);
            ps.setInt(2, itemid);
            ps.execute();
            ps.close();
            connection.close();
        }
        catch (Exception e) {
            e.printStackTrace();
        }
    }
    //---DELETE AUTOCOMPLETION ITEMS VALUES ----------------------------------------------------------------------------
    public void delAutocompletionItemsValues(int itemid, String type, int user_id) {
        Connection connection;
        try {
            PreparedStatement ps = null;
            connection = getOpenclinicConnection();
            // test if value //
            if (itemid == 0) {
                ps = connection.prepareStatement("DELETE FROM AutoCompleteItemValues WHERE type=? AND userid=?");
                ps.setString(1, type);
                ps.setInt(2, user_id);
            } else {
                ps = connection.prepareStatement("DELETE FROM AutoCompleteItemValues WHERE itemid=? ");
                ps.setInt(1, itemid);
            }
            ps.execute();
            ps.close();
            connection.close();

        }
        catch (Exception e) {
            e.printStackTrace();
        }
    }
    //--- GET ALL TYPE ITEMS FROM AUTOCOMPLETE ITEMS ---------------------------------------------------------------------------------
    public List getAllAutocompleteTypeItemsByUser(int userId) {
        List itemTypes = new ArrayList();
        PreparedStatement ps = null;
        ResultSet rs = null;
        String sSelect;
        sSelect = "SELECT type FROM AutoCompleteItemValues WHERE userid = ?" +
                " GROUP BY type ORDER BY type ASC";
        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try {
            ps = oc_conn.prepareStatement(sSelect);
            ps.setInt(1, userId);
            rs = ps.executeQuery();

            // run thru found values
            while (rs.next()) {
                itemTypes.add(ScreenHelper.checkString(rs.getString("type")));
            }
        }
        catch (SQLException sqle) {
            sqle.printStackTrace();
        }
        finally {
            try {
                if (rs != null) rs.close();
                if (ps != null) ps.close();
                oc_conn.close();
            }
            catch (SQLException se) {
                se.printStackTrace();
            }
        }
        return itemTypes;
    }
    //--- GET ALL VALUE ITEMS AND COUNTER BY USER AND TYPE ITEMS ---------------------------------------------------------------------------------
    public Vector getValuesByTypeItemByUser(String type, int userId, String letters) {
        Vector itemTypes = new Vector();
        PreparedStatement ps = null;
        ResultSet rs = null;
        String sSelect;
        sSelect = "SELECT itemid,value,counter FROM AutoCompleteItemValues WHERE userid = ? AND type LIKE ?" +
                " AND value LIKE ?  ORDER BY counter DESC";
        Connection oc_conn = MedwanQuery.getInstance().getOpenclinicConnection();
        try {
            ps = oc_conn.prepareStatement(sSelect);
            ps.setInt(1, userId);
            ps.setString(2, type);
            ps.setString(3, letters + "%");
            rs = ps.executeQuery();
            // run thru found values
            while (rs.next()) {
                Vector v = new Vector();
                v.add(new Integer(rs.getInt("itemid")));
                v.add(ScreenHelper.checkString(rs.getString("value")));
                v.add(new Integer(rs.getInt("counter")));
                itemTypes.add(v);
            }
        }
        catch (SQLException sqle) {
            sqle.printStackTrace();
        }
        finally {
            try {
                if (rs != null) rs.close();
                if (ps != null) ps.close();
                oc_conn.close();
            }
            catch (SQLException se) {
                se.printStackTrace();
            }
        }
        return itemTypes;
    }
    //--- GET ITEMS VALUES FROM ITEMS BY TYPE ---------------------------------------------------------------------------------
    public List getItemsValuesByType(String itemType) {
        List values = new ArrayList();
        PreparedStatement ps = null;
        ResultSet rs = null;
        String sSelect;
        sSelect = "select value from Items where type= ? GROUP BY value";
        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try {
            ps = oc_conn.prepareStatement(sSelect);
            ps.setString(1, itemType);
            rs = ps.executeQuery();

            // run thru found values
            while (rs.next()) {
                values.add(ScreenHelper.checkString(rs.getString("value")));
            }
        }
        catch (SQLException sqle) {
            sqle.printStackTrace();
        }
        finally {
            try {
                if (rs != null) rs.close();
                if (ps != null) ps.close();
                oc_conn.close();
            }
            catch (SQLException se) {
                se.printStackTrace();
            }
        }
        return values;
    }
    //---SET AUTOCOMPLETION ITEMS ----------------------------------------------------------------------------
    public void setAutocompletionItems(String type) {
        Connection connection;
        try {

            // test if exists //
            connection = getOpenclinicConnection();
            PreparedStatement ps = connection.prepareStatement("SELECT type FROM AutoCompleteItems WHERE type = ?");
            ps.setString(1, type);
            ResultSet rs = ps.executeQuery();
            if (!rs.next()) {
                // insert if not exists //
                rs.close();
                ps.close();
            	ps = connection.prepareStatement("insert into AutoCompleteItems(type)values(?)");
                ps.setString(1, type);
                ps.execute();
                ps.close();
                this.autocompletionItemTypes.add(type);
            }
            else {
                rs.close();
                ps.close();
            }
            connection.close();
        }
        catch (Exception e) {
            e.printStackTrace();
        }
    }
    //--- Synchronize counters --/
    public String setSynchroniseCounters(String name, String table, String field, String bd) {
        PreparedStatement ps = null;
        ResultSet rs = null;
        String sOut = "";
        int iActualNbValue = 0;
         int iRealValue = 0;
        try{
           iRealValue = getIntTotalTable(table, field, bd);
        }catch (Exception e){
            sOut += "<span class='error'>!! ERROR !! " +e.getMessage()+"<br />see more information in the server logs...</span>";            
            e.printStackTrace();
        }
        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try {
            String sSelect = "SELECT OC_COUNTER_NAME, OC_COUNTER_VALUE FROM OC_COUNTERS WHERE OC_COUNTER_NAME=?";
            ps = oc_conn.prepareStatement(sSelect);
            ps.setString(1, name);
            rs = ps.executeQuery();

            // get data from DB
            if (rs.next()) {
                iActualNbValue = rs.getInt("OC_COUNTER_VALUE");
            }
        }
        catch (Exception e) {
            e.printStackTrace();
        } finally {
            try {
                if (rs != null) rs.close();
                if (ps != null) ps.close();
            }
            catch (SQLException se) {
                se.printStackTrace();
            }
        }
        //-- uppdate table if necessary --//
        if (iActualNbValue != iRealValue) {
            try {
                String query = "UPDATE OC_COUNTERS SET OC_COUNTER_VALUE=? WHERE OC_COUNTER_NAME=?";
                ps = oc_conn.prepareStatement(query);
                ps.setInt(1, iRealValue);
                ps.setString(2, name);
                if (ps.executeUpdate()>0) {
                    sOut += ("<span class='valid'>Updated with " + iRealValue + " instead of " + iActualNbValue + "</span>");
                } else {
                     //-- insert row if necessary --//
                    query = "insert into OC_COUNTERS(OC_COUNTER_NAME,OC_COUNTER_VALUE) values(?,?)";
                    ps.close();
                    ps = oc_conn.prepareStatement(query);
                    ps.setString(1, name);
                    ps.setInt(2, iRealValue);
                    if (ps.executeUpdate()>0) {
                         sOut += ("<span class='valid'>Row inserted with " + iRealValue + "</span>");
                    }else{
                          sOut += "<span class='error'>!! ERROR WITH THIS UPDATE !! " + query + " with " + iRealValue + " and " + name + "<br />see more information in the server logs...</span>";
                    }
                }
            }
            catch (Exception e) {
                e.printStackTrace();
            } finally {
                try {
                    if (rs != null) rs.close();
                    if (ps != null) ps.close();
                }
                catch (SQLException se) {
                    se.printStackTrace();
                }
            }
        }
        try {
			oc_conn.close();
		} catch (SQLException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
        return sOut;
    }
    private int getIntTotalTable(String table, String field, String bd)throws Exception{
        PreparedStatement ps = null;
        ResultSet rs = null;
        int nb = 0;
        Connection connection=null;
        try {
            String sSelect = "SELECT MAX("+field+")+1 as nb FROM " + table;
            if (bd.equals("openclinic")) {
            	connection=getOpenclinicConnection();
                ps = connection.prepareStatement(sSelect);
            } else if (bd.equals("admin")) {
            	connection=getAdminConnection();
                ps = connection.prepareStatement(sSelect);
	        } else if (bd.equals("stats")) {
	        	connection=getStatsConnection();
	            ps = connection.prepareStatement(sSelect);
	        }
            rs = ps.executeQuery();
            // get data from DB
            if (rs.next()) {
                nb = rs.getInt("nb");
            }
        }
        catch (Exception e) {
            throw e;
        } finally {
            try {
                if (rs != null) rs.close();
                if (ps != null) ps.close();
                connection.close();
            }
            catch (SQLException se) {
                se.printStackTrace();
            }
        }
        return nb;
    }
}