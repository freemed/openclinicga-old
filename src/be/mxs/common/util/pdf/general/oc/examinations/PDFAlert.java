package be.mxs.common.util.pdf.general.oc.examinations;

import com.itextpdf.text.pdf.PdfPTable;
import be.mxs.common.util.pdf.general.PDFGeneralBasic;


public class PDFAlert extends PDFGeneralBasic {

    //--- ADD CONTENT ------------------------------------------------------------------------------
    protected void addContent(){
        try{
            if(transactionVO.getItems().size() >= minNumberOfItems){
                table = new PdfPTable(5);

                // LABEL (naam)
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_ALERTS_LABEL");
                if(itemValue.length() > 0){
                    addItemRow(table,getTran("medwan.common.name"),itemValue);
                }

                // DESCRIPTION
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_ALERTS_DESCRIPTION");
                if(itemValue.length() > 0){
                    addItemRow(table,getTran("medwan.common.description"),itemValue);
                }

                // EXPIRATION DATE
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_ALERTS_EXPIRATION_DATE");
                if(itemValue.length() > 0){
                    addItemRow(table,getTran("medwan.common.expiration-date"),itemValue);
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

