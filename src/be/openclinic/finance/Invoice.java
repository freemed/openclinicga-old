package be.openclinic.finance;

import be.mxs.common.util.system.ScreenHelper;
import be.openclinic.common.OC_Object;

import java.util.HashSet;
import java.util.Vector;
import java.util.Date;
import java.text.SimpleDateFormat;
import java.util.Iterator;

import net.admin.Service;

public class Invoice extends OC_Object {
    protected String invoiceUid;
    protected java.util.Date date;
    protected Vector debets;
    protected Vector credits;
    protected String status;
    protected double balance;
    protected String verifier;

    protected static SimpleDateFormat stdDateFormat = new SimpleDateFormat("dd/MM/yyyy");
    protected static SimpleDateFormat fullDateFormat = new SimpleDateFormat("dd/MM/yyyy HH:mm");
    

	//--- SETTERS & GETTERS -----------------------------------------------------------------------
    public String getInvoiceUid() {
        return invoiceUid;
    }

    public String getVerifier() {
		return verifier;
	}

	public void setVerifier(String verifier) {
		this.verifier = verifier;
	}

	public void setInvoiceUid(String invoiceUid) {
        this.invoiceUid = invoiceUid;
    }

    public java.util.Date getDate() {
        return date;
    }

    public void setDate(Date date) {
        this.date = date;
    }

    public Vector getDebets() {
        return debets;
    }

    public Vector getDebetsForInsurance(String sInsuranceUid) {
        Vector d = new Vector();
        for(int n=0;n<getDebets().size();n++){
            Debet debet = (Debet)getDebets().elementAt(n);
            if(debet!=null && sInsuranceUid.equalsIgnoreCase(debet.getInsuranceUid())){
                d.add(debet);
            }
        }
        return d;
    }

    public void setDebets(Vector debets) {
        this.debets = debets;
    }

    public Vector getCredits() {
        return credits;
    }

    public void setCredits(Vector credits) {
        this.credits = credits;
    }

    public String getStatus() {
       return status;
   }

   public void setStatus(String status) {
       this.status = status;
   }

   public double getBalance() {
       if(balance==1){
           return 0;
       }
       return balance;
   }

   public void setBalance(double balance) {
       this.balance = balance;
   }

   public HashSet getServices(){
	   HashSet services = new HashSet();
	   for(int n=0;n<debets.size();n++){
		   Debet debet = (Debet)debets.elementAt(n);
		   if(ScreenHelper.checkString(debet.getServiceUid()).length()>0){
			   services.add(debet.getServiceUid());
		   }
	   }
	   return services;
   }
   
   public String getServicesAsString(String language){
	   String service="";
	   HashSet services = new HashSet();
	   for(int n=0;n<debets.size();n++){
		   Debet debet = (Debet)debets.elementAt(n);
		   if(ScreenHelper.checkString(debet.getServiceUid()).length()>0){
			   services.add(debet.getServiceUid());
		   }
	   }
	   Iterator hs = services.iterator();
	   while(hs.hasNext()){
		   if(service.length()>0){
			   service+=", ";
		   }
		   service+=ScreenHelper.getTran("service", (String)hs.next(), language);
	   }
	   return service;
   }
   
   public Vector getDebetsForServiceUid(String serviceUid){
	   Vector serviceDebets = new Vector();
	   for(int n=0;n<debets.size();n++){
		   Debet debet = (Debet)debets.elementAt(n);
		   if(ScreenHelper.checkString(debet.getServiceUid()).equalsIgnoreCase(serviceUid)){
			   serviceDebets.add(debet);
		   }
	   }
	   return serviceDebets;
   }
}
