package be.openclinic.statistics;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.text.SimpleDateFormat;
import java.util.Date;

import be.mxs.common.util.db.MedwanQuery;
import be.openclinic.finance.Insurance;
import be.openclinic.finance.Insurar;

public class UpdateStats3 extends UpdateStatsBase{
	public UpdateStats3() {
		setModulename("stats.treated.debets");
	}
	
	public void execute(){
		String sql = "SELECT OC_DEBET_ENCOUNTERUID,OC_ENCOUNTER_BEGINDATE,OC_ENCOUNTER_TYPE,OC_DEBET_INSURANCEUID,OC_DEBET_UPDATETIME from OC_DEBETS a,OC_ENCOUNTERS b where" +
				" b.OC_ENCOUNTER_OBJECTID=replace(a.OC_DEBET_ENCOUNTERUID,'"+MedwanQuery.getInstance().getConfigInt("serverId")+".','') AND "+
				" OC_DEBET_UPDATETIME>? order by OC_DEBET_UPDATETIME ASC";
		Date lastupdatetime=getLastUpdateTime(STARTDATE);
        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        Connection loc_conn=MedwanQuery.getInstance().getLongOpenclinicConnection();
		try{
			PreparedStatement ps = loc_conn.prepareStatement(sql);
			ps.setTimestamp(1, new Timestamp(lastupdatetime.getTime()));
			ResultSet rs = ps.executeQuery();
			while(rs.next()){
				try{
					String encounteruid=rs.getString("OC_DEBET_ENCOUNTERUID");
					String type=rs.getString("OC_ENCOUNTER_TYPE");
					Date debetdate = rs.getDate("OC_ENCOUNTER_BEGINDATE");
					String insuranceuid=rs.getString("OC_DEBET_INSURANCEUID");
					lastupdatetime=rs.getTimestamp("OC_DEBET_UPDATETIME");
					String insurar="";
					if(insuranceuid!=null && insuranceuid.length()>0 && insuranceuid.indexOf(".")>-1){
						sql="SELECT a.OC_INSURAR_NAME from OC_INSURARS a,OC_INSURANCES b where a.OC_INSURAR_OBJECTID=replace(b.OC_INSURANCE_INSURARUID,'"+MedwanQuery.getInstance().getConfigInt("serverId")+".','') and OC_INSURANCE_SERVERID=? and OC_INSURANCE_OBJECTID=?";
						PreparedStatement ps3=oc_conn.prepareStatement(sql);
						ps3.setInt(1, Integer.parseInt(insuranceuid.split("\\.")[0]));
						ps3.setInt(2, Integer.parseInt(insuranceuid.split("\\.")[1]));
						ResultSet rs3 = ps3.executeQuery();
						if(rs3.next()){
							insurar=rs3.getString("OC_INSURAR_NAME");
						}
						rs3.close();
						ps3.close();
					}
					try{
						//remove the debet record(s) from the statstable
						sql="SELECT OC_ENCOUNTERUID FROM UPDATESTATS3 WHERE OC_ENCOUNTERUID=? and OC_INSURAR=?";
						PreparedStatement ps2 = MedwanQuery.getInstance().getStatsConnection().prepareStatement(sql);
						ps2.setString(1, encounteruid );
						ps2.setString(2, insurar);
						ResultSet rs2=ps2.executeQuery();
						if(!rs2.next()){
							rs2.close();
							ps2.close();
							//add the debet records
							sql="INSERT INTO UPDATESTATS3(OC_ENCOUNTERUID,OC_INSURAR,OC_DATE,OC_ENCOUNTERTYPE) values (?,?,?,?)";
							ps2=MedwanQuery.getInstance().getStatsConnection().prepareStatement(sql);
							ps2.setString(1, encounteruid);
							ps2.setString(2, insurar);
							ps2.setDate(3, new java.sql.Date(debetdate.getTime()));
							ps2.setString(4, type);
							ps2.executeUpdate();
						}
						else {
							rs2.close();
						}
						ps2.close();
					}
					catch(Exception e2){
						e2.printStackTrace();
					}
				}
				catch (Exception e3) {
					e3.printStackTrace();
				}
			}
			rs.close();
			ps.close();
			setLastUpdateTime(lastupdatetime);
		}
		catch (Exception e) {
			e.printStackTrace();
		}
		try {
			oc_conn.close();
		} catch (SQLException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		try {
			loc_conn.close();
		} catch (SQLException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		
	}
}
