package be.mxs.common.util.pdf.general;

import com.itextpdf.text.pdf.*;
import com.itextpdf.text.*;

import java.util.*;
import java.io.ByteArrayOutputStream;
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

public class PDFPatientInvoiceGenerator extends PDFInvoiceGenerator {
    String sProforma = "no";

    //--- CONSTRUCTOR -----------------------------------------------------------------------------
    public PDFPatientInvoiceGenerator(User user, AdminPerson patient, String sProject, String sPrintLanguage, String proforma){
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

            addReceipt(invoice);
            addHeading(invoice);
            addPatientData();
            addEncounterData(invoice);
            //get list of patientinsurances
            Vector insurances = Insurance.findInsurances("", "", "", "", "", patient.personid);
            for(int n=0;n<insurances.size();n++){
                Insurance insurance = (Insurance)insurances.elementAt(n);
                if(insurance!=null){
                    Vector debets=invoice.getDebetsForInsurance(insurance.getUid());
                    if(debets.size()>0){
                        addInsuranceData(insurance,invoice);
                        printDebets(invoice,debets);
                    }
                }
            }
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
    
    private void addEncounterData(PatientInvoice invoice){
        try {
	    	PdfPTable wrappertable = new PdfPTable(2);
	    	wrappertable.setWidthPercentage(pageWidth);
	    	SortedMap encounters = new TreeMap();
	    	for(int n=0;n<invoice.getDebets().size();n++){
	    		Debet debet = (Debet)invoice.getDebets().elementAt(n);
	    		encounters.put(debet.getEncounterUid(), "1");
	    	}
	    	Iterator iEncounters = encounters.keySet().iterator();
	    	while(iEncounters.hasNext()){
	    		String encounterUid = (String)iEncounters.next();
	    		Encounter encounter = Encounter.get(encounterUid);
	    		if(encounter!=null){
	    			table = new PdfPTable(100);
	    	        table.setWidthPercentage(pageWidth);
	    			if(encounter.getType()!=null && encounter.getType().equalsIgnoreCase("admission")){
		    			cell= createValueCell(getTran("web","begindate")+":",15);
		    			cell.setBorder(PdfPCell.NO_BORDER);
		    			table.addCell(cell);
	        			cell= createValueCell(encounter.getBegin()==null?"":new SimpleDateFormat("dd/MM/yyyy").format(encounter.getBegin()),23);
		    			cell.setBorder(PdfPCell.NO_BORDER);
		    			table.addCell(cell);
		    			cell= createValueCell(getTran("web","enddate")+":",15);
		    			cell.setBorder(PdfPCell.NO_BORDER);
		    			table.addCell(cell);
		    			cell= createValueCell(encounter.getEnd()==null?"":new SimpleDateFormat("dd/MM/yyyy").format(encounter.getEnd()),23);
		    			cell.setBorder(PdfPCell.NO_BORDER);
		    			table.addCell(cell);
		    			cell= createValueCell(getTran("web","bed")+":",10);
		    			cell.setBorder(PdfPCell.NO_BORDER);
		    			table.addCell(cell);
		    			cell= createValueCell(encounter.getBed()==null?"":encounter.getBed().getName(),14);
		    			cell.setBorder(PdfPCell.NO_BORDER);
		    			table.addCell(cell);
	    			}
	    			else {
		    			cell= createValueCell(getTran("web","begindate")+":",20);
		    			cell.setBorder(PdfPCell.NO_BORDER);
		    			table.addCell(cell);
	        			cell= createValueCell(encounter.getBegin()==null?"":new SimpleDateFormat("dd/MM/yyyy").format(encounter.getBegin()),80);
		    			cell.setBorder(PdfPCell.NO_BORDER);
		    			table.addCell(cell);
	    			}
	    			cell = createGrayCell(getTran("encountertype",encounter.getType()).toUpperCase(), 1);
	    			wrappertable.addCell(cell);
	    			cell = createGrayCell(encounter.getService().getLabel(sPrintLanguage).toUpperCase(), 1);
	    			wrappertable.addCell(cell);
	                cell = createCell(new PdfPCell(table),2,PdfPCell.ALIGN_CENTER,PdfPCell.BOX);
	                cell.setPadding(cellPadding);
	                wrappertable.addCell(cell);
	    		}
	    	}
	    	doc.add(wrappertable);
	    	addBlankRow();
        }
        catch(Exception e){
        	e.printStackTrace();
        }
    }

    //---- ADD RECEIPT ----------------------------------------------------------------------------
    private void addReceipt(PatientInvoice invoice) throws DocumentException {
        PdfPTable receiptTable = new PdfPTable(50);
        receiptTable.setWidthPercentage(pageWidth);

        // logo
        try{
            Image img = Miscelaneous.getImage("logo_"+sProject+".gif",sProject);
            Vector debets = invoice.getDebets();
            for(int n=0;n<debets.size();n++){
            	Debet debet = (Debet)debets.elementAt(n);
            	if(debet.getInsurance()!=null && debet.getInsurance().getInsurarUid()!=null && MedwanQuery.getInstance().getConfigString("insurancelogo."+debet.getInsurance().getInsurarUid(),"").length()>0){
            		img = Miscelaneous.getImage(MedwanQuery.getInstance().getConfigString("insurancelogo."+debet.getInsurance().getInsurarUid(),""),sProject);
            		break;
            	}
            }
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
            if(debet!=null){
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
                int imgwidth=75,imgheight=75;
                Vector debets = invoice.getDebets();
                for(int n=0;n<debets.size();n++){
                	Debet debet = (Debet)debets.elementAt(n);
                	if(debet.getInsurance()!=null && debet.getInsurance().getInsurarUid()!=null && MedwanQuery.getInstance().getConfigString("insurancelogo."+debet.getInsurance().getInsurarUid(),"").length()>0){
                		img = Miscelaneous.getImage(MedwanQuery.getInstance().getConfigString("insurancelogo."+debet.getInsurance().getInsurarUid(),""),sProject);
                		imgwidth=MedwanQuery.getInstance().getConfigInt("insurancelogo."+debet.getInsurance().getInsurarUid()+".width",imgwidth);
                		imgheight=MedwanQuery.getInstance().getConfigInt("insurancelogo."+debet.getInsurance().getInsurarUid()+".height",imgheight);
                		break;
                	}
                }
                img.scaleToFit(imgwidth,imgheight);
                cell = new PdfPCell(img);
                cell.setBorder(PdfPCell.NO_BORDER);
                cell.setColspan(1);
                table.addCell(cell);
            }
            catch(NullPointerException e){
                Debug.println("WARNING : PDFPatientInvoiceGenerator --> IMAGE NOT FOUND : logo_"+sProject+".gif");
                e.printStackTrace();
            }

            //*** title ***
            if(invoice.getInvoiceNumber().equalsIgnoreCase(invoice.getInvoiceUid())){
                table.addCell(createTitleCell(getTran("web","invoice").toUpperCase()+" #"+(sProforma.equalsIgnoreCase("yes")?"PROFORMA":invoice.getInvoiceNumber())+" - "+new SimpleDateFormat("dd/MM/yyyy").format(invoice.getDate()),"",3));
            }
            else {
            	PdfPTable table2 = new PdfPTable(1);
                table2.setWidthPercentage(100);
                table2.addCell(createTitleCell(getTran("web","invoice").toUpperCase()+" #"+(sProforma.equalsIgnoreCase("yes")?"PROFORMA":invoice.getInvoiceNumber())+" - "+new SimpleDateFormat("dd/MM/yyyy").format(invoice.getDate()),"",1));
            	cell=createValueCell(getTran("web.occup","medwan.common.reference")+": "+invoice.getInvoiceUid(),1,8,Font.NORMAL);
                cell.setHorizontalAlignment(PdfPCell.ALIGN_CENTER);
            	table2.addCell(cell);
            	cell = new PdfPCell(table2);
                cell.setBorder(PdfPCell.NO_BORDER);
            	cell.setColspan(3);
            	table.addCell(cell);
            }


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
            addBlankRow();
        }
        catch(Exception e){
            e.printStackTrace();
        }
    }

    //--- ADD PATIENT DATA ------------------------------------------------------------------------
    private void addPatientData(){
        PdfPTable table = new PdfPTable(1);
        table.setWidthPercentage(pageWidth);

        PdfPTable patientTable = new PdfPTable(3);
        patientTable.setWidthPercentage(pageWidth);

        try {
            //--- LEFT SUB TABLE ----------------------------------------------
            PdfPTable leftTable = new PdfPTable(3);

            //*** contact data ***
            String sContactData = "";
            AdminPrivateContact apc = patient.getActivePrivate();
            if(apc!=null){
                sContactData+= apc.address+
                               "\n"+apc.zipcode+" "+apc.city;

                // additional data
                if(apc.province.length() > 0) sContactData+= "\n"+getTran("province",apc.province);
                if(apc.district.length() > 0) sContactData+= "\n"+apc.district;
                if(apc.sector.length() > 0)   sContactData+= "\n"+apc.sector;

                sContactData+= "\n"+getTran("country",apc.country);
            }

            leftTable.addCell(createValueCell(sContactData,3));

            cell = createCell(new PdfPCell(leftTable),1,PdfPCell.ALIGN_CENTER,PdfPCell.NO_BORDER);
            cell.setVerticalAlignment(PdfPCell.ALIGN_TOP);
            patientTable.addCell(cell);

            //--- RIGHT SUB TABLE ---------------------------------------------
            PdfPTable rightTable = new PdfPTable(9);

            //*** date of birth ***
            String sData = patient.dateOfBirth;
            if(sData.length() > 0){
                rightTable.addCell(createValueCell(getTran("web","dateofbirth"),2));
                rightTable.addCell(createValueCell(":   "+sData,7));
            }

            //*** gender ***
            sData = patient.gender;
            if(sData.length() > 0){
                rightTable.addCell(createValueCell(getTran("web","gender"),2));
                rightTable.addCell(createValueCell(":   "+sData,7));
            }

            //*** person id ***
            sData = patient.personid;
            if(sData.length() > 0){
                rightTable.addCell(createValueCell(getTran("web","personid"),2));
                rightTable.addCell(createValueCell(":   "+sData,7));
            }

            //*** natreg ***
            sData = patient.getAdminID("natreg")==null?"":patient.getAdminID("natreg").value;
            if(sData.length() > 0){
                rightTable.addCell(createValueCell(getTran("web","natreg"),2));
                rightTable.addCell(createValueCell(":   "+sData,7));
            }

            cell = createCell(new PdfPCell(rightTable),2,PdfPCell.ALIGN_CENTER,PdfPCell.NO_BORDER);
            cell.setVerticalAlignment(PdfPCell.ALIGN_TOP);
            patientTable.addCell(cell);

            // title = patient name
            String sPatientName = patient.lastname+" "+patient.firstname;
            table.addCell(createGrayCell(getTran("web","patient")+": "+sPatientName.toUpperCase(),1,9,Font.BOLD));
            cell = createCell(new PdfPCell(patientTable),1,PdfPCell.ALIGN_CENTER,PdfPCell.BOX);
            cell.setPadding(cellPadding);
            table.addCell(cell);

            doc.add(table);
            addBlankRow();
            
        }
        catch(Exception e){
            e.printStackTrace();
        }
    }

    //--- ADD INSURANCE DATA ----------------------------------------------------------------------
    private void addInsuranceData(Insurance insurance,PatientInvoice invoice){
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
                        cell = new PdfPCell(getInsuranceData(insurance,invoice));
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
    private void printInvoice(PatientInvoice invoice,Vector debets){
        try {
            PdfPTable table = new PdfPTable(1);
            table.setWidthPercentage(pageWidth);

            // credits
            PdfPTable creditTable = new PdfPTable(1);
            creditTable.addCell(createGrayCell(getTran("web","invoiceCredits").toUpperCase(),1));
            cell = new PdfPCell(getCredits(invoice));
            cell.setPadding(cellPadding);
            creditTable.addCell(createCell(cell,1,PdfPCell.ALIGN_LEFT,PdfPCell.BOX));
            table.addCell(createCell(new PdfPCell(creditTable),1,PdfPCell.ALIGN_CENTER,PdfPCell.NO_BORDER));
            table.addCell(createEmptyCell(1));

            // saldo
            PdfPTable saldoTable = new PdfPTable(1);
            saldoTable.addCell(createGrayCell(getTran("web","invoiceSaldo").toUpperCase(),1));
            cell = new PdfPCell(getSaldo(debets));
            cell.setPadding(cellPadding);
            saldoTable.addCell(createCell(cell,1,PdfPCell.ALIGN_LEFT,PdfPCell.BOX));
            table.addCell(createCell(new PdfPCell(saldoTable),1,PdfPCell.ALIGN_CENTER,PdfPCell.NO_BORDER));
            table.addCell(createEmptyCell(1));

            doc.add(table);

            table = new PdfPTable(2);
            table.setWidthPercentage(pageWidth);
            // "printed by" info
            table.addCell(createCell(new PdfPCell(getPrintedByInfo()),2,PdfPCell.ALIGN_LEFT,PdfPCell.NO_BORDER));
            if(MedwanQuery.getInstance().getConfigInt("enableInvoiceVerification",0)==1){
	            table.addCell(createValueCell(getTran("careproviderSignature"),1));
	            table.addCell(createValueCell(getTran("verifiersignature")+"\n\n"+checkString(invoice.getVerifier()),1));
            }
            else {
	            table.addCell(createValueCell(getTran("patientsignature"),1));
	            table.addCell(createValueCell(getTran("careproviderSignature"),1));
            }
            doc.add(table);
        }
        catch(Exception e){
            e.printStackTrace();
        }
    }

    //### PRIVATE METHODS #########################################################################

    //--- GET INSURANCE DATA ----------------------------------------------------------------------
    private PdfPTable getInsuranceData(Insurance insurance,PatientInvoice invoice){
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

        //*** ROW 3 ***
        // insurance category
        table.addCell(createLabelCell(getTran("web.finance","insurarreference"),2));
        table.addCell(createValueCell(":   "+invoice.getInsurarreference()+(invoice.getInsurarreferenceDate()!=null && invoice.getInsurarreferenceDate().length()>0?" ("+invoice.getInsurarreferenceDate()+")":""),5));
        table.addCell(createLabelCell(getTran("insurance","member"),2));
        table.addCell(createValueCell(":   "+ScreenHelper.checkString(insurance.getMember()),5));

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
        String sEncounterName = debetEncounter.getUid()+", "+MedwanQuery.getInstance().getLabel("encountertype", debetEncounter.getType(), sPrintLanguage)+" ("+(debet.getServiceUid()!=null?debet.getServiceUid():debetEncounter.getServiceUID())+")";

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
    private PdfPTable getSaldo(Vector debets){
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

        
        double complementaryinsurar = 0;
        String sComplementaryInsurars="";
        for (int n=0;n<debets.size();n++){
        	Debet debet = (Debet)debets.elementAt(n);
        	if(debet.getExtraInsurarUid2()!=null && debet.getExtraInsurarUid2().length()>0){
        		Insurar e2 = Insurar.get(debet.getExtraInsurarUid2());
        		if(e2!=null){
        			String sName = e2.getName();
        			if(sComplementaryInsurars.indexOf(sName)<0){
        				if(sComplementaryInsurars.length()>0){
        					sComplementaryInsurars+=", ";
        				}
        				sComplementaryInsurars+=sName;
        			}
        		}
        		complementaryinsurar+=debet.getAmount();
        	}
        }
        // complementary insurar
        table.addCell(createEmptyCell(9));
        cell = createBoldLabelCell(getTran("web","complementarycoverage2").toUpperCase()+" ("+sComplementaryInsurars+")",5);
        cell.setHorizontalAlignment(PdfPCell.ALIGN_RIGHT);
        cell.setPaddingRight(5);
        table.addCell(cell);
        table.addCell(createTotalPriceCell(complementaryinsurar,3));
        table.addCell(createEmptyCell(3));


        return table;
    }

}