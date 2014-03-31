package be.mxs.common.util.pdf.general.oc.examinations;

import com.itextpdf.text.pdf.PdfPCell;
import com.itextpdf.text.pdf.PdfPTable;
import be.openclinic.healthrecord.Document;

import be.mxs.common.util.pdf.general.PDFGeneralBasic;
import be.mxs.common.util.system.ScreenHelper;

public class PDFExternalDocument extends PDFGeneralBasic {

    //--- ADD CONTENT ------------------------------------------------------------------------------
    protected void addContent(){
        try{
            if(transactionVO.getItems().size() >= minNumberOfItems){
                table = new PdfPTable(5);

                // TITLE
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_EXTERNAL_DOCUMENT_TITLE");
                if(itemValue.length() > 0){
                    addItemRow(table,getTran("web","title"),itemValue);
                }

                // DOCUMENTS
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_EXTERNAL_DOCUMENT_TITLE");
                if(itemValue.length() > 0){                    
                    // documents table
                    PdfPTable docsTable = new PdfPTable(1);
                    String sDocumentIds = getItemType(transactionVO.getItems(),ScreenHelper.ITEM_PREFIX+"ITEM_TYPE_EXTERNAL_DOCUMENT_DOCUMENTS");

                    String[] aDocumentIds = sDocumentIds.split(";");

                    for(int i=0; i<aDocumentIds.length; i++){
                        if(checkString(aDocumentIds[i]).length() > 0){
                        	String sDocName = Document.getName(aDocumentIds[i]);
                        	sDocName = sDocName.substring(sDocName.indexOf("_")+1);
                        	
                        	docsTable.addCell(createValueCell(sDocName,1));                        	
                        }
                    }

                    if(docsTable.size() > 0){
                        table.addCell(createItemNameCell(getTran("web","documents"),2));
                    	table.addCell(createCell(new PdfPCell(docsTable),3,PdfPCell.ALIGN_CENTER,PdfPCell.BOX));
                    }
                }

                // add table
                if(table.size() > 0){
                    tranTable.addCell(new PdfPCell(table));
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
