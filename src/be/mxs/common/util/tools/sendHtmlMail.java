package be.mxs.common.util.tools;

import javax.mail.*;
import javax.mail.internet.*;

import java.util.Properties;

import javax.activation.*; // Needed for Email with Images // Attachments .DataSource

import be.mxs.common.util.db.MedwanQuery;
import be.mxs.common.util.system.Debug;

public class sendHtmlMail {
	
	static public void sendSimpleMail(String smtpServer, String sFrom, String sTo, String sSubject, String sMessage)
			throws AddressException, MessagingException {    	

        Properties props = new Properties();
        props.setProperty("mail.transport.protocol", "smtp");
        props.setProperty("mail.host", smtpServer); //props.setProperty("mail.user", ""); //props.setProperty("mail.password", "");

        Session mailSession = Session.getDefaultInstance(props, null);
        mailSession.setDebug(true);
        //Transport transport = mailSession.getTransport();
        Transport transport = mailSession.getTransport("smtp");

        MimeMessage message = new MimeMessage(mailSession);
        message.setSubject(sSubject);
        message.setFrom(new InternetAddress(sFrom));
        
        message.setHeader("content-type: text/plain", "charset=ISO-8859-1");
        //message.setHeader("content-type: text/html", "charset=ISO-8859-1"); 
        //This works!! Output is: Content-Type: text/html; charset=UTF-8. Content-Transfer-Encoding: quoted-printable. content-type: text/html: charset=ISO-8859-1
 
        message.setContent(sMessage, "text/plain");
        message.setRecipients(Message.RecipientType.TO, InternetAddress.parse(sTo,false));

        transport.connect();
        transport.sendMessage(message, message.getRecipients(Message.RecipientType.TO));
        transport.close();        
        //transport.sendMessage(message, message.getAllRecipients());               
	}

	static public void sendMail(String smtpServer, String sFrom, String sTo, String sSubject, String sMessage)
			throws AddressException, MessagingException {    	
		//Send HTML mail without embedded images
        Properties props = new Properties();
        props.setProperty("mail.transport.protocol", "smtp");
        props.setProperty("mail.host", smtpServer); //props.setProperty("mail.user", ""); //props.setProperty("mail.password", "");

        Session mailSession = Session.getDefaultInstance(props, null);
        mailSession.setDebug(true);
        //Transport transport = mailSession.getTransport();
        Transport transport = mailSession.getTransport("smtp");

        MimeMessage message = new MimeMessage(mailSession);
        message.setSubject(sSubject);
        message.setFrom(new InternetAddress(sFrom));
        
        message.setHeader("content-type", "text/html; charset=ISO-8859-1"); 
        //message.setHeader("content-type: text/html", "charset=ISO-8859-1"); 
        //This works!! Output is: Content-Type: text/html; charset=UTF-8. Content-Transfer-Encoding: quoted-printable. content-type: text/html: charset=ISO-8859-1
 
        message.setContent(sMessage, "text/html");
        message.setRecipients(Message.RecipientType.TO, InternetAddress.parse(sTo,false));

        transport.connect();
        transport.sendMessage(message, message.getRecipients(Message.RecipientType.TO));
        transport.close();        
        //transport.sendMessage(message, message.getAllRecipients());               
	}
	
	static public void sendEmailWithImages(String smtpServer, String sFrom, String sTo, String sSubject, String sMessage, String sImage) throws Exception{      		    	
	    	// * * The browser accesses these images just as if it were displaying an image in a Web page. Unfortunately, spammers have used this mechanism as a sneaky way to record who visits their site (and mark your email as valid). To protect your privacy, many Web-based (and other) email clients don't display images in HTML emails.
			//	An alternative to placing absolute URLs to images in your HTML is to include the images as attachments to the email. The HTML can reference the image in an attachment by using the protocol prefix cid: plus the content-id of the attachment.      		       
	        
	        Properties props = new Properties();
	        props.setProperty("mail.transport.protocol", "smtp");
	        props.setProperty("mail.host", smtpServer); //props.setProperty("mail.user", "myuser"); //props.setProperty("mail.password", "mypwd");
	
	        Session mailSession = Session.getDefaultInstance(props, null);
	        mailSession.setDebug(MedwanQuery.getInstance().getConfigString("Debug").equalsIgnoreCase("On"));
	        Transport transport = mailSession.getTransport();
	
	        MimeMessage message = new MimeMessage(mailSession);
	        message.setSubject(sSubject);
	        message.setFrom(new InternetAddress(sFrom));	  
	        message.setSentDate(new java.util.Date());
	        message.setRecipients(Message.RecipientType.TO, InternetAddress.parse(sTo,false));
	
	        // This HTML mail have to 2 part, the BODY and the embedded image       
	        MimeMultipart multipart = new MimeMultipart("related");
	
	        // first part  (the html)
	        BodyPart messageBodyPart = new MimeBodyPart();		
	        String htmlText = sMessage;	    //String htmlText = "<H1>Hello</H1>	<img src=\"cid:image\">";
	        //messageBodyPart.setHeader("content-type: text/html", "charset=ISO-8859-1")
	        message.setHeader("content-type", "text/html; charset=ISO-8859-1"); 
	        messageBodyPart.setContent(htmlText, "text/html");
	
	        // add it
	        multipart.addBodyPart(messageBodyPart);
	        
	        if(new java.io.File(sImage).exists()){
		        // second part (the image)
		        messageBodyPart = new MimeBodyPart();
		        DataSource fds = new FileDataSource(sImage);
		        messageBodyPart.setDataHandler(new DataHandler(fds));
		        messageBodyPart.setHeader("Content-ID","<image_logo>");
		
		        // add it
		        multipart.addBodyPart(messageBodyPart);
	        }
	
	        // put everything together
	        message.setContent(multipart);
	
	        transport.connect();
	        transport.sendMessage(message,
	            message.getRecipients(Message.RecipientType.TO));
	        transport.close();
    }
	//sendAttachEmail
    static public void sendAttachEmailWithImages(String smtpServer, String sFrom, String sTo, String sSubject, String sMessage, String sAttachment, String sFileName, String sLogo)
            throws AddressException, MessagingException {

        Properties props = new Properties();
        props.setProperty("mail.transport.protocol", "smtp");
        props.setProperty("mail.host", smtpServer); //props.setProperty("mail.user", "myuser"); //props.setProperty("mail.password", "mypwd");

        Session mailSession = Session.getDefaultInstance(props, null);
        mailSession.setDebug(true);
        Transport transport = mailSession.getTransport();

        MimeMessage message = new MimeMessage(mailSession);
        message.setSubject(sSubject);
        message.setFrom(new InternetAddress(sFrom));	  
        //message.setSentDate(new java.util.Date());
        message.setRecipients(Message.RecipientType.TO, InternetAddress.parse(sTo,false));

        // This HTML mail have to 2 part, the BODY and the embedded image       
        MimeMultipart multipart = new MimeMultipart("related");

        // first part  (the html)
        BodyPart messageBodyPart = new MimeBodyPart();	             
        String htmlText = sMessage;	    //String htmlText = "<H1>Hello</H1>	<img src=\"cid:image\">";
        //messageBodyPart.setHeader("content-type: text/html", "charset=ISO-8859-1");
        messageBodyPart.addHeader("content-type: text/html", "charset=ISO-8859-1");
        messageBodyPart.setContent(htmlText, "text/html");

        // add it
        multipart.addBodyPart(messageBodyPart);
   
        //second  part: (The Attachment)
        messageBodyPart = new MimeBodyPart();
        DataSource fdsAttach = new FileDataSource(sAttachment);
        messageBodyPart.setDataHandler(new DataHandler(fdsAttach));
        messageBodyPart.setFileName(sFileName);
       
        // add it
        multipart.addBodyPart(messageBodyPart);
        
        // third part (the image)
        messageBodyPart = new MimeBodyPart();
        DataSource fds = new FileDataSource(sLogo);
        messageBodyPart.setDataHandler(new DataHandler(fds));
        //messageBodyPart.setHeader("Content-ID","<image_logo>");
        messageBodyPart.addHeader("Content-ID","<image_logo>");

        // add it
        multipart.addBodyPart(messageBodyPart);

        // put everything together
        message.setContent(multipart);

        transport.connect();
        transport.sendMessage(message,
            message.getRecipients(Message.RecipientType.TO));
        transport.close();
        }
	
	//sendAttachEmail
    static public void sendAttachEmail(String smtpServer, String sFrom, String sTo, String sSubject, String sMessage, String sAttachment, String sFileName)
            throws AddressException, MessagingException {

        Properties props = new Properties();
        props.setProperty("mail.transport.protocol", "smtp");
        props.setProperty("mail.host", smtpServer); //props.setProperty("mail.user", "myuser"); //props.setProperty("mail.password", "mypwd");

        Session mailSession = Session.getDefaultInstance(props, null);
        mailSession.setDebug(true);
        Transport transport = mailSession.getTransport();

        MimeMessage message = new MimeMessage(mailSession);
        message.setSubject(sSubject);
        message.setFrom(new InternetAddress(sFrom));	  
        //message.setSentDate(new java.util.Date());
        message.setRecipients(Message.RecipientType.TO, InternetAddress.parse(sTo,false));

        // This HTML mail have to 2 part, the BODY and the embedded image       
        MimeMultipart multipart = new MimeMultipart("related");

        // first part  (the html)
        BodyPart messageBodyPart = new MimeBodyPart();	             
        String htmlText = sMessage;	    //String htmlText = "<H1>Hello</H1>	<img src=\"cid:image\">";
        //messageBodyPart.setHeader("content-type: text/html", "charset=ISO-8859-1");
        //messageBodyPart.addHeader("content-type: text/html", "charset=ISO-8859-1"); //This works on yahoo mail and in earlier mxs mail. now no more in MXS (attach is not visible
        
        //message.setHeader("content-type", "text/html; charset=ISO-8859-1"); //in yahoo ok. In MxS: Attachment is visible but error
        //Problem accessing /service/home/~/Transaction18112011-130314_Tid7259.html. Reason: us-ascii;
        
        
        
        messageBodyPart.setContent(htmlText, "text/html");

        // add it
        multipart.addBodyPart(messageBodyPart);
   
        //second  part: (The Attachment)
        messageBodyPart = new MimeBodyPart();
        DataSource fdsAttach = new FileDataSource(sAttachment);
        messageBodyPart.setDataHandler(new DataHandler(fdsAttach));
        messageBodyPart.setFileName(sFileName);
       
        // add it
        multipart.addBodyPart(messageBodyPart);
        
         // put everything together
        //message.setHeader("content-type", "text/html; charset=ISO-8859-1");
        message.setContent(multipart);

        transport.connect();
        transport.sendMessage(message,
            message.getRecipients(Message.RecipientType.TO));
        transport.close();
    }
	
    
    /* Multiple Images

Each image needs to be its own MimeBodyPart, break up this code,

// second part (the image)
messageBodyPart = new MimeBodyPart();
DataSource fds = new FileDataSource
  ("C:\\images\\cec_header_457.png");
DataSource fds1 = new FileDataSource
("C:\\images\\cec_header_420.png");
messageBodyPart.setDataHandler(new DataHandler(fds));
messageBodyPart.setDataHandler(new DataHandler(fds1));
messageBodyPart.addHeader("Content-ID","<image>");
messageBodyPart.addHeader("Content-ID","<senny>");
// add it
multipart.addBodyPart(messageBodyPart);

Into two multi parts, something like

// second part (the image)
messageBodyPart = new MimeBodyPart();
DataSource fds1 = new FileDataSource
("C:\\images\\cec_header_420.png");
messageBodyPart.setDataHandler(new DataHandler(fds1));
messageBodyPart.addHeader("Content-ID","<senny>");
// add it
multipart.addBodyPart(messageBodyPart);

messageBodyPart = new MimeBodyPart();
DataSource fds = new FileDataSource
  ("C:\\images\\cec_header_457.png");
messageBodyPart.setDataHandler(new DataHandler(fds));
messageBodyPart.addHeader("Content-ID","<image>");
// add it
multipart.addBodyPart(messageBodyPart);

	 * 
	 * 
	 * 
	 */
	 
}

