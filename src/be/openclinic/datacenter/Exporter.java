package be.openclinic.datacenter;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.Date;

import be.mxs.common.util.db.MedwanQuery;

public abstract class Exporter {
	String param="";
	Date deadline;
	
	public abstract void export();

	public Date getDeadline() {
		return deadline;
	}

	public void setDeadline(Date deadline) {
		this.deadline = deadline;
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
			ps.setString(1, sExportId);
			ps.setTimestamp(2, new java.sql.Timestamp(getDeadline().getTime()));
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
