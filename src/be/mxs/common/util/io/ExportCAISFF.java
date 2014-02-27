package be.mxs.common.util.io;

import java.io.BufferedWriter;
import java.io.FileWriter;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Timestamp;
import java.text.DecimalFormat;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.Vector;

import org.apache.commons.httpclient.HttpClient;
import org.apache.commons.httpclient.NameValuePair;
import org.apache.commons.httpclient.methods.PostMethod;
import org.dom4j.Document;
import org.dom4j.DocumentHelper;
import org.dom4j.Element;

import net.admin.User;

import be.mxs.common.util.db.MedwanQuery;
import be.mxs.common.util.system.Mail;
import be.mxs.common.util.system.Pointer;
import be.mxs.common.util.system.ScreenHelper;
import be.openclinic.finance.Debet;
import be.openclinic.finance.PatientInvoice;

public class ExportCAISFF {

	/**
	 * @param args
	 */
	
	
	public static void main(String[] args) {

		//Find date of last export
		try {
			// This will load the MySQL driver, each DB has its own driver
		    Class.forName("com.mysql.jdbc.Driver");			
		    Connection conn =  DriverManager.getConnection("jdbc:mysql://localhost:3306/openclinic_dbo?"+args[0]);
			
		    Date lastexport = new SimpleDateFormat("yyyyMMddHHmmssSSS").parse("19000101000000000");
			PreparedStatement ps = conn.prepareStatement("select oc_value from oc_config where oc_key='lastCAISFFexport'");
		    ResultSet rs = ps.executeQuery();
		    if(rs.next()){
				lastexport = new SimpleDateFormat("yyyyMMddHHmmssSSS").parse(rs.getString("oc_value"));
			    System.out.println("lastExport="+lastexport);
		    }
		    rs.close();
		    ps.close();

		    String postURL="http://localhost/openclinic/util/storeCaisffData.jsp";
			ps = conn.prepareStatement("select oc_value from oc_config where oc_key='CAISFFpostURL'");
		    rs = ps.executeQuery();
		    if(rs.next()){
		    	postURL = rs.getString("oc_value");
			    System.out.println("postURL="+postURL);
		    }
		    rs.close();
		    ps.close();
		    
		    String caisffId="?";
			ps = conn.prepareStatement("select oc_value from oc_config where oc_key='CAISFFID'");
		    rs = ps.executeQuery();
		    if(rs.next()){
		    	caisffId = rs.getString("oc_value");
			    System.out.println("caisffId="+caisffId);
		    }
		    rs.close();
		    ps.close();
		    
		    boolean hasPayments=false;
		    java.util.Date maxDate = lastexport;
	        Document document = DocumentHelper.createDocument();
	        Element message = DocumentHelper.createElement("message");
	        message.addAttribute("caisffid", caisffId);
	        document.setRootElement(message);
	        Element payment = null;
	        Vector debets=null;
	        
	        String patientid="",patientlastname="",patientfirstname="";
		    //Now find all payments that occurred after lastexport
		    String sQuery = "select * from oc_wicket_credits where oc_wicket_credit_updatetime>? order by oc_wicket_credit_updatetime";
		    ps=conn.prepareStatement(sQuery);
		    ps.setTimestamp(1, new java.sql.Timestamp(lastexport.getTime()));
		    rs=ps.executeQuery();
		    while(rs.next()){
		    	hasPayments=true;
		    	boolean bIsPatientInvoice = false;
		    	String sType = ScreenHelper.checkString(rs.getString("OC_WICKET_CREDIT_TYPE"));
		    	String sInvoice = ScreenHelper.checkString(rs.getString("OC_WICKET_CREDIT_INVOICEUID"));
	    		double paidamount = rs.getDouble("OC_WICKET_CREDIT_AMOUNT");
	    		double invoiceamount=0;
		    	maxDate = rs.getTimestamp("OC_WICKET_CREDIT_UPDATETIME");
		    	java.util.Date creditdate=rs.getDate("OC_WICKET_CREDIT_OPERATIONDATE");
		    	String creditid=rs.getString("OC_WICKET_CREDIT_OBJECTID");
    			String username="";
    			PreparedStatement ps2 = conn.prepareStatement("select b.lastname,b.firstname from usersview a,adminview b where a.personid=b.personid and a.userid=?");
    			ps2.setInt(1, rs.getInt("OC_WICKET_CREDIT_UPDATEUID"));
    			ResultSet rs2 = ps2.executeQuery();
    			if(rs2.next()){
    				username=(ScreenHelper.checkString(rs2.getString("lastname"))+", "+ScreenHelper.checkString(rs2.getString("firstname"))).toUpperCase();
    			}
    			rs2.close();
    			ps2.close();
	    		debets=new Vector();

		    	if(sType.equalsIgnoreCase("patient.payment") && sInvoice.length()>0){
		    		//We found a patient payment, now let's look for the invoice connected to the payment
		    		ps2 = conn.prepareStatement("select * from oc_debets a,oc_encounters b,oc_prestations c where b.oc_encounter_objectid=replace(oc_debet_encounteruid,'1.','') and oc_prestation_objectid=replace(oc_debet_prestationuid,'1.','') and oc_debet_patientinvoiceuid=? and oc_debet_credited=0");
		    		ps2.setString(1, sInvoice);
		    		rs2 = ps2.executeQuery();
		    		while(rs2.next()){
		    			LocalDebet debet = new LocalDebet();
		    			debet.encounterType=rs2.getString("OC_ENCOUNTER_TYPE");
		    			debet.encounterType=debet.encounterType.equalsIgnoreCase("visit")?"C":debet.encounterType.equalsIgnoreCase("admission")?"H":"O";
		    			debet.encounterUid=rs2.getString("OC_ENCOUNTER_OBJECTID");
		    			debet.insurerAmount=rs2.getDouble("OC_DEBET_INSURARAMOUNT")+rs2.getDouble("OC_DEBET_EXTRAINSURARAMOUNT");
		    			debet.patientAmount=rs2.getDouble("OC_DEBET_AMOUNT");
		    			debet.prestationCode=rs2.getString("OC_PRESTATION_CODE");
		    			debet.prestationName=rs2.getString("OC_PRESTATION_DESCRIPTION");
		    			debet.quantity=rs2.getInt("OC_DEBET_QUANTITY");
		    			debet.uid=rs2.getString("OC_DEBET_OBJECTID");
		    			debet.date=rs2.getDate("OC_DEBET_DATE");
		    			debets.add(debet);
		    			invoiceamount+=debet.patientAmount;
		    			bIsPatientInvoice = true;
		    		}
		    		rs2.close();
		    		ps2.close();
		    		ps2 = conn.prepareStatement("select * from adminview a,oc_patientinvoices b where a.personid=b.oc_patientinvoice_patientuid and b.oc_patientinvoice_objectid=?");
		    		ps2.setInt(1, Integer.parseInt(sInvoice.split("\\.")[1]));
		    		rs2 = ps2.executeQuery();
		    		if(rs2.next()){
		    			patientid=rs2.getString("personid");
		    			patientfirstname=rs2.getString("firstname").toUpperCase();
		    			patientlastname=rs2.getString("lastname").toUpperCase();
		    		}
		    		rs2.close();
		    		ps2.close();
		    	}
		    	
		    	if(bIsPatientInvoice){
		    		double pct = 100;
		    		if(invoiceamount>0){
			    		pct=paidamount*100/invoiceamount;
		    		}
		    		if(pct>100){
		    			pct=100;
		    		}
		    		//First write a line for each debet in the invoice with a coverage of pct
		    		for(int n=0;n<debets.size();n++){
		    			LocalDebet debet = (LocalDebet)debets.elementAt(n);
		    			payment = message.addElement("payment");
		    			payment.addElement("prest_id").addText(debet.uid);
		    			payment.addElement("prest_date").addText(new SimpleDateFormat("yyyyMMdd").format(debet.date));
		    			payment.addElement("contact_type").addText(debet.encounterType);
		    			payment.addElement("contact_id").addText(debet.encounterUid);
		    			payment.addElement("hosp_id").addText(patientid);
		    			payment.addElement("pat_lastname").addText( patientlastname);
		    			payment.addElement("pat_firstname").addText( patientfirstname);
		    			payment.addElement("prest_code").addText(debet.prestationCode);
		    			payment.addElement("prest_name").addText( debet.prestationName);
		    			payment.addElement("prest_price").addText(new DecimalFormat("#0.00").format((debet.patientAmount+debet.insurerAmount)/debet.quantity));
		    			payment.addElement("prest_quantity").addText( debet.quantity+"");
		    			payment.addElement("inv_am").addText(new DecimalFormat("#0.00").format(debet.insurerAmount));
		    			payment.addElement("inv_patient").addText(new DecimalFormat("#0.00").format(debet.patientAmount));
		    			payment.addElement("inv_patientref").addText(sInvoice.split("\\.")[1]);
		    			payment.addElement("inv_paid").addText( new DecimalFormat("#0.00").format(debet.patientAmount*pct/100));
		    			payment.addElement("inv_percentpaid").addText( new DecimalFormat("#0.00").format(pct));
		    			payment.addElement("payment_id").addText(creditid);
		    			payment.addElement("payment_date").addText( new SimpleDateFormat("yyyyMMdd").format(creditdate));
		    			payment.addElement("payment_agent").addText( username);
		    		}
		    		//If paidamount>invoiceamount, add a line for the remaining amount
		    		if(paidamount>invoiceamount){
		    			payment = message.addElement("payment");
		    			payment.addElement("prest_id").addText("0");
		    			payment.addElement("prest_date").addText( new SimpleDateFormat("yyyyMMdd").format(creditdate));
		    			payment.addElement("contact_type").addText( "O");
		    			payment.addElement("contact_id").addText( "0");
		    			payment.addElement("hosp_id").addText( "0");
		    			payment.addElement("pat_lastname").addText( patientlastname);
		    			payment.addElement("pat_firstname").addText( patientfirstname);
		    			payment.addElement("prest_code").addText( "");
		    			payment.addElement("prest_name").addText( "OVERPAYMENT - EXCEDENT DE PAIEMENT");
		    			payment.addElement("prest_price").addText( new DecimalFormat("#0.00").format(paidamount-invoiceamount));
		    			payment.addElement("prest_quantity").addText( "1");
		    			payment.addElement("inv_am").addText("0");
		    			payment.addElement("inv_patient").addText( "0");
		    			payment.addElement("inv_patientref").addText( "0");
		    			payment.addElement("inv_paid").addText( new DecimalFormat("#0.00").format(paidamount-invoiceamount));
		    			payment.addElement("inv_percentpaid").addText("100");
		    			payment.addElement("payment_id").addText( creditid);
		    			payment.addElement("payment_date").addText(new SimpleDateFormat("yyyyMMdd").format(creditdate));
		    			payment.addElement("payment_agent").addText( username);
		    		}
		    		
		    	}
		    	else {
		    		//Add a single line for the payment
	    			payment = message.addElement("payment");
	    			payment.addElement("prest_id").addText("0");
	    			payment.addElement("prest_date").addText( new SimpleDateFormat("yyyyMMdd").format(creditdate));
	    			payment.addElement("contact_type").addText("O");
	    			payment.addElement("contact_id").addText("0");
	    			payment.addElement("hosp_id").addText("0");
	    			payment.addElement("pat_lastname").addText("");
	    			payment.addElement("pat_firstname").addText("");
	    			payment.addElement("prest_code").addText("");
	    			payment.addElement("prest_name").addText(rs.getString("OC_WICKET_CREDIT_COMMENT"));
	    			payment.addElement("prest_price").addText( new DecimalFormat("#0.00").format(paidamount));
	    			payment.addElement("prest_quantity").addText( "1");
	    			payment.addElement("inv_am").addText( "0");
	    			payment.addElement("inv_patient").addText( "0");
	    			payment.addElement("inv_patientref").addText( "0");
	    			payment.addElement("inv_paid").addText( new DecimalFormat("#0.00").format(paidamount));
	    			payment.addElement("inv_percentpaid").addText( "100");
	    			payment.addElement("payment_id").addText(creditid);
	    			payment.addElement("payment_date").addText( new SimpleDateFormat("yyyyMMdd").format(creditdate));
	    			payment.addElement("payment_agent").addText( username);
		    	}
		    	if(message.asXML().length()>=100000){
					HttpClient client = new HttpClient();
					String url = postURL;
					PostMethod method = new PostMethod(url);
					method.addParameter("message",message.asXML());
					System.out.println("message size ="+message.asXML().length());
					System.out.println("posting to "+url);
					System.out.println("maxDate = "+maxDate);
					int statusCode = client.executeMethod(method);
					String resultstring=method.getResponseBodyAsString();
					System.out.println("result="+resultstring);
					if(resultstring.contains("<OK>")){
						ps2 = conn.prepareStatement("delete from oc_config where oc_key='lastCAISFFexport'");
					    ps2.execute();
					    ps2.close();
						ps2 = conn.prepareStatement("insert into oc_config(oc_key,oc_value) values('lastCAISFFexport',?)");
						ps2.setString(1, new SimpleDateFormat("yyyyMMddHHmmssSSS").format(maxDate));
					    ps2.execute();
					    ps2.close();
					}
					else {
						conn.close();
						return;
					}
			        message = DocumentHelper.createElement("message");
			        message.addAttribute("caisffid", caisffId);
		    	}
		    }
		    rs.close();
		    ps.close();
		    
			System.out.println("starting post");
			HttpClient client = new HttpClient();
			String url = postURL;
			PostMethod method = new PostMethod(url);
			method.addParameter("message",message.asXML());
			System.out.println("message size ="+message.asXML().length());
			System.out.println("posting to "+url);
			int statusCode = client.executeMethod(method);
			String resultstring=method.getResponseBodyAsString();
			System.out.println("result="+resultstring);
			if(resultstring.contains("<OK>")){
				ps = conn.prepareStatement("delete from oc_config where oc_key='lastCAISFFexport'");
			    ps.execute();
			    ps.close();
				ps = conn.prepareStatement("insert into oc_config(oc_key,oc_value) values('lastCAISFFexport',?)");
				ps.setString(1, new SimpleDateFormat("yyyyMMddHHmmssSSS").format(maxDate));
			    ps.execute();
			    ps.close();
			}
		    
		    conn.close();

		} catch (Exception e) {
			e.printStackTrace();
		}
		

	}

}
