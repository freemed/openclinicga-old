package be.mxs.common.util.pdf.general;

import be.mxs.common.util.pdf.official.PDFOfficialBasic;
import be.mxs.common.util.system.Pointer;
import be.mxs.common.util.system.ScreenHelper;
import be.mxs.common.util.db.MedwanQuery;
import be.openclinic.pharmacy.DrugCategory;
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
        	if(type.equalsIgnoreCase("serviceStockInventorySummary")){
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
	
	private void addRightBoldCol(org.dom4j.Element row, int size, String value){
		org.dom4j.Element col = row.addElement("col");
		col.addAttribute("size", size+"");
		col.addAttribute("align", "right");
		col.addAttribute("weight", "bold");
		col.setText(value);
	}

	private void addPriceCol(org.dom4j.Element row, int size, double value){
		org.dom4j.Element col = row.addElement("col");
		col.addAttribute("size", size+"");
		col.setText(new DecimalFormat(MedwanQuery.getInstance().getConfigString("priceFormat","#")).format(value));
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
    	else if(type.equalsIgnoreCase("serviceStockOperations")){
    		printServiceStockOperations(d, t, (String)parameters.get("begin"), (String)parameters.get("end"), (String)parameters.get("serviceStockUID"));
    	}
    	
		printDocument(d);
    }
    
    protected void printDocument(org.dom4j.Document d) throws DocumentException{
    	System.out.println(d.asXML());
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
	    		table.addCell(cell);
			}
    	}
    	doc.add(table);
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
			System.out.println("uid for "+stock.getUid()+" = "+uid);
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
			java.util.Date date = new SimpleDateFormat("dd/MM/yyyy").parse(sDate);
			//Nu printen we de gegevens van de productstock
	        row =t.addElement("row");
			addCol(row,90,stock.getProduct()==null?"":stock.getProduct().getName());
			int level=stock.getLevel(date);
			addCol(row,30,level+"");
			double pump=0;
			if(stock.getProduct()!=null){
				pump=stock.getProduct().getLastYearsAveragePrice(new java.util.Date(date.getTime()+day));
			}
			addPriceCol(row,30,pump);
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
 			System.out.println("uid for "+stock.getUid()+" = "+uid);
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
 			java.util.Date begin = new SimpleDateFormat("dd/MM/yyyy").parse(sDateBegin);
 			java.util.Date end = new SimpleDateFormat("dd/MM/yyyy").parse(sDateEnd);
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
 			addPriceCol(row,20,pump);
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
 			System.out.println("uid for "+stock.getUid()+" = "+uid);
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
 			java.util.Date begin = new SimpleDateFormat("dd/MM/yyyy").parse(sDateBegin);
 			java.util.Date end = new SimpleDateFormat("dd/MM/yyyy").parse(sDateEnd);
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
 			addPriceCol(row,20,pump);
 			addPriceCol(row,20,(initiallevel+in-out)*pump);
 		}
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
		java.util.Date begin  = new SimpleDateFormat("dd/MM/yyyy").parse("01/01/"+sYear);
		java.util.Date	end = new SimpleDateFormat("dd/MM/yyyy").parse("31/12/"+sYear);
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
						addCol(row,25,new SimpleDateFormat("dd/MM/yyyy").format(begin));
						addCol(row,30,"");
						addCol(row,40,ScreenHelper.getTranNoLink("web","initial.stock",sPrintLanguage));
						addCol(row,20,initialstock+"");
						double pump=productStock.getProduct().getLastYearsAveragePrice(new java.util.Date(begin.getTime()+day));
						addPriceCol(row,20,pump);
						addCol(row,20,"0");
						addCol(row,20,"0");
						addCol(row,20,initialstock+"");
						addPriceCol(row,20,initialstock*pump);
						addPriceCol(row,20,pump);
					}
					//We have to show this operation
					// Date
					row=t.addElement("row");
					addCol(row,25,new SimpleDateFormat("dd/MM/yyyy").format(operation.getDate()));
					// Reference document
					addCol(row,30,(operation.getDocumentUID()==null ||operation.getDocumentUID().trim().length()==0 || operation.getDocument()==null?"":operation.getDocument().getReference()));
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
							addPriceCol(row,20,Double.parseDouble(pump.split(";")[1]));
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
					addPriceCol(row,20,pump);
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
				addCol(row,25,new SimpleDateFormat("dd/MM/yyyy").format(begin));
				addCol(row,30,"");
				addCol(row,40,ScreenHelper.getTranNoLink("web","initial.stock",sPrintLanguage));
				addCol(row,20,initialstock+"");
				double pump=productStock.getProduct().getLastYearsAveragePrice(new java.util.Date(begin.getTime()+day));
				addPriceCol(row,20,pump);
				addCol(row,20,"0");
				addCol(row,20,"0");
				addCol(row,20,initialstock+"");
				addPriceCol(row,20,initialstock*pump);
				addPriceCol(row,20,pump);
			}
		}
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
        	else if(type.equalsIgnoreCase("serviceStockOperations")){
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
                cell = new PdfPCell(table2);
                cell.setBorder(PdfPCell.NO_BORDER);
                cell.setColspan(1);
                table.addCell(cell);

                cell = emptyCell();
                table.addCell(cell);

                cell = emptyCell();
                table.addCell(cell);

                ServiceStock serviceStock = ServiceStock.get((String)parameters.get("serviceStockUID"));
                cell = createTitle(ScreenHelper.getTranNoLink("pharmacy.report","stock.operations",sPrintLanguage)+": "+(serviceStock==null?"":serviceStock.getName()), 3);
                cell = createTitle(ScreenHelper.getTranNoLink("pharmacy.report","period.from",sPrintLanguage)+" "+(String)parameters.get("begin")+" "+ScreenHelper.getTranNoLink("pharmacy.report","till",sPrintLanguage)+" "+(String)parameters.get("end"), 3);
                table.addCell(cell);
                
                table.addCell(emptyCell(3));
                table.addCell(emptyCell(3));
                table.addCell(emptyCell(3));

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