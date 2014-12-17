package be.openclinic.finance;

public class InsuranceRule {
	String insurarUid;
	String prestationUid;
	double quantity;
	double days;
	public String getInsurarUid() {
		return insurarUid;
	}
	public void setInsurarUid(String insurarUid) {
		this.insurarUid = insurarUid;
	}
	public String getPrestationUid() {
		return prestationUid;
	}
	public void setPrestationUid(String prestationUid) {
		this.prestationUid = prestationUid;
	}
	public double getQuantity() {
		return quantity;
	}
	public void setQuantity(double quantity) {
		this.quantity = quantity;
	}
	public double getDays() {
		return days;
	}
	public void setDays(double days) {
		this.days = days;
	}
	public InsuranceRule(String insurarUid, String prestationUid,
			double quantity, double days) {
		super();
		this.insurarUid = insurarUid;
		this.prestationUid = prestationUid;
		this.quantity = quantity;
		this.days = days;
	}
	
}
