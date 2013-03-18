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

public class PDFPatientInvoiceGeneratorCMCK extends PDFInvoiceGenerator {
    String sProforma = "no";

    private class PrestationData{
    	public double quantity;
    	public double patientamount;
    	public double insureramount;
    }
    
    //--- CONSTRUCTOR -----------------------------------------------------------------------------
    public PDFPatientInvoiceGeneratorCMCK(User user, AdminPerson patient, String sProject, String sPrintLanguage, String proforma){
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
        	//Find encounters
        	Hashtable encounters = new Hashtable();
        	Vector debets = invoice.getDebets();
        	for(int n=0;n<debets.size();n++){
        		Debet debet = (Debet)debets.elementAt(n);
        		if(encounters.get(debet.getEncounterUid())==null){
        			encounters.put(debet.getEncounterUid(), debet.getEncounter());
        		}
        	}
        	boolean bInitialized=false;
        	Enumeration eEncounters = encounters.elements();
        	while(eEncounters.hasMoreElements()){
        		Encounter encounter = (Encounter)eEncounters.nextElement();
        		if(bInitialized){
        			doc.newPage();
        		}
        		else{
        			bInitialized=true;
        		}
       			addReceipt(invoice,encounter.getUid());
                addHeading(invoice);
        		if(encounter.getType().equalsIgnoreCase("admission")){
                    addPatientDataAdmission(invoice,encounter.getUid());
                    printInvoiceAdmission(invoice,encounter.getUid());
        		}
        		else {
                    addPatientDataVisit(invoice,encounter.getUid());
                    printInvoiceVisit(invoice);
        		}
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
    private void addReceipt(PatientInvoice invoice, String encounteruid) throws DocumentException {
    	Vector debets = new Vector();
    	for(int n=0;n<invoice.getDebets().size();n++){
    		Debet debet = (Debet)invoice.getDebets().elementAt(n);
    		if(debet!=null && debet.getEncounterUid().equalsIgnoreCase(encounteruid)){
    			debets.add(debet);
    		}
    	}
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
        for(int n=0;n<debets.size();n++){
            Debet debet = (Debet)debets.elementAt(n);
            if(debet!=null){
            	if(debet.getEncounter()!=null && debet.getEncounter().getService()!=null){
            		service=debet.getEncounter().getService().getLabel(sPrintLanguage);
            	}
	            if(service!=null){
	            	services.put(service, "1");
	            }
	            totalDebet+=(debet.hasValidExtrainsurer2()?0:debet.getAmount());
	            totalinsurardebet+=debet.getInsurarAmount()+debet.getExtraInsurarAmount()+(debet.hasValidExtrainsurer2()?debet.getAmount():0);
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

        	PdfPTable table2 = new PdfPTable(30);
            table2.setWidthPercentage(pageWidth);
            Report_Identification report_identification = new Report_Identification(invoice.getDate());
            cell=createValueCell(getTran("web","cmck.ident.1.1"),15,8,Font.BOLD);
            cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
            table2.addCell(cell);
            cell=createValueCell(getTran("web","invoicenumber")+": "+invoice.getUid(),10,8,Font.BOLD);
            cell.setHorizontalAlignment(PdfPCell.ALIGN_RIGHT);
            table2.addCell(cell);
            cell = createEmptyCell(5);
            table2.addCell(cell);

            cell=createValueCell(getTran("web","cmck.ident.2.1"),15,8,Font.BOLD);
            cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
            table2.addCell(cell);
            cell=createValueCell(getTran("web","recordnumber")+": "+invoice.getPatientUid(),10,8,Font.BOLD);
            cell.setHorizontalAlignment(PdfPCell.ALIGN_RIGHT);
            table2.addCell(cell);
            if(!sProforma.equalsIgnoreCase("yes")){
                //*** barcode ***
                PdfContentByte cb = docWriter.getDirectContent();
                Barcode39 barcode39 = new Barcode39();
                barcode39.setCode("7"+invoice.getInvoiceUid());
                Image image = barcode39.createImageWithBarcode(cb,null,null);
                image.scaleAbsoluteWidth(75);
                cell = new PdfPCell(image);
                cell.setHorizontalAlignment(PdfPCell.ALIGN_RIGHT);
                cell.setBorder(PdfPCell.NO_BORDER);
                cell.setPadding(0);
                cell.setColspan(5);
            }
            else {
                cell = createEmptyCell(5);
            }
            table2.addCell(cell);

            cell=new PdfPCell(table2);
            cell.setColspan(4);
            cell.setBorder(PdfPCell.NO_BORDER);
            table.addCell(cell);
            doc.add(table);
            addBlankRow();

        }
        catch(Exception e){
            e.printStackTrace();
        }
    }

    //--- ADD PATIENT DATA ------------------------------------------------------------------------
    private void addPatientDataVisit(PatientInvoice invoice,String encounteruid){
    	Encounter encounter = Encounter.get(encounteruid);

    	Vector debets = new Vector();
    	for(int n=0;n<invoice.getDebets().size();n++){
    		Debet debet = (Debet)invoice.getDebets().elementAt(n);
    		if(debet!=null && debet.getEncounterUid().equalsIgnoreCase(encounteruid)){
    			debets.add(debet);
    		}
    	}
        PdfPTable table = new PdfPTable(100);
        table.setWidthPercentage(pageWidth);
        try{
        	AdminPerson person = invoice.getPatient();
        	String thisinsurance="",thisservice="";
        	Hashtable insurars = new Hashtable(), services = new Hashtable();
        	if(person!=null){
        		for(int n=0;n<debets.size();n++){
        			Debet debet = (Debet)debets.elementAt(n);
    				if(debet.getInsurance()!=null && debet.getInsurance().getInsurarUid()!=null && debet.getInsurance().getInsurarUid().length()>0){
    					insurars.put(debet.getInsurance().getInsurarUid(), "1");
    				}
    				if(debet.getServiceUid()!=null && debet.getServiceUid().length()>0){
    					services.put(debet.getServiceUid(), "1");
    				}
        		}
        		Enumeration eKeys = insurars.keys();
        		while(eKeys.hasMoreElements()){
        			String uid=(String)eKeys.nextElement();
        			Insurar insurar = Insurar.get(uid);
        			if(insurar!=null){
        				if(thisinsurance.length()>0){
        					thisinsurance+=", ";
        				}
        				thisinsurance+=insurar.getName();
        			}
        		}
        		eKeys = services.keys();
        		while(eKeys.hasMoreElements()){
        			String uid=(String)eKeys.nextElement();
        			Service service = Service.getService(uid);
        			if(service!=null){
        				if(thisservice.length()>0){
        					thisservice+=", ";
        				}
        				thisservice+=service.getLabel(sPrintLanguage);
        			}
        		}
	        	cell=createBoldUnderlinedLabelCell(getTran("web","consultation.of")+" "+invoice.getPatient().getFullName()+" "+getTran("web","on.authorization")+" "+invoice.getInsurarreference()+" "+getTran("web","of")+" "+thisinsurance,100);
	        	table.addCell(cell);

	        	cell=createLabelCell(getTran("web","service"), 10);
	        	table.addCell(cell);
	        	cell=createBoldLabelCell(thisservice, 40);
	        	table.addCell(cell);
	        	cell=createLabelCell(getTran("web","date"), 10);
	        	table.addCell(cell);
	        	cell=createBoldLabelCell(new SimpleDateFormat("dd/MM/yyyy").format(encounter.getBegin()), 40);
	        	table.addCell(cell);

	        	cell=createLabelCell(getTran("web","physician"), 10);
	        	table.addCell(cell);
	        	cell=createBoldLabelCell(encounter.getManager()!=null?encounter.getManager().person.getFullName():"", 40);
	        	table.addCell(cell);

	        	cell=createLabelCell(getTran("web","advancepayment"), 10);
	        	table.addCell(cell);
	        	double advancepayment=0;
	        	String receiptNumber="";
	        	Vector credits = invoice.getCredits();
	        	for(int n=0;n<credits.size();n++){
	        		PatientCredit credit = PatientCredit.get((String)credits.elementAt(n));
	        		if(credit!=null){
	        			advancepayment+=credit.getAmount();
	        			if(receiptNumber.length()>0){
	        				receiptNumber+=", ";
	        			}
	        			receiptNumber+=credit.getUid();
	        		}
	        	}
	        	cell=createBoldLabelCell(new DecimalFormat(MedwanQuery.getInstance().getConfigString("priceFormat","#")).format(advancepayment), 15);
	        	table.addCell(cell);
	        	cell=createLabelCell(getTran("web","receiptnumber"), 10);
	        	table.addCell(cell);
	        	cell=createBoldLabelCell(receiptNumber, 15);
	        	table.addCell(cell);

	        	doc.add(table);
	        	
	        	addBlankRow();
        	}
        }
        catch(Exception e){
            e.printStackTrace();
        }
    }


    //--- ADD PATIENT DATA ------------------------------------------------------------------------
    private void addPatientDataAdmission(PatientInvoice invoice, String encounteruid){
    	Encounter encounter = Encounter.get(encounteruid);
    	double stayamount=0;

    	Vector debets = new Vector();
    	for(int n=0;n<invoice.getDebets().size();n++){
    		Debet debet = (Debet)invoice.getDebets().elementAt(n);
    		if(debet!=null && debet.getEncounterUid().equalsIgnoreCase(encounteruid)){
    			debets.add(debet);
    		}
    	}
        PdfPTable table = new PdfPTable(100);
        table.setWidthPercentage(pageWidth);
        try{
        	AdminPerson person = invoice.getPatient();
        	String thisinsurance="",thisservice="";
        	Hashtable insurars = new Hashtable(), services = new Hashtable();
        	if(person!=null){
        		for(int n=0;n<debets.size();n++){
        			Debet debet = (Debet)debets.elementAt(n);
    				if(debet.getInsurance()!=null && debet.getInsurance().getInsurarUid()!=null && debet.getInsurance().getInsurarUid().length()>0){
    					insurars.put(debet.getInsurance().getInsurarUid(), "1");
    				}
    				if(debet.getServiceUid()!=null && debet.getServiceUid().length()>0){
    					services.put(debet.getServiceUid(), "1");
    				}
    				if(debet.getPrestation()!=null && debet.getPrestation().getPrestationClass()!=null && debet.getPrestation().getPrestationClass().equalsIgnoreCase("stay")){
    					stayamount+=debet.getAmount()+debet.getInsurarAmount()+debet.getExtraInsurarAmount();
    				}
        		}
        		Enumeration eKeys = insurars.keys();
        		while(eKeys.hasMoreElements()){
        			String uid=(String)eKeys.nextElement();
        			Insurar insurar = Insurar.get(uid);
        			if(insurar!=null){
        				if(thisinsurance.length()>0){
        					thisinsurance+=", ";
        				}
        				thisinsurance+=insurar.getName();
        			}
        		}
        		eKeys = services.keys();
        		while(eKeys.hasMoreElements()){
        			String uid=(String)eKeys.nextElement();
        			Service service = Service.getService(uid);
        			if(service!=null){
        				if(thisservice.length()>0){
        					thisservice+=", ";
        				}
        				thisservice+=service.getLabel(sPrintLanguage);
        			}
        		}
	        	cell=createBoldUnderlinedLabelCell(getTran("web","admission.of")+" "+invoice.getPatient().getFullName()+" "+getTran("web","on.authorization")+" "+invoice.getInsurarreference()+" "+getTran("web","of")+" "+thisinsurance,100);
	        	table.addCell(cell);

	        	cell=createLabelCell(getTran("web","service"), 10);
	        	table.addCell(cell);
	        	cell=createBoldLabelCell(thisservice, 40);
	        	table.addCell(cell);
	        	cell=createLabelCell(getTran("web","admissiondate"), 10);
	        	table.addCell(cell);
	        	cell=createBoldLabelCell(new SimpleDateFormat("dd/MM/yyyy").format(encounter.getBegin()), 40);
	        	table.addCell(cell);

	        	cell=createLabelCell(getTran("web","physician"), 10);
	        	table.addCell(cell);
	        	cell=createBoldLabelCell(encounter.getManager()!=null?encounter.getManager().person.getFullName():"", 40);
	        	table.addCell(cell);
	        	cell=createLabelCell(getTran("web","dischargedate"), 10);
	        	table.addCell(cell);
	        	cell=createBoldLabelCell(encounter.getEnd()==null?"":new SimpleDateFormat("dd/MM/yyyy").format(encounter.getEnd()), 40);
	        	table.addCell(cell);

	        	cell=createLabelCell(getTran("web","advancepayment"), 10);
	        	table.addCell(cell);
	        	double advancepayment=0;
	        	String receiptNumber="";
	        	Vector credits = invoice.getCredits();
	        	for(int n=0;n<credits.size();n++){
	        		PatientCredit credit = PatientCredit.get((String)credits.elementAt(n));
	        		if(credit!=null){
	        			advancepayment+=credit.getAmount();
	        			if(receiptNumber.length()>0){
	        				receiptNumber+=", ";
	        			}
	        			receiptNumber+=credit.getUid();
	        		}
	        	}
	        	cell=createBoldLabelCell(new DecimalFormat(MedwanQuery.getInstance().getConfigString("priceFormat","#")).format(advancepayment), 15);
	        	table.addCell(cell);
	        	cell=createLabelCell(getTran("web","receiptnumber"), 10);
	        	table.addCell(cell);
	        	cell=createBoldLabelCell(receiptNumber, 15);
	        	table.addCell(cell);
	        	cell=createLabelCell(getTran("web","stay"), 10);
	        	table.addCell(cell);
	        	cell=createBoldLabelCell(new DecimalFormat(MedwanQuery.getInstance().getConfigString("priceFormat","#")).format(stayamount), 40);
	        	table.addCell(cell);

	        	doc.add(table);
	        	
	        	addBlankRow();
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
    private void printInvoiceVisit(PatientInvoice invoice){
        try {
            PdfPTable table = new PdfPTable(100);
            table.setWidthPercentage(pageWidth);
            
            String departments="";
        	//Find encounters
        	Hashtable encounters = new Hashtable();
        	Vector debets = invoice.getDebets();
        	for(int n=0;n<debets.size();n++){
        		Debet debet = (Debet)debets.elementAt(n);
        		if(encounters.get(debet.getEncounterUid())==null){
        			encounters.put(debet.getEncounterUid(), debet.getEncounter());
        		}
        	}
        	Enumeration eEncounters = encounters.elements();
        	while(eEncounters.hasMoreElements()){
        		Encounter encounter = (Encounter)eEncounters.nextElement();
        		if(!encounter.getType().equalsIgnoreCase("admission") && encounter.getService()!=null){
        			if(departments.length()>0){
        				departments+=", ";
        			}
        			departments+=encounter.getService().getLabel(user.person.language);
        		}
        	}

        	cell=createLabelCell(getTran("web","service")+":",20);
        	table.addCell(cell);
        	cell=createBoldLabelCell(departments,80);
        	table.addCell(cell);

            cell=createValueCell("\n",100);
            table.addCell(cell);

            cell=createValueCell(getTran("web","mfp.acts.and.drugs"),40,7,Font.BOLD);
            cell.setBorder(PdfPCell.BOTTOM);
            table.addCell(cell);
            cell=createValueCell(getTran("web","code"),10,7,Font.BOLD);
            cell.setHorizontalAlignment(PdfPCell.ALIGN_RIGHT);
            cell.setBorder(PdfPCell.BOTTOM);
            table.addCell(cell);
            cell=createValueCell("#",5,7,Font.BOLD);
            cell.setHorizontalAlignment(PdfPCell.ALIGN_RIGHT);
            cell.setBorder(PdfPCell.BOTTOM);
            table.addCell(cell);
            cell=createValueCell(getTran("web","up"),5,7,Font.BOLD);
            cell.setHorizontalAlignment(PdfPCell.ALIGN_RIGHT);
            cell.setBorder(PdfPCell.BOTTOM);
            table.addCell(cell);
            cell=createValueCell(getTran("web","mfp.cat1"),10,7,Font.BOLD);
            cell.setHorizontalAlignment(PdfPCell.ALIGN_RIGHT);
            cell.setBorder(PdfPCell.BOTTOM);
            table.addCell(cell);
            cell=createValueCell(getTran("web","mfp.cat2"),10,7,Font.BOLD);
            cell.setHorizontalAlignment(PdfPCell.ALIGN_RIGHT);
            cell.setBorder(PdfPCell.BOTTOM);
            table.addCell(cell);
            cell=createValueCell(getTran("web","mfp.cat3"),10,7,Font.BOLD);
            cell.setHorizontalAlignment(PdfPCell.ALIGN_RIGHT);
            cell.setBorder(PdfPCell.BOTTOM);
            table.addCell(cell);
            cell=createValueCell(getTran("web","mfp.supplement"),10,7,Font.BOLD);
            cell.setHorizontalAlignment(PdfPCell.ALIGN_RIGHT);
            cell.setBorder(PdfPCell.BOTTOM);
            table.addCell(cell);

            debets = invoice.getDebets();
            double patientshare=0,insureramount=0,supplements=0;
            for(int n=0;n<debets.size();n++){
            	Debet debet = (Debet)debets.elementAt(n);
            	if(debet.getEncounter()!=null && debet.getEncounter().getType().equalsIgnoreCase("visit") && debet.getPrestation()!=null && debet.getQuantity()>0){
        			printDebet(debet,table);
        			patientshare+=debet.getAmount()+debet.getExtraInsurarAmount();
        			insureramount+=debet.getInsurarAmount();
        			supplements+=debet.getPrestation().getSupplement()*debet.getQuantity();
            	}
            }

            cell=createValueCell("",60,7,Font.BOLD);
            cell.setBorder(PdfPCell.TOP);
            table.addCell(cell);
            cell=createValueCell(new DecimalFormat(MedwanQuery.getInstance().getConfigString("priceFormat","#")).format(patientshare+insureramount),10,7,Font.BOLD);
            cell.setHorizontalAlignment(PdfPCell.ALIGN_RIGHT);
            cell.setBorder(PdfPCell.TOP);
            table.addCell(cell);
            cell=createValueCell(new DecimalFormat(MedwanQuery.getInstance().getConfigString("priceFormat","#")).format(insureramount),10,7,Font.BOLD);
            cell.setHorizontalAlignment(PdfPCell.ALIGN_RIGHT);
            cell.setBorder(PdfPCell.TOP);
            table.addCell(cell);
            cell=createValueCell(new DecimalFormat(MedwanQuery.getInstance().getConfigString("priceFormat","#")).format(patientshare-supplements),10,7,Font.BOLD);
            cell.setHorizontalAlignment(PdfPCell.ALIGN_RIGHT);
            cell.setBorder(PdfPCell.TOP);
            table.addCell(cell);
            cell=createValueCell(new DecimalFormat(MedwanQuery.getInstance().getConfigString("priceFormat","#")).format(supplements),10,7,Font.BOLD);
            cell.setHorizontalAlignment(PdfPCell.ALIGN_RIGHT);
            cell.setBorder(PdfPCell.TOP);
            table.addCell(cell);

            cell=createValueCell("\n\n",100);
            table.addCell(cell);

            cell=createEmptyCell(20);
            table.addCell(cell);
            cell=createValueCell(getTran("web","mfp.total"),30);
            cell.setBorder(PdfPCell.BOX);
            table.addCell(cell);
            cell=createValueCell(new DecimalFormat(MedwanQuery.getInstance().getConfigString("priceFormat","#")).format(patientshare+insureramount),10,7,Font.BOLD);
            cell.setBorder(PdfPCell.BOX);
            table.addCell(cell);
            cell=createEmptyCell(40);
            table.addCell(cell);
            
            cell=createEmptyCell(20);
            table.addCell(cell);
            cell=createValueCell(getTran("web","mfp.patientshare"),30);
            cell.setBorder(PdfPCell.BOX);
            table.addCell(cell);
            cell=createValueCell(new DecimalFormat(MedwanQuery.getInstance().getConfigString("priceFormat","#")).format(patientshare),10,7,Font.BOLD);
            cell.setBorder(PdfPCell.BOX);
            table.addCell(cell);
            cell=createEmptyCell(40);
            table.addCell(cell);
            
            cell=createEmptyCell(20);
            table.addCell(cell);
            cell=createValueCell(getTran("web","mfp.insurer"),30);
            cell.setBorder(PdfPCell.BOX);
            table.addCell(cell);
            cell=createValueCell(new DecimalFormat(MedwanQuery.getInstance().getConfigString("priceFormat","#")).format(insureramount),10,7,Font.BOLD);
            cell.setBorder(PdfPCell.BOX);
            table.addCell(cell);
            cell=createEmptyCell(40);
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
    
    private void printInvoiceAdmission(PatientInvoice invoice, String encounteruid){
        cell=createValueCell("\n",100);
        table.addCell(cell);
		Encounter encounter = Encounter.get(encounteruid);
        try {
            PdfPTable table = new PdfPTable(100);
            table.setWidthPercentage(pageWidth);
            cell=createValueCell("\n",100);
            table.addCell(cell);
			cell=createBoldLabelCell(getTran("web","stay").toUpperCase(),100);
	        table.addCell(cell);
			cell=createBoldUnderlinedLabelCell(getTran("web","service"),40);
	        table.addCell(cell);
			cell=createBoldUnderlinedLabelCell(getTran("web","type"),30);
	        table.addCell(cell);
			cell=createBoldUnderlinedLabelCell(getTran("web","numberofdays"),15);
	        table.addCell(cell);
			cell=createBoldUnderlinedLabelCell(getTran("web","amount"),15);
	        table.addCell(cell);
            // First print stays
	        Hashtable debetslist;
	        Hashtable classlist = new Hashtable();
	        String prestationClass="";
	        PrestationData pd = null;
	        
        	Vector debets = new Vector();
        	for(int n=0;n<invoice.getDebets().size();n++){
        		Debet debet = (Debet)invoice.getDebets().elementAt(n);
        		if(debet!=null && debet.getEncounterUid().equalsIgnoreCase(encounteruid)){
        			debets.add(debet);
        		}
        		if(debet!=null && debet.getPrestation()!=null && debet.getPrestation().getPrestationClass()!=null && debet.getPrestation().getPrestationClass().equalsIgnoreCase("stay")){
        	        String servicename = "?";
        	        if(debet.getServiceUid()!=null){
        	        	Service service = Service.getService(debet.getServiceUid());
        	        	if(service!=null){
        	        		servicename=service.getFullyQualifiedName(sPrintLanguage);
        	        	}
        	        }
        			cell=createValueCell(servicename,40);
        	        table.addCell(cell);
        			cell=createValueCell(debet.getPrestation().getDescription(),30);
        	        table.addCell(cell);
        			cell=createValueCell(debet.getQuantity()+"",15);
        	        table.addCell(cell);
        			cell=createValueCell((debet.getAmount()+debet.getInsurarAmount()+debet.getExtraInsurarAmount())+"",15);
        	        table.addCell(cell);
        		}
        		if(debet!=null && debet.getPrestation()!=null ){
        			prestationClass=debet.getPrestation().getPrestationClass();
        			if(prestationClass==null){
        				prestationClass="other";
        			}
        			if(classlist.get(prestationClass)==null){
        				classlist.put(prestationClass, new Hashtable());
        			}
        			debetslist = (Hashtable)classlist.get(prestationClass);
        			pd=(PrestationData)debetslist.get(debet.getPrestation().getUid());
        			if(pd==null){
        				pd = new PrestationData();
        				pd.quantity=debet.getQuantity();
        				pd.patientamount=debet.getAmount();
        				pd.insureramount=debet.getInsurarAmount();
        			}
        			else {
        				pd.quantity+=debet.getQuantity();
        				pd.patientamount+=debet.getAmount();
        				pd.insureramount+=debet.getInsurarAmount();
        			}
        			debetslist.put(debet.getPrestation().getUid(), pd);
        		}
        	}
            cell=createValueCell("\n",100);
	        table.addCell(cell);
			cell=createBoldLabelCell(getTran("web","prestation"),50);
	        table.addCell(cell);
			cell=createBoldLabelCell(getTran("web","quantity"),10);
	        table.addCell(cell);
			cell=createBoldLabelCell(getTran("web","unitprice"),10);
	        table.addCell(cell);
			cell=createBoldLabelCell("100%",10);
	        table.addCell(cell);
			cell=createBoldLabelCell(getTran("web","patient"),10);
	        table.addCell(cell);
			cell=createBoldLabelCell(getTran("web","insurar"),10);
	        table.addCell(cell);
            cell=createValueCell("\n",100);
            cell.setBorder(PdfPCell.TOP);
	        table.addCell(cell);
	        double patientamounts=0,insuraramounts=0,totalpatientamounts=0,totalinsuraramounts=0;
	        
	        Enumeration p = classlist.keys();
	        while(p.hasMoreElements()){
	        	prestationClass = (String)p.nextElement();
				cell=createBoldLabelCell(getTran("prestation.class",prestationClass).toUpperCase(),100);
		        table.addCell(cell);
		        debetslist = (Hashtable)classlist.get(prestationClass);
		        Enumeration d = debetslist.keys();
		        patientamounts=0;
		        insuraramounts=0;
		        while(d.hasMoreElements()){
		        	String uid=(String)d.nextElement();
		        	pd=(PrestationData)debetslist.get(uid);
		        	Prestation prestation = Prestation.get(uid);
		        	if(prestation!=null){
		        		patientamounts+=pd.patientamount;
		        		insuraramounts+=pd.insureramount;
						cell=createLabelCell(prestation.getDescription(),50);
				        table.addCell(cell);
						cell=createLabelCell(new Double(pd.quantity).intValue()+"",10);
				        table.addCell(cell);
						cell=createLabelCell(new Double((pd.patientamount+pd.insureramount)/pd.quantity).intValue()+"",10);
				        table.addCell(cell);
						cell=createLabelCell(new Double(pd.patientamount+pd.insureramount).intValue()+"",10);
				        table.addCell(cell);
						cell=createLabelCell(new Double(pd.patientamount).intValue()+"",10);
				        table.addCell(cell);
						cell=createLabelCell(new Double(pd.insureramount).intValue()+"",10);
				        table.addCell(cell);
		        	}
		        }
	        	totalpatientamounts+=patientamounts;
	        	totalinsuraramounts+=insuraramounts;
	            cell=createValueCell("",70);
	            cell.setBorder(PdfPCell.TOP);
		        table.addCell(cell);
	            cell=createBoldLabelCell(new Double(patientamounts+insuraramounts).intValue()+"",10);
	            cell.setBorder(PdfPCell.TOP);
		        table.addCell(cell);
	            cell=createBoldLabelCell(new Double(patientamounts).intValue()+"",10);
	            cell.setBorder(PdfPCell.TOP);
		        table.addCell(cell);
	            cell=createBoldLabelCell(new Double(insuraramounts).intValue()+"",10);
	            cell.setBorder(PdfPCell.TOP);
		        table.addCell(cell);
	        }
            cell=createValueCell("\n",100);
	        table.addCell(cell);
            cell=createValueCell("",70);
	        table.addCell(cell);
            cell=createBoldLabelCell(new Double(totalpatientamounts+totalinsuraramounts).intValue()+"",10,10);
	        table.addCell(cell);
            cell=createBoldLabelCell(new Double(totalpatientamounts).intValue()+"",10,10);
	        table.addCell(cell);
            cell=createBoldLabelCell(new Double(totalinsuraramounts).intValue()+"",10,10);
	        table.addCell(cell);

        	double advancepayment=0;
        	Vector credits = invoice.getCredits();
        	for(int n=0;n<credits.size();n++){
        		PatientCredit credit = PatientCredit.get((String)credits.elementAt(n));
        		if(credit!=null){
        			advancepayment+=credit.getAmount();
        		}
        	}

            cell=createBoldLabelCell(getTran("web","remainstopay"),70,10);
	        table.addCell(cell);
            cell=createBoldLabelCell(new Double(totalpatientamounts+totalinsuraramounts-advancepayment).intValue()+"",30,10);
	        table.addCell(cell);
        	
        	doc.add(table);

        }
        catch(Exception e){
            e.printStackTrace();
        }
    }

    private void printDebet(Debet debet,PdfPTable table){
    	boolean noSupplements=false;
    	if(debet!=null && debet.getInsurance()!=null && debet.getInsurance().getInsurar()!=null && debet.getInsurance().getInsurar().getNoSupplements()==1){
    		noSupplements=true;
    	}
    	if(debet!=null && debet.getPrestationUid()!=null && debet.getPrestationUid().equalsIgnoreCase(MedwanQuery.getInstance().getConfigString("anesthesiaPrestationUid","$$$"))){
    		//This is an anesthesia prestation, try to find the "parent prestation"
    		Debet parentDebet = Debet.getByRefUid(debet.getUid());
    		if(parentDebet!=null && parentDebet.getPrestation()!=null && parentDebet.getPrestation().getAnesthesiaPercentage()>0){
    			debet.getPrestation().setSupplement(parentDebet.getPrestation().getSupplement()*parentDebet.getPrestation().getAnesthesiaPercentage()/100);
    			noSupplements=false;
    		}
    	}
        cell=createValueCell(new SimpleDateFormat("dd/MM/yyyy").format(debet.getDate()),10);
        table.addCell(cell);
        cell=createLabelCell(debet.getPrestation().getDescription(),30);
        table.addCell(cell);
        cell=createValueCell(debet.getPrestation().getCode()+"",10);
        cell.setHorizontalAlignment(PdfPCell.ALIGN_RIGHT);
        table.addCell(cell);
        cell=createValueCell(debet.getQuantity()+"",5);
        cell.setHorizontalAlignment(PdfPCell.ALIGN_RIGHT);
        table.addCell(cell);
        cell=createValueCell(new DecimalFormat(MedwanQuery.getInstance().getConfigString("priceFormat","#")).format((debet.getAmount()+debet.getInsurarAmount()+debet.getExtraInsurarAmount())/debet.getQuantity()-(noSupplements?0:debet.getPrestation().getSupplement())),5);
        cell.setHorizontalAlignment(PdfPCell.ALIGN_RIGHT);
        table.addCell(cell);
        cell=createValueCell(new DecimalFormat(MedwanQuery.getInstance().getConfigString("priceFormat","#")).format(debet.getAmount()+debet.getInsurarAmount()+debet.getExtraInsurarAmount()-(noSupplements?0:debet.getPrestation().getSupplement()*debet.getQuantity())),10);
        cell.setHorizontalAlignment(PdfPCell.ALIGN_RIGHT);
        table.addCell(cell);
        cell=createValueCell(new DecimalFormat(MedwanQuery.getInstance().getConfigString("priceFormat","#")).format(debet.getInsurarAmount()),10);
        cell.setHorizontalAlignment(PdfPCell.ALIGN_RIGHT);
        table.addCell(cell);
        boolean b=debet.getExtraInsurarAmount()>0;
        cell=createValueCell((b?"(":"")+new DecimalFormat(MedwanQuery.getInstance().getConfigString("priceFormat","#")).format(debet.getAmount()+debet.getExtraInsurarAmount()-(noSupplements?0:debet.getPrestation().getSupplement()*debet.getQuantity()))+(b?")":""),10);
        cell.setHorizontalAlignment(PdfPCell.ALIGN_RIGHT);
        table.addCell(cell);
        cell=createValueCell(new DecimalFormat(MedwanQuery.getInstance().getConfigString("priceFormat","#")).format((noSupplements?0:debet.getPrestation().getSupplement()*debet.getQuantity())),10);
        cell.setHorizontalAlignment(PdfPCell.ALIGN_RIGHT);
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