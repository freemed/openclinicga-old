package be.openclinic.accountancy;

import java.util.Date;
import be.openclinic.common.AC_Object;

public class Journal extends AC_Object{
	String type;
	String label;
	Date date;
	String comment;
	
	public String getType() {
		return type;
	}

	public void setType(String type) {
		this.type = type;
	}

	public String getLabel() {
		return label;
	}

	public void setLabel(String label) {
		this.label = label;
	}

	public Date getDate() {
		return date;
	}

	public void setDate(Date date) {
		this.date = date;
	}

	public String getComment() {
		return comment;
	}

	public void setComment(String comment) {
		this.comment = comment;
	}

	protected void initialize() {
		setTable("AC_JOURNALS");
		getColumns().put("id", "AC_JOURNAL_ID");
		getColumns().put("type", "AC_JOURNAL_TYPE");
		getColumns().put("label", "AC_JOURNAL_LABEL");
		getColumns().put("date", "AC_JOURNAL_DATE");
		getColumns().put("comment", "AC_JOURNAL_COMMENT");
		getColumns().put("updateUser", "AC_JOURNAL_UPDATEUID");
		getColumns().put("updateDateTime", "AC_JOURNAL_UPDATETIME");
	}
	
	public static Journal get(int id){
		Journal object = new Journal();
		object.setId(id);
		if(object.load()){
			return object;
		}
		else {
			return null;
		}
	}

	public static Journal get(String id){
		return get(Integer.parseInt(id));
	}
}
