package be.mxs.common.util.pdf.general.oc.examinations;

import be.mxs.common.util.pdf.general.PDFGeneralBasic;
import com.lowagie.text.pdf.PdfPTable;
import com.lowagie.text.pdf.PdfPCell;
import com.lowagie.text.Cell;

import java.util.Vector;

/**
 * User: ssm
 * Date: 18-jul-2007
 */
public class PDFNeurologyTransfer extends PDFGeneralBasic {

    //--- ADD CONTENT -----------------------------------------------------------------------------
    protected void addContent(){
        try{
            if(transactionVO.getItems().size() >= minNumberOfItems){
                Vector list = new Vector();
                list.add(IConstants_PREFIX+"ITEM_TYPE_NEUROLOGY_TRANSFER_TRANSFERDATE");
                list.add(IConstants_PREFIX+"ITEM_TYPE_NEUROLOGY_TRANSFER_CONSULTATIONMOTIF");
                list.add(IConstants_PREFIX+"ITEM_TYPE_NEUROLOGY_TRANSFER_SUMMARY_WORK_DONE_WITH_PATIENT");
                list.add(IConstants_PREFIX+"ITEM_TYPE_NEUROLOGY_TRANSFER_TRANSFERMOTIF");
                list.add(IConstants_PREFIX+"ITEM_TYPE_NEUROLOGY_TRANSFER_TRANSFERTREATMENT");

                if(verifyList(list)){
                    contentTable = new PdfPTable(1);
                    table = new PdfPTable(5);
                    
                    // TRANSFER DATE
                    itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_NEUROLOGY_TRANSFER_TRANSFERDATE");
                    if(itemValue.length() > 0){
                        addItemRow(table,getTran("Web.occup","neurology_transfer_transferdate"),itemValue);
                    }

                    // CONSULTATION MOTIF
                    itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_NEUROLOGY_TRANSFER_CONSULTATIONMOTIF");
                    if(itemValue.length() > 0){
                        addItemRow(table,getTran("Web.occup","neurology_transfer_consultationmotif"),itemValue);
                    }

                    // SUMMARY WORK DONE WITH PATIENT
                    itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_NEUROLOGY_TRANSFER_SUMMARY_WORK_DONE_WITH_PATIENT");
                    if(itemValue.length() > 0){
                        addItemRow(table,getTran("Web.occup","neurology_transfer_summaryworkdonewithpatient"),itemValue);
                    }

                    // TRANSFER MOTIF
                    itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_NEUROLOGY_TRANSFER_TRANSFERMOTIF");
                    if(itemValue.length() > 0){
                        addItemRow(table,getTran("Web.occup","neurology_transfer_transfermotif"),itemValue);
                    }

                    // TRANSFER TREATMENT
                    itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_NEUROLOGY_TRANSFER_TRANSFERTREATMENT");
                    if(itemValue.length() > 0){
                        addItemRow(table,getTran("Web.occup","neurology_transfer_transfertreatment"),itemValue);
                    }

                    // add table
                    if(table.size() > 0){
                        if(contentTable.size() > 0) contentTable.addCell(emptyCell());
                        contentTable.addCell(createCell(new PdfPCell(table),1,Cell.ALIGN_CENTER,Cell.BOX));
                        tranTable.addCell(createContentCell(contentTable));
                        addTransactionToDoc();
                    }
                }
            }
        }
        catch(Exception e){
            e.printStackTrace();
        }
    }


    //### PRIVATE METHODS #########################################################################

}

