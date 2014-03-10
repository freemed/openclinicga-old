package be.mxs.common.util.pdf.general.dossierCreators;

import be.dpms.medwan.webapp.wo.common.system.SessionContainerWO;
import be.mxs.common.util.db.MedwanQuery;
import be.mxs.common.util.system.Debug;
import be.mxs.common.util.system.ScreenHelper;
import be.openclinic.hr.Career;
import be.openclinic.hr.Contract;
import be.openclinic.hr.DisciplinaryRecord;
import be.openclinic.hr.Leave;
import be.openclinic.hr.Salary;
import be.openclinic.hr.Skill;
import be.openclinic.hr.Training;
import be.openclinic.hr.Workschedule;

import com.itextpdf.text.*;
import com.itextpdf.text.pdf.PdfPCell;
import com.itextpdf.text.pdf.PdfPTable;
import com.itextpdf.text.pdf.PdfWriter;
import net.admin.AdminPerson;
import net.admin.User;

import javax.servlet.ServletContext;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpSession;

import org.dom4j.io.SAXReader;

import java.awt.Color;
import java.io.ByteArrayOutputStream;
import java.io.StringReader;
import java.text.DecimalFormat;
import java.text.SimpleDateFormat;
import java.util.*;
import java.util.List;

//#################################################################################################
// Composes a PDF document (in OpenWork-style) containing patient-info and summary-info in the header
// and a detailed view of all general staff data of the current user.
//#################################################################################################
public class StaffDossierPDFCreator extends PDFDossierCreator {

    //### INNER CLASS : PredefinedWeekSchedule ####################################################
    private class PredefinedWeekSchedule implements Comparable {
        public String id;
        public String type;  
        public String xml;  
        
        Vector timeBlocks = new Vector();
    
        //--- COMPARE TO ------------------------------------------------------
        public int compareTo(Object o){
            int comp;
            if(o.getClass().isInstance(this)){
                comp = this.type.compareTo(((PredefinedWeekSchedule)o).type);
            }
            else{
                throw new ClassCastException();
            }
    
            return comp;
        }
        
        //--- AS CONCAT VALUE -------------------------------------------------
        public String asConcatValue(){
            String sConcatValue = "";
            
            TimeBlock timeBlock;
            for(int i=0; i<timeBlocks.size(); i++){
                timeBlock = (TimeBlock)timeBlocks.get(i);
                
                sConcatValue+= checkString(timeBlock.dayIdx)+"|"+
                               checkString(timeBlock.beginHour)+"|"+
                               checkString(timeBlock.endHour)+"|"+
                               calculateDuration(timeBlock.beginHour,timeBlock.endHour)+"$";
            }
            
            return sConcatValue;
        }
        
        //--- CALCULATE DURATION ----------------------------------------------
        private String calculateDuration(String sBeginHour, String sEndHour){
            String sDuration = "";
    
            if(sBeginHour.length()>0 && sEndHour.length()>0){          
                // begin
                String[] beginParts = sBeginHour.split(":");
                String beginHour = checkString(beginParts[0]);
                if(beginHour.length()==0) beginHour = "0";
                String beginMinute = checkString(beginParts[1]);
                if(beginMinute.length()==0) beginMinute = "0";
    
                // end
                String[] endParts = sEndHour.split(":");
                String endHour = checkString(endParts[0]);
                if(endHour.length()==0) endHour = "0";
                String endMinute = checkString(endParts[1]);
                if(endMinute.length()==0) endMinute = "0";
    
                try{
                    java.util.Date dateFrom  = ScreenHelper.fullDateFormat.parse("01/01/2000 "+beginHour+":"+beginMinute),
                                   dateUntil = ScreenHelper.fullDateFormat.parse("01/01/2000 "+endHour+":"+endMinute);
    
                    long millisDiff = dateUntil.getTime() - dateFrom.getTime();
                    int totalMinutes = (int)(millisDiff/(60*1000));
                    
                    int hour    = totalMinutes/60,
                        minutes = (totalMinutes%60);
    
                    sDuration = (hour<10?"0"+hour:hour)+":"+(minutes<10?"0"+minutes:minutes);
                }
                catch(Exception e){
                    if(Debug.enabled) e.printStackTrace();
                    Debug.printProjectErr(e,Thread.currentThread().getStackTrace());
                }
            }

            return sDuration;
        }
       
    }
    
    //### INNER CLASS : TimeBlock #################################################################
    private class TimeBlock implements Comparable {
        public String id;
        public String dayIdx;
        public String beginHour;
        public String endHour;
        
        //--- COMPARE TO ------------------------------------------------------
        public int compareTo(Object o){
            int comp;
            if(o.getClass().isInstance(this)){
                comp = this.dayIdx.compareTo(((TimeBlock)o).dayIdx);
            }
            else{
                throw new ClassCastException();
            }
    
            return comp;
        }
    }
    //#############################################################################################
    
    
    //--- CONSTRUCTOR -----------------------------------------------------------------------------
    public StaffDossierPDFCreator(SessionContainerWO sessionContainerWO, User user, AdminPerson patient,
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
            doc.addTitle("Medical Record Data for "+patient.firstname+" "+patient.lastname);
            doc.addKeywords(patient.firstname+", "+patient.lastname);
            doc.setPageSize(PageSize.A4);
            doc.open();

            //*** HEADER **************************************************************************
            printDocumentHeader(req);

            //*** TITLE ***************************************************************************
            String sTitle = getTran("web","staffDossier").toUpperCase();
            printDocumentTitle(req,sTitle);

            //*** SECTIONS ************************************************************************
            /*
                - 1 : Administratie persoonlijk
                - 2 : Administratie privé
                - 3 : Human resources contracten
                - 4 : Human resources Competenties
                - 5 : Human resources carrière
                - 6 : Human resources disciplinair dossier
                - 7 : Human resources verlof en afwezigheden
                - 8 : Human resources salaris
                - 9 : Human resources uurrooster
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
                printAdminData(patient);
            }
            if(sections[sectionIdx++]){
                //printPhoto(patient); // 1
            }
            if(sections[sectionIdx++]){
                printAdminPrivateData(patient); // 2
            }            
            if(sections[sectionIdx++]){
                printHRContracts(sessionContainerWO,patient); // 3
            }
            if(sections[sectionIdx++]){
                printHRSkills(sessionContainerWO,patient); // 4
            }
            if(sections[sectionIdx++]){
                printHRCareer(sessionContainerWO,patient); // 5
            }
            if(sections[sectionIdx++]){
                printHRDisciplinaryRecord(sessionContainerWO,patient); // 6
            }
            if(sections[sectionIdx++]){
                printHRLeaves(sessionContainerWO,patient); // 8
            }
            if(sections[sectionIdx++]){
                printHRSalary(sessionContainerWO,patient); // 9
            }
            if(sections[sectionIdx++]){
                printHRWorkSchedules(sessionContainerWO,patient); // 10
            }
            if(sections[sectionIdx++]){
                printHRTraining(sessionContainerWO,patient); // 11
            }
            if(sections[sectionIdx++]){
                printSignature(); // 12 : not in jsp
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

    //--- PRINT HR CONTRACTS ----------------------------------------------------------------------
    protected void printHRContracts(SessionContainerWO sessionContainerWO, AdminPerson activePatient) throws Exception {
        table = new PdfPTable(24);
        table.setWidthPercentage(pageWidth);

        // title
        table.addCell(createTitleCell(getTran("web","contracts"),24));
             
        // compose object to pass search criteria with
        Contract findObject = new Contract();
        findObject.personId = Integer.parseInt(activePatient.personid); // required
        
        List contracts = Contract.getList(findObject);        
        if(contracts.size() > 0){
            // header
            table.addCell(createHeaderCell(getTran("web.hr","id"),2)); // contractId
            table.addCell(createHeaderCell(getTran("web.hr","begindate"),2));
            table.addCell(createHeaderCell(getTran("web.hr","enddate"),2));
            table.addCell(createHeaderCell(getTran("web.hr","duration"),5));
            table.addCell(createHeaderCell(getTran("web.hr","function"),2)); // functionCode
            table.addCell(createHeaderCell(getTran("web.hr","functionTitle"),4));
            table.addCell(createHeaderCell(getTran("web.hr","functionDescription"),7));
            
            Hashtable hSort = new Hashtable();
            Contract contract;
        
            // sort on contract.beginDate
            for(int i=0; i<contracts.size(); i++){
                contract = (Contract)contracts.get(i);
                hSort.put(contract.beginDate.getTime()+"="+contract.getUid(),contract);
            } 
            
            Vector keys = new Vector(hSort.keySet());
            Collections.sort(keys);
            Collections.reverse(keys);
           
            Iterator iter = keys.iterator();            
            while(iter.hasNext()){
                contract = (Contract)hSort.get(iter.next());
                
                // one record
                table.addCell(createValueCell(Integer.toString(contract.objectId),2));
                table.addCell(createValueCell(ScreenHelper.getSQLDate(contract.beginDate),2));
                table.addCell(createValueCell(ScreenHelper.getSQLDate(contract.endDate),2));
                table.addCell(createValueCell(calculatePeriod(contract.beginDate,contract.endDate,sPrintLanguage),5));
                table.addCell(createValueCell(getTran("hr.contract.functioncode",checkString(contract.functionCode)),2));
                table.addCell(createValueCell(checkString(contract.functionTitle),4));
                table.addCell(createValueCell(contract.functionDescription.replaceAll("\r\n"," "),7));
                
                addContractDetails(table,contract); // legal reference codes
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
    
    //--- PRINT HR SKILLS -------------------------------------------------------------------------
    protected void printHRSkills(SessionContainerWO sessionContainerWO, AdminPerson activePatient) throws Exception {
        table = new PdfPTable(10);
        table.setWidthPercentage(pageWidth);

        // title
        table.addCell(createTitleCell(getTran("web","skills"),10));

        Skill skill = Skill.get(activePatient.personid);
        if(skill!=null){
            displayLanguageSkills(table,skill.languages);                
            displayComputerSkills(table,skill);
            
            //*** varia skills ***
            table.addCell(createHeaderCell(getTran("web.hr","varia"),10));
            
            // drivingLicense
            table.addCell(createValueCell(getTran("web.hr","drivingLicense"),4));
            table.addCell(createValueCell(getTran("hr.skills.drivinglicense",skill.drivingLicense),6));
                                 
            // communicationSkills
            table.addCell(createValueCell(getTran("web.hr","communicationSkills"),4));
            table.addCell(createValueCell(getTran("hr.skills.range2",skill.communicationSkills),6));
                               
            // stressResistance
            table.addCell(createValueCell(getTran("web.hr","stressResistance"),4));
            table.addCell(createValueCell(getTran("hr.skills.range2",skill.stressResistance),6));
            
            // comment
            table.addCell(createValueCell(getTran("web.hr","comment"),4));
            table.addCell(createValueCell(skill.comment.replaceAll("\r\n"," "),6));
        }
        else{
            // no records found
            table.addCell(createValueCell(getTran("web","noRecordsFound"),10));  
        }

        // add transaction to doc
        if(table.size() > 0){
            doc.add(new Paragraph(" "));
            doc.add(table);
        }         
    }
    
    //--- PRINT HR CAREER -------------------------------------------------------------------------
    protected void printHRCareer(SessionContainerWO sessionContainerWO, AdminPerson activePatient) throws Exception {
        table = new PdfPTable(12);
        table.setWidthPercentage(pageWidth);

        // title
        table.addCell(createTitleCell(getTran("web","career"),12));

        // compose object to pass search criteria with
        Career findObject = new Career();
        findObject.personId = Integer.parseInt(activePatient.personid); // required
        
        List careers = Career.getList(findObject);        
        if(careers.size() > 0){ 
            // header
            table.addCell(createHeaderCell(getTran("web.hr","begin"),1));
            table.addCell(createHeaderCell(getTran("web.hr","end"),1));
            table.addCell(createHeaderCell(getTran("web","duration"),2));
            table.addCell(createHeaderCell(getTran("web.hr","position"),2));
            table.addCell(createHeaderCell(getTran("web","department"),4));
            table.addCell(createHeaderCell(getTran("web.hr","grade"),1));
            table.addCell(createHeaderCell(getTran("web.hr","status"),1));

            Hashtable hSort = new Hashtable();
            Career career;
        
            // sort on career.begin
            for(int i=0; i<careers.size(); i++){
                career = (Career)careers.get(i);                
                hSort.put(career.begin.getTime()+"="+career.getUid(),career);
            }
        
            Vector keys = new Vector(hSort.keySet());
            Collections.sort(keys);
            Collections.reverse(keys);
            
            Iterator iter = keys.iterator();            
            while(iter.hasNext()){
                career = (Career)hSort.get(iter.next());

                // service
                String sServiceName = "";
                if(career.serviceUid.length() > 0){
                    sServiceName = "["+career.serviceUid+"] "+getTran("service",career.serviceUid);
                }
                
                // one career
                table.addCell(createValueCell(ScreenHelper.getSQLDate(career.begin),1));
                table.addCell(createValueCell(ScreenHelper.getSQLDate(career.end),1));
                table.addCell(createValueCell(calculatePeriod(career.begin,career.end,sPrintLanguage),2));
                table.addCell(createValueCell(career.position,2));
                table.addCell(createValueCell(sServiceName,4));
                table.addCell(createValueCell(getTran("hr.career.grade",career.grade),1));
                table.addCell(createValueCell(getTran("hr.career.status",career.status),1));
                
                addCareerDetails(table,career); // comment
            }
        }
        else{
            // no records found
            table.addCell(createValueCell(getTran("web","noRecordsFound"),12));  
        }

        // add transaction to doc
        if(table.size() > 0){
            doc.add(new Paragraph(" "));
            doc.add(table);
        }         
    }
    
    //--- PRINT HR DISCIPLINARY RECORD ------------------------------------------------------------
    protected void printHRDisciplinaryRecord(SessionContainerWO sessionContainerWO, AdminPerson activePatient) throws Exception {
        table = new PdfPTable(12);
        table.setWidthPercentage(pageWidth);

        // title
        table.addCell(createTitleCell(getTran("web","disciplinaryRecord"),12));

        // compose object to pass search criteria with
        DisciplinaryRecord findObject = new DisciplinaryRecord();
        findObject.personId = Integer.parseInt(activePatient.personid); // required

        List disRecs = DisciplinaryRecord.getList(findObject);
        if(disRecs.size() > 0){
            // header
            table.addCell(createHeaderCell(getTran("web.hr","date"),1));
            table.addCell(createHeaderCell(getTran("web.hr","title"),3));
            table.addCell(createHeaderCell(getTran("web.hr","description"),3));
            table.addCell(createHeaderCell(getTran("web.hr","decision"),1));
            table.addCell(createHeaderCell(getTran("web.hr","decisionBy"),2));
            table.addCell(createHeaderCell(getTran("web.hr","duration"),2));
            
            Hashtable hSort = new Hashtable();
            DisciplinaryRecord disRec;
        
            // sort on disRec.date
            for(int i=0; i<disRecs.size(); i++){
                disRec = (DisciplinaryRecord)disRecs.get(i);
                hSort.put(disRec.date.getTime()+"="+disRec.getUid(),disRec);
            }
        
            Vector keys = new Vector(hSort.keySet());
            Collections.sort(keys);
            Collections.reverse(keys);
            
            Iterator iter = keys.iterator();
            while(iter.hasNext()){
                disRec = (DisciplinaryRecord)hSort.get(iter.next());
                
                // one record 
                table.addCell(createValueCell(ScreenHelper.getSQLDate(disRec.date),1));
                table.addCell(createValueCell(checkString(disRec.title),3));
                table.addCell(createValueCell(disRec.description.replaceAll("\r\n"," "),3));
                table.addCell(createValueCell(getTran("hr.disrec.decision",disRec.decision),1));
                table.addCell(createValueCell(disRec.decisionBy,2));
                table.addCell(createValueCell(disRec.duration+" "+getTran("web","days"),2));
                
                addDisciplinaryRecordDetails(table,disRec); // follow-up
            }
        }
        else{
            // no records found
            table.addCell(createValueCell(getTran("web","noRecordsFound"),12));  
        }

        // add transaction to doc
        if(table.size() > 0){
            doc.add(new Paragraph(" "));
            doc.add(table);
        }         
    }
    
    //--- PRINT HR LEAVES -------------------------------------------------------------------------
    protected void printHRLeaves(SessionContainerWO sessionContainerWO, AdminPerson activePatient) throws Exception {
        table = new PdfPTable(12);
        table.setWidthPercentage(pageWidth);

        // title
        table.addCell(createTitleCell(getTran("web","leaves"),12));

        // compose object to pass search criteria with
        Leave findObject = new Leave();
        findObject.personId = Integer.parseInt(activePatient.personid); // required
        
        List leaves = Leave.getList(findObject);
        DecimalFormat deci = new DecimalFormat(MedwanQuery.getInstance().getConfigParam("priceFormat","0.00"));
        
        if(leaves.size() > 0){
            // header
            table.addCell(createHeaderCell(getTran("web.hr","begin"),1));
            table.addCell(createHeaderCell(getTran("web.hr","end"),1));
            table.addCell(createHeaderCell(getTran("web","duration"),2));
            table.addCell(createHeaderCell(getTran("web.hr","type"),2));
            table.addCell(createHeaderCell(getTran("web.hr","episodeCode"),2));
            table.addCell(createHeaderCell(getTran("web.hr","requestDate"),1));
            table.addCell(createHeaderCell(getTran("web.hr","authorizationDate"),1));
            table.addCell(createHeaderCell(getTran("web.hr","authorizedBy"),2));
            
            Hashtable hSort = new Hashtable();
            Leave leave;
                    
            // sort on leave.begin
            for(int i=0; i<leaves.size(); i++){
                leave = (Leave)leaves.get(i);                
                hSort.put(leave.begin.getTime()+"="+leave.getUid(),leave);
            }
        
            Vector keys = new Vector(hSort.keySet());
            Collections.sort(keys);
            Collections.reverse(keys);
            
            Iterator iter = keys.iterator();            
            while(iter.hasNext()){                
                leave = (Leave)hSort.get(iter.next());

                // one record
                table.addCell(createValueCell(ScreenHelper.getSQLDate(leave.begin),1));
                table.addCell(createValueCell(ScreenHelper.getSQLDate(leave.end),1));
                table.addCell(createValueCell(deci.format(leave.duration).replaceAll(",",".")+" "+getTran("web","days"),2));
                table.addCell(createValueCell(getTran("hr.leave.type",leave.type),2));
                table.addCell(createValueCell(leave.episodeCode,2));
                table.addCell(createValueCell(ScreenHelper.getSQLDate(leave.requestDate),1));
                table.addCell(createValueCell(ScreenHelper.getSQLDate(leave.authorizationDate),1));
                table.addCell(createValueCell(leave.authorizedBy,2));
                
                addLeaveDetails(table,leave); // comment
            }
        }
        else{
            // no records found
            table.addCell(createValueCell(getTran("web","noRecordsFound"),12));  
        }

        // add transaction to doc
        if(table.size() > 0){
            doc.add(new Paragraph(" "));
            doc.add(table);
        }         
    }
    
    //--- PRINT HR SALARY -------------------------------------------------------------------------
    protected void printHRSalary(SessionContainerWO sessionContainerWO, AdminPerson activePatient) throws Exception {
        table = new PdfPTable(30);
        table.setWidthPercentage(pageWidth);

        // title
        table.addCell(createTitleCell(getTran("web","salary"),30));

        // compose object to pass search criteria with
        Salary findObject = new Salary();
        findObject.personId = Integer.parseInt(activePatient.personid); // required
                
        List salaries = Salary.getList(findObject);
        if(salaries.size() > 0){
            DecimalFormat deci = new DecimalFormat(MedwanQuery.getInstance().getConfigParam("priceFormat","0.00"));

            // header
            table.addCell(createHeaderCell(getTran("web.hr","begin"),3));
            table.addCell(createHeaderCell(getTran("web.hr","end"),3));
            table.addCell(createHeaderCell(getTran("web.hr","contract"),6));
            table.addCell(createHeaderCell(getTran("web.hr","grossSalary"),4));
            table.addCell(createHeaderCell(getTran("web.hr","grossSalaryPeriod"),6));
            table.addCell(createHeaderCell(getTran("web.hr","comment"),8));
            
            Hashtable hSort = new Hashtable();
            Salary salary;
        
            // sorted on salary.beginDate
            for(int i=0; i<salaries.size(); i++){
                salary = (Salary)salaries.get(i);
                hSort.put(salary.begin.getTime()+"="+salary.getUid(),salary);
            }
            
            Vector keys = new Vector(hSort.keySet());
            Collections.sort(keys);
            Collections.reverse(keys);
            
            Iterator iter = keys.iterator();            
            while(iter.hasNext()){
                salary = (Salary)hSort.get(iter.next());
                
                // contractName == contractId (not uid)
                String sContractName = "";
                if(checkString(salary.contractUid).length() > 0){
                    sContractName = salary.contractUid.substring(salary.contractUid.indexOf(".")+1);
                }
                
                // one record
                table.addCell(createValueCell(ScreenHelper.getSQLDate(salary.begin),3));
                table.addCell(createValueCell(ScreenHelper.getSQLDate(salary.end),3));
                table.addCell(createValueCell(sContractName,6));
                
                cell = createValueCell(deci.format(salary.salary)+" "+MedwanQuery.getInstance().getConfigParam("currency",""),4);
                cell.setHorizontalAlignment(PdfPCell.ALIGN_RIGHT);
                table.addCell(cell);
                
                table.addCell(createValueCell(getTran("hr.salary.period",salary.salaryPeriod),6));
                table.addCell(createValueCell(salary.comment.replaceAll("\r\n"," "),8));
                               
                addSalaryDetails(table,salary);
            }
        }
        else{
            // no records found
            table.addCell(createValueCell(getTran("web","noRecordsFound"),30));  
        }

        // add transaction to doc
        if(table.size() > 0){
            doc.add(new Paragraph(" "));
            doc.add(table);
        }         
    }
    
    //--- PRINT HR WORK SCHEDULES -----------------------------------------------------------------
    protected void printHRWorkSchedules(SessionContainerWO sessionContainerWO, AdminPerson activePatient) throws Exception {
        table = new PdfPTable(10);
        table.setWidthPercentage(pageWidth);

        // title
        table.addCell(createTitleCell(getTran("web","workSchedule"),10));

        // compose object to pass search criteria with
        Workschedule findObject = new Workschedule();
        findObject.personId = Integer.parseInt(activePatient.personid); // required
        
        List workschedules = Workschedule.getList(findObject);
        String sReturn = "";
        
        if(workschedules.size() > 0){
            // header
            table.addCell(createHeaderCell(getTran("web.hr","begin"),1));
            table.addCell(createHeaderCell(getTran("web.hr","end"),1));
            table.addCell(createHeaderCell(getTran("web.hr","fte.short"),1));
            table.addCell(createHeaderCell(getTran("web.hr","type"),2));
            table.addCell(createHeaderCell(getTran("web.hr","details"),4));
            table.addCell(createHeaderCell(getTran("web.hr","duration"),1));
            
            Hashtable hSort = new Hashtable();
            Workschedule workschedule;
        
            // sort on workschedule.getUid
            for(int i=0; i<workschedules.size(); i++){
                workschedule = (Workschedule)workschedules.get(i);
                hSort.put(workschedule.getUid()+"="+workschedule.getUid(),workschedule);
            }
            
            Vector keys = new Vector(hSort.keySet());
            Collections.sort(keys);
            Collections.reverse(keys);
            
            Iterator iter = keys.iterator();            
            while(iter.hasNext()){
                workschedule = (Workschedule)hSort.get(iter.next());

                // parse xml
                String sXML = checkString(workschedule.scheduleXml);
                String sScheduleType = "", sScheduleHours = "";
                            
                if(sXML.length() > 0){
                    SAXReader reader = new SAXReader(false);
                    org.dom4j.Document xmlDoc = reader.read(new StringReader(sXML));

                    // fetch type and hours
                    org.dom4j.Element workScheduleElem = xmlDoc.getRootElement();
                    if(workScheduleElem!=null){
                        org.dom4j.Element scheduleElem = workScheduleElem.element("Schedule");
                        if(scheduleElem!=null){
                            sScheduleType = checkString(scheduleElem.attributeValue("type"));
            
                            if(sScheduleType.equalsIgnoreCase("day")){
                                sScheduleHours = checkString(scheduleElem.elementText("HoursPerDay"));
                            }
                            else if(sScheduleType.equalsIgnoreCase("week")){
                                org.dom4j.Element weekSchedule = scheduleElem.element("WeekSchedule");
                                if(weekSchedule!=null){
                                    sScheduleHours = checkString(weekSchedule.elementText("HoursPerWeek"));
                                }
                            }
                            else if(sScheduleType.equalsIgnoreCase("month")){
                                sScheduleHours = checkString(scheduleElem.elementText("HoursPerMonth"))+" "+getTran("web.hr","hours").toLowerCase();
                            }
                        }
                    }
                    workschedule.type = sScheduleType;
                }
                
                // one record
                table.addCell(createValueCell(ScreenHelper.getSQLDate(workschedule.begin),1));
                table.addCell(createValueCell(ScreenHelper.getSQLDate(workschedule.end),1));
                table.addCell(createValueCell(workschedule.fte+"%",1));
                table.addCell(createValueCell(getTran("web.hr",sScheduleType+"Schedule")+(sScheduleType.equals("week")?" ("+getPredefinedWeekScheduleName(workschedule)+")":""),2));
                table.addCell(createValueCell(getWorkscheduleDetails(workschedule),4));
                table.addCell(createValueCell(sScheduleHours,1));  
                
                //addWorkscheduleDetails(table,workschedule);
            }
        }
        else{
            // no records found
            table.addCell(createValueCell(getTran("web","noRecordsFound"),10));  
        }

        // add transaction to doc
        if(table.size() > 0){
            doc.add(new Paragraph(" "));
            doc.add(table);
        }         
    }
    
    //--- PRINT HR TRAINING -----------------------------------------------------------------------
    protected void printHRTraining(SessionContainerWO sessionContainerWO, AdminPerson activePatient) throws Exception {
        table = new PdfPTable(11);
        table.setWidthPercentage(pageWidth);

        // title
        table.addCell(createTitleCell(getTran("web","training"),11));

        // compose object to pass search criteria with
        Training findObject = new Training();
        findObject.personId = Integer.parseInt(activePatient.personid); // required
        
        List trainings = Training.getList(findObject);
        if(trainings.size() > 0){
            // header
            table.addCell(createHeaderCell(getTran("web.hr","begin"),1));
            table.addCell(createHeaderCell(getTran("web.hr","end"),1));
            table.addCell(createHeaderCell(getTran("web.hr","titleOrDiploma"),4));
            table.addCell(createHeaderCell(getTran("web.hr","level"),1)); // traininglevel
            table.addCell(createHeaderCell(getTran("web.hr","institute"),3));
            table.addCell(createHeaderCell(getTran("web.hr","date"),1)); // diplomaDate
            
            Hashtable hSort = new Hashtable();
            Training training;
        
            // sort on training.begin
            for(int i=0; i<trainings.size(); i++){
                training = (Training)trainings.get(i);
                hSort.put(training.begin.getTime()+"="+training.getUid(),training);
            }
        
            Vector keys = new Vector(hSort.keySet());
            Collections.sort(keys);
            Collections.reverse(keys);
            
            Iterator iter = keys.iterator();
            while(iter.hasNext()){
                training = (Training)hSort.get(iter.next());
                
                // one record 
                table.addCell(createValueCell(ScreenHelper.getSQLDate(training.begin),1));
                table.addCell(createValueCell(ScreenHelper.getSQLDate(training.end),1));
                table.addCell(createValueCell(checkString(training.diploma),4));
                table.addCell(createValueCell(getTran("hr.training.level",training.level),1));
                table.addCell(createValueCell(checkString(training.institute),3));
                table.addCell(createValueCell(ScreenHelper.stdDateFormat.format(training.diplomaDate),1));
            }
        }
        else{
            // no records found
            table.addCell(createValueCell(getTran("web","noRecordsFound"),11));  
        }

        // add transaction to doc
        if(table.size() > 0){
            doc.add(new Paragraph(" "));
            doc.add(table);
        }         
    }
        
    //#############################################################################################
    //################################### UTILITY FUNCTIONS #######################################
    //#############################################################################################
    
    //--- GET PREDEFINED WEEK SCHEDULE NAME -------------------------------------------------------
    private String getPredefinedWeekScheduleName(Workschedule workschedule) throws Exception {
    	String sName = "";

    	if(workschedule.type.equalsIgnoreCase("week")){
            String sScheduleXml = checkString(workschedule.scheduleXml);
            if(sScheduleXml.length() > 0){
                // parse weekSchedule from xml            
                SAXReader reader = new SAXReader(false);
                org.dom4j.Document document = reader.read(new StringReader(sScheduleXml));
                org.dom4j.Element workScheduleElem = document.getRootElement();
                
                org.dom4j.Element scheduleElem = workScheduleElem.element("Schedule");
                if(scheduleElem!=null){                 
                	workschedule.scheduleXml = scheduleElem.asXML();
                }
            }
            
            String sWeekSchedule = workschedule.getScheduleElementValue(workschedule.type,"WeekSchedule").replaceAll("\"","'");        

            // parse weekSchedule from xml           
            SAXReader reader = new SAXReader(false);
            org.dom4j.Document document = reader.read(new StringReader(sWeekSchedule));
            org.dom4j.Element weekSchedule = document.getRootElement();
            	        
		    Vector weekSchedules = parsePredefinedWeekSchedulesFromXMLConfigValue();
		    PredefinedWeekSchedule schedule;
		    for(int i=0; i<weekSchedules.size(); i++){
		        schedule = (PredefinedWeekSchedule)weekSchedules.get(i);

		        if(weekSchedule.attributeValue("scheduleType").toLowerCase().equals(schedule.id.toLowerCase())){
		            sName = schedule.type;
		        }
		    }
    	}
    	
	    return sName;
    }
    
    //--- ADD DISCIPLINARY RECORD DETAILS ---------------------------------------------------------    
    // follow-up
    private void addDisciplinaryRecordDetails(PdfPTable table, DisciplinaryRecord disRec){
        if(disRec.followUp.length() > 0){
        	PdfPTable detailsTable = new PdfPTable(10);
            detailsTable.setWidthPercentage(100);

            // follow-up in grey and italic
            //detailsTable.addCell(createValueCell(disRec.followUp.replaceAll("\r\n"," "),10));
            Font font = FontFactory.getFont(FontFactory.HELVETICA,7,Font.ITALIC);
            font.setColor(BaseColor.GRAY);
            cell = new PdfPCell(new Paragraph(disRec.followUp.replaceAll("\r\n"," "),font));
            cell.setColspan(10);
            cell.setBorder(PdfPCell.BOX);
            cell.setBorderColor(innerBorderColor);
            cell.setVerticalAlignment(PdfPCell.ALIGN_TOP);
            cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
            detailsTable.addCell(cell);
            
            table.addCell(createCell(new PdfPCell(detailsTable),table.getNumberOfColumns(),PdfPCell.ALIGN_CENTER,PdfPCell.BOX));
        }       
    }
    
    //--- ADD LEAVE DETAILS -----------------------------------------------------------------------    
    // comment
    private void addLeaveDetails(PdfPTable table, Leave leave){
        if(leave.comment.length() > 0){
        	PdfPTable detailsTable = new PdfPTable(10);
            detailsTable.setWidthPercentage(100);

            // follow-up in grey and italic
            //detailsTable.addCell(createValueCell(leave.comment.replaceAll("\r\n"," "),10));
            Font font = FontFactory.getFont(FontFactory.HELVETICA,7,Font.ITALIC);
            font.setColor(BaseColor.GRAY);
            cell = new PdfPCell(new Paragraph(leave.comment.replaceAll("\r\n"," "),font));
            cell.setColspan(10);
            cell.setBorder(PdfPCell.BOX);
            cell.setBorderColor(innerBorderColor);
            cell.setVerticalAlignment(PdfPCell.ALIGN_TOP);
            cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
            detailsTable.addCell(cell);
            
            table.addCell(createCell(new PdfPCell(detailsTable),table.getNumberOfColumns(),PdfPCell.ALIGN_CENTER,PdfPCell.BOX));
        }       
    }
    
    //--- ADD CONTRACT DETAILS --------------------------------------------------------------------
    // legal reference codes
    private void addContractDetails(PdfPTable table, Contract contract){
        PdfPTable detailsTable = new PdfPTable(10);
        detailsTable.setWidthPercentage(100);
        
        if(contract.getLegalReferenceCode(1).length() > 0 || 
           contract.getLegalReferenceCode(2).length() > 0 ||
           contract.getLegalReferenceCode(3).length() > 0 ||
           contract.getLegalReferenceCode(4).length() > 0 ||
           contract.getLegalReferenceCode(5).length() > 0){
            //detailsTable.addCell(createSubtitleCell(getTran("web.hr","legalReferenceCodes"),10));
            
            // one LRC
            for(int i=0; i<4; i++){
                if(contract.getLegalReferenceCode(i+1).length() > 0){ 
                    detailsTable.addCell(createValueCell(getTran("web.hr","legalReferenceCode")+" "+(i+1),4));
                    detailsTable.addCell(createValueCell(contract.getLegalReferenceCode(i+1),6));
                }
            }
        }
        
        if(detailsTable.size() > 0){
        	table.addCell(emptyCell(2));
            cell = createCell(new PdfPCell(detailsTable),table.getNumberOfColumns()-2,PdfPCell.ALIGN_CENTER,PdfPCell.BOX);
            cell.setPadding(2);
            table.addCell(cell);
        }
    }
    
    //--- ADD CAREER DETAILS ----------------------------------------------------------------------
    // comment
    private void addCareerDetails(PdfPTable table, Career career){
        if(career.comment.length() > 0){
        	PdfPTable detailsTable = new PdfPTable(10);
            detailsTable.setWidthPercentage(100);

            // comment in grey and italic
            //detailsTable.addCell(createValueCell(career.comment.replaceAll("\r\n"," "),10));
            Font font = FontFactory.getFont(FontFactory.HELVETICA,7,Font.ITALIC);
            font.setColor(BaseColor.GRAY);
            cell = new PdfPCell(new Paragraph(career.comment.replaceAll("\r\n"," "),font));
            cell.setColspan(10);
            cell.setBorder(PdfPCell.BOX);
            cell.setBorderColor(innerBorderColor);
            cell.setVerticalAlignment(PdfPCell.ALIGN_TOP);
            cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
            detailsTable.addCell(cell);
            
            table.addCell(createCell(new PdfPCell(detailsTable),table.getNumberOfColumns(),PdfPCell.ALIGN_CENTER,PdfPCell.BOX));
        }       
    }
    
    //--- ADD SALARY DETAILS (for printHRSalary) --------------------------------------------------
    // benfits, bonuses, otherIncome, deductions
    private void addSalaryDetails(PdfPTable table, Salary salary){
        PdfPTable detailsTable = new PdfPTable(10);
        detailsTable.setWidthPercentage(100);
        
        //*** XML 1 - benefits (multi-add) **************************
        if(salary.benefits.length() > 0){
            detailsTable.addCell(createSubtitleCell(getTran("web.hr","benefits"),10));
            
            // header          
            detailsTable.addCell(createHeaderCell(getTran("web.hr","beginDate"),1));
            detailsTable.addCell(createHeaderCell(getTran("web.hr","endDate"),1));
            detailsTable.addCell(createHeaderCell(getTran("web.hr","period"),2));
            detailsTable.addCell(createHeaderCell(getTran("web.hr","type"),3));
            detailsTable.addCell(createHeaderCell(getTran("web.hr","amount"),3));
            
            try{
                // parse benefits from xml           
                SAXReader reader = new SAXReader(false);
                org.dom4j.Document document = reader.read(new StringReader(salary.benefits));
                org.dom4j.Element benefitsElem = document.getRootElement();
         
                if(benefitsElem!=null){          
                    String sTmpBegin, sTmpEnd, sTmpPeriod, sTmpType, sTmpAmount;
                    org.dom4j.Element benefitElem;

                    Iterator benefitsIter = benefitsElem.elementIterator("Benefit");
                    while(benefitsIter.hasNext()){
                        benefitElem = (org.dom4j.Element)benefitsIter.next();
                                                
                        sTmpBegin  = checkString(benefitElem.elementText("Begin"));
                        sTmpEnd    = checkString(benefitElem.elementText("End"));
                        sTmpPeriod = checkString(benefitElem.elementText("Period"));
                        sTmpType   = checkString(benefitElem.elementText("Type"));
                        sTmpAmount = checkString(benefitElem.elementText("Amount"));
                        
                        // one benefit
                        detailsTable.addCell(createValueCell(sTmpBegin,1));
                        detailsTable.addCell(createValueCell(sTmpEnd,1));
                        detailsTable.addCell(createValueCell(getTran("hr.salary.period",sTmpPeriod),2));
                        detailsTable.addCell(createValueCell(getTran("hr.salary.benefit.type",sTmpType),3));
                        
                        cell = createValueCell(sTmpAmount+" "+MedwanQuery.getInstance().getConfigParam("currency",""),3);
                        cell.setHorizontalAlignment(PdfPCell.ALIGN_RIGHT);
                        detailsTable.addCell(cell);
                    }
                }
            }
            catch(Exception e){
                Debug.printStackTrace(e);
            }
        }
          
        //*** XML 2 - bonuses (multi-add) **************************        
        if(salary.bonuses.length() > 0){
            table.addCell(createSubtitleCell(getTran("web.hr","bonuses"),10));

            // header
            detailsTable.addCell(createHeaderCell(getTran("web.hr","beginDate"),1));
            detailsTable.addCell(createHeaderCell(getTran("web.hr","endDate"),1));
            detailsTable.addCell(createHeaderCell(getTran("web.hr","period"),2));
            detailsTable.addCell(createHeaderCell(getTran("web.hr","type"),2));
            detailsTable.addCell(createHeaderCell(getTran("web","percentage"),2));
            detailsTable.addCell(createHeaderCell(getTran("web.hr","amount"),2));
            
            try{
                // parse bonuses from xml           
                SAXReader reader = new SAXReader(false);
                org.dom4j.Document document = reader.read(new StringReader(salary.bonuses));
                org.dom4j.Element bonusesElem = document.getRootElement();
         
                if(bonusesElem!=null){          
                    String sTmpBegin, sTmpEnd, sTmpPeriod, sTmpType, sTmpPercentage, sTmpAmount;
                    org.dom4j.Element bonusElem;

                    Iterator bonusesIter = bonusesElem.elementIterator("Bonus");
                    while(bonusesIter.hasNext()){
                        bonusElem = (org.dom4j.Element)bonusesIter.next();
                                                
                        sTmpBegin      = checkString(bonusElem.elementText("Begin"));
                        sTmpEnd        = checkString(bonusElem.elementText("End"));
                        sTmpPeriod     = checkString(bonusElem.elementText("Period"));
                        sTmpType       = checkString(bonusElem.elementText("Type"));
                        sTmpPercentage = checkString(bonusElem.elementText("Percentage"));
                        sTmpAmount     = checkString(bonusElem.elementText("Amount"));

                        // one record
                        detailsTable.addCell(createValueCell(sTmpBegin,1));
                        detailsTable.addCell(createValueCell(sTmpEnd,1));
                        detailsTable.addCell(createValueCell(sTmpPeriod,2));
                        detailsTable.addCell(createValueCell(sTmpType,2));
                        detailsTable.addCell(createValueCell(sTmpPercentage+"%",2));
                        
                        cell = createValueCell(sTmpAmount+" "+MedwanQuery.getInstance().getConfigParam("currency",""),2);
                        cell.setHorizontalAlignment(PdfPCell.ALIGN_RIGHT);
                        detailsTable.addCell(cell);                      
                    }
                }
            }
            catch(Exception e){
                Debug.printStackTrace(e);
            }
        }
        
        //*** XML 3 - otherIncome (multi-add) ***********************
        if(salary.otherIncome.length() > 0){
            table.addCell(createSubtitleCell(getTran("web.hr","otherIncome"),10));

            // header
            detailsTable.addCell(createHeaderCell(getTran("web.hr","beginDate"),1));
            detailsTable.addCell(createHeaderCell(getTran("web.hr","endDate"),1));
            detailsTable.addCell(createHeaderCell(getTran("web.hr","period"),2));
            detailsTable.addCell(createHeaderCell(getTran("web.hr","type"),3));
            detailsTable.addCell(createHeaderCell(getTran("web.hr","amount"),3));
            
            try{
                // parse otherIncome from xml           
                SAXReader reader = new SAXReader(false);
                org.dom4j.Document document = reader.read(new StringReader(salary.otherIncome));
                org.dom4j.Element benefitsElem = document.getRootElement();
         
                if(benefitsElem!=null){          
                    String sTmpBegin, sTmpEnd, sTmpPeriod, sTmpType, sTmpAmount;
                    org.dom4j.Element otherIncomeElem;

                    Iterator otherIncomesIter = benefitsElem.elementIterator("OtherIncome");
                    while(otherIncomesIter.hasNext()){
                        otherIncomeElem = (org.dom4j.Element)otherIncomesIter.next();
                                                
                        sTmpBegin  = checkString(otherIncomeElem.elementText("Begin"));
                        sTmpEnd    = checkString(otherIncomeElem.elementText("End"));
                        sTmpPeriod = checkString(otherIncomeElem.elementText("Period"));
                        sTmpType   = checkString(otherIncomeElem.elementText("Type"));
                        sTmpAmount = checkString(otherIncomeElem.elementText("Amount"));

                        // one record
                        detailsTable.addCell(createValueCell(sTmpBegin,1));
                        detailsTable.addCell(createValueCell(sTmpEnd,1));
                        detailsTable.addCell(createValueCell(sTmpPeriod,2));
                        detailsTable.addCell(createValueCell(sTmpType,3));
                        
                        cell = createValueCell(sTmpAmount+" "+MedwanQuery.getInstance().getConfigParam("currency",""),3);
                        cell.setHorizontalAlignment(PdfPCell.ALIGN_RIGHT);
                        detailsTable.addCell(cell);                      
                    }
                }
            }
            catch(Exception e){
                Debug.printStackTrace(e);
            }
        }
        
        //*** XML 4 - deductions (multi-add) ************************
        if(salary.deductions.length() > 0){
            detailsTable.addCell(createSubtitleCell(getTran("web.hr","deductions"),10));
            
            // header
            detailsTable.addCell(createHeaderCell(getTran("web.hr","beginDate"),1));
            detailsTable.addCell(createHeaderCell(getTran("web.hr","endDate"),1));
            detailsTable.addCell(createHeaderCell(getTran("web.hr","period"),2));
            detailsTable.addCell(createHeaderCell(getTran("web.hr","type"),3));
            detailsTable.addCell(createHeaderCell(getTran("web.hr","amount"),3));
                   
            try{
                // parse deductions from xml           
                SAXReader reader = new SAXReader(false);
                org.dom4j.Document document = reader.read(new StringReader(salary.deductions));
                org.dom4j.Element deductionsElem = document.getRootElement();
         
                if(deductionsElem!=null){          
                    String sTmpBegin, sTmpEnd, sTmpPeriod, sTmpType, sTmpAmount;
                    org.dom4j.Element deductionElem;

                    Iterator deductionsIter = deductionsElem.elementIterator("Deduction");
                    while(deductionsIter.hasNext()){
                        deductionElem = (org.dom4j.Element)deductionsIter.next();
                                                
                        sTmpBegin  = checkString(deductionElem.elementText("Begin"));
                        sTmpEnd    = checkString(deductionElem.elementText("End"));
                        sTmpPeriod = checkString(deductionElem.elementText("Period"));
                        sTmpType   = checkString(deductionElem.elementText("Type"));
                        sTmpAmount = checkString(deductionElem.elementText("Amount"));

                        // one record
                        detailsTable.addCell(createValueCell(sTmpBegin,1));
                        detailsTable.addCell(createValueCell(sTmpEnd,1));
                        detailsTable.addCell(createValueCell(sTmpPeriod,2));
                        detailsTable.addCell(createValueCell(sTmpType,3));
                        
                        cell = createValueCell(sTmpAmount+" "+MedwanQuery.getInstance().getConfigParam("currency",""),3);
                        cell.setHorizontalAlignment(PdfPCell.ALIGN_RIGHT);
                        detailsTable.addCell(cell);
                    }
                }
            }
            catch(Exception e){
                Debug.printStackTrace(e);
            }
        }
        
        if(detailsTable.size() > 0){
        	table.addCell(emptyCell(3));
            cell = createCell(new PdfPCell(detailsTable),table.getNumberOfColumns()-3,PdfPCell.ALIGN_CENTER,PdfPCell.BOX);
            cell.setPadding(2);
            table.addCell(cell);
        }
    }
    
    //--- ADD WORKSCHEDULE DETAILS (for printHRWorkschedules) -------------------------------------
    // type : day, week, month
    private void addWorkscheduleDetails(PdfPTable table, Workschedule schedule) throws Exception {
        PdfPTable detailsTable = new PdfPTable(10);
        detailsTable.setWidthPercentage(100);
        
             if(schedule.type.equals("day"))   displayDaySchedule(detailsTable,schedule);
        else if(schedule.type.equals("week"))  displayWeekSchedule(detailsTable,schedule);
        else if(schedule.type.equals("month")) displayMonthSchedule(detailsTable,schedule);
             
       if(detailsTable.size() > 0){
           cell = createCell(new PdfPCell(detailsTable),table.getNumberOfColumns(),PdfPCell.ALIGN_CENTER,PdfPCell.BOX);
           cell.setPadding(2);
           table.addCell(cell);
       }
    }
    
    //--- GET WORKSCHEDULE DETAILS (for printHRWorkschedules) -------------------------------------
    // type : day, week, month
    private String getWorkscheduleDetails(Workschedule schedule) throws Exception {
        String sDetails = "";
        
             if(schedule.type.equals("day"))   sDetails = getDayScheduleDetails(schedule);
        else if(schedule.type.equals("week"))  sDetails = getWeekScheduleDetails(schedule);
        else if(schedule.type.equals("month")) sDetails = getMonthScheduleDetails(schedule);

        return sDetails;
    }
    
    //--- DISPLAY DAY SCHEDULE --------------------------------------------------------------------
    private void displayDaySchedule(PdfPTable table, Workschedule schedule){                    
        table.addCell(createValueCell(getDayScheduleDetails(schedule),10));     
    }
    
    //--- GET DAY SCHEDULE DETAILS ----------------------------------------------------------------
    private String getDayScheduleDetails(Workschedule schedule){
        // day name + begin + end
        String sValue = getTran("web.hr","daily")+" "+
                        getTran("web.hr","from").toLowerCase()+" "+schedule.getScheduleElementValue(schedule.type,"BeginHour")+" "+
        		        getTran("web.hr","to").toLowerCase()+" "+schedule.getScheduleElementValue(schedule.type,"EndHour");
        
        return sValue;
    }
    
    //--- DISPLAY WEEK SCHEDULE -------------------------------------------------------------------
    private void displayWeekSchedule(PdfPTable table, Workschedule schedule) throws Exception {
        String sScheduleXml = checkString(schedule.scheduleXml);
        if(sScheduleXml.length() > 0){
            // parse weekSchedule from xml            
            SAXReader reader = new SAXReader(false);
            org.dom4j.Document document = reader.read(new StringReader(sScheduleXml));
            org.dom4j.Element workScheduleElem = document.getRootElement();
            
            // attribute : type
            org.dom4j.Element scheduleElem = workScheduleElem.element("Schedule");
            if(scheduleElem!=null){                 
            	schedule.scheduleXml = scheduleElem.asXML();
            }
        }
        
        String sWeekSchedule = schedule.getScheduleElementValue(schedule.type,"WeekSchedule").replaceAll("\"","'");        

        // parse weekSchedule from xml           
        SAXReader reader = new SAXReader(false);
        org.dom4j.Document document = reader.read(new StringReader(sWeekSchedule));
        org.dom4j.Element weekSchedule = document.getRootElement();
            
        displayTimeblocks(table,parseWeekschedule(weekSchedule));
    }
    
    //--- GET WEEK SCHEDULE DETAILS ---------------------------------------------------------------
    private String getWeekScheduleDetails(Workschedule schedule) throws Exception {
    	String sDetails = "";
    	
        String sScheduleXml = checkString(schedule.scheduleXml);
        if(sScheduleXml.length() > 0){
            // parse weekSchedule from xml            
            SAXReader reader = new SAXReader(false);
            org.dom4j.Document document = reader.read(new StringReader(sScheduleXml));
            org.dom4j.Element workScheduleElem = document.getRootElement();
            
            // attribute : type
            org.dom4j.Element scheduleElem = workScheduleElem.element("Schedule");
            if(scheduleElem!=null){                 
            	schedule.scheduleXml = scheduleElem.asXML();
            }
        }
        
        String sWeekSchedule = schedule.getScheduleElementValue(schedule.type,"WeekSchedule").replaceAll("\"","'");        

        // parse weekSchedule from xml           
        SAXReader reader = new SAXReader(false);
        org.dom4j.Document document = reader.read(new StringReader(sWeekSchedule));
        org.dom4j.Element weekSchedule = document.getRootElement();
            
        sDetails = getTimeblocksDetails(parseWeekschedule(weekSchedule));
        
        return sDetails;
    }

    //--- DISPLAY MONTH SCHEDULE ------------------------------------------------------------------
    private void displayMonthSchedule(PdfPTable table, Workschedule schedule){
        table.addCell(createValueCell(getMonthScheduleDetails(schedule),10));
    }
    
    //--- GET MONTH SCHEDULE DETAILS --------------------------------------------------------------
    private String getMonthScheduleDetails(Workschedule schedule){
    	String sDetails = "";
    	
        // monthScheduleType + hours
    	sDetails+= getTran("hr.workschedule.monthscheduletype",schedule.getScheduleElementValue(schedule.type,"PredefinedHoursPerMonth"))+
                   " ("+schedule.getScheduleElementValue(schedule.type,"HoursPerMonth")+" "+getTran("web.hr","hours").toLowerCase()+")";
        
        return sDetails;
    }

    //--- PARSE WEEKSCHEDULE ----------------------------------------------------------------------
    // <WeekSchedule scheduleType='weekSchedule.2'>
    //  <TimeBlocks>
    //   <TimeBlock><DayIdx>1</DayIdx><BeginHour>09:00</BeginHour><EndHour>17:36</EndHour><Duration>08:36</Duration></TimeBlock>
    //   <TimeBlock><DayIdx>2</DayIdx><BeginHour>09:00</BeginHour><EndHour>17:36</EndHour><Duration>08:36</Duration></TimeBlock>
    //   <TimeBlock><DayIdx>3</DayIdx><BeginHour>09:00</BeginHour><EndHour>17:36</EndHour><Duration>08:36</Duration></TimeBlock>
    //  </TimeBlocks>
    // </WeekSchedule>
    //
    // to concat value : DayIdx+"|"+BeginHour+"|"+EndHour+"|"+Duration+"$"
    private String parseWeekschedule(org.dom4j.Element weekSchedule){
        String sConcatValue = "";
        
        if(weekSchedule!=null){       
            org.dom4j.Element timeBlocks = weekSchedule.element("TimeBlocks");
            if(timeBlocks!=null){
                Iterator timeBlockIter = timeBlocks.elementIterator("TimeBlock");

                String sTmpDayIdx, sTmpBeginHour, sTmpEndHour, sTmpDuration;
                org.dom4j.Element timeBlock;
                
                while(timeBlockIter.hasNext()){
                    timeBlock = (org.dom4j.Element)timeBlockIter.next();
                                            
                    sTmpDayIdx    = checkString(timeBlock.elementText("DayIdx"));
                    sTmpBeginHour = checkString(timeBlock.elementText("BeginHour"));
                    sTmpEndHour   = checkString(timeBlock.elementText("EndHour"));
                    sTmpDuration  = checkString(timeBlock.elementText("Duration"));
                    
                    sConcatValue+= sTmpDayIdx+"|"+sTmpBeginHour+"|"+sTmpEndHour+"|"+sTmpDuration+"$";
                }
            }
        }
        
        return sConcatValue;
    }
    
    //--- DISPLAY TIME BLOCKS ---------------------------------------------------------------------
    private void displayTimeblocks(PdfPTable table, String sTB){
        if(sTB.indexOf("|") > -1){
            Vector predefinedWeekSchedules = parsePredefinedWeekSchedulesFromXMLConfigValue();
            
            String sTmpTB = sTB;
            sTB = "";
            
            String sTmpDayIdx, sTmpBeginHour, sTmpEndHour, sTmpDuration;
       
            while(sTmpTB.indexOf("$") > -1){
                sTmpDayIdx = "";
                sTmpBeginHour = "";
                sTmpEndHour = "";
                sTmpDuration = "";
  
                if(sTmpTB.indexOf("|") > -1){
                    sTmpDayIdx = sTmpTB.substring(0,sTmpTB.indexOf("|"));
                    sTmpTB = sTmpTB.substring(sTmpTB.indexOf("|")+1);
                }
          
                if(sTmpTB.indexOf("|") > -1){
                    sTmpBeginHour = sTmpTB.substring(0,sTmpTB.indexOf("|"));
                    sTmpTB = sTmpTB.substring(sTmpTB.indexOf("|")+1);
                }
              
                if(sTmpTB.indexOf("|") > -1){
                    sTmpEndHour = sTmpTB.substring(0,sTmpTB.indexOf("|"));
                    sTmpTB = sTmpTB.substring(sTmpTB.indexOf("|")+1);
                }

                if(sTmpTB.indexOf("$") > -1){
                    sTmpDuration = sTmpTB.substring(0,sTmpTB.indexOf("$"));
                    sTmpTB = sTmpTB.substring(sTmpTB.indexOf("$")+1);
                }
                
                // mark greenblue when part of predefined weekschedule --%>
                boolean isInDefaultSchedule = false;
          
                PredefinedWeekSchedule predefinedWeekSchedule;
                String sPreDefinedWeekSchedule;
                for(int i=0; i<predefinedWeekSchedules.size() && !isInDefaultSchedule; i++){
                	predefinedWeekSchedule = (PredefinedWeekSchedule)predefinedWeekSchedules.get(i);
                	sPreDefinedWeekSchedule = predefinedWeekSchedule.asConcatValue();
                      
                    if(sPreDefinedWeekSchedule.indexOf(sTmpDayIdx+"|"+sTmpBeginHour+"|"+sTmpEndHour+"|"+sTmpDuration+"$") > -1){
                        isInDefaultSchedule = true;            
                    }
                }
          
                displayTimeBlock(table,sTmpDayIdx,sTmpBeginHour,sTmpEndHour,sTmpDuration,isInDefaultSchedule);
            }
        }
    }
    
    //--- GET TIME BLOCKS DETAILS -----------------------------------------------------------------
    private String getTimeblocksDetails(String sTB){
    	String sDetails = "";
    	
        if(sTB.indexOf("|") > -1){
            Vector predefinedWeekSchedules = parsePredefinedWeekSchedulesFromXMLConfigValue();
            
            String sTmpTB = sTB;
            sTB = "";
            
            String sTmpDayIdx, sTmpBeginHour, sTmpEndHour, sTmpDuration;
       
            while(sTmpTB.indexOf("$") > -1){
                sTmpDayIdx = "";
                sTmpBeginHour = "";
                sTmpEndHour = "";
                sTmpDuration = "";
  
                if(sTmpTB.indexOf("|") > -1){
                    sTmpDayIdx = sTmpTB.substring(0,sTmpTB.indexOf("|"));
                    sTmpTB = sTmpTB.substring(sTmpTB.indexOf("|")+1);
                }
          
                if(sTmpTB.indexOf("|") > -1){
                    sTmpBeginHour = sTmpTB.substring(0,sTmpTB.indexOf("|"));
                    sTmpTB = sTmpTB.substring(sTmpTB.indexOf("|")+1);
                }
              
                if(sTmpTB.indexOf("|") > -1){
                    sTmpEndHour = sTmpTB.substring(0,sTmpTB.indexOf("|"));
                    sTmpTB = sTmpTB.substring(sTmpTB.indexOf("|")+1);
                }

                if(sTmpTB.indexOf("$") > -1){
                    sTmpDuration = sTmpTB.substring(0,sTmpTB.indexOf("$"));
                    sTmpTB = sTmpTB.substring(sTmpTB.indexOf("$")+1);
                }
                
                // mark greenblue when part of predefined weekschedule --%>
                boolean isInDefaultSchedule = false;
          
                PredefinedWeekSchedule predefinedWeekSchedule;
                String sPreDefinedWeekSchedule;
                for(int i=0; i<predefinedWeekSchedules.size() && !isInDefaultSchedule; i++){
                	predefinedWeekSchedule = (PredefinedWeekSchedule)predefinedWeekSchedules.get(i);
                	sPreDefinedWeekSchedule = predefinedWeekSchedule.asConcatValue();
                      
                    if(sPreDefinedWeekSchedule.indexOf(sTmpDayIdx+"|"+sTmpBeginHour+"|"+sTmpEndHour+"|"+sTmpDuration+"$") > -1){
                        isInDefaultSchedule = true;            
                    }
                }
          
                sDetails+= getTimeblockDetails(sTmpDayIdx,sTmpBeginHour,sTmpEndHour,sTmpDuration,isInDefaultSchedule)+"\r\n";
            }
        }
        
        return sDetails;
    }
    
    //--- DISPLAY TIME BLOCK ----------------------------------------------------------------------
    private void displayTimeBlock(PdfPTable table, String sDayIdx, String sBeginHour, String sEndHour, String sDuration, boolean isInDefaultSchedule){
        table.addCell(createValueCell(getTimeblockDetails(sDayIdx,sBeginHour,sEndHour,sDuration,isInDefaultSchedule),10));     
    }
    
    //--- GET TIME BLOCK DETAILS ------------------------------------------------------------------
    private String getTimeblockDetails(String sDayIdx, String sBeginHour, String sEndHour, String sDuration, boolean isInDefaultSchedule){
        // day name + begin + end
        String sValue = getTran("web.hr","on")+" "+getTran("hr.workschedule.days","day"+sDayIdx)+" "+
                        sDuration+" "+getTran("web.hr","hours").toLowerCase()+" "+
                        getTran("web.hr","from").toLowerCase()+" "+sBeginHour+" "+
        		        getTran("web.hr","to").toLowerCase()+" "+sEndHour;
        
        // mark when part of predefined weekschedule
        if(isInDefaultSchedule==true){
        	sValue+= " ["+getTran("web.hr","defaultSchedule").toLowerCase()+"]";
        }
        
        return sValue;
    }

    //--- PARSE PREDEFINED WEEK SCHEDULES FROM XML CONFIGVALUE ------------------------------------
    private Vector parsePredefinedWeekSchedulesFromXMLConfigValue(){
        Vector schedules = new Vector();
        
        // read xml containing predefined weekSchedules
        try{
            SAXReader xmlReader = new SAXReader();
            String sXMLValue = MedwanQuery.getInstance().getConfigString("defaultWeekschedules");
            org.dom4j.Document document = xmlReader.read(new StringReader(sXMLValue));
            
            if(document!=null){
                org.dom4j.Element root = document.getRootElement();
                Iterator scheduleElems = root.elementIterator("WeekSchedule");

                PredefinedWeekSchedule schedule;
                org.dom4j.Element scheduleElem, timeBlockElem;
                while(scheduleElems.hasNext()){
                    schedule = new PredefinedWeekSchedule();
                    
                    scheduleElem = (org.dom4j.Element)scheduleElems.next();
                    schedule.id = scheduleElem.attributeValue("id");
                    schedule.type = scheduleElem.attributeValue("scheduleType");
                    schedule.xml = scheduleElem.asXML();

                    // timeblocks
                    Iterator timeBlockElems = scheduleElem.element("TimeBlocks").elementIterator("TimeBlock");
                    while(timeBlockElems.hasNext()){
                        timeBlockElem = (org.dom4j.Element)timeBlockElems.next();
                        
                        TimeBlock timeBlock = new TimeBlock();
                        timeBlock.id        = checkString(timeBlockElem.attributeValue("id"));
                        timeBlock.dayIdx    = checkString(timeBlockElem.elementText("DayIdx"));
                        timeBlock.beginHour = checkString(timeBlockElem.elementText("BeginHour"));
                        timeBlock.endHour   = checkString(timeBlockElem.elementText("EndHour"));
                                
                        schedule.timeBlocks.add(timeBlock);    
                    }

                    Collections.sort(schedule.timeBlocks); // on day     
                    schedules.add(schedule);
                }
            }
        }
        catch(Exception e){
            if(Debug.enabled) e.printStackTrace();
            Debug.printProjectErr(e,Thread.currentThread().getStackTrace());
        }

        return schedules;
    }
        
    //--- DISPLAY LANGUAGE SKILLS (for printHRSkills) ---------------------------------------------
    private void displayLanguageSkills(PdfPTable table, String sLS){
        if(sLS.length() > 0 && sLS.indexOf("|") > -1){
            // header
            table.addCell(createHeaderCell(getTran("web.hr","languages"),10));
           
            // subtitle
            table.addCell(createSubtitleCell(getTran("web.hr","languages.language"),4));
            table.addCell(createSubtitleCell(getTran("web.hr","languages.spoken"),2));
            table.addCell(createSubtitleCell(getTran("web.hr","languages.reading"),2));
            table.addCell(createSubtitleCell(getTran("web.hr","languages.writing"),2));
          
            String sTmpLang, sTmpSpoken, sTmpReading, sTmpWriting;
            String sTmpLS = sLS;
            sLS = "";

            // parse value
            while(sTmpLS.indexOf("$") > -1){
                sTmpLang = "";
                sTmpSpoken = "";
                sTmpReading = "";
                sTmpWriting = "";
                
                if(sTmpLS.indexOf("|") > -1){
                    sTmpLang = sTmpLS.substring(0,sTmpLS.indexOf("|"));
                    sTmpLS = sTmpLS.substring(sTmpLS.indexOf("|")+1);
                }
                    
                if(sTmpLS.indexOf("|") > -1){
                    sTmpSpoken = sTmpLS.substring(0,sTmpLS.indexOf("|"));
                    sTmpLS = sTmpLS.substring(sTmpLS.indexOf("|")+1);
                }
                    
                if(sTmpLS.indexOf("|") > -1){
                    sTmpReading = sTmpLS.substring(0,sTmpLS.indexOf("|"));
                    sTmpLS = sTmpLS.substring(sTmpLS.indexOf("|")+1);
                }
    
                if(sTmpLS.indexOf("$") > -1){
                    sTmpWriting = sTmpLS.substring(0,sTmpLS.indexOf("$"));
                    sTmpLS = sTmpLS.substring(sTmpLS.indexOf("$")+1);
                }
    
                // one language skill
                table.addCell(createValueCell(getTran("hr.skills.languages",sTmpLang),4));
                table.addCell(createValueCell(getTran("hr.skills.range1",sTmpSpoken),2));
                table.addCell(createValueCell(getTran("hr.skills.range1",sTmpReading),2));
                table.addCell(createValueCell(getTran("hr.skills.range1",sTmpWriting),2));
            }
        }
        else{
            // no records found
            table.addCell(createValueCell(getTran("web","noRecordsFound"),10));  
        }
    }

    //--- DISPLAY COMPUTER SKILLS (for printHRSkills) ---------------------------------------------
    private void displayComputerSkills(PdfPTable table, Skill skill){        
        if(skill.itOffice.length() > 0 || skill.itInternet.length() > 0 || skill.itOther.length() > 0){
            // header
            table.addCell(createHeaderCell(getTran("web.hr","computerSkills"),10));
            
            // a - office
            table.addCell(createValueCell(getTran("web.hr","itOffice"),4));
            table.addCell(createValueCell(getTran("hr.skills.range1",skill.itOffice),6));
            
            // b - internet
            table.addCell(createValueCell(getTran("web.hr","itInternet"),4));
            table.addCell(createValueCell(getTran("hr.skills.range1",skill.itInternet),6));
            
            // c - other
            table.addCell(createValueCell(getTran("web.hr","itOther"),4));
            table.addCell(createValueCell(skill.itOther.replaceAll("\r\n",", "),6));
        }
        else{
            // no records found
            table.addCell(createValueCell(getTran("web","noRecordsFound"),10));  
        }
    }
        
    //--- YEARS BETWEEN ---------------------------------------------------------------------------
    private long yearsBetween(final Calendar startDate, final Calendar endDate){
        int yearCount = 0;
        Calendar cursor = (Calendar)startDate.clone();   
                  
        // test
        Calendar test = (Calendar)startDate.clone();
        test.add(Calendar.YEAR,1); 
        if(test.after(endDate)) return yearCount;

        // next full unit
        Calendar nfu = (Calendar)startDate.clone();

        // count        
        while(cursor.getTimeInMillis() < endDate.getTimeInMillis()){   
            cursor.add(Calendar.YEAR,1);   

            // next full unit
            nfu.add(Calendar.YEAR,1); 
            if(!nfu.after(endDate)) yearCount++;
            else                    break;
        }
         
        return yearCount;   
    }  
    
    //--- MONTHS BETWEEN --------------------------------------------------------------------------
    private long monthsBetween(final Calendar startDate, final Calendar endDate){
        int monthCount = 0;
        Calendar cursor = (Calendar)startDate.clone();
         
        // test
        Calendar test = (Calendar)startDate.clone();
        test.add(Calendar.MONTH,1); 
        if(test.after(endDate)) return monthCount;

        // next full unit
        Calendar nfu = (Calendar)startDate.clone();
        
        // count        
        while(cursor.getTimeInMillis() < endDate.getTimeInMillis()){   
            cursor.add(Calendar.MONTH,1);   

            // next full unit
            nfu.add(Calendar.MONTH,1); 
            if(!nfu.after(endDate)) monthCount++;
            else                    break;
        }
         
        return monthCount;   
    }  
    
    //--- DAYS BETWEEN ----------------------------------------------------------------------------
    private long daysBetween(final Calendar startDate, final Calendar endDate){
        int dayCount = 0;
        Calendar cursor = (Calendar)startDate.clone();   
         
        // test
        Calendar test = (Calendar)startDate.clone();
        test.add(Calendar.DATE,1); 
        if(test.after(endDate)) return dayCount;

        // next full unit
        Calendar nfu = (Calendar)startDate.clone();
        
        // count        
        while(cursor.getTimeInMillis() < endDate.getTimeInMillis()){   
            cursor.add(Calendar.DATE,1);   

            // next full unit
            nfu.add(Calendar.DATE,1); 
            if(!nfu.after(endDate)) dayCount++;
            else                    break;
        }
         
        return dayCount;   
    }  
    
    //--- CALCULATE PERIOD ------------------------------------------------------------------------
    private String calculatePeriod(java.util.Date startDate, java.util.Date endDate, String sWebLanguage){
        String sPeriod = "";
        
        // check
        if(startDate==null || endDate==null){
            return sPeriod;
        }

        // init
        Calendar startCal = Calendar.getInstance(),
                 endCal   = Calendar.getInstance();
        startCal.setTime(startDate);
        endCal.setTime(endDate);

        // calculate
        long totalYears = yearsBetween(startCal,endCal);
        
        startCal.add(Calendar.YEAR,(int)totalYears); // proceed
        long totalMonths = monthsBetween(startCal,endCal);

        startCal.add(Calendar.MONTH,(int)totalMonths); // proceed
        long totalDays = daysBetween(startCal,endCal);
                    
        // format
        if(totalYears > 0){
            if(totalYears==1){
                sPeriod+= totalYears+" "+getTran("web","year").toLowerCase();
            }
            else{
                sPeriod+= totalYears+" "+getTran("web","years").toLowerCase();
            }
        }
        
        if(totalMonths > 0){
            if(sPeriod.length() > 0) sPeriod+= ", "; // separator

            if(totalMonths==1){
                sPeriod+= totalMonths+" "+getTran("web","month").toLowerCase();
            }
            else{
                sPeriod+= totalMonths+" "+getTran("web","months").toLowerCase();
            }
        }       
        
        if(totalDays > 0){
            if(sPeriod.length() > 0) sPeriod+= ", "; // separator

            if(totalDays==1){
                sPeriod+= totalDays+" "+getTran("web","day").toLowerCase();
            }
            else{
                sPeriod+= totalDays+" "+getTran("web","days").toLowerCase();
            }
        }        

        return sPeriod;
    }
    
}