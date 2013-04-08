package be.openclinic.datacenter;

import java.util.*;
import javax.mail.*;
import javax.mail.internet.*;  

import be.mxs.common.util.db.MedwanQuery;

public class SMTPAckSender {
	
	public void send(ImportMessage importMessage) throws AddressException, MessagingException{
		String host = MedwanQuery.getInstance().getConfigString("datacenterSMTPHost","localhost");
        String from = MedwanQuery.getInstance().getConfigString("datacenterSMTPFrom","");
        String to = importMessage.getRef().split("\\:")[1];
	    Properties properties = System.getProperties(); 
	    properties.setProperty("mail.smtp.localhost", "127.0.0.1"); 
	    properties.setProperty("mail.smtp.host", host); 
	    Session session = Session.getDefaultInstance(properties); 
	    MimeMessage message = new MimeMessage(session); 
	    message.setFrom(new InternetAddress(from));
	    message.addRecipient(Message.RecipientType.TO, new InternetAddress(to));
	    message.setSubject("datacenter.ack: "+importMessage.getServerId()+"."+importMessage.getObjectId()); 
	    //Create message content
	    Date sentDateTime=new Date();
	    message.setText(importMessage.asAckXML()); 
	    Transport.send(message);
	}

}
