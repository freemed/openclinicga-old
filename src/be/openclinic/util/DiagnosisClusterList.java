package be.openclinic.util;

import java.util.Collection;
import java.util.Collections;
import java.util.Comparator;
import java.util.Enumeration;
import java.util.Hashtable;
import java.util.List;
import java.util.SortedMap;
import java.util.SortedSet;
import java.util.TreeMap;
import java.util.TreeSet;
import java.util.Vector;

public class DiagnosisClusterList {
	private Hashtable clusterList = new Hashtable();

	public Hashtable getClusterList() {
		return clusterList;
	}

	public void setClusterList(Hashtable clusterList) {
		this.clusterList = clusterList;
	}

	public DiagnosisClusterList(){
		super();
	}
	
	public DiagnosisClusterList(Hashtable clusterList) {
		super();
		this.clusterList = clusterList;
	}
	
	public DiagnosisClusterList getContaining(String diagnosis){
		Hashtable resultCluster = new Hashtable();
		Enumeration e1 = clusterList.elements();
		while(e1.hasMoreElements()){
			ClusterData clusterData = (ClusterData)e1.nextElement();
			if(clusterData.containsDiagnosis(diagnosis)){
				resultCluster.put(clusterData.getClusterData(), clusterData);
			}
		}
		return new DiagnosisClusterList(resultCluster);
	}
	
	public void add(ClusterData clusterData){
		clusterList.put(clusterData.getClusterData(), clusterData);
	}
	
	public void add(DiagnosisClusterList clusterList){
		this.clusterList.putAll(clusterList.getClusterList());
	}
	
	public void remove(ClusterData clusterData){
		clusterList.remove(clusterData.getClusterData());
	}
	
	public Collection getSortedByCount(){
		Vector collection = new Vector(clusterList.values());
		Collections.sort(collection,new ClusterDataSortByCount());
		return collection;
	}

	public Collection getSortedByRelativeMortality(){
		Vector collection = new Vector(clusterList.values());
		Collections.sort(collection,new ClusterDataSortByRelativeMortality());
		return collection;
	}

	public Collection getSortedByAbsoluteMortality(){
		Vector collection = new Vector(clusterList.values());
		Collections.sort(collection,new ClusterDataSortByAbsoluteMortality());
		return collection;
	}

	public Collection getSortedByGravity(){
		Vector collection = new Vector(clusterList.values());
		Collections.sort(collection,new ClusterDataSortByGravity());
		return collection;
	}
}
