package be.mxs.common.util.pdf.general;

import com.itextpdf.text.pdf.*;
import com.itextpdf.text.*;

import java.util.*;
import java.io.ByteArrayOutputStream;
import java.text.SimpleDateFormat;

import be.mxs.common.util.pdf.official.PDFOfficialBasic;
import be.mxs.common.util.system.Miscelaneous;
import be.mxs.common.util.system.Debug;
import be.mxs.common.util.system.HTMLEntities;
import be.mxs.common.util.system.ScreenHelper;
import be.mxs.common.util.db.MedwanQuery;
import be.openclinic.finance.*;
import be.openclinic.pharmacy.OperationDocument;
import be.openclinic.pharmacy.ProductOrder;
import be.openclinic.pharmacy.ProductStockOperation;
import be.openclinic.adt.Encounter;
import net.admin.*;

import javax.servlet.http.HttpServletRequest;

public class PDFStockOperationDocumentGenerator extends PDFOfficialBasic {
    // declarations
    protected PdfWriter docWriter;
    private final int pageWidth = 100;
    private String type;
    private SimpleDateFormat dateformat=new SimpleDateFormat("dd/MM/yyyy");

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

    private void addFooter() throws Exception {
        table = new PdfPTable(100);
        table.setWidthPercentage(pageWidth);
    	cell=createValueCell("",0,6,15,true);
    	table.addCell(cell);
    	cell=createValueCell(ScreenHelper.getTranNoLink("mdnac","name",sPrintLanguage),0,6,40,true);
    	table.addCell(cell);
    	cell=createValueCell(ScreenHelper.getTranNoLink("mdnac","grade",sPrintLanguage),0,6,15,true);
    	table.addCell(cell);
    	cell=createValueCell(ScreenHelper.getTranNoLink("mdnac","date",sPrintLanguage),0,6,15,true);
    	table.addCell(cell);
    	cell=createValueCell(ScreenHelper.getTranNoLink("mdnac","signature",sPrintLanguage),0,6,15,true);
    	table.addCell(cell);
    	cell=createValueCell(ScreenHelper.getTranNoLink("mdnac","requestor",sPrintLanguage)+"\n \n ",0,6,15,true);
    	table.addCell(cell);
    	cell=createValueCell("",0,6,40,true);
    	table.addCell(cell);
    	cell=createValueCell("",0,6,15,true);
    	table.addCell(cell);
    	cell=createValueCell("",0,6,15,true);
    	table.addCell(cell);
    	cell=createValueCell("",0,6,15,true);
    	table.addCell(cell);
    	cell=createValueCell(ScreenHelper.getTranNoLink("mdnac","distributor",sPrintLanguage)+"\n \n ",0,6,15,true);
    	table.addCell(cell);
    	cell=createValueCell("",0,6,40,true);
    	table.addCell(cell);
    	cell=createValueCell("",0,6,15,true);
    	table.addCell(cell);
    	cell=createValueCell("",0,6,15,true);
    	table.addCell(cell);
    	cell=createValueCell("",0,6,15,true);
    	table.addCell(cell);
    	cell=createValueCell(ScreenHelper.getTranNoLink("mdnac","companion",sPrintLanguage)+"\n \n ",0,6,15,true);
    	table.addCell(cell);
    	cell=createValueCell("",0,6,40,true);
    	table.addCell(cell);
    	cell=createValueCell("",0,6,15,true);
    	table.addCell(cell);
    	cell=createValueCell("",0,6,15,true);
    	table.addCell(cell);
    	cell=createValueCell("",0,6,15,true);
    	table.addCell(cell);
    	cell=createValueCell(ScreenHelper.getTranNoLink("mdnac","receiver",sPrintLanguage)+"\n \n ",0,6,15,true);
    	table.addCell(cell);
    	cell=createValueCell("",0,6,40,true);
    	table.addCell(cell);
    	cell=createValueCell("",0,6,15,true);
    	table.addCell(cell);
    	cell=createValueCell("",0,6,15,true);
    	table.addCell(cell);
    	cell=createValueCell("",0,6,15,true);
    	table.addCell(cell);
    	
    	doc.add(table);
    }

    private void addOperations(OperationDocument document) throws Exception {
        table = new PdfPTable(100);
        table.setWidthPercentage(pageWidth);
        //First print table header
    	cell=createValueCell(ScreenHelper.getTranNoLink("mdnac","serialnumber",sPrintLanguage),0,6,5,true);
    	table.addCell(cell);
    	cell=createValueCell(ScreenHelper.getTranNoLink("mdnac","vtgnumber",sPrintLanguage),0,6,10,true);
    	table.addCell(cell);
    	cell=createValueCell(ScreenHelper.getTranNoLink("mdnac","description",sPrintLanguage),0,6,38,true);
    	table.addCell(cell);
    	cell=createValueCell(ScreenHelper.getTranNoLink("mdnac","autoriseddotation",sPrintLanguage),0,6,10,true);
    	table.addCell(cell);
    	cell=createValueCell(ScreenHelper.getTranNoLink("mdnac","instock",sPrintLanguage),0,6,6,true);
    	table.addCell(cell);
    	cell=createValueCell(ScreenHelper.getTranNoLink("mdnac","measurementunit",sPrintLanguage),0,6,10,true);
    	table.addCell(cell);
    	cell=createValueCell(ScreenHelper.getTranNoLink("mdnac","quantityrequested",sPrintLanguage),0,6,7,true);
    	table.addCell(cell);
    	cell=createValueCell(ScreenHelper.getTranNoLink("mdnac","quantitydelivered",sPrintLanguage),0,6,7,true);
    	table.addCell(cell);
    	cell=createValueCell(ScreenHelper.getTranNoLink("mdnac","reserved",sPrintLanguage),0,6,7,true);
    	table.addCell(cell);
        
    	//We voegen orders voor éénzelfde product samen
    	Hashtable mergedOrders = new Hashtable();
    	Vector operations = document.getProductStockOperations();
    	for (int n=0;n<operations.size();n++){
    		ProductStockOperation operation = (ProductStockOperation)operations.elementAt(n);
    		if(mergedOrders.get(operation.getProductStock().getProduct().getUid())!=null){
    			//Productorder already exists, merge
    			ProductStockOperation existingOperation = (ProductStockOperation)mergedOrders.get(operation.getProductStock().getProduct().getUid());
    			existingOperation.setUnitsChanged(existingOperation.getUnitsChanged()+operation.getUnitsChanged());
    		}
    		else {
    			mergedOrders.put(operation.getProductStock().getProduct().getUid(), operation);
    		}
    	}
    	Enumeration mo = mergedOrders.keys();
    	int n=0;
    	while(mo.hasMoreElements()){
    		ProductStockOperation operation = (ProductStockOperation)mergedOrders.get(mo.nextElement());

    		cell=createValueCell((n+1)+"",0,6,5,true);
        	table.addCell(cell);
        	cell=createValueCell("",0,6,10,true);
        	table.addCell(cell);
        	cell=createValueCell(operation.getProductStock().getProduct().getName(),1,6,38,true);
        	table.addCell(cell);
        	cell=createValueCell("",0,6,10,true);
        	table.addCell(cell);
        	cell=createValueCell(operation.getProductStock().getLevel()+"",1,6,6,true);
        	table.addCell(cell);
        	cell=createValueCell(ScreenHelper.getTranNoLink("product.units",operation.getProductStock().getProduct().getUnit(),sPrintLanguage),1,6,10,true);
        	table.addCell(cell);
        	cell=createValueCell("",0,6,7,true);
        	table.addCell(cell);
        	cell=createValueCell(operation.getUnitsChanged()+"",1,6,7,true);
        	table.addCell(cell);
        	cell=createValueCell("",0,6,7,true);
        	table.addCell(cell);
    	}
    	for(n=0;n<40-operations.size();n++){
        	cell=createValueCell(" ",0,6,5,true);
        	table.addCell(cell);
        	cell=createValueCell(" ",0,6,10,true);
        	table.addCell(cell);
        	cell=createValueCell(" ",1,6,38,true);
        	table.addCell(cell);
        	cell=createValueCell(" ",0,6,10,true);
        	table.addCell(cell);
        	cell=createValueCell(" ",1,6,6,true);
        	table.addCell(cell);
        	cell=createValueCell(" ",1,6,10,true);
        	table.addCell(cell);
        	cell=createValueCell(" ",0,6,7,true);
        	table.addCell(cell); 
        	cell=createValueCell(" ",1,6,7,true);
        	table.addCell(cell);
        	cell=createValueCell(" ",0,6,7,true);
        	table.addCell(cell);
    	}
    	PdfPTable table2 = new PdfPTable(1);
    	cell=createBorderlessCell(ScreenHelper.getTranNoLink("mdnac","justification",sPrintLanguage),1);
    	cell.setHorizontalAlignment(PdfPCell.ALIGN_CENTER);
    	table2.addCell(cell);
    	cell=createBorderlessCell(document.getComment()+"\n ",1);
    	cell.setHorizontalAlignment(PdfPCell.ALIGN_CENTER);
    	table2.addCell(cell);
    	cell=new PdfPCell(table2);
    	cell.setColspan(100);
    	cell.setBorder(PdfPCell.BOX);
    	table.addCell(cell);
    	
    	
    	doc.add(table);
    }

    //---- ADD HEADING (logo & barcode) -----------------------------------------------------------
    private void addHeading(OperationDocument document) throws Exception {
        table = new PdfPTable(100);
        table.setWidthPercentage(pageWidth);

        try {
        	cell= createHeaderCell(ScreenHelper.getTran("operationdocumenttypes",document.getType(),sPrintLanguage).toUpperCase(), 80,20);
        	table.addCell(cell);
        	cell= createHeaderCell(dateformat.format(document.getDate()),20,10);
        	table.addCell(cell);
        	PdfPTable table2 = new PdfPTable(1);
        	cell=createBorderlessCell(ScreenHelper.getTranNoLink("mdnac","requestor",sPrintLanguage),1);
        	cell.setHorizontalAlignment(PdfPCell.ALIGN_CENTER);
        	table2.addCell(cell);
        	cell=createHeaderCell(document.getDestination().getName(),1,12);
            cell.setBackgroundColor(BaseColor.WHITE);
        	cell.setBorderColor(BaseColor.BLACK);
        	cell.setBorder(PdfPCell.BOX);
        	cell.setHorizontalAlignment(PdfPCell.ALIGN_CENTER);
        	table2.addCell(cell);
        	cell=new PdfPCell(table2);
        	cell.setColspan(50);
        	table.addCell(cell);
        	table2 = new PdfPTable(50);
        	PdfPTable table3  = new PdfPTable(1);
        	cell=createValueCell(ScreenHelper.getTranNoLink("mdnac","ordernumber",sPrintLanguage)+": "+document.getUid());
        	cell.setColspan(1);
            cell.setBorder(PdfPCell.NO_BORDER);
        	table3.addCell(cell);
            //Barcode + archiving code
            PdfPTable wrapperTable = new PdfPTable(1);
            wrapperTable.setWidthPercentage(100);

            PdfContentByte cb = docWriter.getDirectContent();
            Barcode39 barcode39 = new Barcode39();
            barcode39.setFont(null);
            barcode39.setCode("8"+MedwanQuery.getInstance().getConfigString("mdnacserverid","00")+document.getUid().split("\\.")[1]);
            Image image = barcode39.createImageWithBarcode(cb, null, null);
            image.scaleToFit(100,30);
            cell = new PdfPCell(image);
            cell.setBorder(PdfPCell.NO_BORDER);
            cell.setVerticalAlignment(PdfPCell.ALIGN_TOP);
            cell.setHorizontalAlignment(PdfPCell.ALIGN_CENTER);
            cell.setColspan(1);
            cell.setPadding(0);
            wrapperTable.addCell(cell);
            cell=new PdfPCell(wrapperTable);
            cell.setBorder(PdfPCell.NO_BORDER);
            cell.setColspan(1);
            table3.addCell(cell);
        	
        	cell=new PdfPCell(table3);
        	cell.setColspan(20);
        	table2.addCell(cell);
        	cell=createValueCell(ScreenHelper.getTranNoLink("mdnac","visa.log1",sPrintLanguage)+"\n"+ScreenHelper.getTranNoLink("mdnac","visa.log2",sPrintLanguage));
        	cell.setColspan(30);
        	table2.addCell(cell);
        	table3 = new PdfPTable(10);
        	cell=createValueCell(ScreenHelper.getTranNoLink("mdnac","distributiontype",sPrintLanguage));
        	cell.setColspan(10);
        	table3.addCell(cell);
        	cell=createValueCell(ScreenHelper.getTranNoLink("mdnac","purchase",sPrintLanguage));
        	cell.setColspan(7);
        	table3.addCell(cell);
        	cell=createValueCell("");
        	cell.setColspan(3);
        	table3.addCell(cell);
        	cell=new PdfPCell(table3);
        	cell.setColspan(20);
        	table2.addCell(cell);
        	cell=createValueCell(ScreenHelper.getTranNoLink("mdnac","blognumber",sPrintLanguage));
        	cell.setColspan(30);
        	table2.addCell(cell);
        	cell=new PdfPCell(table2);
        	cell.setColspan(50);
        	table.addCell(cell);
        	
        	table2 = new PdfPTable(1);
        	cell=createBorderlessCell(ScreenHelper.getTranNoLink("mdnac","distributor",sPrintLanguage),1);
        	cell.setHorizontalAlignment(PdfPCell.ALIGN_CENTER);
        	table2.addCell(cell);
        	cell=createHeaderCell(document.getSource().getName(),1,12);
            cell.setBackgroundColor(BaseColor.WHITE);
        	cell.setBorderColor(BaseColor.BLACK);
        	cell.setBorder(PdfPCell.BOX);
        	cell.setHorizontalAlignment(PdfPCell.ALIGN_CENTER);
        	table2.addCell(cell);
        	cell=new PdfPCell(table2);
        	cell.setColspan(50);
        	table.addCell(cell);
        	
        	table2 = new PdfPTable(50);
        	table3 = new PdfPTable(10);
        	cell=createValueCell(ScreenHelper.getTranNoLink("mdnac","initial",sPrintLanguage));
        	cell.setColspan(7);
        	table3.addCell(cell);
        	cell=createValueCell("");
        	cell.setColspan(3);
        	table3.addCell(cell);
        	cell=createValueCell(ScreenHelper.getTranNoLink("mdnac","replacement",sPrintLanguage));
        	cell.setColspan(7);
        	table3.addCell(cell);
        	cell=createValueCell("");
        	cell.setColspan(3);
        	table3.addCell(cell);
        	cell=createValueCell(ScreenHelper.getTranNoLink("mdnac","loan",sPrintLanguage));
        	cell.setColspan(7);
        	table3.addCell(cell);
        	cell=createValueCell("");
        	cell.setColspan(3);
        	table3.addCell(cell);
        	cell=new PdfPCell(table3);
        	cell.setColspan(20);
        	table2.addCell(cell);
        	cell=createValueCell(ScreenHelper.getTranNoLink("mdnac","approvalg4",sPrintLanguage));
        	cell.setColspan(30);
        	table2.addCell(cell);
        	cell=new PdfPCell(table2);
        	cell.setColspan(50);
        	table.addCell(cell);
        	
            doc.add(table);
        }
        catch(Exception e){
            e.printStackTrace();
        }
    }


}