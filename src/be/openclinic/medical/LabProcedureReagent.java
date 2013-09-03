package be.openclinic.medical;

public class LabProcedureReagent{
	String procedureuid;
	String reagentuid;
	double quantity;
	String consumptionType;
	
	public String getConsumptionType() {
		return consumptionType;
	}

	public void setConsumptionType(String consumptionType) {
		this.consumptionType = consumptionType;
	}

	public String getProcedureuid() {
		return procedureuid;
	}

	public void setProcedureuid(String procedureuid) {
		this.procedureuid = procedureuid;
	}

	public String getReagentuid() {
		return reagentuid;
	}

	public void setReagentuid(String reagentuid) {
		this.reagentuid = reagentuid;
	}

	public double getQuantity() {
		return quantity;
	}

	public void setQuantity(double quantity) {
		this.quantity = quantity;
	}

	public Reagent getReagent(){
		if(reagentuid!=null && reagentuid.split("\\.").length==2){
			return Reagent.get(reagentuid);
		}
		return null;
	}
}