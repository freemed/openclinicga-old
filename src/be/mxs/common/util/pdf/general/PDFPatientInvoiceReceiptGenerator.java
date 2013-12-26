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

public class PDFPatientInvoiceReceiptGenerator extends PDFInvoiceGenerator {

    //--- CONSTRUCTOR -----------------------------------------------------------------------------
    public PDFPatientInvoiceReceiptGenerator(User user, AdminPerson patient, String sProject, String sPrintLanguage){
        this.user = user;
        this.patient = patient;
        this.sProject = sProject;
        this.sPrintLanguage = sPrintLanguage;

        doc = new Document();
    }

    //--- GENERATE PDF DOCUMENT BYTES -------------------------------------------------------------
    public ByteArrayOutputStream generatePDFDocumentBytes(final HttpServletRequest req, String sInvoiceUid) throws Exception {
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
            PatientInvoice invoice = PatientInvoice.get(sInvoiceUid);
            printInvoice(invoice,invoice.getDebets());
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
    
    private void printInvoice(PatientInvoice invoice, Vector debets){
    	try{
	    	double titleScaleFactor = new Double(MedwanQuery.getInstance().getConfigInt("PDFReceiptTitleFontScaleFactor",100))/100;
	    	double scaleFactor = new Double(MedwanQuery.getInstance().getConfigInt("PDFReceiptFontScaleFactor",100))/100;
	    	table = new PdfPTable(50);
	        table.setWidthPercentage(98);
	
	        // logo
	        try{
	            Image img = Miscelaneous.getImage("JavaPOSImage1.gif",sProject);
	            for(int n=0;n<debets.size();n++){
	            	Debet debet = (Debet)debets.elementAt(n);
	            	if(debet.getInsurance()!=null && debet.getInsurance().getInsurarUid()!=null && MedwanQuery.getInstance().getConfigString("insurancelogo."+debet.getInsurance().getInsurarUid(),"").length()>0){
	            		img = Miscelaneous.getImage(MedwanQuery.getInstance().getConfigString("insurancelogo."+debet.getInsurance().getInsurarUid(),""),sProject);
	            		break;
	            	}
	            }
	            if(img==null){
	                cell = createEmptyCell(10);
	                table.addCell(cell);
	            }
	            else {
	                img.scaleToFit(50,50);
	                cell = new PdfPCell(img);
	                cell.setBorder(PdfPCell.NO_BORDER);
	                cell.setPadding(0);
	                cell.setColspan(50);
	                cell.setHorizontalAlignment(PdfPCell.ALIGN_CENTER);
	                table.addCell(cell);
	            }
	        }
	        catch (Exception e){
	            System.out.println("WARNING : PDFPatientInvoiceGenerator --> IMAGE NOT FOUND : logo_"+sProject+".gif");
	            e.printStackTrace();
	        }
	        cell = createBorderlessCell(ScreenHelper.getTranNoLink("web","javaposcentername",sPrintLanguage), 1,50,new Double(10*titleScaleFactor).intValue());
	        cell.setHorizontalAlignment(PdfPCell.ALIGN_CENTER);
	        table.addCell(cell);
	        cell = createBorderlessCell(ScreenHelper.getTranNoLink("web","javaposcentersubtitle",sPrintLanguage), 1,50,new Double(10*titleScaleFactor).intValue());
	        cell.setHorizontalAlignment(PdfPCell.ALIGN_CENTER);
	        table.addCell(cell);
	        cell = createBorderlessCell(ScreenHelper.getTranNoLink("web","javaposcenterphone",sPrintLanguage), 1,50,new Double(10*titleScaleFactor).intValue());
	        cell.setHorizontalAlignment(PdfPCell.ALIGN_CENTER);
	        table.addCell(cell);
	        
	        double totalCredit=0;
	        for(int n=0;n<invoice.getCredits().size();n++){
	            PatientCredit credit = PatientCredit.get((String)invoice.getCredits().elementAt(n));
	            totalCredit+=credit.getAmount();
	        }
	        double totalDebet=0;
	        double totalinsurardebet=0;
	        Hashtable services = new Hashtable(), insurances = new Hashtable();
	        String service="",insurance="";
	        for(int n=0;n<debets.size();n++){
	            Debet debet = (Debet)debets.elementAt(n);
	            if(debet!=null){
	            	if(debet.getEncounter()!=null && debet.getEncounter().getService()!=null){
	            		service=debet.getEncounter().getService().getLabel(sPrintLanguage);
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

			//Create the receipt content
			int receiptid=MedwanQuery.getInstance().getOpenclinicCounter("RECEIPT");
			if(receiptid>=MedwanQuery.getInstance().getConfigInt("maximumNumberOfReceipts",10000)){
				MedwanQuery.getInstance().setOpenclinicCounter("RECEIPT",0);
			}
	        cell = createBorderlessCell(receiptid+" - "+ScreenHelper.getTran("web","receiptforinvoice",sPrintLanguage).toUpperCase()+" #"+invoice.getInvoiceNumber(),10, 50,new Double(8*scaleFactor).intValue());
	        cell.setHorizontalAlignment(PdfPCell.ALIGN_CENTER);
	        cell.setPadding(2);
	        table.addCell(cell);
	        cell = createBorderlessCell(new SimpleDateFormat("dd/MM/yyyy").format(invoice.getDate()),10, 50,new Double(8*scaleFactor).intValue());
	        cell.setHorizontalAlignment(PdfPCell.ALIGN_CENTER);
	        cell.setPaddingBottom(10);
	        table.addCell(cell);

	        cell = createValueCell(ScreenHelper.getTran("web","patient",sPrintLanguage)+":", 15,new Double(7*scaleFactor).intValue(),Font.NORMAL);
	        cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
	        table.addCell(cell);
	        cell = createBoldLabelCell(invoice.getPatient().lastname.toUpperCase()+", "+invoice.getPatient().firstname, 35,new Double(7*scaleFactor).intValue());
	        cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
	        table.addCell(cell);
	        cell = createValueCell("", 15,new Double(7*scaleFactor).intValue(),Font.NORMAL);
	        cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
	        table.addCell(cell);
	        cell = createBoldLabelCell(invoice.getPatientUid(), 15,new Double(7*scaleFactor).intValue());
	        cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
	        table.addCell(cell);
	        cell = createBoldLabelCell("°"+invoice.getPatient().dateOfBirth, 20,new Double(7*scaleFactor).intValue());
	        cell.setHorizontalAlignment(PdfPCell.ALIGN_RIGHT);
	        table.addCell(cell);
	        Enumeration ins=insurances.keys();
	        int nLines=0;
	        while(ins.hasMoreElements()){
	        	if(nLines==0){
	                cell = createValueCell(ScreenHelper.getTran("web","insurance",sPrintLanguage)+":", 15,new Double(7*scaleFactor).intValue(),Font.NORMAL);
	                cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
	                table.addCell(cell);
	        	}
	        	else {
	                cell = createValueCell("", 15);
	                cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
	                table.addCell(cell);
	        	}
	        	nLines++;
	        	insurance = (String)ins.nextElement();
	            cell = createBoldLabelCell(insurance, 35,new Double(7*scaleFactor).intValue());
	            cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
	            table.addCell(cell);
	        }
	        Enumeration es = services.keys();
	        nLines=0;
	        while (es.hasMoreElements()){
	        	if(nLines==0){
	                cell = createValueCell(ScreenHelper.getTran("web","service",sPrintLanguage)+":", 15,new Double(7*scaleFactor).intValue(),Font.NORMAL);
	                cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
	                table.addCell(cell);
	        	}
	        	else {
	                cell = createValueCell("", 15);
	                cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
	                table.addCell(cell);
	        	}
	        	nLines++;
	        	service=(String)es.nextElement();
	            cell = createBoldLabelCell(service, 35,new Double(7*scaleFactor).intValue());
	            cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
	            table.addCell(cell);
	        }
	        cell=createValueCell("",50);
	        cell.setBorder(PdfPCell.NO_BORDER);
	        table.addCell(cell);
	        cell = createUnderlinedTextCell(ScreenHelper.getTran("web","prestations",sPrintLanguage), 50,new Double(7*scaleFactor).intValue());
	        cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
	        table.addCell(cell);
	        for(int n=0;n<debets.size();n++){
	            Debet debet = (Debet)debets.elementAt(n);
	            String extraInsurar="";
	            if(debet.getExtraInsurarUid()!=null && debet.getExtraInsurarUid().length()>0){
	                Insurar exIns = Insurar.get(debet.getExtraInsurarUid());
	                if(exIns!=null && exIns.getName()!=null){
	                    extraInsurar=" >>> "+ScreenHelper.checkString(exIns.getName());
	                    if(extraInsurar.indexOf("#")>-1){
	                        extraInsurar=extraInsurar.substring(0,extraInsurar.indexOf("#"));
	                    }
	                }
	            }
		        System.out.println("10.3");
	            if(debet.getPrestation()!=null){
		            cell = createValueCell(debet.getQuantity()+" x  ["+debet.getPrestation().getCode()+"] "+debet.getPrestation().getDescription()+extraInsurar, 50,new Double(7*scaleFactor).intValue(),Font.NORMAL);
		            cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
		            table.addCell(cell);
		            cell = createValueCell("", 5);
		            cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
		            table.addCell(cell);
		            cell = createValueCell(ScreenHelper.getTranNoLink("web","Pat.",sPrintLanguage)+": "+priceFormat.format(debet.getAmount())+" / "+ScreenHelper.getTranNoLink("web","Ass.",sPrintLanguage)+": "+priceFormat.format(debet.getInsurarAmount()), 45,new Double(7*scaleFactor).intValue(),Font.NORMAL);
		            cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
		            table.addCell(cell);
	            }
	        }

	        cell=createValueCell("",50);
	        cell.setBorder(PdfPCell.BOTTOM);
	        table.addCell(cell);
	        
	        cell = createValueCell(ScreenHelper.getTran("web","total",sPrintLanguage)+": "+priceFormat.format(totalDebet)+" "+sCurrency, 25,new Double(7*scaleFactor).intValue(),Font.NORMAL);
	        cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
	        table.addCell(cell);
	
	        cell = createValueCell(ScreenHelper.getTran("web","payments",sPrintLanguage)+": "+priceFormat.format(totalCredit)+" "+sCurrency, 25,new Double(7*scaleFactor).intValue(),Font.NORMAL);
	        cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
	        table.addCell(cell);

	        cell=createValueCell("",50);
	        cell.setBorder(PdfPCell.NO_BORDER);
	        table.addCell(cell);
	
	        cell = createValueCell(ScreenHelper.getTran("web","insurar",sPrintLanguage)+": "+priceFormat.format(totalinsurardebet)+" "+sCurrency, 25,new Double(7*scaleFactor).intValue(),Font.NORMAL);
	        cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
	        table.addCell(cell);
	
	        cell = createValueCell(ScreenHelper.getTran("web","balance",sPrintLanguage)+": "+priceFormat.format(invoice.getBalance())+" "+sCurrency, 25,new Double(7*scaleFactor).intValue(),Font.NORMAL);
	        cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
	        table.addCell(cell);
	
	        cell=createValueCell("",50);
	        cell.setBorder(PdfPCell.BOTTOM);
	        table.addCell(cell);

	        PdfContentByte cb = docWriter.getDirectContent();
	        Barcode39 barcode39 = new Barcode39();
	        barcode39.setCode("7"+invoice.getInvoiceNumber());
	        Image image = barcode39.createImageWithBarcode(cb, null, null);
	        cell = new PdfPCell(image);
	        cell.setBorder(PdfPCell.NO_BORDER);
	        cell.setVerticalAlignment(PdfPCell.ALIGN_TOP);
	        cell.setHorizontalAlignment(PdfPCell.ALIGN_CENTER);
	        cell.setColspan(50);
	        cell.setPadding(0);
	        table.addCell(cell);
	
	        doc.add(table);
    	}
    	catch(Exception ee){
    		ee.printStackTrace();
    	}
    }
  
}