package be.openclinic.datacenter;

import java.io.ByteArrayInputStream;
import java.io.IOException;
import java.io.UnsupportedEncodingException;
import java.sql.SQLException;
import java.util.Date;
import java.util.Iterator;
import java.util.Properties;
import java.util.Vector;

import javax.mail.*;
import javax.mail.internet.InternetAddress;
import javax.mail.internet.MimeMessage;

import org.dom4j.Document;
import org.dom4j.DocumentException;
import org.dom4j.Element;
import org.dom4j.io.SAXReader;

import be.mxs.common.util.db.MedwanQuery;
import be.mxs.common.util.system.Debug;

public class IMAP4Receiver extends Receiver {

	public void receive(){
        String host = MedwanQuery.getInstance().getConfigString("datacenterPOP3Host","localhost");
        String username = MedwanQuery.getInstance().getConfigString("datacenterPOP3Username","");
        String password = MedwanQuery.getInstance().getConfigString("datacenterPOP3Password","");
    	Properties props=System.getProperties();
    	//props.put("mail.debug","true");
        Session session = Session.getInstance(props, null);
	    try {
	    	Store store = session.getStore("imap");
			store.connect(host, username, password);
		    Folder folder = store.getFolder("INBOX");
		    folder.open(Folder.READ_WRITE);
		    Message message[] = folder.getMessages();
		    for (int i=0, n=message.length; i<n; i++) {
		    	if(message[i].getSubject().startsWith("datacenter.content")){
			    	//Store the message in the oc_imports database here and delete it if successful
		            SAXReader reader = new SAXReader(false);
		            try{
						Document document = reader.read(new ByteArrayInputStream(message[i].getContent().toString().getBytes("UTF-8")));
						Element root = document.getRootElement();
						Iterator msgs = root.elementIterator("data");
						Vector ackMessages=new Vector();
						while(msgs.hasNext()){
							Element data = (Element)msgs.next();
					    	ImportMessage msg = new ImportMessage(data);
							msg.setType(root.attributeValue("type"));
					    	msg.setReceiveDateTime(new java.util.Date());
					    	msg.setRef("SMTP:"+message[i].getFrom()[0]);
					    	try {
								msg.store();
						    	message[i].setFlag(Flags.Flag.DELETED, true);
						    	ackMessages.add(msg);
							} catch (SQLException e) {
								// TODO Auto-generated catch block
								e.printStackTrace();
							}
						}
				    	//Set ackDateTime for all received messages in mail
						ImportMessage.sendAck(ackMessages);
		            }
		            catch(MessagingException e){
		            	Debug.println(e.getMessage());
		            } catch (UnsupportedEncodingException e) {
		    			// TODO Auto-generated catch block
		    			e.printStackTrace();
		    		} catch (DocumentException e) {
		    			// TODO Auto-generated catch block
		    			e.printStackTrace();
		    		} catch (IOException e) {
		    			// TODO Auto-generated catch block
		    			e.printStackTrace();
		    		}
		    	}
		    	else if (message[i].getSubject().startsWith("datacenter.ack")){
		            SAXReader reader = new SAXReader(false);
		            try{
			            Document document = reader.read(new ByteArrayInputStream(message[i].getContent().toString().getBytes("UTF-8")));
						Element root = document.getRootElement();
						Iterator msgs = root.elementIterator("data");
						while(msgs.hasNext()){
							Element data = (Element)msgs.next();
					    	AckMessage msg = new AckMessage(data);
					    	if(msg.serverId==MedwanQuery.getInstance().getConfigInt("datacenterServerId",0)){
					    		ExportMessage.updateAckDateTime(msg.getObjectId(), msg.getAckDateTime());
					    	}
					    	else {
					    		//TODO: send warning to system administrator 
					    		//ACK received addressed to other server!
					    		String error="Server "+MedwanQuery.getInstance().getConfigInt("datacenterServerId",0)+" received SMTP ACK message intended for server "+msg.getServerId();
					    		SMTPSender.sendSysadminMessage(error, msg);
					    	}
						}
				    	message[i].setFlag(Flags.Flag.DELETED, true);
		            }
		            catch(MessagingException e){
		            	Debug.println(e.getMessage());
		            } catch (UnsupportedEncodingException e) {
		    			// TODO Auto-generated catch block
		    			e.printStackTrace();
		    		} catch (DocumentException e) {
		    			// TODO Auto-generated catch block
		    			e.printStackTrace();
		    		} catch (IOException e) {
		    			// TODO Auto-generated catch block
		    			e.printStackTrace();
		    		}
		    	}
		    	else if (message[i].getSubject().startsWith("datacenter.importack")){
		            SAXReader reader = new SAXReader(false);
		            try{
			            Document document = reader.read(new ByteArrayInputStream(message[i].getContent().toString().getBytes("UTF-8")));
						Element root = document.getRootElement();
						Iterator msgs = root.elementIterator("data");
						while(msgs.hasNext()){
							Element data = (Element)msgs.next();
					    	ImportAckMessage msg = new ImportAckMessage(data);
					    	if(msg.serverId==MedwanQuery.getInstance().getConfigInt("datacenterServerId",0)){
					    		ExportMessage.updateImportAckDateTime(msg.getObjectId(), msg.getImportAckDateTime());
					    		ExportMessage.updateImportDateTime(msg.getObjectId(), msg.getImportDateTime());
					    		ExportMessage.updateErrorCode(msg.getObjectId(), msg.getError());
					    	}
					    	else {
					    		//TODO: send warning to system administrator 
					    		//Import ACK received addressed to other server!
					    		String error="Server "+MedwanQuery.getInstance().getConfigInt("datacenterServerId",0)+" received SMTP Import ACK message intended for server "+msg.getServerId();
					    		SMTPSender.sendSysadminMessage(error, msg);
					    	}
						}
				    	message[i].setFlag(Flags.Flag.DELETED, true);
		            }
		            catch(MessagingException e){
		            	Debug.println(e.getMessage());
		            } catch (UnsupportedEncodingException e) {
		    			// TODO Auto-generated catch block
		    			e.printStackTrace();
		    		} catch (DocumentException e) {
		    			// TODO Auto-generated catch block
		    			e.printStackTrace();
		    		} catch (IOException e) {
		    			// TODO Auto-generated catch block
		    			e.printStackTrace();
		    		}
		    	}
		    }
	
		    // Close connection 
		    folder.close(true);
		    store.close();
		} catch (MessagingException e1) {
			// TODO Auto-generated catch block
			e1.printStackTrace();
		}
	}
}
