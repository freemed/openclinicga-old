package be.openclinic.statistics;

import java.util.Vector;

public class BaseChart {
	String name;
	String xlabel;
	String ylabel;
	Vector values=new Vector();
	
	public BaseChart(String name, String xlabel, String ylabel) {
		super();
		this.name = name;
		this.xlabel = xlabel;
		this.ylabel = ylabel;
	}

	public BaseChart(String name, String xlabel, String ylabel, int[] values) {
		super();
		this.name = name;
		this.xlabel = xlabel;
		this.ylabel = ylabel;
		for(int n=0;n<values.length;n++){
			addValue(n, values[n]);
		}
	}

	public BaseChart(String name, String xlabel, String ylabel, double[] values) {
		super();
		this.name = name;
		this.xlabel = xlabel;
		this.ylabel = ylabel;
		for(int n=0;n<values.length;n++){
			addValue(n, values[n]);
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
	
	public void addValue(double x, double y){
		values.add(new XYValue(x,y));
	}
	
	
}
