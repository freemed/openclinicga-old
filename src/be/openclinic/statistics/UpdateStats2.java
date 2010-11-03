package be.openclinic.statistics;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.Hashtable;

import java.util.Iterator;

import be.mxs.common.util.db.MedwanQuery;
import be.openclinic.finance.Insurance;

public class UpdateStats2 extends UpdateStatsBase{
	public UpdateStats2() {
		setModulename("stats.hospitalstats");
	}
	
	public void execute(){
		Date lastupdatetime;
        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
			//Eerst maken we een lijst van alle encounters die moeten worden geupdated
			//Vooreerst de encounters met een nieuwe updatetime
			Hashtable encounters = new Hashtable();
			setModulename("stats.hospitalstats.encounters");
			lastupdatetime=getLastUpdateTime(STARTDATE);
			System.out.println("executing "+this.modulename);
	        String sLocalDbType = "Microsoft SQL Server";
	        try {
				sLocalDbType=oc_conn.getMetaData().getDatabaseProductName();
			} catch (SQLException e1) {
				// TODO Auto-generated catch block
				e1.printStackTrace();
			}
			String sql = "SELECT top "+maxbatchsize+" * from OC_ENCOUNTERS where OC_ENCOUNTER_UPDATETIME>? order by OC_ENCOUNTER_UPDATETIME ASC";
			if(sLocalDbType.equalsIgnoreCase("MySQL")){
				sql = "SELECT * from OC_ENCOUNTERS where OC_ENCOUNTER_UPDATETIME>? order by OC_ENCOUNTER_UPDATETIME ASC limit "+maxbatchsize+"";
			}
			PreparedStatement ps = oc_conn.prepareStatement(sql);
			ps.setTimestamp(1, new Timestamp(lastupdatetime.getTime()));
			ResultSet rs = ps.executeQuery();
			Date maxEncounterUpdateTime=null;
			while(rs.next()){
				encounters.put(rs.getInt("OC_ENCOUNTER_SERVERID")+"."+rs.getInt("OC_ENCOUNTER_OBJECTID"), "1");
				Date encounterUpdateTime=rs.getTimestamp("OC_ENCOUNTER_UPDATETIME");
				if(maxEncounterUpdateTime==null || maxEncounterUpdateTime.before(encounterUpdateTime)){
					maxEncounterUpdateTime=encounterUpdateTime;
				}
			}
			rs.close();
			ps.close();
			//Vervolgens voegen we de encounters toe met een diagnose met nieuwe updatetime
			setModulename("stats.hospitalstats.diagnoses");
			lastupdatetime=getLastUpdateTime(STARTDATE);
			sql = "SELECT top "+maxbatchsize+" * from OC_DIAGNOSES where OC_DIAGNOSIS_UPDATETIME>? order by OC_DIAGNOSIS_UPDATETIME ASC";
			if(sLocalDbType.equalsIgnoreCase("MySQL")){
				sql = "SELECT * from OC_DIAGNOSES where OC_DIAGNOSIS_UPDATETIME>? order by OC_DIAGNOSIS_UPDATETIME ASC limit "+maxbatchsize+"";
			}
			ps = oc_conn.prepareStatement(sql);
			ps.setTimestamp(1, new Timestamp(lastupdatetime.getTime()));
			rs = ps.executeQuery();
			Date maxDiagnosisUpdateTime=null;
			while(rs.next()){
				encounters.put(rs.getString("OC_DIAGNOSIS_ENCOUNTERUID"), "1");
				Date diagnosisUpdateTime=rs.getTimestamp("OC_DIAGNOSIS_UPDATETIME");
				if(maxDiagnosisUpdateTime==null || maxDiagnosisUpdateTime.before(diagnosisUpdateTime)){
					maxDiagnosisUpdateTime=diagnosisUpdateTime;
				}
			}
			rs.close();
			ps.close();
			oc_conn.close();
			Iterator iEncounters = encounters.keySet().iterator();
			int n=0,counter=0;
			while(iEncounters.hasNext()){
				try{
					n++;
					String encounteruid=(String)iEncounters.next();
			        System.out.println("U2 processing encounter UID "+encounteruid+" (#"+(counter++)+")");
					//register diagnoses for every service visited
					sql="SELECT * from OC_ENCOUNTERS_VIEW where OC_ENCOUNTER_SERVERID=? and OC_ENCOUNTER_OBJECTID=?";
					oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
					PreparedStatement ps3=oc_conn.prepareStatement(sql);
					ps3.setInt(1, Integer.parseInt(encounteruid.split("\\.")[0]));
					ps3.setInt(2, Integer.parseInt(encounteruid.split("\\.")[1]));
					ResultSet rs3 = ps3.executeQuery();
					while(rs3.next()){
						String patientuid=rs3.getString("OC_ENCOUNTER_PATIENTUID");
						String type=rs3.getString("OC_ENCOUNTER_TYPE");
						String outcome=rs3.getString("OC_ENCOUNTER_OUTCOME");
						lastupdatetime=rs3.getTimestamp("OC_ENCOUNTER_UPDATETIME");
						Date begindate=rs3.getDate("OC_ENCOUNTER_BEGINDATE");
						Date enddate=rs3.getDate("OC_ENCOUNTER_ENDDATE");
						//remove the encounter record(s) from the statstable
						sql="DELETE FROM UPDATESTATS2 WHERE OC_ENCOUNTER_SERVERID=? and OC_ENCOUNTER_OBJECTID=?";
				        Connection stats_conn=MedwanQuery.getInstance().getStatsConnection();
						PreparedStatement ps2 = stats_conn.prepareStatement(sql);
						ps2.setInt(1, Integer.parseInt(encounteruid.split("\\.")[0]));
						ps2.setInt(2, Integer.parseInt(encounteruid.split("\\.")[1]));
						ps2.executeUpdate();
						ps2.close();
						stats_conn.close();
						//add the encounter records
						String serviceuid=rs3.getString("OC_ENCOUNTER_SERVICEUID");
						sql="SELECT * from OC_DIAGNOSES_VIEW where OC_DIAGNOSIS_ENCOUNTERUID=?";
				        Connection loc_conn=MedwanQuery.getInstance().getLongOpenclinicConnection();
						PreparedStatement ps4 = loc_conn.prepareStatement(sql);
						ps4.setString(1, encounteruid);
						ResultSet rs4=ps4.executeQuery();
						boolean bDiagnosesFound=false;
						while(rs4.next()){
							stats_conn=MedwanQuery.getInstance().getStatsConnection();
							try{
								bDiagnosesFound=true;
								String diagnosiscode=rs4.getString("OC_DIAGNOSIS_CODE");
								String diagnosiscodetype=rs4.getString("OC_DIAGNOSIS_CODETYPE");
								int diagnosisgravity=rs4.getInt("OC_DIAGNOSIS_GRAVITY");
								int diagnosiscertainty=rs4.getInt("OC_DIAGNOSIS_CERTAINTY");
								sql="INSERT INTO UPDATESTATS2(" +
										"OC_ENCOUNTER_SERVERID," +
										"OC_ENCOUNTER_OBJECTID," +
										"OC_ENCOUNTER_PATIENTUID," +
										"OC_ENCOUNTER_BEGINDATE," +
										"OC_ENCOUNTER_ENDDATE," +
										"OC_ENCOUNTER_OUTCOME," +
										"OC_ENCOUNTER_TYPE," +
										"OC_ENCOUNTER_SERVICEUID," +
										"OC_DIAGNOSIS_CODE," +
										"OC_DIAGNOSIS_CODETYPE," +
										"OC_DIAGNOSIS_GRAVITY," +
										"OC_DIAGNOSIS_CERTAINTY) values(?,?,?,?,?,?,?,?,?,?,?,?)";
								ps2=stats_conn.prepareStatement(sql);
								ps2.setInt(1, Integer.parseInt(encounteruid.split("\\.")[0]));
								ps2.setInt(2, Integer.parseInt(encounteruid.split("\\.")[1]));
								ps2.setString(3, patientuid);
								ps2.setDate(4, new java.sql.Date(begindate.getTime()));
								ps2.setDate(5, new java.sql.Date(enddate.getTime()));
								ps2.setString(6, outcome);
								ps2.setString(7, type);
								ps2.setString(8, serviceuid);
								ps2.setString(9, diagnosiscode);
								ps2.setString(10, diagnosiscodetype);
								ps2.setInt(11, diagnosisgravity);
								ps2.setInt(12, diagnosiscertainty);
								ps2.executeUpdate();
								ps2.close();
							}
							catch(Exception e2){
								e2.printStackTrace();
							}
							stats_conn.close();
						}
						rs4.close();
						ps4.close();
						loc_conn.close();
						if(!bDiagnosesFound){
							try{
								sql="INSERT INTO UPDATESTATS2(" +
								"OC_ENCOUNTER_SERVERID," +
								"OC_ENCOUNTER_OBJECTID," +
								"OC_ENCOUNTER_PATIENTUID," +
								"OC_ENCOUNTER_BEGINDATE," +
								"OC_ENCOUNTER_ENDDATE," +
								"OC_ENCOUNTER_OUTCOME," +
								"OC_ENCOUNTER_TYPE," +
								"OC_ENCOUNTER_SERVICEUID," +
								"OC_DIAGNOSIS_CODE," +
								"OC_DIAGNOSIS_CODETYPE," +
								"OC_DIAGNOSIS_GRAVITY," +
								"OC_DIAGNOSIS_CERTAINTY) values(?,?,?,?,?,?,?,?,?,?,?,?)";
								stats_conn=MedwanQuery.getInstance().getStatsConnection();
								ps2=stats_conn.prepareStatement(sql);
								ps2.setInt(1, Integer.parseInt(encounteruid.split("\\.")[0]));
								ps2.setInt(2, Integer.parseInt(encounteruid.split("\\.")[1]));
								ps2.setString(3, patientuid);
								ps2.setDate(4, new java.sql.Date(begindate.getTime()));
								ps2.setDate(5, new java.sql.Date(enddate.getTime()));
								ps2.setString(6, outcome);
								ps2.setString(7, type);
								ps2.setString(8, serviceuid);
								ps2.setObject(9, null);
								ps2.setObject(10, null);
								ps2.setObject(11, null);
								ps2.setObject(12, null);
								ps2.executeUpdate();
								ps2.close();
								stats_conn.close();
							}
							catch(Exception e2){
								e2.printStackTrace();
							}
						}
					}
					rs3.close();
					ps3.close();
					oc_conn.close();
				}
				catch (Exception e3) {
					e3.printStackTrace();
				}
			}
			rs.close();
			ps.close();
			if(maxEncounterUpdateTime!=null){
				setModulename("stats.hospitalstats.encounters");
				setLastUpdateTime(maxEncounterUpdateTime);
			}
			if(maxDiagnosisUpdateTime!=null){
				setModulename("stats.hospitalstats.diagnoses");
				setLastUpdateTime(maxDiagnosisUpdateTime);
			}
		}
		catch (Exception e) {
			e.printStackTrace();
		}
	}
}
