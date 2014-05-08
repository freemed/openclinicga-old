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

public class PDFPatientInvoiceReceiptGeneratorCPLR extends PDFInvoiceGenerator {

    //--- CONSTRUCTOR -----------------------------------------------------------------------------
    public PDFPatientInvoiceReceiptGeneratorCPLR(User user, AdminPerson patient, String sProject, String sPrintLanguage){
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
	        double totalDebet=0,totalinsurardebet=0,totalextrainsurardebet=0;
	        Hashtable services = new Hashtable(), insurances = new Hashtable(), extrainsurances = new Hashtable(), careproviders=new Hashtable();
	        String service="",insurance="",extrainsurance="",careprovider="";
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
	            		insurance=debet.getInsurance().getInsurar().getName()+(ScreenHelper.checkString(debet.getInsurance().getInsuranceNr()).length()==0?"":" ("+debet.getInsurance().getInsuranceNr()+")");
	            	}
		            if(checkString(insurance).length()>0){
		            	insurances.put(insurance, debet.getInsurance());
		            }
	            	if(debet.getExtraInsurarUid()!=null){
	            		Insurar extraInsurar = Insurar.get(debet.getExtraInsurarUid());
	            		if(extraInsurar!=null && extraInsurar.getName()!=null){
	            			extrainsurance=extraInsurar.getName();
	            		}
	            	}
		            if(checkString(extrainsurance).length()>0){
		            	extrainsurances.put(extrainsurance, "1");
		            }
	            	if(checkString(debet.getPerformeruid()).length()>0){
	            		User user = User.get(Integer.parseInt(debet.getPerformeruid()));
	            		if(user!=null && user.person!=null){
	            			careprovider=user.person.getFullName();
	            		}
	            	}
		            if(checkString(careprovider).length()>0){
		            	careproviders.put(careprovider, "1");
		            }
		            totalDebet+=debet.getAmount();
		            totalinsurardebet+=debet.getInsurarAmount();
		            totalextrainsurardebet+=debet.getExtraInsurarAmount();
	            }
	        }

			//Create the receipt content
			int receiptid=MedwanQuery.getInstance().getOpenclinicCounter("RECEIPT");
			if(receiptid>=MedwanQuery.getInstance().getConfigInt("maximumNumberOfReceipts",10000)){
				MedwanQuery.getInstance().setOpenclinicCounter("RECEIPT",0);
			}
	        cell = createBorderlessCell(receiptid+" - "+ScreenHelper.getTran("web","receiptforinvoice",sPrintLanguage).toUpperCase()+" "+invoice.getInvoiceNumber(),10, 50,new Double(8*scaleFactor).intValue());
	        cell.setHorizontalAlignment(PdfPCell.ALIGN_CENTER);
	        cell.setPadding(2);
	        table.addCell(cell);
	        cell = createBorderlessCell(ScreenHelper.stdDateFormat.format(invoice.getDate()),10, 50,new Double(8*scaleFactor).intValue());
	        cell.setHorizontalAlignment(PdfPCell.ALIGN_CENTER);
	        cell.setPaddingBottom(10);
	        table.addCell(cell);

	        //Patient
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
	        while(ins.hasMoreElements()){
	        	//Assurance
	        	cell = createValueCell(ScreenHelper.getTran("web","insurance",sPrintLanguage)+":", 15,new Double(7*scaleFactor).intValue(),Font.NORMAL);
                cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
                table.addCell(cell);
	        	insurance = (String)ins.nextElement();
	            cell = createBoldLabelCell(insurance, 35,new Double(7*scaleFactor).intValue());
	            cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
	            table.addCell(cell);

	            //Adherent
		        cell = createValueCell(ScreenHelper.getTran("insurance","member",sPrintLanguage)+":", 15,new Double(7*scaleFactor).intValue(),Font.NORMAL);
		        cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
		        table.addCell(cell);
		        String immat=ScreenHelper.checkString(((Insurance)insurances.get(insurance)).getMemberImmat());
		        cell = createBoldLabelCell(ScreenHelper.checkString(((Insurance)insurances.get(insurance)).getMember())+(immat.length()==0?"":" ("+immat+")"), 35,new Double(7*scaleFactor).intValue());
		        cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
		        table.addCell(cell);
	        }
	        if(checkString(invoice.getInsurarreference()).length()>0){
	        	//B/C Assurance
	        	cell = createValueCell(ScreenHelper.getTran("web","bc.insurar",sPrintLanguage)+":", 15,new Double(7*scaleFactor).intValue(),Font.NORMAL);
                cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
                table.addCell(cell);
	            cell = createBoldLabelCell(checkString(invoice.getInsurarreference()), 35,new Double(7*scaleFactor).intValue());
	            cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
	            table.addCell(cell);
	        }
	        Enumeration extrains=extrainsurances.keys();
	        while(extrains.hasMoreElements()){
	        	//Assurance complémentaire
	        	cell = createValueCell(ScreenHelper.getTran("web","extrainsurar",sPrintLanguage)+":", 15,new Double(7*scaleFactor).intValue(),Font.NORMAL);
                cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
                table.addCell(cell);
	        	extrainsurance = (String)extrains.nextElement();
	            cell = createBoldLabelCell(extrainsurance, 35,new Double(7*scaleFactor).intValue());
	            cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
	            table.addCell(cell);
	        }
	        if(checkString(invoice.getComment()).length()>0){
	        	//B/C Assurance complémentaire
	        	cell = createValueCell(ScreenHelper.getTran("web","bc.extrainsurar",sPrintLanguage)+":", 15,new Double(7*scaleFactor).intValue(),Font.NORMAL);
                cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
                table.addCell(cell);
	            cell = createBoldLabelCell(checkString(invoice.getComment()), 35,new Double(7*scaleFactor).intValue());
	            cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
	            table.addCell(cell);
	        }
	        //Services
	        Enumeration es = services.keys();
	        int nLines=0;
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
	        //Médecin
	        Enumeration cps = careproviders.keys();
	        nLines=0;
	        while (cps.hasMoreElements()){
	        	if(nLines==0){
	                cell = createValueCell(ScreenHelper.getTran("web","physician",sPrintLanguage)+":", 15,new Double(7*scaleFactor).intValue(),Font.NORMAL);
	                cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
	                table.addCell(cell);
	        	}
	        	else {
	                cell = createValueCell("", 15);
	                cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
	                table.addCell(cell);
	        	}
	        	nLines++;
	        	careprovider=(String)cps.nextElement();
	            cell = createBoldLabelCell(careprovider, 35,new Double(7*scaleFactor).intValue());
	            cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
	            table.addCell(cell);
	        }
	        cell=createValueCell("",50);
	        cell.setBorder(PdfPCell.NO_BORDER);
	        table.addCell(cell);
	        cell = createUnderlinedTextCell(ScreenHelper.getTran("web","prestations",sPrintLanguage), 50*MedwanQuery.getInstance().getConfigInt("patientInvoiceReceiptCareDeliveryColumnWidthPercent",60)/100,new Double(7*scaleFactor).intValue());
	        cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
	        table.addCell(cell);
	        cell = createUnderlinedTextCell(ScreenHelper.getTran("web","amount",sPrintLanguage), 50-50*MedwanQuery.getInstance().getConfigInt("patientInvoiceReceiptCareDeliveryColumnWidthPercent",60)/100,new Double(7*scaleFactor).intValue());
	        cell.setHorizontalAlignment(PdfPCell.ALIGN_RIGHT);
	        table.addCell(cell);
	        for(int n=0;n<debets.size();n++){
	            Debet debet = (Debet)debets.elementAt(n);
	            if(debet.getPrestation()!=null){
		            cell = createValueCell(debet.getQuantity()+" x "+debet.getPrestation().getDescription(), 50*MedwanQuery.getInstance().getConfigInt("patientInvoiceReceiptCareDeliveryColumnWidthPercent",60)/100,new Double(7*scaleFactor).intValue(),Font.NORMAL);
		            cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
		            table.addCell(cell);
		            cell = createValueCell(priceFormat.format(debet.getAmount()+debet.getInsurarAmount()+debet.getExtraInsurarAmount()), 50-50*MedwanQuery.getInstance().getConfigInt("patientInvoiceReceiptCareDeliveryColumnWidthPercent",60)/100,new Double(7*scaleFactor).intValue(),Font.NORMAL);
		            cell.setHorizontalAlignment(PdfPCell.ALIGN_RIGHT);
		            table.addCell(cell);
	            }
	        }

	        cell=createValueCell("",50);
	        cell.setBorder(PdfPCell.BOTTOM);
	        table.addCell(cell);
	        
	        //Total général
	        cell = createValueCell(ScreenHelper.getTran("web","total.general",sPrintLanguage), 25,new Double(7*scaleFactor).intValue(),Font.NORMAL);
	        cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
	        table.addCell(cell);
	        cell = createValueCell(priceFormat.format(totalDebet+totalextrainsurardebet+totalinsurardebet), 25,new Double(7*scaleFactor).intValue(),Font.NORMAL);
	        cell.setHorizontalAlignment(PdfPCell.ALIGN_RIGHT);
	        table.addCell(cell);
	        //Total patient
	        cell = createValueCell(ScreenHelper.getTran("web","total.patient",sPrintLanguage)+": "+priceFormat.format(totalDebet), 25,new Double(7*scaleFactor).intValue(),Font.NORMAL);
	        cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
	        table.addCell(cell);
	        //Total assureur
	        cell = createValueCell(ScreenHelper.getTran("web","total.insurar",sPrintLanguage)+": "+priceFormat.format(totalinsurardebet), 25,new Double(7*scaleFactor).intValue(),Font.NORMAL);
	        cell.setHorizontalAlignment(PdfPCell.ALIGN_RIGHT);
	        table.addCell(cell);
	        //Payé patient
	        cell = createValueCell(ScreenHelper.getTran("web","payments",sPrintLanguage)+": "+priceFormat.format(totalCredit), 25,new Double(7*scaleFactor).intValue(),Font.NORMAL);
	        cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
	        table.addCell(cell);
	        //Total assureur complémentaire
	        cell = createValueCell(ScreenHelper.getTran("web","total.extrainsurar",sPrintLanguage)+": "+priceFormat.format(totalextrainsurardebet), 25,new Double(7*scaleFactor).intValue(),Font.NORMAL);
	        cell.setHorizontalAlignment(PdfPCell.ALIGN_RIGHT);
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

	        cell=createValueCell("",50);
	        cell.setBorder(PdfPCell.BOTTOM);
	        table.addCell(cell);

	        if(MedwanQuery.getInstance().getConfigInt("enablePatientReceiptSignatures",0)==1){
		        //Signature patient
		        cell = createValueCell(ScreenHelper.getTranNoLink("web","signature.patient",sPrintLanguage), 25,new Double(7*scaleFactor).intValue(),Font.NORMAL);
		        cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
		        table.addCell(cell);
		        //Signature provider
		        cell = createValueCell(ScreenHelper.getTranNoLink("web","signature.provider",sPrintLanguage), 25,new Double(7*scaleFactor).intValue(),Font.NORMAL);
		        cell.setHorizontalAlignment(PdfPCell.ALIGN_RIGHT);
		        table.addCell(cell);
	
		        cell=createValueCell("\r\n",50);
		        cell.setBorder(PdfPCell.NO_BORDER);
		        table.addCell(cell);
		        cell=createValueCell("\r\n",50);
		        cell.setBorder(PdfPCell.NO_BORDER);
		        table.addCell(cell);
	        }

	        for(int n=0; n < MedwanQuery.getInstance().getConfigInt("receiptPrinterEmptyLines",0);n++){
		        cell=createValueCell("\r\n",50);
		        cell.setBorder(PdfPCell.NO_BORDER);
		        table.addCell(cell);
	        }


	        doc.add(table);
    	}
    	catch(Exception ee){
    		ee.printStackTrace();
    	}
    }
  
}