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

public class ExporterHR extends Exporter {

	public void export(){
		if(!mustExport(getParam())){
			return;
		}
		if(getParam().equalsIgnoreCase("hr.1")){
			//Find last months HR status
			Date begin = DatacenterHelper.getBeginOfPreviousMonth();
			Date end = DatacenterHelper.getEndOfPreviousMonth();
			String sHR="";
			Connection oc_conn = MedwanQuery.getInstance().getAdminConnection();
			try {
				PreparedStatement ps = oc_conn.prepareStatement("select extendvalue,count(*) total from adminextends where labelid='usergroup' group by extendvalue");
				ResultSet rs = ps.executeQuery();
				while(rs.next()){
					int counter = rs.getInt("total");
					String group=rs.getString("extendvalue");
					exportValue("<hr month='"+new SimpleDateFormat("yyyyMM").format(begin)+"' count='"+counter+"' group='"+group+"'/>", "hr.1");
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
}
