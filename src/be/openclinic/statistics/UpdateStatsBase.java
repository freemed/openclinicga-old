package be.openclinic.statistics;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.util.Date;

import java.sql.ResultSet;
import java.text.ParseException;
import java.text.SimpleDateFormat;

import be.mxs.common.util.db.MedwanQuery;

public class UpdateStatsBase {
	protected static Date STARTDATE;
	protected String modulename;
	protected String maxbatchsize=getConfigString("maxbatchsize","10000");
	
	public UpdateStatsBase(){
		try {
			STARTDATE = new SimpleDateFormat("dd/MM/yyyy").parse("01/01/1900");
		} catch (ParseException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
	}

	public String getModulename() {
		return modulename;
	}
	
	public void setModulename(String modulename) {
		this.modulename = modulename;
	}
	
	public Date getLastUpdateTime(){
		Date lastupdatetime = null;
		String s = getConfigString(modulename+".updatetime");
		if(s!=null){
			try{
				lastupdatetime=new SimpleDateFormat("yyyyMMddHHmmssSSS").parse(s);
			}
			catch (Exception e) {
				e.printStackTrace();
			}
		}
		return lastupdatetime;
	}
	
	public Date getLastUpdateTime(Date defaultValue){
		Date lastupdatetime = getLastUpdateTime();
		if(lastupdatetime==null){
			setLastUpdateTime(defaultValue);
			lastupdatetime=defaultValue;
		}
		return lastupdatetime;
	}
	
	public void setLastUpdateTime(Date updatetime){
		setConfigString(modulename+".updatetime", new SimpleDateFormat("yyyyMMddHHmmssSSS").format(updatetime));
	}
	
	public String getConfigString(String key){
		String value=null;
		try{
			String sql = "SELECT * from OC_CONFIG where OC_KEY=?";
			Connection stats_conn=MedwanQuery.getInstance().getStatsConnection();
			PreparedStatement ps = stats_conn.prepareStatement(sql);
			ps.setString(1, key);
			ResultSet rs = ps.executeQuery();
			if(rs.next()){
				value=rs.getString("OC_VALUE");
			}
			rs.close();
			ps.close();
			stats_conn.close();
		}
		catch(Exception e){
			e.printStackTrace();
		}
		return value;
	}

	public String getConfigString(String key, String defaultValue){
		String value=getConfigString(key);
		if(value==null){
			value=defaultValue;
		}
		return value;
	}

	public void setConfigString(String key,String value){
		try{
			String sql = "DELETE from OC_CONFIG where OC_KEY=?";
			Connection stats_conn=MedwanQuery.getInstance().getStatsConnection();
			PreparedStatement ps = stats_conn.prepareStatement(sql);
			ps.setString(1, key);
			ps.executeUpdate();
			ps.close();
			sql = "INSERT INTO OC_CONFIG(OC_KEY,OC_VALUE) VALUES(?,?)";
			ps = stats_conn.prepareStatement(sql);
			ps.setString(1, key);
			ps.setString(2, value);
			ps.executeUpdate();
			ps.close();
			stats_conn.close();
		}
		catch(Exception e){
			e.printStackTrace();
		}
	}
}
