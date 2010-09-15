package be.mxs.common.util.pdf.general.oc.examinations;

import be.mxs.common.util.pdf.general.PDFGeneralBasic;
import com.lowagie.text.pdf.PdfPTable;
import com.lowagie.text.pdf.PdfPCell;
import com.lowagie.text.Cell;

/**
 * User: ssm
 * Date: 23-jul-2007
 */
public class PDFPhysiotherapyReport extends PDFGeneralBasic {

    //--- ADD CONTENT -----------------------------------------------------------------------------
    protected void addContent(){
        try{
            if(transactionVO.getItems().size() >= minNumberOfItems){
                contentTable = new PdfPTable(1);
                table = new PdfPTable(5);

                // Report
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_PHYSIO_REP_REPORT");
                if(itemValue.length() > 0){
                    addItemRow(table,getTran("Web.Occup","medwan.common.report"),itemValue);
                }

                // Conclusion
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_PHYSIO_REP_CONCLUSION");
                if(itemValue.length() > 0){
                    addItemRow(table,getTran("Web.Occup","medwan.common.conclusion"),itemValue);
                }

                // add table
                if(table.size() > 0){
                    if(contentTable.size() > 0) contentTable.addCell(emptyCell());
                    contentTable.addCell(createCell(new PdfPCell(table),1, Cell.ALIGN_CENTER,Cell.BOX));
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
