package be.openclinic.statistics;
import be.mxs.common.util.db.MedwanQuery;
import be.mxs.common.util.system.ScreenHelper;
import be.mxs.common.util.system.StatFunctions;
import be.openclinic.common.KeyValue;
import be.openclinic.statistics.DepartmentIncome.Income;

import java.text.SimpleDateFormat;
import java.util.Collection;
import java.util.Collections;
import java.util.Date;
import java.util.Enumeration;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Hashtable;
import java.util.Iterator;
import java.util.List;
import java.util.SortedSet;
import java.util.TreeSet;
import java.util.Vector;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

import net.admin.Service;
/**
 * User: Frank Verbeke
 * Date: 9-aug-2007
 * Time: 9:41:51
 */
public class HospitalStats {
    private Date begin;
    private Date end;
    private Hashtable encounters = new Hashtable();
    private Hashtable diagnoses = new Hashtable();
    private HashSet diagnosisencounter = new HashSet();
    private Hashtable statvalues = new Hashtable();
    private Hashtable departmentIncomes = new Hashtable();
    private Hashtable totalDepartmentIncomes;
    private Hashtable insurarAdmissions = new Hashtable();
    private Hashtable insurarVisits = new Hashtable();
    Hashtable admissiondiagnosisfrequencies;
    Hashtable visitdiagnosisfrequencies;
    Hashtable deliveryincomes;
    
    public Hashtable getInsurarAdmissions() {
		return insurarAdmissions;
	}
	public void setInsurarAdmissions(Hashtable insurarAdmissions) {
		this.insurarAdmissions = insurarAdmissions;
	}
	public Hashtable getInsurarVisits() {
		return insurarVisits;
	}
	public void setInsurarVisits(Hashtable insurarVisits) {
		this.insurarVisits = insurarVisits;
	}
	public Hashtable getTotalDepartmentIncomes() {
		return totalDepartmentIncomes;
	}
	public Hashtable getTotalCostcenterIncomes(){
		Hashtable csi = new Hashtable();
		Enumeration e = totalDepartmentIncomes.keys();
		while(e.hasMoreElements()){
			String id = (String)e.nextElement();
			Service service = Service.getService(id);
			String key = (service==null || service.costcenter==null || service.costcenter.length()==0?"?":service.costcenter);
			if(csi.get(key)==null){
				csi.put(key, totalDepartmentIncomes.get(id));
			}
			else {
				csi.put(key,new Double(((Double)csi.get(key)).doubleValue()+((Double)totalDepartmentIncomes.get(id)).doubleValue()));
			}
		}
		return csi;
	}
	public void setTotalDepartmentIncomes(Hashtable totalDepartmentIncomes) {
		this.totalDepartmentIncomes = totalDepartmentIncomes;
	}
	public Hashtable getDeliveryincomes() {
		return deliveryincomes;
	}
	public void setDeliveryincomes(Hashtable deliveryincomes) {
		this.deliveryincomes = deliveryincomes;
	}
	public Hashtable getDepartmentIncomes() {
		return departmentIncomes;
	}
	
	public Hashtable getAdmissiondiagnosisfrequencies() {
		return admissiondiagnosisfrequencies;
	}
	public void setAdmissiondiagnosisfrequencies(
			Hashtable admissiondiagnosisfrequencies) {
		this.admissiondiagnosisfrequencies = admissiondiagnosisfrequencies;
	}
	public Hashtable getVisitdiagnosisfrequencies() {
		return visitdiagnosisfrequencies;
	}
	public void setVisitdiagnosisfrequencies(Hashtable visitdiagnosisfrequencies) {
		this.visitdiagnosisfrequencies = visitdiagnosisfrequencies;
	}
	public void setDepartmentIncomes(Hashtable departmentIncomes) {
		this.departmentIncomes = departmentIncomes;
	}
	private static HospitalStats instance;
    public static HospitalStats getInstance() {
        if(instance==null)
            instance = new HospitalStats();
        return instance;
    }
     public static HospitalStats getInstance(String begin, String end)throws Exception{
        if(instance==null)
            instance = new HospitalStats(begin,end);
        return instance;
    }
    public Hashtable getEncounters() {
        return encounters;
    }
    public void setEncounters(Hashtable encounters) {
        this.encounters = encounters;
    }
    public Date getBegin() {
        return begin;
    }
    public void setBegin(Date begin) {
        this.begin = begin;
    }
    public Date getEnd() {
        return end;
    }
    public void setEnd(Date end) {
        this.end = end;
    }
    public HospitalStats(){
        //void
    }
    public HospitalStats(String begin, String end) throws Exception {
        this.begin = new SimpleDateFormat("dd/MM/yyyy").parse(begin);
        this.end = new SimpleDateFormat("dd/MM/yyyy").parse(end);
    }
    public HospitalStats(Date begin, Date end) {
        this.begin = begin;
        this.end = end;
    }
    public static double getOverheadCosts() {
        double cost = -1;
        String sQuery = MedwanQuery.getInstance().getConfigString("query.statistics.hospital.overheadcosts");
        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try {
            PreparedStatement ps = oc_conn.prepareStatement(sQuery);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                cost = rs.getDouble("cost");
            }
            rs.close();
            ps.close();
        }
        catch (Exception e) {
            e.printStackTrace();
        }
        try {
			oc_conn.close();
		} catch (SQLException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
        return cost;
    }
    public static int getBedCapacity() {
        int capacity = -1;
        String sQuery = "select count(*) total from OC_BEDS a,ServicesAddressView b where a.OC_BED_SERVICEUID=b.serviceid";
        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try {
            PreparedStatement ps = oc_conn.prepareStatement(sQuery);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                capacity = rs.getInt("total");
            }
            rs.close();
            ps.close();
        }
        catch (Exception e) {
            e.printStackTrace();
        }
        try {
			oc_conn.close();
		} catch (SQLException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
        return capacity;
    }
    public ServiceStats getServiceStats() {
        return new ServiceStats("", begin, end);
    }
    @SuppressWarnings("unchecked")
	public void loadEncounters(String codetype) {
        String serverid=MedwanQuery.getInstance().getConfigString("serverId")+".";
        String sql="select OC_ENCOUNTER_SERVERID,OC_ENCOUNTER_OBJECTID,OC_ENCOUNTER_PATIENTUID,OC_ENCOUNTER_BEGINDATE,OC_ENCOUNTER_ENDDATE,"+
        			" OC_ENCOUNTER_OUTCOME,OC_ENCOUNTER_TYPE,OC_DIAGNOSIS_SERVICEUID as OC_ENCOUNTER_SERVICEUID,OC_DIAGNOSIS_CODE,OC_DIAGNOSIS_GRAVITY,OC_DIAGNOSIS_CERTAINTY"+
        			" from"+
        			" OC_ENCOUNTERS a,OC_DIAGNOSES_VIEW b"+
        			" where"+
        			" a.OC_ENCOUNTER_ENDDATE>=? and"+
        			" a.OC_ENCOUNTER_BEGINDATE<=? and"+
        			" b.OC_DIAGNOSIS_ENCOUNTERUID='"+serverid+"'"+MedwanQuery.getInstance().concatSign()+MedwanQuery.getInstance().convert("varchar(10)","a.OC_ENCOUNTER_OBJECTID")+" and"+
        			" b.OC_DIAGNOSIS_CODETYPE=?"+
        			" union"+
        			" select OC_ENCOUNTER_SERVERID,OC_ENCOUNTER_OBJECTID,OC_ENCOUNTER_PATIENTUID,OC_ENCOUNTER_BEGINDATE,OC_ENCOUNTER_ENDDATE,"+
        			" OC_ENCOUNTER_OUTCOME,OC_ENCOUNTER_TYPE,OC_ENCOUNTER_SERVICEUID,null,null,null"+
        			" from"+
        			" OC_ENCOUNTERS_VIEW a"+
        			" where"+
        			" a.OC_ENCOUNTER_ENDDATE>=? and"+
        			" a.OC_ENCOUNTER_BEGINDATE<=? and"+
        			" not exists (select * from oc_diagnoses_view where OC_DIAGNOSIS_ENCOUNTERUID='"+serverid+"'"+MedwanQuery.getInstance().concatSign()+MedwanQuery.getInstance().convert("varchar(10)","a.OC_ENCOUNTER_OBJECTID")+" and OC_DIAGNOSIS_CODETYPE=?)"+
        			" ORDER BY OC_ENCOUNTER_BEGINDATE,OC_ENCOUNTER_SERVERID,OC_ENCOUNTER_OBJECTID";

        Connection loc_conn=MedwanQuery.getInstance().getLongOpenclinicConnection();
        try {
        	PreparedStatement ps = loc_conn.prepareStatement(sql);
            ps.setTimestamp(1, new java.sql.Timestamp(begin.getTime()));
            ps.setTimestamp(2, new java.sql.Timestamp(end.getTime()));
            ps.setString(3, codetype);
            ps.setTimestamp(4, new java.sql.Timestamp(begin.getTime()));
            ps.setTimestamp(5, new java.sql.Timestamp(end.getTime()));
            ps.setString(6, codetype);
            ResultSet rs = ps.executeQuery();
            String encounterUid, patientUid, outcome, type, service, diagnosis;
            Hashtable lastadmissions = new Hashtable();
            Hashtable lastvisits = new Hashtable();
            int readmissions6m = 0, readmissions12m = 0, readmissionPeriod = 0;
            int revisit6m = 0, revisit12m = 0, revisitPeriod = 0;
            long duration6m = 182 * 24 * 60;
            duration6m *= 60000;
            long duration12m = 365 * 24 * 60;
            duration12m *= 60000;
            long duration1w = 7 * 24 * 60;
            duration1w *= 60000;
            long duration1d = 24 * 60 * 60000;
            Date beginDate, endDate;
            Encounter encounter;
            boolean begincorrected,endcorrected;
            double gravity=1,certainty=1;
            double MAX_GRAVITY=MedwanQuery.getInstance().getConfigInt("maxgravity",1),MAX_CERTAINTY=MedwanQuery.getInstance().getConfigInt("maxcertainty",1);
            while (rs.next()) {
            	begincorrected=false;
            	endcorrected=false;
            	encounterUid = rs.getInt("OC_ENCOUNTER_SERVERID") + "." + rs.getInt("OC_ENCOUNTER_OBJECTID");
                patientUid = rs.getString("OC_ENCOUNTER_PATIENTUID");
                outcome = rs.getString("OC_ENCOUNTER_OUTCOME");
                type = rs.getString("OC_ENCOUNTER_TYPE");
                service = rs.getString("OC_ENCOUNTER_SERVICEUID");
                diagnosis = rs.getString("OC_DIAGNOSIS_CODE");
                gravity = rs.getInt("OC_DIAGNOSIS_GRAVITY");
                certainty=rs.getInt("OC_DIAGNOSIS_CERTAINTY");
                if(diagnosis==null){
                	diagnosis="?";
                }
                beginDate = rs.getDate("OC_ENCOUNTER_BEGINDATE");
                if (beginDate.before(begin)) {
                    beginDate = begin;
                    begincorrected=true;
                }
                endDate = rs.getDate("OC_ENCOUNTER_ENDDATE");
                if (endDate == null || endDate.after(end)) {
                    endDate = end;
                    endcorrected=true;
                }
                encounter = (Encounter) encounters.get(encounterUid);
                if (encounter == null) {
                    if (type.equalsIgnoreCase("admission")) {
                        if (lastadmissions.get(patientUid) != null) {
                            readmissionPeriod++;
                            if (beginDate.getTime() - ((Date) lastadmissions.get(patientUid)).getTime() < duration6m) {
                                readmissions6m++;
                            }
                            if (beginDate.getTime() - ((Date) lastadmissions.get(patientUid)).getTime() < duration12m) {
                                readmissions12m++;
                            }
                        }
                    } else if (type.equalsIgnoreCase("visit")) {
                        if (lastvisits.get(patientUid) != null) {
                            revisitPeriod++;
                            if (beginDate.getTime() - ((Date) lastvisits.get(patientUid)).getTime() < duration6m) {
                                revisit6m++;
                            }
                            if (beginDate.getTime() - ((Date) lastvisits.get(patientUid)).getTime() < duration12m) {
                                revisit12m++;
                            }
                        }
                    }
                    encounter = new Encounter(encounterUid, patientUid, beginDate, endDate, outcome, type, service);
                }
                encounter.addDiagnosis(diagnosis, gravity/MAX_GRAVITY, certainty/MAX_CERTAINTY);
                if(!diagnosisencounter.contains(encounterUid+"."+diagnosis)){
                	diagnosisencounter.add(encounterUid+"."+diagnosis);
	                if(diagnoses.get(diagnosis)==null){
	                	diagnoses.put(diagnosis,new Double(1));
	                }
	                else {
	                	diagnoses.put(diagnosis, new Double(((Double)diagnoses.get(diagnosis)).doubleValue()+1));
	                }
                }
                encounter.setBegincorrected(begincorrected);
                encounter.setEndcorrected(endcorrected);
                encounters.put(encounterUid, encounter);
                if (type.equalsIgnoreCase("admission")) {
                    lastadmissions.put(patientUid, beginDate);
                } else if (type.equalsIgnoreCase("visit")) {
                    lastvisits.put(patientUid, beginDate);
                }
            }
            rs.close();
            ps.close();
            //Now perform calculations
            //First declare a bunch of variables
            statvalues = new Hashtable();
            HashSet tpa = new HashSet(), tpv = new HashSet(), am = new HashSet();
            Hashtable dvp = new Hashtable();
            admissiondiagnosisfrequencies = new Hashtable();
            Hashtable admissiondiagnosispatientfrequencies = new Hashtable();
            visitdiagnosisfrequencies = new Hashtable();
            Hashtable visitdiagnosispatientfrequencies = new Hashtable();
            Hashtable admissiondiagnosisdeaths = new Hashtable();
            Vector admissionDurations = new Vector();
            int totalweeks = Math.round((end.getTime() - begin.getTime()) / duration1w) + 1;
            int totaldays = Math.round((end.getTime() - begin.getTime()) / duration1d) + 1;
            int[] dailyAdmittedPatients = new int[totaldays];
            int[] dailyVisitedPatients = new int[totaldays];
            int[] weeklyAdmissions = new int[totalweeks];
            int[] weeklyVisits = new int[totalweeks];
            int[] weeklyDeaths = new int[totalweeks];
            double[] weeklyIncome = new double[totalweeks];
            int ta = 0, tv = 0, tda = 0, tan=0;
            //Then loop through all encounters
            Enumeration e = encounters.elements();
            while (e.hasMoreElements()) {
                encounter = (Encounter) e.nextElement();
                int week = Math.round((encounter.getBegin().getTime() - begin.getTime()) / duration1w);
                int daystart = Math.round((encounter.getBegin().getTime() - begin.getTime()) / duration1d);
                int dayend = Math.round((encounter.getEnd().getTime() - begin.getTime()) / duration1d);
                if (encounter.isType("admission")) {
                    if(!encounter.isBegincorrected()){
                    	weeklyAdmissions[week]++;
                    	tan++;
                    }
                    for (int n = daystart; n < dayend + 1; n++) {
                        dailyAdmittedPatients[n]++;
                    }
                    tda += encounter.getDurationInDays();
                    admissionDurations.add(new Integer(encounter.getDurationInDays()));
                    ta++;
                    tpa.add(encounter.patientUid);
                    Enumeration e2 = encounter.diagnoses.keys();
                    while (e2.hasMoreElements()) {
                        String code = (String) e2.nextElement();
                        if (admissiondiagnosisfrequencies.get(code) == null) {
                            admissiondiagnosisfrequencies.put(code, new Integer(1));
                        } else {
                            admissiondiagnosisfrequencies.put(code, new Integer(((Integer) admissiondiagnosisfrequencies.get(code)).intValue() + 1));
                        }
                        if (admissiondiagnosispatientfrequencies.get(code) == null) {
                            admissiondiagnosispatientfrequencies.put(code, new HashSet());
                        }
                        ((HashSet) admissiondiagnosispatientfrequencies.get(code)).add(encounter.getPatientUid());
                        if (encounter!=null && encounter.getOutcome()!=null && encounter.getOutcome().equalsIgnoreCase("dead")) {
                            if (admissiondiagnosisdeaths.get(code) == null) {
                                admissiondiagnosisdeaths.put(code, new HashSet());
                            }
                            ((HashSet) admissiondiagnosisdeaths.get(code)).add(encounter.getPatientUid());
                        }
                    }
                } else if (encounter.isType("visit")) {
                    if (dvp.get(daystart + "") == null) {
                        dvp.put(daystart + "", new HashSet());
                    }
                    ((HashSet) dvp.get(daystart + "")).add(encounter.patientUid);
                    if(!encounter.isBegincorrected()){
                    	weeklyVisits[week]++;
                    }
                    tv++;
                    tpv.add(encounter.patientUid);
                    Enumeration e2 = encounter.diagnoses.keys();
                    while (e2.hasMoreElements()) {
                        String code = (String) e2.nextElement();
                        if (visitdiagnosisfrequencies.get(code) == null) {
                            visitdiagnosisfrequencies.put(code, new Integer(1));
                        } else {
                            visitdiagnosisfrequencies.put(code, new Integer(((Integer) visitdiagnosisfrequencies.get(code)).intValue() + 1));
                        }
                        if (visitdiagnosispatientfrequencies.get(code) == null) {
                            visitdiagnosispatientfrequencies.put(code, new HashSet());
                        }
                        ((HashSet) visitdiagnosispatientfrequencies.get(code)).add(encounter.getPatientUid());
                    }
                }
                if (encounter!=null && encounter.getOutcome()!=null && encounter.getOutcome().equalsIgnoreCase("dead")) {
                    am.add(encounter.getPatientUid());
                    if(!encounter.isBegincorrected()){
                    	weeklyDeaths[week]++;
                    }
                }
            }

            for (int n = 0; n < totaldays; n++) {
                dailyVisitedPatients[n] = dvp.get(n + "") != null ? ((HashSet) dvp.get(n + "")).size() : 0;
            }
            //Search for quartile values
            statvalues.put("MDA", StatFunctions.getMedian(admissionDurations));
            //Export variables to statvalues array
            statvalues.put("TPA", new Integer(tpa.size()));
            statvalues.put("TA", new Integer(ta));
            statvalues.put("TAN", new Integer(tan));
            statvalues.put("TDA", new Integer(tda));
            statvalues.put("TPV", new Integer(tpv.size()));
            statvalues.put("TV", new Integer(tv));
            statvalues.put("RA6", new Integer(readmissions6m));
            statvalues.put("RA12", new Integer(readmissions12m));
            statvalues.put("RAP", new Integer(readmissionPeriod));
            statvalues.put("RV6", new Integer(revisit6m));
            statvalues.put("RV12", new Integer(revisit12m));
            statvalues.put("RVP", new Integer(revisitPeriod));
            statvalues.put("AM", new Integer(am.size()));
            statvalues.put("WA", weeklyAdmissions);
            statvalues.put("WV", weeklyVisits);
            statvalues.put("DAP", dailyAdmittedPatients);
            statvalues.put("DVP", dailyVisitedPatients);
            statvalues.put("WD", weeklyDeaths);
            statvalues.put("T10FCCA", StatFunctions.getTop(admissiondiagnosisfrequencies, MedwanQuery.getInstance().getConfigInt("topxadmissiondiagnosisfrequencies",10)));
            Hashtable t10pfcca = new Hashtable();
            Enumeration e3 = admissiondiagnosispatientfrequencies.keys();
            while (e3.hasMoreElements()) {
                Object key = e3.nextElement();
                t10pfcca.put(key, new Integer(((HashSet) admissiondiagnosispatientfrequencies.get(key)).size()));
            }
            Hashtable t10ada = new Hashtable();
            Hashtable t10adar = new Hashtable();
            e3 = admissiondiagnosisdeaths.keys();
            while (e3.hasMoreElements()) {
                Object key = e3.nextElement();
                t10ada.put(key, new Integer(((HashSet) admissiondiagnosisdeaths.get(key)).size()));
                t10adar.put(key, new Double(100 * (double) ((HashSet) admissiondiagnosisdeaths.get(key)).size() / (double) ((HashSet) admissiondiagnosispatientfrequencies.get(key)).size()));
            }
            statvalues.put("T10ADA", StatFunctions.getTop(t10ada, 10));
            statvalues.put("T10ADAR", StatFunctions.getTop(t10adar, 10));
            statvalues.put("T10PFCCA", StatFunctions.getTop(t10pfcca, 10));
            statvalues.put("T10FCCV", StatFunctions.getTop(visitdiagnosisfrequencies, 10));
            Hashtable t10pfccv = new Hashtable();
            e3 = visitdiagnosispatientfrequencies.keys();
            while (e3.hasMoreElements()) {
                Object key = e3.nextElement();
                t10pfccv.put(key, new Integer(((HashSet) visitdiagnosispatientfrequencies.get(key)).size()));
            }
            statvalues.put("T10PFCCV", StatFunctions.getTop(t10pfccv, 10));
            //Health econometrics
            Hashtable h = new Hashtable();
            
            sql="select (select max(oc_insurar_name) from oc_insurars c, oc_insurances b where b.oc_insurance_objectid=replace(a.oc_debet_insuranceuid,'"+MedwanQuery.getInstance().getConfigString("serverId")+".','') and c.oc_insurar_objectid=replace(b.oc_insurance_insuraruid,'"+MedwanQuery.getInstance().getConfigString("serverId")+".','')) as oc_insurar_name"+
            	",a.oc_debet_objectid,b.oc_prestation_reftype,b.oc_prestation_code,a.oc_debet_serviceuid,c.oc_encounter_type,a.oc_debet_encounteruid,a.oc_debet_amount+a.oc_debet_insuraramount+"+MedwanQuery.getInstance().convert("float","a.oc_debet_extrainsuraramount")+" as amount"+
            	" from oc_debets a, oc_prestations b, oc_encounters c"+
            	" where"+
				" "+MedwanQuery.getInstance().convert("int","replace(a.oc_debet_prestationuid,'"+serverid+"','')")+"=b.oc_prestation_objectid and"+
				" "+MedwanQuery.getInstance().convert("int","replace(a.oc_debet_encounteruid,'"+serverid+"','')")+"=c.oc_encounter_objectid and"+
				" a.oc_debet_date <=? and"+
				" a.oc_debet_date >=?";
            ps = loc_conn.prepareStatement(sql);
            ps.setDate(1,new java.sql.Date(end.getTime()));
            ps.setDate(2,new java.sql.Date(begin.getTime()));
            rs=ps.executeQuery();
            String serviceid,prestationcode,prestationfamily,encountertype,encounteruid,debetuid,insurarname;
            Integer corrector;
            double amount;
            double totalIncome=0;
            while (rs.next()){
            	insurarname=rs.getString("oc_insurar_name");
            	if(insurarname==null || insurarname.trim().length()==0){
            		insurarname="?";
            	}
            	debetuid=rs.getInt("oc_debet_objectid")+"";
            	serviceid=ScreenHelper.checkString(rs.getString("oc_debet_serviceuid"));
            	encountertype=rs.getString("oc_encounter_type");
            	prestationcode=rs.getString("oc_prestation_code");
            	prestationfamily=rs.getString("oc_prestation_reftype");
            	encounteruid=rs.getString("oc_debet_encounteruid");
            	amount=rs.getDouble("amount");
           		totalIncome+=amount;
           		if(departmentIncomes.get(serviceid)==null){
            		departmentIncomes.put(serviceid, new DepartmentIncome());
            	}
            	((DepartmentIncome)departmentIncomes.get(serviceid)).putIncome(prestationcode, prestationfamily, amount,encountertype);
            	if(encounters.get(encounteruid)!=null){
            		encounter=(Encounter)encounters.get(encounteruid);
            		if(!encounter.begincorrected){
	                	if(encountertype.equalsIgnoreCase("admission")){
	                		if(insurarAdmissions.get(insurarname)==null){
	                			insurarAdmissions.put(insurarname, new HashSet());
	                		}
	                		((HashSet)insurarAdmissions.get(insurarname)).add(encounteruid);
	                	}
	                	else if(encountertype.equalsIgnoreCase("visit")){
	                		if(insurarVisits.get(insurarname)==null){
	                			insurarVisits.put(insurarname, new HashSet());
	                		}
	                		((HashSet)insurarVisits.get(insurarname)).add(encounteruid);
	                	}
            		}
                	encounter.addDelivery(prestationcode, amount);
            		encounter.addFamily(prestationfamily, amount);
                    int week = Math.round((encounter.getBegin().getTime() - begin.getTime()) / duration1w);
                    if(!encounter.isBegincorrected()){
                    	weeklyIncome[week]+=amount;
                    }
            	}
            	else {
            	}
            }
            rs.close();
            ps.close();
            statvalues.put("TI",new Double(totalIncome));
            statvalues.put("WI", weeklyIncome);
            Hashtable familyincomes = new Hashtable();
            deliveryincomes = new Hashtable();
            Enumeration di = departmentIncomes.keys();
            totalDepartmentIncomes=new Hashtable();
            while (di.hasMoreElements()){
            	String departmentCode= (String)di.nextElement();
            	DepartmentIncome departmentIncome = (DepartmentIncome)departmentIncomes.get(departmentCode);
            	Hashtable del = departmentIncome.getDeliveries();
            	Hashtable fam = departmentIncome.getFamilies();
            	totalDepartmentIncomes.put(departmentCode,new Double(departmentIncome.getTotalIncome()));
            	Enumeration dfi=fam.keys();
            	while (dfi.hasMoreElements()){
            		String key=(String)dfi.nextElement();
            		if(familyincomes.get(key)==null){
            			familyincomes.put(key,fam.get(key));
            		}
            		else {
            			familyincomes.put(key,new Double(((Double)familyincomes.get(key)).doubleValue()+((Double)fam.get(key)).doubleValue()));
            		}
            	}
            	dfi=del.keys();
            	while (dfi.hasMoreElements()){
            		String key=(String)dfi.nextElement();
            		if(deliveryincomes.get(key)==null){
            			deliveryincomes.put(key,del.get(key));
            		}
            		else {
            			deliveryincomes.put(key,new Double(((Double)deliveryincomes.get(key)).doubleValue()+((Double)del.get(key)).doubleValue()));
            		}
            	}
            }
            statvalues.put("IDF", StatFunctions.getTop(familyincomes, familyincomes.size()));
            statvalues.put("T10IDD", StatFunctions.getTop(deliveryincomes, 10));
            statvalues.put("T10IDS", StatFunctions.getTop(totalDepartmentIncomes, 10));
            Hashtable admissionDiagnosisCosts = new Hashtable(),visitDiagnosisCosts = new Hashtable();
            e=encounters.elements();
            while(e.hasMoreElements()){
            	Encounter enc = (Encounter)e.nextElement();
            	if(enc.isType("admission")){
	            	Hashtable d=enc.getDiagnosisCosts();
	            	Enumeration dc=d.keys();
	            	while (dc.hasMoreElements()){
	            		String key=(String)dc.nextElement();
	            		if(admissionDiagnosisCosts.get(key)==null){
	            			admissionDiagnosisCosts.put(key,d.get(key));
	            		}
	            		else {
	            			admissionDiagnosisCosts.put(key,new Double(((Double)admissionDiagnosisCosts.get(key)).doubleValue()+((Double)d.get(key)).doubleValue()));
	            		}
	            	}
            	}
            	else if(enc.isType("visit")){
	            	Hashtable d=enc.getDiagnosisCosts();
	            	Enumeration dc=d.keys();
	            	while (dc.hasMoreElements()){
	            		String key=(String)dc.nextElement();
	            		if(visitDiagnosisCosts.get(key)==null){
	            			visitDiagnosisCosts.put(key,d.get(key));
	            		}
	            		else {
	            			visitDiagnosisCosts.put(key,new Double(((Double)visitDiagnosisCosts.get(key)).doubleValue()+((Double)d.get(key)).doubleValue()));
	            		}
	            	}
            	}
            }
            KeyValue[] T10DRA=StatFunctions.getTop(admissionDiagnosisCosts,10);
            KeyValue[] T10DRV=StatFunctions.getTop(visitDiagnosisCosts,10);
            statvalues.put("T10DRA", T10DRA);
            statvalues.put("T10DRV", T10DRV);
            loc_conn.close();

        } catch (SQLException e) {
            // TODO Auto-generated catch block
            e.printStackTrace();
        }
    }
    public KeyValue[] getInsuranceCases(String encounterType){
    	Hashtable insurars = new Hashtable();
    	if(encounterType.equalsIgnoreCase("admission")){
    		insurars=insurarAdmissions;
    	}
    	else if(encounterType.equalsIgnoreCase("visit")){
    		insurars=insurarVisits;
    	}
    	KeyValue[] kv = new KeyValue[insurars.size()];
    	Enumeration e = insurars.keys();
    	String insurar;
    	Hashtable result = new Hashtable();
    	while(e.hasMoreElements()){
    		insurar = (String)e.nextElement();
    		result.put(insurar,Integer.valueOf(((HashSet)insurars.get(insurar)).size()));
    	}
    	return StatFunctions.getTop(result,result.size());
    }
    public static KeyValue[] getInsuranceCases(Date begin, Date end, String encounterType){
        String serverid=MedwanQuery.getInstance().getConfigString("serverId")+".";
    	Hashtable cases = new Hashtable();
        Connection loc_conn=MedwanQuery.getInstance().getLongOpenclinicConnection();
    	try{
    		String sql = "select count(distinct oc_debet_encounteruid) total, oc_insurar_name from ( select oc_debet_encounteruid,(select max(c.oc_insurar_name) from oc_insurars c, oc_insurances b where b.oc_insurance_objectid=replace(d.oc_debet_insuranceuid,'"+MedwanQuery.getInstance().getConfigString("serverId")+".','') and c.oc_insurar_objectid=replace(b.oc_insurance_insuraruid,'"+MedwanQuery.getInstance().getConfigString("serverId")+".','')) as oc_insurar_name"+
							" from oc_encounters a, oc_debets d"+
							" where"+
							" "+MedwanQuery.getInstance().convert("int","replace(d.oc_debet_encounteruid,'"+serverid+"','')")+"=a.oc_encounter_objectid and"+
							" a.oc_encounter_type=? and"+
							" a.oc_encounter_begindate >= ? and"+
							" a.oc_encounter_begindate <= ?) q"+ 
							" group by oc_insurar_name";
    		PreparedStatement ps = loc_conn.prepareStatement(sql);
    		ps.setString(1, encounterType);
    		ps.setTimestamp(2, new java.sql.Timestamp(begin.getTime()));
    		ps.setTimestamp(3, new java.sql.Timestamp(end.getTime()));
    		ResultSet rs = ps.executeQuery();
    		while(rs.next()){
    			String insurarname=rs.getString("oc_insurar_name");
    			cases.put(insurarname==null?"?":insurarname, new Integer(rs.getInt("total")));
    		}
    		rs.close();
    		ps.close();
    	}
    	catch(Exception e){
    		e.printStackTrace();
    	}
    	try {
			loc_conn.close();
		} catch (SQLException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
    	return StatFunctions.getTop(cases, cases.size());
    }
    public static KeyValue[] getInsuranceCasesBasic(Date begin, Date end, String encounterType){
        String serverid=MedwanQuery.getInstance().getConfigString("serverId")+".";
    	Hashtable cases = new Hashtable();
        Connection loc_conn=MedwanQuery.getInstance().getLongOpenclinicConnection();
    	try{
    		String sql = "select count(distinct a.oc_encounter_objectid) total, oc_insurar_name"+
							" from oc_encounters a, oc_insurances b, oc_insurars c"+
							" where"+
							" a.oc_encounter_patientuid=b.oc_insurance_patientuid and"+
							" a.oc_encounter_type=? and"+
							" "+MedwanQuery.getInstance().convert("int","replace(b.oc_insurance_insuraruid,'"+serverid+"','')")+"=c.oc_insurar_objectid and"+
							" a.oc_encounter_begindate >= ? and"+
							" a.oc_encounter_begindate <= ?"+ 
							" group by oc_insurar_name";
    		PreparedStatement ps = loc_conn.prepareStatement(sql);
    		ps.setString(1, encounterType);
    		ps.setTimestamp(2, new java.sql.Timestamp(begin.getTime()));
    		ps.setTimestamp(3, new java.sql.Timestamp(end.getTime()));
    		ResultSet rs = ps.executeQuery();
    		while(rs.next()){
    			String insurarname=rs.getString("oc_insurar_name");
    			cases.put(insurarname==null?"?":insurarname, new Integer(rs.getInt("total")));
    		}
    		rs.close();
    		ps.close();
    	}
    	catch(Exception e){
    		e.printStackTrace();
    	}
    	try {
			loc_conn.close();
		} catch (SQLException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
    	return StatFunctions.getTop(cases, cases.size());
    }
    public double getTI() {
        return ((Double) statvalues.get("TI")).doubleValue();
    }
    public int getTPA() {
        return ((Integer) statvalues.get("TPA")).intValue();
    }
    public int getTPV() {
        return ((Integer) statvalues.get("TPV")).intValue();
    }
    public int getTA() {
        return ((Integer) statvalues.get("TA")).intValue();
    }
    public int getTAN() {
        return ((Integer) statvalues.get("TAN")).intValue();
    }
    public int getTDA() {
        return ((Integer) statvalues.get("TDA")).intValue();
    }
    public int getTV() {
        return ((Integer) statvalues.get("TV")).intValue();
    }
    public int getMDA() {
        return ((Integer) statvalues.get("MDA")).intValue();
    }
    public int getRA6() {
        return ((Integer) statvalues.get("RA6")).intValue();
    }
    public int getRA12() {
        return ((Integer) statvalues.get("RA12")).intValue();
    }
    public int getRAP() {
        return ((Integer) statvalues.get("RAP")).intValue();
    }
    public int getRV6() {
        return ((Integer) statvalues.get("RV6")).intValue();
    }
    public int getRV12() {
        return ((Integer) statvalues.get("RV12")).intValue();
    }
    public int getRVP() {
        return ((Integer) statvalues.get("RVP")).intValue();
    }
    public int getAM() {
        return ((Integer) statvalues.get("AM")).intValue();
    }
    public int[] getWA() {
        return (int[]) statvalues.get("WA");
    }
    public BaseChart getWAChart() {
        return new BaseChart("weekly.admissions", "week", "number.of.admissions", getWA());
    }
    public int[] getWV() {
        return (int[]) statvalues.get("WV");
    }
    public double[] getWI() {
        return (double[]) statvalues.get("WI");
    }
    public BaseChart getWVChart() {
        return new BaseChart("weekly.visits", "week", "number.of.visits", getWV());
    }
    public BaseChart getWIChart() {
        return new BaseChart("weekly.income", "week", "amount", getWI());
    }
    public int[] getDAP() {
        return (int[]) statvalues.get("DAP");
    }
    public BaseChart getDAPChart() {
        return new BaseChart("daily.admitted.patients", "day", "number.of.patients", getDAP());
    }
    public int[] getDVP() {
        return (int[]) statvalues.get("DVP");
    }
    public BaseChart getDVPChart() {
        return new BaseChart("daily.visited.patients", "day", "number.of.patients", getDVP());
    }
    public int[] getWD() {
        return (int[]) statvalues.get("WD");
    }
    public BaseChart getWDChart() {
        return new BaseChart("weekly.deaths", "week", "number.of.deaths", getWD());
    }
    public KeyValue[] getT10FCCA() {
        return (KeyValue[]) statvalues.get("T10FCCA");
    }
    public PieChart getT10FCCAChart() {
        return new PieChart("top10.most.frequent.KPGS.number.of.admissions", getT10FCCA());
    }
    public KeyValue[] getT10PFCCA() {
        return (KeyValue[]) statvalues.get("T10PFCCA");
    }
    public PieChart getT10PFCCAChart() {
        return new PieChart("admission.top10.most.frequent.KPGS.number.of.patients", getT10PFCCA());
    }
    public KeyValue[] getT10ADA() {
        return (KeyValue[]) statvalues.get("T10ADA");
    }
    public PieChart getT10ADAChart() {
        return new PieChart("admission.top10.most.mortal.KPGS.number.of.deaths", getT10ADA());
    }
    public KeyValue[] getT10ADAR() {
        return (KeyValue[]) statvalues.get("T10ADAR");
    }
    public PieChart getT10ADARChart() {
        return new PieChart("admission.top10.most.mortal.KPGS.incode.number.of.deaths", getT10ADAR());
    }
    public KeyValue[] getT10FCCV() {
        return (KeyValue[]) statvalues.get("T10FCCV");
    }
    public PieChart getT10FVVCChart() {
        return new PieChart("visit.top10.most.frequent.KPGS.number.of.visits", getT10FCCV());
    }
    public KeyValue[] getT10PFCCV() {
        return (KeyValue[]) statvalues.get("T10PFCCV");
    }
    public PieChart getT10PFVVCChart() {
        return new PieChart("visit.top10.most.frequent.KPGS.incode.number.patients", getT10PFCCV());
    }

    public KeyValue[] getACP(String code){
    	Hashtable comorbidityCodes = new Hashtable();
    	double diagnosiscount=((Double)diagnoses.get(code)).doubleValue();
    	Enumeration e = encounters.elements();
    	while(e.hasMoreElements()){
    		Encounter encounter = (Encounter)e.nextElement();
    		if(encounter.isType("admission") && encounter.hasDiagnosis(code)){
    			Enumeration diagnoses = encounter.getDiagnoses().elements();
    			while(diagnoses.hasMoreElements()){
    				Diagnosis diagnosis = (Diagnosis)diagnoses.nextElement();
    				if(!code.equalsIgnoreCase(diagnosis.getCode())){
	    				if(comorbidityCodes.get(diagnosis.getCode())==null){
	    					comorbidityCodes.put(diagnosis.getCode(),new Double((double)100/diagnosiscount));
	    				}
	    				else {
	    					comorbidityCodes.put(diagnosis.getCode(),new Double(((Double)comorbidityCodes.get(diagnosis.getCode())).doubleValue()+(double)100/diagnosiscount));
	    				}
    				}
    			}
    		}
    	}
    	return StatFunctions.getTop(comorbidityCodes, 10);
    }
    
    public ColumnChart getACPChart(String code){
    	return new ColumnChart("admission.comorbidity.profile","kpgs.code","% cases",getACP(code));
    }
    
    public double getACPI(String code){
    	double index=0;
    	int counter=0;
    	Enumeration e = encounters.elements();
    	while(e.hasMoreElements()){
    		Encounter encounter = (Encounter)e.nextElement();
    		if(encounter.isType("admission") && encounter.hasDiagnosis(code)){
    			counter++;
    			index+=encounter.getAbsoluteMorbidityIndex();
    		}
    	}
    	return index/counter;
    }
    
    public KeyValue[] getACPW(String code){
    	Hashtable comorbidityCodes = new Hashtable();
    	double diagnosiscount=((Double)diagnoses.get(code)).doubleValue();
    	Enumeration e = encounters.elements();
    	while(e.hasMoreElements()){
    		Encounter encounter = (Encounter)e.nextElement();
    		if(encounter.isType("admission") && encounter.hasDiagnosis(code)){
    			Diagnosis thisDiagnosis = encounter.getDiagnosis(code);
    			double thisweight = thisDiagnosis.getCertainty()*thisDiagnosis.getGravity();
    			Enumeration diagnoses = encounter.getDiagnoses().elements();
    			while(diagnoses.hasMoreElements()){
    				Diagnosis diagnosis = (Diagnosis)diagnoses.nextElement();
    				if(!code.equalsIgnoreCase(diagnosis.getCode())){
	    				if(comorbidityCodes.get(diagnosis.getCode())==null){
	    					comorbidityCodes.put(diagnosis.getCode(),new Double((double)100*diagnosis.getCertainty()*diagnosis.getGravity()/(thisweight*diagnosiscount)));
	    				}
	    				else {
	    					comorbidityCodes.put(diagnosis.getCode(),new Double(((Double)comorbidityCodes.get(diagnosis.getCode())).doubleValue()+(double)100*diagnosis.getCertainty()*diagnosis.getGravity()/(thisweight*diagnosiscount)));
	    				}
    				}
    			}
    		}
    	}
    	return StatFunctions.getTop(comorbidityCodes, 10);
    }
    
    public ColumnChart getACPWChart(String code){
    	return new ColumnChart("admission.weighed.comorbidity.profile","kpgs.code","% weighed cases",getACPW(code));
    }
    
    public double getACPIW(String code){
    	double index=0;
    	int counter=0;
    	Enumeration e = encounters.elements();
    	while(e.hasMoreElements()){
    		Encounter encounter = (Encounter)e.nextElement();
    		if(encounter.isType("admission") && encounter.hasDiagnosis(code)){
    			counter++;
    			index+=encounter.getWeighedComorbidityIndex(code);
    		}
    	}
    	return index/counter;
    }
    
    public KeyValue[] getACMP(String code){
    	Hashtable comorbidityCodes = new Hashtable();
    	double diagnosiscount=getDeadAdmissionDiagnosisCount(code);
    	Enumeration e = encounters.elements();
    	while(e.hasMoreElements()){
    		Encounter encounter = (Encounter)e.nextElement();
    		if(encounter.isType("admission") && encounter.hasDiagnosis(code) && encounter.isOutcome("dead")){
    			Enumeration diagnoses = encounter.getDiagnoses().elements();
    			while(diagnoses.hasMoreElements()){
    				Diagnosis diagnosis = (Diagnosis)diagnoses.nextElement();
    				if(!code.equalsIgnoreCase(diagnosis.getCode())){
	    				if(comorbidityCodes.get(diagnosis.getCode())==null){
	    					comorbidityCodes.put(diagnosis.getCode(),new Double((double)100/diagnosiscount));
	    				}
	    				else {
	    					comorbidityCodes.put(diagnosis.getCode(),new Double(((Double)comorbidityCodes.get(diagnosis.getCode())).doubleValue()+(double)100/diagnosiscount));
	    				}
    				}
    			}
    		}
    	}
    	return StatFunctions.getTop(comorbidityCodes, 10);
    }
    
    public ColumnChart getACMPChart(String code){
    	return new ColumnChart("admission.comortality.profile","kpgs.code","% cases",getACMP(code));
    }
    
    public double getACMPI(String code){
    	double index=0;
    	int counter=0;
    	Enumeration e = encounters.elements();
    	while(e.hasMoreElements()){
    		Encounter encounter = (Encounter)e.nextElement();
    		if(encounter.isType("admission") && encounter.hasDiagnosis(code) && encounter.isOutcome("dead")){
    			counter++;
    			index+=encounter.getAbsoluteMorbidityIndex();
    		}
    	}
    	return index/counter;
    }
    
    public int getDeadAdmissionDiagnosisCount(String code){
    	int count=0;
    	Enumeration e = encounters.elements();
    	while(e.hasMoreElements()){
    		Encounter encounter = (Encounter)e.nextElement();
    		if(encounter.isType("admission") && encounter.hasDiagnosis(code) && encounter.isOutcome("dead")){
    			count++;
    		}
    	}
    	return count;
    }
    
    public int getAdmissionDiagnosisCount(String code){
    	int count=0;
    	Enumeration e = encounters.elements();
    	while(e.hasMoreElements()){
    		Encounter encounter = (Encounter)e.nextElement();
    		if(encounter.isType("admission") && encounter.hasDiagnosis(code)){
    			count++;
    		}
    	}
    	return count;
    }
    
    public int getAdmissionWithDeliveriesDiagnosisCount(String code){
    	int count=0;
    	Enumeration e = encounters.elements();
    	while(e.hasMoreElements()){
    		Encounter encounter = (Encounter)e.nextElement();
    		if(encounter.isType("admission") && encounter.hasDiagnosis(code) && encounter.deliveries.size()>0){
    			count++;
    		}
    	}
    	return count;
    }
    
    public int getDeadVisitDiagnosisCount(String code){
    	int count=0;
    	Enumeration e = encounters.elements();
    	while(e.hasMoreElements()){
    		Encounter encounter = (Encounter)e.nextElement();
    		if(encounter.isType("visit") && encounter.hasDiagnosis(code) && encounter.isOutcome("dead")){
    			count++;
    		}
    	}
    	return count;
    }
    
    public int getVisitDiagnosisCount(String code){
    	int count=0;
    	Enumeration e = encounters.elements();
    	while(e.hasMoreElements()){
    		Encounter encounter = (Encounter)e.nextElement();
    		if(encounter.isType("visit") && encounter.hasDiagnosis(code)){
    			count++;
    		}
    	}
    	return count;
    }
    
    public KeyValue[] getACMPW(String code){
    	Hashtable comorbidityCodes = new Hashtable();
    	double diagnosiscount=getDeadAdmissionDiagnosisCount(code);
    	Enumeration e = encounters.elements();
    	while(e.hasMoreElements()){
    		Encounter encounter = (Encounter)e.nextElement();
    		if(encounter.isType("admission") && encounter.hasDiagnosis(code) && encounter.isOutcome("dead")){
    			Diagnosis thisDiagnosis = encounter.getDiagnosis(code);
    			double thisweight = thisDiagnosis.getCertainty()*thisDiagnosis.getGravity();
    			Enumeration diagnoses = encounter.getDiagnoses().elements();
    			while(diagnoses.hasMoreElements()){
    				Diagnosis diagnosis = (Diagnosis)diagnoses.nextElement();
    				if(!code.equalsIgnoreCase(diagnosis.getCode())){
	    				if(comorbidityCodes.get(diagnosis.getCode())==null){
	    					comorbidityCodes.put(diagnosis.getCode(),new Double((double)100*diagnosis.getWeight()/(thisweight*diagnosiscount)));
	    				}
	    				else {
	    					comorbidityCodes.put(diagnosis.getCode(),new Double(((Double)comorbidityCodes.get(diagnosis.getCode())).doubleValue()+(double)100*diagnosis.getWeight()/(thisweight*diagnosiscount)));
	    				}
    				}
    			}
    		}
    	}
    	return StatFunctions.getTop(comorbidityCodes, 10);
    }
    
    public ColumnChart getACMPWChart(String code){
    	return new ColumnChart("admission.weighed.comortality.profile","kpgs.code","% weighed cases",getACMPW(code));
    }
    
    public double getACMPIW(String code){
    	double index=0;
    	int counter=0;
    	Enumeration e = encounters.elements();
    	while(e.hasMoreElements()){
    		Encounter encounter = (Encounter)e.nextElement();
    		if(encounter.isType("admission") && encounter.hasDiagnosis(code) && encounter.isOutcome("dead")){
    			counter++;
    			index+=encounter.getWeighedComorbidityIndex(code);
    		}
    	}
    	return index/counter;
    }
    
    public KeyValue[] getIDF() {
        return (KeyValue[]) statvalues.get("IDF");
    }
    public PieChart getIDFChart() {
        return new PieChart("income.distribution.per.family", getIDF());
    }

    public KeyValue[] getT10IDD() {
        return (KeyValue[]) statvalues.get("T10IDD");
    }
    public PieChart getT10IDDChart() {
        return new PieChart("top10.income.distribution.per.delivery", getT10IDD());
    }

    public KeyValue[] getT10IDS() {
        return (KeyValue[]) statvalues.get("T10IDS");
    }
    public PieChart getT10IDSChart() {
        return new PieChart("top10.income.distribution.per.department", getT10IDS());
    }
    
    public KeyValue[] getIDFSA(String serviceid){
    	DepartmentIncome departmentIncome = (DepartmentIncome)departmentIncomes.get(serviceid);
    	Hashtable fam=departmentIncome.getFamilies("admission");
    	return StatFunctions.getTop(fam, fam.size());
    }

    public KeyValue[] getIDFSA(String serviceid, int level){
    	DepartmentIncome departmentIncome = (DepartmentIncome)getDepartments(level).get(serviceid);
    	Hashtable fam=departmentIncome.getFamilies("admission");
    	return StatFunctions.getTop(fam, fam.size());
    }

    public PieChart getIDFSAChart(String serviceid) {
        return new PieChart("income.distribution.per.family.per.department.admissions", getIDFSA(serviceid));
    }

    public PieChart getIDFSAChart(String serviceid, int level) {
        return new PieChart("income.distribution.per.family.per.department.admissions", getIDFSA(serviceid,level));
    }

    public KeyValue[] getT10IDDSA(String serviceid){
    	DepartmentIncome departmentIncome = (DepartmentIncome)departmentIncomes.get(serviceid);
    	Hashtable del = departmentIncome.getDeliveries("admission");
    	return StatFunctions.getTop(del,10);
    }

    public KeyValue[] getT10IDDSA(String serviceid, int level){
    	DepartmentIncome departmentIncome = (DepartmentIncome)getDepartments(level).get(serviceid);
    	Hashtable del = departmentIncome.getDeliveries("admission");
    	return StatFunctions.getTop(del,10);
    }

    public PieChart getT10IDDSAChart(String serviceid) {
        return new PieChart("income.distribution.per.family.per.department.admissions", getT10IDDSA(serviceid));
    }

    public PieChart getT10IDDSAChart(String serviceid, int level) {
        return new PieChart("income.distribution.per.family.per.department.admissions", getT10IDDSA(serviceid, level));
    }

    public KeyValue[] getIDFSV(String serviceid){
    	DepartmentIncome departmentIncome = (DepartmentIncome)departmentIncomes.get(serviceid);
    	Hashtable fam=departmentIncome.getFamilies("visit");
    	return StatFunctions.getTop(fam, fam.size());
    }

    public KeyValue[] getIDFSV(String serviceid, int level){
    	DepartmentIncome departmentIncome = (DepartmentIncome)getDepartments(level).get(serviceid);
    	Hashtable fam=departmentIncome.getFamilies("visit");
    	return StatFunctions.getTop(fam, fam.size());
    }

    public PieChart getIDFSVChart(String serviceid) {
        return new PieChart("income.distribution.per.family.per.department.admissions", getIDFSA(serviceid));
    }

    public PieChart getIDFSVChart(String serviceid, int level) {
        return new PieChart("income.distribution.per.family.per.department.admissions", getIDFSA(serviceid, level));
    }

    public KeyValue[] getT10IDDSV(String serviceid){
    	DepartmentIncome departmentIncome = (DepartmentIncome)departmentIncomes.get(serviceid);
    	Hashtable del = departmentIncome.getDeliveries("visit");
    	return StatFunctions.getTop(del,10);
    }

    public KeyValue[] getT10IDDSV(String serviceid, int level){
    	DepartmentIncome departmentIncome = (DepartmentIncome)getDepartments(level).get(serviceid);
    	Hashtable del = departmentIncome.getDeliveries("visit");
    	return StatFunctions.getTop(del,10);
    }

    public PieChart getT10IDDSVChart(String serviceid) {
        return new PieChart("income.distribution.per.family.per.department.admissions", getT10IDDSA(serviceid));
    }
    
    public PieChart getT10IDDSVChart(String serviceid, int level) {
        return new PieChart("income.distribution.per.family.per.department.admissions", getT10IDDSA(serviceid, level));
    }
    
    public PieChart getT10DRAChart() {
        return new PieChart("top10.income.distribution.per.kpgs.code.admissions", getT10DRA());
    }

    public PieChart getT10DRVChart() {
        return new PieChart("top10.income.distribution.per.kpgs.code.visits", getT10DRV());
    }

    public PieChart getT10DRADChart(String code) {
        return new PieChart("income.distribution.per.clinical.condition.admissions", getT10DRAD(code));
    }
    
    public PieChart getT10DRVDChart(String code) {
        return new PieChart("income.distribution.per.clinical.condition.visits", getT10DRVD(code));
    }
    
    public KeyValue[] getDRARedistributed(){
    	return getDRCRedistributed("admission",0);
    }
    
    public KeyValue[] getT10DRARedistributed(){
    	return getDRCRedistributed("admission",10);
    }
    
    public KeyValue[] getDRA(){
    	return getDRC("admission",0);
    }
    
    public KeyValue[] getT10DRA(){
    	return getDRC("admission",10);
    }
    
    public KeyValue[] getDRV(){
    	return getDRC("visit",0);
    }
    
    public KeyValue[] getT10DRV(){
    	return getDRC("visit",10);
    }
    
    public KeyValue[] getT10DRVRedistributed(){
    	return getDRCRedistributed("visit",10);
    }
    
    public KeyValue[] getDRVRedistributed(){
    	return getDRCRedistributed("visit",0);
    }
    
    public KeyValue[] getDRAD(String code){
    	return getDRCD(code,"admission",0);
    }

    public KeyValue[] getT10DRAD(String code){
    	return getDRCD(code,"admission",10);
    }

    public KeyValue[] getDRVD(String code){
    	return getDRCD(code,"visit",0);
    }

    public KeyValue[] getT10DRVD(String code){
    	return getDRCD(code,"visit",10);
    }

    public KeyValue[] getT10DRADRedistributed(String code){
    	return getDRCDRedistributed(code, "admission",10);
    }

    public KeyValue[] getT10DRVDRedistributed(String code){
    	return getDRCDRedistributed(code, "visit",10);
    }

    public KeyValue[] getDRC(String contactType,int count){
    	Hashtable consumingDiagnoses = new Hashtable();
    	Enumeration e = encounters.elements();
    	while(e.hasMoreElements()){
    		Encounter encounter = (Encounter)e.nextElement();
    		if(encounter.isType(contactType)){
    			Enumeration dia = encounter.getDiagnoses().keys();
    			while(dia.hasMoreElements()){
    				String code=(String)dia.nextElement();
	    			Hashtable deliveries = encounter.getDiagnosisDeliveries(code);
	    			Enumeration d = deliveries.keys();
	    			while(d.hasMoreElements()){
	    				String key = (String)d.nextElement();
	    				if(consumingDiagnoses.get(code)==null){
	    					consumingDiagnoses.put(code,deliveries.get(key));
	    				}
	    				else {
	    					consumingDiagnoses.put(code, new Double(((Double)consumingDiagnoses.get(code)).doubleValue()+((Double)deliveries.get(key)).doubleValue()));
	    				}
	    			}
	    		}
    		}
    	}
    	return StatFunctions.getTop(consumingDiagnoses, count>0?count:consumingDiagnoses.size());
    }
    
    public KeyValue[] getDRCRedistributed(String contactType,int count){
    	Hashtable consumingDiagnoses = new Hashtable();
    	Enumeration e = encounters.elements();
    	while(e.hasMoreElements()){
    		Encounter encounter = (Encounter)e.nextElement();
    		if(encounter.isType(contactType)){
    			Enumeration dia = encounter.getDiagnoses().keys();
    			while(dia.hasMoreElements()){
    				String code=(String)dia.nextElement();
	    			Hashtable deliveries = encounter.getDiagnosisDeliveries(code);
	    			Enumeration d = deliveries.keys();
	    			while(d.hasMoreElements()){
	    				String key = (String)d.nextElement();
	    				if(consumingDiagnoses.get(code)==null){
	    					consumingDiagnoses.put(code,deliveries.get(key));
	    				}
	    				else {
	    					consumingDiagnoses.put(code, new Double(((Double)consumingDiagnoses.get(code)).doubleValue()+((Double)deliveries.get(key)).doubleValue()));
	    				}
	    			}
	    		}
    		}
    	}
    	double unknownDiagnosisAmount=((Double)consumingDiagnoses.get("?")).doubleValue();
    	double totalIncomeRemaining = getTI()-unknownDiagnosisAmount;
    	e = consumingDiagnoses.keys();
    	while(e.hasMoreElements()){
    		String key = (String)e.nextElement();
    		consumingDiagnoses.put(key,new Double(((Double)consumingDiagnoses.get(key)).doubleValue()+((Double)consumingDiagnoses.get(key)).doubleValue()*unknownDiagnosisAmount/totalIncomeRemaining));
    	}
    	consumingDiagnoses.remove("?");
    	return StatFunctions.getTop(consumingDiagnoses, count>0?count:consumingDiagnoses.size());
    }
    
    public KeyValue[] getDRCD(String code,String contactType,int count){
    	Hashtable diagnosisDeliveries = new Hashtable();
    	Enumeration e = encounters.elements();
    	while(e.hasMoreElements()){
    		Encounter encounter = (Encounter)e.nextElement();
    		if(encounter.isType(contactType) && encounter.hasDiagnosis(code)){
    			Hashtable deliveries = encounter.getDiagnosisDeliveries(code);
    			Enumeration d = deliveries.keys();
    			while(d.hasMoreElements()){
    				String key = (String)d.nextElement();
    				if(diagnosisDeliveries.get(key)==null){
    					diagnosisDeliveries.put(key,deliveries.get(key));
    				}
    				else {
    					diagnosisDeliveries.put(key, new Double(((Double)diagnosisDeliveries.get(key)).doubleValue()+((Double)deliveries.get(key)).doubleValue()));
    				}
    			}
    		}
    	}
    	return StatFunctions.getTop(diagnosisDeliveries, count>0?count:diagnosisDeliveries.size());
    }

    public KeyValue[] getDRCDRedistributed(String code,String contactType,int count){
    	Hashtable diagnosisDeliveries = new Hashtable();
    	Enumeration e = encounters.elements();
    	while(e.hasMoreElements()){
    		Encounter encounter = (Encounter)e.nextElement();
    		if(encounter.isType(contactType) && encounter.hasDiagnosis(code)){
    			Hashtable deliveries = encounter.getDiagnosisDeliveries(code);
    			Enumeration d = deliveries.keys();
    			while(d.hasMoreElements()){
    				String key = (String)d.nextElement();
    				if(diagnosisDeliveries.get(key)==null){
    					diagnosisDeliveries.put(key,deliveries.get(key));
    				}
    				else {
    					diagnosisDeliveries.put(key, new Double(((Double)diagnosisDeliveries.get(key)).doubleValue()+((Double)deliveries.get(key)).doubleValue()));
    				}
    			}
    		}
    	}
    	Hashtable consumingDiagnoses = new Hashtable();
    	double unknownDiagnosisAmount=0;
    	e = encounters.elements();
    	while(e.hasMoreElements()){
    		Encounter encounter = (Encounter)e.nextElement();
    		if(encounter.isType("admission") && encounter.hasDiagnosis("?")){
    			Hashtable deliveries = encounter.getDiagnosisDeliveries("?");
    			Enumeration d = deliveries.keys();
    			while(d.hasMoreElements()){
    				String key = (String)d.nextElement();
   					unknownDiagnosisAmount+=((Double)deliveries.get(key)).doubleValue();
    			}
    		}
    	}
    	double totalIncomeRemaining = getTI()-unknownDiagnosisAmount;
    	e = consumingDiagnoses.keys();
    	while(e.hasMoreElements()){
    		String key = (String)e.nextElement();
    		consumingDiagnoses.put(key,new Double(((Double)consumingDiagnoses.get(key)).doubleValue()+((Double)consumingDiagnoses.get(key)).doubleValue()*unknownDiagnosisAmount/totalIncomeRemaining));
    	}
    	consumingDiagnoses.remove("?");
    	return StatFunctions.getTop(diagnosisDeliveries, count>0?count:diagnosisDeliveries.size());
    }

    public String[] getIncomeDepartments(){
    	SortedSet deps = new TreeSet();
    	Enumeration e = departmentIncomes.keys();
    	while(e.hasMoreElements()){
    		String key = (String)e.nextElement();
    		DepartmentIncome departmentIncome = (DepartmentIncome)departmentIncomes.get(key);
    		if(departmentIncome.getTotalIncome()>0){
    			deps.add(key);
    		}
    	}
    	String[] d = new String[deps.size()];
    	Iterator i=deps.iterator();
    	int counter=0;
    	while(i.hasNext()){
    		d[counter]=(String)i.next();
    		counter++;
    	}
    	return d;
    }

    public String[] getIncomeDepartments(int level){
    	SortedSet deps = new TreeSet();
    	Hashtable departmentIncomes=getDepartments(level);
    	Enumeration e = departmentIncomes.keys();
    	while(e.hasMoreElements()){
    		String key = (String)e.nextElement();
    		DepartmentIncome departmentIncome = (DepartmentIncome)departmentIncomes.get(key);
    		if(departmentIncome.getTotalIncome()>0){
    			deps.add(key);
    		}
    	}
    	String[] d = new String[deps.size()];
    	Iterator i=deps.iterator();
    	int counter=0;
    	while(i.hasNext()){
    		d[counter]=(String)i.next();
    		counter++;
    	}
    	return d;
    }

    public String[] getIncomeDepartments(String encounterType){
    	SortedSet deps = new TreeSet();
    	Enumeration e = departmentIncomes.keys();
    	while(e.hasMoreElements()){
    		String key = (String)e.nextElement();
    		DepartmentIncome departmentIncome = (DepartmentIncome)departmentIncomes.get(key);
    		if(departmentIncome.getEncounterTypeIncome(encounterType)>0){
    			deps.add(key);
    		}
    	}
    	String[] d = new String[deps.size()];
    	Iterator i=deps.iterator();
    	int counter=0;
    	while(i.hasNext()){
    		d[counter]=(String)i.next();
    		counter++;
    	}
    	return d;
    }
    
    public String[] getIncomeDepartments(String encounterType, int level){
    	SortedSet deps = new TreeSet();
    	Hashtable departmentIncomes=getDepartments(level);
    	Enumeration e = departmentIncomes.keys();
    	while(e.hasMoreElements()){
    		String key = (String)e.nextElement();
    		DepartmentIncome departmentIncome = (DepartmentIncome)departmentIncomes.get(key);
    		if(departmentIncome.getEncounterTypeIncome(encounterType)>0){
    			deps.add(key);
    		}
    	}
    	String[] d = new String[deps.size()];
    	Iterator i=deps.iterator();
    	int counter=0;
    	while(i.hasNext()){
    		d[counter]=(String)i.next();
    		counter++;
    	}
    	return d;
    }
    
    public String[] getIncomeCostcenters(String encounterType, int level){
    	SortedSet deps = new TreeSet();
    	Hashtable departmentIncomes=getCostcenters(level);
    	Enumeration e = departmentIncomes.keys();
    	while(e.hasMoreElements()){
    		String key = (String)e.nextElement();
    		DepartmentIncome departmentIncome = (DepartmentIncome)departmentIncomes.get(key);
    		if(departmentIncome.getEncounterTypeIncome(encounterType)>0){
    			deps.add(key);
    		}
    	}
    	String[] d = new String[deps.size()];
    	Iterator i=deps.iterator();
    	int counter=0;
    	while(i.hasNext()){
    		d[counter]=(String)i.next();
    		counter++;
    	}
    	return d;
    }
    
    public Hashtable getDepartments(int level){
    	Hashtable dps = new Hashtable();
    	Enumeration e = departmentIncomes.keys();
    	while (e.hasMoreElements()){
    		String key = (String)e.nextElement();
    		DepartmentIncome departmentIncome = (DepartmentIncome)departmentIncomes.get(key);
    		String levelkey="";
    		if(key.split("\\.").length<level){
    			levelkey=key;
    		}
    		else {
    			for(int n=0;n<level;n++){
    				if(n>0){
    					levelkey+=".";
    				}
    				levelkey+=key.split("\\.")[n];
    			}
    		}
    		DepartmentIncome dep = (DepartmentIncome)dps.get(levelkey);
    		if(dep==null){
    			dep=new DepartmentIncome();
    			dps.put(levelkey,dep);
    		}
    		Iterator i = departmentIncome.getIncomes().iterator();
    		while (i.hasNext()){
    			Income income = (Income)i.next();
        		dep.putIncome(income.deliveryCode, income.familyCode, income.amount, income.encounterType);
    		}
    	}
    	return dps;
    }

    public Hashtable getCostcenters(int level){
    	Hashtable dps = new Hashtable();
    	Enumeration e = departmentIncomes.keys();
    	while (e.hasMoreElements()){
    		String key = (String)e.nextElement();
    		DepartmentIncome departmentIncome = (DepartmentIncome)departmentIncomes.get(key);
    		Service service = Service.getService(key);
    		String levelkey=(service!=null && service.costcenter!=null?service.costcenter:"?");
    		DepartmentIncome dep = (DepartmentIncome)dps.get(levelkey);
    		if(dep==null){
    			dep=new DepartmentIncome();
    			dps.put(levelkey,dep);
    		}
    		Iterator i = departmentIncome.getIncomes().iterator();
    		while (i.hasNext()){
    			Income income = (Income)i.next();
        		dep.putIncome(income.deliveryCode, income.familyCode, income.amount, income.encounterType);
    		}
    	}
    	return dps;
    }

}
