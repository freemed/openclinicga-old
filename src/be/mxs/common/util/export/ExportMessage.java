package be.mxs.common.util.export;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.Enumeration;
import java.util.HashSet;
import java.util.Hashtable;
import java.util.Iterator;

import org.dom4j.Document;
import org.dom4j.DocumentHelper;
import org.dom4j.Element;

import be.mxs.common.util.db.MedwanQuery;
import be.mxs.common.util.system.HTMLEntities;

public class ExportMessage {
	private static final SimpleDateFormat DATEFORMAT = new SimpleDateFormat("yyyyMMddHHmmssSSS");
	private Document document;
	private Date start;

	public Date getStart() {
		return start;
	}

	public void setStart(Date start) {
		this.start = start;
	}

	public Document getDocument() {
		return document;
	}

	public void setDocument(Document document) {
		this.document = document;
	}
	
	public ExportMessage(int days){
		long day = 24*3600*1000;
		this.start=new Date(new Date().getTime()-days*day);
	}

	public ExportMessage(Date start) {
		this.start=start;
	}
	
	public void createExportMessage(){
		document = DocumentHelper.createDocument();
		Element message = DocumentHelper.createElement("message");
		message.addAttribute("serveid", MedwanQuery.getInstance().getConfigString("serverId"));
		message.addAttribute("servename", MedwanQuery.getInstance().getConfigString("servername"));
		message.addAttribute("date", DATEFORMAT.format(new Date()));
		message.addAttribute("start", DATEFORMAT.format(start));
		document.setRootElement(message);
		document.getRootElement().add(addPatients());
	}
	
	private void addTextElement(Element parent, String name, String text){
		if(text!=null && text.trim().length()>0){
			Element element = DocumentHelper.createElement(name);
			element.setText(HTMLEntities.xmlencode(text));
			parent.add(element);
		}
	}
	
	private void addDateElement(Element parent, String name, Date date){
		if(date!=null){
			Element element = DocumentHelper.createElement(name);
			element.setText(DATEFORMAT.format(date));
			parent.add(element);
		}
	}
	
	private void addIdElement(Element parent, String type, String text){
		if(text!=null && text.trim().length()>0){
			Element element = DocumentHelper.createElement("id");
			element.addAttribute("type",type);
			element.setText(text);
			parent.add(element);
		}
	}
	
	private Element getPersonElement(ResultSet rs){
		Element element = DocumentHelper.createElement("person");
		try{
			element.addAttribute("updatetime", DATEFORMAT.format(rs.getTimestamp("updatetime")));
			addTextElement(element,"lastname", rs.getString("lastname"));
			addTextElement(element,"firstname", rs.getString("firstname"));
			addTextElement(element,"middlename", rs.getString("middlename"));
			addTextElement(element,"gender", rs.getString("gender"));
			addDateElement(element,"dateofbirth", rs.getDate("dateofbirth"));
			addTextElement(element,"language", rs.getString("language"));
			addDateElement(element,"engagement", rs.getDate("engagement"));
			addDateElement(element,"pension", rs.getDate("pension"));
			addTextElement(element,"nativecountry", rs.getString("native_country"));
			addTextElement(element,"nativetown", rs.getString("native_town"));
			addDateElement(element,"startdate_inactivity", rs.getDate("startdate_inactivity"));
			addDateElement(element,"enddate_inactivity", rs.getDate("enddate_inactivity"));
			addTextElement(element,"comment1", rs.getString("comment1"));
			addTextElement(element,"comment2", rs.getString("comment2"));
			addTextElement(element,"comment3", rs.getString("comment3"));
			addTextElement(element,"comment4", rs.getString("comment4"));
			addTextElement(element,"comment5", rs.getString("comment5"));
		}
		catch(Exception e){
			e.printStackTrace();
		}
		return element;
	}
	
	private Element getPrivateElement(ResultSet rs){
		Element element = DocumentHelper.createElement("private");
		try{
			element.addAttribute("updatetime", DATEFORMAT.format(rs.getTimestamp("updatetime")));
			addDateElement(element,"start", rs.getDate("start"));
			addDateElement(element,"stop", rs.getDate("stop"));
			addTextElement(element,"address", rs.getString("address"));
			addTextElement(element,"city", rs.getString("city"));
			addTextElement(element,"zipcode", rs.getString("zipcode"));
			addTextElement(element,"country", rs.getString("country"));
			addTextElement(element,"telephone", rs.getString("telephone"));
			addTextElement(element,"fax", rs.getString("fax"));
			addTextElement(element,"mobile", rs.getString("mobile"));
			addTextElement(element,"email", rs.getString("email"));
			addTextElement(element,"comment", rs.getString("comment"));
			addTextElement(element,"type", rs.getString("type"));
			addTextElement(element,"district", rs.getString("district"));
			addTextElement(element,"sanitarydistrict", rs.getString("sanitarydistrict"));
			addTextElement(element,"province", rs.getString("province"));
			addTextElement(element,"sector", rs.getString("sector"));
			addTextElement(element,"cell", rs.getString("cell"));
			addTextElement(element,"quarter", rs.getString("quarter"));
			addTextElement(element,"business", rs.getString("business"));
			addTextElement(element,"businessfunction", rs.getString("businessfunction"));
		}
		catch(Exception e){
			e.printStackTrace();
		}
		return element;
	}
	
	private Element getAdminIdElement(ResultSet rs){
		Element element = DocumentHelper.createElement("ids");
		try{
			addIdElement(element,"national", rs.getString("natreg"));
			addIdElement(element,"employer", rs.getString("immatnew"));
			addIdElement(element,"healthrecord", rs.getString("immatold"));
			addIdElement(element,"archive", rs.getString("archiveFileCode"));
		}
		catch(Exception e){
			e.printStackTrace();
		}
		return element;
	}
	
	private Element addPatients(){
		int personid;
		Hashtable patientids = new Hashtable();
		Hashtable person = new Hashtable();
		Hashtable privatedata = new Hashtable();
		Element patients = DocumentHelper.createElement("patients");
		//Hier maken we een lijst van alle patiënten waarvan gegevens geëxporteerd moeten kunnen worden
		Connection conn = MedwanQuery.getInstance().getAdminConnection();
		PreparedStatement ps=null;
		ResultSet rs=null;
		try{
			//We beginnen met de admin tabel
			ps=conn.prepareStatement("select * from admin where updatetime>=?");
			ps.setTimestamp(1, new java.sql.Timestamp(start.getTime()));
			rs=ps.executeQuery();
			while(rs.next()){
				personid=rs.getInt("personid");
				patientids.put(personid,getAdminIdElement(rs));
				person.put(personid, getPersonElement(rs));
			}
			rs.close();
			ps.close();
			
			//Dan voegen we de gegevens van de AdminPrivate tabel toe
			ps=conn.prepareStatement("select * from adminprivate where updatetime>=?");
			ps.setTimestamp(1, new java.sql.Timestamp(start.getTime()));
			rs=ps.executeQuery();
			while(rs.next()){
				personid=rs.getInt("personid");
				if(patientids.get(personid)==null){
					patientids.put(personid,DocumentHelper.createElement("ids"));
				}
				privatedata.put(personid, getPrivateElement(rs));
			}
			rs.close();
			ps.close();
			
			
			//Nu hebben we alle patiënten waarvoor wijzigingen werden aangebracht in de database, we gaan deze exporteren
			Enumeration ids = patientids.keys();
			while (ids.hasMoreElements()){
				personid=(Integer)ids.nextElement();
				Element patient = DocumentHelper.createElement("patient");
				patient.addAttribute("iid", personid+"");
				//Add ID elements
				patient.add((Element)patientids.get(personid));
				//Add admin element
				Element admin=DocumentHelper.createElement("admin");
				if(person.get(personid)!=null){
					admin.add((Element)person.get(personid));
				}
				if(privatedata.get(personid)!=null){
					admin.add((Element)privatedata.get(personid));
				}
				patient.add(admin);
				//Add financial element
				//Add healthrecord element
				patients.add(patient);
			}
		}
		catch(Exception e){
			e.printStackTrace();
		}
		finally {
			try{
				if(rs!=null && !rs.isClosed()) rs.close();
				if(ps!=null && !ps.isClosed()) ps.close();
			}
			catch(Exception e2){
				e2.printStackTrace();
			}
			try{
				conn.close();
			}
			catch(Exception e2){
				e2.printStackTrace();
			}
		}
		return patients;
	}
	
	
	
}
