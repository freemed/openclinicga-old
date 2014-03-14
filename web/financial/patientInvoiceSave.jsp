<%@ page import="be.mxs.common.util.system.HTMLEntities,be.openclinic.finance.PatientInvoice,java.util.*
,be.openclinic.finance.PatientCredit,be.openclinic.adt.Encounter,be.openclinic.finance.Debet,java.math.BigDecimal" %>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>
<%
    String sEditDate = checkString(request.getParameter("EditDate"));
    String sEditPatientInvoiceUID = checkString(request.getParameter("EditPatientInvoiceUID"));
    String sEditInvoiceUID = checkString(request.getParameter("EditInvoiceUID"));
    String sEditStatus = checkString(request.getParameter("EditStatus"));
    String sEditBalance = checkString(request.getParameter("EditBalance"));
    String sEditCBs = checkString(request.getParameter("EditCBs"));
    String sEditInvoiceSeries = checkString(request.getParameter("EditInvoiceSeries"));
    String sEditInsurarReference = checkString(request.getParameter("EditInsurarReference"));
    String sEditInvoiceVerifier = checkString(request.getParameter("EditInvoiceVerifier"));
    String sEditInsurarReferenceDate = checkString(request.getParameter("EditInsurarReferenceDate"));
    String sEditReduction = checkString(request.getParameter("EditReduction"));
    String sEditComment = checkString(request.getParameter("EditComment"));
    String acceptationuid = checkString(request.getParameter("EditAcceptationUid"));
    String sEditInvoiceDoctor=checkString(request.getParameter("EditInvoiceDoctor"));
    String sEditInvoicePost=checkString(request.getParameter("EditInvoicePost"));
    String sEditInvoiceAgent=checkString(request.getParameter("EditInvoiceAgent"));
    String sEditInvoiceDrugsIdCard=checkString(request.getParameter("EditInvoiceDrugsIdCard"));
    String sEditInvoiceDrugsRecipient=checkString(request.getParameter("EditInvoiceDrugsRecipient"));
    String sEditInvoiceDrugsIdCardPlace=checkString(request.getParameter("EditInvoiceDrugsIdCardPlace"));
    String sEditInvoiceDrugsIdCardDate=checkString(request.getParameter("EditInvoiceDrugsIdCardDate"));
	
    PatientInvoice patientinvoice = new PatientInvoice();
    AdminPerson invoicePatient=activePatient;

    if (sEditPatientInvoiceUID.length() > 0) {
        PatientInvoice oldpatientinvoice = PatientInvoice.get(sEditPatientInvoiceUID);
        if(oldpatientinvoice!=null){
            patientinvoice.setCreateDateTime(oldpatientinvoice.getCreateDateTime());
            patientinvoice.setNumber(oldpatientinvoice.getNumber());
            patientinvoice.setAcceptationUid(oldpatientinvoice.getAcceptationUid());
           	patientinvoice.setAcceptationDate(oldpatientinvoice.getAcceptationDate());
            invoicePatient=oldpatientinvoice.getPatient();
        }
    } else {
        patientinvoice.setCreateDateTime(getSQLTime());
    }

    patientinvoice.setStatus(sEditStatus);
    patientinvoice.setPatientUid(invoicePatient.personid);
    patientinvoice.setInvoiceUid(sEditInvoiceUID);
    patientinvoice.setDate(ScreenHelper.getSQLDate(sEditDate));
    patientinvoice.setUid(sEditPatientInvoiceUID);
    patientinvoice.setUpdateDateTime(ScreenHelper.getSQLDate(getDate()));
    patientinvoice.setUpdateUser(activeUser.userid);
    patientinvoice.setInsurarreference(sEditInsurarReference);
    patientinvoice.setInsurarreferenceDate(sEditInsurarReferenceDate);
    patientinvoice.setVerifier(sEditInvoiceVerifier);
    patientinvoice.setComment(sEditComment);
    patientinvoice.setMfpDoctor(sEditInvoiceDoctor);
    patientinvoice.setMfpPost(sEditInvoicePost);
    patientinvoice.setMfpAgent(sEditInvoiceAgent);
    patientinvoice.setMfpDrugReceiver(sEditInvoiceDrugsRecipient);
    patientinvoice.setMfpDrugReceiverId(sEditInvoiceDrugsIdCard);
    patientinvoice.setMfpDrugIdCardDate(sEditInvoiceDrugsIdCardDate);
    patientinvoice.setMfpDrugIdCardPlace(sEditInvoiceDrugsIdCardPlace);
	if(!sEditInvoiceSeries.equalsIgnoreCase("") && checkString(patientinvoice.getNumber()).length()==0){
		patientinvoice.setNumber(sEditInvoiceSeries+"."+MedwanQuery.getInstance().getOpenclinicCounter(sEditInvoiceSeries));
	}
    patientinvoice.setDebets(new Vector());
    patientinvoice.setCredits(new Vector());
    double dTotalCredits = 0;
    double dTotalDebets = 0;
    if (sEditCBs.length() > 0) {
        String[] aCBs = sEditCBs.split(",");
        String sID;
        PatientCredit patientcredit;
        Debet debet;

        for (int i = 0; i < aCBs.length; i++) {
            if (checkString(aCBs[i]).length() > 0) {
	
                if (checkString(aCBs[i]).startsWith("cbDebet")) {
                    sID = aCBs[i].substring(7);
                    patientinvoice.getDebets().add(Debet.get(sID));

                    debet = Debet.get(sID);
                    if(sEditStatus.equalsIgnoreCase("canceled")){
                        debet.setAmount(0);
                        debet.setInsurarAmount(0);
                        debet.setCredited(1);
                        debet.store();
                    }

                    if (debet != null) {
                        dTotalDebets += debet.getAmount();
                    }
                } else if (checkString(aCBs[i]).startsWith("cbPatientInvoice")) {
                    sID = aCBs[i].substring(16);
                    patientinvoice.getCredits().add(sID);

                    patientcredit = PatientCredit.get(sID);

                    if (patientcredit != null) {
                        dTotalCredits += patientcredit.getAmount();
                    }
                }
            }
        }
        if(acceptationuid.length()>0){
        	patientinvoice.setAcceptationUid(acceptationuid);
        }
    }
    double dBalance = Double.parseDouble(sEditBalance);
	// patient heeft te veel betaald => aanmaken van credit en saldo invoice = 0
    if (dBalance < 0) {
		Encounter encounter = Encounter.getActiveEncounter(invoicePatient.personid);
		if(encounter==null){
			encounter = Encounter.getLastEncounter(invoicePatient.personid);
		}

        double dCredit = dBalance;
        dBalance = 0;
        PatientCredit patientcredit = new PatientCredit();
        patientcredit.setAmount(dCredit * (-1));
        patientcredit.setEncounterUid(encounter==null?"":encounter.getUid());
        patientcredit.setDate(ScreenHelper.getSQLDate(getDate()));
        patientcredit.setType("transfer.de.credit");
        patientcredit.setUpdateDateTime(ScreenHelper.getSQLDate(getDate()));
        patientcredit.setUpdateUser(activeUser.userid);
        patientcredit.store();
		
        PatientCredit credit;
        String sCreditUid;
        double dTmpCredits = 0;
        boolean paymentCovered=false;
		
        for (int i = 0; i < patientinvoice.getCredits().size(); i++) {
            sCreditUid = checkString((String) patientinvoice.getCredits().elementAt(i));

            if (sCreditUid.length() > 0) {
                credit = PatientCredit.get(sCreditUid);

                if (credit != null) {
                    dTmpCredits += credit.getAmount();
                    if (dTmpCredits > dTotalDebets) {
                        if(!paymentCovered){
                        	credit.setAmount(new BigDecimal("" + (credit.getAmount() - (dTmpCredits - dTotalDebets))).setScale(2, BigDecimal.ROUND_HALF_UP).doubleValue());
                        }
                        else {
                        	credit.setAmount(0);
                        }
                        credit.store();
                        paymentCovered=true;
                    }
                }
            }
        }
    }
    patientinvoice.setBalance(dBalance);

    String sMessage;
    if (patientinvoice.store()) {
    	//Nu zetten we de reducties op orde
    	//Eerst verwijderen we de bestaande reducties
    	if(sEditReduction.length()>0){
        	PatientCredit.deletePatientInvoiceReductions(patientinvoice.getUid());
	    	//Bereken de korting
	    	double reduction = Double.parseDouble(sEditReduction);
	    	if(reduction>0){
		    	PatientCredit credit = new PatientCredit();
		    	credit.setAmount(reduction*patientinvoice.getPatientAmount()/100);
		    	credit.setDate(new java.util.Date());
		    	credit.setInvoiceUid(patientinvoice.getUid());
		    	credit.setPatientUid(patientinvoice.getPatientUid());
		    	credit.setType("reduction");
		    	credit.setUpdateDateTime(new java.util.Date());
		    	credit.setUpdateUser(patientinvoice.getUpdateUser());
		    	credit.setVersion(1);
		    	credit.store();
	    	}
    	}
        sMessage = getTran("web", "dataissaved", sWebLanguage);
    } else {
        sMessage = getTran("web.control", "dberror", sWebLanguage);
    }
%>
{
"Message":"<%=HTMLEntities.htmlentities(sMessage)%>",
"EditPatientInvoiceUID":"<%=patientinvoice.getUid()%>",
"EditComment":"<%=checkString(patientinvoice.getComment())%>",
"EditInsurarReference":"<%=patientinvoice.getInsurarreference()%>",
"EditInsurarReferenceDate":"<%=patientinvoice.getInsurarreferenceDate()%>",
"EditInvoiceUID":"<%=patientinvoice.getInvoiceUid()%>"
}