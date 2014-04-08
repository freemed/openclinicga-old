package be.mxs.common.util.pdf.general.oc.examinations;

import com.itextpdf.text.pdf.PdfPCell;
import com.itextpdf.text.pdf.PdfPTable;

import be.mxs.common.util.pdf.general.PDFGeneralBasic;
import be.mxs.common.util.system.ScreenHelper;

public class PDFCNARSurgeryOperation extends PDFGeneralBasic {

    //--- ADD CONTENT -----------------------------------------------------------------------------
    protected void addContent(){
        try{
            if(transactionVO.getItems().size() >= minNumberOfItems){
                contentTable = new PdfPTable(1);
                table = new PdfPTable(5);
                
                // SURGICAL EXAMINATION
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_NURSE_COMPLAINTS");
                if(itemValue.length() > 0){
                    addItemRow(table,getTran("web","surgical.examination"),itemValue);
                }
                
                //*** URINE ***********************************************************************
                table.addCell(createTitleCell(getTran("web.occup","be.mxs.common.model.vo.healthrecord.IConstants.TRANSACTION_TYPE_URINE_EXAMINATION"),5));
                
                // ALBUMINE                
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_URINE_ALBUMINE");
                if(itemValue.length() > 0){
                    if(itemValue.equalsIgnoreCase("medwan.common.negative")){
                        itemValue = getTran("web.occup",itemValue);
                    }
                    else{
                        itemValue = itemValue+" mg/dl";
                    }
                    
                    addItemRow(table,getTran("web.occup","medwan.healthrecord.urine-exam.albumine"),itemValue);
                }
                
                // GLUCOSE             
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_URINE_GLUCOSE");
                if(itemValue.length() > 0){
                    if(itemValue.equalsIgnoreCase("medwan.common.negative")){
                        itemValue = getTran("web.occup",itemValue);
                    }
                    else{
                        itemValue = itemValue+" mg/dl";
                    }
                    
                    addItemRow(table,getTran("web.occup","medwan.healthrecord.urine-exam.glucose"),itemValue);
                }
                
                // BLOOD            
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_URINE_BLOOD");
                if(itemValue.length() > 0){
                    if(itemValue.equalsIgnoreCase("medwan.common.negative")){
                        itemValue = getTran("web.occup",itemValue);
                    }
                    else{
                        itemValue = itemValue+" ery/µl";
                    }
                    
                    addItemRow(table,getTran("web.occup","medwan.healthrecord.urine-exam.blood"),itemValue);
                }

                //*** BIOMETRY ********************************************************************
                table.addCell(createTitleCell(getTran("web.occup","be.mxs.common.model.vo.healthrecord.IConstants.TRANSACTION_TYPE_BIOMETRY"),5));
                
                // TEMPERATURE            
                itemValue = getItemValue(IConstants_PREFIX+"[GENERAL.ANAMNESE]ITEM_TYPE_TEMPERATURE");
                if(itemValue.length() > 0){
                    addItemRow(table,getTran("openclinic.chuk","temperature"),itemValue+" "+getTran("units","degreesCelcius"));
                }

                // WEIGHT             
                String sWeight = getItemValue(IConstants_PREFIX+"ITEM_TYPE_BIOMETRY_WEIGHT");
                if(sWeight.length() > 0){
                    addItemRow(table,getTran("web.occup","medwan.healthrecord.biometry.weight"),sWeight+" Kg");
                }
                
                // HEIGHT             
                String sHeight = getItemValue(IConstants_PREFIX+"ITEM_TYPE_BIOMETRY_HEIGHT");
                if(sHeight.length() > 0){
                    addItemRow(table,getTran("web.occup","medwan.healthrecord.biometry.length"),sHeight+" cm");
                }
                
                // BMI (calculated)             
                if(sWeight.length() > 0 && sHeight.length() > 0){
                    addItemRow(table,getTran("web.occup","medwan.healthrecord.biometry.bmi"),Double.toString(calculateBMI(Double.parseDouble(sWeight),Double.parseDouble(sHeight))));
                }
                
                //*** CARDIAL *********************************************************************
                table.addCell(createTitleCell(getTran("web.occup","medwan.healthrecord.anamnese.cardial"),5));
                
                // heart freq + heart rythm
                String sFreq  = getItemValue(ScreenHelper.ITEM_PREFIX+"ITEM_TYPE_CARDIAL_CLINICAL_EXAMINATION_HEARTH_FREQUENCY"),
                       sRythm = getItemValue(ScreenHelper.ITEM_PREFIX+"ITEM_TYPE_CARDIAL_CLINICAL_EXAMINATION_HEARTH_RYTMH");
                itemValue = "";
                if(sFreq.length() > 0 || sRythm.length() > 0){
                    if(sFreq.length() > 0) itemValue+= sFreq+" /"+getTran("units","minute");
                    if(sRythm.length() > 0) itemValue+= ", "+getTran("web.occup",sRythm).toLowerCase();
                    
                    if(itemValue.length() > 0){
                        addItemRow(table,getTran("web.occup","medwan.healthrecord.cardial.frequence-cardiaque"),itemValue);
                    }
                }

                //*** BLOOD PRESSURE **********************            
                String sBPSysR = getItemValue(ScreenHelper.ITEM_PREFIX+"ITEM_TYPE_CARDIAL_CLINICAL_EXAMINATION_SYSTOLIC_PRESSURE_RIGHT"),
                       sBPDiaR = getItemValue(ScreenHelper.ITEM_PREFIX+"ITEM_TYPE_CARDIAL_CLINICAL_EXAMINATION_DIASTOLIC_PRESSURE_RIGHT");
                String sBPSysL = getItemValue(ScreenHelper.ITEM_PREFIX+"ITEM_TYPE_CARDIAL_CLINICAL_EXAMINATION_SYSTOLIC_PRESSURE_LEFT"),
                       sBPDiaL = getItemValue(ScreenHelper.ITEM_PREFIX+"ITEM_TYPE_CARDIAL_CLINICAL_EXAMINATION_DIASTOLIC_PRESSURE_LEFT");
                
                if(sBPSysR.length() > 0 || sBPDiaR.length() > 0 || sBPSysL.length() > 0 || sBPDiaL.length() > 0){
                    table.addCell(createItemNameCell(getTran("web.occup","medwan.healthrecord.cardial.pression-arterielle"),1));
                    boolean titleAdded = false;
                    
	                // right arm
	                if(sBPSysR.length() > 0 || sBPDiaR.length() > 0){
	                    itemValue = sBPSysR+" / "+sBPDiaR+" mmHg";
		                titleAdded = true;
	                    
                        cell = createItemNameCell(getTran("web.occup","medwan.healthrecord.cardial.bras-droit"),1);
                    	cell.setHorizontalAlignment(PdfPCell.ALIGN_RIGHT);
	                    table.addCell(cell);
	                    
	                    table.addCell(createValueCell(itemValue));
	                }
	                 
	                // left arm            
	                if(sBPSysL.length() > 0 || sBPDiaL.length() > 0){
	                    itemValue = sBPSysL+" / "+sBPDiaL+" mmHg";
	                    
	                    if(!titleAdded){
	                        table.addCell(emptyCell(1));
	                        cell = createItemNameCell(getTran("web.occup","medwan.healthrecord.cardial.bras-gauche"),1);
	                    	cell.setHorizontalAlignment(PdfPCell.ALIGN_RIGHT);
		                    table.addCell(cell);
		                    titleAdded = true;
	                    }
	                    else{    
	                    	cell = createItemNameCell(getTran("web.occup","medwan.healthrecord.cardial.bras-gauche"),2);
	                    	cell.setHorizontalAlignment(PdfPCell.ALIGN_RIGHT);
		                    table.addCell(cell);
	                    }
	                    
	                    table.addCell(createValueCell(itemValue));
	                }
                }
                
                // add table
                if(table.size() > 0){
                    if(contentTable.size() > 0) contentTable.addCell(emptyCell());
                    contentTable.addCell(createCell(new PdfPCell(table),1,PdfPCell.ALIGN_CENTER,PdfPCell.BOX));
                    tranTable.addCell(new PdfPCell(contentTable));
                    addTransactionToDoc();
                }

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
    
    //--- CALCULATE BMI ---------------------------------------------------------------------------
    private double calculateBMI(double weight, double height){
        double bmi = (weight * 10000d) / (height * height);
        bmi = Math.round(bmi*10d)/10d;                 
        return bmi;
    }
}        