package be.mxs.common.util.pdf.general.oc.examinations;

import com.itextpdf.text.pdf.PdfPTable;
import com.itextpdf.text.pdf.PdfPCell;
import be.mxs.common.util.pdf.general.PDFGeneralBasic;

public class PDFTracnetSuiviClinique extends PDFGeneralBasic {

    //--- ADD CONTENT ------------------------------------------------------------------------------
    protected void addContent(){
        try{
            if(transactionVO.getItems().size() >= minNumberOfItems){  
                table = new PdfPTable(5);     
                                    
                // weight
                itemValue = getItemSeriesValue(IConstants_PREFIX+"ITEM_TYPE_BIOMETRY_WEIGHT");
                if(itemValue.length() > 0){
                    addItemRow(table,getTran("openclinic.chuk","weigth"),itemValue+" Kg");
                }

                // height
                itemValue = getItemSeriesValue(IConstants_PREFIX+"ITEM_TYPE_BIOMETRY_HEIGHT");
                if(itemValue.length() > 0){
                    addItemRow(table,getTran("openclinic.chuk","heigth"),itemValue+" cm");
                }
                
                // BMI
                itemValue = getItemSeriesValue(IConstants_PREFIX+"ITEM_TYPE_TRACNET_SUIVI_CLINIQUE_BMI");
                if(itemValue.length() > 0){
                    addItemRow(table,getTran("openclinic.chuk","bmi"),itemValue);
                }

                // TBC
                itemValue = getItemSeriesValue(IConstants_PREFIX+"ITEM_TYPE_TRACNET_SUIVI_CLINIQUE_SCREENING_TBC");
                if(itemValue.length() > 0){
                	     if(itemValue.equals("+")) itemValue = getTran("web","positive");
                    else if(itemValue.equals("-")) itemValue = getTran("web","negative");
                	
                    addItemRow(table,getTran("openclinic.chuk","tracnet.suivi.clinique.screening.tbc"),itemValue);
                }
                
                // anamnese                
                itemValue = getItemSeriesValue(IConstants_PREFIX+"ITEM_TYPE_TRACNET_SUIVI_CLINIQUE_ANAMNESE");
                if(itemValue.length() > 0){
                    addItemRow(table,getTran("openclinic.chuk","tracnet.suivi.clinique.anamnese"),itemValue);
                }

                // Clinical Examination                
                itemValue = getItemSeriesValue(IConstants_PREFIX+"ITEM_TYPE_TRACNET_SUIVI_CLINIQUE_EXAMEN_CLINIQUE");
                if(itemValue.length() > 0){
                    addItemRow(table,getTran("openclinic.chuk","tracnet.suivi.clinique.examen.clinique"),itemValue);
                }
                
                // Diagnosis
                itemValue = getItemSeriesValue(IConstants_PREFIX+"ITEM_TYPE_TRACNET_SUIVI_CLINIQUE_DIAGNOSIS");
                if(itemValue.length() > 0){
                    addItemRow(table,getTran("openclinic.chuk","tracnet.suivi.clinique.diagnosis"),itemValue);
                }

                // CAT
                itemValue = getItemSeriesValue(IConstants_PREFIX+"ITEM_TYPE_TRACNET_SUIVI_CLINIQUE_CAT");
                if(itemValue.length() > 0){
                    addItemRow(table,getTran("openclinic.chuk","tracnet.suivi.clinique.cat"),itemValue);
                }

                if(table.size() > 0){
                    tranTable.addCell(new PdfPCell(table));
                }

                // add transaction to doc
                addTransactionToDoc();
            }
        }
        catch(Exception e){
            e.printStackTrace();
        }
    }
	
}