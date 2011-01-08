package be.openclinic.datacenter;

import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.SQLException;

import java.sql.PreparedStatement;
import java.util.Vector;

import be.mxs.common.util.db.MedwanQuery;

public class DatacenterHelper {
	public static String getLastSimpleValue(int serverid,String parameterid){
		String value="?";
		Connection conn=MedwanQuery.getInstance().getStatsConnection();
		try{
			PreparedStatement ps = conn.prepareStatement("select max(DC_SIMPLEVALUE_CREATEDATETIME) lastcreate from DC_SIMPLEVALUES where DC_SIMPLEVALUE_SERVERID=? and DC_SIMPLEVALUE_PARAMETERID=?");
			ps.setInt(1, serverid);
			ps.setString(2, parameterid);
			ResultSet rs = ps.executeQuery();
			if(rs.next()){
				java.sql.Timestamp lastcreate= rs.getTimestamp("lastcreate");
				rs.close();
				ps.close();
				ps = conn.prepareStatement("select DC_SIMPLEVALUE_DATA from DC_SIMPLEVALUES where DC_SIMPLEVALUE_SERVERID=? and DC_SIMPLEVALUE_PARAMETERID=? and DC_SIMPLEVALUE_CREATEDATETIME=?");
				ps.setInt(1, serverid);
				ps.setString(2, parameterid);
				ps.setTimestamp(3, lastcreate);
				rs = ps.executeQuery();
				if(rs.next()){
					value=rs.getString("DC_SIMPLEVALUE_DATA");
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
		return value;
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
				groups+=MedwanQuery.getInstance().getLabel("datacenterServerGroup", rs.getString("DC_SERVERGROUP_ID"), sLanguage);
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
		return getDiagnoses(serverid, Integer.parseInt(period.split("\\.")[0]), Integer.parseInt(period.split("\\.")[1]),codetype);
	}
	
	public static Vector getDiagnoses(int serverid, int year, int month, String codetype){
		Vector v = new Vector();
		Connection conn=MedwanQuery.getInstance().getStatsConnection();
		try{
			String sQuery="select * from DC_DIAGNOSISVALUES where DC_DIAGNOSISVALUE_SERVERID=? and DC_DIAGNOSISVALUE_YEAR=? and DC_DIAGNOSISVALUE_MONTH=? and DC_DIAGNOSISVALUE_CODETYPE=? order by DC_DIAGNOSISVALUE_CODE";
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
	
	public static Vector getDiagnosticMonths(int serverid){
		Vector v = new Vector();
		Connection conn=MedwanQuery.getInstance().getStatsConnection();
		try{
			String sQuery="select distinct "+MedwanQuery.getInstance().convert("varchar","DC_DIAGNOSISVALUE_YEAR")+MedwanQuery.getInstance().concatSign()+"'.'"+MedwanQuery.getInstance().concatSign()+MedwanQuery.getInstance().convert("varchar","DC_DIAGNOSISVALUE_MONTH")+" as diagnosis from DC_DIAGNOSISVALUES where DC_DIAGNOSISVALUE_SERVERID=? order by DC_DIAGNOSISVALUE_YEAR DESC,DC_DIAGNOSISVALUE_MONTH DESC";
			PreparedStatement ps = conn.prepareStatement(sQuery);
			ps.setInt(1, serverid);
			ResultSet rs = ps.executeQuery();
			while(rs.next()){
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
