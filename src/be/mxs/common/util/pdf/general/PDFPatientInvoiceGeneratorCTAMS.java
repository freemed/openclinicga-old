package be.mxs.common.util.pdf.general;

import com.itextpdf.text.pdf.*;
import com.itextpdf.text.*;

import java.util.*;
import java.io.ByteArrayOutputStream;
import java.text.DecimalFormat;
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

import org.hnrw.report.Report_Identification;

public class PDFPatientInvoiceGeneratorCTAMS extends PDFInvoiceGenerator {
    String sProforma = "no";

    //--- CONSTRUCTOR -----------------------------------------------------------------------------
    public PDFPatientInvoiceGeneratorCTAMS(User user, AdminPerson patient, String sProject, String sPrintLanguage, String proforma){
        this.user = user;
        this.patient = patient;
        this.sProject = sProject;
        this.sPrintLanguage = sPrintLanguage;
        this.sProforma = proforma;

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
			doc.setPageSize(PageSize.A4);
            addFooter();

            doc.open();

            // get specified invoice
            PatientInvoice invoice = PatientInvoice.get(sInvoiceUid);

            //We want to print an invoice for every insurance involved
            //First make a list of the insurances
            Hashtable insurers = new Hashtable();
            Vector allDebets = new Vector();
            Vector debets = invoice.getDebets();
            for(int n=0;n<debets.size();n++){
            	Debet debet = (Debet)debets.elementAt(n);
            	allDebets.add(debet);
            	if(debet.getInsuranceUid()!=null){
            		insurers.put(debet.getInsuranceUid(), "1");
            	}
            	else {
            		insurers.put("?", "1");
            	}
            }
            Enumeration eInsurers = insurers.keys();
            boolean bInitialized=false;
            while(eInsurers.hasMoreElements()){
            	if(bInitialized){
            		doc.newPage();
            	}
            	else {
            		bInitialized=true;
            	}
            	String insuranceUid=(String)eInsurers.nextElement();
            	//We only select the debets of this insurance;
            	debets = new Vector();
            	for(int n=0;n<allDebets.size();n++){
            		Debet debet = (Debet)allDebets.elementAt(n);
            		if(debet.getInsuranceUid()!=null && debet.getInsuranceUid().equalsIgnoreCase(insuranceUid)){
            			debets.add(debet);
            		}
            		else if(insuranceUid.equalsIgnoreCase("?") && debet.getInsuranceUid()==null){
            			debets.add(debet);
            		}
            	}
            	Insurance insurance = new Insurance();
            	if(!insuranceUid.equalsIgnoreCase("?")){
            		insurance = Insurance.get(insuranceUid);
            	}
            	invoice.setDebets(debets);
	            addReceipt(invoice);
	            addHeading(invoice);
	            addPatientData(invoice,insurance);
	            printInvoice(invoice);
            }
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

    //---- ADD RECEIPT ----------------------------------------------------------------------------
    private void addReceipt(PatientInvoice invoice) throws DocumentException {
        PdfPTable receiptTable = new PdfPTable(50);
        receiptTable.setWidthPercentage(pageWidth);

        // logo
        try{
            Image img = Miscelaneous.getImage("logo_"+sProject+".gif",sProject);
            if(img==null){
                cell = createEmptyCell(10);
                receiptTable.addCell(cell);
            }
            else {
                img.scaleToFit(75,75);
                cell = new PdfPCell(img);
                cell.setBorder(PdfPCell.NO_BORDER);
                cell.setColspan(10);
                receiptTable.addCell(cell);
            }
        }
        catch (Exception e){
            System.out.println("WARNING : PDFPatientInvoiceGenerator --> IMAGE NOT FOUND : logo_"+sProject+".gif");
            e.printStackTrace();
        }

        table = new PdfPTable(5);
        table.setWidthPercentage(100);
        table.addCell(createGrayCell(getTran("web","receiptforinvoice").toUpperCase()+" #"+(sProforma.equalsIgnoreCase("yes")?"PROFORMA":invoice.getInvoiceNumber())+" - "+new SimpleDateFormat("dd/MM/yyyy").format(invoice.getDate()),5,10,Font.BOLD));
        table.addCell(createValueCell(getTran("web","receivedfrom")+": "+patient.lastname.toUpperCase()+" "+patient.firstname+" ("+patient.personid+")",3,8,Font.NORMAL));
        table.addCell(createValueCell(patient.dateOfBirth,1,8,Font.NORMAL));
        table.addCell(createValueCell(patient.gender,1,8,Font.NORMAL));
        if(invoice.getInvoiceNumber().equalsIgnoreCase(invoice.getInvoiceUid())){
        	table.addCell(createEmptyCell(3));
        }
        else {
            table.addCell(createValueCell(getTran("web.occup","medwan.common.reference")+": "+invoice.getInvoiceUid(),1,8,Font.NORMAL));
        	table.addCell(createEmptyCell(2));
        }
        table.addCell(createValueCell(getTran("web","prestations"),1,8,Font.NORMAL));
        double totalDebet=0;
        double totalinsurardebet=0;
        Hashtable services = new Hashtable();
        String service="";
        for(int n=0;n<invoice.getDebets().size();n++){
            Debet debet = (Debet)invoice.getDebets().elementAt(n);
            if(debet!=null && debet.getCredited()==0){
            	if(debet.getEncounter()!=null && debet.getEncounter().getService()!=null){
            		service=debet.getEncounter().getService().getLabel(sPrintLanguage);
            	}
	            if(service!=null){
	            	services.put(service, "1");
	            }
	            totalDebet+=debet.getAmount();
	            totalinsurardebet+=debet.getInsurarAmount();
            }
        }
        table.addCell(createPriceCell(totalDebet,1));
        table.addCell(createValueCell(getTran("web","cashiersignature"),3,8,Font.NORMAL));
        table.addCell(createValueCell(getTran("web","payments"),1,8,Font.NORMAL));
        double totalCredit=0;
        for(int n=0;n<invoice.getCredits().size();n++){
            PatientCredit credit = PatientCredit.get((String)invoice.getCredits().elementAt(n));
            totalCredit+=credit.getAmount();
        }
        cell=createPriceCell(totalCredit,1);
        cell.setBorder(PdfPCell.BOTTOM);
        table.addCell(cell);
        table.addCell(createValueCell(new SimpleDateFormat("dd/MM/yyyy").format(new Date()),3,8,Font.NORMAL));
        table.addCell(createValueCell(getTran("web.finance","balance"),1,8,Font.NORMAL));
        table.addCell(createPriceCell(invoice.getBalance(),1));
        table.addCell(createEmptyCell(3));
        table.addCell(createValueCell(getTran("web","insurar"),1,8,Font.ITALIC));
        cell = new PdfPCell(new Paragraph(priceFormat.format(totalinsurardebet)+" "+sCurrency,FontFactory.getFont(FontFactory.HELVETICA,7,Font.ITALIC)));
        cell.setColspan(1);
        cell.setBorder(PdfPCell.NO_BORDER);
        cell.setVerticalAlignment(PdfPCell.ALIGN_TOP);
        cell.setHorizontalAlignment(PdfPCell.ALIGN_RIGHT);
        table.addCell(cell);
        cell = new PdfPCell(table);
        cell.setBorder(PdfPCell.NO_BORDER);
        cell.setColspan(40);
        receiptTable.addCell(cell);
        receiptTable.addCell(createEmptyCell(50));
        receiptTable.addCell(createValueCell(getTran("web","service"),10,8,Font.BOLD));
        Enumeration es = services.keys();
        int nLines=2;
        while (es.hasMoreElements()){
        	if(nLines==0){
                receiptTable.addCell(createEmptyCell(10));
                nLines=1;
        	}
        	else if(nLines==1){
        		nLines=0;
        	}
        	else {
        		nLines=1;
        	}
        	service=(String)es.nextElement();
            receiptTable.addCell(createValueCell(service,20,7,Font.NORMAL));
        }
        receiptTable.addCell(createEmptyCell(50-((services.size() % 2)*20)));
        receiptTable.addCell(createValueCell(getTran("web","prestations"),10,8,Font.BOLD));
        Vector debets = invoice.getDebets();
        nLines=2;
        for(int n=0;n<debets.size();n++){
            Debet debet = (Debet)debets.elementAt(n);
            String extraInsurar="";
            if(debet.getExtraInsurarUid()!=null && debet.getExtraInsurarUid().length()>0){
                Insurar exIns = Insurar.get(debet.getExtraInsurarUid());
                if(exIns!=null){
                    extraInsurar=" >>> "+ScreenHelper.checkString(exIns.getName());
                    if(extraInsurar.indexOf("#")>-1){
                        extraInsurar=extraInsurar.substring(0,extraInsurar.indexOf("#"));
                    }
                }
            }
        	if(nLines==0){
                receiptTable.addCell(createEmptyCell(10));
                nLines=1;
        	}
        	else if(nLines==1){
        		nLines=0;
        	}
        	else {
        		nLines=1;
        	}
            receiptTable.addCell(createValueCell(debet.getQuantity()+" x  ["+debet.getPrestation().getCode()+"] "+debet.getPrestation().getDescription()+extraInsurar,20,7,Font.NORMAL));
        }
        receiptTable.addCell(createEmptyCell(50-((debets.size() % 2)*20)));
        receiptTable.addCell(createEmptyCell(50));
        receiptTable.addCell(createCell(createValueCell(" "),50,PdfPCell.ALIGN_CENTER,PdfPCell.BOTTOM));
        receiptTable.addCell(createEmptyCell(50));
        doc.add(receiptTable);
    }

    //---- ADD HEADING (logo & barcode) -----------------------------------------------------------
    private void addHeading(PatientInvoice invoice) throws Exception {
        table = new PdfPTable(5);
        table.setWidthPercentage(pageWidth);

        try {
            //*** logo ***
            try{
                Image img = Miscelaneous.getImage("logo_"+sProject+".gif",sProject);
                img.scaleToFit(75, 75);
                cell = new PdfPCell(img);
                cell.setBorder(PdfPCell.NO_BORDER);
                cell.setColspan(1);
                table.addCell(cell);
            }
            catch(NullPointerException e){
                Debug.println("WARNING : PDFPatientInvoiceGenerator --> IMAGE NOT FOUND : logo_"+sProject+".gif");
                e.printStackTrace();
            }

            Report_Identification report_identification = new Report_Identification(invoice.getDate());
            String sHealthFacilityIdentification=getTran("web","ctams.hfident.1")+"\n";
            sHealthFacilityIdentification+=getTran("web","ctams.hfident.2")+"\n";
            sHealthFacilityIdentification+=getTran("web","ctams.hfident.3")+"\n";
            sHealthFacilityIdentification+=getTran("web","ctams.hfident.4")+"\n";
            sHealthFacilityIdentification+=getTran("web","ctams.hfident.5")+"\n";
            sHealthFacilityIdentification+=getTran("web","ctams.hfident.6");
            cell=createValueCell(sHealthFacilityIdentification,3,8,Font.BOLD);
            cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
            table.addCell(cell);
            

            if(!sProforma.equalsIgnoreCase("yes")){
                //*** barcode ***
                PdfContentByte cb = docWriter.getDirectContent();
                Barcode39 barcode39 = new Barcode39();
                barcode39.setCode("7"+invoice.getInvoiceUid());
                Image image = barcode39.createImageWithBarcode(cb,null,null);
                cell = new PdfPCell(image);
                cell.setHorizontalAlignment(PdfPCell.ALIGN_RIGHT);
                cell.setBorder(PdfPCell.NO_BORDER);
                cell.setColspan(1);
            }
            else {
                cell = createEmptyCell(1);
            }
            table.addCell(cell);
            doc.add(table);
            addBlankRow();

            table = new PdfPTable(5);
            table.setWidthPercentage(pageWidth);

            //*** title ***
            table.addCell(createTitleCell(getTran("web","ctams.invoice").toUpperCase()+" #"+(sProforma.equalsIgnoreCase("yes")?"PROFORMA":invoice.getInvoiceUid())+" - "+new SimpleDateFormat("dd/MM/yyyy").format(invoice.getDate()),"",5));


            doc.add(table);
            addBlankRow();
            addBlankRow();
        }
        catch(Exception e){
            e.printStackTrace();
        }
    }

    //--- ADD PATIENT DATA ------------------------------------------------------------------------
    private void addPatientData(PatientInvoice invoice,Insurance ins){
        PdfPTable table = new PdfPTable(100);
        table.setWidthPercentage(pageWidth);
        try{
        	AdminPerson person = invoice.getPatient();
        	String allInsurers="",allInsurarNumbers="";
    		allInsurers=ins!=null && ins.getInsurar()!=null?ins.getInsurar().getName():"?";
   			allInsurarNumbers=ins!=null?ins.getInsuranceNr():"";
        	//Find encounters
        	Hashtable encounters = new Hashtable();
        	Vector debets = invoice.getDebets();
        	for(int n=0;n<debets.size();n++){
        		Debet debet = (Debet)debets.elementAt(n);
        		if(encounters.get(debet.getEncounterUid())==null){
        			encounters.put(debet.getEncounterUid(), debet.getEncounter());
        		}
        	}
        	if(person!=null){
	        	cell=createLabelCell(getTran("web","ctams.insurername"),15);
	        	table.addCell(cell);
	        	cell=createBoldLabelCell(allInsurers,85);
	        	table.addCell(cell);
	        	cell=createLabelCell(getTran("web","ctams.cardnumber"),15);
	        	table.addCell(cell);
	        	cell=createBoldLabelCell(allInsurarNumbers,15);
	        	table.addCell(cell);
	        	cell=createLabelCell(getTran("web","ctams.beneficiary"),20);
	        	table.addCell(cell);
	        	cell=createBoldLabelCell(person.lastname.toUpperCase()+", "+person.firstname,50);
	        	table.addCell(cell);
	        	
	        	cell=createLabelCell(getTran("web","ctams.dateofbirth"),15);
	        	table.addCell(cell);
	        	cell=createBoldLabelCell(person.dateOfBirth,15);
	        	table.addCell(cell);
	        	cell=createLabelCell(getTran("web","ctams.gender"),20);
	        	table.addCell(cell);
	        	cell=createBoldLabelCell(person.gender,50);
	        	table.addCell(cell);
	        	
	        	cell=createLabelCell(getTran("web","ctams.recordnumber"),15);
	        	table.addCell(cell);
	        	cell=createBoldLabelCell(person.personid,15);
	        	table.addCell(cell);
	        	cell=createLabelCell(getTran("web","ctams.bed"),20);
	        	table.addCell(cell);
	        	String beds="";
	        	Enumeration eEncounters = encounters.elements();
	        	while(eEncounters.hasMoreElements()){
	        		Encounter encounter = (Encounter)eEncounters.nextElement();
	        		if(encounter!=null && encounter.getBed()!=null && encounter.getBed().getName()!=null && beds.indexOf(encounter.getBed().getName())<0){
	        			if(beds.length()>0){
	        				beds+=", ";
	        			}
	        			beds+=encounter.getBed().getName();
	        		}
	        	}
	        	cell=createBoldLabelCell(beds,15);
	        	table.addCell(cell);
	        	cell=createLabelCell(getTran("web","ctams.service"),15);
	        	table.addCell(cell);
	        	String services="";
	        	eEncounters = encounters.elements();
	        	while(eEncounters.hasMoreElements()){
	        		Encounter encounter = (Encounter)eEncounters.nextElement();
	        		if(encounter!=null && encounter.getService()!=null && encounter.getService().getLabel(user.person.language)!=null && services.indexOf(encounter.getService().getLabel(user.person.language))<0){
	        			if(services.length()>0){
	        				services+=", ";
	        			}
	        			services+=encounter.getService().getLabel(user.person.language);
	        		}
	        	}
	        	cell=createBoldLabelCell(services,20);
	        	table.addCell(cell);
	        	
	        	cell=createLabelCell(getTran("web","ctams.transferred.by"),30);
	        	table.addCell(cell);
	        	cell=createLabelCell(getTran("web","ctams.entry"),20);
	        	table.addCell(cell);
	        	String entry="", exit="";
	        	eEncounters = encounters.elements();
	        	while(eEncounters.hasMoreElements()){
	        		Encounter encounter = (Encounter)eEncounters.nextElement();
	        		if(encounter!=null && encounter.getBegin()!=null && entry.indexOf(new SimpleDateFormat("dd/MM/yyyy").format(encounter.getBegin()))<0){
	        			if(entry.length()>0){
	        				entry+=", ";
	        			}
	        			entry+=new SimpleDateFormat("dd/MM/yyyy").format(encounter.getBegin());
	        		}
	        		if(encounter!=null && encounter.getEnd()!=null && exit.indexOf(new SimpleDateFormat("dd/MM/yyyy").format(encounter.getEnd()))<0){
	        			if(exit.length()>0){
	        				exit+=", ";
	        			}
	        			exit+=new SimpleDateFormat("dd/MM/yyyy").format(encounter.getEnd());
	        		}
	        	}
	        	cell=createBoldLabelCell(entry,15);
	        	table.addCell(cell);
	        	cell=createLabelCell(getTran("web","ctams.exit"),15);
	        	table.addCell(cell);
	        	cell=createBoldLabelCell(exit,20);
	        	table.addCell(cell);

	        	cell=createLabelCell(getTran("web","ctams.ambulatory"),15);
	        	table.addCell(cell);
	        	eEncounters = encounters.elements();
	        	String ambulatory=getTran("web","no");
	        	String categories="";
	        	while(eEncounters.hasMoreElements()){
	        		Encounter encounter = (Encounter)eEncounters.nextElement();
	        		if(encounter.getCategories()!=null && categories.indexOf(encounter.getCategories())<0){
	        			categories+=encounter.getCategories();
	        		}
	        		if(encounter!=null && encounter.getType().equalsIgnoreCase("visit")){
	        			ambulatory=getTran("web","yes");
	        			break;
	        		}
	        	}
	        	cell=createBoldLabelCell(ambulatory,85);
	        	table.addCell(cell);

	        	cell=createLabelCell(getTran("web","ctams.diseasetype"),15);
	        	table.addCell(cell);
	        	cell=createLabelCell(getTran("web","ctams.disease.natural"),17);
	        	cell.setHorizontalAlignment(PdfPCell.ALIGN_CENTER);
	        	table.addCell(cell);
	        	cell=createLabelCell(getTran("web","ctams.disease.professional"),17);
	        	cell.setHorizontalAlignment(PdfPCell.ALIGN_CENTER);
	        	table.addCell(cell);
	        	cell=createLabelCell(getTran("web","ctams.disease.traffic"),17);
	        	cell.setHorizontalAlignment(PdfPCell.ALIGN_CENTER);
	        	table.addCell(cell);
	        	cell=createLabelCell(getTran("web","ctams.disease.occupational"),17);
	        	cell.setHorizontalAlignment(PdfPCell.ALIGN_CENTER);
	        	table.addCell(cell);
	        	cell=createLabelCell(getTran("web","ctams.disease.other"),17);
	        	cell.setHorizontalAlignment(PdfPCell.ALIGN_CENTER);
	        	table.addCell(cell);
	        	
	        	cell=createLabelCell("",15);
	        	table.addCell(cell);
	        	cell=createLabelCell("",2);
	        	table.addCell(cell);
	        	cell=createBoldLabelCell(categories.indexOf("A")<0?"\n":"X",13);
	        	cell.setHorizontalAlignment(PdfPCell.ALIGN_CENTER);
	        	cell.setBorder(PdfPCell.BOX);
	        	table.addCell(cell);
	        	cell=createLabelCell("",2);
	        	table.addCell(cell);
	        	cell=createLabelCell("",2);
	        	table.addCell(cell);
	        	cell=createBoldLabelCell(categories.indexOf("B")<0?"\n":"X",13);
	        	cell.setHorizontalAlignment(PdfPCell.ALIGN_CENTER);
	        	cell.setBorder(PdfPCell.BOX);
	        	table.addCell(cell);
	        	cell=createLabelCell("",2);
	        	table.addCell(cell);
	        	cell=createLabelCell("",2);
	        	table.addCell(cell);
	        	cell=createBoldLabelCell(categories.indexOf("D")<0?"\n":"X",13);
	        	cell.setHorizontalAlignment(PdfPCell.ALIGN_CENTER);
	        	cell.setBorder(PdfPCell.BOX);
	        	table.addCell(cell);
	        	cell=createLabelCell("",2);
	        	table.addCell(cell);
	        	cell=createLabelCell("",2);
	        	table.addCell(cell);
	        	cell=createBoldLabelCell(categories.indexOf("C")<0?"\n":"X",13);
	        	cell.setHorizontalAlignment(PdfPCell.ALIGN_CENTER);
	        	cell.setBorder(PdfPCell.BOX);
	        	table.addCell(cell);
	        	cell=createLabelCell("",2);
	        	table.addCell(cell);
	        	cell=createLabelCell("",2);
	        	table.addCell(cell);
	        	cell=createBoldLabelCell(categories.indexOf("E")<0?"\n":"X",13);
	        	cell.setHorizontalAlignment(PdfPCell.ALIGN_CENTER);
	        	cell.setBorder(PdfPCell.BOX);
	        	table.addCell(cell);
	        	cell=createLabelCell("",2);
	        	table.addCell(cell);
	        	
	        	
	        	doc.add(table);
        	}
        }
        catch(Exception e){
            e.printStackTrace();
        }
    }

    //--- ADD INSURANCE DATA ----------------------------------------------------------------------
    private void addInsuranceData(Insurance insurance){
        try {
            if(insurance!=null){
                InsuranceCategory insuranceCat = insurance.getInsuranceCategory();
                if(insuranceCat!=null){
                    Insurar insurar = insuranceCat.getInsurar();
                    if(!insurar.getUid().equals(getConfigString("patientSelfInsurarUID"))){
                        PdfPTable table = new PdfPTable(1);
                        table.setWidthPercentage(pageWidth);

                        PdfPTable insuranceTable = new PdfPTable(1);
                        insuranceTable.addCell(createGrayCell(getTran("web","insurancyData").toUpperCase(),1));
                        cell = new PdfPCell(getInsuranceData(insurance));
                        cell.setPadding(cellPadding);
                        insuranceTable.addCell(createCell(cell,1,PdfPCell.ALIGN_LEFT,PdfPCell.BOX));
                        table.addCell(createCell(new PdfPCell(insuranceTable),1,PdfPCell.ALIGN_CENTER,PdfPCell.NO_BORDER));
                        table.addCell(createEmptyCell(1));

                        doc.add(table);
                    }
                }
            }
        }
        catch(Exception e){
            e.printStackTrace();
        }
    }

    //--- PRINT INVOICE ---------------------------------------------------------------------------
    private void printDebets(PatientInvoice invoice,Vector debets){
        try{
            PdfPTable table = new PdfPTable(1);
            table.setWidthPercentage(pageWidth);

            // debets
            table.addCell(createGrayCell(getTran("web","invoiceDebets").toUpperCase(),1));
            getDebets(invoice,table,debets);
            table.addCell(createEmptyCell(1));
            doc.add(table);
        }
        catch(Exception e){
            e.printStackTrace();
        }
    }
    private void printInvoice(PatientInvoice invoice){
        try {
            PdfPTable table = new PdfPTable(100);
            table.setWidthPercentage(pageWidth);
            
            cell=createUnderlinedCell(getTran("web","ctams.caredetail"),100,9);
            table.addCell(cell);
            
            cell=createValueCell("\n",100);
            table.addCell(cell);

            cell=createValueCell(getTran("web","date"),10);
            cell.setBorder(PdfPCell.BOX);
            table.addCell(cell);
            cell=createValueCell(getTran("web","code"),10);
            cell.setBorder(PdfPCell.BOX);
            table.addCell(cell);
            cell=createValueCell(getTran("web","label"),50);
            cell.setBorder(PdfPCell.BOX);
            table.addCell(cell);
            cell=createValueCell(getTran("web","quantity"),10);
            cell.setBorder(PdfPCell.BOX);
            table.addCell(cell);
            cell=createValueCell(getTran("web","up"),10);
            cell.setBorder(PdfPCell.BOX);
            table.addCell(cell);
            cell=createValueCell(getTran("web","tp"),10);
            cell.setBorder(PdfPCell.BOX);
            table.addCell(cell);
            
            cell=createValueCell("",10);
            cell.setBorder(PdfPCell.BOX);
            table.addCell(cell);
            cell=createValueCell("",10);
            cell.setBorder(PdfPCell.BOX);
            table.addCell(cell);
            cell=createBoldLabelCell(getTran("web","consultations"),80);
            cell.setBorder(PdfPCell.BOX);
            table.addCell(cell);

            Hashtable printedDebets = new Hashtable();
            Vector debets = invoice.getDebets();
            boolean bPrinted=false;
            for(int n=0;n<debets.size();n++){
            	Debet debet = (Debet)debets.elementAt(n);
            	if(debet.getPrestation()!=null){
            		if(debet.getQuantity()>0 && debet.getPrestation().getReferenceObject()!=null && debet.getPrestation().getReferenceObject().getObjectType()!=null && debet.getPrestation().getReferenceObject().getObjectType().equalsIgnoreCase(MedwanQuery.getInstance().getConfigString("CTAMSconsultationCategory","Co"))){
            			printDebet(debet,table);
            			printedDebets.put(debet.getUid(), "1");
            			bPrinted=true;
            		}
            	}
            }
            if(!bPrinted){
                cell=createValueCell("\n",10);
                cell.setBorder(PdfPCell.BOX);
                table.addCell(cell);
                cell=createValueCell("",10);
                cell.setBorder(PdfPCell.BOX);
                table.addCell(cell);
                cell=createValueCell("",50);
                cell.setBorder(PdfPCell.BOX);
                table.addCell(cell);
                cell=createValueCell("",10);
                cell.setBorder(PdfPCell.BOX);
                table.addCell(cell);
                cell=createValueCell("",10);
                cell.setBorder(PdfPCell.BOX);
                table.addCell(cell);
                cell=createValueCell("",10);
                cell.setBorder(PdfPCell.BOX);
                table.addCell(cell);
            }
            
            cell=createValueCell("",10);
            cell.setBorder(PdfPCell.BOX);
            table.addCell(cell);
            cell=createValueCell("",10);
            cell.setBorder(PdfPCell.BOX);
            table.addCell(cell);
            cell=createBoldLabelCell(getTran("web","examinations"),80);
            cell.setBorder(PdfPCell.BOX);
            table.addCell(cell);

            debets = invoice.getDebets();
            bPrinted=false;
            for(int n=0;n<debets.size();n++){
            	Debet debet = (Debet)debets.elementAt(n);
            	if(debet.getPrestation()!=null){
            		if(debet.getQuantity()>0 && debet.getPrestation().getReferenceObject()!=null && debet.getPrestation().getReferenceObject().getObjectType()!=null  && (debet.getPrestation().getReferenceObject().getObjectType().equalsIgnoreCase(MedwanQuery.getInstance().getConfigString("CTAMSlabCategory","L")) || debet.getPrestation().getReferenceObject().getObjectType().equalsIgnoreCase(MedwanQuery.getInstance().getConfigString("CTAMSimagingCategory","R")))){
            			printDebet(debet,table);
            			printedDebets.put(debet.getUid(), "1");
            			bPrinted=true;
            		}
            	}
            }
            if(!bPrinted){
                cell=createValueCell("\n",10);
                cell.setBorder(PdfPCell.BOX);
                table.addCell(cell);
                cell=createValueCell("",10);
                cell.setBorder(PdfPCell.BOX);
                table.addCell(cell);
                cell=createValueCell("",50);
                cell.setBorder(PdfPCell.BOX);
                table.addCell(cell);
                cell=createValueCell("",10);
                cell.setBorder(PdfPCell.BOX);
                table.addCell(cell);
                cell=createValueCell("",10);
                cell.setBorder(PdfPCell.BOX);
                table.addCell(cell);
                cell=createValueCell("",10);
                cell.setBorder(PdfPCell.BOX);
                table.addCell(cell);
            }

            cell=createValueCell("",10);
            cell.setBorder(PdfPCell.BOX);
            table.addCell(cell);
            cell=createValueCell("",10);
            cell.setBorder(PdfPCell.BOX);
            table.addCell(cell);
            cell=createBoldLabelCell(getTran("web","acts"),80);
            cell.setBorder(PdfPCell.BOX);
            table.addCell(cell);

            debets = invoice.getDebets();
            bPrinted=false;
            for(int n=0;n<debets.size();n++){
            	Debet debet = (Debet)debets.elementAt(n);
            	if(debet.getPrestation()!=null){
            		if(debet.getQuantity()>0 && debet.getPrestation().getReferenceObject()!=null && debet.getPrestation().getReferenceObject().getObjectType()!=null  && debet.getPrestation().getReferenceObject().getObjectType().equalsIgnoreCase(MedwanQuery.getInstance().getConfigString("CTAMSactsCategory","A"))){
            			printDebet(debet,table);
            			printedDebets.put(debet.getUid(), "1");
            			bPrinted=true;
            		}
            	}
            }
            if(!bPrinted){
                cell=createValueCell("\n",10);
                cell.setBorder(PdfPCell.BOX);
                table.addCell(cell);
                cell=createValueCell("",10);
                cell.setBorder(PdfPCell.BOX);
                table.addCell(cell);
                cell=createValueCell("",50);
                cell.setBorder(PdfPCell.BOX);
                table.addCell(cell);
                cell=createValueCell("",10);
                cell.setBorder(PdfPCell.BOX);
                table.addCell(cell);
                cell=createValueCell("",10);
                cell.setBorder(PdfPCell.BOX);
                table.addCell(cell);
                cell=createValueCell("",10);
                cell.setBorder(PdfPCell.BOX);
                table.addCell(cell);
            }

            cell=createValueCell("",10);
            cell.setBorder(PdfPCell.BOX);
            table.addCell(cell);
            cell=createValueCell("",10);
            cell.setBorder(PdfPCell.BOX);
            table.addCell(cell);
            cell=createBoldLabelCell(getTran("web","consumables"),80);
            cell.setBorder(PdfPCell.BOX);
            table.addCell(cell);

            debets = invoice.getDebets();
            bPrinted=false;
            for(int n=0;n<debets.size();n++){
            	Debet debet = (Debet)debets.elementAt(n);
            	if(debet.getPrestation()!=null){
            		if(debet.getQuantity()>0 && debet.getPrestation().getReferenceObject()!=null && debet.getPrestation().getReferenceObject().getObjectType()!=null  && debet.getPrestation().getReferenceObject().getObjectType().equalsIgnoreCase(MedwanQuery.getInstance().getConfigString("CTAMSconsumablesCategory","C"))){
            			printDebet(debet,table);
            			printedDebets.put(debet.getUid(), "1");
            			bPrinted=true;
            		}
            	}
            }
            if(!bPrinted){
                cell=createValueCell("\n",10);
                cell.setBorder(PdfPCell.BOX);
                table.addCell(cell);
                cell=createValueCell("",10);
                cell.setBorder(PdfPCell.BOX);
                table.addCell(cell);
                cell=createValueCell("",50);
                cell.setBorder(PdfPCell.BOX);
                table.addCell(cell);
                cell=createValueCell("",10);
                cell.setBorder(PdfPCell.BOX);
                table.addCell(cell);
                cell=createValueCell("",10);
                cell.setBorder(PdfPCell.BOX);
                table.addCell(cell);
                cell=createValueCell("",10);
                cell.setBorder(PdfPCell.BOX);
                table.addCell(cell);
            }

            cell=createValueCell("",10);
            cell.setBorder(PdfPCell.BOX);
            table.addCell(cell);
            cell=createValueCell("",10);
            cell.setBorder(PdfPCell.BOX);
            table.addCell(cell);
            cell=createBoldLabelCell(getTran("web","other"),80);
            cell.setBorder(PdfPCell.BOX);
            table.addCell(cell);

            //Eerst nog de geneesmiddelen verwijderen
            debets = invoice.getDebets();
            for(int n=0;n<debets.size();n++){
            	Debet debet = (Debet)debets.elementAt(n);
            	if(debet.getPrestation()!=null){
            		if(debet.getQuantity()>0 && debet.getPrestation().getReferenceObject()!=null && debet.getPrestation().getReferenceObject().getObjectType()!=null  && debet.getPrestation().getReferenceObject().getObjectType().equalsIgnoreCase(MedwanQuery.getInstance().getConfigString("CTAMSdrugsCategory","M"))){
            			printedDebets.put(debet.getUid(), "1");
            		}
            	}
            }
            
            debets = invoice.getDebets();
            bPrinted=false;
            for(int n=0;n<debets.size();n++){
            	Debet debet = (Debet)debets.elementAt(n);
            	if(debet.getPrestation()!=null){
            		if(debet.getQuantity()>0 && printedDebets.get(debet.getUid())==null){
            			printDebet(debet,table);
            			bPrinted=true;
            		}
            	}
            }
            if(!bPrinted){
                cell=createValueCell("\n",10);
                cell.setBorder(PdfPCell.BOX);
                table.addCell(cell);
                cell=createValueCell("",10);
                cell.setBorder(PdfPCell.BOX);
                table.addCell(cell);
                cell=createValueCell("",50);
                cell.setBorder(PdfPCell.BOX);
                table.addCell(cell);
                cell=createValueCell("",10);
                cell.setBorder(PdfPCell.BOX);
                table.addCell(cell);
                cell=createValueCell("",10);
                cell.setBorder(PdfPCell.BOX);
                table.addCell(cell);
                cell=createValueCell("",10);
                cell.setBorder(PdfPCell.BOX);
                table.addCell(cell);
            }

        	//Find encounters
        	Hashtable encounters = new Hashtable();
        	debets = invoice.getDebets();
        	for(int n=0;n<debets.size();n++){
        		Debet debet = (Debet)debets.elementAt(n);
        		if(encounters.get(debet.getEncounterUid())==null){
        			encounters.put(debet.getEncounterUid(), debet.getEncounter());
        		}
        	}
        	Enumeration eEncounters = encounters.elements();
        	int admDays=0, ambCount=0;
        	Date admBegin=null,admEnd=null;
        	while(eEncounters.hasMoreElements()){
        		Encounter encounter = (Encounter)eEncounters.nextElement();
        		if(encounter.getType().equalsIgnoreCase("admission")){
        			if(admBegin==null || admBegin.after(encounter.getBegin())){
        				admBegin=encounter.getBegin();
        			}
        			if(admEnd==null || (encounter.getEnd()!=null && admEnd.before(encounter.getEnd()))){
        				admEnd=encounter.getEnd();
        			}
        			admDays+=encounter.getDurationInDays();
        		}
        		else {
        			ambCount++;
        		}
        	}
            cell=createValueCell("",20);
            cell.setBorder(PdfPCell.BOX);
            table.addCell(cell);
            cell=createBoldLabelCell(getTran("web","admission.from")+": "+(admBegin==null?"":new SimpleDateFormat("dd/MM/yyyy").format(admBegin))+" "+getTran("web","ctams.to")+" "+(admEnd==null?"":new SimpleDateFormat("dd/MM/yyyy").format(admEnd))+"   "+getTran("web","ctams.number.of.days")+": "+admDays+"\n"+
            getTran("web","number.of.visits")+": "+ambCount,80);
            cell.setBorder(PdfPCell.BOX);
            table.addCell(cell);
            doc.add(table);
            
            addBlankRow();

            table = new PdfPTable(100);
            table.setWidthPercentage(pageWidth);
            
            cell=createUnderlinedCell(getTran("web","ctams.drugs"),100,9);
            table.addCell(cell);
            
            cell=createValueCell("\n",100);
            table.addCell(cell);

            cell=createValueCell(getTran("web","date"),10);
            cell.setBorder(PdfPCell.BOX);
            table.addCell(cell);
            cell=createValueCell(getTran("web","code"),10);
            cell.setBorder(PdfPCell.BOX);
            table.addCell(cell);
            cell=createValueCell(getTran("web","drugnames"),50);
            cell.setBorder(PdfPCell.BOX);
            table.addCell(cell);
            cell=createValueCell(getTran("web","quantity"),10);
            cell.setBorder(PdfPCell.BOX);
            table.addCell(cell);
            cell=createValueCell(getTran("web","up"),10);
            cell.setBorder(PdfPCell.BOX);
            table.addCell(cell);
            cell=createValueCell(getTran("web","tp"),10);
            cell.setBorder(PdfPCell.BOX);
            table.addCell(cell);

            debets = invoice.getDebets();
            bPrinted=false;
            for(int n=0;n<debets.size();n++){
            	Debet debet = (Debet)debets.elementAt(n);
            	if(debet.getPrestation()!=null){
            		if(debet.getQuantity()>0 && debet.getPrestation().getReferenceObject()!=null && debet.getPrestation().getReferenceObject().getObjectType()!=null && debet.getPrestation().getReferenceObject().getObjectType().equalsIgnoreCase(MedwanQuery.getInstance().getConfigString("CTAMSdrugsCategory","M"))){
            			printDebet(debet,table);
            			printedDebets.put(debet.getUid(), "1");
            			bPrinted=true;
            		}
            	}
            }
            if(!bPrinted){
                cell=createValueCell("\n",10);
                cell.setBorder(PdfPCell.BOX);
                table.addCell(cell);
                cell=createValueCell("",10);
                cell.setBorder(PdfPCell.BOX);
                table.addCell(cell);
                cell=createValueCell("",50);
                cell.setBorder(PdfPCell.BOX);
                table.addCell(cell);
                cell=createValueCell("",10);
                cell.setBorder(PdfPCell.BOX);
                table.addCell(cell);
                cell=createValueCell("",10);
                cell.setBorder(PdfPCell.BOX);
                table.addCell(cell);
                cell=createValueCell("",10);
                cell.setBorder(PdfPCell.BOX);
                table.addCell(cell);
            }

            doc.add(table);
            
            addBlankRow();
            
            table = new PdfPTable(100);
            table.setWidthPercentage(pageWidth);

            cell=createEmptyCell(20);
            table.addCell(cell);
            cell=createValueCell(getTran("web","insurance"),30);
            cell.setBorder(PdfPCell.BOX);
            table.addCell(cell);
            cell=createValueCell(getTran("web","amount"),10);
            cell.setBorder(PdfPCell.BOX);
            table.addCell(cell);
            cell=createValueCell("%",10);
            cell.setBorder(PdfPCell.BOX);
            table.addCell(cell);
            cell=createEmptyCell(30);
            table.addCell(cell);

            double patientshare=0,insureramount=0;
            debets = invoice.getDebets();
            bPrinted=false;
            for(int n=0;n<debets.size();n++){
            	Debet debet = (Debet)debets.elementAt(n);
            	patientshare+=debet.getAmount()+debet.getExtraInsurarAmount();
            	insureramount+=debet.getInsurarAmount();
            }

            cell=createEmptyCell(20);
            table.addCell(cell);
            cell=createValueCell(getTran("web","total"),30);
            cell.setBorder(PdfPCell.BOX);
            table.addCell(cell);
            cell=createValueCell(new DecimalFormat(MedwanQuery.getInstance().getConfigString("priceFormat","#")).format(patientshare+insureramount),10);
            cell.setBorder(PdfPCell.BOX);
            table.addCell(cell);
            cell=createValueCell("100%",10);
            cell.setBorder(PdfPCell.BOX);
            table.addCell(cell);
            cell=createEmptyCell(30);
            table.addCell(cell);
            
            cell=createEmptyCell(20);
            table.addCell(cell);
            cell=createValueCell(getTran("web","ctams.patientshare"),30);
            cell.setBorder(PdfPCell.BOX);
            table.addCell(cell);
            cell=createValueCell(new DecimalFormat(MedwanQuery.getInstance().getConfigString("priceFormat","#")).format(patientshare),10);
            cell.setBorder(PdfPCell.BOX);
            table.addCell(cell);
            cell=createValueCell(new DecimalFormat(MedwanQuery.getInstance().getConfigString("priceFormat","#")).format(patientshare*100/(patientshare+insureramount))+"%",10);
            cell.setBorder(PdfPCell.BOX);
            table.addCell(cell);
            cell=createEmptyCell(30);
            table.addCell(cell);
            
            cell=createEmptyCell(20);
            table.addCell(cell);
            cell=createValueCell(getTran("web","ctams.insurer"),30);
            cell.setBorder(PdfPCell.BOX);
            table.addCell(cell);
            cell=createValueCell(new DecimalFormat(MedwanQuery.getInstance().getConfigString("priceFormat","#")).format(insureramount),10);
            cell.setBorder(PdfPCell.BOX);
            table.addCell(cell);
            cell=createValueCell(new DecimalFormat(MedwanQuery.getInstance().getConfigString("priceFormat","#")).format(insureramount*100/(patientshare+insureramount))+"%",10);
            cell.setBorder(PdfPCell.BOX);
            table.addCell(cell);
            cell=createEmptyCell(30);
            table.addCell(cell);
            
            doc.add(table);

            addBlankRow();
            
            table = new PdfPTable(100);
            table.setWidthPercentage(pageWidth);

            cell=createEmptyCell(70);
            table.addCell(cell);
            cell=createValueCell(getTran("web","ctams.done.at")+" "+new SimpleDateFormat("dd/MM/yyyy").format(new Date()),30);
            table.addCell(cell);
            cell=createValueCell("\n",100);
            table.addCell(cell);
            cell=createValueCell(getTran("web","printedby")+": "+user.person.lastname.toUpperCase()+", "+user.person.firstname+" "+new SimpleDateFormat("dd/MM/yyyy HH:mm:ss").format(new java.util.Date()),100);
            cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
            table.addCell(cell);
            cell=createValueCell(getTran("web","ctams.beneficiary.signature"),33);
            cell.setHorizontalAlignment(PdfPCell.ALIGN_CENTER);
            table.addCell(cell);
            cell=createValueCell(getTran("web","ctams.caregiver.signature"),33);
            cell.setHorizontalAlignment(PdfPCell.ALIGN_CENTER);
            table.addCell(cell);
            cell=createValueCell(getTran("web","ctams.facility.stamp"),34);
            cell.setHorizontalAlignment(PdfPCell.ALIGN_CENTER);
            table.addCell(cell);
            
            doc.add(table);

        }
        catch(Exception e){
            e.printStackTrace();
        }
    }

    private void printDebet(Debet debet,PdfPTable table){
        cell=createValueCell(new SimpleDateFormat("dd/MM/yyyy").format(debet.getDate()),10);
        cell.setBorder(PdfPCell.BOX);
        table.addCell(cell);
        cell=createValueCell(debet.getPrestation().getCode(),10);
        cell.setBorder(PdfPCell.BOX);
        table.addCell(cell);
        cell=createLabelCell(debet.getPrestation().getDescription(),50);
        cell.setBorder(PdfPCell.BOX);
        table.addCell(cell);
        cell=createValueCell(debet.getQuantity()+"",10);
        cell.setBorder(PdfPCell.BOX);
        table.addCell(cell);
        cell=createValueCell(new DecimalFormat(MedwanQuery.getInstance().getConfigString("priceFormat","#")).format((debet.getAmount()+debet.getInsurarAmount()+debet.getExtraInsurarAmount())/debet.getQuantity()),10);
        cell.setBorder(PdfPCell.BOX);
        table.addCell(cell);
        cell=createValueCell(new DecimalFormat(MedwanQuery.getInstance().getConfigString("priceFormat","#")).format(debet.getAmount()+debet.getInsurarAmount()+debet.getExtraInsurarAmount()),10);
        cell.setBorder(PdfPCell.BOX);
        table.addCell(cell);
    }
    
    //### PRIVATE METHODS #########################################################################

    //--- GET INSURANCE DATA ----------------------------------------------------------------------
    private PdfPTable getInsuranceData(Insurance insurance){
        PdfPTable table = new PdfPTable(14);
        table.setWidthPercentage(pageWidth);

        InsuranceCategory insuranceCat = insurance.getInsuranceCategory();
        Insurar insurar = insuranceCat.getInsurar();
        double patientShare = Double.parseDouble(insuranceCat.getPatientShare());

        //*** ROW 1 ***
        // insurar name
        table.addCell(createLabelCell(getTran("web","insurar"),2));
        table.addCell(createValueCell(":   "+insurar.getName(),5,8,Font.BOLD));

        // patient share
        table.addCell(createLabelCell(getTran("system.manage","categorypatientshare"),2));
        cell = createValueCell(":   "+patientShare+" %",2);
        table.addCell(cell);
        table.addCell(createLabelCell(getTran("hrm","dossiernr"),1));
        table.addCell(createValueCell(":   "+insurance.getInsuranceNr(),2));

        //*** ROW 2 ***
        // insurance category
        table.addCell(createLabelCell(getTran("web","tariff"),2));
        table.addCell(createValueCell(":   "+ getTran("insurance.types",insurance.getType()),5));

        // insurar share
        table.addCell(createLabelCell(getTran("system.manage","categoryinsurarshare"),2));
        cell = createValueCell(":   "+(100-patientShare)+" %",2);
        table.addCell(cell);
        table.addCell(createEmptyCell(3));

        return table;
    }

    //--- GET DEBETS (prestations) ----------------------------------------------------------------
    private void getDebets(PatientInvoice invoice,PdfPTable tableParent,Vector debets){

        Vector debetUids = debets;
        if(debetUids.size() > 0){
            PdfPTable table = new PdfPTable(20);
            table.setWidthPercentage(pageWidth);
            // header
            cell = createUnderlinedCell(getTran("web","date"),1);
            PdfPTable singleCellHeaderTable = new PdfPTable(1);
            singleCellHeaderTable.addCell(cell);
            cell = createCell(new PdfPCell(singleCellHeaderTable),2,PdfPCell.ALIGN_CENTER,PdfPCell.NO_BORDER);
            cell.setPaddingRight(2);
            table.addCell(cell);

            cell = createUnderlinedCell(getTran("web","encounter"),1);
            singleCellHeaderTable = new PdfPTable(1);
            singleCellHeaderTable.addCell(cell);
            cell = createCell(new PdfPCell(singleCellHeaderTable),4,PdfPCell.ALIGN_CENTER,PdfPCell.NO_BORDER);
            cell.setPaddingRight(2);
            table.addCell(cell);

            cell = createUnderlinedCell(getTran("web","prestation"),1);
            singleCellHeaderTable = new PdfPTable(1);
            singleCellHeaderTable.addCell(cell);
            cell = createCell(new PdfPCell(singleCellHeaderTable),8,PdfPCell.ALIGN_CENTER,PdfPCell.NO_BORDER);
            cell.setPaddingRight(2);
            table.addCell(cell);

            cell = createUnderlinedCell(getTran("web","patient"),1);
            cell.setHorizontalAlignment(PdfPCell.ALIGN_RIGHT);
            singleCellHeaderTable = new PdfPTable(1);
            singleCellHeaderTable.addCell(cell);
            cell = createCell(new PdfPCell(singleCellHeaderTable),2,PdfPCell.ALIGN_CENTER,PdfPCell.NO_BORDER);
            cell.setPaddingRight(2);
            table.addCell(cell);

            cell = createUnderlinedCell(getTran("web","insurar"),1);
            cell.setHorizontalAlignment(PdfPCell.ALIGN_RIGHT);
            singleCellHeaderTable = new PdfPTable(1);
            singleCellHeaderTable.addCell(cell);
            cell = createCell(new PdfPCell(singleCellHeaderTable),2,PdfPCell.ALIGN_CENTER,PdfPCell.NO_BORDER);
            cell.setPaddingRight(2);
            table.addCell(cell);

            cell = createUnderlinedCell(getTran("web","extrainsurar"),1);
            cell.setHorizontalAlignment(PdfPCell.ALIGN_RIGHT);
            singleCellHeaderTable = new PdfPTable(1);
            singleCellHeaderTable.addCell(cell);
            cell = createCell(new PdfPCell(singleCellHeaderTable),2,PdfPCell.ALIGN_CENTER,PdfPCell.NO_BORDER);
            cell.setPaddingRight(2);
            table.addCell(cell);

            cell = new PdfPCell(table);
            cell.setPadding(cellPadding);
            tableParent.addCell(createCell(cell,1,PdfPCell.ALIGN_LEFT,PdfPCell.NO_BORDER));

            // print debets
            double totalPatient = 0, totalInsurar = 0, totalExtraInsurar=0;
            Debet debet;
            String activePrestationClass="";

            Vector debetsVector = new Vector();
            for(int i=0; i<debetUids.size(); i++){
                debet = (Debet)debetUids.get(i);
                debetsVector.add(debet);
            }

            for(int i=0; i<debetUids.size(); i++){
                table = new PdfPTable(20);
                table.setWidthPercentage(pageWidth);
                debet = (Debet)debetUids.get(i);
                String prestationClass= debet.getPrestation().getReferenceObject().getObjectType()==null?"?":debet.getPrestation().getReferenceObject().getObjectType();
                if(!prestationClass.equalsIgnoreCase(activePrestationClass)){
                    //This is a new prestation class, go calculate the header
                    activePrestationClass=prestationClass;
                    printPrestationClass(table,activePrestationClass,debetsVector);
                }
                totalPatient+= debet.getAmount();
                totalInsurar+= debet.getInsurarAmount();
                totalExtraInsurar+= debet.getExtraInsurarAmount();
                printDebet(table,debet);
                cell = new PdfPCell(table);
                cell.setPadding(0);
                tableParent.addCell(createCell(cell,1,PdfPCell.ALIGN_LEFT,PdfPCell.NO_BORDER));
            }

            table = new PdfPTable(20);
            // spacer
            //table.addCell(createEmptyCell(20));

            // display debet total
            table.addCell(createEmptyCell(9));
            cell = createLabelCell(getTran("web","subtotalprice"),5);
            cell.setHorizontalAlignment(PdfPCell.ALIGN_RIGHT);
            cell.setPaddingRight(cellPadding);
            table.addCell(cell);
            table.addCell(createTotalPriceCell(totalPatient,2));

            table.addCell(createTotalPriceCell(totalInsurar,2));

            table.addCell(createTotalPriceCell(totalExtraInsurar,2));
            cell = new PdfPCell(table);
            cell.setPadding(cellPadding);
            tableParent.addCell(createCell(cell,1,PdfPCell.ALIGN_LEFT,PdfPCell.NO_BORDER));

            this.patientDebetTotal += totalPatient;
            this.insurarDebetTotal += totalInsurar;
        }
        else{
            table.addCell(createValueCell(getTran("web","noDataAvailable"),20));
        }

    }

    //--- GET CREDITS (payments) ------------------------------------------------------------------
    private PdfPTable getCredits(PatientInvoice invoice){
        PdfPTable table = new PdfPTable(20);
        table.setWidthPercentage(pageWidth);

        Vector creditUids = invoice.getCredits();
        if(creditUids.size() > 0){
            // header
            cell = createUnderlinedCell(getTran("web","date"),1);
            PdfPTable singleCellHeaderTable = new PdfPTable(1);
            singleCellHeaderTable.addCell(cell);
            cell = createCell(new PdfPCell(singleCellHeaderTable),2,PdfPCell.ALIGN_CENTER,PdfPCell.NO_BORDER);
            cell.setPaddingRight(2);
            table.addCell(cell);

            cell = createUnderlinedCell(getTran("web","type"),1);
            singleCellHeaderTable = new PdfPTable(1);
            singleCellHeaderTable.addCell(cell);
            cell = createCell(new PdfPCell(singleCellHeaderTable),3,PdfPCell.ALIGN_CENTER,PdfPCell.NO_BORDER);
            cell.setPaddingRight(2);
            table.addCell(cell);

            cell = createUnderlinedCell(getTran("web","comment"),1);
            singleCellHeaderTable = new PdfPTable(1);
            singleCellHeaderTable.addCell(cell);
            cell = createCell(new PdfPCell(singleCellHeaderTable),9,PdfPCell.ALIGN_CENTER,PdfPCell.NO_BORDER);
            cell.setPaddingRight(2);
            table.addCell(cell);

            cell = createUnderlinedCell(getTran("web","patient"),1);
            cell.setHorizontalAlignment(PdfPCell.ALIGN_RIGHT);
            singleCellHeaderTable = new PdfPTable(1);
            singleCellHeaderTable.addCell(cell);
            cell = createCell(new PdfPCell(singleCellHeaderTable),3,PdfPCell.ALIGN_CENTER,PdfPCell.NO_BORDER);
            cell.setPaddingRight(2);
            table.addCell(cell);

            cell = createUnderlinedCell(" ",1);
            cell.setHorizontalAlignment(PdfPCell.ALIGN_RIGHT);
            singleCellHeaderTable = new PdfPTable(1);
            singleCellHeaderTable.addCell(cell);
            cell = createCell(new PdfPCell(singleCellHeaderTable),3,PdfPCell.ALIGN_CENTER,PdfPCell.NO_BORDER);
            cell.setPaddingRight(2);
            table.addCell(cell);

            // get credits from uids
            double total = 0;
            Hashtable creditsHash = new Hashtable();
            PatientCredit credit;
            String sCreditUid;

            for(int i=0; i<creditUids.size(); i++){
                sCreditUid = (String)creditUids.get(i);
                credit = PatientCredit.get(sCreditUid);
                creditsHash.put(new SimpleDateFormat("yyyyMMddHHmmss").format(credit.getDate())+"."+credit.getUid(),credit);
            }

            // sort credits on date
            Vector creditDates = new Vector(creditsHash.keySet());
            Collections.sort(creditDates);
            Collections.reverse(creditDates);

            String creditDate;
            for(int i=0; i<creditDates.size(); i++){
                creditDate = (String)creditDates.get(i);
                credit = (PatientCredit)creditsHash.get(creditDate);
                total+= credit.getAmount();
                printCredit(table,credit);
            }

            // spacer
            //table.addCell(createEmptyCell(20));

            // display credit total
            table.addCell(createEmptyCell(9));
            cell = createLabelCell(getTran("web","subtotalprice"),5);
            cell.setHorizontalAlignment(PdfPCell.ALIGN_RIGHT);
            cell.setPaddingRight(cellPadding);
            table.addCell(cell);
            table.addCell(createTotalPriceCell(total,3));
            table.addCell(createEmptyCell(3));

            this.creditTotal = total;
        }
        else{
            table.addCell(createValueCell(getTran("web","noDataAvailable"),20));
        }

        return table;
    }

    //--- PRINT PRESTATIONCLASS -------------------------------------------------------------------
    private void printPrestationClass(PdfPTable invoiceTable,String prestationClass,Vector debets){
        double classPatientAmount = 0,classInsurarAmount=0,classExtraInsurarAmount=0;
        for(int n=0;n<debets.size();n++){
            Debet debet = (Debet)debets.elementAt(n);
            String sClass= debet.getPrestation().getReferenceObject().getObjectType()==null?"?":debet.getPrestation().getReferenceObject().getObjectType();
            if(sClass.equalsIgnoreCase(prestationClass)){
                classPatientAmount+=debet.getAmount();
                classInsurarAmount+=debet.getInsurarAmount();
                classExtraInsurarAmount+=debet.getExtraInsurarAmount();
            }
        }
        cell = new PdfPCell(new Paragraph(getTran("prestationclass",prestationClass),FontFactory.getFont(FontFactory.HELVETICA,7,Font.BOLDITALIC)));
        cell.setColspan(14);
        cell.setBorder(PdfPCell.BOX);
        cell.setVerticalAlignment(PdfPCell.ALIGN_TOP);
        cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
        invoiceTable.addCell(cell);
        cell = new PdfPCell(new Paragraph(priceFormat.format(classPatientAmount)+" "+sCurrency,FontFactory.getFont(FontFactory.HELVETICA,7,Font.BOLDITALIC)));
        cell.setColspan(2);
        cell.setBorder(PdfPCell.BOX);
        cell.setVerticalAlignment(PdfPCell.ALIGN_TOP);
        cell.setHorizontalAlignment(PdfPCell.ALIGN_RIGHT);
        invoiceTable.addCell(cell);
        cell = new PdfPCell(new Paragraph(priceFormat.format(classInsurarAmount)+" "+sCurrency,FontFactory.getFont(FontFactory.HELVETICA,7,Font.BOLDITALIC)));
        cell.setColspan(2);
        cell.setBorder(PdfPCell.BOX);
        cell.setVerticalAlignment(PdfPCell.ALIGN_TOP);
        cell.setHorizontalAlignment(PdfPCell.ALIGN_RIGHT);
        invoiceTable.addCell(cell);
        cell = new PdfPCell(new Paragraph(priceFormat.format(classExtraInsurarAmount)+" "+sCurrency,FontFactory.getFont(FontFactory.HELVETICA,7,Font.BOLDITALIC)));
        cell.setColspan(2);
        cell.setBorder(PdfPCell.BOX);
        cell.setVerticalAlignment(PdfPCell.ALIGN_TOP);
        cell.setHorizontalAlignment(PdfPCell.ALIGN_RIGHT);
        invoiceTable.addCell(cell);
    };

    //--- PRINT DEBET (prestation) ----------------------------------------------------------------
    private void printDebet(PdfPTable invoiceTable, Debet debet){
        String sDebetDate = stdDateFormat.format(debet.getDate());
        double debetAmountPatient = debet.getAmount();
        double debetAmountInsurar = debet.getInsurarAmount();
        double debetAmountExtraInsurar = debet.getExtraInsurarAmount();

        // encounter
        Encounter debetEncounter = debet.getEncounter();
        String sEncounterName = debetEncounter.getEncounterDisplayNameNoDate(this.sPrintLanguage);

        // prestation
        Prestation prestation = debet.getPrestation();
        String sPrestationCode  = "", sPrestationDescr = "";
        if(prestation!=null){
            sPrestationCode  = checkString(prestation.getCode());
            sPrestationDescr = checkString(prestation.getDescription());
        }

        if(sPrestationCode.length() > 0){
            sPrestationCode = "["+sPrestationCode+"] ";
        }

        // row
        invoiceTable.addCell(createValueCell(sDebetDate,2));
        invoiceTable.addCell(createValueCell(sEncounterName,4));
        String extraInsurar="";
        if(debet.getExtraInsurarUid()!=null && debet.getExtraInsurarUid().length()>0){
            Insurar exIns = Insurar.get(debet.getExtraInsurarUid());
            if(exIns!=null){
                extraInsurar=" >>> "+ScreenHelper.checkString(exIns.getName());
                if(extraInsurar.indexOf("#")>-1){
                    extraInsurar=extraInsurar.substring(0,extraInsurar.indexOf("#"));
                }
            }
        }
        invoiceTable.addCell(createValueCell(sPrestationCode+debet.getQuantity()+" x "+sPrestationDescr+extraInsurar,8));
        invoiceTable.addCell(createPriceCell(debetAmountPatient,2));
        invoiceTable.addCell(createPriceCell(debetAmountInsurar,2));
        invoiceTable.addCell(createPriceCell(debetAmountExtraInsurar,2));
    }

    //--- PRINT CREDIT (payment) ------------------------------------------------------------------
    private void printCredit(PdfPTable invoiceTable, PatientCredit credit){
        String sCreditDate = stdDateFormat.format(credit.getDate());
        double creditAmount = credit.getAmount();
        String sCreditComment = checkString(credit.getComment());
        String sCreditType = getTran("credit.type",credit.getType());

        // row
        invoiceTable.addCell(createValueCell(sCreditDate,2));
        invoiceTable.addCell(createValueCell(sCreditType,3));
        invoiceTable.addCell(createValueCell(sCreditComment,9));
        invoiceTable.addCell(createPriceCell(creditAmount,3));
        invoiceTable.addCell(createEmptyCell(3));
    }

    //--- GET SALDO -------------------------------------------------------------------------------
    private PdfPTable getSaldo(){
        PdfPTable table = new PdfPTable(20);
        table.setWidthPercentage(pageWidth);

        // debets
        table.addCell(createEmptyCell(9));
        cell = createLabelCell(getTran("web","invoiceDebets"),5);
        cell.setHorizontalAlignment(PdfPCell.ALIGN_RIGHT);
        cell.setPaddingRight(5);
        table.addCell(cell);
        table.addCell(createPriceCell(this.patientDebetTotal,3));
        table.addCell(createEmptyCell(3));

        // credits
        table.addCell(createEmptyCell(9));
        cell = createLabelCell(getTran("web","invoiceCredits"),5);
        cell.setHorizontalAlignment(PdfPCell.ALIGN_RIGHT);
        cell.setPaddingRight(5);
        table.addCell(cell);
        table.addCell(createPriceCell(this.creditTotal,(this.creditTotal>=0),3));
        table.addCell(createEmptyCell(3));

        // saldo
        table.addCell(createEmptyCell(9));
        cell = createBoldLabelCell(getTran("web","totalprice").toUpperCase(),5);
        cell.setHorizontalAlignment(PdfPCell.ALIGN_RIGHT);
        cell.setPaddingRight(5);
        table.addCell(cell);

        double saldo = (this.patientDebetTotal - Math.abs(this.creditTotal));
        table.addCell(createTotalPriceCell(saldo,3));
        table.addCell(createEmptyCell(3));

        return table;
    }

}