package be.mxs.common.util.pdf.general.oc.examinations;

import be.mxs.common.util.pdf.general.PDFGeneralBasic;
import com.itextpdf.text.pdf.PdfPTable;
import com.itextpdf.text.pdf.PdfPCell;

/**
 * User: ssm
 * Date: 18-jul-2007
 */
public class PDFStomatologyOperationProtocol extends PDFGeneralBasic {

    //--- ADD CONTENT -----------------------------------------------------------------------------
    protected void addContent(){
        try{
            if(transactionVO.getItems().size() >= minNumberOfItems){
                contentTable = new PdfPTable(1);
                table = new PdfPTable(5);

                // starthour
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_OPERATION_PROTOCOL_START");
                if(itemValue.length() > 0){
                    addItemRow(table,getTran("openclinic.chuk","starthour"),itemValue);
                }

                // endhour
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_OPERATION_PROTOCOL_END");
                if(itemValue.length() > 0){
                    addItemRow(table,getTran("openclinic.chuk","endhour"),itemValue);
                }

                // duration
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_OPERATION_PROTOCOL_DURATION");
                if(itemValue.length() > 0){
                    addItemRow(table,getTran("openclinic.chuk","duration"),itemValue);
                }

                // diagnostic
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_OPERATION_PROTOCOL_DIAGNOSTIC");
                if(itemValue.length() > 0){
                    addItemRow(table,getTran("openclinic.chuk","diagnostic"),itemValue);
                }

                // intervention
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_OPERATION_PROTOCOL_INTERVENTION");
                if(itemValue.length() > 0){
                    addItemRow(table,getTran("openclinic.chuk","intervention"),itemValue);
                }
                
                //*** lochies *************************************************
                PdfPTable compostitionTable = new PdfPTable(4);

                // surgeons
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_OPERATION_PROTOCOL_SURGEONS");
                if(itemValue.length() > 0){
                    compostitionTable.addCell(createValueCell(getTran("openclinic.chuk","surgeons"),1));
                    compostitionTable.addCell(createValueCell(itemValue,3));
                }

                // anasthesists
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_OPERATION_PROTOCOL_ANASTHESISTS");
                if(itemValue.length() > 0){
                    compostitionTable.addCell(createValueCell(getTran("openclinic.chuk","anasthesists"),1));
                    compostitionTable.addCell(createValueCell(itemValue,3));
                }

                // nurses
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_OPERATION_PROTOCOL_NURSES");
                if(itemValue.length() > 0){
                    compostitionTable.addCell(createValueCell(getTran("openclinic.chuk","nurses"),1));
                    compostitionTable.addCell(createValueCell(itemValue,3));
                }

                // add compostion table
                if(compostitionTable.size() > 1){
                    table.addCell(createItemNameCell(getTran("openclinic.chuk","group.composition"),1));
                    table.addCell(createCell(new PdfPCell(compostitionTable),4,PdfPCell.ALIGN_CENTER,PdfPCell.BOX));
                }
                
                // patient.installation
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_OPERATION_PROTOCOL_PATIENT_INSTALLATION");
                if(itemValue.length() > 0){
                    addItemRow(table,getTran("openclinic.chuk","patient.installation"),itemValue);
                }

                // aproval
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_OPERATION_PROTOCOL_APROVAL");
                if(itemValue.length() > 0){
                    addItemRow(table,getTran("openclinic.chuk","aproval"),itemValue);
                }

                // observations
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_OPERATION_PROTOCOL_OBSERVATION");
                if(itemValue.length() > 0){
                    addItemRow(table,getTran("openclinic.chuk","observations"),itemValue);
                }

                // surgical.act
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_OPERATION_PROTOCOL_SURGICAL_ACT");
                if(itemValue.length() > 0){
                    addItemRow(table,getTran("openclinic.chuk","surgical.act"),itemValue);
                }

                // closure
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_OPERATION_PROTOCOL_CLOSURE");
                if(itemValue.length() > 0){
                    addItemRow(table,getTran("openclinic.chuk","closure"),itemValue);
                }

                // care.post.op
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_OPERATION_PROTOCOL_CARE");
                if(itemValue.length() > 0){
                    addItemRow(table,getTran("openclinic.chuk","care.post.op"),itemValue);
                }

                // remarks
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_OPERATION_PROTOCOL_REMARKS");
                if(itemValue.length() > 0){
                    addItemRow(table,getTran("openclinic.chuk","remarks"),itemValue);
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
