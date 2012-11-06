<%@ page import="be.mxs.common.util.io.*,be.openclinic.finance.*" %>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>
<%
	java.text.DecimalFormat priceFormat = new java.text.DecimalFormat(MedwanQuery.getInstance().getConfigString("priceFormat","#,##0.00"));
	String sCurrency = MedwanQuery.getInstance().getConfigParam("currency","EUR");
	String credituid = checkString(request.getParameter("credituid"));
	String creditnumber="";
	if(credituid.split("\\.").length>1){
		creditnumber=credituid.split("\\.")[1];
	}
	PatientCredit credit = PatientCredit.get(credituid);
	if(credit!=null){
		JavaPOSPrinter printer = new JavaPOSPrinter();
		String content="";
		//Create the receipt content
		int receiptid=MedwanQuery.getInstance().getOpenclinicCounter("RECEIPT");
		if(receiptid>=MedwanQuery.getInstance().getConfigInt("maximumNumberOfReceipts",10000)){
			MedwanQuery.getInstance().setOpenclinicCounter("RECEIPT",0);
		}
		content+=printer.CENTER+receiptid+" - "+printer.BOLD+getTran("web","receiptforcredit",sWebLanguage).toUpperCase()+" #"+creditnumber+" - "+new SimpleDateFormat("dd/MM/yyyy").format(credit.getDate())+printer.NOTBOLD+printer.LF;
        double totalCredit=credit.getAmount();
        //Patientgegevens
        content+=printer.LF;
		AdminPerson person = AdminPerson.getAdminPerson(credit.getPatientUid());
		if(person!=null){
	        content+=printer.LEFT+(getTran("web","patient",sWebLanguage)+":              ").substring(0,15)+" "+printer.BOLD+person.lastname.toUpperCase()+", "+person.firstname+printer.NOTBOLD+printer.LF;
			content+=printer.LEFT+"                "+printer.BOLD+person.personid+printer.NOTBOLD+printer.LF;
			content+=printer.LEFT+"                "+printer.BOLD+person.dateOfBirth+"   "+person.gender.toUpperCase()+printer.NOTBOLD+printer.LF;
	        //Verzekeringsgegevens
            Insurance insurance = Insurance.getMostInterestingInsuranceForPatient(person.personid);
			content+=printer.LEFT+(getTran("web","insurance",sWebLanguage)+":              ").substring(0,15)+printer.BOLD+insurance.getInsurar().getName()+" ("+insurance.getInsuranceNr()+")"+printer.NOTBOLD+printer.LF;
			//Afrdukken van de dienst gelinked aan het contact
			content+=printer.LEFT+(getTran("web","service",sWebLanguage)+":              ").substring(0,15)+printer.BOLD;
			Encounter encounter = credit.getEncounter();
			if(encounter!=null && encounter.getService()!=null){
				content+=encounter.getService().getLabel(sWebLanguage);
			}
			content+=printer.NOTBOLD+printer.LF;
	        content+=printer.LF;
			//Afdrukken van betalingsgegevens
			content+=printer.LEFT+printer.UNDERLINE+getTran("web","payments",sWebLanguage)+printer.NOTUNDERLINE+printer.LF;
            content+=printer.LEFT+new SimpleDateFormat("dd/MM/yyyy").format(credit.getDate())+"  "+getTran("credit.type",credit.getType(),sWebLanguage)+": "+priceFormat.format(credit.getAmount())+" "+sCurrency+printer.LF;
			//Totale kost en betalingen
			content+=printer.LEFT+printer.UNDERLINE+"                                                                              ".substring(0,48)+printer.NOTUNDERLINE+printer.LF;
			content+=printer.LEFT+printer.DOUBLE+getTran("web.finance","balance",sWebLanguage)+": "+priceFormat.format(credit.getAmount())+" "+sCurrency+printer.NOTBOLD+printer.REGULAR+printer.LF;
			out.print("{\"message\":\""+printer.printReceipt(activeUser.project, sWebLanguage,content,"8"+creditnumber)+"\"}");
		}
	}
	else {
		out.print("{\"message\":\""+ScreenHelper.getTranNoLink("web","javapos.patientinvoicedoesnotexist",sWebLanguage)+"\"}");
	}
%>