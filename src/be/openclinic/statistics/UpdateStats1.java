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
        Connection loc_conn=MedwanQuery.getInstance().getLongOpenclinicConnection();
        String sLocalDbType = "Microsoft SQL Server";
        try {
			sLocalDbType=loc_conn.getMetaData().getDatabaseProductName();
		} catch (SQLException e1) {
			// TODO Auto-generated catch block
			e1.printStackTrace();
		}
		String sql = "SELECT top "+maxbatchsize+" * from OC_ENCOUNTERS where OC_ENCOUNTER_UPDATETIME>? order by OC_ENCOUNTER_UPDATETIME ASC";
		if(sLocalDbType.equalsIgnoreCase("MySQL")){
			sql = "SELECT * from OC_ENCOUNTERS where OC_ENCOUNTER_UPDATETIME>? order by OC_ENCOUNTER_UPDATETIME ASC limit "+maxbatchsize+"";
		}
		Date lastupdatetime=getLastUpdateTime(STARTDATE);
		System.out.println("executing "+this.modulename);
		int counter=0;
		try{
			PreparedStatement ps = loc_conn.prepareStatement(sql);
			ps.setTimestamp(1, new Timestamp(lastupdatetime.getTime()));
			ResultSet rs = ps.executeQuery();
			while(rs.next()){
		        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
		        Connection stats_conn=MedwanQuery.getInstance().getStatsConnection();
		        try{
					String encounteruid=rs.getInt("OC_ENCOUNTER_SERVERID")+"."+rs.getInt("OC_ENCOUNTER_OBJECTID");
			        System.out.println("U1 processing encounter UID "+encounteruid+" (#"+(counter++)+") "+new SimpleDateFormat("yyyyMMddHHmmssSSS").format(lastupdatetime));
					String patientuid=rs.getString("OC_ENCOUNTER_PATIENTUID");
					String type=rs.getString("OC_ENCOUNTER_TYPE");
					lastupdatetime=rs.getTimestamp("OC_ENCOUNTER_UPDATETIME");
					//remove the encounter record(s) from the statstable
					sql="DELETE FROM UPDATESTATS1 WHERE OC_ENCOUNTERUID=?";
					PreparedStatement ps2 = stats_conn.prepareStatement(sql);
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
							ps2=stats_conn.prepareStatement(sql);
							ps2.setString(1, encounteruid);
							ps2.setString(2, patientuid);
							ps2.setDate(3, new java.sql.Date(begindate.getTime()));
							ps2.setDate(4, new java.sql.Date(enddate.getTime()));
							ps2.setString(5, serviceuid);
							Insurance insurance = Insurance.getMostInterestingInsuranceForPatient(patientuid,begindate);
							ps2.setString(6, insurance==null?"":insurance.getInsurar().getName());
							ps2.setString(7, type);
							ps2.executeUpdate();
							ps2.close();
						}
						catch(Exception e2){
							e2.printStackTrace();
						}
					}
					rs3.close();
					ps3.close();
					if(counter%100==0){
						setLastUpdateTime(lastupdatetime);
					}
				}
				catch (Exception e3) {
					e3.printStackTrace();
				}
				oc_conn.close();
				stats_conn.close();
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
