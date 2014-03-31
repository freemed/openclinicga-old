package be.mxs.common.util.pdf.general.oc.examinations;

import com.itextpdf.text.pdf.PdfPCell;
import com.itextpdf.text.pdf.PdfPTable;

import be.mxs.common.util.pdf.general.PDFGeneralBasic;

public class PDFRMHOutpatientFile extends PDFGeneralBasic {

    //--- ADD CONTENT -----------------------------------------------------------------------------
    protected void addContent(){
        try{
            if(transactionVO.getItems().size() >= minNumberOfItems){
            	addVitalSigns();               
                addTextFields();

                // diagnoses
                addDiagnosisEncoding();
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
    
    //--- ADD VITAL SIGNS -------------------------------------------------------------------------
    private void addVitalSigns(){
        contentTable = new PdfPTable(1);
        table = new PdfPTable(5);
        
        // title
        table.addCell(createTitleCell(getTran("Web.Occup","rmh.vital.signs"),5));
        
        // temperature
        itemValue = getItemValue(IConstants_PREFIX+"[GENERAL.ANAMNESE]ITEM_TYPE_TEMPERATURE");
        if(itemValue.length() > 0){
            addItemRow(table,getTran("openclinic.chuk","temperature"),(itemValue.length()>0?itemValue+" "+getTran("units","degrees"):""));
        }
        
        // height
        itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_BIOMETRY_HEIGHT");
        if(itemValue.length() > 0){
            addItemRow(table,getTran("Web.Occup","medwan.healthrecord.biometry.length"),(itemValue.length()>0?itemValue+"cm":""));
        }
        
        // hearth frequency
        itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_CARDIAL_CLINICAL_EXAMINATION_HEARTH_FREQUENCY");
        if(itemValue.length() > 0){
            addItemRow(table,getTran("Web.Occup","medwan.healthrecord.cardial.frequence-cardiaque"),(itemValue.length()>0?itemValue+"/min":""));
        }

        // blood pressure
        String sBP_SYS_R = getItemValue(IConstants_PREFIX+"ITEM_TYPE_CARDIAL_CLINICAL_EXAMINATION_SYSTOLIC_PRESSURE_RIGHT"),
        	   sBP_DIA_R = getItemValue(IConstants_PREFIX+"ITEM_TYPE_CARDIAL_CLINICAL_EXAMINATION_DIASTOLIC_PRESSURE_RIGHT");
        	   //sBP_SYS_L = getItemValue(IConstants_PREFIX+"ITEM_TYPE_CARDIAL_CLINICAL_EXAMINATION_SYSTOLIC_PRESSURE_LEFT"),
        	   //sBP_DIA_L = getItemValue(IConstants_PREFIX+"ITEM_TYPE_CARDIAL_CLINICAL_EXAMINATION_DIASTOLIC_PRESSURE_LEFT");
        if(sBP_SYS_R.length() > 0 || sBP_DIA_R.length() > 0 /*|| sBP_SYS_L.length() > 0 || sBP_DIA_L.length() > 0*/){
        	itemValue = sBP_SYS_R+" / "+sBP_DIA_R+"mmHg";
        	//itemValue = sBP_SYS_L+" / "+sBP_DIA_L+"mmHg";
            addItemRow(table,getTran("Web.Occup","medwan.healthrecord.cardial.pression-arterielle"),itemValue);
        }

        
        // respiratory frequency
        itemValue = getItemValue(IConstants_PREFIX+"[GENERAL.ANAMNESE]ITEM_TYPE_RESPIRATORY_FRENQUENCY");
        if(itemValue.length() > 0){
            addItemRow(table,getTran("openclinic.chuk","respiratory.frequency"),(itemValue.length()>0?itemValue+"/min":""));
        }
        
        // weight
        itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_BIOMETRY_WEIGHT");
        if(itemValue.length() > 0){
            addItemRow(table,getTran("Web.Occup","medwan.healthrecord.biometry.weight"),(itemValue.length()>0?itemValue+"kg":""));
        }
	    
        // add table
        if(table.size() > 0){
            if(contentTable.size() > 0) contentTable.addCell(emptyCell());
            contentTable.addCell(createCell(new PdfPCell(table),1,PdfPCell.ALIGN_CENTER,PdfPCell.BOX));
            tranTable.addCell(createContentCell(contentTable));
            addTransactionToDoc();
        }
    }
    
    //--- ADD TEXT FIELDS -------------------------------------------------------------------------
    private void addTextFields(){
        contentTable = new PdfPTable(1);
        table = new PdfPTable(5);
        
        // rmh.clinical.history
        itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_RMH_CLINICALHISTORY");
        if(itemValue.length() > 0){
            addItemRow(table,getTran("Web.Occup","rmh.clinical.history"),itemValue);
        }

        // rmh.physical.examination
        itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_RMH_PHYSICALEXAM");
        if(itemValue.length() > 0){
            addItemRow(table,getTran("Web.Occup","rmh.physical.examination"),itemValue);
        }
        
        // rmh.differential.diagnosis
        itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_RMH_DIFFERENTIALDIAGNOSIS");
        if(itemValue.length() > 0){
            addItemRow(table,getTran("Web.Occup","rmh.differential.diagnosis"),itemValue);
        }
        
        // rmh.clinical.summary
        itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_RMH_CLINICALSUMMARY");
        if(itemValue.length() > 0){
            addItemRow(table,getTran("Web.Occup","rmh.clinical.summary"),itemValue);
        }

        // rmh.investigations
        itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_RMH_INVESTIGATIONS");
        if(itemValue.length() > 0){
            addItemRow(table,getTran("Web.Occup","rmh.investigations"),itemValue);
        }
        
        // rmh.treatment
        itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_RMH_TREATMENT");
        if(itemValue.length() > 0){
            addItemRow(table,getTran("web.Occup","rmh.treatment"),itemValue);
        }
        
        // rmh.final.diagnosis
        itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_RMH_FINALDIAGNOSIS");
        if(itemValue.length() > 0){
            addItemRow(table,getTran("Web.Occup","rmh.final.diagnosis"),itemValue);
        }
        
        // rmh.followup
        itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_RMH_FOLLOWUP");
        if(itemValue.length() > 0){
            addItemRow(table,getTran("Web.Occup","rmh.followup"),itemValue);
        }

        // add table
        if(table.size() > 0){
            if(contentTable.size() > 0) contentTable.addCell(emptyCell());
            contentTable.addCell(createCell(new PdfPCell(table),1,PdfPCell.ALIGN_CENTER,PdfPCell.BOX));
            tranTable.addCell(new PdfPCell(contentTable));
            addTransactionToDoc();
        }
    }

}