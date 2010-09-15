<%@page import="sun.net.smtp.SmtpClient,
                be.mxs.common.util.db.MedwanQuery,
                java.io.PrintStream,
                be.mxs.common.util.system.Debug,
                javax.mail.*,
                javax.mail.internet.*,
                java.util.Properties,
                javax.activation.*"%>
<%!
    public void sendMail(String sClient, String sFrom, String sTo, String sSubject, String sMessage) {
        //Debug.println("Sending via spd "+sTo+","+sFrom+","+sSubject+","+sMessage);
        if ((MedwanQuery.getInstance().getConfigString("MailProgram")+"").equalsIgnoreCase("spd_send_mail")){
             MedwanQuery.getInstance().spdSendMail(sTo,sFrom,sSubject,sMessage);
        }
        try  {
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
        }
        catch(Exception e)  {
            Debug.println(e.getMessage());
        }
    }

    public void sendMail(String smtpServer,String sFrom, String sTo, String sSubject, String sMessage,String sAttachment,String sFileName) {
        try  {
            Properties props = System.getProperties();
            props.put("mail.smtp.host", smtpServer);
            Session session = Session.getDefaultInstance(props, null);
            Message msg = new MimeMessage(session);

            msg.setFrom(new InternetAddress(sFrom));
            msg.setRecipients(Message.RecipientType.TO,InternetAddress.parse(sTo, false));
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
        }
        catch(Exception e)  {
            e.printStackTrace();
        }
    }
%>
