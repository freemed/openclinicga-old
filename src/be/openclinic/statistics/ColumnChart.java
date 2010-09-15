package be.openclinic.statistics;

import java.util.Hashtable;
import java.util.Vector;

import be.mxs.common.util.system.StatFunctions;
import be.openclinic.common.KeyValue;

public class ColumnChart {
	String name;
	String xlabel;
	String ylabel;
	Vector values=new Vector();
	
	public ColumnChart(String name, String xlabel, String ylabel) {
		super();
		this.name = name;
		this.xlabel = xlabel;
		this.ylabel = ylabel;
	}

	public ColumnChart(String name, String xlabel, String ylabel, KeyValue[] values) {
		super();
		this.name = name;
		this.xlabel = xlabel;
		this.ylabel = ylabel;
		for(int n=0;n<values.length;n++){
			addValue(values[n].getKey(), values[n].getValue());
		}
	}

	public ColumnChart(String name, String xlabel, String ylabel, Hashtable v) {
		KeyValue[] values = StatFunctions.getTop(v, v.size());
		this.name = name;
		this.xlabel = xlabel;
		this.ylabel = ylabel;
		for(int n=0;n<values.length;n++){
			addValue(values[n].getKey(), values[n].getValue());
		}
		
	}

	public String getName() {
		return name;
	}

	public void setName(String name) {
		this.name = name;
	}

	public String getXlabel() {
		return xlabel;
	}

	public void setXlabel(String xlabel) {
		this.xlabel = xlabel;
	}

	public String getYlabel() {
		return ylabel;
	}

	public void setYlabel(String ylabel) {
		this.ylabel = ylabel;
	}

	public Vector getValues() {
		return values;
	}

	public void setValues(Vector values) {
		this.values = values;
	}
	
	public void addValue(String x, String y){
		values.add(new KeyValue(x,y));
	}
	
	
}
