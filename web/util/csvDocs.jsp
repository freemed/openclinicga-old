<%@ page import="be.openclinic.statistics.CsvStats,be.openclinic.finance.*" %><%@include file="/includes/validateUser.jsp"%><%@ page import="be.mxs.common.util.db.MedwanQuery" %><%@ page import="java.text.SimpleDateFormat" %><%@ page import="java.util.Date" %><%
    String query=null;
	String label="labelfr";
	if(sWebLanguage.equalsIgnoreCase("e")||sWebLanguage.equalsIgnoreCase("en")){
		label="labelen";		
	}
    response.setContentType("application/octet-stream");
    response.setHeader("Content-Disposition", "Attachment;Filename=\"OpenClinicStatistic" + new SimpleDateFormat("yyyyMMddHHmmss").format(new Date()) + ".csv\"");
    ServletOutputStream os = response.getOutputStream();
    String sOutput="";
	if("invoice.rama".equalsIgnoreCase(request.getParameter("docid"))){
		InsurarInvoice invoice = InsurarInvoice.get(request.getParameter("invoiceuid"));
		if(invoice!=null){
			sOutput+="INVOICE NUMBER:;"+invoice.getUid()+"\r\n";
			sOutput+="INVOICE DATE:;"+ScreenHelper.stdDateFormat.format(invoice.getDate())+"\r\n";
			sOutput+="INSURAR:;"+invoice.getInsurar().getName()+"\r\n";
			sOutput+="\r\n";
			sOutput+=CsvInvoiceRama.getOutput(request);
		}
	}
	else if("invoice.rama.extra".equalsIgnoreCase(request.getParameter("docid"))){
		ExtraInsurarInvoice invoice = ExtraInsurarInvoice.get(request.getParameter("invoiceuid"));
		if(invoice!=null){
			sOutput+="INVOICE NUMBER:;"+invoice.getUid()+"\r\n";
			sOutput+="INVOICE DATE:;"+ScreenHelper.stdDateFormat.format(invoice.getDate())+"\r\n";
			sOutput+="INSURAR:;"+invoice.getInsurar().getName()+"\r\n";
			sOutput+="\r\n";
			sOutput+=CsvInvoiceRamaExtra.getOutput(request);
		}
	}
	else if("invoice.rama.extra2".equalsIgnoreCase(request.getParameter("docid"))){
		ExtraInsurarInvoice2 invoice = ExtraInsurarInvoice2.get(request.getParameter("invoiceuid"));
		if(invoice!=null){
			sOutput+="INVOICE NUMBER:;"+invoice.getUid()+"\r\n";
			sOutput+="INVOICE DATE:;"+ScreenHelper.stdDateFormat.format(invoice.getDate())+"\r\n";
			sOutput+="INSURAR:;"+invoice.getInsurar().getName()+"\r\n";
			sOutput+="\r\n";
			sOutput+=CsvInvoiceRamaExtra2.getOutput(request);
		}
	}
	else if("invoice.cplr".equalsIgnoreCase(request.getParameter("docid"))){
		InsurarInvoice invoice = InsurarInvoice.get(request.getParameter("invoiceuid"));
		if(invoice!=null){
			sOutput+="INVOICE NUMBER:;"+invoice.getUid()+"\r\n";
			sOutput+="INVOICE DATE:;"+ScreenHelper.stdDateFormat.format(invoice.getDate())+"\r\n";
			sOutput+="INSURAR:;"+invoice.getInsurar().getName()+"\r\n";
			sOutput+="\r\n";
			sOutput+=CsvInvoiceCplr.getOutput(request);
		}
	}
	else if("invoice.cplr2".equalsIgnoreCase(request.getParameter("docid"))){
		ExtraInsurarInvoice invoice = ExtraInsurarInvoice.get(request.getParameter("invoiceuid"));
		if(invoice!=null){
			sOutput+="INVOICE NUMBER:;"+invoice.getUid()+"\r\n";
			sOutput+="INVOICE DATE:;"+ScreenHelper.stdDateFormat.format(invoice.getDate())+"\r\n";
			sOutput+="INSURAR:;"+invoice.getInsurar().getName()+"\r\n";
			sOutput+="\r\n";
			sOutput+=CsvInvoiceCplr2.getOutput(request);
		}
	}
    byte[] b = sOutput.getBytes();
    for (int n=0;n<b.length;n++) {
        os.write(b[n]);
    }
    os.flush();
    os.close();
%>