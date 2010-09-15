package be.openclinic.statistics;

import java.util.Date;
import java.util.Vector;
import java.util.Hashtable;

/**
 * User: Frank Verbeke
 * Date: 6-aug-2007
 * Time: 21:45:13
 */
public class ServiceStats {
    private String serviceUid;
    private Date begin;
    private Date end;

    private Vector periodStats;
    private int physiciansCount;
    private int a0count;
    private int a1count;
    private int a2count;
    private int aOthercount;
    private int technicalCount;

    public Vector getPeriodStats() {
        return periodStats;
    }

    public int getPhysiciansCount() {
        return physiciansCount;
    }

    public void setPhysiciansCount(int physiciansCount) {
        this.physiciansCount = physiciansCount;
    }

    public int getA0count() {
        return a0count;
    }

    public void setA0count(int a0count) {
        this.a0count = a0count;
    }

    public int getA1count() {
        return a1count;
    }

    public void setA1count(int a1count) {
        this.a1count = a1count;
    }

    public int getA2count() {
        return a2count;
    }

    public void setA2count(int a2count) {
        this.a2count = a2count;
    }

    public int getAOthercount() {
        return aOthercount;
    }

    public void setAOthercount(int aOthercount) {
        this.aOthercount = aOthercount;
    }

    public int getTechnicalCount() {
        return technicalCount;
    }

    public void setTechnicalCount(int technicalCount) {
        this.technicalCount = technicalCount;
    }

    public String getServiceUid() {
        return serviceUid;
    }

    public void setServiceUid(String serviceUid) {
        this.serviceUid = serviceUid;
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

    public ServiceStats(String serviceUid, Date begin, Date end) {
        this.serviceUid = serviceUid;
        this.begin = begin;
        this.end = end;
        initPeriodStats();
    }

    public void initPeriodStats(){
        ServicePeriodStats servicePeriodStats=null;
        periodStats=new Vector();
        for(long n=begin.getTime();n<end.getTime();n+=7*24*3600*1000){
            if(n+7*24*3600*1000-1<=end.getTime()){
                servicePeriodStats=new ServicePeriodStats(serviceUid,new Date(n),new Date(n+7*24*3600*1000-1));
            }
            else{
                servicePeriodStats=new ServicePeriodStats(serviceUid,new Date(n),new Date(end.getTime()+24*3600*1000-1));
            }
            servicePeriodStats.initialize();
            periodStats.add(servicePeriodStats);
        }
    }

    public double[] getPeriodPatients(){
        double[] d = new double[getPeriodStats().size()];
        for(int n=0;n<d.length;n++){
            d[n]=((ServicePeriodStats)getPeriodStats().elementAt(n)).getPatients();
        }
        return d;
    }

    public double[] getPeriodAdmissions(){
        double[] d = new double[getPeriodStats().size()];
        for(int n=0;n<d.length;n++){
            d[n]=((ServicePeriodStats)getPeriodStats().elementAt(n)).getAdmissions();
        }
        return d;
    }

    public double[] getPeriodAdmissionDays(){
        double[] d = new double[getPeriodStats().size()];
        for(int n=0;n<d.length;n++){
            d[n]=((ServicePeriodStats)getPeriodStats().elementAt(n)).getAdmissiondays();
        }
        return d;
    }

    public double[] getPeriodVisits(){
        double[] d = new double[getPeriodStats().size()];
        for(int n=0;n<d.length;n++){
            d[n]=((ServicePeriodStats)getPeriodStats().elementAt(n)).getVisits();
        }
        return d;
    }

    public Hashtable getPeriodTransactionTypes(){
        Hashtable transactionTypes = new Hashtable();
        for(int n=0;n<getPeriodStats().size();n++){
            ServicePeriodStats servicePeriodStats = (ServicePeriodStats)getPeriodStats().elementAt(n);
            for(int i=0;i<servicePeriodStats.getTransactionStats().size();i++){
                ServicePeriodTransactionStats tranStats = (ServicePeriodTransactionStats)servicePeriodStats.getTransactionStats().elementAt(i);
            }
        }
        return transactionTypes;
    }

    public double[] getPeriodTransactions(String transactionType){
        double[] d = new double[getPeriodStats().size()];
        for(int n=0;n<d.length;n++){
            ServicePeriodTransactionStats transactionStats=((ServicePeriodStats)getPeriodStats().elementAt(n)).getTransactionStats(transactionType);
            d[n]=transactionStats!=null?transactionStats.getCount():0;
        }
        return d;
    }

    public boolean nonPeriodVisitsZero(){
        for(int n=0;n<getPeriodStats().size();n++){
            if (((ServicePeriodStats)getPeriodStats().elementAt(n)).getVisits()>0) {
                return true;
            }
        }
        return false;
    }

    public boolean nonPeriodAdmissionsZero(){
        for(int n=0;n<getPeriodStats().size();n++){
            if (((ServicePeriodStats)getPeriodStats().elementAt(n)).getAdmissions()>0) {
                return true;
            }
        }
        return false;
    }

    public boolean nonPeriodAdmissionDaysZero(){
        for(int n=0;n<getPeriodStats().size();n++){
            if (((ServicePeriodStats)getPeriodStats().elementAt(n)).getAdmissiondays()>0) {
                return true;
            }
        }
        return false;
    }

    public boolean nonPeriodPatientsZero(){
        for(int n=0;n<getPeriodStats().size();n++){
            if (((ServicePeriodStats)getPeriodStats().elementAt(n)).getPatients()>0) {
                return true;
            }
        }
        return false;
    }

    public double[] getX(){
        double[] x = new double[getPeriodStats().size()];
        for(int n=0;n<x.length;n++){
            x[n]=n+1;
        }
        return x;
    }

    public double[] getPeriodPatientsY(){
        double[] x = new double[getPeriodStats().size()];
        for(int n=0;n<x.length;n++){
            x[n]=((ServicePeriodStats)getPeriodStats().elementAt(n)).getPatients();
        }
        return x;
    }

    public double[] getPeriodAdmissionsY(){
        double[] x = new double[getPeriodStats().size()];
        for(int n=0;n<x.length;n++){
            x[n]=((ServicePeriodStats)getPeriodStats().elementAt(n)).getAdmissions();
        }
        return x;
    }

    public double[] getPeriodAdmissionDaysY(){
        double[] x = new double[getPeriodStats().size()];
        for(int n=0;n<x.length;n++){
            x[n]=((ServicePeriodStats)getPeriodStats().elementAt(n)).getAdmissiondays();
        }
        return x;
    }

    public double[] getPeriodVisitsY(){
        double[] x = new double[getPeriodStats().size()];
        for(int n=0;n<x.length;n++){
            x[n]=((ServicePeriodStats)getPeriodStats().elementAt(n)).getVisits();
        }
        return x;
    }

}
