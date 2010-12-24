package be.openclinic.datacenter;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

import be.mxs.common.util.db.MedwanQuery;

public abstract class Exporter {
	String param="";
	long interval=0;

	public abstract void export();

	public long getInterval() {
		return interval;
	}

	public void setInterval(long interval) {
		this.interval = interval;
	}
	
	public String getParam() {
		return param;
	}

	public void setParam(String param) {
		this.param = param;
	}
	
	public void exportSingleValue(String sDb,String sQuery,String sColumn,String sExportId){
		Connection conn =null;
		Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
		if(sDb.equalsIgnoreCase("admin")){
			conn = MedwanQuery.getInstance().getAdminConnection();
		}
		else if(sDb.equalsIgnoreCase("openclinic")){
			conn = MedwanQuery.getInstance().getOpenclinicConnection();
		}
		else if(sDb.equalsIgnoreCase("stats")){
			conn = MedwanQuery.getInstance().getStatsConnection();
		}
		PreparedStatement ps,ps2;
		try {
			ps = oc_conn.prepareStatement("select * from OC_EXPORTS where OC_EXPORT_ID=? and OC_EXPORT_CREATEDATETIME>?");
			java.sql.Timestamp date = new java.sql.Timestamp(new java.util.Date().getTime()-getInterval());
			System.out.println("date="+date);
			System.out.println("interval="+getInterval());
			ps.setString(1, sExportId);
			ps.setTimestamp(2, date);
			ResultSet rs = ps.executeQuery();
			if(!rs.next()){
				rs.close();
				ps.close();
				ps = conn.prepareStatement(sQuery);
				rs = ps.executeQuery();
				if(rs.next()){
					sQuery="INSERT INTO OC_EXPORTS(OC_EXPORT_OBJECTID,OC_EXPORT_ID,OC_EXPORT_CREATEDATETIME,OC_EXPORT_DATA) VALUES(?,?,?,?)";
					ps2=oc_conn.prepareStatement(sQuery);
					ps2.setInt(1,MedwanQuery.getInstance().getOpenclinicCounter("OC_EXPORT_OBJECTID"));
					ps2.setString(2, sExportId);
					ps2.setTimestamp(3, new java.sql.Timestamp(new java.util.Date().getTime()));
					ps2.setString(4, rs.getString(sColumn));
					ps2.execute();
					ps2.close();
				}
			}
			rs.close();
			ps.close();
		} catch (SQLException e) {
			e.printStackTrace();
		}
		finally {
			try {
				conn.close();
				oc_conn.close();
			} catch (SQLException e) {
				e.printStackTrace();
			}
		}
	}
}
