package be.mxs.common.util.pdf.general.oc.examinations;

import be.mxs.common.util.db.MedwanQuery;
import be.mxs.common.util.pdf.general.PDFGeneralBasic;
import be.mxs.common.util.system.ScreenHelper;
import be.mxs.common.model.vo.healthrecord.ItemVO;
import be.openclinic.medical.Problem;
import be.openclinic.medical.Prescription;
import be.openclinic.pharmacy.Product;
import be.openclinic.system.Transaction;
import be.openclinic.system.Item;

import java.util.Vector;
import java.util.Iterator;
import java.util.Collection;
import java.text.SimpleDateFormat;
import java.text.DecimalFormat;
import java.sql.SQLException;

import com.itextpdf.text.pdf.PdfPTable;
import com.itextpdf.text.pdf.PdfPCell;
import com.itextpdf.text.*;


public class PDFClinicalExamination extends PDFGeneralBasic {

    // PRIVATE CLASS TransactionID
    private class TransactionID {
        public int transactionid = 0;
        public int serverid = 0;
    }
    

    //--- ADD CONTENT ------------------------------------------------------------------------------
    protected void addContent(){
        try {
            //*** SUMMARY ***
            addLastBiometricExaminationInfo();
            addSummary();
            addTransactionToDoc();

            addICPCCodes();
            addProblemList();
            addActivePrescriptions();
            addTransactionToDoc();

            addAntecedenten();
        }
        catch(Exception e){
            e.printStackTrace();
        }
    }


    //### PRIVATE METHODS ##########################################################################

    //--- ADD ANTECEDENTEN -------------------------------------------------------------------------
    private void addAntecedenten() throws Exception {
        Vector vANT = new Vector();
        vANT.add(IConstants_PREFIX+"ITEM_TYPE_CE_HISTORY1");
        vANT.add(IConstants_PREFIX+"ITEM_TYPE_CE_BEROEPSZIEKTEN1");
        vANT.add(IConstants_PREFIX+"ITEM_TYPE_CE_ARBEIDSONGEVALLEN1");
        vANT.add(IConstants_PREFIX+"ITEM_TYPE_CE_MEDISCHE_ANTECEDENTEN1");
        vANT.add(IConstants_PREFIX+"ITEM_TYPE_CE_PERSONAL_ACCIDENT1");
        vANT.add(IConstants_PREFIX+"ITEM_TYPE_CE_MEDISCH_TABACCO1");
        vANT.add(IConstants_PREFIX+"ITEM_TYPE_CE_PERSONAL_BLOOTSTELLING_PROFESSIONIEEL");
        vANT.add(IConstants_PREFIX+"ITEM_TYPE_CE_PERSONAL_BLOOTSTELLING_PROFESSIONIEEL_VALUE");
        vANT.add(IConstants_PREFIX+"ITEM_TYPE_CE_PERSONAL_BLOOTSTELLING_MEDISCH");

        if(verifyList(vANT)){
            addFamilialeAntecedenten();
            addTransactionToDoc();

            addPersoonlijkeAntecedenten();
            addTransactionToDoc();
        }
    }

    //--- ADD LAST BIOMETRIC EXAMINATION INFO -----------------------------------------------------
    private void addLastBiometricExaminationInfo(){
        contentTable = new PdfPTable(1);

        String sItemTypes = "'"+IConstants_PREFIX+"ITEM_TYPE_CARDIAL_CLINICAL_EXAMINATION_SYSTOLIC_PRESSURE_RIGHT',"+
                            "'"+IConstants_PREFIX+"ITEM_TYPE_CARDIAL_CLINICAL_EXAMINATION_DIASTOLIC_PRESSURE_RIGHT',"+
                            "'"+IConstants_PREFIX+"ITEM_TYPE_CARDIAL_CLINICAL_EXAMINATION_DIASTOLIC_PRESSURE_LEFT',"+
                            "'"+IConstants_PREFIX+"ITEM_TYPE_CARDIAL_CLINICAL_EXAMINATION_SYSTOLIC_PRESSURE_LEFT'";

        Transaction transaction = Transaction.getSummaryTransaction(sItemTypes,patient.personid);
        if (transaction != null) {
            String sUpdateTime = ScreenHelper.getSQLDate(transaction.getUpdatetime());

            // transactionID
            TransactionID transactionID = new TransactionID();
            transactionID.transactionid = transaction.getTransactionId();
            transactionID.serverid = transaction.getServerid();

            // blood pressure
            String sSystolicRight  = getItemValueByTransactionID(transactionID,IConstants_PREFIX+"ITEM_TYPE_CARDIAL_CLINICAL_EXAMINATION_SYSTOLIC_PRESSURE_RIGHT"),
                   sSystolicLeft   = getItemValueByTransactionID(transactionID,IConstants_PREFIX+"ITEM_TYPE_CARDIAL_CLINICAL_EXAMINATION_DIASTOLIC_PRESSURE_RIGHT"),
                   sDiastolicRight = getItemValueByTransactionID(transactionID,IConstants_PREFIX+"ITEM_TYPE_CARDIAL_CLINICAL_EXAMINATION_SYSTOLIC_PRESSURE_LEFT"),
                   sDiastolicLeft  = getItemValueByTransactionID(transactionID,IConstants_PREFIX+"ITEM_TYPE_CARDIAL_CLINICAL_EXAMINATION_DIASTOLIC_PRESSURE_LEFT");

            String sWeight = getLastItemValue(IConstants_PREFIX+"ITEM_TYPE_BIOMETRY_WEIGHT"),
                   sHeight = getLastItemValue(IConstants_PREFIX+"ITEM_TYPE_BIOMETRY_HEIGHT");

            // calculate bmi
            String sBMI = "";
            if(sWeight.length() > 0 && sHeight.length() > 0){
                double bmi = (Double.parseDouble(sWeight) * 10000) / (Double.parseDouble(sHeight) * Double.parseDouble(sHeight));
                bmi = Math.round(bmi*10)/10;
                sBMI = bmi+"";
            }

            if(sSystolicRight.length() > 0 || sSystolicLeft.length() > 0 ||
               sDiastolicRight.length() > 0 || sDiastolicLeft.length() > 0 ||
               sWeight.length() > 0 || sHeight.length() > 0 || sBMI.length() > 0){

                // display values in one row
                PdfPTable bioTable = new PdfPTable(6);

                cell = createHeaderCell(getTran("Web.Occup","medwan.healthrecord.clinical-examination.systeme-cardiovasculaire.TA")+" ("+sUpdateTime+")",1);
                cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
                bioTable.addCell(cell);

                cell = new PdfPCell(new Paragraph(sSystolicRight+" / "+sSystolicLeft+" mmHg",FontFactory.getFont(FontFactory.HELVETICA,7,Font.BOLD)));
                cell.setColspan(1);
                cell.setBorder(PdfPCell.BOX);
                cell.setBorderColor(innerBorderColor);
                cell.setBackgroundColor(BGCOLOR_LIGHT);
                bioTable.addCell(cell);

                cell = new PdfPCell(new Paragraph(sDiastolicRight+" / "+sDiastolicLeft+" mmHg",FontFactory.getFont(FontFactory.HELVETICA,7,Font.BOLD)));
                cell.setColspan(1);
                cell.setBorder(PdfPCell.BOX);
                cell.setBorderColor(innerBorderColor);
                cell.setBackgroundColor(BGCOLOR_LIGHT);
                bioTable.addCell(cell);

                cell = createHeaderCell(getTran("Web.Occup","medwan.healthrecord.biometry.weight")+" : "+sWeight,1);
                cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
                bioTable.addCell(cell);

                cell = createHeaderCell(getTran("Web.Occup","medwan.healthrecord.biometry.length")+" : "+sHeight,1);
                cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
                bioTable.addCell(cell);

                cell = createHeaderCell(getTran("Web.Occup","medwan.healthrecord.biometry.bmi")+" : "+sBMI,1);
                cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
                bioTable.addCell(cell);

                // add table
                if(bioTable.size() > 0){
                    if(contentTable.size() > 0) contentTable.addCell(emptyCell());
                    contentTable.addCell(createCell(new PdfPCell(bioTable),1,PdfPCell.ALIGN_CENTER,PdfPCell.BOX));
                    tranTable.addCell(createContentCell(contentTable));
                }
            }
        }
    }

    //--- GET ITEM VALUE BY TRANSACTION ID --------------------------------------------------------
    private String getItemValueByTransactionID(TransactionID transactionID, String sItemType) {
        String sItemValue = "";
        Vector vItems = Item.getItems(Integer.toString(transactionID.transactionid), Integer.toString(transactionID.serverid), sItemType);
        Iterator iter = vItems.iterator();

        Item item;
        while (iter.hasNext()) {
            item = (Item) iter.next();
            sItemValue = item.getValue();
            sItemValue = getTran("Web.Occup",sItemValue);
        }

        return sItemValue;
    }

    //--- ADD SUMMARY -----------------------------------------------------------------------------
    private void addSummary() throws Exception {
        contentTable = new PdfPTable(1);
        table = new PdfPTable(5);

        // title
        table.addCell(createTitleCell(getTran("Web.Occup","medwan.healthrecord.general"),5));

        //*** Signes subjectifs ***
        itemValue = getItemSeriesValue(IConstants_PREFIX+"[GENERAL.ANAMNESE]ITEM_TYPE_SUBJECTIVE");
        if(itemValue.length() > 0){
            addItemRow(table,getTran("Web.Occup","medwan.healthrecord.anamnese.general.subjective"),itemValue);
        }

        //*** Signes objectifs ***
        itemValue = getItemSeriesValue(IConstants_PREFIX+"[GENERAL.ANAMNESE]ITEM_TYPE_OBJECTIVE");
        if(itemValue.length() > 0){
            addItemRow(table,getTran("Web.Occup","medwan.healthrecord.anamnese.general.objective"),itemValue);
        }

        //*** Evaluation ***
        itemValue = getItemSeriesValue(IConstants_PREFIX+"[GENERAL.ANAMNESE]ITEM_TYPE_EVALUATION");
        if(itemValue.length() > 0){
            addItemRow(table,getTran("Web.Occup","medwan.healthrecord.anamnese.general.evaluation"),itemValue);
        }

        //*** Planning ***
        itemValue = getItemSeriesValue(IConstants_PREFIX+"[GENERAL.ANAMNESE]ITEM_TYPE_PLANNING");
        if(itemValue.length() > 0){
            addItemRow(table,getTran("Web.Occup","medwan.healthrecord.anamnese.general.planning"),itemValue);
        }

        //*** hartritme *******************************************************
        String sHeartFreq  = getItemValue(IConstants_PREFIX+"ITEM_TYPE_CARDIAL_CLINICAL_EXAMINATION_HEARTH_FREQUENCY"),
               sHeartRytmh = getItemValue(IConstants_PREFIX+"ITEM_TYPE_CARDIAL_CLINICAL_EXAMINATION_HEARTH_RYTMH");

        if(sHeartFreq.length() > 0 || sHeartRytmh.length() > 0){
            if(sHeartFreq.length() > 0){
                sHeartFreq+= " /"+getTran("units","minute");
            }

            if(sHeartRytmh.length() > 0){
                sHeartRytmh = "  ("+getTran(sHeartRytmh).toLowerCase()+")";
            }

            table.addCell(createItemNameCell(getTran(IConstants_PREFIX+"ITEM_TYPE_CARDIAL_CLINICAL_EXAMINATION_HEARTH_FREQUENCY"),2));
            table.addCell(createValueCell(sHeartFreq+sHeartRytmh,3));
        }

        //*** bloodpressure ***************************************************
        PdfPTable containerTable = new PdfPTable(10),
                  bloodpressureTable = new PdfPTable(7);

        // bloodpressure right
        String sysRight = getItemValue(IConstants_PREFIX+"ITEM_TYPE_CARDIAL_CLINICAL_EXAMINATION_SYSTOLIC_PRESSURE_RIGHT"),
               diaRight = getItemValue(IConstants_PREFIX+"ITEM_TYPE_CARDIAL_CLINICAL_EXAMINATION_DIASTOLIC_PRESSURE_RIGHT");
        if(sysRight.length() > 0 || diaRight.length() > 0){
            bloodpressureTable.addCell(createValueCell(getTran("Web.Occup","medwan.healthrecord.cardial.bras-droit"),1));
            bloodpressureTable.addCell(createValueCell(sysRight+" / "+diaRight+" mmHg",6));
        }

        // bloodpressure left
        String sysLeft = getItemValue(IConstants_PREFIX+"ITEM_TYPE_CARDIAL_CLINICAL_EXAMINATION_SYSTOLIC_PRESSURE_LEFT"),
               diaLeft = getItemValue(IConstants_PREFIX+"ITEM_TYPE_CARDIAL_CLINICAL_EXAMINATION_DIASTOLIC_PRESSURE_LEFT");
        if(sysLeft.length() > 0 || diaLeft.length() > 0){
            bloodpressureTable.addCell(createValueCell(getTran("Web.Occup","medwan.healthrecord.cardial.bras-gauche"),1));
            bloodpressureTable.addCell(createValueCell(sysLeft+" / "+diaLeft+" mmHg",6));
        }

        if(bloodpressureTable.size() > 0){
            containerTable.addCell(createItemNameCell(getTran("Web.Occup","medwan.healthrecord.cardial.pression-arterielle"),3));
            containerTable.addCell(createCell(new PdfPCell(bloodpressureTable),7,PdfPCell.ALIGN_CENTER,PdfPCell.NO_BORDER));

            table.addCell(createCell(new PdfPCell(containerTable),5,PdfPCell.ALIGN_CENTER,PdfPCell.NO_BORDER));
        }
        
        //*** temperature *****************************************************
        itemValue = getItemValue(IConstants_PREFIX+"[GENERAL.ANAMNESE]ITEM_TYPE_TEMPERATURE");
        if(itemValue.length() > 0){
            addItemRow(table,getTran("openclinic.chuk","temperature"),itemValue+" "+getTran("units","degreesCelcius"));
        }

        //*** breathing *******************************************************
        itemValue = getItemValue(IConstants_PREFIX+"[GENERAL.ANAMNESE]ITEM_TYPE_RESPIRATORY_FRENQUENCY");
        if(itemValue.length() > 0){
            addItemRow(table,getTran("openclinic.chuk","respiratory.frequency"),itemValue+" /"+getTran("units","minute"));
        }
        
        //*** roken-alcohol-sport *********************************************
        Vector listRAS = new Vector();
        listRAS.add(IConstants_PREFIX+"[GENERAL.ANAMNESE]ITEM_TYPE_TOBACCO_USAGE");
        listRAS.add(IConstants_PREFIX+"[GENERAL.ANAMNESE]ITEM_TYPE_ALCOHOL_USAGE");
        listRAS.add(IConstants_PREFIX+"[GENERAL.ANAMNESE]ITEM_TYPE_SPORTS");
        listRAS.add(IConstants_PREFIX+"ITEM_TYPE_CE_ANAMNESE_SPORT");

        if(verifyList(listRAS)){
            // tobacco
            String sTobacco = getItemValue(IConstants_PREFIX+"[GENERAL.ANAMNESE]ITEM_TYPE_TOBACCO_USAGE");
            if(sTobacco.length() > 0){
                     if(sTobacco.equals("1")) sTobacco = "0 ";
                else if(sTobacco.equals("2")) sTobacco = "0 - 5 ";
                else if(sTobacco.equals("3")) sTobacco = "5 - 10 ";
                else if(sTobacco.equals("4")) sTobacco = "10 - 15 ";
                else if(sTobacco.equals("5")) sTobacco = "15 - 25 ";
                else if(sTobacco.equals("6")) sTobacco = "> 25 ";
                sTobacco+= "/"+getTran("units","day");

                addItemRow(table,getTran(IConstants_PREFIX+"[GENERAL.ANAMNESE]ITEM_TYPE_TOBACCO_USAGE"),sTobacco);
            }

            // alcohol
            itemValue = getItemValue(IConstants_PREFIX+"[GENERAL.ANAMNESE]ITEM_TYPE_ALCOHOL_USAGE");
            if(itemValue.length() > 0){
                itemValue = getTran("Web.Occup",itemValue).toLowerCase();                
                addItemRow(table,getTran(IConstants_PREFIX+"[GENERAL.ANAMNESE]ITEM_TYPE_ALCOHOL_USAGE"),itemValue);
            }

            // sport
            String sSport = getItemValue(IConstants_PREFIX+"ITEM_TYPE_CE_ANAMNESE_SPORT");
            if(sSport.length() > 0){
                     if(sSport.equals("1")) sSport = "0 ";
                else if(sSport.equals("2")) sSport = "0 - 1 ";
                else if(sSport.equals("3")) sSport = "1 - 2 ";
                else if(sSport.equals("4")) sSport = "2 - 3 ";
                else if(sSport.equals("5")) sSport = "3 - 4 ";
                else if(sSport.equals("6")) sSport = "> 4 ";
                sSport+= getTran("units","hour")+"/"+getTran("units","week");

                // remark
                String sSportRemark = getItemValue(IConstants_PREFIX+"[GENERAL.ANAMNESE]ITEM_TYPE_SPORTS");
                if(sSportRemark.length() > 0){
                    sSport+= "  ("+sSportRemark+")";
                }

                addItemRow(table,getTran(IConstants_PREFIX+"ITEM_TYPE_CE_ANAMNESE_SPORT"),sSport);
            }
        }

        // add summary table
        if(table.size() > 0){
            if(contentTable.size() > 0) contentTable.addCell(emptyCell());
            contentTable.addCell(createCell(new PdfPCell(table),1,PdfPCell.ALIGN_CENTER,PdfPCell.NO_BORDER));
            tranTable.addCell(createContentCell(contentTable));
        }
    }

    //--- ADD ICPC CODES --------------------------------------------------------------------------
    private void addICPCCodes() throws Exception {
        contentTable = new PdfPTable(1);
        table = new PdfPTable(5);

        // title
        table.addCell(createHeaderCell(getTran("ICPC-2")+" / "+getTran("ICD-10"),5));
        Collection items = transactionVO.getItems();

        if(items != null){
            Iterator itemIter = items.iterator();
            ItemVO item;
            String value, type;

            while(itemIter.hasNext()){
                item = (ItemVO)itemIter.next();

                if(item.getType().indexOf("ICPCCode")==0){
                    value = item.getValue().trim();
                    type = item.getType().trim();
                    type = type.replaceAll("ICPCCode","")+" "+MedwanQuery.getInstance().getCodeTran(type,sPrintLanguage);
                    table.addCell(createValueCell(type+" ["+value+"]",5));
                }
                else if (item.getType().indexOf("ICD10Code")==0){
                    value = item.getValue().trim();
                    type = item.getType().trim();
                    type = type.replaceAll("ICD10Code","")+" "+MedwanQuery.getInstance().getCodeTran(type,sPrintLanguage);
                    table.addCell(createValueCell(type+" ["+value+"]",5));
                }
            }

            // add icpc codes table
            if(table.size() > 1){
                if(contentTable.size() > 0) contentTable.addCell(emptyCell());
                contentTable.addCell(createCell(new PdfPCell(table),1,PdfPCell.ALIGN_CENTER,PdfPCell.NO_BORDER));
                tranTable.addCell(createContentCell(contentTable));
            }
        }
    }

    //--- ADD PROBLEMLIST -------------------------------------------------------------------------
    private void addProblemList(){
        contentTable = new PdfPTable(1);
        table = new PdfPTable(5);

        // title
        table.addCell(createTitleCell(getTran("web.occup","medwan.common.problemlist"),5));

        Vector activeProblems = Problem.getActiveProblems(patient.personid);
        if(activeProblems.size()>0){
            PdfPTable problemsTable = new PdfPTable(3);

            // header
            problemsTable.addCell(createHeaderCell(getTran("web.occup","medwan.common.description"),2));
            problemsTable.addCell(createHeaderCell(getTran("web.occup","medwan.common.datebegin"),1));

            Problem activeProblem;
            String comment, value;
            for(int n=0; n<activeProblems.size(); n++){
                activeProblem = (Problem)activeProblems.elementAt(n);

                value = activeProblem.getCode()+" "+ MedwanQuery.getInstance().getCodeTran(activeProblem.getCodeType()+"code"+activeProblem.getCode(),sPrintLanguage);
                Paragraph par = new Paragraph(value, FontFactory.getFont(FontFactory.HELVETICA,7, Font.NORMAL));

                // add comment if any
                if(activeProblem.getComment().trim().length() > 0){
                    comment = " : "+activeProblem.getComment().trim();
                    par.add(new Chunk(comment,FontFactory.getFont(FontFactory.HELVETICA,7,Font.ITALIC)));
                }

                cell = new PdfPCell(par);
                cell.setColspan(2);
                cell.setBorder(PdfPCell.BOX);
                cell.setBorderColor(innerBorderColor);
                cell.setVerticalAlignment(PdfPCell.ALIGN_TOP);
                cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
                problemsTable.addCell(cell);

                // date
                problemsTable.addCell(createValueCell(new SimpleDateFormat("dd/MM/yyyy").format(activeProblem.getBegin()),1));
            }
        }

        // add table
        if(table.size() > 1){
            if(contentTable.size() > 0) contentTable.addCell(emptyCell());
            contentTable.addCell(createCell(new PdfPCell(table),1,PdfPCell.ALIGN_CENTER,PdfPCell.NO_BORDER));
            tranTable.addCell(createContentCell(contentTable));
        }
    }
    
    //--- ADD ACTIVE PRESCRIPTIONS ----------------------------------------------------------------
    private void addActivePrescriptions(){
        try{
            contentTable = new PdfPTable(1);
            table = new PdfPTable(5);

            // Active prescriptions
            Vector vActivePrescriptions = Prescription.findActive(patient.personid,transactionVO.user.getUserId()+"","","","","","","");
            StringBuffer prescriptions = new StringBuffer();
            Vector idsVector = getActivePrescriptionsFromRs(prescriptions,vActivePrescriptions);
            PdfPTable prescrTable = new PdfPTable(4);

            if(idsVector.size() > 0){
                // title
                prescrTable.addCell(createTitleCell(getTran("Web.Occup","medwan.healthrecord.medication"),4));

                // header
                prescrTable.addCell(createTitleCell(getTran("Web","product"),4));
                prescrTable.addCell(createTitleCell(getTran("Web","begindate"),4));
                prescrTable.addCell(createTitleCell(getTran("Web","enddate"),4));
                prescrTable.addCell(createTitleCell(getTran("Web","prescriptionrule"),4));

                // medicines
                itemValue = prescriptions.toString();
                prescrTable.addCell(createItemNameCell(getTran("openclinic.chuk","administer_medicines"),1));
                prescrTable.addCell(createValueCell(itemValue,3));

                // add prescriptions table
                if(prescrTable.size() > 0){
                    table.addCell(createCell(new PdfPCell(table),4,PdfPCell.ALIGN_CENTER,PdfPCell.BOX));
                }
            }

            // add transaction to doc
            if(table.size() > 0){
                if(contentTable.size() > 0) contentTable.addCell(emptyCell());
                contentTable.addCell(createCell(new PdfPCell(table),1, PdfPCell.ALIGN_CENTER,PdfPCell.BOX));
                tranTable.addCell(createContentCell(contentTable));
            }
        }
        catch(Exception e){
            e.printStackTrace();
        }
    }

    //--- GET ACTIVE PRESCRIPTIONS FROM RS --------------------------------------------------------
    private Vector getActivePrescriptionsFromRs(StringBuffer prescriptions, Vector vActivePrescriptions) throws SQLException {
        Vector idsVector = new Vector();
        Product product = null;
        String sClass = "1", sPrescriptionUid, sProductName = "", sProductUid, sPreviousProductUid = "",
               sTimeUnit, sTimeUnitCount,  sUnitsPerTimeUnit, sPrescrRule = "", sProductUnit, timeUnitTran;
        DecimalFormat unitCountDeci = new DecimalFormat("#.#");

        // frequently used translations
        Iterator iter = vActivePrescriptions.iterator();

        // run thru found prescriptions
        Prescription prescription;

        while (iter.hasNext()) {
            prescription = (Prescription) iter.next();
            sPrescriptionUid = prescription.getUid();

            // alternate row-style
            if(sClass.equals("")) sClass = "1";
            else                  sClass = "";

            idsVector.add(sPrescriptionUid);

            // only search product-name when different product-UID
            sProductUid = prescription.getProductUid();
            if(!sProductUid.equals(sPreviousProductUid)){
                sPreviousProductUid = sProductUid;
                product = getProduct(sProductUid);
                if(product != null) sProductName = product.getName();
                else                sProductName = "";
            }

            //*** compose prescriptionrule (gebruiksaanwijzing) ***
            // unit-stuff
            sTimeUnit         = prescription.getTimeUnit();
            sTimeUnitCount    = Integer.toString(prescription.getTimeUnitCount());
            sUnitsPerTimeUnit = Double.toString(prescription.getUnitsPerTimeUnit());

            // only compose prescriptio-rule if all data is available
            if (!sTimeUnit.equals("0") && !sTimeUnitCount.equals("0") && !sUnitsPerTimeUnit.equals("0")) {
                sPrescrRule = getTran("web.prescriptions", "prescriptionrule");
                sPrescrRule = sPrescrRule.replaceAll("#unitspertimeunit#", unitCountDeci.format(Double.parseDouble(sUnitsPerTimeUnit)));
                if(product != null) sProductUnit = product.getUnit();
                else                sProductUnit = "";

                // productunits
                if (Double.parseDouble(sUnitsPerTimeUnit) == 1) {
                    sProductUnit = getTran("product.unit", sProductUnit);
                }
                else {
                    sProductUnit = getTran("product.units", sProductUnit);
                }
                sPrescrRule = sPrescrRule.replaceAll("#productunit#", sProductUnit.toLowerCase());

                // timeunits
                if (Integer.parseInt(sTimeUnitCount) == 1) {
                    sPrescrRule = sPrescrRule.replaceAll("#timeunitcount#", "");
                    timeUnitTran = getTran("prescription.timeunit", sTimeUnit);
                }
                else {
                    sPrescrRule = sPrescrRule.replaceAll("#timeunitcount#", sTimeUnitCount);
                    timeUnitTran = getTran("prescription.timeunits", sTimeUnit);
                }
                sPrescrRule = sPrescrRule.replaceAll("#timeunit#", timeUnitTran.toLowerCase());
            }

            //*** display prescription in one row ***
            prescriptions.append(sProductName+" ("+sPrescrRule.toLowerCase() + ")\n");
        }

        return idsVector;
    }

    //--- GET PRODUCT -----------------------------------------------------------------------------
    private Product getProduct(String sProductUid) {
        // search for product in products-table
        Product product;
        product = Product.get(sProductUid);

        if (product != null && product.getName() == null) {
            // search for product in product-history-table
            product = product.getProductFromHistory(sProductUid);
        }

        return product;
    }

    //#############################################################################################
    //### ANTECEDENTEN ############################################################################
    //#############################################################################################

    //--- ADD PERSOONLIJKE ANTECEDENTEN -----------------------------------------------------------
    private void addPersoonlijkeAntecedenten() throws Exception {
        contentTable = new PdfPTable(1);
        table = new PdfPTable(8);

        // title
        table.addCell(createTitleCell(getTran("personal_antecedents"),8));

        //*** comment *********************************************************
        itemValue = getItemSeriesValue(IConstants_PREFIX+"ITEM_TYPE_CE_PERSONAL_COMMENT");
        if(itemValue.length() > 0){
            table.addCell(createItemNameCell(getTran("medwan.common.comment"),3));
            table.addCell(createValueCell(itemValue,5));
        }

        //*** medische antecedenten *******************************************
        String sChirurgie = getItemSeriesValue(IConstants_PREFIX+"ITEM_TYPE_CE_MEDISCHE_ANTECEDENTEN");
        if(sChirurgie.length() > 0){
            // spacer cell
            table.addCell(createBorderlessCell(8));

            // title
            cell = createTitleCell(getTran("medical_antecedents"),8);
            cell.setHorizontalAlignment(PdfPCell.LEFT);
            table.addCell(cell);

            // header
            table.addCell(createHeaderCell(getTran("medwan.common.date-begin"),1));
            table.addCell(createHeaderCell(getTran("medwan.common.date-end"),1));
            table.addCell(createHeaderCell(getTran("medwan.common.description"),6));

            if(sChirurgie.indexOf("£")>-1) {
                String sTmpChirurgie = sChirurgie;
                String sTmpChirurgieDateBegin, sTmpChirurgieDateEnd, sTmpChirurgieDescr;

                while(sTmpChirurgie.indexOf("$")>-1) {
                    // date begin
                    sTmpChirurgieDateBegin = "";
                    if(sTmpChirurgie.indexOf("£")>-1){
                        sTmpChirurgieDateBegin = sTmpChirurgie.substring(0,sTmpChirurgie.indexOf("£"));
                        sTmpChirurgie = sTmpChirurgie.substring(sTmpChirurgie.indexOf("£")+1);
                    }

                    // date end
                    sTmpChirurgieDateEnd = "";
                    if(sTmpChirurgie.indexOf("£")>-1){
                        sTmpChirurgieDateEnd = sTmpChirurgie.substring(0,sTmpChirurgie.indexOf("£"));
                        sTmpChirurgie = sTmpChirurgie.substring(sTmpChirurgie.indexOf("£")+1);
                    }

                    // description
                    sTmpChirurgieDescr = "";
                    if(sTmpChirurgie.indexOf("$")>-1){
                        sTmpChirurgieDescr = sTmpChirurgie.substring(0,sTmpChirurgie.indexOf("$"));
                        sTmpChirurgie = sTmpChirurgie.substring(sTmpChirurgie.indexOf("$")+1);
                    }

                    // add row
                    table.addCell(createValueCell(sTmpChirurgieDateBegin,1));
                    table.addCell(createValueCell(sTmpChirurgieDateEnd,1));
                    table.addCell(createValueCell(sTmpChirurgieDescr,6));
                }
            }
        }

        //*** heelkundige antecedenten ****************************************
        String sHeelkunde = getItemSeriesValue(IConstants_PREFIX+"ITEM_TYPE_CE_HEELKUNDE");
        if(sHeelkunde.length() > 0){
            // spacer cell
            table.addCell(createBorderlessCell(8));

            // title
            cell = createTitleCell(getTran("heelkundige_antecedenten"),8);
            cell.setHorizontalAlignment(PdfPCell.LEFT);
            table.addCell(cell);

            // header
            table.addCell(createHeaderCell(getTran("medwan.common.date-begin"),1));
            table.addCell(createHeaderCell(getTran("medwan.common.date-end"),1));
            table.addCell(createHeaderCell(getTran("medwan.common.description"),6));

            if(sHeelkunde.indexOf("£")>-1) {
                String sTmpHeelkunde = sHeelkunde;
                String sTmpHeelkundeDateBegin, sTmpHeelkundeDateEnd, sTmpHeelkundeDescr;

                while(sTmpHeelkunde.indexOf("$")>-1) {
                    // date begin
                    sTmpHeelkundeDateBegin = "";
                    if(sTmpHeelkunde.indexOf("£")>-1){
                        sTmpHeelkundeDateBegin = sTmpHeelkunde.substring(0,sTmpHeelkunde.indexOf("£"));
                        sTmpHeelkunde = sTmpHeelkunde.substring(sTmpHeelkunde.indexOf("£")+1);
                    }

                    // date end
                    sTmpHeelkundeDateEnd = "";
                    if(sTmpHeelkunde.indexOf("£")>-1){
                        sTmpHeelkundeDateEnd = sTmpHeelkunde.substring(0,sTmpHeelkunde.indexOf("£"));
                        sTmpHeelkunde = sTmpHeelkunde.substring(sTmpHeelkunde.indexOf("£")+1);
                    }

                    // description
                    sTmpHeelkundeDescr = "";
                    if(sTmpHeelkunde.indexOf("$")>-1){
                        sTmpHeelkundeDescr = sTmpHeelkunde.substring(0,sTmpHeelkunde.indexOf("$"));
                        sTmpHeelkunde = sTmpHeelkunde.substring(sTmpHeelkunde.indexOf("$")+1);
                    }

                    // add row
                    table.addCell(createValueCell(sTmpHeelkundeDateBegin,1));
                    table.addCell(createValueCell(sTmpHeelkundeDateEnd,1));
                    table.addCell(createValueCell(sTmpHeelkundeDescr,6));
                }
            }
        }

        //*** Letsels met %BI *************************************************
        String sLetsels = getItemSeriesValue(IConstants_PREFIX+"ITEM_TYPE_CE_LETSELS");
        if(sLetsels.length() > 0){
            // spacer cell
            table.addCell(createBorderlessCell(8));

            // title
            cell = createTitleCell(getTran("lesions_with_%_pi"),8);
            cell.setHorizontalAlignment(PdfPCell.LEFT);
            table.addCell(cell);

            // header
            table.addCell(createHeaderCell(getTran("medwan.common.date-begin"),1));
            table.addCell(createHeaderCell(getTran("medwan.common.description"),6));
            table.addCell(createHeaderCell(getTran("PI"),1));

            if(sLetsels.indexOf("£")>-1) {
                String sTmpLetsels = sLetsels;
                String sTmpLetselsDate, sTmpLetselsDescr, sTmpLetselsBI;

                while(sTmpLetsels.indexOf("$")>-1) {
                    // date
                    sTmpLetselsDate = "";
                    if(sTmpLetsels.indexOf("£")>-1){
                        sTmpLetselsDate = sTmpLetsels.substring(0,sTmpLetsels.indexOf("£"));
                        sTmpLetsels = sTmpLetsels.substring(sTmpLetsels.indexOf("£")+1);
                    }

                    // description
                    sTmpLetselsDescr = "";
                    if(sTmpLetsels.indexOf("£")>-1){
                        sTmpLetselsDescr = sTmpLetsels.substring(0,sTmpLetsels.indexOf("£"));
                        sTmpLetsels = sTmpLetsels.substring(sTmpLetsels.indexOf("£")+1);
                    }

                    // BI
                    sTmpLetselsBI = "";
                    if(sTmpLetsels.indexOf("$")>-1){
                        sTmpLetselsBI = sTmpLetsels.substring(0,sTmpLetsels.indexOf("$"));
                        sTmpLetsels = sTmpLetsels.substring(sTmpLetsels.indexOf("$")+1);
                    }

                    // add row
                    table.addCell(createValueCell(sTmpLetselsDate,1));
                    table.addCell(createValueCell(sTmpLetselsDescr,6));
                    table.addCell(createValueCell(sTmpLetselsBI+" "+getTran("units","percentage"),1));
                }
            }
        }

        // add PersoonlijkeAntecedenten table
        if(table.size() > 1){
            contentTable.addCell(createCell(new PdfPCell(table),1,PdfPCell.ALIGN_CENTER,PdfPCell.NO_BORDER));
            tranTable.addCell(createContentCell(contentTable));
        }
    }

    //--- ADD FAMILIALE ANTECEDENTEN --------------------------------------------------------------
    protected void addFamilialeAntecedenten() throws Exception {
        contentTable = new PdfPTable(1);
        table = new PdfPTable(8);

        // title
        table.addCell(createTitleCell(getTran("familial_antecedents"),8));

        //*** status & comment ************************************************
        String sStatus  = getItemValue(IConstants_PREFIX+"ITEM_TYPE_CE_STATUS"),
               sComment = getItemValue(IConstants_PREFIX+"ITEM_TYPE_CE_STATUS_COMMENT");

        if(sStatus.length() > 0 || sComment.length() > 0){
            // status
            if(sStatus.length() > 0){
                sStatus = getTran("clinicalexamination.familialstatus",sStatus).toLowerCase();
                table.addCell(createItemNameCell(getTran("medwan.occupational-medicine.risk-profile.status"),2));
                table.addCell(createValueCell(sStatus,6));
            }

            // comment
            if(sComment.length() > 0){
                table.addCell(createItemNameCell(getTran("medwan.common.comment"),2));
                table.addCell(createValueCell(sComment,6));
            }
        }

        //*** kinderen ********************************************************
        String sKinderen = getItemValue(IConstants_PREFIX+"ITEM_TYPE_CE_KINDEREN");
        if(!sKinderen.equals("")){
            // spacer cell
            table.addCell(createBorderlessCell(8));

            // title
            cell = createTitleCell(getTran("children"),8);
            cell.setHorizontalAlignment(PdfPCell.LEFT);
            table.addCell(cell);

            // header
            table.addCell(createHeaderCell(getTran("Birth_Year"),2));  
            table.addCell(createHeaderCell(getTran("cbmt.occup.individual.gender"),1));
            table.addCell(createHeaderCell(getTran("web","firstname"),5));

            if(sKinderen.indexOf("£")>-1){
                String sTmpKinderen = sKinderen;
                String sTmpKinderenGeslacht, sTmpKinderenGeboortejaar, sTmpKinderenFirstname;

                while(sTmpKinderen.indexOf("$")>-1) {
                    // geboortejaar
                    sTmpKinderenGeboortejaar = "";
                    if(sTmpKinderen.indexOf("£")>-1){
                        sTmpKinderenGeboortejaar = sTmpKinderen.substring(0,sTmpKinderen.indexOf("£"));
                        sTmpKinderen = sTmpKinderen.substring(sTmpKinderen.indexOf("£")+1);
                    }
                    
                    // geslacht
                    sTmpKinderenGeslacht = "";
                    if(sTmpKinderen.indexOf("£")>-1){
                         sTmpKinderenGeslacht = sTmpKinderen.substring(0,sTmpKinderen.indexOf("£"));

                              if(sTmpKinderenGeslacht.equals("M")) sTmpKinderenGeslacht = getTran("Male");
                         else if(sTmpKinderenGeslacht.equals("F")) sTmpKinderenGeslacht = getTran("Female");

                         sTmpKinderen = sTmpKinderen.substring(sTmpKinderen.indexOf("£")+1);
                    }

                    // firstname
                    sTmpKinderenFirstname = "";
                    if(sTmpKinderen.indexOf("$")>-1){
                        sTmpKinderenFirstname = sTmpKinderen.substring(0,sTmpKinderen.indexOf("$"));
                        sTmpKinderen = sTmpKinderen.substring(sTmpKinderen.indexOf("$")+1);
                    }

                    // add row
                    table.addCell(createValueCell(sTmpKinderenGeboortejaar,2));
                    table.addCell(createValueCell(sTmpKinderenGeslacht,1));
                    table.addCell(createValueCell(sTmpKinderenFirstname,5));
                }
            }
        }

        //*** verwantschap ****************************************************
        String sFami = getItemValue(IConstants_PREFIX+"ITEM_TYPE_CE_FAMILIALE_ANTECEDENTEN");
        if(sFami.length() > 0){
            // spacer cell
            table.addCell(createBorderlessCell(8));

            // title
            cell = createTitleCell(getTran("familial_antecedents"),8);
            cell.setHorizontalAlignment(PdfPCell.LEFT);
            table.addCell(cell);

            // header
            table.addCell(createHeaderCell(getTran("medwan.common.date"),1));
            table.addCell(createHeaderCell(getTran("medwan.common.description"),5));
            table.addCell(createHeaderCell(getTran("verwantschap"),2));

            if(sFami.indexOf("$") > 0){
                String sTmpFami = sFami;
                String sTmpFamiDate, sTmpFamiDescr, sTmpFamiVerwantschap;

                while(sTmpFami.indexOf("$")>-1) {
                    // date
                    sTmpFamiDate = "";
                    if(sTmpFami.indexOf("£")>-1){
                        sTmpFamiDate = sTmpFami.substring(0,sTmpFami.indexOf("£"));
                        sTmpFami = sTmpFami.substring(sTmpFami.indexOf("£")+1);
                    }

                    // description
                    sTmpFamiDescr = "";
                    if(sTmpFami.indexOf("£")>-1){
                        sTmpFamiDescr = sTmpFami.substring(0,sTmpFami.indexOf("£"));
                        sTmpFami = sTmpFami.substring(sTmpFami.indexOf("£")+1);
                    }

                    // verwantschap
                    sTmpFamiVerwantschap = "";
                    if(sTmpFami.indexOf("$")>-1){
                        sTmpFamiVerwantschap = sTmpFami.substring(0,sTmpFami.indexOf("$"));
                        sTmpFami = sTmpFami.substring(sTmpFami.indexOf("$")+1);
                    }

                    // add row
                    table.addCell(createValueCell(sTmpFamiDate,1));
                    table.addCell(createValueCell(sTmpFamiDescr,5));
                    table.addCell(createValueCell(sTmpFamiVerwantschap,2));
                }
            }
        }

        //*** comment *********************************************************
        itemValue = getItemSeriesValue(IConstants_PREFIX+"ITEM_TYPE_CE_FAMILIAAL_COMMENT");
        if(itemValue.length() > 0){
            // spacer cell
            table.addCell(createBorderlessCell(8));

            table.addCell(createItemNameCell(getTran("medwan.common.comment"),3));
            table.addCell(createValueCell(itemValue,5));
        }

        // add FamilialeAntecedenten table
        if(table.size() > 1){
            contentTable.addCell(createCell(new PdfPCell(table),1,PdfPCell.ALIGN_CENTER,PdfPCell.NO_BORDER));
            tranTable.addCell(createContentCell(contentTable));
        }
    }

}