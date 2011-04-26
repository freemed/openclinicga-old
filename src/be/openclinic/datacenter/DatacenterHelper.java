package be.openclinic.datacenter;

import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.SQLException;

import java.sql.PreparedStatement;
import java.text.DecimalFormat;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Hashtable;
import java.util.Vector;

import be.mxs.common.util.db.MedwanQuery;

public class DatacenterHelper {
	static Hashtable lastvalues;
	
	public static Hashtable getLastvalues() {
		return lastvalues;
	}
	
	public static void setLastvalues(Hashtable lastvalues) {
		DatacenterHelper.lastvalues = lastvalues;
	}
	
	public static Hashtable getLastSimpleValues(){
		Hashtable h = new Hashtable();
		Connection conn=MedwanQuery.getInstance().getStatsConnection();
		try{
			PreparedStatement ps = conn.prepareStatement("select * from dc_simplevalues a," +
					" (select max(dc_simplevalue_createdatetime) maxdate,dc_simplevalue_serverid,dc_simplevalue_parameterid from dc_simplevalues group by dc_simplevalue_serverid,dc_simplevalue_parameterid) b " +
					" where a.dc_simplevalue_createdatetime=b.maxdate and a.dc_simplevalue_serverid=b.dc_simplevalue_serverid and a.dc_simplevalue_parameterid=b.dc_simplevalue_parameterid");
			ResultSet rs = ps.executeQuery();
			while(rs.next()){
				h.put(rs.getString("DC_SIMPLEVALUE_SERVERID")+"."+rs.getString("DC_SIMPLEVALUE_PARAMETERID"),rs.getString("DC_SIMPLEVALUE_DATA"));
			}
			rs.close();
			ps.close();
		} catch (SQLException e) {
			e.printStackTrace();
		}
		finally {
			try {
				conn.close();
			} catch (SQLException e) {
				e.printStackTrace();
			}
		}
		return h;
	}
	public static String getLastSimpleValue(int serverid,String parameterid){
		String value="?";
		Connection conn=MedwanQuery.getInstance().getStatsConnection();
		try{
			PreparedStatement ps = conn.prepareStatement("select DC_SIMPLEVALUE_DATA from DC_SIMPLEVALUES where DC_SIMPLEVALUE_SERVERID=? and DC_SIMPLEVALUE_PARAMETERID=? order by DC_SIMPLEVALUE_CREATEDATETIME DESC");
			ps.setInt(1, serverid);
			ps.setString(2, parameterid);
			ResultSet rs = ps.executeQuery();
			if(rs.next()){
				value=rs.getString("DC_SIMPLEVALUE_DATA");
			}
			rs.close();
			ps.close();
		} catch (SQLException e) {
			e.printStackTrace();
		}
		finally {
			try {
				conn.close();
			} catch (SQLException e) {
				e.printStackTrace();
			}
		}
		return value;
	}
	public static String getLastSimpleValue(int serverid,String parameterid,Hashtable h){
		String value="?";
		if(h.get(serverid+"."+parameterid)!=null){
			value=(String)h.get(serverid+"."+parameterid);
		}
		return value;
	}
	public static String getLastSimpleValueFormatted(int serverid,String parameterid){
		String value=getLastSimpleValue(serverid, parameterid);
		if(value!=null && !value.equalsIgnoreCase("?")){
			value=new java.text.DecimalFormat("#,###").format(Integer.parseInt(value));
		}
		return value;
	}
	
	public static String getLastSimpleValueFormatted(int serverid,String parameterid,Hashtable lastvalues){
		String value=getLastSimpleValue(serverid, parameterid,lastvalues);
		if(value!=null && !value.equalsIgnoreCase("?")){
			value=new java.text.DecimalFormat("#,###").format(Integer.parseInt(value));
		}
		return value;
	}
	
	public static String getFinancialValue(int serverid,String parameterid,String period){
		String value="?";
		Connection conn=MedwanQuery.getInstance().getStatsConnection();
		try{
			String sQuery;
			if(period.split("\\.").length==2){
				sQuery="select DC_FINANCIALVALUE_VALUE from DC_FINANCIALVALUES where DC_FINANCIALVALUE_SERVERID=? and DC_FINANCIALVALUE_PARAMETERID=? and DC_FINANCIALVALUE_YEAR=? and DC_FINANCIALVALUE_MONTH=?";
			}
			else {
				sQuery="select SUM(DC_FINANCIALVALUE_VALUE) AS DC_FINANCIALVALUE_VALUE from DC_FINANCIALVALUES where DC_FINANCIALVALUE_SERVERID=? and DC_FINANCIALVALUE_PARAMETERID=? and DC_FINANCIALVALUE_YEAR=?";
			}
			PreparedStatement ps = conn.prepareStatement(sQuery);
			ps.setInt(1, serverid);
			ps.setString(2, parameterid);
			ps.setInt(3, Integer.parseInt(period.split("\\.")[0]));
			if(period.split("\\.").length==2){
				ps.setInt(4, Integer.parseInt(period.split("\\.")[1]));
			}
			ResultSet rs = ps.executeQuery();
			if(rs.next()){
				value=rs.getString("DC_FINANCIALVALUE_VALUE");
			}
			rs.close();
			ps.close();
		} catch (SQLException e) {
			e.printStackTrace();
		}
		finally {
			try {
				conn.close();
			} catch (SQLException e) {
				e.printStackTrace();
			}
		}
		return value;
	}
	
	public static java.util.Date getEndOfPreviousMonth(){
		try {
			return  new java.util.Date(new SimpleDateFormat("yyyyMMdd").parse(new SimpleDateFormat("yyyyMM").format(new java.util.Date())+"01").getTime()-1);
		} catch (ParseException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		return null;
	}
	
	public static java.util.Date getBeginOfPreviousMonth(){
		try {
			return new SimpleDateFormat("yyyyMMdd").parse(new SimpleDateFormat("yyyyMM").format(getEndOfPreviousMonth())+"01");
		} catch (ParseException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		return null;
	}
	
	public static java.util.Date getLastDate(int serverid){
		java.util.Date value=null;
		Connection conn=MedwanQuery.getInstance().getStatsConnection();
		try{
			PreparedStatement ps = conn.prepareStatement("select max(DC_SIMPLEVALUE_CREATEDATETIME) lastcreate from DC_SIMPLEVALUES where DC_SIMPLEVALUE_SERVERID=?");
			ps.setInt(1, serverid);
			ResultSet rs = ps.executeQuery();
			if(rs.next()){
				value= rs.getTimestamp("lastcreate");
			}
			rs.close();
			ps.close();
		} catch (SQLException e) {
			e.printStackTrace();
		}
		finally {
			try {
				conn.close();
			} catch (SQLException e) {
				e.printStackTrace();
			}
		}
		return value;
	}
	
	public static String getGroupsForServer(int serverid, String sLanguage){
		String groups="";
		Connection conn=MedwanQuery.getInstance().getOpenclinicConnection();
		try{
			PreparedStatement ps = conn.prepareStatement("select * from DC_SERVERGROUPS where DC_SERVERGROUP_SERVERID=?");
			ps.setInt(1, serverid);
			ResultSet rs = ps.executeQuery();
			while(rs.next()){
				groups+=MedwanQuery.getInstance().getLabel("datacenterServerGroup", rs.getString("DC_SERVERGROUP_ID"), sLanguage)+" ";
			}
			rs.close();
			ps.close();
		} catch (SQLException e) {
			e.printStackTrace();
		}
		finally {
			try {
				conn.close();
			} catch (SQLException e) {
				e.printStackTrace();
			}
		}
		return groups;
	}
	
	public static Vector getDiagnoses(int serverid, String period, String codetype){
		if(period.split("\\.").length>1){
			return getDiagnoses(serverid, Integer.parseInt(period.split("\\.")[0]), Integer.parseInt(period.split("\\.")[1]),codetype);
		}
		else {
			return getDiagnoses(serverid, Integer.parseInt(period.split("\\.")[0]),codetype);
		}
	}
	
	public static Vector getEncounterDiagnoses(int serverid, String period, String codetype,String encounterType){
		if(period.split("\\.").length>1){
			return getEncounterDiagnoses(serverid, Integer.parseInt(period.split("\\.")[0]), Integer.parseInt(period.split("\\.")[1]),codetype, encounterType);
		}
		else {
			return getEncounterDiagnoses(serverid, Integer.parseInt(period.split("\\.")[0]),codetype, encounterType);
		}
	}
	
	public static Vector getDiagnoses(int serverid, int year, int month, String codetype){
		Vector v = new Vector();
		Connection conn=MedwanQuery.getInstance().getStatsConnection();
		try{
			String sQuery="select distinct * from DC_DIAGNOSISVALUES where DC_DIAGNOSISVALUE_SERVERID=? and DC_DIAGNOSISVALUE_YEAR=? and DC_DIAGNOSISVALUE_MONTH=? and DC_DIAGNOSISVALUE_CODETYPE=? order by DC_DIAGNOSISVALUE_CODE";
			PreparedStatement ps = conn.prepareStatement(sQuery);
			ps.setInt(1, serverid);
			ps.setInt(2,year);
			ps.setInt(3,month);
			ps.setString(4,codetype);
			ResultSet rs = ps.executeQuery();
			while(rs.next()){
				v.add(rs.getString("DC_DIAGNOSISVALUE_CODE")+";"+rs.getString("DC_DIAGNOSISVALUE_COUNT"));
			}
			rs.close();
			ps.close();
		} catch (SQLException e) {
			e.printStackTrace();
		}
		finally {
			try {
				conn.close();
			} catch (SQLException e) {
				e.printStackTrace();
			}
		}
		return v;
	}
	

	public static Vector getMortalities(int serverid, int year, int month, String codetype){
		Vector v = new Vector();
		Connection conn=MedwanQuery.getInstance().getStatsConnection();
		try{
			String sQuery="select * from DC_MORTALITYVALUES where DC_MORTALITYVALUE_SERVERID=? and DC_MORTALITYVALUE_YEAR=? and DC_MORTALITYVALUE_MONTH=? and DC_MORTALITYVALUE_CODETYPE=? order by DC_MORTALITYVALUE_CODE";
			PreparedStatement ps = conn.prepareStatement(sQuery);
			ps.setInt(1, serverid);
			ps.setInt(2,year);
			ps.setInt(3,month);
			ps.setString(4,codetype);
			ResultSet rs = ps.executeQuery();
			while(rs.next()){
				v.add(rs.getString("DC_MORTALITYVALUE_CODE")+";"+rs.getString("DC_MORTALITYVALUE_COUNT")+";"+rs.getString("DC_MORTALITYVALUE_DIAGNOSISCOUNT"));
			}
			rs.close();
			ps.close();
		} catch (SQLException e) {
			e.printStackTrace();
		}
		finally {
			try {
				conn.close();
			} catch (SQLException e) {
				e.printStackTrace();
			}
		}
		return v;
	}
	
	public static Vector getMortalities(int serverid, int year, String codetype){
		Vector v = new Vector();
		Connection conn=MedwanQuery.getInstance().getStatsConnection();
		try{
			String sQuery="select SUM(DC_MORTALITYVALUE_COUNT) DC_MORTALITYVALUE_COUNT,SUM(DC_MORTALITYVALUE_DIAGNOSISCOUNT) DC_MORTALITYVALUE_DIAGNOSISCOUNT,DC_MORTALITYVALUE_CODE from DC_MORTALITYVALUES where DC_MORTALITYVALUE_SERVERID=? and DC_MORTALITYVALUE_YEAR=? and DC_MORTALITYVALUE_CODETYPE=? group by DC_MORTALITYVALUE_CODE order by DC_MORTALITYVALUE_CODE";
			PreparedStatement ps = conn.prepareStatement(sQuery);
			ps.setInt(1, serverid);
			ps.setInt(2,year);
			ps.setString(3,codetype);
			ResultSet rs = ps.executeQuery();
			while(rs.next()){
				v.add(rs.getString("DC_MORTALITYVALUE_CODE")+";"+rs.getString("DC_MORTALITYVALUE_COUNT")+";"+rs.getString("DC_MORTALITYVALUE_DIAGNOSISCOUNT"));
			}
			rs.close();
			ps.close();
		} catch (SQLException e) {
			e.printStackTrace();
		}
		finally {
			try {
				conn.close();
			} catch (SQLException e) {
				e.printStackTrace();
			}
		}
		return v;
	}
	
	public static String getTotalMortalities(int serverid, int year, int month){
		String s="0";
		Connection conn=MedwanQuery.getInstance().getStatsConnection();
		try{
			String sQuery="select * from DC_MORTALITYVALUES where DC_MORTALITYVALUE_SERVERID=? and DC_MORTALITYVALUE_YEAR=? and DC_MORTALITYVALUE_MONTH=? and DC_MORTALITYVALUE_CODETYPE is NULL";
			PreparedStatement ps = conn.prepareStatement(sQuery);
			ps.setInt(1, serverid);
			ps.setInt(2,year);
			ps.setInt(3,month);
			ResultSet rs = ps.executeQuery();
			if(rs.next()){
				s=rs.getString("DC_MORTALITYVALUE_COUNT");
			}
			rs.close();
			ps.close();
		} catch (SQLException e) {
			e.printStackTrace();
		}
		finally {
			try {
				conn.close();
			} catch (SQLException e) {
				e.printStackTrace();
			}
		}
		return s;
	}
	
	public static String getTotalMortalities(int serverid, int year){
		String s="0";
		Connection conn=MedwanQuery.getInstance().getStatsConnection();
		try{
			String sQuery="select SUM(DC_MORTALITYVALUE_COUNT) DC_MORTALITYVALUE_COUNT from DC_MORTALITYVALUES where DC_MORTALITYVALUE_SERVERID=? and DC_MORTALITYVALUE_YEAR=? and DC_MORTALITYVALUE_CODETYPE is NULL";
			PreparedStatement ps = conn.prepareStatement(sQuery);
			ps.setInt(1, serverid);
			ps.setInt(2,year);
			ResultSet rs = ps.executeQuery();
			if(rs.next()){
				s=rs.getString("DC_MORTALITYVALUE_COUNT");
			}
			rs.close();
			ps.close();
		} catch (SQLException e) {
			e.printStackTrace();
		}
		finally {
			try {
				conn.close();
			} catch (SQLException e) {
				e.printStackTrace();
			}
		}
		return s;
	}
	
	public static Vector getMortalities(int serverid, String period, String codetype){
		if(period.split("\\.").length>1){
			return getMortalities(serverid, Integer.parseInt(period.split("\\.")[0]), Integer.parseInt(period.split("\\.")[1]),codetype);
		}
		else {
			return getMortalities(serverid, Integer.parseInt(period.split("\\.")[0]),codetype);
		}
	}
	
	public static String getTotalMortalities(int serverid, String period){
		if(period.split("\\.").length>1){
			return getTotalMortalities(serverid, Integer.parseInt(period.split("\\.")[0]), Integer.parseInt(period.split("\\.")[1]));
		}
		else {
			return getTotalMortalities(serverid, Integer.parseInt(period.split("\\.")[0]));
		}
	}
	
	public static Vector getFinancials(int serverid, String period){
		if(period.split("\\.").length>1){
			return getFinancials(serverid, Integer.parseInt(period.split("\\.")[0]), Integer.parseInt(period.split("\\.")[1]));
		}
		else {
			return getFinancials(serverid, Integer.parseInt(period.split("\\.")[0]));
		}
	}
	
	public static Vector getFinancials(int serverid, int year, int month){
		Vector v = new Vector();
		Connection conn=MedwanQuery.getInstance().getStatsConnection();
		try{
			String sQuery="select * from DC_FINANCIALVALUES where DC_FINANCIALVALUE_SERVERID=? and DC_FINANCIALVALUE_YEAR=? and DC_FINANCIALVALUE_MONTH=? and DC_FINANCIALVALUE_PARAMETERID='financial.4' order by DC_FINANCIALVALUE_CLASS";
			PreparedStatement ps = conn.prepareStatement(sQuery);
			ps.setInt(1, serverid);
			ps.setInt(2,year);
			ps.setInt(3,month);
			ResultSet rs = ps.executeQuery();
			while(rs.next()){
				v.add(rs.getString("DC_FINANCIALVALUE_CLASS")+";"+rs.getString("DC_FINANCIALVALUE_VALUE"));
			}
			rs.close();
			ps.close();
		} catch (SQLException e) {
			e.printStackTrace();
		}
		finally {
			try {
				conn.close();
			} catch (SQLException e) {
				e.printStackTrace();
			}
		}
		return v;
	}

	public static Vector getFinancials(int serverid, int year){
		Vector v = new Vector();
		Connection conn=MedwanQuery.getInstance().getStatsConnection();
		try{
			String sQuery="select sum(DC_FINANCIALVALUE_VALUE) DC_FINANCIALVALUE_VALUE,DC_FINANCIALVALUE_CLASS from DC_FINANCIALVALUES where DC_FINANCIALVALUE_SERVERID=? and DC_FINANCIALVALUE_YEAR=? and DC_FINANCIALVALUE_PARAMETERID='financial.4' group by DC_FINANCIALVALUE_CLASS order by DC_FINANCIALVALUE_CLASS";
			PreparedStatement ps = conn.prepareStatement(sQuery);
			ps.setInt(1, serverid);
			ps.setInt(2,year);
			ResultSet rs = ps.executeQuery();
			while(rs.next()){
				v.add(rs.getString("DC_FINANCIALVALUE_CLASS")+";"+rs.getString("DC_FINANCIALVALUE_VALUE"));
			}
			rs.close();
			ps.close();
		} catch (SQLException e) {
			e.printStackTrace();
		}
		finally {
			try {
				conn.close();
			} catch (SQLException e) {
				e.printStackTrace();
			}
		}
		return v;
	}
	
	public static Vector getEncounterDiagnoses(int serverid, int year, int month, String codetype, String encounterType){
		Vector v = new Vector();
		Connection conn=MedwanQuery.getInstance().getStatsConnection();
		try{
			String sQuery="select distinct * from DC_ENCOUNTERDIAGNOSISVALUES where DC_DIAGNOSISVALUE_SERVERID=? and DC_DIAGNOSISVALUE_YEAR=? and DC_DIAGNOSISVALUE_MONTH=? and DC_DIAGNOSISVALUE_CODETYPE=? and DC_DIAGNOSISVALUE_ENCOUNTERTYPE like '"+encounterType+"%' order by DC_DIAGNOSISVALUE_CODE";
			PreparedStatement ps = conn.prepareStatement(sQuery);
			ps.setInt(1, serverid);
			ps.setInt(2,year);
			ps.setInt(3,month);
			ps.setString(4,codetype);
			ResultSet rs = ps.executeQuery();
			while(rs.next()){
				v.add(rs.getString("DC_DIAGNOSISVALUE_CODE")+";"+rs.getString("DC_DIAGNOSISVALUE_COUNT"));
			}
			rs.close();
			ps.close();
		} catch (SQLException e) {
			e.printStackTrace();
		}
		finally {
			try {
				conn.close();
			} catch (SQLException e) {
				e.printStackTrace();
			}
		}
		return v;
	}
	
	public static Vector getDiagnoses(int serverid, int year, String codetype){
		Vector v = new Vector();
		Connection conn=MedwanQuery.getInstance().getStatsConnection();
		try{
			String sQuery="select sum(DC_DIAGNOSISVALUE_COUNT) DC_DIAGNOSISVALUE_COUNT,DC_DIAGNOSISVALUE_CODE from DC_DIAGNOSISVALUES where DC_DIAGNOSISVALUE_SERVERID=? and DC_DIAGNOSISVALUE_YEAR=? and DC_DIAGNOSISVALUE_CODETYPE=? group by DC_DIAGNOSISVALUE_CODE order by DC_DIAGNOSISVALUE_CODE";
			PreparedStatement ps = conn.prepareStatement(sQuery);
			ps.setInt(1, serverid);
			ps.setInt(2,year);
			ps.setString(3,codetype);
			ResultSet rs = ps.executeQuery();
			while(rs.next()){
				v.add(rs.getString("DC_DIAGNOSISVALUE_CODE")+";"+rs.getString("DC_DIAGNOSISVALUE_COUNT"));
			}
			rs.close();
			ps.close();
		} catch (SQLException e) {
			e.printStackTrace();
		}
		finally {
			try {
				conn.close();
			} catch (SQLException e) {
				e.printStackTrace();
			}
		}
		return v;
	}
	
	public static Vector getBedoccupancy(int serverid){
		Vector v = new Vector();
		Connection conn=MedwanQuery.getInstance().getStatsConnection();
		try{
			String sQuery="select max(DC_BEDOCCUPANCYVALUE_DATE) DC_BEDOCCUPANCYVALUE_DATE from DC_BEDOCCUPANCYVALUES where DC_BEDOCCUPANCYVALUE_SERVERID=?";
			PreparedStatement ps = conn.prepareStatement(sQuery);
			ps.setInt(1, serverid);
			ResultSet rs = ps.executeQuery();
			if(rs.next()){
				java.util.Date date = rs.getTimestamp("DC_BEDOCCUPANCYVALUE_DATE");
				rs.close();
				ps.close();
				if(date!=null){
					sQuery="select max(DC_BEDOCCUPANCYVALUE_OBJECTID) DC_BEDOCCUPANCYVALUE_OBJECTID from DC_BEDOCCUPANCYVALUES where DC_BEDOCCUPANCYVALUE_SERVERID=? and DC_BEDOCCUPANCYVALUE_DATE=?";
					ps = conn.prepareStatement(sQuery);
					ps.setInt(1, serverid);
					ps.setTimestamp(2, new java.sql.Timestamp(date.getTime()));
					rs = ps.executeQuery();
					if(rs.next()){
						int objectid=rs.getInt("DC_BEDOCCUPANCYVALUE_OBJECTID");
						rs.close();
						ps.close();
						sQuery="select distinct DC_BEDOCCUPANCYVALUE_SERVICEUID,DC_BEDOCCUPANCYVALUE_TOTALBEDS,DC_BEDOCCUPANCYVALUE_OCCUPIEDBEDS from DC_BEDOCCUPANCYVALUES where DC_BEDOCCUPANCYVALUE_SERVERID=? and DC_BEDOCCUPANCYVALUE_OBJECTID=? ORDER BY DC_BEDOCCUPANCYVALUE_SERVICEUID";
						ps = conn.prepareStatement(sQuery);
						ps.setInt(1, serverid);
						ps.setInt(2, objectid);
						rs = ps.executeQuery();
						while(rs.next()){
							double count=rs.getInt("DC_BEDOCCUPANCYVALUE_OCCUPIEDBEDS");
							double total=rs.getInt("DC_BEDOCCUPANCYVALUE_TOTALBEDS");
							String pct=new DecimalFormat("0.00").format(count*100/total);
							v.add(rs.getString("DC_BEDOCCUPANCYVALUE_SERVICEUID")+";"+new Double(count).intValue()+"/"+new Double(total).intValue()+";"+pct);
						}
					}
				}
			}
			rs.close();
			ps.close();
		} catch (SQLException e) {
			e.printStackTrace();
		}
		finally {
			try {
				conn.close();
			} catch (SQLException e) {
				e.printStackTrace();
			}
		}
		return v;
	}
	
	public static String getGlobalBedoccupancy(int serverid){
		String pct="?";
		Connection conn=MedwanQuery.getInstance().getStatsConnection();
		try{
			String sQuery="select max(DC_BEDOCCUPANCYVALUE_DATE) DC_BEDOCCUPANCYVALUE_DATE from DC_BEDOCCUPANCYVALUES where DC_BEDOCCUPANCYVALUE_SERVERID=?";
			PreparedStatement ps = conn.prepareStatement(sQuery);
			ps.setInt(1, serverid);
			ResultSet rs = ps.executeQuery();
			if(rs.next()){
				java.util.Date date = rs.getTimestamp("DC_BEDOCCUPANCYVALUE_DATE");
				rs.close();
				ps.close();
				if(date!=null){
					sQuery="select max(DC_BEDOCCUPANCYVALUE_OBJECTID) DC_BEDOCCUPANCYVALUE_OBJECTID from DC_BEDOCCUPANCYVALUES where DC_BEDOCCUPANCYVALUE_SERVERID=? and DC_BEDOCCUPANCYVALUE_DATE=?";
					ps = conn.prepareStatement(sQuery);
					ps.setInt(1, serverid);
					ps.setTimestamp(2, new java.sql.Timestamp(date.getTime()));
					rs = ps.executeQuery();
					if(rs.next()){
						int objectid=rs.getInt("DC_BEDOCCUPANCYVALUE_OBJECTID");
						rs.close();
						ps.close();
						sQuery="select sum(DC_BEDOCCUPANCYVALUE_OCCUPIEDBEDS) DC_BEDOCCUPANCYVALUE_OCCUPIEDBEDS,sum(DC_BEDOCCUPANCYVALUE_TOTALBEDS) DC_BEDOCCUPANCYVALUE_TOTALBEDS from (select distinct DC_BEDOCCUPANCYVALUE_SERVICEUID,DC_BEDOCCUPANCYVALUE_TOTALBEDS,DC_BEDOCCUPANCYVALUE_OCCUPIEDBEDS from DC_BEDOCCUPANCYVALUES where DC_BEDOCCUPANCYVALUE_SERVERID=? and DC_BEDOCCUPANCYVALUE_OBJECTID=?) a";
						ps = conn.prepareStatement(sQuery);
						ps.setInt(1, serverid);
						ps.setInt(2, objectid);
						rs = ps.executeQuery();
						if(rs.next()){
							double count=rs.getInt("DC_BEDOCCUPANCYVALUE_OCCUPIEDBEDS");
							double total=rs.getInt("DC_BEDOCCUPANCYVALUE_TOTALBEDS");
							pct=new Double(count).intValue()+"/"+new Double(total).intValue()+" = "+new DecimalFormat("0.00").format(count*100/total);
						}
					}
				}
			}
			rs.close();
			ps.close();
		} catch (SQLException e) {
			e.printStackTrace();
		}
		finally {
			try {
				conn.close();
			} catch (SQLException e) {
				e.printStackTrace();
			}
		}
		return pct;
	}
	
	public static Vector getEncounterDiagnoses(int serverid, int year, String codetype, String encounterType){
		Vector v = new Vector();
		Connection conn=MedwanQuery.getInstance().getStatsConnection();
		try{
			String sQuery="select sum(DC_DIAGNOSISVALUE_COUNT) DC_DIAGNOSISVALUE_COUNT,DC_DIAGNOSISVALUE_CODE from DC_ENCOUNTERDIAGNOSISVALUES where DC_DIAGNOSISVALUE_SERVERID=? and DC_DIAGNOSISVALUE_YEAR=? and DC_DIAGNOSISVALUE_CODETYPE=? and DC_DIAGNOSISVALUE_ENCOUNTERTYPE like '"+encounterType+"%' group by DC_DIAGNOSISVALUE_CODE order by DC_DIAGNOSISVALUE_CODE";
			PreparedStatement ps = conn.prepareStatement(sQuery);
			ps.setInt(1, serverid);
			ps.setInt(2,year);
			ps.setString(3,codetype);
			ResultSet rs = ps.executeQuery();
			while(rs.next()){
				v.add(rs.getString("DC_DIAGNOSISVALUE_CODE")+";"+rs.getString("DC_DIAGNOSISVALUE_COUNT"));
			}
			rs.close();
			ps.close();
		} catch (SQLException e) {
			e.printStackTrace();
		}
		finally {
			try {
				conn.close();
			} catch (SQLException e) {
				e.printStackTrace();
			}
		}
		return v;
	}
	
	public static Vector getDiagnosticMonths(int serverid){
		Vector v = new Vector();
		Connection conn=MedwanQuery.getInstance().getStatsConnection();
		try{
			String sQuery="select distinct DC_DIAGNOSISVALUE_YEAR,"+MedwanQuery.getInstance().convert("varchar","DC_DIAGNOSISVALUE_YEAR")+MedwanQuery.getInstance().concatSign()+"'.'"+MedwanQuery.getInstance().concatSign()+MedwanQuery.getInstance().convert("varchar","DC_DIAGNOSISVALUE_MONTH")+" as diagnosis from DC_DIAGNOSISVALUES where DC_DIAGNOSISVALUE_SERVERID=? order by DC_DIAGNOSISVALUE_YEAR DESC,DC_DIAGNOSISVALUE_MONTH DESC";
			PreparedStatement ps = conn.prepareStatement(sQuery);
			ps.setInt(1, serverid);
			ResultSet rs = ps.executeQuery();
			String activeYear="",year="";
			while(rs.next()){
				year=rs.getString("DC_DIAGNOSISVALUE_YEAR");
				if(!activeYear.equalsIgnoreCase(year)){
					activeYear=year;
					v.add(year);
				}
				v.add(rs.getString("diagnosis"));
			}
			rs.close();
			ps.close();
		} catch (SQLException e) {
			e.printStackTrace();
		}
		finally {
			try {
				conn.close();
			} catch (SQLException e) {
				e.printStackTrace();
			}
		}
		return v;
	}
	
	public static Vector getMortalityMonths(int serverid){
		Vector v = new Vector();
		Connection conn=MedwanQuery.getInstance().getStatsConnection();
		try{
			String sQuery="select distinct DC_MORTALITYVALUE_YEAR,"+MedwanQuery.getInstance().convert("varchar","DC_MORTALITYVALUE_YEAR")+MedwanQuery.getInstance().concatSign()+"'.'"+MedwanQuery.getInstance().concatSign()+MedwanQuery.getInstance().convert("varchar","DC_MORTALITYVALUE_MONTH")+" as diagnosis from DC_MORTALITYVALUES where DC_MORTALITYVALUE_SERVERID=? order by DC_MORTALITYVALUE_YEAR DESC,DC_MORTALITYVALUE_MONTH DESC";
			PreparedStatement ps = conn.prepareStatement(sQuery);
			ps.setInt(1, serverid);
			ResultSet rs = ps.executeQuery();
			String activeYear="",year="";
			while(rs.next()){
				year=rs.getString("DC_MORTALITYVALUE_YEAR");
				if(!activeYear.equalsIgnoreCase(year)){
					activeYear=year;
					v.add(year);
				}
				v.add(rs.getString("diagnosis"));
			}
			rs.close();
			ps.close();
		} catch (SQLException e) {
			e.printStackTrace();
		}
		finally {
			try {
				conn.close();
			} catch (SQLException e) {
				e.printStackTrace();
			}
		}
		return v;
	}
	
	public static Vector getFinancialMonths(int serverid){
		Vector v = new Vector();
		Connection conn=MedwanQuery.getInstance().getStatsConnection();
		try{
			String sQuery="select distinct DC_FINANCIALVALUE_YEAR,"+MedwanQuery.getInstance().convert("varchar","DC_FINANCIALVALUE_YEAR")+MedwanQuery.getInstance().concatSign()+"'.'"+MedwanQuery.getInstance().concatSign()+MedwanQuery.getInstance().convert("varchar","DC_FINANCIALVALUE_MONTH")+" as financial from DC_FINANCIALVALUES where DC_FINANCIALVALUE_SERVERID=? order by DC_FINANCIALVALUE_YEAR DESC,DC_FINANCIALVALUE_MONTH DESC";
			PreparedStatement ps = conn.prepareStatement(sQuery);
			ps.setInt(1, serverid);
			ResultSet rs = ps.executeQuery();
			String activeYear="",year="";
			while(rs.next()){
				year=rs.getString("DC_FINANCIALVALUE_YEAR");
				if(!activeYear.equalsIgnoreCase(year)){
					activeYear=year;
					v.add(year);
				}
				v.add(rs.getString("financial"));
			}
			rs.close();
			ps.close();
		} catch (SQLException e) {
			e.printStackTrace();
		}
		finally {
			try {
				conn.close();
			} catch (SQLException e) {
				e.printStackTrace();
			}
		}
		return v;
	}
	
	public static boolean hasEncounterDiagnosticMonths(int serverid,String type){
		boolean v=false;;
		Connection conn=MedwanQuery.getInstance().getStatsConnection();
		try{
			String sQuery="select count(*) total from DC_ENCOUNTERDIAGNOSISVALUES where DC_DIAGNOSISVALUE_SERVERID=? and DC_DIAGNOSISVALUE_ENCOUNTERTYPE=?";
			PreparedStatement ps = conn.prepareStatement(sQuery);
			ps.setInt(1, serverid);
			ps.setString(2, type);
			ResultSet rs = ps.executeQuery();
			while(rs.next()){
				v=rs.getInt("total")>0;
			}
			rs.close();
			ps.close();
		} catch (SQLException e) {
			e.printStackTrace();
		}
		finally {
			try {
				conn.close();
			} catch (SQLException e) {
				e.printStackTrace();
			}
		}
		return v;
	}
	
	public static String getServerLocation(int serverid){
		String location="";
		Connection conn=MedwanQuery.getInstance().getOpenclinicConnection();
		try{
			PreparedStatement ps = conn.prepareStatement("select * from DC_SERVERS where DC_SERVER_SERVERID=?");
			ps.setInt(1, serverid);
			ResultSet rs = ps.executeQuery();
			while(rs.next()){
				location=rs.getString("DC_SERVER_LOCATION");
			}
			rs.close();
			ps.close();
		} catch (SQLException e) {
			e.printStackTrace();
		}
		finally {
			try {
				conn.close();
			} catch (SQLException e) {
				e.printStackTrace();
			}
		}
		return location;
	}
}
