package be.mxs.common.util.pdf.general.oc.examinations;

import be.mxs.common.util.pdf.general.PDFGeneralBasic;
import be.mxs.common.util.db.MedwanQuery;
import be.mxs.common.util.system.ScreenHelper;
import be.mxs.common.model.vo.healthrecord.ItemVO;
import be.mxs.common.model.vo.healthrecord.TransactionVO;
import be.openclinic.medical.Prescription;
import be.openclinic.medical.Problem;
import be.openclinic.pharmacy.Product;
import com.itextpdf.text.pdf.PdfPTable;
import com.itextpdf.text.pdf.PdfPCell;
import com.itextpdf.text.*;
import com.itextpdf.text.Font;

import java.util.Vector;
import java.util.Iterator;
import java.sql.SQLException;
import java.text.DecimalFormat;
import java.text.SimpleDateFormat;

/**
 * User: ssm
 * Date: 18-jul-2007
 */
public class PDFPediatryConsultation extends PDFGeneralBasic {

    //--- ADD CONTENT -----------------------------------------------------------------------------
    protected void addContent(){
        try{
            if(transactionVO.getItems().size() >= minNumberOfItems){
                addBiometry();
                addSummary();
                
                addFamilialAntecedents();
                addPersonalAntecedents();
            }
        }
        catch(Exception e){
            e.printStackTrace();
        }
    }


    //### PRIVATE METHODS #########################################################################

    //--- ADD BIOMETRY ----------------------------------------------------------------------------
    private void addBiometry(){
        contentTable = new PdfPTable(1);

        TransactionVO tran = MedwanQuery.getInstance().getLastTransactionVO(Integer.parseInt(patient.personid),IConstants_PREFIX+"TRANSACTION_TYPE_BIOMETRY");
        if(tran!=null){
            tran = MedwanQuery.getInstance().loadTransaction(tran.getServerId(),tran.getTransactionId().intValue());

            String sBiometry = getItemSeriesValue(tran,IConstants_PREFIX+"ITEM_TYPE_BIOMETRY_PARAMETER");
            String sDate = "", sWeight = "", sHeight = "", sSkull = "", sArm = "", sFood = "";
            if(sBiometry.indexOf("£") > -1) {
                StringBuffer sTmpBio = new StringBuffer(sBiometry);
                String sTmpDate, sTmpWeight, sTmpHeight, sTmpSkull, sTmpArm, sTmpFood;

                while (sTmpBio.indexOf("$") > -1) {
                    sTmpDate = "";
                    if(sTmpBio.toString().toLowerCase().indexOf("£") > -1) {
                        sTmpDate = sTmpBio.substring(0, sTmpBio.toString().toLowerCase().indexOf("£"));
                        sTmpDate = ScreenHelper.convertDate(sTmpDate);
                        sTmpBio = new StringBuffer(sTmpBio.substring(sTmpBio.toString().toLowerCase().indexOf("£") + 1));
                    }

                    sTmpWeight = "";
                    if(sTmpBio.toString().toLowerCase().indexOf("£") > -1) {
                        sTmpWeight = sTmpBio.substring(0, sTmpBio.toString().toLowerCase().indexOf("£"));
                        sTmpBio = new StringBuffer(sTmpBio.substring(sTmpBio.toString().toLowerCase().indexOf("£") + 1));
                    }

                    sTmpHeight = "";
                    if(sTmpBio.toString().toLowerCase().indexOf("£") > -1) {
                        sTmpHeight = sTmpBio.substring(0, sTmpBio.toString().toLowerCase().indexOf("£"));
                        sTmpBio = new StringBuffer(sTmpBio.substring(sTmpBio.toString().toLowerCase().indexOf("£") + 1));
                    }

                    sTmpSkull = "";
                    if(sTmpBio.toString().toLowerCase().indexOf("£") > -1) {
                        sTmpSkull = sTmpBio.substring(0, sTmpBio.toString().toLowerCase().indexOf("£"));
                        sTmpBio = new StringBuffer(sTmpBio.substring(sTmpBio.toString().toLowerCase().indexOf("£") + 1));
                    }

                    sTmpArm = "";
                    if(sTmpBio.toString().toLowerCase().indexOf("£") > -1) {
                        sTmpArm = sTmpBio.substring(0, sTmpBio.toString().toLowerCase().indexOf("£"));
                        sTmpBio = new StringBuffer(sTmpBio.substring(sTmpBio.toString().toLowerCase().indexOf("£") + 1));
                    }

                    sTmpFood = "";
                    if(sTmpBio.toString().toLowerCase().indexOf("$") > -1) {
                        sTmpFood = sTmpBio.substring(0, sTmpBio.toString().toLowerCase().indexOf("$"));
                        sTmpBio = new StringBuffer(sTmpBio.substring(sTmpBio.toString().toLowerCase().indexOf("$") + 1));
                    }

                    if(sDate.length() > 0) {
                        if(ScreenHelper.getSQLDate(sDate).before(ScreenHelper.getSQLDate(sTmpDate))) {
                            sDate = sTmpDate;
                            sWeight = sTmpWeight;
                            sHeight = sTmpHeight;
                            sSkull = sTmpSkull;
                            sArm = sTmpArm;
                            sFood = sTmpFood;
                        }
                    }
                    else {
                        sDate = sTmpDate;
                        sWeight = sTmpWeight;
                        sHeight = sTmpHeight;
                        sSkull = sTmpSkull;
                        sArm = sTmpArm;
                        sFood = sTmpFood;
                    }
                }
            }

            if(sDate.length() > 0 || sWeight.length() > 0 || sHeight.length() > 0 || sSkull.length() > 0 || sArm.length() > 0 || sFood.length() > 0){
                // display values in one row
                PdfPTable bioTable = new PdfPTable(7);

                // header
                bioTable.addCell(createHeaderCell(getTran("Web.Occup","medwan.common.date"),1));
                bioTable.addCell(createHeaderCell(getTran("Web.Occup","medwan.healthrecord.biometry.weight"),1));
                bioTable.addCell(createHeaderCell(getTran("Web.Occup","medwan.healthrecord.biometry.length"),1));
                bioTable.addCell(createHeaderCell(getTran("openclinic.chuk","skull"),1));
                bioTable.addCell(createHeaderCell(getTran("openclinic.chuk","arm.circumference"),1));
                bioTable.addCell(createHeaderCell(getTran("openclinic.chuk","food"),2));

                // data
                bioTable.addCell(createValueCell(sDate,1));
                bioTable.addCell(createValueCell(sWeight,1));
                bioTable.addCell(createValueCell(sHeight,1));
                bioTable.addCell(createValueCell(sSkull,1));
                bioTable.addCell(createValueCell(sArm,1));
                bioTable.addCell(createValueCell(getTran("biometry_food",sFood),2));

                // add transaction to doc
                if(bioTable.size() > 0){
                    if(contentTable.size() > 0) contentTable.addCell(emptyCell());
                    contentTable.addCell(createCell(new PdfPCell(bioTable),1,PdfPCell.ALIGN_CENTER,PdfPCell.BOX));
                    tranTable.addCell(createContentCell(contentTable));
                }
            }
        }
    }

    //--- ADD SUMMARY -----------------------------------------------------------------------------
    private void addSummary(){
        addAnamnese();
        addClinicalExaminations();
        addProblemList();
        addActivePrescriptions();
    }

    //--- ADD ANAMNESE ----------------------------------------------------------------------------
    private void addAnamnese(){
        contentTable = new PdfPTable(1);
        table = new PdfPTable(5);

        // title
        table.addCell(createTitleCell(getTran("web.occup","medwan.healthrecord.general"),5));

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

        // frequence-cardiaque
        String heartFreq  = getItemValue(IConstants_PREFIX+"ITEM_TYPE_CARDIAL_CLINICAL_EXAMINATION_HEARTH_FREQUENCY"),
               heartRythm = getItemValue(IConstants_PREFIX+"ITEM_TYPE_CARDIAL_CLINICAL_EXAMINATION_HEARTH_RYTMH");

        if(heartFreq.length() > 0 || heartRythm.length() > 0){
            if(heartFreq.length() > 0){
                itemValue = heartFreq+" /"+getTran("units","minute");
            }

            if(heartRythm.length() > 0){
                itemValue+= " ("+getTran("web.occup",heartRythm).toLowerCase()+")";
            }

            if(itemValue.length() > 0){
                addItemRow(table,getTran("web.occup","medwan.healthrecord.cardial.frequence-cardiaque"),itemValue);
            }
        }

        //*** bloodpressure ***
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

        // temperature
        itemValue = getItemValue(IConstants_PREFIX+"[GENERAL.ANAMNESE]ITEM_TYPE_TEMPERATURE");
        if(itemValue.length() > 0){
            addItemRow(table,getTran("openclinic.chuk","temperature"),itemValue+" "+getTran("units","degreesCelcius"));
        }

        // respiratory.frequency
        itemValue = getItemValue(IConstants_PREFIX+"[GENERAL.ANAMNESE]ITEM_TYPE_RESPIRATORY_FRENQUENCY");
        if(itemValue.length() > 0){
            addItemRow(table,getTran("openclinic.chuk","respiratory.frequency"),itemValue+" /"+getTran("units","minute"));
        }

        // psychomotoric.development
        itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_PSYCHOMOTORIC");
        if(itemValue.length() > 0){
            addItemRow(table,getTran("web.occup","medwan.healthrecord.psychomotoric.development"),getTran("Web.Occup",itemValue));
        }

        // academy
        itemValue = getItemSeriesValue(IConstants_PREFIX+"[GENERAL.ANAMNESE]ITEM_TYPE_ACADEMY");
        if(itemValue.length() > 0){
            addItemRow(table,getTran("openclinic.chuk","academy"),itemValue);
        }

        // remark
        itemValue = getItemValue(IConstants_PREFIX+"[GENERAL.ANAMNESE]ITEM_TYPE_PSYCHOMOTORIC_REMARK");
        if(itemValue.length() > 0){
            addItemRow(table,getTran("openclinic.chuk","remark"),itemValue);
        }

        // add transaction to doc
        if(table.size() > 0){
            if(contentTable.size() > 0) contentTable.addCell(emptyCell());
            contentTable.addCell(createCell(new PdfPCell(table),1,PdfPCell.ALIGN_CENTER,PdfPCell.BOX));
            tranTable.addCell(createContentCell(contentTable));
            addTransactionToDoc();
        }
    }
    
    //--- ADD CLINICAL EXAMINATIONS ---------------------------------------------------------------
    private void addClinicalExaminations(){
        contentTable = new PdfPTable(1);
        table = new PdfPTable(5);

        //*** DIAGNOSTICS ***
        PdfPTable diagnosticsTable = new PdfPTable(1);

        try{
            Iterator items = transactionVO.getItems().iterator();
            String codeTran;
            ItemVO item;

            while(items.hasNext()){
                item = (ItemVO)items.next();

                // ICPC
                if(item.getType().startsWith("ICPCCode")){
                    codeTran = MedwanQuery.getInstance().getCodeTran(item.getType().trim(),sPrintLanguage);
                    diagnosticsTable.addCell(createValueCell(item.getType().replaceAll("ICPCCode","")+" "+codeTran+" "+item.getValue().trim()));
                }
                // ICD10
                else if(item.getType().startsWith("ICD10Code")){
                    codeTran = MedwanQuery.getInstance().getCodeTran(item.getType().trim(),sPrintLanguage);
                    diagnosticsTable.addCell(createValueCell(item.getType().replaceAll("ICD10Code","")+" "+codeTran+" "+item.getValue().trim()));
                }
            }
        }
        catch(Exception e){
            e.printStackTrace();
        }

        // add diagnostics table
        if(diagnosticsTable.size() > 0){
            table.addCell(createTitleCell(getTran("openclinic.chuk","diagnostic")+" "+getTran("Web.Occup","ICPC-2")+" / "+getTran("Web.Occup","ICD-10"),5));
            table.addCell(createCell(new PdfPCell(diagnosticsTable),5,PdfPCell.ALIGN_CENTER,PdfPCell.NO_BORDER));
        }

        // add transaction to doc
        if(table.size() > 0){
            if(contentTable.size() > 0) contentTable.addCell(emptyCell());
            contentTable.addCell(createCell(new PdfPCell(table),1,PdfPCell.ALIGN_CENTER,PdfPCell.BOX));
            tranTable.addCell(createContentCell(contentTable));
            addTransactionToDoc();
        }
    }

    //--- ADD FAMILIAL ANTECEDENTS ----------------------------------------------------------------
    private void addFamilialAntecedents(){
        contentTable = new PdfPTable(1);
        table = new PdfPTable(5);
        PdfPTable famiTable = new PdfPTable(8);

        String sFami = getItemSeriesValue(IConstants_PREFIX+"ITEM_TYPE_CE_FAMILIALE_ANTECEDENTEN");
        if(sFami.indexOf("$")>0){
            String sTmpFami = sFami;
            String sTmpFamiDate, sTmpFamiDescr, sTmpFamiVerwantschap;

            while (sTmpFami.toLowerCase().indexOf("$")>-1) {
                sTmpFamiDate = "";
                if(sTmpFami.toLowerCase().indexOf("£")>-1){
                    sTmpFamiDate = sTmpFami.substring(0,sTmpFami.toLowerCase().indexOf("£"));
                    sTmpFami = sTmpFami.substring(sTmpFami.toLowerCase().indexOf("£")+1);
                }

                sTmpFamiDescr = "";
                if(sTmpFami.toLowerCase().indexOf("£")>-1){
                    sTmpFamiDescr = sTmpFami.substring(0,sTmpFami.toLowerCase().indexOf("£"));
                    sTmpFami = sTmpFami.substring(sTmpFami.toLowerCase().indexOf("£")+1);
                }

                sTmpFamiVerwantschap = "";
                if(sTmpFami.toLowerCase().indexOf("$")>-1){
                    sTmpFamiVerwantschap = sTmpFami.substring(0,sTmpFami.toLowerCase().indexOf("$"));
                    sTmpFami = sTmpFami.substring(sTmpFami.toLowerCase().indexOf("$")+1);
                }

                famiTable = addFamiToPDFTable(famiTable,sTmpFamiDate,sTmpFamiDescr,sTmpFamiVerwantschap);
            }

            if(famiTable.size() > 0){
                table.addCell(createTitleCell(getTran("Web.Occup","Familial_Antecedents"),5));
                table.addCell(createCell(new PdfPCell(famiTable),5,PdfPCell.ALIGN_CENTER,PdfPCell.NO_BORDER));
            }
        }

        // COMMENT
        itemValue = getItemSeriesValue(IConstants_PREFIX+"ITEM_TYPE_CE_FAMILIAAL_COMMENT");
        if(itemValue.length() > 0){
            table.addCell(createBorderlessCell(5));            
            addItemRow(table,getTran("web","comment"),itemValue);
        }

        // add transaction to doc
        if(table.size() > 0){
            if(contentTable.size() > 0) contentTable.addCell(emptyCell());
            contentTable.addCell(createCell(new PdfPCell(table),1,PdfPCell.ALIGN_CENTER,PdfPCell.BOX));
            tranTable.addCell(createContentCell(contentTable));
            addTransactionToDoc();
        }
    }

    //--- ADD FAMI TO PDF TABLE -------------------------------------------------------------------
    private PdfPTable addFamiToPDFTable(PdfPTable pdfTable, String sDate, String sDescr, String sVerwantschap){

        // add header if no header yet
        if(pdfTable.size() == 0){
            pdfTable.addCell(createHeaderCell(getTran("Web.Occup","medwan.common.date"),1));
            pdfTable.addCell(createHeaderCell(getTran("Web.Occup","medwan.common.description"),5));
            pdfTable.addCell(createHeaderCell(getTran("Web.Occup","verwantschap"),2));
        }

        pdfTable.addCell(createValueCell(sDate,1));
        pdfTable.addCell(createValueCell(sDescr,5));
        pdfTable.addCell(createValueCell(sVerwantschap,2));

        return pdfTable;
    }

    //--- ADD PERSONAL ANTECEDENTS ----------------------------------------------------------------
    private void addPersonalAntecedents() throws Exception {
        contentTable = new PdfPTable(1);
        table = new PdfPTable(8);

        // title
        table.addCell(createTitleCell(getTran("personal_antecedents"),8));

        //*** comment *********************************************************
        String sComment = getItemSeriesValue(IConstants_PREFIX+"ITEM_TYPE_CE_PERSONAL_COMMENT");
        if(sComment.length() > 0){
            table.addCell(createItemNameCell(getTran("medwan.common.comment"),3));
            table.addCell(createValueCell(sComment,5));
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

        //*** heelkundige antecedenten *************************************************************
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

        //*** Letsels met %BI **********************************************************************
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
                    sTmpLetselsDate = "";
                    sTmpLetselsDescr = "";
                    sTmpLetselsBI = "";

                    // date
                    if(sTmpLetsels.indexOf("£")>-1){
                        sTmpLetselsDate = sTmpLetsels.substring(0,sTmpLetsels.indexOf("£"));
                        sTmpLetsels = sTmpLetsels.substring(sTmpLetsels.indexOf("£")+1);
                    }

                    // description
                    if(sTmpLetsels.indexOf("£")>-1){
                        sTmpLetselsDescr = sTmpLetsels.substring(0,sTmpLetsels.indexOf("£"));
                        sTmpLetsels = sTmpLetsels.substring(sTmpLetsels.indexOf("£")+1);
                    }

                    // BI
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

        // add transaction to doc
        addTransactionToDoc();
    }
    
}

