package be.mxs.common.util.system;

import be.mxs.common.util.db.MedwanQuery;
import sun.net.smtp.SmtpClient;

import javax.mail.*;
import javax.mail.internet.MimeMessage;
import javax.mail.internet.InternetAddress;
import javax.mail.internet.MimeBodyPart;
import javax.mail.internet.MimeMultipart;
import javax.mail.internet.AddressException;
import javax.activation.FileDataSource;
import javax.activation.DataHandler;
import java.io.PrintStream;
import java.util.Properties;

public class Mail {
    static public void sendMail(String sClient, String sFrom, String sTo, String sSubject, String sMessage)
        throws Exception {

        if ((MedwanQuery.getInstance().getConfigString("MailProgram")+"").equalsIgnoreCase("spd_send_mail")){
            MedwanQuery.getInstance().spdSendMail(sTo,sFrom,sSubject,sMessage);

            if(Debug.enabled){
                Debug.println("*** Mail sent via SPD ***");
                Debug.println("From : "+sFrom);
                Debug.println("To   : "+sTo);
                Debug.println("*************************");
            }
        }
        else {
            SmtpClient client = new SmtpClient(sClient);
            client.from(sFrom);
            client.to(sTo);

            PrintStream message = client.startMessage();
            message.println("From: "+sFrom);
            message.println("To: "+sTo);
            message.println("Subject: "+sSubject);
            message.println();
            message.println(sMessage);

            client.closeServer();
            message = null;
            client = null;

            if(Debug.enabled){
                Debug.println("*** Mail sent ***");
                Debug.println("From   : "+sFrom);
                Debug.println("To     : "+sTo);
                Debug.println("Server : "+sClient);
                Debug.println("*****************");
            }
        }
    }

    static public void sendMail(String smtpServer, String sFrom, String sTo, String sSubject, String sMessage, String sAttachment, String sFileName)
        throws AddressException, MessagingException {

        Properties props = System.getProperties();
        props.put("mail.smtp.localhost", "127.0.0.1"); 
        props.put("mail.smtp.host", smtpServer);
        Session session = Session.getDefaultInstance(props, null);
        Message msg = new MimeMessage(session);

        msg.setFrom(new InternetAddress(sFrom));
        msg.setRecipients(Message.RecipientType.TO,InternetAddress.parse(sTo, false)); // false : simple email addresses separated by spaces are also allowed
        msg.setSentDate(new java.util.Date());
        msg.setSubject(sSubject);

        BodyPart messageBodyPart = new MimeBodyPart();
        messageBodyPart.setText(sMessage);
        Multipart multipart = new MimeMultipart();
        multipart.addBodyPart(messageBodyPart);
        messageBodyPart = new MimeBodyPart();
        javax.activation.DataSource source = new FileDataSource(sAttachment);
        messageBodyPart.setDataHandler(new DataHandler(source));
        messageBodyPart.setFileName(sFileName);
        multipart.addBodyPart(messageBodyPart);

        msg.setContent(multipart);

        Transport.send(msg);

        if(Debug.enabled){
            Debug.println("*** Mail sent ***");
            Debug.println("From   : "+sFrom);
            Debug.println("To     : "+sTo);
            Debug.println("Server : "+smtpServer);
            Debug.println("*****************");
        }
    }
}
