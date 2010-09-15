package be.openclinic.util;

import java.util.Comparator;

public class ClusterDataSortByRelativeMortality implements Comparator{
	public int compare(Object arg0, Object arg1) {
		// TODO Auto-generated method stub
		return new Double(((ClusterData)arg1).getRelativeMortality()*10000-((ClusterData)arg0).getRelativeMortality()*10000).intValue();
	}
}
