package be.openclinic.sync;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.Enumeration;
import java.util.Hashtable;

import org.dom4j.Document;
import org.dom4j.DocumentHelper;
import org.dom4j.Element;

import com.sun.corba.se.spi.legacy.connection.GetEndPointInfoAgainException;

import be.mxs.common.util.db.MedwanQuery;
import be.mxs.common.util.system.ScreenHelper;

public class OpenclinicExporter {
	public Hashtable patientrecords = new Hashtable();
	public Date begin,end;
	
	public String run(){
		begin = getLastExport();
		end = getLastExport();;
		addAdmin();

		Document document = DocumentHelper.createDocument();
		Element export = document.addElement("export");
		export.addAttribute("begin", new SimpleDateFormat("yyyyMMddHHmmssSSSS").format(begin));
		export.addAttribute("end", new SimpleDateFormat("yyyyMMddHHmmssSSSS").format(end));
		Enumeration e = patientrecords.keys();
		while(e.hasMoreElements()){
			int personid = (Integer)e.nextElement();
			export.add((Element)patientrecords.get(personid));
		}
		//setLastExport(end);
		return export.asXML();
	}
	
	public void addAdmin(){
		Connection conn = MedwanQuery.getInstance().getAdminConnection();
		try {
			PreparedStatement ps = conn.prepareStatement("select * from admin where updatetime>=? order by updatetime desc");
			ps.setTimestamp(1, new java.sql.Timestamp(begin.getTime()));
			ResultSet rs = ps.executeQuery();
			while(rs.next() && patientrecords.size()<1000){
				//Create an admin block and save it to the patient record
		        Element admin = DocumentHelper.createElement("admin");
		        Timestamp updatetime = rs.getTimestamp("updatetime");
		        if(updatetime.after(end)){
		        	end=updatetime;
		        }
		        addStringElement(admin, "immatold", rs.getString("immatold"));
		        addStringElement(admin, "immatnew", rs.getString("immatnew"));
		        addStringElement(admin, "candidate", rs.getString("candidate"));
		        addStringElement(admin, "lastname", rs.getString("lastname"));
		        addStringElement(admin, "firstname", rs.getString("firstname"));
		        addStringElement(admin, "gender", rs.getString("gender"));
		        addDateElement(admin, "dateofbirth", rs.getDate("dateofbirth"));
		        addStringElement(admin, "comment", rs.getString("comment"));
		        addStringElement(admin, "sourceid", rs.getString("sourceid"));
		        addStringElement(admin, "language", rs.getString("language"));
		        addStringElement(admin, "gender", rs.getString("gender"));
		        addDateElement(admin, "engagement", rs.getDate("engagement"));
		        addDateElement(admin, "pension", rs.getDate("pension"));
		        addStringElement(admin, "claimant", rs.getString("claimant"));
		        addStringElement(admin, "searchname", rs.getString("searchname"));
		        addTimestampElement(admin, "updatetime", updatetime);
		        addDateElement(admin, "claimant_expiration", rs.getDate("claimant_expiration"));
		        addStringElement(admin, "native_country", rs.getString("native_country"));
		        addStringElement(admin, "native_town", rs.getString("native_town"));
		        addStringElement(admin, "motive_end_of_service", rs.getString("motive_end_of_service"));
		        addDateElement(admin, "startdate_inactivity", rs.getDate("startdate_inactivity"));
		        addDateElement(admin, "enddate_inactivity", rs.getDate("enddate_inactivity"));
		        addStringElement(admin, "code_inactivity", rs.getString("code_inactivity"));
		        addStringElement(admin, "update_status", rs.getString("update_status"));
		        addStringElement(admin, "person_type", rs.getString("person_type"));
		        addStringElement(admin, "situation_end_of_service", rs.getString("situation_end_of_service"));
		        addStringElement(admin, "updateuserid", rs.getString("updateuserid"));
		        addStringElement(admin, "updateserverid", rs.getString("updateserverid"));
		        addStringElement(admin, "comment1", rs.getString("comment1"));
		        addStringElement(admin, "comment2", rs.getString("comment2"));
		        addStringElement(admin, "comment3", rs.getString("comment3"));
		        addStringElement(admin, "comment4", rs.getString("comment4"));
		        addStringElement(admin, "comment5", rs.getString("comment5"));
		        addStringElement(admin, "natreg", rs.getString("natreg"));
		        addStringElement(admin, "middlename", rs.getString("middlename"));
		        addDateElement(admin, "begindate", rs.getDate("begindate"));
		        addDateElement(admin, "enddate", rs.getDate("enddate"));
		        addStringElement(admin, "archivefilecode", rs.getString("archivefilecode"));
		        addToRecord(rs.getInt("personid"), admin);
			}
			rs.close();
			ps.close();
		} catch (SQLException e) {
			e.printStackTrace();
		}
		finally{
			try {
				conn.close();
			} catch (SQLException e) {
				e.printStackTrace();
			}
		}
	}

	public static Date getLastExport(){
		Date dLastExport = null;
		try {
			dLastExport = new SimpleDateFormat("yyyyMMddHHmmssSSS").parse(MedwanQuery.getInstance().getConfigString("lastOpenClinicExport","19000101000000000"));
		} catch (ParseException e) {
			e.printStackTrace();
		}
		return dLastExport;
	}
	
	public static void setLastExport(Date date){
		if(date!=null){
			MedwanQuery.getInstance().setConfigString("lastOpenClinicExport",new SimpleDateFormat("yyyyMMddHHmmssSSS").format(date));
		}
	}
	
	public OpenclinicExporter(){
		
	}

	private void addToRecord(int personid, Element element){
		if(patientrecords.get(personid)==null){
			Element e = DocumentHelper.createElement("record");
			e.addAttribute("personid", personid+"");
			patientrecords.put(personid, e);
		}
		Element e = (Element)patientrecords.get(personid);
		e.add(element);
	}
	
	private void addStringElement(Element parent, String elementName, String elementValue){
		if(elementValue!=null && elementValue.length()>0){
			Element e = parent.addElement(elementName);
			e.setText(elementValue);
			
		}
	}
	
	private void addDateElement(Element parent, String elementName, Date elementValue){
		if(elementValue!=null){
			Element e = parent.addElement(elementName);
			e.setText(new SimpleDateFormat("yyyyDDmm").format(elementValue));
		}
	}
	
	private void addTimestampElement(Element parent, String elementName, Timestamp elementValue){
		if(elementValue!=null){
			Element e = parent.addElement(elementName);
			e.setText(new SimpleDateFormat("yyyyDDmmHHmmssSSS").format(elementValue));
		}
	}
	
}
