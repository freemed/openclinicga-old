package be.mxs.common.util.pdf.general.oc.examinations;

import be.mxs.common.util.db.MedwanQuery;
import be.mxs.common.util.pdf.general.PDFGeneralBasic;
import com.itextpdf.text.pdf.PdfPTable;
import com.itextpdf.text.pdf.PdfPCell;

public class PDFArchiveDocument extends PDFGeneralBasic {

    //--- ADD CONTENT -----------------------------------------------------------------------------
    protected void addContent(){
        try{
            if(transactionVO.getItems().size() >= minNumberOfItems){
                contentTable = new PdfPTable(1);
                table = new PdfPTable(5);
                
                // UDI
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_DOC_UDI");
                if(itemValue.length() > 0){
                    addItemRow(table,getTran("web","udi"),itemValue);
                }
                
                // title
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_DOC_TITLE");
                if(itemValue.length() > 0){
                    addItemRow(table,getTran("web","title"),itemValue);
                }
                
                // description
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_DOC_DESCRIPTION");
                if(itemValue.length() > 0){
                    addItemRow(table,getTran("web","description"),itemValue);
                }
                            
                // category
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_DOC_CATEGORY");
                if(itemValue.length() > 0){
                	if(itemValue.length() > 0) itemValue = getTran("arch.doc.category",itemValue);
                    addItemRow(table,getTran("web","category"),itemValue);
                }
                
                // author
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_DOC_AUTHOR");
                if(itemValue.length() > 0){
                    addItemRow(table,getTran("web","author"),itemValue);
                }
                
                // destination
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_DOC_DESTINATION");
                if(itemValue.length() > 0){
                    addItemRow(table,getTran("web","destination"),itemValue);
                }
                
                // reference
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_DOC_REFERENCE");
                if(itemValue.length() > 0){
                    addItemRow(table,getTran("web","paperReference"),itemValue);
                }
                                
                // storage-name
                String sStorageName = getItemValue(IConstants_PREFIX+"ITEM_TYPE_DOC_STORAGENAME");
                if(sStorageName.length()==0){
                    sStorageName = getTran("web.occup","documentIsBeingProcessed")
                    		       .replaceAll("<i>","")
                    		       .replaceAll("</i>","");
                }
                else{
                	// show link to open document, when server is configured
                	String sServer = MedwanQuery.getInstance().getConfigString("scanDirectoryMonitor_url","http://localhost/openclinic/scan")+"/"+
                	                 MedwanQuery.getInstance().getConfigString("scanDirectoryMonitor_dirTo","to");
                	if(sServer.length() > 0){
                        sStorageName = sServer+"/"+sStorageName;
                        sStorageName = sStorageName.replaceAll("http://","http:///");
                        sStorageName = sStorageName.replaceAll("//","/");
                    }
                }
                
                if(sStorageName.length() > 0){
                    addItemRow(table,getTran("web","storageName"),sStorageName);
                }
                
                // add transaction to doc
                if(table.size() > 0){
                    if(contentTable.size() > 0) contentTable.addCell(emptyCell());
                    contentTable.addCell(createCell(new PdfPCell(table),1,PdfPCell.ALIGN_CENTER,PdfPCell.BOX));
                    tranTable.addCell(new PdfPCell(contentTable));
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