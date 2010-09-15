package be.mxs.common.util.pdf.general.oc.examinations;

import be.mxs.common.util.pdf.general.PDFGeneralBasic;
import com.lowagie.text.pdf.PdfPTable;
import com.lowagie.text.pdf.PdfPCell;
import com.lowagie.text.Cell;

/**
 * User: ssm
 * Date: 23-jul-2007
 */
public class PDFPhysiotherapyConsultation extends PDFGeneralBasic {

    //--- ADD CONTENT -----------------------------------------------------------------------------
    protected void addContent(){
        try{
            if(transactionVO.getItems().size() >= minNumberOfItems){
                contentTable = new PdfPTable(1);
                table = new PdfPTable(5);

                // Medical Diagnose
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_PHYSIO_CONS_DIAG_MEDIC");
                if(itemValue.length() > 0){
                    addItemRow(table,getTran("Web.Occup","medwan.common.diagnose_medical"),itemValue);
                }

                // Anamnese
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_PHYSIO_CONS_ANAMNESE");
                if(itemValue.length() > 0){
                    addItemRow(table,getTran("Web.Occup","medwan.common.anamnese"),itemValue);
                }

                // Physical Exam
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_PHYSIO_CONS_EXAM_PHYS");
                if(itemValue.length() > 0){
                    addItemRow(table,getTran("Web.Occup","medwan.common.physical_exam"),itemValue);
                }

                // Physical Diagnose
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_PHYSIO_CONS_DIAG_PHYS");
                if(itemValue.length() > 0){
                    addItemRow(table,getTran("Web.Occup","medwan.common.physical_diagnose"),itemValue);
                }

                // Physical treatment plan
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_PHYSIO_CONS_PLAN_TRAIT_PHYS");
                if(itemValue.length() > 0){
                    addItemRow(table,getTran("Web.Occup","medwan.common.physical_treatment_plan"),itemValue);
                }

                // Reevalution
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_PHYSIO_CONS_REEVAL");
                if(itemValue.length() > 0){
                    addItemRow(table,getTran("Web.Occup","medwan.common.reeval"),itemValue);
                }

                // End Treatment date
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_PHYSIO_CONS_FIN_TRAIT");
                if(itemValue.length() > 0){
                    addItemRow(table,getTran("web.occup","medwan.common.enddate_treatment"),itemValue);
                }
                
                // add table
                if(table.size() > 0){
                    if(contentTable.size() > 0) contentTable.addCell(emptyCell());
                    contentTable.addCell(createCell(new PdfPCell(table),1,Cell.ALIGN_CENTER,Cell.BOX));
                    tranTable.addCell(createContentCell(contentTable));
                }

                // add transaction to doc
                addTransactionToDoc();
            }
        }
        catch(Exception e){
            e.printStackTrace();
        }
    }


    //### PRIVATE METHODS #########################################################################

}

