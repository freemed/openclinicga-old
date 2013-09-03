<%@ page import="java.io.*,org.dom4j.*,org.dom4j.io.*,sun.misc.*,be.mxs.common.util.io.*,org.apache.commons.httpclient.*,org.apache.commons.httpclient.methods.*,be.mxs.common.util.db.*,be.mxs.common.util.system.*,be.openclinic.finance.*,net.admin.*,java.util.*,java.text.*,be.openclinic.adt.*" %>
<%!
    //--- ENCODE ----------------------------------------------------------------------------------
    public String encode(String sValue) {
        BASE64Encoder encoder = new BASE64Encoder();
        return encoder.encodeBuffer(sValue.getBytes());
    }

    //--- DECODE ----------------------------------------------------------------------------------
    public String decode(String sValue) {
        String sReturn = "";
        BASE64Decoder decoder = new BASE64Decoder();

        try {
            sReturn = new String(decoder.decodeBuffer(sValue));
        }
        catch (Exception e) {
            if(Debug.enabled) Debug.println("User decoding error: "+e.getMessage());
        }

        return sReturn;
    }
%>
<%
	java.text.DecimalFormat priceFormat = new java.text.DecimalFormat(MedwanQuery.getInstance().getConfigString("priceFormat","#,##0.00"));
	String sCurrency = MedwanQuery.getInstance().getConfigParam("currency","EUR");
	String credituid = ScreenHelper.checkString(request.getParameter("credituid"));
	String creditnumber="";
	String sWebLanguage = ScreenHelper.checkString(request.getParameter("language"));
	String sUserId = ScreenHelper.checkString(request.getParameter("userid"));
	if(credituid.split("\\.").length>1){
		creditnumber=credituid.split("\\.")[1];
	}
	InsurarCredit credit = InsurarCredit.get(credituid);

	if(credit!=null && credit.getDate()!=null){
		JavaPOSPrinter printer = new JavaPOSPrinter();
		String content="";
		//Create the receipt content
		int receiptid=MedwanQuery.getInstance().getOpenclinicCounter("RECEIPT");
		if(receiptid>=MedwanQuery.getInstance().getConfigInt("maximumNumberOfReceipts",10000)){
			MedwanQuery.getInstance().setOpenclinicCounter("RECEIPT",0);
		}
		content+=printer.CENTER+receiptid+" - "+printer.BOLD+ScreenHelper.getTranNoLink("web","receiptforinsurarcredit",sWebLanguage).toUpperCase()+" #"+creditnumber+" - "+new SimpleDateFormat("dd/MM/yyyy").format(credit.getDate())+printer.NOTBOLD+printer.LF;
        double totalCredit=credit.getAmount();
        //Patientgegevens
        content+=printer.LF;

        //Verzekeringsgegevens
		Insurar insurar = Insurar.get(ScreenHelper.checkString(credit.getInsurarUid()));
        if(insurar!=null){
        	content+=printer.LEFT+(ScreenHelper.getTran("web","insurance",sWebLanguage)+":              ").substring(0,15)+printer.BOLD+insurar.getName()+printer.NOTBOLD+printer.LF;
        }

		//Afdrukken van betalingsgegevens
		content+=printer.LEFT+printer.UNDERLINE+ScreenHelper.getTran("web","payments",sWebLanguage)+printer.NOTUNDERLINE+printer.LF;
           content+=printer.LEFT+new SimpleDateFormat("dd/MM/yyyy").format(credit.getDate())+"  "+ScreenHelper.getTran("credit.type",credit.getType(),sWebLanguage)+": "+priceFormat.format(credit.getAmount())+" "+sCurrency+printer.LF;
           if(credit.getComment()!=null && credit.getComment().length()>0){
			content+=printer.LEFT+"---------------------------------------------------------------------------------".substring(0,48)+printer.LF;
           	content+=printer.LEFT+credit.getComment()+printer.LF;
           }
		//Totale kost en betalingen
		content+=printer.LEFT+printer.UNDERLINE+"                                                                              ".substring(0,48)+printer.NOTUNDERLINE+printer.LF;
		content+=printer.LEFT+printer.DOUBLE+ScreenHelper.getTran("web","total",sWebLanguage)+": "+priceFormat.format(credit.getAmount())+" "+sCurrency+printer.NOTBOLD+printer.REGULAR+printer.LF;
		net.admin.User activeUser = net.admin.User.get(Integer.parseInt(sUserId));
		//out.print("{\"message\":\""+printer.printReceipt(activeUser.project, sWebLanguage,content,"8"+creditnumber)+"\"}");
		//Send print instruction to JAVAPOS server
		HttpClient client = new HttpClient();
		String javaPOSServer=(String)session.getAttribute("javaPOSServer");
		if(javaPOSServer.length()==0){
			javaPOSServer="http://localhost/openclinic";
		}
		String url = javaPOSServer+"/financial/printReceipt.jsp";
		PostMethod method = new PostMethod(url);
		method.setRequestHeader("Content-type","text/xml; charset=windows-1252");
		NameValuePair nvp1= new NameValuePair("project",activeUser.project);
		NameValuePair nvp2= new NameValuePair("language",sWebLanguage);
		NameValuePair nvp3= new NameValuePair("content",HTMLEntities.htmlentities(content));
		NameValuePair nvp4= new NameValuePair("id","8"+creditnumber);
		method.setQueryString(new NameValuePair[]{nvp1,nvp2,nvp3,nvp4});
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
		out.print("{\"message\":\""+ScreenHelper.getTranNoLink("web","javapos.patientcreditdoesnotexist",sWebLanguage)+"\"}");
	}
%>