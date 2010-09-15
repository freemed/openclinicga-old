package be.mxs.statistics;

import be.mxs.common.util.db.MedwanQuery;
import be.mxs.common.util.system.Miscelaneous;
import be.mxs.common.model.vo.healthrecord.HealthRecordVO;
import be.dpms.medwan.common.model.vo.occupationalmedicine.RiskProfileVO;
import be.dpms.medwan.common.model.vo.administration.PersonVO;

import java.util.*;
import java.sql.*;
import java.sql.Date;
import java.text.SimpleDateFormat;
import java.io.IOException;

public class YearReport {
    public PersonVO activePerson;
    public HealthRecordVO activeMedicalRecord;
    public RiskProfileVO activeRiskProfile;
    private int year,count,percent=0;
    private Connection longOccupdbConnection;
    private java.util.Date begin,end;
    private Hashtable results=new Hashtable();
    private Collection tests;
    private javax.servlet.jsp.JspWriter out;

    public void printResults(){
        Enumeration keys=results.keys();
        while (keys.hasMoreElements()){
            String key = (String)keys.nextElement();
            try {
                out.print(key+": "+results.get(key)+"<br/>");
            } catch (IOException e) {
                e.printStackTrace();
            }
        }
    }

    public javax.servlet.jsp.JspWriter getOut() {
        return out;
    }

    public void setOut(javax.servlet.jsp.JspWriter out) {
        this.out = out;
    }

    public YearReport(Collection tests){
        this.tests=tests;
    }

    public java.util.Date getBegin() {
        return begin;
    }

    public void setBegin(java.util.Date begin) {
        this.begin = begin;
    }

    public java.util.Date getEnd() {
        return end;
    }

    public void setEnd(java.util.Date end) {
        this.end = end;
    }

    public int getYear() {
        return year;
    }

    public void setYear(int year) {
        this.year = year;
    }

    private void initCommon(int year){
        this.year=year;
        results = new Hashtable();
        count=0;
        longOccupdbConnection = MedwanQuery.getInstance().getLongOpenclinicConnection();
        begin =Miscelaneous.parseDate("01/01/"+year);
        end =Miscelaneous.parseDate("31/12/"+year);
    }

    private void initCommon(java.util.Date begin,java.util.Date end){
        year=new Integer(new SimpleDateFormat("yyyy").format(begin)).intValue();
        initCommon(year);
        this.begin =begin;
        this.end =end;
    }

    public void initializeServiceBase(String serviceId){
        try {
            int total=0;
            PreparedStatement ps = longOccupdbConnection.prepareStatement("select count(distinct ad.personid) total from AdminView ad,WorkView2 a,ServicesViewYearReport b where ad.personid=a.personid and (a.passive is null or a.passive='') and a.workid=b.workid and a.start<? and (a.stop is null or a.stop>?) and (ad.pension is null or ad.pension>?) and b.serviceid like ?");
            ps.setDate(1,new Date(end.getTime()));
            ps.setDate(2,new Date(begin.getTime()));
            ps.setDate(3,new Date(begin.getTime()));
            ps.setString(4,serviceId+"%");
            ResultSet rs = ps .executeQuery();
            if (rs.next()){
                total=rs.getInt("total");
            }
            rs.close();
            ps.close();
            writeStatus(total);
            ps = longOccupdbConnection.prepareStatement("select distinct ad.personid from AdminView ad,WorkView2 a,ServicesViewYearReport b where ad.personid=a.personid and (a.passive is null or a.passive='') and a.workid=b.workid and a.start<? and (a.stop is null or a.stop>?) and (ad.pension is null or ad.pension>?) and b.serviceid like ?");
            ps.setDate(1,new Date(end.getTime()));
            ps.setDate(2,new Date(begin.getTime()));
            ps.setDate(3,new Date(begin.getTime()));
            ps.setString(4,serviceId+"%");
            rs = ps .executeQuery();
            while (rs.next()){
                Iterator iterator = tests.iterator();
                while (iterator.hasNext()){
                    RecordAction test = (RecordAction)(Class.forName((String)iterator.next()).newInstance());
                    try {test.evaluate(rs.getInt("personid"),this);} catch(Exception z){z.printStackTrace();}
                }
                count++;
                if (count%5==0){
                    writeStatus(total);
                }
            }
            writeStatus(total);
            rs.close();
            ps.close();
        } catch (SQLException e) {
            e.printStackTrace();
        } catch (ClassNotFoundException e) {
            e.printStackTrace();
        } catch (InstantiationException e) {
            e.printStackTrace();
        } catch (IllegalAccessException e) {
            e.printStackTrace();
        }
    }

    public int initializeService(String serviceId,java.util.Date begin,java.util.Date end){
        initCommon(begin, end);
        initializeServiceBase(serviceId);
        return count;
    }

    public int initializeService(String serviceId, int year){
        initCommon(year);
        initializeServiceBase(serviceId);
        return count;
    }

    public int initializeServiceGroup(String serviceGroupId,java.util.Date begin,java.util.Date end){
        initCommon(begin, end);
        initializeServiceGroupBase(serviceGroupId);
        return count;
    }

    public int initializeServiceGroup(String serviceGroupId, int year){
        initCommon(year);
        initializeServiceGroupBase(serviceGroupId);
        return count;
    }

    public void initializeServiceGroupBase(String serviceGroupId){
        try {
            int total=0;
            PreparedStatement ps = longOccupdbConnection.prepareStatement("select count(distinct ad.personid) total from AdminView ad,WorkView2 a,ServicesViewYearReport b,UnitGroupsView c where ad.personid=a.personid and (a.passive is null or a.passive='') and b.serviceid=c.linkId and a.workid=b.workid and a.start<? and (a.stop is null or a.stop>?) and (ad.pension is null or ad.pension>?) and c.groupName=?");
            ps.setDate(1,new Date(end.getTime()));
            ps.setDate(2,new Date(begin.getTime()));
            ps.setDate(3,new Date(begin.getTime()));
            ps.setString(4,serviceGroupId);
            ResultSet rs = ps .executeQuery();
            if (rs.next()){
                total=rs.getInt("total");
            }
            rs.close();
            ps.close();
            writeStatus(total);
            ps = longOccupdbConnection.prepareStatement("select distinct ad.personid from AdminView ad,WorkView2 a,ServicesViewYearReport b,UnitGroupsView c where ad.personid=a.personid and (a.passive is null or a.passive='') and b.serviceid=c.linkId and a.workid=b.workid and a.start<? and (a.stop is null or a.stop>?) and (ad.pension is null or ad.pension>?) and c.groupName=?");
            ps.setDate(1,new Date(end.getTime()));
            ps.setDate(2,new Date(begin.getTime()));
            ps.setDate(3,new Date(begin.getTime()));
            ps.setString(4,serviceGroupId);
            rs = ps .executeQuery();
            while (rs.next()){
                Iterator iterator = tests.iterator();
                while (iterator.hasNext()){
                    RecordAction test = (RecordAction)(Class.forName((String)iterator.next()).newInstance());
                    try {test.evaluate(rs.getInt("personid"),this);} catch(Exception z){z.printStackTrace();}
                }
                count++;
                if (count%5==0){
                    writeStatus(total);
                }
            }
            writeStatus(total);
            rs.close();
            ps.close();
        } catch (SQLException e) {
            e.printStackTrace();
        } catch (ClassNotFoundException e) {
            e.printStackTrace();
        } catch (InstantiationException e) {
            e.printStackTrace();
        } catch (IllegalAccessException e) {
            e.printStackTrace();
        }
    }

    private void writeStatus(int total){
        if (total>0){
            int pct = count*100/total;
            try {
                if (out!=null && pct!=percent){
                    percent=pct;
                    out.print("<script>window.status='Period "+new SimpleDateFormat("dd/MM/yyyy").format(begin)+"-"+new SimpleDateFormat("dd/MM/yyyy").format(end)+": "+percent+"% ("+Integer.parseInt(new SimpleDateFormat("MM").format(end))/3+"/4)'</script>");
                    out.flush();
                }
            } catch (IOException e) {
                e.printStackTrace();
            }
        }
    }
    public int initializeAll(java.util.Date begin,java.util.Date end){
        initCommon(begin,end);
        initializeAllBase();
        return count;
    }

    public int initializeAll(int year){
        initCommon(year);
        initializeAllBase();
        return count;
    }

    public void initializeAllBase(){
        try {
            int total=0;
            PreparedStatement ps = longOccupdbConnection.prepareStatement("select count(distinct ad.personid) total from AdminView ad,WorkView2 a where ad.personid=a.personid and (a.passive is null or a.passive='') and start<? and (stop is null or stop>?)");
            ps.setDate(1,new Date(end.getTime()));
            ps.setDate(2,new Date(begin.getTime()));
            ResultSet rs = ps .executeQuery();
            if (rs.next()){
                total=rs.getInt("total");
            }
            rs.close();
            ps.close();
            writeStatus(total);
            ps = longOccupdbConnection.prepareStatement("select distinct ad.personid from AdminView ad,WorkView2 a where ad.personid=a.personid and (a.passive is null or a.passive='') and start<? and (stop is null or stop>?)");
            ps.setDate(1,new Date(end.getTime()));
            ps.setDate(2,new Date(begin.getTime()));
            rs = ps .executeQuery();
            while (rs.next()){
                Iterator iterator = tests.iterator();
                while (iterator.hasNext()){
                    RecordAction test = (RecordAction)(Class.forName((String)iterator.next()).newInstance());
                    try {test.evaluate(rs.getInt("personid"),this);} catch(Exception z){z.printStackTrace();}
                }
                count++;
                if (count%5==0){
                    writeStatus(total);
                }
            }
            writeStatus(total);
            rs.close();
            ps.close();
        } catch (SQLException e) {
            e.printStackTrace();
        } catch (ClassNotFoundException e) {
            e.printStackTrace();
        } catch (InstantiationException e) {
            e.printStackTrace();
        } catch (IllegalAccessException e) {
            e.printStackTrace();
        }
    }

    public PersonVO getPerson(int personid){
        if (activePerson==null || activePerson.personId.intValue()!=personid){
            activePerson=MedwanQuery.getInstance().getPerson(""+personid);
        }
        return activePerson;
    }
    public HealthRecordVO getMedicalRecord(int personid){
        if (activeMedicalRecord==null || activeMedicalRecord.getPerson().personId.intValue()!=personid){
            activeMedicalRecord=MedwanQuery.getInstance().getMedicalRecord(getPerson(personid),begin,end);
        }
        return activeMedicalRecord;
    }

    public RiskProfileVO getRiskProfile(int personid){
        if (activeRiskProfile==null || activeRiskProfile.personId.intValue()!=personid){
            activeRiskProfile=MedwanQuery.getInstance().getRiskProfileVOExport(new Long(personid));
        }
        return activeRiskProfile;
    }

    public void setResult(String id,String o){
        results.put(id,o);
    }

    public String getResult(String id){
        return results.get(id)!=null?(String)results.get(id):"";
    }

    public int getResultValue(String id){
        return results.get(id)!=null?Integer.parseInt((String)results.get(id)):0;
    }

    public void incrementResult(String id){
        try{
            if (results.get(id)!=null){
                results.put(id,new Integer(( Integer.parseInt((String)results.get(id))+1)).toString());
            }
            else {
                results.put(id,"1");
            }
        }
        catch(Exception e){
            e.printStackTrace();
        }
    }
}
