package be.openclinic.reporting;

import java.util.Date;
import java.util.Hashtable;
import java.util.Enumeration;
import java.util.Vector;
import java.text.*; 

import be.mxs.common.util.db.MedwanQuery;

import java.net.URLEncoder;
import java.sql.*;

import org.apache.commons.httpclient.HttpClient;
import org.apache.commons.httpclient.NameValuePair;
import org.apache.commons.httpclient.methods.PostMethod;

import be.mxs.common.util.system.HTMLEntities;
import be.mxs.common.util.system.ScreenHelper;
import be.openclinic.datacenter.SendSMS;

import net.admin.AdminPerson;
import be.mxs.common.util.tools.sendHtmlMail;
import be.mxs.common.util.tools.ProcessFiles;

import be.openclinic.medical.*;
import be.mxs.common.model.vo.healthrecord.*;
import be.dpms.medwan.common.model.vo.administration.PersonVO;


public class LabresultsNotifier {
	
	private Date lastResultsCheck;
	
	public void setLastNotifiedResult(Date date){		
		String sDate = new SimpleDateFormat("yyyyMMddHHmmssSSS").format(date);
		MedwanQuery.getInstance().setConfigString("lastNotifiedLabResult", sDate);			
	}
	
	public Date getLastNotifiedResult(){
		String sDate = MedwanQuery.getInstance().getConfigString("lastNotifiedLabResult"); 
		if (sDate == ""){
			sDate = new SimpleDateFormat("yyyyMMddHHmmssSSS").format(new Date(new Date().getTime()-24*3600*1000));
		}
		
		Date dDate=null;
		try {
			try { 
				dDate = new SimpleDateFormat("yyyyMMddHHmmssSSS").parse(sDate);
			} catch (ParseException e) {
				dDate = new SimpleDateFormat("yyyyMMddHHmmss").parse(sDate);
			}		
			return dDate;
			
		} catch (ParseException e) {
			//e.printStackTrace();
			return new Date(new Date().getTime()-24*3600*1000);
		}		
	}
	
	public Vector findNewLabs() throws SQLException{ 		
		Vector vAnalysesToNotify = new Vector();
				
		String sQuery = "select * from requestedlabanalyses "  +
						" where resultvalue is not null and resultvalue <> ''" +
						" and finalvalidationdatetime is not null And finalvalidationdatetime > ? And finalvalidationdatetime <= ? " +  
						" order by analysiscode";
		
		Connection conn = MedwanQuery.getInstance().getOpenclinicConnection();
		PreparedStatement ps = conn.prepareStatement(sQuery);							
		ps.setTimestamp(1, new Timestamp(getLastNotifiedResult().getTime()));
		ps.setTimestamp(2, new Timestamp(new java.util.Date().getTime()));			
		
		ResultSet rs = ps.executeQuery();
					
		while(rs.next()){
			// Call the constructor to set the values
			RequestedLabAnalysis requestedLabAnalysis = new RequestedLabAnalysis(rs.getString("serverId"), rs.getString("transactionId"), rs.getString("patientId"), rs.getString("analysisCode"), rs.getString("comment"), rs.getString("resultValue"), rs.getString("resultUnit"), rs.getString("resultModifier"), rs.getString("resultComment"), rs.getString("resultRefMax"), rs.getString("resultRefMin"), rs.getString("resultUserId"), rs.getDate("resultDate"), rs.getString("resultProvisional"),new Date(rs.getTimestamp("finalvalidationdatetime").getTime()));
			
			vAnalysesToNotify.add(requestedLabAnalysis);					
		}			
		
		rs.close();
		ps.close();
		conn.close();
		
		return vAnalysesToNotify;		
	}

	public void sendNewLabs(){
		String sSendMode = "htmlmail";
		sendNewLabs(sSendMode);
	}
	
	public void sendNewLabs(String sSendMode){
		TransactionVO transactionVO; 
		String sLanguage;
		Hashtable transactionlanguages = new Hashtable();

		try {
			Hashtable htLabsToSendEmail = new Hashtable();	 		
			Hashtable htLabsToSendSMS = new Hashtable();
			Vector vNewLabs = (Vector)findNewLabs();	
			lastResultsCheck=null;
			for (int i=0; i<vNewLabs.size(); i++){
				RequestedLabAnalysis rqLabAnalysis = (RequestedLabAnalysis)vNewLabs.elementAt(i);				
				if(lastResultsCheck==null || lastResultsCheck.before(rqLabAnalysis.getFinalvalidationdatetime())){
					lastResultsCheck = rqLabAnalysis.getFinalvalidationdatetime();				
				}
				LabAnalysis la = LabAnalysis.getLabAnalysisByLabcode(rqLabAnalysis.getAnalysisCode()); 
				String sSMSValue = rqLabAnalysis.getNotifyBySMS();
				String emailValue =  rqLabAnalysis.getNotifyByEmail(); 	
				
				String result;
				if (sSMSValue != null){ 				
                	String normal = rqLabAnalysis.getResultModifier();
                	if(normal.length()==0){
                		String min =rqLabAnalysis.getResultRefMin();
                		String max =rqLabAnalysis.getResultRefMax();
						try{
	                        double iResult = Double.parseDouble(rqLabAnalysis.getResultValue().replaceAll(",", "\\."));
	                        double iMin = Double.parseDouble(min.replaceAll(",", "\\."));
	                        double iMax = Double.parseDouble(max.replaceAll(",", "\\."));
	
	                        if ((iResult >= iMin)&&(iResult <= iMax)){
	                            normal = "";
	                        }
	                        else {
	                            double iAverage = (iMax-iMin);
	
	                            if (iResult > iMax+iAverage*2){
	                                normal = "+++";
	                            }
	                            else if (iResult > iMax + iAverage){
	                                normal = "++";
	                            }
	                            else if (iResult > iMax){
	                                normal = "+";
	                            }
	                            else if (iResult < iMin - iAverage*2){
	                                normal = "---";
	                            }
	                            else if (iResult < iMin - iAverage){
	                                normal = "--";
	                            }
	                            else if (iResult < iMin){
	                                normal = "-";
	                            }
	                        }
                    	}
                    	catch(Exception e2){
                    		//e2.printStackTrace();
                    	}
                	}
					if(transactionlanguages.get(rqLabAnalysis.getTransactionId())!=null){
						sLanguage=(String)transactionlanguages.get(rqLabAnalysis.getTransactionId());
					}
					else{
						transactionVO = MedwanQuery.getInstance().loadTransaction(MedwanQuery.getInstance().getConfigInt("serverId"), Integer.parseInt(rqLabAnalysis.getTransactionId())); 				
						sLanguage=transactionVO.getUser().personVO.language; 
						transactionlanguages.put(transactionVO.getTransactionId()+"",sLanguage); 
					}		
					if(sLanguage==null || sLanguage.equalsIgnoreCase("")){
						sLanguage=MedwanQuery.getInstance().getConfigString("defaultBrokerLanguage","FR");
					}
					String sl =MedwanQuery.getInstance().getLabel("labanalysis.short", la.getLabId()+"", sLanguage);
					if(sl.equalsIgnoreCase(la.getLabId()+"")){
						sl=MedwanQuery.getInstance().getLabel("labanalysis", la.getLabId()+"", sLanguage);
					}
					result =  sl + ": " + rqLabAnalysis.getResultValue()+" "+rqLabAnalysis.getResultUnit();					
					
					if(htLabsToSendSMS.get(rqLabAnalysis.getTransactionId())==null){
						htLabsToSendSMS.put(rqLabAnalysis.getTransactionId(), result+" "+normal+"\n");
					}
					else {
						htLabsToSendSMS.put(rqLabAnalysis.getTransactionId(), (String)htLabsToSendSMS.get(rqLabAnalysis.getTransactionId())+result+" "+normal+"\n");
					}						
				}	
				if ( emailValue != null){ 					
					if(transactionlanguages.get(rqLabAnalysis.getTransactionId())!=null){
						sLanguage=(String)transactionlanguages.get(rqLabAnalysis.getTransactionId());
					}
					else{
						transactionVO = MedwanQuery.getInstance().loadTransaction(MedwanQuery.getInstance().getConfigInt("serverId"), Integer.parseInt(rqLabAnalysis.getTransactionId())); 						
						sLanguage=transactionVO.getUser().personVO.language; 
						transactionlanguages.put(transactionVO.getTransactionId()+"",sLanguage); 
					}
					if(sLanguage==null || sLanguage.equalsIgnoreCase("")){
						sLanguage=MedwanQuery.getInstance().getConfigString("defaultBrokerLanguage","FR");
					}
					if (sSendMode == "htmlmail" || sSendMode == "attachedmail"){
                    	String normal = rqLabAnalysis.getResultModifier();
                    	if(normal.length()==0){
                    		String min =rqLabAnalysis.getResultRefMin();
                    		String max =rqLabAnalysis.getResultRefMax();
							try{
		                        double iResult = Double.parseDouble(rqLabAnalysis.getResultValue().replaceAll(",", "\\."));
		                        double iMin = Double.parseDouble(min.replaceAll(",", "\\."));
		                        double iMax = Double.parseDouble(max.replaceAll(",", "\\."));
		
		                        if ((iResult >= iMin)&&(iResult <= iMax)){
		                            normal = "<font color='green'>n</font>";
		                        }
		                        else {
		                            double iAverage = (iMax-iMin);
		
		                            if (iResult > iMax+iAverage*2){
		                                normal = "<font color='red'>+++</font>";
		                            }
		                            else if (iResult > iMax + iAverage){
		                                normal = "<font color='red'>++</font>";
		                            }
		                            else if (iResult > iMax){
		                                normal = "<font color='red'>+</font>";
		                            }
		                            else if (iResult < iMin - iAverage*2){
		                                normal = "<font color='red'>---</font>";
		                            }
		                            else if (iResult < iMin - iAverage){
		                                normal = "<font color='red'>--</font>";
		                            }
		                            else if (iResult < iMin){
		                                normal = "<font color='red'>-</font>";
		                            }
		                        }
	                    	}
	                    	catch(Exception e2){
	                    		//e2.printStackTrace();
	                    	}
                    	}
                    	String references=rqLabAnalysis.getResultRefMin()+" - "+rqLabAnalysis.getResultRefMax();
                    	if(references.equalsIgnoreCase(" - ")){
                    		references="";
                    	}
						result =  "<tr><td>" + la.getLabcode() + "</td><td><b>" + MedwanQuery.getInstance().getLabel("labanalysis", la.getLabId()+"", sLanguage) 
								+  "</b></td><td><b> " + rqLabAnalysis.getResultValue()+"</b> "+rqLabAnalysis.getResultUnit()+"</td><td>"+references+"</td><td>"+normal+" </td></tr>";
					}
					else { 
						result =  la.getLabcode() + " " + MedwanQuery.getInstance().getLabel("labanalysis", la.getLabId()+"", sLanguage) 
								+  "  " + rqLabAnalysis.getResultValue()+" "+rqLabAnalysis.getResultUnit() +"\n";
					}
					
					if(htLabsToSendEmail.get(rqLabAnalysis.getTransactionId())==null){
						htLabsToSendEmail.put(rqLabAnalysis.getTransactionId(), result);
					}
					else {
						htLabsToSendEmail.put(rqLabAnalysis.getTransactionId(), (String)htLabsToSendEmail.get(rqLabAnalysis.getTransactionId())+result);
					}	
					
				}
			}
			if (htLabsToSendEmail.size() > 0){
				spoolEmail(htLabsToSendEmail, sSendMode); 
			}
			if (htLabsToSendSMS.size() > 0){
				spoolSMS(htLabsToSendSMS); 
			}
			if(lastResultsCheck!=null){
				setLastNotifiedResult(lastResultsCheck);				
			}
			sendSpooledMessages();
		} catch (SQLException e) {
			e.printStackTrace();
		}		
	}	

	
	public static String validateSMSValue(String sSMSValue){
		if (sSMSValue != null){
			if (!sSMSValue.matches("[+]?\\d+")){
				sSMSValue = null;
			}
		}
		return sSMSValue;
	}
	
	public static String validateEmailValue(String sEmailValue){
		if (sEmailValue != null){			
			if (!sEmailValue.matches("(\\w)+@(\\w)+[.].+")){ 
				sEmailValue = null;
			}			
		}
		return sEmailValue;
	}
	
	public void spoolSMS(Hashtable htLabsToSendTable){
		Enumeration<String> eTransationIds = htLabsToSendTable.keys();
		while (eTransationIds.hasMoreElements()){
			String sTransactionId = eTransationIds.nextElement();
			String sResult = (String)htLabsToSendTable.get(sTransactionId);			
			TransactionVO transactionVO = MedwanQuery.getInstance().loadTransaction(MedwanQuery.getInstance().getConfigInt("serverId"), Integer.parseInt(sTransactionId));
			if(transactionVO.getHealthrecordId() == 0){
				MedwanQuery.getInstance().getObjectCache().removeObject("transaction",MedwanQuery.getInstance().getConfigInt("serverId")+"."+sTransactionId);
				transactionVO = MedwanQuery.getInstance().loadTransaction(MedwanQuery.getInstance().getConfigInt("serverId"), Integer.parseInt(sTransactionId));
			}
			String sSMSDestination = getSMSDestinationByTransactionId(sTransactionId).replaceAll(";", " ").replaceAll(",", " ");	
			SpoolMessage(transactionVO.getTransactionId(), "sms", sResult, sSMSDestination);
		}
	}
	
	public void spoolEmail(Hashtable htLabsToSendTable,String transport){
		Enumeration<String> eTransationIds = htLabsToSendTable.keys();
		while (eTransationIds.hasMoreElements()){
			String sTransactionId = eTransationIds.nextElement();
			String sResult = (String)htLabsToSendTable.get(sTransactionId);			
			TransactionVO transactionVO = MedwanQuery.getInstance().loadTransaction(MedwanQuery.getInstance().getConfigInt("serverId"), Integer.parseInt(sTransactionId));
			if(transactionVO.getHealthrecordId() == 0){
				MedwanQuery.getInstance().getObjectCache().removeObject("transaction",MedwanQuery.getInstance().getConfigInt("serverId")+"."+sTransactionId);
				transactionVO = MedwanQuery.getInstance().loadTransaction(MedwanQuery.getInstance().getConfigInt("serverId"), Integer.parseInt(sTransactionId));
			}
			String sEmailAddress = getEmailAddressByTransactionId(sTransactionId).replaceAll(";", " ").replaceAll(",", " ");									
			SpoolMessage(transactionVO.getTransactionId(), transport, sResult, sEmailAddress);
		}
	}
	
	public void sendSpooledMessages(){
		Connection conn=MedwanQuery.getInstance().getOpenclinicConnection();
		try{
			PreparedStatement ps = conn.prepareStatement("SELECT * from OC_NOTIFIER where OC_NOTIFIER_SENTDATETIME IS NULL and OC_NOTIFIER_CREATEDATETIME>?");
			long day = 24*3600*1000;
			long period = day * MedwanQuery.getInstance().getConfigInt("spoolnotifiermessagesfordays",7);
			ps.setDate(1, new java.sql.Date(new Date().getTime()-period));
			ResultSet rs = ps.executeQuery();
			while(rs.next()){
				int transactionId = rs.getInt("OC_NOTIFIER_TRANSACTIONID");
				String transport = rs.getString("OC_NOTIFIER_TRANSPORT");
				String result = rs.getString("OC_NOTIFIER_RESULTS");
				String sentto = ScreenHelper.checkString(rs.getString("OC_NOTIFIER_SENTTO")).replace("+", "");
				System.out.println("Trying to send messages to "+sentto);
				TransactionVO transactionVO = MedwanQuery.getInstance().loadTransaction(MedwanQuery.getInstance().getConfigInt("serverId"), transactionId);
				if(transactionVO.getHealthrecordId() == 0){
					MedwanQuery.getInstance().getObjectCache().removeObject("transaction",MedwanQuery.getInstance().getConfigInt("serverId")+"."+transactionId);
					transactionVO = MedwanQuery.getInstance().loadTransaction(MedwanQuery.getInstance().getConfigInt("serverId"), transactionId);
				}
				int personid = MedwanQuery.getInstance().getPersonIdFromHealthrecordId(transactionVO.getHealthrecordId());
				AdminPerson patient = AdminPerson.getAdminPerson(personid+"");
				String sPatientFirstname = patient.firstname;
				sPatientFirstname = sPatientFirstname.charAt(0) + sPatientFirstname.substring(1).toLowerCase();
				
				PersonVO user = transactionVO.getUser().personVO;
				String sUserFirstname = user.firstname;			
				sUserFirstname = sUserFirstname.charAt(0) + sUserFirstname.substring(1).toLowerCase();					

				if(transport.equalsIgnoreCase("sms")){
					String sResult = "Lab " + MedwanQuery.getInstance().getLabel("sendhtmlmail", "for", user.language) + " " + patient.lastname.toUpperCase()+" "+sPatientFirstname + "\n" + result;
					if(MedwanQuery.getInstance().getConfigString("smsgateway","").equalsIgnoreCase("smsglobal")){
						try {						
							HttpClient client = new HttpClient();
							PostMethod method = new PostMethod(MedwanQuery.getInstance().getConfigString("smsglobal.url","http://www.smsglobal.com/http-api.php"));
							Vector<NameValuePair> vNvp = new Vector<NameValuePair>();
							vNvp.add(new NameValuePair("action","sendsms"));
							vNvp.add(new NameValuePair("user",MedwanQuery.getInstance().getConfigString("smsglobal.user","")));
							vNvp.add(new NameValuePair("password",MedwanQuery.getInstance().getConfigString("smsglobal.password","")));
							vNvp.add(new NameValuePair("from",MedwanQuery.getInstance().getConfigString("smsglobal.from","")));
							vNvp.add(new NameValuePair("to",sentto));
							vNvp.add(new NameValuePair("text",URLEncoder.encode(sResult,"utf-8")));
							NameValuePair[] nvp = new NameValuePair[vNvp.size()];
							vNvp.copyInto(nvp);
							method.setQueryString(nvp);
							client.executeMethod(method);
							String sResponse=method.getResponseBodyAsString();
							if(sResponse.contains("OK: 0")){
								System.out.println("SMS correctly sent transactionid "+transactionId+" to "+sentto+": "+sResponse);
								setSpoolMessageSent(transactionId,transport);
							}
							else {
								System.out.println("Error sending SMS with transactionid "+transactionId+" to "+sentto+": "+sResponse);
							}
						} catch (Exception e) {				
							e.printStackTrace();
						}
					}
					else if(MedwanQuery.getInstance().getConfigString("smsgateway","").equalsIgnoreCase("nokia")){
						try{
							String sPinCode = MedwanQuery.getInstance().getConfigString("smsPincode","0000"); 
							String sPort= MedwanQuery.getInstance().getConfigString("smsDevicePort","/dev/ttyS20");
							int nBaudrate=MedwanQuery.getInstance().getConfigInt("smsBaudrate",115200);
							System.setProperty("smslib.serial.polling", MedwanQuery.getInstance().getConfigString("smsPolling","false"));
							SendSMS sendSMS = new SendSMS();				
							if (sResult.length() > 160){ 					
								Vector vSMSs = new Vector();
								vSMSs = splitSMSText(sResult);
								Enumeration<String> eSMSs = vSMSs.elements();
								String sSMS;
								while (eSMSs.hasMoreElements()){
									sSMS = eSMSs.nextElement();
									sendSMS.send("modem.nokia",sPort, nBaudrate, "Nokia", "2690", sPinCode, sentto, sSMS);
								}
							}
							else { 
								sendSMS.send("modem.nokia", sPort, nBaudrate, "Nokia", "2690", sPinCode, sentto, sResult);
							}						
							setSpoolMessageSent(transactionId,transport);
						}
						catch(Exception m){
							
						}
					}
				}
				else if(transport.equalsIgnoreCase("simplemail")){
					try{
						String sMailTitle = MedwanQuery.getInstance().getLabel("sendhtmlmail", "labrequestfortransaction", user.language);
						String sHeader = MedwanQuery.getInstance().getLabel("sendhtmlmail", "todoctor", user.language) + " " +  sUserFirstname + " " + user.lastname + ", \n\n" +
						MedwanQuery.getInstance().getLabel("sendhtmlmail", "newresults", user.language) + ". \n\n" + sMailTitle + " " + transactionId + ": \n\n" +
						MedwanQuery.getInstance().getLabel("web", "patient", user.language) +": "+ patient.lastname.toUpperCase()+" "+sPatientFirstname+", "+patient.gender.toUpperCase()+" °"+patient.dateOfBirth + " (ID: "+patient.personid+"), \n\n";
				
						String sResult=sHeader+result;
						sResult+= "\n\n" + MedwanQuery.getInstance().getLabel("sendhtmlmail", "closingmail", user.language) + "\n\n" + MedwanQuery.getInstance().getLabel("sendhtmlmail", "closingmailname", user.language);
						sendHtmlMail.sendSimpleMail(MedwanQuery.getInstance().getConfigString("PatientEdit.MailServer"), MedwanQuery.getInstance().getConfigString("labNotifierEmailSender","frank.verbeke@mxs.be"), sentto, sMailTitle + " " + transactionId, sResult);					
						setSpoolMessageSent(transactionId,transport);
					}
					catch(Exception m){
						
					}
				}
				else if(transport.equalsIgnoreCase("htmlmail")){
					try{
						String sMailTitle = MedwanQuery.getInstance().getLabel("sendhtmlmail", "labrequestfortransaction", user.language);
						String sImage = "<img src=\"cid:image_logo\">";
						String sHeader = "<html><body style='font-family: arial, sans-serif;height:100%;background-color: #DCEDFF'>"+
						"<table border='0' width='100%'><tr><td>" + MedwanQuery.getInstance().getLabel("sendhtmlmail", "todoctor", user.language) + " " +  sUserFirstname + " " + user.lastname + ", </td> <td></td> <td ALIGN='right'> " + sImage + "</td> </tr></table> <br>" +			
						MedwanQuery.getInstance().getLabel("sendhtmlmail", "newresults", user.language) + "<br><br>" +
						"<center><h3>" + sMailTitle + " " + transactionId + " ("+ScreenHelper.stdDateFormat.format(transactionVO.getUpdateTime())+")</h3></center><center><h3>"+
						MedwanQuery.getInstance().getLabel("web", "patient", user.language) +": "+ patient.lastname.toUpperCase()+" "+sPatientFirstname+", "+patient.gender.toUpperCase()+" °"+patient.dateOfBirth + " (ID: "+patient.personid+")</h3></center>" +
						"<table border='1' width='100%'>" +
						"	<tr BGCOLOR='Lightskyblue'><th>"+MedwanQuery.getInstance().getLabel("web", "labcode", user.language)+"</th><th>" + MedwanQuery.getInstance().getLabel("web", "label", user.language)+"</th><th>"+ MedwanQuery.getInstance().getLabel("web", "value", user.language) +"</th><th>"+ MedwanQuery.getInstance().getLabel("web", "references", user.language) +"</th><th>"+ MedwanQuery.getInstance().getLabel("web", "evaluation", user.language) +"</th></tr>";
	
						String sResult=sHeader+result;
						sResult+= "</table><br/><br/>"+MedwanQuery.getInstance().getLabel("sendhtmlmail", "closingmail", user.language) + "<br><br>" + MedwanQuery.getInstance().getLabel("sendhtmlmail", "closingmailname", user.language);
						sResult=sResult+ 
								"<br><br> <table border='0' width='100%'>" +
								"<tr><td></td> <td></td> <td>" + "</td> </tr></table>";
								
						sResult=sResult+ "</body></html>";									
						sResult=HTMLEntities.htmlentities(sResult);
						String sLogo = MedwanQuery.getInstance().getConfigString("projectLogo","/projects/openclinic/_img/projectlogo.jpg");	
						sendHtmlMail.sendEmailWithImages(MedwanQuery.getInstance().getConfigString("PatientEdit.MailServer"), MedwanQuery.getInstance().getConfigString("labNotifierEmailSender","frank.verbeke@mxs.be"), sentto, sMailTitle + " " + transactionId, sResult, sLogo);														
						setSpoolMessageSent(transactionId,transport);
					}
					catch(Exception m){
						
					}
				}
				else if(transport.equalsIgnoreCase("attachedmail")){
					try{
						String sMailTitle = MedwanQuery.getInstance().getLabel("sendhtmlmail", "labrequestfortransaction", user.language);
						String sImage = "<img src=\"http://www.mxs.be/openclinic/_img/projectlogo.jpg\">";
						String sHeader = "<html><body style='font-family: arial, sans-serif;height:100%;background-color: #DCEDFF'>"+
						"<table border='0' width='100%'><tr><td>" + MedwanQuery.getInstance().getLabel("sendhtmlmail", "todoctor", user.language) + " " +  sUserFirstname + " " + user.lastname + ", </td> <td></td> <td ALIGN='right'> " + sImage + "</td> </tr></table> <br>" +			
						MedwanQuery.getInstance().getLabel("sendhtmlmail", "newresults", user.language) + "<br><br>" +
						"<center><h3>" + sMailTitle + " " + transactionId + " ("+ScreenHelper.stdDateFormat.format(transactionVO.getUpdateTime())+")</h3></center><center><h3>"+
						MedwanQuery.getInstance().getLabel("web", "patient", user.language) +": "+ patient.lastname.toUpperCase()+" "+sPatientFirstname+", "+patient.gender.toUpperCase()+" °"+patient.dateOfBirth + " (ID: "+patient.personid+")</h3></center>" +
						"<table border='1' width='100%'>" +
						"	<tr BGCOLOR='Lightskyblue'><th>"+MedwanQuery.getInstance().getLabel("web", "labcode", user.language)+"</th><th>" + MedwanQuery.getInstance().getLabel("web", "label", user.language)+"</th><th>"+ MedwanQuery.getInstance().getLabel("web", "value", user.language) +"</th><th>"+ MedwanQuery.getInstance().getLabel("web", "references", user.language) +"</th><th>"+ MedwanQuery.getInstance().getLabel("web", "evaluation", user.language) +"</th></tr>";
	
						String sResult=sHeader+result;
						sResult+= "</table><br/><br/>"+MedwanQuery.getInstance().getLabel("sendhtmlmail", "closingmail", user.language) + "<br><br>" + MedwanQuery.getInstance().getLabel("sendhtmlmail", "closingmailname", user.language);
						sResult=sResult+ 
								"<br><br> <table border='0' width='100%'>" +
								"<tr><td></td> <td></td> <td>" + "</td> </tr></table>";
								
						sResult=sResult+ "</body></html>";									
						sResult=HTMLEntities.htmlentities(sResult);
						String sFileName = "Transaction"+ new SimpleDateFormat("ddMMyyyy-HHmmss").format(new java.util.Date())+"_Tid"+transactionId+".html";
		                String sAttachment = MedwanQuery.getInstance().getConfigString("tempDirectory","/tmp")+"/"+sFileName;				
						ProcessFiles.writeFile(sAttachment, sResult);
						sendHtmlMail.sendAttachEmail(MedwanQuery.getInstance().getConfigString("PatientEdit.MailServer"), MedwanQuery.getInstance().getConfigString("labNotifierEmailSender","frank.verbeke@mxs.be"), sentto, sMailTitle + " " + transactionId, sMailTitle + " " + transactionId, sAttachment, sFileName);						
						setSpoolMessageSent(transactionId,transport);
					}
					catch(Exception m){
						
					}
				}
			}
		}
		catch(Exception e){
			e.printStackTrace();
		}
		finally {
			try{
				conn.close();
			}
			catch(Exception e2){
				e2.printStackTrace();
			}
		}

	}
	
	public void setSpoolMessageSent(int transactionId, String transport){
		Connection conn=MedwanQuery.getInstance().getOpenclinicConnection();
		try{
			PreparedStatement ps = conn.prepareStatement("UPDATE OC_NOTIFIER set OC_NOTIFIER_SENTDATETIME=? where OC_NOTIFIER_TRANSACTIONID=? and OC_NOTIFIER_TRANSPORT=? and OC_NOTIFIER_SENTDATETIME IS NULL");
			ps.setTimestamp(1, new java.sql.Timestamp(new java.util.Date().getTime()));
			ps.setInt(2, transactionId);
			ps.setString(3, transport);
			ps.execute();
			ps.close();
		}
		catch(Exception e){
			e.printStackTrace();
		}
		finally {
			try{
				conn.close();
			}
			catch (Exception e2) {
				e2.printStackTrace();
			}
		}
	}
	
	public int sendLabResultsSMS(Hashtable htLabsToSendTable){
		Enumeration<String> eTransationIds = htLabsToSendTable.keys();
		int i = 0;
		while (eTransationIds.hasMoreElements()){
			String sTransactionId = eTransationIds.nextElement();
			String sResult = (String)htLabsToSendTable.get(sTransactionId);			
			String sSMSDestination = null;
			TransactionVO transactionVO = MedwanQuery.getInstance().loadTransaction(MedwanQuery.getInstance().getConfigInt("serverId"), Integer.parseInt(sTransactionId));
			if(transactionVO.getHealthrecordId() == 0){
				MedwanQuery.getInstance().getObjectCache().removeObject("transaction",MedwanQuery.getInstance().getConfigInt("serverId")+"."+sTransactionId);
				transactionVO = MedwanQuery.getInstance().loadTransaction(MedwanQuery.getInstance().getConfigInt("serverId"), Integer.parseInt(sTransactionId));
			}
			int personid = MedwanQuery.getInstance().getPersonIdFromHealthrecordId(transactionVO.getHealthrecordId());
			AdminPerson patient = AdminPerson.getAdminPerson(personid+"");
			String sPatientFirstname = patient.firstname;
			sPatientFirstname = sPatientFirstname.charAt(0) + sPatientFirstname.substring(1).toLowerCase();
			
			PersonVO user = transactionVO.getUser().personVO;
			String sUserFirstname = user.firstname;			
			sUserFirstname = sUserFirstname.charAt(0) + sUserFirstname.substring(1).toLowerCase();					
			sResult = "Lab " + MedwanQuery.getInstance().getLabel("sendhtmlmail", "for", user.language) + " " + patient.lastname.toUpperCase()+" "+sPatientFirstname + "\n" +
						sResult;
			sSMSDestination = getSMSDestinationByTransactionId(sTransactionId).replaceAll(";", " ").replaceAll(",", " ");						

			if(MedwanQuery.getInstance().getConfigString("smsgateway","").equalsIgnoreCase("smsglobal")){
				try {						
					HttpClient client = new HttpClient();
					PostMethod method = new PostMethod(MedwanQuery.getInstance().getConfigString("smsglobal.url","http://www.smsglobal.com/http-api.php"));
					Vector<NameValuePair> vNvp = new Vector<NameValuePair>();
					vNvp.add(new NameValuePair("action","sendsms"));
					vNvp.add(new NameValuePair("user",MedwanQuery.getInstance().getConfigString("smsglobal.user","")));
					vNvp.add(new NameValuePair("password",MedwanQuery.getInstance().getConfigString("smsglobal.password","")));
					vNvp.add(new NameValuePair("from",MedwanQuery.getInstance().getConfigString("smsglobal.from","")));
					vNvp.add(new NameValuePair("to",sSMSDestination));
					vNvp.add(new NameValuePair("text",URLEncoder.encode(sResult,"utf-8")));
					NameValuePair[] nvp = new NameValuePair[vNvp.size()];
					vNvp.copyInto(nvp);
					method.setQueryString(nvp);
					client.executeMethod(method);
					String sResponse=method.getResponseBodyAsString();
					if(sResponse.contains("OK: 0")){
						i = i + 1;
					}
					else {
						System.out.println(sResponse);
					}
				} catch (Exception e) {				
					e.printStackTrace();
				}
			}
			else if(MedwanQuery.getInstance().getConfigString("smsgateway","").equalsIgnoreCase("nokia")){
				try {						
					String sPinCode = MedwanQuery.getInstance().getConfigString("smsPincode","0000"); 
					String sPort= MedwanQuery.getInstance().getConfigString("smsDevicePort","/dev/ttyS20");
					int nBaudrate=MedwanQuery.getInstance().getConfigInt("smsBaudrate",115200);
					System.setProperty("smslib.serial.polling", MedwanQuery.getInstance().getConfigString("smsPolling","false"));
					SendSMS sendSMS = new SendSMS();				
					if (sResult.length() > 160){ 					
						Vector vSMSs = new Vector();
						vSMSs = splitSMSText(sResult);
						Enumeration<String> eSMSs = vSMSs.elements();
						String sSMS;
						while (eSMSs.hasMoreElements()){
							sSMS = eSMSs.nextElement();
							sendSMS.send("modem.nokia",sPort, nBaudrate, "Nokia", "2690", sPinCode, sSMSDestination, sSMS);
						}
					}
					else { 
						sendSMS.send("modem.nokia", sPort, nBaudrate, "Nokia", "2690", sPinCode, sSMSDestination, sResult);
					}							
					i = i + 1;
				} catch (Exception e) {				
					e.printStackTrace();
				}
			}
		}
		return i;
	}

	public int sendLabResultsEmail(Hashtable htLabsToSendTable, String sSendMode){
		Enumeration<String> eTransationIds = htLabsToSendTable.keys();
		int i = 0;
		while (eTransationIds.hasMoreElements()){
			String sTransactionId = eTransationIds.nextElement();
			String sResult = (String)htLabsToSendTable.get(sTransactionId);
			String sEmailAddress = null; 
			String sImage = null;
			TransactionVO transactionVO = MedwanQuery.getInstance().loadTransaction(MedwanQuery.getInstance().getConfigInt("serverId"), Integer.parseInt(sTransactionId));
			if( transactionVO.getHealthrecordId() == 0){
				MedwanQuery.getInstance().getObjectCache().removeObject("transaction",MedwanQuery.getInstance().getConfigInt("serverId")+"."+sTransactionId);
				transactionVO = MedwanQuery.getInstance().loadTransaction(MedwanQuery.getInstance().getConfigInt("serverId"), Integer.parseInt(sTransactionId));									
			}					
			int personid = MedwanQuery.getInstance().getPersonIdFromHealthrecordId(transactionVO.getHealthrecordId());
			
			AdminPerson patient = AdminPerson.getAdminPerson(personid+"");
			String sPatientFirstname = patient.firstname;
			
			PersonVO user = transactionVO.getUser().personVO;
			String sUserFirstname = user.firstname;	
			sUserFirstname = sUserFirstname.charAt(0) + sUserFirstname.substring(1).toLowerCase();
			sPatientFirstname = sPatientFirstname.charAt(0) + sPatientFirstname.substring(1).toLowerCase();
			String sMailTitle = MedwanQuery.getInstance().getLabel("sendhtmlmail", "labrequestfortransaction", user.language);
			
			if (sSendMode == "simple"){ 
				String sHeader = MedwanQuery.getInstance().getLabel("sendhtmlmail", "todoctor", user.language) + " " +  sUserFirstname + " " + user.lastname + ", \n\n" +
						MedwanQuery.getInstance().getLabel("sendhtmlmail", "newresults", user.language) + ". \n\n" +
						sMailTitle + " " + sTransactionId + ": \n\n" +
						MedwanQuery.getInstance().getLabel("web", "patient", user.language) +": "+ patient.lastname.toUpperCase()+" "+sPatientFirstname+", "+patient.gender.toUpperCase()+" °"+patient.dateOfBirth + " (ID: "+patient.personid+"), \n\n";
				
				sResult=sHeader+sResult;
				sResult+= "\n\n" + MedwanQuery.getInstance().getLabel("sendhtmlmail", "closingmail", user.language) + "\n\n" + MedwanQuery.getInstance().getLabel("sendhtmlmail", "closingmailname", user.language);
			}
				
			else { 		
				if (sSendMode == "html" || sSendMode == "attach") {						
						if (sSendMode == "html"){
							sImage = "<img src=\"cid:image_logo\">";
						}
						else  {
							sImage = "<img src=\"http://www.mxs.be/openclinic/_img/projectlogo.jpg\">";
						}						
				} 
				String sHeader = "<html><body style='font-family: arial, sans-serif;height:100%;background-color: #DCEDFF'>"+
						"<table border='0' width='100%'><tr><td>" + MedwanQuery.getInstance().getLabel("sendhtmlmail", "todoctor", user.language) + " " +  sUserFirstname + " " + user.lastname + ", </td> <td></td> <td ALIGN='right'> " + sImage + "</td> </tr></table> <br>" +			
						MedwanQuery.getInstance().getLabel("sendhtmlmail", "newresults", user.language) + "<br><br>" +
						"<center><h3>" + sMailTitle + " " + sTransactionId + " ("+ScreenHelper.stdDateFormat.format(transactionVO.getUpdateTime())+")</h3></center><center><h3>"+
						MedwanQuery.getInstance().getLabel("web", "patient", user.language) +": "+ patient.lastname.toUpperCase()+" "+sPatientFirstname+", "+patient.gender.toUpperCase()+" °"+patient.dateOfBirth + " (ID: "+patient.personid+")</h3></center>" +
						"<table border='1' width='100%'>" +
						"	<tr BGCOLOR='Lightskyblue'><th>"+MedwanQuery.getInstance().getLabel("web", "labcode", user.language)+"</th><th>" + MedwanQuery.getInstance().getLabel("web", "label", user.language)+"</th><th>"+ MedwanQuery.getInstance().getLabel("web", "value", user.language) +"</th><th>"+ MedwanQuery.getInstance().getLabel("web", "references", user.language) +"</th><th>"+ MedwanQuery.getInstance().getLabel("web", "evaluation", user.language) +"</th></tr>";

				sResult=sHeader+sResult;
				sResult+= "</table><br/><br/>"+MedwanQuery.getInstance().getLabel("sendhtmlmail", "closingmail", user.language) + "<br><br>" + MedwanQuery.getInstance().getLabel("sendhtmlmail", "closingmailname", user.language);
				sResult=sResult+ 
						"<br><br> <table border='0' width='100%'>" +
						"<tr><td></td> <td></td> <td>" + "</td> </tr></table>";
						
				sResult=sResult+ "</body></html>";									
			}
						
			sEmailAddress = getEmailAddressByTransactionId(sTransactionId).replaceAll(";", " ").replaceAll(",", " ");									
			try {				
				if (sSendMode == "simple"){
					sendHtmlMail.sendSimpleMail(MedwanQuery.getInstance().getConfigString("PatientEdit.MailServer"), MedwanQuery.getInstance().getConfigString("labNotifierEmailSender","frank.verbeke@mxs.be"), sEmailAddress, sMailTitle + " " + sTransactionId, sResult);					
				}				
				if (sSendMode == "html"){ 	
					sResult=HTMLEntities.htmlentities(sResult);
					String sLogo = "/projects/openclinic/web/_img/projectlogo.jpg";	
					sendHtmlMail.sendEmailWithImages(MedwanQuery.getInstance().getConfigString("PatientEdit.MailServer"), MedwanQuery.getInstance().getConfigString("labNotifierEmailSender","frank.verbeke@mxs.be"), sEmailAddress, sMailTitle + " " + sTransactionId, sResult, sLogo);														
				}

				if (sSendMode == "attach"){
					sResult=HTMLEntities.htmlentities(sResult);
					String sFileName = "Transaction"+ new SimpleDateFormat("ddMMyyyy-HHmmss").format(new java.util.Date())+"_Tid"+sTransactionId+".html";
	                String sAttachment = "/tmp/"+sFileName;				
					ProcessFiles.writeFile(sAttachment, sResult);
					sendHtmlMail.sendAttachEmail(MedwanQuery.getInstance().getConfigString("PatientEdit.MailServer"), MedwanQuery.getInstance().getConfigString("labNotifierEmailSender","frank.verbeke@mxs.be"), sEmailAddress, sMailTitle + " " + sTransactionId, sMailTitle + " " + sTransactionId, sAttachment, sFileName);						
				}
				i = i + 1;								
			
			} catch (Exception e) {
				e.printStackTrace();
			}			
		}
		return i;
	}
	
	public void SpoolMessage(int transactionId, String transport, String result, String sentto){
		Connection conn=MedwanQuery.getInstance().getOpenclinicConnection();
		try{
			PreparedStatement ps = conn.prepareStatement("SELECT * from OC_NOTIFIER where OC_NOTIFIER_TRANSACTIONID=? and OC_NOTIFIER_TRANSPORT=? and OC_NOTIFIER_SENTDATETIME IS NULL");
			ps.setInt(1, transactionId);
			ps.setString(2, transport);
			ResultSet rs = ps.executeQuery();
			if(rs.next()){
				result+=rs.getString("OC_NOTIFIER_RESULTS");
			}
			rs.close();
			ps.close();
			ps = conn.prepareStatement("DELETE from OC_NOTIFIER where OC_NOTIFIER_TRANSACTIONID=? and OC_NOTIFIER_TRANSPORT=? and OC_NOTIFIER_SENTDATETIME IS NULL");
			ps.setInt(1, transactionId);
			ps.setString(2, transport);
			ps.execute();
			ps.close();
			ps = conn.prepareStatement("INSERT INTO OC_NOTIFIER(OC_NOTIFIER_TRANSACTIONID,OC_NOTIFIER_TRANSPORT,OC_NOTIFIER_RESULTS,OC_NOTIFIER_CREATEDATETIME,OC_NOTIFIER_SENTTO) values(?,?,?,?,?)");
			ps.setInt(1, transactionId);
			ps.setString(2, transport);
			ps.setString(3, result);
			ps.setTimestamp(4, new java.sql.Timestamp(new java.util.Date().getTime()));
			ps.setString(5, sentto);
			ps.execute();
			ps.close();
		}
		catch(Exception e){
			e.printStackTrace();
		}
		finally {
			try{
				conn.close();
			}
			catch (Exception e2) {
				e2.printStackTrace();
			}
		}
	}
	
	public static Vector<String> splitSMSText(String sResult){
		Vector<String> vSMSs = new Vector<String>();		
		String[] aLines = sResult.split("\n");
		
		if (aLines[0].length() < 160) {
			int iMsgsSend = 1;
			String sMsgToSend = aLines[0]+" (" + iMsgsSend + ")";
			int iLabLineToAdd = 1;
			int iLabLinesSent = 0;			
			String sNextLabLine;
			while (iLabLinesSent < aLines.length - 1) { // eg from 0 to 2
				sNextLabLine = aLines[iLabLineToAdd];
				if (sMsgToSend.length() + sNextLabLine.length() <= 160) {					
					sMsgToSend = sMsgToSend + "\n" + sNextLabLine;
					iLabLineToAdd = iLabLineToAdd + 1;
					iLabLinesSent = iLabLinesSent + 1;
					if (iLabLinesSent == aLines.length - 1){ // last line
						vSMSs.add(sMsgToSend);						
					}
				}
				else { // Longer than 160 ==>> Send earlier one									
					vSMSs.add(sMsgToSend);						
					iMsgsSend = iMsgsSend + 1;
					sMsgToSend = aLines[0]+" (" + iMsgsSend + ")";
				}								
			}			
		}
		return vSMSs;
	}
	
	public String getSMSDestinationByTransactionId(String sTransactionId){
		int iServerId = MedwanQuery.getInstance().getConfigInt("serverId");
		String sSelect = "select value from items where transactionid = ? and type = ? and serverid = ?";
		Connection conn = MedwanQuery.getInstance().getOpenclinicConnection();
		try {
			PreparedStatement ps = conn.prepareStatement(sSelect);
			ps.setString(1, sTransactionId);
			ps.setString(2, "be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LAB_SMS");
			ps.setInt(3, iServerId);
			ResultSet rs = ps.executeQuery();
			String SMSDestitination;
			if (rs.next()){
				SMSDestitination = rs.getString("value");				
			} else {				
				SMSDestitination = "";				
			}
			rs.close();
			ps.close();
			conn.close();
			return SMSDestitination;
			
		} catch (SQLException e) {
			e.printStackTrace();
			return null;
		}		
	}

	public String getEmailAddressByTransactionId(String sTransactionId){		
		int iServerId = MedwanQuery.getInstance().getConfigInt("serverId");
		String sSelect = "select value from items where transactionid = ? and type = ? and serverid = ?";
		Connection conn = MedwanQuery.getInstance().getOpenclinicConnection();
		try {
			PreparedStatement ps = conn.prepareStatement(sSelect);
			ps.setString(1, sTransactionId);
			ps.setString(2, "be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LAB_EMAIL");
			ps.setInt(3, iServerId);		
			ResultSet rs = ps.executeQuery();
			String sEmailAddress;
			if (rs.next()){
				sEmailAddress = rs.getString("value");				
			} else {				
				sEmailAddress = "";				
			}
			rs.close();
			ps.close();
			conn.close();
			return sEmailAddress;
			
		} catch (SQLException e) {
			e.printStackTrace();
			return null;
		}		
	}

}
