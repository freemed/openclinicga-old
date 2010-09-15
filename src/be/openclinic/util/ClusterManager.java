package be.openclinic.util;

import java.util.Enumeration;
import java.util.Hashtable;
import java.util.Vector;

public class ClusterManager {
	private String diagnosisType;
	private String[] diagnoses;
	private DiagnosisClusterList[] levels;
	
	public ClusterManager(){
	}

	public ClusterManager(String diagnosisType, String diagnoses){
		this.diagnosisType = diagnosisType;
		this.diagnoses = diagnoses.split("\\$");
		load();
	}
	
	public ClusterManager(String diagnosisType, String[] diagnoses){
		this.diagnosisType = diagnosisType;
		this.diagnoses = diagnoses;
		load();
	}
	
	public void load(){
		DiagnosisClusterList allClusters = new DiagnosisClusterList();
		Hashtable clusterLevels = new Hashtable();
		levels = new DiagnosisClusterList[diagnoses.length];
		int[] diagnosisLevels = new int[diagnoses.length];
		for(int n = 0; n<diagnoses.length ; n++){
			allClusters.add(new DiagnosisCluster(diagnosisType, diagnoses[n]).getClusters());
			levels[n]=new DiagnosisClusterList();
		}
		Enumeration e1 = allClusters.getClusterList().elements();
		while (e1.hasMoreElements()){
			ClusterData clusterData = (ClusterData)e1.nextElement();
			for(int n = 0; n<diagnoses.length ; n++){
				if(clusterData.containsDiagnosis(diagnoses[n])){
					if(clusterLevels.get(clusterData.getClusterData())==null){
						clusterLevels.put(clusterData.getClusterData(), "0");
					}
					else {
						clusterLevels.put(clusterData.getClusterData(), ""+(Integer.parseInt((String)clusterLevels.get(clusterData.getClusterData()))+1));
					}
				}
			}
			levels[Integer.parseInt((String)clusterLevels.get(clusterData.getClusterData()))].add(clusterData);
		}
	}
	
	public DiagnosisClusterList getLevel(int n){
		if(n>=levels.length){
			return null;
		}
		return levels[n];
	}

	public DiagnosisClusterList[] getLevels() {
		return levels;
	}
	
	public int getLevelCount(){
		return levels.length;
	}

}
