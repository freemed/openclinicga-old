package be.openclinic.statistics;

public class Diagnosis {
	String code;
	double gravity;
	double certainty;
	
	public Diagnosis(String code, double gravity, double certainty) {
		super();
		this.code = code;
		this.gravity = gravity;
		this.certainty = certainty;
	}

	public String getCode() {
		return code;
	}

	public void setCode(String code) {
		this.code = code;
	}

	public double getGravity() {
		return gravity;
	}

	public void setGravity(double gravity) {
		this.gravity = gravity;
	}

	public double getCertainty() {
		return certainty;
	}

	public void setCertainty(double certainty) {
		this.certainty = certainty;
	}
	
	public double getWeight(){
		return gravity*certainty;
	}
}
