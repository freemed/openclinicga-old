package be.mxs.common.util.pdf.general;

import com.itextpdf.text.pdf.*;
import com.itextpdf.text.*;

import java.util.*;
import java.io.ByteArrayOutputStream;
import java.net.URL;
import java.text.SimpleDateFormat;

import be.mxs.common.util.system.Miscelaneous;
import be.mxs.common.util.system.Debug;
import be.mxs.common.util.system.HTMLEntities;
import be.mxs.common.util.system.ScreenHelper;
import be.mxs.common.util.db.MedwanQuery;
import be.openclinic.finance.*;
import be.openclinic.adt.Encounter;
import net.admin.*;

import javax.servlet.http.HttpServletRequest;

public class PDFPatientPaymentReceiptGenerator extends PDFInvoiceGenerator {

    //--- CONSTRUCTOR -----------------------------------------------------------------------------
    public PDFPatientPaymentReceiptGenerator(User user, AdminPerson patient, String sProject, String sPrintLanguage){
        this.user = user;
        this.patient = patient;
        this.sProject = sProject;
        this.sPrintLanguage = sPrintLanguage;

        doc = new Document();
    }

    //--- GENERATE PDF DOCUMENT BYTES -------------------------------------------------------------
    public ByteArrayOutputStream generatePDFDocumentBytes(final HttpServletRequest req, String sCreditUid) throws Exception {
        ByteArrayOutputStream baosPDF = new ByteArrayOutputStream();
		docWriter = PdfWriter.getInstance(doc,baosPDF);
        this.req = req;

        // reset totals
        this.patientDebetTotal = 0;
        this.insurarDebetTotal = 0;
        this.creditTotal = 0;

		try{
            doc.addProducer();
            doc.addAuthor(user.person.firstname+" "+user.person.lastname);
			doc.addCreationDate();
			doc.addCreator("OpenClinic Software");
            Rectangle rectangle = new Rectangle(0,0,new Float(MedwanQuery.getInstance().getConfigInt("patientReceiptWidth",720)*72/254).floatValue(),new Float(MedwanQuery.getInstance().getConfigInt("patientReceiptHeight",5000)*72/254).floatValue());
            doc.setPageSize(rectangle);
            doc.setMargins(0, 0, 0, 0);
            doc.open();

            // get specified invoice
            PatientCredit credit = PatientCredit.get(sCreditUid);
            printCredit(credit);
        }
		catch(Exception e){
			baosPDF.reset();
			e.printStackTrace();
        }
		finally{
			if(doc!=null) {
				doc.close();
			}
            if(docWriter!=null) {
            	docWriter.close();
            }
		}
		if(baosPDF.size() < 1){
			throw new DocumentException("document has no bytes");
		}

		return baosPDF;
	}
    
    private void printCredit(PatientCredit credit){
    	try{
	    	double titleScaleFactor = new Double(MedwanQuery.getInstance().getConfigInt("PDFReceiptTitleFontScaleFactor",100))/100;
	    	double scaleFactor = new Double(MedwanQuery.getInstance().getConfigInt("PDFReceiptFontScaleFactor",100))/100;
	    	table = new PdfPTable(50);
	        table.setWidthPercentage(98);
	
	        cell = createBorderlessCell(ScreenHelper.getTranNoLink("web","javaposcentername",sPrintLanguage), 1,50,new Double(10*titleScaleFactor).intValue());
	        cell.setHorizontalAlignment(PdfPCell.ALIGN_CENTER);
	        table.addCell(cell);
	        cell = createBorderlessCell(ScreenHelper.getTranNoLink("web","javaposcentersubtitle",sPrintLanguage), 1,50,new Double(10*titleScaleFactor).intValue());
	        cell.setHorizontalAlignment(PdfPCell.ALIGN_CENTER);
	        table.addCell(cell);
	        cell = createBorderlessCell(ScreenHelper.getTranNoLink("web","javaposcenterphone",sPrintLanguage), 1,50,new Double(10*titleScaleFactor).intValue());
	        cell.setHorizontalAlignment(PdfPCell.ALIGN_CENTER);
	        table.addCell(cell);
	        
			//Create the receipt content
			int receiptid=MedwanQuery.getInstance().getOpenclinicCounter("RECEIPT");
			if(receiptid>=MedwanQuery.getInstance().getConfigInt("maximumNumberOfReceipts",10000)){
				MedwanQuery.getInstance().setOpenclinicCounter("RECEIPT",0);
			}
	        cell = createBorderlessCell(receiptid+" - "+ScreenHelper.getTran("web","receiptforpayment",sPrintLanguage).toUpperCase()+" "+credit.getUid().split("\\.")[1],10, 50,new Double(8*scaleFactor).intValue());
	        cell.setHorizontalAlignment(PdfPCell.ALIGN_CENTER);
	        cell.setPadding(2);
	        table.addCell(cell);
	        cell = createBorderlessCell(ScreenHelper.stdDateFormat.format(credit.getDate()),10, 50,new Double(8*scaleFactor).intValue());
	        cell.setHorizontalAlignment(PdfPCell.ALIGN_CENTER);
	        cell.setPaddingBottom(10);
	        table.addCell(cell);

	        //Patient
	        cell = createValueCell(ScreenHelper.getTran("web","patient",sPrintLanguage)+":", 15,new Double(7*scaleFactor).intValue(),Font.NORMAL);
	        cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
	        table.addCell(cell);
	        cell = createBoldLabelCell(credit.getPatient().lastname.toUpperCase()+", "+credit.getPatient().firstname, 35,new Double(7*scaleFactor).intValue());
	        cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
	        table.addCell(cell);
	        cell = createValueCell("", 15,new Double(7*scaleFactor).intValue(),Font.NORMAL);
	        cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
	        table.addCell(cell);
	        cell = createBoldLabelCell(credit.getPatientUid(), 15,new Double(7*scaleFactor).intValue());
	        cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
	        table.addCell(cell);
	        cell = createBoldLabelCell("°"+credit.getPatient().dateOfBirth, 20,new Double(7*scaleFactor).intValue());
	        cell.setHorizontalAlignment(PdfPCell.ALIGN_RIGHT);
	        table.addCell(cell);

	        cell = createUnderlinedTextCell(ScreenHelper.getTran("web","payments",sPrintLanguage), 40,new Double(7*scaleFactor).intValue());
	        cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
	        table.addCell(cell);
	        cell = createUnderlinedTextCell(ScreenHelper.getTran("web","amount",sPrintLanguage), 10,new Double(7*scaleFactor).intValue());
	        cell.setHorizontalAlignment(PdfPCell.ALIGN_RIGHT);
	        table.addCell(cell);
            cell = createValueCell(ScreenHelper.getTran("credit.type", credit.getType(),sPrintLanguage), 40,new Double(7*scaleFactor).intValue(),Font.NORMAL);
            cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
            table.addCell(cell);
            cell = createValueCell(priceFormat.format(credit.getAmount()), 10,new Double(7*scaleFactor).intValue(),Font.NORMAL);
            cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
            table.addCell(cell);
            cell = createValueCell(ScreenHelper.checkString(credit.getComment()), 50,new Double(7*scaleFactor).intValue(),Font.NORMAL);
            cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
            table.addCell(cell);

	        cell=createValueCell("",50);
	        cell.setBorder(PdfPCell.BOTTOM);
	        table.addCell(cell);
	        
	        cell=createValueCell("",50);
	        cell.setBorder(PdfPCell.NO_BORDER);
	        table.addCell(cell);
	
	        cell = createValueCell(user.person.getFullName().toUpperCase(), 40,new Double(7*scaleFactor).intValue(),Font.NORMAL);
	        cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
	        table.addCell(cell);
	
	        cell = createValueCell(ScreenHelper.getTran("web","thankyou",sPrintLanguage), 10,new Double(7*scaleFactor).intValue(),Font.NORMAL);
	        cell.setHorizontalAlignment(PdfPCell.ALIGN_RIGHT);
	        table.addCell(cell);

	        doc.add(table);
    	}
    	catch(Exception ee){
    		ee.printStackTrace();
    	}
    }
  
}