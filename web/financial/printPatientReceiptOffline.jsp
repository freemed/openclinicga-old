<%@ page import="java.io.*,org.dom4j.*,org.dom4j.io.*,be.mxs.common.util.io.*,org.apache.commons.httpclient.*,org.apache.commons.httpclient.methods.*,be.mxs.common.util.db.*,be.mxs.common.util.system.*,be.openclinic.finance.*,java.util.*,java.text.*" %>
<%@page errorPage="/includes/error.jsp"%>
<%
	java.text.DecimalFormat priceFormat = new java.text.DecimalFormat(MedwanQuery.getInstance().getConfigString("priceFormat","#,##0.00"));
	String sCurrency = MedwanQuery.getInstance().getConfigParam("currency","EUR");
	String invoiceuid = ScreenHelper.checkString(request.getParameter("invoiceuid"));
	String invoicenumber="";
	String sWebLanguage = ScreenHelper.checkString(request.getParameter("language"));
	String sUserId = ScreenHelper.checkString(request.getParameter("userid"));
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
		content+=printer.CENTER+receiptid+" - "+printer.BOLD+ScreenHelper.getTran("web","receiptforinvoice",sWebLanguage).toUpperCase()+" #"+invoice.getInvoiceNumber()+" - "+ScreenHelper.stdDateFormat.format(invoice.getDate())+printer.NOTBOLD+printer.LF;
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
            if(debet!=null && debet.getCredited()==0){
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
		content+=printer.LEFT+(ScreenHelper.getTran("web","patient",sWebLanguage)+":              ").substring(0,15)+" "+printer.BOLD+invoice.getPatient().lastname.toUpperCase()+", "+invoice.getPatient().firstname+printer.NOTBOLD+printer.LF;
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
		content+=printer.LEFT+(ScreenHelper.getTran("web","insurance",sWebLanguage)+":              ").substring(0,15)+printer.BOLD+insurancedata+printer.NOTBOLD+printer.LF;
		//Afrdukken van de diensten
		content+=printer.LEFT+(ScreenHelper.getTran("web","service",sWebLanguage)+":              ").substring(0,15)+printer.BOLD;
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
		content+=printer.LEFT+printer.UNDERLINE+ScreenHelper.getTran("web","prestations",sWebLanguage)+printer.NOTUNDERLINE+printer.LF;
        for(int n=0;n<invoice.getDebets().size();n++){
            Debet debet = (Debet)invoice.getDebets().elementAt(n);
            String extraInsurar="";
            if(debet!=null &&  && debet.getCredited()==0 && debet.getExtraInsurarUid()!=null && debet.getExtraInsurarUid().length()>0){
                Insurar exIns = Insurar.get(debet.getExtraInsurarUid());
                if(exIns!=null){
                    extraInsurar=" >>> "+ScreenHelper.checkString(exIns.getName());
                    if(extraInsurar.indexOf("#")>-1){
                        extraInsurar=extraInsurar.substring(0,extraInsurar.indexOf("#"));
                    }
                }
            }
            content+=printer.LEFT+(debet.getQuantity()+" x  ["+debet.getPrestation().getCode()+"] "+debet.getPrestation().getDescription()+extraInsurar)+printer.LF;
            content+=printer.LEFT+"     "+ScreenHelper.getTranNoLink("web","Pat.",sWebLanguage)+": "+priceFormat.format(debet.getAmount())+" / "+ScreenHelper.getTranNoLink("web","Ass.",sWebLanguage)+": "+priceFormat.format(debet.getInsurarAmount())+printer.LF;
        }
		//Totale kost en betalingen
		content+=printer.LEFT+printer.UNDERLINE+"                                                                              ".substring(0,48)+printer.NOTUNDERLINE+printer.LF;
		content+=printer.LEFT+printer.BOLD+(ScreenHelper.getTran("web","total",sWebLanguage)+": "+priceFormat.format(totalDebet)+" "+sCurrency+"                         ").substring(0,25);
		content+=printer.LEFT+ScreenHelper.getTran("web","payments",sWebLanguage)+": "+priceFormat.format(totalCredit)+" "+sCurrency+printer.LF;
		content+=printer.LEFT+printer.BOLD+"                         ";
		content+=printer.LEFT+printer.ITALIC+ScreenHelper.getTran("web","insurar",sWebLanguage)+": "+priceFormat.format(totalinsurardebet)+" "+sCurrency+printer.NOTITALIC+printer.LF;
		content+=printer.LEFT+printer.DOUBLE+ScreenHelper.getTran("web.finance","balance",sWebLanguage)+": "+priceFormat.format(invoice.getBalance())+" "+sCurrency+printer.NOTBOLD+printer.REGULAR+printer.LF;
		net.admin.User activeUser = net.admin.User.get(Integer.parseInt(sUserId));
		//out.print("{\"message\":\""+printer.printReceipt(activeUser.project, sWebLanguage,content,"7"+invoicenumber)+"\"}");
		//Send print instruction to JAVAPOS server
		HttpClient client = new HttpClient();
		String javaPOSServer=(String)session.getAttribute("javaPOSServer");
		if(javaPOSServer.length()==0){
			javaPOSServer="http://localhost/openclinic";
		}
		String url = javaPOSServer+"/financial/printReceipt.jsp";
		PostMethod method = new PostMethod(url);
		method.setRequestHeader("Content-type","text/xml; charset=windows-1252");
		Vector<NameValuePair> vNvp = new Vector<NameValuePair>();
		vNvp.add(new NameValuePair("project",activeUser.project));
		vNvp.add(new NameValuePair("language",sWebLanguage));
		vNvp.add(new NameValuePair("content",HTMLEntities.htmlentities(content)));
		vNvp.add(new NameValuePair("id","7"+invoicenumber));
		NameValuePair[] nvp = new NameValuePair[vNvp.size()];
		vNvp.copyInto(nvp);
		method.setQueryString(nvp);
		int statusCode = client.executeMethod(method);
		String sError="";
		if(method.getResponseBodyAsString().contains("<error>")){
			BufferedReader br = new BufferedReader(new StringReader(method.getResponseBodyAsString()));
			SAXReader reader=new SAXReader(false);
			org.dom4j.Document document=reader.read(br);
			Element root = document.getRootElement();
			if(ScreenHelper.checkString(root.getText()).trim().length()>0){
				sError=root.getText();
			}
			
		}

		out.print("{\"message\":\""+sError+"\"}");

	}
	else {
		out.print("{\"message\":\""+ScreenHelper.getTranNoLink("web","javapos.patientinvoicedoesnotexist",sWebLanguage)+"\"}");
	}
%>