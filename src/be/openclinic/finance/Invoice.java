package be.openclinic.finance;

import be.openclinic.common.OC_Object;

import java.util.Vector;
import java.util.Date;
import java.text.SimpleDateFormat;

public class Invoice extends OC_Object {
    protected String invoiceUid;
    protected java.util.Date date;
    protected Vector debets;
    protected Vector credits;
    protected String status;
    protected double balance;

    protected static SimpleDateFormat stdDateFormat = new SimpleDateFormat("dd/MM/yyyy");
    protected static SimpleDateFormat fullDateFormat = new SimpleDateFormat("dd/MM/yyyy HH:mm");
    

    //--- SETTERS & GETTERS -----------------------------------------------------------------------
    public String getInvoiceUid() {
        return invoiceUid;
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

}
