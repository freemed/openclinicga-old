package be.openclinic.statistics;

public class KeyValue {
	String key;
	double value;
	public String getKey() {
		return key;
	}
	public void setKey(String key) {
		this.key = key;
	}
	public double getValue() {
		return value;
	}
	public void setValue(double value) {
		this.value = value;
	}
	public KeyValue(String key, double value) {
		super();
		this.key = key;
		this.value = value;
	}
	
	
}
