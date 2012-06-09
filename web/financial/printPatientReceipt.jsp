<%@ page import="be.mxs.common.util.io.*,be.openclinic.finance.*" %>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>
<%
	java.text.DecimalFormat priceFormat = new java.text.DecimalFormat(MedwanQuery.getInstance().getConfigString("priceFormat","#,##0.00"));
	String sCurrency = MedwanQuery.getInstance().getConfigParam("currency","EUR");
	String invoiceuid = checkString(request.getParameter("invoiceuid"));
	String invoicenumber="";
	if(invoiceuid.split("\\.").length>1){
		invoicenumber=invoiceuid.split("\\.")[1];
	}
	PatientInvoice invoice = PatientInvoice.get(invoiceuid);
	if(invoice!=null){
		JavaPOSPrinter printer = new JavaPOSPrinter();
		String content="";
		//Create the receipt content
		int receiptid=MedwanQuery.getInstance().getOpenclinicCounter("RECEIPT");
		if(receiptid>=MedwanQuery.getInstance().getConfigInt("maximumNumberOfReceipts",10000)){
			MedwanQuery.getInstance().setOpenclinicCounter("RECEIPT",0);
		}
		content+=printer.CENTER+receiptid+" - "+printer.BOLD+getTran("web","receiptforinvoice",sWebLanguage).toUpperCase()+" #"+invoice.getInvoiceNumber()+" - "+new SimpleDateFormat("dd/MM/yyyy").format(invoice.getDate())+printer.NOTBOLD+printer.LF;
        double totalCredit=0;
        for(int n=0;n<invoice.getCredits().size();n++){
            PatientCredit credit = PatientCredit.get((String)invoice.getCredits().elementAt(n));
            totalCredit+=credit.getAmount();
        }
        double totalDebet=0;
        double totalinsurardebet=0;
        Hashtable services = new Hashtable(), insurances = new Hashtable();
        String service="",insurance="";
        for(int n=0;n<invoice.getDebets().size();n++){
            Debet debet = (Debet)invoice.getDebets().elementAt(n);
            if(debet!=null){
            	if(debet.getEncounter()!=null && debet.getEncounter().getService()!=null){
            		service=debet.getEncounter().getService().getLabel(sWebLanguage);
            	}
	            if(service!=null){
	            	services.put(service, "1");
	            }
            	if(debet.getInsurance()!=null && debet.getInsurance().getInsurar()!=null){
            		insurance=debet.getInsurance().getInsurar().getName()+" ("+debet.getInsurance().getInsuranceNr()+")";
            	}
	            if(insurance!=null){
	            	insurances.put(insurance, "1");
	            }
	            totalDebet+=debet.getAmount();
	            totalinsurardebet+=debet.getInsurarAmount();
            }
        }
        //Patientgegevens
        content+=printer.LF;
		content+=printer.LEFT+(getTran("web","patient",sWebLanguage)+":              ").substring(0,15)+" "+printer.BOLD+invoice.getPatient().lastname.toUpperCase()+", "+invoice.getPatient().firstname+printer.NOTBOLD+printer.LF;
		content+=printer.LEFT+"                "+printer.BOLD+invoice.getPatient().personid+printer.NOTBOLD+printer.LF;
		content+=printer.LEFT+"                "+printer.BOLD+invoice.getPatient().dateOfBirth+"   "+invoice.getPatient().gender.toUpperCase()+printer.NOTBOLD+printer.LF;
        //Verzekeringsgegevens
        String insurancedata="";
        Enumeration ins=insurances.keys();
        int nLines=0;
        while(ins.hasMoreElements()){
        	if(nLines>0){
        		insurancedata+=printer.LF+"               ";
        	}
        	nLines++;
        	insurance = (String)ins.nextElement();
        	insurancedata+=" "+insurance;
        }
		content+=printer.LEFT+(getTran("web","insurance",sWebLanguage)+":              ").substring(0,15)+printer.BOLD+insurancedata+printer.NOTBOLD+printer.LF;
		//Afrdukken van de diensten
		content+=printer.LEFT+(getTran("web","service",sWebLanguage)+":              ").substring(0,15)+printer.BOLD;
        Enumeration es = services.keys();
        nLines=0;
        while (es.hasMoreElements()){
        	if(nLines>0){
        		content+=printer.LF+"               ";
        	}
        	nLines++;
        	service=(String)es.nextElement();
            content+=" "+service;
        }
        content+=printer.NOTBOLD+printer.LF;
        content+=printer.LF;
		//Afdrukken van prestaties
		content+=printer.LEFT+printer.UNDERLINE+getTran("web","prestations",sWebLanguage)+printer.NOTUNDERLINE+printer.LF;
        for(int n=0;n<invoice.getDebets().size();n++){
            Debet debet = (Debet)invoice.getDebets().elementAt(n);
            String extraInsurar="";
            if(debet.getExtraInsurarUid()!=null && debet.getExtraInsurarUid().length()>0){
                Insurar exIns = Insurar.get(debet.getExtraInsurarUid());
                if(exIns!=null){
                    extraInsurar=" >>> "+ScreenHelper.checkString(exIns.getName());
                    if(extraInsurar.indexOf("#")>-1){
                        extraInsurar=extraInsurar.substring(0,extraInsurar.indexOf("#"));
                    }
                }
            }
            content+=printer.LEFT+(debet.getQuantity()+" x  ["+debet.getPrestation().getCode()+"] "+debet.getPrestation().getDescription()+extraInsurar)+printer.LF;
        }
		//Totale kost en betalingen
		content+=printer.LEFT+printer.UNDERLINE+"                                                                              ".substring(0,48)+printer.NOTUNDERLINE+printer.LF;
		content+=printer.LEFT+printer.BOLD+(getTran("web","total",sWebLanguage)+": "+priceFormat.format(totalDebet)+" "+sCurrency+"                         ").substring(0,25);
		content+=printer.LEFT+getTran("web","payments",sWebLanguage)+": "+priceFormat.format(totalCredit)+" "+sCurrency+printer.LF;
		content+=printer.LEFT+printer.BOLD+"                         ";
		content+=printer.LEFT+printer.ITALIC+getTran("web","insurar",sWebLanguage)+": "+priceFormat.format(totalinsurardebet)+" "+sCurrency+printer.NOTITALIC+printer.LF;
		content+=printer.LEFT+printer.DOUBLE+getTran("web.finance","balance",sWebLanguage)+": "+priceFormat.format(invoice.getBalance())+" "+sCurrency+printer.NOTBOLD+printer.REGULAR+printer.LF;
		out.print("{\"message\":\""+printer.printReceipt(activeUser.project, sWebLanguage,content,"7"+invoicenumber)+"\"}");
	}
	else {
		out.print("{\"message\":\""+ScreenHelper.getTranNoLink("web","javapos.patientinvoicedoesnotexist",sWebLanguage)+"\"}");
	}
%>