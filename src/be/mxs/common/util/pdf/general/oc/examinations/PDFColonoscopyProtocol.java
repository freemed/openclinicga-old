package be.mxs.common.util.pdf.general.oc.examinations;

import be.mxs.common.util.pdf.general.PDFGeneralBasic;
import com.itextpdf.text.pdf.PdfPTable;
import com.itextpdf.text.pdf.PdfPCell;

/**
 * User: ssm
 * Date: 18-jul-2007
 */
public class PDFColonoscopyProtocol extends PDFGeneralBasic {

    //--- ADD CONTENT -----------------------------------------------------------------------------
    protected void addContent(){
        try{
            if(transactionVO.getItems().size() >= minNumberOfItems){
                contentTable = new PdfPTable(1);
                table = new PdfPTable(5);

                // motive
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_COLONOSCOPY_PROTOCOL_MOTIVE");
                if(itemValue.length() > 0){
                    addItemRow(table,getTran("openclinic.chuk","motive"),itemValue);
                }

                // premedication
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_COLONOSCOPY_PROTOCOL_PREMEDICATION");
                if(itemValue.length() > 0){
                    addItemRow(table,getTran("openclinic.chuk","premedication"),itemValue);
                }

                // endoscopy_type
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_COLONOSCOPY_PROTOCOL_ENDOSCOPY_TYPE");
                if(itemValue.length() > 0){
                    addItemRow(table,getTran("openclinic.chuk","endoscopy_type"),itemValue);
                }

                // examination_description
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_COLONOSCOPY_PROTOCOL_EXAMINATION_DESCRIPTION");
                if(itemValue.length() > 0){
                    addItemRow(table,getTran("openclinic.chuk","examination_description"),itemValue);
                }

                //*** investigations_done (BIOSCOPY) ***
                String investigations = "";

                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_COLONOSCOPY_PROTOCOL_BIOSCOPY");
                if(itemValue.equalsIgnoreCase("medwan.common.true")){
                    if(investigations.length() > 0) investigations+= ", ";
                    investigations+= getTran("openclinic.chuk","bioscopy");
                }

                /*
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_PROCOTOLOGY_PROTOCOL_BIOSCOPY2");
                if(itemValue.equalsIgnoreCase("medwan.common.true")){
                    if(investigations.length() > 0) investigations+= ", ";
                    investigations+= getTran("openclinic.chuk","bioscopy2");
                }
                */

                if(investigations.length() > 0){
                    addItemRow(table,getTran("openclinic.chuk","investigations_done"),investigations);
                }

                // conclusion
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_COLONOSCOPY_PROTOCOL_CONCLUSION");
                if(itemValue.length() > 0){
                    addItemRow(table,getTran("openclinic.chuk","conclusion"),itemValue);
                }

                // remarks
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_COLONOSCOPY_PROTOCOL_REMARKS");
                if(itemValue.length() > 0){
                    addItemRow(table,getTran("openclinic.chuk","remarks"),itemValue);
                }
                    
                // add table
                if(table.size() > 0){
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

