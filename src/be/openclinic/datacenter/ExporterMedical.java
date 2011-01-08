package be.openclinic.datacenter;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Date;

import be.mxs.common.util.db.MedwanQuery;

public class ExporterMedical extends Exporter {

	public void export(){
		if(getParam().equalsIgnoreCase("medical.1")){
			//Export a summary of all ICD-10 based KPGS codes per month
			//First find first month for which a summary must be provided
			StringBuffer sb = new StringBuffer("<diags>");
			String firstMonth = MedwanQuery.getInstance().getConfigString("datacenterFirstKPGSSummaryMonth","0");
			if(firstMonth.equalsIgnoreCase("0")){
				//Find oldest diagnosis
				Connection oc_conn = MedwanQuery.getInstance().getOpenclinicConnection();
				try {
					PreparedStatement ps = oc_conn.prepareStatement("select min(OC_DIAGNOSIS_DATE) as firstMonth from OC_DIAGNOSES_VIEW");
					ResultSet rs = ps.executeQuery();
					if(rs.next()){
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
			if(!firstMonth.equalsIgnoreCase("0")){
				try {
					boolean bFound=false;
					Date lastDay=new Date(new SimpleDateFormat("yyyyMMdd").parse(new SimpleDateFormat("yyyyMM").format(new Date())+"01").getTime()-1);
					Date firstDay=new SimpleDateFormat("yyyyMMdd").parse(firstMonth+"01");
					if(firstDay.before(new SimpleDateFormat("dd/MM/yyyy").parse("01/01/2000"))){
						firstDay=new SimpleDateFormat("dd/MM/yyyy").parse("01/01/2000");
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
								PreparedStatement ps = oc_conn.prepareStatement("select count(*) total,OC_DIAGNOSIS_CODE from OC_DIAGNOSES_VIEW where OC_DIAGNOSIS_DATE>=? and OC_DIAGNOSIS_DATE<? and OC_DIAGNOSIS_CODETYPE='icd10'" +
										" GROUP BY OC_DIAGNOSIS_CODE");
								ps.setTimestamp(1,new java.sql.Timestamp(begin.getTime()));
								ps.setTimestamp(2,new java.sql.Timestamp(end.getTime()));
								ResultSet rs = ps.executeQuery();
								while(rs.next()){
									bFound=true;
									sb.append("<diagnosis code='"+rs.getString("OC_DIAGNOSIS_CODE")+"' count='"+rs.getInt("total")+"' year='"+n+"' month='"+i+"'/>");
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
					}
					if(bFound){
						sb.append("</diags>");
						exportSingleValue(sb.toString(), "medical.1");
						MedwanQuery.getInstance().setConfigString("datacenterFirstKPGSSummaryMonth", new SimpleDateFormat("yyyyMM").format(new Date(lastDay.getTime()+2)));
					}
				} catch (ParseException e) {
					// TODO Auto-generated catch block
					e.printStackTrace();
				}
			}
		}
	}
}
