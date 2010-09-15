package be.mxs.common.util.pdf.general.oc.examinations;

import be.mxs.common.util.pdf.general.PDFGeneralBasic;
import com.lowagie.text.pdf.PdfPTable;
import com.lowagie.text.pdf.PdfPCell;
import com.lowagie.text.Cell;

import java.util.Vector;

/**
 * User: ssm
 * Date: 18-jul-2007
 */
public class PDFPostPartumMother extends PDFGeneralBasic {

    //--- ADD CONTENT -----------------------------------------------------------------------------
    protected void addContent(){
        try{
            if(transactionVO.getItems().size() >= minNumberOfItems){
                Vector list = new Vector();
                list.add(IConstants_PREFIX+"ITEM_TYPE_CARDIAL_CLINICAL_EXAMINATION_SYSTOLIC_PRESSURE_LEFT");
                list.add(IConstants_PREFIX+"ITEM_TYPE_CARDIAL_CLINICAL_EXAMINATION_DIASTOLIC_PRESSURE_LEFT");
                list.add(IConstants_PREFIX+"ITEM_TYPE_BIOMETRY_WEIGHT");
                list.add(IConstants_PREFIX+"ITEM_TYPE_BIOMETRY_TEMPERATURE");
                list.add(IConstants_PREFIX+"ITEM_TYPE_PPM_CONJUNCTIVA");
                list.add(IConstants_PREFIX+"ITEM_TYPE_PPM_LOSS");
                list.add(IConstants_PREFIX+"ITEM_TYPE_PPM_BREAST");
                list.add(IConstants_PREFIX+"ITEM_TYPE_PPM_OBSERVATION");
                list.add(IConstants_PREFIX+"ITEM_TYPE_PPM_TREATMENT");
                list.add(IConstants_PREFIX+"ITEM_TYPE_PPM_ASPECT");
                list.add(IConstants_PREFIX+"ITEM_TYPE_PPM_ODEUR");
                list.add(IConstants_PREFIX+"ITEM_TYPE_PPM_CONCLUSION");
                list.add(IConstants_PREFIX+"ITEM_TYPE_PPM_LOCHIES_CONCLUSION_REMARK");

                if(verifyList(list)){
                    contentTable = new PdfPTable(1);
                    table = new PdfPTable(10);
                    int itemCount = 0;

                    //*** bloodpressure ***
                    String sysLeft = getItemValue(IConstants_PREFIX+"ITEM_TYPE_CARDIAL_CLINICAL_EXAMINATION_SYSTOLIC_PRESSURE_LEFT"),
                           diaLeft = getItemValue(IConstants_PREFIX+"ITEM_TYPE_CARDIAL_CLINICAL_EXAMINATION_DIASTOLIC_PRESSURE_LEFT");
                    String bloodpressure = sysLeft+" / "+diaLeft+" mmHg";

                    if(sysLeft.length() > 0 || diaLeft.length() > 0){
                        addItemRow(table,getTran("openclinic.chuk","bloodpressure"),bloodpressure);
                        itemCount++;
                    }

                    // weight
                    itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_BIOMETRY_WEIGHT");
                    if(itemValue.length() > 0){
                        addItemRow(table,getTran("openclinic.chuk","weight"),itemValue);
                        itemCount++;
                    }

                    // temperature
                    itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_BIOMETRY_TEMPERATURE");
                    if(itemValue.length() > 0){
                        addItemRow(table,getTran("openclinic.chuk","temperature"),itemValue);
                        itemCount++;
                    }

                    // paleness.conjunctiva
                    itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_PPM_CONJUNCTIVA");
                    if(itemValue.length() > 0){
                        addItemRow(table,getTran("openclinic.chuk","paleness.conjunctiva"),itemValue);
                        itemCount++;
                    }

                    // loss
                    itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_PPM_LOSS");
                    if(itemValue.length() > 0){
                        addItemRow(table,getTran("openclinic.chuk","loss"),itemValue);
                        itemCount++;
                    }

                    // breast
                    itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_PPM_BREAST");
                    if(itemValue.length() > 0){
                        addItemRow(table,getTran("openclinic.chuk","breast"),itemValue);
                        itemCount++;
                    }

                    // observation
                    itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_PPM_OBSERVATION");
                    if(itemValue.length() > 0){
                        addItemRow(table,getTran("openclinic.chuk","observation"),itemValue);
                        itemCount++;
                    }

                    // treatment
                    itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_PPM_TREATMENT");
                    if(itemValue.length() > 0){
                        addItemRow(table,getTran("openclinic.chuk","treatment"),itemValue);
                        itemCount++;
                    }

                    // add cell to achieve an even number of displayed cells
                    if(itemCount%2==1){
                        cell = new PdfPCell();
                        cell.setColspan(5);
                        cell.setBorder(Cell.NO_BORDER);
                        table.addCell(cell);
                    }

                    // todo : lochies
                    //*** lochies *************************************************
                    PdfPTable lochiesTable = new PdfPTable(4);

                    // aspect
                    itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_PPM_ASPECT");
                    if(itemValue.length() > 0){
                        lochiesTable.addCell(createItemNameCell(getTran("gynaeco","lochies.aspect"),1));
                        lochiesTable.addCell(createValueCell(getTran("web.occup",itemValue).toLowerCase(),3));
                    }

                    // odeur
                    itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_PPM_ODEUR");
                    if(itemValue.length() > 0){
                        lochiesTable.addCell(createItemNameCell(getTran("gynaeco","lochies.odeur"),1));
                        lochiesTable.addCell(createValueCell(getTran("web.occup",itemValue).toLowerCase(),3));
                    }

                    // conclusion
                    itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_PPM_CONCLUSION");
                    if(itemValue.length() > 0){
                        itemValue = itemValue.substring(itemValue.lastIndexOf(".")+1);   
                        lochiesTable.addCell(createItemNameCell(getTran("gynaeco","lochies.conclusion"),1));
                        lochiesTable.addCell(createValueCell(getTran("gynaeco.conclusion",itemValue).toLowerCase(),3));
                    }

                    // remark
                    itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_PPM_LOCHIES_CONCLUSION_REMARK");
                    if(itemValue.length() > 0){
                        lochiesTable.addCell(createItemNameCell(getTran("gynaeco","lochies.remark"),1));
                        lochiesTable.addCell(createValueCell(itemValue,3));
                    }

                    // add lochies table
                    if(lochiesTable.size() > 0){
                        // title
                        cell = createItemNameCell(getTran("gynaeco","lochies"),2);
                        cell.setBackgroundColor(BGCOLOR_LIGHT);
                        table.addCell(cell);

                        table.addCell(createCell(new PdfPCell(lochiesTable),8,Cell.ALIGN_CENTER,Cell.BOX));
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

