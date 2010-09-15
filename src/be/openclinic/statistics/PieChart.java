package be.openclinic.statistics;

import java.util.Vector;

public class PieChart {
	String name;
	Vector values = new Vector();
	
	public PieChart(String name) {
		super();
		this.name = name;
	}

	public PieChart(String name,be.openclinic.common.KeyValue[] values) {
		super();
		this.name = name;
		for(int n=0;n<values.length;n++){
			addValue(values[n].getKey(), Double.parseDouble(values[n].getValue()));
		}
	}

	public String getName() {
		return name;
	}

	public void setName(String name) {
		this.name = name;
	}

	public Vector getValues() {
		return values;
	}

	public void setValues(Vector values) {
		this.values = values;
	}
	
	public void addValue(String key, double value){
		values.add(new KeyValue(key,value));
	}
	
	
}
