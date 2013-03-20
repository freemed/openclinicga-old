package be.mxs.common.util.pdf.general.oc.examinations;

import com.itextpdf.text.pdf.PdfPTable;
import be.mxs.common.util.pdf.general.PDFGeneralBasic;


public class PDFMeetingReport extends PDFGeneralBasic {

    //--- ADD CONTENT ------------------------------------------------------------------------------
    protected void addContent(){
        try{
            if(transactionVO.getItems().size() >= minNumberOfItems){
                table = new PdfPTable(5);

                // LABEL (naam)
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_MEETINGREPORT_MEETING");
                if(itemValue.length() > 0){
                    addItemRow(table,getTran("web","meeting"),itemValue);
                }

                // DESCRIPTION
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_MEETINGREPORT_CONCLUSION");
                if(itemValue.length() > 0){
                    addItemRow(table,getTran("web","conclusion"),itemValue);
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

