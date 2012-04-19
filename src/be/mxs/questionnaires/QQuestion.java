package be.mxs.questionnaires;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

import be.mxs.common.util.db.MedwanQuery;

public class QQuestion {
	private int id;
	private int questionnaireid;
	private String nl;
	private String fr;
	private String en;
	private String de;
	private String es;
	private String answertype;
	private String answervalues;
	private int answermandatory;
	public int getId() {
		return id;
	}
	public void setId(int id) {
		this.id = id;
	}
	public int getQuestionnaireid() {
		return questionnaireid;
	}
	public void setQuestionnaireid(int questionnaireid) {
		this.questionnaireid = questionnaireid;
	}
	public String getNl() {
		return nl;
	}
	public void setNl(String nl) {
		this.nl = nl;
	}
	public String getFr() {
		return fr;
	}
	public void setFr(String fr) {
		this.fr = fr;
	}
	public String getEn() {
		return en;
	}
	public void setEn(String en) {
		this.en = en;
	}
	public String getDe() {
		return de;
	}
	public void setDe(String de) {
		this.de = de;
	}
	public String getEs() {
		return es;
	}
	public void setEs(String es) {
		this.es = es;
	}
	public String getAnswertype() {
		return answertype;
	}
	public void setAnswertype(String answertype) {
		this.answertype = answertype;
	}
	public String getAnswervalues() {
		return answervalues;
	}
	public void setAnswervalues(String answervalues) {
		this.answervalues = answervalues;
	}
	public int getAnswermandatory() {
		return answermandatory;
	}
	public void setAnswermandatory(int answermandatory) {
		this.answermandatory = answermandatory;
	}
	public QQuestion(int id, int questionnaireid, String nl, String fr,
			String en, String de, String es, String answertype,
			String answervalues, int answermandatory) {
		this.id = id;
		this.questionnaireid = questionnaireid;
		this.nl = nl;
		this.fr = fr;
		this.en = en;
		this.de = de;
		this.es = es;
		this.answertype = answertype;
		this.answervalues = answervalues;
		this.answermandatory = answermandatory;
	}
	
	public static QQuestion get(int id){
		QQuestion q = null;
		try{
			Connection conn = MedwanQuery.getInstance().getOpenclinicConnection();
			String sQuery="select * from OC_QUESTIONS where OC_QUESTION_ID=?";
			PreparedStatement ps = conn.prepareStatement(sQuery);
			ps.setInt(1, id);
			ResultSet rs = ps.executeQuery();
			if(rs.next()){
				q = new QQuestion(rs.getInt("OC_QUESTION_ID"),rs.getInt("OC_QUESTION_QUESTIONNAIREID"),rs.getString("OC_QUESTION_NL"),rs.getString("OC_QUESTION_FR"),rs.getString("OC_QUESTION_EN"),rs.getString("OC_QUESTION_DE"),rs.getString("OC_QUESTION_ES"),rs.getString("OC_QUESTION_ANSWERTYPE"),rs.getString("OC_QUESTION_ANSWERVALUES"),rs.getInt("OC_QUESTION_ANSWERMANDATORY"));
			}
			rs.close();
			ps.close();
			conn.close();
		}
		catch(Exception e){
			e.printStackTrace();
		}
		return q;
	}
	
	public void store(){
		try{
			String sQuery;
			PreparedStatement ps;
			Connection conn = MedwanQuery.getInstance().getOpenclinicConnection();
			if(this.id<0){
				this.id=MedwanQuery.getInstance().getOpenclinicCounter("QQUESTION");
			}
			else {
				sQuery="delete from OC_QUESTIONS where OC_QUESTION_ID=?";
				ps = conn.prepareStatement(sQuery);
				ps.setInt(1, this.id);
				ps.execute();
				ps.close();
			}
			sQuery="insert into OC_QUESTIONS(OC_QUESTION_ID,OC_QUESTION_QUESTIONNAIREID,OC_QUESTION_NL,OC_QUESTION_FR,OC_QUESTION_EN,OC_QUESTION_DE,OC_QUESTION_ES,OC_QUESTION_ANSWERTYPE,OC_QUESTION_ANSWERVALUES,OC_QUESTION_ANSWERMANDATORY) values (?,?,?,?,?,?,?,?,?,?)";
			ps = conn.prepareStatement(sQuery);
			ps.setInt(1, this.id);
			ps.setInt(2, this.questionnaireid);
			ps.setString(3, this.nl);
			ps.setString(4, this.fr);
			ps.setString(5, this.en);
			ps.setString(6, this.de);
			ps.setString(7, this.es);
			ps.setString(8, this.answertype);
			ps.setString(9, this.answervalues);
			ps.setInt(10, this.answermandatory);
			ps.execute();
			ps.close();
			conn.close();
		}
		catch(Exception e){
			e.printStackTrace();
		}
	}
	
	public QAnswer getAnswer(String sessionid){
		QAnswer answer = null;
		try{
			Connection conn = MedwanQuery.getInstance().getOpenclinicConnection();
			String sQuery="select * from OC_ANSWERS where OC_ANSWER_QUESTIONID=? and OC_ANSWER_SESSIONID=?";
			PreparedStatement ps = conn.prepareStatement(sQuery);
			ps.setInt(1, this.id);
			ps.setString(2, sessionid);
			ResultSet rs = ps.executeQuery();
			if(rs.next()){
				answer = new QAnswer(rs.getInt("OC_ANSWER_ID"),this.id,rs.getString("OC_ANSWER_VALUE"),sessionid);
			}
			rs.close();
			ps.close();
			conn.close();
		}
		catch(Exception e){
			e.printStackTrace();
		}
		return answer;
	}
	

}
