package be.openclinic.util;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.Enumeration;
import java.util.Hashtable;

import be.mxs.common.util.db.MedwanQuery;

public class DiagnosisCluster {
	String diagnosisType;
	String diagnosisCode;
	Hashtable years=new Hashtable();;
	
	public String getDiagnosisType() {
		return diagnosisType;
	}
	public void setDiagnosisType(String diagnosisType) {
		this.diagnosisType = diagnosisType;
	}
	public String getDiagnosisCode() {
		return diagnosisCode;
	}
	public void setDiagnosisCode(String diagnosisCode) {
		this.diagnosisCode = diagnosisCode;
	}
	public Hashtable getYears() {
		return years;
	}
	public void setYears(Hashtable years) {
		this.years = years;
	}
	public DiagnosisCluster(String diagnosisType, String diagnosisCode) {
		super();
		this.diagnosisType = diagnosisType;
		this.diagnosisCode = diagnosisCode;
		load();
	}
	
	public void load(){
        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
		try{
			String year, clusterData;
			int count,mortality,gravity;
			String sql="SELECT b.* " +
					" from OC_CLUSTER_DIAGS a, OC_DIAG_CLUSTERS b" +
					" where" +
					" a.OC_DIAG_CODE=? and" +
					" a.OC_DIAG_TYPE=? and" +
					" a.OC_DIAG_CLUSTERDATA=b.OC_CLUSTER_DATA and" +
					" a.OC_DIAG_YEAR=b.OC_CLUSTER_YEAR and" +
					" a.OC_DIAG_TYPE=b.OC_CLUSTER_DIAGTYPE";
			PreparedStatement ps = oc_conn.prepareStatement(sql);
			ps.setString(1, diagnosisCode);
			ps.setString(2, diagnosisType);
			ResultSet rs = ps.executeQuery();
			while (rs.next()){
				year = rs.getString("OC_CLUSTER_YEAR");
				clusterData = rs.getString("OC_CLUSTER_DATA");
				count = rs.getInt("OC_CLUSTER_COUNT");
				mortality = rs.getInt("OC_CLUSTER_MORTALITY");
				gravity = rs.getInt("OC_CLUSTER_GRAVITY");
				if(years.get(year)==null){
					years.put(year, new Hashtable());
				}
				((Hashtable)years.get(year)).put(clusterData, new ClusterData(count, mortality, gravity, clusterData));
			}
			rs.close();
			ps.close();
		}
		catch(Exception e){
			e.printStackTrace();
		}
		try {
			oc_conn.close();
		} catch (SQLException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
	}
	
	public DiagnosisClusterList getClusters(){
		String year;
		Hashtable clusters = new Hashtable();
		Enumeration e1 = years.elements();
		while(e1.hasMoreElements()){
			Enumeration e2 = ((Hashtable)e1.nextElement()).elements();
			while (e2.hasMoreElements()){
				ClusterData clusterData = (ClusterData)e2.nextElement();
				if (clusters.get(clusterData.getClusterData())==null){
					clusters.put(clusterData.getClusterData(), clusterData);
				}
				else {
					((ClusterData)clusters.get(clusterData.getClusterData())).add(clusterData);
				}
			}
		}
		return new DiagnosisClusterList(clusters);
	}

	public DiagnosisClusterList getClusters(String year){
		return new DiagnosisClusterList((Hashtable)years.get(year));
	}
}
