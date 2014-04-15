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
import be.openclinic.adt.Encounter.EncounterService;
import net.admin.*;

public class PDFInsurarInvoiceGeneratorCMCK extends PDFInvoiceGenerator {
    String PrintType,model="";
    double pageConsultationAmount=0,pageLabAmount=0,pageImagingAmount=0,pageAdmissionAmount=0,pageActsAmount=0,pageConsumablesAmount=0,pageOtherAmount=0,pageDrugsAmount=0,pageTotalAmount100=0,pageTotalAmount85=0;
    java.util.Date start, end;
    Vector debets;

    //--- CONSTRUCTOR -----------------------------------------------------------------------------
    public PDFInsurarInvoiceGeneratorCMCK(User user, String sProject, String sPrintLanguage, String PrintType){
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
			doc.setMargins(1,1,20,20);
            addFooter(sInvoiceUid.replaceAll("1\\.",""));

            doc.open();

            // get specified invoice
            InsurarInvoice invoice = InsurarInvoice.get(sInvoiceUid);
            boolean hasAdmissions=false,hasVisits=false;
            debets = InsurarInvoice.getDebetsForInvoiceSortByDate(invoice.getUid());
            for(int n=0;n<debets.size();n++){
            	Debet debet = (Debet)debets.elementAt(n);
            	if(debet!=null){
            		if(debet.getDate()!=null && (start==null || debet.getDate().before(start))){
            			start=debet.getDate();
            		}
            		if(debet.getDate()!=null && (end==null || debet.getDate().after(end))){
            			end=debet.getDate();
            		}
            	}
            }
           
            
            addHeading2(invoice);
            addInsurarData2(invoice);
            printInvoiceDetailed(invoice);
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
    
	private class Income{
		public double mn,mp,at,ac,aa,unknown;
		
		public double getTotal(){
			return mn+mp+at+ac+aa+unknown;
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
  

    private void addHeading2(InsurarInvoice invoice) throws Exception {
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
            cell=createValueCell(getTran("web","date")+": "+new SimpleDateFormat("dd/MM/yyyy").format(invoice.getDate()),10,8,Font.BOLD);
            cell.setHorizontalAlignment(PdfPCell.ALIGN_RIGHT);
            table2.addCell(cell);
            cell = createEmptyCell(5);
            table2.addCell(cell);

            cell=createValueCell(getTran("web","cmck.ident.2.1"),15,8,Font.BOLD);
            cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
            table2.addCell(cell);
            cell=createValueCell("",10,8,Font.BOLD);
            cell.setHorizontalAlignment(PdfPCell.ALIGN_RIGHT);
            table2.addCell(cell);
            if(invoice.getStatus().equalsIgnoreCase("closed")){
                //*** barcode ***
                PdfContentByte cb = docWriter.getDirectContent();
                Barcode39 barcode39 = new Barcode39();
                barcode39.setCode("6"+invoice.getInvoiceUid());
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

  
    private void addInsurarData2(InsurarInvoice invoice){
        PdfPTable table = new PdfPTable(100);
        table.setWidthPercentage(pageWidth);

        try {
            Insurar insurar = invoice.getInsurar();
            cell=createBoldLabelCell(insurar.getName(),100,10);
            cell.setHorizontalAlignment(PdfPCell.ALIGN_CENTER);
            table.addCell(cell);

            doc.add(table);
            addBlankRow();
        }
        catch(Exception e){
            e.printStackTrace();
        }
    }


    protected void printInvoiceDetailed(InsurarInvoice invoice){
        try {
            Vector debets = new Vector();
            for(int n=0;n<invoice.getDebets().size();n++){
            	Debet debet = (Debet)invoice.getDebets().elementAt(n);
            	if(debet!=null && debet.getEncounter()!=null){
           			debets.addElement(debet);
            	}
            }

            PdfPTable table = new PdfPTable(100);
            table.setWidthPercentage(pageWidth);
            
            cell=createLabelCell(getTran("web","invoicenumber")+":", 15);
            table.addCell(cell);
            cell=createBoldLabelCell(invoice.getUid(), 20);
            table.addCell(cell);
            cell=createLabelCell(getTran("web","period")+":", 10);
            table.addCell(cell);
            Date begin = new Date();
            Date end = new SimpleDateFormat("dd/MM/yyyy").parse("01/01/1900");
            SortedMap invoices = new TreeMap();
            String uid;
            for(int n=0;n<debets.size();n++){
            	Debet debet = (Debet)debets.elementAt(n);
            	if(debet.getDate().after(end)){
            		end=debet.getDate();
            	}
            	if(debet.getDate().before(begin)){
            		begin=debet.getDate();
            	}
            	//Invoicekey
            	String invoicekey="?";
            	if(debet.getPatientInvoiceUid()!=null){
        			PatientInvoice inv = PatientInvoice.get(debet.getPatientInvoiceUid());
        			if(inv!=null){
        				invoicekey=new SimpleDateFormat("yyyyMMdd").format(inv.getDate())+";"+inv.getInvoiceNumber()+";"+inv.getInsurarreference();
        			}
            	}
            	
            	//Adherent
            	String adherentkey="?";
            	if(debet.getInsurance()!=null && ScreenHelper.checkString(debet.getInsurance().getMember()).length()>0){
            		adherentkey=debet.getInsurance().getMember();
            	}

            	//Beneficiaries
            	String beneficiarykey="?";
            	if(debet.getEncounter()!=null && debet.getEncounter().getPatient()!=null){
            		beneficiarykey=debet.getEncounter().getPatient().getFullName();
            	}

            	//PrestationClass
            	String prestationclasskey="?";
            	if(debet.getPrestation()!=null && debet.getPrestation().getPrestationClass()!=null){
            		prestationclasskey=debet.getPrestation().getPrestationClass();
            	}
            	
            	if(invoices.get(invoicekey)==null){
            		invoices.put(invoicekey, new TreeMap());
            	}
            	TreeMap adherents = (TreeMap)invoices.get(invoicekey);

            	if(adherents.get(adherentkey)==null){
            		adherents.put(adherentkey, new TreeMap());
            	}
            	TreeMap beneficiaries=(TreeMap)adherents.get(adherentkey);
            	
            	if(beneficiaries.get(beneficiarykey)==null){
            		beneficiaries.put(beneficiarykey, new TreeMap());
            	}
            	TreeMap prestationclasses = (TreeMap)beneficiaries.get(beneficiarykey);
            	
            	if(prestationclasses.get(prestationclasskey)==null){
            		prestationclasses.put(prestationclasskey, new Vector());
            	}
            	            	
           		((Vector)prestationclasses.get(prestationclasskey)).add(debet);
           	}
            cell=createBoldLabelCell(new SimpleDateFormat("MM/yyyy").format(begin)+(new SimpleDateFormat("MM/yyyy").format(begin).equalsIgnoreCase(new SimpleDateFormat("MM/yyyy").format(end))?"":" - "+new SimpleDateFormat("MM/yyyy").format(end)), 55);
            table.addCell(cell);
			cell=createLabelCell("\n",100);
			table.addCell(cell);
			cell = createBoldLabelCell(getTran("web","beneficiary"), 30);
			cell.setBorder(PdfPCell.TOP+PdfPCell.LEFT+PdfPCell.RIGHT);
			table.addCell(cell);
			cell = createBoldLabelCell(getTran("web","prestations"), 70);
			cell.setHorizontalAlignment(PdfPCell.ALIGN_CENTER);
			cell.setBorder(PdfPCell.BOX);
			table.addCell(cell);
			cell = createEmptyCell(30);
			cell.setBorder(PdfPCell.LEFT);
			table.addCell(cell);
			cell = createBoldLabelCell(getTran("web","prestation"), 30);
			cell.setBorder(PdfPCell.BOX);
			table.addCell(cell);
			cell = createBoldLabelCell(getTran("web","quantity"), 10);
			cell.setBorder(PdfPCell.BOX);
			table.addCell(cell);
			cell = createBoldLabelCell(getTran("web","unitprice"), 10);
			cell.setHorizontalAlignment(PdfPCell.ALIGN_RIGHT);
			cell.setBorder(PdfPCell.BOX);
			table.addCell(cell);
			cell = createBoldLabelCell(getTran("web","total"), 10);
			cell.setHorizontalAlignment(PdfPCell.ALIGN_RIGHT);
			cell.setBorder(PdfPCell.BOX);
			table.addCell(cell);
			cell = createBoldLabelCell(getTran("web","patient"), 10);
			cell.setHorizontalAlignment(PdfPCell.ALIGN_RIGHT);
			cell.setBorder(PdfPCell.BOX);
			table.addCell(cell);
			
			Iterator iInvoices = invoices.keySet().iterator();
			double generaltotal=0,generalpatienttotal=0;
			while(iInvoices.hasNext()){
				String invoicekey = (String)iInvoices.next();
				TreeMap adherents=(TreeMap)invoices.get(invoicekey);
				double adherenttotal=0;
				double patienttotal=0;
				Iterator iAdherents = adherents.keySet().iterator();
				while(iAdherents.hasNext()){
					String adherentkey=(String)iAdherents.next();
					adherenttotal=0;
					patienttotal=0;
					cell = createBoldLabelCell(getTran("web","adherent")+": "+adherentkey, 50,10);
					cell.setBorder(PdfPCell.TOP+PdfPCell.LEFT);
					table.addCell(cell);
					cell = createBoldLabelCell(getTran("web","invoicenumber")+": "+invoicekey.split(";")[1], 25,10);
					cell.setBorder(PdfPCell.TOP);
					table.addCell(cell);
					System.out.println("invoicekey="+invoicekey);
					cell = createBoldLabelCell(getTran("web","bcnumber")+": "+(invoicekey.split(";").length>2?invoicekey.split(";")[2]:""), 25,10);
					cell.setBorder(PdfPCell.TOP+PdfPCell.RIGHT);
					table.addCell(cell);
					TreeMap beneficiaries = (TreeMap)adherents.get(adherentkey);
					Iterator iBeneficiaries = beneficiaries.keySet().iterator();
					int linecounter=0;
					while(iBeneficiaries.hasNext()){
						String beneficiarykey=(String)iBeneficiaries.next();
						cell = createBoldLabelCell((invoicekey.split(";")[0].length()==8?new SimpleDateFormat("dd/MM/yyyy").format(new SimpleDateFormat("yyyyMMdd").parse(invoicekey.split(";")[0])):invoicekey.split(";")[0])+" - "+beneficiarykey, 30);
						cell.setBorder(PdfPCell.LEFT);
						table.addCell(cell);
						TreeMap prestationclasses = (TreeMap)beneficiaries.get(beneficiarykey);
						Iterator iPrestationclasses = prestationclasses.keySet().iterator();
						//First we want to print the medication class name
						while(iPrestationclasses.hasNext()){
							String prestationclasskey = (String)iPrestationclasses.next();
							if(linecounter>0){
								cell = createBoldLabelCell("", 30);
								cell.setBorder(PdfPCell.LEFT);
								table.addCell(cell);
							}
							cell = createBoldLabelCell(getTran("prestation.class",prestationclasskey), 50);
							cell.setBackgroundColor(BaseColor.LIGHT_GRAY);
							table.addCell(cell);
							Vector debs=(Vector)prestationclasses.get(prestationclasskey);
							double classtotal=0,classpatient=0;
							for(int n=0;n<debs.size();n++){
								Debet debet = (Debet)debs.elementAt(n);
								classtotal+=debet.getInsurarAmount();
								classpatient+=debet.getAmount();
							}
							cell = createBoldLabelCell(new DecimalFormat(MedwanQuery.getInstance().getConfigString("priceFormat")).format(classtotal), 10);
							cell.setBackgroundColor(BaseColor.LIGHT_GRAY);
							cell.setHorizontalAlignment(PdfPCell.ALIGN_RIGHT);
							table.addCell(cell);
							cell = createBoldLabelCell(new DecimalFormat(MedwanQuery.getInstance().getConfigString("priceFormat")).format(classpatient), 10);
							cell.setBackgroundColor(BaseColor.LIGHT_GRAY);
							cell.setHorizontalAlignment(PdfPCell.ALIGN_RIGHT);
							cell.setBorder(PdfPCell.RIGHT);
							table.addCell(cell);
							linecounter++;
							for(int n=0;n<debs.size();n++){
								Debet debet = (Debet)debs.elementAt(n);
								cell = createLabelCell("", 15);
								cell.setBorder(PdfPCell.LEFT);
								table.addCell(cell);
								cell = createLabelCell(new SimpleDateFormat("dd/MM/yyyy").format(debet.getDate()), 15);
								table.addCell(cell);
								cell = createLabelCell(debet.getPrestation().getDescription(), 30);
								table.addCell(cell);
								cell = createLabelCell(new Double(debet.getQuantity()).intValue()+"", 10);
								table.addCell(cell);
								cell = createLabelCell(new Double((debet.getAmount()+debet.getInsurarAmount()+debet.getExtraInsurarAmount())/debet.getQuantity()).intValue()+"", 10);
								cell.setHorizontalAlignment(PdfPCell.ALIGN_RIGHT);
								table.addCell(cell);
								cell = createLabelCell(new Double(debet.getInsurarAmount()).intValue()+"", 10);
								cell.setHorizontalAlignment(PdfPCell.ALIGN_RIGHT);
								table.addCell(cell);
								cell = createLabelCell(new Double(debet.getAmount()).intValue()+"", 10);
								cell.setHorizontalAlignment(PdfPCell.ALIGN_RIGHT);
								cell.setBorder(PdfPCell.RIGHT);
								table.addCell(cell);
								adherenttotal+=debet.getInsurarAmount();
								generaltotal+=debet.getInsurarAmount();
								patienttotal+=debet.getAmount();
								generalpatienttotal+=debet.getAmount();
							}
							cell = createBoldLabelCell("\n", 100);
							cell.setBorder(PdfPCell.LEFT+PdfPCell.RIGHT);
							table.addCell(cell);
						}
					}
					cell = createBoldLabelCell("", 70);
					cell.setBorder(PdfPCell.LEFT);
					table.addCell(cell);
					cell = createBoldLabelCell(getTran("web","subtotal"), 10,9);
					cell.setBorder(PdfPCell.TOP);
					table.addCell(cell);
					cell = createBoldLabelCell(new Double(adherenttotal).intValue()+"", 10,9);
					cell.setHorizontalAlignment(PdfPCell.ALIGN_RIGHT);
					cell.setBorder(PdfPCell.TOP);
					table.addCell(cell);
					cell = createBoldLabelCell(new Double(patienttotal).intValue()+"", 10,9);
					cell.setHorizontalAlignment(PdfPCell.ALIGN_RIGHT);
					cell.setBorder(PdfPCell.TOP+PdfPCell.RIGHT);
					table.addCell(cell);
				}
			}

			
			cell = createBoldLabelCell(getTran("web","generaltotal")+": "+new Double(generaltotal).intValue(),90,10);
			cell.setBorder(PdfPCell.TOP);
			cell.setHorizontalAlignment(PdfPCell.ALIGN_RIGHT);
			table.addCell(cell);
			cell = createBoldLabelCell(new Double(generalpatienttotal).intValue()+"",90,10);
			cell.setBorder(PdfPCell.TOP);
			cell.setHorizontalAlignment(PdfPCell.ALIGN_RIGHT);
			table.addCell(cell);
			addBlankRow();
			cell=createLabelCell(getTran("web.occup","invoicedirector"),50);
			table.addCell(cell);
            
            
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
    	
        //Eerst nemen we alle debets
        Vector debets = invoice.getDebets();
        //Nu gaan we aan elke debet als datum de patientfactuurdatum geven
        Hashtable patientInvoices = new Hashtable();
        Debet debet;
        Date date;
        PatientInvoice patientInvoice;
        SortedMap sortedDebets = new TreeMap();
        for(int n=0;n<debets.size();n++){
        	debet = (Debet)debets.elementAt(n);
        	date = (Date)patientInvoices.get(debet.getPatientInvoiceUid());
        	if(date==null){
        		patientInvoice = PatientInvoice.get(debet.getPatientInvoiceUid());
        		if(patientInvoice!=null){
        			date = patientInvoice.getDate();
        			patientInvoices.put(debet.getPatientInvoiceUid(), date);
        		}
        	}
        	if(date!=null){
        		debet.setDate(date);
        	}
        	sortedDebets.put(new SimpleDateFormat("yyyyMMdd").format(debet.getDate())+"."+debet.getPatientInvoiceUid()+"."+debet.getUid(), debet);
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
	                date = debet.getDate();
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
	                        table.addCell(createEmptyCell(200));
	
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