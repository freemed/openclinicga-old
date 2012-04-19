package be.mxs.questionnaires;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.Vector;

import be.mxs.common.util.db.MedwanQuery;

public class QQuestionnaire {
	private int id;
	private String nl;
	private String fr;
	private String en;
	private String de;
	private String es;

	public int getId() {
		return id;
	}
	public void setId(int id) {
		this.id = id;
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
	
	public QQuestionnaire(int id,String nl, String fr, String en, String de, String es){
		this.id=id;
		this.nl=nl;
		this.fr=fr;
		this.en=en;
		this.de=de;
		this.es=es;
	}
	
	public static QQuestionnaire get(int id){
		QQuestionnaire q = null;
		try{
			Connection conn = MedwanQuery.getInstance().getOpenclinicConnection();
			String sQuery="select * from OC_QUESTIONNAIRES where OC_QUESTIONNAIRE_ID=?";
			PreparedStatement ps = conn.prepareStatement(sQuery);
			ps.setInt(1, id);
			ResultSet rs = ps.executeQuery();
			if(rs.next()){
				q = new QQuestionnaire(id,rs.getString("OC_QUESTIONNAIRE_TITLE_NL"),rs.getString("OC_QUESTIONNAIRE_TITLE_FR"),rs.getString("OC_QUESTIONNAIRE_TITLE_EN"),rs.getString("OC_QUESTIONNAIRE_TITLE_DE"),rs.getString("OC_QUESTIONNAIRE_TITLE_ES"));
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
				this.id=MedwanQuery.getInstance().getOpenclinicCounter("QQUESTIONNAIRE");
			}
			else {
				sQuery="delete from OC_QUESTIONNAIRES where OC_QUESTIONNAIRE_ID=?";
				ps = conn.prepareStatement(sQuery);
				ps.setInt(1, this.id);
				ps.execute();
				ps.close();
			}
			sQuery="insert into OC_QUESTIONNAIRES(OC_QUESTIONNAIRE_ID,OC_QUESTIONNAIRE_TITLE_NL,OC_QUESTIONNAIRE_TITLE_FR,OC_QUESTIONNAIRE_TITLE_EN,OC_QUESTIONNAIRE_TITLE_DE,OC_QUESTIONNAIRE_TITLE_ES) values (?,?,?,?,?,?)";
			ps = conn.prepareStatement(sQuery);
			ps.setInt(1, this.id);
			ps.setString(2, this.nl);
			ps.setString(3, this.fr);
			ps.setString(4, this.en);
			ps.setString(5, this.de);
			ps.setString(6, this.es);
			ps.execute();
			ps.close();
			conn.close();
		}
		catch(Exception e){
			e.printStackTrace();
		}
	}
	
	public Vector getQuestions(){
		Vector questions = new Vector();
		try{
			Connection conn = MedwanQuery.getInstance().getOpenclinicConnection();
			String sQuery="select * from OC_QUESTIONS where OC_QUESTION_QUESTIONNAIREID=? order by OC_QUESTION_ID";
			PreparedStatement ps = conn.prepareStatement(sQuery);
			ps.setInt(1,this.id);
			ResultSet rs = ps.executeQuery();
			while(rs.next()){
				QQuestion q = new QQuestion(rs.getInt("OC_QUESTION_ID"),rs.getInt("OC_QUESTION_QUESTIONNAIREID"),rs.getString("OC_QUESTIONNAIRE_NL"),rs.getString("OC_QUESTIONNAIRE_FR"),rs.getString("OC_QUESTIONNAIRE_EN"),rs.getString("OC_QUESTIONNAIRE_DE"),rs.getString("OC_QUESTIONNAIRE_ES"),rs.getString("OC_QUESTION_ANSWERTYPE"),rs.getString("OC_QUESTION_ANSWERVALUES"),rs.getInt("OC_QUESTION_ANSWERMANDATORY"));
				questions.add(q);
			}
			rs.close();
			ps.close();
			conn.close();
		}
		catch(Exception e){
			e.printStackTrace();
		}
		return questions;
	}
}
