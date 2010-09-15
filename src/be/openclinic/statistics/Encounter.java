package be.openclinic.statistics;

import java.util.Date;
import java.util.Enumeration;
import java.util.Hashtable;

public class Encounter {
	boolean begincorrected,endcorrected;
	String encounterUid;
	String patientUid;
	Date begin;
	Date end;
	String outcome;
	String type;
	String service;
	Hashtable diagnoses;
	Hashtable deliveries=new Hashtable();
	Hashtable families=new Hashtable();
	
	public boolean isBegincorrected() {
		return begincorrected;
	}

	public void setBegincorrected(boolean begincorrected) {
		this.begincorrected = begincorrected;
	}

	public boolean isEndcorrected() {
		return endcorrected;
	}

	public void setEndcorrected(boolean endcorrected) {
		this.endcorrected = endcorrected;
	}

	public Hashtable getFamilies() {
		return families;
	}

	public void setFamilies(Hashtable families) {
		this.families = families;
	}

	public Hashtable getDeliveries() {
		return deliveries;
	}

	public void setDeliveries(Hashtable deliveries) {
		this.deliveries = deliveries;
	}

	public Encounter(String encounterUid,String patientUid,Date begin,Date end, String outcome, String type,String service){
		this.encounterUid=encounterUid;
		this.patientUid=patientUid;
		this.begin=begin;
		this.end=end;
		if(end==null){
			this.end=new Date();
		}
		this.outcome=outcome;
		this.type=type;
		this.service=service;
		diagnoses=new Hashtable();
	}
	
	public String getService() {
		return service;
	}

	public void setService(String service) {
		this.service = service;
	}

	public String getOutcome() {
		return outcome;
	}

	public String getType() {
		return type;
	}

	public void setType(String type) {
		this.type = type;
	}

	public void setOutcome(String outcome) {
		this.outcome = outcome;
	}

	public String getEncounterUid() {
		return encounterUid;
	}
	
	public void setEncounterUid(String encounterUid) {
		this.encounterUid = encounterUid;
	}
	
	public String getPatientUid() {
		return patientUid;
	}
	
	public void setPatientUid(String patientUid) {
		this.patientUid = patientUid;
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
	
	public Hashtable getDiagnoses() {
		return diagnoses;
	}
	
	public void setDiagnoses(Hashtable diagnoses) {
		this.diagnoses = diagnoses;
	}
	
	public void addDiagnosis(String code, double gravity, double certainty){
		Diagnosis diagnosis = new Diagnosis(code,gravity,certainty);
		diagnoses.put(code,diagnosis);
	}
	
	public void addDelivery(String code, double amount){
		if(code!=null){
			if(deliveries.get(code)==null){
				deliveries.put(code, new Double(amount));
			}
			else {
				deliveries.put(code,new Double(((Double)deliveries.get(code)).doubleValue()+amount));
			}
		}
	}
	
	public void addFamily(String code, double amount){
		if(code!=null){
			if(families.get(code)==null){
				families.put(code, new Double(amount));
			}
			else {
				families.put(code,new Double(((Double)families.get(code)).doubleValue()+amount));
			}
		}
	}
	
	public int getDurationInDays(){
		double duration=0;
		long millis = end.getTime()-begin.getTime();
		double day = 24*60*60000;
		duration = millis/day;
		if(duration==0){
			duration=1;
		}
		return new Double(duration).intValue()+1;
	}
	
	public boolean hasDiagnosis(String code){
		return diagnoses.get(code)!=null;
	}
	
	public int getAbsoluteMorbidityIndex(){
		return diagnoses.size();
	}
	
	public double getWeighedMorbidityIndex(){
		double index = 0;
		Enumeration e = diagnoses.elements();
		while(e.hasMoreElements()){
			Diagnosis diagnosis = (Diagnosis)e.nextElement();
			index += diagnosis.getGravity()*diagnosis.getCertainty();
		}
		return index;
	}
	
	public Diagnosis getDiagnosis(String code){
		return (Diagnosis)diagnoses.get(code);
	}
	
	public double getWeighedComorbidityIndex(String code){
		double index = 1;
		if(hasDiagnosis(code)){
			double diagnosisWeight=((Diagnosis)getDiagnoses().get(code)).getWeight();
			Enumeration e = diagnoses.elements();
			while(e.hasMoreElements()){
				Diagnosis diagnosis = (Diagnosis)e.nextElement();
				if(!diagnosis.getCode().equalsIgnoreCase(code)){
					index += diagnosis.getGravity()*diagnosis.getCertainty()/diagnosisWeight;
				}
			}
		}
		return index;
	}
	
	public boolean isOutcome(String outcome){
		return this.outcome.equalsIgnoreCase(outcome);
	}
	
	public boolean isType(String type){
		return this.type.equalsIgnoreCase(type);
	}

	public double getTotalCost(){
		double cost=0;
		Enumeration e = deliveries.elements();
		while (e.hasMoreElements()){
			cost+=((Double)e.nextElement()).doubleValue();
		}
		return cost;
	}
	
	public Hashtable getDiagnosisCosts(){
		double totalCost=getTotalCost();
		double totalWeight=getWeighedMorbidityIndex();
		Hashtable diagnosisCosts = new Hashtable();
		Enumeration e = diagnoses.keys();
		while (e.hasMoreElements()){
			String key=(String)e.nextElement();
			Diagnosis diagnosis = (Diagnosis)diagnoses.get(key);
			diagnosisCosts.put(key, new Double(totalCost*diagnosis.getWeight()/totalWeight));
		}
		return diagnosisCosts;
	}
	
	public Hashtable getDiagnosisDeliveries(String code){
		Hashtable diagnosisDeliveries = new Hashtable();
		double totalWeight=getWeighedMorbidityIndex();
		Diagnosis diagnosis = (Diagnosis)diagnoses.get(code);
		if(diagnosis!=null){
			Enumeration e = deliveries.keys();
			while (e.hasMoreElements()){
				String key=(String)e.nextElement();
				diagnosisDeliveries.put(key, new Double(((Double)deliveries.get(key)).doubleValue()*diagnosis.getWeight()/totalWeight));
			}
		}
		return diagnosisDeliveries;
	}
}
