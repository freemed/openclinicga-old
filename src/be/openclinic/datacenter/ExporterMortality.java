package be.openclinic.datacenter;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.Enumeration;
import java.util.Hashtable;
import java.util.Vector;

import webcab.lib.statistics.pdistributions.NormalProbabilityDistribution;
import webcab.lib.statistics.statistics.BasicStatistics;

import be.mxs.common.util.db.MedwanQuery;

public class ExporterMortality extends Exporter {

	public void export(){
		if(getParam().equalsIgnoreCase("mortality.1")){
			//Export a summary of all ICD-10 based KPGS codes per month
			//First find first month for which a summary must be provided
			StringBuffer sb = new StringBuffer("<mortalities>");
			String firstMonth = MedwanQuery.getInstance().getConfigString("datacenterFirstMortalitySummaryMonth","0");
			if(firstMonth.equalsIgnoreCase("0")){
				//Find oldest diagnosis
				Connection oc_conn = MedwanQuery.getInstance().getOpenclinicConnection();
				try {
					PreparedStatement ps = oc_conn.prepareStatement("select count(*) total,min(OC_ENCOUNTER_ENDDATE) as firstMonth from OC_ENCOUNTERS");
					ResultSet rs = ps.executeQuery();
					if(rs.next() && rs.getInt("total")>0){
						firstMonth=new SimpleDateFormat("yyyyMM").format(rs.getDate("firstMonth"));
					}
					rs.close();
					ps.close();
				} catch (SQLException e) {
					e.printStackTrace();
				}
				finally {
					try {
						oc_conn.close();
					} catch (SQLException e) {
						e.printStackTrace();
					}
				}
			}
			try {
				boolean bFound=false;
				//todo: toevoegen totaal mortaliteitscijfer per maand!
				Date lastDay=new Date(new SimpleDateFormat("yyyyMMdd").parse(new SimpleDateFormat("yyyyMM").format(new Date())+"01").getTime()-1);
				Date firstDay=new SimpleDateFormat("yyyyMMdd").parse(firstMonth+"01");
				if(firstDay.before(new SimpleDateFormat("dd/MM/yyyy").parse("01/01/2005"))){
					firstDay=new SimpleDateFormat("dd/MM/yyyy").parse("01/01/2005");
				}
				int firstYear = Integer.parseInt(new SimpleDateFormat("yyyy").format(firstDay));
				int lastYear = Integer.parseInt(new SimpleDateFormat("yyyy").format(lastDay));
				for(int n=firstYear;n<=lastYear;n++){
					int firstmonth=1;
					if(n==firstYear){
						firstmonth=Integer.parseInt(new SimpleDateFormat("MM").format(firstDay));;
					}
					int lastmonth=12;
					if(n==lastYear){
						lastmonth=Integer.parseInt(new SimpleDateFormat("MM").format(lastDay));;
					}
					for(int i=firstmonth;i<=lastmonth;i++){
						//Find all diagnoses for this month
						Date begin = new SimpleDateFormat("dd/MM/yyyy").parse("01/"+i+"/"+n);
						Date end = new SimpleDateFormat("dd/MM/yyyy").parse(i==12?"01/01/"+(n+1):"01/"+(i+1)+"/"+n);
						Connection oc_conn = MedwanQuery.getInstance().getOpenclinicConnection();
						try {
							Hashtable deaths = new Hashtable();
							Hashtable alldiagnoses = new Hashtable();
							PreparedStatement ps = oc_conn.prepareStatement("select count(*) total, oc_diagnosis_code from oc_encounters a, oc_diagnoses_view b where a.oc_encounter_objectid=replace(b.oc_diagnosis_encounteruid,'"+MedwanQuery.getInstance().getConfigInt("serverId")+".','') and"+
							" oc_encounter_enddate >=? and oc_encounter_enddate <? and oc_diagnosis_codetype='icd10' and oc_encounter_outcome='dead' group by oc_diagnosis_code order by count(*) desc");
							ps.setTimestamp(1,new java.sql.Timestamp(begin.getTime()));
							ps.setTimestamp(2,new java.sql.Timestamp(end.getTime()));
							ResultSet rs = ps.executeQuery();
							while(rs.next()){
								deaths.put(rs.getString("oc_diagnosis_code"), rs.getInt("total"));
								bFound=true;
							}
							rs.close();
							ps.close();
							ps = oc_conn.prepareStatement("select count(*) total, oc_diagnosis_code from oc_encounters a, oc_diagnoses_view b where a.oc_encounter_objectid=replace(b.oc_diagnosis_encounteruid,'"+MedwanQuery.getInstance().getConfigInt("serverId")+".','') and"+
							" oc_encounter_enddate >=? and oc_encounter_enddate <? and oc_diagnosis_codetype='icd10' group by oc_diagnosis_code order by count(*) desc");
							ps.setTimestamp(1,new java.sql.Timestamp(begin.getTime()));
							ps.setTimestamp(2,new java.sql.Timestamp(end.getTime()));
							rs = ps.executeQuery();
							while(rs.next()){
								alldiagnoses.put(rs.getString("oc_diagnosis_code"), rs.getInt("total"));
							}
							rs.close();
							ps.close();
							Enumeration e = deaths.keys();
							while(e.hasMoreElements()){
								String o = (String)e.nextElement();
								sb.append("<mortality deaths='"+deaths.get(o)+"' all='"+alldiagnoses.get(o)+"' code='"+o+"' month='"+i+"' year='"+n+"'/>");
							}
						} catch (Exception e) {
							e.printStackTrace();
						}
						finally {
							try {
								oc_conn.close();
							} catch (SQLException e) {
								e.printStackTrace();
							}
						}
					}
				}
				if(bFound){
					sb.append("</mortalities>");
					exportSingleValue(sb.toString(), "mortality.1");
					MedwanQuery.getInstance().setConfigString("datacenterFirstMortalitySummaryMonth", new SimpleDateFormat("yyyyMM").format(new Date(lastDay.getTime()+2)));
				}
			} catch (ParseException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
		}
	}
}
