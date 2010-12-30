package be.openclinic.datacenter;

import java.io.ByteArrayInputStream;
import java.io.UnsupportedEncodingException;
import java.net.URL;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.Enumeration;
import java.util.Hashtable;
import java.util.Properties;
import java.util.Vector;

import javax.mail.Message;
import javax.mail.MessagingException;
import javax.mail.Session;
import javax.mail.Transport;
import javax.mail.internet.InternetAddress;
import javax.mail.internet.MimeMessage;

import org.dom4j.Document;
import org.dom4j.DocumentException;
import org.dom4j.DocumentHelper;
import org.dom4j.Element;
import org.dom4j.io.SAXReader;

import be.mxs.common.util.db.MedwanQuery;

public class ImportMessage extends DatacenterMessage {
	String type;
	int uid;
	Date receiveDateTime;
	String ref;

	public String getRef() {
		return ref;
	}

	public void setRef(String ref) {
		this.ref = ref;
	}

	public String getType() {
		return type;
	}

	public void setType(String type) {
		this.type = type;
	}

	public int getUid() {
		return uid;
	}

	public void setUid(int uid) {
		this.uid = uid;
	}

	public Date getReceiveDateTime() {
		return receiveDateTime;
	}

	public void setReceiveDateTime(Date receiveDateTime) {
		this.receiveDateTime = receiveDateTime;
	}
	
	public void store(){
		Connection conn = MedwanQuery.getInstance().getOpenclinicConnection();
		PreparedStatement ps=null;
		try{
			ps=conn.prepareStatement("select * from OC_IMPORTS where OC_IMPORT_SERVERID=? and OC_IMPORT_OBJECTID=?");
			ps.setInt(1, getServerId());
			ps.setInt(2, getObjectId());
			ResultSet rs = ps.executeQuery();
			if(!rs.next()){
				rs.close();
				ps.close();
				ps=conn.prepareStatement("INSERT INTO OC_IMPORTS(OC_IMPORT_SERVERID,OC_IMPORT_OBJECTID,OC_IMPORT_ID,OC_IMPORT_CREATEDATETIME,OC_IMPORT_RECEIVEDATETIME,OC_IMPORT_ACKDATETIME,OC_IMPORT_DATA,OC_IMPORT_REF,OC_IMPORT_UID,OC_IMPORT_SENTDATETIME) values (?,?,?,?,?,?,?,?,?,?)");
				ps.setInt(1, getServerId());
				ps.setInt(2, getObjectId());
				ps.setString(3, getMessageId());
				ps.setTimestamp(4, new java.sql.Timestamp(getCreateDateTime().getTime()));
				ps.setTimestamp(5, new java.sql.Timestamp(getReceiveDateTime().getTime()));
				ps.setTimestamp(6, getAckDateTime()==null?null:new java.sql.Timestamp(getAckDateTime().getTime()));
				ps.setString(7,getData());
				ps.setString(8, getRef());
				setUid(MedwanQuery.getInstance().getOpenclinicCounter("OC_IMPORTS_UID"));
				ps.setInt(9, getUid());
				ps.setTimestamp(10, getSentDateTime()==null?null:new java.sql.Timestamp(getSentDateTime().getTime()));
				ps.executeUpdate();
			}
			else {
				rs.close();
			}
		}
		catch(Exception e){
			try {
				if(ps!=null){
					ps.close();
				}
			} catch (SQLException e2) {
				// TODO Auto-generated catch block
				e2.printStackTrace();
			}
			e.printStackTrace();
		}
		finally {
			try {
				conn.close();
			} catch (SQLException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
		}
	}
	
	public void updateAckDateTime(Date ackDateTime){
		setAckDateTime(ackDateTime);
		Connection conn = MedwanQuery.getInstance().getOpenclinicConnection();
		PreparedStatement ps=null;
		try{
			ps = conn.prepareStatement("update OC_IMPORTS set OC_IMPORT_ACKDATETIME=? where OC_IMPORT_UID=?");
			ps.setTimestamp(1, new java.sql.Timestamp(ackDateTime.getTime()));
			ps.setInt(2, getUid());
			ps.executeUpdate();
			ps.close();
		}
		catch(Exception e){
			try {
				if(ps!=null){
					ps.close();
				}
			} catch (SQLException e2) {
				// TODO Auto-generated catch block
				e2.printStackTrace();
			}
			e.printStackTrace();
		}
		finally {
			try {
				conn.close();
			} catch (SQLException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
		}
	}
	
	public void updateImportAckDateTime(Date ackDateTime){
		setImportAckDateTime(ackDateTime);
		Connection conn = MedwanQuery.getInstance().getOpenclinicConnection();
		PreparedStatement ps=null;
		try{
			ps = conn.prepareStatement("update OC_IMPORTS set OC_IMPORT_IMPORTACKDATETIME=? where OC_IMPORT_UID=?");
			ps.setTimestamp(1, new java.sql.Timestamp(ackDateTime.getTime()));
			ps.setInt(2, getUid());
			ps.executeUpdate();
			ps.close();
		}
		catch(Exception e){
			try {
				if(ps!=null){
					ps.close();
				}
			} catch (SQLException e2) {
				// TODO Auto-generated catch block
				e2.printStackTrace();
			}
			e.printStackTrace();
		}
		finally {
			try {
				conn.close();
			} catch (SQLException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
		}
	}
	
	public void updateImportDateTime(Date ackDateTime){
		setImportAckDateTime(ackDateTime);
		Connection conn = MedwanQuery.getInstance().getOpenclinicConnection();
		PreparedStatement ps=null;
		try{
			ps = conn.prepareStatement("update OC_IMPORTS set OC_IMPORT_IMPORTDATETIME=? where OC_IMPORT_UID=?");
			ps.setTimestamp(1, new java.sql.Timestamp(ackDateTime.getTime()));
			ps.setInt(2, getUid());
			ps.executeUpdate();
			ps.close();
		}
		catch(Exception e){
			try {
				if(ps!=null){
					ps.close();
				}
			} catch (SQLException e2) {
				// TODO Auto-generated catch block
				e2.printStackTrace();
			}
			e.printStackTrace();
		}
		finally {
			try {
				conn.close();
			} catch (SQLException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
		}
	}
	
	public void updateErrorCode(int error){
		setError(error);
		Connection conn = MedwanQuery.getInstance().getOpenclinicConnection();
		PreparedStatement ps=null;
		try{
			ps = conn.prepareStatement("update OC_IMPORTS set OC_IMPORT_ERRORCODE=? where OC_IMPORT_UID=?");
			ps.setInt(1, error);
			ps.setInt(2, getUid());
			ps.executeUpdate();
			ps.close();
		}
		catch(Exception e){
			try {
				if(ps!=null){
					ps.close();
				}
			} catch (SQLException e2) {
				// TODO Auto-generated catch block
				e2.printStackTrace();
			}
			e.printStackTrace();
		}
		finally {
			try {
				conn.close();
			} catch (SQLException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
		}
	}
	
	public ImportMessage(){
		
	}
	
	public static ImportMessage get(int uid){
		ImportMessage importMessage = null;
		Connection conn = MedwanQuery.getInstance().getOpenclinicConnection();
		PreparedStatement ps=null;
		try{
			ps = conn.prepareStatement("select * from OC_IMPORTS where OC_IMPORT_UID=?");
			ps.setInt(1, uid);
			ResultSet rs = ps.executeQuery();
			if(rs.next()){
				importMessage = new ImportMessage();
				importMessage.setUid(uid);
				importMessage.setServerId(rs.getInt("OC_IMPORT_SERVERID"));
				importMessage.setObjectId(rs.getInt("OC_IMPORT_OBJECTID"));
				importMessage.setMessageId(rs.getString("OC_IMPORT_ID"));
				importMessage.setCreateDateTime(rs.getTimestamp("OC_IMPORT_CREATEDATETIME"));
				importMessage.setSentDateTime(rs.getTimestamp("OC_IMPORT_SENTDATETIME"));
				importMessage.setAckDateTime(rs.getTimestamp("OC_IMPORT_ACKDATETIME"));
				importMessage.setReceiveDateTime(rs.getTimestamp("OC_IMPORT_RECEIVEDATETIME"));
				importMessage.setImportDateTime(rs.getTimestamp("OC_IMPORT_IMPORTDATETIME"));
				importMessage.setImportAckDateTime(rs.getTimestamp("OC_IMPORT_IMPORTACKDATETIME"));
				importMessage.setError(rs.getInt("OC_IMPORT_ERRORCODE"));
				importMessage.setData(rs.getString("OC_IMPORT_DATA"));
				importMessage.setRef(rs.getString("OC_IMPORT_REF"));
			}
			rs.close();
			ps.close();
		}
		catch(Exception e){
			try {
				if(ps!=null){
					ps.close();
				}
			} catch (SQLException e2) {
				// TODO Auto-generated catch block
				e2.printStackTrace();
			}
			e.printStackTrace();
		}
		finally {
			try {
				conn.close();
			} catch (SQLException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
		}
		return importMessage;
	}
	
	public void sendError(){
		
	}
	
	public String asImportAckXML(){
        String msg ="<data serverid='"+getServerId()
        	+"' objectid='"+getObjectId()
        	+"' errorcode='"+getError()
        	+"' importdatetime='"+new SimpleDateFormat("yyyyMMddHHmmss").format(importDateTime)
        	+"' importackdatetime='"+new SimpleDateFormat("yyyyMMddHHmmss").format(importAckDateTime)+"'/>";
        return msg;
	}
	
	public String asAckXML(){
        String msg ="<data serverid='"+getServerId()
    	+"' objectid='"+getObjectId()
    	+"' ackdatetime='"+new SimpleDateFormat("yyyyMMddHHmmss").format(ackDateTime)+"'/>";
        return msg;
	}
	
	public static void sendImportAck(Vector messages) throws MessagingException{
		Hashtable destinations = new Hashtable();
		Hashtable acks = new Hashtable();
        String msgid=new SimpleDateFormat("yyyyMMddHHmmss").format(new Date());
		for(int n=0;n<messages.size();n++){
			ImportMessage importMessage =(ImportMessage)messages.elementAt(n);
			importMessage.setImportAckDateTime(new java.util.Date());
	        String to = importMessage.getRef();
	        String content = (String)destinations.get(to);
	        if(content==null){
	        	destinations.put(to, "");
	        }
	        destinations.put(to, (String)destinations.get(to)+importMessage.asImportAckXML());
	        Vector ackmsgs = (Vector)acks.get(to);
	        if(ackmsgs==null){
	        	acks.put(to, new Vector());
	        }
	        ((Vector)acks.get(to)).add(importMessage);
		}
		Enumeration<String> e = destinations.keys();
		while(e.hasMoreElements()){
			String to = (String)e.nextElement();
			if(to.split("\\:").length==2 && to.split("\\:")[0].equalsIgnoreCase("SMTP")){
				String content="<?xml version='1.0' encoding='UTF-8'?><message type='datacenter.importack' id='"+msgid+"'>"+destinations.get(to)+"</message>";
				SMTPSender.sendImportAckMessage(content, to.split("\\:")[1],msgid);
				//We only set the importAckDateTime if transmission of Ack messages was successfull
				Vector ackmsgs = (Vector)acks.get(to);
				for(int n=0;n<ackmsgs.size();n++){
					ImportMessage importMessage = (ImportMessage)ackmsgs.elementAt(n);
					importMessage.updateImportAckDateTime(importMessage.getImportAckDateTime());
				}
			}
		}
	}
	
	public static void sendAck(Vector messages) throws MessagingException{
		Hashtable destinations = new Hashtable();
		Hashtable acks = new Hashtable();
        String msgid=new SimpleDateFormat("yyyyMMddHHmmss").format(new Date());
		for(int n=0;n<messages.size();n++){
			ImportMessage importMessage =(ImportMessage)messages.elementAt(n);
			importMessage.setAckDateTime(new java.util.Date());
	        String to = importMessage.getRef();
	        String content = (String)destinations.get(to);
	        if(content==null){
	        	destinations.put(to, "");
	        }
	        destinations.put(to, (String)destinations.get(to)+importMessage.asAckXML());
	        Vector ackmsgs = (Vector)acks.get(to);
	        if(ackmsgs==null){
	        	acks.put(to, new Vector());
	        }
	        ((Vector)acks.get(to)).add(importMessage);
		}
		Enumeration<String> e = destinations.keys();
		while(e.hasMoreElements()){
			String to = (String)e.nextElement();
			if(to.split("\\:").length==2 && to.split("\\:")[0].equalsIgnoreCase("SMTP")){
				String content="<?xml version='1.0' encoding='UTF-8'?><message type='datacenter.ack' id='"+msgid+"'>"+destinations.get(to)+"</message>";
				SMTPSender.sendAckMessage(content, to.split("\\:")[1],msgid);
				//We only set the ackDateTime if transmission of Ack messages was successfull
				Vector ackmsgs = (Vector)acks.get(to);
				for(int n=0;n<ackmsgs.size();n++){
					ImportMessage importMessage = (ImportMessage)ackmsgs.elementAt(n);
					importMessage.updateAckDateTime(importMessage.getAckDateTime());
				}
			}
		}
	}
	
	public ImportMessage(String xml){
        SAXReader reader = new SAXReader(false);
        try {
			Document document = reader.read(new ByteArrayInputStream(xml.getBytes("UTF-8")));
			Element root = document.getRootElement();
			setType(root.attributeValue("type"));
			Element data = root.element("data");
			if(data!=null){
				setServerId(Integer.parseInt(data.attributeValue("serverid")));
				setObjectId(Integer.parseInt(data.attributeValue("objectid")));
				setMessageId(data.attributeValue("parameterid"));
				setCreateDateTime(new SimpleDateFormat("yyyyMMddHHmmss").parse(data.attributeValue("createdatetime")));
				setSentDateTime(new SimpleDateFormat("yyyyMMddHHmmss").parse(data.attributeValue("sentdatetime")));
				setData(data.getText());
			}
			
		} catch (Exception e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
	}

	public ImportMessage(Element data){
        try {
			setServerId(Integer.parseInt(data.attributeValue("serverid")));
			setObjectId(Integer.parseInt(data.attributeValue("objectid")));
			setMessageId(data.attributeValue("parameterid"));
			setCreateDateTime(new SimpleDateFormat("yyyyMMddHHmmss").parse(data.attributeValue("createdatetime")));
			setSentDateTime(new SimpleDateFormat("yyyyMMddHHmmss").parse(data.attributeValue("sentdatetime")));
			setData(data.getText());
		} catch (Exception e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
	}

	
}
