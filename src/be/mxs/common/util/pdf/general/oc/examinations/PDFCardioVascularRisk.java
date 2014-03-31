package be.mxs.common.util.pdf.general.oc.examinations;

import com.itextpdf.text.pdf.PdfPCell;
import com.itextpdf.text.pdf.PdfPTable;
import java.util.Vector;

import be.mxs.common.util.pdf.general.PDFGeneralBasic;
import be.mxs.common.util.system.ScreenHelper;


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
                    addItemRow(table,getTran("Web.Occup",ScreenHelper.ITEM_PREFIX+"item_type_recruitment_sce_sbp"),itemValue+" mmHg");
                }

                // CHOLESTEROL
                itemValue = getItemValue(IConstants_PREFIX+"ext_medidoc_57131a.b");
                if(itemValue.length() > 0){
                    addItemRow(table,getTran("web.occup","medwan.healthrecord.laboratory-examinations.blood.totale-cholesterol"),itemValue+" mg/dl");
                }

                // SMOKING ?
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_CE_ROKER");
                if(itemValue.equalsIgnoreCase("healthrecord.ce.smoker") || itemValue.equalsIgnoreCase("healthrecord.ce.not_smoker")){
                    addItemRow(table,getTran("web.occup","smoking"),getTran(itemValue));
                }

                // NOTICED PHYSICIAN ?
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_CARDIOVASCULAR_RISK_NOTICED_PHYSICIAN");
                if(itemValue.equalsIgnoreCase("medwan.common.true")){
                    addItemRow(table,getTran("Web.occup","noticed_physician"),getTran("medwan.common.yes"));
                }
                else if(itemValue.equalsIgnoreCase("medwan.common.false")){
                    addItemRow(table,getTran("web.occup","noticed_physician"),getTran("medwan.common.no"));
                }

                // COMMENT
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_CARDIOVASCULAR_RISK_COMMENT");
                if(itemValue.length() > 0){
                    addItemRow(table,getTran("web","comment"),itemValue);
                }

                // add table
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
