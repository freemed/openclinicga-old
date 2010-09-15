package be.mxs.common.util.pdf.general.oc.examinations;

import be.mxs.common.util.pdf.general.PDFGeneralBasic;
import com.lowagie.text.pdf.PdfPTable;
import com.lowagie.text.pdf.PdfPCell;
import com.lowagie.text.Cell;

/**
 * User: ssm
 * Date: 18-jul-2007
 */
public class PDFProtocolImagesStomatology extends PDFGeneralBasic {
                    
    //--- ADD CONTENT -----------------------------------------------------------------------------
    protected void addContent(){
        try{
            if(transactionVO.getItems().size() >= minNumberOfItems){
                contentTable = new PdfPTable(1);
                table = new PdfPTable(5);
                
                PdfPTable imagesTable = new PdfPTable(5);

                String sImagesInformation = getItemSeriesValue(IConstants_PREFIX+"ITEM_TYPE_PROTOCOL_IMAGES_STOMATOLOGY_IMG_INFORMATION");
                if(sImagesInformation.indexOf("£")>-1){
                    StringBuffer sTmpImagesInformation = new StringBuffer(sImagesInformation);
                    String sTmpType, sTmpNomenclature, sTmpResultsRx;

                    while (sTmpImagesInformation.toString().toLowerCase().indexOf("$")>-1) {
                        sTmpType = "";
                        if (sTmpImagesInformation.toString().toLowerCase().indexOf("£")>-1){
                            sTmpType = sTmpImagesInformation.substring(0,sTmpImagesInformation.toString().toLowerCase().indexOf("£"));
                            sTmpImagesInformation = new StringBuffer(sTmpImagesInformation.substring(sTmpImagesInformation.toString().toLowerCase().indexOf("£")+1));
                        }

                        sTmpNomenclature  = "";
                        if (sTmpImagesInformation.toString().toLowerCase().indexOf("£")>-1){
                            sTmpNomenclature = sTmpImagesInformation.substring(0,sTmpImagesInformation.toString().toLowerCase().indexOf("£"));
                            sTmpImagesInformation = new StringBuffer(sTmpImagesInformation.substring(sTmpImagesInformation.toString().toLowerCase().indexOf("£")+1));
                        }

                        sTmpResultsRx = "";
                        if (sTmpImagesInformation.toString().toLowerCase().indexOf("$")>-1){
                            sTmpResultsRx = sTmpImagesInformation.substring(0,sTmpImagesInformation.toString().toLowerCase().indexOf("$"));
                            sTmpImagesInformation = new StringBuffer(sTmpImagesInformation.substring(sTmpImagesInformation.toString().toLowerCase().indexOf("$")+1));
                        }

                        // add image record
                        imagesTable = addImageToPDFTable(imagesTable,sTmpType,sTmpNomenclature,sTmpResultsRx);
                    }
                }

                // add images table
                if(imagesTable.size() > 0){
                    table.addCell(createCell(new PdfPCell(imagesTable),5,Cell.ALIGN_CENTER,Cell.NO_BORDER));
                }

                // conclusion
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_PROTOCOL_IMAGES_STOMATOLOGY_CONCLUSION");
                if(itemValue.length() > 0){
                    if(table.size() > 0){
                        // spacer
                        cell = createBorderlessCell(5);
                        cell.setBorder(Cell.NO_BORDER);
                        table.addCell(cell);
                    }
                    
                    addItemRow(table,getTran("openclinic.chuk","conclusion"),itemValue);
                }

                // add table
                if(table.size() > 0){
                    if(contentTable.size() > 0) contentTable.addCell(emptyCell());
                    contentTable.addCell(createCell(new PdfPCell(table),1,Cell.ALIGN_CENTER,Cell.NO_BORDER));
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
                                              
    //--- ADD IMAGE TO PDF TABLE ------------------------------------------------------------------
    private PdfPTable addImageToPDFTable(PdfPTable pdfTable, String sType, String sNomenclature, String sResultsRx){

        // add header if no header yet
        if(pdfTable.size() == 0){
            pdfTable.addCell(createHeaderCell(getTran("web","type"),1));
            pdfTable.addCell(createHeaderCell(getTran("openclinic.chuk","nomenclature"),2));
            pdfTable.addCell(createHeaderCell(getTran("openclinic.chuk","results_rx"),2));
        }
        
        pdfTable.addCell(createValueCell(getTran("web.occup",sType),1));
        pdfTable.addCell(createValueCell(sNomenclature,2));
        pdfTable.addCell(createValueCell(sResultsRx,2));

        return pdfTable;
    }
    
}
