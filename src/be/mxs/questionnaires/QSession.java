package be.mxs.questionnaires;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.Vector;

import net.admin.AdminPerson;

import be.mxs.common.util.db.MedwanQuery;

public class QSession {
	private String candidateid;
	private Vector Appointments;
	
	public String getCandidateid() {
		return candidateid;
	}
	public void setCandidateid(String candidateid) {
		this.candidateid = candidateid;
	}
	public Vector getQuestionnaires() {
		Vector questionnaires = new Vector();
		try{
			Connection conn = MedwanQuery.getInstance().getOpenclinicConnection();
			String sQuery="select * from OC_QUESTIONNAIRES order by OC_QUESTIONNAIRE_ID";
			PreparedStatement ps = conn.prepareStatement(sQuery);
			ResultSet rs = ps.executeQuery();
			while(rs.next()){
				QQuestionnaire q = new QQuestionnaire(rs.getInt("OC_QUESTIONNAIRE_ID"),rs.getString("OC_QUESTIONNAIRE_TITLE_NL"),rs.getString("OC_QUESTIONNAIRE_TITLE_FR"),rs.getString("OC_QUESTIONNAIRE_TITLE_EN"),rs.getString("OC_QUESTIONNAIRE_TITLE_DE"),rs.getString("OC_QUESTIONNAIRE_TITLE_ES"));
				questionnaires.add(q);
			}
			rs.close();
			ps.close();
			conn.close();
		}
		catch(Exception e){
			e.printStackTrace();
		}
		return questionnaires;
	}
	public Vector getAppointments() {
		return Appointments;
	}
	public void setAppointments(Vector appointments) {
		Appointments = appointments;
	}
	
	public QSession(String candidateid){
		this.candidateid=candidateid;
	}
	
	public AdminPerson getPerson(){
		String personid = AdminPerson.getPersonIdByImmatnew(this.candidateid);
		if(personid!=null){
			return AdminPerson.getAdminPerson(personid);
		}
		return null;
	}
	
}
