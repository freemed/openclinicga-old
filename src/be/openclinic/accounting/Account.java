package be.openclinic.accounting;

import be.openclinic.common.AC_Object;

public class Account extends AC_Object{
	String type;
	String code;
	String name;
	
	public String getType() {
		return type;
	}
	public void setType(String type) {
		this.type = type;
	}
	public String getCode() {
		return code;
	}
	public void setCode(String code) {
		this.code = code;
	}
	public String getName() {
		return name;
	}
	public void setName(String name) {
		this.name = name;
	}

	protected void initialize() {
		setTable("AC_ACCOUNTS");
		getColumns().put("id", "AC_ACCOUNT_ID");
		getColumns().put("type", "AC_ACCOUNT_TYPE");
		getColumns().put("code", "AC_ACCOUNT_CODE");
		getColumns().put("name", "AC_ACCOUNT_NAME");
		getColumns().put("updateUser", "AC_ACCOUNT_UPDATEUID");
		getColumns().put("updateDateTime", "AC_ACCOUNT_UPDATETIME");
	}
	
	public static Account get(int id){
		Account object = new Account();
		object.setId(id);
		if(object.load()){
			return object;
		}
		else {
			return null;
		}
	}

	public static Account get(String id){
		return get(Integer.parseInt(id));
	}
}
