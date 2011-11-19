package be.openclinic.reporting;

import java.util.Date;
import java.util.Hashtable;
import java.util.Enumeration;
import java.util.Vector;
import java.text.*; //ParseException;

import be.mxs.common.util.db.MedwanQuery;
import java.sql.*;

import be.mxs.common.util.system.HTMLEntities;
import be.mxs.common.util.system.Mail;
import be.openclinic.datacenter.SendSMS;

import java.io.*;

import org.smslib.modem.AModemDriver;

import net.admin.AdminPerson;
import be.mxs.common.util.tools.sendHtmlMail;
import be.mxs.common.util.tools.ProcessFiles;

import be.openclinic.medical.*;
import be.mxs.common.model.vo.healthrecord.*;
import be.dpms.medwan.common.model.vo.administration.PersonVO;


public class LabresultsNotifier {
	
	private Date lastResultsCheck;
	
	public void setLastNotifiedResult(Date date){		
		String sDate = new SimpleDateFormat("yyyyMMddHHmmss").format(date);
		//sDate = "20111005160119"; //temp
		MedwanQuery.getInstance().setConfigString("lastNotifiedLabResult", sDate);			
	}
	
	public Date getLastNotifiedResult(){
		String sDate = MedwanQuery.getInstance().getConfigString("lastNotifiedLabResult"); //Gets oc_value from config-HashTable. Still in Memory as MedwanQuery is defined as Static: Factory. 
		if (sDate == ""){
			sDate = "19000101000000";
		}
		
		try { // Why is try here compulsory??
			Date dDate = new SimpleDateFormat("yyyyMMddHHmmss").parse(sDate);
			return dDate;
			
		} catch (ParseException e) {
		    // execution will come here if the String that is given does not match the expected format.
			e.printStackTrace();
			return null;
		}		
	}
	
	public Vector findNewLabs() throws SQLException{ 		//findNewRequestedLabAnalysis should be a better name
		Vector vAnalysesToNotify = new Vector();
				
		String sQuery = "select * from requestedlabanalyses "  +
						" where resultvalue is not null and resultvalue <> ''" +
						" and finalvalidationdatetime is not null And finalvalidationdatetime > ? And finalvalidationdatetime <= ? " +  
						" order by finalvalidationdatetime";
		
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
		if (vAnalysesToNotify.size()==0){
			System.out.println("No Requested lab Analyses Records found. Nothing added to vector " + new Timestamp(new java.util.Date().getTime()));
		}
		
		rs.close();
		ps.close();
		conn.close();
		
		return vAnalysesToNotify;		
	}

	public String makeResultString(RequestedLabAnalysis rqLabAnalysis, LabAnalysis la, String sEmail){
		String sResult = "";
		
		return sResult;
	}
	
	public void sendNewLabs_old(String language){ // simple email
		try {			
			Hashtable htLabsToSendTable = new Hashtable();			
			Vector vNewLabs = (Vector)findNewLabs();	//findNewRequestedLabAnalysis should be a better name: Contains transactionid, analysiscode, etc		
			for (int i=0; i<vNewLabs.size(); i++){
				RequestedLabAnalysis rqLabAnalysis = (RequestedLabAnalysis)vNewLabs.elementAt(i);
				lastResultsCheck = rqLabAnalysis.getFinalvalidationdatetime();
				
				//System.out.println("Debug$$$ Transaction " + i + ":      	TransactionId is: " +rqLabAnalysis.getTransactionId());
				
				// get all medical data for this transaction
				LabAnalysis la = LabAnalysis.getLabAnalysisByLabcode(rqLabAnalysis.getAnalysisCode()); //(bc , hgb )
				
				String result = la.getLabcode() + " " + MedwanQuery.getInstance().getLabel("labanalysis", la.getLabId()+"", language)+": "+rqLabAnalysis.getResultValue()+" "+rqLabAnalysis.getResultUnit()+"\n";				
				System.out.println("Result String for this transaction is: " + result);
				
				String emailValue = rqLabAnalysis.getNotifyByEmail(); // Transaction id already in RequestedlabAnalysis object: rqLabAnalysis
				if (emailValue != null){
					//System.out.println("Email address for this transaction is: " + emailValue);

					if(htLabsToSendTable.get(rqLabAnalysis.getTransactionId())==null){
						htLabsToSendTable.put(rqLabAnalysis.getTransactionId(), result);
					}
					else {
						htLabsToSendTable.put(rqLabAnalysis.getTransactionId(), (String)htLabsToSendTable.get(rqLabAnalysis.getTransactionId())+result);
					}
					//System.out.println("Fullresult for transactionid "+rqLabAnalysis.getTransactionId()+": \n"+htLabsToSendTable.get(rqLabAnalysis.getTransactionId()));
					System.out.println("Fullresult in htLabsToSendTable for transactionid "+rqLabAnalysis.getTransactionId()+": \n"+htLabsToSendTable.get(rqLabAnalysis.getTransactionId()));
				}				
			}

			System.out.println("--------------------Looping the HashTable-------------------------");
			
			if (htLabsToSendTable.size() > 0){
				int totalSendResults = sendSimpleMail(htLabsToSendTable);
				if (totalSendResults > 0){
					setLastNotifiedResult(lastResultsCheck);
				}
			}
												
		} catch (SQLException e) {
			System.out.println("Error reading Vector findNewLabs() " + new Timestamp(new java.util.Date().getTime()));
			System.out.println("No Requested lab Analyses Records found. Nothing to Send " + new Timestamp(new java.util.Date().getTime()));
			e.printStackTrace();
		}
		
	}
	
	// Not Used
	public String[] getPatientData(String sPatientId) throws SQLException{
		String[] asPatientData = new String[4];
		
		String sQuery = "select firstname, lastname, language, email from admin, adminprivate"  +
				" where admin.personid = adminprivate.personid" +
				" and admin.personid = ? " +
				" and email is not null and email != ''";		

		Connection conn2 = MedwanQuery.getInstance().getAdminConnection();
		PreparedStatement ps2 = conn2.prepareStatement(sQuery);							
		ps2.setString(1, sPatientId);					
		
		ResultSet rs = ps2.executeQuery();
					
		if (rs.next()){
			asPatientData[0] = rs.getString("firstname");
			asPatientData[1] = rs.getString("lastname");
			asPatientData[2] = rs.getString("language");
			asPatientData[3] = rs.getString("email");			
		}		
		
		return asPatientData;
		
	}
	
	public String sendNewLabs(){
		String sSendMode = "html";
		//String sSendMode = "attach";
		//String sSendMode = "simple";
		//String sSendMode = "SMS";
		String sCheck = sendNewLabs(sSendMode);
		return sCheck;
	}
	

	public String sendNewLabs_SmsEmailTogether(String sSendMode){
		TransactionVO transactionVO;
		String sLanguage;
		Hashtable transactionlanguages = new Hashtable();

		try {
			Hashtable htLabsToSendTable = new Hashtable();			
			Vector vNewLabs = (Vector)findNewLabs();	//findNewRequestedLabAnalysis should be a better name: Contains transactionid, analysiscode, etc
			//We hebben nu de lijst van te verzenden analyses: meerdere analyses kunnen tot 1 dezelfde transactie behoren
			for (int i=0; i<vNewLabs.size(); i++){
				RequestedLabAnalysis rqLabAnalysis = (RequestedLabAnalysis)vNewLabs.elementAt(i);				
				lastResultsCheck = rqLabAnalysis.getFinalvalidationdatetime();	//The last one is used			
				System.out.println("________________________________________________________________________________________________________________________________");
				System.out.println("Debug$$$$$ Transaction " + i + ":   TransactionId is: " +rqLabAnalysis.getTransactionId() + " Time: " + new java.util.Date());
				// zoek de labanalyse-gegevens die passen bij dit requestedLabResult en geef deze weer als een <tr> element voor een HTML tabel
				LabAnalysis la = LabAnalysis.getLabAnalysisByLabcode(rqLabAnalysis.getAnalysisCode()); 
				//zoek de taal van de gebruiker die deze labanalyse heeft aangevraagd
				//eerst kijken of we de taal niet reeds vroeger hebben opgehaald voor deze transactie
				if(transactionlanguages.get(rqLabAnalysis.getTransactionId())!=null){
					sLanguage=(String)transactionlanguages.get(rqLabAnalysis.getTransactionId());
				}
				else{
					// transactie in kwestie ophalen
					transactionVO = MedwanQuery.getInstance().loadTransaction(MedwanQuery.getInstance().getConfigInt("serverId"), Integer.parseInt(rqLabAnalysis.getTransactionId()));
					// taal van de aanvrager van deze transactie ophalen
					sLanguage=transactionVO.getUser().personVO.language;

					// taal in hashtable stockeren voor later gebruik
					transactionlanguages.put(transactionVO.getTransactionId()+"",sLanguage);
				}
				// nu hebben we zeker de taal van de aanvrager gerecupereerd
				// we verpakken nu het labresultaat in een <tr> element
				String result;
				if (sSendMode == "simple" || sSendMode == "SMS"){
					result =  la.getLabcode() + " " + MedwanQuery.getInstance().getLabel("labanalysis", la.getLabId()+"", sLanguage) 
							+  "  " + rqLabAnalysis.getResultValue()+" "+rqLabAnalysis.getResultUnit() +"\n";
				}
				else { // html or attach
					result =  "<tr><td>" + la.getLabcode() + "</td><td>" + MedwanQuery.getInstance().getLabel("labanalysis", la.getLabId()+"", sLanguage) 
							+  "</td><td> " + rqLabAnalysis.getResultValue()+" "+rqLabAnalysis.getResultUnit()+" </td></tr>";
				}
						 				
				// Email of SMS van de aanvraag ophalen
				String sSMSValue = null;
				String emailValue = null;
				if (sSendMode == "SMS") {
					sSMSValue = validateSMSValue(sSMSValue = rqLabAnalysis.getNotifyBySMS());								
				}
				else {
					emailValue =  rqLabAnalysis.getNotifyByEmail(); // Transaction id already in RequestedlabAnalysis object: rqLabAnalysis	
					//emailValue = validateEmailValue(emailValue = rqLabAnalysis.getNotifyByEmail()); // Transaction id already in RequestedlabAnalysis object: rqLabAnalysis	
				}
				
				//if there is a destination to send the lab-results, fill the htLabsToSend Table
				if (emailValue != null || sSMSValue != null){												
					if(htLabsToSendTable.get(rqLabAnalysis.getTransactionId())==null){
						htLabsToSendTable.put(rqLabAnalysis.getTransactionId(), result);
					}
					else {
						htLabsToSendTable.put(rqLabAnalysis.getTransactionId(), (String)htLabsToSendTable.get(rqLabAnalysis.getTransactionId())+result);
					}										
					System.out.println("Fullresult in htLabsToSendTable for transactionid "+rqLabAnalysis.getTransactionId()+" is: \n"+htLabsToSendTable.get(rqLabAnalysis.getTransactionId()));
				}								
			}
			String sCheck = "Nothing Send";
			if (htLabsToSendTable.size() > 0){
				//sCheck = (String)htLabsToSendTable.get(7230);				
				int totalSendResults = sendLabResults(htLabsToSendTable, sSendMode);

				if (totalSendResults > 0){
					//setLastNotifiedResult(lastResultsCheck);
					sCheck = totalSendResults+"";
					if (sSendMode == "SMS") sCheck = sCheck + " SMS(s) send";
					else sCheck = sCheck + " Email(s) send";
				}				
			}
			return sCheck;
												
		} catch (SQLException e) {
			System.out.println("Error reading Vector findNewLabs() " + new Timestamp(new java.util.Date().getTime()));
			System.out.println("No Requested lab Analyses Records found. Nothing to Send " + new Timestamp(new java.util.Date().getTime()));
			e.printStackTrace();
			return "0";
		}		
	}	
	
	public String sendNewLabs(String sSendMode){
		TransactionVO transactionVO; //$$ Vervangen? //loadTransaction_FromDB
		String sLanguage;
		Hashtable transactionlanguages = new Hashtable();


		try {
			Hashtable htLabsToSendEmail = new Hashtable();	 //htLabsToSendTable		
			Hashtable htLabsToSendSMS = new Hashtable();
			Vector vNewLabs = (Vector)findNewLabs();	// Contains transactionid, analysiscode, 
			
			for (int i=0; i<vNewLabs.size(); i++){
				RequestedLabAnalysis rqLabAnalysis = (RequestedLabAnalysis)vNewLabs.elementAt(i);				
				lastResultsCheck = rqLabAnalysis.getFinalvalidationdatetime();	//The last one is used			
				System.out.println("________________________________________________________________________________________________________________________________");
				System.out.println("Debug$$$$$ Transaction " + i + ":   TransactionId is: " +rqLabAnalysis.getTransactionId() + " Time: " + new java.util.Date());
				
				LabAnalysis la = LabAnalysis.getLabAnalysisByLabcode(rqLabAnalysis.getAnalysisCode()); 
				
				//Fill Hashtable LabsToSend if there is a destination to send the lab-results 				
				String sSMSValue = rqLabAnalysis.getNotifyBySMS();
				//sSMSValue = validateSMSValue(sSMSValue = rqLabAnalysis.getNotifyBySMS());				
				String emailValue =  rqLabAnalysis.getNotifyByEmail(); // Transaction id already in RequestedlabAnalysis object: rqLabAnalysis	
				//emailValue = validateEmailValue(emailValue = rqLabAnalysis.getNotifyByEmail()); // Transaction id already in RequestedlabAnalysis object: rqLabAnalysis	
				
				String result;
				if (sSMSValue != null){ // Fill hashtable					
					if(transactionlanguages.get(rqLabAnalysis.getTransactionId())!=null){
						sLanguage=(String)transactionlanguages.get(rqLabAnalysis.getTransactionId());
					}
					else{
						transactionVO = MedwanQuery.getInstance().loadTransaction(MedwanQuery.getInstance().getConfigInt("serverId"), Integer.parseInt(rqLabAnalysis.getTransactionId())); 				
						sLanguage=transactionVO.getUser().personVO.language; 
						transactionlanguages.put(transactionVO.getTransactionId()+"",sLanguage); 
					}		
					result =  la.getLabcode() + " " + MedwanQuery.getInstance().getLabel("labanalysis", la.getLabId()+"", sLanguage) 
							+  "  " + rqLabAnalysis.getResultValue()+" "+rqLabAnalysis.getResultUnit() +"\n";					
					
					if(htLabsToSendSMS.get(rqLabAnalysis.getTransactionId())==null){
						htLabsToSendSMS.put(rqLabAnalysis.getTransactionId(), result);
					}
					else {
						htLabsToSendSMS.put(rqLabAnalysis.getTransactionId(), (String)htLabsToSendSMS.get(rqLabAnalysis.getTransactionId())+result);
					}						
					System.out.println("Fullresult in htLabsToSendSMS for transactionid "+rqLabAnalysis.getTransactionId()+" is: \n"+htLabsToSendSMS.get(rqLabAnalysis.getTransactionId()));
					
				}	
				if ( emailValue != null){ 					
					if(transactionlanguages.get(rqLabAnalysis.getTransactionId())!=null){
						sLanguage=(String)transactionlanguages.get(rqLabAnalysis.getTransactionId());
					}
					else{
						transactionVO = MedwanQuery.getInstance().loadTransaction(MedwanQuery.getInstance().getConfigInt("serverId"), Integer.parseInt(rqLabAnalysis.getTransactionId())); //$$weg						
						sLanguage=transactionVO.getUser().personVO.language; //$$ Vervangen met OccuprsResultSet.getString("lastname") // language
						transactionlanguages.put(transactionVO.getTransactionId()+"",sLanguage); //$$ Vervangen met put(rqLabAnalysis.getTransactionId(),sLanguage);
					}

					if (sSendMode == "html" || sSendMode == "attach"){
						result =  "<tr><td>" + la.getLabcode() + "</td><td>" + MedwanQuery.getInstance().getLabel("labanalysis", la.getLabId()+"", sLanguage) 
								+  "</td><td> " + rqLabAnalysis.getResultValue()+" "+rqLabAnalysis.getResultUnit()+" </td></tr>";
					}
					else { // simple text mail
						result =  la.getLabcode() + " " + MedwanQuery.getInstance().getLabel("labanalysis", la.getLabId()+"", sLanguage) 
								+  "  " + rqLabAnalysis.getResultValue()+" "+rqLabAnalysis.getResultUnit() +"\n";
					}
					
					if(htLabsToSendEmail.get(rqLabAnalysis.getTransactionId())==null){
						htLabsToSendEmail.put(rqLabAnalysis.getTransactionId(), result);
					}
					else {
						htLabsToSendEmail.put(rqLabAnalysis.getTransactionId(), (String)htLabsToSendEmail.get(rqLabAnalysis.getTransactionId())+result);
					}	
					
					System.out.println("Fullresult in htLabsToSendEmail for transactionid "+rqLabAnalysis.getTransactionId()+" is: \n"+htLabsToSendEmail.get(rqLabAnalysis.getTransactionId()));
					
				}
			}
			//String SCheck = "Nothing Send";
			String sCheckEmailSend = "No Mails Send. ";
			String sCheckSMSSend = "No SMS Send. ";
			int totalSendResultsEmail = 0;
			int totalSendResultsSMS = 0;
			
			if (htLabsToSendEmail.size() > 0){
				//sCheck = (String)htLabsToSendEmail.get(7230);				
				totalSendResultsEmail = sendLabResultsEmail(htLabsToSendEmail, sSendMode); 
				if (totalSendResultsEmail > 0){				
					sCheckEmailSend = totalSendResultsEmail+"";
					sCheckEmailSend = sCheckEmailSend + " Email(s) send. ";
				}				
			}
			if (htLabsToSendSMS.size() > 0){
				//sCheck = (String)htLabsToSendEmail.get(7230);				
				totalSendResultsSMS = sendLabResultsSMS(htLabsToSendSMS); 
				if (totalSendResultsSMS > 0){			
					sCheckSMSSend = totalSendResultsSMS+"";
					sCheckSMSSend = sCheckSMSSend + " SMS(s) send. ";					
				}				
			}
			if (totalSendResultsEmail + totalSendResultsSMS > 0){				
				setLastNotifiedResult(lastResultsCheck);				
			}
			return sCheckEmailSend + sCheckSMSSend;
												
		} catch (SQLException e) {
			System.out.println("Error reading Vector findNewLabs() " + new Timestamp(new java.util.Date().getTime()));
			System.out.println("No Requested lab Analyses Records found. Nothing to Send " + new Timestamp(new java.util.Date().getTime()));
			e.printStackTrace();
			return "0";
		}		
	}	

	
	public static String validateSMSValue(String sSMSValue){
		if (sSMSValue != null){
			
			//if (!sSMSValue.matches("[+-]?\\d*(\\.\\d+)?")){
			if (!sSMSValue.matches("[+]?\\d+")){
				sSMSValue = null;
			}

			/*
			if (sSMSValue.indexOf("+") == -1){ // To do: Check also for digits in string 
				System.out.println("No valid SMS Number");
				sSMSValue = null;				
			}
			*/		
		}
		System.out.println("SMS value to return is: " + sSMSValue);
		return sSMSValue;
	}
	
	public static String validateEmailValue(String sEmailValue){
		System.out.println("Received Email value is: " + sEmailValue);
		if (sEmailValue != null){			
			if (!sEmailValue.matches("(\\w)+@(\\w)+[.].+")){ //A word (\w) short for [a-zA-Z_0-9]. One or more times (+); Char @ ; A word (\w) One or more times (+);  A point [.]; Any char One or more times (+)
				System.out.println("No valid Email Address");
				sEmailValue = null;
			}			
			/*
			if (sEmailValue.indexOf("@") == -1){ // To do: Check also for digits in string 
				System.out.println("No valid Email Address");
				sEmailValue = null;				
			}
			*/		
		}
		System.out.println("Email value to return is: " + sEmailValue);
		return sEmailValue;
	}
	
	
	//Old, not used any more
	public int sendSimpleMail(Hashtable htLabsToSendTable){
		Enumeration<String> eTransationIds = htLabsToSendTable.keys();
		int i = 0;
		while (eTransationIds.hasMoreElements()){
			String sTransactionId = eTransationIds.nextElement();
			String sEmailAddress = getEmailAddressByTransactionId(sTransactionId).replaceAll(";", " ").replaceAll(",", " ");
			String[] emails = sEmailAddress.split(" ");
			for(int n=0;n<emails.length;n++){
				if(emails[n].trim().length()>0){
					//String sEmailAddress = "fernando.corral@mxs.be";
					String sBodyText = (String)htLabsToSendTable.get(sTransactionId);
					
					System.out.println("Email Address is: " + emails[n]);
					System.out.println("Subject to send to this emailaddress is:");
					System.out.println(sBodyText);
					System.out.println("----------------Sending Mail - check it on your mailbox or log file --------------------");
					try {
						Mail.sendMail(MedwanQuery.getInstance().getConfigString("PatientEdit.MailServer"), "fernando.corral@mxs.be", emails[n], "Requested LabAnalyses for Transaction " + sTransactionId, sBodyText);
						i = i + 1;
					} catch (Exception e) {
						System.out.println("Unable to send Email to " + emails[n] + "Throu: " + MedwanQuery.getInstance().getConfigString("PatientEdit.MailServer"));
						e.printStackTrace();
					}
					//Mail.sendMail(MedwanQuery.getInstance().getConfigString("PatientEdit.MailServer"),sFromEmail,sDestinationEmail,sAPPTITLE+" message from "+sFrom.toUpperCase(), sMessage);
				}
			}
		}
		return i;
	}
	
	//public int sendHtmlMail(Hashtable htLabsToSendTable){
	public int sendLabResults(Hashtable htLabsToSendTable, String sSendMode){
		Enumeration<String> eTransationIds = htLabsToSendTable.keys();
		int i = 0;
		while (eTransationIds.hasMoreElements()){
			String sTransactionId = eTransationIds.nextElement();
			String sResult = (String)htLabsToSendTable.get(sTransactionId);
			String sEmailAddress = null;
			String sSMSDestination = null;
			String sImage = null;
			//Voeg header toe aan sResult
			//Zoek eerst de transactie in kwestie op
			System.out.println("MedwanQuery.getInstance().getConfigInt('serverId')="+MedwanQuery.getInstance().getConfigInt("serverId"));
			TransactionVO transactionVO = MedwanQuery.getInstance().loadTransaction(MedwanQuery.getInstance().getConfigInt("serverId"), Integer.parseInt(sTransactionId));
			//Haal nu de patient op die bij deze transactie hoort
			System.out.println("transactionVO.getHealthrecordId()="+transactionVO.getHealthrecordId());
			int personid = MedwanQuery.getInstance().getPersonIdFromHealthrecordId(transactionVO.getHealthrecordId());
			System.out.println("patient.personid="+personid);
			AdminPerson patient = AdminPerson.getAdminPerson(personid+"");
			PersonVO user = transactionVO.getUser().personVO;
			// Stel de header samen aan de hand van de patiëntgegevens
			String sUserFirstname = user.firstname;			
			String sPatientFirstname = patient.firstname;
			
			sUserFirstname = sUserFirstname.charAt(0) + sUserFirstname.substring(1).toLowerCase();
			System.out.println("\n ---------------------Debug StringIndexOutOfBoundsException CharAT(0)---------------------------");
			
			System.out.println("transactionVO.getUser().personVO.firstname is: "+ transactionVO.getUser().personVO.firstname);
			System.out.println("transactionVO.getUser().personVO.lastname is: "+ transactionVO.getUser().personVO.lastname);
			
			System.out.println("UserFirstname is: " + sUserFirstname + ". sUserFirstname.charAt(0) is: " + sUserFirstname.charAt(0));
			System.out.println("sUserFirstname.substring(1).toLowerCase() is: " + sUserFirstname.substring(1).toLowerCase());
			System.out.println("patient.firstname="+patient.firstname);
			sPatientFirstname = sPatientFirstname.charAt(0) + sPatientFirstname.substring(1).toLowerCase();
			System.out.println("sPatientFirstname is: " + sPatientFirstname + ". sPatientFirstname.charAt(0) is: " + sPatientFirstname.charAt(0));
			System.out.println("sPatientFirstname.substring(1).toLowerCase() is: " + sPatientFirstname.substring(1).toLowerCase());
			System.out.println("--------------------------------------------End Debug---------------------------------------------------- \n");
			
			String sMailTitle = MedwanQuery.getInstance().getLabel("sendhtmlmail", "labrequestfortransaction", user.language);
			
			if (sSendMode == "simple"){
				String sHeader = MedwanQuery.getInstance().getLabel("sendhtmlmail", "dear", user.language) + " " +  sUserFirstname + " " + user.lastname + ", \n\n" +
						MedwanQuery.getInstance().getLabel("sendhtmlmail", "findattachment", user.language) + ". \n\n" +
						sMailTitle + " " + sTransactionId + ": \n\n" +
						MedwanQuery.getInstance().getLabel("web", "patient", user.language) +": "+ patient.lastname.toUpperCase()+" "+sPatientFirstname+" °"+patient.dateOfBirth + ", \n\n";
				
				sResult=sHeader+sResult;
				sResult+= "\n\n" + MedwanQuery.getInstance().getLabel("sendhtmlmail", "closingmail", user.language) + "\n\n" + MedwanQuery.getInstance().getLabel("sendhtmlmail", "closingmailname", user.language);
			}
			
			else if (sSendMode == "SMS"){
				sResult = "Lab " + MedwanQuery.getInstance().getLabel("sendhtmlmail", "for", user.language) + " " + patient.lastname.toUpperCase()+" "+sPatientFirstname + "\n" +
						sResult;
			}		
			else { //html or attachment				
				if (sSendMode == "html" || sSendMode == "attach") {						
						if (sSendMode == "html"){
							sImage = "<img src=\"cid:image_logo\">";
						}
						else  {
							sImage = "<img src=\"http://www.mxs.be/openclinic/_img/projectlogo.jpg\">";
						}
						//sImage = sImage;
				} 
				
				//E0FFFF =\"Lightcyan\" //<body style="background-color:color:DBEBFF;"> //<body BGCOLOR=\"E0FFFF\">  	DBEBFF			
				String sHeader = "<html><body style='height:100%;background-color: #DCEDFF'>"+
						"<table border='0' width='100%'><tr><td>" + MedwanQuery.getInstance().getLabel("sendhtmlmail", "dear", user.language) + " " +  sUserFirstname + " " + user.lastname + ", </td> <td></td> <td ALIGN='right'> " + sImage + "</td> </tr></table> <br>" +			
						MedwanQuery.getInstance().getLabel("sendhtmlmail", "findattachment", user.language) + ". <br><br>" +
						"<center><h3>" + sMailTitle + " " + sTransactionId + "</h3></center><center><h3>"+
						MedwanQuery.getInstance().getLabel("web", "patient", user.language) +": "+ patient.lastname.toUpperCase()+" "+sPatientFirstname+" °"+patient.dateOfBirth + "</h3></center>" +
						"<table border='1' width='100%'>" +
						"	<tr BGCOLOR='Lightskyblue'><th>"+MedwanQuery.getInstance().getLabel("web", "labcode", user.language)+"</th><th>" + MedwanQuery.getInstance().getLabel("web", "label", user.language)+"</th><th>"+ MedwanQuery.getInstance().getLabel("web", "value", user.language) +"</th></tr>";
				//Voeg nu de resultaten toe aan de header
				sResult=sHeader+sResult;
				//Voeg nu de footer toe
				sResult+= "</table><br/><br/>"+MedwanQuery.getInstance().getLabel("sendhtmlmail", "closingmail", user.language) + "<br><br>" + MedwanQuery.getInstance().getLabel("sendhtmlmail", "closingmailname", user.language);
				
				// *** Voeg image toe
				sResult=sResult+ 
						"<br><br> <table border='0' width='100%'>" +
						"<tr><td></td> <td></td> <td>" + "</td> </tr></table>";
						
				sResult=sResult+ "</body></html>";									
			}
						
			//Get Email / SMS and Debug	
			if (sSendMode == "SMS"){
				sSMSDestination = getSMSDestinationByTransactionId(sTransactionId).replaceAll(";", " ").replaceAll(",", " ");
				System.out.println("SMS Destination is: " + sSMSDestination);
				System.out.println("Text to send to this SMS is:\n");				
			}
			else {
				sEmailAddress = getEmailAddressByTransactionId(sTransactionId).replaceAll(";", " ").replaceAll(",", " ");									
				System.out.println("Email Address is: " + sEmailAddress);
				System.out.println("Text to send to this emailaddress is:\n");				
			}
			System.out.println(sResult);				
			System.out.println("----------------Writing File  - Sending Mail --------------------" + new java.util.Date());
			
			//Send HTML Mail
			try {
				
				if (sSendMode == "SMS"){
					//sSMSDestination = "+32475621569"; //= "+32473348754"; //prox pay n go ::://String sPinCode = "8821";
					String sPinCode = "2147"; //prox pay n go					
					System.setProperty("smslib.serial.polling", "true");
					SendSMS sendSMS = new SendSMS();
					
					/*
					sResult = sResult + "This is only a test text to complete more than 160 characters ffffffffffffffffffffffffffffffffffff fdfdf \n"+
							"Test 3th lab result\n" +
							"---test test test test --------dddddddddddddddddddddddddddddddddddddddddddddddd before--end\n" + //;
							"---test test test test --------dddddddddddddddddddddddddddddddddddddddddddddddd --end";
							//+ "This is the next line. -------------------llllllllllllllllllllllllllllllllllllllllll--------End";
					*/
					if (sResult.length() > 160){ 
						
						Vector vSMSs = new Vector();
						vSMSs = splitSMSText(sResult);
						Enumeration<String> eSMSs = vSMSs.elements();
						String sSMS;
						while (eSMSs.hasMoreElements()){
							sSMS = eSMSs.nextElement();
							System.out.println("\n --------------- SMS to send is: --------------- \n");
							System.out.println(sSMS);
							System.out.println(" --------------- End of SMS's Vector Enumeration While --------------- \n");
							sendSMS.send("modem.nokia", "/dev/ttyS20", 115200, "Nokia", "2690", sPinCode, sSMSDestination, sSMS);
						}
					}
					else { // sResult.length() <= 160 chars. Send the SMS
						sendSMS.send("modem.nokia", "/dev/ttyS20", 115200, "Nokia", "2690", sPinCode, sSMSDestination, sResult);
					}			
				}
				
				
				//send attachment mail
				//Mail.sendMail(MedwanQuery.getInstance().getConfigString("PatientEdit.MailServer"), "fernando.corral@mxs.be", sEmailAddress, sMailTitle + " " + sTransactionId, sMailTitle + " " + sTransactionId, sAttachment, sFileName);
				if (sSendMode == "simple"){
					//Mail.sendMail(MedwanQuery.getInstance().getConfigString("PatientEdit.MailServer"), "fernando.corral@mxs.be", sEmailAddress, sMailTitle + " " + sTransactionId, sResult);	
					sendHtmlMail.sendSimpleMail(MedwanQuery.getInstance().getConfigString("PatientEdit.MailServer"), "fernando.corral@mxs.be", sEmailAddress, sMailTitle + " " + sTransactionId, sResult);					
				}				
				
				if (sSendMode == "html"){ 	
					//Escape non ascii characters
					sResult=HTMLEntities.htmlentities(sResult);
					String sLogo = "/home/fernando/projectlogo.jpg";	
					sendHtmlMail.sendEmailWithImages(MedwanQuery.getInstance().getConfigString("PatientEdit.MailServer"), "fernando.corral@mxs.be", sEmailAddress, sMailTitle + " " + sTransactionId, sResult, sLogo);														
					//Zonder Logo //sendHtmlMail.sendMail(MedwanQuery.getInstance().getConfigString("PatientEdit.MailServer"), "fernando.corral@mxs.be", sEmailAddress, sMailTitle + " " + sTransactionId, sResult);						
				}

				if (sSendMode == "attach"){
					//Escape non ascii characters
					sResult=HTMLEntities.htmlentities(sResult);
					// *** Write file for Attachment
					String sFileName = "Transaction"+ new SimpleDateFormat("ddMMyyyy-HHmmss").format(new java.util.Date())+"_Tid"+sTransactionId+".html";
					String sAttachment = "/home/fernando/"+sFileName;				
					ProcessFiles.writeFile(sAttachment, sResult);
					
					//send Attachment Html mail with images
					//String sLogo = "/home/fernando/projectlogo.jpg";
					//sendHtmlMail.sendAttachEmailWithImages(MedwanQuery.getInstance().getConfigString("PatientEdit.MailServer"), "fernando.corral@mxs.be", sEmailAddress, sMailTitle + " " + sTransactionId, sMailTitle + " " + sTransactionId, sAttachment, sFileName, sLogo);
					sendHtmlMail.sendAttachEmail(MedwanQuery.getInstance().getConfigString("PatientEdit.MailServer"), "fernando.corral@mxs.be", sEmailAddress, sMailTitle + " " + sTransactionId, sMailTitle + " " + sTransactionId, sAttachment, sFileName);
						
				}
				i = i + 1;				
				//Mail.sendMail(smtpServer, sFrom, sTo, sSubject, sMessage)
			
			} catch (Exception e) {
				if (sSendMode == "SMS"){
					System.out.println("Unable to send SMS to " + sSMSDestination  + new java.util.Date());
				}
				else {
					System.out.println("Unable to send Emailto " + sEmailAddress + "Throu: " + MedwanQuery.getInstance().getConfigString("PatientEdit.MailServer. ") + new java.util.Date());
				}				
				e.printStackTrace();
			}			
		}
		return i;
	}

	public int sendLabResultsSMS(Hashtable htLabsToSendTable){
		Enumeration<String> eTransationIds = htLabsToSendTable.keys();
		int i = 0;
		while (eTransationIds.hasMoreElements()){
			String sTransactionId = eTransationIds.nextElement();
			String sResult = (String)htLabsToSendTable.get(sTransactionId);			
			String sSMSDestination = null;
						
			System.out.println("-------------------------SMS HashTable ----------------------------------------------------------------------------");			
			TransactionVO transactionVO = MedwanQuery.getInstance().loadTransaction(MedwanQuery.getInstance().getConfigInt("serverId"), Integer.parseInt(sTransactionId));
			System.out.println("transactionVO.getHealthrecordId() is: "+transactionVO.getHealthrecordId());
			
			if(transactionVO.getHealthrecordId() == 0){
				MedwanQuery.getInstance().getObjectCache().removeObject("transaction",MedwanQuery.getInstance().getConfigInt("serverId")+"."+sTransactionId);
				transactionVO = MedwanQuery.getInstance().loadTransaction(MedwanQuery.getInstance().getConfigInt("serverId"), Integer.parseInt(sTransactionId));
			}
			
			int personid = MedwanQuery.getInstance().getPersonIdFromHealthrecordId(transactionVO.getHealthrecordId());
			System.out.println("patient.personid="+personid);
			AdminPerson patient = AdminPerson.getAdminPerson(personid+"");
			String sPatientFirstname = patient.firstname;
			sPatientFirstname = sPatientFirstname.charAt(0) + sPatientFirstname.substring(1).toLowerCase();
			
			PersonVO user = transactionVO.getUser().personVO;
			String sUserFirstname = user.firstname;			
			sUserFirstname = sUserFirstname.charAt(0) + sUserFirstname.substring(1).toLowerCase();					
					
			System.out.println("\n ---------------------Debug StringIndexOutOfBoundsException CharAT(0)---------------------------");
			
			System.out.println("patient.firstname is: "+patient.firstname);			
			System.out.println("sPatientFirstname is: " + sPatientFirstname + ". sPatientFirstname.charAt(0) is: " + sPatientFirstname.charAt(0));
			System.out.println("sPatientFirstname.substring(1).toLowerCase() is: " + sPatientFirstname.substring(1).toLowerCase());
			System.out.println("--------------------------------------------End Debug---------------------------------------------------- \n");
			
			sResult = "Lab " + MedwanQuery.getInstance().getLabel("sendhtmlmail", "for", user.language) + " " + patient.lastname.toUpperCase()+" "+sPatientFirstname + "\n" +
						sResult;
			
			sSMSDestination = getSMSDestinationByTransactionId(sTransactionId).replaceAll(";", " ").replaceAll(",", " ");						
			System.out.println("SMS Destination is: " + sSMSDestination);
			System.out.println("Text to send to this SMS is:\n");							
			System.out.println(sResult);				
			System.out.println("----------------Writing File  - Sending SMS --------------------" + new java.util.Date());
						
			try {						
				//sSMSDestination = "+32475621569"; //= "+32473348754"; //prox pay n go ::://String sPinCode = "8821";
				String sPinCode = MedwanQuery.getInstance().getConfigString("smsPincode","2147"); //prox pay n go
				String sPort= MedwanQuery.getInstance().getConfigString("smsDevicePort","/dev/ttyS20");
				int nBaudrate=MedwanQuery.getInstance().getConfigInt("smsBaudrate",115200);
				System.setProperty("smslib.serial.polling", MedwanQuery.getInstance().getConfigString("smsPolling","false"));
				SendSMS sendSMS = new SendSMS();				
				/*
				sResult = sResult + "This is only a test text to complete more than 160 characters ffffffffffffffffffffffffffffffffffff fdfdf \n"+
						"Test 3th lab result\n" +
						"---test test test test --------dddddddddddddddddddddddddddddddddddddddddddddddd before--end\n" + //;
						"---test test test test --------dddddddddddddddddddddddddddddddddddddddddddddddd --end";
						//+ "This is the next line. -------------------llllllllllllllllllllllllllllllllllllllllll--------End";
				*/
				if (sResult.length() > 160){ 					
					Vector vSMSs = new Vector();
					vSMSs = splitSMSText(sResult);
					Enumeration<String> eSMSs = vSMSs.elements();
					String sSMS;
					while (eSMSs.hasMoreElements()){
						sSMS = eSMSs.nextElement();
						System.out.println("\n --------------- SMS to send is: --------------- \n");
						System.out.println(sSMS);
						System.out.println(" --------------- End of SMS's Vector Enumeration While --------------- \n");
						sendSMS.send("modem.nokia",sPort, nBaudrate, "Nokia", "2690", sPinCode, sSMSDestination, sSMS);
					}
				}
				else { // sResult.length() <= 160 chars. Send the SMS
					sendSMS.send("modem.nokia", sPort, nBaudrate, "Nokia", "2690", sPinCode, sSMSDestination, sResult);
				}							
			i = i + 1;
			} catch (Exception e) {				
					System.out.println("Unable to send SMS to " + sSMSDestination  + new java.util.Date());
								
				e.printStackTrace();
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
			
			System.out.println("--------------------------------------In Email HashTable ---------------------------------------------------------------------------------");			
			TransactionVO transactionVO = MedwanQuery.getInstance().loadTransaction(MedwanQuery.getInstance().getConfigInt("serverId"), Integer.parseInt(sTransactionId));
			
			System.out.println("transactionVO.getHealthrecordId() is: "+ transactionVO.getHealthrecordId());
			if( transactionVO.getHealthrecordId() == 0){
				System.out.println("Cache failed to get valid transactionVO. Load it from DB");
				MedwanQuery.getInstance().getObjectCache().removeObject("transaction",MedwanQuery.getInstance().getConfigInt("serverId")+"."+sTransactionId);
				transactionVO = MedwanQuery.getInstance().loadTransaction(MedwanQuery.getInstance().getConfigInt("serverId"), Integer.parseInt(sTransactionId));									
			}					
			int personid = MedwanQuery.getInstance().getPersonIdFromHealthrecordId(transactionVO.getHealthrecordId());
			
			AdminPerson patient = AdminPerson.getAdminPerson(personid+"");
			String sPatientFirstname = patient.firstname;
			
			PersonVO user = transactionVO.getUser().personVO;
			String sUserFirstname = user.firstname;	
			sUserFirstname = sUserFirstname.charAt(0) + sUserFirstname.substring(1).toLowerCase();

			System.out.println("\n ---------------------Debug StringIndexOutOfBoundsException CharAT(0)---------------------------");		
			
			System.out.println("patient.personid="+personid);	
			System.out.println("patient.firstname="+patient.firstname);
			System.out.println("patient.lastname="+patient.lastname);
			System.out.println("sPatientFirstname is: " + sPatientFirstname + ". sPatientFirstname.charAt(0) is: " + sPatientFirstname.charAt(0));
			System.out.println("sPatientFirstname.substring(1).toLowerCase() is: " + sPatientFirstname.substring(1).toLowerCase());
			System.out.println("--------------------------------------------End Debug---------------------------------------------------- \n");

			sPatientFirstname = sPatientFirstname.charAt(0) + sPatientFirstname.substring(1).toLowerCase();
			String sMailTitle = MedwanQuery.getInstance().getLabel("sendhtmlmail", "labrequestfortransaction", user.language);
			
			if (sSendMode == "simple"){ 
				String sHeader = MedwanQuery.getInstance().getLabel("sendhtmlmail", "dear", user.language) + " " +  sUserFirstname + " " + user.lastname + ", \n\n" +
						MedwanQuery.getInstance().getLabel("sendhtmlmail", "findattachment", user.language) + ". \n\n" +
						sMailTitle + " " + sTransactionId + ": \n\n" +
						MedwanQuery.getInstance().getLabel("web", "patient", user.language) +": "+ patient.lastname.toUpperCase()+" "+sPatientFirstname+" °"+patient.dateOfBirth + ", \n\n";
				
				sResult=sHeader+sResult;
				sResult+= "\n\n" + MedwanQuery.getInstance().getLabel("sendhtmlmail", "closingmail", user.language) + "\n\n" + MedwanQuery.getInstance().getLabel("sendhtmlmail", "closingmailname", user.language);
			}
				
			else { //html or attachment				
				if (sSendMode == "html" || sSendMode == "attach") {						
						if (sSendMode == "html"){
							sImage = "<img src=\"cid:image_logo\">";
						}
						else  {
							sImage = "<img src=\"http://www.mxs.be/openclinic/_img/projectlogo.jpg\">";
						}						
				} 
						
				String sHeader = "<html><body style='height:100%;background-color: #DCEDFF'>"+
						"<table border='0' width='100%'><tr><td>" + MedwanQuery.getInstance().getLabel("sendhtmlmail", "dear", user.language) + " " +  sUserFirstname + " " + user.lastname + ", </td> <td></td> <td ALIGN='right'> " + sImage + "</td> </tr></table> <br>" +			
						MedwanQuery.getInstance().getLabel("sendhtmlmail", "findattachment", user.language) + ". <br><br>" +
						"<center><h3>" + sMailTitle + " " + sTransactionId + "</h3></center><center><h3>"+
						MedwanQuery.getInstance().getLabel("web", "patient", user.language) +": "+ patient.lastname.toUpperCase()+" "+sPatientFirstname+" °"+patient.dateOfBirth + "</h3></center>" +
						"<table border='1' width='100%'>" +
						"	<tr BGCOLOR='Lightskyblue'><th>"+MedwanQuery.getInstance().getLabel("web", "labcode", user.language)+"</th><th>" + MedwanQuery.getInstance().getLabel("web", "label", user.language)+"</th><th>"+ MedwanQuery.getInstance().getLabel("web", "value", user.language) +"</th></tr>";

				sResult=sHeader+sResult;
				sResult+= "</table><br/><br/>"+MedwanQuery.getInstance().getLabel("sendhtmlmail", "closingmail", user.language) + "<br><br>" + MedwanQuery.getInstance().getLabel("sendhtmlmail", "closingmailname", user.language);
				
				// *** Voeg image toe
				sResult=sResult+ 
						"<br><br> <table border='0' width='100%'>" +
						"<tr><td></td> <td></td> <td>" + "</td> </tr></table>";
						
				sResult=sResult+ "</body></html>";									
			}
						
			//Get Email
			sEmailAddress = getEmailAddressByTransactionId(sTransactionId).replaceAll(";", " ").replaceAll(",", " ");									
			System.out.println("Email Address is: " + sEmailAddress);
			System.out.println("Text to send to this emailaddress is:\n");				
			System.out.println(sResult);				
			System.out.println("----------------Writing File  - Sending Mail --------------------" + new java.util.Date());
			
			//Send  Mail
			try {				
				//send attachment mail
				//Mail.sendMail(MedwanQuery.getInstance().getConfigString("PatientEdit.MailServer"), "fernando.corral@mxs.be", sEmailAddress, sMailTitle + " " + sTransactionId, sMailTitle + " " + sTransactionId, sAttachment, sFileName);
				if (sSendMode == "simple"){
					//Mail.sendMail(MedwanQuery.getInstance().getConfigString("PatientEdit.MailServer"), "fernando.corral@mxs.be", sEmailAddress, sMailTitle + " " + sTransactionId, sResult);	
					sendHtmlMail.sendSimpleMail(MedwanQuery.getInstance().getConfigString("PatientEdit.MailServer"), "fernando.corral@mxs.be", sEmailAddress, sMailTitle + " " + sTransactionId, sResult);					
				}				
				
				if (sSendMode == "html"){ 	
					//Escape non ascii characters
					sResult=HTMLEntities.htmlentities(sResult);
					String sLogo = "/projects/openclinic/web/_img/projectlogo.jpg";	
					sendHtmlMail.sendEmailWithImages(MedwanQuery.getInstance().getConfigString("PatientEdit.MailServer"), "fernando.corral@mxs.be", sEmailAddress, sMailTitle + " " + sTransactionId, sResult, sLogo);														
					//Zonder Logo //sendHtmlMail.sendMail(MedwanQuery.getInstance().getConfigString("PatientEdit.MailServer"), "fernando.corral@mxs.be", sEmailAddress, sMailTitle + " " + sTransactionId, sResult);						
				}

				if (sSendMode == "attach"){
					//Escape non ascii characters
					sResult=HTMLEntities.htmlentities(sResult);
					// *** Write file for Attachment
					
					String sFileName = "Transaction"+ new SimpleDateFormat("ddMMyyyy-HHmmss").format(new java.util.Date())+"_Tid"+sTransactionId+".html";
					String sTempDir = "";
					System.out.println("String curDir = System.getProperty(\"user.dir\")" + System.getProperty("user.dir"));
					System.out.println("MedwanQuery.getInstance().getConfigString(\"tempDir\") " + MedwanQuery.getInstance().getConfigString("tempDir"));
	                if(MedwanQuery.getInstance().getConfigString("tempDir").length() > 0){
	                    sTempDir = MedwanQuery.getInstance().getConfigString("tempDir");
	                }
					
	                String sAttachment = "/tmp/"+sFileName;				
					ProcessFiles.writeFile(sAttachment, sResult);
					
					//send Attachment Html mail with images					
					sendHtmlMail.sendAttachEmail(MedwanQuery.getInstance().getConfigString("PatientEdit.MailServer"), "fernando.corral@mxs.be", sEmailAddress, sMailTitle + " " + sTransactionId, sMailTitle + " " + sTransactionId, sAttachment, sFileName);						
				}
				i = i + 1;								
			
			} catch (Exception e) {
				System.out.println("Unable to send Emailto " + sEmailAddress + "Throu: " + MedwanQuery.getInstance().getConfigString("PatientEdit.MailServer. ") + new java.util.Date());
				e.printStackTrace();
			}			
		}
		return i;
	}

	
	public static Vector<String> splitSMSText(String sResult){
		Vector<String> vSMSs = new Vector<String>();		
		String[] aLines = sResult.split("\n");
		//System.out.println("Array sSMS lenght is: " + aLines.length);
		for (int i = 0; i<aLines.length; i++){
			System.out.println("Lenght of Line [" + i + "] is: " + aLines[i].length() + " " + aLines[i] );
		}
		
		if (aLines[0].length() >= 160) {
			System.out.println("Patient Name is to long. No place to send SMS: " + aLines[0]);			
		}
		else {
			int iMsgsSend = 1;
			String sMsgToSend = aLines[0]+" (" + iMsgsSend + ")";
			int iLabLineToAdd = 1;
			int iLabLinesSent = 0;			
			String sNextLabLine;
			while (iLabLinesSent < aLines.length - 1) { // eg from 0 to 2
				sNextLabLine = aLines[iLabLineToAdd];
				if (sMsgToSend.length() + sNextLabLine.length() <= 160) {					
					sMsgToSend = sMsgToSend + "\n" + sNextLabLine;
					System.out.println("sMsgToSend = sMsgToSend + aLines[iLabLineToAdd]; Msg to send is: \n" +sMsgToSend + " \n iLabLineToADDED is: " + iLabLineToAdd);
					iLabLineToAdd = iLabLineToAdd + 1;
					iLabLinesSent = iLabLinesSent + 1;
					if (iLabLinesSent == aLines.length - 1){ // last line
						System.out.println("end of process. last Message to send is:\n" + sMsgToSend);
						vSMSs.add(sMsgToSend);						
					}
					else {
						System.out.println(" iLabLineToAdd increased by one is now: " + iLabLineToAdd);
						System.out.println(" iLabLinesSent increased by one is now: " + iLabLinesSent);											
					}
					System.out.println(" ---------------------------- end if condition ------------------------------------------------------------");
				}
				else { // Longer than 160 ==>> Send earlier one									
					System.out.println("Message passed the limit lenght, previous Message:\n" + sMsgToSend + "\n added to Vector to be send: \n");	
					vSMSs.add(sMsgToSend);						
					iMsgsSend = iMsgsSend + 1;
					sMsgToSend = aLines[0]+" (" + iMsgsSend + ")";
					System.out.println(" ---------------------------- end else condition ------------------------------------------------------------");							
				}								
			}			
		}
		return vSMSs;
	}
	
	public static Vector<String> splitSMSText_copy(String sResult){
		Vector<String> vSMSs = new Vector<String>();		
		String[] aSMS = sResult.split("\n");
		//System.out.println("Array sSMS lenght is: " + aSMS.length);
		/*
		for (int i = 0; i<aSMS.length; i++){
			System.out.println("Lenght of Line [" + i + "] is: " + aSMS[i].length() + " " + aSMS[i] );
		}
		*/
		if (aSMS[0].length() >= 160) {
			System.out.println("Patient Name is to long. No place to send SMS: " + aSMS[0]);			
		}
		else {
			int iMsgsSend = 1;
			String sMsgToSend = aSMS[0]+" (" + iMsgsSend + ")";
			int iLabLineToAdd = 1;
			int iLabLinesSent = 0;			
			String sNextLabLine;
			while (iLabLinesSent < aSMS.length - 1) { // || iMsgsSend <= aSMS.length
				sNextLabLine = aSMS[iLabLineToAdd];
				if (sMsgToSend.length() + sNextLabLine.length() <= 160) {					
					sMsgToSend = sMsgToSend + "\n" + sNextLabLine;
					System.out.println("sMsgToSend = sMsgToSend + aSMS[iLabLineToAdd]; Msg to send is: \n" +sMsgToSend + " \n iLabLineToADDED is: " + iLabLineToAdd);
					iLabLineToAdd = iLabLineToAdd + 1;
					iLabLinesSent = iLabLinesSent + 1;
					if (iLabLinesSent == aSMS.length - 1){ // last line
						System.out.println("end of process. last Message to send is:\n" + sMsgToSend);
						vSMSs.add(sMsgToSend);						
					}
					else {
						System.out.println(" iLabLineToAdd increased by one is now: " + iLabLineToAdd);
						System.out.println(" iLabLinesSent increased by one is now: " + iLabLinesSent);											
					}
					System.out.println(" ---------------------------- end if condition ------------------------------------------------------------");
				}
				else { // Longer than 160 ==>> Send earlier one									
					System.out.println("Message passed the limit lenght, previous Message:\n" + sMsgToSend + "\n added to Vector to be send: \n");	
					vSMSs.add(sMsgToSend);						
					iMsgsSend = iMsgsSend + 1;
					sMsgToSend = aSMS[0]+" (" + iMsgsSend + ")";
					System.out.println(" ---------------------------- end else condition ------------------------------------------------------------");							
				}								
			}			
		}
		return vSMSs;
	}
	
	public static Vector<String> splitSMSText1(String sResult){
		Vector<String> vSMSs = new Vector<String>();		
		String[] aLines = sResult.split("\n");
		for (int i = 0; i<aLines.length; i++){
			System.out.println("Lenght of Line [" + i + "] is: " + aLines[i].length() + " " + aLines[i] );
		}
		//System.out.println("Array sSMS lenght is: " + aLines.length);
		if (aLines[0].length() >= 160) {
			System.out.println("Patient Name is to long. No place to send SMS: " + aLines[0]);			
		}
		else {
			String sNameLine = aLines[0];
			int iSentMsgs = 1;
			String sMsgToSend = sNameLine + " (" + iSentMsgs + ")"; 			
			for (int iNextLab = 1; iNextLab < aLines.length; iNextLab ++) { 
				//aLines[iNextLab] = aLines[iNextLab];
				if (sMsgToSend.length() + aLines[iNextLab].length() == 160) {					
					vSMSs.add(sMsgToSend + "\n" + aLines[iNextLab]);
					System.out.println("== 160: vSMSs.add(sMsgToSend + \n + aLines[iNextLab]) \n" + sMsgToSend + "\n" + aLines[iNextLab] + "\n Added to Vector vSMSs" + "\n");
					sMsgToSend = sNameLine + " (" + iSentMsgs + ")";
					iSentMsgs++;
					
				}
				else if (sMsgToSend.length() + aLines[iNextLab].length() > 160) { // Send previous message And decrement iNextlab
					vSMSs.add(sMsgToSend);			
					System.out.println("> 160: vSMSs.add(sMsgToSend) \n " + sMsgToSend  + " Added to Vector vSMSs" + "\n");
					sMsgToSend = sNameLine + " (" + iSentMsgs + ")";					
					iSentMsgs++;
					iNextLab = iNextLab - 1;
				}
				else {// < 160					
					sMsgToSend = sMsgToSend + "\n" + aLines[iNextLab];
					System.out.println("< 160: sMsgToSend = sMsgToSend + aLines[iNextLab]; Becomes: \n"  + sMsgToSend + "\n");
					if (iNextLab == aLines.length - 1){ // Last Line
						vSMSs.add(sMsgToSend);	
						System.out.println("Last Line and < 160: vSMSs.add(sMsgToSend) \n " + sMsgToSend  + " Added to Vector vSMSs" + "\n");
					}
				}
			}			
		}
		return vSMSs;
	}

	public static Vector<String> splitSMSText3(String sResult){
		Vector<String> vSMSs = new Vector<String>();		
		String[] aLines = sResult.split("\n");
		//System.out.println("Array sSMS lenght is: " + aLines.length);
		if (aLines[0].length() >= 160) {
			System.out.println("Patient Name is to long. No place to send SMS: " + aLines[0]);			
		}
		else {
			String sNameLine = aLines[0];
			int iSentMsgs = 1;
			String sMsgToSend = sNameLine + " (" + iSentMsgs + ")"; 
			String sLabLineToAdd;
			for (int iNextLab = 1; iNextLab < aLines.length; iNextLab ++) { 
				sLabLineToAdd = aLines[iNextLab];
				if (sMsgToSend.length() + aLines[iNextLab].length() == 160) {					
					vSMSs.add(sMsgToSend + "\n" + sLabLineToAdd);
					System.out.println("== 160: vSMSs.add(sMsgToSend + \n + sLabLineToAdd) \n" + sMsgToSend + "\n" + sLabLineToAdd + "\n Added to Vector vSMSs" + "\n");
					sMsgToSend = sNameLine + " (" + iSentMsgs + ")";
					iSentMsgs++;
					
				}
				else if (sMsgToSend.length() + aLines[iNextLab].length() > 160) { // Send previous message And decrement iNextlab
					vSMSs.add(sMsgToSend);			
					System.out.println("> 160: vSMSs.add(sMsgToSend) \n " + sMsgToSend  + " Added to Vector vSMSs" + "\n");
					sMsgToSend = sNameLine + " (" + iSentMsgs + ")";					
					iSentMsgs++;
					iNextLab = iNextLab - 1;
				}
				else {// < 160					
					sMsgToSend = sMsgToSend + "\n" + sLabLineToAdd;
					System.out.println("< 160: sMsgToSend = sMsgToSend + sLabLineToAdd; Becomes: \n"  + sMsgToSend + "\n");
					if (iNextLab == aLines.length - 1){ // Last Line
						vSMSs.add(sMsgToSend);	
						System.out.println("Last Line and < 160: vSMSs.add(sMsgToSend) \n " + sMsgToSend  + " Added to Vector vSMSs" + "\n");
					}
				}
			}			
		}
		return vSMSs;
	}
		
	public String getSMSDestinationByTransactionId(String sTransactionId){
		//use this: MedwanQuery.getInstance().getConfigInt("serverId")
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
			System.out.println("Unable to execute the query");
			e.printStackTrace();
			return null;
		}		
	}

	
	public String getEmailAddressByTransactionId(String sTransactionId){		
		// Does the same as MedwanQuery.getItem() but we have no ServerId here. Unique key??  
		// Need for other solution? 1. create (again) an RequestedLabAnalysis object?, 2. Include emailaddress in another Hashtable?
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
			System.out.println("Unable to execute the query");
			e.printStackTrace();
			return null;
		}		
	}

}
