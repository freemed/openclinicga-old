package be.mxs.common.util.pdf.general;

import com.lowagie.text.pdf.*;
import com.lowagie.text.*;

import java.util.*;
import java.io.ByteArrayOutputStream;
import java.text.DecimalFormat;
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
import net.admin.*;

public class PDFInsurarInvoiceGeneratorRAMA extends PDFInvoiceGenerator {
    String PrintType;

    //--- CONSTRUCTOR -----------------------------------------------------------------------------
    public PDFInsurarInvoiceGeneratorRAMA(User user, String sProject, String sPrintLanguage, String PrintType){
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
        cell.setBorder(Cell.BOX);
        table.addCell(cell);
        table.addCell(createCell(new PdfPCell(getPrintedByInfo()),2,Cell.ALIGN_LEFT,Cell.NO_BORDER));
        cell = createBoldLabelCell(getTran("invoiceDirector"),1);
        table.addCell(cell);
        doc.add(table);
    }
    //---- ADD HEADING (logo & barcode) -----------------------------------------------------------
    private void addHeading(InsurarInvoice invoice) throws Exception {
        table = new PdfPTable(10);
        table.setWidthPercentage(pageWidth);

        try {
            //*** logo ***
            try{
                Image img = Miscelaneous.getImage("logo_"+sProject+".gif",sProject);
                img.scalePercent(50);
                cell = new PdfPCell(img);
                cell.setBorder(Cell.NO_BORDER);
                cell.setColspan(2);
                table.addCell(cell);
            }
            catch(NullPointerException e){
                Debug.println("WARNING : PDFPatientInvoiceGenerator --> IMAGE NOT FOUND : logo_"+sProject+".gif");
                e.printStackTrace();
            }

            //*** barcode ***
            PdfContentByte cb = docWriter.getDirectContent();
            Barcode39 barcode39 = new Barcode39();
            barcode39.setCode("6"+invoice.getInvoiceUid());
            Image image = barcode39.createImageWithBarcode(cb,null,null);
            cell = new PdfPCell(image);
            cell.setHorizontalAlignment(Cell.ALIGN_LEFT);
            cell.setBorder(Cell.NO_BORDER);
            cell.setColspan(2);
            table.addCell(cell);

            Report_Identification report_identification = new Report_Identification(invoice.getDate());
            PdfPTable table2 = new PdfPTable(5);
            cell=createLabelCell(MedwanQuery.getInstance().getLabel("report.monthly","province",user.person.language), 1);
            table2.addCell(cell);
            cell=createBoldLabelCell(MedwanQuery.getInstance().getLabel("province",report_identification.getItem("OC_HC_PROVINCE"),user.person.language), 3);
            table2.addCell(cell);
            String month="";
            Vector debets = InsurarInvoice.getDebetsForInvoiceSortByDate(invoice.getUid());
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
            cell=createLabelCell(MedwanQuery.getInstance().getLabel("web","month",user.person.language)+": "+month+new SimpleDateFormat("/yyyy").format(invoice.getDate()), 1);
            table2.addCell(cell);
            cell=createLabelCell(MedwanQuery.getInstance().getLabel("report.monthly","district",user.person.language), 1);
            table2.addCell(cell);
            cell=createBoldLabelCell(report_identification.getItem("OC_HC_DISTRICT"), 3);
            table2.addCell(cell);
            cell=createEmptyCell(1);
            table2.addCell(cell);
            cell=createLabelCell(MedwanQuery.getInstance().getLabel("report.monthly","fosa",user.person.language), 1);
            table2.addCell(cell);
            cell=createBoldLabelCell(report_identification.getItem("OC_HC_FOSA"), 3);
            table2.addCell(cell);
            cell=createEmptyCell(1);
            table2.addCell(cell);
            
            cell=new PdfPCell(table2);
            cell.setBorder(Cell.NO_BORDER);
            cell.setColspan(6);
            
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

        try {
            Insurar insurar = invoice.getInsurar();

            // title = insurar name
            table.addCell(createGrayCell(MedwanQuery.getInstance().getLabel("web.occup", "invoice_summary", user.person.language)+" "+insurar.getOfficialName().toUpperCase(),1,9,Font.BOLD));

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

            // debets
            getDebets(invoice,table);
            table.addCell(createEmptyCell(1));

            // "pay to" info
            PdfPTable payToTable = new PdfPTable(1);
            payToTable.addCell(createGrayCell(getTran("web","payToInfo").toUpperCase(),1));
            cell = new PdfPCell(getPayToInfo());
            cell.setPadding(cellPadding);
            payToTable.addCell(createCell(cell,1,Cell.ALIGN_LEFT,Cell.BOX));
            table.addCell(createCell(new PdfPCell(payToTable),1,Cell.ALIGN_CENTER,Cell.NO_BORDER));
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
    private void getDebets(InsurarInvoice invoice, PdfPTable tableParent){

        Vector debets = InsurarInvoice.getDebetsForInvoiceSortByDate(invoice.getUid());
        if(debets.size() > 0){
            PdfPTable table = new PdfPTable(200);
            table.setWidthPercentage(pageWidth);
            // header
            cell = createUnderlinedCell("#",1);
            PdfPTable singleCellHeaderTable = new PdfPTable(1);
            singleCellHeaderTable.addCell(cell);
            cell = createCell(new PdfPCell(singleCellHeaderTable),7,Cell.ALIGN_LEFT,Cell.NO_BORDER);
            cell.setPaddingRight(2);
            table.addCell(cell);

            cell = createUnderlinedCell(getTran("web","date"),1);
            singleCellHeaderTable = new PdfPTable(1);
            singleCellHeaderTable.addCell(cell);
            cell = createCell(new PdfPCell(singleCellHeaderTable),13,Cell.ALIGN_LEFT,Cell.NO_BORDER);
            cell.setPaddingRight(2);
            table.addCell(cell);

            cell = createUnderlinedCell(getTran("web","fac"),1);
            singleCellHeaderTable = new PdfPTable(1);
            singleCellHeaderTable.addCell(cell);
            cell = createCell(new PdfPCell(singleCellHeaderTable),15,Cell.ALIGN_LEFT,Cell.NO_BORDER);
            cell.setPaddingRight(2);
            table.addCell(cell);

            cell = createUnderlinedCell(getTran("web","numero_affiliation"),1);
            singleCellHeaderTable = new PdfPTable(1);
            singleCellHeaderTable.addCell(cell);
            cell = createCell(new PdfPCell(singleCellHeaderTable),15,Cell.ALIGN_LEFT,Cell.NO_BORDER);
            cell.setPaddingRight(2);
            table.addCell(cell);

            cell = createUnderlinedCell(getTran("web","adherent"),1);
            singleCellHeaderTable = new PdfPTable(1);
            singleCellHeaderTable.addCell(cell);
            cell = createCell(new PdfPCell(singleCellHeaderTable),30,Cell.ALIGN_LEFT,Cell.NO_BORDER);
            cell.setPaddingRight(2);
            table.addCell(cell);

            cell = createUnderlinedCell(getTran("web","beneficiary"),1);
            singleCellHeaderTable = new PdfPTable(1);
            singleCellHeaderTable.addCell(cell);
            cell = createCell(new PdfPCell(singleCellHeaderTable),30,Cell.ALIGN_LEFT,Cell.NO_BORDER);
            cell.setPaddingRight(2);
            table.addCell(cell);

            cell = createUnderlinedCell(getTran("web","prestations_100pct"),1);
            cell.setHorizontalAlignment(Cell.ALIGN_LEFT);
            singleCellHeaderTable = new PdfPTable(1);
            singleCellHeaderTable.addCell(cell);
            cell = createCell(new PdfPCell(singleCellHeaderTable),50,Cell.ALIGN_LEFT,Cell.NO_BORDER);
            table.addCell(cell);

            cell = createUnderlinedCell(getTran("web","total_100pct"),1);
            cell.setHorizontalAlignment(Cell.ALIGN_LEFT);
            singleCellHeaderTable = new PdfPTable(1);
            singleCellHeaderTable.addCell(cell);
            cell = createCell(new PdfPCell(singleCellHeaderTable),20,Cell.ALIGN_LEFT,Cell.NO_BORDER);
            table.addCell(cell);

            cell = createUnderlinedCell(getTran("web","total_85pct"),1);
            cell.setHorizontalAlignment(Cell.ALIGN_LEFT);
            singleCellHeaderTable = new PdfPTable(1);
            singleCellHeaderTable.addCell(cell);
            cell = createCell(new PdfPCell(singleCellHeaderTable),20,Cell.ALIGN_LEFT,Cell.NO_BORDER);
            table.addCell(cell);

            cell=new PdfPCell(table);
            cell.setPadding(cellPadding);
            tableParent.addCell(createCell(cell,1,Cell.ALIGN_LEFT,Cell.NO_BORDER));

            // print debets
            Debet debet;
            String sPatientName="", sPrevPatientName = "",sPreviousInvoiceUID="";
            Date date=null,prevdate=null;
            boolean displayPatientName=false,displayDate=false;
            SortedMap categories = new TreeMap(), totalcategories = new TreeMap();
            double total100pct=0,total85pct=0,generaltotal100pct=0,generaltotal85pct=0,daytotal100pct=0,daytotal85pct=0;
            String invoiceid="",adherent="",recordnumber="";
            int linecounter=1;
            for(int i=0; i<debets.size(); i++){
                debet = (Debet)debets.get(i);
                date = debet.getDate();
                displayDate = !date.equals(prevdate);
                sPatientName = debet.getPatientName();
                displayPatientName = displayDate || !sPatientName.equals(sPrevPatientName) || (debet.getPatientInvoiceUid()!=null && invoiceid.indexOf(debet.getPatientInvoiceUid())<0 && invoiceid.length()>0);
                if(i>0 && (displayDate || displayPatientName)){
                    table = new PdfPTable(2000);
                    table.setWidthPercentage(pageWidth);
                    printDebet2(table,categories,displayDate,prevdate!=null?prevdate:date,invoiceid,adherent,sPrevPatientName,total100pct,total85pct,recordnumber,linecounter++,daytotal100pct,daytotal85pct);
                    cell=new PdfPCell(table);
                    cell.setPadding(0);
                    tableParent.addCell(createCell(cell,1,Cell.ALIGN_LEFT,Cell.NO_BORDER));
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
                }
                if(debet.getPatientInvoiceUid()!=null && invoiceid.indexOf(debet.getPatientInvoiceUid())<0){
                	if(invoiceid.length()>0){
                		invoiceid+="\n";
                	}
                	invoiceid+=debet.getPatientInvoiceUid();
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
                if(prestation!=null && prestation.getReferenceObject()!=null && prestation.getReferenceObject().getObjectType()!=null && prestation.getReferenceObject().getObjectType().length()>0){
                    if(categories.get(prestation.getReferenceObject().getObjectType())==null){
                        categories.put(prestation.getReferenceObject().getObjectType(),new Double(debet.getAmount()+debet.getInsurarAmount()+debet.getExtraInsurarAmount()));
                    }
                    else {
                        categories.put(prestation.getReferenceObject().getObjectType(),new Double(((Double)categories.get(prestation.getReferenceObject().getObjectType())).doubleValue()+debet.getAmount()+debet.getInsurarAmount()+debet.getExtraInsurarAmount()));
                    }
                    if(totalcategories.get(prestation.getReferenceObject().getObjectType())==null){
                        totalcategories.put(prestation.getReferenceObject().getObjectType(),new Double(debet.getAmount()+debet.getInsurarAmount()+debet.getExtraInsurarAmount()));
                    }
                    else {
                        totalcategories.put(prestation.getReferenceObject().getObjectType(),new Double(((Double)totalcategories.get(prestation.getReferenceObject().getObjectType())).doubleValue()+debet.getAmount()+debet.getInsurarAmount()+debet.getExtraInsurarAmount()));
                    }
                }
                else {
                    if(categories.get("OTHER")==null){
                        categories.put("OTHER",new Double(debet.getAmount()+debet.getInsurarAmount()+debet.getExtraInsurarAmount()));
                    }
                    else {
                        categories.put("OTHER",new Double(((Double)categories.get("OTHER")).doubleValue()+debet.getAmount()+debet.getInsurarAmount()+debet.getExtraInsurarAmount()));
                    }
                    if(totalcategories.get("OTHER")==null){
                        totalcategories.put("OTHER",new Double(debet.getAmount()+debet.getInsurarAmount()+debet.getExtraInsurarAmount()));
                    }
                    else {
                        totalcategories.put("OTHER",new Double(((Double)totalcategories.get("OTHER")).doubleValue()+debet.getAmount()+debet.getInsurarAmount()+debet.getExtraInsurarAmount()));
                    }
                }                
                total100pct+=debet.getAmount()+debet.getInsurarAmount()+debet.getExtraInsurarAmount();
                total85pct+=debet.getInsurarAmount();
                generaltotal100pct+=debet.getAmount()+debet.getInsurarAmount()+debet.getExtraInsurarAmount();
                generaltotal85pct+=debet.getInsurarAmount();
                daytotal100pct+=debet.getAmount()+debet.getInsurarAmount()+debet.getExtraInsurarAmount();
                daytotal85pct+=debet.getInsurarAmount();
                prevdate = date;
                sPrevPatientName = sPatientName;
            }
            if(debets.size()>0){
                table = new PdfPTable(2000);
                table.setWidthPercentage(pageWidth);
                printDebet2(table,categories,true,prevdate,invoiceid,adherent,sPrevPatientName,total100pct,total85pct,recordnumber,linecounter++,daytotal100pct,daytotal85pct);
                cell=new PdfPCell(table);
                cell.setPadding(0);
                tableParent.addCell(createCell(cell,1,Cell.ALIGN_LEFT,Cell.NO_BORDER));
            }

            table = new PdfPTable(2000);
            cell = createLabelCell("",2000);
            cell.setBorder(Cell.BOTTOM);
            table.addCell(cell);
            // display debet total
            table.addCell(createEmptyCell(800));
            cell = createLabelCell(getTran("web","subtotalprice"),300);
            cell.setHorizontalAlignment(Cell.ALIGN_RIGHT);
            cell.setPaddingRight(5);
            table.addCell(cell);
            PdfPTable categoryTable = new PdfPTable(4);
            //Voor alle categorieën, toon de totalen
            Iterator iterator = totalcategories.keySet().iterator();
            int counter=0;
            while(iterator.hasNext()){
            	if(counter==4){
            		counter=0;
            	}
            	counter++;
            	String category = (String)iterator.next();
                cell = createLabelCell(category+": "+priceFormatInsurar.format(totalcategories.get(category)),1);
                cell.setHorizontalAlignment(Cell.ALIGN_LEFT);
                cell.setPaddingRight(5);
                categoryTable.addCell(cell);
            }
            if(counter<4){
            	cell=createEmptyCell(4-counter);
                categoryTable.addCell(cell);
            }
            cell=new PdfPCell(categoryTable);
            cell.setColspan(500);
            cell.setBorder(Cell.BOX);
            table.addCell(cell);
            table.addCell(createEmptyCell(400));
            //Nu de totalen toevoegen
            table.addCell(createEmptyCell(800));
            cell = createLabelCell(getTran("web","totalprice"),300);
            cell.setHorizontalAlignment(Cell.ALIGN_RIGHT);
            cell.setPaddingRight(5);
            table.addCell(cell);
            table.addCell(createEmptyCell(500));
            cell = createLabelCell(priceFormatInsurar.format(generaltotal100pct)+" RWF",200);
            cell.setHorizontalAlignment(Cell.ALIGN_LEFT);
            cell.setBorder(Cell.BOX);
            cell.setPaddingRight(5);
            table.addCell(cell);
            cell = createLabelCell(priceFormatInsurar.format(generaltotal85pct)+" RWF",200);
            cell.setHorizontalAlignment(Cell.ALIGN_LEFT);
            cell.setBorder(Cell.BOX);
            cell.setPaddingRight(5);
            table.addCell(cell);

            cell=new PdfPCell(table);
            cell.setPadding(0);
            tableParent.addCell(createCell(cell,1,Cell.ALIGN_LEFT,Cell.NO_BORDER));

        }
    }

    //--- PRINT DEBET (prestation) ----------------------------------------------------------------
    private void printDebet2(PdfPTable invoiceTable, SortedMap categories, boolean displayDate, Date date, String invoiceid,String adherent,String beneficiary,double total100pct,double total85pct,String recordnumber,int linecounter,double daytotal100pct,double daytotal85pct){
    	cell = createLabelCell(linecounter+"",70);
        cell.setHorizontalAlignment(Cell.ALIGN_LEFT);
        cell.setVerticalAlignment(Cell.ALIGN_TOP);
        cell.setPaddingRight(5);
        invoiceTable.addCell(cell);
        cell = createLabelCell(new SimpleDateFormat("dd/MM/yyyy").format(date),130);
        cell.setHorizontalAlignment(Cell.ALIGN_LEFT);
        cell.setVerticalAlignment(Cell.ALIGN_TOP);
        cell.setPaddingRight(5);
        invoiceTable.addCell(cell);
        cell = createLabelCell(invoiceid,150);
        cell.setHorizontalAlignment(Cell.ALIGN_LEFT);
        cell.setVerticalAlignment(Cell.ALIGN_TOP);
        cell.setPaddingRight(5);
        invoiceTable.addCell(cell);
        cell = createLabelCell(recordnumber,150);
        cell.setHorizontalAlignment(Cell.ALIGN_LEFT);
        cell.setVerticalAlignment(Cell.ALIGN_TOP);
        cell.setPaddingRight(5);
        invoiceTable.addCell(cell);
        cell = createLabelCell(adherent,300);
        cell.setHorizontalAlignment(Cell.ALIGN_LEFT);
        cell.setVerticalAlignment(Cell.ALIGN_TOP);
        cell.setPaddingRight(5);
        invoiceTable.addCell(cell);
        cell = createLabelCell(beneficiary,300);
        cell.setHorizontalAlignment(Cell.ALIGN_LEFT);
        cell.setVerticalAlignment(Cell.ALIGN_TOP);
        cell.setPaddingRight(5);
        invoiceTable.addCell(cell);
        PdfPTable debetTable = new PdfPTable(4);
        debetTable.setWidthPercentage(100);
        Iterator iterator = categories.keySet().iterator();
        int counter=0;
        while(iterator.hasNext()){
        	if(counter==4){
        		counter=0;
        	}
        	counter++;
        	String category = (String)iterator.next();
            cell = createLabelCell(category+": "+ priceFormatInsurar.format(categories.get(category)),1);
            cell.setHorizontalAlignment(Cell.ALIGN_LEFT);
            cell.setVerticalAlignment(Cell.ALIGN_TOP);
            cell.setBorder(Cell.BOX);
            cell.setPaddingRight(5);
            debetTable.addCell(cell);
        }
        if(counter<4){
        	debetTable.addCell(createEmptyCell(4-counter));
        }
        cell = new PdfPCell(debetTable);
        cell.setColspan(500);
        cell.setVerticalAlignment(Cell.ALIGN_TOP);
        cell.setBorder(Cell.NO_BORDER);
        invoiceTable.addCell(cell);
        cell = createLabelCell(priceFormatInsurar.format(total100pct),200);
        cell.setHorizontalAlignment(Cell.ALIGN_LEFT);
        cell.setVerticalAlignment(Cell.ALIGN_TOP);
        cell.setPaddingRight(5);
        invoiceTable.addCell(cell);
        cell = createLabelCell(priceFormatInsurar.format(total85pct),200);
        cell.setHorizontalAlignment(Cell.ALIGN_LEFT);
        cell.setVerticalAlignment(Cell.ALIGN_TOP);
        cell.setPaddingRight(5);
        invoiceTable.addCell(cell);
    	if(displayDate){
    		invoiceTable.addCell(createEmptyCell(2000));
            //Nu de totalen toevoegen
    		invoiceTable.addCell(createEmptyCell(1400));
            cell = createUnderlinedCell(getTran("web","totalprice")+" "+new SimpleDateFormat("dd/MM/yyyy").format(date),200);
            cell.setHorizontalAlignment(Cell.ALIGN_RIGHT);
            cell.setPaddingRight(5);
            invoiceTable.addCell(cell);
            cell = createUnderlinedCell(priceFormatInsurar.format(daytotal100pct)+" RWF",200);
            cell.setHorizontalAlignment(Cell.ALIGN_LEFT);
            cell.setPaddingRight(5);
            invoiceTable.addCell(cell);
            cell = createUnderlinedCell(priceFormatInsurar.format(daytotal85pct)+" RWF",200);
            cell.setHorizontalAlignment(Cell.ALIGN_LEFT);
            cell.setPaddingRight(5);
            invoiceTable.addCell(cell);
    	}
        invoiceTable.addCell(createEmptyCell(2000));
    }

}