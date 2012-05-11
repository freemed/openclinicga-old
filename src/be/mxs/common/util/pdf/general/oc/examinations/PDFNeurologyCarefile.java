package be.mxs.common.util.pdf.general.oc.examinations;

import be.mxs.common.util.pdf.general.PDFGeneralBasic;
import com.itextpdf.text.pdf.PdfPTable;
import com.itextpdf.text.pdf.PdfPCell;

/**
 * User: ssm
 * Date: 18-jul-2007
 */
public class PDFNeurologyCarefile extends PDFGeneralBasic {

    //--- ADD CONTENT -----------------------------------------------------------------------------
    protected void addContent(){
        try{
            if(transactionVO.getItems().size() >= minNumberOfItems){
                contentTable = new PdfPTable(1);
                table = new PdfPTable(5);

                // FAMILIAL SITUATION AND LIVING CONDITIONS
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_NEUROLOGY_CAREFILE_FAMILIALSITUATION_AND_LIVINGCONDITIONS");
                if(itemValue.length() > 0){
                    addItemRow(table,getTran("Web.occup","neurology_carefile_familialsituation_and_livingconditions"),itemValue);
                }

                // ACTUAL PROBLEM AND ILLNESS HISTORY
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_NEUROLOGY_CAREFILE_ACTUALPROBLEM_AND_ILLNESSHISTORY");
                if(itemValue.length() > 0){
                    addItemRow(table,getTran("Web.occup","neurology_carefile_actualproblem_and_illnesshistory"),itemValue);
                }

                // PROBLEM CONTEXT
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_NEUROLOGY_CAREFILE_PROBLEMCONTEXT");
                if(itemValue.length() > 0){
                    addItemRow(table,getTran("Web.occup","neurology_carefile_problemcontext"),itemValue);
                }

                // FAMILIAL HISTORY SHORT
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_NEUROLOGY_CAREFILE_FAMILIALHISTORY_SHORT");
                if(itemValue.length() > 0){
                    addItemRow(table,getTran("Web.occup","neurology_carefile_familialhistoryshort"),itemValue);
                }

                // PERSONAL HISTORY SHORT
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_NEUROLOGY_CAREFILE_PERSONALHISTORY_SHORT");
                if(itemValue.length() > 0){
                    addItemRow(table,getTran("Web.occup","neurology_carefile_personalhistoryshort"),itemValue);
                }

                // SOMATIC STATUS
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_NEUROLOGY_CAREFILE_SOMATICSTATUS");
                if(itemValue.length() > 0){
                    addItemRow(table,getTran("Web.occup","neurology_carefile_somaticstatus"),itemValue);
                }

                // NEUROLOGICAL STATUS AND OBJECTIVES
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_NEUROLOGY_CAREFILE_NEUROLOGICALSTATUS_AND_OBJECTIVES");
                if(itemValue.length() > 0){
                    addItemRow(table,getTran("Web.occup","neurology_carefile_neurologicalstatus_and_objectives"),itemValue);
                }

                // PROBLEM HYPOTHESIS
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_NEUROLOGY_CAREFILE_PROBLEMHYPOTHESIS");
                if(itemValue.length() > 0){
                    addItemRow(table,getTran("Web.occup","neurology_carefile_problemhypothesis"),itemValue);
                }

                // DIAGNOSTIC IMPRESSION
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_NEUROLOGY_CAREFILE_DIAGNOSTICIMPRESSION");
                if(itemValue.length() > 0){
                    addItemRow(table,getTran("Web.occup","neurology_carefile_diagnosticimpression"),itemValue);
                }

                // THERAPEUTICAL PROJECT
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_NEUROLOGY_CAREFILE_THERAPEUTICALPROJECT");
                if(itemValue.length() > 0){
                    addItemRow(table,getTran("Web.occup","neurology_carefile_therapeuticalproject"),itemValue);
                }
                    
                // add table
                if(table.size() > 0){
                    if(contentTable.size() > 0) contentTable.addCell(emptyCell());
                    contentTable.addCell(createCell(new PdfPCell(table),1, PdfPCell.ALIGN_CENTER,PdfPCell.BOX));
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

