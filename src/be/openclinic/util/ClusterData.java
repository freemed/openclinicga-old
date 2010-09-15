package be.openclinic.util;

public class ClusterData implements Comparable{
	private double count;
	private double mortality;
	private double gravity;
	private String clusterData;

	public int compareTo(Object o) {
		return compareTo((ClusterData)o);
	}

	public int compareTo(ClusterData o){
        return new Double(this.getCount()-o.getCount()).intValue();
    }

	public double getCount() {
		return count;
	}

	public int getAbsoluteMortality(){
		return new Double(mortality).intValue();
	}
	
	public double getRelativeMortality(){
		return mortality/count;
	}
	
	public double getGravity(){
		return gravity/count;
	}

	public String getClusterData() {
		return clusterData;
	}

	public ClusterData(double count, double mortality, double gravity,
			String clusterData) {
		super();
		this.count = count;
		this.mortality = mortality;
		this.gravity = gravity;
		this.clusterData = clusterData;
	}
	
	public void add(ClusterData clusterData){
		this.count+=clusterData.count;
		this.mortality+=clusterData.mortality;
		this.gravity+=clusterData.gravity;
	}
	
	public boolean containsDiagnosis(String diagnosis){
		String[] diagnoses = clusterData.split("\\$");
		for(int n=0; n<diagnoses.length; n++){
			if(diagnosis.equalsIgnoreCase(diagnoses[n])){
				return true;
			}
		}
		return false;
	}

}
