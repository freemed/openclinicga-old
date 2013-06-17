package be.openclinic.reporting;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.text.SimpleDateFormat;
import java.util.Calendar;
import java.util.Date;
import java.util.GregorianCalendar;
import java.util.Hashtable;

import be.mxs.common.util.db.MedwanQuery;

public class PeriodicReport {
	private Date start;
	private Date stop;
	private Hashtable encounters; 
	
	public PeriodicReport(Date start, Date stop) {
		super();
		this.start = start;
		this.stop = stop;
	}
	
	public static double monthsBetween(Date first, Date last){
		Calendar date1= new GregorianCalendar();
		date1.setTime(first);
		Calendar date2= new GregorianCalendar();
		date1.setTime(last);
        double monthsBetween = 0;
        //difference in month for years
        monthsBetween = (date1.get(Calendar.YEAR)-date2.get(Calendar.YEAR))*12;
        //difference in month for months
        monthsBetween += date1.get(Calendar.MONTH)-date2.get(Calendar.MONTH);
        //difference in month for days
        if(date1.get(Calendar.DAY_OF_MONTH)!=date1.getActualMaximum(Calendar.DAY_OF_MONTH)
                && date1.get(Calendar.DAY_OF_MONTH)!=date1.getActualMaximum(Calendar.DAY_OF_MONTH) ){
            monthsBetween += ((date1.get(Calendar.DAY_OF_MONTH)-date2.get(Calendar.DAY_OF_MONTH))/31d);
        }
        return monthsBetween;
    }

	public void loadEncounters(){
		encounters = new Hashtable();
		Connection conn = MedwanQuery.getInstance().getOpenclinicConnection();
		PreparedStatement ps = null;
		ResultSet rs = null;
		try{
			//Eerst maken we een lijst van alle encounters
			String sQuery = "select OC_ENCOUNTER_OBJECTID,dateofbirth,gender,OC_ENCOUNTER_BEGINDATE from OC_ENCOUNTERS a, AdminView b where OC_ENCOUNTER_PATIENTUID=personid and OC_ENCOUNTER_BEGINDATE >= ? and OC_ENCOUNTER_BEGINDATE<?";
			ps=conn.prepareStatement(sQuery);
			ps.setDate(1, new java.sql.Date(start.getTime()));
			ps.setDate(2, new java.sql.Date(stop.getTime()));
			rs=ps.executeQuery();
			while (rs.next()){
				ReportEncounter encounter = new ReportEncounter();
				Date dateofbirth= rs.getDate("dateofbirth");
				Date encounterdate = rs.getDate("OC_ENCOUNTER_BEGINDATE");
				encounter.patientAge= (int)monthsBetween(dateofbirth, encounterdate);
				encounter.patientGender=rs.getString("gender");
				encounters.put(rs.getString("OC_ENCOUNTER_OBJECTID"), encounter);
			}
			rs.close();
			ps.close();
			//Nu maken we een lijst van alle RFE flags voor de encounters
			//RFE Flags
			ps = conn.prepareStatement("select distinct b.OC_ENCOUNTER_OBJECTID,a.OC_RFE_ENCOUNTERUID,a.OC_RFE_FLAGS from OC_RFE a,OC_ENCOUNTERS b where b.OC_ENCOUNTER_OBJECTID=replace(a.OC_RFE_ENCOUNTERUID,'"+MedwanQuery.getInstance().getConfigInt("serverId")+".','') and b.OC_ENCOUNTER_BEGINDATE>=? and OC_ENCOUNTER_BEGINDATE<=?");
			ps.setTimestamp(1,new java.sql.Timestamp(start.getTime()));
			ps.setTimestamp(2,new java.sql.Timestamp(stop.getTime()));
			rs = ps.executeQuery();
			while(rs.next()){
				if(rs.getString("OC_RFE_FLAGS").indexOf("n")>-1){
					((ReportEncounter)encounters.get(rs.getString("OC_ENCOUNTER_OBJECTID"))).flags.add("n");
				}
			}
			rs.close();
			ps.close();
			//Nu maken we een lijst van alle verzekerde patiënten
			ps = conn.prepareStatement("select distinct b.OC_ENCOUNTER_OBJECTID from OC_INSURANCES a,OC_ENCOUNTERS b where b.OC_ENCOUNTER_PATIENTUID=OC_INSURANCE_PATIENTUID and b.OC_ENCOUNTER_BEGINDATE>=? and OC_ENCOUNTER_BEGINDATE<=? and OC_INSURANCE_START<=OC_ENCOUNTER_BEGINDATE and (OC_INSURANCE_STOP IS NULL or OC_INSURANCE_STOP>=OC_ENCOUNTER_BEGINDATE) and OC_INSURANCE_INSURARUID<>?");
			ps.setTimestamp(1,new java.sql.Timestamp(start.getTime()));
			ps.setTimestamp(2,new java.sql.Timestamp(stop.getTime()));
			ps.setString(3, MedwanQuery.getInstance().getConfigString("patientSelfInsurarUID"));
			rs = ps.executeQuery();
			while(rs.next()){
				((ReportEncounter)encounters.get(rs.getString("OC_ENCOUNTER_OBJECTID"))).flags.add("I");
			}
			rs.close();
			ps.close();
			//Nu maken we een lijst van alle patiënten die consulteerden en waarvoor geen prestaties werden gefactureerd
			ps = conn.prepareStatement("select distinct OC_ENCOUNTER_OBJECTID from OC_ENCOUNTERS where OC_ENCOUNTER_BEGINDATE>=? and OC_ENCOUNTER_BEGINDATE<=? and not exists (select * from OC_DEBETS where (OC_DEBET_AMOUNT+OC_DEBET_INSURARAMOUNT)>0 and OC_DEBET_ENCOUNTERUID='"+MedwanQuery.getInstance().getConfigInt("serverId")+".'"+MedwanQuery.getInstance().concatSign()+"OC_ENCOUNTER_OBJECTID)");
			ps.setTimestamp(1,new java.sql.Timestamp(start.getTime()));
			ps.setTimestamp(2,new java.sql.Timestamp(stop.getTime()));
			rs = ps.executeQuery();
			while(rs.next()){
				((ReportEncounter)encounters.get(rs.getString("OC_ENCOUNTER_OBJECTID"))).flags.add("NP");
			}
			rs.close();
			ps.close();
			//Nu maken we een lijst van alle patiënten met actieve verzekering 'onvermogend'
			ps = conn.prepareStatement("select distinct b.OC_ENCOUNTER_OBJECTID from OC_INSURANCES a,OC_ENCOUNTERS b where b.OC_ENCOUNTER_PATIENTUID=OC_INSURANCE_PATIENTUID and b.OC_ENCOUNTER_BEGINDATE>=? and OC_ENCOUNTER_BEGINDATE<=? and OC_INSURANCE_START<=OC_ENCOUNTER_BEGINDATE and (OC_INSURANCE_STOP IS NULL or OC_INSURANCE_STOP>=OC_ENCOUNTER_BEGINDATE) and OC_INSURANCE_INSURARUID=?");
			ps.setTimestamp(1,new java.sql.Timestamp(start.getTime()));
			ps.setTimestamp(2,new java.sql.Timestamp(stop.getTime()));
			ps.setString(3, MedwanQuery.getInstance().getConfigString("pauperStatusInsuranceUID"));
			rs = ps.executeQuery();
			while(rs.next()){
				((ReportEncounter)encounters.get(rs.getString("OC_ENCOUNTER_OBJECTID"))).flags.add("IND");
			}
			rs.close();
			ps.close();
		}
		catch(Exception e){
			e.printStackTrace();
		}
		finally {
			try{
				if(rs!=null) rs.close();
				if(ps!=null) ps.close();
				conn.close();
			}
			catch(Exception e2){
				e2.printStackTrace();
			}
		}
	}

}
