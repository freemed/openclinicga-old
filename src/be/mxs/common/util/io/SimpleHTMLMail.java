package be.mxs.common.util.io;

import javax.mail.*;
import javax.mail.internet.*;

import java.util.Properties;

class SimpleHTMLMail {
    public static void main(String[] args) throws Exception{
      Properties props = new Properties();
      props.setProperty("mail.transport.protocol", "smtp");
      props.setProperty("mail.host", "mail.mxs.be");
      props.setProperty("mail.user", "frank.verbeke");
      props.setProperty("mail.password", "rodewijnmetballetjes");

      Session mailSession = Session.getDefaultInstance(props, null);
      Transport transport = mailSession.getTransport();

      MimeMessage message = new MimeMessage(mailSession);
      message.setSubject("Testing javamail html");
      message.setHeader("content-type", "text/html; charset=ISO-8859-1"); 
      message.setContent
         ("This is a test <b>HOWTO<b>", "text/html; charset=ISO-8859-1");
      message.addRecipient(Message.RecipientType.TO,
         new InternetAddress("frank.verbeke@mxs.be"));

      transport.connect();
      transport.sendMessage(message,
         message.getRecipients(Message.RecipientType.TO));
      transport.close();
    }
}