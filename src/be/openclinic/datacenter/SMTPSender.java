package be.openclinic.datacenter;

import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.*;
import javax.mail.*;
import javax.mail.internet.*;  

import be.mxs.common.util.db.MedwanQuery;
import be.mxs.common.util.system.Debug;

public class SMTPSender extends Sender {

	public void send() {
		
        try{
			String lastSMTPSenderActivity = MedwanQuery.getInstance().getConfigString("lastDatacenterSMTPSenderActivity","0");
			Debug.println("...: "+lastSMTPSenderActivity+" < "+getDeadline());
			if(lastSMTPSenderActivity.equalsIgnoreCase("0") || new SimpleDateFormat("yyyyMMddHHmmss").parse(lastSMTPSenderActivity).before(getDeadline())){
		 		loadMessages();
		 		if(messages.size()>0){
			 		String host = MedwanQuery.getInstance().getConfigString("datacenterSMTPHost","localhost");
			        String from = MedwanQuery.getInstance().getConfigString("datacenterSMTPFrom","");
			        String to = MedwanQuery.getInstance().getConfigString("datacenterSMTPTo","server.mxs@globalhealthbarometer.net");
			        String datacenterServerId=MedwanQuery.getInstance().getConfigString("datacenterServerId","");
			        String msgid=new SimpleDateFormat("yyyyMMddHHmmss").format(new Date());
			 		//Compose mail content
			        Date sentDateTime=new Date();
			 		String messageContent="<?xml version='1.0' encoding='UTF-8'?><message type='datacenter.content' id='"+msgid+"'>";
					for (int n=0;n<messages.size();n++){
						ExportMessage exportMessage = (ExportMessage) messages.elementAt(n);
				        exportMessage.setServerId(Integer.parseInt(datacenterServerId));
				        exportMessage.setSentDateTime(sentDateTime);
				        messageContent=messageContent+exportMessage.asXML();
					}
					messageContent=messageContent+"</message>";
					//Send mail
			        Properties properties = System.getProperties(); 
			        properties.setProperty("mail.smtp.localhost", "127.0.0.1"); 
			        properties.setProperty("mail.smtp.host", host); 
			        Session session = Session.getDefaultInstance(properties); 
			        MimeMessage message = new MimeMessage(session); 
			        message.setFrom(new InternetAddress(from));
			        message.addRecipient(Message.RecipientType.TO, new InternetAddress(to));
			        message.setSubject("datacenter.content: "+msgid); 
			        message.setText(messageContent); 
			        Debug.println("------------------------------------------------------------------------------------------");
			        Debug.println("sending message from host "+properties.getProperty("mail.smtp.localhost")+" to host "+properties.getProperty("mail.smtp.host"));
			        Debug.println("-- Message from   : "+from);
			        Debug.println("-- Message to     : "+to);
			        Debug.println("-- Server id      : "+datacenterServerId);
			        Debug.println("-- Message id     : "+msgid);
			        Debug.println("-- Message subject: "+message.getSubject());
			        Debug.println("-- Message content: "+messageContent);
			        Transport.send(message);
					for (int n=0;n<messages.size();n++){
						ExportMessage exportMessage = (ExportMessage) messages.elementAt(n);
				        //Update message sentDateTime
				        exportMessage.updateSentDateTime(sentDateTime);
					}
			        Debug.println("-- Message successfully sent");
			        Debug.println("------------------------------------------------------------------------------------------");
		 		}
		        MedwanQuery.getInstance().setConfigString("lastDatacenterSMTPSenderActivity",new SimpleDateFormat("yyyyMMddHHmmss").format(new Date()));
			}
        }
        catch(MessagingException e){
        	Debug.println(e.getMessage());
        	e.printStackTrace();
        } catch (NumberFormatException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		} catch (ParseException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
	}
	
	public static void sendAckMessage(String messageContent, String to, String msgid) throws MessagingException{
        String host = MedwanQuery.getInstance().getConfigString("datacenterSMTPHost","localhost");
        String from = MedwanQuery.getInstance().getConfigString("datacenterSMTPFrom","");
        Properties properties = System.getProperties(); 
        properties.setProperty("mail.smtp.host", host); 
        Session session = Session.getDefaultInstance(properties); 
        MimeMessage message = new MimeMessage(session); 
        message.setFrom(new InternetAddress(from));
        message.addRecipient(Message.RecipientType.TO, new InternetAddress(to));
        message.setSubject("datacenter.ack: "+msgid); 
        //Create message content
        message.setText(messageContent); 
        Transport.send(message);
	}

	public static void sendImportAckMessage(String messageContent, String to, String msgid) throws MessagingException{
        String host = MedwanQuery.getInstance().getConfigString("datacenterSMTPHost","localhost");
        String from = MedwanQuery.getInstance().getConfigString("datacenterSMTPFrom","");
        Properties properties = System.getProperties(); 
        properties.setProperty("mail.smtp.host", host); 
        Session session = Session.getDefaultInstance(properties); 
        MimeMessage message = new MimeMessage(session); 
        message.setFrom(new InternetAddress(from));
        message.addRecipient(Message.RecipientType.TO, new InternetAddress(to));
        message.setSubject("datacenter.importack: "+msgid); 
        //Create message content
        message.setText(messageContent); 
        Transport.send(message);
	}

	public static void sendImportAckMessage(ImportMessage importMessage) throws MessagingException{
        String host = MedwanQuery.getInstance().getConfigString("datacenterSMTPHost","localhost");
        String from = MedwanQuery.getInstance().getConfigString("datacenterSMTPFrom","");
        String to = importMessage.getRef().split("\\:")[1];
        Properties properties = System.getProperties(); 
        properties.setProperty("mail.smtp.host", host); 
        Session session = Session.getDefaultInstance(properties); 
        MimeMessage message = new MimeMessage(session); 
        message.setFrom(new InternetAddress(from));
        message.addRecipient(Message.RecipientType.TO, new InternetAddress(to));
        message.setSubject("datacenter.importack: "+importMessage.getServerId()+"."+importMessage.getObjectId()); 
        //Create message content
        message.setText(importMessage.asImportAckXML()); 
        Transport.send(message);
	}

	public static void sendSysadminMessage(String s, DatacenterMessage msg) throws MessagingException{
        String host = MedwanQuery.getInstance().getConfigString("datacenterSMTPHost","localhost");
        String to = MedwanQuery.getInstance().getConfigString("datacenterSysAdminMailAddress","frank.verbeke@mxs.be");
        String from = MedwanQuery.getInstance().getConfigString("datacenterSMTPFrom","");
        Properties properties = System.getProperties(); 
        properties.setProperty("mail.smtp.host", host); 
        Session session = Session.getDefaultInstance(properties); 
        MimeMessage message = new MimeMessage(session); 
        message.setFrom(new InternetAddress(from));
        message.addRecipient(Message.RecipientType.TO, new InternetAddress(to));
        message.setSubject("datacenter.error: "+msg.getServerId()+"."+msg.getObjectId()); 
        message.setText(s); 
        Transport.send(message);
	}

}
