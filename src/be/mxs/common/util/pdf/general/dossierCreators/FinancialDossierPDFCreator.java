package be.mxs.common.util.pdf.general.dossierCreators;

import be.dpms.medwan.webapp.wo.common.system.SessionContainerWO;
import be.mxs.common.util.db.MedwanQuery;
import be.mxs.common.util.system.Debug;
import be.mxs.common.util.system.ScreenHelper;
import be.openclinic.adt.Encounter;
import be.openclinic.finance.Debet;
import be.openclinic.finance.PatientCredit;
import be.openclinic.finance.PatientInvoice;
import be.openclinic.finance.Prestation;
import be.openclinic.finance.Wicket;
import be.openclinic.hr.Contract;

import com.itextpdf.text.*;
import com.itextpdf.text.pdf.PdfPCell;
import com.itextpdf.text.pdf.PdfPTable;
import com.itextpdf.text.pdf.PdfWriter;
import net.admin.AdminPerson;
import net.admin.User;
import javax.servlet.ServletContext;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpSession;
import java.io.ByteArrayOutputStream;
import java.text.SimpleDateFormat;
import java.util.*;

//#################################################################################################
// Composes a PDF document (in OpenWork-style) containing info-sections (as chosen in the jsp)
// which contain a detailed view of general financial data of the current patient.
//#################################################################################################
public class FinancialDossierPDFCreator extends PDFDossierCreator {

    //--- CONSTRUCTOR -----------------------------------------------------------------------------
    public FinancialDossierPDFCreator(SessionContainerWO sessionContainerWO, User user, AdminPerson patient,
                                      String sProject, String sProjectDir, String sPrintLanguage){
        this.user = user;
        this.patient = patient;
        this.sProject = sProject;
        this.sProjectPath = sProjectDir;
        this.sessionContainerWO = sessionContainerWO;
        this.sPrintLanguage = sPrintLanguage;

        doc = new Document();

        dateFormat = ScreenHelper.stdDateFormat;
    }

    //--- GENERATE DOCUMENT BYTES (1) -------------------------------------------------------------
    public ByteArrayOutputStream generatePDFDocumentBytes(final HttpServletRequest req, ServletContext application, 
                                                          boolean filterApplied, int partsOfTransactionToPrint) 
            throws DocumentException {
        return generatePDFDocumentBytes(req,application); // let go of the 2 last params, they only serve to implement the abstract extend    
    }

    //--- GENERATE DOCUMENT BYTES (2) -------------------------------------------------------------
    public ByteArrayOutputStream generatePDFDocumentBytes(final HttpServletRequest req, ServletContext application) 
            throws DocumentException {
        this.req = req;
        this.application = application;
        this.baosPDF = new ByteArrayOutputStream();

        String sURL = req.getRequestURL().toString();
        if(sURL.indexOf("openclinic",10) > 0){
            sURL = sURL.substring(0,sURL.indexOf("openclinic",10));
        }
        if(sURL.indexOf("openinsurance",10) > 0){
            sURL = sURL.substring(0,sURL.indexOf("openinsurance",10));
        }

        String sContextPath = req.getContextPath()+"/";
        HttpSession session = req.getSession();
        String sProjectDir = (String)session.getAttribute("activeProjectDir");

        // if request from Chuk, project = chuk
        if(sContextPath.indexOf("chuk") > -1){
            sContextPath = "openclinic/";
            sProjectDir = "projects/chuk/";
        }

        this.url = sURL;
        this.contextPath = sContextPath;
        this.projectDir = sProjectDir;
        
        try{
            docWriter = PdfWriter.getInstance(doc,baosPDF);

            //*** META TAGS ***********************************************************************
            doc.addProducer();
            doc.addAuthor(user.person.firstname+" "+user.person.lastname);
            doc.addCreationDate();
            doc.addCreator("OpenClinic Software for Hospital Management");
            doc.addTitle("Medical Record Data for "+patient.firstname+", "+patient.lastname);
            doc.addKeywords(patient.firstname+", "+patient.lastname);
            doc.setPageSize(PageSize.A4);
            doc.open();

            //*** HEADER **************************************************************************
            printDocumentHeader(req);

            //*** TITLE ***************************************************************************
    	    String sTitle = getTran("web","financialDossier").toUpperCase();
            printDocumentTitle(req,sTitle);

            //*** SECTIONS ************************************************************************
            /*
        	    - 1 : Administratie persoonlijk
        		- 2 : Administratie privé
        		- 3 : Actieve verzekeringsgegevens
        		- 4 : Historiek verzekeringsgegevens
        		- 5 : Historiek van alle facturen met voor elke factuur de lijst van bijhorende prestaties
        		- 6 : Historiek van alle betalingen verricht door de patiënt
            */
            boolean[] sections = new boolean[17];
            
            // which sections are chosen ?
            Enumeration parameters = req.getParameterNames();
            Vector paramNames = new Vector();
            String sParamName, sParamValue;
            
            // sort the parameternames
            while(parameters.hasMoreElements()){
                sParamName = (String)parameters.nextElement();
                
                if(sParamName.startsWith("section_")){
                    paramNames.add(new Integer(sParamName.substring("section_".length())));
                }
            }
            Collections.sort(paramNames); // on number

            int sectionIdx = 0;
            for(int i=0; i<paramNames.size(); i++){
            	sectionIdx = ((Integer)paramNames.get(i)).intValue()-1;
                sections[sectionIdx] = checkString(req.getParameter("section_"+(sectionIdx+1))).equalsIgnoreCase("on");
                Debug.println("Adding section["+sectionIdx+"] to document : "+sections[sectionIdx]);
            }

            sectionIdx = 0;
            if(sections[sectionIdx++]){
                printPatientCard(patient,sections[1]); // 0, showPhoto
                printAdminData(patient); // 0
            }
            if(sections[sectionIdx++]){
                //printPhoto(patient); // 1
            }
            if(sections[sectionIdx++]){
                printAdminPrivateData(patient); // 2
            }
            if(sections[sectionIdx++]){
                printActiveInsurances(sessionContainerWO,patient); // 4
            }  
            if(sections[sectionIdx++]){
                printInsuranceHistory(sessionContainerWO,patient); // 5
            }
            if(sections[sectionIdx++]){
                printPatientInvoices(sessionContainerWO,patient); // 6
            }
            if(sections[sectionIdx++]){
            	printPatientPayments(sessionContainerWO,patient); // 7
            }
            if(sections[sectionIdx++]){
                printSignature(); // 8 : not in jsp
            }
        }
        catch(DocumentException dex){
            baosPDF.reset();
            throw dex;
        }
        catch(Exception e){
            e.printStackTrace();
        }
        finally{
            if(doc!=null) doc.close();
            if(docWriter!=null) docWriter.close();
        }

        if(baosPDF.size() < 1){
            throw new DocumentException("ERROR : The pdf-document has "+baosPDF.size()+" bytes");
        }

        return baosPDF;
    }


    //#############################################################################################
    //### NON-PUBLIC METHODS ######################################################################
    //#############################################################################################

    //--- PRINT PATIENT INVOICES ------------------------------------------------------------------
    protected void printPatientInvoices(SessionContainerWO sessionContainerWO, AdminPerson activePatient) throws Exception {
        table = new PdfPTable(8);
        table.setWidthPercentage(pageWidth);

        // title
        table.addCell(createTitleCell(getTran("web","patientInvoices"),8));
        
        Vector invoices = PatientInvoice.getPatientInvoices(activePatient.personid);
        if(invoices.size() > 0){
            // header
            table.addCell(createHeaderCell(getTran("web","date"),1));
            table.addCell(createHeaderCell(getTran("web","invoicenumber"),2));
            table.addCell(createHeaderCell(getTran("web","balance"),1));
            table.addCell(createHeaderCell(getTran("web.finance","patientinvoice.status"),2));
            table.addCell(createHeaderCell("",2));

            // run through invoices
	        PatientInvoice invoice;
	        for(int i=0; i<invoices.size(); i++){
	        	invoice = (PatientInvoice)invoices.elementAt(i);

	            //*** one invoice ***
	            // date
	            if(invoice.getDate()!=null){
		            table.addCell(createValueCell(ScreenHelper.stdDateFormat.format(invoice.getDate()),1));
	            }
	            else{
		            table.addCell(createValueCell("",1));
	            }
	
	            table.addCell(createValueCell(invoice.getInvoiceUid(),2));
	            
	            // amount
	            cell = createValueCell(invoice.getBalance()+" "+MedwanQuery.getInstance().getConfigParam("currency",""),1);
	            cell.setHorizontalAlignment(PdfPCell.ALIGN_RIGHT);
	            table.addCell(cell);
	            
	            table.addCell(createValueCell(getTran("finance.patientinvoice.status",invoice.getStatus()),2)); 
	            table.addCell(createValueCell("",2));         
	        }
	    }
	    else{
	    	// no records found
	    	table.addCell(createValueCell(getTran("web","noRecordsFound"),8));  
	    }

        // add transaction to doc
        if(table.size() > 0){
            doc.add(new Paragraph(" "));
            doc.add(table);
        }         
    }
        
    //--- PRINT PATIENT PAYMENTS ------------------------------------------------------------------
    protected void printPatientPayments(SessionContainerWO sessionContainerWO, AdminPerson activePatient) throws Exception {
        table = new PdfPTable(24);
        table.setWidthPercentage(pageWidth);

        // title
        table.addCell(createTitleCell(getTran("web","patientPayments"),24));

        Vector creditUIDs = PatientCredit.getPatientCredits(activePatient.getUid());
    	if(creditUIDs.size() > 0){ 
            // header
            //table.addCell(createHeaderCell("#",1));
            table.addCell(createHeaderCell(getTran("web","date"),2));
            table.addCell(createHeaderCell(getTran("web","encounter"),8));
            table.addCell(createHeaderCell(getTran("web","amount"),2));
            table.addCell(createHeaderCell(getTran("web","type"),4));
            table.addCell(createHeaderCell(getTran("web","invoice"),4));
            table.addCell(createHeaderCell(getTran("wicket","wicket"),4));

            PatientCredit credit;
            Encounter encounter;
            String sCreditUID;

            for(int i=0; i<creditUIDs.size(); i++){
            	sCreditUID = (String)creditUIDs.get(i);
            	credit = PatientCredit.get(sCreditUID);
                
                //*** one credit ***
            	//table.addCell(createValueCell(credit.getUid(),1)); 
            	table.addCell(createValueCell(ScreenHelper.getSQLDate(credit.getDate()),2)); 

            	// encounter
                encounter = credit.getEncounter();
                if(encounter!=null){
                    String sEditCreditEncUid = checkString(encounter.getUid());

                    String sType = "";
                    if(checkString(encounter.getType()).length()>0){
                        sType = ", "+getTran("encounterType",encounter.getType());
                    }

                    String sBegin = "";
                    if(encounter.getBegin()!=null){
                        sBegin = ", "+ScreenHelper.getSQLDate(encounter.getBegin());
                    }

                    String sEnd = "";
                    if(encounter.getEnd()!=null){
                        sEnd = ", "+ScreenHelper.getSQLDate(encounter.getEnd());
                    }

                	table.addCell(createValueCell(sEditCreditEncUid+sBegin+sEnd+sType,8));
                }
                else{
                    table.addCell(createValueCell(getTran("web","dataMissing"),8));
                }
                
            	table.addCell(createValueCell(credit.getAmount()+" "+MedwanQuery.getInstance().getConfigParam("currency",""),2));
            	table.addCell(createValueCell(getTran("credit.type",credit.getType()),4));

                // invoice
            	if(credit.getInvoiceUid().length() > 0){
            		PatientInvoice invoice = PatientInvoice.get(credit.getInvoiceUid());
                	table.addCell(createValueCell(invoice.getInvoiceUid()+" ("+invoice.getBalance()+" "+MedwanQuery.getInstance().getConfigParam("currency","")+")",4));
            	}
                else{
                    table.addCell(createValueCell(getTran("web","dataMissing"),4));
                }
                            	
                // wickets
                Vector userWickets = Wicket.getWicketsForUser(user.userid);
                if(userWickets.size() > 0){
	                Iterator iter = userWickets.iterator();
	                Wicket wicket;
	                String sWickets = "";
	                while(iter.hasNext()){
	                    wicket = (Wicket)iter.next();
	                    sWickets+= getTran("service",wicket.getServiceUID())+", ";
	                }
	                
	                if(sWickets.endsWith(", ")) sWickets = sWickets.substring(0,sWickets.indexOf(", "));
                    table.addCell(createValueCell(sWickets,4));
                }
                else{
                    table.addCell(createValueCell(getTran("web","noWicketAssignedToUser"),4));
                }
                
                addPatientPaymentDetails(table,credit); // comment
            }    
        }
        else{
        	// no records found
        	table.addCell(createValueCell(getTran("web","noRecordsFound"),24));  
        }

        // add transaction to doc
        if(table.size() > 0){
            doc.add(new Paragraph(" "));
            doc.add(table);
        }         
    }
    
    /*
	//--- PRINT PATIENT DEBETS --------------------------------------------------------------------
	protected void printPatientDebets(SessionContainerWO sessionContainerWO, AdminPerson activePatient) throws Exception {
	    table = new PdfPTable(20);
	    table.setWidthPercentage(pageWidth);
	
	    // title
	    table.addCell(createTitleCell(getTran("web","patientDebets"),20));
	
	    Vector debetUIDs = Debet.getUnassignedPatientDebets(activePatient.getUid());
	    //Vector debetUIDs = Debet.getPatientDebets(activePatient.getUid());
		if(debetUIDs.size() > 0){ 
	        // header
	        table.addCell(createHeaderCell(getTran("web","date"),2));
	        table.addCell(createHeaderCell(getTran("web.finance","encounter"),4));
	        table.addCell(createHeaderCell(getTran("web","prestation"),3));
	        table.addCell(createHeaderCell(getTran("web","amount"),2));
	        table.addCell(createHeaderCell(getTran("web.finance","amount.insurar"),5));
	        table.addCell(createHeaderCell(getTran("web.finance","amount.complementaryInsurar"),3));
	        table.addCell(createHeaderCell(getTran("web","canceled"),1));
	        
	        Debet debet;
            Encounter encounter = null;
            Prestation prestation = null;
            String sEncounterName = "", sPrestationDescription = "", sPatientName, sCredited = "", sDebetUID;
            Hashtable hSort = new Hashtable();
	
	        for(int i=0; i<debetUIDs.size(); i++){
	        	sDebetUID = (String)debetUIDs.get(i);
	        	debet = Debet.get(sDebetUID);
	
	            // sub-title
	            table.addCell(createSubtitleCell(getTran("web","patientDebet")+": "+debet.getAmount(),20));
	            
                if(sDebetUID.length() > 0){
                    debet = Debet.get(sDebetUID);

                    if(debet!=null){
                        sEncounterName = "";
                        sPatientName = "";

                        if(checkString(debet.getEncounterUid()).length() > 0){
                            encounter = debet.getEncounter();

                            if(encounter!=null){
                                sEncounterName = encounter.getEncounterDisplayName(sPrintLanguage);
                                sPatientName = ScreenHelper.getFullPersonName(encounter.getPatientUID());
                            }
                        }

                        // prestation description
                        sPrestationDescription = "";
                        if(checkString(debet.getPrestationUid()).length() > 0){
                            prestation = debet.getPrestation();

                            if(prestation!=null){
                                sPrestationDescription = checkString(prestation.getDescription());
                            }
                        }

                        sCredited = "";

                        if(debet.getCredited() > 0){
                            sCredited = getTran("web.occup","medwan.common.yes");
                        }
                        
                        hSort.put(sPatientName.toUpperCase()+"="+debet.getDate().getTime()+"="+debet.getUid(),debet);
                    }
                }
            }

            Vector keys = new Vector(hSort.keySet());
            Collections.sort(keys);
            Collections.reverse(keys);
            
            Iterator iter = keys.iterator();
            while(iter.hasNext()){
                 debet = (Debet)hSort.get((String)iter.next());
                 
                 // one record
                 table.addCell(createValueCell(ScreenHelper.getSQLDate(debet.getDate()),2));
                 
                 table.addCell(createValueCell(sEncounterName+" ("+MedwanQuery.getInstance().getUser(debet.getUpdateUser()).getPersonVO().getFullName()+")",3));
                 table.addCell(createValueCell(debet.getQuantity()+" x "+sPrestationDescription,4));
                 
                 // strike-through when insurar2 known
                 if(checkString(debet.getExtraInsurarUid2()).length() > 0){                	 
                	 String sValue = debet.getAmount()+" "+MedwanQuery.getInstance().getConfigParam("currency","");
                     cell = new PdfPCell(new Paragraph(sValue,FontFactory.getFont(FontFactory.HELVETICA,7,Font.STRIKETHRU)));
                     cell.setColspan(2);
                     cell.setBorder(PdfPCell.BOX);
                     cell.setBorderColor(innerBorderColor);
                     cell.setVerticalAlignment(PdfPCell.ALIGN_TOP);
                     cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
                     table.addCell(cell);
                 }
                 else{
                	 table.addCell(createValueCell(debet.getAmount()+" "+MedwanQuery.getInstance().getConfigParam("currency",""),2));
                 }                 
                 
                 table.addCell(createValueCell(debet.getInsurarAmount()+" "+MedwanQuery.getInstance().getConfigParam("currency",""),5));
                 table.addCell(createValueCell(debet.getExtraInsurarAmount()+" "+MedwanQuery.getInstance().getConfigParam("currency",""),3));
                 table.addCell(createValueCell(sCredited,1));
            }    
	    }
	    else{
	    	// no records found
	    	table.addCell(createValueCell(getTran("web","noRecordsFound"),20));  
	    }
	
	    // add transaction to doc
	    if(table.size() > 0){
	        doc.add(new Paragraph(" "));
	        doc.add(table);
	    }         
	}
	*/
        
    //#############################################################################################
    //################################### UTILITY FUNCTIONS #######################################
    //#############################################################################################
    
    //--- ADD PATIENT PAYMENT DETAILS -------------------------------------------------------------
    // comment
    private void addPatientPaymentDetails(PdfPTable table, PatientCredit credit){
        if(credit.getComment().length() > 0){
        	PdfPTable detailsTable = new PdfPTable(10);
            detailsTable.setWidthPercentage(100);

            // comment in grey and italic
            //detailsTable.addCell(createValueCell(career.comment.replaceAll("\r\n"," "),10));
            Font font = FontFactory.getFont(FontFactory.HELVETICA,7,Font.ITALIC);
            font.setColor(BaseColor.GRAY);
            cell = new PdfPCell(new Paragraph(credit.getComment().replaceAll("\r\n"," "),font));
            cell.setColspan(10);
            cell.setBorder(PdfPCell.BOX);
            cell.setBorderColor(innerBorderColor);
            cell.setVerticalAlignment(PdfPCell.ALIGN_TOP);
            cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
            detailsTable.addCell(cell);
            
            table.addCell(createCell(new PdfPCell(detailsTable),table.getNumberOfColumns(),PdfPCell.ALIGN_CENTER,PdfPCell.BOX));
        }
    }
    
	/*
    //--- ADD DEBETS FOR CREDIT -------------------------------------------------------------------
    private PdfPTable addDebetsForCredit(PdfPTable table, Vector debetUIDs, PatientInvoice invoice) throws Exception {
    	String sDebetUID;
    	Debet debet;
    	
        for(int i=0; i<debetUIDs.size(); i++){
        	sDebetUID = (String)debetUIDs.get(i);
        	debet = Debet.get(sDebetUID);
            
	        // date
	        if(debet.getDate()!=null){
                table.addCell(createValueCell(ScreenHelper.stdDateFormat.format(debet.getDate()),2));
	        }
	        else{
                table.addCell(createValueCell("",2));
	        }
	        
	        // insurar
	        if(debet.getInsurance()==null || debet.getInsurance().getInsurar()==null){
                table.addCell(createValueCell("",3));
	        }
	        else{
                table.addCell(createValueCell(debet.getInsurance().getInsurar().getName(),3));
	        }

	        // encounter
	        String sEncounterName = "";
	        Encounter encounter;
	        
	        if(checkString(debet.getEncounterUid()).length() > 0){
	            encounter = debet.getEncounter();
	
	            if(encounter!=null){
	                sEncounterName = encounter.getEncounterDisplayName(sPrintLanguage);
	            }
	        }
            table.addCell(createValueCell(sEncounterName,3));

	        // prestation
	        String sPrestationDescription = "";
	        Prestation prestation;
	        
	        if(checkString(debet.getPrestationUid()).length()>0){
	            prestation = debet.getPrestation();
	
	            if(prestation!=null){
	                sPrestationDescription = checkString(prestation.getDescription());
	            }
	        }
            table.addCell(createValueCell(debet.getQuantity()+" x "+sPrestationDescription,2));

            // amount
	        double patientAmount = debet.getExtraInsurarUid2()!=null && debet.getExtraInsurarUid2().length()>0?0:debet.getAmount();	             
            table.addCell(createValueCell(patientAmount+" "+MedwanQuery.getInstance().getConfigParam("currency",""),2));
            
	        // credited
	        String sCredited = "";
	        if(debet.getCredited() > 0){
	            sCredited = getTran("web","canceled");
	        }	        
            table.addCell(createValueCell(sCredited,2));
            
            // insurar invoice
            if(debet.getInsurarInvoiceUid()==null){
            	table.addCell(createValueCell("",2));
            }
            else{
            	table.addCell(createValueCell(ScreenHelper.checkString(debet.getInsurarInvoiceUid()).replaceAll("1\\.",""),2));
            }

            // extra insurar 1
            if(debet.getExtraInsurarInvoiceUid()==null){
            	table.addCell(createValueCell("",2));
            }
            else{
            	table.addCell(createValueCell(ScreenHelper.checkString(debet.getExtraInsurarInvoiceUid()).replaceAll("1\\.",""),2));
            }

            // extra insurar 2
            if(debet.getExtraInsurarInvoiceUid2()==null){
            	table.addCell(createValueCell("",2));
            }
            else{
            	table.addCell(createValueCell(ScreenHelper.checkString(debet.getExtraInsurarInvoiceUid2()).replaceAll("1\\.",""),2));
            }
        }    
        
        return table;
    }
    */

    /*
    //--- PRINT PATIENT INVOICES ------------------------------------------------------------------
    protected void printPatientInvoices(SessionContainerWO sessionContainerWO, AdminPerson activePatient) throws Exception {
        table = new PdfPTable(8);
        table.setWidthPercentage(pageWidth);

        // title
        table.addCell(createTitleCell(getTran("web","patientInvoices"),8));
        
        //*** 1 - OPEN INVOICES *********************************************************
        // sub-title
        table.addCell(createSubtitleCell(getTran("web","openPatientInvoices"),8));
        
        Vector invoices = PatientInvoice.getPatientInvoicesWhereDifferentStatus(activePatient.personid,"'closed','canceled'");
        if(invoices.size() > 0){
            // header
            table.addCell(createHeaderCell(getTran("web","date"),1));
            table.addCell(createHeaderCell(getTran("web","invoicenumber"),3));
            table.addCell(createHeaderCell(getTran("web","balance"),2));
            table.addCell(createHeaderCell(getTran("web.finance","patientinvoice.status"),2));

            // run through invoices
	        PatientInvoice invoice;
	        for(int i=0; i<invoices.size(); i++){
	        	invoice = (PatientInvoice)invoices.elementAt(i);

	            //*** one invoice ***
	            // date
	            if(invoice.getDate()!=null){
		            table.addCell(createValueCell(ScreenHelper.stdDateFormat.format(invoice.getDate()),1));
	            }
	            else{
		            table.addCell(createValueCell("",1));
	            }
	
	            table.addCell(createHeaderCell(invoice.getInvoiceUid(),3));
	            table.addCell(createHeaderCell(invoice.getBalance()+" "+getConfigString("currency"),2));
	            table.addCell(createHeaderCell(getTran("finance.patientinvoice.status",invoice.getStatus()),2));          
	        }
	    }
	    else{
	    	// no records found
	    	table.addCell(createValueCell(getTran("web","noRecordsFound"),8));  
	    }
        
        //*** 2 - CLOSED INVOICES *******************************************************
        // sub-title
        table.addCell(createSubtitleCell(getTran("web","closedPatientInvoices"),8));
        
        invoices = PatientInvoice.getPatientInvoicesWhereDifferentStatus(activePatient.personid,"'open'");              
        if(invoices.size() > 0){   
            // header
            table.addCell(createHeaderCell(getTran("web","date"),1));
            table.addCell(createHeaderCell(getTran("web","invoicenumber"),3));
            table.addCell(createHeaderCell(getTran("web","balance"),2));
            table.addCell(createHeaderCell(getTran("web.finance","patientinvoice.status"),2));

            // run through invoices
	        PatientInvoice invoice;
	        for(int i=0; i<invoices.size(); i++){
	        	invoice = (PatientInvoice)invoices.elementAt(i);

	            //*** one invoice ***
                // date
                if(invoice.getDate()!=null){
    	            table.addCell(createValueCell(ScreenHelper.stdDateFormat.format(invoice.getDate()),1));
                }
                else{
    	            table.addCell(createValueCell("",1));
                }

	            table.addCell(createHeaderCell(invoice.getInvoiceUid(),3));
	            table.addCell(createHeaderCell(invoice.getBalance()+" "+getConfigString("currency"),2));
	            table.addCell(createHeaderCell(getTran("finance.patientinvoice.status",invoice.getStatus()),2));	            
	        }
	    }
        else{
        	// no records found
        	table.addCell(createValueCell(getTran("web","noRecordsFound"),8));  
        }

        // add transaction to doc
        if(table.size() > 0){
            doc.add(new Paragraph(" "));
            doc.add(table);
        }         
    }
    */
    
}