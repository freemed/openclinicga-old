package be.mxs.common.util.pdf.general.oc.examinations;

import com.itextpdf.text.pdf.PdfPTable;
import be.mxs.common.util.pdf.general.PDFGeneralBasic;


public class PDFMedicalCare extends PDFGeneralBasic {

    //--- ADD CONTENT ------------------------------------------------------------------------------
    protected void addContent(){
        try {
            if(transactionVO.getItems().size() >= minNumberOfItems){
                table = new PdfPTable(5);

                // MEDICAL CARE (textArea)
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_MEDICALCARE_CARE");
                if(itemValue.length() > 0){
                    addItemRow(table,getTran(IConstants_PREFIX+"ITEM_TYPE_MEDICALCARE_CARE"),itemValue);
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
