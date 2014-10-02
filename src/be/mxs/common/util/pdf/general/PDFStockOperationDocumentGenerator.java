package be.mxs.common.util.pdf.general;

import com.itextpdf.text.pdf.*;
import com.itextpdf.text.*;
import com.lowagie.text.Paragraph;

import java.util.*;
import java.io.ByteArrayOutputStream;
import java.text.SimpleDateFormat;

import be.mxs.common.util.pdf.official.PDFOfficialBasic;
import be.mxs.common.util.system.ScreenHelper;
import be.mxs.common.util.db.MedwanQuery;
import be.openclinic.pharmacy.OperationDocument;
import be.openclinic.pharmacy.ProductStockOperation;
import net.admin.*;

import javax.servlet.http.HttpServletRequest;


public class PDFStockOperationDocumentGenerator extends PDFOfficialBasic {
    // declarations
    protected PdfWriter docWriter;
    private final int pageWidth = 100;
    private String type;
    private SimpleDateFormat dateformat=ScreenHelper.stdDateFormat;

    
    //--- CONSTRUCTOR -----------------------------------------------------------------------------
    public PDFStockOperationDocumentGenerator(User user, String sProject, String sPrintLanguage){
        this.user = user;
        this.sProject = sProject;
        this.sPrintLanguage = sPrintLanguage;

        doc = new Document();
    }

    public void addHeader(){
    }

    public void addContent(){
    }

    //--- GENERATE PDF DOCUMENT BYTES -------------------------------------------------------------
    public ByteArrayOutputStream generatePDFDocumentBytes(final HttpServletRequest req, String sDocumentUid) throws Exception {
        ByteArrayOutputStream baosPDF = new ByteArrayOutputStream();
		docWriter = PdfWriter.getInstance(doc,baosPDF);
        this.req = req;

		try{
            doc.addProducer();
            doc.addAuthor(user.person.firstname+" "+user.person.lastname);
			doc.addCreationDate();
			doc.addCreator("OpenClinic Software");
			doc.setPageSize(PageSize.A4);

            doc.open();

            // get specified document
            OperationDocument operationDocument = OperationDocument.get(sDocumentUid);
            addHeading(operationDocument);
            addOperations(operationDocument);
            addFooter();
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

    //--- ADD FOOTER ------------------------------------------------------------------------------
    private void addFooter() throws Exception {
        table = new PdfPTable(100);
        table.setWidthPercentage(pageWidth);
    	table.addCell(emptyCell(100));
        
        // horizontal header
    	table.addCell(emptyCell(15)); // empty cell
    	table.addCell(createHeaderCell(ScreenHelper.getTranNoLink("mdnac","name",sPrintLanguage),40,6));
    	table.addCell(createHeaderCell(ScreenHelper.getTranNoLink("mdnac","grade",sPrintLanguage),15,6));
    	table.addCell(createHeaderCell(ScreenHelper.getTranNoLink("mdnac","date",sPrintLanguage),15,6));
    	table.addCell(createHeaderCell(ScreenHelper.getTranNoLink("mdnac","signature",sPrintLanguage),15,6));
    	
    	// vertical header
    	table.addCell(createHeaderCell(ScreenHelper.getTranNoLink("mdnac","requestor",sPrintLanguage)+"\n\n",15,6));
    	table.addCell(emptyCell(40,true));
    	table.addCell(emptyCell(15,true));
    	table.addCell(emptyCell(15,true));
    	table.addCell(emptyCell(15,true));
    	
    	table.addCell(createHeaderCell(ScreenHelper.getTranNoLink("mdnac","distributor",sPrintLanguage)+"\n\n",15,6));
    	table.addCell(emptyCell(40,true));
    	table.addCell(emptyCell(15,true));
    	table.addCell(emptyCell(15,true));
    	table.addCell(emptyCell(15,true));
    	
    	table.addCell(createHeaderCell(ScreenHelper.getTranNoLink("mdnac","companion",sPrintLanguage)+"\n\n",15,6));
    	table.addCell(emptyCell(40,true));
    	table.addCell(emptyCell(15,true));
    	table.addCell(emptyCell(15,true));
    	table.addCell(emptyCell(15,true));
    	
    	table.addCell(createHeaderCell(ScreenHelper.getTranNoLink("mdnac","receiver",sPrintLanguage)+"\n\n",15,6));
    	table.addCell(emptyCell(40,true));
    	table.addCell(emptyCell(15,true));
    	table.addCell(emptyCell(15,true));
    	table.addCell(emptyCell(15,true));
    	
    	doc.add(table);
    }

    //--- ADD OPERATIONS --------------------------------------------------------------------------
    private void addOperations(OperationDocument document) throws Exception {
        table = new PdfPTable(100);
        table.setWidthPercentage(pageWidth);
    	table.addCell(emptyCell(100));
        
        // header
        table.addCell(createHeaderCell(ScreenHelper.getTranNoLink("mdnac","serialnumber",sPrintLanguage),5,6));
    	table.addCell(createHeaderCell(ScreenHelper.getTranNoLink("mdnac","vtgnumber",sPrintLanguage),10,6));
    	table.addCell(createHeaderCell(ScreenHelper.getTranNoLink("mdnac","description",sPrintLanguage),38,6));
    	table.addCell(createHeaderCell(ScreenHelper.getTranNoLink("mdnac","autoriseddotation",sPrintLanguage),10,6));
    	table.addCell(createHeaderCell(ScreenHelper.getTranNoLink("mdnac","instock",sPrintLanguage),6,6));
    	table.addCell(createHeaderCell(ScreenHelper.getTranNoLink("mdnac","measurementunit",sPrintLanguage),10,6));
    	table.addCell(createHeaderCell(ScreenHelper.getTranNoLink("mdnac","quantityrequested",sPrintLanguage),7,6));
    	table.addCell(createHeaderCell(ScreenHelper.getTranNoLink("mdnac","quantitydelivered",sPrintLanguage),7,6));
    	table.addCell(createHeaderCell(ScreenHelper.getTranNoLink("mdnac","reserved",sPrintLanguage),7,6));
    	        
    	// merge orders for the same product
    	Hashtable mergedOrders = new Hashtable();
    	Vector operations = document.getProductStockOperations();
    	for(int n=0; n<operations.size(); n++){
    		ProductStockOperation operation = (ProductStockOperation)operations.elementAt(n);
    		if(mergedOrders.get(operation.getProductStock().getProduct().getUid())!=null){
    			// order already exists, merge
    			ProductStockOperation existingOperation = (ProductStockOperation)mergedOrders.get(operation.getProductStock().getProduct().getUid());
    			existingOperation.setUnitsChanged(existingOperation.getUnitsChanged()+operation.getUnitsChanged());
    		}
    		else {
    			mergedOrders.put(operation.getProductStock().getProduct().getUid(), operation);
    		}
    	}
    	
    	Enumeration mo = mergedOrders.keys();
    	int n = 0;
    	while(mo.hasMoreElements()){
    		ProductStockOperation operation = (ProductStockOperation)mergedOrders.get(mo.nextElement());

    		table.addCell(createValueCell((n+1)+"",0,6,5,true));        	
        	table.addCell(createValueCell("",0,6,10,true));        	
        	table.addCell(createValueCell(operation.getProductStock().getProduct().getName(),1,6,38,true));        	
        	table.addCell(createValueCell("",0,6,10,true));        	
        	table.addCell(createValueCell(operation.getProductStock().getLevel()+"",1,6,6,true));        	
        	table.addCell(createValueCell(ScreenHelper.getTranNoLink("product.units",operation.getProductStock().getProduct().getUnit(),sPrintLanguage),1,6,10,true));
        	table.addCell(createValueCell("",0,6,7,true));        	
        	table.addCell(createValueCell(operation.getUnitsChanged()+"",1,6,7,true));        	
        	table.addCell(createValueCell("",0,6,7,true));
    	}
    	
    	for(n=0; n<40-operations.size(); n++){          	
        	table.addCell(emptyCell(5,true));        	      	
        	table.addCell(emptyCell(10,true));        	      	
        	table.addCell(emptyCell(38,true));        	      	
        	table.addCell(emptyCell(10,true));        	      	
        	table.addCell(emptyCell(6,true));        	      	
        	table.addCell(emptyCell(10,true));        	      	
        	table.addCell(emptyCell(7,true));        	      	
        	table.addCell(emptyCell(7,true));        	      	
        	table.addCell(emptyCell(7,true));        	
    	}
    	
    	// justification
    	table.addCell(emptyCell(100));
    	PdfPTable table2 = new PdfPTable(1);
    	table2.addCell(createHeaderCell(ScreenHelper.getTranNoLink("mdnac","justification",sPrintLanguage),1));
    	table2.addCell(createValueCell(document.getComment(),1));
    	
    	cell = new PdfPCell(table2);
    	cell.setColspan(100);
    	table.addCell(cell);
    	    	
    	doc.add(table);
    }

    //---- ADD HEADING ----------------------------------------------------------------------------
    private void addHeading(OperationDocument document) throws Exception {
        table = new PdfPTable(100);
        table.setWidthPercentage(pageWidth);

        try{
        	// title
        	cell = createHeaderCell(ScreenHelper.getTran("operationdocumenttypes",document.getType(),sPrintLanguage).toUpperCase(),80,20);
        	cell.setPaddingBottom(5);
        	table.addCell(cell);
        	cell = createHeaderCell(dateformat.format(document.getDate()),20,10);
        	table.addCell(cell);
        	
        	PdfPTable table2 = new PdfPTable(1);
        	cell = createBorderlessCell(ScreenHelper.getTranNoLink("mdnac","requestor",sPrintLanguage),1);
        	cell.setHorizontalAlignment(PdfPCell.ALIGN_CENTER);
        	table2.addCell(cell);
        	
        	cell = createHeaderCell(document.getDestination().getName(),1,12);
            cell.setBackgroundColor(BaseColor.WHITE);
        	cell.setBorderColor(BaseColor.BLACK);
        	cell.setBorder(PdfPCell.BOX);
        	cell.setBorderColor(innerBorderColor);
        	cell.setHorizontalAlignment(PdfPCell.ALIGN_CENTER);
        	table2.addCell(cell);
        	
        	cell = new PdfPCell(table2);
            cell.setBorder(PdfPCell.BOX);
            cell.setBorderColor(innerBorderColor);
        	cell.setColspan(50);
        	table.addCell(cell);
        	
        	table2 = new PdfPTable(50);
        	PdfPTable table3 = new PdfPTable(1);
        	cell = createValueCell(ScreenHelper.getTranNoLink("mdnac","ordernumber",sPrintLanguage)+": "+document.getUid());
        	cell.setColspan(1);
            cell.setBorder(PdfPCell.BOX);
            cell.setBorderColor(innerBorderColor);
        	table3.addCell(cell);
            
        	// Barcode + archiving code
            PdfPTable wrapperTable = new PdfPTable(1);
            wrapperTable.setWidthPercentage(100);

            PdfContentByte cb = docWriter.getDirectContent();
            Barcode39 barcode39 = new Barcode39();
            barcode39.setFont(null);
            barcode39.setCode("8"+MedwanQuery.getInstance().getConfigString("mdnacserverid","00")+document.getUid().split("\\.")[1]);
            Image image = barcode39.createImageWithBarcode(cb,null,null);
            image.scalePercent(99);
            cell = new PdfPCell(image);
            cell.setBorder(PdfPCell.BOX);
            cell.setBorderColor(innerBorderColor);
            cell.setPadding(2);
            cell.setVerticalAlignment(PdfPCell.ALIGN_TOP);
            cell.setHorizontalAlignment(PdfPCell.ALIGN_CENTER);
            cell.setColspan(1);
            wrapperTable.addCell(cell);
            cell = new PdfPCell(wrapperTable);
            cell.setColspan(1);
            table3.addCell(cell);
        	
        	cell = new PdfPCell(table3);
        	cell.setColspan(20);
        	table2.addCell(cell);
        	
        	cell = createValueCell(ScreenHelper.getTranNoLink("mdnac","visa.log1",sPrintLanguage)+"\n"+ScreenHelper.getTranNoLink("mdnac","visa.log2",sPrintLanguage));
        	cell.setColspan(30);
        	table2.addCell(cell);
        	
        	table3 = new PdfPTable(10);
        	cell = createValueCell(ScreenHelper.getTranNoLink("mdnac","distributiontype",sPrintLanguage));
        	cell.setColspan(10);
        	table3.addCell(cell);
        	cell = createValueCell(ScreenHelper.getTranNoLink("mdnac","purchase",sPrintLanguage));
        	cell.setColspan(7);
        	table3.addCell(cell);
        	cell = createValueCell("");
        	cell.setColspan(3);
        	table3.addCell(cell);
        	cell = new PdfPCell(table3);
        	cell.setColspan(20);
        	table2.addCell(cell);
        	cell = createValueCell(ScreenHelper.getTranNoLink("mdnac","blognumber",sPrintLanguage));
        	cell.setColspan(30);
        	table2.addCell(cell);
        	cell = new PdfPCell(table2);
        	cell.setColspan(50);
        	table.addCell(cell);
        	
        	table2 = new PdfPTable(1);
        	cell = createBorderlessCell(ScreenHelper.getTranNoLink("mdnac","distributor",sPrintLanguage),1);
        	cell.setHorizontalAlignment(PdfPCell.ALIGN_CENTER);
        	table2.addCell(cell);
        	
        	cell = createHeaderCell(document.getSourceName(sPrintLanguage),1,12);
            cell.setBackgroundColor(BaseColor.WHITE);
        	cell.setBorderColor(BaseColor.BLACK);
            cell.setBorder(PdfPCell.BOX);
            cell.setBorderColor(innerBorderColor);
        	cell.setHorizontalAlignment(PdfPCell.ALIGN_CENTER);
        	table2.addCell(cell);
        	
        	cell = new PdfPCell(table2);
        	cell.setColspan(50);
        	table.addCell(cell);
        	
        	table2 = new PdfPTable(50);
        	table3 = new PdfPTable(10);
        	cell = createValueCell(ScreenHelper.getTranNoLink("mdnac","initial",sPrintLanguage));
        	cell.setColspan(7);
        	table3.addCell(cell);
        	cell = createValueCell("");
        	cell.setColspan(3);
        	table3.addCell(cell);
        	cell = createValueCell(ScreenHelper.getTranNoLink("mdnac","replacement",sPrintLanguage));
        	cell.setColspan(7);
        	table3.addCell(cell);
        	cell = createValueCell("");
        	cell.setColspan(3);
        	table3.addCell(cell);
        	cell = createValueCell(ScreenHelper.getTranNoLink("mdnac","loan",sPrintLanguage));
        	cell.setColspan(7);
        	table3.addCell(cell);
        	cell = createValueCell("");
        	cell.setColspan(3);
        	table3.addCell(cell);
        	cell = new PdfPCell(table3);
        	cell.setColspan(20);
        	table2.addCell(cell);
        	cell = createValueCell(ScreenHelper.getTranNoLink("mdnac","approvalg4",sPrintLanguage));
        	cell.setColspan(30);
        	table2.addCell(cell);
        	cell = new PdfPCell(table2);
        	cell.setColspan(50);
        	table.addCell(cell);
        	
            doc.add(table);
        }
        catch(Exception e){
            e.printStackTrace();
        }
    }

}