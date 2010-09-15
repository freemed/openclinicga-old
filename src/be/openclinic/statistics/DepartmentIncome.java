package be.openclinic.statistics;

import java.util.Enumeration;
import java.util.Hashtable;
import java.util.Vector;

public class DepartmentIncome {
	Hashtable deliveries = new Hashtable();
	Hashtable families = new Hashtable();
	Hashtable encounterTypeIncome = new Hashtable();
	Vector incomes = new Vector();
	
	public class Income{
		String deliveryCode;
		String familyCode;
		double amount;
		String encounterType;
		
		public Income(String deliveryCode, String familyCode, double amount,
				String encounterType) {
			super();
			this.deliveryCode = deliveryCode;
			this.familyCode = familyCode;
			this.amount = amount;
			this.encounterType = encounterType;
		}
	}

	public void putIncome(String deliveryCode, String familyCode, double amount, String encounterType){
		incomes.add(new Income(deliveryCode,familyCode,amount,encounterType));
		if(encounterType!=null){
			if(encounterTypeIncome.get(encounterType)==null){
				encounterTypeIncome.put(encounterType,new Double(amount));
			}
			else {
				encounterTypeIncome.put(encounterType, new Double(((Double)encounterTypeIncome.get(encounterType)).doubleValue()+amount));
			}
		}
		if(deliveryCode!=null){
			if(deliveries.get(deliveryCode)==null){
				deliveries.put(deliveryCode, new Hashtable());
			}
			Hashtable deliveryCodeIncome = (Hashtable)deliveries.get(deliveryCode);
			if(encounterType!=null){
				if(deliveryCodeIncome.get(encounterType)==null){
					deliveryCodeIncome.put(encounterType,new Double(amount));
				}
				else {
					deliveryCodeIncome.put(encounterType, new Double(((Double)deliveryCodeIncome.get(encounterType)).doubleValue()+amount));
				}
			}
		}
		if(familyCode!=null){
			if(families.get(familyCode)==null){
				families.put(familyCode, new Hashtable());
			}
			Hashtable familyCodeIncome = (Hashtable)families.get(familyCode);
			if(encounterType!=null){
				if(familyCodeIncome.get(encounterType)==null){
					familyCodeIncome.put(encounterType,new Double(amount));
				}
				else {
					familyCodeIncome.put(encounterType, new Double(((Double)familyCodeIncome.get(encounterType)).doubleValue()+amount));
				}
			}
		}
	}
	
	public Vector getIncomes() {
		return incomes;
	}

	public double getEncounterTypeIncome(String encounterType){
		if(encounterTypeIncome.get(encounterType)==null){
			return 0;
		}
		else {
			return ((Double)encounterTypeIncome.get(encounterType)).doubleValue();
		}
	}
	
	public Hashtable getDeliveries(){
		Hashtable h = new Hashtable();
		Enumeration e = deliveries.keys();
		while(e.hasMoreElements()){
			String key=(String)e.nextElement();
			Hashtable incomes = (Hashtable)deliveries.get(key);
			Enumeration i = incomes.elements();
			while(i.hasMoreElements()){
				if(h.get(key)==null){
					h.put(key, i.nextElement());
				}
				else {
					h.put(key, new Double(((Double)h.get(key)).doubleValue()+((Double)i.nextElement()).doubleValue()));
				}
			}
		}
		return h;
	}
	
	public Hashtable getFamilies(){
		Hashtable h = new Hashtable();
		Enumeration e = families.keys();
		while(e.hasMoreElements()){
			String key=(String)e.nextElement();
			Hashtable incomes = (Hashtable)families.get(key);
			Enumeration i = incomes.elements();
			while(i.hasMoreElements()){
				if(h.get(key)==null){
					h.put(key, i.nextElement());
				}
				else {
					h.put(key, new Double(((Double)h.get(key)).doubleValue()+((Double)i.nextElement()).doubleValue()));
				}
			}
		}
		return h;
	}
	
	public Hashtable getDeliveries(String encounterType){
		Hashtable h = new Hashtable();
		Enumeration e = deliveries.keys();
		while(e.hasMoreElements()){
			String key=(String)e.nextElement();
			Hashtable incomes = (Hashtable)deliveries.get(key);
			if(incomes.get(encounterType)!=null){
				h.put(key, incomes.get(encounterType));
			}
		}
		return h;
	}
	
	public Hashtable getFamilies(String encounterType){
		Hashtable h = new Hashtable();
		Enumeration e = families.keys();
		while(e.hasMoreElements()){
			String key=(String)e.nextElement();
			Hashtable incomes = (Hashtable)families.get(key);
			if(incomes.get(encounterType)!=null){
				h.put(key, incomes.get(encounterType));
			}
		}
		return h;
	}
	
	public double getTotalIncome(){
		double income=0;
		Enumeration e = deliveries.elements();
		while(e.hasMoreElements()){
			Hashtable incomes = (Hashtable)e.nextElement();
			Enumeration i = incomes.elements();
			while(i.hasMoreElements()){
				income+=((Double)i.nextElement()).doubleValue();
			}
		}
		return income;
	}

}
