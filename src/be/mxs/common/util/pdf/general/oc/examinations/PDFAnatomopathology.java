package be.mxs.common.util.pdf.general.oc.examinations;

import be.mxs.common.util.pdf.general.PDFGeneralBasic;
import com.lowagie.text.pdf.PdfPTable;
import com.lowagie.text.pdf.PdfPCell;
import com.lowagie.text.Cell;

/**
 * User: ssm
 * Date: 23-jul-2007
 */
public class PDFAnatomopathology extends PDFGeneralBasic {

    //--- ADD CONTENT -----------------------------------------------------------------------------
    protected void addContent(){
        try{
            if(transactionVO.getItems().size() >= minNumberOfItems){
                contentTable = new PdfPTable(1);
                table = new PdfPTable(5);

                // nature
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_ANATOMOPATHOLOGY_NATURE");
                if(itemValue.length() > 0){
                    addItemRow(table,getTran("openclinic.chuk","nature"),itemValue);
                }

                // sample_date
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_ANATOMOPATHOLOGY_SAMPLE_DATE");
                if(itemValue.length() > 0){
                    addItemRow(table,getTran("openclinic.chuk","sample_date"),itemValue);
                }

                // disease_history
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_ANATOMOPATHOLOGY_HISTORY");
                if(itemValue.length() > 0){
                    addItemRow(table,getTran("openclinic.chuk","disease_history"),itemValue);
                }

                // result
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_ANATOMOPATHOLOGY_RESULT");
                if(itemValue.length() > 0){
                    addItemRow(table,getTran("openclinic.chuk","result"),itemValue);
                }

                // declared_valid
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_ANATOMOPATHOLOGY_DECLARED_VALID");
                if(itemValue.length() > 0){
                    addItemRow(table,getTran("openclinic.chuk","declared_valid"),itemValue);
                }

                // add transaction to doc
                if(table.size() > 0){
                    if(contentTable.size() > 0) contentTable.addCell(emptyCell());
                    contentTable.addCell(createCell(new PdfPCell(table),1, Cell.ALIGN_CENTER,Cell.BOX));
                    tranTable.addCell(createContentCell(contentTable));
                    addTransactionToDoc();
                }
            }
        }
        catch(Exception e){
            e.printStackTrace();
        }
    }


    //### PRIVATE METHODS #########################################################################

}

