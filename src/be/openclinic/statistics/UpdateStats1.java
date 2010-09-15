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

public class UpdateStats1 extends UpdateStatsBase{
	public UpdateStats1() {
		setModulename("stats.treated.patients");
	}
	
	public void execute(){
		System.out.println("Executing "+modulename);
		String sql = "SELECT * from OC_ENCOUNTERS where OC_ENCOUNTER_UPDATETIME>? order by OC_ENCOUNTER_UPDATETIME ASC";
		Date lastupdatetime=getLastUpdateTime(STARTDATE);
        Connection loc_conn=MedwanQuery.getInstance().getLongOpenclinicConnection();
		try{
			PreparedStatement ps = loc_conn.prepareStatement(sql);
			ps.setTimestamp(1, new Timestamp(lastupdatetime.getTime()));
			ResultSet rs = ps.executeQuery();
			while(rs.next()){
		        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
				try{
					String encounteruid=rs.getInt("OC_ENCOUNTER_SERVERID")+"."+rs.getInt("OC_ENCOUNTER_OBJECTID");
					String patientuid=rs.getString("OC_ENCOUNTER_PATIENTUID");
					String type=rs.getString("OC_ENCOUNTER_TYPE");
					lastupdatetime=rs.getTimestamp("OC_ENCOUNTER_UPDATETIME");
					//remove the encounter record(s) from the statstable
					sql="DELETE FROM UPDATESTATS1 WHERE OC_ENCOUNTERUID=?";
					PreparedStatement ps2 = MedwanQuery.getInstance().getStatsConnection().prepareStatement(sql);
					ps2.setString(1, encounteruid );
					ps2.executeUpdate();
					ps2.close();
					//add the encounter records
					//one record for every service visited
					sql="SELECT * from OC_ENCOUNTERS_VIEW where OC_ENCOUNTER_SERVERID=? and OC_ENCOUNTER_OBJECTID=?";
					PreparedStatement ps3=oc_conn.prepareStatement(sql);
					ps3.setInt(1, Integer.parseInt(encounteruid.split("\\.")[0]));
					ps3.setInt(2, Integer.parseInt(encounteruid.split("\\.")[1]));
					ResultSet rs3 = ps3.executeQuery();
					while(rs3.next()){
						try{
							Date begindate=rs3.getDate("OC_ENCOUNTER_BEGINDATE");
							Date enddate=rs3.getDate("OC_ENCOUNTER_ENDDATE");
							String serviceuid=rs3.getString("OC_ENCOUNTER_SERVICEUID");
							sql="INSERT INTO UPDATESTATS1(OC_ENCOUNTERUID,OC_PATIENTUID,OC_BEGINDATE,OC_ENDDATE,OC_SERVICEUID,OC_INSURAR,OC_TYPE) values (?,?,?,?,?,?,?)";
							ps2=MedwanQuery.getInstance().getStatsConnection().prepareStatement(sql);
							ps2.setString(1, encounteruid);
							ps2.setString(2, patientuid);
							ps2.setDate(3, new java.sql.Date(begindate.getTime()));
							ps2.setDate(4, new java.sql.Date(enddate.getTime()));
							ps2.setString(5, serviceuid);
							Insurance insurance = Insurance.getMostInterestingInsuranceForPatient(patientuid,begindate);
							ps2.setString(6, insurance==null?"":insurance.getInsurar().getName());
							ps2.setString(7, type);
							ps2.executeUpdate();
							System.out.println("Added "+type+" #"+encounteruid+" on "+new SimpleDateFormat("dd/MM/yyyy").format(begindate)+" for patient ID "+patientuid+" in department "+serviceuid);
							ps2.close();
						}
						catch(Exception e2){
							e2.printStackTrace();
						}
					}
					rs3.close();
					ps3.close();
				}
				catch (Exception e3) {
					e3.printStackTrace();
				}
				oc_conn.close();
			}
			rs.close();
			ps.close();
			setLastUpdateTime(lastupdatetime);
		}
		catch (Exception e) {
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
