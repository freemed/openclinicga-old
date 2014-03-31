package be.mxs.common.util.pdf.general.oc.examinations;

import be.mxs.common.util.pdf.general.PDFGeneralBasic;
import com.itextpdf.text.pdf.PdfPTable;
import com.itextpdf.text.pdf.PdfPCell;

/**
 * User: ssm
 * Date: 13-jul-2007
 */
public class PDFAbdominalEchographyProtocol extends PDFGeneralBasic {

    //--- ADD CONTENT -----------------------------------------------------------------------------
    protected void addContent(){
        try{
            if(transactionVO.getItems().size() >= minNumberOfItems){
                contentTable = new PdfPTable(1);
                table = new PdfPTable(10);
                int itemCounter = 0;

                // motive
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_ABDOMINAL_ECHOGRAPHY_PROTOCOL_MOTIVE");
                if(itemValue.length() > 0){
                    addItemRow(table,getTran("openclinic.chuk","motive"),itemValue);
                    itemCounter++;
                }

                // liver
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_ABDOMINAL_ECHOGRAPHY_PROTOCOL_LIVER");
                if(itemValue.length() > 0){
                    addItemRow(table,getTran("openclinic.chuk","liver"),itemValue);
                    itemCounter++;
                }

                // hile
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_ABDOMINAL_ECHOGRAPHY_PROTOCOL_HILE");
                if(itemValue.length() > 0){
                    addItemRow(table,getTran("openclinic.chuk","hile"),itemValue);
                    itemCounter++;
                }

                // vp_diameter
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_ABDOMINAL_ECHOGRAPHY_PROTOCOL_VP_DIAMETER");
                if(itemValue.length() > 0){
                    addItemRow(table,getTran("openclinic.chuk","vp_diameter"),itemValue);
                    itemCounter++;
                }

                // biliary_vesicle
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_ABDOMINAL_ECHOGRAPHY_PROTOCOL_BILIARY_VESICLE");
                if(itemValue.length() > 0){
                    addItemRow(table,getTran("openclinic.chuk","biliary_vesicle"),itemValue);
                    itemCounter++;
                }

                // paroi
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_ABDOMINAL_ECHOGRAPHY_PROTOCOL_PAROI");
                if(itemValue.length() > 0){
                    addItemRow(table,getTran("openclinic.chuk","paroi"),itemValue);
                    itemCounter++;
                }

                // veine_cave
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_ABDOMINAL_ECHOGRAPHY_PROTOCOL_VEINE_CAVE");
                if(itemValue.length() > 0){
                    addItemRow(table,getTran("openclinic.chuk","veine_cave"),itemValue);
                    itemCounter++;
                }

                // aorta
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_ABDOMINAL_ECHOGRAPHY_PROTOCOL_AORTA");
                if(itemValue.length() > 0){
                    addItemRow(table,getTran("openclinic.chuk","aorta"),itemValue);
                    itemCounter++;
                }

                // right_kidney
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_ABDOMINAL_ECHOGRAPHY_PROTOCOL_RIGHT_KIDNEY");
                if(itemValue.length() > 0){
                    addItemRow(table,getTran("openclinic.chuk","right_kidney"),itemValue);
                    itemCounter++;
                }

                // left_kidney
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_ABDOMINAL_ECHOGRAPHY_PROTOCOL_LEFT_KIDNEY");
                if(itemValue.length() > 0){
                    addItemRow(table,getTran("openclinic.chuk","left_kidney"),itemValue);
                    itemCounter++;
                }

                // ascite
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_ABDOMINAL_ECHOGRAPHY_PROTOCOL_ASCITES");
                if(itemValue.length() > 0){
                    addItemRow(table,getTran("openclinic.chuk","ascite"),itemValue);
                    itemCounter++;
                }

                // spleen
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_ABDOMINAL_ECHOGRAPHY_PROTOCOL_SPLEEN");
                if(itemValue.length() > 0){
                    addItemRow(table,getTran("openclinic.chuk","spleen"),itemValue);
                    itemCounter++;
                }

                // pancreas
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_ABDOMINAL_ECHOGRAPHY_PROTOCOL_PANCREAS");
                if(itemValue.length() > 0){
                    addItemRow(table,getTran("openclinic.chuk","pancreas"),itemValue);
                    itemCounter++;
                }

                // right_pleural_effusion
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_ABDOMINAL_ECHOGRAPHY_PROTOCOL_RIGHT_PLEURAL_EFFUSION");
                if(itemValue.length() > 0){
                    addItemRow(table,getTran("openclinic.chuk","right_pleural_effusion"),itemValue);
                    itemCounter++;
                }

                // left_pleural_effusion
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_ABDOMINAL_ECHOGRAPHY_PROTOCOL_LEFT_PLEURAL_EFFUSION");
                if(itemValue.length() > 0){
                    addItemRow(table,getTran("openclinic.chuk","left_pleural_effusion"),itemValue);
                    itemCounter++;
                }

                // precardial_pleural_effusion
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_ABDOMINAL_ECHOGRAPHY_PROTOCOL_PRECARDIAL_PLEURAL_EFFUSION");
                if(itemValue.length() > 0){
                    addItemRow(table,getTran("openclinic.chuk","precardial_pleural_effusion"),itemValue);
                    itemCounter++;
                }

                // conclusion
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_ABDOMINAL_ECHOGRAPHY_PROTOCOL_CONCLUSION");
                if(itemValue.length() > 0){
                    addItemRow(table,getTran("openclinic.chuk","conclusion"),itemValue);
                    itemCounter++;
                }

                // remarks
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_ABDOMINAL_ECHOGRAPHY_PROTOCOL_REMARKS");
                if(itemValue.length() > 0){
                    addItemRow(table,getTran("openclinic.chuk","remarks"),itemValue);
                    itemCounter++;
                }

                // add cell to achieve an even number of displayed cells
                if(itemCounter%2==1){
                    cell = new PdfPCell();
                    cell.setColspan(5);
                    cell.setBorder(PdfPCell.NO_BORDER);
                    table.addCell(cell);
                }

                // add table
                if(table.size() > 0){
                    if(contentTable.size() > 0) contentTable.addCell(emptyCell());
                    contentTable.addCell(createCell(new PdfPCell(table),1, PdfPCell.ALIGN_CENTER,PdfPCell.BOX));
                    tranTable.addCell(createContentCell(contentTable));
                }
                
                addDiagnosisEncoding();
                
                // add transaction to doc
                addTransactionToDoc();
            }
        }
        catch(Exception e){
            e.printStackTrace();
        }
    }

    
    //### PRIVATE METHODS #########################################################################

    //--- ADD ITEM ROW ----------------------------------------------------------------------------
    protected void addItemRow(PdfPTable table, String itemName, String itemValue){
        cell = createItemNameCell(itemName);
        cell.setBackgroundColor(BGCOLOR_LIGHT);
        table.addCell(cell);
        table.addCell(createValueCell(itemValue));
    }
    
}
