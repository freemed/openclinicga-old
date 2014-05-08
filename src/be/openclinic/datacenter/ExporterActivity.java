package be.openclinic.datacenter;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.Vector;

import webcab.lib.statistics.pdistributions.NormalProbabilityDistribution;
import webcab.lib.statistics.statistics.BasicStatistics;

import be.mxs.common.util.db.MedwanQuery;
import be.mxs.common.util.system.ScreenHelper;

public class ExporterActivity extends Exporter {

	public void export(){
		if(!mustExport(getParam())){
			return;
		}
		if(getParam().equalsIgnoreCase("activity.1")){
			//Export a summary of all ICD-10 based KPGS codes per month
			//First find first month for which a summary must be provided
			StringBuffer sb = new StringBuffer("<activities>");
			String firstMonth = MedwanQuery.getInstance().getConfigString("datacenterFirstActivitySummaryMonth","0");
			if(firstMonth.equalsIgnoreCase("0")){
				//Find oldest diagnosis
				Connection oc_conn = MedwanQuery.getInstance().getAdminConnection();
				try {
					PreparedStatement ps = oc_conn.prepareStatement("select count(*) total,min(accesstime) as firstMonth from AccessLogs");
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
				Date lastDay=new Date(new SimpleDateFormat("yyyyMMdd").parse(new SimpleDateFormat("yyyyMM").format(new Date())+"01").getTime()-1);
				Date firstDay=new SimpleDateFormat("yyyyMMdd").parse(firstMonth+"01");
				if(firstDay.before(ScreenHelper.parseDate("01/01/2000"))){
					firstDay=ScreenHelper.parseDate("01/01/2000");
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
						Date begin = ScreenHelper.parseDate("01/"+i+"/"+n);
						Date end = ScreenHelper.parseDate(i==12?"01/01/"+(n+1):"01/"+(i+1)+"/"+n);
						Connection oc_conn = MedwanQuery.getInstance().getAdminConnection();
						try {
							Vector m = new Vector();
							PreparedStatement ps = oc_conn.prepareStatement("select count(*) total, userid from accesslogs where accesstime>=? and accesstime<? and accesscode like 'A.%' group by userid");
							ps.setTimestamp(1,new java.sql.Timestamp(begin.getTime()));
							ps.setTimestamp(2,new java.sql.Timestamp(end.getTime()));
							ResultSet rs = ps.executeQuery();
							while(rs.next()){
								m.add(rs.getDouble("total"));
								bFound=true;
							}
							if(m.size()>0){
								double[] measurements = new double[m.size()];
								for(int q=0;q<m.size();q++){
									measurements[q]=(Double)m.elementAt(q);
								}
								BasicStatistics basicStatistics = new BasicStatistics(measurements);
								sb.append("<activity type='A' users='"+m.size()+"' mean='"+basicStatistics.arithmeticMean()+"' median='"+basicStatistics.median()+"' meanDeviation='"+basicStatistics.meanDeviation()+"' month='"+i+"' year='"+n+"'/>");
							}
							rs.close();
							ps.close();
							m = new Vector();
							ps = oc_conn.prepareStatement("select count(*) total, userid from accesslogs where accesstime>=? and accesstime<? and accesscode like 'M.%' group by userid");
							ps.setTimestamp(1,new java.sql.Timestamp(begin.getTime()));
							ps.setTimestamp(2,new java.sql.Timestamp(end.getTime()));
							rs = ps.executeQuery();
							while(rs.next()){
								 m.add(rs.getDouble("total"));
								bFound=true;
							}
							if(m.size()>0){
								double[]measurements = new double[m.size()];
								for(int q=0;q<m.size();q++){
									measurements[q]=(Double)m.elementAt(q);
								}
								BasicStatistics basicStatistics = new BasicStatistics(measurements);
								sb.append("<activity type='M' users='"+m.size()+"' mean='"+basicStatistics.arithmeticMean()+"' median='"+basicStatistics.median()+"' meanDeviation='"+basicStatistics.meanDeviation()+"' month='"+i+"' year='"+n+"'/>");
							}
							rs.close();
							ps.close();
							m = new Vector();
							ps = oc_conn.prepareStatement("select count(*) total, userid from accesslogs where accesstime>=? and accesstime<? and accesscode like 'T.%' group by userid");
							ps.setTimestamp(1,new java.sql.Timestamp(begin.getTime()));
							ps.setTimestamp(2,new java.sql.Timestamp(end.getTime()));
							rs = ps.executeQuery();
							while(rs.next()){
								m.add(rs.getDouble("total"));
								bFound=true;
							}
							if(m.size()>0){
								double[] measurements = new double[m.size()];
								for(int q=0;q<m.size();q++){
									measurements[q]=(Double)m.elementAt(q);
								}
								BasicStatistics basicStatistics = new BasicStatistics(measurements);
								sb.append("<activity type='T' users='"+m.size()+"' mean='"+basicStatistics.arithmeticMean()+"' median='"+basicStatistics.median()+"' meanDeviation='"+basicStatistics.meanDeviation()+"' month='"+i+"' year='"+n+"'/>");
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
				if(bFound){
					sb.append("</activities>");
					exportSingleValue(sb.toString(), "activity.1");
					MedwanQuery.getInstance().setConfigString("datacenterFirstActivitySummaryMonth", new SimpleDateFormat("yyyyMM").format(new Date(lastDay.getTime()+2)));
				}
			} catch (ParseException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
		}
	}
}
