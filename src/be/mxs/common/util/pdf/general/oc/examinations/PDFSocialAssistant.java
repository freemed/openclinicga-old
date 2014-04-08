package be.mxs.common.util.pdf.general.oc.examinations;

import com.itextpdf.text.pdf.PdfPCell;
import com.itextpdf.text.pdf.PdfPTable;

import be.mxs.common.util.pdf.general.PDFGeneralBasic;

public class PDFSocialAssistant extends PDFGeneralBasic {

    //--- ADD CONTENT -----------------------------------------------------------------------------
    protected void addContent(){
        try{
            if(transactionVO.getItems().size() >= minNumberOfItems){
                contentTable = new PdfPTable(1);
                table = new PdfPTable(5);

                // SOCIAL ASSISTANT
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_SOCIALASSISTANT_NAME");
                if(itemValue.length() > 0){
                    addItemRow(table,getTran("web.occup","socialassistant"),itemValue);
                }                 

                // ACTS
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_SOCIALASSISTANT_ACTS");
                if(itemValue.length() > 0){
                    addItemRow(table,getTran("web.occup","actssocialassistant"),itemValue);
                }                

                // COMMENT
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_SOCIALASSISTANT_COMMENT");
                if(itemValue.length() > 0){
                    addItemRow(table,getTran("web.occup","comment"),itemValue.replaceAll("<br>","\r\n"));
                }

                // add table
                if(table.size() > 0){
                    if(contentTable.size() > 0) contentTable.addCell(emptyCell());
                    contentTable.addCell(createCell(new PdfPCell(table),1,PdfPCell.ALIGN_CENTER,PdfPCell.BOX));
                    tranTable.addCell(new PdfPCell(contentTable));
                    addTransactionToDoc();
                }

                // diagnoses
                addDiagnosisEncoding();
                addTransactionToDoc();
            }
        }
        catch(Exception e){
            e.printStackTrace();
        }
    }
    
}