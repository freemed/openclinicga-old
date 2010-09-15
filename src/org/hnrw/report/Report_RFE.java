package org.hnrw.report;

import be.mxs.common.util.db.MedwanQuery;

import java.util.Vector;
import java.util.Date;
import java.util.Hashtable;
import java.util.Iterator;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;



/**
 * Created by IntelliJ IDEA.
 * User: Frank
 * Date: 12-jan-2009
 * Time: 13:11:05
 * To change this template use File | Settings | File Templates.
 */
public class Report_RFE {
    public Vector rfes;

    public class RFE {
        String codeType;
        String code;
        long ageInDays;
        String flags;
        String gender;
        String encounterUid;
        String location;
        boolean counted=false;
        int duration;

        public int getDuration() {
            return duration;
        }

        public void setDuration(int duration) {
            this.duration = duration;
        }

        public boolean isCounted() {
            return counted;
        }

        public void setCounted(boolean counted) {
            this.counted = counted;
        }

        public String getLocation() {
            return location;
        }

        public void setLocation(String location) {
            this.location = location;
        }

        public String getEncounterUid() {
            return encounterUid;
        }

        public void setEncounterUid(String encounterUid) {
            this.encounterUid = encounterUid;
        }

        public String getCodeType() {
            return codeType;
        }

        public void setCodeType(String codeType) {
            this.codeType = codeType;
        }

        public String getCode() {
            return code;
        }

        public void setCode(String code) {
            this.code = code;
        }

        public String getGender() {
            return gender;
        }

        public void setGender(String gender) {
            this.gender = gender;
        }

        public long getAgeInDays() {
            return ageInDays;
        }

        public void setAgeInDays(long ageInDays) {
            this.ageInDays = ageInDays;
        }

        public String getFlags() {
            return flags;
        }

        public void setFlags(String flags) {
            this.flags = flags;
        }

        public boolean isConfirmed(){
            return flags.indexOf("C")>-1;
        }

        public boolean isPregnant(){
            return flags.indexOf("E")>-1;
        }

        public boolean isPlanned(){
            return flags.indexOf("P")>-1;
        }

        public boolean isNewcase(){
            return flags.indexOf("N")>-1;
        }

        public boolean checkGender(String gender){
            return gender.toLowerCase().indexOf(getGender().toLowerCase())>-1;
        }

        public boolean checkAge(int minage,int maxage){
            return minage<=getAgeInDays() && maxage>=getAgeInDays();
        }

        public boolean checkFlags(String flags){
            for(int n=0;n<flags.length();n++){
                if(getFlags().indexOf(flags.substring(n,n+1))<0){
                    return false;
                }
            }
            return true;
        }

        public boolean checkCode(CodeRules codeRules){
            return codeRules.isWithinRange(getCodeType(),getCode());
        }
    }

    public Vector getRfes() {
        return rfes;
    }

    public void setRfes(Vector rfes) {
        this.rfes = rfes;
    }

    public Report_RFE(Date begin, Date end,String encounterType){
        rfes= new Vector();
        //We zoeken alle diagnoses op voor de gevraagde periode
        PreparedStatement ps;
        ResultSet rs;
        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            String sQuery="SELECT e.OC_ENCOUNTER_OBJECTID,e.OC_ENCOUNTER_SITUATION,r.OC_RFE_CODETYPE,r.OC_RFE_CODE,r.OC_RFE_FLAGS,r.OC_RFE_DATE,a.dateofbirth,a.gender,e.OC_ENCOUNTER_BEGINDATE,e.OC_ENCOUNTER_ENDDATE " +
                    " from OC_RFE r, OC_ENCOUNTERS e, AdminView a" +
                    " where " +
                    " e.OC_ENCOUNTER_OBJECTID=replace(r.OC_RFE_ENCOUNTERUID,'"+MedwanQuery.getInstance().getConfigInt("serverId")+".','') AND"+
                    " e.OC_ENCOUNTER_PATIENTUID="+MedwanQuery.getInstance().convert("varchar(50)","a.personid")+" AND" +
                    " (e.OC_ENCOUNTER_ENDDATE IS NULL OR e.OC_ENCOUNTER_ENDDATE >=?) AND" +
                    " e.OC_ENCOUNTER_BEGINDATE<=? AND" +
                    " e.OC_ENCOUNTER_TYPE=?";
            ps=oc_conn.prepareStatement(sQuery);
            ps.setDate(1,new java.sql.Date(begin.getTime()));
            ps.setDate(2,new java.sql.Date(end.getTime()));
            ps.setString(3,encounterType);
           
            rs=ps.executeQuery();
            
            while(rs.next()){
                RFE rfe = new RFE();
                rfe.encounterUid=rs.getInt("OC_ENCOUNTER_OBJECTID")+"";
                rfe.location=rs.getString("OC_ENCOUNTER_SITUATION");
                if(rfe.location==null || rfe.location.length()==0){
                    rfe.location="1";
                }
                rfe.code=rs.getString("OC_RFE_CODE");
                rfe.codeType=rs.getString("OC_RFE_CODETYPE");
                rfe.flags=rs.getString("OC_RFE_FLAGS");
                rfe.gender=rs.getString("gender");
                if("mf".indexOf(rfe.gender.toLowerCase())<0){
                    rfe.gender="m";
                }
                rfe.ageInDays=6000l;
                Date dateofbirth = rs.getDate("dateofbirth");
                Date diagnosisdate = rs.getDate("OC_RFE_DATE");
                if(dateofbirth!=null && diagnosisdate!=null){
                    long t = diagnosisdate.getTime()-dateofbirth.getTime();
                    rfe.ageInDays=t/(1000*3600*24);
                }
                Timestamp b=rs.getTimestamp("OC_ENCOUNTER_BEGINDATE");
                Timestamp e=rs.getTimestamp("OC_ENCOUNTER_ENDDATE");
                if(begin.after(b)){
                    b.setTime(begin.getTime());
                }
                if(e==null){
                    e=new Timestamp(new Date().getTime());
                }
                else if (e.after(end)){
                    e=new Timestamp(end.getTime());
                }
                long secs = e.getTime()-b.getTime();
                rfe.setDuration(Math.round(secs/(1000*3600*24)));
                rfes.add(rfe);
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

    public class CodeRules {
        Vector codeSegments = new Vector();

        public CodeRules(String rules){
            String[] s = rules.split(";");
            for(int n=0;n<s.length;n++){
                codeSegments.add(new CodeSegment(s[n]));
            }
        }

        public boolean isWithinRange(String codeType,String code){
            for(int n=0;n<codeSegments.size();n++){
                CodeSegment codeSegment = (CodeSegment)codeSegments.elementAt(n);
                if(codeSegment.getCodeType().equalsIgnoreCase(codeType)){
                    if(codeSegment.isWithinRange(code)){
                        return true;
                    }
                }
            }
            return false;
        }

        public Vector getCodeSegments() {
            return codeSegments;
        }

        public void setCodeSegments(Vector codeSegments) {
            this.codeSegments = codeSegments;
        }
    }

    public class CodeSegment {
        String codeType;
        CodeRange codeRange;

        public CodeSegment(String segment){
            String[] s = segment.split(":");
            setCodeType(s[0]);
            codeRange=new CodeRange(s[1]);
        }

        public boolean isWithinRange(String code){
            return codeRange.isWithinRange(code);
        }

        public String getCodeType() {
            return codeType;
        }

        public void setCodeType(String codeType) {
            this.codeType = codeType;
        }

        public CodeRange getCodeRange() {
            return codeRange;
        }

        public void setCodeRange(CodeRange codeRange) {
            this.codeRange = codeRange;
        }
    }

    public class CodeRange {
        Vector codeRangeSegments=new Vector();

        public CodeRange(String range){
            String[] s = range.split(",");
            for(int n=0;n<s.length;n++){
                codeRangeSegments.add(new CodeRangeSegment(s[n]));
            }
        }

        public boolean isWithinRange(String code){
            for(int n=0;n<codeRangeSegments.size();n++){
                CodeRangeSegment codeRangeSegment = (CodeRangeSegment)codeRangeSegments.elementAt(n);
                if(codeRangeSegment.isWithinRange(code)){
                    return true;
                }
            }
            return false;
        }

        public Vector getCodeRangeSegments() {
            return codeRangeSegments;
        }

        public void setCodeRangeSegments(Vector codeRangeSegments) {
            this.codeRangeSegments = codeRangeSegments;
        }
    }

    public class CodeRangeSegment {
        String from;
        String to;

        public CodeRangeSegment(String rangeSegment){
            String[] s = rangeSegment.split("-");
            from = s[0];
            if(s.length>1){
                to=s[1];
            }
            else {
                to=s[0];
            }
        }

        public boolean isWithinRange(String code){
            return code.compareTo(from)>-1 && code.compareTo(to)<1;
        }

        public String getFrom() {
            return from;
        }

        public void setFrom(String from) {
            this.from = from;
        }

        public String getTo() {
            return to;
        }

        public void setTo(String to) {
            this.to = to;
        }
    }

    public void reset(){
        for(int n=0;n<getRfes().size();n++){
            RFE rfe = (RFE)getRfes().elementAt(n);
            rfe.setCounted(false);
        }
    }

    public Hashtable getUncountedRFEs(){
        Hashtable uncounted = new Hashtable();
        for(int n=0;n<getRfes().size();n++){
            RFE rfe = (RFE)getRfes().elementAt(n);
            if(!rfe.isCounted()){
                uncounted.put(rfe.getCode()+"."+rfe.getCode(),rfe);
            }
        }
        return uncounted;
    }

    public int count(String codes,String gender,int minageInDays,int maxAgeInDays,String flags){
        Hashtable encounters=new Hashtable();
        CodeRules codeRules = new CodeRules(codes);
        for(int n=0;n<rfes.size();n++){
            RFE rfe = (RFE)rfes.elementAt(n);
            if(rfe.checkGender(gender) && rfe.checkAge(minageInDays,maxAgeInDays) && rfe.checkFlags(flags) && rfe.checkCode(codeRules)){
                rfe.setCounted(true);
                encounters.put(rfe.getEncounterUid(),"1");
            }
        }
        return encounters.size();
    }

    public int countDuration(String codes,String gender,int minageInDays,int maxAgeInDays,String flags){
        Hashtable encounters=new Hashtable();
        CodeRules codeRules = new CodeRules(codes);
        for(int n=0;n<rfes.size();n++){
            RFE rfe = (RFE)rfes.elementAt(n);
            if(rfe.checkGender(gender) && rfe.checkAge(minageInDays,maxAgeInDays) && rfe.checkFlags(flags) && rfe.checkCode(codeRules)){
                rfe.setCounted(true);
                encounters.put(rfe.getEncounterUid(),new Integer(rfe.getDuration()));
            }
        }
        Iterator durations = encounters.values().iterator();
        int count=0;
        while(durations.hasNext()){
            count+=((Integer)durations.next()).intValue();
        }
        return count;
    }

    public int countNewCases(){
        Hashtable encounters=new Hashtable();
        for(int n=0;n<rfes.size();n++){
            RFE rfe = (RFE)rfes.elementAt(n);
            if(rfe.isNewcase()){
                encounters.put(rfe.getEncounterUid(),"1");
            }
        }
        return encounters.size();
    }

    public int countNewCases(String gender){
        Hashtable encounters=new Hashtable();
        for(int n=0;n<rfes.size();n++){
            RFE rfe = (RFE)rfes.elementAt(n);
            if(rfe.isNewcase() && gender.toLowerCase().indexOf(rfe.getGender().toLowerCase())>-1){
                encounters.put(rfe.getEncounterUid(),"1");
            }
        }
        return encounters.size();
    }

    public int countGender(String gender){
        Hashtable encounters=new Hashtable();
        for(int n=0;n<rfes.size();n++){
            RFE rfe = (RFE)rfes.elementAt(n);
            if(gender.toLowerCase().indexOf(rfe.getGender().toLowerCase())>-1){
                encounters.put(rfe.getEncounterUid(),"1");
            }
        }
        return encounters.size();
    }

    public int countLocations(String location){
        Hashtable encounters=new Hashtable();
        for(int n=0;n<rfes.size();n++){
            RFE rfe = (RFE)rfes.elementAt(n);
            if(location.equalsIgnoreCase(rfe.getLocation())){
                encounters.put(rfe.getEncounterUid(),"1");
            }
        }
        return encounters.size();
    }

    public int countLocations(String location, String gender){
        Hashtable encounters=new Hashtable();
        for(int n=0;n<rfes.size();n++){
            RFE rfe = (RFE)rfes.elementAt(n);
            if(location.equalsIgnoreCase(rfe.getLocation()) && gender.toLowerCase().indexOf(rfe.getGender().toLowerCase())>-1){
                encounters.put(rfe.getEncounterUid(),"1");
            }
        }
        return encounters.size();
    }

    public int countLocations(String location, boolean newcase,String gender){
        Hashtable encounters=new Hashtable();
        for(int n=0;n<rfes.size();n++){
            RFE rfe = (RFE)rfes.elementAt(n);
            if(location.equalsIgnoreCase(rfe.getLocation()) && rfe.isNewcase()==newcase && gender.toLowerCase().indexOf(rfe.getGender().toLowerCase())>-1){
                encounters.put(rfe.getEncounterUid(),"1");
            }
        }
        return encounters.size();
    }

    public int countOldCases(){
        Hashtable encounters=new Hashtable();
        for(int n=0;n<rfes.size();n++){
            RFE rfe = (RFE)rfes.elementAt(n);
            if(!rfe.isNewcase()){
                encounters.put(rfe.getEncounterUid(),"1");
            }
        }
        return encounters.size();
    }

    public int countOldCases(String gender){
        Hashtable encounters=new Hashtable();
        for(int n=0;n<rfes.size();n++){
            RFE rfe = (RFE)rfes.elementAt(n);
            if(!rfe.isNewcase()  && gender.toLowerCase().indexOf(rfe.getGender().toLowerCase())>-1){
                encounters.put(rfe.getEncounterUid(),"1");
            }
        }
        return encounters.size();
    }
}
