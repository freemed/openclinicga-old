package be.mxs.common.util.pdf.general.oc.examinations;

import java.text.DecimalFormat;
import java.util.Hashtable;
import java.util.Iterator;
import java.util.Vector;

import net.admin.AdminPerson;
import net.admin.User;

import com.itextpdf.text.BaseColor;
import com.itextpdf.text.Chunk;
import com.itextpdf.text.Font;
import com.itextpdf.text.FontFactory;
import com.itextpdf.text.Paragraph;
import com.itextpdf.text.pdf.PdfPCell;
import com.itextpdf.text.pdf.PdfPTable;

import be.mxs.common.model.vo.healthrecord.ItemVO;
import be.mxs.common.util.db.MedwanQuery;
import be.mxs.common.util.pdf.general.PDFGeneralBasic;
import be.mxs.common.util.system.ScreenHelper;
import be.openclinic.adt.Encounter;
import be.openclinic.medical.ChronicMedication;
import be.openclinic.medical.Diagnosis;
import be.openclinic.medical.PaperPrescription;
import be.openclinic.medical.Prescription;
import be.openclinic.medical.Problem;
import be.openclinic.medical.ReasonForEncounter;
import be.openclinic.pharmacy.Product;


public class PDFHealthcenterConsultation extends PDFGeneralBasic {

    //### INNER CLASS : TransactionID #############################################################
    private class TransactionID {
        public int transactionid = 0;
        public int serverid = 0; 
    }
    //#############################################################################################
    

    //--- ADD CONTENT -----------------------------------------------------------------------------
    protected void addContent(){
        try{
            if(transactionVO.getItems().size() >= minNumberOfItems){
                addSummary();
                addFamilial();
                addPersonal();                
                
                // add transaction to doc
                addTransactionToDoc();
            }
        }
        catch(Exception e){
            e.printStackTrace();
        }
    }


    //#############################################################################################
    //### PRIVATE METHODS #########################################################################
    //#############################################################################################
    
    //--- ADD SUMMARY -----------------------------------------------------------------------------
    private void addSummary() throws Exception {
        contentTable = new PdfPTable(1);
        table = new PdfPTable(5);
        table.setWidthPercentage(100);

        //*******************************************************************************
        //***** Summary 1 : GENERAL *****************************************************
        //*******************************************************************************
        // subtitle       
        table.addCell(createSubtitleCell(getTran("web.occup","medwan.healthrecord.general"),5));
        
        // subjective
        itemValue = getItemSeriesValue(IConstants_PREFIX+"[GENERAL.ANAMNESE]ITEM_TYPE_SUBJECTIVE");
        if(itemValue.length() > 0){
            addItemRow(table,getTran("web.occup","medwan.healthrecord.anamnese.general.subjective"),itemValue);
        }

        // objective
        itemValue = getItemSeriesValue(IConstants_PREFIX+"[GENERAL.ANAMNESE]ITEM_TYPE_OBJECTIVE");
        if(itemValue.length() > 0){
            addItemRow(table,getTran("web.occup","medwan.healthrecord.anamnese.general.objective"),itemValue);
        }

        // evaluation
        itemValue = getItemSeriesValue(IConstants_PREFIX+"[GENERAL.ANAMNESE]ITEM_TYPE_EVALUATION");
        if(itemValue.length() > 0){
            addItemRow(table,getTran("web.occup","medwan.healthrecord.anamnese.general.evaluation"),itemValue);
        }    

        // planning
        itemValue = getItemSeriesValue(IConstants_PREFIX+"[GENERAL.ANAMNESE]ITEM_TYPE_PLANNING");
        if(itemValue.length() > 0){
            addItemRow(table,getTran("web.occup","medwan.healthrecord.anamnese.general.planning"),itemValue);
        }
        
        // frequence cardiaque
        itemValue = getItemValue(ScreenHelper.ITEM_PREFIX+"ITEM_TYPE_CARDIAL_CLINICAL_EXAMINATION_HEARTH_FREQUENCY");
        if(itemValue.length() > 0){
            itemValue+= "("+getTran("web.occup",getItemValue(ScreenHelper.ITEM_PREFIX+"ITEM_TYPE_CARDIAL_CLINICAL_EXAMINATION_HEARTH_RYTMH"))+")";
            addItemRow(table,getTran("web.occup","medwan.healthrecord.cardial.frequence-cardiaque"),itemValue);
        }

        // pression-arterielle
        String sPressRightSys = getItemValue(ScreenHelper.ITEM_PREFIX+"ITEM_TYPE_CARDIAL_CLINICAL_EXAMINATION_SYSTOLIC_PRESSURE_RIGHT"),
               sPressRightDia = getItemValue(ScreenHelper.ITEM_PREFIX+"ITEM_TYPE_CARDIAL_CLINICAL_EXAMINATION_DIASTOLIC_PRESSURE_RIGHT"),
               sPressLeftSys = getItemValue(ScreenHelper.ITEM_PREFIX+"ITEM_TYPE_CARDIAL_CLINICAL_EXAMINATION_SYSTOLIC_PRESSURE_LEFT"),
               sPressLeftDia = getItemValue(ScreenHelper.ITEM_PREFIX+"ITEM_TYPE_CARDIAL_CLINICAL_EXAMINATION_DIASTOLIC_PRESSURE_LEFT");
        
        if(sPressRightSys.length() > 0 || sPressRightDia.length() > 0 || sPressLeftSys.length() > 0 || sPressLeftDia.length() > 0){
            String sValue = getTran("web.occup","medwan.healthrecord.cardial.bras-droit")+": "+sPressLeftSys+"/"+sPressLeftDia+"mmHg\n"+
                            getTran("web.occup","medwan.healthrecord.cardial.bras-gauche")+": "+sPressRightSys+"/"+sPressRightDia+"mmHg";
        
            addItemRow(table,getTran("web.occup","medwan.healthrecord.cardial.pression-arterielle"),sValue);
        }
            
        // temperature
        itemValue = getItemSeriesValue(IConstants_PREFIX+"[GENERAL.ANAMNESE]ITEM_TYPE_TEMPERATURE");
        if(itemValue.length() > 0){
            addItemRow(table,getTran("openclinic.chuk","temperature"),itemValue+"°C");
        }
        
        // respiratory frequency
        itemValue = getItemSeriesValue(IConstants_PREFIX+"[GENERAL.ANAMNESE]ITEM_TYPE_RESPIRATORY_FRENQUENCY");
        if(itemValue.length() > 0){
            addItemRow(table,getTran("openclinic.chuk","respiratory.frequency"),itemValue+"/min");
        }
        
        // add table
        if(table.size() > 1){
            if(contentTable.size() > 0) contentTable.addCell(emptyCell());
            contentTable.addCell(createCell(new PdfPCell(table),1,PdfPCell.ALIGN_CENTER,PdfPCell.BOX));
            tranTable.addCell(createContentCell(contentTable));
            addTransactionToDoc();
        }
        
        //*******************************************************************************
        //***** Summary 2 : CLINICAL EXAMINATION ****************************************
        //*******************************************************************************
        contentTable = new PdfPTable(1);        
        table = new PdfPTable(5);
        table.setWidthPercentage(100);
        
        // subtitle       
        table.addCell(createSubtitleCell(getTran("web.occup","medwan.healthrecord.clinical-examination"),5));
        
        addDiagnosisEncoding(table,true,true,true);
                     
        printProblemList(table,patient);
        printActiveDrugPrescriptions(table,patient);
        printPaperPrescriptions(table,patient);

        // add table
        if(table.size() > 1){
            if(contentTable.size() > 0) contentTable.addCell(emptyCell());
            contentTable.addCell(createCell(new PdfPCell(table),1,PdfPCell.ALIGN_CENTER,PdfPCell.BOX));
            tranTable.addCell(createContentCell(contentTable));
        }   
    }
    

    //#############################################################################################
    //### PRIVATE METHODS #########################################################################
    //#############################################################################################

    //--- ADD DIAGNOSIS ENCODING ------------------------------------------------------------------
    // Reasons for encounter 
    // Diagnoses of the actual document 
    // Contact diagnoses
    private PdfPTable addDiagnosisEncoding(PdfPTable table, boolean printPart1, boolean printPart2, boolean printPart3) throws Exception {
    	String sActiveEncounterUID = "";
        String sEncounterUID = transactionVO.getItemValue(ScreenHelper.ITEM_PREFIX+"ITEM_TYPE_CONTEXT_ENCOUNTERUID");
        if(sEncounterUID.length() > 0){
        	sActiveEncounterUID = sEncounterUID;
        }
        else{
            Encounter activeEnc = Encounter.getActiveEncounterOnDate(new java.sql.Timestamp(transactionVO.getUpdateTime().getTime()),this.patient.personid);
            if(activeEnc!=null){
            	sActiveEncounterUID = activeEnc.getUid();
            }
        }
        
        //***** PART 1 - reasons for encounter ********************************
        if(printPart1==true){        
	        if(sActiveEncounterUID.length() > 0){
	            Vector rfeVector = ReasonForEncounter.getReasonsForEncounterByEncounterUid(sActiveEncounterUID);
	            
	            if(rfeVector.size() > 0){	                    
	                PdfPTable rfeTable = new PdfPTable(20);
	                rfeTable.setWidthPercentage(100);
	
	                // title
	                String sTitle = getTran("openclinic.chuk","rfe")+" "+getTran("web.occup","ICPC-2")+" / "+getTran("web.occup","ICD-10");
	                cell = createTitleCell(sTitle,20);
	                cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
	                rfeTable.addCell(cell);
	                
	                ReasonForEncounter rfe;
	                for(int i=0; i<rfeVector.size(); i++){
	                	rfe = (ReasonForEncounter)rfeVector.get(i);
	                	
	                    // one encounter
	                    rfeTable.addCell(createValueCell(rfe.getCodeType().toUpperCase(),2));
	                    rfeTable.addCell(createValueCell(rfe.getCode(),2));
	                    rfeTable.addCell(createValueCell(MedwanQuery.getInstance().getCodeTran(rfe.getCodeType()+"code"+rfe.getCode(),sPrintLanguage),16));
	                }
	                
	                // add to main table
	    	        if(rfeTable.size() > 1){
		                cell = createBorderlessCell(5);
		                cell.addElement(rfeTable);
		                table.addCell(cell);
	    	        }
	            }
	        }
        }
        
        //***** PART 2 - ICPC / ICD10 *****************************************
        if(printPart2==true){
	        PdfPTable icpcTable = new PdfPTable(20);
	        icpcTable.setWidthPercentage(100);
	        
	        String sTitle = getTran("openclinic.chuk","diagnostic.document")+" "+getTran("web.occup","ICPC-2")+" / "+getTran("web.occup","ICD-10");
	        cell = createTitleCell(sTitle,20);
	        cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
	        icpcTable.addCell(cell);
	                        		
	        String sReferenceUID = transactionVO.getServerId()+"."+transactionVO.getTransactionId();
	        Hashtable hDiagnoses = Diagnosis.getDiagnosesByReferenceUID(sReferenceUID,"Transaction");
	        String sCode, sGravity, sCertainty, sPOA, sNC, sServiceUid, sFlags;
	
	        Iterator items = transactionVO.getItems().iterator();
	        Hashtable hDiagnosisInfo;
	        ItemVO item;
	        
	        while(items.hasNext()){
	            item = (ItemVO)items.next();
	             
	            //***** a : ICPC *****	             
	            if(item.getType().indexOf("ICPCCode")==0){
	                sCode = item.getType().substring("ICPCCode".length(),item.getType().length());
	
	                hDiagnosisInfo = (Hashtable)hDiagnoses.get(sCode);
	                if(hDiagnosisInfo!=null){
	                    sGravity    = (String)hDiagnosisInfo.get("Gravity");
	                    sCertainty  = (String)hDiagnosisInfo.get("Certainty");
	                    sPOA        = (String)hDiagnosisInfo.get("POA");
	                    sNC         = (String)hDiagnosisInfo.get("NC");
	                    sServiceUid = (String)hDiagnosisInfo.get("ServiceUid");
	                    sFlags      = (String)hDiagnosisInfo.get("Flags");
	                }
	                else{
	                    sGravity = "";
	                    sCertainty = "";
	                    sPOA = "";
	                    sNC = "";
	                    sServiceUid = "";
	                    sFlags = "";
	                }
	
	                // one ICPC
	                icpcTable.addCell(createValueCell("ICPC",2));
	                icpcTable.addCell(createValueCell(item.getType().replaceAll("ICPCCode",""),2));
	                icpcTable.addCell(createValueCell(MedwanQuery.getInstance().getCodeTran(item.getType().trim(),sPrintLanguage)+" "+item.getValue().trim(),11));
	                icpcTable.addCell(createValueCell("G:"+sGravity+"/C:"+sCertainty+(sPOA.length()>0?" POA":"")+(sNC.length()>0?" N":"")+(sFlags.length()==0?"":" ("+sFlags+")"),5));
	     	    }		      
	            //***** b : icd10 *****
	            else if(item.getType().indexOf("ICD10Code")==0){
	                sCode = item.getType().substring("ICD10Code".length(),item.getType().length());
	
	                hDiagnosisInfo = (Hashtable)hDiagnoses.get(sCode);
	                if(hDiagnosisInfo!=null){
	                    sGravity    = (String)hDiagnosisInfo.get("Gravity");
	                    sCertainty  = (String)hDiagnosisInfo.get("Certainty");
	                    sPOA        = (String)hDiagnosisInfo.get("POA");
	                    sNC         = (String)hDiagnosisInfo.get("NC");
	                    sServiceUid = (String)hDiagnosisInfo.get("ServiceUid");
	                    sFlags      = (String)hDiagnosisInfo.get("Flags");
	                } 
	                else{
	                    sGravity = "";
	                    sCertainty = "";
	                    sPOA = "";
	                    sNC = "";
	                    sServiceUid = "";
	                    sFlags = "";
	                }
	
	                // one ICD10
	                icpcTable.addCell(createValueCell("ICD10",2));
	                icpcTable.addCell(createValueCell(item.getType().replaceAll("ICD10Code",""),2));
	                icpcTable.addCell(createValueCell(MedwanQuery.getInstance().getCodeTran(item.getType().trim(),sPrintLanguage)+" "+item.getValue().trim(),11));
	                icpcTable.addCell(createValueCell("G:"+sGravity+"/C:"+sCertainty+(sPOA.length()>0?" POA":"")+(sNC.length()>0?" N":"")+(sFlags.length()==0?"":" ("+sFlags+")"),5));		               
	            }
	        }
	        
	        // add to main table
	        if(icpcTable.size() > 1){
		        cell = createBorderlessCell(5);
		        cell.addElement(icpcTable);
		        table.addCell(cell);
	        }
        }
        
        //***** PART 3 - diagnoses ********************************************
        if(printPart3==true){
	        PdfPTable diagTable = new PdfPTable(20);
	        diagTable.setWidthPercentage(100);
	        
	        String sTitle = getTran("openclinic.chuk","contact.diagnoses")+" "+getTran("web.occup","ICPC-2")+" / "+getTran("web.occup","ICD-10");
	        cell = createTitleCell(sTitle,20);
	        cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
	        diagTable.addCell(cell);
	  
	        if(sActiveEncounterUID.length() > 0){
		        String sCode, sGravity, sCertainty, sPOA, sNC, sServiceUid, sFlags;
		        
		        String sReferenceUID = transactionVO.getServerId()+"."+transactionVO.getTransactionId();
		        Vector diagnoses = Diagnosis.selectDiagnoses("","",sActiveEncounterUID,"","","","","","","","","","");
	
		        Diagnosis diag;
		        for(int n=0; n<diagnoses.size(); n++){
		       	 diag = (Diagnosis)diagnoses.get(n);
		        	 
	                sGravity   = diag.getGravity()+"";
	                sCertainty = diag.getCertainty()+"";
	                sPOA       = diag.getPOA();
	                sNC        = diag.getNC();
	                sFlags     = diag.getFlags();
	                 
	     	        if(diag.getCodeType().equalsIgnoreCase("icpc")){
		    		    // one ICPC
	                    diagTable.addCell(createValueCell("ICPC",2));
			            diagTable.addCell(createValueCell(diag.getCode(),2));
			            diagTable.addCell(createValueCell(MedwanQuery.getInstance().getCodeTran("icpccode"+diag.getCode(),sPrintLanguage)+" "+diag.getLateralisation(),11));
			            diagTable.addCell(createValueCell("G:"+sGravity+"/C:"+sCertainty+(sPOA.length()>0?" POA":"")+(sNC.length()>0?" N":"")+(sFlags.length()==0?"":" ("+sFlags+")"),5));
		            }
		            else if(diag.getCodeType().equalsIgnoreCase("icd10")){
		                // one ICD10
		            	diagTable.addCell(createValueCell("ICD10",2));
			            diagTable.addCell(createValueCell(diag.getCode(),2));
			            diagTable.addCell(createValueCell(MedwanQuery.getInstance().getCodeTran("icd10code"+diag.getCode(),sPrintLanguage)+" "+diag.getLateralisation(),11));
			            diagTable.addCell(createValueCell("G:"+sGravity+"/C:"+sCertainty+(sPOA.length()>0?" POA":"")+(sNC.length()>0?" N":"")+(sFlags.length()==0?"":" ("+sFlags+")"),5));			             	 				     		 
		            }
		        }
	            
	            // add to main table
    	        if(diagTable.size() > 1){
		            cell = createBorderlessCell(5);
		            cell.addElement(diagTable);
		            table.addCell(cell);
    	        }
	        }
        } 
        
        return table;
    }
    
    //--- PRINT PROBLEM LIST (active problems) ----------------------------------------------------
    private void printProblemList(PdfPTable table, AdminPerson activePatient) throws Exception {    
        Vector activeProblems = Problem.getActiveProblems(patient.personid);
        if(activeProblems.size() > 0){
            PdfPTable problemsTable = new PdfPTable(10);
            problemsTable.setWidthPercentage(100);
            
            // title
            problemsTable.addCell(createTitleCell(getTran("web","problemlist"),10));
    
            // header
            problemsTable.addCell(createHeaderCell(getTran("web.occup","medwan.common.description"),9));
            problemsTable.addCell(createHeaderCell(getTran("web.occup","medwan.common.datebegin"),1));
    
            Problem problem;
            String comment, value;
            for(int n=0; n<activeProblems.size(); n++){
                problem = (Problem)activeProblems.elementAt(n);
    
                value = problem.getCode()+" "+MedwanQuery.getInstance().getCodeTran(problem.getCodeType()+"code"+problem.getCode(),sPrintLanguage);
                Paragraph par = new Paragraph(value,FontFactory.getFont(FontFactory.HELVETICA,Math.round((double)7*fontSizePercentage/100.0),Font.NORMAL));
    
                // add comment if any
                if(problem.getComment().trim().length() > 0){
                    comment = " : "+problem.getComment().trim();
                    par.add(new Chunk(comment,FontFactory.getFont(FontFactory.HELVETICA,Math.round((double)7*fontSizePercentage/100.0),Font.ITALIC)));
                }
    
                cell = new PdfPCell(par);
                cell.setColspan(9);
                cell.setBorder(PdfPCell.BOX);
                cell.setBorderColor(innerBorderColor);
                cell.setVerticalAlignment(PdfPCell.ALIGN_TOP);
                cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
                problemsTable.addCell(cell);
    
                // date
                problemsTable.addCell(createValueCell(ScreenHelper.stdDateFormat.format(problem.getBegin()),1));
            }

            // add to main table
            if(table.size() > 1){
	            cell = createBorderlessCell(5);
	            cell.addElement(problemsTable);
	            table.addCell(cell);
            }
        }
        else{
            // no records found
            //table.addCell(createValueCell(getTran("web","noRecordsFound"),5));
        }
    }

    //--- PRINT ACTIVE DRUG PRESCRIPTIONS (medication) --------------------------------------------
    protected void printActiveDrugPrescriptions(PdfPTable table, AdminPerson activePatient) throws Exception {
    	PdfPTable medicationsTable = new PdfPTable(1);
    	medicationsTable.setWidthPercentage(100);
    	
        // title
    	medicationsTable.addCell(createTitleCell(getTran("web","drugPrescriptions"),1));

        String sTimeUnit, sTimeUnitCount, sUnitsPerTimeUnit, sPrescrRule = "", sProductUnit, timeUnitTran,
               sProductUid, sPrevProductUid = "", sProductName = "", sBeginDate = "", sEndDate = "";
        DecimalFormat unitCountDeci = new DecimalFormat("#.#");
        PdfPTable prescrTable;
        Product product = null;
        
        //***************************************************************************
        //*** 1 - ACTIVE PRESCRIPTIONS **********************************************
        //***************************************************************************        
        Vector activePrescriptions = Prescription.findActive(activePatient.personid,"","","","","","","");
    	prescrTable = new PdfPTable(12);
    	prescrTable.setWidthPercentage(100);
     	
        // sub title
    	prescrTable.addCell(createSubtitleCell(getTran("web","medication.active"),12));
        
        if(activePrescriptions.size() > 0){                   
            // header
        	prescrTable.addCell(createHeaderCell(getTran("web","product"),6));
        	prescrTable.addCell(createHeaderCell(getTran("web","beginDate"),1));
        	prescrTable.addCell(createHeaderCell(getTran("web","endDate"),1));
        	prescrTable.addCell(createHeaderCell(getTran("web","prescriptionRule"),4));

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
                prescrTable.addCell(createValueCell(sProductName,6));
                prescrTable.addCell(createValueCell(sBeginDate,1));
                prescrTable.addCell(createValueCell(sEndDate,1));
                prescrTable.addCell(createValueCell(sPrescrRule.toLowerCase(),4));
            }
        }
        else{
        	// no records found
        	//prescrTable.addCell(createValueCell(getTran("web","noRecordsFound"),12)); 
        }

        if(prescrTable.size() > 1){
            cell = new PdfPCell();
            cell.addElement(prescrTable);
            cell.setBorder(PdfPCell.BOX);
            cell.setBorderColor(BaseColor.LIGHT_GRAY);
            cell.setVerticalAlignment(PdfPCell.ALIGN_TOP);
            cell.setPadding(3);
            cell.setColspan(1);
            
            medicationsTable.addCell(cell);
        }

        //***************************************************************************
        //*** 2 - CHRONIC MEDICATION ************************************************
        //***************************************************************************
        Vector chronicMedications  = ChronicMedication.find(patient.personid,"","","","OC_CHRONICMED_BEGIN","ASC");
        prescrTable = new PdfPTable(12);
        prescrTable.setWidthPercentage(100);

        // sub title
        prescrTable.addCell(createSubtitleCell(getTran("web","medication.chronic"),12));
        
        if(chronicMedications.size() > 0){
            // header
        	prescrTable.addCell(createHeaderCell(getTran("web","product"),6));
        	prescrTable.addCell(createHeaderCell(getTran("web","beginDate"),1));
        	prescrTable.addCell(createHeaderCell(getTran("web","endDate"),1));
        	prescrTable.addCell(createHeaderCell(getTran("web","prescriptionRule"),4));
            
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
                prescrTable.addCell(createValueCell(sProductName,6));
                prescrTable.addCell(createValueCell(sBeginDate,1));
                prescrTable.addCell(createValueCell(sPrescrRule.toLowerCase(),5));
            }
        }
        else{
        	// no records found
        	//prescrTable.addCell(createValueCell(getTran("web","noRecordsFound"),12)); 
        }

        if(prescrTable.size() > 1){
            cell = new PdfPCell();
            cell.addElement(prescrTable);
            cell.setBorder(PdfPCell.BOX);
            cell.setBorderColor(BaseColor.LIGHT_GRAY);
            cell.setVerticalAlignment(PdfPCell.ALIGN_TOP);
            cell.setPadding(3);
            cell.setColspan(1);
            
            medicationsTable.addCell(cell);
        } 
        
        // add to main table
        if(prescrTable.size() > 1){
	        cell = createBorderlessCell(5);
	        cell.addElement(medicationsTable);
	        table.addCell(cell);
        }
    }
    
    //--- PRINT PAPER PRESCRIPTIONS ---------------------------------------------------------------
    private void printPaperPrescriptions(PdfPTable table, AdminPerson patient) throws Exception {
    	PdfPTable prescrTable = new PdfPTable(5);
    	prescrTable.setWidthPercentage(100);
    	
        // title
    	prescrTable.addCell(createTitleCell(getTran("curative","medication.paperPrescriptions")+" ("+ScreenHelper.stdDateFormat.format(transactionVO.getUpdateTime())+")",5));
        
        Vector paperPrescriptions = PaperPrescription.find(patient.personid,"",ScreenHelper.stdDateFormat.format(transactionVO.getUpdateTime()),ScreenHelper.stdDateFormat.format(transactionVO.getUpdateTime()),"","DESC");
        if(paperPrescriptions.size() > 0){                   
            // header
        	table.addCell(createHeaderCell(getTran("web","date"),1));
        	table.addCell(createHeaderCell(getTran("web","products"),4));

            PaperPrescription paperPrescription;            
            for(int n=0; n<paperPrescriptions.size(); n++){
                paperPrescription = (PaperPrescription)paperPrescriptions.elementAt(n);
                
                // list products
                Vector products = paperPrescription.getProducts();
                String sProducts = "";               
                for(int i=0; i<products.size(); i++){
                    sProducts+= products.elementAt(i)+", ";
                }
                
                if(sProducts.endsWith(", ")){
                	sProducts = sProducts.substring(0,sProducts.lastIndexOf(", "));
                }
            	
                // one paper prescription
                prescrTable.addCell(createValueCell(ScreenHelper.stdDateFormat.format(paperPrescription.getBegin()),1));
                prescrTable.addCell(createValueCell(sProducts,4));
            }
        }
        else{
        	// no records found
        	//prescrTable.addCell(createValueCell(getTran("web","noRecordsFound"),5)); 
        }
        
        // add to main table
        if(prescrTable.size() > 1){
	        cell = createBorderlessCell(5);
	        cell.addElement(prescrTable);
	        table.addCell(cell);
        }
    }
        
    //--- ADD FAMILIAL ----------------------------------------------------------------------------
    private void addFamilial() throws Exception {
        contentTable = new PdfPTable(1);
        table = new PdfPTable(5);
        table.setWidthPercentage(100);

        table.addCell(createTitleCell(getTran("web.occup","familial").toUpperCase(),5));

        //*** STATUS ***
        itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_CE_STATUS");
        if(itemValue.length() > 0){
            addItemRow(table,getTran("web.occup","medwan.occupational-medicine.risk-profile.status"),getTran("clinicalexamination.familialstatus",itemValue));
        }    
        
        //*** STATUS COMMENT ***
        itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_CE_STATUS_COMMENT");
        if(itemValue.length() > 0){
            addItemRow(table,getTran("web","comment"),itemValue);
        } 
        
        //*******************************************************************************
        //*** 1 - KINDEREN **************************************************************
        //*******************************************************************************
        PdfPTable detailsTable = new PdfPTable(10);
        detailsTable.setWidthPercentage(100);

        // subtitle
        detailsTable.addCell(createTitleCell(getTran("web.occup","children"),PdfPCell.ALIGN_LEFT,10));
        
        String sKinderen = getItemSeriesValue(ScreenHelper.ITEM_PREFIX+"ITEM_TYPE_CE_KINDEREN");
        if(sKinderen.indexOf("£") > -1){
            // header
        	detailsTable.addCell(createHeaderCell(getTran("web.occup","Birth_Year"),1));
        	detailsTable.addCell(createHeaderCell(getTran("web.occup","cbmt.occup.individual.gender"),1));
            detailsTable.addCell(createHeaderCell(getTran("Web","firstname"),8));

            String sTmpKinderen = sKinderen;
            String sTmpKinderenGeboortejaar, sTmpKinderenGeslacht, sTmpKinderenFirstname;
            sKinderen = "";
            
            while(sTmpKinderen.toLowerCase().indexOf("$")>-1){
                sTmpKinderenGeboortejaar = "";
                sTmpKinderenGeslacht = "";
                sTmpKinderenFirstname = "";

                if(sTmpKinderen.toLowerCase().indexOf("£")>-1){
                    sTmpKinderenGeboortejaar = sTmpKinderen.substring(0,sTmpKinderen.toLowerCase().indexOf("£"));
                    sTmpKinderen = sTmpKinderen.substring(sTmpKinderen.toLowerCase().indexOf("£")+1);
                }

                if(sTmpKinderen.toLowerCase().indexOf("£")>-1){
                    sTmpKinderenGeslacht = sTmpKinderen.substring(0,sTmpKinderen.toLowerCase().indexOf("£"));
                    sTmpKinderen = sTmpKinderen.substring(sTmpKinderen.toLowerCase().indexOf("£")+1);
                }

                if(sTmpKinderen.toLowerCase().indexOf("$")>-1){
                    sTmpKinderenFirstname = sTmpKinderen.substring(0,sTmpKinderen.toLowerCase().indexOf("$"));
                    sTmpKinderen = sTmpKinderen.substring(sTmpKinderen.toLowerCase().indexOf("$")+1);
                }
                
                // translate gender
                if(sTmpKinderenGeslacht.equalsIgnoreCase("M")){
                	sTmpKinderenGeslacht = getTran("web.occup","male");
                }
                else if(sTmpKinderenGeslacht.equalsIgnoreCase("F")){
                	sTmpKinderenGeslacht = getTran("web.occup","female");
                }
                
                // add one record
            	detailsTable.addCell(createValueCell(sTmpKinderenGeboortejaar,1));
            	detailsTable.addCell(createValueCell(sTmpKinderenGeslacht,1));
            	detailsTable.addCell(createValueCell(sTmpKinderenFirstname,8));
            } 
            
            // add details table
            if(detailsTable.size() > 1){
            	cell = new PdfPCell(detailsTable);
                cell.setBorder(PdfPCell.NO_BORDER);
                cell.setVerticalAlignment(PdfPCell.ALIGN_TOP);
                cell.setPadding(3);
            	cell.setColspan(5);
                table.addCell(cell);
            }  
        }

        //*******************************************************************************
        //*** 2 - FAMILIAL ANTECEDENTS **************************************************
        //*******************************************************************************       
        detailsTable = new PdfPTable(10);
        detailsTable.setWidthPercentage(100);

        // subtitle
        detailsTable.addCell(createTitleCell(getTran("web.occup","Familial_Antecedents"),PdfPCell.ALIGN_LEFT,10));
        
        String sFami = getItemSeriesValue(ScreenHelper.ITEM_PREFIX+"ITEM_TYPE_CE_FAMILIALE_ANTECEDENTEN");
        if(sFami.indexOf("$") > 0){            
		    // header
        	detailsTable.addCell(createHeaderCell(getTran("web.occup","medwan.common.date"),1));
        	detailsTable.addCell(createHeaderCell(getTran("web.occup","medwan.common.description"),5));
        	detailsTable.addCell(createHeaderCell(getTran("web.occup","verwantschap"),4));
        
            String sTmpFami = sFami;
            String sTmpFamiDate, sTmpFamiDescr, sTmpFamiVerwantschap;
            sFami = "";

            while(sTmpFami.toLowerCase().indexOf("$")>-1){
                sTmpFamiDate = "";
                sTmpFamiDescr = "";
                sTmpFamiVerwantschap = "";

                if(sTmpFami.toLowerCase().indexOf("£")>-1){
                    sTmpFamiDate = sTmpFami.substring(0,sTmpFami.toLowerCase().indexOf("£"));
                    sTmpFami = sTmpFami.substring(sTmpFami.toLowerCase().indexOf("£")+1);
                }

                if(sTmpFami.toLowerCase().indexOf("£")>-1){
                    sTmpFamiDescr = sTmpFami.substring(0,sTmpFami.toLowerCase().indexOf("£"));
                    sTmpFami = sTmpFami.substring(sTmpFami.toLowerCase().indexOf("£")+1);
                }

                if(sTmpFami.toLowerCase().indexOf("$")>-1){
                    sTmpFamiVerwantschap = sTmpFami.substring(0,sTmpFami.toLowerCase().indexOf("$"));
                    sTmpFami = sTmpFami.substring(sTmpFami.toLowerCase().indexOf("$")+1);
                }
                
                // add one record
            	detailsTable.addCell(createValueCell(sTmpFamiDate,1));
            	detailsTable.addCell(createValueCell(sTmpFamiDescr,5));
            	detailsTable.addCell(createValueCell(sTmpFamiVerwantschap,4));                
            }  

            // FAMILIAAL COMMENT
            itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_CE_FAMILIAAL_COMMENT");
            if(itemValue.length() > 0){
                cell = createItemNameCell(getTran("web","comment"));
            	cell.setColspan(4);
            	detailsTable.addCell(cell);
            	
            	cell = createValueCell(itemValue);
            	cell.setColspan(6);
                detailsTable.addCell(cell);
            }    
            
            // add details table
            if(detailsTable.size() > 1){
            	cell = new PdfPCell(detailsTable);
                cell.setBorder(PdfPCell.NO_BORDER);
                cell.setVerticalAlignment(PdfPCell.ALIGN_TOP);
                cell.setPadding(3);
            	cell.setColspan(5);
                table.addCell(cell);
            }  
        }     
        
        // add table
        if(table.size() > 1){
            if(contentTable.size() > 0) contentTable.addCell(emptyCell());
            contentTable.addCell(createCell(new PdfPCell(table),1,PdfPCell.ALIGN_CENTER,PdfPCell.BOX));
            tranTable.addCell(createContentCell(contentTable));
        }   
    }
    
    //--- ADD PERSONAL ----------------------------------------------------------------------------
    private void addPersonal() throws Exception {
        contentTable = new PdfPTable(1);
        table = new PdfPTable(5);
        table.setWidthPercentage(100);

        table.addCell(createTitleCell(getTran("web.occup","personal").toUpperCase(),5));
        
        // COMMENT/REMARKS
        itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_CE_PERSONAL_COMMENT");
        if(itemValue.length() > 0){
            addItemRow(table,getTran("web.occup","medwan.common.remark"),itemValue);
        }    

        //*******************************************************************************
        //*** Personal 1 - CHIRURGIE ****************************************************
        //*******************************************************************************
        PdfPTable detailsTable = new PdfPTable(10);
        detailsTable.setWidthPercentage(100);

        // subtitle
        detailsTable.addCell(createTitleCell(getTran("web.occup","Medical_Antecedents"),PdfPCell.ALIGN_LEFT,10));
        
        String sChirurgie = getItemSeriesValue(ScreenHelper.ITEM_PREFIX+"ITEM_TYPE_CE_MEDISCHE_ANTECEDENTEN");
        if(sChirurgie.indexOf("£") > -1){
            // header
        	detailsTable.addCell(createHeaderCell(getTran("web.occup","medwan.common.date-begin"),1));
        	detailsTable.addCell(createHeaderCell(getTran("web.occup","medwan.common.date-end"),1));
        	detailsTable.addCell(createHeaderCell(getTran("web.occup","medwan.common.description"),8));
        	
            String sTmpChirurgie = sChirurgie;
            String sTmpChirurgieDateBegin, sTmpChirurgieDateEnd, sTmpChirurgieDescr;
            sChirurgie = "";
            
            while(sTmpChirurgie.toLowerCase().indexOf("$") > -1){
                sTmpChirurgieDateBegin = "";
                sTmpChirurgieDateEnd = "";
                sTmpChirurgieDescr = "";

                if(sTmpChirurgie.toLowerCase().indexOf("£") > -1){
                    sTmpChirurgieDateBegin = sTmpChirurgie.substring(0,sTmpChirurgie.toLowerCase().indexOf("£"));
                    sTmpChirurgie = sTmpChirurgie.substring(sTmpChirurgie.toLowerCase().indexOf("£")+1);
                }
                if(sTmpChirurgie.toLowerCase().indexOf("£") > -1){
                    sTmpChirurgieDateEnd = sTmpChirurgie.substring(0, sTmpChirurgie.toLowerCase().indexOf("£"));
                    sTmpChirurgie = sTmpChirurgie.substring(sTmpChirurgie.toLowerCase().indexOf("£")+1);
                }
                if(sTmpChirurgie.toLowerCase().indexOf("$") > -1){
                    sTmpChirurgieDescr = sTmpChirurgie.substring(0, sTmpChirurgie.toLowerCase().indexOf("$"));
                    sTmpChirurgie = sTmpChirurgie.substring(sTmpChirurgie.toLowerCase().indexOf("$")+1);
                }
                
                // add one record
            	detailsTable.addCell(createValueCell(sTmpChirurgieDateBegin,1));
            	detailsTable.addCell(createValueCell(sTmpChirurgieDateEnd,1));
            	detailsTable.addCell(createValueCell(sTmpChirurgieDescr,8));
            } 
            
            // add details table
            if(detailsTable.size() > 1){
            	cell = new PdfPCell(detailsTable);
                cell.setBorder(PdfPCell.NO_BORDER);
                cell.setVerticalAlignment(PdfPCell.ALIGN_TOP);
                cell.setPadding(3);
            	cell.setColspan(5);
                table.addCell(cell);
            }   
        }

        //*******************************************************************************
        //*** Personal 2 - HEELKUNDE ****************************************************
        //*******************************************************************************
        detailsTable = new PdfPTable(10);
        detailsTable.setWidthPercentage(100);
        
        // subtitle
        detailsTable.addCell(createTitleCell(getTran("web.occup","Heelkundige_antecedenten"),PdfPCell.ALIGN_LEFT,10));
       
        String sHeelkunde = getItemSeriesValue(ScreenHelper.ITEM_PREFIX+"ITEM_TYPE_CE_HEELKUNDE");
        if(sHeelkunde.indexOf("£") > -1){
            // header
        	detailsTable.addCell(createHeaderCell(getTran("web.occup","medwan.common.date-begin"),1));
        	detailsTable.addCell(createHeaderCell(getTran("web.occup","medwan.common.date-end"),1));
        	detailsTable.addCell(createHeaderCell(getTran("web.occup","medwan.common.description"),8));

            String sTmpHeelkunde = sHeelkunde;
            String sTmpHeelkundeDateBegin, sTmpHeelkundeDateEnd, sTmpHeelkundeDescr;
            sHeelkunde = "";

            while(sTmpHeelkunde.toLowerCase().indexOf("$") > -1){
            	sTmpHeelkundeDateBegin = "";
            	sTmpHeelkundeDateEnd = "";
            	sTmpHeelkundeDescr = "";
            	
                if(sTmpHeelkunde.toLowerCase().indexOf("£") > -1){
	                sTmpHeelkundeDateBegin = sTmpHeelkunde.substring(0,sTmpHeelkunde.toLowerCase().indexOf("£"));
	                sTmpHeelkunde = sTmpHeelkunde.substring(sTmpHeelkunde.toLowerCase().indexOf("£")+1);
                }
                
                if(sTmpHeelkunde.toLowerCase().indexOf("£") > -1){
	                sTmpHeelkundeDateEnd = sTmpHeelkunde.substring(0,sTmpHeelkunde.toLowerCase().indexOf("£"));
	                sTmpHeelkunde = sTmpHeelkunde.substring(sTmpHeelkunde.toLowerCase().indexOf("£")+1);
                }
                
                if(sTmpHeelkunde.toLowerCase().indexOf("$") > -1){
	                sTmpHeelkundeDescr = sTmpHeelkunde.substring(0,sTmpHeelkunde.toLowerCase().indexOf("$"));
	                sTmpHeelkunde = sTmpHeelkunde.substring(sTmpHeelkunde.toLowerCase().indexOf("$")+1);
                }
                
                // add one record
            	detailsTable.addCell(createValueCell(sTmpHeelkundeDateBegin,1));
            	detailsTable.addCell(createValueCell(sTmpHeelkundeDateEnd,1));
            	detailsTable.addCell(createValueCell(sTmpHeelkundeDescr,8));
            } 
            
            // add details table
            if(detailsTable.size() > 1){
            	cell = new PdfPCell(detailsTable);
                cell.setBorder(PdfPCell.NO_BORDER);
                cell.setVerticalAlignment(PdfPCell.ALIGN_TOP);
                cell.setPadding(3);
            	cell.setColspan(5);
                table.addCell(cell);
            }  
        }

        //*******************************************************************************
        //*** Personal 3 - LETSELS ******************************************************
        //*******************************************************************************
        detailsTable = new PdfPTable(10);
        detailsTable.setWidthPercentage(100);
        
        // subtitle
        detailsTable.addCell(createTitleCell(getTran("web.occup","Lesions_with_%_PI"),PdfPCell.ALIGN_LEFT,10));
        
        String sLetsels = getItemSeriesValue(ScreenHelper.ITEM_PREFIX+"ITEM_TYPE_CE_LETSELS");
        if(sLetsels.indexOf("£") > -1){                            
            // header
            detailsTable.addCell(createHeaderCell(getTran("web.occup","medwan.common.date"),1));
            detailsTable.addCell(createHeaderCell(getTran("web.occup","medwan.common.description"),8));
            detailsTable.addCell(createHeaderCell(getTran("web.occup","PI"),1));
            
            String sTmpLetsels = sLetsels;
            String sTmpLetselsDate, sTmpLetselsDescr, sTmpLetselsBI;
            sLetsels = "";

            while(sTmpLetsels.toLowerCase().indexOf("$") > -1){ 
                sTmpLetselsDate = "";
                sTmpLetselsBI = "";
                sTmpLetselsDescr = "";

                if(sTmpLetsels.toLowerCase().indexOf("£") > -1){
                    sTmpLetselsDate = sTmpLetsels.substring(0,sTmpLetsels.toLowerCase().indexOf("£"));
                    sTmpLetsels = sTmpLetsels.substring(sTmpLetsels.toLowerCase().indexOf("£")+1);
                }
                if(sTmpLetsels.toLowerCase().indexOf("£") > -1){
                    sTmpLetselsDescr = sTmpLetsels.substring(0,sTmpLetsels.toLowerCase().indexOf("£"));
                    sTmpLetsels = sTmpLetsels.substring(sTmpLetsels.toLowerCase().indexOf("£")+1);
                }
                if(sTmpLetsels.toLowerCase().indexOf("$") > -1){
                    sTmpLetselsBI = sTmpLetsels.substring(0,sTmpLetsels.toLowerCase().indexOf("$"));
                    sTmpLetsels = sTmpLetsels.substring(sTmpLetsels.toLowerCase().indexOf("$")+1);
                }
                
                // add unit to PI
            	if(sTmpLetselsBI.length() > 0) sTmpLetselsBI+= "%";
            	
                // add one record
            	detailsTable.addCell(createValueCell(sTmpLetselsDate,1));
            	detailsTable.addCell(createValueCell(sTmpLetselsDescr,8));
            	detailsTable.addCell(createValueCell(sTmpLetselsBI,1));
            } 
            
            // add details table
            if(detailsTable.size() > 1){
            	cell = new PdfPCell(detailsTable);
                cell.setBorder(PdfPCell.NO_BORDER);
                cell.setVerticalAlignment(PdfPCell.ALIGN_TOP);
                cell.setPadding(3);
            	cell.setColspan(5);
                table.addCell(cell);
            }  
        }   
        
        // add table
        if(table.size() > 1){
            if(contentTable.size() > 0) contentTable.addCell(emptyCell());
            contentTable.addCell(createCell(new PdfPCell(table),1,PdfPCell.ALIGN_CENTER,PdfPCell.BOX));
            tranTable.addCell(createContentCell(contentTable));
        }   
    }


    //#############################################################################################
    //### UTILITY METHODS #########################################################################
    //#############################################################################################

    //--- GET PRODUCT -----------------------------------------------------------------------------
    private Product getProduct(String sProductUid){
        // search for product in products-table
        Product product = new Product();
        product = product.get(sProductUid);

        if(product!=null && product.getName()==null){
            // search for product in product-history-table
            product = product.getProductFromHistory(sProductUid);
        }

        return product;
    }
    
}
