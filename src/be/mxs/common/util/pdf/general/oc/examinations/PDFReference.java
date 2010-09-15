package be.mxs.common.util.pdf.general.oc.examinations;

import be.mxs.common.util.pdf.general.PDFGeneralBasic;
import com.lowagie.text.pdf.PdfPTable;
import com.lowagie.text.pdf.PdfPCell;
import com.lowagie.text.Cell;
import com.lowagie.text.Paragraph;
import com.lowagie.text.FontFactory;
import com.lowagie.text.Font;

import java.util.Vector;

/**
 * User: ssm
 * Date: 18-jul-2007
 */
public class PDFReference extends PDFGeneralBasic {

    //--- ADD CONTENT -----------------------------------------------------------------------------
    protected void addContent(){
        try{
            if(transactionVO.getItems().size() >= minNumberOfItems){
                Vector list = new Vector();
                list.add(IConstants_PREFIX+"ITEM_TYPE_REFERENCE_REF_CENTR");
                list.add(IConstants_PREFIX+"ITEM_TYPE_REFERENCE_ANAMNESE");
                list.add(IConstants_PREFIX+"ITEM_TYPE_REFERENCE_EXAM_COMPL");
                list.add(IConstants_PREFIX+"ITEM_TYPE_REFERENCE_TRAIT_RECU");
                list.add(IConstants_PREFIX+"ITEM_TYPE_REFERENCE_RAISON_TRANSF");

                if(verifyList(list)){
                    contentTable = new PdfPTable(1);
                    table = new PdfPTable(10);
                    int itemCounter = 0;

                    // title
                    table.addCell(createTitleCell(getTran("Web.Occup","medwan.common.reference"),10));

                    //*** REFERENCE ***********************************************
                    // reference center
                    itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_REFERENCE_REF_CENTR");
                    if(itemValue.length() > 0){
                        cell = createItemNameCell(getTran("Web.Occup","medwan.common.reference_centre"),2);
                        cell.setBackgroundColor(BGCOLOR_LIGHT);
                        table.addCell(cell);
                        
                        table.addCell(createValueCell(itemValue,8));
                    }

                    // Anamnese
                    itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_REFERENCE_ANAMNESE");
                    if(itemValue.length() > 0){
                        addItemRow(table,getTran("Web.Occup","medwan.common.anamnese"),itemValue);
                        itemCounter++;
                    }

                    // Complementary exams
                    itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_REFERENCE_EXAM_COMPL");
                    if(itemValue.length() > 0){
                        addItemRow(table,getTran("Web.Occup","medwan.common.complementary_exams"),itemValue);
                        itemCounter++;
                    }

                   // Treatment Recieved
                    itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_REFERENCE_TRAIT_RECU");
                    if(itemValue.length() > 0){
                        addItemRow(table,getTran("Web.Occup","medwan.common.treatement_recieved"),itemValue);
                        itemCounter++;
                    }

                    // Transfer reason
                    itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_REFERENCE_RAISON_TRANSF");
                    if(itemValue.length() > 0){
                        addItemRow(table,getTran("Web.Occup","medwan.common.transfer_reason"),itemValue);
                        itemCounter++;
                    }

                    // add cell to achieve an even number of displayed cells
                    if(itemCounter%2==1){
                        cell = new PdfPCell();
                        cell.setColspan(10);
                        cell.setBorder(Cell.NO_BORDER);
                        table.addCell(cell);
                    }

                    // add table
                    if(table.size() > 0){
                        if(contentTable.size() > 0) contentTable.addCell(emptyCell());
                        contentTable.addCell(createCell(new PdfPCell(table),1,Cell.ALIGN_CENTER,Cell.BOX));
                    }
                }
                
                //*** CONTRA REFERENCE ****************************************
                list = new Vector();
                list.add(IConstants_PREFIX+"ITEM_TYPE_REFERENCE_ID_REF");
                list.add(IConstants_PREFIX+"ITEM_TYPE_REFERENCE_RESULTS_SIGNIF");
                list.add(IConstants_PREFIX+"ITEM_TYPE_REFERENCE_DIAGN");
                list.add(IConstants_PREFIX+"ITEM_TYPE_REFERENCE_TRAIT_RECU_INTERV");
                list.add(IConstants_PREFIX+"ITEM_TYPE_REFERENCE_RECOM_TRAIT_SUIVRE");

                if(verifyList(list)){
                    table = new PdfPTable(10);
                    int itemCounter = 0;

                    // title
                    table.addCell(createTitleCell(getTran("Web.Occup","medwan.common.contre_reference"),10));

                    // Reference ID
                    itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_REFERENCE_ID_REF");
                    if(itemValue.length() > 0){
                        cell = createItemNameCell(getTran("Web.Occup","medwan.common.reference_id"),2);
                        cell.setBackgroundColor(BGCOLOR_LIGHT);
                        table.addCell(cell);
                        
                        table.addCell(createValueCell(itemValue,8));
                    }

                    // Significal results
                    itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_REFERENCE_RESULTS_SIGNIF");
                    if(itemValue.length() > 0){
                        addItemRow(table,getTran("Web.Occup","medwan.common.significal_results"),itemValue);
                        itemCounter++;
                    }

                    // Diagnostic
                    itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_REFERENCE_DIAGN");
                    if(itemValue.length() > 0){
                        addItemRow(table,getTran("Web.Occup","medwan.common.diagnostic"),itemValue);
                        itemCounter++;
                    }

                    // treatment recieved and intervention
                    itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_REFERENCE_TRAIT_RECU_INTERV");
                    if(itemValue.length() > 0){
                        addItemRow(table,getTran("Web.Occup","medwan.common.treatment_received_intervention"),itemValue);
                        itemCounter++;
                    }

                    // Recommendations/treatment to follow
                    itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_REFERENCE_RECOM_TRAIT_SUIVRE");
                    if(itemValue.length() > 0){
                        addItemRow(table,getTran("Web.Occup","medwan.common.recommendations_treatment_to_follow"),itemValue);
                        itemCounter++;
                    }

                    // add cell to achieve an even number of displayed cells
                    if(itemCounter%2==1){
                        cell = new PdfPCell();
                        cell.setColspan(10);
                        cell.setBorder(Cell.NO_BORDER);
                        table.addCell(cell);
                    }
                    
                    
                    // add table
                    if(table.size() > 0){
                        cell = createBorderlessCell("",1);
                        cell.setBorder(Cell.NO_BORDER);
                        if(contentTable.size() > 0) contentTable.addCell(cell);

                        contentTable.addCell(createCell(new PdfPCell(table),1,Cell.ALIGN_CENTER,Cell.BOX));
                        tranTable.addCell(createContentCell(contentTable));
                    }
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

    //--- ADD ITEM ROW ----------------------------------------------------------------------------
    protected void addItemRow(PdfPTable table, String itemName, String itemValue){
        cell = createItemNameCell(itemName);
        cell.setBackgroundColor(BGCOLOR_LIGHT);
        table.addCell(cell);
        table.addCell(createValueCell(itemValue));
    }
    
    //--- CREATE CONTENT CELL ----------------------------------------------------------------------
    protected PdfPCell createContentCell(String value){
        cell = new PdfPCell(new Paragraph(value, FontFactory.getFont(FontFactory.HELVETICA,7,Font.NORMAL)));
        cell.setColspan(1);
        cell.setBorder(Cell.BOX);
        cell.setBorderColor(innerBorderColor);
        cell.setVerticalAlignment(Cell.ALIGN_MIDDLE);
        cell.setHorizontalAlignment(Cell.ALIGN_CENTER); // difference

        return cell;
    }
}