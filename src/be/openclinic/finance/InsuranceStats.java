package be.openclinic.finance;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Vector;

import be.mxs.common.util.db.MedwanQuery;

public class InsuranceStats {
	private Connection conn;
	private PreparedStatement ps;
	private ResultSet rs;
	private String sSelect;
	private String serverId=MedwanQuery.getInstance().getConfigString("serverId");
	
	private void closeConnection(){
		try {
			if(ps!=null){
				ps.close();
			}
			if(rs!=null){
				rs.close();
			}
			conn.close();
		} catch (SQLException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
	}
	
	public java.util.Date getOneYearAgo(){
		try {
			return new SimpleDateFormat("dd/MM/yyyy").parse(new SimpleDateFormat("dd/MM/").format(new java.util.Date())+(Integer.parseInt(new SimpleDateFormat("yyyy").format(new java.util.Date()))-1)+"");
		} catch (Exception e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		return null;
	}
	
	public java.util.Date getNow(){
		return new java.util.Date();
	}
	
	public double getLastYearPrestationDebetInsurarAmount(String insurarUid){
		return getClaimedDebetInsurarAmount(insurarUid, getOneYearAgo(), getNow());
	}
	
	public int getTotalAffiliatesToday(String insurarUid){
		int total=0;
		conn=MedwanQuery.getInstance().getOpenclinicConnection();
		try {
			sSelect=" SELECT COUNT(DISTINCT OC_INSURANCE_PATIENTUID) TOTAL FROM OC_INSURANCES" +
					" WHERE" +
					(insurarUid.length()>0?" OC_INSURANCE_INSURARUID=? AND":" ?='' AND") +
					" OC_INSURANCE_STATUS='affiliate' AND" +
					" OC_INSURANCE_STOP IS NULL";
			ps=conn.prepareStatement(sSelect);
			ps.setString(1, insurarUid);
			rs=ps.executeQuery();
			if(rs.next()){
				total=rs.getInt("TOTAL");
			}
		} catch (Exception e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		finally {
			closeConnection();
		}
		return total;
	}
	
	public int getTotalCoveredToday(String insurarUid){
		int total=0;
		conn=MedwanQuery.getInstance().getOpenclinicConnection();
		try {
			sSelect=" SELECT COUNT(DISTINCT OC_INSURANCE_PATIENTUID) TOTAL FROM OC_INSURANCES" +
					" WHERE" +
					(insurarUid.length()>0?" OC_INSURANCE_INSURARUID=? AND":" ?='' AND") +
					" OC_INSURANCE_STATUS <> 'virtual' AND" +
					" OC_INSURANCE_STOP IS NULL";
			ps=conn.prepareStatement(sSelect);
			ps.setString(1, insurarUid);
			rs=ps.executeQuery();
			if(rs.next()){
				total=rs.getInt("TOTAL");
			}
		} catch (Exception e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		finally {
			closeConnection();
		}
		return total;
	}
	
	public Vector getContributionTypesDeclared(String insurarUid,java.util.Date begin,java.util.Date end){
		Vector types = new Vector();
		conn=MedwanQuery.getInstance().getOpenclinicConnection();
		try {
			sSelect=" SELECT count(*) total,OC_DEBET_PRESTATIONUID FROM OC_DEBETS a,OC_ENCOUNTERS b,OC_INSURANCES c" +
					" WHERE" +
					" b.OC_ENCOUNTER_OBJECTID=replace(a.OC_DEBET_ENCOUNTERUID,'"+serverId+".','') AND" +
					" b.OC_ENCOUNTER_PATIENTUID=c.OC_INSURANCE_PATIENTUID AND" +
					(insurarUid.length()>0?" c.OC_INSURANCE_INSURARUID=? AND":" ?='' AND") +
					" (c.OC_INSURANCE_STOP IS NULL OR c.OC_INSURANCE_STOP>a.OC_DEBET_DATE) AND" +
					" a.OC_DEBET_CREDITED<>1 AND" +
					" a.OC_DEBET_DATE>=? AND" +
					" a.OC_DEBET_DATE<=?" +
					" GROUP BY OC_DEBET_PRESTATIONUID";
			ps=conn.prepareStatement(sSelect);
			ps.setString(1, insurarUid);
			ps.setTimestamp(2, new java.sql.Timestamp(begin.getTime()));
			ps.setTimestamp(3, new java.sql.Timestamp(end.getTime()));
			rs=ps.executeQuery();
			while(rs.next()){
				types.add(rs.getString("OC_DEBET_PRESTATIONUID")+";"+rs.getString("total"));
			}
		} catch (Exception e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		finally {
			closeConnection();
		}
		return types;
	}
	
	public int getTotalAffiliatesPeriod(String insurarUid,java.util.Date begin,java.util.Date end){
		int total=0;
		conn=MedwanQuery.getInstance().getOpenclinicConnection();
		try {
			sSelect=" SELECT COUNT(DISTINCT OC_INSURANCE_PATIENTUID) TOTAL FROM OC_INSURANCES" +
					" WHERE" +
					(insurarUid.length()>0?" OC_INSURANCE_INSURARUID=? AND":" ?='' AND") +
					" OC_INSURANCE_STATUS='affiliate' AND" +
					" (OC_INSURANCE_START <=? AND (OC_INSURANCE_STOP IS NULL OR OC_INSURANCE_STOP>=?))";
			ps=conn.prepareStatement(sSelect);
			ps.setString(1, insurarUid);
			ps.setTimestamp(2, new java.sql.Timestamp(end.getTime()));
			ps.setTimestamp(3, new java.sql.Timestamp(begin.getTime()));
			rs=ps.executeQuery();
			if(rs.next()){
				total=rs.getInt("TOTAL");
			}
		} catch (Exception e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		finally {
			closeConnection();
		}
		return total;
	}
	
	public int getTotalCareProviderInsuredPeriod(String serviceUid,java.util.Date begin,java.util.Date end){
		int total=0;
		conn=MedwanQuery.getInstance().getOpenclinicConnection();
		try {
			sSelect=" SELECT COUNT(DISTINCT b.OC_ENCOUNTER_PATIENTUID) TOTAL FROM OC_PRESTATIONDEBETS a, OC_ENCOUNTERS_VIEW b" +
					" WHERE" +
					" b.OC_ENCOUNTER_OBJECTID=replace(a.OC_DEBET_ENCOUNTERUID,'"+serverId+".','') AND" +
					" b.OC_ENCOUNTER_SERVICEUID like ? AND" +
					" a.OC_DEBET_DATE >=? AND a.OC_DEBET_DATE<=?";
			ps=conn.prepareStatement(sSelect);
			ps.setString(1, serviceUid+"%");
			ps.setTimestamp(2, new java.sql.Timestamp(begin.getTime()));
			ps.setTimestamp(3, new java.sql.Timestamp(end.getTime()));
			rs=ps.executeQuery();
			if(rs.next()){
				total=rs.getInt("TOTAL");
			}
		} catch (Exception e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		finally {
			closeConnection();
		}
		return total;
	}
	
	public int getTotalCareproviderCoveredPeriod(String serviceuid,java.util.Date begin,java.util.Date end){
		int total=0;
		conn=MedwanQuery.getInstance().getOpenclinicConnection();
		try {
			sSelect=" SELECT COUNT(distinct OC_ENCOUNTER_PATIENTUID) TOTAL FROM OC_PRESTATIONDEBETS a,OC_ENCOUNTERS_VIEW b,OC_INSURANCES c" +
					" WHERE" +
					" b.OC_ENCOUNTER_OBJECTID=replace(a.OC_DEBET_ENCOUNTERUID,'"+serverId+".','') AND" +
					" b.OC_ENCOUNTER_PATIENTUID=c.OC_INSURANCE_PATIENTUID AND" +
					" b.OC_ENCOUNTER_SERVICEUID like ? AND" +
					" (c.OC_INSURANCE_STOP IS NULL OR c.OC_INSURANCE_STOP>a.OC_DEBET_DATE) AND" +
					" a.OC_DEBET_DATE>=? AND" +
					" a.OC_DEBET_DATE<=?";
			ps=conn.prepareStatement(sSelect);
			ps.setString(1, serviceuid+"%");
			ps.setTimestamp(2, new java.sql.Timestamp(begin.getTime()));
			ps.setTimestamp(3, new java.sql.Timestamp(end.getTime()));
			rs=ps.executeQuery();
			if(rs.next()){
				total=rs.getInt("TOTAL");
			}
		} catch (Exception e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		finally {
			closeConnection();
		}
		return total;
	}
	
	public int getAllAffiliatesPeriod(java.util.Date begin,java.util.Date end){
		int total=0;
		conn=MedwanQuery.getInstance().getOpenclinicConnection();
		try {
			sSelect=" SELECT COUNT(DISTINCT OC_INSURANCE_PATIENTUID) TOTAL FROM OC_INSURANCES" +
					" WHERE" +
					" OC_INSURANCE_STATUS='affiliate' AND" +
					" (OC_INSURANCE_START <=? AND (OC_INSURANCE_STOP IS NULL OR OC_INSURANCE_STOP>=?))";
			ps=conn.prepareStatement(sSelect);
			ps.setTimestamp(1, new java.sql.Timestamp(end.getTime()));
			ps.setTimestamp(2, new java.sql.Timestamp(begin.getTime()));
			rs=ps.executeQuery();
			if(rs.next()){
				total=rs.getInt("TOTAL");
			}
		} catch (Exception e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		finally {
			closeConnection();
		}
		return total;
	}
	
	public int getTotalAffiliateDaysPeriod(String insurarUid,java.util.Date begin,java.util.Date end){
		int total=0;
		conn=MedwanQuery.getInstance().getOpenclinicConnection();
		try {
			sSelect=" SELECT sum(datediff(case when OC_INSURANCE_STOP IS NULL OR OC_INSURANCE_STOP>=? then ? else OC_INSURANCE_STOP end,case when OC_INSURANCE_START<=? then ? else OC_INSURANCE_START end)) AS TOTAL FROM OC_INSURANCES" +
					" WHERE" +
					(insurarUid.length()>0?" OC_INSURANCE_INSURARUID=? AND":" ?='' AND") +
					" OC_INSURANCE_STATUS='affiliate' AND" +
					" (OC_INSURANCE_START <=? AND (OC_INSURANCE_STOP IS NULL OR OC_INSURANCE_STOP>=?))";
			ps=conn.prepareStatement(sSelect);
			ps.setTimestamp(1, new java.sql.Timestamp(end.getTime()));
			ps.setTimestamp(2, new java.sql.Timestamp(end.getTime()));
			ps.setTimestamp(3, new java.sql.Timestamp(begin.getTime()));
			ps.setTimestamp(4, new java.sql.Timestamp(begin.getTime()));
			ps.setString(5, insurarUid);
			ps.setTimestamp(6, new java.sql.Timestamp(end.getTime()));
			ps.setTimestamp(7, new java.sql.Timestamp(begin.getTime()));
			rs=ps.executeQuery();
			if(rs.next()){
				total=rs.getInt("TOTAL");
			}
		} catch (Exception e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		finally {
			closeConnection();
		}
		return total;
	}
	
	public int getAllAffiliateDaysPeriod(java.util.Date begin,java.util.Date end){
		int total=0;
		conn=MedwanQuery.getInstance().getOpenclinicConnection();
		try {
			sSelect=" SELECT sum(datediff(case when OC_INSURANCE_STOP IS NULL OR OC_INSURANCE_STOP>=? then ? else OC_INSURANCE_STOP end,case when OC_INSURANCE_START<=? then ? else OC_INSURANCE_START end)) AS TOTAL FROM OC_INSURANCES" +
					" WHERE" +
					" OC_INSURANCE_STATUS='affiliate' AND" +
					" (OC_INSURANCE_START <=? AND (OC_INSURANCE_STOP IS NULL OR OC_INSURANCE_STOP>=?))";
			ps=conn.prepareStatement(sSelect);
			ps.setTimestamp(1, new java.sql.Timestamp(end.getTime()));
			ps.setTimestamp(2, new java.sql.Timestamp(end.getTime()));
			ps.setTimestamp(3, new java.sql.Timestamp(begin.getTime()));
			ps.setTimestamp(4, new java.sql.Timestamp(begin.getTime()));
			ps.setTimestamp(5, new java.sql.Timestamp(end.getTime()));
			ps.setTimestamp(6, new java.sql.Timestamp(begin.getTime()));
			rs=ps.executeQuery();
			if(rs.next()){
				total=rs.getInt("TOTAL");
			}
		} catch (Exception e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		finally {
			closeConnection();
		}
		return total;
	}
	
	public int getTotalInsuredDaysPeriod(String insurarUid,java.util.Date begin,java.util.Date end){
		int total=0;
		conn=MedwanQuery.getInstance().getOpenclinicConnection();
		try {
			sSelect=" SELECT sum(datediff(case when OC_INSURANCE_STOP IS NULL OR OC_INSURANCE_STOP>=? then ? else OC_INSURANCE_STOP end,case when OC_INSURANCE_START<=? then ? else OC_INSURANCE_START end)) AS TOTAL FROM OC_INSURANCES" +
					" WHERE" +
					(insurarUid.length()>0?" OC_INSURANCE_INSURARUID=? AND":" ?='' AND") +
					" OC_INSURANCE_STATUS<>'virtual' AND" +
					" (OC_INSURANCE_START <=? AND (OC_INSURANCE_STOP IS NULL OR OC_INSURANCE_STOP>=?))";
			ps=conn.prepareStatement(sSelect);
			ps.setTimestamp(1, new java.sql.Timestamp(end.getTime()));
			ps.setTimestamp(2, new java.sql.Timestamp(end.getTime()));
			ps.setTimestamp(3, new java.sql.Timestamp(begin.getTime()));
			ps.setTimestamp(4, new java.sql.Timestamp(begin.getTime()));
			ps.setString(5, insurarUid);
			ps.setTimestamp(6, new java.sql.Timestamp(end.getTime()));
			ps.setTimestamp(7, new java.sql.Timestamp(begin.getTime()));
			rs=ps.executeQuery();
			if(rs.next()){
				total=rs.getInt("TOTAL");
			}
		} catch (Exception e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		finally {
			closeConnection();
		}
		return total;
	}
	
	public int getTotalCoveredPeriod(String insurarUid,java.util.Date begin,java.util.Date end){
		int total=0;
		conn=MedwanQuery.getInstance().getOpenclinicConnection();
		try {
			sSelect=" SELECT COUNT(DISTINCT OC_INSURANCE_PATIENTUID) TOTAL FROM OC_INSURANCES" +
					" WHERE" +
					(insurarUid.length()>0?" OC_INSURANCE_INSURARUID=? AND":" ?='' AND") +
					" OC_INSURANCE_STATUS <> 'virtual' AND" +
					" (OC_INSURANCE_START <=? AND (OC_INSURANCE_STOP IS NULL OR OC_INSURANCE_STOP>=?))";
			ps=conn.prepareStatement(sSelect);
			ps.setString(1, insurarUid);
			ps.setTimestamp(2, new java.sql.Timestamp(end.getTime()));
			ps.setTimestamp(3, new java.sql.Timestamp(begin.getTime()));
			rs=ps.executeQuery();
			if(rs.next()){
				total=rs.getInt("TOTAL");
			}
		} catch (Exception e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		finally {
			closeConnection();
		}
		return total;
	}
	
	public double getClaimedDebetInsurarAmount(String insurarUid,java.util.Date begin,java.util.Date end){
		double amount=0;
		conn=MedwanQuery.getInstance().getOpenclinicConnection();
		try {
			sSelect=" SELECT SUM(OC_DEBET_INSURARAMOUNT) TOTAL FROM OC_PRESTATIONDEBETS a,OC_ENCOUNTERS b,OC_INSURANCES c" +
					" WHERE" +
					" b.OC_ENCOUNTER_OBJECTID=replace(a.OC_DEBET_ENCOUNTERUID,'"+serverId+".','') AND" +
					" b.OC_ENCOUNTER_PATIENTUID=c.OC_INSURANCE_PATIENTUID AND" +
					(insurarUid.length()>0?" c.OC_INSURANCE_INSURARUID=? AND":" ?='' AND") +
					" (c.OC_INSURANCE_STOP IS NULL OR c.OC_INSURANCE_STOP>a.OC_DEBET_DATE) AND" +
					" a.OC_DEBET_DATE>=? AND" +
					" a.OC_DEBET_DATE<=?";
			ps=conn.prepareStatement(sSelect);
			ps.setString(1, insurarUid);
			ps.setTimestamp(2, new java.sql.Timestamp(begin.getTime()));
			ps.setTimestamp(3, new java.sql.Timestamp(end.getTime()));
			rs=ps.executeQuery();
			if(rs.next()){
				amount=rs.getDouble("TOTAL");
			}
		} catch (Exception e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		finally {
			closeConnection();
		}
		return amount;
	}

	public double getClaimedDebetCareproviderAmount(String serviceuid,java.util.Date begin,java.util.Date end){
		double amount=0;
		conn=MedwanQuery.getInstance().getOpenclinicConnection();
		try {
			sSelect=" SELECT SUM(OC_DEBET_INSURARAMOUNT) TOTAL FROM OC_PRESTATIONDEBETS a,OC_ENCOUNTERS_VIEW b,OC_INSURANCES c" +
					" WHERE" +
					" b.OC_ENCOUNTER_OBJECTID=replace(a.OC_DEBET_ENCOUNTERUID,'"+serverId+".','') AND" +
					" b.OC_ENCOUNTER_PATIENTUID=c.OC_INSURANCE_PATIENTUID AND" +
					" b.OC_ENCOUNTER_SERVICEUID like ? AND" +
					" (c.OC_INSURANCE_STOP IS NULL OR c.OC_INSURANCE_STOP>a.OC_DEBET_DATE) AND" +
					" a.OC_DEBET_DATE>=? AND" +
					" a.OC_DEBET_DATE<=?";
			ps=conn.prepareStatement(sSelect);
			ps.setString(1, serviceuid+"%");
			ps.setTimestamp(2, new java.sql.Timestamp(begin.getTime()));
			ps.setTimestamp(3, new java.sql.Timestamp(end.getTime()));
			rs=ps.executeQuery();
			if(rs.next()){
				amount=rs.getDouble("TOTAL");
			}
		} catch (Exception e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		finally {
			closeConnection();
		}
		return amount;
	}

	public double getClaimedDebetInsurarAmount(java.util.Date begin,java.util.Date end){
		double amount=0;
		conn=MedwanQuery.getInstance().getOpenclinicConnection();
		try {
			sSelect=" SELECT SUM(OC_DEBET_INSURARAMOUNT) TOTAL FROM OC_PRESTATIONDEBETS a,OC_ENCOUNTERS b,OC_INSURANCES c" +
					" WHERE" +
					" b.OC_ENCOUNTER_OBJECTID=replace(a.OC_DEBET_ENCOUNTERUID,'"+serverId+".','') AND" +
					" b.OC_ENCOUNTER_PATIENTUID=c.OC_INSURANCE_PATIENTUID AND" +
					" (c.OC_INSURANCE_STOP IS NULL OR c.OC_INSURANCE_STOP>a.OC_DEBET_DATE) AND" +
					" a.OC_DEBET_DATE>=? AND" +
					" a.OC_DEBET_DATE<=?";
			ps=conn.prepareStatement(sSelect);
			ps.setTimestamp(1, new java.sql.Timestamp(begin.getTime()));
			ps.setTimestamp(2, new java.sql.Timestamp(end.getTime()));
			rs=ps.executeQuery();
			if(rs.next()){
				amount=rs.getDouble("TOTAL");
			}
		} catch (Exception e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		finally {
			closeConnection();
		}
		return amount;
	}

	public double getAllAverageInsuredAmount(java.util.Date begin,java.util.Date end){
		double amount=0;
		conn=MedwanQuery.getInstance().getOpenclinicConnection();
		try {
			sSelect=" select avg(case when total is null then 0 else total end) AS AVERAGE from (" +
					" select(" +
					" select sum(oc_debet_insuraramount) from oc_prestationdebets a,oc_encounters b where" +
					" b.oc_encounter_objectid=replace(a.oc_debet_encounteruid,'"+MedwanQuery.getInstance().getConfigString("serverId")+".','') and b.oc_encounter_patientuid=c.oc_insurance_patientuid and" +
					" oc_debet_date>=? and oc_debet_date<=?" +
					" ) total, c.oc_insurance_patientuid" +
					" from (select distinct oc_insurance_patientuid from oc_insurances where oc_insurance_start<=? and" +
					" (oc_insurance_stop is null or oc_insurance_stop>?)) as c) as d";
			ps=conn.prepareStatement(sSelect);
			ps.setTimestamp(1, new java.sql.Timestamp(begin.getTime()));
			ps.setTimestamp(2, new java.sql.Timestamp(end.getTime()));
			ps.setTimestamp(3, new java.sql.Timestamp(end.getTime()));
			ps.setTimestamp(4, new java.sql.Timestamp(begin.getTime()));
			rs=ps.executeQuery();
			if(rs.next()){
				amount=rs.getDouble("AVERAGE");
			}
		} catch (Exception e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		finally {
			closeConnection();
		}
		return amount;
	}

	public double getAllAverageCareproviderAmount(String serviceCategory,java.util.Date begin,java.util.Date end){
		double amount=0;
		conn=MedwanQuery.getInstance().getOpenclinicConnection();
		try {
			sSelect=" select avg(amount) TOTAL from (" +
					" select sum(oc_debet_insuraramount) AMOUNT,OC_ENCOUNTER_SERVICEUID,OC_ENCOUNTER_PATIENTUID from oc_prestationdebets a,oc_encounters_view b,ServicesView d" +
					" where" +
					" b.OC_ENCOUNTER_SERVICEUID=d.serviceid AND" +
					" d.costcenter like ? AND" +
					" b.OC_ENCOUNTER_OBJECTID=replace(a.OC_DEBET_ENCOUNTERUID,'"+serverId+".','') AND" +
					" oc_debet_date>=? and oc_debet_date<=?" +
					" GROUP by OC_ENCOUNTER_SERVICEUID,OC_ENCOUNTER_PATIENTUID) c";
			ps=conn.prepareStatement(sSelect);
			ps.setString(1, serviceCategory+"%");
			ps.setTimestamp(2, new java.sql.Timestamp(begin.getTime()));
			ps.setTimestamp(3, new java.sql.Timestamp(end.getTime()));
			rs=ps.executeQuery();
			if(rs.next()){
				amount=rs.getDouble("TOTAL");
			}
		} catch (Exception e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		finally {
			closeConnection();
		}
		return amount;
	}

	public double getAllStdDevCareproviderAmount(String serviceCategory,java.util.Date begin,java.util.Date end){
		double amount=0;
		conn=MedwanQuery.getInstance().getOpenclinicConnection();
		try {
			sSelect=" select stddev(amount) TOTAL from (" +
					" select sum(oc_debet_insuraramount) AMOUNT,OC_ENCOUNTER_SERVICEUID,OC_ENCOUNTER_PATIENTUID from oc_prestationdebets a,oc_encounters_view b,servicesview d" +
					" where" +
					" b.OC_ENCOUNTER_SERVICEUID=d.serviceid AND" +
					" d.costcenter like ? AND" +
					" b.OC_ENCOUNTER_OBJECTID=replace(a.OC_DEBET_ENCOUNTERUID,'"+serverId+".','') AND" +
					" oc_debet_date>=? and oc_debet_date<=?" +
					" GROUP by OC_ENCOUNTER_SERVICEUID,OC_ENCOUNTER_PATIENTUID) c";
			ps=conn.prepareStatement(sSelect);
			ps.setString(1, serviceCategory+"%");
			ps.setTimestamp(2, new java.sql.Timestamp(begin.getTime()));
			ps.setTimestamp(3, new java.sql.Timestamp(end.getTime()));
			rs=ps.executeQuery();
			if(rs.next()){
				amount=rs.getDouble("TOTAL");
			}
		} catch (Exception e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		finally {
			closeConnection();
		}
		return amount;
	}

	public double getAllAverageInsuredCoverage(java.util.Date begin,java.util.Date end){
		double amount=0;
		conn=MedwanQuery.getInstance().getOpenclinicConnection();
		try {
			sSelect=" select avg(case when total is null then 0 else total end) AS AVERAGE from (" +
					" select(" +
					" select sum(oc_debet_insuraramount) from oc_debets a,oc_encounters b where" +
					" b.oc_encounter_objectid=replace(a.oc_debet_encounteruid,'"+MedwanQuery.getInstance().getConfigString("serverId")+".','') and b.oc_encounter_patientuid=c.oc_insurance_patientuid and" +
					" oc_debet_date>=? and oc_debet_date<=?" +
					" ) total, c.oc_insurance_patientuid" +
					" from (select distinct oc_insurance_patientuid from oc_insurances where oc_insurance_start<=? and" +
					" (oc_insurance_stop is null or oc_insurance_stop>?)) as c) as d";
			ps=conn.prepareStatement(sSelect);
			ps.setTimestamp(1, new java.sql.Timestamp(begin.getTime()));
			ps.setTimestamp(2, new java.sql.Timestamp(end.getTime()));
			ps.setTimestamp(3, new java.sql.Timestamp(end.getTime()));
			ps.setTimestamp(4, new java.sql.Timestamp(begin.getTime()));
			rs=ps.executeQuery();
			if(rs.next()){
				amount=rs.getDouble("AVERAGE");
			}
		} catch (Exception e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		finally {
			closeConnection();
		}
		return amount;
	}

	public double getAllStdDevInsuredAmount(java.util.Date begin,java.util.Date end){
		double amount=0;
		conn=MedwanQuery.getInstance().getOpenclinicConnection();
		try {
			sSelect=" select stddev(case when total is null then 0 else total end) as STDDEV from (" +
					" select(" +
					" select sum(oc_debet_insuraramount) from oc_prestationdebets a,oc_encounters b where" +
					" b.oc_encounter_objectid=replace(a.oc_debet_encounteruid,'"+MedwanQuery.getInstance().getConfigString("serverId")+".','') and b.oc_encounter_patientuid=c.oc_insurance_patientuid and" +
					" oc_debet_date>=? and oc_debet_date<=?" +
					" ) total, c.oc_insurance_patientuid" +
					" from (select distinct oc_insurance_patientuid from oc_insurances where oc_insurance_start<=? and" +
					" (oc_insurance_stop is null or oc_insurance_stop>?)) as c) as d";
			ps=conn.prepareStatement(sSelect);
			ps.setTimestamp(1, new java.sql.Timestamp(begin.getTime()));
			ps.setTimestamp(2, new java.sql.Timestamp(end.getTime()));
			ps.setTimestamp(3, new java.sql.Timestamp(end.getTime()));
			ps.setTimestamp(4, new java.sql.Timestamp(begin.getTime()));
			rs=ps.executeQuery();
			if(rs.next()){
				amount=rs.getDouble("STDDEV");
			}
		} catch (Exception e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		finally {
			closeConnection();
		}
		return amount;
	}

	public double getAllStdDevInsuredCoverage(java.util.Date begin,java.util.Date end){
		double amount=0;
		conn=MedwanQuery.getInstance().getOpenclinicConnection();
		try {
			sSelect=" select stddev(case when total is null then 0 else total end) as STDDEV from (" +
					" select(" +
					" select sum(oc_debet_insuraramount) from oc_debets a,oc_encounters b where" +
					" b.oc_encounter_objectid=replace(a.oc_debet_encounteruid,'"+MedwanQuery.getInstance().getConfigString("serverId")+".','') and b.oc_encounter_patientuid=c.oc_insurance_patientuid and" +
					" oc_debet_date>=? and oc_debet_date<=?" +
					" ) total, c.oc_insurance_patientuid" +
					" from (select distinct oc_insurance_patientuid from oc_insurances where oc_insurance_start<=? and" +
					" (oc_insurance_stop is null or oc_insurance_stop>?)) as c) as d";
			ps=conn.prepareStatement(sSelect);
			ps.setTimestamp(1, new java.sql.Timestamp(begin.getTime()));
			ps.setTimestamp(2, new java.sql.Timestamp(end.getTime()));
			ps.setTimestamp(3, new java.sql.Timestamp(end.getTime()));
			ps.setTimestamp(4, new java.sql.Timestamp(begin.getTime()));
			rs=ps.executeQuery();
			if(rs.next()){
				amount=rs.getDouble("STDDEV");
			}
		} catch (Exception e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		finally {
			closeConnection();
		}
		return amount;
	}

	public double getInsurerCoverageAmount(String insurarUid,java.util.Date begin,java.util.Date end){
		double amount=0;
		conn=MedwanQuery.getInstance().getOpenclinicConnection();
		try {
			sSelect=" SELECT SUM(OC_DEBET_INSURARAMOUNT) TOTAL FROM OC_DEBETS a,OC_ENCOUNTERS b,OC_INSURANCES c" +
					" WHERE" +
					" b.OC_ENCOUNTER_OBJECTID=replace(a.OC_DEBET_ENCOUNTERUID,'"+serverId+".','') AND" +
					" b.OC_ENCOUNTER_PATIENTUID=c.OC_INSURANCE_PATIENTUID AND" +
					(insurarUid.length()>0?" c.OC_INSURANCE_INSURARUID=? AND":" ?='' AND") +
					" (c.OC_INSURANCE_STOP IS NULL OR c.OC_INSURANCE_STOP>a.OC_DEBET_DATE) AND" +
					" a.OC_DEBET_INSURARINVOICEUID IS NOT NULL AND" +
					" a.OC_DEBET_INSURARINVOICEUID<>'' AND" +
					" a.OC_DEBET_DATE>=? AND" +
					" a.OC_DEBET_DATE<=?";
			ps=conn.prepareStatement(sSelect);
			ps.setString(1, insurarUid);
			ps.setTimestamp(2, new java.sql.Timestamp(begin.getTime()));
			ps.setTimestamp(3, new java.sql.Timestamp(end.getTime()));
			rs=ps.executeQuery();
			if(rs.next()){
				amount=rs.getDouble("TOTAL");
			}
		} catch (Exception e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		finally {
			closeConnection();
		}
		return amount;
	}

	public double getAcceptedDebetInsurarAmount(String insurarUid,java.util.Date begin,java.util.Date end){
		double amount=0;
		conn=MedwanQuery.getInstance().getOpenclinicConnection();
		try {
			sSelect=" SELECT SUM(OC_DEBET_INSURARAMOUNT) TOTAL FROM OC_PRESTATIONDEBETS a,OC_ENCOUNTERS b,OC_INSURANCES c" +
					" WHERE" +
					" b.OC_ENCOUNTER_OBJECTID=replace(a.OC_DEBET_ENCOUNTERUID,'"+serverId+".','') AND" +
					" b.OC_ENCOUNTER_PATIENTUID=c.OC_INSURANCE_PATIENTUID AND" +
					(insurarUid.length()>0?" c.OC_INSURANCE_INSURARUID=? AND":" ?='' AND") +
					" (c.OC_INSURANCE_STOP IS NULL OR c.OC_INSURANCE_STOP>a.OC_DEBET_DATE) AND" +
					" a.OC_DEBET_INSURARINVOICEUID IS NOT NULL AND" +
					" a.OC_DEBET_INSURARINVOICEUID<>'' AND" +
					" a.OC_DEBET_DATE>=? AND" +
					" a.OC_DEBET_DATE<=?";
			ps=conn.prepareStatement(sSelect);
			ps.setString(1, insurarUid);
			ps.setTimestamp(2, new java.sql.Timestamp(begin.getTime()));
			ps.setTimestamp(3, new java.sql.Timestamp(end.getTime()));
			rs=ps.executeQuery();
			if(rs.next()){
				amount=rs.getDouble("TOTAL");
			}
		} catch (Exception e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		finally {
			closeConnection();
		}
		return amount;
	}

	public double getAcceptedDebetCareproviderAmount(String serviceUid,java.util.Date begin,java.util.Date end){
		double amount=0;
		conn=MedwanQuery.getInstance().getOpenclinicConnection();
		try {
			sSelect=" SELECT SUM(OC_DEBET_INSURARAMOUNT) TOTAL FROM OC_PRESTATIONDEBETS a,OC_ENCOUNTERS_VIEW b,OC_INSURANCES c" +
					" WHERE" +
					" b.OC_ENCOUNTER_OBJECTID=replace(a.OC_DEBET_ENCOUNTERUID,'"+serverId+".','') AND" +
					" b.OC_ENCOUNTER_PATIENTUID=c.OC_INSURANCE_PATIENTUID AND" +
					" b.OC_ENCOUNTER_SERVICEUID like ? AND" +
					" (c.OC_INSURANCE_STOP IS NULL OR c.OC_INSURANCE_STOP>a.OC_DEBET_DATE) AND" +
					" a.OC_DEBET_INSURARINVOICEUID IS NOT NULL AND" +
					" a.OC_DEBET_INSURARINVOICEUID<>'' AND" +
					" a.OC_DEBET_DATE>=? AND" +
					" a.OC_DEBET_DATE<=?";
			ps=conn.prepareStatement(sSelect);
			ps.setString(1, serviceUid+"%");
			ps.setTimestamp(2, new java.sql.Timestamp(begin.getTime()));
			ps.setTimestamp(3, new java.sql.Timestamp(end.getTime()));
			rs=ps.executeQuery();
			if(rs.next()){
				amount=rs.getDouble("TOTAL");
			}
		} catch (Exception e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		finally {
			closeConnection();
		}
		return amount;
	}

}
