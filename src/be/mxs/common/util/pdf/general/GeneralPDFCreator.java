package be.mxs.common.util.pdf.general;

import be.dpms.medwan.webapp.wo.common.system.SessionContainerWO;
import be.mxs.common.model.vo.healthrecord.ItemContextVO;
import be.mxs.common.model.vo.healthrecord.ItemVO;
import be.mxs.common.model.vo.healthrecord.TransactionVO;
import be.mxs.common.model.vo.healthrecord.IConstants;
import be.mxs.common.util.db.MedwanQuery;
import be.mxs.common.util.pdf.PDFCreator;
import be.mxs.common.util.system.Debug;
import be.mxs.common.util.system.Picture;
import be.mxs.common.util.system.ScreenHelper;
import be.openclinic.medical.ChronicMedication;
import be.openclinic.medical.Prescription;
import be.openclinic.medical.Problem;
import com.itextpdf.text.*;
import com.itextpdf.text.Font;
import com.itextpdf.text.Image;
import com.itextpdf.text.Rectangle;
import com.itextpdf.text.pdf.Barcode39;
import com.itextpdf.text.pdf.ColumnText;
import com.itextpdf.text.pdf.PdfContentByte;
import com.itextpdf.text.pdf.PdfPCell;
import com.itextpdf.text.pdf.PdfPTable;
import com.itextpdf.text.pdf.PdfPageEventHelper;
import com.itextpdf.text.pdf.PdfWriter;
import net.admin.AdminPerson;
import net.admin.AdminPrivateContact;
import net.admin.User;

import javax.servlet.ServletContext;
import javax.servlet.http.HttpServletRequest;
import java.awt.*;
import java.io.ByteArrayOutputStream;
import java.lang.reflect.Constructor;
import java.lang.reflect.Method;
import java.text.DecimalFormat;
import java.text.SimpleDateFormat;
import java.util.*;

/*
    Check loadTransaction() for supported examinations !!
*/

//#################################################################################################
// Composes a PDF document (in OpenWork-style) containing patient-info and summary-info in the header
// and a detailed view of all or a selection of examinations of the current patient.
//#################################################################################################
public class GeneralPDFCreator extends PDFCreator {

    // declarations
    private boolean respGraphsArePrinted, diabetesGraphsArePrinted;
    private PdfPCell cell;
    private PdfPTable table;
    
    protected PdfWriter docWriter = null;
    protected final BaseColor innerBorderColor = BaseColor.LIGHT_GRAY;
    protected final BaseColor BGCOLOR_LIGHT = new BaseColor(240,240,240); // light gray


    //--- CONSTRUCTOR -----------------------------------------------------------------------------
    public GeneralPDFCreator(SessionContainerWO sessionContainerWO, User user, AdminPerson patient,
    		                 String sProject, String sProjectDir, Date dateFrom, Date dateTo, String sPrintLanguage){
        this.user = user;
        this.patient = patient;
        this.sProject = sProject;
        this.sProjectPath = sProjectDir;
        this.dateFrom = dateFrom;
        this.dateTo = dateTo;
        this.sessionContainerWO = sessionContainerWO;
        this.sPrintLanguage = sPrintLanguage;

        doc = new Document();

        dateFormat = new SimpleDateFormat("dd/MM/yyyy");
    }

    //--- GENERATE DOCUMENT BYTES (1) -------------------------------------------------------------
    public ByteArrayOutputStream generatePDFDocumentBytes(final HttpServletRequest req, ServletContext application)
    		throws DocumentException {
        return generatePDFDocumentBytes(req,application,false,2); // no filter, full transactions
    }

    //--- GENERATE DOCUMENT BYTES (2) -------------------------------------------------------------
    public ByteArrayOutputStream generatePDFDocumentBytes(final HttpServletRequest req, ServletContext application,
    		                                              boolean filterApplied, int partsOfTransactionToPrint) 
            throws DocumentException {
        ByteArrayOutputStream baosPDF = new ByteArrayOutputStream();

        this.req = req;
        this.application = application;
        sContextPath = req.getContextPath();

		try{
			docWriter = PdfWriter.getInstance(doc,baosPDF);

            //*** META TAGS ***********************************************************************
            doc.addProducer();
            doc.addAuthor(user.person.firstname+" "+user.person.lastname);
			doc.addCreationDate();
			doc.addCreator("OpenClinic Software for Hospital Management");
			doc.addTitle("Medical Record Data for "+patient.firstname+" "+patient.lastname);
			doc.addKeywords(patient.firstname+", "+patient.lastname);
			doc.setPageSize(PageSize.A4);

			//*** FOOTER **************************************************************************
			//PDFFooter footer = new PDFFooter(MedwanQuery.getInstance().getConfigString("footer."+sProject,"OpenClinic pdf engine (c)2007, MXS nv"));
			//docWriter.setPageEvent(footer);
            doc.open();

            //*** HEADER **************************************************************************
            printDocumentHeader(req);

            //*** TITLE ***************************************************************************
            String title = getTran("web","examinations").toUpperCase();

            Paragraph par = new Paragraph(title,FontFactory.getFont(FontFactory.HELVETICA,15,Font.BOLD));
            par.setAlignment(Paragraph.ALIGN_CENTER);
            doc.add(par);
            
            // add date restriction to document title
            String sSubTitle = "";

            if(dateFrom!=null && dateTo!=null){
                if(dateFrom.getTime()==dateTo.getTime()){
                	sSubTitle+= "("+getTran("web","on")+" "+dateFormat.format(dateTo)+")\n";
                }
                else{
                	sSubTitle+= "("+getTran("pdf","date.from")+" "+dateFormat.format(dateFrom)+" "+getTran("pdf","date.to")+" "+dateFormat.format(dateTo)+")\n";
                }
            }
            else if(dateFrom!=null){
            	sSubTitle+= "("+getTran("web","since")+" "+dateFormat.format(dateFrom)+")\n";
            }
            else if(dateTo!=null){
            	sSubTitle+= "("+getTran("pdf","date.to")+" "+dateFormat.format(dateTo)+")\n";
            }

            sSubTitle+= getTran("web","printdate")+": "+dateFormat.format(new Date());
            		
            par = new Paragraph(sSubTitle,FontFactory.getFont(FontFactory.HELVETICA,10,Font.NORMAL));
            par.setAlignment(Paragraph.ALIGN_CENTER);
            doc.add(par);

            //*** OTHER DOCUMENT ELEMENTS *********************************************************
            printPatientCard(patient,true); // 0, showPhoto
            //printAdminHeader(patient);
            //printMedication(sessionContainerWO);
            //printActiveDiagnosis(sessionContainerWO);
            //printWarnings(sessionContainerWO);
            doc.add(new Paragraph(" "));

            //*** VACCINATION CARD ****************************************************************
            new be.mxs.common.util.pdf.general.oc.examinations.PDFVaccinationCard().printCard(doc,sessionContainerWO,transactionVO,patient,req,sProject,sPrintLanguage,new Integer(partsOfTransactionToPrint));

            //*** TRANSACTIONS ********************************************************************
            Enumeration e = req.getParameterNames();
            String paramName, paramValue, sTranID, sServerID;
            boolean transactionIDsSpecified = false;

            while(e.hasMoreElements()){
                paramName = (String)e.nextElement();

                // transactionIDs were specified as request-parameters
                if(paramName.startsWith("tranAndServerID_")){
                    transactionIDsSpecified = true;

                    paramValue = checkString(req.getParameter(paramName));
                    sTranID   = paramValue.substring(0,paramValue.indexOf("_"));
                    sServerID = paramValue.substring(paramValue.indexOf("_")+1);

                    this.transactionVO = MedwanQuery.getInstance().loadTransaction(Integer.parseInt(sServerID),Integer.parseInt(sTranID));
                    loadTransaction(transactionVO,2); // 2 = print whole transaction
                }
            }

            if(!transactionIDsSpecified){
                printTransactions(filterApplied,partsOfTransactionToPrint);
            }
            
            doc.add(new Paragraph(" "));
            printSignature();
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


    //### NON-PUBLIC METHODS ######################################################################

    //--- PRINT TRANSACTIONS ----------------------------------------------------------------------
    private void printTransactions(boolean filterApplied, int partsOfTransactionToPrint){

        // retrieve transaction-id OR transaction-type of transactions to be printed, from request
        int tranPropertyInVector = 0;
        Vector tranPropertiesToBePrinted = new Vector();

        if(filterApplied){
            Vector transactionIDsToBePrinted = new Vector();
            Vector transactionTypesToBePrinted = new Vector();
            Enumeration e = req.getParameterNames();
            String paramName;

            while(e.hasMoreElements()){
                paramName = (String)e.nextElement();

                if(paramName.startsWith("tranAndServerID_")){
                    transactionIDsToBePrinted.add(req.getParameter(paramName));
                }
                else if(paramName.startsWith("tranType_")){
                    transactionTypesToBePrinted.add(req.getParameter(paramName));
                }
            }

            // were transactions selected based on tranType or tranID ?
            if(transactionIDsToBePrinted.size() > 0){
                tranPropertyInVector = 1;
                tranPropertiesToBePrinted = transactionIDsToBePrinted;
            }
            else if(transactionTypesToBePrinted.size() > 0){
                tranPropertyInVector = 2;
                tranPropertiesToBePrinted = transactionTypesToBePrinted;
            }
        }

        // Get all transactions of active patient.
        // Print only transactions between the specified start- and enddate.
        String tranProperty = null;

        Iterator tranIter = sessionContainerWO.getHealthRecordVO().getTransactions().iterator();
        while(tranIter.hasNext()){
            transactionVO = (TransactionVO)tranIter.next();

            // some transactions were selected
            if(tranPropertiesToBePrinted.size() > 0){
                     if(tranPropertyInVector == 1) tranProperty = transactionVO.getTransactionId()+"_"+transactionVO.getServerId();
                else if(tranPropertyInVector == 2) tranProperty = transactionVO.getTransactionType();

                // print the selected transaction complete
                if(tranPropertiesToBePrinted.contains(tranProperty)){
                    if(isTransactionInInterval(transactionVO,dateFrom,dateTo)){
                        if(transactionVO!=null){
                            loadTransaction(transactionVO,2); // 0=nothing, 1=header, 2=all
                        }
                    }
                }
                // print only the header of non-selected transactions
                else{
                    if(isTransactionInInterval(transactionVO,dateFrom,dateTo)){
                        if(transactionVO!=null){
                            loadTransaction(transactionVO,partsOfTransactionToPrint); // 0=nothing, 1=header, 2=all
                        }
                    }
                }
            }
            // no transactions selected, so print all
            else{
                if(isTransactionInInterval(transactionVO,dateFrom,dateTo)){
                    if(transactionVO!=null){
                        loadTransaction(transactionVO,(filterApplied?partsOfTransactionToPrint:2)); // 0=nothing, 1=header, 2=all
                    }
                }
            }
        }
    }

    //--- PRINT DOCUMENT HEADER -------------------------------------------------------------------
    protected void printDocumentHeader(final HttpServletRequest req){
        Class cls = null;
        boolean bClassFound = false;

        // First search the projectclass
        try{
            cls = Class.forName("be.mxs.common.util.pdf.general."+sProject.toLowerCase()+"."+sProject.toLowerCase()+"PDFHeader");
            bClassFound = true;
        }
        catch(ClassNotFoundException e){
            Debug.println(e.getMessage());
        }

        // else search the normal class
        if(cls==null){
            try{
                cls = Class.forName("be.mxs.common.util.pdf.general.PDFHeader");
            }
            catch(ClassNotFoundException e){
                Debug.println(e.getMessage());
            }
        }

        if(cls!=null){
            try{
                Constructor[] cons  = cls.getConstructors();
                Object[] oParams = new Object[0];
                Object oConstructor = cons[0].newInstance(oParams);

                Class cParams[] = new Class[4];
                cParams[0] = HttpServletRequest.class;
                cParams[1] = String.class;
                cParams[2] = String.class;
                cParams[3] = String.class;

                Method mPrint = oConstructor.getClass().getMethod("print",cParams);
                oParams = new Object[4];
                oParams[0] = req;
                oParams[1] = this.sPrintLanguage;

                if(bClassFound){
                    oParams[2] = this.sContextPath+"/"+this.sProjectPath;
                }
                else{
                    oParams[2] = this.sContextPath;
                }
                oParams[3]=sProject.toLowerCase();

                PdfPTable tHeader = (PdfPTable)mPrint.invoke(oConstructor,oParams);
                if(tHeader!=null){
                    doc.add(tHeader);
                }
            }
            catch(Exception e){
                e.printStackTrace();
            }
        }
    }
    
    //--- PRINT SIGNATURE -------------------------------------------------------------------------
    protected void printSignature(){
    	try{
	    	table = new PdfPTable(2);
	        table.setWidthPercentage(100);
	        cell=new PdfPCell();
	        cell.setBorder(PdfPCell.NO_BORDER);
	        table.addCell(cell);
	        cell = new PdfPCell(new Paragraph(getTran("report.monthly","signature").toUpperCase()+"\n\n\n\n\n\n\n\n",FontFactory.getFont(FontFactory.HELVETICA,8,Font.ITALIC)));
	        cell.setColspan(1);
	        cell.setBorder(PdfPCell.BOX);
	        cell.setBorderColor(BaseColor.LIGHT_GRAY);
	        cell.setVerticalAlignment(PdfPCell.ALIGN_TOP);
	        table.addCell(cell);
	        doc.add(table);
    	}
    	catch(Exception e){
    		e.printStackTrace();
    	}    	
    }
    
    //--- PRINT ACTIVE DIAGNOSIS ------------------------------------------------------------------
    protected void printActiveDiagnosis(SessionContainerWO sessionContainerWO){
        try {
            Vector activeProblems = Problem.getActiveProblems(patient.personid);

            if(activeProblems.size() > 0){
                doc.add(new Paragraph(" "));
                table = new PdfPTable(1);
                table.setWidthPercentage(100);

                // title
                cell = new PdfPCell(new Paragraph(getTran("web.occup","medwan.common.problemlist").toUpperCase(),FontFactory.getFont(FontFactory.HELVETICA,8,Font.ITALIC)));
                cell.setColspan(1);
                cell.setBorder(PdfPCell.BOX);
                cell.setBorderColor(BaseColor.LIGHT_GRAY);
                cell.setVerticalAlignment(PdfPCell.ALIGN_MIDDLE);
                cell.setBackgroundColor(BaseColor.LIGHT_GRAY);
                table.addCell(cell);

                // run thru diagnoses
                Problem activeProblem;
                String value;

                for(int n=0; n<activeProblems.size(); n++){
                    activeProblem = (Problem) activeProblems.elementAt(n);
                    value = MedwanQuery.getInstance().getCodeTran(activeProblem.getCodeType() + "code" + activeProblem.getCode(),sPrintLanguage);
                    cell = new PdfPCell(new Paragraph(value+" ("+getTran("Web","since")+" "+dateFormat.format(activeProblem.getBegin())+")",FontFactory.getFont(FontFactory.HELVETICA,7,Font.NORMAL)));

                    cell.setColspan(1);
                    cell.setBorder(PdfPCell.BOX);
                    cell.setBorderColor(BaseColor.LIGHT_GRAY);
                    cell.setVerticalAlignment(PdfPCell.ALIGN_TOP);
                    table.addCell(cell);
                }

                doc.add(table);
            }
        }
        catch(Exception e){
            e.printStackTrace();
        }
    }

    //--- PRINT WARNINGS --------------------------------------------------------------------------
    protected void printWarnings(SessionContainerWO sessionContainerWO){
        try {
            if(sessionContainerWO.getHealthRecordVO() != null) {
                Collection alerts = MedwanQuery.getInstance().getTransactionsByType(sessionContainerWO.getHealthRecordVO(), IConstants.TRANSACTION_TYPE_ALERT);
                sessionContainerWO.setAlerts(alerts);

                if(sessionContainerWO.getActiveAlerts().size() > 0) {
                    doc.add(new Paragraph(" "));
                    table = new PdfPTable(4);
                    table.setWidthPercentage(100);

                    // title
                    cell = new PdfPCell(new Paragraph(getTran("curative","warning.status.title").toUpperCase(),FontFactory.getFont(FontFactory.HELVETICA,8,Font.ITALIC)));
                    cell.setColspan(4);
                    cell.setBorder(PdfPCell.BOX);
                    cell.setBorderColor(BaseColor.LIGHT_GRAY);
                    cell.setVerticalAlignment(PdfPCell.ALIGN_MIDDLE);
                    cell.setBackgroundColor(BaseColor.LIGHT_GRAY);
                    table.addCell(cell);

                    // list alerts
                    Collection activeAlerts = sessionContainerWO.getActiveAlerts();
                    Iterator alertsIter = activeAlerts.iterator();
                    TransactionVO transactionVO;
                    String sLabel, sComment;
                    ItemVO itemVO;

                    while (alertsIter.hasNext()) {
                        transactionVO = (TransactionVO)alertsIter.next();

                        // label
                        sLabel = "";
                        itemVO = transactionVO.getItem(IConstants_PREFIX+"ITEM_TYPE_ALERTS_LABEL");
                        if(itemVO != null) {
                            sLabel = checkString(itemVO.getValue());
                        }

                        cell = new PdfPCell(new Paragraph(sLabel,FontFactory.getFont(FontFactory.HELVETICA,7,Font.NORMAL)));
                        cell.setColspan(1);
                        cell.setBorder(PdfPCell.LEFT+PdfPCell.TOP+PdfPCell.BOTTOM); // no right border
                        cell.setBorderColor(BaseColor.LIGHT_GRAY);
                        cell.setVerticalAlignment(PdfPCell.ALIGN_TOP);
                        table.addCell(cell);

                        // comment
                        sComment = "";
                        itemVO = transactionVO.getItem(IConstants_PREFIX+"ITEM_TYPE_ALERTS_DESCRIPTION");
                        if(itemVO != null) {
                            sComment = checkString(itemVO.getValue());
                        }

                        cell = new PdfPCell(new Paragraph(sComment,FontFactory.getFont(FontFactory.HELVETICA,7,Font.NORMAL)));
                        cell.setColspan(4);
                        cell.setBorder(PdfPCell.RIGHT+PdfPCell.TOP+PdfPCell.BOTTOM); // no left border
                        cell.setBorderColor(BaseColor.LIGHT_GRAY);
                        cell.setVerticalAlignment(PdfPCell.ALIGN_TOP);
                        table.addCell(cell);
                    }

                    doc.add(table);
                }
            }
        }
        catch(Exception e){
            e.printStackTrace();
        }
    }

    //--- PRINT MEDICATION ------------------------------------------------------------------------
    protected void printMedication(SessionContainerWO sessionContainerWO){
        try {
            doc.add(new Paragraph(" "));
            table = new PdfPTable(2);
            table.setWidthPercentage(100);

            // main title
            cell = new PdfPCell(new Paragraph(getTran("curative","medication.status.title").toUpperCase(),FontFactory.getFont(FontFactory.HELVETICA,8,Font.ITALIC)));
            cell.setColspan(2);
            cell.setBorder(PdfPCell.BOX);
            cell.setBorderColor(BaseColor.LIGHT_GRAY);
            cell.setVerticalAlignment(PdfPCell.ALIGN_MIDDLE);
            cell.setBackgroundColor(BaseColor.LIGHT_GRAY);
            table.addCell(cell);

            Vector chronicMedications  = ChronicMedication.find(patient.personid,"","","","OC_CHRONICMED_BEGIN","ASC"), 
                   activePrescriptions = Prescription.getActivePrescriptions(patient.personid);
            Debug.println("chronicMedications : "+chronicMedications.size());
            Debug.println("activePrescriptions : "+activePrescriptions.size());

            if(chronicMedications.size() > 0 || activePrescriptions.size() > 0){            	
	            //*** A : CHRONIC MEDICATION ********************************************
	            if(chronicMedications.size() > 0){
	                PdfPTable medicationTable = new PdfPTable(2);
	
	                // sub title
	                cell = new PdfPCell(new Paragraph(getTran("curative","medication.chronic"),FontFactory.getFont(FontFactory.HELVETICA,8,Font.ITALIC)));
	                cell.setColspan(2);
	                cell.setBorder(PdfPCell.BOX);
	                cell.setBorderColor(BaseColor.LIGHT_GRAY);
	                cell.setVerticalAlignment(PdfPCell.ALIGN_LEFT);
	                cell.setBackgroundColor(BGCOLOR_LIGHT);
	                medicationTable.addCell(cell);
	
	                // run thru medications
	                String sPrescrRule, sProductUnit, timeUnitTran;
	                ChronicMedication medication;
	
	                for(int n=0; n<chronicMedications.size(); n++){
	                    medication = (ChronicMedication)chronicMedications.elementAt(n);
	
	                    sPrescrRule = getTran("web.prescriptions","prescriptionrule");
	                    sPrescrRule = sPrescrRule.replaceAll("#unitspertimeunit#", medication.getUnitsPerTimeUnit() + "");
	
	                    // productunits
	                    if(medication.getUnitsPerTimeUnit() == 1) {
	                        sProductUnit = getTran("product.unit", medication.getProduct().getUnit());
	                    }
	                    else {
	                        sProductUnit = getTran("product.units", medication.getProduct().getUnit());
	                    }                      
	                    sPrescrRule = sPrescrRule.replaceAll("#productunit#", sProductUnit.toLowerCase());
	
	                    // timeunits
	                    if(medication.getTimeUnitCount() == 1) {
	                        sPrescrRule = sPrescrRule.replaceAll("#timeunitcount#", "");
	                        timeUnitTran = getTran("prescription.timeunit", medication.getTimeUnit());
	                    }
	                    else {
	                        sPrescrRule = sPrescrRule.replaceAll("#timeunitcount#", medication.getTimeUnitCount() + "");
	                        timeUnitTran = getTran("prescription.timeunits", medication.getTimeUnit());
	                    }
	                    sPrescrRule = sPrescrRule.replaceAll("#timeunit#", timeUnitTran.replaceAll("  "," ").toLowerCase());
	
	                    // product name
	                    cell = new PdfPCell(new Paragraph(medication.getProduct().getName(),FontFactory.getFont(FontFactory.HELVETICA,7,Font.BOLD)));
	                    cell.setColspan(1);
	                    cell.setBorder(PdfPCell.LEFT+PdfPCell.TOP+PdfPCell.BOTTOM); // no right border
	                    cell.setBorderColor(BaseColor.LIGHT_GRAY);
	                    medicationTable.addCell(cell);
	
	                    // prescription rule
	                    cell = new PdfPCell(new Paragraph(sPrescrRule,FontFactory.getFont(FontFactory.HELVETICA,7,Font.ITALIC)));
	                    cell.setColspan(1);
	                    cell.setBorder(PdfPCell.RIGHT+PdfPCell.TOP+PdfPCell.BOTTOM); // no left border
	                    cell.setBorderColor(BaseColor.LIGHT_GRAY);
	                    medicationTable.addCell(cell);
	                }
	
	                // add cells to make up with the chronic medications
	                if(chronicMedications.size() < activePrescriptions.size()){
	                    int missingCellCount = activePrescriptions.size()-chronicMedications.size(); 
	                    for(int i=0; i<missingCellCount; i++){
	                        cell = new PdfPCell();
	                        cell.setColspan(2);
	                        cell.setBorder(PdfPCell.NO_BORDER);
	                        medicationTable.addCell(cell);
	                    }
	                }

	                // add medicationtable to document
	                cell = new PdfPCell(medicationTable);
	                cell.setBorder(PdfPCell.BOX);
	                cell.setBorderColor(BaseColor.LIGHT_GRAY);
	                cell.setPadding(3);
	                table.addCell(cell);
	            }
                        
	            //*** B : PRESCRIPTIONS *****************************************************
	            if(activePrescriptions.size() > 0){
	                PdfPTable medicationTable = new PdfPTable(2);
	
	                // sub title
	                cell = new PdfPCell(new Paragraph(getTran("curative","medication.prescription"),FontFactory.getFont(FontFactory.HELVETICA,8,Font.ITALIC)));
	                cell.setColspan(2);
	                cell.setBorder(PdfPCell.BOX);
	                cell.setBorderColor(BaseColor.LIGHT_GRAY);
	                cell.setVerticalAlignment(PdfPCell.ALIGN_LEFT);
	                cell.setBackgroundColor(BGCOLOR_LIGHT);
	                medicationTable.addCell(cell);
	
	                // run thru medications
	                String sPrescrRule, sProductUnit, timeUnitTran;
	                Prescription prescription;
	                int n;
	
	                for (n=0; n<activePrescriptions.size(); n++){
	                    prescription = (Prescription)activePrescriptions.elementAt(n);
	
	                    sPrescrRule = getTran("web.prescriptions","prescriptionrule");
	                    sPrescrRule = sPrescrRule.replaceAll("#unitspertimeunit#", prescription.getUnitsPerTimeUnit() + "");
	
	                    // productunits
	                    if(prescription.getUnitsPerTimeUnit() == 1) {
	                        sProductUnit = getTran("product.unit", prescription.getProduct().getUnit());
	                    }
	                    else {
	                        sProductUnit = getTran("product.units", prescription.getProduct().getUnit());
	                    }
	                    sPrescrRule = sPrescrRule.replaceAll("#productunit#", sProductUnit.toLowerCase());
	
	                    // timeunits
	                    if(prescription.getTimeUnitCount() == 1) {
	                        sPrescrRule = sPrescrRule.replaceAll("#timeunitcount#", "");
	                        timeUnitTran = getTran("prescription.timeunit", prescription.getTimeUnit());
	                    }
	                    else {
	                        sPrescrRule = sPrescrRule.replaceAll("#timeunitcount#", prescription.getTimeUnitCount() + "");
	                        timeUnitTran = getTran("prescription.timeunits", prescription.getTimeUnit());
	                    }
	                    sPrescrRule = sPrescrRule.replaceAll("#timeunit#", timeUnitTran.toLowerCase());
	
	                    // product name
	                    cell = new PdfPCell(new Paragraph(prescription.getProduct().getName(),FontFactory.getFont(FontFactory.HELVETICA,7,Font.BOLD)));
	                    cell.setColspan(1);
	                    cell.setBorder(PdfPCell.LEFT+PdfPCell.TOP+PdfPCell.BOTTOM); // no right border
	                    cell.setBorderColor(BaseColor.LIGHT_GRAY);
	                    medicationTable.addCell(cell);
	
	                    // prescription rule
	                    cell = new PdfPCell(new Paragraph(sPrescrRule,FontFactory.getFont(FontFactory.HELVETICA,7,Font.ITALIC)));
	                    cell.setColspan(1);
	                    cell.setBorder(PdfPCell.RIGHT+PdfPCell.TOP+PdfPCell.BOTTOM); // no left border
	                    cell.setBorderColor(BaseColor.LIGHT_GRAY);
	                    medicationTable.addCell(cell);
	                }
	
	                // add cells to make up with the active prescriptions
	                if(activePrescriptions.size() < chronicMedications.size()){
	                    int missingCellCount = chronicMedications.size()-activePrescriptions.size();
	                    
	                    for(int i=0; i<missingCellCount; i++){
	                        cell = new PdfPCell();
	                        cell.setColspan(2);
	                        cell.setBorder(PdfPCell.NO_BORDER);
	                        medicationTable.addCell(cell);
	                    }
	                }

	                // add medicationtable to document
	                cell = new PdfPCell(medicationTable);
	                cell.setBorder(PdfPCell.BOX);
	                cell.setBorderColor(BaseColor.LIGHT_GRAY);
	                cell.setPadding(3);
	                table.addCell(cell);
	            }
            }   
            //*** C : NO MEDICATION FOUND ***********************************************
            else{
                cell = new PdfPCell(new Paragraph(getTran("curative","noMedication"),FontFactory.getFont(FontFactory.HELVETICA,8,Font.NORMAL)));
                cell.setBorder(PdfPCell.NO_BORDER);
                cell.setPadding(3);
                table.addCell(cell);
            }
            
            if(table.size() > 0){
                doc.add(table);
            }
        }
        catch(Exception e){
            e.printStackTrace();
        }
    }

    //--- PRINT PATIENT CARD ----------------------------------------------------------------------
    protected void printPatientCard(AdminPerson person, boolean showPhoto) throws Exception {
        table = new PdfPTable(20);
        table.setWidthPercentage(100);
        
    	PdfPTable cardTable = new PdfPTable(2);
        cardTable.setWidthPercentage(100);
        
        //*** ROW 1 ***************************************
        // label : name + archive code                      
        cell = createLabel(MedwanQuery.getInstance().getLabel("web","cardname",sPrintLanguage),7,1,Font.ITALIC);
        cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
        cardTable.addCell(cell);

        cell = createLabel(MedwanQuery.getInstance().getLabel("web","cardArchiveCode",sPrintLanguage),7,1,Font.ITALIC);
        cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
        cardTable.addCell(cell);

        // data : name + archive code
        cell = createLabel(person.firstname+", "+person.lastname,12,1,Font.BOLD);
        cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
        cardTable.addCell(cell);
        
        cell = createLabel(person.getID("archiveFileCode").toUpperCase(),10,1,Font.BOLD);
        cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
        cardTable.addCell(cell);
        
        //*** ROW 2 ***************************************
        // label : date of birth & gender
        cell = createLabel(MedwanQuery.getInstance().getLabel("web","carddateofbirth",sPrintLanguage),7,1,Font.ITALIC);
        cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
        cardTable.addCell(cell);
        
        cell = createLabel(MedwanQuery.getInstance().getLabel("web","cardgender",sPrintLanguage),7,1,Font.ITALIC);
        cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
        cardTable.addCell(cell);

        // data : date of birth & gender
        cell = createLabel(person.dateOfBirth,10,1,Font.BOLD);
        cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
        cardTable.addCell(cell);
        
        cell = createLabel(person.gender,10,1,Font.BOLD);
        cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
        cardTable.addCell(cell);
        
        //*** ROW 3 ***************************************
        if(MedwanQuery.getInstance().getConfigInt("patientCardModel",1)==2){
            cell = createLabel(MedwanQuery.getInstance().getLabel("web","cardInsuranceNumber",sPrintLanguage),7,2,Font.ITALIC);
            cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
            cardTable.addCell(cell);

            cell = createLabel(person.comment5,10,2,Font.BOLD);
            cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
            cardTable.addCell(cell);
        }
        
        //*** Photo ***
        PdfPCell imgCell = new PdfPCell();
        
        if(showPhoto){
            if(Picture.exists(Integer.parseInt(person.personid))){
                Picture picture = new Picture(Integer.parseInt(person.personid));
                        
	            try{
	                Image image = Image.getInstance(picture.getPicture());
	                image.scaleToFit(130,72);
	                imgCell = new PdfPCell(image);
	            }
	            catch(Exception e){
	                e.printStackTrace();
	                
	                imgCell = new PdfPCell();
	            }
	            
	            imgCell.setBorder(PdfPCell.NO_BORDER);
	            imgCell.setVerticalAlignment(PdfPCell.ALIGN_MIDDLE);
	            imgCell.setHorizontalAlignment(PdfPCell.ALIGN_JUSTIFIED);
	            imgCell.setPadding(2);
	            imgCell.setColspan(5);
            }
            else{                	
            	// no picture found
            	imgCell = createValueCell(getTran("web","noPictureFound"),1);  
            }
        }

        // cardTable in table
        cell = createBorderlessCell(12);
        cell.addElement(cardTable);
        cell.setPadding(0);
        table.addCell(cell);
        
        // imgCell in table              
        imgCell.setBorder(PdfPCell.NO_BORDER);
        imgCell.setVerticalAlignment(PdfPCell.ALIGN_MIDDLE);
        imgCell.setHorizontalAlignment(PdfPCell.ALIGN_CENTER);
        imgCell.setPadding(2);
        imgCell.setColspan(3);            
        table.addCell(imgCell);
        
        // barcode in table
        PdfContentByte contentByte = docWriter.getDirectContent();
        Barcode39 barcode39 = new Barcode39();
        barcode39.setCode("0"+person.personid);
        barcode39.setSize(8);
        barcode39.setBaseline(10);
        barcode39.setBarHeight(65);
        
        Image barcodeImg = barcode39.createImageWithBarcode(contentByte,null,null);            
        cell = new PdfPCell(barcodeImg);
        cell.setHorizontalAlignment(PdfPCell.ALIGN_CENTER);
        cell.setBorder(PdfPCell.NO_BORDER);
        cell.setPadding(2);
        cell.setColspan(5);
        table.addCell(cell);
        
        // hospital ref (horizontal line)
        cell = createLabel(getTran("web","cardHospitalRef"),8,20,Font.NORMAL);
        cell.setBorder(PdfPCell.TOP);
        cell.setHorizontalAlignment(PdfPCell.ALIGN_CENTER);
        table.addCell(cell);
                    
        // add transaction to doc
        if(table.size() > 0){
            doc.add(new Paragraph(" "));
            doc.add(table);
            doc.add(new Paragraph(" "));
        }
        
        //doc.setJavaScript_onLoad(MedwanQuery.getInstance().getConfigString("cardJavaScriptOnLoad","document.print();"));
    }
    
    //--- PRINT ADMIN HEADER ----------------------------------------------------------------------
    protected void printAdminHeader(AdminPerson activePerson){
        try{
            doc.add(new Paragraph(" "));
            table = new PdfPTable(4);
            table.setWidthPercentage(100);

            // title
            cell = new PdfPCell(new Paragraph(getTran("Web.Occup","medwan.common.administrative-data").toUpperCase(),FontFactory.getFont(FontFactory.HELVETICA,8,Font.ITALIC)));
            cell.setColspan(4);
            cell.setBorder(PdfPCell.BOX);
            cell.setBorderColor(BaseColor.LIGHT_GRAY);
            cell.setVerticalAlignment(PdfPCell.ALIGN_MIDDLE);
            cell.setBackgroundColor(BaseColor.LIGHT_GRAY);
            table.addCell(cell);

            // firstname
            cell = new PdfPCell(new Paragraph(activePerson.firstname+" "+activePerson.lastname,FontFactory.getFont(FontFactory.HELVETICA,8,Font.BOLD)));
            cell.setColspan(2);
            cell.setBorder(PdfPCell.BOX);
            cell.setBorderColor(BaseColor.LIGHT_GRAY);
            cell.setVerticalAlignment(PdfPCell.ALIGN_TOP);
            table.addCell(cell);

            // dateOfBirth
            cell = new PdfPCell(new Paragraph("°"+activePerson.dateOfBirth,FontFactory.getFont(FontFactory.HELVETICA,8,Font.BOLD)));
            cell.setColspan(1);
            cell.setBorder(PdfPCell.BOX);
            cell.setBorderColor(BaseColor.LIGHT_GRAY);
            cell.setVerticalAlignment(PdfPCell.ALIGN_TOP);
            table.addCell(cell);

            // gender
            cell = new PdfPCell(new Paragraph(activePerson.gender+"",FontFactory.getFont(FontFactory.HELVETICA,8,Font.BOLD)));
            cell.setColspan(1);
            cell.setBorder(PdfPCell.BOX);
            cell.setBorderColor(BaseColor.LIGHT_GRAY);
            cell.setVerticalAlignment(PdfPCell.ALIGN_TOP);
            table.addCell(cell);

            // address
            AdminPrivateContact contact = activePerson.getActivePrivate();
            if(contact!=null){
                cell = new PdfPCell(new Paragraph(contact.district+" - "+ScreenHelper.getTranNoLink("province",contact.province,sPrintLanguage),FontFactory.getFont(FontFactory.HELVETICA,8,Font.NORMAL)));
                cell.setColspan(4);
                cell.setBorder(PdfPCell.BOX);
                cell.setBorderColor(BaseColor.LIGHT_GRAY);
                cell.setVerticalAlignment(PdfPCell.ALIGN_TOP);
                table.addCell(cell);
            }

            doc.add(table);
        }
        catch(Exception e){
            e.printStackTrace();
        }
    }

    //--- LOAD TRANSACTION ------------------------------------------------------------------------
    protected void loadTransaction(TransactionVO transactionVO, int partsOfTransactionToPrint){
        transactionVO = MedwanQuery.getInstance().loadTransaction(transactionVO.getServerId(),transactionVO.getTransactionId().intValue());

        if(transactionVO.getTransactionType().equalsIgnoreCase(IConstants_PREFIX+"TRANSACTION_TYPE_VACCINATION")){
            // do nothing : transactions are displayed separately
        }
        else if(transactionVO.getTransactionType().equalsIgnoreCase(IConstants_PREFIX+"TRANSACTION_TYPE_ALERT")){
            // do nothing : alerts are displayed separately
        }
        else if(transactionVO.getTransactionType().equalsIgnoreCase(IConstants_PREFIX+"TRANSACTION_TYPE_EXTERNAL_DOCUMENT")){
            loadTransactionOfType("PDFExternalDocument",transactionVO,partsOfTransactionToPrint);
        }
        else if(transactionVO.getTransactionType().equalsIgnoreCase(IConstants_PREFIX+"TRANSACTION_TYPE_ABDOMINAL_ECHOGRAPHY_PROTOCOL")){
            loadTransactionOfType("PDFAbdominalEchographyProtocol",transactionVO,partsOfTransactionToPrint);
        }
        else if(transactionVO.getTransactionType().equalsIgnoreCase(IConstants_PREFIX+"TRANSACTION_TYPE_ANATOMOPATHOLOGY")){
            loadTransactionOfType("PDFAnatomopathology",transactionVO,partsOfTransactionToPrint);
        }
        else if(transactionVO.getTransactionType().equalsIgnoreCase(IConstants_PREFIX+"TRANSACTION_TYPE_ANESTHESIA_PREOP")){
            loadTransactionOfType("PDFAnesthesiaPreop",transactionVO,partsOfTransactionToPrint);
        }
        else if(transactionVO.getTransactionType().equalsIgnoreCase(IConstants_PREFIX+"TRANSACTION_TYPE_ANESTHESIA_REPORT")){
            loadTransactionOfType("PDFAnesthesiaReport",transactionVO,partsOfTransactionToPrint);
        }
        else if(transactionVO.getTransactionType().equalsIgnoreCase(IConstants_PREFIX+"TRANSACTION_TYPE_ANESTHESIE_SUPERVISION")){
            loadTransactionOfType("PDFAnesthesieSupervision",transactionVO,partsOfTransactionToPrint);
        }
        else if(transactionVO.getTransactionType().equalsIgnoreCase(IConstants_PREFIX+"TRANSACTION_TYPE_AUDIOMETRY")){
            loadTransactionOfType("PDFAudiometry",transactionVO,partsOfTransactionToPrint);
        }
        else if(transactionVO.getTransactionType().equalsIgnoreCase(IConstants_PREFIX+"TRANSACTION_TYPE_OPHTALMOLOGY_CDO")){
            loadTransactionOfType("PDFOphtalmologyCDO",transactionVO,partsOfTransactionToPrint);
        }
        else if(transactionVO.getTransactionType().equalsIgnoreCase(IConstants_PREFIX+"TRANSACTION_TYPE_BIOMETRY")){ // pediatryBiometry.jsp
            loadTransactionOfType("PDFBiometry",transactionVO,partsOfTransactionToPrint);
        }
        else if(transactionVO.getTransactionType().equalsIgnoreCase(IConstants_PREFIX+"TRANSACTION_TYPE_BRONCHOSCOPY_PROTOCOL")){
            loadTransactionOfType("PDFBronchoscopyProtocol",transactionVO,partsOfTransactionToPrint);
        }
        else if(transactionVO.getTransactionType().equalsIgnoreCase(IConstants_PREFIX+"TRANSACTION_TYPE_CARDIO_ECHOGRAPHY_PROTOCOL")){
            loadTransactionOfType("PDFCardioEchographyProtocol",transactionVO,partsOfTransactionToPrint);
        }
        else if(transactionVO.getTransactionType().equalsIgnoreCase(IConstants_PREFIX+"TRANSACTION_TYPE_CARDIOVASCULAR_RISK")){
            loadTransactionOfType("PDFCardioVascularRisk",transactionVO,partsOfTransactionToPrint);
        }
        else if(transactionVO.getTransactionType().equalsIgnoreCase(IConstants_PREFIX+"TRANSACTION_TYPE_COLONOSCOPY_PROTOCOL")){
            loadTransactionOfType("PDFColonoscopyProtocol",transactionVO,partsOfTransactionToPrint);
        }
        else if(transactionVO.getTransactionType().equalsIgnoreCase(IConstants_PREFIX+"TRANSACTION_TYPE_DAILY_NOTE")){
            loadTransactionOfType("PDFIntensiveCareDailyNote",transactionVO,partsOfTransactionToPrint);
        }
        else if(transactionVO.getTransactionType().equalsIgnoreCase(IConstants_PREFIX+"TRANSACTION_TYPE_DELIVERY")){
            loadTransactionOfType("PDFDelivery",transactionVO,partsOfTransactionToPrint);
        }
        else if(transactionVO.getTransactionType().equalsIgnoreCase(IConstants_PREFIX+"TRANSACTION_TYPE_DENTIST")){
            loadTransactionOfType("PDFDentist",transactionVO,partsOfTransactionToPrint);
        }
        else if(transactionVO.getTransactionType().equalsIgnoreCase(IConstants_PREFIX+"TRANSACTION_TYPE_DERMATOLOGY_CONSULTATION")){
            //loadTransactionOfType("PDFDermatologyConsultation",transactionVO,partsOfTransactionToPrint); 
            loadTransactionOfType("PDFClinicalExamination",transactionVO,partsOfTransactionToPrint); 
        }
        else if(transactionVO.getTransactionType().equalsIgnoreCase(IConstants_PREFIX+"TRANSACTION_TYPE_DERMATOLOGY_LEPROSY_BEGIN")){
            loadTransactionOfType("PDFDermatologyLeprosyBegin",transactionVO,partsOfTransactionToPrint);
        }
        else if(transactionVO.getTransactionType().equalsIgnoreCase(IConstants_PREFIX+"TRANSACTION_TYPE_DERMATOLOGY_LEPROSY_FOLLOWUP")){
            loadTransactionOfType("PDFDermatologyLeprosyFollowup",transactionVO,partsOfTransactionToPrint);
        }
        else if(transactionVO.getTransactionType().equalsIgnoreCase(IConstants_PREFIX+"TRANSACTION_TYPE_DERMATOLOGY_LEPROSY_END")){
            loadTransactionOfType("PDFDermatologyLeprosyEnd",transactionVO,partsOfTransactionToPrint);
        }
        else if(transactionVO.getTransactionType().equalsIgnoreCase(IConstants_PREFIX+"TRANSACTION_TYPE_DRIVING_LICENCE_DECLARATION")){
            loadTransactionOfType("PDFDrivingLicenceDeclaration",transactionVO,partsOfTransactionToPrint);
        }
        else if(transactionVO.getTransactionType().equalsIgnoreCase(IConstants_PREFIX+"TRANSACTION_TYPE_ECG")){
            loadTransactionOfType("PDFEcg",transactionVO,partsOfTransactionToPrint);
        }
        else if(transactionVO.getTransactionType().equalsIgnoreCase(IConstants_PREFIX+"TRANSACTION_TYPE_GENERAL_CLINICAL_EXAMINATION")){
            loadTransactionOfType("PDFClinicalExamination",transactionVO,partsOfTransactionToPrint);
        }
        else if(transactionVO.getTransactionType().equalsIgnoreCase(IConstants_PREFIX+"TRANSACTION_TYPE_GYNAE_CONSULTATION")){
            //loadTransactionOfType("PDFGynaeConsultation",transactionVO,partsOfTransactionToPrint);
            loadTransactionOfType("PDFClinicalExamination",transactionVO,partsOfTransactionToPrint); 
        }
        else if(transactionVO.getTransactionType().equalsIgnoreCase(IConstants_PREFIX+"TRANSACTION_TYPE_INTERNAL_EXPOSITION")){
            loadTransactionOfType("PDFInternalExposition",transactionVO,partsOfTransactionToPrint);
        }
        else if(transactionVO.getTransactionType().equalsIgnoreCase(IConstants_PREFIX+"TRANSACTION_TYPE_INTRADERMO")){
            loadTransactionOfType("PDFIntradermo",transactionVO,partsOfTransactionToPrint);
        }
        else if(transactionVO.getTransactionType().equalsIgnoreCase(IConstants_PREFIX+"TRANSACTION_TYPE_KINESITHERAPY_APPLICATION")){
            loadTransactionOfType("PDFKinesitherapyApplication",transactionVO,partsOfTransactionToPrint);
        }
        else if(transactionVO.getTransactionType().equalsIgnoreCase(IConstants_PREFIX+"TRANSACTION_TYPE_KINESITHERAPY_CONSULTATION_TREATMENT")){
            loadTransactionOfType("PDFKinesitherapyConsultationTreatment",transactionVO,partsOfTransactionToPrint);
        }
        else if(transactionVO.getTransactionType().equalsIgnoreCase(IConstants_PREFIX+"TRANSACTION_TYPE_LAB_REQUEST")){
            loadTransactionOfType("PDFLabRequest",transactionVO,partsOfTransactionToPrint);
        }
        else if(transactionVO.getTransactionType().equalsIgnoreCase(IConstants_PREFIX+"TRANSACTION_TYPE_MEDICALCARE")){
            loadTransactionOfType("PDFMedicalCare",transactionVO,partsOfTransactionToPrint);
        }
        else if(transactionVO.getTransactionType().equalsIgnoreCase(IConstants_PREFIX+"TRANSACTION_TYPE_MIR2")){
            loadTransactionOfType("PDFMedicalImagingRequest2",transactionVO,partsOfTransactionToPrint);
        }
        else if(transactionVO.getTransactionType().equalsIgnoreCase(IConstants_PREFIX+"TRANSACTION_TYPE_NEUROLOGY_CAREFILE")){
            loadTransactionOfType("PDFNeurologyCarefile",transactionVO,partsOfTransactionToPrint);
        }
        else if(transactionVO.getTransactionType().equalsIgnoreCase(IConstants_PREFIX+"TRANSACTION_TYPE_NEUROLOGY_FOLLOWUP")){
            loadTransactionOfType("PDFNeurlogyFollowup",transactionVO,partsOfTransactionToPrint);
        }
        else if(transactionVO.getTransactionType().equalsIgnoreCase(IConstants_PREFIX+"TRANSACTION_TYPE_NEUROLOGY_TRANSFER")){
            loadTransactionOfType("PDFNeurologyTransfer",transactionVO,partsOfTransactionToPrint);
        }
        else if(transactionVO.getTransactionType().equalsIgnoreCase(IConstants_PREFIX+"TRANSACTION_TYPE_NURSE_EXAMINATION")){
            loadTransactionOfType("PDFNurseExamination",transactionVO,partsOfTransactionToPrint);
        }
        else if(transactionVO.getTransactionType().equalsIgnoreCase(IConstants_PREFIX+"TRANSACTION_TYPE_NURSE_FOLLOWUP")){
            loadTransactionOfType("PDFNurseFollowup",transactionVO,partsOfTransactionToPrint);
        }
        else if(transactionVO.getTransactionType().equalsIgnoreCase(IConstants_PREFIX+"TRANSACTION_TYPE_OESOPHAGOGASTRODUODENOSCOPY_PROTOCOL")){
            loadTransactionOfType("PDFOesoPhagoGastroDuoDenoScopyProtocol",transactionVO,partsOfTransactionToPrint);
        }
        else if(transactionVO.getTransactionType().equalsIgnoreCase(IConstants_PREFIX+"TRANSACTION_TYPE_OPHTALMOLOGY")){
            loadTransactionOfType("PDFOphtalmology",transactionVO,partsOfTransactionToPrint);
        }
        else if(transactionVO.getTransactionType().equalsIgnoreCase(IConstants_PREFIX+"TRANSACTION_TYPE_OPHTALMOLOGY_CONSULTATION")){
            loadTransactionOfType("PDFOphtalmologyConsultation",transactionVO,partsOfTransactionToPrint);
        }
        else if(transactionVO.getTransactionType().equalsIgnoreCase(IConstants_PREFIX+"TRANSACTION_TYPE_OPHTALMOLOGY_OPERATION_PROTOCOL")){
            loadTransactionOfType("PDFOphtalmologyOperationProtocol",transactionVO,partsOfTransactionToPrint);
        }
        else if(transactionVO.getTransactionType().equalsIgnoreCase(IConstants_PREFIX+"TRANSACTION_TYPE_ORL_CONSULTATION")){
            //loadTransactionOfType("PDFOrlConsultation",transactionVO,partsOfTransactionToPrint);  
            loadTransactionOfType("PDFClinicalExamination",transactionVO,partsOfTransactionToPrint); 
        }
        else if(transactionVO.getTransactionType().equalsIgnoreCase(IConstants_PREFIX+"TRANSACTION_TYPE_OTHER_REQUESTS")){
            loadTransactionOfType("PDFOtherRequests",transactionVO,partsOfTransactionToPrint);
        }
        else if(transactionVO.getTransactionType().equalsIgnoreCase(IConstants_PREFIX+"TRANSACTION_TYPE_PEDIATRY_CONSULTATION")){
            loadTransactionOfType("PDFPediatryConsultation",transactionVO,partsOfTransactionToPrint);
        }
        else if(transactionVO.getTransactionType().equalsIgnoreCase(IConstants_PREFIX+"TRANSACTION_TYPE_PHYSIO_CONS")){
            loadTransactionOfType("PDFPhysiotherapyConsultation",transactionVO,partsOfTransactionToPrint);
        }
        else if(transactionVO.getTransactionType().equalsIgnoreCase(IConstants_PREFIX+"TRANSACTION_TYPE_PHYSIO_REP")){
            loadTransactionOfType("PDFPhysiotherapyReport",transactionVO,partsOfTransactionToPrint);
        }
        else if(transactionVO.getTransactionType().equalsIgnoreCase(IConstants_PREFIX+"TRANSACTION_TYPE_POST_PARTUM_CHILD")){
            loadTransactionOfType("PDFPostPartumChild",transactionVO,partsOfTransactionToPrint);
        }
        else if(transactionVO.getTransactionType().equalsIgnoreCase(IConstants_PREFIX+"TRANSACTION_TYPE_POST_PARTUM_MOTHER")){
            loadTransactionOfType("PDFPostPartumMother",transactionVO,partsOfTransactionToPrint);
        }
        else if(transactionVO.getTransactionType().equalsIgnoreCase(IConstants_PREFIX+"TRANSACTION_TYPE_PROCTOLOGY_PROTOCOL")){
            loadTransactionOfType("PDFProctologyProtocol",transactionVO,partsOfTransactionToPrint);      
        }
        else if(transactionVO.getTransactionType().equalsIgnoreCase(IConstants_PREFIX+"TRANSACTION_TYPE_PROTOCOL_IMAGES_STOMATOLOGY")){
            loadTransactionOfType("PDFProtocolImagesStomatology",transactionVO,partsOfTransactionToPrint);
        }
        else if(transactionVO.getTransactionType().equalsIgnoreCase(IConstants_PREFIX+"TRANSACTION_TYPE_REFERENCE")){
            loadTransactionOfType("PDFReference",transactionVO,partsOfTransactionToPrint);
        }
        else if(transactionVO.getTransactionType().equalsIgnoreCase(IConstants_PREFIX+"TRANSACTION_TYPE_STOMATOLOGY_CONSULTATION")){
            //loadTransactionOfType("PDFStomatologyConsultation",transactionVO,partsOfTransactionToPrint);
            loadTransactionOfType("PDFClinicalExamination",transactionVO,partsOfTransactionToPrint); 
        }
        else if(transactionVO.getTransactionType().equalsIgnoreCase(IConstants_PREFIX+"TRANSACTION_TYPE_STOMATOLOGY_OPERATION_PROTOCOL")){
            loadTransactionOfType("PDFStomatologyOperationProtocol",transactionVO,partsOfTransactionToPrint);
        }
        else if(transactionVO.getTransactionType().equalsIgnoreCase(IConstants_PREFIX+"TRANSACTION_TYPE_SURVEILLANCE_PROTOCOL")){
            loadTransactionOfType("PDFSurveillanceProtocol",transactionVO,partsOfTransactionToPrint);
        }
        else if(transactionVO.getTransactionType().equalsIgnoreCase(IConstants_PREFIX+"TRANSACTION_TYPE_SURGERY_CONSULTATION")){
            //loadTransactionOfType("PDFSurgeryConsulation",transactionVO,partsOfTransactionToPrint);
            loadTransactionOfType("PDFClinicalExamination",transactionVO,partsOfTransactionToPrint); 
        }
        else if(transactionVO.getTransactionType().equalsIgnoreCase(IConstants_PREFIX+"TRANSACTION_TYPE_THYROID_ECHOGRAPHY_PROTOCOL")){
            loadTransactionOfType("PDFThyroidEchographyProtocol",transactionVO,partsOfTransactionToPrint);
        }
        else if(transactionVO.getTransactionType().equalsIgnoreCase(IConstants_PREFIX+"TRANSACTION_TYPE_PSYCHOLOGYFOLLOWUP")){
            loadTransactionOfType("PDFPsychologyFollowUp",transactionVO,partsOfTransactionToPrint);
        }
        else if(transactionVO.getTransactionType().equalsIgnoreCase(IConstants_PREFIX+"TRANSACTION_TYPE_MEETINGREPORT")){
            loadTransactionOfType("PDFMeetingReport",transactionVO,partsOfTransactionToPrint);
        }
        else if(transactionVO.getTransactionType().equalsIgnoreCase(IConstants_PREFIX+"TRANSACTION_TYPE_ERGOTHERAPY")){
            loadTransactionOfType("PDFErgotherapyConsultation",transactionVO,partsOfTransactionToPrint);
        }
        else if(transactionVO.getTransactionType().equalsIgnoreCase(IConstants_PREFIX+"TRANSACTION_TYPE_EEG")){
            loadTransactionOfType("PDFEEG",transactionVO,partsOfTransactionToPrint);
        }
        else if(transactionVO.getTransactionType().equalsIgnoreCase(IConstants_PREFIX+"TRANSACTION_TYPE_EMG")){
            loadTransactionOfType("PDFEMG",transactionVO,partsOfTransactionToPrint);
        }
        else if(transactionVO.getTransactionType().equalsIgnoreCase(IConstants_PREFIX+"TRANSACTION_TYPE_NEUROPSY_PHYSIOTHERAPYREPORT")){
            loadTransactionOfType("PDFNeuropsyPhysiotherapyReport",transactionVO,partsOfTransactionToPrint);
        }
        else if(transactionVO.getTransactionType().equalsIgnoreCase(IConstants_PREFIX+"TRANSACTION_TYPE_NEUROPSY_OUTPATIENTSUMMARY")){
            loadTransactionOfType("PDFNeuropsyOutpatientSummary",transactionVO,partsOfTransactionToPrint);
        }
        else if(transactionVO.getTransactionType().equalsIgnoreCase(IConstants_PREFIX+"TRANSACTION_TYPE_NEUROPSY_INPATIENTSUMMARY")){
            loadTransactionOfType("PDFNeuropsyInpatientSummary",transactionVO,partsOfTransactionToPrint);
        }
        else if(transactionVO.getTransactionType().equalsIgnoreCase(IConstants_PREFIX+"TRANSACTION_TYPE_URGENCE_CONSULTATION")){
            //loadTransactionOfType("PDFUrgenceConsultation",transactionVO,partsOfTransactionToPrint);
            loadTransactionOfType("PDFClinicalExamination",transactionVO,partsOfTransactionToPrint); 
        }
        else if(transactionVO.getTransactionType().equalsIgnoreCase(IConstants_PREFIX+"TRANSACTION_TYPE_CS_SUIVI_ENFANTS")){
            loadTransactionOfType("PDFFollowUpChildren",transactionVO,partsOfTransactionToPrint);
        }
        else if(transactionVO.getTransactionType().equalsIgnoreCase(IConstants_PREFIX+"TRANSACTION_TYPE_MCD")){
            loadTransactionOfType("PDFMinimalClinicalData",transactionVO,partsOfTransactionToPrint);
        }
        else if(transactionVO.getTransactionType().equalsIgnoreCase(IConstants_PREFIX+"TRANSACTION_TYPE_TRACNET_SUIVI_CLINIQUE")){
            loadTransactionOfType("PDFTracnetSuiviClinique",transactionVO,partsOfTransactionToPrint);
        }
        else if(transactionVO.getTransactionType().equalsIgnoreCase(IConstants_PREFIX+"TRANSACTION_TYPE_MOBILE_TECHNIQUE_SUPPORT")){
            loadTransactionOfType("PDFMobileTechniqueSupport",transactionVO,partsOfTransactionToPrint);
        }
        else if(transactionVO.getTransactionType().equalsIgnoreCase(IConstants_PREFIX+"TRANSACTION_TYPE_EP")){
            loadTransactionOfType("PDFEvokedPotentials",transactionVO,partsOfTransactionToPrint);
        }
        else if(transactionVO.getTransactionType().equalsIgnoreCase(IConstants_PREFIX+"TRANSACTION_TYPE_SURVEILLANCE_USI")){
            loadTransactionOfType("PDFIntensiveCareSurveillance",transactionVO,partsOfTransactionToPrint);
        }
        else if(transactionVO.getTransactionType().equalsIgnoreCase(IConstants_PREFIX+"TRANSACTION_TYPE_CS_PLANNING_FAMILIAL")){
            loadTransactionOfType("PDFFamilyPlanning",transactionVO,partsOfTransactionToPrint);
        }
        else if(transactionVO.getTransactionType().equalsIgnoreCase(IConstants_PREFIX+"TRANSACTION_TYPE_CS_PMTCT")){
            loadTransactionOfType("PDFPMTCT",transactionVO,partsOfTransactionToPrint);
        }
        else if(transactionVO.getTransactionType().equalsIgnoreCase(IConstants_PREFIX+"TRANSACTION_TYPE_CS_CPN")){
            loadTransactionOfType("PDFPrenatalConsultation",transactionVO,partsOfTransactionToPrint);
        }
        else if(transactionVO.getTransactionType().equalsIgnoreCase(IConstants_PREFIX+"TRANSACTION_TYPE_ORTHOPROSTESIS_CONSULTATION_TREATMENT")){
            loadTransactionOfType("PDFOrthoprostesisConsultationTreatment",transactionVO,partsOfTransactionToPrint);
        }
        else if(transactionVO.getTransactionType().equalsIgnoreCase(IConstants_PREFIX+"TRANSACTION_TYPE_HC_CONTACT")){
            loadTransactionOfType("PDFHealthcenterContact",transactionVO,partsOfTransactionToPrint);
        }
        else if(transactionVO.getTransactionType().equalsIgnoreCase(IConstants_PREFIX+"TRANSACTION_TYPE_RMH_OUTPATIENT")){
            loadTransactionOfType("PDFRMHOutpatientFile",transactionVO,partsOfTransactionToPrint);
        }
        else if(transactionVO.getTransactionType().equalsIgnoreCase(IConstants_PREFIX+"TRANSACTION_TYPE_SOCIALASSISTANT")){
            loadTransactionOfType("PDFSocialAssistant",transactionVO,partsOfTransactionToPrint);
        }
        else if(transactionVO.getTransactionType().equalsIgnoreCase(IConstants_PREFIX+"TRANSACTION_TYPE_OPERATION_PROTOCOL")){
            loadTransactionOfType("PDFOperationProtocol",transactionVO,partsOfTransactionToPrint);
        }
        else if(transactionVO.getTransactionType().equalsIgnoreCase(IConstants_PREFIX+"TRANSACTION_TYPE_CNAR_SURGERY_EXAMINATION")){
            loadTransactionOfType("PDFCNARSurgeryOperation",transactionVO,partsOfTransactionToPrint);
        }
        else if(transactionVO.getTransactionType().equalsIgnoreCase(IConstants_PREFIX+"TRANSACTION_TYPE_CNAR_CONSULTATION")){
            loadTransactionOfType("PDFCNARConsultation",transactionVO,partsOfTransactionToPrint);
        }
        else if(transactionVO.getTransactionType().equalsIgnoreCase(IConstants_PREFIX+"TRANSACTION_TYPE_CS_CONSULTATION")){
            loadTransactionOfType("PDFHealthcenterConsultation",transactionVO,partsOfTransactionToPrint);
        }   
        // respiratory function examination
        else if(transactionVO.getTransactionType().equalsIgnoreCase(IConstants_PREFIX+"TRANSACTION_TYPE_RESP_FUNC_EX")){
            if(!respGraphsArePrinted){  
                respGraphsArePrinted = true;
                Collection items = transactionVO.getItems();
                items.add(new ItemVO(new Integer(-54321),"graphsArePrinted","true",new Date(),new ItemContextVO(new Integer(-54321),"","")));
                transactionVO.setItems(items);
            }

            loadTransactionOfType("PDFRespiratoryFunctionExamination",transactionVO,partsOfTransactionToPrint);
        }
        // diabetes follow up
        else if(transactionVO.getTransactionType().equalsIgnoreCase(IConstants_PREFIX+"TRANSACTION_TYPE_DIABETES_FOLLOWUP")){
            if(!diabetesGraphsArePrinted){
                diabetesGraphsArePrinted = true;
                Collection items = transactionVO.getItems();
                items.add(new ItemVO(new Integer(-54321),"diabetesGraphsArePrinted","true",new Date(),new ItemContextVO(new Integer(-54321),"","")));
                transactionVO.setItems(items);
            }

            loadTransactionOfType("PDFDiabetesFollowup",transactionVO,partsOfTransactionToPrint);
        }
        // generic transaction
        else{
        	Debug.println("Transaction of type '"+transactionVO.getTransactionType()+"' is not supported by GeneralPDFCreator");
            loadTransactionOfType("PDFGenericTransaction",transactionVO,partsOfTransactionToPrint);
        }
    }

    //--- LOAD TRANSACTION OF TYPE ----------------------------------------------------------------
    protected void loadTransactionOfType (String sClassName, TransactionVO transactionVO, int partsOfTransactionToPrint){
        if(partsOfTransactionToPrint > 0){
            Class cls = null;

            // First search the project class
            try{
                cls = Class.forName("be.mxs.common.util.pdf.general."+sProject.toLowerCase()+".examinations."+sProject.toLowerCase()+sClassName);
            }
            catch(ClassNotFoundException e){
                Debug.println(e.getMessage());
            }

            // else search the normal class
            if(cls==null){
                try{
                    cls = Class.forName("be.mxs.common.util.pdf.general.oc.examinations."+sClassName);
                }
                catch(ClassNotFoundException e){
                    Debug.println(e.getMessage());
                    
                    // re-enter this function, now as a generic transaction
                    loadTransactionOfType("PDFGenericTransaction",transactionVO,partsOfTransactionToPrint);
                }
            }
            
            if(cls!=null){
                Debug.println("Dynamically loading specific PDF-class : "+cls.getName());
                
                try{
                    Constructor[] cons = cls.getConstructors();
                    Object[] oParams = new Object[0];
                    Object oConstructor = cons[0].newInstance(oParams);

                    Class cParams[] = new Class[8];
                    cParams[0] = Document.class;
                    cParams[1] = SessionContainerWO.class;
                    cParams[2] = TransactionVO.class;
                    cParams[3] = AdminPerson.class;
                    cParams[4] = HttpServletRequest.class;
                    cParams[5] = String.class;
                    cParams[6] = String.class;
                    cParams[7] = Integer.class;

                    Method mPrint = oConstructor.getClass().getMethod("print",cParams);
                    oParams = new Object[8];
                    oParams[0] = doc;
                    oParams[1] = sessionContainerWO;
                    oParams[2] = transactionVO;
                    oParams[3] = patient;
                    oParams[4] = req;
                    oParams[5] = sProject;
                    oParams[6] = sPrintLanguage;
                    oParams[7] = new Integer(partsOfTransactionToPrint);

                    mPrint.invoke(oConstructor,oParams);
                }
                catch(Exception e){
                    e.printStackTrace();
                }
            }
        }
    }

    //--- CHECK STRING ----------------------------------------------------------------------------
    protected String checkString(String value){
        return ScreenHelper.checkString(value);
    }
    
    
    //**********************************************************************************************
    //*** CELLS ************************************************************************************
    //**********************************************************************************************

    //--- EMPTY CELL -------------------------------------------------------------------------------
    protected PdfPCell emptyCell(int colspan){
        cell = emptyCell();
        cell.setColspan(colspan);

        return cell;
    }

    protected PdfPCell emptyCell(){
        cell = new PdfPCell();
        cell.setBorder(PdfPCell.BOX);
        cell.setBorderColor(innerBorderColor);

        return cell;
    }

    //--- CREATE CELL ------------------------------------------------------------------------------
    protected PdfPCell createCell(PdfPCell childCell, int colspan, int alignment, int border){
        childCell.setColspan(colspan);
        childCell.setHorizontalAlignment(alignment);
        childCell.setBorder(border);
        childCell.setBorderColor(innerBorderColor);
        childCell.setVerticalAlignment(PdfPCell.TOP);

        return childCell;
    }

    //--- CREATE CONTENT CELL ----------------------------------------------------------------------
    protected PdfPCell createContentCell(PdfPTable contentTable){
        cell = new PdfPCell(contentTable);
        cell.setPadding(3);
        cell.setBorder(PdfPCell.NO_BORDER);
        cell.setVerticalAlignment(PdfPCell.TOP);
        cell.setHorizontalAlignment(PdfPCell.ALIGN_CENTER);

        return cell;
    }

    //--- CREATE ITEMNAME CELL ---------------------------------------------------------------------
    protected PdfPCell createItemNameCell(String itemName, int colspan){
        cell = new PdfPCell(new Paragraph(itemName.toUpperCase(),FontFactory.getFont(FontFactory.HELVETICA,7,Font.NORMAL)));
        cell.setColspan(colspan);
        cell.setBorder(PdfPCell.BOX);
        cell.setBorderColor(innerBorderColor);
        cell.setVerticalAlignment(PdfPCell.ALIGN_MIDDLE);
        cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);

        return cell;
    }

    protected PdfPCell createItemNameCell(String itemName){
        return createItemNameCell(itemName,2);
    }

    //--- CREATE VALUE CELL ------------------------------------------------------------------------
    protected PdfPCell createValueCell(String value, int colspan){
        cell = new PdfPCell(new Paragraph(value,FontFactory.getFont(FontFactory.HELVETICA,7,Font.NORMAL)));
        cell.setColspan(colspan);
        cell.setBorder(PdfPCell.BOX);
        cell.setBorderColor(innerBorderColor);
        cell.setVerticalAlignment(PdfPCell.ALIGN_TOP);
        cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);

        return cell;
    }

    protected PdfPCell createValueCell(String value){
        return createValueCell(value,3);
    }

    //--- CREATE TITLE CELL ------------------------------------------------------------------------
    protected PdfPCell createTitleCell(String msg, int colspan){
        cell = new PdfPCell(new Paragraph(msg.toUpperCase(),FontFactory.getFont(FontFactory.HELVETICA,8,Font.ITALIC)));
        cell.setColspan(colspan);
        cell.setBorder(PdfPCell.BOX);
        cell.setBorderColor(BaseColor.LIGHT_GRAY);
        cell.setBackgroundColor(BaseColor.LIGHT_GRAY);
        cell.setVerticalAlignment(PdfPCell.ALIGN_TOP);

        return cell;
    }

    //--- CREATE SUBTITLE CELL --------------------------------------------------------------------
    protected PdfPCell createSubtitleCell(String msg, int colspan){
        cell = new PdfPCell(new Paragraph(msg,FontFactory.getFont(FontFactory.HELVETICA,8,Font.ITALIC)));
        cell.setColspan(colspan);
        cell.setBorder(PdfPCell.BOX);
        cell.setBorderColor(BaseColor.LIGHT_GRAY);
        cell.setVerticalAlignment(PdfPCell.ALIGN_LEFT);
        cell.setBackgroundColor(BGCOLOR_LIGHT);

        return cell;
    }

    //--- CREATE HEADER CELL -----------------------------------------------------------------------
    protected PdfPCell createHeaderCell(String msg, int colspan){
        cell = new PdfPCell(new Paragraph(msg,FontFactory.getFont(FontFactory.HELVETICA,7,Font.BOLDITALIC)));
        cell.setColspan(colspan);
        cell.setBorder(PdfPCell.BOX);
        cell.setBorderColor(innerBorderColor);
        cell.setVerticalAlignment(PdfPCell.ALIGN_TOP);
        cell.setHorizontalAlignment(PdfPCell.ALIGN_CENTER);
        cell.setBackgroundColor(new BaseColor(220,220,220)); // grey

        return cell;
    }

    //--- CREATE INVISIBLE CELL -------------------------------------------------------------------
    protected PdfPCell createInvisibleCell(){
        return createInvisibleCell(1);
    }

    protected PdfPCell createInvisibleCell(int colspan){
        cell = new PdfPCell();
        cell.setColspan(colspan);
        cell.setBorder(PdfPCell.NO_BORDER);
        cell.setVerticalAlignment(PdfPCell.ALIGN_TOP);
        cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);

        return cell;
    }

    //--- CREATE TITLE ----------------------------------------------------------------------------
    protected PdfPCell createTitle(String msg, int colspan){
        cell = new PdfPCell(new Paragraph(msg,FontFactory.getFont(FontFactory.HELVETICA,10,Font.UNDERLINE)));
        cell.setColspan(colspan);
        cell.setBorder(PdfPCell.NO_BORDER);
        cell.setVerticalAlignment(PdfPCell.ALIGN_MIDDLE);
        cell.setHorizontalAlignment(PdfPCell.ALIGN_CENTER);

        return cell;
    }

    //--- CREATE TITLE ----------------------------------------------------------------------------
    protected PdfPCell createLabel(String msg, int fontsize, int colspan, int style){
        cell = new PdfPCell(new Paragraph(msg,FontFactory.getFont(FontFactory.HELVETICA,fontsize,style)));
        cell.setColspan(colspan);
        cell.setBorder(PdfPCell.NO_BORDER);
        cell.setVerticalAlignment(PdfPCell.ALIGN_MIDDLE);
        cell.setHorizontalAlignment(PdfPCell.ALIGN_CENTER);

        return cell;
    }

    //--- CREATE BORDERLESS CELL ------------------------------------------------------------------
    protected PdfPCell createBorderlessCell(String value, int height, int colspan){
        cell = new PdfPCell(new Paragraph(value,FontFactory.getFont(FontFactory.HELVETICA,7,Font.NORMAL)));
        cell.setPaddingTop(height); //
        cell.setColspan(colspan);
        cell.setBorder(PdfPCell.NO_BORDER);
        cell.setVerticalAlignment(PdfPCell.ALIGN_TOP);
        cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);

        return cell;
    }

    protected PdfPCell createBorderlessCell(String value, int colspan){
        return createBorderlessCell(value,3,colspan);
    }

    protected PdfPCell createBorderlessCell(int colspan){
        cell = new PdfPCell();
        cell.setColspan(colspan);
        cell.setBorder(PdfPCell.NO_BORDER);

        return cell;
    }

    //--- CREATE ITEMVALUE CELL -------------------------------------------------------------------
    protected PdfPCell createItemValueCell(String itemValue){
        return createItemValueCell(itemValue,3);         
    }
    
    protected PdfPCell createItemValueCell(String itemValue, int colspan){
        cell = new PdfPCell(new Paragraph(itemValue,FontFactory.getFont(FontFactory.HELVETICA,7,Font.NORMAL))); // no uppercase
        cell.setColspan(colspan);
        cell.setBorder(PdfPCell.BOX);
        cell.setBorderColor(innerBorderColor);
        cell.setVerticalAlignment(PdfPCell.ALIGN_MIDDLE);
        cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);

        return cell;
    }

    //--- CREATE PADDED VALUE CELL ----------------------------------------------------------------
    protected PdfPCell createPaddedValueCell(String value, int colspan){
        cell = new PdfPCell(new Paragraph(value,FontFactory.getFont(FontFactory.HELVETICA,7,Font.NORMAL)));
        cell.setColspan(colspan);
        cell.setBorder(PdfPCell.BOX);
        cell.setBorderColor(innerBorderColor);
        cell.setVerticalAlignment(PdfPCell.ALIGN_TOP);
        cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
        cell.setPaddingRight(5); // difference

        return cell;
    }

    //--- CREATE NUMBER VALUE CELL ----------------------------------------------------------------
    protected PdfPCell createNumberCell(String value, int colspan){
        cell = new PdfPCell(new Paragraph(value,FontFactory.getFont(FontFactory.HELVETICA,7,Font.NORMAL)));
        cell.setColspan(colspan);
        cell.setBorder(PdfPCell.BOX);
        cell.setBorderColor(innerBorderColor);
        cell.setVerticalAlignment(PdfPCell.ALIGN_TOP);
        cell.setHorizontalAlignment(PdfPCell.ALIGN_RIGHT);

        return cell;
    }

}