package be.mxs.common.util.pdf.general.dossierCreators;

import be.dpms.medwan.common.model.vo.occupationalmedicine.ExaminationVO;
import be.dpms.medwan.webapp.wo.common.system.SessionContainerWO;
import be.mxs.common.model.vo.healthrecord.ItemContextVO;
import be.mxs.common.model.vo.healthrecord.ItemVO;
import be.mxs.common.model.vo.healthrecord.TransactionVO;
import be.mxs.common.model.vo.healthrecord.IConstants;
import be.mxs.common.model.vo.healthrecord.VaccinationInfoVO;
import be.mxs.common.util.db.MedwanQuery;
import be.mxs.common.util.system.Debug;
import be.mxs.common.util.system.Miscelaneous;
import be.mxs.common.util.system.ScreenHelper;
import be.openclinic.adt.Encounter;
import be.openclinic.adt.Planning;
import be.openclinic.common.ObjectReference;
import be.openclinic.medical.CarePrescription;
import be.openclinic.medical.ChronicMedication;
import be.openclinic.medical.Diagnosis;
import be.openclinic.medical.Prescription;
import be.openclinic.medical.Problem;
import be.openclinic.medical.ReasonForEncounter;
import be.openclinic.pharmacy.Product;

import com.itextpdf.text.*;
import com.itextpdf.text.pdf.PdfPCell;
import com.itextpdf.text.pdf.PdfPTable;
import com.itextpdf.text.pdf.PdfWriter;

import net.admin.AdminFamilyRelation;
import net.admin.AdminPerson;
import net.admin.User;

import javax.servlet.ServletContext;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpSession;

import java.io.ByteArrayOutputStream;
import java.lang.reflect.Constructor;
import java.lang.reflect.Method;
import java.text.DecimalFormat;
import java.util.*;
import java.util.List;

/*
    Check loadTransaction() for supported examinations
*/

//#################################################################################################
// Composes a PDF document (in OpenWork-style) containing info-sections (as chosen in the jsp)
// which contain a detailed view of general medical data of the current patient.
//#################################################################################################
public class MedicalDossierPDFCreator extends PDFDossierCreator {

    //--- CONSTRUCTOR -----------------------------------------------------------------------------
    public MedicalDossierPDFCreator(SessionContainerWO sessionContainerWO, User user, AdminPerson patient,
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
    	    String sTitle = getTran("web.occup","medwan.common.occupational-health-record").toUpperCase();
            printDocumentTitle(req,sTitle);

            //*** SECTIONS ************************************************************************
            /*
                -  1 : Administratie persoonlijk (verplicht)
                -  2 : Foto
                -  3 : Administratie privé
                -  4 : Administratie familierelaties
                -  5 : Actieve verzekeringsgegevens
                -  6 : Historiek verzekeringsgegevens
                -  7 : Actieve geneesmiddelen voorschriften
                -  8 : Actieve zorgvoorschriften
                -  9 : Vaccinaties
                - 10 : Probleemlijst
                - 11 : Lijst van gestelde diagnoses
                - 12 : Actieve afspraken
                - 13 : Actief contact 
                - 14 : Historiek oudere contacten (mogelijkheid om contacten te selecteren)
                - 15 : Onderzoeken (mogelijkheid om onderzoeken te selecteren) 
                - 16 : Waarschuwingen
                - 17 : Handtekening
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
                printPatientCard(patient,sections[3]); // 0, showPhoto
                printAdminData(patient); // 0
            }
            if(sections[sectionIdx++]){
                //printPhoto(patient); // 1
            }
            if(sections[sectionIdx++]){
                printAdminPrivateData(patient); // 2
            }
            if(sections[sectionIdx++]){
                printAdminFamilyRelations(patient); // 3
            }
            if(sections[sectionIdx++]){
                printActiveInsurances(sessionContainerWO,patient); // 4
            }  
            if(sections[sectionIdx++]){
                printInsuranceHistory(sessionContainerWO,patient); // 5
            }
            if(sections[sectionIdx++]){
                printActiveDrugPrescriptions(sessionContainerWO,patient); // 6
            }
            if(sections[sectionIdx++]){
                printActiveCarePrescriptions(sessionContainerWO,patient); // 7
            }
            if(sections[sectionIdx++]){
                printVaccinations(sessionContainerWO,patient); // 8
            }
            if(sections[sectionIdx++]){
                printProblemList(sessionContainerWO,patient); // 9
            }                        
            if(sections[sectionIdx++]){
                printActiveDiagnoses(sessionContainerWO,patient); // 10
            }
            if(sections[sectionIdx++]){
                printActiveAppointments(sessionContainerWO,patient); // 11
            }
            if(sections[sectionIdx++]){
                printActiveEncounter(sessionContainerWO,patient); // 12
            }
            if(sections[sectionIdx++]){
                printEncounterHistory(sessionContainerWO,patient); // 13
            }
            if(sections[sectionIdx++]){
                printWarnings(sessionContainerWO); // 14 : not in jsp
            }
            if(sections[sectionIdx++]){
                printTransactions(true,2); // 15
            }
            if(sections[sectionIdx++]){
                printSignature(); // 16 : not in jsp
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

    //--- PRINT ADMIN FAMILY RELATIONS ------------------------------------------------------------
    protected void printAdminFamilyRelations(AdminPerson activePatient) throws Exception {                     
        table = new PdfPTable(3);
        table.setWidthPercentage(pageWidth);

        // title
        table.addCell(createTitleCell(getTran("web","adminFamilyRelation"),3));

        if(activePatient.familyRelations.size() > 0){            
            // header
            table.addCell(createHeaderCell(getTran("web.admin","sourcePerson"),1));
            table.addCell(createHeaderCell(getTran("web.admin","destinationPerson"),1));
            table.addCell(createHeaderCell(getTran("web.admin","relationType"),1));
            
            // relations
            AdminFamilyRelation relation;
            for(int i=0; i<activePatient.familyRelations.size(); i++){
                relation = (AdminFamilyRelation)activePatient.familyRelations.get(i);

                if(relation!=null){
                    String sSourceFullName      = ScreenHelper.getFullPersonName(relation.sourceId),
                           sDestinationFullName = ScreenHelper.getFullPersonName(relation.destinationId);
                             
                    if(activePatient.personid.equals(relation)){
                        // source - destination           
                    	table.addCell(createValueCell(sSourceFullName,1));
                    	table.addCell(createValueCell(sDestinationFullName,1));
                    }
                    else{
                        // destination - source              
                    	table.addCell(createValueCell(sDestinationFullName,1));       
                    	table.addCell(createValueCell(sSourceFullName,1));
                    }

                    // relation type   
                	table.addCell(createValueCell(getTran("admin.familyrelation",relation.relationType),1));   
                }
            }                     
        }
        else{
        	// no records found
        	table.addCell(createValueCell(getTran("web","noFamilyRelationsFound"),3));  
        }

        // add transaction to doc
        if(table.size() > 0){
            doc.add(new Paragraph(" "));
            doc.add(table);
        }
    }    
    
    //--- PRINT ACTIVE DRUG PRESCRIPTIONS (medication) --------------------------------------------
    protected void printActiveDrugPrescriptions(SessionContainerWO sessionContainerWO, AdminPerson activePatient) throws Exception {  
        table = new PdfPTable(1);
        table.setWidthPercentage(pageWidth);
        
        // title
        table.addCell(createTitleCell(getTran("web","drugPrescriptions"),2));

        String sTimeUnit, sTimeUnitCount, sUnitsPerTimeUnit, sPrescrRule = "", sProductUnit, timeUnitTran,
               sProductUid, sPrevProductUid = "", sProductName = "", sBeginDate = "", sEndDate = "";
        DecimalFormat unitCountDeci = new DecimalFormat("#.#");
        PdfPTable medicationTable;
        Product product = null;
        
        //***************************************************************************
        //*** 1 - ACTIVE PRESCRIPTIONS **********************************************
        //***************************************************************************
        Vector activePrescriptions = Prescription.findActive(activePatient.personid,user.userid,"","","","","","");
    	medicationTable = new PdfPTable(12);
    	medicationTable.setWidthPercentage(100);
     	
        // sub title
        medicationTable.addCell(createSubtitleCell(getTran("web","medication.active"),12));
        
        if(activePrescriptions.size() > 0){                   
            // header
            medicationTable.addCell(createHeaderCell(getTran("web","product"),6));
            medicationTable.addCell(createHeaderCell(getTran("web","beginDate"),1));
            medicationTable.addCell(createHeaderCell(getTran("web","endDate"),1));
            medicationTable.addCell(createHeaderCell(getTran("web","prescriptionRule"),4));

            Prescription prescription; 
            for(int n=0; n<activePrescriptions.size(); n++){
            	prescription = (Prescription)activePrescriptions.elementAt(n);

                // only search product-name when different product-UID
                sProductUid = prescription.getProductUid();
                if(!sProductUid.equals(sPrevProductUid)){
                	sPrevProductUid = sProductUid;
                    product = getProduct(sProductUid);
                    
                    if(product!=null) sProductName = product.getName();
                    else              sProductName = "";
                }
                
                //*** compose prescriptionrule (gebruiksaanwijzing) ***
                // unit-stuff
                sTimeUnit         = prescription.getTimeUnit();
                sTimeUnitCount    = Integer.toString(prescription.getTimeUnitCount());
                sUnitsPerTimeUnit = Double.toString(prescription.getUnitsPerTimeUnit());

                // only compose prescriptio-rule if all data is available
                if(!sTimeUnit.equals("0") && !sTimeUnitCount.equals("0") && !sUnitsPerTimeUnit.equals("0")){
                    sPrescrRule = getTran("web.prescriptions","prescriptionrule");
                    sPrescrRule = sPrescrRule.replaceAll("#unitspertimeunit#",unitCountDeci.format(Double.parseDouble(sUnitsPerTimeUnit)));
                    if(product!=null) sProductUnit = product.getUnit();
                    else              sProductUnit = "";

                    // productunits
                    if(Double.parseDouble(sUnitsPerTimeUnit)==1){
                        sProductUnit = getTran("product.unit",sProductUnit);
                    }
                    else{
                        sProductUnit = getTran("product.units",sProductUnit);
                    }
                    sPrescrRule = sPrescrRule.replaceAll("#productunit#",sProductUnit.toLowerCase());

                    // timeunits
                    if(Integer.parseInt(sTimeUnitCount)==1){
                        sPrescrRule = sPrescrRule.replaceAll("#timeunitcount#","");
                        timeUnitTran = getTran("prescription.timeunit",sTimeUnit);
                    }
                    else{
                        sPrescrRule = sPrescrRule.replaceAll("#timeunitcount#",sTimeUnitCount);
                        timeUnitTran = getTran("prescription.timeunits",sTimeUnit);
                    }                  
                    sPrescrRule = sPrescrRule.replaceAll("#timeunit#",timeUnitTran.toLowerCase());
                }
                
                sBeginDate = "";
                if(prescription.getBegin()!=null){
                    sBeginDate = ScreenHelper.stdDateFormat.format(prescription.getBegin());
                }
                
                sEndDate = "";
                if(prescription.getEnd()!=null){
                    sEndDate = ScreenHelper.stdDateFormat.format(prescription.getEnd());
                }
                       
                // one prescription
                medicationTable.addCell(createValueCell(sProductName,6));
                medicationTable.addCell(createValueCell(sBeginDate,1));
                medicationTable.addCell(createValueCell(sEndDate,1));
                medicationTable.addCell(createValueCell(sPrescrRule.toLowerCase(),4));
            }
        }
        else{
        	// no records found
        	//medicationTable.addCell(createValueCell(getTran("web","noRecordsFound"),12)); 
        }

        if(medicationTable.size() > 1){
            cell = new PdfPCell();
            cell.addElement(medicationTable);
            cell.setBorder(PdfPCell.BOX);
            cell.setBorderColor(BaseColor.LIGHT_GRAY);
            cell.setVerticalAlignment(PdfPCell.ALIGN_TOP);
            table.addCell(cell);
        }

        //***************************************************************************
        //*** 2 - CHRONIC MEDICATION ************************************************
        //***************************************************************************
        Vector chronicMedications  = ChronicMedication.find(patient.personid,"","","","OC_CHRONICMED_BEGIN","ASC");
    	medicationTable = new PdfPTable(12);
    	medicationTable.setWidthPercentage(100);

        // sub title
        medicationTable.addCell(createSubtitleCell(getTran("web","medication.chronic"),12));
        
        if(chronicMedications.size() > 0){
            // header
            medicationTable.addCell(createHeaderCell(getTran("web","product"),6));
            medicationTable.addCell(createHeaderCell(getTran("web","beginDate"),1));
            medicationTable.addCell(createHeaderCell(getTran("web","endDate"),1));
            medicationTable.addCell(createHeaderCell(getTran("web","prescriptionRule"),4));
            
            // run through chronic medications
            ChronicMedication medication;
            for(int n=0; n<chronicMedications.size(); n++){
                medication = (ChronicMedication)chronicMedications.elementAt(n);
                 
                //*** compose prescriptionrule (gebruiksaanwijzing) ***
                // unit-stuff
                sTimeUnit         = medication.getTimeUnit();
                sTimeUnitCount    = Integer.toString(medication.getTimeUnitCount());
                sUnitsPerTimeUnit = Double.toString(medication.getUnitsPerTimeUnit());

                // only compose prescriptio-rule if all data is available
                if(!sTimeUnit.equals("0") && !sTimeUnitCount.equals("0") && !sUnitsPerTimeUnit.equals("0")){
                    sPrescrRule = getTran("web.prescriptions","prescriptionrule");
                    sPrescrRule = sPrescrRule.replaceAll("#unitspertimeunit#",unitCountDeci.format(Double.parseDouble(sUnitsPerTimeUnit)));
                    if(product!=null) sProductUnit = product.getUnit();
                    else              sProductUnit = "";

                    // productunits
                    if(Double.parseDouble(sUnitsPerTimeUnit)==1){
                        sProductUnit = getTran("product.unit",sProductUnit);
                    }
                    else{
                        sProductUnit = getTran("product.units",sProductUnit);
                    }
                    sPrescrRule = sPrescrRule.replaceAll("#productunit#",sProductUnit.toLowerCase());

                    // timeunits
                    if(Integer.parseInt(sTimeUnitCount)==1){
                        sPrescrRule = sPrescrRule.replaceAll("#timeunitcount#","");
                        timeUnitTran = getTran("prescription.timeunit",sTimeUnit);
                    }
                    else{
                        sPrescrRule = sPrescrRule.replaceAll("#timeunitcount#",sTimeUnitCount);
                        timeUnitTran = getTran("prescription.timeunits",sTimeUnit);
                    }                  
                    sPrescrRule = sPrescrRule.replaceAll("#timeunit#",timeUnitTran.toLowerCase());
                }
                
                sBeginDate = "";
                if(medication.getBegin()!=null){
                    sBeginDate = ScreenHelper.stdDateFormat.format(medication.getBegin());
                }
                
                // one prescription
                medicationTable.addCell(createValueCell(sProductName,6));
                medicationTable.addCell(createValueCell(sBeginDate,1));
                medicationTable.addCell(createValueCell(sPrescrRule.toLowerCase(),5));
            }
        }
        else{
        	// no records found
        	//medicationTable.addCell(createValueCell(getTran("web","noRecordsFound"),12)); 
        }

        if(medicationTable.size() > 1){
            cell = new PdfPCell();
            cell.addElement(medicationTable);
            cell.setBorder(PdfPCell.BOX);
            cell.setBorderColor(BaseColor.LIGHT_GRAY);
            cell.setVerticalAlignment(PdfPCell.ALIGN_TOP);
            table.addCell(cell);
        }

        // add transaction to doc
        doc.add(new Paragraph(" "));
        doc.add(table);
    }
            
    //--- PRINT ACTIVE CARE PRESCRIPTIONS ---------------------------------------------------------
    protected void printActiveCarePrescriptions(SessionContainerWO sessionContainerWO, AdminPerson activePatient) throws Exception {
        table = new PdfPTable(1);
        table.setWidthPercentage(pageWidth);

        // title
        table.addCell(createTitleCell(getTran("web","activeCarePrescriptions"),1));
        
        // Active prescriptions (in last 48 hours)
        Vector activePrescrs = CarePrescription.findActive(activePatient.personid,"","",
                                                           ScreenHelper.stdDateFormat.format(ScreenHelper.getDate(new Date(new Date().getTime()-48*60*60000))),
                                                           "","","OC_CAREPRESCR_BEGIN","DESC");
        PdfPTable prescrTable = new PdfPTable(8);
        prescrTable.setWidthPercentage(100);

        if(activePrescrs.size() > 0){
            // header
            prescrTable.addCell(createHeaderCell(getTran("web","care_type"),3));
            prescrTable.addCell(createHeaderCell(getTran("web","prescriber"),3));
            prescrTable.addCell(createHeaderCell(getTran("web","begindate"),1));
            prescrTable.addCell(createHeaderCell(getTran("web","enddate"),1));

            // run through found prescriptions
            String sPrescriber, sDateBeginFormatted, sDateEndFormatted, sCareUid, sPreviousCareUid = "", sCareDescr = "";
            CarePrescription prescr;
            java.util.Date tmpDate;
            
            for(int i=0; i<activePrescrs.size(); i++){
                prescr = (CarePrescription)activePrescrs.get(i);

                // prescriber
                sPrescriber = User.getFullUserName(prescr.getPrescriberUid());
                
                // format date begin
                tmpDate = prescr.getBegin();
                if(tmpDate!=null) sDateBeginFormatted = ScreenHelper.stdDateFormat.format(tmpDate);
                else              sDateBeginFormatted = "";

                // format date end
                tmpDate = prescr.getEnd();
                if(tmpDate!=null) sDateEndFormatted = ScreenHelper.stdDateFormat.format(tmpDate);
                else              sDateEndFormatted = "";

                // only search product-name when different product-UID
                sCareUid = prescr.getCareUid();
                if(!sCareUid.equals(sPreviousCareUid)){
                    sPreviousCareUid = sCareUid;

                    if(sCareUid!=null){
                        sCareDescr = getTran("care_type",sCareUid);
                    }
                    else{
                        sCareDescr = getTran("web","nonExistingCare");
                    }
                }

                prescrTable.addCell(createItemValueCell(sCareDescr,3));
                prescrTable.addCell(createItemValueCell(sPrescriber,3));
                prescrTable.addCell(createItemValueCell(sDateBeginFormatted,1));
                prescrTable.addCell(createItemValueCell(sDateEndFormatted,1));
            }
            
            // add prescriptions table
            if(prescrTable.size() > 0){
                table.addCell(createCell(new PdfPCell(prescrTable),1,PdfPCell.ALIGN_CENTER,PdfPCell.BOX));
            }
            else{
            	// no records found
            	table.addCell(createValueCell(getTran("web","noRecordsFound"),1));
            }
        }

        // add transaction to doc
        if(table.size() > 0){
            doc.add(new Paragraph(" "));
            doc.add(table);
        }
    }
    
    //--- PRINT VACCINATIONS ----------------------------------------------------------------------
    protected void printVaccinations(SessionContainerWO sessionContainerWO, AdminPerson activePatient) throws Exception {
        //new be.mxs.common.util.pdf.general.oc.examinations.PDFVaccinationCard().printCard(doc,sessionContainerWO,transactionVO,patient,req,sProject,sPrintLanguage,2);

        table = new PdfPTable(40);
        table.setWidthPercentage(pageWidth);         
        
        // title
        table.addCell(createTitleCell(getTran("web","vaccinations"),40));
                  
        // list vaccinations
        Iterator vaccIter = MedwanQuery.getInstance().getPersonalVaccinationsInfo(sessionContainerWO.getPersonVO(),sPrintLanguage).getVaccinationsInfoVO().iterator();
        if(vaccIter.hasNext()){
            // header
            table.addCell(createHeaderCell("",1));
            table.addCell(createHeaderCell(getTran("web","type"),9));
            table.addCell(createHeaderCell(getTran("web","comment"),10));
            table.addCell(createHeaderCell(getTran("web","date"),4));
            table.addCell(createHeaderCell(getTran("web","status"),6));
            table.addCell(createHeaderCell(getTran("web","nextDate"),4));
            table.addCell(createHeaderCell(getTran("web","nextStatus"),6));

            VaccinationInfoVO vacc;    
            while(vaccIter.hasNext()){
            	vacc = (VaccinationInfoVO)vaccIter.next();

            	// indicate when due     
                String sNextDate = vacc.getTransactionVO().getItemValue(ScreenHelper.ITEM_PREFIX+"ITEM_TYPE_VACCINATION_NEXT_DATE");	                               
                if(ScreenHelper.stdDateFormat.parse(sNextDate).before(new java.util.Date())){
                    // add warning-icon
                    Image image = Miscelaneous.getImage("warning.gif","");
                    image.scaleToFit(10,10);
                    
                    cell = new PdfPCell(image);
                    cell.setBorder(PdfPCell.BOX);
                    cell.setBorderColor(innerBorderColor);
                    cell.setVerticalAlignment(PdfPCell.ALIGN_MIDDLE);
                    cell.setColspan(1);
                    cell.setPaddingLeft(2);
                    cell.setPaddingRight(2);
                    table.addCell(cell);
                }
                else{
                	// add empty cell
                    table.addCell(emptyCell(1));
                }

                // one vaccination
                table.addCell(createValueCell(getTran("web.occup",vacc.getType()),9));
                table.addCell(createValueCell(getTran("web.occup",checkString(vacc.getComment()).replaceAll("\r\n"," ")),10));
                table.addCell(createValueCell(getTran("web.occup",vacc.getTransactionVO().getItemValue(ScreenHelper.ITEM_PREFIX+"ITEM_TYPE_VACCINATION_DATE")),4));
                table.addCell(createValueCell(getTran("web.Occup",vacc.getTransactionVO().getItemValue(ScreenHelper.ITEM_PREFIX+"ITEM_TYPE_VACCINATION_STATUS")),6));
                table.addCell(createValueCell(sNextDate,4));
                table.addCell(createValueCell(getTran("web.Occup",vacc.getNextStatus()),6));
            }
        }
        else{
        	// no records found
        	table.addCell(createValueCell(getTran("web","noRecordsFound"),40));
        }
        
        // add transaction to doc
        if(table.size() > 0){
            doc.add(new Paragraph(" "));
            doc.add(table);
        }         
    }
    
    //--- PRINT PROBLEM LIST (active problems) ----------------------------------------------------
    protected void printProblemList(SessionContainerWO sessionContainerWO, AdminPerson activePatient) throws Exception {
        table = new PdfPTable(5);
        table.setWidthPercentage(pageWidth);

        // title
        table.addCell(createTitleCell(getTran("web","problemlist"),5));

        Vector activeProblems = Problem.getActiveProblems(patient.personid);
        if(activeProblems.size() > 0){
            PdfPTable problemsTable = new PdfPTable(3);
            problemsTable.setWidthPercentage(100);

            // header
            problemsTable.addCell(createHeaderCell(getTran("web.occup","medwan.common.description"),4));
            problemsTable.addCell(createHeaderCell(getTran("web.occup","medwan.common.datebegin"),1));

            Problem problem;
            String comment, value;
            for(int n=0; n<activeProblems.size(); n++){
            	problem = (Problem)activeProblems.elementAt(n);

                value = problem.getCode()+" "+MedwanQuery.getInstance().getCodeTran(problem.getCodeType()+"code"+problem.getCode(),sPrintLanguage);
                Paragraph par = new Paragraph(value,FontFactory.getFont(FontFactory.HELVETICA,7,Font.NORMAL));

                // add comment if any
                if(problem.getComment().trim().length() > 0){
                    comment = " : "+problem.getComment().trim();
                    par.add(new Chunk(comment,FontFactory.getFont(FontFactory.HELVETICA,7,Font.ITALIC)));
                }

                cell = new PdfPCell(par);
                cell.setColspan(4);
                cell.setBorder(PdfPCell.BOX);
                cell.setBorderColor(innerBorderColor);
                cell.setVerticalAlignment(PdfPCell.ALIGN_TOP);
                cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
                problemsTable.addCell(cell);

                // date
                problemsTable.addCell(createValueCell(ScreenHelper.stdDateFormat.format(problem.getBegin()),1));
            }
        }
        else{
	    	// no records found
	    	table.addCell(createValueCell(getTran("web","noRecordsFound"),5));
        }

        // add table
        if(table.size() > 1){
            doc.add(new Paragraph(" "));
            doc.add(table);
        }
    }

    //--- PRINT ACTIVE DIAGNOSES ------------------------------------------------------------------
    protected void printActiveDiagnoses(SessionContainerWO sessionContainerWO, AdminPerson activePatient) throws Exception {
        table = new PdfPTable(1);
        table.setWidthPercentage(pageWidth);
        
        // title
        table.addCell(createTitleCell(getTran("web","activeDiagnoses"),1));
           	    
        Encounter activeEncounter = Encounter.getActiveEncounter(activePatient.personid);
        if(activeEncounter!=null){
    	    Vector diagnoses = Diagnosis.selectDiagnoses("","",activeEncounter.getUid(),"","","","","","","","","","","","");   
    	    
    	    if(diagnoses.size() > 0){	    
        	    Diagnosis diagnosis;
        	    
        	  	for(int i=0; i<diagnoses.size(); i++){
        			diagnosis = (Diagnosis)diagnoses.elementAt(i);
        			
        			String sValue = MedwanQuery.getInstance().getCodeTran(diagnosis.getCodeType()+"code"+diagnosis.getCode(),sPrintLanguage);
                    cell = new PdfPCell(new Paragraph("("+diagnosis.getCodeType()+") "+diagnosis.getCode()+" - "+sValue,FontFactory.getFont(FontFactory.HELVETICA,7,Font.NORMAL)));
                    cell.setColspan(1);
                    cell.setBorder(PdfPCell.BOX);
                    cell.setBorderColor(BaseColor.LIGHT_GRAY);
                    cell.setVerticalAlignment(PdfPCell.ALIGN_TOP);
                    table.addCell(cell);
        	  	}
    	    }
            else{
    	    	// no records found
    	    	table.addCell(createValueCell(getTran("web","noRecordsFound"),1));
            }
        }
        else{
	    	// no records found
	    	table.addCell(createValueCell(getTran("web","noRecordsFound"),1));
        }

        // add table
        if(table.size() > 1){
            doc.add(new Paragraph(" "));
            doc.add(table);
        }
    }

    //--- PRINT ACTIVE APPOINTMENTS ---------------------------------------------------------------
    protected void printActiveAppointments(SessionContainerWO sessionContainerWO, AdminPerson activePatient) throws Exception {
        table = new PdfPTable(20);
        table.setWidthPercentage(pageWidth);

        // title
        table.addCell(createTitleCell(getTran("web","activeAppointments"),20));
                           
        List appointments = Planning.getPatientFuturePlannings(activePatient.personid,ScreenHelper.stdDateFormat.format(new java.util.Date())); // no user
        if(appointments.size() > 0){
            // header
        	table.addCell(createHeaderCell(getTran("web.occup","medwan.common.date"),2));
        	table.addCell(createHeaderCell(ScreenHelper.uppercaseFirstLetter(getTran("web","from")),1));
        	table.addCell(createHeaderCell(ScreenHelper.uppercaseFirstLetter(getTran("web","to")),1));
        	table.addCell(createHeaderCell(getTran("planning","cancelationDate"),2));
        	table.addCell(createHeaderCell(getTran("planning","user"),4));
        	table.addCell(createHeaderCell(getTran("web","context"),3));
        	table.addCell(createHeaderCell(getTran("web","prestation"),3));
        	table.addCell(createHeaderCell(getTran("web","description"),4));
        	
            Planning appointment;
            String sUserName, sContext = "";
            String[] aHour;
            
            for(int i=0; i<appointments.size(); i++){
                appointment = (Planning)appointments.get(i);
                                       
                // context
                if(checkString(appointment.getContextID()).length() > 0){
                	sContext = getTran("web.Occup",appointment.getContextID());
                }
                
                // planning stop
                Calendar calPlanningStop = Calendar.getInstance();
                calPlanningStop.setTime(appointment.getPlannedDate());
                calPlanningStop.set(Calendar.SECOND,0);
                calPlanningStop.set(Calendar.MILLISECOND,0);

                if(checkString(appointment.getEstimatedtime()).length() > 0){
                    try{
                        aHour = appointment.getEstimatedtime().split(":");
                        calPlanningStop.setTime(appointment.getPlannedDate());
                        calPlanningStop.add(Calendar.HOUR,Integer.parseInt(aHour[0]));
                        calPlanningStop.add(Calendar.MINUTE,Integer.parseInt(aHour[1]));
                    }
                    catch(Exception e){
                        calPlanningStop.setTime(appointment.getPlannedDate());
                    }
                }
                
                // user
            	user = new User();
            	user.initialize(Integer.parseInt(appointment.getUserUID()));
            	user.person.initialize(user.personid);
            	String sUserService = user.getParameter("defaultserviceid");
            	if(sUserService!=null && sUserService.length()>0){
            		sUserService = " ("+sUserService.toUpperCase()+": "+getTran("service",sUserService)+")";
            	}
            	sUserName = user.person.firstname.toUpperCase()+", "+user.person.lastname.toUpperCase()+sUserService;
                          
                //***** one appointment *****                
            	table.addCell(createValueCell(ScreenHelper.stdDateFormat.format(appointment.getPlannedDate()),2));
            	table.addCell(createValueCell(ScreenHelper.hourFormat.format(appointment.getPlannedDate()),1));
            	
            	// planned end date
            	table.addCell(createValueCell(ScreenHelper.hourFormat.format(calPlanningStop.getTime()),1));

            	// cancellation date
            	if(appointment.getCancelationDate()!=null){
            	    table.addCell(createValueCell(ScreenHelper.stdDateFormat.format(appointment.getCancelationDate()),2));
            	}
            	else{
            	    table.addCell(emptyCell(2));
            	}
            	
            	table.addCell(createValueCell(sUserName,4));
            	table.addCell(createValueCell(sContext,3));
            	
            	// prestation
                ObjectReference orContact = appointment.getContact();
                if(orContact!=null){
                    if(orContact.getObjectType().equalsIgnoreCase("examination") && checkString(orContact.getObjectUid()).length() > 0){
                        ExaminationVO examination = MedwanQuery.getInstance().getExamination(orContact.getObjectUid(),sPrintLanguage);
                        table.addCell(createValueCell(getTran("examination",examination.getId().toString()),2));
                    }
                    else{
                	    table.addCell(emptyCell(3));
                    }
                }
                else{
            	    table.addCell(emptyCell(3));
                }
        
            	table.addCell(createValueCell(checkString(appointment.getDescription()).replaceAll("\r\n"," "),4));                
            }
        }
        else{
	    	// no records found
	    	table.addCell(createValueCell(getTran("web","noRecordsFound"),20));
        }
        
        // add table
        if(table.size() > 1){
            doc.add(new Paragraph(" "));
            doc.add(table);
        }     
    }
    
    //--- PRINT ACTIVE ENCOUNTER ------------------------------------------------------------------
    protected void printActiveEncounter(SessionContainerWO sessionContainerWO, AdminPerson activePatient) throws Exception {                        
        table = new PdfPTable(5);
        table.setWidthPercentage(pageWidth);

        // title
        table.addCell(createTitleCell(getTran("web","active_encounter"),5));
        
		Encounter activeEncounter = Encounter.getActiveEncounter(activePatient.personid);	
		if(activeEncounter!=null){
			// type
			table.addCell(createItemNameCell(getTran("web.occup","medwan.common.contacttype")));
			table.addCell(createItemValueCell(getTran("encountertype",activeEncounter.getType())));
			
			// begin date
			table.addCell(createItemNameCell(getTran("web","begin")));
			table.addCell(createItemValueCell(ScreenHelper.stdDateFormat.format(activeEncounter.getBegin())));
			
			// urgency origin
			table.addCell(createItemNameCell(getTran("openclinic.chuk","urgency.origin")));
			table.addCell(createItemValueCell(getTran("urgency.origin",activeEncounter.getOrigin())));
			
			// manager
			if(activeEncounter.getManager()!=null && activeEncounter.getManager().person!=null && activeEncounter.getManager().person.lastname.length() > 0){
    			table.addCell(createItemNameCell(getTran("web","manager")));
    			table.addCell(createItemValueCell(activeEncounter.getManager().person.getFullName()));
			}
			
			// service
			table.addCell(createItemNameCell(getTran("web","service")));
			table.addCell(createItemValueCell(activeEncounter.getService().getLabel(sPrintLanguage)));
			
			// reason
			table.addCell(createItemNameCell(getTran("openclinic.chuk","rfe")));
			String sReasons = ReasonForEncounter.getReasonsForEncounterAsText(activeEncounter.getUid(),sPrintLanguage);
			table.addCell(createItemValueCell(sReasons.length()==0?getTran("web","noneSpecified"):sReasons));
		}
        else{
	    	// no records found
	    	table.addCell(createValueCell(getTran("web","noRecordsFound"),5));
        }

        // add table
        if(table.size() > 1){
            doc.add(new Paragraph(" "));
            doc.add(table);
        }       
    }    

    /*
    //--- PRINT MOST RECENT ENCOUNTERS ------------------------------------------------------------
    // display the last encounter of each type
    protected void printMostRecentEncounters(SessionContainerWO sessionContainerWO, AdminPerson activePatient) throws Exception {
        table = new PdfPTable(5);
        table.setWidthPercentage(pageWidth);

        // title
        table.addCell(createTitleCell(getTran("web","mostRecentEncounters"),5));
                        
        // 1 - last visit
		Encounter lastVisit = Encounter.getInactiveEncounterBefore(activePatient.personid,"visit",new java.util.Date());
		if(lastVisit!=null){
			// type
			table.addCell(createItemNameCell(getTran("web.occup","medwan.common.contacttype")));
			table.addCell(createItemValueCell(getTran("encountertype",lastVisit.getType())));
			
			// begin date
			table.addCell(createItemNameCell(getTran("web","begin")));
			table.addCell(createItemValueCell(ScreenHelper.stdDateFormat.format(lastVisit.getBegin())));

			// end date
			table.addCell(createItemNameCell(getTran("web","end")));
			table.addCell(createItemValueCell(ScreenHelper.stdDateFormat.format(lastVisit.getEnd())));
			
			// urgency origin
			table.addCell(createItemNameCell(getTran("openclinic.chuk","urgency.origin")));
			table.addCell(createItemValueCell(getTran("urgency.origin",lastVisit.getOrigin())));
			
			// service
			table.addCell(createItemNameCell(getTran("web","service")));
			table.addCell(createItemValueCell(lastVisit.getService().getLabel(sPrintLanguage)));
			
			// reason
			table.addCell(createItemNameCell(getTran("openclinic.chuk","rfe")));
			table.addCell(createItemValueCell(ReasonForEncounter.getReasonsForEncounterAsText(lastVisit.getUid(),sPrintLanguage)));
		}
		
		// 2 - last admission
		Encounter lastAdmission = Encounter.getInactiveEncounterBefore(activePatient.personid,"admission",new java.util.Date());	
		if(lastAdmission!=null){
			// type
			table.addCell(createItemNameCell(getTran("web.occup","medwan.common.contacttype")));
			table.addCell(createItemValueCell(getTran("encountertype",lastAdmission.getType())));

			// begin date
			table.addCell(createItemNameCell(getTran("web","begin")));
			table.addCell(createItemValueCell(ScreenHelper.stdDateFormat.format(lastAdmission.getBegin())));

			// end date
			table.addCell(createItemNameCell(getTran("web","end")));
			table.addCell(createItemValueCell(ScreenHelper.stdDateFormat.format(lastAdmission.getEnd())));
			
			// urgency origin
			table.addCell(createItemNameCell(getTran("openclinic.chuk","urgency.origin")));
			table.addCell(createItemValueCell(getTran("urgency.origin",lastAdmission.getOrigin())));
			
			// service
			table.addCell(createItemNameCell(getTran("web","service")));
			table.addCell(createItemValueCell(lastAdmission.getService().getLabel(sPrintLanguage)));
			
			// reason
			table.addCell(createItemNameCell(getTran("openclinic.chuk","rfe")));
			table.addCell(createItemValueCell(ReasonForEncounter.getReasonsForEncounterAsText(lastAdmission.getUid(),sPrintLanguage)));
		}

		if(lastVisit==null && lastAdmission==null){
	    	// no records found
	    	table.addCell(createValueCell(getTran("web","noRecordsFound"),5));
        }
		
        // add table
        if(table.size() > 1){
            doc.add(new Paragraph(" "));
            doc.add(table);
        }
    }    
    */
    
    //--- PRINT ENCOUNTER HISTORY -----------------------------------------------------------------
    protected void printEncounterHistory(SessionContainerWO sessionContainerWO, AdminPerson activePatient) throws Exception {
    	// fetch UIDs of encounters to display, from parameters
    	Vector encounterUIDsToBePrinted = new Vector();
        Enumeration paramEnum = req.getParameterNames();
        String paramName;

        while(paramEnum.hasMoreElements()){
            paramName = (String)paramEnum.nextElement();

            if(paramName.startsWith("encounterUID_")){
                encounterUIDsToBePrinted.add(req.getParameter(paramName));
            }
        }
        
        table = new PdfPTable(1);
        table.setWidthPercentage(pageWidth);

        // title
        table.addCell(createTitleCell(getTran("web","encounterHistory"),1));
                        
        //*** 1 - visits ***
		Vector visits = (Vector)Encounter.getInactiveEncounters(activePatient.personid,"visit",new java.util.Date());
		if(visits.size() > 0){
	        PdfPTable encounterTable = new PdfPTable(25);
	        encounterTable.setWidthPercentage(pageWidth);
	        
	        boolean headerPrinted = false;
			Encounter encounter;
			for(int i=0; i<visits.size(); i++){
				encounter = (Encounter)visits.get(i);

				if(encounterUIDsToBePrinted.contains(encounter.getUid())){
					if(!headerPrinted){
						headerPrinted = false;
						
				        // subtitle
				        cell = createTitleCell(getTran("web","visits"),25);
				        cell.setHorizontalAlignment(PdfPCell.ALIGN_CENTER);
				        cell.setBackgroundColor(BGCOLOR_LIGHT);
				        encounterTable.addCell(cell);

				        // header
				        encounterTable.addCell(createHeaderCell(getTran("web.occup","medwan.common.contactType"),3));
				        encounterTable.addCell(createHeaderCell(getTran("web","begin"),2));
				        encounterTable.addCell(createHeaderCell(getTran("web","end"),2));
				        encounterTable.addCell(createHeaderCell(getTran("openclinic.chuk","urgency.origin"),3));
				        encounterTable.addCell(createHeaderCell(getTran("web","service"),5));
				        encounterTable.addCell(createHeaderCell(getTran("openclinic.chuk","rfe"),10));		
					}
					
					// one counter
					encounterTable.addCell(createValueCell(getTran("encounterType",encounter.getType()),3));
					encounterTable.addCell(createValueCell(ScreenHelper.stdDateFormat.format(encounter.getBegin()),2));
					encounterTable.addCell(createValueCell(ScreenHelper.stdDateFormat.format(encounter.getEnd()),2));
					encounterTable.addCell(createValueCell(getTran("urgency.origin",encounter.getOrigin()),3));
					encounterTable.addCell(createValueCell(encounter.getService().getLabel(sPrintLanguage),5));
					encounterTable.addCell(createValueCell(ReasonForEncounter.getReasonsForEncounterAsText(encounter.getUid(),sPrintLanguage),10));
				}
			}
			
	        // add encounter table to main table
	        if(encounterTable.size() > 0){
	            table.addCell(createCell(new PdfPCell(encounterTable),1,PdfPCell.ALIGN_CENTER,PdfPCell.BOX));
	        }	
	    }
		/*
		else{
	    	// no records found
	    	table.addCell(createValueCell(getTran("web","noRecordsFound"),1));
		}
		*/
		
		//*** 2 - admissions ***
		Vector admissions = (Vector)Encounter.getInactiveEncounters(activePatient.personid,"admission",new java.util.Date());
		if(admissions.size() > 0){
	        PdfPTable encounterTable = new PdfPTable(25);
	        encounterTable.setWidthPercentage(pageWidth);
	        
	        boolean headerPrinted = false;
			Encounter encounter;
			for(int i=0; i<admissions.size(); i++){
				encounter = (Encounter)admissions.get(i);
				
				if(encounterUIDsToBePrinted.contains(encounter.getUid())){
					if(!headerPrinted){
						headerPrinted = false;

				        // subtitle
				        cell = createTitleCell(getTran("web","admissions"),25);
				        cell.setHorizontalAlignment(PdfPCell.ALIGN_CENTER);
				        cell.setBackgroundColor(BGCOLOR_LIGHT);
				        encounterTable.addCell(cell);
				        
				        // header
				        encounterTable.addCell(createHeaderCell(getTran("web.occup","medwan.common.contactType"),3));
				        encounterTable.addCell(createHeaderCell(getTran("web","begin"),2));
				        encounterTable.addCell(createHeaderCell(getTran("web","end"),2));
				        encounterTable.addCell(createHeaderCell(getTran("openclinic.chuk","urgency.origin"),3));
				        encounterTable.addCell(createHeaderCell(getTran("web","service"),5));
				        encounterTable.addCell(createHeaderCell(getTran("openclinic.chuk","rfe"),10));
					}
					
					// one counter
					encounterTable.addCell(createValueCell(getTran("encounterType",encounter.getType()),3));
					encounterTable.addCell(createValueCell(ScreenHelper.stdDateFormat.format(encounter.getBegin()),2));
					encounterTable.addCell(createValueCell(ScreenHelper.stdDateFormat.format(encounter.getEnd()),2));
					encounterTable.addCell(createValueCell(getTran("urgency.origin",encounter.getOrigin()),3));
					encounterTable.addCell(createValueCell(encounter.getService().getLabel(sPrintLanguage),5));
					encounterTable.addCell(createValueCell(ReasonForEncounter.getReasonsForEncounterAsText(encounter.getUid(),sPrintLanguage),10));
				}
			}
			
	        // add encounter table to main table
	        if(encounterTable.size() > 0){
	            table.addCell(createCell(new PdfPCell(encounterTable),1,PdfPCell.ALIGN_CENTER,PdfPCell.BOX));
	        }	
	    }
		/*
		else{
	    	// no records found
	    	table.addCell(createValueCell(getTran("web","noRecordsFound"),1));
		}
		*/
		
        // add table
        if(table.size() > 1){
            doc.add(new Paragraph(" "));
            doc.add(table);
        }
    }    
    
    //--- PRINT WARNINGS (alerts) -----------------------------------------------------------------
    protected void printWarnings(SessionContainerWO sessionContainerWO) throws Exception {
        table = new PdfPTable(7);
        table.setWidthPercentage(pageWidth);

        // title
        table.addCell(createTitleCell(getTran("curative","warning.status.title"),7));

        // list alerts
        Collection alerts = MedwanQuery.getInstance().getTransactionsByType(sessionContainerWO.getHealthRecordVO(),IConstants.TRANSACTION_TYPE_ALERT);
        if(alerts.size() > 0){
            // header
        	table.addCell(createHeaderCell(getTran("web","title"),2));
        	table.addCell(createHeaderCell(getTran("web","description"),4));
        	table.addCell(createHeaderCell(getTran("web.occup","medwan.common.expiration-date"),1));
            
            Collection activeAlerts = sessionContainerWO.getActiveAlerts();
            Iterator alertsIter = activeAlerts.iterator();
            TransactionVO alert;
            String sValue;
            ItemVO itemVO;

            while(alertsIter.hasNext()){
                alert = (TransactionVO)alertsIter.next();

                // one alert
                table.addCell(createValueCell(alert.getItemValue(IConstants_PREFIX+"ITEM_TYPE_ALERTS_LABEL"),2));
                table.addCell(createValueCell(alert.getItemValue(IConstants_PREFIX+"ITEM_TYPE_ALERTS_DESCRIPTION"),4));
                table.addCell(createValueCell(alert.getItemValue(IConstants_PREFIX+"ITEM_TYPE_ALERTS_EXPIRATION_DATE"),1));
            }
        }
        else{
	    	// no records found
	    	table.addCell(createValueCell(getTran("web","noRecordsFound"),7));
        }

        // add table
        if(table.size() > 1){
            doc.add(new Paragraph(" "));
            doc.add(table);
        }
    }
    
    //--- PRINT TRANSACTIONS ----------------------------------------------------------------------
    private void printTransactions(boolean filterApplied, int partsOfTransactionToPrint) throws Exception {
        doc.add(new Paragraph(" "));
        
    	// header
        table = new PdfPTable(1);
        table.setWidthPercentage(pageWidth);
        PdfPCell cell = createTitleCell(getTran("pdf","examinations"),5);
        cell.setBorder(PdfPCell.BOX);
        cell.setBorderColor(BaseColor.DARK_GRAY);
        table.addCell(cell);
        doc.add(table);
	    
        // retrieve transaction-id OR transaction-type of transactions to be printed, from request
        int tranPropertyInVector = 0;
        Vector tranPropertiesToBePrinted = new Vector();

        if(filterApplied){
            Vector transactionIDsToBePrinted = new Vector();
            Vector transactionTypesToBePrinted = new Vector();
            Enumeration tranEnum = req.getParameterNames();
            String paramName;

            while(tranEnum.hasMoreElements()){
                paramName = (String)tranEnum.nextElement();

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

        // Get all transactions of active patient
        // Print only transactions between the specified start- and enddate.
        String tranProperty = null;

        Iterator tranIter = sessionContainerWO.getHealthRecordVO().getTransactions().iterator();
        while(tranIter.hasNext()){
            transactionVO = (TransactionVO)tranIter.next();

            // some transactions were selected
            if(tranPropertiesToBePrinted.size() > 0){
                     if(tranPropertyInVector==1) tranProperty = transactionVO.getTransactionId()+"_"+transactionVO.getServerId();
                else if(tranPropertyInVector==2) tranProperty = transactionVO.getTransactionType();

                // print the selected transaction complete
                if(tranPropertiesToBePrinted.contains(tranProperty)){
                    if(transactionVO!=null){
                        loadTransaction(transactionVO,2); // 0=nothing, 1=header, 2=all
                    }
                }
            }
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
        else if(transactionVO.getTransactionType().equalsIgnoreCase(IConstants_PREFIX+"TRANSACTION_TYPE_BIOMETRY")){
            loadTransactionOfType("PDFBiometry",transactionVO,partsOfTransactionToPrint);
        }
        else if(transactionVO.getTransactionType().equalsIgnoreCase(IConstants_PREFIX+"TRANSACTION_TYPE_BRONCHOSCOPY_PROTOCOL")){
            loadTransactionOfType("PDFBronchoscopyProtocol",transactionVO,partsOfTransactionToPrint);
        }
        else if(transactionVO.getTransactionType().equalsIgnoreCase(IConstants_PREFIX+"TRANSACTION_TYPE_CARDIO_ECHOGRAPHY_PROTOCOL")){
            loadTransactionOfType("PDFCardioEchographyProtocol",transactionVO,partsOfTransactionToPrint);
        }
        else if(transactionVO.getTransactionType().equalsIgnoreCase(IConstants_PREFIX+"TRANSACTION_TYPE_CARDIOVASCULAR_RISK")){
            loadTransactionOfType("PDFCardiovascularRisk",transactionVO,partsOfTransactionToPrint);
        }
        else if(transactionVO.getTransactionType().equalsIgnoreCase(IConstants_PREFIX+"TRANSACTION_TYPE_COLONOSCOPY_PROTOCOL")){
            loadTransactionOfType("PDFColonoscopyProtocol",transactionVO,partsOfTransactionToPrint);
        }
        else if(transactionVO.getTransactionType().equalsIgnoreCase(IConstants_PREFIX+"TRANSACTION_TYPE_DAILY_NOTE")){
            loadTransactionOfType("PDFDailyNote",transactionVO,partsOfTransactionToPrint);
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
        // respiratory function examination
        else if(transactionVO.getTransactionType().equalsIgnoreCase(IConstants_PREFIX+"TRANSACTION_TYPE_RESP_FUNC_EX")){
            if(!respGraphsArePrinted){  
                respGraphsArePrinted = true;
                Collection items = transactionVO.getItems();
                items.add(new ItemVO(new Integer(-54321),"graphsArePrinted","true", new Date(),new ItemContextVO(new Integer(-54321),"","")));
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
            loadTransactionOfType("PDFGenericTransaction",transactionVO,partsOfTransactionToPrint);
        }
    }
    
    //#############################################################################################
    //################################### UTILITY FUNCTIONS #######################################
    //#############################################################################################

    //--- LOAD TRANSACTION OF TYPE ----------------------------------------------------------------
    private void loadTransactionOfType(String sClassName, TransactionVO transactionVO, int partsOfTransactionToPrint){
    	Debug.println("loadTransactionOfType : "+sClassName);
    	
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
    
    //--- GET PRODUCT -----------------------------------------------------------------------------
    private Product getProduct(String sProductUid){
        // search for product in products-table
        Product product = Product.get(sProductUid);
    
        if(product!=null && product.getName()==null){
            // search for product in product-history-table
            product = product.getProductFromHistory(sProductUid);
        }
    
        return product;
    }
    
}