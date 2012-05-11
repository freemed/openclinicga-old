package be.mxs.common.util.pdf.general;

import com.itextpdf.text.pdf.*;
import com.itextpdf.text.*;
import java.io.ByteArrayOutputStream;
import java.text.SimpleDateFormat;

import be.mxs.common.util.system.Miscelaneous;
import be.mxs.common.util.system.Debug;
import be.mxs.common.util.system.ScreenHelper;
import be.mxs.common.util.db.MedwanQuery;
import be.openclinic.finance.*;
import net.admin.*;

import javax.servlet.http.HttpServletRequest;

public class PDFWicketReceiptGenerator extends PDFInvoiceGenerator {

    private WicketCredit wicketCredit=null;
    //--- CONSTRUCTOR -----------------------------------------------------------------------------
    public PDFWicketReceiptGenerator(User user, WicketCredit operation, String sProject, String sPrintLanguage){
        this.user = user;
        this.wicketCredit = operation;
        this.sProject = sProject;
        this.sPrintLanguage = sPrintLanguage;

        doc = new Document();
    }

    //--- GENERATE PDF DOCUMENT BYTES -------------------------------------------------------------
    public ByteArrayOutputStream generatePDFDocumentBytes(final HttpServletRequest req, String sCreditUid) throws Exception {
        ByteArrayOutputStream baosPDF = new ByteArrayOutputStream();
		docWriter = PdfWriter.getInstance(doc,baosPDF);
        this.req = req;

		try{
            doc.addProducer();
            doc.addAuthor(user.person.firstname+" "+user.person.lastname);
			doc.addCreationDate();
			doc.addCreator("OpenClinic Software");
			doc.setPageSize(PageSize.A4);
            addFooter();

            doc.open();

            // get specified invoice
            addHeading(wicketCredit);
            printCreditReceipt(wicketCredit);
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

    //---- ADD HEADING (logo & barcode) -----------------------------------------------------------
    private void addHeading(WicketCredit credit) throws Exception {
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

            //*** title ***
            table.addCell(createTitleCell(getTran("web","wicketpaymentreceipt").toUpperCase()+" #"+credit.getUid().split("\\.")[1]+" - "+new SimpleDateFormat("dd/MM/yyyy").format(credit.getOperationDate()),"",4));

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
    private void printCreditReceipt(WicketCredit credit){
        try {
            PdfPTable table = new PdfPTable(1);
            table.setWidthPercentage(pageWidth);

            // credits
            PdfPTable creditTable = new PdfPTable(100);
            creditTable.addCell(createGrayCell(getTran("web","operation.identification").toUpperCase(),100));
            creditTable.addCell(createGrayCell("ID",20));
            creditTable.addCell(createValueCell(credit.getUid(),80));
            creditTable.addCell(createGrayCell(getTran("web","wicket").toUpperCase(),20));
            creditTable.addCell(createValueCell(getTran("service",Wicket.get(credit.getWicketUID()).getServiceUID()),80));
            creditTable.addCell(createGrayCell(getTran("web","operator").toUpperCase(),20));
            creditTable.addCell(createValueCell(user.person.firstname.toUpperCase()+" "+user.person.lastname,80));
            creditTable.addCell(createGrayCell(getTran("web","date").toUpperCase(),20));
            creditTable.addCell(createValueCell(new SimpleDateFormat("dd/MM/yyyy").format(credit.getOperationDate()),80));
            creditTable.addCell(createGrayCell(getTran("web","operation.type").toUpperCase(),20));
            creditTable.addCell(createValueCell(getTran("wicketcredit.type",credit.getOperationType()),80));
            creditTable.addCell(createGrayCell(getTran("web","amount").toUpperCase(),20));
            creditTable.addCell(createValueCell(credit.getAmount()+" "+sCurrency,80));
            creditTable.addCell(createGrayCell(getTran("web","comment").toUpperCase(),20));
            creditTable.addCell(createValueCell(credit.getComment()+"",80));
            creditTable.addCell(createEmptyCell(100));
            creditTable.addCell(createGrayCell(getTran("web","operator.signature").toUpperCase(),100));
            creditTable.addCell(createValueCell(user.person.firstname.toUpperCase()+" "+user.person.lastname,100));
            if(user.activeService!=null){
                creditTable.addCell(createValueCell(user.activeService.getLabel(user.person.language),100));
            }
            creditTable.addCell(createEmptyCell(100));
            creditTable.addCell(createEmptyCell(100));
            creditTable.addCell(createEmptyCell(100));
            creditTable.addCell(createEmptyCell(100));
            creditTable.addCell(createEmptyCell(100));
            creditTable.addCell(createEmptyCell(100));
            creditTable.addCell(createGrayCell(getTran("web","payor.signature").toUpperCase(),100));
            creditTable.addCell(createEmptyCell(100));
            creditTable.addCell(createEmptyCell(100));
            creditTable.addCell(createEmptyCell(100));
            creditTable.addCell(createEmptyCell(100));
            creditTable.addCell(createEmptyCell(100));
            creditTable.addCell(createEmptyCell(100));
            creditTable.addCell(createEmptyCell(100));
            creditTable.addCell(createEmptyCell(100));
            creditTable.addCell(createEmptyCell(100));
            creditTable.addCell(createEmptyCell(100));
            creditTable.addCell(createEmptyCell(100));
            creditTable.addCell(createEmptyCell(100));
            creditTable.addCell(createEmptyCell(100));
            creditTable.addCell(createEmptyCell(100));

            table.addCell(createCell(new PdfPCell(creditTable),1,PdfPCell.ALIGN_CENTER,PdfPCell.NO_BORDER));
            table.addCell(createEmptyCell(1));

            // "printed by" info
            table.addCell(createCell(new PdfPCell(getPrintedByInfo()),1,PdfPCell.ALIGN_LEFT,PdfPCell.NO_BORDER));

            doc.add(table);
        }
        catch(Exception e){
            e.printStackTrace();
        }
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
        table.addCell(createValueCell(":   "+insurar.getName(),5));

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

    //--- GET CREDITS (payments) ------------------------------------------------------------------
    private PdfPTable getCredits(PatientCredit credit){
        PdfPTable table = new PdfPTable(20);
        table.setWidthPercentage(pageWidth);

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

        cell = createUnderlinedCell(getTran("web","contact"),1);
        singleCellHeaderTable = new PdfPTable(1);
        singleCellHeaderTable.addCell(cell);
        cell = createCell(new PdfPCell(singleCellHeaderTable),4,PdfPCell.ALIGN_CENTER,PdfPCell.NO_BORDER);
        cell.setPaddingRight(2);
        table.addCell(cell);

        cell = createUnderlinedCell(getTran("web","comment"),1);
        singleCellHeaderTable = new PdfPTable(1);
        singleCellHeaderTable.addCell(cell);
        cell = createCell(new PdfPCell(singleCellHeaderTable),5,PdfPCell.ALIGN_CENTER,PdfPCell.NO_BORDER);
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
        total+= credit.getAmount();
        printCredit(table,credit);


        this.creditTotal = total;

        return table;
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
        invoiceTable.addCell(createValueCell(credit.getEncounterUid()+", "+ScreenHelper.getTranDb("encountertype", credit.getEncounter().getType(),sPrintLanguage),4));
        invoiceTable.addCell(createValueCell(sCreditComment,5));
        invoiceTable.addCell(createPriceCell(creditAmount,3));
        invoiceTable.addCell(createEmptyCell(3));
    }

}