package be.mxs.common.util.pdf.general;

import com.itextpdf.text.pdf.*;
import com.itextpdf.text.*;

import java.util.*;
import java.io.ByteArrayOutputStream;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import javax.servlet.http.HttpServletRequest;

import be.mxs.common.util.system.Miscelaneous;
import be.mxs.common.util.system.Debug;
import be.mxs.common.util.system.ScreenHelper;
import be.mxs.common.util.db.MedwanQuery;
import be.openclinic.finance.*;
import be.openclinic.adt.Encounter;
import net.admin.*;

public class PDFInsurarInvoiceGenerator extends PDFInvoiceGenerator {
    String PrintType;

    //--- CONSTRUCTOR -----------------------------------------------------------------------------
    public PDFInsurarInvoiceGenerator(User user, String sProject, String sPrintLanguage, String PrintType){
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
			doc.setPageSize(PageSize.A4);
            addFooter(sInvoiceUid.replaceAll("1\\.",""));

            doc.open();

            // get specified invoice
            InsurarInvoice invoice = InsurarInvoice.get(sInvoiceUid);

            addHeading(invoice);
            addInsurarData(invoice);
            printInvoice(invoice);
            addFinancialMessage();
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
    private void addHeading(InsurarInvoice invoice) throws Exception {
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
            if(invoice.getStatus().equalsIgnoreCase("closed")){
                table.addCell(createTitleCell(getTran("web","invoice").toUpperCase(),"",3));
            }
            else {
                table.addCell(createTitleCell(getTran("web","prestationlist").toUpperCase(),"",3));
            }

            //*** barcode ***
            PdfContentByte cb = docWriter.getDirectContent();
            Barcode39 barcode39 = new Barcode39();
            barcode39.setCode("6"+invoice.getInvoiceUid());
            Image image = barcode39.createImageWithBarcode(cb,null,null);
            cell = new PdfPCell(image);
            cell.setHorizontalAlignment(PdfPCell.ALIGN_RIGHT);
            cell.setBorder(PdfPCell.NO_BORDER);
            cell.setColspan(1);
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
    private void addInsurarData(InsurarInvoice invoice){
        PdfPTable table = new PdfPTable(1);
        table.setWidthPercentage(pageWidth);

        PdfPTable insurarTable = new PdfPTable(1);
        insurarTable.setWidthPercentage(pageWidth);

        try {
            Insurar insurar = invoice.getInsurar();
            String sInsurarContactData = insurar.getContact();
            insurarTable.addCell(createValueCell(sInsurarContactData,1));

            // title = insurar name
            table.addCell(createGrayCell(insurar.getOfficialName().toUpperCase(),1,9,Font.BOLD));
            cell = createCell(new PdfPCell(insurarTable),1,PdfPCell.ALIGN_CENTER,PdfPCell.BOX);
            cell.setPadding(cellPadding);
            table.addCell(cell);

            doc.add(table);
            addBlankRow();
        }
        catch(Exception e){
            e.printStackTrace();
        }
    }

    //--- PRINT INVOICE ---------------------------------------------------------------------------
    protected void printInvoice(InsurarInvoice invoice){
        try {
            PdfPTable table = new PdfPTable(1);
            table.setWidthPercentage(pageWidth);

            // invoice id
            cell = new PdfPCell(getInvoiceId(invoice));
            cell.setPadding(cellPadding);
            table.addCell(createCell(cell,1,PdfPCell.ALIGN_LEFT,PdfPCell.BOX));
            table.addCell(createEmptyCell(1));

            // debets
            table.addCell(createGrayCell(getTran("web","invoiceDebets").toUpperCase(),1));
            getDebets(invoice,table);
            table.addCell(createEmptyCell(1));

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
            cell = new PdfPCell(getSaldo());
            cell.setPadding(cellPadding);
            saldoTable.addCell(createCell(cell,1,PdfPCell.ALIGN_LEFT,PdfPCell.BOX));
            table.addCell(createCell(new PdfPCell(saldoTable),1,PdfPCell.ALIGN_CENTER,PdfPCell.NO_BORDER));
            table.addCell(createEmptyCell(1));


            doc.add(table);
        }
        catch(Exception e){
            e.printStackTrace();
        }
    }

    //### PRIVATE METHODS #########################################################################

    //--- GET DEBETS (prestations) ----------------------------------------------------------------
    // grouped by patient, sorted on date desc
    private void getDebets(InsurarInvoice invoice, PdfPTable tableParent){
        if(PrintType.equalsIgnoreCase("sortbypatient")){
            Vector debets = InsurarInvoice.getDebetsForInvoice(invoice.getUid());
            if(debets.size() > 0){
                PdfPTable table = new PdfPTable(20);
                table.setWidthPercentage(pageWidth);
                // header
                cell = createUnderlinedCell(getTran("web","patientordate"),1);
                PdfPTable singleCellHeaderTable = new PdfPTable(1);
                singleCellHeaderTable.addCell(cell);
                cell = createCell(new PdfPCell(singleCellHeaderTable),3,PdfPCell.ALIGN_CENTER,PdfPCell.NO_BORDER);
                cell.setPaddingRight(2);
                table.addCell(cell);

                cell = createUnderlinedCell(getTran("web","encounter"),1);
                singleCellHeaderTable = new PdfPTable(1);
                singleCellHeaderTable.addCell(cell);
                cell = createCell(new PdfPCell(singleCellHeaderTable),4,PdfPCell.ALIGN_CENTER,PdfPCell.NO_BORDER);
                cell.setPaddingRight(2);
                table.addCell(cell);

                cell = createUnderlinedCell(getTran("web","invoice"),1);
                singleCellHeaderTable = new PdfPTable(1);
                singleCellHeaderTable.addCell(cell);
                cell = createCell(new PdfPCell(singleCellHeaderTable),2,PdfPCell.ALIGN_CENTER,PdfPCell.NO_BORDER);
                cell.setPaddingRight(2);
                table.addCell(cell);

                cell = createUnderlinedCell(getTran("web","prestation"),1);
                singleCellHeaderTable = new PdfPTable(1);
                singleCellHeaderTable.addCell(cell);
                cell = createCell(new PdfPCell(singleCellHeaderTable),6,PdfPCell.ALIGN_CENTER,PdfPCell.NO_BORDER);
                cell.setPaddingRight(2);
                table.addCell(cell);

                cell = createUnderlinedCell("#",1);
                singleCellHeaderTable = new PdfPTable(1);
                singleCellHeaderTable.addCell(cell);
                cell = createCell(new PdfPCell(singleCellHeaderTable),1,PdfPCell.ALIGN_CENTER,PdfPCell.NO_BORDER);
                cell.setPaddingRight(2);
                table.addCell(cell);

                cell = createUnderlinedCell(getTran("web","unitprice.abbreviation"),1);
                singleCellHeaderTable = new PdfPTable(1);
                singleCellHeaderTable.addCell(cell);
                cell = createCell(new PdfPCell(singleCellHeaderTable),2,PdfPCell.ALIGN_CENTER,PdfPCell.NO_BORDER);
                cell.setPaddingRight(2);
                table.addCell(cell);

                cell = createUnderlinedCell(getTran("web","amount"),1);
                cell.setHorizontalAlignment(PdfPCell.ALIGN_RIGHT);
                singleCellHeaderTable = new PdfPTable(1);
                singleCellHeaderTable.addCell(cell);
                cell = createCell(new PdfPCell(singleCellHeaderTable),2,PdfPCell.ALIGN_CENTER,PdfPCell.NO_BORDER);
                table.addCell(cell);

                cell=new PdfPCell(table);
                cell.setPadding(cellPadding);
                tableParent.addCell(createCell(cell,1,PdfPCell.ALIGN_LEFT,PdfPCell.NO_BORDER));

                // print debets
                double total = 0;
                Debet debet;
                String sPatientName, sPrevPatientName = "";
                boolean displayPatientName;
                int counter=0;
                for(int i=0; i<debets.size(); i++){
                    table = new PdfPTable(20);
                    table.setWidthPercentage(pageWidth);
                    debet = (Debet)debets.get(i);
                    sPatientName = debet.getPatientName()+";"+debet.getEncounter().getPatientUID();
                    displayPatientName = !sPatientName.equals(sPrevPatientName);
                    if(displayPatientName){
                    	counter++;
                    }
                    total+= debet.getInsurarAmount();
                    printDebet(table,debet,displayPatientName,counter);
                    sPrevPatientName = sPatientName;
                    cell=new PdfPCell(table);
                    cell.setPadding(0);
                    tableParent.addCell(createCell(cell,1,PdfPCell.ALIGN_LEFT,PdfPCell.NO_BORDER));
                }

                table = new PdfPTable(20);
                // spacer
                table.addCell(createEmptyCell(20));

                // display debet total
                table.addCell(createEmptyCell(12));
                cell = createLabelCell(getTran("web","subtotalprice"),5);
                cell.setHorizontalAlignment(PdfPCell.ALIGN_RIGHT);
                cell.setPaddingRight(5);
                table.addCell(cell);
                table.addCell(createTotalPriceCellInsurar(total,3));
                cell=new PdfPCell(table);
                cell.setPadding(0);
                tableParent.addCell(createCell(cell,1,PdfPCell.ALIGN_LEFT,PdfPCell.NO_BORDER));

                this.insurarDebetTotal = total;
            }
            else{
                table.addCell(createValueCell(getTran("web","noDataAvailable"),20));
            }
        }
        else if(PrintType.equalsIgnoreCase("sortbyservice")){
        	SortedMap services = InsurarInvoice.getDebetsForInvoiceSortByService(invoice.getUid());
        	Iterator iServices = services.keySet().iterator();
        	while(iServices.hasNext()){
        		String serviceuid = (String)iServices.next();
        		//todo: First write header for this service
                tableParent.addCell(createEmptyCell(1));
                tableParent.addCell(createGrayCell(serviceuid.toUpperCase()+": "+ScreenHelper.getTranNoLink("service",serviceuid,sPrintLanguage).toUpperCase(),1,12));
        		//Now write debets for this service
        		Vector debets = (Vector)services.get(serviceuid);
        		if(debets.size()>0){
                    PdfPTable table = new PdfPTable(200);
                    table.setWidthPercentage(pageWidth);
                    // header
                    cell = createUnderlinedCell(getTran("web","patientordate"),1);
                    PdfPTable singleCellHeaderTable = new PdfPTable(1);
                    singleCellHeaderTable.addCell(cell);
                    cell = createCell(new PdfPCell(singleCellHeaderTable),30,PdfPCell.ALIGN_CENTER,PdfPCell.NO_BORDER);
                    cell.setPaddingRight(2);
                    table.addCell(cell);

                    cell = createUnderlinedCell(getTran("web","encounter"),1);
                    singleCellHeaderTable = new PdfPTable(1);
                    singleCellHeaderTable.addCell(cell);
                    cell = createCell(new PdfPCell(singleCellHeaderTable),35,PdfPCell.ALIGN_CENTER,PdfPCell.NO_BORDER);
                    cell.setPaddingRight(2);
                    table.addCell(cell);

                    cell = createUnderlinedCell(getTran("web","fac"),1);
                    singleCellHeaderTable = new PdfPTable(1);
                    singleCellHeaderTable.addCell(cell);
                    cell = createCell(new PdfPCell(singleCellHeaderTable),15,PdfPCell.ALIGN_CENTER,PdfPCell.NO_BORDER);
                    cell.setPaddingRight(2);
                    table.addCell(cell);

                    cell = createUnderlinedCell(getTran("web","prestation"),1);
                    singleCellHeaderTable = new PdfPTable(1);
                    singleCellHeaderTable.addCell(cell);
                    cell = createCell(new PdfPCell(singleCellHeaderTable),65,PdfPCell.ALIGN_CENTER,PdfPCell.NO_BORDER);
                    cell.setPaddingRight(2);
                    table.addCell(cell);

                    cell = createUnderlinedCell("#",1);
                    singleCellHeaderTable = new PdfPTable(1);
                    singleCellHeaderTable.addCell(cell);
                    cell = createCell(new PdfPCell(singleCellHeaderTable),10,PdfPCell.ALIGN_CENTER,PdfPCell.NO_BORDER);
                    cell.setPaddingRight(2);
                    table.addCell(cell);

                    cell = createUnderlinedCell(getTran("web","unitprice.abbreviation"),1);
                    singleCellHeaderTable = new PdfPTable(1);
                    singleCellHeaderTable.addCell(cell);
                    cell = createCell(new PdfPCell(singleCellHeaderTable),20,PdfPCell.ALIGN_CENTER,PdfPCell.NO_BORDER);
                    cell.setPaddingRight(2);
                    table.addCell(cell);

                    cell = createUnderlinedCell(getTran("web","amount"),1);
                    cell.setHorizontalAlignment(PdfPCell.ALIGN_RIGHT);
                    singleCellHeaderTable = new PdfPTable(1);
                    singleCellHeaderTable.addCell(cell);
                    cell = createCell(new PdfPCell(singleCellHeaderTable),25,PdfPCell.ALIGN_CENTER,PdfPCell.NO_BORDER);
                    table.addCell(cell);

                    cell=new PdfPCell(table);
                    cell.setPadding(cellPadding);
                    tableParent.addCell(createCell(cell,1,PdfPCell.ALIGN_LEFT,PdfPCell.NO_BORDER));

                    // print debets
                    double total = 0;
                    Debet debet;
                    String sPatientName, sPrevPatientName = "";
                    Date date=null,prevdate=null;
                    boolean displayPatientName,displayDate;
                    int counter=0;
                    for(int i=0; i<debets.size(); i++){
                        table = new PdfPTable(200);
                        table.setWidthPercentage(pageWidth);
                        debet = (Debet)debets.get(i);
                        date = debet.getDate();
                        displayDate = !date.equals(prevdate);
                        sPatientName = debet.getPatientName();
                        displayPatientName = displayDate || !sPatientName.equals(sPrevPatientName);
                        if(displayPatientName){
                        	counter++;
                        }
                        total+= debet.getInsurarAmount();
                        printDebet2(table,debet,displayDate,displayPatientName,counter);
                        prevdate = date;
                        sPrevPatientName = sPatientName;
                        cell=new PdfPCell(table);
                        cell.setPadding(0);
                        tableParent.addCell(createCell(cell,1,PdfPCell.ALIGN_LEFT,PdfPCell.NO_BORDER));
                    }

                    table = new PdfPTable(20);
                    // spacer
                    table.addCell(createEmptyCell(20));

                    // display debet total
                    table.addCell(createEmptyCell(12));
                    cell = createLabelCell(getTran("web","subtotalprice"),5);
                    cell.setHorizontalAlignment(PdfPCell.ALIGN_RIGHT);
                    cell.setPaddingRight(5);
                    table.addCell(cell);
                    table.addCell(createTotalPriceCellInsurar(total,3));
                    cell=new PdfPCell(table);
                    cell.setPadding(0);
                    tableParent.addCell(createCell(cell,1,PdfPCell.ALIGN_LEFT,PdfPCell.NO_BORDER));

                    this.insurarDebetTotal = total;
                }
                else{
                    table.addCell(createValueCell(getTran("web","noDataAvailable"),20));
                }
        	}
        }
        else if(PrintType.equalsIgnoreCase("sortbydate")){
            Vector debets = InsurarInvoice.getDebetsForInvoiceSortByDate(invoice.getUid());
            if(debets.size() > 0){
                PdfPTable table = new PdfPTable(200);
                table.setWidthPercentage(pageWidth);
                // header
                cell = createUnderlinedCell(getTran("web","patientordate"),1);
                PdfPTable singleCellHeaderTable = new PdfPTable(1);
                singleCellHeaderTable.addCell(cell);
                cell = createCell(new PdfPCell(singleCellHeaderTable),30,PdfPCell.ALIGN_CENTER,PdfPCell.NO_BORDER);
                cell.setPaddingRight(2);
                table.addCell(cell);

                cell = createUnderlinedCell(getTran("web","encounter"),1);
                singleCellHeaderTable = new PdfPTable(1);
                singleCellHeaderTable.addCell(cell);
                cell = createCell(new PdfPCell(singleCellHeaderTable),35,PdfPCell.ALIGN_CENTER,PdfPCell.NO_BORDER);
                cell.setPaddingRight(2);
                table.addCell(cell);

                cell = createUnderlinedCell(getTran("web","fac"),1);
                singleCellHeaderTable = new PdfPTable(1);
                singleCellHeaderTable.addCell(cell);
                cell = createCell(new PdfPCell(singleCellHeaderTable),15,PdfPCell.ALIGN_CENTER,PdfPCell.NO_BORDER);
                cell.setPaddingRight(2);
                table.addCell(cell);

                cell = createUnderlinedCell(getTran("web","prestation"),1);
                singleCellHeaderTable = new PdfPTable(1);
                singleCellHeaderTable.addCell(cell);
                cell = createCell(new PdfPCell(singleCellHeaderTable),65,PdfPCell.ALIGN_CENTER,PdfPCell.NO_BORDER);
                cell.setPaddingRight(2);
                table.addCell(cell);

                cell = createUnderlinedCell("#",1);
                singleCellHeaderTable = new PdfPTable(1);
                singleCellHeaderTable.addCell(cell);
                cell = createCell(new PdfPCell(singleCellHeaderTable),10,PdfPCell.ALIGN_CENTER,PdfPCell.NO_BORDER);
                cell.setPaddingRight(2);
                table.addCell(cell);

                cell = createUnderlinedCell(getTran("web","unitprice.abbreviation"),1);
                singleCellHeaderTable = new PdfPTable(1);
                singleCellHeaderTable.addCell(cell);
                cell = createCell(new PdfPCell(singleCellHeaderTable),20,PdfPCell.ALIGN_CENTER,PdfPCell.NO_BORDER);
                cell.setPaddingRight(2);
                table.addCell(cell);

                cell = createUnderlinedCell(getTran("web","amount"),1);
                cell.setHorizontalAlignment(PdfPCell.ALIGN_RIGHT);
                singleCellHeaderTable = new PdfPTable(1);
                singleCellHeaderTable.addCell(cell);
                cell = createCell(new PdfPCell(singleCellHeaderTable),25,PdfPCell.ALIGN_CENTER,PdfPCell.NO_BORDER);
                table.addCell(cell);

                cell=new PdfPCell(table);
                cell.setPadding(cellPadding);
                tableParent.addCell(createCell(cell,1,PdfPCell.ALIGN_LEFT,PdfPCell.NO_BORDER));

                // print debets
                double total = 0;
                Debet debet;
                String sPatientName, sPrevPatientName = "";
                Date date=null,prevdate=null;
                boolean displayPatientName,displayDate;
                int counter=0;
                for(int i=0; i<debets.size(); i++){
                    table = new PdfPTable(200);
                    table.setWidthPercentage(pageWidth);
                    debet = (Debet)debets.get(i);
                    try {
						date = stdDateFormat.parse(stdDateFormat.format(debet.getDate()));
					} catch (ParseException e) {
						e.printStackTrace();
					}
                    displayDate = !date.equals(prevdate);
                    sPatientName = debet.getPatientName();
                    displayPatientName = displayDate || !sPatientName.equals(sPrevPatientName);
                    if(displayPatientName){
                    	counter++;
                    }
                    total+= debet.getInsurarAmount();
                    printDebet2(table,debet,displayDate,displayPatientName,counter);
                    prevdate = date;
                    sPrevPatientName = sPatientName;
                    cell=new PdfPCell(table);
                    cell.setPadding(0);
                    tableParent.addCell(createCell(cell,1,PdfPCell.ALIGN_LEFT,PdfPCell.NO_BORDER));
                }

                table = new PdfPTable(20);
                // spacer
                table.addCell(createEmptyCell(20));

                // display debet total
                table.addCell(createEmptyCell(12));
                cell = createLabelCell(getTran("web","subtotalprice"),5);
                cell.setHorizontalAlignment(PdfPCell.ALIGN_RIGHT);
                cell.setPaddingRight(5);
                table.addCell(cell);
                table.addCell(createTotalPriceCellInsurar(total,3));
                cell=new PdfPCell(table);
                cell.setPadding(0);
                tableParent.addCell(createCell(cell,1,PdfPCell.ALIGN_LEFT,PdfPCell.NO_BORDER));

                this.insurarDebetTotal = total;
            }
            else{
                table.addCell(createValueCell(getTran("web","noDataAvailable"),20));
            }
        }
    }

    //--- GET CREDITS (payments) (sorted on date desc) --------------------------------------------
    private PdfPTable getCredits(InsurarInvoice invoice){
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
            cell = createCell(new PdfPCell(singleCellHeaderTable),5,PdfPCell.ALIGN_CENTER,PdfPCell.NO_BORDER);
            cell.setPaddingRight(2);
            table.addCell(cell);

            cell = createUnderlinedCell(getTran("web","comment"),1);
            cell.setBorderColorBottom(innerBorderColor);
            singleCellHeaderTable = new PdfPTable(1);
            singleCellHeaderTable.addCell(cell);
            cell = createCell(new PdfPCell(singleCellHeaderTable),10,PdfPCell.ALIGN_CENTER,PdfPCell.NO_BORDER);
            cell.setPaddingRight(2);
            table.addCell(cell);

            cell = createUnderlinedCell(getTran("web","amount"),1);
            cell.setBorderColorBottom(innerBorderColor);
            cell.setHorizontalAlignment(PdfPCell.ALIGN_RIGHT);
            singleCellHeaderTable = new PdfPTable(1);
            singleCellHeaderTable.addCell(cell);
            cell = createCell(new PdfPCell(singleCellHeaderTable),3,PdfPCell.ALIGN_CENTER,PdfPCell.NO_BORDER);
            table.addCell(cell);

            // get credits from uids
            double total = 0;
            Hashtable creditsHash = new Hashtable();
            InsurarCredit credit;
            String sCreditUid;

            for(int i=0; i<creditUids.size(); i++){
                sCreditUid = (String)creditUids.get(i);
                credit = InsurarCredit.get(sCreditUid);
                creditsHash.put(credit.getDate(),credit);
            }

            // sort credits on date
            Vector creditDates = new Vector(creditsHash.keySet());
            Collections.sort(creditDates);
            Collections.reverse(creditDates);

            java.util.Date creditDate;
            for(int i=0; i<creditDates.size(); i++){
                creditDate = (java.util.Date)creditDates.get(i);
                credit = (InsurarCredit)creditsHash.get(creditDate);
                total+= credit.getAmount();
                printCredit(table,credit);
            }

            // spacer
            table.addCell(createEmptyCell(20));

            // display credit total
            table.addCell(createEmptyCell(12));
            cell = createLabelCell(getTran("web","subtotalprice"),5);
            cell.setHorizontalAlignment(PdfPCell.ALIGN_RIGHT);
            cell.setPaddingRight(5);
            table.addCell(cell);
            table.addCell(createTotalPriceCell(total,3));

            this.creditTotal = total;
        }
        else{
            table.addCell(createValueCell(getTran("web","noDataAvailable"),20));
        }

        return table;
    }

    //--- PRINT DEBET (prestation) ----------------------------------------------------------------
    private void printDebet(PdfPTable invoiceTable, Debet debet, boolean displayPatientName,int counter){
        String sDebetDate = stdDateFormat.format(debet.getDate());
        double debetAmount = debet.getInsurarAmount();

        // encounter
        Encounter encounter = debet.getEncounter();
        String sEncounterName = "ERROR : encounter not found";
        if(encounter!=null){
            sEncounterName = checkString(encounter.getEncounterDisplayNameNoDate(this.sPrintLanguage));
        }

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
        if(displayPatientName){
            String insuranceMemberNumber="";
            try{
                Insurance insurance = debet.getInsurance();
                if(insurance!=null && insurance.getInsuranceNr().length()>0){
                    insuranceMemberNumber = "#"+insurance.getInsuranceNr();
                    if(insurance.getMember().length()>0){
                    	insuranceMemberNumber+=" ("+getTran("insurance.status","affiliate")+": "+insurance.getMember()+")";
                    }
                }
            }
            catch(Exception e){
                e.printStackTrace();
            }
            invoiceTable.addCell(createValueCell(counter+". "+debet.getPatientName()+" °"+debet.getEncounter().getPatient().dateOfBirth+" "+debet.getEncounter().getPatient().gender+" "+insuranceMemberNumber,20,7,Font.BOLD));
        }
        invoiceTable.addCell(createEmptyCell(1));
        invoiceTable.addCell(createValueCell(sDebetDate,2));
        invoiceTable.addCell(createValueCell(sEncounterName,4));
        invoiceTable.addCell(createValueCell(debet.getPatientInvoiceUid()==null?"":debet.getPatientInvoiceUid().replaceAll("1\\.", ""),2));
        invoiceTable.addCell(createValueCell(sPrestationCode+sPrestationDescr,6));
        invoiceTable.addCell(createValueCell(debet.getQuantity()+"",1));
        invoiceTable.addCell(createValueCell(priceFormat.format(debetAmount/debet.getQuantity()),2));
        invoiceTable.addCell(createPriceCellInsurar(debetAmount,2));
    }

    //--- PRINT DEBET (prestation) ----------------------------------------------------------------
    private void printDebet2(PdfPTable invoiceTable, Debet debet, boolean displayDate,boolean displayPatientName,int counter){
        String sDebetDate = stdDateFormat.format(debet.getDate());
        double debetAmount = debet.getInsurarAmount();

        // encounter
        Encounter encounter = debet.getEncounter();
        String sEncounterName = "ERROR : encounter not found";
        if(encounter!=null){
            sEncounterName = checkString(encounter.getEncounterDisplayNameNoDate(this.sPrintLanguage));
        }

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
        if(displayDate){
            invoiceTable.addCell(createValueCell(new SimpleDateFormat("dd/MM/yyyy").format(debet.getDate()),200,7,Font.BOLD));
        }
        if(displayPatientName){
            String insuranceMemberNumber="";
            try{
                Insurance insurance = debet.getInsurance();
                if(insurance!=null && insurance.getInsuranceNr().length()>0){
                    insuranceMemberNumber = "#"+insurance.getInsuranceNr();
                    if(insurance.getMember().length()>0){
                    	insuranceMemberNumber+=" ("+getTran("insurance.status","affiliate")+": "+insurance.getMember()+")";
                    }
                }
            }
            catch(Exception e){
                e.printStackTrace();
            }
            invoiceTable.addCell(createEmptyCell(10));
            invoiceTable.addCell(createValueCell(counter+". "+debet.getPatientName()+" °"+debet.getEncounter().getPatient().dateOfBirth+" "+debet.getEncounter().getPatient().gender+" "+insuranceMemberNumber,190,7,Font.BOLD));
        }
        invoiceTable.addCell(createEmptyCell(30));
        invoiceTable.addCell(createValueCell(sEncounterName,35));
        invoiceTable.addCell(createValueCell(ScreenHelper.checkString(debet.getPatientInvoiceUid()).replaceAll("1\\.",""),15));
        invoiceTable.addCell(createValueCell(sPrestationCode+sPrestationDescr,65));
        invoiceTable.addCell(createValueCell(debet.getQuantity()+"",10));
        invoiceTable.addCell(createValueCell(priceFormat.format(debetAmount/debet.getQuantity()),20));
        invoiceTable.addCell(createPriceCellInsurar(debetAmount,25));
    }

    //--- PRINT CREDIT (payment) ------------------------------------------------------------------
    private double printCredit(PdfPTable invoiceTable, InsurarCredit credit){
        String sCreditDate = stdDateFormat.format(credit.getDate());
        double creditAmount = credit.getAmount();
        String sCreditComment = checkString(credit.getComment());
        String sCreditType = getTran("credit.type",credit.getType());

        // row
        invoiceTable.addCell(createValueCell(sCreditDate,2));
        invoiceTable.addCell(createValueCell(sCreditType,5));
        invoiceTable.addCell(createValueCell(sCreditComment,10));
        invoiceTable.addCell(createPriceCell(creditAmount,3));

        return creditAmount;
    }

    //--- GET SALDO -------------------------------------------------------------------------------
    private PdfPTable getSaldo(){
        PdfPTable table = new PdfPTable(20);
        table.setWidthPercentage(pageWidth);

        // debets
        table.addCell(createEmptyCell(12));
        cell = createLabelCell(getTran("web","invoiceDebets"),5);
        cell.setHorizontalAlignment(PdfPCell.ALIGN_RIGHT);
        cell.setPaddingRight(5);
        table.addCell(cell);
        table.addCell(createPriceCell(this.insurarDebetTotal,3));

        // credits
        table.addCell(createEmptyCell(12));
        cell = createLabelCell(getTran("web","invoiceCredits"),5);
        cell.setHorizontalAlignment(PdfPCell.ALIGN_RIGHT);
        cell.setPaddingRight(5);
        table.addCell(cell);
        table.addCell(createPriceCell(this.creditTotal,(this.creditTotal>=0),3));

        // spacer
        table.addCell(createEmptyCell(20));

        // saldo
        double saldo = (this.insurarDebetTotal - Math.abs(this.creditTotal));
        table.addCell(createEmptyCell(12));
        cell = createBoldLabelCell(getTran("web","totalprice").toUpperCase(),5);
        cell.setHorizontalAlignment(PdfPCell.ALIGN_RIGHT);
        cell.setPaddingRight(5);
        table.addCell(cell);
        table.addCell(createTotalPriceCell(saldo,3));

        return table;
    }

}