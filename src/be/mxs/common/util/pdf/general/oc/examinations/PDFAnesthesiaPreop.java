package be.mxs.common.util.pdf.general.oc.examinations;

import be.mxs.common.util.pdf.general.PDFGeneralBasic;
import com.itextpdf.text.pdf.PdfPTable;
import com.itextpdf.text.pdf.PdfPCell;


/**
 * User: ssm
 * Date: 13-jul-2007
 */
public class PDFAnesthesiaPreop extends PDFGeneralBasic {

    //--- ADD CONTENT -----------------------------------------------------------------------------
    protected void addContent(){
        try{
            if(transactionVO.getItems().size() >= minNumberOfItems){
                addVaria();
                addAntecedents();
                addClinical();
                addParaclinicExaminations();
                addTreatment();
                addConclusion();
                addTransactionToDoc();
                
                // diagnoses
                addDiagnosisEncoding();                
                addTransactionToDoc();
            }
        }
        catch(Exception e){
            e.printStackTrace();
        }
    }


    //### PRIVATE METHODS #########################################################################

    //--- ADD VARIA -------------------------------------------------------------------------------
    private void addVaria(){
        contentTable = new PdfPTable(1);
        table = new PdfPTable(5);

        // indication
        itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_ANESTHESIA_INDICATION");
        if(itemValue.length() > 0){
            addItemRow(table,getTran("openclinic.chuk","anesthesia.indication"),getTran("openclinic.chuk",itemValue).toLowerCase());
        }

        // intervention
        itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_ANESTHESIA_INTERVENTION");
        if(itemValue.length() > 0){
            addItemRow(table,getTran("openclinic.chuk","intervention"),itemValue);
        }

        // add table to transaction
        if(table.size() > 0){
            if(contentTable.size() > 0) contentTable.addCell(emptyCell());
            contentTable.addCell(createCell(new PdfPCell(table),1,PdfPCell.ALIGN_CENTER,PdfPCell.NO_BORDER));
            tranTable.addCell(createContentCell(contentTable));
        }
    }

    //--- ADD ANTECEDENTS -------------------------------------------------------------------------
    private void addAntecedents(){
        contentTable = new PdfPTable(1);
        table = new PdfPTable(5);

        // title
        table.addCell(createTitleCell(getTran("openclinic.chuk","patient.antecedents"),5));

        // antecedents
        String antecedents = "";
        itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_ANESTHESIA_TOBACCO");
        if(itemValue.equalsIgnoreCase("medwan.common.true")){
            antecedents+= getTran("openclinic.chuk","tobacco")+", ";
        }

        itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_ANESTHESIA_ASTHMA");
        if(itemValue.equalsIgnoreCase("medwan.common.true")){
            antecedents+= getTran("openclinic.chuk","asthma")+", ";
        }

        itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_ANESTHESIA_DIABETES");
        if(itemValue.equalsIgnoreCase("medwan.common.true")){
            antecedents+= getTran("openclinic.chuk","diabetes")+", ";
        }

        itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_ANESTHESIA_HEPATITIS");
        if(itemValue.equalsIgnoreCase("medwan.common.true")){
            antecedents+= getTran("openclinic.chuk","hepatitis")+", ";
        }

        itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_ANESTHESIA_ALLERGY");
        if(itemValue.equalsIgnoreCase("medwan.common.true")){
            antecedents+= getTran("openclinic.chuk","allergy")+", ";
        }

        itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_ANESTHESIA_CARDIOPATHY");
        if(itemValue.equalsIgnoreCase("medwan.common.true")){
            antecedents+= getTran("openclinic.chuk","cardiopathy")+", ";
        }

        itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_ANESTHESIA_HYPERTENSION");
        if(itemValue.equalsIgnoreCase("medwan.common.true")){
            antecedents+= getTran("openclinic.chuk","hypertension")+", ";
        }

        itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_ANESTHESIA_OTHERA");
        if(itemValue.equalsIgnoreCase("medwan.common.true")){
            antecedents+= getTran("openclinic.chuk","other")+", ";
        }

        if(antecedents.length() > 0){
            // remove last comma
            if(antecedents.indexOf(",") > -1){
                antecedents = antecedents.substring(0,antecedents.length()-2);
            }

            addItemRow(table,getTran("openclinic.chuk","patient.antecedents"),antecedents.toLowerCase());
        }

        // previous_anesthesia
        itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_ANESTHESIA_PREVIOUS_ANESTHESIA");
        if(itemValue.length() > 0){
            addItemRow(table,getTran("openclinic.chuk","previous_anesthesia"),itemValue);
        }

        // neurologic_problem
        itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_ANESTHESIA_NEUROLOGIC_PROBLEM");
        if(itemValue.length() > 0){
            addItemRow(table,getTran("openclinic.chuk","neurologic_problem"),itemValue);
        }

        // description
        itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_ANESTHESIA_COMMENTA");
        if(itemValue.length() > 0){
            addItemRow(table,getTran("openclinic.chuk","comment"),itemValue);
        }

        // add table to transaction
        if(table.size() > 0){
            if(contentTable.size() > 0) contentTable.addCell(emptyCell());
            contentTable.addCell(createCell(new PdfPCell(table),1,PdfPCell.ALIGN_CENTER,PdfPCell.NO_BORDER));
            tranTable.addCell(createContentCell(contentTable));
            addTransactionToDoc();
        }
    }

    //--- ADD CLINICAL ----------------------------------------------------------------------------
    private void addClinical(){
        contentTable = new PdfPTable(1);
        table = new PdfPTable(5);

        // title
        table.addCell(createTitleCell(getTran("openclinic.chuk","patient.clinical"),5));

        // general condition
        itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_ANESTHESIA_GENERAL_CONDITION");
        if(itemValue.length() > 0){
            addItemRow(table,getTran("openclinic.chuk","general.condition"),itemValue);
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

        // conjunctiva
        itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_ANESTHESIA_CONJUNCTIVA");
        if(itemValue.length() > 0){
            addItemRow(table,getTran("openclinic.chuk","conjunctiva"),itemValue);
        }

        // oedema legs
        itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_ANESTHESIA_OEDEMA_LEGS");
        if(itemValue.length() > 0){
            addItemRow(table,getTran("openclinic.chuk","oedema.legs"),itemValue);
        }

        // dyspnoe
        itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_ANESTHESIA_DYSPNOE");
        if(itemValue.length() > 0){
            addItemRow(table,getTran("openclinic.chuk","dyspnoe"),itemValue);
        }

        // add table to transaction
        if(table.size() > 0){
            if(contentTable.size() > 0) contentTable.addCell(emptyCell());
            contentTable.addCell(createCell(new PdfPCell(table),1,PdfPCell.ALIGN_CENTER,PdfPCell.NO_BORDER));
            tranTable.addCell(createContentCell(contentTable));
            addTransactionToDoc();
        }
    }

    //--- ADD PARACLINIC EXAMINATIONS -------------------------------------------------------------
    private void addParaclinicExaminations(){
        contentTable = new PdfPTable(1);
        table = new PdfPTable(5);

        // title
        table.addCell(createTitleCell(getTran("openclinic.chuk","paraclinic.examinations"),5));

        //*** components ***
        PdfPTable componentsTable = new PdfPTable(5);

        componentsTable.addCell(createValueCell(getItemValue(IConstants_PREFIX+"ITEM_TYPE_ANESTHESIA_HB")+" "+getTran("openclinic.chuk","anesthesia.hb"),1));
        componentsTable.addCell(createValueCell(getItemValue(IConstants_PREFIX+"ITEM_TYPE_ANESTHESIA_NA")+" "+getTran("openclinic.chuk","anesthesia.na"),1));
        componentsTable.addCell(createValueCell(getItemValue(IConstants_PREFIX+"ITEM_TYPE_ANESTHESIA_K")+" "+getTran("openclinic.chuk","anesthesia.k"),1));
        componentsTable.addCell(createValueCell(getItemValue(IConstants_PREFIX+"ITEM_TYPE_ANESTHESIA_CA")+" "+getTran("openclinic.chuk","anesthesia.ca"),1));
        componentsTable.addCell(createValueCell(getItemValue(IConstants_PREFIX+"ITEM_TYPE_ANESTHESIA_GLUC")+" "+getTran("openclinic.chuk","anesthesia.glucose"),1));

        componentsTable.addCell(createValueCell(getItemValue(IConstants_PREFIX+"ITEM_TYPE_ANESTHESIA_UREUM")+" "+getTran("openclinic.chuk","anesthesia.ureum"),1));
        componentsTable.addCell(createValueCell(getItemValue(IConstants_PREFIX+"ITEM_TYPE_ANESTHESIA_CREATININE")+" "+getTran("openclinic.chuk","anesthesia.creatinine"),1));
        componentsTable.addCell(createValueCell(getItemValue(IConstants_PREFIX+"ITEM_TYPE_ANESTHESIA_PROTIDES")+" "+getTran("openclinic.chuk","anesthesia.protides"),1));
        componentsTable.addCell(createValueCell(getItemValue(IConstants_PREFIX+"ITEM_TYPE_ANESTHESIA_SGOT")+" "+getTran("openclinic.chuk","anesthesia.sgot"),1));
        componentsTable.addCell(createValueCell(getItemValue(IConstants_PREFIX+"ITEM_TYPE_ANESTHESIA_SGPT")+" "+getTran("openclinic.chuk","anesthesia.sgpt"),1));

        componentsTable.addCell(createValueCell(getItemValue(IConstants_PREFIX+"ITEM_TYPE_ANESTHESIA_FIBRINOGENE")+" "+getTran("openclinic.chuk","anesthesia.sgpt"),1));
        componentsTable.addCell(createValueCell(getItemValue(IConstants_PREFIX+"ITEM_TYPE_ANESTHESIA_PLATELETS")+" "+getTran("openclinic.chuk","anesthesia.platelets"),1));
        componentsTable.addCell(createValueCell(getItemValue(IConstants_PREFIX+"ITEM_TYPE_ANESTHESIA_TCA")+" "+getTran("openclinic.chuk","anesthesia.tca"),1));
        componentsTable.addCell(emptyCell(2));

        // add to components table
        cell = createCell(new PdfPCell(componentsTable),5,PdfPCell.ALIGN_CENTER,PdfPCell.BOX);
        cell.setPadding(3);
        cell.setColspan(5);
        table.addCell(cell);

        // xray.lungs
        itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_ANESTHESIA_XRAY_LUNGS");
        if(itemValue.length() > 0){
            addItemRow(table,getTran("openclinic.chuk","xray.lungs"),itemValue);
        }

        // ecg
        itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_ANESTHESIA_ECG");
        if(itemValue.length() > 0){
            addItemRow(table,getTran("openclinic.chuk","ecg"),itemValue);
        }

        // eyefundus
        itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_ANESTHESIA_EYE_FUNDUS");
        if(itemValue.length() > 0){
            addItemRow(table,getTran("openclinic.chuk","eyefundus"),itemValue);
        }

        // add table to transaction
        if(table.size() > 0){
            if(contentTable.size() > 0) contentTable.addCell(emptyCell());
            contentTable.addCell(createCell(new PdfPCell(table),1,PdfPCell.ALIGN_CENTER,PdfPCell.NO_BORDER));
            tranTable.addCell(createContentCell(contentTable));
            addTransactionToDoc();
        }  
    }

    //--- ADD TREATMENT ---------------------------------------------------------------------------
    private void addTreatment(){
        contentTable = new PdfPTable(1);
        table = new PdfPTable(5);

        // title
        table.addCell(createTitleCell(getTran("openclinic.chuk","treatment"),5));

        // current.treatment
        itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_ANESTHESIA_CURRENT_TREATMENT");
        if(itemValue.length() > 0){
            addItemRow(table,getTran("openclinic.chuk","current.treatment"),itemValue);
        }

        // add table to transaction
        if(table.size() > 0){
            if(contentTable.size() > 0) contentTable.addCell(emptyCell());
            contentTable.addCell(createCell(new PdfPCell(table),1,PdfPCell.ALIGN_CENTER,PdfPCell.NO_BORDER));
            tranTable.addCell(createContentCell(contentTable));
        }
    }

    //--- ADD CONCLUSION --------------------------------------------------------------------------
    private void addConclusion(){
        contentTable = new PdfPTable(1);
        table = new PdfPTable(5);

        // title
        table.addCell(createTitleCell(getTran("openclinic.chuk","conclusion"),5));

        // intubation
        itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_ANESTHESIA_INTUBATION");
        if(itemValue.length() > 0){
            addItemRow(table,getTran("openclinic.chuk","intubation"),itemValue);
        }

        // anesthesia.class
        itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_ANESTHESIA_CLASS");
        if(itemValue.length() > 0){
            addItemRow(table,getTran("openclinic.chuk","anesthesia.class"),getTran("openclinic.chuk",itemValue).toLowerCase());
        }

        // anesthesia.protocol
        itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_ANESTHESIA_PROTOCOLE");
        if(itemValue.length() > 0){
            addItemRow(table,getTran("openclinic.chuk","anesthesia.protocol"),getTran("openclinic.chuk",itemValue).toLowerCase());
        }

        // sober since
        String sDate = getItemValue(IConstants_PREFIX+"ITEM_TYPE_ANESTHESIA_SOBER_DATE"),
               sHour = getItemValue(IConstants_PREFIX+"ITEM_TYPE_ANESTHESIA_SOBER_HOUR");

        if(sDate.length() > 0 || sHour.length() > 0){
            itemValue = sDate+" "+sHour;
            addItemRow(table,getTran("openclinic.chuk","sober"),itemValue);
        }

        // premedication
        itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_ANESTHESIA_PREMEDICATION");
        if(itemValue.length() > 0){
            addItemRow(table,getTran("openclinic.chuk","premedication"),itemValue);
        }

        // add table to transaction
        if(table.size() > 0){
            if(contentTable.size() > 0) contentTable.addCell(emptyCell());
            contentTable.addCell(createCell(new PdfPCell(table),1,PdfPCell.ALIGN_CENTER,PdfPCell.NO_BORDER));
            tranTable.addCell(createContentCell(contentTable));
        }
    }

}

