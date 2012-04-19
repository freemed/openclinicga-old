package be.mxs.questionnaires;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

import be.mxs.common.util.db.MedwanQuery;

public class QAnswer {
	private int id=-1;
	private int questionid;
	private String value;
	private String sessionid;
	public int getId() {
		return id;
	}
	public void setId(int id) {
		this.id = id;
	}
	public int getQuestionid() {
		return questionid;
	}
	public void setQuestionid(int questionid) {
		this.questionid = questionid;
	}
	public String getValue() {
		return value;
	}
	public void setValue(String value) {
		this.value = value;
	}
	public String getSessionid() {
		return sessionid;
	}
	public void setSessionid(String sessionid) {
		this.sessionid = sessionid;
	}
	public QAnswer(int id, int questionid, String value, String sessionid) {
		super();
		this.id = id;
		this.questionid = questionid;
		this.value = value;
		this.sessionid = sessionid;
	}
	
	public static QAnswer get(int id){
		QAnswer a = null;
		try{
			Connection conn = MedwanQuery.getInstance().getOpenclinicConnection();
			String sQuery="select * from OC_ANSWERS where OC_ANSWER_ID=?";
			PreparedStatement ps = conn.prepareStatement(sQuery);
			ps.setInt(1, id);
			ResultSet rs = ps.executeQuery();
			if(rs.next()){
				a = new QAnswer(rs.getInt("OC_ANSWER_ID"),rs.getInt("OC_ANSWER_QUESTIONID"),rs.getString("OC_ANSWER_VALUE"),rs.getString("OC_ANSWER_SESSIONID"));
			}
			rs.close();
			ps.close();
			conn.close();
		}
		catch(Exception e){
			e.printStackTrace();
		}
		return a;
	}

	public void store(){
		try{
			String sQuery;
			PreparedStatement ps;
			Connection conn = MedwanQuery.getInstance().getOpenclinicConnection();
			if(this.id<0){
				this.id=MedwanQuery.getInstance().getOpenclinicCounter("QANSWER");
			}
			else {
				sQuery="delete from OC_ANSWERS where OC_ANSWER_ID=?";
				ps = conn.prepareStatement(sQuery);
				ps.setInt(1, this.id);
				ps.execute();
				ps.close();
			}
			sQuery="insert into OC_ANSWERS(OC_ANSWER_ID,OC_ANSWER_QUESTIONID,OC_ANSWER_VALUE,OC_ANSWER_SESSIONID) values (?,?,?,?)";
			ps = conn.prepareStatement(sQuery);
			ps.setInt(1, this.id);
			ps.setInt(2, this.questionid);
			ps.setString(3, this.value);
			ps.setString(4, this.sessionid);
			ps.execute();
			ps.close();
			conn.close();
		}
		catch(Exception e){
			e.printStackTrace();
		}
	}


}
