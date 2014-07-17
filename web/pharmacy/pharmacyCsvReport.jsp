<%@ page import="be.openclinic.pharmacy.*,be.mxs.common.util.system.*" %><%@page errorPage="/includes/error.jsp"%><%@include file="/includes/validateUser.jsp"%>
<%!
	public static String sFormat;	
	public static StringBuffer sOutput;
	public static int totalcols;

	void addLine(boolean boxed){
		
	}
	
	void addCell(String value, int cols,boolean boxed){
		if(sFormat.equals("pdf")){
			
		}
		else {
			sOutput.append(value);
			for(int n=1;n<cols;n++){
				sOutput.append(";");
			}
		}
	}

	void addBoldCell(String value, int cols,boolean boxed){
		if(sFormat.equals("pdf")){
			
		}
		else {
			addCell(value, cols);
		}
	}
	
	void addGreyCell(String value, int cols,boolean boxed){
		if(sFormat.equals("pdf")){
			
		}
		else {
			addCell(value, cols);
		}
	}

	void addTitleCell(String value, int cols,boolean boxed){
		if(sFormat.equals("pdf")){
			
		}
		else {
			addCell(value, cols);
		}
	}

%>
<%
	
	sOutput = new StringBuffer();
	String sType = checkString(request.getParameter("type"));
	String sStart = checkString(request.getParameter("start"));
	String sEnd = checkString(request.getParameter("end"));
	String sServiceStockUid = checkString(request.getParameter("servicestockuid"));
	sFormat=checkString(request.getParameter("format"));
	response.setContentType("application/octet-stream");
	response.setHeader("Content-Disposition", "Attachment;Filename=\"PharmacyReport." + sType+"."+ new SimpleDateFormat("yyyyMMddHHmmss").format(new java.util.Date()) + ".csv\"");
	ServletOutputStream os = response.getOutputStream();
	
	ServiceStock serviceStock = ServiceStock.get(sServiceStockUid);
	
	//Header goes here
	sOutput.append(getTranNoLink("pharmacy.report","general.title",sWebLanguage).replaceAll("<cr>","\r\n")+"\r\n\r\n");
	sOutput.append(getTranNoLink("web","from",sWebLanguage)+" "+sStart+" "+getTranNoLink("web","to",sWebLanguage)+" "+sEnd+"\r\n");
	sOutput.append(getTranNoLink("web","servicestock",sWebLanguage)+": "+serviceStock.getName()+"\r\n\r\n");
	
	
	if(sType.equals("supplier.deliveries")){
		//Report title goes here
		sOutput.append(getTranNoLink("pharmacy.report","supplier.deliveries.title",sWebLanguage)+"\r\n\r\n");
		sOutput.append(getTranNoLink("pharmacy.report","article",sWebLanguage)+";"+getTranNoLink("pharmacy.report","expirydate",sWebLanguage)+";"+getTranNoLink("pharmacy.report","quantity",sWebLanguage)+";"+getTranNoLink("pharmacy.report","unit",sWebLanguage)+";"+getTranNoLink("pharmacy.report","fobprice",sWebLanguage)+";"+getTranNoLink("pharmacy.report","salesprice",sWebLanguage)+";"+getTranNoLink("pharmacy.report","totalprice",sWebLanguage)+"\r\n");
		String sActiveSupplier="?***$$poo",sActiveDate="", sActiveDocument="";
		double documenttotal=0;
		Vector operations = ProductStockOperation.getReceipts("", ScreenHelper.parseDate(sStart), ScreenHelper.parseDate(sEnd), "OC_OPERATION_SRCDESTUID,OC_OPERATION_ORDERUID", "");
		boolean initialized=false;
		boolean changed=false;
		for(int n=0;n<operations.size();n++){
			changed=false;
			ProductStockOperation operation = (ProductStockOperation)operations.elementAt(n);
			Product product = null;
			if(operation.getProductStock()!=null && operation.getProductStock().getProduct()!=null){
				product = operation.getProductStock().getProduct();
			}
			if(!sActiveSupplier.equalsIgnoreCase(operation.getSourceDestination().getObjectUid())){
				if(initialized & !changed){
					//Close previous document
					sOutput.append(";;;;;"+getTranNoLink("web","total",sWebLanguage)+";"+documenttotal+"\r\n\r\n");
					documenttotal=0;
					changed=true;
				}
				//Print supplier header
				sActiveSupplier=operation.getSourceDestination().getObjectUid();
				if(sActiveSupplier==null || sActiveSupplier.length()==0){
					sActiveSupplier="?";
				}
				sOutput.append(getTranNoLink("web","supplier",sWebLanguage)+": "+sActiveSupplier+"\r\n********************************************************\r\n");
				sActiveDate="";
				sActiveDocument="";
			}
			if(!sActiveDate.equalsIgnoreCase(ScreenHelper.stdDateFormat.format(operation.getDate())) || !sActiveDocument.equalsIgnoreCase(operation.getOrderUID())){
				if(initialized & !changed){
					//Close previous document
					sOutput.append(";;;;;"+getTranNoLink("web","total",sWebLanguage)+";"+documenttotal+"\r\n\r\n");
					documenttotal=0;
					changed=true;
				}
				//Print document header
				sActiveDate=ScreenHelper.stdDateFormat.format(operation.getDate());
				sActiveDocument=operation.getOrderUID();
				sOutput.append(getTranNoLink("web","date",sWebLanguage)+": "+sActiveDate+"       "+getTranNoLink("web","document",sWebLanguage)+": "+sActiveDocument+"\r\n");
			}
			if(product!=null){
				sOutput.append(product.getName()+";");
			}
			else {
				sOutput.append("?;");
			}
			if(operation.getBatchEnd()!=null){
				sOutput.append(ScreenHelper.stdDateFormat.format(operation.getBatchEnd())+";");
			}
			else {
				sOutput.append(";");
			}
			sOutput.append(operation.getUnitsChanged()+";");
			if(product!=null){
				sOutput.append(product.getUnit()+";");
			}
			else {
				sOutput.append(";");
			}
			String price = "";
			if(product!=null){
				String[] pricepointer=Pointer.getPointer("drugprice."+product.getUid()+"."+operation.getUid()).split(";");
				if(pricepointer.length>1){
					price=pricepointer[1];
				}
			}
			sOutput.append(price+";");
			sOutput.append(price+";");
			double cost = 0;
			try{
				cost=Double.parseDouble(price)*operation.getUnitsChanged();
			}
			catch(Exception e){}
			sOutput.append(cost+"\r\n");
			documenttotal+=cost;
			initialized=true;
		}
		if(initialized){
			//Close previous document
			sOutput.append(";;;;;"+getTranNoLink("web","total",sWebLanguage)+";"+documenttotal+"\r\n\r\n");
		}
	}
	
    byte[] b = sOutput.toString().getBytes();
    for (int n=0;n<b.length;n++) {
        os.write(b[n]);
    }
    os.flush();
    os.close();
%>