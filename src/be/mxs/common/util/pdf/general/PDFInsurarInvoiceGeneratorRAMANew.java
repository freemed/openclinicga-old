package be.mxs.common.util.pdf.general;

import com.itextpdf.text.pdf.*;
import com.itextpdf.text.*;

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

public class PDFInsurarInvoiceGeneratorRAMANew extends PDFInvoiceGenerator {
    String PrintType;
    double pageConsultationAmount=0,pageLabAmount=0,pageImagingAmount=0,pageAdmissionAmount=0,pageActsAmount=0,pageConsumablesAmount=0,pageOtherAmount=0,pageDrugsAmount=0,pageTotalAmount100=0,pageTotalAmount85=0;

    //--- CONSTRUCTOR -----------------------------------------------------------------------------
    public PDFInsurarInvoiceGeneratorRAMANew(User user, String sProject, String sPrintLanguage, String PrintType){
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
			doc.setMargins(1,1,20,20);
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
            }

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
            cell.setBorder(PdfPCell.NO_BORDER);
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
    private void getDebets(InsurarInvoice invoice) throws DocumentException{
    	
    	PdfPTable tableParent = new PdfPTable(1);
        tableParent.setWidthPercentage(pageWidth);
    	
        Vector debets = InsurarInvoice.getDebetsForInvoiceSortByDate(invoice.getUid());
        if(debets.size() > 0){
            cell=new PdfPCell(getTableHeader(invoice.getInsurar()));
            cell.setPadding(cellPadding);
            tableParent.addCell(createCell(cell,1,PdfPCell.ALIGN_LEFT,PdfPCell.NO_BORDER));

            // print debets
            Debet debet;
            String sPatientName="", sPrevPatientName = "",sPreviousInvoiceUID="";
            Date date=null,prevdate=null;
            boolean displayPatientName=false,displayDate=false;
            SortedMap categories = new TreeMap(), totalcategories = new TreeMap();
            double total100pct=0,total85pct=0,generaltotal100pct=0,generaltotal85pct=0,daytotal100pct=0,daytotal85pct=0;
            String invoiceid="",adherent="",recordnumber="",insurarreference="";
            int linecounter=1;
            for(int i=0; i<debets.size(); i++){
                debet = (Debet)debets.get(i);
                date = debet.getDate();
                displayDate = !date.equals(prevdate);
                sPatientName = debet.getPatientName()+";"+debet.getEncounter().getPatientUID();
                displayPatientName = displayDate || !sPatientName.equals(sPrevPatientName) || (debet.getPatientInvoiceUid()!=null && debet.getPatientInvoiceUid().indexOf(".")>=0 && invoiceid.indexOf(debet.getPatientInvoiceUid().split("\\.")[1])<0 && invoiceid.length()>0);
                if(i>0 && (displayDate || displayPatientName)){
                    table = new PdfPTable(2000);
                    table.setWidthPercentage(pageWidth);
                    printDebet2(table,categories,displayDate,prevdate!=null?prevdate:date,invoiceid,adherent,sPrevPatientName.split(";")[0],total100pct,total85pct,recordnumber,linecounter++,daytotal100pct,daytotal85pct,tableParent,insurarreference);
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

                        cell = createLabelCell(priceFormatInsurar.format(pageActsAmount),100,7);
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

                        cell = createLabelCell(priceFormatInsurar.format(pageOtherAmount),100,7);
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
                if(debet.getPatientInvoiceUid()!=null && debet.getPatientInvoiceUid().indexOf(".")>=0 && invoiceid.indexOf(debet.getPatientInvoiceUid().split("\\.")[1])<0){
                	if(invoiceid.length()>0){
                		invoiceid+="\n";
                	}
                	invoiceid+=debet.getPatientInvoiceUid().split("\\.")[1];
                	if(insurarreference.equalsIgnoreCase("")){
	                	PatientInvoice patientInvoice = PatientInvoice.get(debet.getPatientInvoiceUid());
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
                pageTotalAmount85+=rInsurarAmount;
                total100pct+=rTotal;
                total85pct+=rInsurarAmount;
                generaltotal100pct+=rTotal;
                generaltotal85pct+=rInsurarAmount;
                daytotal100pct+=rTotal;
                daytotal85pct+=rInsurarAmount;
                prevdate = date;
                sPrevPatientName = sPatientName;
            }
            table = new PdfPTable(2000);
            table.setWidthPercentage(pageWidth);
        	printDebet2(table,categories,true,prevdate,invoiceid,adherent,sPrevPatientName.split(";")[0],total100pct,total85pct,recordnumber,linecounter++,daytotal100pct,daytotal85pct,tableParent,insurarreference);
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

            cell = createLabelCell(priceFormatInsurar.format(pageActsAmount),100,7);
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

            cell = createLabelCell(priceFormatInsurar.format(pageOtherAmount),100,7);
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

            Double amount = (Double)totalcategories.get(MedwanQuery.getInstance().getConfigString("RAMAconsultationCategory","Co"));
            cell = createLabelCell(amount==null?"":priceFormatInsurar.format(amount),100,7);
            cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
            cell.setVerticalAlignment(PdfPCell.ALIGN_TOP);
            cell.setBorder(PdfPCell.BOX);
            cell.setPaddingRight(5);
            table.addCell(cell);

            amount = (Double)totalcategories.get(MedwanQuery.getInstance().getConfigString("RAMAlabCategory","L"));
            cell = createLabelCell(amount==null?"":priceFormatInsurar.format(amount),100,7);
            cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
            cell.setVerticalAlignment(PdfPCell.ALIGN_TOP);
            cell.setBorder(PdfPCell.BOX);
            cell.setPaddingRight(5);
            table.addCell(cell);

            amount = (Double)totalcategories.get(MedwanQuery.getInstance().getConfigString("RAMAimagingCategory","R"));
            cell = createLabelCell(amount==null?"":priceFormatInsurar.format(amount),100,7);
            cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
            cell.setVerticalAlignment(PdfPCell.ALIGN_TOP);
            cell.setBorder(PdfPCell.BOX);
            cell.setPaddingRight(5);
            table.addCell(cell);

            amount = (Double)totalcategories.get(MedwanQuery.getInstance().getConfigString("RAMAadmissionCategory","S"));
            cell = createLabelCell(amount==null?"":priceFormatInsurar.format(amount),100,7);
            cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
            cell.setVerticalAlignment(PdfPCell.ALIGN_TOP);
            cell.setBorder(PdfPCell.BOX);
            cell.setPaddingRight(5);
            table.addCell(cell);

            amount = (Double)totalcategories.get(MedwanQuery.getInstance().getConfigString("RAMAactsCategory","A"));
            cell = createLabelCell(amount==null?"":priceFormatInsurar.format(amount),100,7);
            cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
            cell.setVerticalAlignment(PdfPCell.ALIGN_TOP);
            cell.setBorder(PdfPCell.BOX);
            cell.setPaddingRight(5);
            table.addCell(cell);

            amount = (Double)totalcategories.get(MedwanQuery.getInstance().getConfigString("RAMAconsumablesCategory","C"));
            cell = createLabelCell(amount==null?"":priceFormatInsurar.format(amount),100,7);
            cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
            cell.setVerticalAlignment(PdfPCell.ALIGN_TOP);
            cell.setBorder(PdfPCell.BOX);
            cell.setPaddingRight(5);
            table.addCell(cell);

            double otherprice=0;
            String allcats=	"*"+MedwanQuery.getInstance().getConfigString("RAMAconsultationCategory","Co")+
    						"*"+MedwanQuery.getInstance().getConfigString("RAMAlabCategory","L")+
    						"*"+MedwanQuery.getInstance().getConfigString("RAMAimagingCategory","R")+
    						"*"+MedwanQuery.getInstance().getConfigString("RAMAadmissionCategory","S")+
    						"*"+MedwanQuery.getInstance().getConfigString("RAMAactsCategory","A")+
    						"*"+MedwanQuery.getInstance().getConfigString("RAMAconsumablesCategory","C")+
    						"*"+MedwanQuery.getInstance().getConfigString("RAMAdrugsCategory","M")+"*";
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

            amount = (Double)totalcategories.get(MedwanQuery.getInstance().getConfigString("RAMAdrugsCategory","M"));
            cell = createLabelCell(amount==null?"":priceFormatInsurar.format(amount),100,7);
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
    private void printDebet2(PdfPTable invoiceTable, SortedMap categories, boolean displayDate, Date date, String invoiceid,String adherent,String beneficiary,double total100pct,double total85pct,String recordnumber,int linecounter,double daytotal100pct,double daytotal85pct,PdfPTable tableParent,String insurarreference){
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
        cell = createLabelCell(insurarreference,210,7);
        cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
        cell.setVerticalAlignment(PdfPCell.ALIGN_TOP);
        cell.setBorder(PdfPCell.BOX);
        cell.setPaddingRight(5);
        invoiceTable.addCell(cell);
        cell = createLabelCell(recordnumber+" / "+adherent+" / "+beneficiary,500,7);
        cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
        cell.setVerticalAlignment(PdfPCell.ALIGN_TOP);
        cell.setBorder(PdfPCell.BOX);
        cell.setPaddingRight(5);
        invoiceTable.addCell(cell);

        Double amount = (Double)categories.get(MedwanQuery.getInstance().getConfigString("RAMAconsultationCategory","Co"));
        pageConsultationAmount+=amount==null?0:amount.doubleValue();
        cell = createLabelCell(amount==null?"":priceFormatInsurar.format(amount),100,7);
        cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
        cell.setVerticalAlignment(PdfPCell.ALIGN_TOP);
        cell.setBorder(PdfPCell.BOX);
        cell.setPaddingRight(5);
        invoiceTable.addCell(cell);

        amount = (Double)categories.get(MedwanQuery.getInstance().getConfigString("RAMAlabCategory","L"));
        pageLabAmount+=amount==null?0:amount.doubleValue();
        cell = createLabelCell(amount==null?"":priceFormatInsurar.format(amount),100,7);
        cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
        cell.setVerticalAlignment(PdfPCell.ALIGN_TOP);
        cell.setBorder(PdfPCell.BOX);
        cell.setPaddingRight(5);
        invoiceTable.addCell(cell);

        amount = (Double)categories.get(MedwanQuery.getInstance().getConfigString("RAMAimagingCategory","R"));
        pageImagingAmount+=amount==null?0:amount.doubleValue();
        cell = createLabelCell(amount==null?"":priceFormatInsurar.format(amount),100,7);
        cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
        cell.setVerticalAlignment(PdfPCell.ALIGN_TOP);
        cell.setBorder(PdfPCell.BOX);
        cell.setPaddingRight(5);
        invoiceTable.addCell(cell);

        amount = (Double)categories.get(MedwanQuery.getInstance().getConfigString("RAMAadmissionCategory","S"));
        pageAdmissionAmount+=amount==null?0:amount.doubleValue();
        cell = createLabelCell(amount==null?"":priceFormatInsurar.format(amount),100,7);
        cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
        cell.setVerticalAlignment(PdfPCell.ALIGN_TOP);
        cell.setBorder(PdfPCell.BOX);
        cell.setPaddingRight(5);
        invoiceTable.addCell(cell);

        amount = (Double)categories.get(MedwanQuery.getInstance().getConfigString("RAMAactsCategory","A"));
        pageActsAmount+=amount==null?0:amount.doubleValue();
        cell = createLabelCell(amount==null?"":priceFormatInsurar.format(amount),100,7);
        cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
        cell.setVerticalAlignment(PdfPCell.ALIGN_TOP);
        cell.setBorder(PdfPCell.BOX);
        cell.setPaddingRight(5);
        invoiceTable.addCell(cell);

        amount = (Double)categories.get(MedwanQuery.getInstance().getConfigString("RAMAconsumablesCategory","C"));
        pageConsumablesAmount+=amount==null?0:amount.doubleValue();
        cell = createLabelCell(amount==null?"":priceFormatInsurar.format(amount),100,7);
        cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
        cell.setVerticalAlignment(PdfPCell.ALIGN_TOP);
        cell.setBorder(PdfPCell.BOX);
        cell.setPaddingRight(5);
        invoiceTable.addCell(cell);

        double otherprice=0;
        String allcats=	"*"+MedwanQuery.getInstance().getConfigString("RAMAconsultationCategory","Co")+
						"*"+MedwanQuery.getInstance().getConfigString("RAMAlabCategory","L")+
						"*"+MedwanQuery.getInstance().getConfigString("RAMAimagingCategory","R")+
						"*"+MedwanQuery.getInstance().getConfigString("RAMAadmissionCategory","S")+
						"*"+MedwanQuery.getInstance().getConfigString("RAMAactsCategory","A")+
						"*"+MedwanQuery.getInstance().getConfigString("RAMAconsumablesCategory","C")+
						"*"+MedwanQuery.getInstance().getConfigString("RAMAdrugsCategory","M")+"*";
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

        amount = (Double)categories.get(MedwanQuery.getInstance().getConfigString("RAMAdrugsCategory","M"));
        pageDrugsAmount+=amount==null?0:amount.doubleValue();
        cell = createLabelCell(amount==null?"":priceFormatInsurar.format(amount),100,7);
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

        cell = createUnderlinedCell(getTran("web","insurarreference")+"\n ",1,7);
        singleCellHeaderTable = new PdfPTable(1);
        singleCellHeaderTable.addCell(cell);
        cell = createCell(new PdfPCell(singleCellHeaderTable),210,PdfPCell.ALIGN_LEFT,PdfPCell.NO_BORDER);
        cell.setPaddingRight(2);
        table.addCell(cell);

        cell = createUnderlinedCell(getTran("web","numero_affiliation")+" / "+getTran("web","adherent")+" / "+getTran("web","beneficiary")+"\n ",1,7);
        singleCellHeaderTable = new PdfPTable(1);
        singleCellHeaderTable.addCell(cell);
        cell = createCell(new PdfPCell(singleCellHeaderTable),500,PdfPCell.ALIGN_LEFT,PdfPCell.NO_BORDER);
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

        cell = createUnderlinedCell("ACT\n100%",1,7);
        cell.setHorizontalAlignment(PdfPCell.ALIGN_CENTER);
        singleCellHeaderTable = new PdfPTable(1);
        singleCellHeaderTable.addCell(cell);
        cell = createCell(new PdfPCell(singleCellHeaderTable),100,PdfPCell.ALIGN_CENTER,PdfPCell.NO_BORDER);
        table.addCell(cell);

        cell = createUnderlinedCell("MAT\n100%",1,7);
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

        cell = createUnderlinedCell("MED\n100%",1,7);
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

        int coverage=85;
        if(insurar!=null && insurar.getInsuraceCategories()!=null && insurar.getInsuraceCategories().size()>0){
        	try{
        		coverage=100-Integer.parseInt(((InsuranceCategory)insurar.getInsuraceCategories().elementAt(0)).getPatientShare());
        	}
        	catch(Exception e){
        		e.printStackTrace();
        	}
        }
        cell = createUnderlinedCell("TOT\n"+coverage+"%",1,7);
        cell.setHorizontalAlignment(PdfPCell.ALIGN_CENTER);
        singleCellHeaderTable = new PdfPTable(1);
        singleCellHeaderTable.addCell(cell);
        cell = createCell(new PdfPCell(singleCellHeaderTable),100,PdfPCell.ALIGN_CENTER,PdfPCell.NO_BORDER);
        table.addCell(cell);

        return table;
    }
}