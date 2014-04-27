package be.mxs.common.util.pdf.general;

import com.itextpdf.text.pdf.*;
import com.itextpdf.text.*;

import java.util.*;
import java.io.ByteArrayOutputStream;
import java.text.DecimalFormat;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import javax.servlet.http.HttpServletRequest;

import org.hnrw.report.Report_Identification;

import be.mxs.common.util.system.Miscelaneous;
import be.mxs.common.util.system.Debug;
import be.mxs.common.util.system.ScreenHelper;
import be.mxs.common.util.db.MedwanQuery;
import be.mxs.webapp.wl.struts.actions.healthrecord.CreateTransactionAction;
import be.openclinic.finance.*;
import be.openclinic.adt.Encounter;
import be.openclinic.adt.Encounter.EncounterService;
import net.admin.*;

public class PDFExtraInsurarInvoiceGeneratorCTAMS2 extends PDFInvoiceGenerator {
    String PrintType;
    double pageConsultationAmount=0,pageLabAmount=0,pageImagingAmount=0,pageAdmissionAmount=0,pageActsAmount=0,pageConsumablesAmount=0,pageOtherAmount=0,pageDrugsAmount=0,pageTotalAmount100=0,pageTotalAmount85=0;

    //--- CONSTRUCTOR -----------------------------------------------------------------------------
    public PDFExtraInsurarInvoiceGeneratorCTAMS2(User user, String sProject, String sPrintLanguage, String PrintType){
        this.user = user;
        this.sProject = sProject;
        this.sPrintLanguage = sPrintLanguage;
        this.PrintType=PrintType;

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
			doc.setPageSize(PageSize.A4.rotate());
            addFooter(sInvoiceUid.replaceAll("1\\.",""));

            doc.open();

            // get specified invoice
            ExtraInsurarInvoice2 invoice = ExtraInsurarInvoice2.get(sInvoiceUid);

            addHeading(invoice);
            addInsurarData(invoice);
            printInvoice(invoice);
            addFinancialMessage();
            
            doc.setPageSize(PageSize.A4);
            doc.newPage();
            addSummaryData(invoice);
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
    
    private void addSummaryData(ExtraInsurarInvoice2 invoice) throws Exception{
		try{
			int iAmbCount=0,iAdmCount=0;
			double dAmbDrugs=0,dAdmDrugs=0,dAmbExa=0,dAdmExa=0,dAmbAct=0,dAdmAct=0,dAmbOther=0,dAdmOther=0,rInsurarAmount=0;
		    String month="";
		    String switch1="",s="",sCat="";
	        //Eerst nemen we alle debets
	        Vector debets = invoice.getDebets();
	        //Nu gaan we aan elke debet als datum de patientfactuurdatum geven
	        Hashtable patientInvoices = new Hashtable(), categories = new Hashtable();
	        Debet debet;
	        Date date;
	        PatientInvoice patientInvoice;
	        SortedMap sortedDebets = new TreeMap();
	        for(int n=0;n<debets.size();n++){
	        	debet = (Debet)debets.elementAt(n);
	        	if(debet.getPatientInvoiceUid()!=null){
		        	date = (Date)patientInvoices.get(debet.getPatientInvoiceUid());
		        	if(date==null){
		        		patientInvoice = PatientInvoice.get(debet.getPatientInvoiceUid());
		        		if(patientInvoice!=null){
		        			date = patientInvoice.getDate();
		        			if(date!=null){
		        				patientInvoices.put(debet.getPatientInvoiceUid(), date);
		        			}
		        		}
		        	}
		        	if(date!=null){
		        		debet.setDate(date);
		        	}
		        	sortedDebets.put(new SimpleDateFormat("yyyyMMdd").format(debet.getDate())+"."+debet.getPatientName()+"."+debet.getUid(), debet);
	        	}
	        	else {
	        		System.out.println("WARNING: debet "+debet.getUid()+" has no PatientInvoice associated");
	        	}
	        }
	        //Breng nu de gesorteerde debets terug over naar de vector
	        debets = new Vector();
	        Iterator iDebets = sortedDebets.keySet().iterator();
	        while(iDebets.hasNext()){
	        	debets.add(sortedDebets.get(iDebets.next()));
	        }
			for(int n=0;n<debets.size();n++){
				debet = (Debet)debets.elementAt(n);
		    	if(debet!=null && debet.getDate()!=null){
		    		String m = new SimpleDateFormat("MM").format(debet.getDate());
		    		if(month.indexOf(m)<0){
		    			if(month.length()>0){
		    				month+="+";
		    			}
		    			month+=m;
		    		}
		    	}
		    	rInsurarAmount=0;
		    	if(debet.getEncounter()!=null){
		    		s=new SimpleDateFormat("yyy.MM.dd").format(debet.getDate())+"."+debet.getEncounter().getPatientUID()+"."+debet.getEncounter().getType();
	                Prestation prestation = debet.getPrestation();
	                rInsurarAmount = Math.round(debet.getExtraInsurarAmount());
	                if(prestation!=null && prestation.getReferenceObject()!=null && prestation.getReferenceObject().getObjectType()!=null && prestation.getReferenceObject().getObjectType().length()>0){
	                	sCat=prestation.getReferenceObject().getObjectType();
	                }
	                else {
	                	sCat="OTHER";
	                }                
	    			if(s.indexOf(".admission")>0){
	    				if(sCat.equalsIgnoreCase(MedwanQuery.getInstance().getConfigString("CTAMSdrugsCategory","M"))){
	    					dAdmDrugs+=rInsurarAmount;
	    				}
	    				else if(sCat.equalsIgnoreCase(MedwanQuery.getInstance().getConfigString("CTAMSconsumablesCategory","C"))){
	    					dAdmDrugs+=rInsurarAmount;
	    				}
	    				else if(sCat.equalsIgnoreCase(MedwanQuery.getInstance().getConfigString("CTAMSimagingCategory","R"))){
	    					dAdmExa+=rInsurarAmount;
	    				}
	    				else if(sCat.equalsIgnoreCase(MedwanQuery.getInstance().getConfigString("CTAMSlabCategory","L"))){
	    					dAdmExa+=rInsurarAmount;
	    				}
	    				else if(sCat.equalsIgnoreCase(MedwanQuery.getInstance().getConfigString("CTAMSconsultationCategory","Co"))){
	    					dAdmAct+=rInsurarAmount;
	    				}
	    				else if(sCat.equalsIgnoreCase(MedwanQuery.getInstance().getConfigString("CTAMSactsCategory","A"))){
	    					dAdmAct+=rInsurarAmount;
	    				}
	    				else {
	    					dAdmOther+=rInsurarAmount;
	    				}
	    			}
	    			else{
	    				if(sCat.equalsIgnoreCase(MedwanQuery.getInstance().getConfigString("CTAMSdrugsCategory","M"))){
	    					dAmbDrugs+=rInsurarAmount;
	    				}
	    				else if(sCat.equalsIgnoreCase(MedwanQuery.getInstance().getConfigString("CTAMSconsumablesCategory","C"))){
	    					dAmbDrugs+=rInsurarAmount;
	    				}
	    				else if(sCat.equalsIgnoreCase(MedwanQuery.getInstance().getConfigString("CTAMSimagingCategory","R"))){
	    					dAmbExa+=rInsurarAmount;
	    				}
	    				else if(sCat.equalsIgnoreCase(MedwanQuery.getInstance().getConfigString("CTAMSlabCategory","L"))){
	    					dAmbExa+=rInsurarAmount;
	    				}
	    				else if(sCat.equalsIgnoreCase(MedwanQuery.getInstance().getConfigString("CTAMSconsultationCategory","Co"))){
	    					dAmbAct+=rInsurarAmount;
	    				}
	    				else if(sCat.equalsIgnoreCase(MedwanQuery.getInstance().getConfigString("CTAMSactsCategory","A"))){
	    					dAmbAct+=rInsurarAmount;
	    				}
	    				else {
	    					dAmbOther+=rInsurarAmount;
	    				}
	    			}
		    		
		    		//Count ambulatory or admission whenever the combination date-patientuid-encountertype changes
		    		if(n>0 && !switch1.equalsIgnoreCase(s)){
		    			switch1=s;
		    			if(s.indexOf(".admission")>0){
		    				iAdmCount++;
		    			}
		    			else{
		    				iAmbCount++;
		    			}
		    		}
		    	}
			}
			if(s.indexOf(".admission")>0){
				iAdmCount++;
			}
			else{
				iAmbCount++;
			}
			
			table=new PdfPTable(100);
		    table.setWidthPercentage(pageWidth);
		    Report_Identification report_identification = new Report_Identification(invoice.getDate());
		    PdfPTable table2 = new PdfPTable(5);
		    cell=createLabelCell(MedwanQuery.getInstance().getLabel("report.monthly","fosa",user.person.language), 1);
		    table2.addCell(cell);
		    cell=createBoldLabelCell(report_identification.getItem("OC_HC_FOSA"), 4);
		    table2.addCell(cell);
		    cell=createLabelCell(MedwanQuery.getInstance().getLabel("report.monthly","district",user.person.language), 1);
		    table2.addCell(cell);
		    cell=createBoldLabelCell(report_identification.getItem("OC_HC_DISTRICT"), 4);
		    table2.addCell(cell);
		    cell=createLabelCell(MedwanQuery.getInstance().getLabel("report.monthly","province",user.person.language), 1);
		    table2.addCell(cell);
		    cell=createBoldLabelCell(MedwanQuery.getInstance().getLabel("province",report_identification.getItem("OC_HC_PROVINCE"),user.person.language), 4);
		    table2.addCell(cell);
		    cell=new PdfPCell(table2);
		    cell.setBorder(PdfPCell.NO_BORDER);
		    cell.setColspan(100);
		    table.addCell(cell);
		    doc.add(table);
		    addBlankRow();
		    addBlankRow();
		    Insurar insurar = invoice.getInsurar();
			table=new PdfPTable(1);
		    table.setWidthPercentage(pageWidth);
		    table.addCell(createGrayCell(MedwanQuery.getInstance().getLabel("web","global_invoice",user.person.language)+": "+month+new SimpleDateFormat("/yyyy").format(invoice.getDate()),1,9,Font.BOLD));
		
		    doc.add(table);
		    addBlankRow();
		    addBlankRow();
			table=new PdfPTable(1);
		    table.setWidthPercentage(pageWidth);
		    table.addCell(createLabelCell(insurar.getOfficialName()+" "+MedwanQuery.getInstance().getLabel("report.monthly","district",user.person.language)+" "+report_identification.getItem("OC_HC_DISTRICT")+" "+
		    		MedwanQuery.getInstance().getLabel("web","owes",user.person.language)+" "+report_identification.getItem("OC_HC_FOSA")+" "+MedwanQuery.getInstance().getLabel("web","thesumof",user.person.language)+
		    		" "+new DecimalFormat(MedwanQuery.getInstance().getConfigString("priceFormatInsurar","#")).format(invoice.getBalance())+" "+MedwanQuery.getInstance().getConfigString("currency","RWF"),1));
		
		    table.addCell(createLabelCell(MedwanQuery.getInstance().getLabel("web","for.health.services.during",user.person.language)+" "+month+" "+MedwanQuery.getInstance().getLabel("web","of.which",user.person.language),1));
		    doc.add(table);
		    addBlankRow();
		    addBlankRow();
			table=new PdfPTable(60);
		    table.setWidthPercentage(pageWidth);
		    cell=createBoldLabelCell(MedwanQuery.getInstance().getLabel("web","patients",user.person.language), 10);
		    cell.setBorder(PdfPCell.BOX);
		    table.addCell(cell);
		    cell=createBoldLabelCell(MedwanQuery.getInstance().getLabel("web","ctams.number",user.person.language), 10);
		    cell.setBorder(PdfPCell.BOX);
		    table.addCell(cell);
		    cell=createBoldLabelCell(MedwanQuery.getInstance().getLabel("web","drugs.and.consumables.costs",user.person.language), 10);
		    cell.setBorder(PdfPCell.BOX);
		    table.addCell(cell);
		    cell=createBoldLabelCell(MedwanQuery.getInstance().getLabel("web","examination.costs",user.person.language), 10);
		    cell.setBorder(PdfPCell.BOX);
		    table.addCell(cell);
		    cell=createBoldLabelCell(MedwanQuery.getInstance().getLabel("web","acts.costs",user.person.language), 10);
		    cell.setBorder(PdfPCell.BOX);
		    table.addCell(cell);
		    cell=createBoldLabelCell(MedwanQuery.getInstance().getLabel("web","other.costs",user.person.language), 10);
		    cell.setBorder(PdfPCell.BOX);
		    table.addCell(cell);
		    cell=createBoldLabelCell(MedwanQuery.getInstance().getLabel("web","ambulatory",user.person.language), 10);
		    cell.setBorder(PdfPCell.BOX);
		    table.addCell(cell);
		    cell=createBoldLabelCell(iAmbCount+"", 10);
		    cell.setBorder(PdfPCell.BOX);
		    table.addCell(cell);
		    cell=createBoldLabelCell(new DecimalFormat(MedwanQuery.getInstance().getConfigString("priceFormat","#")).format(dAmbDrugs), 10);
		    cell.setBorder(PdfPCell.BOX);
		    table.addCell(cell);
		    cell=createBoldLabelCell(new DecimalFormat(MedwanQuery.getInstance().getConfigString("priceFormat","#")).format(dAmbExa), 10);
		    cell.setBorder(PdfPCell.BOX);
		    table.addCell(cell);
		    cell=createBoldLabelCell(new DecimalFormat(MedwanQuery.getInstance().getConfigString("priceFormat","#")).format(dAmbAct), 10);
		    cell.setBorder(PdfPCell.BOX);
		    table.addCell(cell);
		    cell=createBoldLabelCell(new DecimalFormat(MedwanQuery.getInstance().getConfigString("priceFormat","#")).format(dAmbOther), 10);
		    cell.setBorder(PdfPCell.BOX);
		    table.addCell(cell);
		    cell=createBoldLabelCell(MedwanQuery.getInstance().getLabel("web","admitted",user.person.language), 10);
		    cell.setBorder(PdfPCell.BOX);
		    table.addCell(cell);
		    cell=createBoldLabelCell(iAdmCount+"", 10);
		    cell.setBorder(PdfPCell.BOX);
		    table.addCell(cell);
		    cell=createBoldLabelCell(new DecimalFormat(MedwanQuery.getInstance().getConfigString("priceFormat","#")).format(dAdmDrugs), 10);
		    cell.setBorder(PdfPCell.BOX);
		    table.addCell(cell);
		    cell=createBoldLabelCell(new DecimalFormat(MedwanQuery.getInstance().getConfigString("priceFormat","#")).format(dAdmExa), 10);
		    cell.setBorder(PdfPCell.BOX);
		    table.addCell(cell);
		    cell=createBoldLabelCell(new DecimalFormat(MedwanQuery.getInstance().getConfigString("priceFormat","#")).format(dAdmAct), 10);
		    cell.setBorder(PdfPCell.BOX);
		    table.addCell(cell);
		    cell=createBoldLabelCell(new DecimalFormat(MedwanQuery.getInstance().getConfigString("priceFormat","#")).format(dAdmOther), 10);
		    cell.setBorder(PdfPCell.BOX);
		    table.addCell(cell);
		    cell=createBoldLabelCell(MedwanQuery.getInstance().getLabel("web","total",user.person.language), 10);
		    cell.setBorder(PdfPCell.BOX);
		    table.addCell(cell);
		    cell=createBoldLabelCell((iAmbCount+iAdmCount)+"", 10);
		    cell.setBorder(PdfPCell.BOX);
		    table.addCell(cell);
		    cell=createBoldLabelCell(new DecimalFormat(MedwanQuery.getInstance().getConfigString("priceFormat","#")).format(dAdmDrugs+dAmbDrugs), 10);
		    cell.setBorder(PdfPCell.BOX);
		    table.addCell(cell);
		    cell=createBoldLabelCell(new DecimalFormat(MedwanQuery.getInstance().getConfigString("priceFormat","#")).format(dAdmExa+dAmbExa), 10);
		    cell.setBorder(PdfPCell.BOX);
		    table.addCell(cell);
		    cell=createBoldLabelCell(new DecimalFormat(MedwanQuery.getInstance().getConfigString("priceFormat","#")).format(dAdmAct+dAmbAct), 10);
		    cell.setBorder(PdfPCell.BOX);
		    table.addCell(cell);
		    cell=createBoldLabelCell(new DecimalFormat(MedwanQuery.getInstance().getConfigString("priceFormat","#")).format(dAdmOther+dAmbOther), 10);
		    cell.setBorder(PdfPCell.BOX);
		    table.addCell(cell);
		    doc.add(table);
		    
		    addBlankRow();
		    addBlankRow();
			table=new PdfPTable(1);
		    table.setWidthPercentage(pageWidth);
		    table.addCell(createLabelCell(MedwanQuery.getInstance().getLabel("web","ctams.payto",user.person.language),1));
		    doc.add(table);
		    addBlankRow();
			table=new PdfPTable(2);
		    table.setWidthPercentage(pageWidth);
		    table.addCell(createLabelCell("",1));
		    table.addCell(createLabelCell(MedwanQuery.getInstance().getLabel("web","ctams.signature1",user.person.language),1));
		    doc.add(table);
		    addBlankRow();
			table=new PdfPTable(2);
		    table.setWidthPercentage(pageWidth);
		    table.addCell(createLabelCell("",1));
		    table.addCell(createLabelCell(MedwanQuery.getInstance().getLabel("web","ctams.signature2",user.person.language),1));
		    doc.add(table);
		    
		    
		}
		catch(Exception e){
			e.printStackTrace();
		}
        
 }

    private void addFinancialMessage() throws Exception {
        addBlankRow();
        table = new PdfPTable(3);
        table.setWidthPercentage(pageWidth);
        cell = createValueCell(getTran("invoiceFinancialMessageTitle")+getTran("invoiceFinancialMessageTitle2"),3);
        cell.setBorder(PdfPCell.BOX);
        table.addCell(cell);
        table.addCell(createCell(new PdfPCell(getPrintedByInfo()),2,PdfPCell.ALIGN_LEFT,PdfPCell.NO_BORDER));
        cell = createBoldLabelCell(getTran("invoiceDirector"),1);
        table.addCell(cell);
        doc.add(table);
    }
    //---- ADD HEADING (logo & barcode) -----------------------------------------------------------
    private void addHeading(ExtraInsurarInvoice2 invoice) throws Exception {
        table = new PdfPTable(10);
        table.setWidthPercentage(pageWidth);

        try {
            //*** logo ***
            try{
                Image img = Miscelaneous.getImage("logo_"+sProject+".gif",sProject);
                img.scaleToFit(75, 75);
                cell = new PdfPCell(img);
                cell.setBorder(PdfPCell.NO_BORDER);
                cell.setColspan(2);
                table.addCell(cell);
            }
            catch(NullPointerException e){
                Debug.println("WARNING : PDFPatientInvoiceGenerator --> IMAGE NOT FOUND : logo_"+sProject+".gif");
                e.printStackTrace();
                cell = new PdfPCell();
                cell.setBorder(PdfPCell.NO_BORDER);
                cell.setColspan(2);
                table.addCell(cell);
            }

            Report_Identification report_identification = new Report_Identification(invoice.getDate());
            PdfPTable table2 = new PdfPTable(5);
            cell=createLabelCell(MedwanQuery.getInstance().getLabel("report.monthly","district",user.person.language), 1);
            table2.addCell(cell);
            cell=createBoldLabelCell(report_identification.getItem("OC_HC_DISTRICT"), 4);
            table2.addCell(cell);
            cell=createLabelCell(MedwanQuery.getInstance().getLabel("report.monthly","province",user.person.language), 1);
            table2.addCell(cell);
            cell=createBoldLabelCell(MedwanQuery.getInstance().getLabel("province",report_identification.getItem("OC_HC_PROVINCE"),user.person.language), 4);
            table2.addCell(cell);
            cell=createLabelCell(MedwanQuery.getInstance().getLabel("report.monthly","fosa",user.person.language), 1);
            table2.addCell(cell);
            cell=createBoldLabelCell(report_identification.getItem("OC_HC_FOSA"), 4);
            table2.addCell(cell);
            cell=new PdfPCell(table2);
            cell.setBorder(PdfPCell.NO_BORDER);
            cell.setColspan(6);
            table.addCell(cell);
            
            //*** barcode ***
            PdfContentByte cb = docWriter.getDirectContent();
            Barcode39 barcode39 = new Barcode39();
            barcode39.setCode("6"+invoice.getInvoiceUid());
            Image image = barcode39.createImageWithBarcode(cb,null,null);
            cell = new PdfPCell(image);
            cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
            cell.setBorder(PdfPCell.NO_BORDER);
            cell.setColspan(2);
            table.addCell(cell);

            doc.add(table);
            addBlankRow();
            addBlankRow();
        }
        catch(Exception e){
            e.printStackTrace();
        }
    }

    //--- ADD INSURAR DATA ------------------------------------------------------------------------
    private void addInsurarData(ExtraInsurarInvoice2 invoice){
        PdfPTable table = new PdfPTable(1);
        table.setWidthPercentage(pageWidth);

        try {
            Insurar insurar = invoice.getInsurar();

            String month="";
            Vector debets = ExtraInsurarInvoice2.getDebetsForInvoiceSortByDate(invoice.getUid());
            for(int n=0;n<debets.size();n++){
            	Debet debet = (Debet)debets.elementAt(n);
            	if(debet!=null && debet.getDate()!=null){
            		String m = new SimpleDateFormat("MM").format(debet.getDate());
            		if(month.indexOf(m)<0){
            			if(month.length()>0){
            				month+="+";
            			}
            			month+=m;
            		}
            	}
            }
            table.addCell(createGrayCell(insurar.getOfficialName().toUpperCase()+"\n"+MedwanQuery.getInstance().getLabel("web","month_invoice_summary",user.person.language)+": "+month+new SimpleDateFormat("/yyyy").format(invoice.getDate()),1,9,Font.BOLD));

            doc.add(table);
            addBlankRow();
        }
        catch(Exception e){
            e.printStackTrace();
        }
    }

    //--- PRINT INVOICE ---------------------------------------------------------------------------
    protected void printInvoice(ExtraInsurarInvoice2 invoice){
        try {

            // debets
            getDebets(invoice);
            PdfPTable table = new PdfPTable(1);
            table.setWidthPercentage(pageWidth);
            
            
            table.addCell(createEmptyCell(1));

            // "pay to" info
            PdfPTable payToTable = new PdfPTable(1);
            payToTable.addCell(createGrayCell(getTran("web","payToInfo").toUpperCase(),1));
            cell = new PdfPCell(getPayToInfo());
            cell.setPadding(cellPadding);
            payToTable.addCell(createCell(cell,1,PdfPCell.ALIGN_LEFT,PdfPCell.BOX));
            table.addCell(createCell(new PdfPCell(payToTable),1,PdfPCell.ALIGN_CENTER,PdfPCell.NO_BORDER));
            table.addCell(createEmptyCell(10,1));
			
            doc.add(table);
        }
        catch(Exception e){
            e.printStackTrace();
        }
    }

    //### PRIVATE METHODS #########################################################################

    //--- GET DEBETS (prestations) ----------------------------------------------------------------
    // grouped by patient, sorted on date desc
    private void getDebets(ExtraInsurarInvoice2 invoice) throws DocumentException{
    	
    	PdfPTable tableParent = new PdfPTable(1);
        tableParent.setWidthPercentage(pageWidth);
    	
        //Eerst nemen we alle debets
        Vector debets = invoice.getDebets();
        //Nu gaan we aan elke debet als datum de patientfactuurdatum geven
        Hashtable patientInvoices = new Hashtable();
        Debet debet;
        Date date=null;
        PatientInvoice patientInvoice;
        SortedMap sortedDebets = new TreeMap();
        for(int n=0;n<debets.size();n++){
        	debet = (Debet)debets.elementAt(n);
        	if(debet.getPatientInvoiceUid()!=null){
	        	date = (Date)patientInvoices.get(debet.getPatientInvoiceUid());
	        	if(date==null){
	        		patientInvoice = PatientInvoice.get(debet.getPatientInvoiceUid());
	        		if(patientInvoice!=null){
	        			date = patientInvoice.getDate();
	        			if(date!=null){
	        				patientInvoices.put(debet.getPatientInvoiceUid(), date);
	        			}
	        		}
	        	}
	        	if(date!=null){
	        		debet.setDate(date);
	        	}
	        	sortedDebets.put(new SimpleDateFormat("yyyyMMdd").format(debet.getDate())+"."+debet.getPatientName()+"."+debet.getUid(), debet);
        	}
        	else {
        		System.out.println("WARNING: debet "+debet.getUid()+" has no PatientInvoice associated");
        	}
        }
        //Breng nu de gesorteerde debets terug over naar de vector
        debets = new Vector();
        Iterator iDebets = sortedDebets.keySet().iterator();
        while(iDebets.hasNext()){
        	debets.add(sortedDebets.get(iDebets.next()));
        }
        if(debets.size() > 0){
            cell=new PdfPCell(getTableHeader(invoice.getInsurar()));
            cell.setPadding(cellPadding);
            tableParent.addCell(createCell(cell,1,PdfPCell.ALIGN_LEFT,PdfPCell.NO_BORDER));

            // print debets
            String sPatientName="", sPrevPatientName = "",sPreviousInvoiceUID="";
		    String switch1="",sw="",svc="";
            Date prevdate=null;
            boolean displayPatientName=false,displayDate=false;
            SortedMap categories = new TreeMap(), totalcategories = new TreeMap();
            double total100pct=0,total85pct=0,generaltotal100pct=0,generaltotal85pct=0,daytotal100pct=0,daytotal85pct=0;
            String invoiceid="",adherent="",recordnumber="",insurarreference="",service="";
            int linecounter=1;
            EncounterService lastservice;
            for(int i=0; i<debets.size(); i++){
                debet = (Debet)debets.get(i);
		    	if(debet.getEncounter()!=null){
                    if(ScreenHelper.checkString(debet.getEncounter().getServiceUID()).length()==0){
                    	lastservice=debet.getEncounter().getLastEncounterService();
                    	if(lastservice!=null){
                    		debet.getEncounter().setServiceUID(lastservice.serviceUID);
                    	}
                    }
                    if(debet.getEncounter().getService()!=null){
                    	svc=debet.getEncounter().getService().getLabel(user.person.language);
                    	service=svc.substring(0,svc.length()>16?16:svc.length());
                    }
	                try {
						date = stdDateFormat.parse(stdDateFormat.format(debet.getDate()));
					} catch (ParseException e) {
						e.printStackTrace();
					}
	                displayDate = !date.equals(prevdate);
	                sPatientName = debet.getPatientName()+";"+debet.getEncounter().getPatientUID();
	                displayPatientName = displayDate || !sPatientName.equals(sPrevPatientName) || (debet.getPatientInvoiceUid()!=null && debet.getPatientInvoiceUid().indexOf(".")>=0 && invoiceid.indexOf(debet.getPatientInvoiceUid().split("\\.")[1])<0 && invoiceid.length()>0);
		    		sw=new SimpleDateFormat("yyy.MM.dd").format(debet.getDate())+"."+debet.getEncounter().getPatientUID()+"."+debet.getEncounter().getType();
		    		//Count ambulatory or admission whenever the combination date-patientuid-encountertype changes
		    		if(i>0 && !switch1.equalsIgnoreCase(sw)){
		    			switch1=sw;
	                    table = new PdfPTable(2000);
	                    table.setWidthPercentage(pageWidth);
	                    printDebet2(table,categories,displayDate,prevdate!=null?prevdate:date,invoiceid,adherent,sPrevPatientName.split(";")[0],total100pct,total85pct,recordnumber,linecounter++,daytotal100pct,daytotal85pct,tableParent,insurarreference,service);
	                    service="";
	                    if(linecounter==36 || (linecounter-36)%40==0){
	                        // display debet total
	                		table.addCell(createEmptyCell(700));
	                        cell = createLabelCell(getTran("web","pagesubtotalprice"),300);
	                        cell.setHorizontalAlignment(PdfPCell.ALIGN_RIGHT);
	                        cell.setPaddingRight(5);
	                        table.addCell(cell);
	
	                        cell = createLabelCell(priceFormatInsurar.format(pageConsultationAmount),100,7);
	                        cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
	                        cell.setVerticalAlignment(PdfPCell.ALIGN_TOP);
	                        cell.setBorder(PdfPCell.BOX);
	                        cell.setPaddingRight(5);
	                        table.addCell(cell);
	
	                        cell = createLabelCell(priceFormatInsurar.format(pageLabAmount),100,7);
	                        cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
	                        cell.setVerticalAlignment(PdfPCell.ALIGN_TOP);
	                        cell.setBorder(PdfPCell.BOX);
	                        cell.setPaddingRight(5);
	                        table.addCell(cell);
	
	                        cell = createLabelCell(priceFormatInsurar.format(pageImagingAmount),100,7);
	                        cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
	                        cell.setVerticalAlignment(PdfPCell.ALIGN_TOP);
	                        cell.setBorder(PdfPCell.BOX);
	                        cell.setPaddingRight(5);
	                        table.addCell(cell);
	
	                        cell = createLabelCell(priceFormatInsurar.format(pageAdmissionAmount),100,7);
	                        cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
	                        cell.setVerticalAlignment(PdfPCell.ALIGN_TOP);
	                        cell.setBorder(PdfPCell.BOX);
	                        cell.setPaddingRight(5);
	                        table.addCell(cell);
	
	                        cell = createLabelCell(priceFormatInsurar.format(pageDrugsAmount),100,7);
	                        cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
	                        cell.setVerticalAlignment(PdfPCell.ALIGN_TOP);
	                        cell.setBorder(PdfPCell.BOX);
	                        cell.setPaddingRight(5);
	                        table.addCell(cell);
	
	                        cell = createLabelCell(priceFormatInsurar.format(pageConsumablesAmount),100,7);
	                        cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
	                        cell.setVerticalAlignment(PdfPCell.ALIGN_TOP);
	                        cell.setBorder(PdfPCell.BOX);
	                        cell.setPaddingRight(5);
	                        table.addCell(cell);
	
	                        cell = createLabelCell(priceFormatInsurar.format(pageActsAmount),100,7);
	                        cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
	                        cell.setVerticalAlignment(PdfPCell.ALIGN_TOP);
	                        cell.setBorder(PdfPCell.BOX);
	                        cell.setPaddingRight(5);
	                        table.addCell(cell);
	
	                        cell = createLabelCell(priceFormatInsurar.format(pageOtherAmount),100,7);
	                        cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
	                        cell.setVerticalAlignment(PdfPCell.ALIGN_TOP);
	                        cell.setBorder(PdfPCell.BOX);
	                        cell.setPaddingRight(5);
	                        table.addCell(cell);
	                        table.addCell(createEmptyCell(200));
	
	                        
	                        //Nu de totalen toevoegen
	                        table.addCell(createEmptyCell(700));
	                        cell = createLabelCell(getTran("web","pagetotalprice"),300);
	                        cell.setHorizontalAlignment(PdfPCell.ALIGN_RIGHT);
	                        cell.setPaddingRight(5);
	                        table.addCell(cell);
	                        table.addCell(createEmptyCell(800));
	                        cell = createLabelCell(priceFormatInsurar.format(pageTotalAmount100)+" RWF",100,7);
	                        cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
	                        cell.setBorder(PdfPCell.BOX);
	                        cell.setPaddingRight(5);
	                        table.addCell(cell);
	                        cell = createLabelCell(priceFormatInsurar.format(pageTotalAmount85)+" RWF",100,7);
	                        cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
	                        cell.setBorder(PdfPCell.BOX);
	                        cell.setPaddingRight(5);
	                        table.addCell(cell);
	                        
	                        pageConsultationAmount=0;
	                        pageLabAmount=0;
	                        pageImagingAmount=0;
	                        pageAdmissionAmount=0;
	                        pageActsAmount=0;
	                        pageConsumablesAmount=0;
	                        pageOtherAmount=0;
	                        pageDrugsAmount=0;
	                        pageTotalAmount100=0;
	                        pageTotalAmount85=0;
	                	}
	                    cell=new PdfPCell(table);
	                    cell.setPadding(0);
	                    tableParent.addCell(createCell(cell,1,PdfPCell.ALIGN_LEFT,PdfPCell.NO_BORDER));
	                	if(linecounter==36 || (linecounter-36)%40==0){
	                        doc.add(tableParent);
	                    	doc.newPage();
	                        tableParent = new PdfPTable(1);
	                        tableParent.setWidthPercentage(pageWidth);
	                        cell=new PdfPCell(getTableHeader(invoice.getInsurar()));
	                        cell.setPadding(cellPadding);
	                        tableParent.addCell(createCell(cell,1,PdfPCell.ALIGN_LEFT,PdfPCell.NO_BORDER));
	                        table = new PdfPTable(2000);
	                        table.setWidthPercentage(pageWidth);
	                	}
	                	
	                	categories = new TreeMap();
	                	total100pct=0;
	                	total85pct=0;
	                	if(displayDate){
	                		daytotal100pct=0;
	                		daytotal85pct=0;
	                	}
	                	invoiceid="";
	                	adherent="";
	                	recordnumber="";
	                	insurarreference="";
	                }
		    		else if(i==0){
		    			switch1=sw;
		    		}
	                if(debet.getPatientInvoiceUid()!=null && debet.getPatientInvoiceUid().indexOf(".")>=0 && invoiceid.indexOf(debet.getPatientInvoiceUid().split("\\.")[1])<0){
	                	if(invoiceid.length()>0){
	                		invoiceid+="\n";
	                	}
	                	invoiceid+=debet.getPatientInvoiceUid().split("\\.")[1];
	                	if(insurarreference.equalsIgnoreCase("")){
		                	patientInvoice = PatientInvoice.get(debet.getPatientInvoiceUid());
		                	if(patientInvoice!=null){
		                		insurarreference=patientInvoice.getInsurarreference();
		                	}
	                	}
	                }
	                if(debet.getInsuranceUid()!=null){
	                	Insurance insurance = Insurance.get(debet.getInsuranceUid());
	                	debet.setInsurance(insurance);
	                }
	                if(debet.getInsurance()!=null && debet.getInsurance().getMember()!=null && adherent.indexOf(debet.getInsurance().getMember().toUpperCase())<0){
	                	if(adherent.length()>0){
	                		adherent+="\n";
	                	}
	                	adherent+=debet.getInsurance().getMember().toUpperCase();
	                }
	                if(debet.getInsurance()!=null && debet.getInsurance().getInsuranceNr()!=null && recordnumber.indexOf(debet.getInsurance().getInsuranceNr())<0){
	                	if(recordnumber.length()>0){
	                		recordnumber+="\n";
	                	}
	                	recordnumber+=debet.getInsurance().getInsuranceNr();
	                }
	                Prestation prestation = debet.getPrestation();
	                double rAmount = Math.round(debet.getAmount());
	                double rInsurarAmount = Math.round(debet.getInsurarAmount());
	                double rExtraInsurarAmount = Math.round(debet.getExtraInsurarAmount());
	                double rTotal=rAmount+rInsurarAmount+rExtraInsurarAmount;
	                if(prestation!=null && prestation.getReferenceObject()!=null && prestation.getReferenceObject().getObjectType()!=null && prestation.getReferenceObject().getObjectType().length()>0){
	                	String sCat=prestation.getReferenceObject().getObjectType();
	                    if(categories.get(sCat)==null){
	                        categories.put(sCat,new Double(rTotal));
	                    }
	                    else {
	                        categories.put(sCat,new Double(((Double)categories.get(sCat)).doubleValue()+rTotal));
	                    }
	                    if(totalcategories.get(sCat)==null){
	                        totalcategories.put(sCat,new Double(rTotal));
	                    }
	                    else {
	                        totalcategories.put(sCat,new Double(((Double)totalcategories.get(sCat)).doubleValue()+rTotal));
	                    }
	                }
	                else {
	                    if(categories.get("OTHER")==null){
	                        categories.put("OTHER",new Double(rTotal));
	                    }
	                    else {
	                        categories.put("OTHER",new Double(((Double)categories.get("OTHER")).doubleValue()+rTotal));
	                    }
	                    if(totalcategories.get("OTHER")==null){
	                        totalcategories.put("OTHER",new Double(rTotal));
	                    }
	                    else {
	                        totalcategories.put("OTHER",new Double(((Double)totalcategories.get("OTHER")).doubleValue()+rTotal));
	                    }
	                }                
	                pageTotalAmount100+=rTotal;
	                pageTotalAmount85+=rAmount;
	                total100pct+=rTotal;
	                total85pct+=rAmount;
	                generaltotal100pct+=rTotal;
	                generaltotal85pct+=rAmount;
	                daytotal100pct+=rTotal;
	                daytotal85pct+=rAmount;
	                prevdate = date;
	                sPrevPatientName = sPatientName;
		    	}
		    }
            table = new PdfPTable(2000);
            table.setWidthPercentage(pageWidth);
        	printDebet2(table,categories,true,prevdate,invoiceid,adherent,sPrevPatientName.split(";")[0],total100pct,total85pct,recordnumber,linecounter++,daytotal100pct,daytotal85pct,tableParent,insurarreference,service);
        	// display debet total
            table.addCell(createEmptyCell(700));
            cell = createLabelCell(getTran("web","pagesubtotalprice"),300);
            cell.setHorizontalAlignment(PdfPCell.ALIGN_RIGHT);
            cell.setPaddingRight(5);
            table.addCell(cell);

            cell = createLabelCell(priceFormatInsurar.format(pageConsultationAmount),100,7);
            cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
            cell.setVerticalAlignment(PdfPCell.ALIGN_TOP);
            cell.setBorder(PdfPCell.BOX);
            cell.setPaddingRight(5);
            table.addCell(cell);

            cell = createLabelCell(priceFormatInsurar.format(pageLabAmount),100,7);
            cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
            cell.setVerticalAlignment(PdfPCell.ALIGN_TOP);
            cell.setBorder(PdfPCell.BOX);
            cell.setPaddingRight(5);
            table.addCell(cell);

            cell = createLabelCell(priceFormatInsurar.format(pageImagingAmount),100,7);
            cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
            cell.setVerticalAlignment(PdfPCell.ALIGN_TOP);
            cell.setBorder(PdfPCell.BOX);
            cell.setPaddingRight(5);
            table.addCell(cell);

            cell = createLabelCell(priceFormatInsurar.format(pageAdmissionAmount),100,7);
            cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
            cell.setVerticalAlignment(PdfPCell.ALIGN_TOP);
            cell.setBorder(PdfPCell.BOX);
            cell.setPaddingRight(5);
            table.addCell(cell);

            cell = createLabelCell(priceFormatInsurar.format(pageDrugsAmount),100,7);
            cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
            cell.setVerticalAlignment(PdfPCell.ALIGN_TOP);
            cell.setBorder(PdfPCell.BOX);
            cell.setPaddingRight(5);
            table.addCell(cell);

            cell = createLabelCell(priceFormatInsurar.format(pageConsumablesAmount),100,7);
            cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
            cell.setVerticalAlignment(PdfPCell.ALIGN_TOP);
            cell.setBorder(PdfPCell.BOX);
            cell.setPaddingRight(5);
            table.addCell(cell);

            cell = createLabelCell(priceFormatInsurar.format(pageActsAmount),100,7);
            cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
            cell.setVerticalAlignment(PdfPCell.ALIGN_TOP);
            cell.setBorder(PdfPCell.BOX);
            cell.setPaddingRight(5);
            table.addCell(cell);

            cell = createLabelCell(priceFormatInsurar.format(pageOtherAmount),100,7);
            cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
            cell.setVerticalAlignment(PdfPCell.ALIGN_TOP);
            cell.setBorder(PdfPCell.BOX);
            cell.setPaddingRight(5);
            table.addCell(cell);
            table.addCell(createEmptyCell(200));

            
            //Nu de totalen toevoegen
            table.addCell(createEmptyCell(700));
            cell = createLabelCell(getTran("web","pagetotalprice"),300);
            cell.setHorizontalAlignment(PdfPCell.ALIGN_RIGHT);
            cell.setPaddingRight(5);
            table.addCell(cell);
            table.addCell(createEmptyCell(800));
            cell = createLabelCell(priceFormatInsurar.format(pageTotalAmount100)+" RWF",100,7);
            cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
            cell.setBorder(PdfPCell.BOX);
            cell.setPaddingRight(5);
            table.addCell(cell);
            cell = createLabelCell(priceFormatInsurar.format(pageTotalAmount85)+" RWF",100,7);
            cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
            cell.setBorder(PdfPCell.BOX);
            cell.setPaddingRight(5);
            table.addCell(cell);
            cell=new PdfPCell(table);
            cell.setPadding(0);
            tableParent.addCell(createCell(cell,1,PdfPCell.ALIGN_LEFT,PdfPCell.NO_BORDER));

            table = new PdfPTable(2000);
            cell = createLabelCell("",2000);
            cell.setBorder(PdfPCell.BOTTOM);
            table.addCell(cell);
            
            // display debet total
            table.addCell(createEmptyCell(700));
            cell = createLabelCell(getTran("web","subtotalprice"),300);
            cell.setHorizontalAlignment(PdfPCell.ALIGN_RIGHT);
            cell.setPaddingRight(5);
            table.addCell(cell);

            Double amount = (Double)totalcategories.get(MedwanQuery.getInstance().getConfigString("CTAMSconsultationCategory","Co"));
            cell = createLabelCell(amount==null?"":priceFormatInsurar.format(amount),100,7);
            cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
            cell.setVerticalAlignment(PdfPCell.ALIGN_TOP);
            cell.setBorder(PdfPCell.BOX);
            cell.setPaddingRight(5);
            table.addCell(cell);

            amount = (Double)totalcategories.get(MedwanQuery.getInstance().getConfigString("CTAMSlabCategory","L"));
            cell = createLabelCell(amount==null?"":priceFormatInsurar.format(amount),100,7);
            cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
            cell.setVerticalAlignment(PdfPCell.ALIGN_TOP);
            cell.setBorder(PdfPCell.BOX);
            cell.setPaddingRight(5);
            table.addCell(cell);

            amount = (Double)totalcategories.get(MedwanQuery.getInstance().getConfigString("CTAMSimagingCategory","R"));
            cell = createLabelCell(amount==null?"":priceFormatInsurar.format(amount),100,7);
            cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
            cell.setVerticalAlignment(PdfPCell.ALIGN_TOP);
            cell.setBorder(PdfPCell.BOX);
            cell.setPaddingRight(5);
            table.addCell(cell);

            amount = (Double)totalcategories.get(MedwanQuery.getInstance().getConfigString("CTAMSadmissionCategory","S"));
            cell = createLabelCell(amount==null?"":priceFormatInsurar.format(amount),100,7);
            cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
            cell.setVerticalAlignment(PdfPCell.ALIGN_TOP);
            cell.setBorder(PdfPCell.BOX);
            cell.setPaddingRight(5);
            table.addCell(cell);

            amount = (Double)totalcategories.get(MedwanQuery.getInstance().getConfigString("CTAMSdrugsCategory","M"));
            cell = createLabelCell(amount==null?"":priceFormatInsurar.format(amount),100,7);
            cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
            cell.setVerticalAlignment(PdfPCell.ALIGN_TOP);
            cell.setBorder(PdfPCell.BOX);
            cell.setPaddingRight(5);
            table.addCell(cell);

            amount = (Double)totalcategories.get(MedwanQuery.getInstance().getConfigString("CTAMSconsumablesCategory","C"));
            cell = createLabelCell(amount==null?"":priceFormatInsurar.format(amount),100,7);
            cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
            cell.setVerticalAlignment(PdfPCell.ALIGN_TOP);
            cell.setBorder(PdfPCell.BOX);
            cell.setPaddingRight(5);
            table.addCell(cell);

            amount = (Double)totalcategories.get(MedwanQuery.getInstance().getConfigString("CTAMSactsCategory","A"));
            cell = createLabelCell(amount==null?"":priceFormatInsurar.format(amount),100,7);
            cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
            cell.setVerticalAlignment(PdfPCell.ALIGN_TOP);
            cell.setBorder(PdfPCell.BOX);
            cell.setPaddingRight(5);
            table.addCell(cell);

            double otherprice=0;
            String allcats=	"*"+MedwanQuery.getInstance().getConfigString("CTAMSconsultationCategory","Co")+
    						"*"+MedwanQuery.getInstance().getConfigString("CTAMSlabCategory","L")+
    						"*"+MedwanQuery.getInstance().getConfigString("CTAMSimagingCategory","R")+
    						"*"+MedwanQuery.getInstance().getConfigString("CTAMSadmissionCategory","S")+
    						"*"+MedwanQuery.getInstance().getConfigString("CTAMSactsCategory","A")+
    						"*"+MedwanQuery.getInstance().getConfigString("CTAMSconsumablesCategory","C")+
    						"*"+MedwanQuery.getInstance().getConfigString("CTAMSdrugsCategory","M")+"*";
            Iterator iterator = totalcategories.keySet().iterator();
            while (iterator.hasNext()){
            	String cat = (String)iterator.next();
            	if(allcats.indexOf("*"+cat+"*")<0){
            		otherprice+=((Double)totalcategories.get(cat)).doubleValue();
            	}
            }
            cell = createLabelCell(otherprice==0?"":priceFormatInsurar.format(otherprice),100,7);
            cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
            cell.setVerticalAlignment(PdfPCell.ALIGN_TOP);
            cell.setBorder(PdfPCell.BOX);
            cell.setPaddingRight(5);
            table.addCell(cell);
            table.addCell(createEmptyCell(200));

            
            //Nu de totalen toevoegen
            table.addCell(createEmptyCell(700));
            cell = createLabelCell(getTran("web","totalprice"),300);
            cell.setHorizontalAlignment(PdfPCell.ALIGN_RIGHT);
            cell.setPaddingRight(5);
            table.addCell(cell);
            table.addCell(createEmptyCell(800));
            cell = createLabelCell(priceFormatInsurar.format(generaltotal100pct)+" RWF",100,7);
            cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
            cell.setBorder(PdfPCell.BOX);
            cell.setPaddingRight(5);
            table.addCell(cell);
            cell = createLabelCell(priceFormatInsurar.format(generaltotal85pct)+" RWF",100,7);
            cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
            cell.setBorder(PdfPCell.BOX);
            cell.setPaddingRight(5);
            table.addCell(cell);

            cell=new PdfPCell(table);
            cell.setPadding(0);
            tableParent.addCell(createCell(cell,1,PdfPCell.ALIGN_LEFT,PdfPCell.NO_BORDER));
            doc.add(tableParent);
        }
    }

    //--- PRINT DEBET (prestation) ----------------------------------------------------------------
    private void printDebet2(PdfPTable invoiceTable, SortedMap categories, boolean displayDate, Date date, String invoiceid,String adherent,String beneficiary,double total100pct,double total85pct,String recordnumber,int linecounter,double daytotal100pct,double daytotal85pct,PdfPTable tableParent,String insurarreference,String service){
    	cell = createLabelCell(linecounter+"",70,7);
        cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
        cell.setVerticalAlignment(PdfPCell.ALIGN_TOP);
        cell.setBorder(PdfPCell.BOX);
        cell.setPaddingRight(5);
        invoiceTable.addCell(cell);
        cell = createLabelCell(new SimpleDateFormat("dd/MM/yyyy").format(date),120,7);
        cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
        cell.setVerticalAlignment(PdfPCell.ALIGN_TOP);
        cell.setBorder(PdfPCell.BOX);
        cell.setPaddingRight(5);
        invoiceTable.addCell(cell);
        cell = createLabelCell(invoiceid,100,7);
        cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
        cell.setVerticalAlignment(PdfPCell.ALIGN_TOP);
        cell.setBorder(PdfPCell.BOX);
        cell.setPaddingRight(5);
        invoiceTable.addCell(cell);
        cell = createLabelCell(recordnumber,120,7);
        cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
        cell.setVerticalAlignment(PdfPCell.ALIGN_TOP);
        cell.setBorder(PdfPCell.BOX);
        cell.setPaddingRight(5);
        invoiceTable.addCell(cell);
        cell = createLabelCell(beneficiary,350,7);
        cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
        cell.setVerticalAlignment(PdfPCell.ALIGN_TOP);
        cell.setBorder(PdfPCell.BOX);
        cell.setPaddingRight(5);
        invoiceTable.addCell(cell);
        cell = createLabelCell(service,240,7);
        cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
        cell.setVerticalAlignment(PdfPCell.ALIGN_TOP);
        cell.setBorder(PdfPCell.BOX);
        cell.setPaddingRight(5);
        invoiceTable.addCell(cell);

        Double amount = (Double)categories.get(MedwanQuery.getInstance().getConfigString("CTAMSconsultationCategory","Co"));
        pageConsultationAmount+=amount==null?0:amount.doubleValue();
        cell = createLabelCell(amount==null?"":priceFormatInsurar.format(amount),100,7);
        cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
        cell.setVerticalAlignment(PdfPCell.ALIGN_TOP);
        cell.setBorder(PdfPCell.BOX);
        cell.setPaddingRight(5);
        invoiceTable.addCell(cell);

        amount = (Double)categories.get(MedwanQuery.getInstance().getConfigString("CTAMSlabCategory","L"));
        pageLabAmount+=amount==null?0:amount.doubleValue();
        cell = createLabelCell(amount==null?"":priceFormatInsurar.format(amount),100,7);
        cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
        cell.setVerticalAlignment(PdfPCell.ALIGN_TOP);
        cell.setBorder(PdfPCell.BOX);
        cell.setPaddingRight(5);
        invoiceTable.addCell(cell);

        amount = (Double)categories.get(MedwanQuery.getInstance().getConfigString("CTAMSimagingCategory","R"));
        pageImagingAmount+=amount==null?0:amount.doubleValue();
        cell = createLabelCell(amount==null?"":priceFormatInsurar.format(amount),100,7);
        cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
        cell.setVerticalAlignment(PdfPCell.ALIGN_TOP);
        cell.setBorder(PdfPCell.BOX);
        cell.setPaddingRight(5);
        invoiceTable.addCell(cell);

        amount = (Double)categories.get(MedwanQuery.getInstance().getConfigString("CTAMSadmissionCategory","S"));
        pageAdmissionAmount+=amount==null?0:amount.doubleValue();
        cell = createLabelCell(amount==null?"":priceFormatInsurar.format(amount),100,7);
        cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
        cell.setVerticalAlignment(PdfPCell.ALIGN_TOP);
        cell.setBorder(PdfPCell.BOX);
        cell.setPaddingRight(5);
        invoiceTable.addCell(cell);

        amount = (Double)categories.get(MedwanQuery.getInstance().getConfigString("CTAMSdrugsCategory","M"));
        pageDrugsAmount+=amount==null?0:amount.doubleValue();
        cell = createLabelCell(amount==null?"":priceFormatInsurar.format(amount),100,7);
        cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
        cell.setVerticalAlignment(PdfPCell.ALIGN_TOP);
        cell.setBorder(PdfPCell.BOX);
        cell.setPaddingRight(5);
        invoiceTable.addCell(cell);

        amount = (Double)categories.get(MedwanQuery.getInstance().getConfigString("CTAMSconsumablesCategory","C"));
        pageConsumablesAmount+=amount==null?0:amount.doubleValue();
        cell = createLabelCell(amount==null?"":priceFormatInsurar.format(amount),100,7);
        cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
        cell.setVerticalAlignment(PdfPCell.ALIGN_TOP);
        cell.setBorder(PdfPCell.BOX);
        cell.setPaddingRight(5);
        invoiceTable.addCell(cell);

        amount = (Double)categories.get(MedwanQuery.getInstance().getConfigString("CTAMSactsCategory","A"));
        pageActsAmount+=amount==null?0:amount.doubleValue();
        cell = createLabelCell(amount==null?"":priceFormatInsurar.format(amount),100,7);
        cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
        cell.setVerticalAlignment(PdfPCell.ALIGN_TOP);
        cell.setBorder(PdfPCell.BOX);
        cell.setPaddingRight(5);
        invoiceTable.addCell(cell);

        double otherprice=0;
        String allcats=	"*"+MedwanQuery.getInstance().getConfigString("CTAMSconsultationCategory","Co")+
						"*"+MedwanQuery.getInstance().getConfigString("CTAMSlabCategory","L")+
						"*"+MedwanQuery.getInstance().getConfigString("CTAMSimagingCategory","R")+
						"*"+MedwanQuery.getInstance().getConfigString("CTAMSadmissionCategory","S")+
						"*"+MedwanQuery.getInstance().getConfigString("CTAMSactsCategory","A")+
						"*"+MedwanQuery.getInstance().getConfigString("CTAMSconsumablesCategory","C")+
						"*"+MedwanQuery.getInstance().getConfigString("CTAMSdrugsCategory","M")+"*";
        Iterator iterator = categories.keySet().iterator();
        while (iterator.hasNext()){
        	String cat = (String)iterator.next();
        	if(allcats.indexOf("*"+cat+"*")<0){
        		otherprice+=((Double)categories.get(cat)).doubleValue();
        	}
        }
        pageOtherAmount+=otherprice;
        cell = createLabelCell(otherprice==0?"":priceFormatInsurar.format(otherprice),100,7);
        cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
        cell.setVerticalAlignment(PdfPCell.ALIGN_TOP);
        cell.setBorder(PdfPCell.BOX);
        cell.setPaddingRight(5);
        invoiceTable.addCell(cell);

        cell = createLabelCell(priceFormatInsurar.format(total100pct),100,7);
        cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
        cell.setVerticalAlignment(PdfPCell.ALIGN_TOP);
        cell.setBorder(PdfPCell.BOX);
        cell.setPaddingRight(5);
        invoiceTable.addCell(cell);
        cell = createLabelCell(priceFormatInsurar.format(total85pct),100,7);
        cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
        cell.setVerticalAlignment(PdfPCell.ALIGN_TOP);
        cell.setBorder(PdfPCell.BOX);
        cell.setPaddingRight(5);
        invoiceTable.addCell(cell);
    }
    
    private PdfPTable getTableHeader(Insurar insurar){
        PdfPTable table = new PdfPTable(2000);
        table.setWidthPercentage(pageWidth);
        // header
        cell = createUnderlinedCell("#\n ",1,7);
        PdfPTable singleCellHeaderTable = new PdfPTable(1);
        singleCellHeaderTable.addCell(cell);
        cell = createCell(new PdfPCell(singleCellHeaderTable),70,PdfPCell.ALIGN_LEFT,PdfPCell.NO_BORDER);
        cell.setPaddingRight(2);
        table.addCell(cell);

        cell = createUnderlinedCell(getTran("web","date")+"\n ",1,7);
        singleCellHeaderTable = new PdfPTable(1);
        singleCellHeaderTable.addCell(cell);
        cell = createCell(new PdfPCell(singleCellHeaderTable),120,PdfPCell.ALIGN_LEFT,PdfPCell.NO_BORDER);
        cell.setPaddingRight(2);
        table.addCell(cell);

        cell = createUnderlinedCell(getTran("web","fac")+"\n ",1,7);
        singleCellHeaderTable = new PdfPTable(1);
        singleCellHeaderTable.addCell(cell);
        cell = createCell(new PdfPCell(singleCellHeaderTable),100,PdfPCell.ALIGN_LEFT,PdfPCell.NO_BORDER);
        cell.setPaddingRight(2);
        table.addCell(cell);

        cell = createUnderlinedCell(getTran("web","numero_affiliation")+"\n ",1,7);
        singleCellHeaderTable = new PdfPTable(1);
        singleCellHeaderTable.addCell(cell);
        cell = createCell(new PdfPCell(singleCellHeaderTable),120,PdfPCell.ALIGN_LEFT,PdfPCell.NO_BORDER);
        cell.setPaddingRight(2);
        table.addCell(cell);

        cell = createUnderlinedCell(getTran("web","beneficiary")+"\n ",1,7);
        singleCellHeaderTable = new PdfPTable(1);
        singleCellHeaderTable.addCell(cell);
        cell = createCell(new PdfPCell(singleCellHeaderTable),350,PdfPCell.ALIGN_LEFT,PdfPCell.NO_BORDER);
        cell.setPaddingRight(2);
        table.addCell(cell);

        cell = createUnderlinedCell(getTran("web","service")+"\n ",1,7);
        singleCellHeaderTable = new PdfPTable(1);
        singleCellHeaderTable.addCell(cell);
        cell = createCell(new PdfPCell(singleCellHeaderTable),240,PdfPCell.ALIGN_LEFT,PdfPCell.NO_BORDER);
        cell.setPaddingRight(2);
        table.addCell(cell);

        cell = createUnderlinedCell("CONS\n100%",1,7);
        cell.setHorizontalAlignment(PdfPCell.ALIGN_CENTER);
        singleCellHeaderTable = new PdfPTable(1);
        singleCellHeaderTable.addCell(cell);
        cell = createCell(new PdfPCell(singleCellHeaderTable),100,PdfPCell.ALIGN_CENTER,PdfPCell.NO_BORDER);
        table.addCell(cell);

        cell = createUnderlinedCell("LAB\n100%",1,7);
        cell.setHorizontalAlignment(PdfPCell.ALIGN_CENTER);
        singleCellHeaderTable = new PdfPTable(1);
        singleCellHeaderTable.addCell(cell);
        cell = createCell(new PdfPCell(singleCellHeaderTable),100,PdfPCell.ALIGN_CENTER,PdfPCell.NO_BORDER);
        table.addCell(cell);

        cell = createUnderlinedCell("IMA\n100%",1,7);
        cell.setHorizontalAlignment(PdfPCell.ALIGN_CENTER);
        singleCellHeaderTable = new PdfPTable(1);
        singleCellHeaderTable.addCell(cell);
        cell = createCell(new PdfPCell(singleCellHeaderTable),100,PdfPCell.ALIGN_CENTER,PdfPCell.NO_BORDER);
        table.addCell(cell);

        cell = createUnderlinedCell("HOS\n100%",1,7);
        cell.setHorizontalAlignment(PdfPCell.ALIGN_CENTER);
        singleCellHeaderTable = new PdfPTable(1);
        singleCellHeaderTable.addCell(cell);
        cell = createCell(new PdfPCell(singleCellHeaderTable),100,PdfPCell.ALIGN_CENTER,PdfPCell.NO_BORDER);
        table.addCell(cell);

        cell = createUnderlinedCell("MED\n100%",1,7);
        cell.setHorizontalAlignment(PdfPCell.ALIGN_CENTER);
        singleCellHeaderTable = new PdfPTable(1);
        singleCellHeaderTable.addCell(cell);
        cell = createCell(new PdfPCell(singleCellHeaderTable),100,PdfPCell.ALIGN_CENTER,PdfPCell.NO_BORDER);
        table.addCell(cell);

        cell = createUnderlinedCell("CONSOM\n100%",1,7);
        cell.setHorizontalAlignment(PdfPCell.ALIGN_CENTER);
        singleCellHeaderTable = new PdfPTable(1);
        singleCellHeaderTable.addCell(cell);
        cell = createCell(new PdfPCell(singleCellHeaderTable),100,PdfPCell.ALIGN_CENTER,PdfPCell.NO_BORDER);
        table.addCell(cell);

        cell = createUnderlinedCell("ACT\n100%",1,7);
        cell.setHorizontalAlignment(PdfPCell.ALIGN_CENTER);
        singleCellHeaderTable = new PdfPTable(1);
        singleCellHeaderTable.addCell(cell);
        cell = createCell(new PdfPCell(singleCellHeaderTable),100,PdfPCell.ALIGN_CENTER,PdfPCell.NO_BORDER);
        table.addCell(cell);

        cell = createUnderlinedCell("AUTR\n100%",1,7);
        cell.setHorizontalAlignment(PdfPCell.ALIGN_CENTER);
        singleCellHeaderTable = new PdfPTable(1);
        singleCellHeaderTable.addCell(cell);
        cell = createCell(new PdfPCell(singleCellHeaderTable),100,PdfPCell.ALIGN_CENTER,PdfPCell.NO_BORDER);
        table.addCell(cell);

        cell = createUnderlinedCell("TOT\n100%",1,7);
        cell.setHorizontalAlignment(PdfPCell.ALIGN_CENTER);
        singleCellHeaderTable = new PdfPTable(1);
        singleCellHeaderTable.addCell(cell);
        cell = createCell(new PdfPCell(singleCellHeaderTable),100,PdfPCell.ALIGN_CENTER,PdfPCell.NO_BORDER);
        table.addCell(cell);

        cell = createUnderlinedCell("TOT\nx%",1,7);
        cell.setHorizontalAlignment(PdfPCell.ALIGN_CENTER);
        singleCellHeaderTable = new PdfPTable(1);
        singleCellHeaderTable.addCell(cell);
        cell = createCell(new PdfPCell(singleCellHeaderTable),100,PdfPCell.ALIGN_CENTER,PdfPCell.NO_BORDER);
        table.addCell(cell);

        return table;
    }
}