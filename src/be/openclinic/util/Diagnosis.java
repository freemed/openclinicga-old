package be.openclinic.util;

public class Diagnosis {
	String sCodeType;
	String sCode;
	int nGravity;
	
	public Diagnosis(){
		
	}
	public Diagnosis (String sCodeType, String sCode, int nGravity){
		this.sCodeType = sCodeType;
		this.sCode = sCode;
		this.nGravity = nGravity;
	}
}
