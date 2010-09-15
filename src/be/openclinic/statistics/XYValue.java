package be.openclinic.statistics;

public class XYValue {
	double x;
	double y;
	public double getX() {
		return x;
	}
	public void setX(double x) {
		this.x = x;
	}
	public double getY() {
		return y;
	}
	public void setY(double y) {
		this.y = y;
	}
	public XYValue(double x, double y) {
		super();
		this.x = x;
		this.y = y;
	}
}
