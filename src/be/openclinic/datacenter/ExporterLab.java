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

public class ExporterLab extends Exporter {

	public void export(){
		if(!mustExport(getParam())){
			return;
		}
		if(getParam().equalsIgnoreCase("lab.1")){
			//Export a summary of all ICD-10 based in-patient mortality per month
			//First find first month for which a summary must be provided
			StringBuffer sb = new StringBuffer("<labtests>");
			String firstMonth = MedwanQuery.getInstance().getConfigString("datacenterFirstLabSummaryMonth","0");
			if(firstMonth.equalsIgnoreCase("0")){
				//Find oldest diagnosis
				Connection oc_conn = MedwanQuery.getInstance().getOpenclinicConnection();
				try {
					PreparedStatement ps = oc_conn.prepareStatement("select count(*) total,min(resultdate) as firstMonth from requestedlabanalyses where finalvalidationdatetime is not null");
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
			if(!firstMonth.equalsIgnoreCase("0")){
				try {
					boolean bFound=false;
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
								Hashtable analyses = new Hashtable();
								//First numerical results
								PreparedStatement ps = oc_conn.prepareStatement("select count(*) total, analysiscode,avg(resultvalue) as average,"+MedwanQuery.getInstance().getConfigString("stdevFunction","stdev")+"(resultvalue)) as stddev from requestedlabanalyses a, labanalysis b where a.analysiscode=b.labcode and b.editor='numeric' and finalvalidationdatetime is not null and finalvalidationdatetime between ? and ? group by analysiscode order by count(*) desc");
								ps.setTimestamp(1,new java.sql.Timestamp(begin.getTime()));
								ps.setTimestamp(2,new java.sql.Timestamp(end.getTime()));
								ResultSet rs = ps.executeQuery();
								while(rs.next()){
									System.out.println("Found numeric");
									String labcode=rs.getString("labanalysiscode");
									sb.append("<labtest editor='numeric' code='"+labcode+"' count='"+rs.getInt("total")+"' average='"+rs.getDouble("average")+"' standarddeviation='"+rs.getDouble("stdev")+"' month='"+i+"' year='"+n+"'/>");
								}
								rs.close();
								ps.close();
								//then listbox results
								ps = oc_conn.prepareStatement("select count(*) total, analysiscode, resultvalue from requestedlabanalyses a, labanalysis b where a.analysiscode=b.labcode and b.editor='listbox' and finalvalidationdatetime is not null and finalvalidationdatetime between ? and ?  group by analysiscode,resultvalue order by count(*) desc");
								ps.setTimestamp(1,new java.sql.Timestamp(begin.getTime()));
								ps.setTimestamp(2,new java.sql.Timestamp(end.getTime()));
								rs = ps.executeQuery();
								while(rs.next()){
									System.out.println("Found listbox");
									String labcode=rs.getString("labanalysiscode");
									String resultvalue=rs.getString("resultvalue");
									sb.append("<labtest editor='listbox' code='"+labcode+"' value='"+resultvalue+"' count='"+rs.getInt("total")+"' month='"+i+"' year='"+n+"'/>");
								}
								rs.close();
								ps.close();
								//then the other results
								ps = oc_conn.prepareStatement("select count(*) total, analysiscode, editor from requestedlabanalyses a, labanalysis b where a.analysiscode=b.labcode and b.editor NOT in ('listbox','numeric') and finalvalidationdatetime is not null and finalvalidationdatetime between ? and ?  group by analysiscode,editor order by count(*) desc");
								ps.setTimestamp(1,new java.sql.Timestamp(begin.getTime()));
								ps.setTimestamp(2,new java.sql.Timestamp(end.getTime()));
								rs = ps.executeQuery();
								while(rs.next()){
									System.out.println("Found other");
									String labcode=rs.getString("labanalysiscode");
									String editor=rs.getString("editor");
									sb.append("<labtest editor='"+editor+"' code='"+labcode+"' count='"+rs.getInt("total")+"' month='"+i+"' year='"+n+"'/>");
								}
								rs.close();
								ps.close();
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
					sb.append("</labtests>");
					exportSingleValue(sb.toString(), "lab.1");
					MedwanQuery.getInstance().setConfigString("datacenterFirstLabSummaryMonth", new SimpleDateFormat("yyyyMM").format(new Date(lastDay.getTime()+2)));
				} catch (ParseException e) {
					// TODO Auto-generated catch block
					e.printStackTrace();
				}
			}
		}
	}
}
