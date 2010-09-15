package org.hnrw.report;

import be.mxs.common.util.db.MedwanQuery;
import be.openclinic.adt.Encounter;

import java.util.Vector;
import java.util.Date;
import java.util.Hashtable;
import java.util.Enumeration;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;

/**
 * Created by IntelliJ IDEA.
 * User: Frank
 * Date: 17-jan-2009
 * Time: 19:34:26
 * To change this template use File | Settings | File Templates.
 */
public class Report_Transaction extends Report {
    public Vector transactions=new Vector();

    public class TRAN{
        String transactionUid;
        String transactionType;
        String itemType;
        String itemValue;
        long ageInDays;
        String gender;
        Date updatetime;
        int personid;

        public Date getUpdatetime() {
            return updatetime;
        }

        public int getPersonid() {
            return personid;
        }

        public void setPersonid(int personid) {
            this.personid = personid;
        }

        public void setUpdatetime(Date updatetime) {
            this.updatetime = updatetime;
        }

        public String getTransactionUid() {
            return transactionUid;
        }

        public void setTransactionUid(String transactionUid) {
            this.transactionUid = transactionUid;
        }

        public String getTransactionType() {
            return transactionType;
        }

        public void setTransactionType(String transactionType) {
            this.transactionType = transactionType;
        }

        public String getItemType() {
            return itemType;
        }

        public void setItemType(String itemType) {
            this.itemType = itemType;
        }

        public String getItemValue() {
            return itemValue;
        }

        public void setItemValue(String itemValue) {
            this.itemValue = itemValue;
        }

        public long getAgeInDays() {
            return ageInDays;
        }

        public void setAgeInDays(long ageInDays) {
            this.ageInDays = ageInDays;
        }

        public String getGender() {
            return gender;
        }

        public void setGender(String gender) {
            this.gender = gender;
        }

        public boolean checkGender(String gender){
            return gender.toLowerCase().indexOf(getGender().toLowerCase())>-1;
        }

        public boolean checkAge(int minage,int maxage){
            return minage<=getAgeInDays() && maxage>=getAgeInDays();
        }
    }

    public Vector getTransactions() {
        return transactions;
    }

    public void setTransactions(Vector transactions) {
        this.transactions = transactions;
    }

    public Report_Transaction(Date begin, Date end){
        transactions= new Vector();
        //We zoeken alle transacties op voor de gevraagde periode
        PreparedStatement ps;
        ResultSet rs;
        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            String sQuery="SELECT a.dateofbirth,a.gender,a.personid,c.serverid,c.transactionId,c.transactionType,c.updateTime,d.type,d.value from AdminView a,Healthrecord b,Transactions c,Items d" +
                    " where" +
                    " a.personid=b.personid and" +
                    " b.healthRecordId=c.healthRecordId and" +
                    " c.serverid=d.serverid and" +
                    " c.transactionId=d.transactionid and" +
                    " c.updateTime>=? and" +
                    " c.updateTime<=?";
            ps=oc_conn.prepareStatement(sQuery);
            ps.setDate(1,new java.sql.Date(begin.getTime()));
            ps.setDate(2,new java.sql.Date(end.getTime()));
            rs=ps.executeQuery();
            while(rs.next()){
                TRAN tran = new TRAN();
                tran.gender=rs.getString("gender");
                if("mf".indexOf(tran.gender.toLowerCase())<0){
                    tran.gender="m";
                }
                tran.ageInDays=6000l;
                Date dateofbirth = rs.getDate("dateofbirth");
                Date transactiondate = rs.getDate("updateTime");
                if(dateofbirth!=null && transactiondate!=null){
                    long t = transactiondate.getTime()-dateofbirth.getTime();
                    tran.ageInDays=t/(1000*3600*24);
                }
                tran.transactionType=rs.getString("transactionType");
                tran.itemType=rs.getString("type");
                tran.itemValue=rs.getString("value");
                tran.transactionUid=rs.getInt("serverid")+"."+rs.getInt("transactionId");
                tran.updatetime=rs.getDate("updatetime");
                tran.personid=rs.getInt("personid");
                transactions.add(tran);
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
    }

    public int count(int minAgeInDays,int maxAgeInDays,String gender,String transactionType,String item){
        String [] items = item.split(";");
        Hashtable trans=new Hashtable();
        Hashtable its=new Hashtable();
        for(int n=0;n<transactions.size();n++){
            TRAN tran = (TRAN)transactions.elementAt(n);
            for(int i=0;i<items.length;i++){
                String itemType=items[i].split(",")[0];
                String itemValue="";
                if(items[i].split(",").length>1){
                    itemValue=items[i].split(",")[1];
                }
                if(tran.checkGender(gender) && tran.checkAge(minAgeInDays,maxAgeInDays) && transactionType.equalsIgnoreCase(tran.getTransactionType()) && itemType.equalsIgnoreCase(tran.getItemType()) && itemValue.equals(tran.getItemValue())){
                    if(trans.get(tran.getTransactionUid())==null){
                        trans.put(tran.getTransactionUid(),new Integer(1));
                    }
                    else {
                        trans.put(tran.getTransactionUid(),new Integer(((Integer)trans.get(tran.getTransactionUid())).intValue()+1));
                    }
                }
            }
        }
        Enumeration t = trans.keys();
        while(t.hasMoreElements()){
            Object el=t.nextElement();
            if(((Integer)trans.get(el)).intValue()<items.length){
                trans.remove(el);
            }
        }
        return trans.size();
    }

    public int countWithoutLocation(String gender,String transactionType,String item){
        String [] items = item.split(";");
        Hashtable trans=new Hashtable();
        Hashtable its=new Hashtable();
        for(int n=0;n<transactions.size();n++){
            TRAN tran = (TRAN)transactions.elementAt(n);
            for(int i=0;i<items.length;i++){
                String itemType=items[i].split(",")[0];
                String itemValue="";
                if(items[i].split(",").length>1){
                    itemValue=items[i].split(",")[1];
                }
                if(tran.checkGender(gender) && transactionType.equalsIgnoreCase(tran.getTransactionType()) && itemType.equalsIgnoreCase(tran.getItemType()) && itemValue.equals(tran.getItemValue())){
                    if(trans.get(tran.getTransactionUid())==null){
                        trans.put(tran.getTransactionUid(),new Integer(1));
                    }
                    else {
                        trans.put(tran.getTransactionUid(),new Integer(((Integer)trans.get(tran.getTransactionUid())).intValue()+1));
                    }
                }
            }
        }
        Enumeration t = trans.keys();
        while(t.hasMoreElements()){
            Object el=t.nextElement();
            if(((Integer)trans.get(el)).intValue()<items.length){
                trans.remove(el);
            }
        }
        return trans.size();
    }

    public int count(int minAgeInDays,int maxAgeInDays,String gender,String transactionType,String itemType,String value){
        Hashtable trans=new Hashtable();
        for(int n=0;n<transactions.size();n++){
            TRAN tran = (TRAN)transactions.elementAt(n);
            if(tran.checkGender(gender) && tran.checkAge(minAgeInDays,maxAgeInDays) && transactionType.equalsIgnoreCase(tran.getTransactionType()) && itemType.equalsIgnoreCase(tran.getItemType()) && value.equals(tran.getItemValue())){
                trans.put(tran.getTransactionUid(),"1");
            }
        }
        return trans.size();
    }

    public int count(String situation,String gender,String transactionType,String itemType,String value){
        Hashtable trans=new Hashtable();
        for(int n=0;n<transactions.size();n++){
            TRAN tran = (TRAN)transactions.elementAt(n);
            if(tran.checkGender(gender) && transactionType.equalsIgnoreCase(tran.getTransactionType()) && itemType.equalsIgnoreCase(tran.getItemType()) && value.equals(tran.getItemValue())){
                Encounter encounter = Encounter.getActiveEncounterOnDate(new Timestamp(tran.updatetime.getTime()),tran.personid+"");
                if(encounter!=null && situation.equalsIgnoreCase(encounter.getSituation())){
                    trans.put(tran.getTransactionUid(),"1");
                }
            }
        }
        return trans.size();
    }

    public int countSmaller(String situation,String gender,String transactionType,String itemType,double value){
        Hashtable trans=new Hashtable();
        for(int n=0;n<transactions.size();n++){
            TRAN tran = (TRAN)transactions.elementAt(n);
            if(tran.checkGender(gender) && transactionType.equalsIgnoreCase(tran.getTransactionType()) && itemType.equalsIgnoreCase(tran.getItemType())){
                try{
                    double val = Double.parseDouble(tran.getItemValue());
                    Encounter encounter = Encounter.getActiveEncounterOnDate(new Timestamp(tran.updatetime.getTime()),tran.personid+"");
                    if(val<value && encounter!=null && situation.equalsIgnoreCase(encounter.getSituation())){
                        trans.put(tran.getTransactionUid(),"1");
                    }
                }
                catch(Exception e){}
            }
        }
        return trans.size();
    }

    public int countSmallerWithoutLocation(String gender,String transactionType,String itemType,double value){
        Hashtable trans=new Hashtable();
        for(int n=0;n<transactions.size();n++){
            TRAN tran = (TRAN)transactions.elementAt(n);
            if(tran.checkGender(gender) && transactionType.equalsIgnoreCase(tran.getTransactionType()) && itemType.equalsIgnoreCase(tran.getItemType())){
                try{
                    double val = Double.parseDouble(tran.getItemValue());
                    trans.put(tran.getTransactionUid(),"1");
                }
                catch(Exception e){}
            }
        }
        return trans.size();
    }

    public int countBigger(String situation,String gender,String transactionType,String itemType,double value){
        Hashtable trans=new Hashtable();
        for(int n=0;n<transactions.size();n++){
            TRAN tran = (TRAN)transactions.elementAt(n);
            if(tran.checkGender(gender) && transactionType.equalsIgnoreCase(tran.getTransactionType()) && itemType.equalsIgnoreCase(tran.getItemType())){
                try{
                    double val = Double.parseDouble(tran.getItemValue());
                    Encounter encounter = Encounter.getActiveEncounterOnDate(new Timestamp(tran.updatetime.getTime()),tran.personid+"");
                    if(val>value && encounter!=null && situation.equalsIgnoreCase(encounter.getSituation())){
                        trans.put(tran.getTransactionUid(),"1");
                    }
                }
                catch(Exception e){}
            }
        }
        return trans.size();
    }

    public int count(String situation,String gender,String transactionType){
        Hashtable trans=new Hashtable();
        for(int n=0;n<transactions.size();n++){
            TRAN tran = (TRAN)transactions.elementAt(n);
            if(tran.checkGender(gender) && transactionType.equalsIgnoreCase(tran.getTransactionType())){
                Encounter encounter = Encounter.getActiveEncounterOnDate(new Timestamp(tran.updatetime.getTime()),tran.personid+"");
                if(encounter!=null && situation.equalsIgnoreCase(encounter.getSituation())){
                    trans.put(tran.getTransactionUid(),"1");
                }
            }
        }
        return trans.size();
    }

    public int countWithoutLocation(String gender,String transactionType){
        Hashtable trans=new Hashtable();
        for(int n=0;n<transactions.size();n++){
            TRAN tran = (TRAN)transactions.elementAt(n);
            if(tran.checkGender(gender) && transactionType.equalsIgnoreCase(tran.getTransactionType())){
                trans.put(tran.getTransactionUid(),"1");
            }
        }
        return trans.size();
    }

    public int countWithoutLocation(String gender,String transactionType,String itemType,String value){
        Hashtable trans=new Hashtable();
        for(int n=0;n<transactions.size();n++){
            TRAN tran = (TRAN)transactions.elementAt(n);
            if(tran.checkGender(gender) && transactionType.equalsIgnoreCase(tran.getTransactionType()) && itemType.equalsIgnoreCase(tran.getItemType()) && value.equals(tran.getItemValue())){
                trans.put(tran.getTransactionUid(),"1");
            }
        }
        return trans.size();
    }

    public int count(String situation,String gender,String transactionType,String itemType){
        Hashtable trans=new Hashtable();
        for(int n=0;n<transactions.size();n++){
            TRAN tran = (TRAN)transactions.elementAt(n);
            if(tran.checkGender(gender) && transactionType.equalsIgnoreCase(tran.getTransactionType()) && itemType.equalsIgnoreCase(tran.getItemType())){
                Encounter encounter = Encounter.getActiveEncounterOnDate(new Timestamp(tran.updatetime.getTime()),tran.personid+"");
                if(encounter!=null && situation.equalsIgnoreCase(encounter.getSituation())){
                    trans.put(tran.getTransactionUid(),"1");
                }
            }
        }
        return trans.size();
    }

    public int countWithOutcome(String situation,String gender,String transactionType,String itemType,String value,String outcome){
        Hashtable trans=new Hashtable();
        for(int n=0;n<transactions.size();n++){
            TRAN tran = (TRAN)transactions.elementAt(n);
            if(tran.checkGender(gender) && transactionType.equalsIgnoreCase(tran.getTransactionType()) && itemType.equalsIgnoreCase(tran.getItemType()) && value.equals(tran.getItemValue())){
                Encounter encounter = Encounter.getActiveEncounterOnDate(new Timestamp(tran.updatetime.getTime()),tran.personid+"");
                if(encounter!=null && situation.equalsIgnoreCase(encounter.getSituation()) && outcome.equalsIgnoreCase(encounter.getOutcome())){
                    trans.put(tran.getTransactionUid(),"1");
                }
            }
        }
        return trans.size();
    }

    public int countWithOutcomeNoLocation(String gender,String transactionType,String itemType,String value,String outcome){
        Hashtable trans=new Hashtable();
        for(int n=0;n<transactions.size();n++){
            TRAN tran = (TRAN)transactions.elementAt(n);
            if(tran.checkGender(gender) && transactionType.equalsIgnoreCase(tran.getTransactionType()) && itemType.equalsIgnoreCase(tran.getItemType()) && value.equals(tran.getItemValue())){
                Encounter encounter = Encounter.getActiveEncounterOnDate(new Timestamp(tran.updatetime.getTime()),tran.personid+"");
                if(encounter!=null && outcome.equalsIgnoreCase(encounter.getOutcome())){
                    trans.put(tran.getTransactionUid(),"1");
                }
            }
        }
        return trans.size();
    }
}
