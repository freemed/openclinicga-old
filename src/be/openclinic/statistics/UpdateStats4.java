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

public class UpdateStats4 extends UpdateStatsBase{
	public UpdateStats4() {
		setModulename("stats.treated.encounterdebets");
	}
	
	public void execute(){
        String serverid=MedwanQuery.getInstance().getConfigString("serverId")+".";
        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        Connection loc_conn=MedwanQuery.getInstance().getLongOpenclinicConnection();
        String sLocalDbType = "Microsoft SQL Server";
        try {
			sLocalDbType=oc_conn.getMetaData().getDatabaseProductName();
		} catch (SQLException e1) {
			// TODO Auto-generated catch block
			e1.printStackTrace();
		}
        String sql = "SELECT top "+maxbatchsize+" a.OC_DEBET_OBJECTID," +
				" OC_DEBET_ENCOUNTERUID," +
				" OC_DEBET_INSURANCEUID," +
				" OC_ENCOUNTER_SERVICEUID," +
				" OC_ENCOUNTER_TYPE," +
				" OC_PRESTATION_REFTYPE," +
				" OC_PRESTATION_CODE," +
				" OC_ENCOUNTER_BEGINDATE," +
				" OC_ENCOUNTER_ENDDATE," +
				" OC_DEBET_UPDATETIME," +
				" a.oc_debet_amount+a.oc_debet_insuraramount+"+MedwanQuery.getInstance().convert("float","a.oc_debet_extrainsuraramount")+" as amount," +
				" OC_DEBET_AMOUNT," +
				" OC_DEBET_INSURARAMOUNT," +
				" OC_DEBET_EXTRAINSURARAMOUNT" +
				" from OC_DEBETS a,OC_ENCOUNTERS_VIEW b, OC_PRESTATIONS c where" +
				" c.oc_prestation_objectid=replace(a.oc_debet_prestationuid,'"+serverid+"','') and"+
				" b.oc_encounter_objectid=replace(a.oc_debet_encounteruid,'"+serverid+"','') and"+
				" OC_DEBET_UPDATETIME>? order by OC_DEBET_UPDATETIME ASC";
        if(sLocalDbType.equalsIgnoreCase("MySQL")){
        	sql = "SELECT a.OC_DEBET_OBJECTID," +
			" OC_DEBET_ENCOUNTERUID," +
			" OC_DEBET_INSURANCEUID," +
			" OC_ENCOUNTER_SERVICEUID," +
			" OC_ENCOUNTER_TYPE," +
			" OC_PRESTATION_REFTYPE," +
			" OC_PRESTATION_CODE," +
			" OC_ENCOUNTER_BEGINDATE," +
			" OC_ENCOUNTER_ENDDATE," +
			" OC_DEBET_UPDATETIME," +
			" a.oc_debet_amount+a.oc_debet_insuraramount+"+MedwanQuery.getInstance().convert("float","a.oc_debet_extrainsuraramount")+" as amount," +
			" OC_DEBET_AMOUNT," +
			" OC_DEBET_INSURARAMOUNT," +
			" OC_DEBET_EXTRAINSURARAMOUNT" +
			" from OC_DEBETS a,OC_ENCOUNTERS_VIEW b, OC_PRESTATIONS c where" +
			" c.oc_prestation_objectid=replace(a.oc_debet_prestationuid,'"+serverid+"','') and"+
			" b.oc_encounter_objectid=replace(a.oc_debet_encounteruid,'"+serverid+"','') and"+
			" OC_DEBET_UPDATETIME>? order by OC_DEBET_UPDATETIME ASC limit "+maxbatchsize+"";
        }
		Date lastupdatetime=getLastUpdateTime(STARTDATE);
		System.out.println("executing "+this.modulename);
		try{
			PreparedStatement ps = loc_conn.prepareStatement(sql);
			ps.setTimestamp(1, new Timestamp(lastupdatetime.getTime()));
			ResultSet rs = ps.executeQuery();
			int counter=0;
			while(rs.next()){
				try{
					int debetobjectid=rs.getInt("OC_DEBET_OBJECTID");
					String encounteruid=rs.getString("OC_DEBET_ENCOUNTERUID");
					counter++;
					if(counter%100==0) System.out.println("U4 processing encounter UID "+encounteruid+" (#"+counter+") "+new SimpleDateFormat("yyyyMMddHHmmssSSS").format(lastupdatetime));
					String prestationreftype=rs.getString("OC_PRESTATION_REFTYPE");
					String prestationcode=rs.getString("OC_PRESTATION_CODE");
					String encounterserviceuid=rs.getString("OC_ENCOUNTER_SERVICEUID");
					String type=rs.getString("OC_ENCOUNTER_TYPE");
					double amount=rs.getDouble("amount");
					double patientamount= rs.getDouble("OC_DEBET_AMOUNT");
					double insuraramount= rs.getDouble("OC_DEBET_INSURARAMOUNT");
					double extrainsuraramount= rs.getDouble("OC_DEBET_EXTRAINSURARAMOUNT");
					Date begindate = rs.getDate("OC_ENCOUNTER_BEGINDATE");
					Date enddate = rs.getDate("OC_ENCOUNTER_ENDDATE");
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
						//add the debet records
						sql="INSERT INTO UPDATESTATS4(OC_INSURAR,OC_DEBETOBJECTID,OC_PRESTATIONREFTYPE,OC_PRESTATIONCODE,OC_SERVICEUID,OC_ENCOUNTERTYPE,OC_ENCOUNTERUID,OC_AMOUNT,OC_BEGINDATE,OC_ENDDATE,OC_PATIENTAMOUNT,OC_INSURARAMOUNT,OC_EXTRAINSURARAMOUNT) values (?,?,?,?,?,?,?,?,?,?,?,?,?)";
						Connection stats_conn=MedwanQuery.getInstance().getStatsConnection();
						PreparedStatement ps2=stats_conn.prepareStatement(sql);
						ps2.setString(1, insurar);
						ps2.setInt(2, debetobjectid);
						ps2.setString(3, prestationreftype);
						ps2.setString(4, prestationcode);
						ps2.setString(5, encounterserviceuid);
						ps2.setString(6, type);
						ps2.setString(7, encounteruid);
						ps2.setDouble(8, amount);
						ps2.setDate(9, new java.sql.Date(begindate.getTime()));
						ps2.setDate(10, new java.sql.Date(enddate.getTime()));
						ps2.setDouble(11, patientamount);
						ps2.setDouble(12, insuraramount);
						ps2.setDouble(13, extrainsuraramount);
						ps2.executeUpdate();
						ps2.close();
						if(counter%100==0){
							setLastUpdateTime(lastupdatetime);
						}
						stats_conn.close();
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
			System.out.println("closing "+this.modulename);
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
		System.out.println("closed "+this.modulename);
	}
}
