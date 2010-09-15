package be.openclinic.util;

import java.util.Comparator;

public class ClusterDataSortByGravity implements Comparator{
	public int compare(Object arg0, Object arg1) {
		// TODO Auto-generated method stub
		return new Double(((ClusterData)arg1).getGravity()-((ClusterData)arg0).getGravity()).intValue();
	}
}
