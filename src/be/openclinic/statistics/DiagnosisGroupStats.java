package be.openclinic.statistics;

import be.mxs.common.util.db.MedwanQuery;
import be.mxs.common.util.system.ScreenHelper;

import java.util.*;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;
import java.sql.ResultSet;
import java.text.SimpleDateFormat;

import net.admin.Service;

public class DiagnosisGroupStats extends DStats{

    public DiagnosisGroupStats(String codeType, String code) {
        this.codeType = codeType;
        this.code = code;
    }

    public DiagnosisGroupStats(String codeType, String code, Date start, Date end,String service,String sortorder,String type) {
        this.codeType = codeType;
        this.code = code;
        this.start = start;
        this.end = end;
        this.service=service;
        this.sortOrder=sortorder;
        this.type=type;
        calculate();
    }

    public SortedSet getOutcomeStats() {
        return outcomeStats;
    }

    public static Vector getDiagnosisList(String codetype,String code,Date start,Date end,String service,int detail,String type){
        Vector codes=new Vector();
        Connection loc_conn=MedwanQuery.getInstance().getLongOpenclinicConnection();
        try {
            String sQuery="select distinct substring(OC_DIAGNOSIS_CODE,1,"+detail+") code " +
                    "from OC_DIAGNOSES_VIEW a,OC_ENCOUNTERS b where " +
                    "a.OC_DIAGNOSIS_ENCOUNTERUID="+ MedwanQuery.getInstance().convert("varchar(10)","b.OC_ENCOUNTER_SERVERID")+MedwanQuery.getInstance().concatSign()+"'.'"+MedwanQuery.getInstance().concatSign()+ MedwanQuery.getInstance().convert("varchar(10)","b.OC_ENCOUNTER_OBJECTID")+" and "+
                    "a.OC_DIAGNOSIS_ENCOUNTEROBJECTID=b.OC_ENCOUNTER_OBJECTID and "+
                    "b.OC_ENCOUNTER_BEGINDATE<=? and " +
                    "b.OC_ENCOUNTER_TYPE='"+type+"' and " +
                    "b.OC_ENCOUNTER_ENDDATE>=? and "+
                    MedwanQuery.getInstance().getConfigString("charindexFunction","charindex")+"(?,a.OC_DIAGNOSIS_CODETYPE)=1 AND " +
                    (code.length()==0?"'"+code+"'=? and ":MedwanQuery.getInstance().getConfigString("charindexFunction","charindex")+"(?,a.OC_DIAGNOSIS_CODE)=1 AND ") +
                    MedwanQuery.getInstance().getConfigString("charindexFunction","charindex")+"(?,a.OC_DIAGNOSIS_SERVICEUID)=1 ";
            PreparedStatement ps = loc_conn.prepareStatement(sQuery);
            ps.setDate(1,new java.sql.Date(end.getTime()));
            ps.setDate(2,new java.sql.Date(start.getTime()));
            ps.setString(3,codetype);
            ps.setString(4,code);
            ps.setString(5,service);
            ResultSet rs = ps.executeQuery();
            while (rs.next()){
                codes.add(rs.getString("code"));
            }
            rs.close();
            ps.close();
        } catch (SQLException e) {
            e.printStackTrace();
        }
        try {
			loc_conn.close();
		} catch (SQLException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
        return codes;
    }

    public int calculateTotalDead(Date start,Date end){
        int totalDead=0;
        Connection loc_conn=MedwanQuery.getInstance().getLongOpenclinicConnection();
        try {
            PreparedStatement ps=null;
            ResultSet rs=null;
            if(service.length()>0){
            	String children = Service.getChildIdsAsString(service);
                String sQuery="select count(*) totalContacts from " +
                        "OC_ENCOUNTERS_VIEW " +
                        "where "+
                        "OC_ENCOUNTER_BEGINDATE<=? and " +
                        "OC_ENCOUNTER_TYPE='"+this.type+"' and " +
                        "OC_ENCOUNTER_ENDDATE>=? and " +
                        "OC_ENCOUNTER_SERVICEUID in ("+children+") AND " +
                        "OC_ENCOUNTER_OUTCOME='dead'";
                ps = loc_conn.prepareStatement(sQuery);
                ps.setDate(1,new java.sql.Date(end.getTime()));
                ps.setDate(2,new java.sql.Date(start.getTime()));
                rs = ps.executeQuery();
                if (rs.next()){
                    totalDead=rs.getInt("totalContacts");
                }
            }
            else {
                String sQuery="select count(*) totalContacts from " +
                        "OC_ENCOUNTERS_VIEW " +
                        "where "+
                        "OC_ENCOUNTER_BEGINDATE<=? and " +
                        "OC_ENCOUNTER_TYPE='"+this.type+"' and " +
                        "OC_ENCOUNTER_ENDDATE>=? and " +
                        "OC_ENCOUNTER_OUTCOME='dead'";
                ps = loc_conn.prepareStatement(sQuery);
                ps.setDate(1,new java.sql.Date(end.getTime()));
                ps.setDate(2,new java.sql.Date(start.getTime()));
                rs = ps.executeQuery();
                if (rs.next()){
                    totalDead=rs.getInt("totalContacts");
                }
            }
            rs.close();
            ps.close();
        } catch (SQLException e) {
            e.printStackTrace();  //To change body of catch statement use File | Settings | File Templates.
        }
        try {
			loc_conn.close();
		} catch (SQLException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
        return totalDead;
    }

    public void calculate(Date start,Date end){
        Connection loc_conn=MedwanQuery.getInstance().getLongOpenclinicConnection();
        try {
            PreparedStatement ps=null;
            ResultSet rs=null;
            if(service.length()>0){
            	String children = Service.getChildIdsAsString(service);
                String sQuery="select count(*) totalContacts,sum(abs("+MedwanQuery.getInstance().datediff("d","begindate","enddate")+"+1)) totalDuration from " +
                        "(select " +
                        "   OC_ENCOUNTER_SERVICEUID," +
                        "   OC_ENCOUNTER_BEGINDATE," +
                        "   OC_ENCOUNTER_ENDDATE," +
                        "   "+MedwanQuery.getInstance().iif("OC_ENCOUNTER_BEGINDATE>?","OC_ENCOUNTER_BEGINDATE","?")+" begindate," +
                        "   "+MedwanQuery.getInstance().iif("OC_ENCOUNTER_ENDDATE<?","OC_ENCOUNTER_ENDDATE","?")+" enddate " +
                        " from OC_ENCOUNTERS_VIEW" +
                        " where OC_ENCOUNTER_TYPE='"+this.type+"'" +
                        ") b where "+
                        "b.OC_ENCOUNTER_BEGINDATE<=? and " +
                        "(b.OC_ENCOUNTER_ENDDATE is null or b.OC_ENCOUNTER_ENDDATE>=?) and " +
                        "OC_ENCOUNTER_SERVICEUID in ("+children+")";
                ps = loc_conn.prepareStatement(sQuery);
                ps.setDate(1,new java.sql.Date(start.getTime()));
                ps.setDate(2,new java.sql.Date(start.getTime()));
                ps.setDate(3,new java.sql.Date(end.getTime()));
                ps.setDate(4,new java.sql.Date(end.getTime()));
                ps.setDate(5,new java.sql.Date(end.getTime()));
                ps.setDate(6,new java.sql.Date(start.getTime()));
                rs = ps.executeQuery();
                if (rs.next()){
                    totalContacts=rs.getInt("totalContacts");
                    totalDuration=rs.getInt("totalDuration");
                }
                rs.close();
                ps.close();

                sQuery="select c.OC_ENCOUNTER_OUTCOME, " +
                        "avg(abs("+ MedwanQuery.getInstance().convert("float",MedwanQuery.getInstance().datediff("d","a.begindate","a.enddate"))+"+1)) meanDuration," +
                        "min(abs("+ MedwanQuery.getInstance().convert("float",MedwanQuery.getInstance().datediff("d","a.begindate","a.enddate"))+"+1)) min," +
                        "max(abs("+ MedwanQuery.getInstance().convert("float",MedwanQuery.getInstance().datediff("d","a.begindate","a.enddate"))+"+1)) max," +
                        MedwanQuery.getInstance().getConfigString("stddevFunction","stdev")+"(abs("+ MedwanQuery.getInstance().convert("float",MedwanQuery.getInstance().datediff("d","a.begindate","a.enddate"))+"+1)) standardDeviationDuration," +
                        "count(distinct oc_diagnosis_objectid) cases," +
                        "avg("+ MedwanQuery.getInstance().convert("float","a.comorb")+") comorbidity " +
                        "from (select distinct " +
                        "   count(distinct a.oc_diagnosis_objectid) comorb," +
                        "   OC_DIAGNOSIS_ENCOUNTERUID," +
                        "   OC_DIAGNOSIS_ENCOUNTEROBJECTID," +
                        "   "+MedwanQuery.getInstance().iif("OC_ENCOUNTER_BEGINDATE>?","OC_ENCOUNTER_BEGINDATE","?")+" begindate," +
                        "   "+MedwanQuery.getInstance().iif("OC_ENCOUNTER_ENDDATE<?","OC_ENCOUNTER_ENDDATE","?")+" enddate " +
                        "from OC_DIAGNOSES_VIEW a,OC_ENCOUNTERS b where " +
                        "b.OC_ENCOUNTER_TYPE='"+this.type+"' and " +
                        "a.OC_DIAGNOSIS_ENCOUNTERUID="+ MedwanQuery.getInstance().convert("varchar(10)","b.OC_ENCOUNTER_SERVERID")+MedwanQuery.getInstance().concatSign()+"'.'"+MedwanQuery.getInstance().concatSign()+ MedwanQuery.getInstance().convert("varchar(10)","b.OC_ENCOUNTER_OBJECTID")+" and " +
                        "a.OC_DIAGNOSIS_ENCOUNTEROBJECTID=b.OC_ENCOUNTER_OBJECTID and "+
                        "b.OC_ENCOUNTER_BEGINDATE<=? and " +
                        "(b.OC_ENCOUNTER_ENDDATE is null or b.OC_ENCOUNTER_ENDDATE>=?) and " +
                        MedwanQuery.getInstance().getConfigString("charindexFunction","charindex")+"(?,a.OC_DIAGNOSIS_CODETYPE)=1 AND " +
                        "OC_DIAGNOSIS_SERVICEUID in ("+children+") "+
                        "group by OC_DIAGNOSIS_ENCOUNTERUID,OC_DIAGNOSIS_ENCOUNTEROBJECTID," +
                        " OC_ENCOUNTER_BEGINDATE," +
                        " OC_ENCOUNTER_ENDDATE " +
                        ") a, OC_DIAGNOSES_VIEW b, OC_ENCOUNTERS c " +
                        "where " +
                        "c.OC_ENCOUNTER_TYPE='"+this.type+"' and " +
                        "a.OC_DIAGNOSIS_ENCOUNTERUID=b.OC_DIAGNOSIS_ENCOUNTERUID and " +
                        "a.OC_DIAGNOSIS_ENCOUNTERUID="+ MedwanQuery.getInstance().convert("varchar(10)","c.OC_ENCOUNTER_SERVERID")+MedwanQuery.getInstance().concatSign()+"'.'"+MedwanQuery.getInstance().concatSign()+ MedwanQuery.getInstance().convert("varchar(10)","c.OC_ENCOUNTER_OBJECTID")+" and " +
                        "a.OC_DIAGNOSIS_ENCOUNTEROBJECTID=c.OC_ENCOUNTER_OBJECTID and "+
                        MedwanQuery.getInstance().getConfigString("charindexFunction","charindex")+"(?,b.OC_DIAGNOSIS_CODETYPE)=1 AND " +
                        "b.OC_DIAGNOSIS_CODE like ? AND " +
                        "OC_DIAGNOSIS_SERVICEUID in ("+children+") "+
                        "group by c.OC_ENCOUNTER_OUTCOME";

                ps = loc_conn.prepareStatement(sQuery);
                ps.setDate(1,new java.sql.Date(start.getTime()));
                ps.setDate(2,new java.sql.Date(start.getTime()));
                ps.setDate(3,new java.sql.Date(end.getTime()));
                ps.setDate(4,new java.sql.Date(end.getTime()));
                ps.setDate(5,new java.sql.Date(end.getTime()));
                ps.setDate(6,new java.sql.Date(start.getTime()));
                ps.setString(7,codeType);
                ps.setString(8,codeType);
                ps.setString(9,code);
                rs = ps.executeQuery();
            }
            else {
                String sQuery="select count(*) totalContacts,sum(abs("+MedwanQuery.getInstance().datediff("d","b.begindate","b.enddate")+"+1)) totalDuration from " +
                        "(select " +
                        "   OC_ENCOUNTER_BEGINDATE," +
                        "   OC_ENCOUNTER_ENDDATE," +
                        "   "+MedwanQuery.getInstance().iif("OC_ENCOUNTER_BEGINDATE>?","OC_ENCOUNTER_BEGINDATE","?")+" begindate," +
                        "   "+MedwanQuery.getInstance().iif("OC_ENCOUNTER_ENDDATE<?","OC_ENCOUNTER_ENDDATE","?")+" enddate " +
                        " from OC_ENCOUNTERS" +
                        " where OC_ENCOUNTER_TYPE='"+this.type+"' " +
                        ") b where "+
                        "b.OC_ENCOUNTER_BEGINDATE<=? and " +
                        "(b.OC_ENCOUNTER_ENDDATE is null or b.OC_ENCOUNTER_ENDDATE>=?)";
                ps = loc_conn.prepareStatement(sQuery);
                ps.setDate(1,new java.sql.Date(start.getTime()));
                ps.setDate(2,new java.sql.Date(start.getTime()));
                ps.setDate(3,new java.sql.Date(end.getTime()));
                ps.setDate(4,new java.sql.Date(end.getTime()));
                ps.setDate(5,new java.sql.Date(end.getTime()));
                ps.setDate(6,new java.sql.Date(start.getTime()));
                rs = ps.executeQuery();
                if (rs.next()){
                    totalContacts=rs.getInt("totalContacts");
                    totalDuration=rs.getInt("totalDuration");
                }
                rs.close();
                ps.close();

                sQuery="select c.OC_ENCOUNTER_OUTCOME, " +
                        "avg(abs("+ MedwanQuery.getInstance().convert("float",MedwanQuery.getInstance().datediff("d","a.begindate","a.enddate"))+"+1)) meanDuration," +
                        "min(abs("+ MedwanQuery.getInstance().convert("float",MedwanQuery.getInstance().datediff("d","a.begindate","a.enddate"))+"+1)) min," +
                        "max(abs("+ MedwanQuery.getInstance().convert("float",MedwanQuery.getInstance().datediff("d","a.begindate","a.enddate"))+"+1)) max," +
                        MedwanQuery.getInstance().getConfigString("stddevFunction","stdev")+"(abs("+ MedwanQuery.getInstance().convert("float",MedwanQuery.getInstance().datediff("d","a.begindate","a.enddate"))+"+1)) standardDeviationDuration," +
                        "count(distinct oc_diagnosis_objectid) cases," +
                        "avg("+ MedwanQuery.getInstance().convert("float","a.comorb")+") comorbidity " +
                        "from (select " +
                        "   distinct count(distinct a.oc_diagnosis_objectid) comorb," +
                        "   OC_DIAGNOSIS_ENCOUNTERUID," +
                        "   OC_DIAGNOSIS_ENCOUNTEROBJECTID," +
                        "   "+MedwanQuery.getInstance().iif("OC_ENCOUNTER_BEGINDATE>?","OC_ENCOUNTER_BEGINDATE","?")+" begindate," +
                        "   "+MedwanQuery.getInstance().iif("OC_ENCOUNTER_ENDDATE<?","OC_ENCOUNTER_ENDDATE","?")+" enddate " +
                        "from OC_DIAGNOSES_VIEW a,OC_ENCOUNTERS b where " +
                        "b.OC_ENCOUNTER_TYPE='"+this.type+"' and " +
                        "a.OC_DIAGNOSIS_ENCOUNTERUID="+ MedwanQuery.getInstance().convert("varchar(10)","b.OC_ENCOUNTER_SERVERID")+MedwanQuery.getInstance().concatSign()+"'.'"+MedwanQuery.getInstance().concatSign()+ MedwanQuery.getInstance().convert("varchar(10)","b.OC_ENCOUNTER_OBJECTID")+" and " +
                        "a.OC_DIAGNOSIS_ENCOUNTEROBJECTID=b.OC_ENCOUNTER_OBJECTID and "+
                        "b.OC_ENCOUNTER_BEGINDATE<=? and " +
                        "(b.OC_ENCOUNTER_ENDDATE is null or b.OC_ENCOUNTER_ENDDATE>=?) and " +
                        MedwanQuery.getInstance().getConfigString("charindexFunction","charindex")+"(?,a.OC_DIAGNOSIS_CODETYPE)=1 " +
                        "group by OC_DIAGNOSIS_ENCOUNTERUID,OC_DIAGNOSIS_ENCOUNTEROBJECTID,OC_ENCOUNTER_BEGINDATE,OC_ENCOUNTER_ENDDATE " +
                        ") a, OC_DIAGNOSES_VIEW b, OC_ENCOUNTERS c " +
                        "where " +
                        "c.OC_ENCOUNTER_TYPE='"+this.type+"' and " +
                        "a.OC_DIAGNOSIS_ENCOUNTERUID=b.OC_DIAGNOSIS_ENCOUNTERUID and " +
                        "a.OC_DIAGNOSIS_ENCOUNTERUID="+ MedwanQuery.getInstance().convert("varchar(10)","c.OC_ENCOUNTER_SERVERID")+MedwanQuery.getInstance().concatSign()+"'.'"+MedwanQuery.getInstance().concatSign()+ MedwanQuery.getInstance().convert("varchar(10)","c.OC_ENCOUNTER_OBJECTID")+" and " +
                        "a.OC_DIAGNOSIS_ENCOUNTEROBJECTID=c.OC_ENCOUNTER_OBJECTID and "+
                        MedwanQuery.getInstance().getConfigString("charindexFunction","charindex")+"(?,b.OC_DIAGNOSIS_CODETYPE)=1 AND " +
                        "b.OC_DIAGNOSIS_CODE like ? " +
                        "group by c.OC_ENCOUNTER_OUTCOME";

                ps = loc_conn.prepareStatement(sQuery);
                ps.setDate(1,new java.sql.Date(start.getTime()));
                ps.setDate(2,new java.sql.Date(start.getTime()));
                ps.setDate(3,new java.sql.Date(end.getTime()));
                ps.setDate(4,new java.sql.Date(end.getTime()));
                ps.setDate(5,new java.sql.Date(end.getTime()));
                ps.setDate(6,new java.sql.Date(start.getTime()));
                ps.setString(7,codeType);
                ps.setString(8,codeType);
                ps.setString(9,code);
                rs = ps.executeQuery();
            }
            outcomeStats=new TreeSet();
            while (rs.next()){
                OutcomeStat outcomeStat = new OutcomeStat();
                outcomeStat.setCoMorbidityScore(rs.getDouble("comorbidity"));
                outcomeStat.setDiagnosisCases(rs.getInt("cases"));
                outcomeStat.setMaxDuration(rs.getInt("max"));
                outcomeStat.setMeanDuration(rs.getDouble("meanDuration"));
                outcomeStat.setMinDuration(rs.getInt("min"));
                outcomeStat.setStandardDeviationDuration(rs.getDouble("standardDeviationDuration"));
                outcomeStat.setOutcome(rs.getString("OC_ENCOUNTER_OUTCOME"));
                outcomeStats.add(outcomeStat);
            }

            rs.close();
            ps.close();
        } catch (SQLException e) {
            e.printStackTrace();  //To change body of catch statement use File | Settings | File Templates.
        }
        try {
			loc_conn.close();
		} catch (SQLException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
    }

    public void calculateHeader(Date start,Date end){
        Connection loc_conn=MedwanQuery.getInstance().getLongOpenclinicConnection();
        try {
            PreparedStatement ps=null;
            ResultSet rs=null;
            if(service.length()>0){
            	String children = Service.getChildIdsAsString(service);
                String sQuery="select count(*) totalContacts,sum(abs("+MedwanQuery.getInstance().datediff("d","b.begindate","b.enddate")+"+1)) totalDuration from " +
                        "(select OC_ENCOUNTER_SERVICEUID," +
                        "   OC_ENCOUNTER_BEGINDATE," +
                        "   OC_ENCOUNTER_ENDDATE," +
                        "   "+MedwanQuery.getInstance().iif("OC_ENCOUNTER_BEGINDATE>?","OC_ENCOUNTER_BEGINDATE","?")+" begindate," +
                        "   "+MedwanQuery.getInstance().iif("OC_ENCOUNTER_ENDDATE<?","OC_ENCOUNTER_ENDDATE","?")+" enddate " +
                        " from OC_ENCOUNTERS_VIEW" +
                        " where OC_ENCOUNTER_TYPE='"+this.type+"'" +
                        ") b where "+
                        "b.OC_ENCOUNTER_BEGINDATE<=? and " +
                        "(b.OC_ENCOUNTER_ENDDATE is null or b.OC_ENCOUNTER_ENDDATE>=?) and " +
                        "OC_ENCOUNTER_SERVICEUID in ("+children+")";
                ps = loc_conn.prepareStatement(sQuery);
                ps.setDate(1,new java.sql.Date(start.getTime()));
                ps.setDate(2,new java.sql.Date(start.getTime()));
                ps.setDate(3,new java.sql.Date(end.getTime()));
                ps.setDate(4,new java.sql.Date(end.getTime()));
                ps.setDate(5,new java.sql.Date(end.getTime()));
                ps.setDate(6,new java.sql.Date(start.getTime()));
                rs = ps.executeQuery();
                if (rs.next()){
                    totalContacts=rs.getInt("totalContacts");
                    totalDuration=rs.getInt("totalDuration");
                }
                rs.close();
                ps.close();
            }
            else {
                String sQuery="select count(*) totalContacts,sum(abs("+MedwanQuery.getInstance().datediff("d","b.begindate","b.enddate")+"+1)) totalDuration from " +
                        "(select OC_ENCOUNTER_BEGINDATE," +
                        "   OC_ENCOUNTER_ENDDATE," +
                        "   "+MedwanQuery.getInstance().iif("OC_ENCOUNTER_BEGINDATE>?","OC_ENCOUNTER_BEGINDATE","?")+" begindate," +
                        "   "+MedwanQuery.getInstance().iif("OC_ENCOUNTER_ENDDATE<?","OC_ENCOUNTER_ENDDATE","?")+" enddate " +
                        " from OC_ENCOUNTERS" +
                        " where OC_ENCOUNTER_TYPE='"+this.type+"'" +
                        ") b where "+
                        "b.OC_ENCOUNTER_BEGINDATE<=? and " +
                        "(b.OC_ENCOUNTER_ENDDATE is null or b.OC_ENCOUNTER_ENDDATE>=?)";
                ps = loc_conn.prepareStatement(sQuery);
                ps.setDate(1,new java.sql.Date(start.getTime()));
                ps.setDate(2,new java.sql.Date(start.getTime()));
                ps.setDate(3,new java.sql.Date(end.getTime()));
                ps.setDate(4,new java.sql.Date(end.getTime()));
                ps.setDate(5,new java.sql.Date(end.getTime()));
                ps.setDate(6,new java.sql.Date(start.getTime()));
                rs = ps.executeQuery();
                if (rs.next()){
                    totalContacts=rs.getInt("totalContacts");
                    totalDuration=rs.getInt("totalDuration");
                }
                rs.close();
                ps.close();
            }
            rs.close();
            ps.close();
        } catch (SQLException e) {
            e.printStackTrace();  //To change body of catch statement use File | Settings | File Templates.
        }
        try {
			loc_conn.close();
		} catch (SQLException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
    }

    public static SortedSet calculateSubStats(String codeType, String code, Date start, Date end,String service,String sortorder,int detail,String type){
        SortedSet diags = new TreeSet();
        Connection loc_conn=MedwanQuery.getInstance().getLongOpenclinicConnection();
        try {
            PreparedStatement ps=null;
            ResultSet rs=null;
            String activeDiagnosis="";
            if(service.length()>0){
            	String children = Service.getChildIdsAsString(service);
                String sQuery="select substring(b.OC_DIAGNOSIS_CODE,1,"+detail+") diagnosisCode,c.OC_ENCOUNTER_OUTCOME, " +
                        "avg(abs("+ MedwanQuery.getInstance().convert("float",MedwanQuery.getInstance().datediff("d","a.begindate","a.enddate"))+"+1)) meanDuration," +
                        "min(abs("+ MedwanQuery.getInstance().convert("float",MedwanQuery.getInstance().datediff("d","a.begindate","a.enddate"))+"+1)) min," +
                        "max(abs("+ MedwanQuery.getInstance().convert("float",MedwanQuery.getInstance().datediff("d","a.begindate","a.enddate"))+"+1)) max," +
                        MedwanQuery.getInstance().getConfigString("stddevFunction","stdev")+"(abs("+ MedwanQuery.getInstance().convert("float",MedwanQuery.getInstance().datediff("d","a.begindate","a.enddate"))+"+1)) standardDeviationDuration," +
                        "count(distinct oc_diagnosis_objectid) cases," +
                        "avg("+MedwanQuery.getInstance().convert("float","comorb")+") comorbidity " +
                        "from (select distinct count(distinct a.oc_diagnosis_objectid) comorb," +
                        "   OC_DIAGNOSIS_ENCOUNTERUID," +
                        "   OC_DIAGNOSIS_ENCOUNTEROBJECTID," +
                        "   "+MedwanQuery.getInstance().iif("OC_ENCOUNTER_BEGINDATE>?","OC_ENCOUNTER_BEGINDATE","?")+" begindate," +
                        "   "+MedwanQuery.getInstance().iif("OC_ENCOUNTER_ENDDATE<?","OC_ENCOUNTER_ENDDATE","?")+" enddate " +
                        "from OC_DIAGNOSES_VIEW a,OC_ENCOUNTERS b where " +
                        "b.OC_ENCOUNTER_TYPE='"+type+"' and " +
                        "a.OC_DIAGNOSIS_ENCOUNTERUID="+MedwanQuery.getInstance().convert("varchar(10)","b.OC_ENCOUNTER_SERVERID")+MedwanQuery.getInstance().concatSign()+"'.'"+MedwanQuery.getInstance().concatSign()+MedwanQuery.getInstance().convert("varchar(10)","b.OC_ENCOUNTER_OBJECTID")+" and " +
                        "a.OC_DIAGNOSIS_ENCOUNTEROBJECTID=b.OC_ENCOUNTER_OBJECTID and "+
                        "b.OC_ENCOUNTER_BEGINDATE<=? and " +
                        "b.OC_ENCOUNTER_ENDDATE>=? and " +
                        MedwanQuery.getInstance().getConfigString("charindexFunction","charindex")+"(?,a.OC_DIAGNOSIS_CODETYPE)=1 AND " +
                        "OC_DIAGNOSIS_SERVICEUID in ("+children+") "+
                        "group by OC_DIAGNOSIS_ENCOUNTERUID,OC_DIAGNOSIS_ENCOUNTEROBJECTID,OC_ENCOUNTER_BEGINDATE,OC_ENCOUNTER_ENDDATE " +
                        ") a, OC_DIAGNOSES_VIEW b, OC_ENCOUNTERS c " +
                        "where " +
                        "c.OC_ENCOUNTER_TYPE='"+type+"' and " +
                        "a.OC_DIAGNOSIS_ENCOUNTERUID=b.OC_DIAGNOSIS_ENCOUNTERUID and " +
                        "a.OC_DIAGNOSIS_ENCOUNTERUID="+MedwanQuery.getInstance().convert("varchar(10)","c.OC_ENCOUNTER_SERVERID")+MedwanQuery.getInstance().concatSign()+"'.'"+MedwanQuery.getInstance().concatSign()+MedwanQuery.getInstance().convert("varchar(10)","c.OC_ENCOUNTER_OBJECTID")+" and " +
                        "a.OC_DIAGNOSIS_ENCOUNTEROBJECTID=c.OC_ENCOUNTER_OBJECTID and "+
                        MedwanQuery.getInstance().getConfigString("charindexFunction","charindex")+"(?,b.OC_DIAGNOSIS_CODETYPE)=1 AND " +
                        "b.OC_DIAGNOSIS_CODE like ? and " +
                        "OC_DIAGNOSIS_SERVICEUID in ("+children+") "+
                        "group by substring(b.OC_DIAGNOSIS_CODE,1,"+detail+"),c.OC_ENCOUNTER_OUTCOME " +
                        "order by substring(b.OC_DIAGNOSIS_CODE,1,"+detail+"),c.OC_ENCOUNTER_OUTCOME";

                ps = loc_conn.prepareStatement(sQuery);
                ps.setDate(1,new java.sql.Date(start.getTime()));
                ps.setDate(2,new java.sql.Date(start.getTime()));
                ps.setDate(3,new java.sql.Date(end.getTime()));
                ps.setDate(4,new java.sql.Date(end.getTime()));
                ps.setDate(5,new java.sql.Date(end.getTime()));
                ps.setDate(6,new java.sql.Date(start.getTime()));
                ps.setString(7,codeType);
                ps.setString(8,codeType);
                ps.setString(9,code);
                rs = ps.executeQuery();
            }
            else {
                String sQuery="select substring(b.OC_DIAGNOSIS_CODE,1,"+detail+") diagnosisCode,c.OC_ENCOUNTER_OUTCOME, " +
                        "avg(abs("+ MedwanQuery.getInstance().convert("float",MedwanQuery.getInstance().datediff("d","a.begindate","a.enddate"))+"+1)) meanDuration," +
                        "min(abs("+ MedwanQuery.getInstance().convert("float",MedwanQuery.getInstance().datediff("d","a.begindate","a.enddate"))+"+1)) min," +
                        "max(abs("+ MedwanQuery.getInstance().convert("float",MedwanQuery.getInstance().datediff("d","a.begindate","a.enddate"))+"+1)) max," +
                        MedwanQuery.getInstance().getConfigString("stddevFunction","stdev")+"(abs("+ MedwanQuery.getInstance().convert("float",MedwanQuery.getInstance().datediff("d","a.begindate","a.enddate"))+"+1)) standardDeviationDuration," +
                        "count(distinct oc_diagnosis_objectid) cases," +
                        "avg("+ MedwanQuery.getInstance().convert("float","a.comorb")+") comorbidity " +
                        "from (select distinct count(distinct a.oc_diagnosis_objectid) comorb," +
                        "   OC_DIAGNOSIS_ENCOUNTERUID," +
                        "   OC_DIAGNOSIS_ENCOUNTEROBJECTID," +
                        "   "+MedwanQuery.getInstance().iif("OC_ENCOUNTER_BEGINDATE>?","OC_ENCOUNTER_BEGINDATE","?")+" begindate," +
                        "   "+MedwanQuery.getInstance().iif("OC_ENCOUNTER_ENDDATE<?","OC_ENCOUNTER_ENDDATE","?")+" enddate " +
                        "from OC_DIAGNOSES_VIEW a,OC_ENCOUNTERS_VIEW b where " +
                        "b.OC_ENCOUNTER_TYPE='"+type+"' and " +
                        "a.OC_DIAGNOSIS_ENCOUNTERUID="+ MedwanQuery.getInstance().convert("varchar(10)","b.OC_ENCOUNTER_SERVERID")+MedwanQuery.getInstance().concatSign()+"'.'"+MedwanQuery.getInstance().concatSign()+ MedwanQuery.getInstance().convert("varchar(10)","b.OC_ENCOUNTER_OBJECTID")+" and " +
                        "a.OC_DIAGNOSIS_ENCOUNTEROBJECTID=b.OC_ENCOUNTER_OBJECTID and "+
                        "b.OC_ENCOUNTER_BEGINDATE<=? and " +
                        "b.OC_ENCOUNTER_ENDDATE>=? and " +
                        MedwanQuery.getInstance().getConfigString("charindexFunction","charindex")+"(?,a.OC_DIAGNOSIS_CODETYPE)=1 " +
                        "group by OC_DIAGNOSIS_ENCOUNTERUID,OC_DIAGNOSIS_ENCOUNTEROBJECTID,OC_ENCOUNTER_BEGINDATE,OC_ENCOUNTER_ENDDATE " +
                        ") a, OC_DIAGNOSES_VIEW b, OC_ENCOUNTERS_VIEW c " +
                        "where " +
                        "c.OC_ENCOUNTER_TYPE='"+type+"' and " +
                        "a.OC_DIAGNOSIS_ENCOUNTERUID=b.OC_DIAGNOSIS_ENCOUNTERUID and " +
                        "a.OC_DIAGNOSIS_ENCOUNTERUID="+ MedwanQuery.getInstance().convert("varchar(10)","c.OC_ENCOUNTER_SERVERID")+MedwanQuery.getInstance().concatSign()+"'.'"+MedwanQuery.getInstance().concatSign()+ MedwanQuery.getInstance().convert("varchar(10)","c.OC_ENCOUNTER_OBJECTID")+" and " +
                        "a.OC_DIAGNOSIS_ENCOUNTEROBJECTID=c.OC_ENCOUNTER_OBJECTID and "+
                        MedwanQuery.getInstance().getConfigString("charindexFunction","charindex")+"(?,b.OC_DIAGNOSIS_CODETYPE)=1 AND " +
                        "b.OC_DIAGNOSIS_CODE like ? " +
                        "group by substring(b.OC_DIAGNOSIS_CODE,1,"+detail+"),c.OC_ENCOUNTER_OUTCOME " +
                        "order by substring(b.OC_DIAGNOSIS_CODE,1,"+detail+"),c.OC_ENCOUNTER_OUTCOME";

                ps = loc_conn.prepareStatement(sQuery);
                ps.setDate(1,new java.sql.Date(start.getTime()));
                ps.setDate(2,new java.sql.Date(start.getTime()));
                ps.setDate(3,new java.sql.Date(end.getTime()));
                ps.setDate(4,new java.sql.Date(end.getTime()));
                ps.setDate(5,new java.sql.Date(end.getTime()));
                ps.setDate(6,new java.sql.Date(start.getTime()));
                ps.setString(7,codeType);
                ps.setString(8,codeType);
                ps.setString(9,code);
                rs = ps.executeQuery();
            }
            DiagnosisGroupStats diagnosisStats = null;
            while (rs.next()){
                String sCode=rs.getString("diagnosisCode");
                if(!activeDiagnosis.equalsIgnoreCase(sCode)){
                    if(diagnosisStats!=null){
                        diags.add(diagnosisStats);
                    }
                    activeDiagnosis=sCode;
                    diagnosisStats = new DiagnosisGroupStats(codeType,sCode+"%");
                    diagnosisStats.type = type;
                    diagnosisStats.start = start;
                    diagnosisStats.end = end;
                    diagnosisStats.service=service;
                    diagnosisStats.sortOrder=sortorder;
                    diagnosisStats.outcomeStats=new TreeSet();
                    diagnosisStats.calculateHeader(start,end);
                }
                OutcomeStat outcomeStat = new OutcomeStat();
                outcomeStat.setCoMorbidityScore(rs.getDouble("comorbidity"));
                outcomeStat.setDiagnosisCases(rs.getInt("cases"));
                outcomeStat.setMaxDuration(rs.getInt("max"));
                outcomeStat.setMeanDuration(rs.getDouble("meanDuration"));
                outcomeStat.setMinDuration(rs.getInt("min"));
                outcomeStat.setStandardDeviationDuration(rs.getDouble("standardDeviationDuration"));
                outcomeStat.setOutcome(rs.getString("OC_ENCOUNTER_OUTCOME"));
                diagnosisStats.outcomeStats.add(outcomeStat);
            }
            if(diagnosisStats!=null){
                diags.add(diagnosisStats);
            }

            rs.close();
            ps.close();
        } catch (SQLException e) {
            e.printStackTrace();  //To change body of catch statement use File | Settings | File Templates.
        }
        try {
			loc_conn.close();
		} catch (SQLException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
        return diags;
    }

    public static Vector getAssociatedPathologies(String diagnosisCode, String diagnosisType,Date dBegin, Date dEnd,String outcome,String service,int detail,String type){
        Vector comorbidities = new Vector();
        Connection loc_conn=MedwanQuery.getInstance().getLongOpenclinicConnection();
        try{
            PreparedStatement ps=null;
            if(service.length()>0){
            	String children = Service.getChildIdsAsString(service);
                String sQuery = "select count(*) cases, substring(c.OC_DIAGNOSIS_CODE,1,"+detail+") as OC_DIAGNOSIS_CODE" +
                        " from OC_DIAGNOSES_VIEW c, " +
                        " (select" +
                        "  a.OC_DIAGNOSIS_ENCOUNTERUID," +
                        "   OC_DIAGNOSIS_ENCOUNTEROBJECTID," +
                        "  OC_DIAGNOSIS_CODE," +
                        "  OC_DIAGNOSIS_CODETYPE" +
                        "  from OC_DIAGNOSES_VIEW a,OC_ENCOUNTERS_VIEW b" +
                        "  where" +
                        "  b.OC_ENCOUNTER_TYPE='"+type+"' and " +
                        "  a.OC_DIAGNOSIS_ENCOUNTERUID="+ MedwanQuery.getInstance().convert("varchar(10)","b.OC_ENCOUNTER_SERVERID")+MedwanQuery.getInstance().concatSign()+"'.'"+MedwanQuery.getInstance().concatSign()+ MedwanQuery.getInstance().convert("varchar(10)","b.OC_ENCOUNTER_OBJECTID")+" and " +
                        "  a.OC_DIAGNOSIS_ENCOUNTEROBJECTID=b.OC_ENCOUNTER_OBJECTID and "+
                        MedwanQuery.getInstance().getConfigString("charindexFunction","charindex")+"(?,a.OC_DIAGNOSIS_CODETYPE)=1 AND " +
                        (diagnosisCode.length()==0?"":MedwanQuery.getInstance().getConfigString("charindexFunction","charindex")+"(?,a.OC_DIAGNOSIS_CODE)=1 AND ") +
                        (outcome.equalsIgnoreCase("null")?" (b.OC_ENCOUNTER_OUTCOME IS NULL OR b.OC_ENCOUNTER_OUTCOME='') AND":"  b.OC_ENCOUNTER_OUTCOME = ? and" )+
                        "  b.OC_ENCOUNTER_BEGINDATE<=? and" +
                        "  b.OC_ENCOUNTER_ENDDATE>=? and " +
                        "OC_DIAGNOSIS_SERVICEUID in ("+children+") "+
                        " ) d" +
                        " where" +
                        " c.OC_DIAGNOSIS_CODE<>d.OC_DIAGNOSIS_CODE and" +
                        " c.OC_DIAGNOSIS_CODETYPE=d.OC_DIAGNOSIS_CODETYPE and" +
                        " c.OC_DIAGNOSIS_ENCOUNTERUID=d.OC_DIAGNOSIS_ENCOUNTERUID " +
                        " group by substring(c.OC_DIAGNOSIS_CODE,1,"+detail+")" +
                        " order by count(*) DESC";
                ps = loc_conn.prepareStatement(sQuery);
                ps.setString(1,diagnosisType);
                ps.setString(2,diagnosisCode);
                ps.setString(3,outcome);
                ps.setDate(4,new java.sql.Date(dEnd.getTime()));
                ps.setDate(5,new java.sql.Date(dBegin.getTime()));
            }
            else {
                String sQuery = "select count(*) cases, substring(c.OC_DIAGNOSIS_CODE,1,"+detail+") as OC_DIAGNOSIS_CODE" +
                        " from OC_DIAGNOSES_VIEW c, " +
                        " (select" +
                        "  a.OC_DIAGNOSIS_ENCOUNTERUID," +
                        "   OC_DIAGNOSIS_ENCOUNTEROBJECTID," +
                        "  OC_DIAGNOSIS_CODE," +
                        "  OC_DIAGNOSIS_CODETYPE" +
                        "  from OC_DIAGNOSES_VIEW a,OC_ENCOUNTERS_VIEW b" +
                        "  where" +
                        "  b.OC_ENCOUNTER_TYPE='"+type+"' and " +
                        "  a.OC_DIAGNOSIS_ENCOUNTERUID="+ MedwanQuery.getInstance().convert("varchar(10)","b.OC_ENCOUNTER_SERVERID")+MedwanQuery.getInstance().concatSign()+"'.'"+MedwanQuery.getInstance().concatSign()+ MedwanQuery.getInstance().convert("varchar(10)","b.OC_ENCOUNTER_OBJECTID")+" and " +
                        "  a.OC_DIAGNOSIS_ENCOUNTEROBJECTID=b.OC_ENCOUNTER_OBJECTID and "+
                        MedwanQuery.getInstance().getConfigString("charindexFunction","charindex")+"(?,a.OC_DIAGNOSIS_CODETYPE)=1 AND " +
                        (diagnosisCode.length()==0?"'"+diagnosisCode+"'=? and ":MedwanQuery.getInstance().getConfigString("charindexFunction","charindex")+"(?,a.OC_DIAGNOSIS_CODE)=1 AND ") +
                        (outcome.equalsIgnoreCase("null")?" (b.OC_ENCOUNTER_OUTCOME IS NULL OR b.OC_ENCOUNTER_OUTCOME='') AND":"  b.OC_ENCOUNTER_OUTCOME = ? and" )+
                        "  b.OC_ENCOUNTER_BEGINDATE<=? and" +
                        "  b.OC_ENCOUNTER_ENDDATE>=?) d" +
                        " where" +
                        " c.OC_DIAGNOSIS_CODE<>d.OC_DIAGNOSIS_CODE and " +
                        " c.OC_DIAGNOSIS_CODETYPE=d.OC_DIAGNOSIS_CODETYPE and " +
                        " c.OC_DIAGNOSIS_ENCOUNTERUID=d.OC_DIAGNOSIS_ENCOUNTERUID " +
                        " group by substring(c.OC_DIAGNOSIS_CODE,1,"+detail+")" +
                        " order by count(*) DESC";
                ps = loc_conn.prepareStatement(sQuery);
                int n=1;
                ps.setString(n++,diagnosisType);
                ps.setString(n++,diagnosisCode);
                if(!outcome.equalsIgnoreCase("null")) ps.setString(n++,outcome);
                ps.setDate(n++,new java.sql.Date(dEnd.getTime()));
                ps.setDate(n++,new java.sql.Date(dBegin.getTime()));
            }
            ResultSet rs = ps.executeQuery();
            while (rs.next()){
                comorbidities.add(new Comorbidity(rs.getString("OC_DIAGNOSIS_CODE"),rs.getInt("cases")));
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
        return comorbidities;
    }

    public static double[] getMedianDuration(String diagnosisCode, String diagnosisType,Date dBegin, Date dEnd,String outcome,String service,String type){
        double[] quartiles=new double[3];
        Vector values= new Vector();
        Connection loc_conn=MedwanQuery.getInstance().getLongOpenclinicConnection();
        try{
            PreparedStatement ps=null;
            if(service.length()>0){
            	String children = Service.getChildIdsAsString(service);
                String sQuery = "select "+MedwanQuery.getInstance().datediff("d","a.begindate","a.enddate")+"+1 duration" +
                        " from " +
                        " (select" +
                        "   "+MedwanQuery.getInstance().iif("OC_ENCOUNTER_BEGINDATE>?","OC_ENCOUNTER_BEGINDATE","?")+" begindate," +
                        "   "+MedwanQuery.getInstance().iif("OC_ENCOUNTER_ENDDATE<?","OC_ENCOUNTER_ENDDATE","?")+" enddate " +
                        "  from OC_DIAGNOSES_VIEW a,OC_ENCOUNTERS b" +
                        "  where" +
                        "  b.OC_ENCOUNTER_TYPE='"+type+"' and " +
                        "  a.OC_DIAGNOSIS_ENCOUNTERUID="+ MedwanQuery.getInstance().convert("varchar(10)","b.OC_ENCOUNTER_SERVERID")+MedwanQuery.getInstance().concatSign()+"'.'"+MedwanQuery.getInstance().concatSign()+ MedwanQuery.getInstance().convert("varchar(10)","b.OC_ENCOUNTER_OBJECTID")+" and " +
                        "  a.OC_DIAGNOSIS_ENCOUNTEROBJECTID=b.OC_ENCOUNTER_OBJECTID and "+
                        MedwanQuery.getInstance().getConfigString("charindexFunction","charindex")+"(?,a.OC_DIAGNOSIS_CODETYPE)=1 AND " +
                        (diagnosisCode.length()==0?"'"+diagnosisCode+"'=? and ":MedwanQuery.getInstance().getConfigString("charindexFunction","charindex")+"(?,a.OC_DIAGNOSIS_CODE)=1 AND ") +
                        "  b.OC_ENCOUNTER_OUTCOME = ? and " +
                        "  b.OC_ENCOUNTER_BEGINDATE<=? and " +
                        "  b.OC_ENCOUNTER_ENDDATE>=? and " +
                        "OC_DIAGNOSIS_SERVICEUID in ("+children+") "+
                        " ) a" +
                        " order by duration";
                ps = loc_conn.prepareStatement(sQuery);
                ps.setDate(1,new java.sql.Date(dBegin.getTime()));
                ps.setDate(2,new java.sql.Date(dBegin.getTime()));
                ps.setDate(3,new java.sql.Date(dEnd.getTime()));
                ps.setDate(4,new java.sql.Date(dEnd.getTime()));
                ps.setString(5,diagnosisType);
                ps.setString(6,diagnosisCode);
                ps.setString(7,outcome);
                ps.setDate(8,new java.sql.Date(dEnd.getTime()));
                ps.setDate(9,new java.sql.Date(dBegin.getTime()));
            }
            else {
                String sQuery = "select "+MedwanQuery.getInstance().datediff("d","a.begindate","a.enddate")+"+1 duration" +
                        " from " +
                        " (select" +
                        "   "+MedwanQuery.getInstance().iif("OC_ENCOUNTER_BEGINDATE>?","OC_ENCOUNTER_BEGINDATE","?")+" begindate," +
                        "   "+MedwanQuery.getInstance().iif("OC_ENCOUNTER_ENDDATE<?","OC_ENCOUNTER_ENDDATE","?")+" enddate " +
                        "  from OC_DIAGNOSES_VIEW a,OC_ENCOUNTERS b" +
                        "  where" +
                        "  b.OC_ENCOUNTER_TYPE='"+type+"' and " +
                        "  a.OC_DIAGNOSIS_ENCOUNTERUID="+ MedwanQuery.getInstance().convert("varchar(10)","b.OC_ENCOUNTER_SERVERID")+MedwanQuery.getInstance().concatSign()+"'.'"+MedwanQuery.getInstance().concatSign()+ MedwanQuery.getInstance().convert("varchar(10)","b.OC_ENCOUNTER_OBJECTID")+" and " +
                        "  a.OC_DIAGNOSIS_ENCOUNTEROBJECTID=b.OC_ENCOUNTER_OBJECTID and "+
                        MedwanQuery.getInstance().getConfigString("charindexFunction","charindex")+"(?,a.OC_DIAGNOSIS_CODETYPE)=1 AND " +
                        (diagnosisCode.length()==0?"'"+diagnosisCode+"'=? and ":MedwanQuery.getInstance().getConfigString("charindexFunction","charindex")+"(?,a.OC_DIAGNOSIS_CODE)=1 AND ") +
                        "  b.OC_ENCOUNTER_OUTCOME = ? and " +
                        "  b.OC_ENCOUNTER_BEGINDATE<=? and " +
                        "  b.OC_ENCOUNTER_ENDDATE>=?) a" +
                        " order by duration";
                ps = loc_conn.prepareStatement(sQuery);
                ps.setDate(1,new java.sql.Date(dBegin.getTime()));
                ps.setDate(2,new java.sql.Date(dBegin.getTime()));
                ps.setDate(3,new java.sql.Date(dEnd.getTime()));
                ps.setDate(4,new java.sql.Date(dEnd.getTime()));
                ps.setString(5,diagnosisType);
                ps.setString(6,diagnosisCode);
                ps.setString(7,outcome);
                ps.setDate(8,new java.sql.Date(dEnd.getTime()));
                ps.setDate(9,new java.sql.Date(dBegin.getTime()));
            }
            ResultSet rs = ps.executeQuery();
            while (rs.next()){
                values.add(new Double(rs.getDouble("duration")));
            }
            rs.close();
            ps.close();
            int q1high=new Double(Math.ceil(values.size()/4)).intValue();
            if(values.size()==0){
                quartiles[0]= 0;
            }
            else if(values.size()<4){
                quartiles[0]= ((Double)values.elementAt(0)).doubleValue();
            }
            else if(values.size() % 4 ==0){
                quartiles[0]= ((Double)values.elementAt(q1high)).doubleValue();
            }
            else {
                quartiles[0]= (((Double)values.elementAt(q1high)).doubleValue()+((Double)values.elementAt(q1high-1)).doubleValue())/2;
            }
            int medianhigh=new Double(Math.ceil(values.size()/2)).intValue();
            if(values.size()==0){
                quartiles[1]= 0;
            }
            else if(values.size()<2){
                quartiles[1]= ((Double)values.elementAt(0)).doubleValue();
            }
            else if(values.size() % 2 !=0){
                quartiles[1]= ((Double)values.elementAt(medianhigh)).doubleValue();
            }
            else {
                quartiles[1]= (((Double)values.elementAt(medianhigh)).doubleValue()+((Double)values.elementAt(medianhigh-1)).doubleValue())/2;
            }
            int q3high=new Double(Math.ceil(values.size()*3/4)).intValue();
            if(values.size()==0){
                quartiles[2]= 0;
            }
            else if(values.size()<2){
                quartiles[2]= ((Double)values.elementAt(0)).doubleValue();
            }
            else if(values.size() % 4 ==0){
                quartiles[2]= ((Double)values.elementAt(q3high)).doubleValue();
            }
            else {
                quartiles[2]= (((Double)values.elementAt(q3high)).doubleValue()+((Double)values.elementAt(q3high-1)).doubleValue())/2;
            }
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
        return quartiles;
    }

    public void calculate(){
        calculate(start,end);
    }
}