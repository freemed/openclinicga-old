package be.mxs.common.util.pdf.general;

import be.mxs.common.util.pdf.official.PDFOfficialBasic;
import be.mxs.common.util.system.Pointer;
import be.mxs.common.util.system.ScreenHelper;
import be.mxs.common.util.db.MedwanQuery;
import be.openclinic.pharmacy.Batch;
import be.openclinic.pharmacy.BatchOperation;
import be.openclinic.pharmacy.DrugCategory;
import be.openclinic.pharmacy.OperationDocument;
import be.openclinic.pharmacy.ProductOrder;
import be.openclinic.pharmacy.ProductStock;
import be.openclinic.pharmacy.ProductStockOperation;
import be.openclinic.pharmacy.ServiceStock;
import be.chuk.Article;
import com.itextpdf.text.pdf.*;
import com.itextpdf.text.*;

import net.admin.User;
import net.admin.AdminPerson;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpSession;

import org.dom4j.DocumentHelper;

import java.io.ByteArrayOutputStream;
import java.text.DecimalFormat;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Iterator;
import java.util.SortedMap;
import java.util.TreeMap;
import java.util.Vector;
import java.util.Hashtable;
import java.util.Enumeration;

/**
 * User: stijn smets
 * Date: 21-nov-2006
 */
public class PDFPharmacyReportGenerator extends PDFOfficialBasic {

    // declarations
    private final int pageWidth = 100;
    private String type;
    private final long day = 24*3600*1000;
    PdfWriter docWriter=null;
    public void addHeader(){
    }
    public void addContent(){
    }



    //--- CONSTRUCTOR -----------------------------------------------------------------------------
    public PDFPharmacyReportGenerator(User user, String sProject){
        this.user = user;
        this.sProject = sProject;
        this.sPrintLanguage = user.person.language;
        doc = new Document();
    }

    //--- GENERATE PDF DOCUMENT BYTES -------------------------------------------------------------
    public ByteArrayOutputStream generatePDFDocumentBytes(final HttpServletRequest req, String type, Hashtable parameters) throws Exception {
        ByteArrayOutputStream baosPDF = new ByteArrayOutputStream();
		docWriter = PdfWriter.getInstance(doc,baosPDF);
        this.req = req;

        String sURL = req.getRequestURL().toString();
        if(sURL.indexOf("openclinic",10) > 0){
            sURL = sURL.substring(0,sURL.indexOf("openclinic", 10));
        }

        String sContextPath = req.getContextPath()+"/";
        HttpSession session = req.getSession();
        String sProjectDir = (String)session.getAttribute("activeProjectDir");

        this.url = sURL;
        this.contextPath = sContextPath;
        this.projectDir = sProjectDir;

		try{
            doc.addProducer();
            doc.addAuthor(user.person.firstname+" "+user.person.lastname);
			doc.addCreationDate();
			doc.addCreator("OpenClinic Software");
        	if(type.equalsIgnoreCase("serviceStockInventorySummary")||type.equalsIgnoreCase("serviceIncomingStockOperationsPerProvider")||type.equalsIgnoreCase("serviceIncomingStockOperationsPerItem")||type.equalsIgnoreCase("serviceIncomingStockOperationsPerOrder")||type.equalsIgnoreCase("serviceIncomingStockOperations")||type.equalsIgnoreCase("monthlyConsumption")||type.equalsIgnoreCase("serviceOutgoingStockOperations")||type.equalsIgnoreCase("serviceOutgoingStockOperationsListing")||type.equalsIgnoreCase("serviceOutgoingStockOperationsListingPerService")||type.equalsIgnoreCase("stockout")||type.equalsIgnoreCase("serviceIncomingStockOperationsPerCategoryItem")){
        		doc.setPageSize(PageSize.A4);
        	}
        	else {
        		doc.setPageSize(PageSize.A4.rotate());
        	}
            doc.open();
            printHeader(type,parameters);
            printTable(type,parameters);
		}
		catch(Exception e){
			baosPDF.reset();
			e.printStackTrace();
		}
		finally{
			if(doc!=null) doc.close();
            if(docWriter!=null) docWriter.close();
		}

		if(baosPDF.size() < 1){
			throw new DocumentException("document has no bytes");
		}

		return baosPDF;
	}

    //---- ADD PAGE HEADER ------------------------------------------------------------------------
    private void addPageHeader() throws Exception {
    }

	private void addCol(org.dom4j.Element row, int size, String value){
		org.dom4j.Element col = row.addElement("col");
		col.addAttribute("size", size+"");
		col.setText(value);
	}
	private void addCol(org.dom4j.Element row, int size, String value, int fontsize){
		org.dom4j.Element col = row.addElement("col");
		col.addAttribute("size", size+"");
		col.addAttribute("fontsize", fontsize+"");
		col.setText(value);
	}
	private void addBoldCol(org.dom4j.Element row, int size, String value){
		org.dom4j.Element col = row.addElement("col");
		col.addAttribute("size", size+"");
		col.addAttribute("weight", "bold");
		col.setText(value);
	}
	
	private void addRightCol(org.dom4j.Element row, int size, String value){
		org.dom4j.Element col = row.addElement("col");
		col.addAttribute("size", size+"");
		col.addAttribute("align", "right");
		col.setText(value);
	}
	
	private void addCenterCol(org.dom4j.Element row, int size, String value){
		org.dom4j.Element col = row.addElement("col");
		col.addAttribute("size", size+"");
		col.addAttribute("align", "center");
		col.setText(value);
	}
	
	private void addRightBoldCol(org.dom4j.Element row, int size, String value){
		org.dom4j.Element col = row.addElement("col");
		col.addAttribute("size", size+"");
		col.addAttribute("align", "right");
		col.addAttribute("weight", "bold");
		col.setText(value);
	}

	private void addCenterBoldCol(org.dom4j.Element row, int size, String value){
		org.dom4j.Element col = row.addElement("col");
		col.addAttribute("size", size+"");
		col.addAttribute("align", "center");
		col.addAttribute("weight", "bold");
		col.setText(value);
	}

	private void addPriceCol(org.dom4j.Element row, int size, double value){
		org.dom4j.Element col = row.addElement("col");
		col.addAttribute("size", size+"");
		col.setText(new DecimalFormat(MedwanQuery.getInstance().getConfigString("priceFormat","#")).format(value));
	}

	private void addPriceCol(org.dom4j.Element row, int size, double value,String format){
		org.dom4j.Element col = row.addElement("col");
		col.addAttribute("size", size+"");
		col.setText(new DecimalFormat(format).format(value));
	}

	private void addPriceBoldCol(org.dom4j.Element row, int size, double value,String format){
		org.dom4j.Element col = row.addElement("col");
		col.addAttribute("size", size+"");
		col.addAttribute("weight", "bold");
		col.setText(new DecimalFormat(format).format(value));
	}

	private void addPriceBoldCol(org.dom4j.Element row, int size, double value){
		org.dom4j.Element col = row.addElement("col");
		col.addAttribute("size", size+"");
		col.addAttribute("weight", "bold");
		col.setText(new DecimalFormat(MedwanQuery.getInstance().getConfigString("priceFormat","#")).format(value));
	}

    protected void printTable(String type,Hashtable parameters) throws DocumentException, ParseException{
		org.dom4j.Document d = DocumentHelper.createDocument();
		org.dom4j.Element t = DocumentHelper.createElement("table");
    	if(type.equalsIgnoreCase("productStockFile")){
    		printProductStockFile(d, t, (String)parameters.get("year"), (String)parameters.get("productStockUID"));
    	}
    	else if(type.equalsIgnoreCase("serviceStockInventory")){
    		printServiceStockInventory(d, t, (String)parameters.get("begin"), (String)parameters.get("end"), (String)parameters.get("serviceStockUID"));
    	}
    	else if(type.equalsIgnoreCase("serviceStockInventorySummary")){
    		printServiceStockInventory(d, t, (String)parameters.get("date"), (String)parameters.get("serviceStockUID"));
    	}
    	else if(type.equalsIgnoreCase("expiration")){
    		printExpiration(d, t, (String)parameters.get("date"), (String)parameters.get("serviceStockUID"));
    	}
    	else if(type.equalsIgnoreCase("stockout")){
    		printStockOut(d, t, (String)parameters.get("date"), (String)parameters.get("serviceStockUID"));
    	}
    	else if(type.equalsIgnoreCase("serviceStockOperations")){
    		printServiceStockOperations(d, t, (String)parameters.get("begin"), (String)parameters.get("end"), (String)parameters.get("serviceStockUID"));
    	}
    	else if(type.equalsIgnoreCase("serviceOutgoingStockOperations")){
    		printServiceOutgoingStockOperations(d, t, (String)parameters.get("begin"), (String)parameters.get("end"), (String)parameters.get("serviceStockUID"));
    	}
    	else if(type.equalsIgnoreCase("serviceIncomingStockOperations")){
    		printServiceIncomingStockOperations(d, t, (String)parameters.get("begin"), (String)parameters.get("end"), (String)parameters.get("serviceStockUID"));
    	}
    	else if(type.equalsIgnoreCase("serviceIncomingStockOperationsPerOrder")){
    		printServiceIncomingStockOperationsPerOrder(d, t, (String)parameters.get("begin"), (String)parameters.get("end"), (String)parameters.get("serviceStockUID"));
    	}
    	else if(type.equalsIgnoreCase("serviceIncomingStockOperationsPerItem")){
    		printServiceIncomingStockOperationsPerItem(d, t, (String)parameters.get("begin"), (String)parameters.get("end"), (String)parameters.get("serviceStockUID"));
    	}
    	else if(type.equalsIgnoreCase("serviceIncomingStockOperationsPerCategoryItem")){
    		printServiceIncomingStockOperationsPerCategoryItem(d, t, (String)parameters.get("begin"), (String)parameters.get("end"), (String)parameters.get("serviceStockUID"));
    	}
    	else if(type.equalsIgnoreCase("serviceIncomingStockOperationsPerProvider")){
    		printServiceIncomingStockOperationsPerProvider(d, t, (String)parameters.get("begin"), (String)parameters.get("end"), (String)parameters.get("serviceStockUID"));
    	}
    	else if(type.equalsIgnoreCase("serviceOutgoingStockOperationsListing")){
    		printServiceOutgoingStockOperationsListing(d, t, (String)parameters.get("begin"), (String)parameters.get("end"), (String)parameters.get("serviceStockUID"));
    	}
    	else if(type.equalsIgnoreCase("serviceOutgoingStockOperationsListingPerService")){
    		printServiceOutgoingStockOperationsListingPerService(d, t, (String)parameters.get("begin"), (String)parameters.get("end"), (String)parameters.get("serviceStockUID"), (String)parameters.get("destinationStockUID"));
    	}
    	else if(type.equalsIgnoreCase("monthlyConsumption")){
    		printMonthlyConsumption(d, t, (String)parameters.get("date"), (String)parameters.get("serviceStockUID"),parameters.get("includePatients")!=null,parameters.get("includeStocks")!=null,parameters.get("includeOther")!=null);
    	}
    	
		printDocument(d);
    }
    
    protected void printDocument(org.dom4j.Document d) throws DocumentException{
    	org.dom4j.Element root = d.getRootElement();
    	table = new PdfPTable(Integer.parseInt(root.attributeValue("size")));
    	table.setWidthPercentage(100);
    	Iterator rows = root.elementIterator("row");
    	while(rows.hasNext()){
    		org.dom4j.Element row = (org.dom4j.Element)rows.next();
			Iterator cols = row.elementIterator("col");
			while(cols.hasNext()){
				org.dom4j.Element col = (org.dom4j.Element)cols.next();
				int fontsize=10;
				if(ScreenHelper.checkString(col.attributeValue("fontsize")).length()>0){
					fontsize=Integer.parseInt(ScreenHelper.checkString(col.attributeValue("fontsize")));
				}
	    		if(ScreenHelper.checkString(row.attributeValue("type")).equalsIgnoreCase("title")){
	    			cell = createGreyCell(fontsize,col.getText(), Integer.parseInt(col.attributeValue("size")));
	    		}
	    		else {
		    		if(ScreenHelper.checkString(col.attributeValue("weight")).equalsIgnoreCase("bold")){
		    			cell = createBoldValueCell(fontsize,col.getText(), Integer.parseInt(col.attributeValue("size")));
		    		}
		    		else {
		    			cell = createValueCell(fontsize,col.getText(), Integer.parseInt(col.attributeValue("size")));
		    		}
	    		}
	    		if(ScreenHelper.checkString(col.attributeValue("align")).equalsIgnoreCase("right")){
	    			cell.setHorizontalAlignment(PdfPCell.ALIGN_RIGHT);
	    		}
	    		else if(ScreenHelper.checkString(col.attributeValue("align")).equalsIgnoreCase("center")){
	    			cell.setHorizontalAlignment(PdfPCell.ALIGN_CENTER);
	    		}
	    		table.addCell(cell);
			}
    	}
    	doc.add(table);
    }

    protected void printExpiration(org.dom4j.Document d, org.dom4j.Element t, String sDate, String sServiceStockUID) throws ParseException{
		d.add(t);
        t.addAttribute("size", "180");
        java.util.Date date = ScreenHelper.parseDate(sDate);
    	
		//Add title rows
        org.dom4j.Element row =t.addElement("row");
		row.addAttribute("type", "title");
		addCol(row,80,ScreenHelper.getTranNoLink("web","article",sPrintLanguage));
		addCol(row,20,ScreenHelper.getTranNoLink("web","expiration",sPrintLanguage));
		addCol(row,20,ScreenHelper.getTranNoLink("web","stock",sPrintLanguage));
		addCol(row,20,ScreenHelper.getTranNoLink("web","unit",sPrintLanguage));
		addCol(row,20,ScreenHelper.getTranNoLink("web","PU",sPrintLanguage));
		addCol(row,20,ScreenHelper.getTranNoLink("web","amount",sPrintLanguage));
		
		//Now we have to find all productstocks sorted by productsubgroup
		SortedMap stocks = new TreeMap();
		Vector productStocks = ServiceStock.getProductStocks(sServiceStockUID);
		for(int n=0;n<productStocks.size();n++){
			ProductStock stock = (ProductStock)productStocks.elementAt(n);
			//Check if product is about to expire
			Vector batches = Batch.getAllBatches(stock.getUid());
			for (int i=0; i<batches.size();i++){
				Batch batch = (Batch)batches.elementAt(i);
				if(batch.getEnd()!=null && !batch.getEnd().after(date)){
					//First find the product subcategory
					String uid=stock.getProduct()==null?"|"+stock.getUid():stock.getProduct().getFullProductSubGroupName(sPrintLanguage)+"|"+stock.getUid()+"|"+new SimpleDateFormat("dd/MM/yyyy").format(batch.getEnd())+"|"+batch.getLevel()+"|"+batch.getBatchNumber();
					stocks.put(uid, stock);
				}
			}
		}
		
		Hashtable printedSubTitels = new Hashtable();
		Iterator iStocks = stocks.keySet().iterator();
		boolean bInitialized = false;
		double generalTotal=0;
		while(iStocks.hasNext()){
			String key = (String)iStocks.next();
			ProductStock stock = (ProductStock)stocks.get(key);
			//Nu kijken we welke tussentitels er moeten geprint worden
			String[] subtitles = key.split("\\|")[0].split(";");
			String title="";
			for(int n=0;n<subtitles.length;n++){
				title+=subtitles[n]+";";
				if(printedSubTitels.get(title)==null){
					//This one must be printed
			        row =t.addElement("row");
			        if(n>0){
			        	addCol(row,n*5,"");
			        }
					addBoldCol(row,180-n*5,subtitles[n]);
					printedSubTitels.put(title, "1");
				}
			}
			bInitialized=true;
			//Nu printen we de gegevens van de productstock
	        row =t.addElement("row");
			addCol(row,80,stock.getProduct()==null?"":stock.getProduct().getName()+" ("+getTran("web","batchnumber.short")+": "+key.split("\\|")[4]+")");
			addCol(row,20,key.split("\\|")[2]);
			int level=0;
			try{
				level=Integer.parseInt(key.split("\\|")[3]);
			}
			catch(Exception r){};
			addCol(row,20,level+"");
			addCol(row,20,stock.getProduct()==null?"":ScreenHelper.getTranNoLink("product.unit",stock.getProduct().getUnit(),sPrintLanguage));
			double pump=0;
			if(stock.getProduct()!=null){
				pump=stock.getProduct().getLooseLastYearsAveragePrice(new java.util.Date(date.getTime()+day));
			}
			addPriceCol(row,20,pump,"#,##0.00");
			addPriceCol(row,20,level*pump);
			generalTotal+=level*pump;
		}
		if(bInitialized){
	        row =t.addElement("row");
			addRightBoldCol(row,160,ScreenHelper.getTranNoLink("web","general.total",sPrintLanguage));
			addPriceBoldCol(row,20,generalTotal);
		}
    }


    protected void printStockOut(org.dom4j.Document d, org.dom4j.Element t, String sDate, String sServiceStockUID) throws ParseException{
		d.add(t);
        t.addAttribute("size", "180");
        java.util.Date date = ScreenHelper.parseDate(sDate);
    	
		//Add title rows
        org.dom4j.Element row =t.addElement("row");
		row.addAttribute("type", "title");
		addCol(row,100,ScreenHelper.getTranNoLink("web","article",sPrintLanguage));
		addCol(row,40,ScreenHelper.getTranNoLink("web","stock",sPrintLanguage));
		addCol(row,40,ScreenHelper.getTranNoLink("web","minstock",sPrintLanguage));
		
		//Now we have to find all productstocks sorted by productsubgroup
		SortedMap stocks = new TreeMap();
		Vector productStocks = ServiceStock.getProductStocks(sServiceStockUID);
		for(int n=0;n<productStocks.size();n++){
			ProductStock stock = (ProductStock)productStocks.elementAt(n);
			if(stock.getLevel()<stock.getMinimumLevel()){
				//First find the product subcategory
				String uid=stock.getProduct()==null?"|"+stock.getUid():stock.getProduct().getFullProductSubGroupName(sPrintLanguage)+"|"+stock.getUid();
				stocks.put(uid, stock);
			}
		}
		
		Hashtable printedSubTitels = new Hashtable();
		Iterator iStocks = stocks.keySet().iterator();
		while(iStocks.hasNext()){
			String key = (String)iStocks.next();
			ProductStock stock = (ProductStock)stocks.get(key);
			//Nu kijken we welke tussentitels er moeten geprint worden
			String[] subtitles = key.split("\\|")[0].split(";");
			String title="";
			for(int n=0;n<subtitles.length;n++){
				title+=subtitles[n]+";";
				if(printedSubTitels.get(title)==null){
					//This one must be printed
			        row =t.addElement("row");
			        if(n>0){
			        	addCol(row,n*5,"");
			        }
					addBoldCol(row,180-n*5,subtitles[n]);
					printedSubTitels.put(title, "1");
				}
			}
			//Nu printen we de gegevens van de productstock
	        row =t.addElement("row");
			addCol(row,100,stock.getProduct()==null?"":stock.getProduct().getName());
			addCol(row,40,stock.getLevel()+"");
			addCol(row,40,stock.getMinimumLevel()+"");
		}
    }


    protected void printServiceStockInventory(org.dom4j.Document d, org.dom4j.Element t, String sDate, String sServiceStockUID) throws ParseException{
		d.add(t);
        t.addAttribute("size", "180");
    	
		//Add title rows
        org.dom4j.Element row =t.addElement("row");
		row.addAttribute("type", "title");
		addCol(row,90,ScreenHelper.getTranNoLink("web","article",sPrintLanguage));
		addCol(row,30,ScreenHelper.getTranNoLink("web","theor.stock",sPrintLanguage));
		addCol(row,30,ScreenHelper.getTranNoLink("web","pump",sPrintLanguage));
		addCol(row,30,ScreenHelper.getTranNoLink("web","theor.value",sPrintLanguage));
		
		//Now we have to find all productstocks sorted by productsubgroup
		SortedMap stocks = new TreeMap();
		Vector productStocks = ServiceStock.getProductStocks(sServiceStockUID);
		for(int n=0;n<productStocks.size();n++){
			ProductStock stock = (ProductStock)productStocks.elementAt(n);
			//First find the product subcategory
			String uid=stock.getProduct()==null?"|"+stock.getUid():stock.getProduct().getFullProductSubGroupName(sPrintLanguage)+"|"+stock.getUid();
			stocks.put(uid, stock);
		}
		
		Hashtable printedSubTitels = new Hashtable();
		Iterator iStocks = stocks.keySet().iterator();
		boolean bInitialized = false;
		double sectionTotal=0,generalTotal=0;
		String lasttitle="";
		while(iStocks.hasNext()){
			String key = (String)iStocks.next();
			ProductStock stock = (ProductStock)stocks.get(key);
			//Nu kijken we welke tussentitels er moeten geprint worden
			String[] subtitles = key.split("\\|")[0].split(";");
			String title="";
			for(int n=0;n<subtitles.length;n++){
				title+=subtitles[n]+";";
				if(printedSubTitels.get(title)==null){
					//First look if we don't have to print a section total
					if(bInitialized){
				        row =t.addElement("row");
						addRightBoldCol(row,150,ScreenHelper.getTranNoLink("web","total.for",sPrintLanguage)+": "+lasttitle);
						addPriceBoldCol(row,30,sectionTotal);
						sectionTotal=0;
						bInitialized=false;
					}
					//This one must be printed
			        row =t.addElement("row");
			        if(n>0){
			        	addCol(row,n*5,"");
			        }
					addBoldCol(row,180-n*5,subtitles[n]);
					printedSubTitels.put(title, "1");
				}
				lasttitle=subtitles[n];
			}
			bInitialized=true;
			java.util.Date date = ScreenHelper.parseDate(sDate);
			//Nu printen we de gegevens van de productstock
	        row =t.addElement("row");
			addCol(row,90,stock.getProduct()==null?"":stock.getProduct().getName());
			int level=stock.getLevel(date);
			addCol(row,30,level+"");
			double pump=0;
			if(stock.getProduct()!=null){
				pump=stock.getProduct().getLastYearsAveragePrice(new java.util.Date(date.getTime()+day));
			}
			addPriceCol(row,30,pump,"#,##0.00");
			addPriceCol(row,30,level*pump);
			sectionTotal+=level*pump;
			generalTotal+=level*pump;
		}
		if(bInitialized){
	        row =t.addElement("row");
			addRightBoldCol(row,150,ScreenHelper.getTranNoLink("web","total.for",sPrintLanguage)+": "+lasttitle);
			addPriceBoldCol(row,30,sectionTotal);
			addRightBoldCol(row,150,ScreenHelper.getTranNoLink("web","general.total",sPrintLanguage));
			addPriceBoldCol(row,30,generalTotal);
		}
    }

    protected void printMonthlyConsumption(org.dom4j.Document d, org.dom4j.Element t, String sDate, String sServiceStockUID,boolean bIncludePatients,boolean bIncludeStocks,boolean bOther) throws ParseException{
 		d.add(t);
        t.addAttribute("size", "180");

		//Add title rows
        org.dom4j.Element row =t.addElement("row");
		row.addAttribute("type", "title");
		addCol(row,20,ScreenHelper.getTranNoLink("web","code",sPrintLanguage),8);
		addCol(row,80,ScreenHelper.getTranNoLink("web","article",sPrintLanguage),8);
		addCol(row,20,ScreenHelper.getTranNoLink("web","unit",sPrintLanguage),8);
		addCol(row,20,ScreenHelper.getTranNoLink("web","cmm",sPrintLanguage),8);
		addCol(row,20,ScreenHelper.getTranNoLink("web","min.stock",sPrintLanguage),8);
		addCol(row,20,ScreenHelper.getTranNoLink("web","max.stock",sPrintLanguage),8);
		
		//Now we have to find all productstocks sorted by productsubgroup
		SortedMap stocks = new TreeMap();
		Vector productStocks = ServiceStock.getProductStocks(sServiceStockUID);
		for(int n=0;n<productStocks.size();n++){
			ProductStock stock = (ProductStock)productStocks.elementAt(n);
			//First find the product subcategory
			String uid=stock.getProduct()==null?"|"+stock.getUid():stock.getProduct().getFullProductSubGroupName(sPrintLanguage)+"|"+stock.getUid();
			stocks.put(uid, stock);
		}
		
 		Hashtable printedSubTitels = new Hashtable();
 		Iterator iStocks = stocks.keySet().iterator();
 		boolean bInitialized = false;
 		double sectionTotal=0,generalTotal=0;
 		String lasttitle="";
 		while(iStocks.hasNext()){
 			String key = (String)iStocks.next();
 			ProductStock stock = (ProductStock)stocks.get(key);
 			//Nu kijken we welke tussentitels er moeten geprint worden
 			String[] subtitles = key.split("\\|")[0].split(";");
 			String title="";
 			for(int n=0;n<subtitles.length;n++){
 				title+=subtitles[n]+";";
 				if(printedSubTitels.get(title)==null){
 					//This one must be printed
 			        row =t.addElement("row");
 			        if(n>0){
 			        	addCol(row,n*5,"");
 			        }
 					addBoldCol(row,180-n*5,subtitles[n]);
 					printedSubTitels.put(title, "1");
 				}
 				lasttitle=subtitles[n];
 			}
 			java.util.Date date = ScreenHelper.parseDate(sDate);
 			//Nu printen we de gegevens van de productstock
 	        row =t.addElement("row");
 			addCol(row,20,stock.getProduct()==null || stock.getProduct().getPrestationcode()==null?"":stock.getProduct().getPrestationcode());
 			addCol(row,80,stock.getProduct()==null || stock.getProduct().getName()==null?"":stock.getProduct().getName());
 			addCol(row,20,stock.getProduct()==null || stock.getProduct().getUnit()==null?"":ScreenHelper.getTranNoLink("product.unit",stock.getProduct().getUnit(),sPrintLanguage),7);
 			int averageConsumption=0;
 			if(stock.getProduct()!=null){
 				averageConsumption=stock.getAverageConsumption(new java.util.Date(date.getTime()+day),bIncludePatients,bIncludeStocks,bOther);
 			}
 			addCol(row,20,averageConsumption+"");
 			addCol(row,20,(averageConsumption*2)+"");
 			addCol(row,20,(averageConsumption*3)+"");
 		}
    	
    }
    
    protected void printServiceStockInventory(org.dom4j.Document d, org.dom4j.Element t, String sDateBegin, String sDateEnd, String sServiceStockUID) throws ParseException{
 		d.add(t);
         t.addAttribute("size", "290");

 		//Add title rows
         org.dom4j.Element row =t.addElement("row");
 		row.addAttribute("type", "title");
 		addCol(row,70,ScreenHelper.getTranNoLink("web","article",sPrintLanguage),8);
 		addCol(row,20,ScreenHelper.getTranNoLink("web","unit",sPrintLanguage),8);
 		addCol(row,20,ScreenHelper.getTranNoLink("web","init.stock",sPrintLanguage),8);
 		addCol(row,20,ScreenHelper.getTranNoLink("web","entries",sPrintLanguage),8);
 		addCol(row,20,ScreenHelper.getTranNoLink("web","exits",sPrintLanguage),8);
 		addCol(row,20,ScreenHelper.getTranNoLink("web","theor.stock",sPrintLanguage),8);
 		addCol(row,20,ScreenHelper.getTranNoLink("web","pump",sPrintLanguage),8);
 		addCol(row,20,ScreenHelper.getTranNoLink("web","theor.value",sPrintLanguage),8);
 		addCol(row,20,ScreenHelper.getTranNoLink("web","stock.phys",sPrintLanguage),8);
 		addCol(row,20,ScreenHelper.getTranNoLink("web","val.reelle",sPrintLanguage),8);
 		addCol(row,20,ScreenHelper.getTranNoLink("web","manq",sPrintLanguage),8);
 		addCol(row,20,ScreenHelper.getTranNoLink("web","exced",sPrintLanguage),8);
 		
 		//Now we have to find all productstocks sorted by productsubgroup
 		SortedMap stocks = new TreeMap();
 		Vector productStocks = ServiceStock.getProductStocks(sServiceStockUID);
 		for(int n=0;n<productStocks.size();n++){
 			ProductStock stock = (ProductStock)productStocks.elementAt(n);
 			//First find the product subcategory
 			String uid=stock.getProduct()==null?"|"+stock.getUid():stock.getProduct().getFullProductSubGroupName(sPrintLanguage)+"|"+stock.getUid();
 			stocks.put(uid, stock);
 		}
 		
 		Hashtable printedSubTitels = new Hashtable();
 		Iterator iStocks = stocks.keySet().iterator();
 		boolean bInitialized = false;
 		double sectionTotal=0,generalTotal=0;
 		String lasttitle="";
 		while(iStocks.hasNext()){
 			String key = (String)iStocks.next();
 			ProductStock stock = (ProductStock)stocks.get(key);
 			//Nu kijken we welke tussentitels er moeten geprint worden
 			String[] subtitles = key.split("\\|")[0].split(";");
 			String title="";
 			for(int n=0;n<subtitles.length;n++){
 				title+=subtitles[n]+";";
 				if(printedSubTitels.get(title)==null){
 					//First look if we don't have to print a section total
 					if(bInitialized){
 				        row =t.addElement("row");
 						addRightBoldCol(row,190,ScreenHelper.getTranNoLink("web","total.for",sPrintLanguage)+": "+lasttitle);
 						addPriceBoldCol(row,20,sectionTotal);
 						addCol(row,20,"");
 						addCol(row,20,"");
 						addCol(row,20,"");
 						addCol(row,20,"");
 						sectionTotal=0;
 						bInitialized=false;
 					}
 					//This one must be printed
 			        row =t.addElement("row");
 			        if(n>0){
 			        	addCol(row,n*5,"");
 			        }
 					addBoldCol(row,210-n*5,subtitles[n]);
 					addCol(row,20,"");
 					addCol(row,20,"");
 					addCol(row,20,"");
 					addCol(row,20,"");
 					printedSubTitels.put(title, "1");
 				}
 				lasttitle=subtitles[n];
 			}
 			bInitialized=true;
 			java.util.Date begin = ScreenHelper.parseDate(sDateBegin);
 			java.util.Date end = ScreenHelper.parseDate(sDateEnd);
 			//Nu printen we de gegevens van de productstock
 	        row =t.addElement("row");
 			addCol(row,70,stock.getProduct()==null?"":stock.getProduct().getName());
 			addCol(row,20,stock.getProduct()==null?"":ScreenHelper.getTranNoLink("product.unit",stock.getProduct().getUnit(),sPrintLanguage),7);
 			int initiallevel=stock.getLevel(begin);
 			addCol(row,20,initiallevel+"");
 			int in = stock.getTotalUnitsInForPeriod(begin, new java.util.Date(end.getTime()+day));
 			addCol(row,20,in+"");
 			int out = stock.getTotalUnitsOutForPeriod(begin, new java.util.Date(end.getTime()+day));
 			addCol(row,20,out+"");
 			addCol(row,20,(initiallevel+in-out)+"");
 			double pump=0;
 			if(stock.getProduct()!=null){
 				pump=stock.getProduct().getLastYearsAveragePrice(new java.util.Date(end.getTime()+day));
 			}
 			addPriceCol(row,20,pump,"#,##0.00");
 			addPriceCol(row,20,(initiallevel+in-out)*pump);
 			addCol(row,20,"");
 			addCol(row,20,"");
 			addCol(row,20,"");
 			addCol(row,20,"");
 			sectionTotal+=(initiallevel+in-out)*pump;
 			generalTotal+=(initiallevel+in-out)*pump;
 		}
 		if(bInitialized){
 	        row =t.addElement("row");
 			addRightBoldCol(row,190,ScreenHelper.getTranNoLink("web","total.for",sPrintLanguage)+": "+lasttitle);
 			addPriceBoldCol(row,20,sectionTotal);
 			addCol(row,20,"");
 			addCol(row,20,"");
 			addCol(row,20,"");
 			addCol(row,20,"");
 			addRightBoldCol(row,190,ScreenHelper.getTranNoLink("web","general.total",sPrintLanguage));
 			addPriceBoldCol(row,20,generalTotal);
 			addCol(row,20,"");
 			addCol(row,20,"");
 			addCol(row,20,"");
 			addCol(row,20,"");
 		}

     }
    
    protected void printServiceStockOperations(org.dom4j.Document d, org.dom4j.Element t, String sDateBegin, String sDateEnd, String sServiceStockUID) throws ParseException{
 		d.add(t);
        t.addAttribute("size", "260");

 		//Add title rows
        org.dom4j.Element row =t.addElement("row");
 		row.addAttribute("type", "title");
 		addCol(row,80,"");
 		addCol(row,40,ScreenHelper.getTranNoLink("web","initial.situation",sPrintLanguage));
 		addCol(row,40,ScreenHelper.getTranNoLink("web","entries",sPrintLanguage));
 		addCol(row,40,ScreenHelper.getTranNoLink("web","exits",sPrintLanguage));
 		addCol(row,60,ScreenHelper.getTranNoLink("web","stock",sPrintLanguage));
 		
		row =t.addElement("row");
		row.addAttribute("type", "title");
 		addCol(row,80,ScreenHelper.getTranNoLink("web","article",sPrintLanguage));
 		addCol(row,20,ScreenHelper.getTranNoLink("web","qte",sPrintLanguage));
 		addCol(row,20,ScreenHelper.getTranNoLink("web","amount",sPrintLanguage));
 		addCol(row,20,ScreenHelper.getTranNoLink("web","qte",sPrintLanguage));
 		addCol(row,20,ScreenHelper.getTranNoLink("web","amount",sPrintLanguage));
 		addCol(row,20,ScreenHelper.getTranNoLink("web","qte",sPrintLanguage));
 		addCol(row,20,ScreenHelper.getTranNoLink("web","amount",sPrintLanguage));
 		addCol(row,20,ScreenHelper.getTranNoLink("web","qte",sPrintLanguage));
 		addCol(row,20,ScreenHelper.getTranNoLink("web","pump",sPrintLanguage));
 		addCol(row,20,ScreenHelper.getTranNoLink("web","amount",sPrintLanguage));
 		
 		//Now we have to find all productstocks sorted by productsubgroup
 		SortedMap stocks = new TreeMap();
 		Vector productStocks = ServiceStock.getProductStocks(sServiceStockUID);
 		for(int n=0;n<productStocks.size();n++){
 			ProductStock stock = (ProductStock)productStocks.elementAt(n);
 			//First find the product subcategory
 			String uid=stock.getProduct()==null?"|"+stock.getUid():stock.getProduct().getFullProductSubGroupName(sPrintLanguage)+"|"+stock.getUid();
 			stocks.put(uid, stock);
 		}
 		
 		Hashtable printedSubTitels = new Hashtable();
 		Iterator iStocks = stocks.keySet().iterator();
 		double sectionTotal=0,generalTotal=0;
 		String lasttitle="";
 		while(iStocks.hasNext()){
 			String key = (String)iStocks.next();
 			ProductStock stock = (ProductStock)stocks.get(key);
 			//Nu kijken we welke tussentitels er moeten geprint worden
 			String[] subtitles = key.split("\\|")[0].split(";");
 			String title="";
 			for(int n=0;n<subtitles.length;n++){
 				title+=subtitles[n]+";";
 				if(printedSubTitels.get(title)==null){
 					//First look if we don't have to print a section total
 					//This one must be printed
 			        row =t.addElement("row");
 			        if(n>0){
 			        	addCol(row,n*5,"");
 			        }
 					addBoldCol(row,260-n*5,subtitles[n]);
 					printedSubTitels.put(title, "1");
 				}
 				lasttitle=subtitles[n];
 			}
 			java.util.Date begin = ScreenHelper.parseDate(sDateBegin);
 			java.util.Date end = ScreenHelper.parseDate(sDateEnd);
 			//Nu printen we de gegevens van de productstock
 	        row =t.addElement("row");
 			addCol(row,80,stock.getProduct()==null?"":stock.getProduct().getName());
 			int initiallevel=stock.getLevel(begin);
 			addCol(row,20,initiallevel+"");
 			double pump=0;
 			if(stock.getProduct()!=null){
 				pump=stock.getProduct().getLastYearsAveragePrice(new java.util.Date(end.getTime()+day));
 			}
 			addPriceCol(row,20,initiallevel*pump);
 			int in = stock.getTotalUnitsInForPeriod(begin, new java.util.Date(end.getTime()+day));
 			addCol(row,20,in+"");
 			addPriceCol(row,20,in*pump);
 			int out = stock.getTotalUnitsOutForPeriod(begin, new java.util.Date(end.getTime()+day));
 			addCol(row,20,out+"");
 			addPriceCol(row,20,out*pump);
 			addCol(row,20,(initiallevel+in-out)+"");
 			addPriceCol(row,20,pump,"#,##0.00");
 			addPriceCol(row,20,(initiallevel+in-out)*pump);
 		}
     }
    protected void printServiceOutgoingStockOperations(org.dom4j.Document d, org.dom4j.Element t, String sDateBegin, String sDateEnd, String sServiceStockUID) throws ParseException{
 		d.add(t);
        t.addAttribute("size", "195");

 		//Add title rows
        org.dom4j.Element row =t.addElement("row");
 		row.addAttribute("type", "title");
 		addCol(row,30,ScreenHelper.getTranNoLink("web","document",sPrintLanguage));
 		addCol(row,80,ScreenHelper.getTranNoLink("web","article",sPrintLanguage));
 		addCol(row,20,ScreenHelper.getTranNoLink("web","year",sPrintLanguage));
 		addCol(row,20,ScreenHelper.getTranNoLink("web","qte",sPrintLanguage));
 		addCol(row,20,ScreenHelper.getTranNoLink("web","pu",sPrintLanguage));
 		addCol(row,25,ScreenHelper.getTranNoLink("web","totalprice",sPrintLanguage));

 		//First we make a list of all productstockoperations ordered by date
		java.util.Date begin = ScreenHelper.parseDate(sDateBegin);
		java.util.Date end = ScreenHelper.parseDate(sDateEnd);
		double subtotal=0, generaltotal=0;
 		Vector deliveries = ProductStockOperation.getServiceStockDeliveries(sServiceStockUID, begin, new java.util.Date(end.getTime()+day), "OC_OPERATION_DATE,OC_OPERATION_SRCDESTUID,OC_OPERATION_DOCUMENTUID", "ASC");
 		String activedate="",activedestination="$$$";
 		for(int n=0;n<deliveries.size();n++){
 			ProductStockOperation operation = (ProductStockOperation)deliveries.elementAt(n);
 			String date=new SimpleDateFormat("dd/MM/yyyy").format(operation.getDate());
 			String destination=operation.getDescription()+"."+(operation.getSourceDestination()==null?"":ScreenHelper.checkString(operation.getSourceDestination().getObjectType()))+"."+(operation.getSourceDestination()==null?"":ScreenHelper.checkString(operation.getSourceDestination().getObjectUid()))+"."+operation.getDocumentUID();

 			if(activedate.length()>0 && (!date.equalsIgnoreCase(activedate) || !destination.equalsIgnoreCase(activedestination))){
 				row =t.addElement("row");
 		 		addRightBoldCol(row,170,ScreenHelper.getTranNoLink("web", "subtotal", sPrintLanguage));
 		 		addPriceBoldCol(row,25,subtotal);
 		 		subtotal=0;
 		 		activedestination="$$$";
 			}
 			if(!date.equalsIgnoreCase(activedate)){
 				row =t.addElement("row");
 		 		addBoldCol(row,195,date);
 		 		activedate=date;
 			}
 			if(!destination.equalsIgnoreCase(activedestination)){
 				row =t.addElement("row");
 		 		addCol(row,10,"");
 	 			String document="";
 	 			if(operation.getDocument()!=null){
 	 				document=operation.getDocument().getReference();
 	 			}
 		 		addBoldCol(row,60,getTran("web","document")+": "+document);
 		 		addBoldCol(row,125,ScreenHelper.getTranNoLink("productstockoperation.medicationdelivery",operation.getDescription(),sPrintLanguage)+": "+operation.getSourceDestinationName());
 		 		activedestination=destination;
 			}
 	        row =t.addElement("row");
	 		addCol(row,10,"");
 			addCol(row,100,operation.getProductStock()!=null && operation.getProductStock().getProduct()!=null?ScreenHelper.checkString(operation.getProductStock().getProduct().getName()):"");
 			addCol(row,20,operation.getDate()==null?"":new SimpleDateFormat("yyyy").format(operation.getDate()));
 			addCol(row,20,operation.getUnitsChanged()+"");
 			double price=operation.getProductStock()==null || operation.getProductStock().getProduct()==null?0:operation.getProductStock().getProduct().getLastYearsAveragePrice(operation.getDate()==null?new java.util.Date():operation.getDate());
 			addPriceCol(row,20,price,"#,##0.00");
 			addPriceCol(row,25,operation.getUnitsChanged()*price);
 			subtotal+=operation.getUnitsChanged()*price;
 			generaltotal+=operation.getUnitsChanged()*price;
 		}
		if(activedate.length()>0){
			row =t.addElement("row");
	 		addRightBoldCol(row,170,ScreenHelper.getTranNoLink("web", "subtotal", sPrintLanguage));
	 		addPriceBoldCol(row,25,subtotal);
		}

 		row =t.addElement("row");
 		addCol(row,195,"");
 		addRightBoldCol(row,170,ScreenHelper.getTranNoLink("web", "total", sPrintLanguage));
 		addPriceBoldCol(row,25,generaltotal);
 		
     }
    
    protected void printServiceIncomingStockOperations(org.dom4j.Document d, org.dom4j.Element t, String sDateBegin, String sDateEnd, String sServiceStockUID) throws ParseException{
 		d.add(t);
        t.addAttribute("size", "180");
		java.util.Date begin = ScreenHelper.parseDate(sDateBegin);
		java.util.Date end = ScreenHelper.parseDate(sDateEnd);

		//Add title rows
        org.dom4j.Element row =t.addElement("row");
		row.addAttribute("type", "title");
		addCol(row,30,ScreenHelper.getTranNoLink("web","category",sPrintLanguage),8);
		addCol(row,70,ScreenHelper.getTranNoLink("web","article",sPrintLanguage),8);
		addCol(row,20,ScreenHelper.getTranNoLink("web","quantity",sPrintLanguage),8);
		addCol(row,20,ScreenHelper.getTranNoLink("web","unit",sPrintLanguage),8);
		addCol(row,20,ScreenHelper.getTranNoLink("web","PU",sPrintLanguage),8);
		addCol(row,20,ScreenHelper.getTranNoLink("web","totalprice",sPrintLanguage),8);
		
		//Now we have to find all productstocks sorted by productsubgroup
		SortedMap stocks = new TreeMap();
		Vector productStocks = ServiceStock.getProductStocks(sServiceStockUID);
		for(int n=0;n<productStocks.size();n++){
			ProductStock stock = (ProductStock)productStocks.elementAt(n);
			//First we look up if there have been incoming transactions
			if(stock.getTotalUnitsInForPeriod(begin, end)>0){
				//First find the product subcategory
				String uid=stock.getProduct()==null?"|"+stock.getUid():stock.getProduct().getFullProductSubGroupName(sPrintLanguage)+"|"+stock.getUid();
				stocks.put(uid, stock);
			}
		}
		
		Hashtable printedSubTitels = new Hashtable();
		Iterator iStocks = stocks.keySet().iterator();
		boolean bInitialized = false;
		double generalTotal=0;
		while(iStocks.hasNext()){
			String key = (String)iStocks.next();
			ProductStock stock = (ProductStock)stocks.get(key);
			//Nu kijken we welke tussentitels er moeten geprint worden
			String[] subtitles = key.split("\\|")[0].split(";");
			String title="";
			for(int n=0;n<subtitles.length;n++){
				title+=subtitles[n]+";";
				if(printedSubTitels.get(title)==null){
					//This one must be printed
			        row =t.addElement("row");
			        if(n>0){
			        	addCol(row,n*5,"");
			        }
					addBoldCol(row,180-n*5,subtitles[n]);
					printedSubTitels.put(title, "1");
				}
			}
			bInitialized=true;
			//Nu printen we de gegevens van de productstock
	        row =t.addElement("row");
	        addCol(row,10,"");
			addCol(row,90,stock.getProduct()==null?"":stock.getProduct().getName());
			int in = stock.getTotalUnitsInForPeriod(begin, end);
			addCol(row,20,in+"");
			addCol(row,20,stock.getProductUid()==null?"":ScreenHelper.getTranNoLink("product.unit",stock.getProduct().getUnit(),sPrintLanguage),7);
			double pump=0;
			if(stock.getProduct()!=null){
				pump=stock.getProduct().getLooseLastYearsAveragePrice(new java.util.Date(end.getTime()+day));
			}
			addPriceCol(row,20,pump,"#,##0.00");
			addPriceCol(row,20,in*pump);
			generalTotal+=in*pump;
		}
		if(bInitialized){
	        row =t.addElement("row");
			addRightBoldCol(row,160,ScreenHelper.getTranNoLink("web","general.total",sPrintLanguage));
			addPriceBoldCol(row,20,generalTotal);
		}

     }
    
    protected void printServiceIncomingStockOperationsPerOrder(org.dom4j.Document d, org.dom4j.Element t, String sDateBegin, String sDateEnd, String sServiceStockUID) throws ParseException{
 		d.add(t);
        t.addAttribute("size", "190");
		java.util.Date begin = ScreenHelper.parseDate(sDateBegin);
		java.util.Date end = ScreenHelper.parseDate(sDateEnd);

		//Add title rows
        org.dom4j.Element row =t.addElement("row");
		row.addAttribute("type", "title");
		addCol(row,90,ScreenHelper.getTranNoLink("web","article",sPrintLanguage),8);
		addCol(row,20,ScreenHelper.getTranNoLink("web","expiry",sPrintLanguage),8);
		addCol(row,20,ScreenHelper.getTranNoLink("web","quantity",sPrintLanguage),8);
		addCol(row,20,ScreenHelper.getTranNoLink("web","unit",sPrintLanguage),8);
		addCol(row,20,ScreenHelper.getTranNoLink("web","PU",sPrintLanguage),8);
		addCol(row,20,ScreenHelper.getTranNoLink("web","totalprice",sPrintLanguage),8);

		String activedocument = "$$$";
		double sectiontotal = 0;
		//Now we have to find all the orders for this period
		Vector receipts = ProductStockOperation.getReceiptsForServiceStock(sServiceStockUID, begin, new java.util.Date(end.getTime()+day), "OC_OPERATION_DOCUMENTUID", "ASC");
		for(int n=0;n<receipts.size();n++){
			ProductStockOperation operation = (ProductStockOperation)receipts.elementAt(n);
			if(!ScreenHelper.checkString(operation.getDocumentUID()).equals(activedocument)){
				//First check if we have to print the sectiontotal
				if(!activedocument.equalsIgnoreCase("$$$")){
					row =t.addElement("row");
					addRightBoldCol(row, 170, getTran("web","total"));
					addPriceBoldCol(row, 20, sectiontotal);
					sectiontotal=0;
				}
				//We have to print the order title
				if(ScreenHelper.checkString(operation.getDocumentUID()).length()==0){
					row =t.addElement("row");
					addBoldCol(row,45,getTran("web","date")+": ?");
					addBoldCol(row,45,getTran("web","ordernr")+": ?");
					addBoldCol(row,100,getTran("web","supplier")+": ?");
				}
				else {
					OperationDocument document = OperationDocument.get(operation.getDocumentUID());
					if(document==null){
						row =t.addElement("row");
						addBoldCol(row,45,getTran("web","date")+": ?");
						addBoldCol(row,45,getTran("web","ordernr")+": ?");
						addBoldCol(row,100,getTran("web","supplier")+": ?");
					}
					else {
						row =t.addElement("row");
						addBoldCol(row,45,getTran("web","date")+": "+new SimpleDateFormat("dd/MM/yyyy").format(document.getDate()));
						addBoldCol(row,45,getTran("web","ordernr")+": "+document.getReference());
						addBoldCol(row,100,getTran("web","supplier")+": "+document.getSourceName(sPrintLanguage));
					}
				}
				activedocument=ScreenHelper.checkString(operation.getDocumentUID());
			}
			//Now we print the operation data
			row =t.addElement("row");
			addCol(row,90,operation.getProductStock()==null || operation.getProductStock().getProduct()==null?"?":operation.getProductStock().getProduct().getName());
			addCol(row,20,operation.getBatchEnd()==null?"":new SimpleDateFormat("dd/MM/yyyy").format(operation.getBatchEnd()));
			int in=operation.getUnitsChanged();
			addCol(row,20,in+"");
			addCol(row,20,operation.getProductStock()==null || operation.getProductStock().getProduct()==null?"?":ScreenHelper.getTranNoLink("product.unit",operation.getProductStock().getProduct().getUnit(),sPrintLanguage),7);
			double pump=0;
			if(operation.getProductStock()!=null && operation.getProductStock().getProduct()!=null){
				pump=operation.getProductStock().getProduct().getLooseLastYearsAveragePrice(new java.util.Date(end.getTime()+day));
			}
			addPriceCol(row,20,pump,"#,##0.00");
			addPriceCol(row,20,in*pump);
			sectiontotal+=in*pump;
		}
		if(!activedocument.equalsIgnoreCase("$$$")){
			row =t.addElement("row");
			addRightBoldCol(row, 170, getTran("web","total"));
			addPriceBoldCol(row, 20, sectiontotal);
		}
     }
    
    protected void printServiceIncomingStockOperationsPerItem(org.dom4j.Document d, org.dom4j.Element t, String sDateBegin, String sDateEnd, String sServiceStockUID) throws ParseException{
 		d.add(t);
        t.addAttribute("size", "140");
		java.util.Date begin = ScreenHelper.parseDate(sDateBegin);
		java.util.Date end = ScreenHelper.parseDate(sDateEnd);

		//Add title rows
        org.dom4j.Element row =t.addElement("row");
		row.addAttribute("type", "title");
		addCol(row,20,ScreenHelper.getTranNoLink("web","date",sPrintLanguage),8);
		addCol(row,30,ScreenHelper.getTranNoLink("web","docnr",sPrintLanguage),8);
		addCol(row,20,ScreenHelper.getTranNoLink("web","quantity",sPrintLanguage),8);
		addCol(row,20,ScreenHelper.getTranNoLink("web","PU",sPrintLanguage),8);
		addCol(row,20,ScreenHelper.getTranNoLink("web","totalprice",sPrintLanguage),8);
		addCol(row,30,ScreenHelper.getTranNoLink("web","provider",sPrintLanguage),8);

		String activeproduct = "$$$";
		double sectiontotal = 0;
		//Now we have to find all the orders for this period
		SortedMap operations = new TreeMap();
		Vector receipts = ProductStockOperation.getReceiptsForServiceStock(sServiceStockUID, begin, new java.util.Date(end.getTime()+day), "OC_OPERATION_DOCUMENTUID", "ASC");
		for(int n=0;n<receipts.size();n++){
			ProductStockOperation operation = (ProductStockOperation)receipts.elementAt(n);
			String prodname="";
			if(operation.getProductStock()!=null && operation.getProductStock().getProduct()!=null){
				operations.put(operation.getProductStock().getProduct().getName()+";"+operation.getUid(), operation);
			}
		}
		Iterator iOperations = operations.keySet().iterator();
		while(iOperations.hasNext()){
			String key=(String)iOperations.next();
			ProductStockOperation operation = (ProductStockOperation)operations.get(key);
			String prodname="?";
			if(operation.getProductStock()!=null && operation.getProductStock().getProduct()!=null){
				prodname=operation.getProductStock().getProduct().getName();
			}
			if(!prodname.equals(activeproduct)){
				//First check if we have to print the sectiontotal
				if(!activeproduct.equalsIgnoreCase("$$$")){
					row =t.addElement("row");
					addRightBoldCol(row, 90, getTran("web","total"));
					addPriceBoldCol(row, 50, sectiontotal);
					sectiontotal=0;
				}
				//We have to print the productname
				row =t.addElement("row");
				row.addAttribute("type", "title");
				addCenterBoldCol(row, 140, prodname);
				activeproduct=prodname;
			}
			//Now we print the operation data
			row =t.addElement("row");
			addCol(row,20,operation.getDate()==null?"":new SimpleDateFormat("dd/MM/yyyy").format(operation.getDate()));
			addCol(row,30,operation.getDocument()==null?"":operation.getDocument().getReference());
			int in=operation.getUnitsChanged();
			addCol(row,20,in+"");
			double pump=0;
			if(operation.getProductStock()!=null && operation.getProductStock().getProduct()!=null){
				pump=operation.getProductStock().getProduct().getLooseLastYearsAveragePrice(new java.util.Date(end.getTime()+day));
			}
			addPriceCol(row,20,pump,"#,##0.00");
			addPriceCol(row,20,in*pump);
			addCol(row,30,operation.getDocument()==null?"":operation.getDocument().getSourceName(sPrintLanguage));
			sectiontotal+=in*pump;
		}
		if(!activeproduct.equalsIgnoreCase("$$$")){
			row =t.addElement("row");
			addRightBoldCol(row, 90, getTran("web","total"));
			addPriceBoldCol(row, 50, sectiontotal);
		}
     }

    protected void printServiceIncomingStockOperationsPerCategoryItem(org.dom4j.Document d, org.dom4j.Element t, String sDateBegin, String sDateEnd, String sServiceStockUID) throws ParseException{
 		d.add(t);
        t.addAttribute("size", "160");
		java.util.Date begin = ScreenHelper.parseDate(sDateBegin);
		java.util.Date end = ScreenHelper.parseDate(sDateEnd);

		//Add title rows
        org.dom4j.Element row =t.addElement("row");
		row.addAttribute("type", "title");
		addCol(row,20,ScreenHelper.getTranNoLink("web","month",sPrintLanguage),8);
		addCol(row,80,ScreenHelper.getTranNoLink("web","article",sPrintLanguage),8);
		addCol(row,20,ScreenHelper.getTranNoLink("web","quantity",sPrintLanguage),8);
		addCol(row,20,ScreenHelper.getTranNoLink("web","PU",sPrintLanguage),8);
		addCol(row,20,ScreenHelper.getTranNoLink("web","totalprice",sPrintLanguage),8);

		String activecategory = "$$$";
		String activeproduct = "$$$";
		String activemonth ="$$$";
		//Now we have to find all the orders for this period
		SortedMap operations = new TreeMap();
		Vector receipts = ProductStockOperation.getReceiptsForServiceStock(sServiceStockUID, begin, new java.util.Date(end.getTime()+day), "OC_OPERATION_DOCUMENTUID", "ASC");
		for(int n=0;n<receipts.size();n++){
			ProductStockOperation operation = (ProductStockOperation)receipts.elementAt(n);
			String prodname="";
			if(operation.getProductStock()!=null && operation.getProductStock().getProduct()!=null){
				operations.put(new SimpleDateFormat("MM/yyyy").format(operation.getDate())+"|"+operation.getProductStock().getProduct().getFullProductSubGroupName(sPrintLanguage)+"|"+operation.getProductStock().getProduct().getName()+"|"+operation.getUid(), operation);
			}
		}
		Iterator iOperations = operations.keySet().iterator();
		Hashtable printedSubTitels = new Hashtable();
		while(iOperations.hasNext()){
			String key=(String)iOperations.next();
			ProductStockOperation operation = (ProductStockOperation)operations.get(key);
			String month=key.split("\\|")[0];
			if(!month.equals(activemonth)){
				//We have to print the month
				row =t.addElement("row");
				addBoldCol(row, 160, month);
				activemonth=month;
				printedSubTitels = new Hashtable();
				activecategory="$$$";
			}
			String category=key.split("\\|")[1];
			if(!category.equals(activecategory)){
				//We have to print the category
				String[] subtitles = category.split(";");
				String title="";
				for(int n=0;n<subtitles.length;n++){
					title+=subtitles[n]+";";
					if(printedSubTitels.get(title)==null){
						//This one must be printed
				        row =t.addElement("row");
				        if(n>0){
				        	addCol(row,n*5,"");
				        }
						addBoldCol(row,160-n*5,subtitles[n]);
						printedSubTitels.put(title, "1");
					}
				}
				activecategory=category;
				activeproduct="$$$";
			}
			String productname=key.split("\\|")[2];
			//Now we print the operation data
			row =t.addElement("row");
			addCol(row,20,"");
			addCol(row,80,productname);
			int in=operation.getUnitsChanged();
			addCol(row,20,in+"");
			double pump=operation.getPrice();
			if(pump==0){
				if(operation.getProductStock()!=null && operation.getProductStock().getProduct()!=null){
					pump=operation.getProductStock().getProduct().getLooseLastYearsAveragePrice(new java.util.Date(end.getTime()+day));
				}
			}
			addPriceCol(row,20,pump,"#,##0.00");
			addPriceCol(row,20,in*pump);
		}
     }

    protected void printServiceIncomingStockOperationsPerProvider(org.dom4j.Document d, org.dom4j.Element t, String sDateBegin, String sDateEnd, String sServiceStockUID) throws ParseException{
 		d.add(t);
        t.addAttribute("size", "180");
		java.util.Date begin = ScreenHelper.parseDate(sDateBegin);
		java.util.Date end = ScreenHelper.parseDate(sDateEnd);

		//Add title rows
        org.dom4j.Element row =t.addElement("row");
		row.addAttribute("type", "title");
		addCol(row,80,ScreenHelper.getTranNoLink("web","article",sPrintLanguage),8);
		addCol(row,20,ScreenHelper.getTranNoLink("web","expiry",sPrintLanguage),8);
		addCol(row,20,ScreenHelper.getTranNoLink("web","quantity",sPrintLanguage),8);
		addCol(row,20,ScreenHelper.getTranNoLink("web","unit",sPrintLanguage),8);
		addCol(row,20,ScreenHelper.getTranNoLink("web","PU",sPrintLanguage),8);
		addCol(row,20,ScreenHelper.getTranNoLink("web","totalprice",sPrintLanguage),8);

		String activeprovider = "$$$";
		String activedocument = "$$$";
		double sectiontotal = 0;
		//Now we have to find all the orders for this period
		SortedMap operations = new TreeMap();
		Vector receipts = ProductStockOperation.getReceiptsForServiceStock(sServiceStockUID, begin, new java.util.Date(end.getTime()+day), "OC_OPERATION_DOCUMENTUID", "ASC");
		for(int n=0;n<receipts.size();n++){
			ProductStockOperation operation = (ProductStockOperation)receipts.elementAt(n);
			String provname="?";
			if(operation.getDocument()!=null && ScreenHelper.checkString(operation.getDocument().getSourceName(sPrintLanguage)).length()>0){
				provname=ScreenHelper.checkString(operation.getDocument().getSourceName(sPrintLanguage));
			}
			String docid="?";
			if(operation.getDocument()!=null){
				docid=operation.getDocument().getUid();
			}
			operations.put(provname+";"+docid+";"+operation.getUid(), operation);
		}
		Iterator iOperations = operations.keySet().iterator();
		while(iOperations.hasNext()){
			String key=(String)iOperations.next();
			ProductStockOperation operation = (ProductStockOperation)operations.get(key);
			String provname=key.split(";")[0];
			boolean bNewProvider=false;
			if(!provname.equals(activeprovider)){
				//First check if we have to print the sectiontotal
				if(!activeprovider.equalsIgnoreCase("$$$")){
					row =t.addElement("row");
					addRightBoldCol(row, 160, getTran("web","total"));
					addPriceBoldCol(row, 20, sectiontotal);
					sectiontotal=0;
					activedocument = "$$$";
					bNewProvider=true;
				}
				//We have to print the provider name
				row =t.addElement("row");
				addBoldCol(row, 180, getTran("web","provider")+": "+provname);
				activeprovider=provname;
			}
			String docid=key.split(";")[1];
			if(!docid.equals(activedocument)){
				//First check if we have to print the sectiontotal
				if(!bNewProvider && !activedocument.equalsIgnoreCase("$$$")){
					row =t.addElement("row");
					addRightBoldCol(row, 160, getTran("web","total"));
					addPriceBoldCol(row, 20, sectiontotal);
					sectiontotal=0;
					activedocument = "$$$";
				}
				//We have to print the document data 
				String docdate="?";
				String docref="?";
				if(!docid.equalsIgnoreCase("?")){
					OperationDocument document = OperationDocument.get(docid);
					if(document!=null){
						docdate=new SimpleDateFormat("dd/MM/yyyy").format(document.getDate());
						docref=document.getReference()+"";
					}
				}
				row =t.addElement("row");
				addBoldCol(row, 40, getTran("web","date")+": "+docdate);
				addBoldCol(row, 140, getTran("web","docnr")+": "+docref);
				activedocument=docid;
			}
			//Now we print the operation data
			row =t.addElement("row");
			addCol(row,80,operation.getProductStock()==null || operation.getProductStock().getProduct()==null?"?":operation.getProductStock().getProduct().getName());
			addCol(row,20,operation.getBatchEnd()==null?"":new SimpleDateFormat("dd/MM/yyyy").format(operation.getBatchEnd()));
			int in=operation.getUnitsChanged();
			addCol(row,20,in+"");
			addCol(row,20,operation.getProductStock()==null || operation.getProductStock().getProduct()==null?"?":ScreenHelper.getTranNoLink("product.unit",operation.getProductStock().getProduct().getUnit(),sPrintLanguage),7);
			double pump=0;
			if(operation.getProductStock()!=null && operation.getProductStock().getProduct()!=null){
				pump=operation.getProductStock().getProduct().getLooseLastYearsAveragePrice(new java.util.Date(end.getTime()+day));
			}
			addPriceCol(row,20,pump,"#,##0.00");
			addPriceCol(row,20,in*pump);
			sectiontotal+=in*pump;
		}
		if(!activedocument.equalsIgnoreCase("$$$")){
			row =t.addElement("row");
			addRightBoldCol(row, 160, getTran("web","total"));
			addPriceBoldCol(row, 20, sectiontotal);
		}
     }
    
    protected void printServiceOutgoingStockOperationsListingPerService(org.dom4j.Document d, org.dom4j.Element t, String sDateBegin, String sDateEnd, String sServiceStockUID, String destinationStockUID) throws ParseException{
 		d.add(t);
        t.addAttribute("size", "170");

 		//Add title rows
        org.dom4j.Element row =t.addElement("row");
 		row.addAttribute("type", "title");
 		addCol(row,30,ScreenHelper.getTranNoLink("web","warehouse",sPrintLanguage));
 		addCol(row,80,ScreenHelper.getTranNoLink("web","article",sPrintLanguage));
 		addCol(row,20,ScreenHelper.getTranNoLink("web","qte",sPrintLanguage));
 		addCol(row,20,ScreenHelper.getTranNoLink("web","pu",sPrintLanguage));
 		addCol(row,20,ScreenHelper.getTranNoLink("web","amount",sPrintLanguage));

 		//First we make a list of all productstockoperations ordered by date
		java.util.Date begin = ScreenHelper.parseDate(sDateBegin);
		java.util.Date end = ScreenHelper.parseDate(sDateEnd);
		double subtotal=0, generaltotal=0;
 		Vector deliveries = ProductStockOperation.getServiceDestinationStockDeliveries(sServiceStockUID,destinationStockUID, begin, new java.util.Date(end.getTime()+day), "OC_OPERATION_DATE,OC_OPERATION_DOCUMENTUID", "ASC");
 		String activedate="",activedestination="$$$";
 		for(int n=0;n<deliveries.size();n++){
 			ProductStockOperation operation = (ProductStockOperation)deliveries.elementAt(n);
 			String date=new SimpleDateFormat("dd/MM/yyyy").format(operation.getDate());
 			String destination=operation.getDescription()+"."+date+"."+operation.getDocumentUID();

 			if(!destination.equalsIgnoreCase(activedestination)){
 				if(!activedestination.equalsIgnoreCase("$$$")){
 					row =t.addElement("row");
 			 		addRightBoldCol(row,150,ScreenHelper.getTranNoLink("web", "subtotal", sPrintLanguage));
 			 		addPriceBoldCol(row,20,subtotal);
 				}
 				row =t.addElement("row");
 	 			String document="";
 	 			if(operation.getDocument()!=null){
 	 				document=operation.getDocument().getReference();
 	 			}
 		 		addBoldCol(row,170,date +"   -   "+getTran("web","document")+": "+document);
 		 		activedestination=destination;
 		 		subtotal=0;
 			}
 	        row =t.addElement("row");
	 		addCol(row,30,"");
 			addCol(row,80,operation.getProductStock()!=null && operation.getProductStock().getProduct()!=null?ScreenHelper.checkString(operation.getProductStock().getProduct().getName()):"");
 			addCol(row,20,operation.getUnitsChanged()+"");
 			double price=operation.getProductStock()==null || operation.getProductStock().getProduct()==null?0:operation.getProductStock().getProduct().getLastYearsAveragePrice(operation.getDate()==null?new java.util.Date():operation.getDate());
 			addPriceCol(row,20,price,"#,##0.00");
 			addPriceCol(row,20,operation.getUnitsChanged()*price);
 			subtotal+=operation.getUnitsChanged()*price;
 			generaltotal+=operation.getUnitsChanged()*price;
 		}

		if(!activedestination.equalsIgnoreCase("$$$")){
			row =t.addElement("row");
	 		addRightBoldCol(row,150,ScreenHelper.getTranNoLink("web", "subtotal", sPrintLanguage));
	 		addPriceBoldCol(row,20,subtotal);
		}
 		row =t.addElement("row");
 		addCol(row,170,"");
 		addRightBoldCol(row,150,ScreenHelper.getTranNoLink("web", "total", sPrintLanguage));
 		addPriceBoldCol(row,20,generaltotal);
 		
     }
    
    protected void printServiceOutgoingStockOperationsListing(org.dom4j.Document d, org.dom4j.Element t, String sDateBegin, String sDateEnd, String sServiceStockUID) throws ParseException{
 		d.add(t);
        t.addAttribute("size", "180");

 		//Add title rows
        org.dom4j.Element row =t.addElement("row");
 		row.addAttribute("type", "title");
 		addCol(row,20,ScreenHelper.getTranNoLink("web","document",sPrintLanguage));
 		addCol(row,20,ScreenHelper.getTranNoLink("web","date",sPrintLanguage));
 		addCol(row,80,ScreenHelper.getTranNoLink("web","article",sPrintLanguage));
 		addCol(row,20,ScreenHelper.getTranNoLink("web","qte",sPrintLanguage));
 		addCol(row,20,ScreenHelper.getTranNoLink("web","pu",sPrintLanguage));
 		addCol(row,20,ScreenHelper.getTranNoLink("web","amount",sPrintLanguage));

        row =t.addElement("row");
 		//First we make a list of all productstockoperations ordered by date
		java.util.Date begin = ScreenHelper.parseDate(sDateBegin);
		java.util.Date end = ScreenHelper.parseDate(sDateEnd);
		double subtotal=0, generaltotal=0;
 		Vector deliveries = ProductStockOperation.getServiceStockDeliveries(sServiceStockUID, begin, new java.util.Date(end.getTime()+day), "OC_OPERATION_DATE,OC_OPERATION_DOCUMENTUID", "ASC");
 		for(int n=0;n<deliveries.size();n++){
 			ProductStockOperation operation = (ProductStockOperation)deliveries.elementAt(n);
 			String date=ScreenHelper.stdDateFormat.format(operation.getDate());
 			String document="";
 			if(operation.getDocument()!=null){
 				document=operation.getDocument().getReference();
 			}
 			addCol(row,20,document);
 			addCol(row,20,date);
 			addCol(row,80,operation.getProductStock()!=null && operation.getProductStock().getProduct()!=null?ScreenHelper.checkString(operation.getProductStock().getProduct().getName()):"");
 			addCol(row,20,operation.getUnitsChanged()+"");
 			double price=operation.getProductStock()==null || operation.getProductStock().getProduct()==null?0:operation.getProductStock().getProduct().getLastYearsAveragePrice(operation.getDate()==null?new java.util.Date():operation.getDate());
 			addPriceCol(row,20,price,"#,##0.00");
 			addPriceCol(row,20,operation.getUnitsChanged()*price);
 			generaltotal+=operation.getUnitsChanged()*price;
 		}

 		row =t.addElement("row");
 		addCol(row,180,"");
 		addBoldCol(row,160,ScreenHelper.getTranNoLink("web", "total", sPrintLanguage));
 		addPriceBoldCol(row,20,generaltotal);
 		
     }
    
    protected void printProductStockFile(org.dom4j.Document d, org.dom4j.Element t, String sYear, String sProductStockUID) throws ParseException{
		d.add(t);
        t.addAttribute("size", "235");
		
		//Add title rows
        org.dom4j.Element row =t.addElement("row");
		row.addAttribute("type", "title");
		addCol(row,95,"");
		addCol(row,40,ScreenHelper.getTranNoLink("web","entries",sPrintLanguage));
		addCol(row,40,ScreenHelper.getTranNoLink("web","exits",sPrintLanguage));
		addCol(row,40,ScreenHelper.getTranNoLink("web","available",sPrintLanguage));
		addCol(row,20,ScreenHelper.getTranNoLink("web","pump",sPrintLanguage));
		
		row =t.addElement("row");
		row.addAttribute("type", "title");
		addCol(row,25,ScreenHelper.getTranNoLink("web","date",sPrintLanguage));
		addCol(row,30,ScreenHelper.getTranNoLink("web","reference",sPrintLanguage));
		addCol(row,40,ScreenHelper.getTranNoLink("web","pharmacy.sourcedestination",sPrintLanguage));
		addCol(row,20,ScreenHelper.getTranNoLink("web","qe",sPrintLanguage));
		addCol(row,20,ScreenHelper.getTranNoLink("web","pue",sPrintLanguage));
		addCol(row,20,ScreenHelper.getTranNoLink("web","qte",sPrintLanguage));
		addCol(row,20,ScreenHelper.getTranNoLink("web","vs",sPrintLanguage));
		addCol(row,20,ScreenHelper.getTranNoLink("web","qd",sPrintLanguage));
		addCol(row,20,ScreenHelper.getTranNoLink("web","vd",sPrintLanguage));
		addCol(row,20,ScreenHelper.getTranNoLink("web","value",sPrintLanguage));
		
		ProductStock productStock = ProductStock.get(sProductStockUID);
		java.util.Date begin  = ScreenHelper.parseDate("01/01/"+sYear);
		java.util.Date	end = ScreenHelper.parseDate("31/12/"+sYear);
		int stock=0;
		int initialstock=-999;
		if(productStock!=null){
			Vector operations = ProductStockOperation.getAll(productStock.getUid());
			for(int n=0;n<operations.size();n++){
				ProductStockOperation operation = (ProductStockOperation)operations.elementAt(n);
				if(!operation.getDate().before(begin)){
					//if this operation falss after the end date, whe can stop
					if(operation.getDate().after(end)){
						break;
					}
					//First let's see if we have to show the initial stock level
					if(initialstock==-999){
						initialstock=stock;
						//Add initial stock row
						row=t.addElement("row");
						addCol(row,25,ScreenHelper.stdDateFormat.format(begin));
						addCol(row,30,"");
						addCol(row,40,ScreenHelper.getTranNoLink("web","initial.stock",sPrintLanguage));
						addCol(row,20,initialstock+"");
						double pump=productStock.getProduct().getLastYearsAveragePrice(new java.util.Date(begin.getTime()+day));
						addPriceCol(row,20,pump,"#,##0.00");
						addCol(row,20,"0");
						addCol(row,20,"0");
						addCol(row,20,initialstock+"");
						addPriceCol(row,20,initialstock*pump);
						addPriceCol(row,20,pump,"#,##0.00");
					}
					//We have to show this operation
					// Date
					row=t.addElement("row");
					addCol(row,25,ScreenHelper.stdDateFormat.format(operation.getDate()));
					// Reference document
		 			String document="";
		 			if(operation.getDocument()!=null){
		 				document=operation.getDocument().getReference();
		 			}
		 			addCol(row,30,document);
					// Origin or Destination
					if(operation.getSourceDestination().getObjectType().equalsIgnoreCase("servicestock")){
						ServiceStock serviceStock = ServiceStock.get(operation.getSourceDestination().getObjectUid());
						if(serviceStock!=null){
							addCol(row,40,serviceStock.getName());
						}
					}
					else if (operation.getSourceDestination().getObjectType().equalsIgnoreCase("patient")){
						addCol(row,40,AdminPerson.getFullName(operation.getSourceDestination().getObjectUid()));
					}
					else if (operation.getSourceDestination().getObjectType().equalsIgnoreCase("supplier")){
						addCol(row,40,operation.getSourceDestination().getObjectUid());
					}
					else {
						if(operation.getDescription().indexOf("medicationreceipt.")>-1){
							addCol(row,40,ScreenHelper.getTranNoLink("productstockoperation.medicationreceipt",operation.getDescription(),sPrintLanguage));
						}
						else if (operation.getDescription().indexOf("medicationdelivery.")>-1){
							addCol(row,40,ScreenHelper.getTranNoLink("productstockoperation.medicationdelivery",operation.getDescription(),sPrintLanguage));
						}
					}
					// Quantity received and price
					if(operation.getDescription().indexOf("medicationreceipt.")>-1){
						addCol(row,20,operation.getUnitsChanged()+"");
						String pump=Pointer.getPointer("drugprice."+productStock.getProductUid()+"."+operation.getUid());
						if(pump.length()>0){
							addPriceCol(row,20,Double.parseDouble(pump.split(";")[1]),"#,##0.00");
						}
						else {
							addCol(row,20,"0");
						}
					}
					else {
						addCol(row,20,"0");
						addCol(row,20,"0");
					}
					double pump=productStock.getProduct().getLastYearsAveragePrice(new java.util.Date(operation.getDate().getTime()+day));
					// Quantity delivered and price
					if (operation.getDescription().indexOf("medicationdelivery.")>-1){
						addCol(row,20,operation.getUnitsChanged()+"");
						addPriceCol(row,20,operation.getUnitsChanged()*pump);
					}
					else {
						addCol(row,20,"0");
						addCol(row,20,"0");
					}
					// Remaining stock and value
					if(operation.getDescription().indexOf("medicationreceipt.")>-1){
						stock+=operation.getUnitsChanged();
					}
					else if (operation.getDescription().indexOf("medicationdelivery.")>-1){
						stock-=operation.getUnitsChanged();
					}
					addCol(row,20,stock+"");
					addPriceCol(row,20,stock*pump);
					//PUMP
					addPriceCol(row,20,pump,"#,##0.00");
				}
				else {
					//update stock level
					if(operation.getDescription().indexOf("medicationreceipt.")>-1){
						stock+=operation.getUnitsChanged();
					}
					else if (operation.getDescription().indexOf("medicationdelivery.")>-1){
						stock-=operation.getUnitsChanged();
					}
				}
			}
			//First let's see if we have to show the initial stock level (if there were no operations)
			if(initialstock==-999){
				initialstock=stock;
				//Add initial stock row
				row=t.addElement("row");
				addCol(row,25,ScreenHelper.stdDateFormat.format(begin));
				addCol(row,30,"");
				addCol(row,40,ScreenHelper.getTranNoLink("web","initial.stock",sPrintLanguage));
				addCol(row,20,initialstock+"");
				double pump=productStock.getProduct().getLastYearsAveragePrice(new java.util.Date(begin.getTime()+day));
				addPriceCol(row,20,pump,"#,##0.00");
				addCol(row,20,"0");
				addCol(row,20,"0");
				addCol(row,20,initialstock+"");
				addPriceCol(row,20,initialstock*pump);
				addPriceCol(row,20,pump,"#,##0.00");
			}
		}
    }
    
    protected void printHeaderModel1 (String type, Hashtable parameters, String title){
            table = new PdfPTable(3);
            table.setWidthPercentage(100);
            
            PdfPTable table2 = new PdfPTable(1);
            table2.setWidthPercentage(100);
            table2.addCell(createBorderlessCell(ScreenHelper.getTranNoLink("pharmacy.report","title1",sPrintLanguage), 1, 1, 10));
            table2.addCell(createBorderlessCell(ScreenHelper.getTranNoLink("pharmacy.report","title2",sPrintLanguage), 1, 1, 10));
            table2.addCell(createBorderlessCell(ScreenHelper.getTranNoLink("pharmacy.report","title3",sPrintLanguage), 1, 1, 10));
            table2.addCell(createBorderlessCell(ScreenHelper.getTranNoLink("pharmacy.report","title4",sPrintLanguage), 1, 1, 10));
            table2.addCell(createBorderlessCell(ScreenHelper.getTranNoLink("pharmacy.report","title5",sPrintLanguage), 1, 1, 10));
            table2.addCell(createBorderlessCell(ScreenHelper.getTranNoLink("pharmacy.report","title6",sPrintLanguage), 1, 1, 10));
            table2.addCell(createBorderlessCell(" \n", 1, 1, 10));
            cell = new PdfPCell(table2);
            cell.setBorder(PdfPCell.NO_BORDER);
            cell.setColspan(1);
            table.addCell(cell);

            cell = emptyCell();
            table.addCell(cell);

            cell = emptyCell();
            table.addCell(cell);

            cell = createTitle(title, 3);
            table.addCell(cell);
            cell = createTitle(ScreenHelper.getTranNoLink("pharmacy.report","period.from",sPrintLanguage)+" "+(String)parameters.get("begin")+" "+ScreenHelper.getTranNoLink("pharmacy.report","till",sPrintLanguage)+" "+(String)parameters.get("end"), 3);
            table.addCell(cell);
            
            table.addCell(emptyCell(3));
            table.addCell(emptyCell(3));
            table.addCell(emptyCell(3));
    }
    protected void printHeader(String type, Hashtable parameters){
        try {
        	if(type.equalsIgnoreCase("productStockFile")){
                table = new PdfPTable(3);
                table.setWidthPercentage(100);
                
                PdfPTable table2 = new PdfPTable(1);
                table2.setWidthPercentage(100);
                table2.addCell(createBorderlessCell(ScreenHelper.getTranNoLink("pharmacy.report","title1",sPrintLanguage), 1, 1, 10));
                table2.addCell(createBorderlessCell(ScreenHelper.getTranNoLink("pharmacy.report","title2",sPrintLanguage), 1, 1, 10));
                table2.addCell(createBorderlessCell(ScreenHelper.getTranNoLink("pharmacy.report","title3",sPrintLanguage), 1, 1, 10));
                table2.addCell(createBorderlessCell(ScreenHelper.getTranNoLink("pharmacy.report","title4",sPrintLanguage), 1, 1, 10));
                table2.addCell(createBorderlessCell(ScreenHelper.getTranNoLink("pharmacy.report","title5",sPrintLanguage), 1, 1, 10));
                table2.addCell(createBorderlessCell(ScreenHelper.getTranNoLink("pharmacy.report","title6",sPrintLanguage), 1, 1, 10));
                table2.addCell(createBorderlessCell(" \n", 1, 1, 10));
                cell = new PdfPCell(table2);
                cell.setBorder(PdfPCell.NO_BORDER);
                cell.setColspan(1);
                table.addCell(cell);
                
                ProductStock productStock = ProductStock.get((String)parameters.get("productStockUID"));
                table2 = new PdfPTable(2);
                table2.setWidthPercentage(100);
                table2.addCell(createBoldBorderlessCell(ScreenHelper.getTranNoLink("pharmacy.report","stockfile",sPrintLanguage), 1, 1, 10));
                table2.addCell(createBorderlessCell(productStock==null||productStock.getServiceStock()==null?"":productStock.getServiceStock().getName(), 1, 1, 10));
                table2.addCell(createBoldBorderlessCell(ScreenHelper.getTranNoLink("pharmacy.report","productname",sPrintLanguage), 1, 1, 10));
                table2.addCell(createBorderlessCell(productStock==null||productStock.getProduct()==null?"":productStock.getProduct().getName(), 1, 1, 10));
                table2.addCell(createBoldBorderlessCell(ScreenHelper.getTranNoLink("pharmacy.report","productunit",sPrintLanguage), 1, 1, 10));
                table2.addCell(createBorderlessCell(productStock==null||productStock.getProduct()==null?"":ScreenHelper.getTranNoLink("product.unit",productStock.getProduct().getUnit(),sPrintLanguage), 1, 1, 10));
                table2.addCell(createBoldBorderlessCell(ScreenHelper.getTranNoLink("pharmacy.report","productcode",sPrintLanguage), 1, 1, 10));
                table2.addCell(createBorderlessCell(productStock==null||productStock.getProduct()==null?"":productStock.getProduct().getUid(), 1, 1, 10));
                cell = new PdfPCell(table2);
                cell.setBorder(PdfPCell.NO_BORDER);
                cell.setColspan(1);
                table.addCell(cell);

                table2 = new PdfPTable(3);
                table2.setWidthPercentage(100);
                table2.addCell(emptyCell());
                table2.addCell(createBoldBorderlessCell(ScreenHelper.getTranNoLink("pharmacy.report","maximumstock",sPrintLanguage), 1, 1, 10));
                table2.addCell(createBorderlessCell(productStock==null?"":productStock.getMaximumLevel()+"", 1, 1, 10));
                table2.addCell(emptyCell());
                table2.addCell(createBoldBorderlessCell(ScreenHelper.getTranNoLink("pharmacy.report","minimumstock",sPrintLanguage), 1, 1, 10));
                table2.addCell(createBorderlessCell(productStock==null?"":productStock.getMinimumLevel()+"", 1, 1, 10));
                cell = new PdfPCell(table2);
                cell.setBorder(PdfPCell.NO_BORDER);
                cell.setColspan(1);
                table.addCell(cell);
                table.addCell(emptyCell(3));
                table.addCell(emptyCell(3));
                table.addCell(emptyCell(3));
        	}
        	else if(type.equalsIgnoreCase("serviceStockInventory")){
                table = new PdfPTable(3);
                table.setWidthPercentage(100);
                
                PdfPTable table2 = new PdfPTable(1);
                table2.setWidthPercentage(100);
                table2.addCell(createBorderlessCell(ScreenHelper.getTranNoLink("pharmacy.report","title1",sPrintLanguage), 1, 1, 10));
                table2.addCell(createBorderlessCell(ScreenHelper.getTranNoLink("pharmacy.report","title2",sPrintLanguage), 1, 1, 10));
                table2.addCell(createBorderlessCell(ScreenHelper.getTranNoLink("pharmacy.report","title3",sPrintLanguage), 1, 1, 10));
                table2.addCell(createBorderlessCell(ScreenHelper.getTranNoLink("pharmacy.report","title4",sPrintLanguage), 1, 1, 10));
                table2.addCell(createBorderlessCell(ScreenHelper.getTranNoLink("pharmacy.report","title5",sPrintLanguage), 1, 1, 10));
                table2.addCell(createBorderlessCell(ScreenHelper.getTranNoLink("pharmacy.report","title6",sPrintLanguage), 1, 1, 10));
                table2.addCell(createBorderlessCell(" \n", 1, 1, 10));
                cell = new PdfPCell(table2);
                cell.setBorder(PdfPCell.NO_BORDER);
                cell.setColspan(1);
                table.addCell(cell);

                ServiceStock serviceStock = ServiceStock.get((String)parameters.get("serviceStockUID"));
                table2 = new PdfPTable(1);
                table2.setWidthPercentage(100);
                table2.addCell(createBoldBorderlessCell(serviceStock==null?"":serviceStock.getName(), 1, 1, 10));
                table2.addCell(createBoldBorderlessCell(ScreenHelper.getTranNoLink("pharmacy.report","inventory.on",sPrintLanguage)+" "+(String)parameters.get("begin"), 1, 1, 10));
                cell = new PdfPCell(table2);
                cell.setBorder(PdfPCell.NO_BORDER);
                cell.setColspan(1);
                table.addCell(cell);

                cell = emptyCell();
                table.addCell(cell);
                table.addCell(emptyCell(3));
                table.addCell(emptyCell(3));
                table.addCell(emptyCell(3));

        	}
        	else if(type.equalsIgnoreCase("serviceStockInventorySummary")){
                table = new PdfPTable(3);
                table.setWidthPercentage(100);
                
                PdfPTable table2 = new PdfPTable(1);
                table2.setWidthPercentage(100);
                table2.addCell(createBorderlessCell(ScreenHelper.getTranNoLink("pharmacy.report","title1",sPrintLanguage), 1, 1, 10));
                table2.addCell(createBorderlessCell(ScreenHelper.getTranNoLink("pharmacy.report","title2",sPrintLanguage), 1, 1, 10));
                table2.addCell(createBorderlessCell(ScreenHelper.getTranNoLink("pharmacy.report","title3",sPrintLanguage), 1, 1, 10));
                table2.addCell(createBorderlessCell(ScreenHelper.getTranNoLink("pharmacy.report","title4",sPrintLanguage), 1, 1, 10));
                table2.addCell(createBorderlessCell(ScreenHelper.getTranNoLink("pharmacy.report","title5",sPrintLanguage), 1, 1, 10));
                table2.addCell(createBorderlessCell(ScreenHelper.getTranNoLink("pharmacy.report","title6",sPrintLanguage), 1, 1, 10));
                table2.addCell(createBorderlessCell(" \n", 1, 1, 10));
                cell = new PdfPCell(table2);
                cell.setBorder(PdfPCell.NO_BORDER);
                cell.setColspan(1);
                table.addCell(cell);

                cell = emptyCell();
                table.addCell(cell);

                cell = emptyCell();
                table.addCell(cell);

                ServiceStock serviceStock = ServiceStock.get((String)parameters.get("serviceStockUID"));
                cell = createTitle(ScreenHelper.getTranNoLink("pharmacy.report","theoretical.inventory.on",sPrintLanguage)+" "+(String)parameters.get("date")+": "+(serviceStock==null?"":serviceStock.getName()), 3);
                table.addCell(cell);
                
                table.addCell(emptyCell(3));
                table.addCell(emptyCell(3));
                table.addCell(emptyCell(3));

        	}
        	else if(type.equalsIgnoreCase("monthlyConsumption")){
                table = new PdfPTable(3);
                table.setWidthPercentage(100);
                
                PdfPTable table2 = new PdfPTable(1);
                table2.setWidthPercentage(100);
                table2.addCell(createBorderlessCell(ScreenHelper.getTranNoLink("pharmacy.report","title1",sPrintLanguage), 1, 1, 10));
                table2.addCell(createBorderlessCell(ScreenHelper.getTranNoLink("pharmacy.report","title2",sPrintLanguage), 1, 1, 10));
                table2.addCell(createBorderlessCell(ScreenHelper.getTranNoLink("pharmacy.report","title3",sPrintLanguage), 1, 1, 10));
                table2.addCell(createBorderlessCell(ScreenHelper.getTranNoLink("pharmacy.report","title4",sPrintLanguage), 1, 1, 10));
                table2.addCell(createBorderlessCell(ScreenHelper.getTranNoLink("pharmacy.report","title5",sPrintLanguage), 1, 1, 10));
                table2.addCell(createBorderlessCell(ScreenHelper.getTranNoLink("pharmacy.report","title6",sPrintLanguage), 1, 1, 10));
                table2.addCell(createBorderlessCell(" \n", 1, 1, 10));
                cell = new PdfPCell(table2);
                cell.setBorder(PdfPCell.NO_BORDER);
                cell.setColspan(1);
                table.addCell(cell);

                cell = emptyCell();
                table.addCell(cell);

                cell = emptyCell();
                table.addCell(cell);

                ServiceStock serviceStock = ServiceStock.get((String)parameters.get("serviceStockUID"));
                cell = createTitle(ScreenHelper.getTranNoLink("pharmacy.report","monthly.consumption.on",sPrintLanguage)+" "+(String)parameters.get("date")+": "+(serviceStock==null?"":serviceStock.getName()), 3);
                table.addCell(cell);
                
                table.addCell(emptyCell(3));
                table.addCell(emptyCell(3));
                table.addCell(emptyCell(3));

        	}
        	else if(type.equalsIgnoreCase("expiration")){
                table = new PdfPTable(3);
                table.setWidthPercentage(100);
                
                PdfPTable table2 = new PdfPTable(1);
                table2.setWidthPercentage(100);
                table2.addCell(createBorderlessCell(ScreenHelper.getTranNoLink("pharmacy.report","title1",sPrintLanguage), 1, 1, 10));
                table2.addCell(createBorderlessCell(ScreenHelper.getTranNoLink("pharmacy.report","title2",sPrintLanguage), 1, 1, 10));
                table2.addCell(createBorderlessCell(ScreenHelper.getTranNoLink("pharmacy.report","title3",sPrintLanguage), 1, 1, 10));
                table2.addCell(createBorderlessCell(ScreenHelper.getTranNoLink("pharmacy.report","title4",sPrintLanguage), 1, 1, 10));
                table2.addCell(createBorderlessCell(ScreenHelper.getTranNoLink("pharmacy.report","title5",sPrintLanguage), 1, 1, 10));
                table2.addCell(createBorderlessCell(ScreenHelper.getTranNoLink("pharmacy.report","title6",sPrintLanguage), 1, 1, 10));
                table2.addCell(createBorderlessCell(" \n", 1, 1, 10));
                cell = new PdfPCell(table2);
                cell.setBorder(PdfPCell.NO_BORDER);
                cell.setColspan(1);
                table.addCell(cell);

                cell = emptyCell();
                table.addCell(cell);

                cell = emptyCell();
                table.addCell(cell);

                ServiceStock serviceStock = ServiceStock.get((String)parameters.get("serviceStockUID"));
                cell = createTitle(ScreenHelper.getTranNoLink("pharmacy.report","expiration.for",sPrintLanguage)+" "+(serviceStock==null?"":serviceStock.getName()), 3);
                table.addCell(cell);
                cell = createTitle(ScreenHelper.getTranNoLink("web","date",sPrintLanguage)+": "+(String)parameters.get("date"), 3);
                table.addCell(cell);
                
                table.addCell(emptyCell(3));
                table.addCell(emptyCell(3));
                table.addCell(emptyCell(3));

        	}
        	else if(type.equalsIgnoreCase("stockout")){
                table = new PdfPTable(3);
                table.setWidthPercentage(100);
                
                PdfPTable table2 = new PdfPTable(1);
                table2.setWidthPercentage(100);
                table2.addCell(createBorderlessCell(ScreenHelper.getTranNoLink("pharmacy.report","title1",sPrintLanguage), 1, 1, 10));
                table2.addCell(createBorderlessCell(ScreenHelper.getTranNoLink("pharmacy.report","title2",sPrintLanguage), 1, 1, 10));
                table2.addCell(createBorderlessCell(ScreenHelper.getTranNoLink("pharmacy.report","title3",sPrintLanguage), 1, 1, 10));
                table2.addCell(createBorderlessCell(ScreenHelper.getTranNoLink("pharmacy.report","title4",sPrintLanguage), 1, 1, 10));
                table2.addCell(createBorderlessCell(ScreenHelper.getTranNoLink("pharmacy.report","title5",sPrintLanguage), 1, 1, 10));
                table2.addCell(createBorderlessCell(ScreenHelper.getTranNoLink("pharmacy.report","title6",sPrintLanguage), 1, 1, 10));
                table2.addCell(createBorderlessCell(" \n", 1, 1, 10));
                cell = new PdfPCell(table2);
                cell.setBorder(PdfPCell.NO_BORDER);
                cell.setColspan(1);
                table.addCell(cell);

                cell = emptyCell();
                table.addCell(cell);

                cell = emptyCell();
                table.addCell(cell);

                ServiceStock serviceStock = ServiceStock.get((String)parameters.get("serviceStockUID"));
                cell = createTitle(ScreenHelper.getTranNoLink("pharmacy.report","stockout.for",sPrintLanguage)+" "+(serviceStock==null?"":serviceStock.getName()), 3);
                table.addCell(cell);
                cell = createTitle(ScreenHelper.getTranNoLink("web","date",sPrintLanguage)+": "+(String)parameters.get("date"), 3);
                table.addCell(cell);
                
                table.addCell(emptyCell(3));
                table.addCell(emptyCell(3));
                table.addCell(emptyCell(3));

        	}
        	else if(type.equalsIgnoreCase("serviceStockOperations")){
                ServiceStock serviceStock = ServiceStock.get((String)parameters.get("serviceStockUID"));
        		printHeaderModel1(type, parameters, ScreenHelper.getTranNoLink("pharmacy.report","stock.operations",sPrintLanguage)+": "+(serviceStock==null?"":serviceStock.getName()));
        	}
        	else if(type.equalsIgnoreCase("serviceOutgoingStockOperations")){
                ServiceStock serviceStock = ServiceStock.get((String)parameters.get("serviceStockUID"));
        		printHeaderModel1(type, parameters, ScreenHelper.getTranNoLink("pharmacy.report","outgoing.stock.operations",sPrintLanguage)+": "+(serviceStock==null?"":serviceStock.getName()));
        	}
        	else if(type.equalsIgnoreCase("serviceIncomingStockOperations")){
                ServiceStock serviceStock = ServiceStock.get((String)parameters.get("serviceStockUID"));
        		printHeaderModel1(type, parameters, ScreenHelper.getTranNoLink("pharmacy.report","incoming.stock.operations",sPrintLanguage)+": "+(serviceStock==null?"":serviceStock.getName()));
        	}
        	else if(type.equalsIgnoreCase("serviceIncomingStockOperationsPerOrder")){
                ServiceStock serviceStock = ServiceStock.get((String)parameters.get("serviceStockUID"));
        		printHeaderModel1(type, parameters, ScreenHelper.getTranNoLink("pharmacy.report","incoming.stock.operations.perorder",sPrintLanguage)+": "+(serviceStock==null?"":serviceStock.getName()));
        	}
        	else if(type.equalsIgnoreCase("serviceIncomingStockOperationsPerItem")){
                ServiceStock serviceStock = ServiceStock.get((String)parameters.get("serviceStockUID"));
        		printHeaderModel1(type, parameters, ScreenHelper.getTranNoLink("pharmacy.report","incoming.stock.operations.peritem",sPrintLanguage)+": "+(serviceStock==null?"":serviceStock.getName()));
        	}
        	else if(type.equalsIgnoreCase("serviceIncomingStockOperationsPerCategoryItem")){
                ServiceStock serviceStock = ServiceStock.get((String)parameters.get("serviceStockUID"));
        		printHeaderModel1(type, parameters, ScreenHelper.getTranNoLink("pharmacy.report","incoming.stock.operations.percategoryitem",sPrintLanguage)+": "+(serviceStock==null?"":serviceStock.getName()));
        	}
        	else if(type.equalsIgnoreCase("serviceIncomingStockOperationsPerProvider")){
                ServiceStock serviceStock = ServiceStock.get((String)parameters.get("serviceStockUID"));
        		printHeaderModel1(type, parameters, ScreenHelper.getTranNoLink("pharmacy.report","incoming.stock.operations.perprovider",sPrintLanguage)+": "+(serviceStock==null?"":serviceStock.getName()));
        	}
        	else if(type.equalsIgnoreCase("serviceOutgoingStockOperationsListing")){
                ServiceStock serviceStock = ServiceStock.get((String)parameters.get("serviceStockUID"));
        		printHeaderModel1(type, parameters, ScreenHelper.getTranNoLink("pharmacy.report","outgoing.stock.operations.listing",sPrintLanguage)+": "+(serviceStock==null?"":serviceStock.getName()));
        	}
        	else if(type.equalsIgnoreCase("serviceOutgoingStockOperationsListingPerService")){
                ServiceStock serviceStock = ServiceStock.get((String)parameters.get("serviceStockUID"));
                ServiceStock serviceStock2 = ServiceStock.get((String)parameters.get("destinationStockUID"));
        		printHeaderModel1(type, parameters, ScreenHelper.getTranNoLink("pharmacy.report","outgoing.stock.operations.listing.per.service",sPrintLanguage)+" "+getTran("web","from")+" "+(serviceStock==null?"":serviceStock.getName())+" "+getTran("web","towards")+" "+(serviceStock2==null?"":serviceStock2.getName()));
        	}
            doc.add(table);
        }
        catch(Exception e){
            e.printStackTrace();
        }
    }

    //################################### UTILITY FUNCTIONS #######################################

    //--- CREATE UNDERLINED CELL ------------------------------------------------------------------
    protected PdfPCell createUnderlinedCell(String value, int colspan){
        cell = new PdfPCell(new Paragraph(value,FontFactory.getFont(FontFactory.HELVETICA,7,Font.UNDERLINE))); // underlined
        cell.setColspan(colspan);
        cell.setBorder(PdfPCell.NO_BORDER);
        cell.setVerticalAlignment(PdfPCell.ALIGN_TOP);
        cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);

        return cell;
    }

    //--- PRINT VECTOR ----------------------------------------------------------------------------
    protected String printVector(Vector vector){
        StringBuffer buf = new StringBuffer();
        for(int i=0; i<vector.size(); i++){
            buf.append(vector.get(i)).append(", ");
        }

        // remove last comma
        if(buf.length() > 0) buf.deleteCharAt(buf.length()-2);

        return buf.toString();
    }

    //--- CREATE TITLE ----------------------------------------------------------------------------
    protected PdfPCell createTitle(String msg, int colspan){
        cell = new PdfPCell(new Paragraph(msg,FontFactory.getFont(FontFactory.HELVETICA,10,Font.UNDERLINE)));
        cell.setColspan(colspan);
        cell.setBorder(PdfPCell.NO_BORDER);
        cell.setVerticalAlignment(PdfPCell.ALIGN_MIDDLE);
        cell.setHorizontalAlignment(PdfPCell.ALIGN_CENTER);

        return cell;
    }

    //--- CREATE TITLE ----------------------------------------------------------------------------
    protected PdfPCell createLabel(String msg, int fontsize, int colspan,int style){
        cell = new PdfPCell(new Paragraph(msg,FontFactory.getFont(FontFactory.HELVETICA,fontsize,style)));
        cell.setColspan(colspan);
        cell.setBorder(PdfPCell.NO_BORDER);
        cell.setVerticalAlignment(PdfPCell.ALIGN_MIDDLE);
        cell.setHorizontalAlignment(PdfPCell.ALIGN_CENTER);

        return cell;
    }

    //--- CREATE BORDERLESS CELL ------------------------------------------------------------------
    protected PdfPCell createBorderlessCell(String value, int height, int colspan){
        cell = new PdfPCell(new Paragraph(value,FontFactory.getFont(FontFactory.HELVETICA,7,Font.NORMAL)));
        cell.setPaddingTop(height); //
        cell.setColspan(colspan);
        cell.setBorder(PdfPCell.NO_BORDER);
        cell.setVerticalAlignment(PdfPCell.ALIGN_TOP);
        cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);

        return cell;
    }

    protected PdfPCell createBoldBorderlessCell(String value, int height, int colspan){
        cell = new PdfPCell(new Paragraph(value,FontFactory.getFont(FontFactory.HELVETICA,7,Font.BOLD)));
        cell.setPaddingTop(height); //
        cell.setColspan(colspan);
        cell.setBorder(PdfPCell.NO_BORDER);
        cell.setVerticalAlignment(PdfPCell.ALIGN_TOP);
        cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);

        return cell;
    }

    protected PdfPCell createBorderlessCell(String value, int colspan){
        return createBorderlessCell(value,3,colspan);
    }

    protected PdfPCell createBoldBorderlessCell(String value, int colspan){
        return createBoldBorderlessCell(value,3,colspan);
    }

    protected PdfPCell createBorderlessCell(int colspan){
        cell = new PdfPCell();
        cell.setColspan(colspan);
        cell.setBorder(PdfPCell.NO_BORDER);

        return cell;
    }

    //--- CREATE ITEMNAME CELL --------------------------------------------------------------------
    protected PdfPCell createItemNameCell(String itemName, int colspan){
        cell = new PdfPCell(new Paragraph(itemName,FontFactory.getFont(FontFactory.HELVETICA,7,Font.NORMAL))); // no uppercase
        cell.setColspan(colspan);
        cell.setBorder(PdfPCell.BOX);
        cell.setBorderColor(innerBorderColor);
        cell.setVerticalAlignment(PdfPCell.ALIGN_MIDDLE);
        cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);

        return cell;
    }

    //--- CREATE PADDED VALUE CELL ----------------------------------------------------------------
    protected PdfPCell createPaddedValueCell(String value, int colspan){
        cell = new PdfPCell(new Paragraph(value,FontFactory.getFont(FontFactory.HELVETICA,7,Font.NORMAL)));
        cell.setColspan(colspan);
        cell.setBorder(PdfPCell.BOX);
        cell.setBorderColor(innerBorderColor);
        cell.setVerticalAlignment(PdfPCell.ALIGN_TOP);
        cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
        cell.setPaddingRight(5); // difference

        return cell;
    }

    //--- CREATE NUMBER VALUE CELL ----------------------------------------------------------------
    protected PdfPCell createNumberCell(String value, int colspan){
        cell = new PdfPCell(new Paragraph(value,FontFactory.getFont(FontFactory.HELVETICA,7,Font.NORMAL)));
        cell.setColspan(colspan);
        cell.setBorder(PdfPCell.BOX);
        cell.setBorderColor(innerBorderColor);
        cell.setVerticalAlignment(PdfPCell.ALIGN_TOP);
        cell.setHorizontalAlignment(PdfPCell.ALIGN_RIGHT);

        return cell;
    }

}