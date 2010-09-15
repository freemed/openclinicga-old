package be.mxs.common.util.pdf.general.oc.examinations;

import com.lowagie.text.pdf.PdfPTable;
import java.util.Vector;

import be.mxs.common.util.pdf.general.PDFGeneralBasic;


/**
 * User: stijn smets
 * Date: 8-dec-2005
 */
public class PDFCardioVascularRisk extends PDFGeneralBasic {

    //--- ADD CONTENT ------------------------------------------------------------------------------
    protected void addContent(){
        try{
            Vector list = new Vector();
            list.add(IConstants_PREFIX+"ITEM_TYPE_CARDIAL_CLINICAL_EXAMINATION_SYSTOLIC_PRESSURE_LEFT");
            list.add(IConstants_PREFIX+"ext_medidoc_57131a.b");
            list.add(IConstants_PREFIX+"ITEM_TYPE_CE_ROKER");
            list.add(IConstants_PREFIX+"ITEM_TYPE_CARDIOVASCULAR_RISK_NOTICED_PHYSICIAN");
            list.add(IConstants_PREFIX+"ITEM_TYPE_CARDIOVASCULAR_RISK_COMMENT");

            if(verifyList(list)){
                table = new PdfPTable(5);

                // SYSTOLIC PRESSURE
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_CARDIAL_CLINICAL_EXAMINATION_SYSTOLIC_PRESSURE_LEFT");
                if(itemValue.length() > 0){
                    addItemRow(table,getTran(IConstants_PREFIX+"ITEM_TYPE_CARDIAL_CLINICAL_EXAMINATION_SYSTOLIC_PRESSURE_LEFT"),itemValue+" mmHg");
                }

                // CHOLESTEROL
                itemValue = getItemValue(IConstants_PREFIX+"ext_medidoc_57131a.b");
                if(itemValue.length() > 0){
                    addItemRow(table,getTran("medwan.healthrecord.laboratory-examinations.blood.totale-cholesterol"),itemValue+" mg/dl");
                }

                // SMOKING ?
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_CE_ROKER");
                if(itemValue.equalsIgnoreCase("healthrecord.ce.smoker") ||
                   itemValue.equalsIgnoreCase("healthrecord.ce.not_smoker")){
                    addItemRow(table,getTran(IConstants_PREFIX+"ITEM_TYPE_CE_ROKER"),getTran(itemValue));
                }

                // NOTICED PHYSICIAN ?
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_CARDIOVASCULAR_RISK_NOTICED_PHYSICIAN");
                if(itemValue.equalsIgnoreCase("medwan.common.true")){
                    addItemRow(table,getTran(IConstants_PREFIX+"ITEM_TYPE_CARDIOVASCULAR_RISK_NOTICED_PHYSICIAN"),getTran("medwan.common.yes"));
                }
                else if(itemValue.equalsIgnoreCase("medwan.common.false")){
                    addItemRow(table,getTran(IConstants_PREFIX+"ITEM_TYPE_CARDIOVASCULAR_RISK_NOTICED_PHYSICIAN"),getTran("medwan.common.no"));
                }

                // COMMENT
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_CARDIOVASCULAR_RISK_COMMENT");
                if(itemValue.length() > 0){
                    addItemRow(table,getTran(IConstants_PREFIX+"ITEM_TYPE_CARDIOVASCULAR_RISK_COMMENT"),itemValue);
                }

                // add table
                if(table.size() > 0){
                    tranTable.addCell(createContentCell(table));
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
