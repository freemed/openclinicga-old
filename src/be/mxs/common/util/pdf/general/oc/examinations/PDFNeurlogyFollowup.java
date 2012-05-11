package be.mxs.common.util.pdf.general.oc.examinations;

import be.mxs.common.util.pdf.general.PDFGeneralBasic;
import com.itextpdf.text.pdf.PdfPTable;
import com.itextpdf.text.pdf.PdfPCell;

/**
 * User: ssm
 * Date: 18-jul-2007
 */
public class PDFNeurlogyFollowup extends PDFGeneralBasic {

    //--- ADD CONTENT -----------------------------------------------------------------------------
    protected void addContent(){
        try{
            if(transactionVO.getItems().size() >= minNumberOfItems){
                contentTable = new PdfPTable(1);
                table = new PdfPTable(5);

                // DESCRIPTION
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_NEUROLOGY_FOLLOWUP_DESCRIPTION");
                if(itemValue.length() > 0){
                    addItemRow(table,getTran("Web.occup","neurology_followup_description"),itemValue);
                }
                
                // THERAPEUTICAL MODIFICATIONS
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_NEUROLOGY_FOLLOWUP_THERAPEUTICAL_MODIFICATIONS");
                if(itemValue.length() > 0){
                    addItemRow(table,getTran("Web.occup","neurology_followup_therapeutical_modifications"),itemValue);
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

